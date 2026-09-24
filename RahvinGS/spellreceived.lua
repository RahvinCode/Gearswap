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
-- COMPONENT: spellreceived -- section 17: multibox spell-received gear
----------------------------------------------------------------------------------------------------
-- CONTENTS
--   Section 17 - Multibox spell-received tracking. The set lookup, the IPC target matcher,
--   the equip and release paths, the Sleep hold, the eleven tracker and its recovery after
--   a load, and the four event handlers the root registers: the IPC listener, the failsafe
--   tick, and the two buff handlers.
--
-- WHAT IT DOES  When another character on this machine starts casting a supported spell or
--          ability on this one, that character announces it over Windower's IPC channel. This
--          file wears the matching received set at once, before the spell lands, which is
--          what makes it work through Quick Magic. It holds those slots and gives them back
--          when the completion arrives.
--
--          It also keeps the eleven tracker: the total of every Corsair roll on this
--          character, read off the action packet, and the one answer the equip component's
--          XIRoll flag takes from it. After a load, with the tracker empty, it asks the other
--          characters on this machine for the totals they hold, and it answers the same
--          question from a character in its party.
--
--          The two buff handlers also own the engine's status-ailment responses: sleep,
--          doom, petrification, stun, and the automatic Remedy and Holy Water. The doom
--          response claims its slots in the same registry as received gear.
--
-- EXPORTS  sr_ipc_message, sr_prerender, sr_gain_buff and sr_lose_buff, all registered by
--          the root. reset_spell_received_state, which commands calls on every SpellReceived
--          change. sr_failsafe_active, which lets the debug box read the private failsafe
--          flag. roll_action and roll_clear, the eleven tracker's packet read and its zone
--          clear, both called by th. roll_query, the tracker's question, which the root
--          schedules once after the load. The file also clears accession_predicted and
--          divine_seal_predicted, which the state component declares.
-- LOADS    After hooks and before th. Three globals it calls are defined by components that
--          load later: cancel (monitor), display_box_update (display) and equip_set_command
--          (the root). None of them may be bound in the import block, where it would be nil.
--          All three are reached only from event handlers, which never run before the load
--          completes. E.repaint_slot, the display component's one-cell recolor, is read
--          through E at each call for the same reason.

