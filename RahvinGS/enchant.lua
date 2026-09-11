--------------------------------------------------------------------------
--===              RahvinGS -- GearSwap Engine for FFXI              ===--
--===       DO NOT MODIFY THIS FILE - ONLY MODIFY JOB FILES          ===--
--------------------------------------------------------------------------
-- Copyright (c) 2026 Rahvin
-- Released under the MIT License. See LICENSE.md.
--
-- Derived from Mirdain-Include (github.com/Mirdain/Gearswap) Copyright (c)
-- 2020 Mirdain, used with the author's permission. The monolithic include
-- has been decomposed into components and substantially rewritten; portions
-- of the original remain, and the job-file API is preserved for compatibility.
--
-- See https://github.com/rahvincode for the latest version.
-- README.md covers installation, features, commands and troubleshooting.
--------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- COMPONENT: enchant -- section 13: the enchanted item engine and the lock modes
----------------------------------------------------------------------------------------------------
-- CONTENTS
--   Section 13 - Enchanted item engine. Slot constants and the slot chooser, the item
--   index, the two timing reads and the throttled cooldown warning, the use state machine
--   and its tick, and the lock modes that wear an item and hold its slot indefinitely.
--
-- TWO FEATURES, ONE SET OF GUARDS. An item USE equips, waits out the delay, sends the
--          /item and gives the slot back; a LOCK MODE equips and simply keeps the slot.
--          They live together because they fail in the same ways -- item not carried, item
--          unwearable, slot already claimed by something that outranks them -- so the
--          guards, the slot chooser and the refusal wording are shared.
--
-- ONE STATE MACHINE, NO COROUTINES. E.ench_active is either a use in progress or nil.
--          That is what makes two overlapping uses impossible, and it is also why nothing
--          survives a reload: a use in flight when the engine reloads simply ceases, and
--          the slot it held is freed by the root's load-time release.
--
-- THE TICK RUNS ON A RAW HANDLER. enchantment_tick is driven from the Hoxne component's
--          prerender driver, four times a second. An equip() issued from a raw handler is
--          DISCARDED, so the tick never equips: it sends itself gs c enchrepair and the
--          wrapped command does the work. player.equipment is stale there too, which is why
--          every "is it still worn" test reads the bag copy's status byte instead.
--
-- EXPORTS  The block at the end, plus ench_active, initialized here where the state machine
--          uses it, and ench_held_slot, which this file assigns while the equip component
--          declares it, beside the rest of slot ownership. Five of them feed the Hoxne
--          component, which is built on this one: ENCH_BAGS, find_enchantment,
--          enchantment_waits, warn_unavailable and enchantment_tick. The others go to
--          commands, builders and th; the two fields are read from commands, equip,
--          display, hoxne and lifecycle. Two globals: use_enchantment, called by the
--          enchanted-item commands, and enchantment_completed, called from the action
--          handler when the server confirms a use.
-- LOADS    Fifth of fifteen, before Hoxne on purpose. equip_set_command (the root) and
--          display_box_update (display) resolve LATE: both are globals reached at call time
--          from lock_mode, and neither may be bound to a local in the import block.

