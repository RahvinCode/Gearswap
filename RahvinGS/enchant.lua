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
--   and its tick, and the lock modes that wear an item and hold its slot until turned off.
--
-- An item use equips an item, waits out its equip delay, sends the /item and gives the slot
-- back. A lock mode equips an item and keeps the slot. The two share their guards, the slot
-- chooser and the refusal wording, because they fail in the same ways: the item is not
-- carried, the character cannot wear it, or a layer that outranks them holds the slot.
--
-- E.ench_active holds the one use in progress, or nil, so two uses can never overlap.
-- Nothing survives a reload. A use in flight simply ends, and the root's load-time release
-- frees the slot it held.
--
-- enchantment_tick runs four times a second from the Hoxne component's prerender driver,
-- which is a raw handler. GearSwap discards an equip issued there, so the tick never equips.
-- It sends itself gs c enchrepair, and that wrapped command does the work. player.equipment
-- is stale there too, so every worn test reads the status byte of the item's bag copy.
--
-- EXPORTS  The block at the end. The Hoxne component treats the Ampulla as an enchanted item,
--          so it takes ENCH_BAGS, find_enchantment, enchantment_waits, warn_unavailable and
--          enchantment_tick. The rest go to commands, builders and th. This file also
--          initializes E.ench_active and assigns E.ench_held_slot, which the equip component
--          declares with slot ownership. Commands, equip, display, hoxne and lifecycle use
--          those two fields.
-- GLOBALS  use_enchantment, called by gs c use and its shortcut commands, and
--          enchantment_completed, called by the action handler when an item use finishes or
--          is interrupted.
-- LOADS    After the equip component and before the Hoxne component, which imports from it.
--          equip_set_command (the root) and display_box_update (display) are globals from
--          files that load later. They resolve when called, so neither may be bound in the
--          import block.