-- requires: rahvings/state, rahvings/core, rahvings/equip, rahvings/hoxne, rahvings/builders
return function(E)
    -- Immutable dependencies, bound once at construction. The shared flags
    -- accession_predicted and divine_seal_predicted are never bound here. They are reached
    -- through E at every touch, because a file-local copy would not be the value the other
    -- components read and write.
    local BUFF_ACCESSION, BUFF_DIVINE_SEAL, Mage_Job = E.BUFF_ACCESSION, E.BUFF_DIVINE_SEAL, E.Mage_Job
    local ability_info, spell_info, res, settings    = E.ability_info, E.spell_info, E.res, E.settings
    local build_current_set, count_keys, debug       = E.build_current_set, E.count_keys, E.debug
    local finish_outgoing_cast, get_time, merge_into = E.finish_outgoing_cast, E.get_time, E.merge_into
    local release_slot, slot_claim, warn_if_empty    = E.release_slot, E.slot_claim, E.warn_if_empty
    local CANON_SLOT, sleep_held                     = E.CANON_SLOT, E.sleep_held
    local hoxne_sleep_open, hoxne_sleep_close        = E.hoxne_sleep_open, E.hoxne_sleep_close
    local assert_over_lock, report_refused           = E.assert_over_lock, E.report_refused
    local set_roll_eleven                            = E.set_roll_eleven
    local send_ipc, get_party, is_target_in_party    = E.send_ipc, E.get_party, E.is_target_in_party

    -- Private state, kept as upvalues because only this file writes it. The caster pool is a
    -- set rather than a count: several characters may cast on this one at once, and the gear
    -- is held until the last of them completes. The failsafe pair is the deadline that
    -- releases the slots when a completion message never arrives. cast_start_time feeds a
    -- debug line only.
    local active_incoming_casters             = {}
    local cast_start_time                     = 0
    local failsafe_active                     = false
    local failsafe_trigger_time               = 0
    ------------------------------------------------------------------------------------------------
    -- SECTION 17 - MULTIBOX SPELL-RECEIVED TRACKING
    ------------------------------------------------------------------------------------------------
    -- The incoming half of the multibox feature: what this character does when told a spell
    -- is on its way. The section also holds the Sleep hold, the eleven tracker and the buff
    -- handlers. The outgoing half, which announces this character's own casts, is core's
    -- announce_tracked_cast and finish_outgoing_cast.

    -- The received set each equip key names. This table is the only place that mapping lives.
    -- The set is fetched, named in the chat report and warned about through it.
    local SR_SET_KEY = {
        cure_set          = 'Cure_Received',
        cursna_set        = 'Cursna_Received',
        phalanx_set       = 'Phalanx_Received',
        protect_shell_set = 'Protect_Shell_Received',
        regen_set         = 'Regen_Received',
        refresh_set       = 'Refresh_Received',
        waltz_set         = 'Waltz_Received',
    }

    -- The two announce tags that start a cast here, and the lookup table each one selects. A
    -- tag not listed selects nothing, and the listener passes the message on to its COMPLETE
    -- branch.
    local IPC_CAST_KIND = {
        SPELL   = 'spell',
        ABILITY = 'ability',
    }

    -- Whether a comma-joined target list names this character exactly. The name is found as
    -- a plain substring, and a match counts only when both of its ends sit against a comma or
    -- the edge of the field, so a longer name that contains this one does not match. The walk
    -- builds no table, and it runs on every announce from every character.
    local COMMA_BYTE = (','):byte()
    local function target_list_contains(field, name)
        local last, from = #field, 1
        while true do
            local s, e = field:find(name, from, true)
            if not s then return false end
            if (s == 1 or field:byte(s - 1) == COMMA_BYTE)
                and (e == last or field:byte(e + 1) == COMMA_BYTE) then
                return true
            end
            from = s + 1
        end
    end

    -- Give back every slot borrowed for an incoming cast, forget the casters and disarm the
    -- failsafe. It does not re-equip: each caller decides what to dress the character in
    -- next. Each slot's rig cell is recolored once the slot is handed on.
    local function release_spell_received_gear()
        failsafe_active = false
        failsafe_trigger_time = 0
        active_incoming_casters = {}
        -- The registry is emptied before any slot is released. release_slot reads this same
        -- table to find a slot's owner, and a slot still registered here would answer
        -- 'spell' and stay held by the layer letting it go. Releasing first leaks every slot.
        local held = active_external_locks
        active_external_locks = {}
        for slot, _ in pairs(held) do
            release_slot(slot)
            E.repaint_slot(slot)
        end
    end

    -- Return the feature to a clean state in both directions: finish anything this character
    -- was announcing outward, then give back anything it borrowed. The commands component
    -- calls this on every SpellReceived change, not only on the way to OFF. Both delivery
    -- paths claim into one registry and each releases under its own mode, so a claim left
    -- behind by a switch would never come back.
    local function reset_spell_received_state()
        finish_outgoing_cast()
        release_spell_received_gear()
    end

    -- The layers each hold in this file yields to, keyed by the resolver's answer. Received
    -- gear yields to an item use, the disable hold, a strip hold, the Hoxne hold, the Sleep
    -- hold and the cast in progress. The Sleep hold yields to the first four of those.
    local RECEIVED_YIELDS_TO = { ['ench'] = true, ['disable'] = true, ['strip'] = true, ['hoxne'] = true, ['sleep'] = true, ['implement'] = true }
    local SLEEP_YIELDS_TO    = { ['ench'] = true, ['disable'] = true, ['strip'] = true, ['hoxne'] = true }

    -- The precedence pass every hold in this file runs before it equips. An equip into a slot
    -- a lower layer has disabled would be diverted, so each slot this hold may take is enabled
    -- first and returned in the first result, for the caller to claim after the equip. A slot
    -- a higher layer holds is left alone and named with its holder in the second result, so
    -- the caller can say why that piece did not go on. The second result is nil when nothing
    -- was refused.
    local function free_slots(set, yields_to)
        local taken, refused = {}, nil
        for slot in pairs(set) do
            local claim = slot_claim(slot)
            if claim and yields_to[claim] then
                refused = refused or {}
                refused[slot] = claim
            else
                taken[slot] = true
                enable(slot)
            end
        end
        return taken, refused
    end

    -- Dress the pieces a hold took over the weapon lock, after the ordinary equip. The hold
    -- outranks the lock, so in a slot the lock holds, the hold's piece replaces the lock's.
    local function dress_over_lock(set, taken)
        local over
        for slot in pairs(taken) do
            over = over or {}
            over[slot] = set[slot]
        end
        if over then assert_over_lock(over) end
    end

    -- Wear the set for an incoming spell or ability, and hold those slots until the cast
    -- completes. Each miss has a warning of its own: an id with no entry, an entry naming no
    -- set, and a named set that does not exist.
    local function equip_spell_received_gear(spell_id, spell_type)
        if settings.debug then debug("Equip gear function triggered: " .. spell_id .. ", " .. spell_type) end
        local s_info
        if spell_type == "spell" then
            s_info = spell_info[spell_id]
        elseif spell_type == "ability" then
            s_info = ability_info[spell_id]
        end
        if not s_info then
            warn("Unknown Spell for Spell Received Gear")
            return
        end

        local set_key = SR_SET_KEY[s_info.equip]
        local set_name = set_key and ('sets.' .. set_key)
        local spell_received_set = {}
        if not set_key then
            warn("Unknown Equip Set for Spell Received Gear")
        elseif sets[set_key] then
            spell_received_set = sets[set_key]
        else
            warn(set_name .. " not found!")
        end

        if type(spell_received_set) == 'table' then
            -- Reported the way an ordinary cast reports its set, so received gear shows in the
            -- same running commentary. There is no fallback to trace: this set dresses the
            -- slots or nothing does.
            if set_name then
                if warn_if_empty(spell_received_set, set_name) then
                    info('[' .. set_name .. '][Not Usable] -> nothing to equip.')
                else
                    info('[' .. set_name .. '][Used]')
                end
            end
            -- Free what this layer may take, name what it may not, equip, then claim only
            -- what was freed.
            local taken, refused = free_slots(spell_received_set, RECEIVED_YIELDS_TO)
            report_refused('Received gear', refused)
            equip(spell_received_set)
            dress_over_lock(spell_received_set, taken)
            if state.SpellReceived.value == "ON" then
                -- Hold the slots so nothing else overwrites the received gear before the
                -- spell lands. Only the slots this set dressed are held, since holding one
                -- whose equip was diverted would hold gear that never went on. Each held
                -- slot's rig cell is recolored.
                for slot in pairs(taken) do
                    disable(slot)

                    if settings.debug then debug("Locking " .. tostring(slot)) end
                    active_external_locks[slot] = true
                    E.repaint_slot(slot)
                end
            end
        end
    end

    -- The Sleep hold. Sleep gear is for a drain piece that wakes the character on its first
    -- tick, so being slept dresses idle gear plus sets.Weapons.Sleep and holds the slots that
    -- set names. It holds only the ones no higher layer holds: an item use, the disable hold,
    -- a strip hold and the Hoxne hold outrank it, and every layer below yields to it. The
    -- registry is the equip component's, keyed by canonical slot and holding the item, so the
    -- resolver answers 'sleep' for the slot, and a higher layer that hands the slot back can
    -- put the drain gear on again. An empty set holds nothing. The status box is repainted
    -- once the slots are recorded, and only when something was held. Returns whether
    -- anything was held.
    local function hold_sleep_gear()
        local built_set = {}
        if sets.Idle then built_set = sets.Idle else warn('sets.Idle not found!') end
        local sleep_set = sets.Weapons and sets.Weapons.Sleep
        if not sleep_set then
            warn(sets.Weapons and 'sets.Weapons.Sleep not found!' or 'sets.Weapons not found!')
            equip(built_set)
            return false
        end
        info('Locking Sleep Gear')
        -- set_combine, not merge_into. built_set is the job file's own sets.Idle, not a copy,
        -- so an in-place merge would write the sleep gear into the player's idle set for good.
        built_set = set_combine(built_set, sleep_set)
        local taken, refused = free_slots(sleep_set, SLEEP_YIELDS_TO)
        report_refused('Sleep gear', refused)
        -- Opened before the equip, so a range or ammo piece reaches its slot under
        -- ON-Allow Critical, whose filter would otherwise strip it from the request.
        hoxne_sleep_open(taken)
        equip(built_set)
        dress_over_lock(sleep_set, taken)
        local held = false
        for slot in pairs(taken) do
            disable(slot)
            sleep_held[CANON_SLOT[slot] or slot] = sleep_set[slot]
            held = true
        end
        if held then display_box_update() end
        return held
    end

    -- Waking hands every held slot to whoever is next in line. Each slot is deregistered
    -- first, because release_slot reads this same registry: a slot still recorded here would
    -- answer 'sleep' and be re-asserted by the call meant to let it go. The Hoxne window
    -- closes before the slots go, so the relock it sends finds range enabled when it lands.
    -- The status box is repainted once every slot is handed on. Returns whether anything was
    -- held.
    local function release_sleep_gear()
        if next(sleep_held) == nil then return false end
        hoxne_sleep_close(sleep_held)
        for canon in pairs(sleep_held) do
            sleep_held[canon] = nil
            release_slot(canon)
        end
        display_box_update()
        return true
    end

    -- The eleven tracker --------------------------------------------------------------------------
    -- The total of every Corsair roll standing on this character, and the one answer the equip
    -- component's flag takes from it: whether any of them is an eleven. Only the action packet
    -- carries a total, at the moment a roll or its Double-Up lands. The buff list carries the
    -- roll's id and never its number. So the table is empty after every load until the next
    -- roll or Double-Up lands here, or a character in this one's party answers the question
    -- the recovery below sends. The th component's action handler hands every category-6
    -- packet to roll_action. The clears below and the lose-buff handler take entries out, th's
    -- zone handler calls roll_clear, and the equip component's setter asks for the rebuild
    -- when the answer changes. Nothing here prints.

    -- Phantom Roll ability id to the roll's buff id, and the set of those buff ids. Built once
    -- at construction from the rows typed CorsairRoll. Double-Up is a JobAbility with no
    -- status, so it is absent. A Double-Up packet is named by its roll: its top-level param is
    -- the roll's own ability id, as on the roll itself.
    local function roll_index(abilities)
        local by_ability, by_buff = {}, {}
        for _, row in pairs(abilities) do
            if row.type == 'CorsairRoll' then
                by_ability[row.id] = row.status
                by_buff[row.status] = true
            end
        end
        return by_ability, by_buff
    end
    local ROLL_JA, ROLL_BUFF = roll_index(res.job_abilities)

    -- Buff id to { total, at }, at most one table per roll, updated in place by each later
    -- packet for that roll. ROLL_STALE is the cap: an entry older than that many seconds is
    -- dropped at the next write of any kind. Nothing polls the table.
    local rolls = {}
    local ROLL_STALE = 660

    -- After every write, whether a total recorded, an entry deleted, a clear or an entry the
    -- cap drops here, recompute whether any entry stands at eleven and hand the answer to the
    -- setter. The setter owns the change test, so the answer is handed over every time.
    -- Assigning nil to an existing key during a pairs walk is defined in Lua 5.1, so stale
    -- entries are dropped where they are found.
    local function roll_recompute()
        local now, eleven = os.clock(), false
        for buff, entry in pairs(rolls) do
            if now - entry.at > ROLL_STALE then
                rolls[buff] = nil
            elseif entry.total == 11 then
                eleven = true
            end
        end
        set_roll_eleven(eleven)
    end

    -- One category-6 action packet, from any actor. A non-roll ability misses ROLL_JA and
    -- returns before the target list is touched. For a roll, this character's entry is the
    -- target whose id is the player's. No entry means the roll did not reach this character:
    -- an out-of-range party member receives the packet without being listed, and a roll on
    -- strangers lists only them.
    --
    -- The entry's first action carries the outcome in its message and the roll's total in its
    -- param, on every entry alike:
    --   420, 421, 424  the roll, the roll received, the Double-Up. The total is recorded. A
    --                  held roll's later packet overwrites it in place, including a re-roll
    --                  of a held roll, which raises no buff event.
    --   426, 427       the bust pair. The roll is taken out.
    --   422, 423       the no-effect pair, drawn when a second Corsair's roll of the same
    --                  name, or its Double-Up, lands on a target already holding the first
    --                  Corsair's roll. The target keeps the first roll, so nothing is
    --                  written, since a delete would drop a standing entry.
    -- Any other message writes nothing.
    local function roll_action(data)
        local buff = ROLL_JA[data.param]
        if not buff then return end
        local me, targets = player.id, data.targets
        for i = 1, #targets do
            local target = targets[i]
            if target.id == me then
                local action = target.actions[1]
                local msg = action and action.message
                if msg == 420 or msg == 421 or msg == 424 then
                    local entry = rolls[buff]
                    if entry then
                        entry.total, entry.at = action.param, os.clock()
                    else
                        rolls[buff] = { total = action.param, at = os.clock() }
                    end
                elseif msg == 426 or msg == 427 then
                    rolls[buff] = nil
                else
                    return
                end
                roll_recompute()
                return
            end
        end
    end

    -- The roll's buff left this character, so its entry goes too. The lose-buff handler below
    -- calls this for a roll buff, which covers a roll that expires, busts, is folded or drops
    -- on death.
    local function roll_lost(buff)
        rolls[buff] = nil
        roll_recompute()
    end

    -- Every roll leaves a character that zones, so th's zone handler clears the whole table
    -- before it sends its own rebuild. The buff losses that follow the zone-in find the
    -- entries already gone.
    local function roll_clear()
        for buff in pairs(rolls) do rolls[buff] = nil end
        roll_recompute()
    end

    -- The recovery after a load. The table starts empty and no packet carries a total after
    -- the fact, so a character asks the others on this machine once. Each character in the
    -- asker's party that holds a total answers, addressed to the asker alone. The asker
    -- records a total only for a roll it has and holds no total for yet, so an answer never
    -- replaces a total a packet wrote. Each record is a tracker write like any other.
    --
    -- Two messages on the IPC channel, read by the listener below before it tests the
    -- spell-received mode, so a character with that mode off still asks and answers:
    --   RAHVIN|ROLLQ|<asker>
    --   RAHVIN|ROLL|<asker>|<buff id>|<total>
    -- A message's eighth byte is the first letter of its tag. Of the tags this engine sends,
    -- only these two begin with R, so every other message is passed over on one byte read.
    local ROLL_TAG = ('R'):byte()

    -- The question, sent once by the root's startup schedule.
    local function roll_query()
        send_ipc('RAHVIN|ROLLQ|' .. player.name)
    end

    -- One message that may be either roll message. Returns whether it was one. A question
    -- from this character, or from one outside its party, gets no answer, and an entry past
    -- the cap is not sent.
    local function roll_ipc(msg)
        local asker = msg:match('^RAHVIN|ROLLQ|([^|]+)$')
        if asker then
            if asker ~= player.name and is_target_in_party(asker, get_party()) then
                local now = os.clock()
                for buff, entry in pairs(rolls) do
                    if now - entry.at <= ROLL_STALE then
                        send_ipc('RAHVIN|ROLL|' .. asker .. '|' .. buff .. '|' .. entry.total)
                    end
                end
            end
            return true
        end
        local to, buff, total = msg:match('^RAHVIN|ROLL|([^|]+)|(%d+)|(%d+)$')
        if not to then return false end
        buff = tonumber(buff)
        if to == player.name and ROLL_BUFF[buff] and buffactive[buff] and not rolls[buff] then
            rolls[buff] = { total = tonumber(total), at = os.clock() }
            roll_recompute()
        end
        return true
    end


    -- The IPC listener: another character on this machine announcing a cast, or reporting one
    -- finished. Built as a closure, so the caster pool and the failsafe pair stay upvalues.
    -- The root registers it on 'ipc message'.
    --
    -- The cast messages, in the form core's sender writes them:
    --   RAHVIN|SPELL|<caster>|<comma-joined targets>|<spell id>|<time sent>
    --   RAHVIN|ABILITY|<caster>|<comma-joined targets>|<ability id>|<time sent>
    --   RAHVIN|COMPLETE|<caster>|<time sent>
    -- The eleven tracker's two messages, above, are read before the mode is tested. A message
    -- with any other tag is ignored.
    E.sr_ipc_message = function(msg)
        if msg:byte(8) == ROLL_TAG and roll_ipc(msg) then return end
        if state.SpellReceived.value == 'OFF' then return end

        -- One pattern serves both announce kinds, which differ only in the tag and in the
        -- table the id is read from. A COMPLETE message carries two fields fewer, so it
        -- cannot match this shape. It reaches the branch below, which tests the caster pool
        -- before it reads the string.
        local tag, caster_name, target_name, spell_id, time_str =
            msg:match('^RAHVIN|([^|]*)|([^|]*)|([^|]*)|([^|]*)|(.*)$')
        local kind = tag and IPC_CAST_KIND[tag]

        if kind then
            if target_name and target_list_contains(target_name, player.name) then
                local time_sent = tonumber(time_str) or 9999999999999
                local time_received = get_time()
                if settings.debug then
                    debug("Targeted IPC Message Received: " ..
                        msg .. " after " .. (time_received - time_sent) .. " ms")
                end

                if next(active_incoming_casters) == nil then
                    cast_start_time = time_sent
                    equip_spell_received_gear(tonumber(spell_id), kind)
                end

                -- Only the first caster in a window dresses gear, since the test above is on
                -- an empty pool. A later caster joins the pool and pushes the failsafe out
                -- without re-equipping, so the first announced set stays on until the pool
                -- empties.
                active_incoming_casters[caster_name] = true
                if settings.debug then
                    debug(caster_name ..
                        " added to Active Incoming Casters (" .. count_keys(active_incoming_casters) .. ")")
                end
                failsafe_active = true
                failsafe_trigger_time = os.clock() + settings.delay
                if settings.debug then
                    debug(player.name ..
                        " is targeted by " .. caster_name .. ". Gear equipped and timer refreshed.")
                end
            end
        -- A completion is read only while somebody is pooled, so with nobody pooled this
        -- branch never touches the string, and with a pool it costs one match. The match takes
        -- the caster and the time from a message of four or more fields, which is the shape
        -- the sender writes, and ignores anything shorter.
        elseif next(active_incoming_casters) ~= nil then
            local caster_name, time_str = msg:match('^RAHVIN|COMPLETE|([^|]*)|([^|]*)')
            if caster_name then
                if settings.debug then debug("Targeted IPC Message Received: " .. msg) end
                local time_sent = tonumber(time_str)
                if active_incoming_casters[caster_name] then
                    active_incoming_casters[caster_name] = nil
                    if settings.debug then
                        debug(caster_name ..
                            " finished casting after " ..
                            (time_sent - cast_start_time) ..
                            " ms and is removed from Active Incoming Casters (" ..
                            count_keys(active_incoming_casters) .. ")")
                    end
                    if next(active_incoming_casters) == nil then
                        if settings.debug then debug("No active incoming casts remain. Resetting gear.") end
                        if state.SpellReceived.value == 'ON' then
                            local held = active_external_locks
                            active_external_locks = {}
                            for slot, _ in pairs(held) do
                                release_slot(slot)
                                E.repaint_slot(slot)
                                if settings.debug then debug("Unlocking " .. tostring(slot)) end
                            end
                        end
                        equip_set_command()
                        failsafe_active = false
                    end
                end
            end
        end
    end

    -- The failsafe, on prerender. A completion message can fail to arrive, when the caster
    -- zoned, was interrupted in a way that reported nothing, or crashed. Without this the
    -- borrowed slots would stay held, and the character would fight in cure-potency gear.
    -- Every announce aimed at this character arms it and pushes it out, so it fires only
    -- after the whole window has been quiet for settings.delay seconds.
    --
    -- It is a prerender registration of its own, so an error in the Hoxne driver cannot stop
    -- it.
    E.sr_prerender = function()
        if not failsafe_active or state.SpellReceived.value == "OFF" then return end

        if os.clock() >= failsafe_trigger_time then
            if settings.debug then debug("Failsafe triggered! Sending equipment reset command.") end
            release_spell_received_gear()
            equip_set_command()
        end
    end

    -- Buff gained. Registered by the root on 'gain buff'. Three jobs: clear the two
    -- prediction flags, use a status-removal item where the job file allows it, and dress
    -- and hold gear for the ailments that need it.
    --
    -- The buff ids handled: 2 sleep, 4 paralysis, 6 silence (with a mage main job or subjob),
    -- 7 petrification, 10 stun, 15 doom.
    E.sr_gain_buff = function(id)
        -- A prediction covers the gap between using the ability and its buff becoming
        -- readable. Once the buff is here, the prediction is dropped.
        if id == BUFF_ACCESSION then E.accession_predicted = false end
        if id == BUFF_DIVINE_SEAL then E.divine_seal_predicted = false end
        if id == 4 or (id == 6
                and (Mage_Job:contains(player.main_job) or Mage_Job:contains(player.sub_job))) then
            if player.inventory['Remedy'] ~= nil then
                if AutoItem == true then
                    windower.chat.input('/item "Remedy" <me>')
                end
            else
                info('No Remedies in inventory.')
            end
        elseif id == 2 then
            hold_sleep_gear()
            -- Stoneskin absorbs the damage that would wake the character, so it is canceled
            -- at once. A character slept under Stoneskin would otherwise stay asleep.
            if buffactive['Stoneskin'] then
                info('Cancel Stoneskin')
                cancel('Stoneskin')
            end
        elseif id == 7 or id == 10 then
            log(id == 7 and 'Petrification' or 'Stunned', ' - Checking Gear')
            equip(build_current_set())
        elseif id == 15 then
            info('DOOOOOOM!!!')
            -- Doom gear is dressed here only while SpellReceived is OFF. With it ON, a Cursna
            -- announced at this character dresses and holds the same set through the IPC
            -- path above, and doing both would put two owners on one slot.
            if state.SpellReceived.value == "OFF" then
                if sets.Cursna_Received then
                    warn_if_empty(sets.Cursna_Received, 'sets.Cursna_Received')
                    -- The same precedence pass the IPC path runs: free what this may take,
                    -- name what outranks it, and claim only what it got.
                    local taken, refused = free_slots(sets.Cursna_Received, RECEIVED_YIELDS_TO)
                    report_refused('Received gear', refused)
                    equip(sets.Cursna_Received)
                    dress_over_lock(sets.Cursna_Received, taken)
                    -- Both delivery paths claim into one registry. Their modes are exclusive,
                    -- so a claim made here is released by the lose-buff handler below or by a
                    -- mode switch, whichever comes first. Neither path can strand the other's
                    -- claim, because there is only one table to empty.
                    for slot in pairs(taken) do
                        disable(slot)
                        active_external_locks[slot] = true
                        E.repaint_slot(slot)
                    end
                    info('Locking Cursna Received Gear')
                else
                    warn('sets.Cursna_Received not found!')
                end
            end
            if AutoItem then
                if player.inventory['Holy Water'] ~= nil then
                    windower.chat.input('/item "Holy Water" <me>')
                else
                    info('No Holy Waters in inventory. Unable to cure DOOM status!')
                end
            end
        end
    end

    -- Buff lost. Registered by the root on 'lose buff'. Releases the gear the matching gain
    -- held, clears the two prediction flags, and takes a roll's total out of the eleven
    -- tracker. Only sleep and doom hold gear, so only those two are released here. The other
    -- ailments above never hold anything.
    E.sr_lose_buff = function(id)
        -- Cleared on loss as well as on gain, so a prediction never outlives its buff.
        if id == BUFF_ACCESSION then E.accession_predicted = false end
        if id == BUFF_DIVINE_SEAL then E.divine_seal_predicted = false end
        -- A roll's buff leaving clears that roll from the tracker, however it ended.
        if ROLL_BUFF[id] then roll_lost(id) end
        local buff = res.buffs[id]
        local name = buff and buff.en or tostring(id)
        local gain = false
        -- Doom (15) is released here only while SpellReceived is OFF. With it ON, the
        -- received-gear path owns the Cursna set and its release.
        local doom = id == 15 and state.SpellReceived.value == "OFF"
        if doom or id == 2 then
            -- Deregister before unlocking. UnlockByMode skips any slot still claimed, so the
            -- slots the hold took would otherwise be passed over and never come back.
            if doom then release_spell_received_gear() else release_sleep_gear() end
            UnlockByMode()
            local built_set = build_current_set()
            -- A job file without buff_change_custom is passed over silently here. The
            -- ordinary buff-change path, which runs on the same event, already warns that
            -- the hook is missing.
            if buff_change_custom then
                merge_into(built_set, buff_change_custom(name, gain))
            end
            equip(built_set)
            info(doom and 'Unlocking Cursna Received Gear' or 'Unlocking Sleep Gear')
        end
    end

    -- For the commands component, which calls it on every SpellReceived change.
    E.reset_spell_received_state = reset_spell_received_state
    -- The failsafe flag through a read-only accessor, so the debug box can show it while the
    -- flag stays private to this file. Everything above reads the upvalue directly.
    E.sr_failsafe_active = function() return failsafe_active end
    -- The eleven tracker's entry points: the packet read and the zone clear for the th
    -- component, and the question the root schedules once.
    E.roll_action = roll_action
    E.roll_clear = roll_clear
    E.roll_query = roll_query

    -- The version stamp. The root checks it against Rahvin_GS, so a stale copy of this file
    -- stops the load with an error that names it.
    return '2.1'
end