-- requires: rahvings/state, rahvings/core, rahvings/equip
return function(E)
    -- Immutable dependencies bound once at construction, so no call below repeats the lookup
    -- for them. The cross-component mutables are never bound here: ench_active,
    -- ench_held_slot, locked_n and is_moving are reached through E at every touch, because a
    -- file-local copy would not be the one the other components read and write.
    -- The slot-ownership helpers -- locked, slot_claim, release_slot, unlock_slot -- all come
    -- from the equip component, which is the single arbiter of who owns a slot.
    local CANON_SLOT, HOLDER_NAME, extdata, res  = E.CANON_SLOT, E.HOLDER_NAME, E.extdata, E.res
    local verify_stripped_slots, report_refused  = E.verify_stripped_slots, E.report_refused
    local verify_disabled_slots                  = E.verify_disabled_slots
    local gs_equip, have_item, unwearable_reason = E.gs_equip, E.have_item, E.unwearable_reason
    local locked, locked_slot_of, release_slot   = E.locked, E.locked_slot_of, E.release_slot
    local slot_claim, unlock_slot                = E.slot_claim, E.unlock_slot
    local verify_weapon_lock                     = E.verify_weapon_lock

    ------------------------------------------------------------------------------------------------
    -- SECTION 13 - ENCHANTED ITEM ENGINE
    ------------------------------------------------------------------------------------------------
    -- Everything behind gs c use, the shortcut commands built on it, and the two lock modes.

    -- Constants -----------------------------------------------------------------------------------

    -- Resource slot id to GearSwap slot name. This mirrors GearSwap's own default_slot_map
    -- (statics.lua:97-99), which is how player.equipment is keyed -- the two must agree or
    -- every worn test reads nothing.
    local ENCH_SLOT_NAMES                        = {
        [0] = 'main',
        [1] = 'sub',
        [2] = 'range',
        [3] = 'ammo',
        [4] = 'head',
        [5] = 'body',
        [6] = 'hands',
        [7] = 'legs',
        [8] = 'feet',
        [9] = 'neck',
        [10] = 'waist',
        [11] = 'left_ear',
        [12] = 'right_ear',
        [13] = 'left_ring',
        [14] = 'right_ring',
        [15] = 'back',
    }

    -- Choose the slot an item should go in, in strict order of preference: one where it is
    -- ALREADY WORN, then one NO LAYER CLAIMS, then the FIRST it fits.
    --
    -- Each term earns its place. Preferring a worn copy avoids moving an item that is
    -- already in position. The middle term is what keeps a two-slot item -- a ring, an
    -- earring -- off a hand something else is holding while the other hand is free. And
    -- falling through to the first slot regardless is correct for a USE, which outranks a
    -- lock and may take the slot when it must; the lock path deliberately does not accept
    -- that fall-through, and re-tests the claim itself.
    local function pick_slot(row, name)
        local worn, free, first
        for id = 0, 15 do
            if row.slots:contains(id) then
                local s = ENCH_SLOT_NAMES[id]
                first = first or s
                if player.equipment[s] == name then worn = worn or s end
                if not slot_claim(s) then free = free or s end
            end
        end
        return worn or free or first
    end

    -- Bags that can hold equippable gear: inventory, then wardrobes 1 through 8.
    local ENCH_BAGS = { 0, 8, 10, 11, 12, 13, 14, 15, 16 }

    -- A five-hour epoch correction, and it is not optional. Windower's extdata library
    -- decodes enchantment timestamps against 2001-12-31 10:00 UTC (extdata.lua:1180), while
    -- the server's epoch is midnight 2002-01-01 JST. Every decoded timestamp therefore lands 18000 seconds
    -- early -- which silently hides EVERY cooldown shorter than five hours, meaning almost
    -- all of them. Without this the engine would believe every item was always ready.
    local EXTDATA_TS_CORRECTION = 18000

    -- The server keeps refusing a use for roughly three seconds past the listed equip delay
    -- or recast boundary, so every wait computed below carries this margin.
    local ENCH_ACTIVATION_BUFFER = 3

    -- Item lookup ---------------------------------------------------------------------------------

    -- The item index: lowercased name to resource row, built once on first use rather than
    -- at load, so a session that never uses an enchanted item never pays for it.
    --
    -- Both name fields are indexed, because a self command arrives lowercased while many
    -- items carry a mixed-case log name. The order is deliberate: real item names are
    -- indexed FIRST, in a separate pass, so one item's log name can never shadow another
    -- item's actual name.
    --
    -- Membership is derived from the game's own data rather than a hand-kept list: any item
    -- with a cast delay that can target the player is usable this way, which is currently
    -- 530 of them.
    local ench_index
    local function build_ench_index()
        ench_index = {}
        -- What makes an item usable this way: a cast delay, and the ability to target the
        -- player. Both come from the game's own item data, so the set tracks the game.
        local function usable(row)
            return row.cast_delay and row.targets and row.targets:contains('Self')
        end
        for _, row in pairs(res.items) do
            if usable(row) then
                local k = row.en:lower()
                ench_index[k] = ench_index[k] or row
            end
        end
        for _, row in pairs(res.items) do
            if usable(row) and row.enl then
                local k = row.enl:lower()
                ench_index[k] = ench_index[k] or row
            end
        end
    end

    -- Find an item and read its live enchantment data in one bag walk. Returns four things:
    -- the resource row, the decoded extdata, whether it is carried at all, and whether that
    -- copy is currently worn. Callers need different subsets, and one walk answers them all.
    local function find_enchantment(name)
        if not ench_index then build_ench_index() end
        local row = ench_index[tostring(name):lower():trim()]
        if not row then return nil, nil, false end
        for _, bag_id in ipairs(ENCH_BAGS) do
            local bag = windower.ffxi.get_items(bag_id)
            if bag then
                for _, it in ipairs(bag) do
                    if type(it) == 'table' and it.id == row.id then
                        local ok, ext = pcall(extdata.decode, it)
                        -- Status 5 on the bag copy means the item is worn. It is the same
                        -- field GearSwap's own equip pipeline trusts (equip_processing.lua
                        -- :139), and it is live server state -- unlike player.equipment,
                        -- which GearSwap refreshes only as a wrapped event begins
                        -- (flow.lua:59-60) and which is therefore stale on the raw handler
                        -- this is reached from.
                        return row, (ok and ext) or nil, true, (it.status == 5)
                    end
                end
            end
        end
        return row, nil, false
    end

    -- Timing and warnings -------------------------------------------------------------------------

    -- The two waits that gate a use, in seconds: the RECAST and the EQUIP DELAY.
    --
    -- They are returned separately because they deserve opposite treatment, and conflating
    -- them is the mistake this shape prevents. A recast cannot be waited out while the item
    -- is worn, lasts minutes or hours, and is worth refusing a command over with the time
    -- named. An equip delay just means the item needs to stay on a few seconds longer, which
    -- is exactly what the engine is about to do anyway -- so it passes silently.
    local function enchantment_waits(ext)
        if not ext then return nil, nil end
        local now_t = os.time() - EXTDATA_TS_CORRECTION
        local recast, activation = 0, 0
        if ext.next_use_time then
            recast = (ext.next_use_time - now_t) + ENCH_ACTIVATION_BUFFER
        end
        if ext.activation_time then
            activation = (ext.activation_time - now_t) + ENCH_ACTIVATION_BUFFER
        end
        if recast < 0 then recast = 0 end
        if activation < 0 then activation = 0 end
        -- Both clocks read ready and the item still says it is not usable. Trust the item.
        -- The unknown wait is reported as an equip delay rather than a cooldown, because
        -- that is the interpretation that waits quietly instead of refusing the player.
        -- The 5 is a POLL INTERVAL, not a countdown -- nothing decrements it, and asking
        -- again in five seconds is the only way to learn more.
        if recast == 0 and activation == 0 and ext.usable == false then
            activation = 5
        end
        return recast, activation
    end

    -- Report an item as on cooldown, throttled per item until it is genuinely back.
    --
    -- The throttle exists for the automated caller: the Hoxne tick asks once a second, and
    -- without it a long cooldown would print once a second for its whole duration. A typed
    -- command passes `always`, which answers unconditionally AND leaves the throttle
    -- untouched -- so the two callers cannot silence one another in either direction.
    -- `always` marks the caller that answers a command the player just typed, and it also
    -- chooses the channel: a typed use is answered on the ungated notice whatever the
    -- toggles say, while the tick's own throttled warning stays on info.
    local ench_warned = {}
    local function warn_unavailable(row, wait, always)
        if not always then
            local ready_at = os.time() + math.ceil(wait)
            if (ench_warned[row.id] or 0) >= ready_at then return end
            ench_warned[row.id] = ready_at
        end
        local say = always and notice or info
        if wait >= 3600 then
            say(('%s is on cooldown [%dh %dm].'):format(
                row.en, math.floor(wait / 3600), math.floor(wait % 3600 / 60)))
        else
            say(('%s is on cooldown [%d:%02d].'):format(
                row.en, math.floor(wait / 60), math.floor(wait % 60)))
        end
    end

    -- Use state machine ---------------------------------------------------------------------------

    -- The one use in progress, or nil. Only use_enchantment sets this, which is what
    -- guarantees two uses can never overlap. Inside this file only finish_enchantment clears
    -- it -- the cancel, the completion and the tick all route through that one function --
    -- and the job-file teardown clears it outright, without the re-dress, because by then
    -- there is nothing left to dress.
    E.ench_active = nil

    -- End the use: forget it, give the slot back, and re-dress the character. release_slot
    -- is used rather than a bare enable because it knows the whole ownership picture -- it
    -- skips the enable if another layer still claims that slot, and it re-asserts a lock
    -- mode's item if a lock was waiting underneath this use.
    local function finish_enchantment()
        local st = E.ench_active
        E.ench_active = nil
        E.ench_held_slot = nil
        if not st then return end
        release_slot(st.slot)
        equip_set_command()
    end

    -- Abort the running use and hand the slot back. Returns the item's name and whether its
    -- /item had already gone to the server, so the caller can tell the player the difference
    -- between a use that was stopped and one that can no longer be recalled.
    local function cancel_enchantment()
        local st = E.ench_active
        if not st then return nil end
        local name, sent = st.name, (st.phase == 'sent')
        finish_enchantment()
        return name, sent
    end

    -- The server confirmed an item use finished. Called from the action handler.
    --
    -- The packet that reports this is GENERIC -- it fires for food, medicines and anything
    -- else the player uses -- so it is only treated as this engine's confirmation once a
    -- use of its own has actually been sent. Without the phase test, eating a meal would
    -- close out a use that was still waiting on its equip delay.
    function enchantment_completed()
        if E.ench_active and E.ench_active.phase == 'sent' then finish_enchantment() end
    end

    -- Advance the use by one step. Driven four times a second from the Hoxne component's
    -- prerender handler.
    --
    -- Because that is a RAW handler, this function never calls equip: an equip issued there
    -- is discarded when the next wrapped event clears the pending list. Every repair it
    -- needs is routed through the gs c enchrepair self command instead. For the same reason
    -- it never trusts player.equipment, and reads worn state from the bag copy.
    --
    -- The phases are 'waiting' (equipped, counting out the delay) and 'sent' (the /item has
    -- gone, waiting for the server to confirm). Each return sets next_step, so the tick
    -- costs one comparison until there is something to do.
    local function enchantment_tick(now)
        local st = E.ench_active
        if not st or now < st.next_step then return end

        if now > st.deadline then
            if st.phase == 'sent' then
                warn(st.name .. ': use was not accepted - most likely still on cooldown. Releasing.')
            else
                warn(st.name .. ': timed out, releasing lock.')
            end
            finish_enchantment()
            return
        end

        if st.phase == 'sent' then
            st.next_step = now + 1
            return
        end

        if E.is_moving or midaction() or pet_midaction() then
            st.next_step = now + 1
            return
        end

        local held = now - st.equipped_at
        if held < st.cast_delay then
            st.next_step = now + (st.cast_delay - held) + 0.5
            return
        end

        -- One bag walk answers presence, worn state and the timers together. The worn test
        -- must NOT use player.equipment here: it refreshes only when a wrapped GearSwap
        -- event begins, so on this raw handler it lags the engine's own equip and would
        -- report the item missing moments after it was put on.
        local row, ext, carried, equipped = find_enchantment(st.name)

        -- The item is genuinely gone from the slot -- an in-game /equipset, or the game
        -- clearing ammo as a side effect of something else. Repair it, through a self
        -- command because an equip from here would be discarded. Bounded to three attempts,
        -- after which the use is abandoned rather than retried forever.
        if not equipped then
            st.attempts = st.attempts + 1
            if st.attempts > 3 then
                warn(st.name .. ': could not keep it equipped in ' .. st.slot .. '.')
                finish_enchantment()
                return
            end
            windower.send_command('gs c enchrepair')
            st.equipped_at = now
            st.next_step = now + st.cast_delay + ENCH_ACTIVATION_BUFFER + 1
            -- The repair re-equips, so the item's settle time starts over and the DEADLINE
            -- has to move with it. Left where it was, the next wake would reap a use that
            -- had just recovered -- and the three-attempt budget above would be
            -- unreachable, because the deadline would always fire first.
            st.deadline = now + st.cast_delay + st.cast_time + 12
            return
        end

        local recast, activation = enchantment_waits(ext)
        recast, activation = recast or 0, activation or 0
        if recast > 0 then
            -- A cooldown discovered only after the item was equipped. The use is abandoned
            -- rather than waited out, because waiting would hold the player's slot for the
            -- entire cooldown. Answered unconditionally: the player asked for this item, so
            -- the automated throttle must not swallow the explanation.
            warn_unavailable(row, recast, true)
            finish_enchantment()
            return
        end
        if activation > 0 then
            -- An equip delay only, so wait silently. The deadline is deliberately NOT
            -- extended here: the initial budget already covers a full delay, and the
            -- item's activation time restarts on every re-equip -- so extending on each
            -- wake could push the deadline past every future wake and the use would never
            -- time out at all.
            st.next_step = now + activation + 0.5
            return
        end

        log('/item "', st.name, '" <me>')
        windower.chat.input('/item "' .. st.name .. '" <me>')
        st.phase = 'sent'
        st.next_step = now + 1
        -- enchantment_completed closes this out when the server accepts. A REJECTION never
        -- arrives at all -- the server simply says nothing -- so the deadline is what turns
        -- a silent refusal into a released slot and a message.
        st.deadline = now + st.cast_time + 4
    end

    -- Equip an enchanted item and use it. The entry point behind gs c use and every
    -- shortcut command built on it.
    --
    -- The guards run in order of COST, cheapest first: is the name known, is the item
    -- carried, can this character wear it, is the same item already running, is it on
    -- cooldown. Each answers with the specific reason rather than a generic failure, and
    -- the ordering means the expensive bag reads are only reached when the cheap tests pass.
    function use_enchantment(item)
        local row, ext, carried = find_enchantment(item)
        if not row then
            notice('Unknown enchanted item: [' .. tostring(item) .. ']')
            return
        end
        local i_name = row.en
        if not carried then
            notice(i_name .. ': not found in inventory or wardrobes.')
            return
        end

        -- Wrong job, too low a level, wrong race: named here and now, rather than letting
        -- the state machine equip nothing and time out with a message about the equip.
        local why = unwearable_reason(row)
        if why then
            notice(why)
            return
        end

        -- Re-issuing the item that is ALREADY running is not treated as an override.
        -- Restarting it would reset the equip delay, so an impatient player pressing the
        -- macro again would push the use further away rather than closer.
        if E.ench_active and E.ench_active.id == row.id then
            notice(i_name .. ' is already in progress.')
            return
        end

        -- Only a genuine cooldown refuses the command. An equip delay is deliberately
        -- ignored here: equipping the item and waiting the delay out is precisely what
        -- this function exists to do, so the tick handles it rather than refusing.
        local recast = enchantment_waits(ext)
        if recast and recast > 0 then
            warn_unavailable(row, recast, true) -- user asked; always answer
            return
        end

        -- The slot must be chosen deliberately rather than taken from the item data: a ring
        -- lists both ring slots, and table order is undefined, so letting the first one win
        -- would put the item in a different slot from one call to the next.
        local slot = pick_slot(row, i_name)
        -- The wearability guard above rejects an item with no slots field at all; this
        -- catches the rarer case of a slots set that exists but is empty.
        if not slot then
            notice('No equippable slot for [' .. i_name .. '].')
            return
        end

        -- A DIFFERENT item takes over from whatever is running. This sits below every guard
        -- above on purpose: a command that is about to be refused must never disturb a use
        -- already in progress, so the takeover happens only once this one is certain to run.
        local prev, prev_sent = cancel_enchantment()
        if prev then
            if prev_sent then
                warn(prev .. ': already sent and cannot be recalled; move to interrupt it.')
            else
                notice('Canceled [' .. prev .. '].')
            end
        end

        notice('Equipping and using [' .. i_name .. ']')

        local cd, ct = row.cast_delay or 5, row.cast_time or 1
        local now = os.clock()
        E.ench_active = {
            name        = i_name,
            id          = row.id,
            slot        = slot,
            cast_delay  = cd,
            cast_time   = ct,
            equipped_at = now,
            attempts    = 0,
            phase       = 'waiting',
            next_step   = now + cd + ENCH_ACTIVATION_BUFFER + 1,
            deadline    = now + cd + ct + 12,
        }

        -- gs_equip rather than the engine's own equip: this function manages its slot
        -- directly, and the Hoxne filter that normally protects range and ammo must not
        -- strip an enchanted item in one of those slots that the player explicitly asked
        -- for. Enable, equip, disable in one event -- the same ordering the Hoxne hold uses,
        -- and for the same reason.
        enable(slot)
        gs_equip({ [slot] = i_name })
        disable(slot)
        E.ench_held_slot = slot
        log('use_enchantment: ', i_name, ' -> ', slot)
    end

    -- Lock modes ----------------------------------------------------------------------------------

    -- The items a lock mode can hold, keyed by the command word and stored as resource ids.
    -- Keying by command word means the command already knows its item, so this path never
    -- touches the name index the use path needs. The capacity point lock is not here: it
    -- chooses among three capes at engagement rather than naming one.
    local LOCKABLE = {
        jubilee = 27593, -- Jubilee Ring
    }

    -- The command words whose lock mode picks its item by scanning, and what that mode calls
    -- itself before a scan has run -- no cape name is true at a point where none is chosen.
    -- All three words run the same chooser: 'mecisto' is a second name for the mode, not an
    -- instruction to wear a Mecisto.
    local CAPACITY_KEYS                          = { capacity = true, aptitude = true,
                                                     mecisto = true }
    local CAPACITY_MODE_NAME                     = 'Capacity point cape'

    -- The capes the capacity point lock can wear. The two natives carry their bonus as item
    -- text, which extdata cannot see at all, so their value is stated here; the Mecisto
    -- carries a real augment and its value is read from each copy. A row with no value is
    -- what marks the second kind.
    local CAPACITY_CAPES = {
        { id = 27604, value = 30 }, -- Aptitude Mantle +1
        { id = 27603, value = 25 }, -- Aptitude Mantle
        { id = 27596 },             -- Mecisto. Mantle
    }

    -- The rendered form of the capacity augment. Every escape is required -- the dot, the
    -- plus and the percent sign are all pattern metacharacters -- and the anchors keep this
    -- off the many other augments that render as a percentage.
    local CAPACITY_AUGMENT                       = '^Cap%. Point%+(%d+)%%$'

    -- What one carried Mecisto is worth, and the augment list naming that copy to an equip
    -- call. A nil value means the augments could not be READ, which is not the same as a
    -- zero: the cape always carries a capacity augment. The decode is wrapped because it
    -- throws on any extdata string that is not 24 bytes, and the list is scanned rather than
    -- indexed because it is positional and padded with the literal string 'none'.
    local function mecisto_value(it)
        local ok, ext = pcall(extdata.decode, it)
        if not ok or type(ext) ~= 'table' or type(ext.augments) ~= 'table' then
            return nil, nil
        end
        local named, value = {}, nil
        for _, augment in ipairs(ext.augments) do
            if type(augment) == 'string' and augment ~= 'none' then
                named[#named + 1] = augment
                local percent = augment:match(CAPACITY_AUGMENT)
                if percent then value = tonumber(percent) end
            end
        end
        if #named == 0 then return value, nil end
        return value, named
    end

    -- Every capacity point cape carried and wearable, one entry per COPY, in bag order. The
    -- value is read from the copy for a Mecisto and taken from the static row for a native;
    -- a nil value marks a Mecisto whose augments did not read, which still carries one and is
    -- still a candidate. Unwearable copies are left out and the walk continues, so a level
    -- sync narrows the field rather than refusing the mode.
    local function scan_capacity_capes()
        local found = {}
        for _, bag_id in ipairs(ENCH_BAGS) do
            local bag = windower.ffxi.get_items(bag_id)
            for _, it in ipairs(bag or {}) do
                local cape
                if type(it) == 'table' then
                    for _, candidate in ipairs(CAPACITY_CAPES) do
                        if candidate.id == it.id then cape = candidate break end
                    end
                end
                local row = cape and res.items[cape.id]
                if row and not unwearable_reason(row) then
                    local value, augments = cape.value, nil
                    if not value then value, augments = mecisto_value(it) end
                    found[#found + 1] = { row = row, value = value, augments = augments,
                                          count = augments and #augments or 0 }
                end
            end
        end
        return found
    end

    -- The best entry of a scan, and separately the best unreadable one. Two ranks, not one
    -- score: a cape whose value reads always wins, and a Mecisto whose augments did not read
    -- is taken only when no readable cape is carried at all. A score of zero could express
    -- neither end of that -- it would lose to an empty bag and tie a readable 1%.
    local function best_capacity_cape(carried)
        local best, spare
        for _, c in ipairs(carried) do
            if c.value then
                -- Highest value wins, and one comparison settles both tie rules: a native
                -- carries no augments and so counts zero, which puts any Mecisto above it on
                -- a tie, and among equal Mecistos it puts the richest copy first. Richest is
                -- the only rule an "at least these augments" match can express without
                -- leaving which copy gets worn undetermined.
                if not best or c.value > best.value
                    or (c.value == best.value and c.augments and c.count > best.count) then
                    best = c
                end
            elseif not spare or c.count > spare.count then
                spare = c
            end
        end
        return best, spare
    end

    -- Returns the resource row, its value, the augment list to match on, and the name of a
    -- Mecisto that was passed over unread. A nil value on a returned row means the second
    -- rank was taken and no percentage can be named.
    local function choose_capacity_cape()
        local best, spare = best_capacity_cape(scan_capacity_capes())
        if best then
            return best.row, best.value, best.augments, spare and spare.row.en or nil
        end
        if spare then return spare.row, nil, spare.augments, nil end
    end

    -- Which slot the capacity point lock is holding, whichever cape it settled on. The off
    -- path needs this because that mode's item is chosen rather than fixed, so there is no
    -- single id to ask about.
    local function locked_capacity_slot()
        for _, cape in ipairs(CAPACITY_CAPES) do
            local slot = locked_slot_of(cape.id)
            if slot then return slot end
        end
    end

    -- The command word whose lock mode wears a job-specific Dynamis Divergence neck, and
    -- what that mode calls itself before a neck has been chosen -- no neck name is true at
    -- a point where none is chosen, and the choice depends on the job and the bags.
    local JSE_KEYS                               = { dynamisrp = true }
    local JSE_MODE_NAME                          = 'Dynamis RP'

    -- The sixty-six job-specific Dynamis Divergence necks, three ranks per job, keyed by the
    -- three-letter main job as player.main_job spells it and stored BEST FIRST: +2, +1, then
    -- the base piece. Every id is a level-99 neck-slot item whose job mask names exactly the
    -- job it is filed under, so a rank this character cannot wear means none of the three can.
    local JSE_NECKS = {
        WAR = { 25419, 25418, 25417 }, -- War. Beads +2, +1, Warrior's Beads
        MNK = { 25425, 25424, 25423 }, -- Mnk. Nodowa +2, +1, Monk's Nodowa
        WHM = { 25431, 25430, 25429 }, -- Clr. Torque +2, +1, Cleric's Torque
        BLM = { 25437, 25436, 25435 }, -- Src. Stole +2, +1, Sorcerer's Stole
        RDM = { 25443, 25442, 25441 }, -- Dls. Torque +2, +1, Duelist's Torque
        THF = { 25449, 25448, 25447 }, -- Asn. Gorget +2, +1, Assassin's Gorget
        PLD = { 25455, 25454, 25453 }, -- Kgt. Beads +2, +1, Knight's Beads
        DRK = { 25461, 25460, 25459 }, -- Abyssal Beads +2, +1, Abyssal Beads
        BST = { 25467, 25466, 25465 }, -- Bst. Collar +2, +1, Beastmaster Collar
        BRD = { 25473, 25472, 25471 }, -- Bard's Charm +2, +1, Bard's Charm
        RNG = { 25479, 25478, 25477 }, -- Scout's Gorget +2, +1, Scout's Gorget
        SAM = { 25485, 25484, 25483 }, -- Sam. Nodowa +2, +1, Samurai's Nodowa
        NIN = { 25491, 25490, 25489 }, -- Ninja Nodowa +2, +1, Ninja Nodowa
        DRG = { 25497, 25496, 25495 }, -- Dgn. Collar +2, +1, Dragoon's Collar
        SMN = { 25503, 25502, 25501 }, -- Smn. Collar +2, +1, Summoner's Collar
        BLU = { 25509, 25508, 25507 }, -- Mirage Stole +2, +1, Mirage Stole
        COR = { 25515, 25514, 25513 }, -- Comm. Charm +2, +1, Commodore Charm
        PUP = { 25521, 25520, 25519 }, -- Pup. Collar +2, +1, Pup. Collar
        DNC = { 25527, 25526, 25525 }, -- Etoile Gorget +2, +1, Etoile Gorget
        SCH = { 25533, 25532, 25531 }, -- Argute Stole +2, +1, Argute Stole
        GEO = { 25539, 25538, 25537 }, -- Bagua Charm +2, +1, Bagua Charm
        RUN = { 25545, 25544, 25543 }, -- Futhark Torque +2, +1, Futhark Torque
    }

    -- The best rank of the main job's neck this character is carrying, as a resource row, or
    -- nil when none of the three is carried and when the job has no neck of its own. It does
    -- not test wearability: all three ranks are level 99 for the one job, so lock_slot's own
    -- guard is where an unwearable neck is refused with a reason.
    local function choose_jse_neck()
        local ranks = JSE_NECKS[player.main_job]
        if not ranks then return end
        for i = 1, #ranks do
            local row = res.items[ranks[i]]
            if row and have_item(row.en) then return row end
        end
    end

    -- Which slot the neck lock is holding, whichever rank it settled on. The off path needs
    -- this for the reason the capacity lock's does: the item is chosen rather than fixed, so
    -- there is no single id to ask about.
    local function locked_jse_slot()
        local ranks = JSE_NECKS[player.main_job]
        if not ranks then return end
        for i = 1, #ranks do
            local slot = locked_slot_of(ranks[i])
            if slot then return slot end
        end
    end

    -- Wear an item and hold its slot against everything the job file would otherwise put
    -- there. The guards mirror use_enchantment's because the ways this fails are the same
    -- ones, with one addition: a lock will not take a slot from anything above it.
    local function lock_slot(row, augments)
        local name = row.en
        if not have_item(name) then
            notice(name .. ': not found in inventory or wardrobes.')
            return false
        end
        local why = unwearable_reason(row)
        if why then
            notice(why)
            return false
        end

        -- Re-issuing the command is the documented manual repair, so it MUST land on the
        -- slot already registered rather than choosing afresh. Registering one item in two
        -- slots leaves the second permanently empty and sets the verify sweep shuttling the
        -- single item back and forth between them.
        local slot = locked_slot_of(row.id) or pick_slot(row, name)
        if not slot then
            notice('No equippable slot for [' .. name .. '].')
            return false
        end

        -- A lock is the LOWEST layer that can hold a slot, so it waits rather than taking
        -- one. This re-test is why: pick_slot falls through to the first slot the item fits,
        -- which is right for an item use -- that outranks a lock and may take the slot --
        -- but here the same fall-through would seize a slot an item use, the Hoxne hold or
        -- incoming received gear is still wearing.
        local claim = slot_claim(slot)
        if claim and claim ~= 'lock' then
            report_refused(name, { [slot] = claim }, notice)
            return false
        end

        -- An augment list names ONE copy among several of the same item. It rides beside the
        -- name and never replaces it: two player-facing lines concatenate the recorded name,
        -- and the re-assert in the equip component rebuilds this same request.
        enable(slot)
        gs_equip({ [slot] = augments and { name = name, augments = augments } or name })
        disable(slot)
        local canon = CANON_SLOT[slot] or slot
        if not locked[canon] then E.locked_n = E.locked_n + 1 end
        locked[canon] = { id = row.id, name = name, augments = augments }
        return true
    end

    -- Reclaim a locked slot that something took without telling the engine.
    --
    -- An in-game /equipset, a level-sync unequip and a console enable all bypass GearSwap
    -- entirely and fire NO event this engine could hear. So rather than waiting to be told,
    -- this compares what is worn against what is held, on the path where gear is chosen.
    -- It yields whenever a higher layer holds the slot -- that layer gives it back itself,
    -- and re-taking it here would fight the layer that outranks this one. The weapon lock's
    -- held slots take the same sweep first.
    local function verify_locked_slots()
        verify_weapon_lock()
        verify_disabled_slots()
        verify_stripped_slots()
        if E.locked_n == 0 then return end
        for canon, held in pairs(locked) do
            if player.equipment[canon] ~= held.name and slot_claim(canon) == 'lock' then
                release_slot(canon)
            end
        end
    end

    -- Turn a lock mode on, off, or to the opposite of wherever it is. Backs the capacity
    -- point lock's three words, the Dynamis Divergence neck lock, and gs c jubilee.
    --
    -- Setting jubilee while it is already on RE-ASSERTS it rather than reporting it as
    -- already on, which is what makes the bare command double as the manual repair when
    -- something has taken the slot behind the engine's back. The two chosen-item modes do
    -- not re-assert: setting one on again chooses afresh and may settle on a different
    -- piece -- a cape whose augment reads higher, or a neck rank acquired since.
    local function lock_mode(key, arg)
        local capacity = CAPACITY_KEYS[key] or false
        local jse = JSE_KEYS[key] or false
        local row, held
        if capacity then
            held = locked_capacity_slot()
        elseif jse then
            held = locked_jse_slot()
        else
            row = res.items[LOCKABLE[key]]
            held = locked_slot_of(row.id)
        end
        local label = row and row.en or (jse and JSE_MODE_NAME or CAPACITY_MODE_NAME)
        local want
        if arg == 'on' then
            want = true
        elseif arg == 'off' then
            want = false
        elseif arg then
            warn(('%s: "%s" is not on or off.'):format(label, tostring(arg)))
            warn(('Usage: //gs c %s [on|off]'):format(key))
            return
        else
            want = not held
        end

        if not want then
            if held then
                -- Read the name before releasing: unlock_slot forgets the record.
                local worn = locked[held] and locked[held].name or label
                unlock_slot(held)
                notice(worn .. ': [OFF]')
                -- The status box names the lock modes standing: repainted after the release.
                display_box_update()
            else
                notice(label .. ': already [OFF]')
            end
            return
        end

        -- The bag walk runs here and nowhere else, for both chosen-item modes. A re-assert
        -- from a higher layer giving the slot back reuses the piece this chose, and never
        -- walks the bags again. The neck's refusal names the job, which is what says which
        -- three pieces were looked for.
        local value, augments
        if capacity then
            local unread
            row, value, augments, unread = choose_capacity_cape()
            if not row then
                notice('No capacity point cape found in inventory or wardrobes.')
                return
            end
            if unread then notice(unread .. ': augments unreadable, skipped.') end
        elseif jse then
            row = choose_jse_neck()
            if not row then
                notice('No ' .. tostring(player.main_job) .. ' Dynamis neck found in inventory or wardrobes.')
                return
            end
        end

        if lock_slot(row, augments) then
            local worn = row.en
            if capacity then
                worn = value and ('%s (+%d%%)'):format(row.en, value)
                              or (row.en .. ' (bonus unreadable)')
            end
            notice(worn .. ': [ON] held in ' .. tostring(locked_slot_of(row.id)) .. '.')
            -- And after the take, once the slot is registered.
            display_box_update()
        end
    end


    -- Handed to E. The Hoxne component is built on five of these -- ENCH_BAGS,
    -- find_enchantment, enchantment_waits, warn_unavailable and enchantment_tick -- because
    -- it treats the Ampulla as an enchanted item and reuses this engine's bag list, lookup,
    -- timing reads and cooldown reporting wholesale. The rest go to commands, builders
    -- and th.
    E.ENCH_BAGS = ENCH_BAGS
    E.EXTDATA_TS_CORRECTION = EXTDATA_TS_CORRECTION
    E.find_enchantment = find_enchantment
    E.enchantment_waits = enchantment_waits
    E.warn_unavailable = warn_unavailable
    E.cancel_enchantment = cancel_enchantment
    E.enchantment_tick = enchantment_tick
    E.verify_locked_slots = verify_locked_slots
    E.lock_mode = lock_mode
    E.scan_capacity_capes = scan_capacity_capes
    E.best_capacity_cape = best_capacity_cape
    E.locked_capacity_slot = locked_capacity_slot

    -- Version stamp. The root asserts this against Rahvin_GS, so a stale copy of this file
    -- announces itself at load instead of running.
    return '2.0'
end