-- requires: rahvings/state, rahvings/core, rahvings/equip
return function(E)
    -- The exports this file uses, bound once at construction. The shared mutable fields
    -- ench_active, ench_held_slot, locked_n and is_moving are never bound here. They are
    -- read through E at every use, because a local copy would not be the one the other
    -- components write. The slot-ownership helpers come from the equip component, which
    -- decides who owns each slot.
    local CANON_SLOT, extdata, res               = E.CANON_SLOT, E.extdata, E.res
    local verify_stripped_slots, report_refused  = E.verify_stripped_slots, E.report_refused
    local verify_disabled_slots                  = E.verify_disabled_slots
    local gs_equip, have_item, unwearable_reason = E.gs_equip, E.have_item, E.unwearable_reason
    local locked, locked_slot_of, release_slot   = E.locked, E.locked_slot_of, E.release_slot
    local slot_claim, unlock_slot                = E.slot_claim, E.unlock_slot
    local verify_weapon_lock                     = E.verify_weapon_lock

    ------------------------------------------------------------------------------------------------
    -- SECTION 13 - ENCHANTED ITEM ENGINE
    ------------------------------------------------------------------------------------------------
    -- Everything behind gs c use, the shortcut commands built on it, and the lock modes.

    -- Constants -----------------------------------------------------------------------------------

    -- Resource slot id to GearSwap slot name. It mirrors default_slot_map in GearSwap's
    -- statics.lua, which keys player.equipment. The two must agree, or every worn test
    -- reads nothing.
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

    -- Choose the slot for an item, in order of preference: a slot where it is already worn,
    -- then a slot no layer claims, then the first slot it fits.
    --
    -- A worn copy is not moved. The middle choice keeps a ring or an earring off a side
    -- another layer holds while the other side is free. Falling through to the first slot
    -- is right for an item use, which outranks every other layer. The lock path re-tests the
    -- claim itself, because a lock mode must not take a claimed slot.
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

    -- The bags that can hold worn gear, by bag id: 0 the inventory, 8 Wardrobe, and 10 to 16
    -- Wardrobe 2 to 8.
    local ENCH_BAGS = { 0, 8, 10, 11, 12, 13, 14, 15, 16 }

    -- A five-hour correction to decoded timestamps. Windower's extdata library adds
    -- server_timestamp_offset, an epoch of 2001-12-31 10:00 UTC, while the server counts
    -- from midnight 2002-01-01 JST. Every decoded timestamp lands 18000 seconds early, which
    -- would hide every cooldown shorter than five hours and make almost every item read as
    -- ready.
    local EXTDATA_TS_CORRECTION = 18000

    -- The server keeps refusing a use for roughly three seconds past the listed equip delay
    -- or recast boundary, so every wait computed below carries this margin.
    local ENCH_ACTIVATION_BUFFER = 3

    -- Item lookup ---------------------------------------------------------------------------------

    -- The item index: lowercased name to resource row. It is built on first use rather than
    -- at load, so a session that never uses an enchanted item never builds it.
    --
    -- Both name fields are indexed, so a player can type the short name or the full log
    -- name. The short names go in first, in their own pass, so one item's log name can never
    -- shadow another item's short name.
    --
    -- Membership comes from the game's own item data: any item with a cast delay that can
    -- target the player.
    local ench_index
    local function build_ench_index()
        ench_index = {}
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

    -- Find an item and read its enchantment data in one bag walk. Returns the resource row,
    -- the decoded extdata, whether the item is carried, and whether that copy is worn.
    -- Callers need different subsets, and one walk answers them all.
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
                        -- Status 5 on the bag copy means the item is worn. GearSwap's own
                        -- equip_processing.lua reads the same field, and it is live server
                        -- state. player.equipment is refreshed only as a wrapped event
                        -- begins, in equip_sets in GearSwap's flow.lua, so it is stale on
                        -- the raw handler that reaches this.
                        return row, (ok and ext) or nil, true, (it.status == 5)
                    end
                end
            end
        end
        return row, nil, false
    end

    -- Timing and warnings -------------------------------------------------------------------------

    -- The two waits that gate a use, in seconds: the recast and the equip delay. Both are
    -- nil when there is no extdata.
    --
    -- They are returned separately because callers treat them oppositely. A recast lasts
    -- minutes or hours, and a command is refused over it with the time named. An equip delay
    -- only means the item must stay on a few seconds longer, which the engine does anyway,
    -- so it passes silently.
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
        -- Both clocks read ready but the item says it is not usable, so the item is trusted.
        -- The unknown wait is returned as an equip delay, which waits quietly instead of
        -- refusing the player. The 5 is a poll interval, not a countdown: the caller asks
        -- again in five seconds.
        if recast == 0 and activation == 0 and ext.usable == false then
            activation = 5
        end
        return recast, activation
    end

    -- Report an item as on cooldown, at most once per item until the recast it reported has
    -- run out.
    --
    -- The throttle is for the Hoxne tick, which asks every few seconds for as long as the
    -- recast runs. A caller answering the player sets always, which prints on notice
    -- whatever the toggles say and leaves the throttle alone, so neither caller can silence
    -- the other. Without always the line prints on info, throttled.
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

    -- The use in progress, or nil. Only use_enchantment sets it, which keeps two uses from
    -- overlapping. In this file only finish_enchantment clears it, and the cancel, the
    -- completion and the tick all go through that function. The job file's teardown in the
    -- lifecycle component clears it directly, with no re-dress.
    E.ench_active = nil

    -- End the use: forget it, give the slot back, repaint the status box and queue a
    -- rebuild. release_slot hands the slot to the next layer in line, so a hold or lock mode
    -- waiting under the use gets its item back, and an unclaimed slot is enabled. The
    -- repaint follows the release, so the rig shows the slot's next holder. quiet skips the
    -- repaint, for a caller that repaints once itself after further releases.
    local function finish_enchantment(quiet)
        local st = E.ench_active
        E.ench_active = nil
        E.ench_held_slot = nil
        if not st then return end
        release_slot(st.slot)
        if not quiet then display_box_update() end
        equip_set_command()
    end

    -- Abort the running use and give the slot back. Returns the item's name and whether its
    -- /item had already gone to the server, so the caller can tell a stopped use from one
    -- past recall, or nil when no use is running. quiet is passed to finish_enchantment.
    local function cancel_enchantment(quiet)
        local st = E.ench_active
        if not st then return nil end
        local name, sent = st.name, (st.phase == 'sent')
        finish_enchantment(quiet)
        return name, sent
    end

    -- The server reported an item use finished or interrupted. Called from the action
    -- handler.
    --
    -- That packet comes for every item the player uses, food and medicine included, so it
    -- ends this engine's use only once its /item has been sent. Without the phase test,
    -- eating a meal would end a use still waiting out its equip delay.
    function enchantment_completed()
        if E.ench_active and E.ench_active.phase == 'sent' then finish_enchantment() end
    end

    -- Advance the use by one step. The Hoxne component's prerender driver calls this four
    -- times a second.
    --
    -- The driver is a raw handler, so this never calls equip. An equip issued there is
    -- discarded when the next wrapped event clears GearSwap's pending list, so every repair
    -- goes through the gs c enchrepair self command. For the same reason worn state comes
    -- from the bag copy, never from player.equipment.
    --
    -- The phase is 'waiting' while the item is on and its equip delay runs, and 'sent' once
    -- the /item has gone and the server's answer is awaited. Each return that keeps the use
    -- sets next_step, so between steps the tick is one comparison.
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
        -- must not use player.equipment, which lags the engine's own equip on this raw
        -- handler and would report the item missing just after it went on.
        local row, ext, carried, equipped = find_enchantment(st.name)

        -- The item is gone from the slot, taken by an in-game /equipset or by the game
        -- clearing ammo. It is repaired through the enchrepair self command, at most three
        -- times, and then the use is abandoned.
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
            -- The repair re-equips, so the equip delay starts over and the deadline moves
            -- with it. Left where it was, the deadline would end a use that had just
            -- recovered, and the three-attempt budget above could never be reached.
            st.deadline = now + st.cast_delay + st.cast_time + 12
            return
        end

        local recast, activation = enchantment_waits(ext)
        recast, activation = recast or 0, activation or 0
        if recast > 0 then
            -- A cooldown found only after the item went on. The use is abandoned, since
            -- waiting would hold the slot for the whole cooldown. The player asked for this
            -- item, so the warning sets always and the throttle cannot swallow it.
            warn_unavailable(row, recast, true)
            finish_enchantment()
            return
        end
        if activation > 0 then
            -- An equip delay only, so wait silently. The deadline is not extended here. The
            -- initial budget already covers a full delay, and the activation time restarts
            -- on every re-equip, so extending it on each wake could keep the use from ever
            -- timing out.
            st.next_step = now + activation + 0.5
            return
        end

        log('/item "', st.name, '" <me>')
        windower.chat.input('/item "' .. st.name .. '" <me>')
        st.phase = 'sent'
        st.next_step = now + 1
        -- enchantment_completed ends the use when the server accepts. A refusal sends
        -- nothing at all, so the deadline is what turns a silent refusal into a released
        -- slot and a message.
        st.deadline = now + st.cast_time + 4
    end

    -- Equip an enchanted item and use it. The entry point behind gs c use and the shortcut
    -- commands built on it.
    --
    -- The guards answer in this order, each with its own reason: an unknown name, an item
    -- not carried, an item this character cannot wear, the same item already running, and
    -- a recast. One bag walk at the top answers the first two and reads the timers for the
    -- last.
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

        -- A wrong job, too low a level or a wrong race is named here. Otherwise the state
        -- machine would equip nothing and time out with a message about the equip.
        local why = unwearable_reason(row)
        if why then
            notice(why)
            return
        end

        -- The same item again is not an override. Restarting it would reset the equip
        -- delay, so a second press of the macro would only push the use further away.
        if E.ench_active and E.ench_active.id == row.id then
            notice(i_name .. ' is already in progress.')
            return
        end

        -- Only a recast refuses the command. An equip delay is ignored here, because the
        -- tick waits it out once the item is on.
        local recast = enchantment_waits(ext)
        if recast and recast > 0 then
            warn_unavailable(row, recast, true) -- the player asked, so always answer
            return
        end

        -- The slot is chosen, not read from the item data. A ring lists both ring slots in
        -- a set with no defined order, so the first one listed could differ between calls.
        local slot = pick_slot(row, i_name)
        -- The wearability guard above rejects an item with no slots field. This catches a
        -- slots set that exists but is empty.
        if not slot then
            notice('No equippable slot for [' .. i_name .. '].')
            return
        end

        -- A different item takes over from the running use. The takeover sits below every
        -- guard, so a command that is refused never disturbs a use already in progress.
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

        -- The captured gs_equip bypasses the ON-Allow Critical filter, which would otherwise
        -- strip an item the player asked for in range or ammo. The enable, the equip and the
        -- disable run in one event, in that order, as the Hoxne hold's do. The status box is
        -- repainted once the slot is recorded, so the rig shows the item use holding it.
        enable(slot)
        gs_equip({ [slot] = i_name })
        disable(slot)
        E.ench_held_slot = slot
        display_box_update()
        log('use_enchantment: ', i_name, ' -> ', slot)
    end

    -- Lock modes ----------------------------------------------------------------------------------

    -- The fixed-item lock modes, keyed by command word, each naming its item by resource id.
    -- The command knows its item, so this path never builds the name index the use path
    -- needs. The capacity point and Dynamis neck locks are not here, because each chooses
    -- its item when it is turned on.
    local LOCKABLE = {
        jubilee = 27593, -- Jubilee Ring
    }

    -- The three command words of the capacity point lock, and the name it goes by before a
    -- cape is chosen. All three run the same chooser. 'mecisto' is another name for the
    -- mode, not an instruction to wear a Mecisto.
    local CAPACITY_KEYS                          = { capacity = true, aptitude = true,
                                                     mecisto = true }
    local CAPACITY_MODE_NAME                     = 'Capacity point cape'

    -- The capes the capacity point lock can wear. The two Aptitude Mantles carry their bonus
    -- as item text, which extdata cannot read, so their value is stated here. The Mecisto
    -- carries a real augment, read from each copy, and its row is the one with no value.
    local CAPACITY_CAPES = {
        { id = 27604, value = 30 }, -- Aptitude Mantle +1
        { id = 27603, value = 25 }, -- Aptitude Mantle
        { id = 27596 },             -- Mecisto. Mantle
    }

    -- The capacity augment as extdata renders it, Cap. Point+ then a number and a percent
    -- sign. Every escape is required, because the dot, the plus and the percent sign are
    -- pattern characters. The anchors keep it off other augments that render as a percent.
    local CAPACITY_AUGMENT                       = '^Cap%. Point%+(%d+)%%$'

    -- What one carried Mecisto is worth, and the augment list that names that copy to an
    -- equip call. A nil value means the augments could not be read, which is not zero,
    -- because the cape always carries a capacity augment. The decode is wrapped because it
    -- throws on any extdata string that is not 24 bytes. The list is scanned rather than
    -- indexed, because it is positional and padded with the string 'none'.
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

    -- Every capacity point cape carried and wearable, one entry per copy, in bag order. A
    -- Mecisto's value is read from the copy, and an Aptitude Mantle's is taken from its row.
    -- A nil value marks a Mecisto whose augments did not read, and it stays a candidate.
    -- Unwearable copies are skipped, so a level sync narrows the field rather than refusing
    -- the mode.
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

    -- The best entry of a scan, and separately the best unreadable one. A cape whose value
    -- reads always wins. A Mecisto whose augments did not read is taken only when no
    -- readable cape is carried.
    local function best_capacity_cape(carried)
        local best, spare
        for _, c in ipairs(carried) do
            if c.value then
                -- The highest value wins, and one comparison settles both ties. An Aptitude
                -- Mantle counts zero augments, so a Mecisto of equal value beats it, and among
                -- equal Mecistos the copy with the most augments wins. An augment match means
                -- "at least these augments", so only the fullest list picks one copy for
                -- certain.
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

    -- Choose the capacity point cape. Returns the resource row, its value, the augment list
    -- to match on, and the name of a Mecisto passed over unread. A nil value on a returned
    -- row means an unreadable Mecisto was taken and no percentage can be named. Returns
    -- nothing when no cape is carried.
    local function choose_capacity_cape()
        local best, spare = best_capacity_cape(scan_capacity_capes())
        if best then
            return best.row, best.value, best.augments, spare and spare.row.en or nil
        end
        if spare then return spare.row, nil, spare.augments, nil end
    end

    -- The slot the capacity point lock holds, whichever cape it chose, or nil. The off path
    -- needs it, because a chosen item has no single id to ask about.
    local function locked_capacity_slot()
        for _, cape in ipairs(CAPACITY_CAPES) do
            local slot = locked_slot_of(cape.id)
            if slot then return slot end
        end
    end

    -- The command word of the Dynamis Divergence neck lock, and the name it goes by before
    -- a neck is chosen.
    local JSE_KEYS                               = { dynamisrp = true }
    local JSE_MODE_NAME                          = 'Dynamis RP'

    -- The job-specific Dynamis Divergence necks, three ranks per job, keyed by the main job
    -- as player.main_job spells it and listed best first: +2, +1, then the base piece. Every
    -- id is a level-99 neck whose job mask names only the job it is filed under, so if this
    -- character cannot wear one rank, it cannot wear any of the three.
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

    -- The best rank of the main job's neck this character carries, as a resource row, or nil
    -- when none is carried or the job has no neck. Wearability is not tested here. All three
    -- ranks share one job and level 99, so lock_slot's guard refuses an unwearable neck with
    -- its reason.
    local function choose_jse_neck()
        local ranks = JSE_NECKS[player.main_job]
        if not ranks then return end
        for i = 1, #ranks do
            local row = res.items[ranks[i]]
            if row and have_item(row.en) then return row end
        end
    end

    -- The slot the neck lock holds, whichever rank it chose, or nil. The off path needs it
    -- for the same reason as the capacity lock's.
    local function locked_jse_slot()
        local ranks = JSE_NECKS[player.main_job]
        if not ranks then return end
        for i = 1, #ranks do
            local slot = locked_slot_of(ranks[i])
            if slot then return slot end
        end
    end

    -- Wear an item and hold its slot against everything the job file would put there.
    -- Returns whether it took the slot. The guards mirror use_enchantment's, with one more:
    -- a lock mode never takes a slot from a layer above it.
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

        -- Re-issuing the command is the manual repair, so it must land on the slot already
        -- registered rather than choose again. One item registered in two slots leaves the
        -- second empty for good, and the locked-slot sweep would move the item back and
        -- forth between them.
        local slot = locked_slot_of(row.id) or pick_slot(row, name)
        if not slot then
            notice('No equippable slot for [' .. name .. '].')
            return false
        end

        -- A lock mode is the lowest layer, so it waits rather than take a claimed slot.
        -- pick_slot falls through to the first slot the item fits, which suits an item use.
        -- Here the same fall-through would seize a slot that an item use, the Hoxne hold or
        -- received gear is still wearing, so the claim is tested again.
        local claim = slot_claim(slot)
        if claim and claim ~= 'lock' then
            report_refused(name, { [slot] = claim }, notice)
            return false
        end

        -- An augment list picks one copy among several of the same item. It is kept beside
        -- the name, never in place of it, because two chat lines print the recorded name and
        -- the equip component's re-assert rebuilds this same request.
        enable(slot)
        gs_equip({ [slot] = augments and { name = name, augments = augments } or name })
        disable(slot)
        local canon = CANON_SLOT[slot] or slot
        if not locked[canon] then E.locked_n = E.locked_n + 1 end
        locked[canon] = { id = row.id, name = name, augments = augments }
        return true
    end

    -- Reclaim a held slot that something took without telling the engine. choose_set calls
    -- this on every build.
    --
    -- An in-game /equipset, a level-sync unequip and a console enable all bypass GearSwap
    -- and fire no event the engine can hear. So this compares what is worn with what is
    -- held. The weapon lock, the disable hold and the strip hold are swept first, then the
    -- lock modes. A lock mode's slot is reclaimed only while the lock still owns it, since a
    -- higher layer gives the slot back itself.
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

    -- Turn a lock mode on, off, or to the opposite of its state. Backs the capacity point
    -- lock's three words, the Dynamis Divergence neck lock, and gs c jubilee.
    --
    -- Jubilee set on while already on re-asserts the ring rather than reporting it as on,
    -- so gs c jubilee on doubles as the repair when something took the slot behind the
    -- engine's back. A chosen-item mode set on again chooses afresh and may settle on a
    -- different piece, such as a cape whose augment reads higher or a neck rank acquired
    -- since.
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
        -- The argument is compared lowercased, and a refusal names it as the player typed
        -- it. A refused argument returns true, which keeps the command from the job file's
        -- self_command_custom. Every other outcome returns nothing, so that hook still runs.
        local want
        local word = arg and arg:lower()
        if word == 'on' then
            want = true
        elseif word == 'off' then
            want = false
        elseif arg then
            warn(('%s: "%s" is not on or off.'):format(label, tostring(arg)))
            warn(('Usage: //gs c %s [on|off]'):format(key))
            return true
        else
            want = not held
        end

        if not want then
            if held then
                -- Read the name before releasing: unlock_slot forgets the record.
                local worn = locked[held] and locked[held].name or label
                unlock_slot(held)
                notice(worn .. ': [OFF]')
                -- Repainted after the release, since the status box names the lock modes.
                display_box_update()
            else
                notice(label .. ': already [OFF]')
            end
            return
        end

        -- The chosen-item modes walk the bags here and nowhere else. When a higher layer
        -- gives the slot back, the re-assert reuses the piece chosen here. The neck's refusal
        -- names the job, which tells the player which three pieces were looked for.
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
            -- Repainted again once the new slot is registered.
            display_box_update()
        end
    end


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

    -- The version stamp. The root checks it against Rahvin_GS, so a stale copy of this file
    -- stops the load with an error that names it.
    return '2.1'
end
