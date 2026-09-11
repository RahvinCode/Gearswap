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
--   the equip and release paths, the Sleep hold, and the four event bodies the root
--   registers: the IPC listener, the failsafe tick, and the two buff handlers.
--
-- WHAT IT DOES  When another character on this machine starts casting a supported spell on
--          this one, that character announces it over Windower's IPC channel. This file
--          wears the matching received set immediately -- before the spell lands, which is
--          what makes it work through Quick Magic -- holds those slots, and gives them back
--          when the completion arrives.
--
-- EXPORTS  sr_ipc_message, sr_prerender, sr_gain_buff and sr_lose_buff, all registered by
--          the root; reset_spell_received_state, called by commands when the mode changes;
--          sr_failsafe_active, a read-only accessor the debug box uses to see the private
--          failsafe flag below. It also writes accession_predicted and divine_seal_predicted,
--          which the state component declares and the gear builders read.
-- LOADS    Ninth of fifteen. Two globals it calls resolve LATE -- cancel (monitor, eleventh)
--          and equip_set_command (the root, fifteenth) -- so neither may be bound to a local
--          in the import block. Both are only reached from event bodies, which never run
--          before the load completes.
--
-- The two buff handlers do more than their names suggest: alongside the prediction-flag
-- clears they own the engine's status-ailment responses -- sleep, doom, petrification, stun,
-- and the automatic Remedy and Holy Water. Those live here because the doom response equips
-- and holds the same Cursna set this file already knows how to claim slots for.

-- requires: rahvings/state, rahvings/core, rahvings/equip, rahvings/hoxne, rahvings/builders
return function(E)
    -- Immutable dependencies bound once at construction, so no call below repeats the lookup
    -- for them. The cross-component mutables are never bound here: accession_predicted and
    -- divine_seal_predicted are reached through E at every touch, because a file-local copy
    -- would not be the one the other components read and write.
    local BUFF_ACCESSION, BUFF_DIVINE_SEAL, Mage_Job = E.BUFF_ACCESSION, E.BUFF_DIVINE_SEAL, E.Mage_Job
    local ability_info, spell_info, res, settings    = E.ability_info, E.spell_info, E.res, E.settings
    local build_current_set, count_keys, debug       = E.build_current_set, E.count_keys, E.debug
    local finish_outgoing_cast, get_time, merge_into = E.finish_outgoing_cast, E.get_time, E.merge_into
    local release_slot, slot_claim, warn_if_empty    = E.release_slot, E.slot_claim, E.warn_if_empty
    local CANON_SLOT, HOLDER_NAME, sleep_held        = E.CANON_SLOT, E.HOLDER_NAME, E.sleep_held
    local hoxne_sleep_open, hoxne_sleep_close        = E.hoxne_sleep_open, E.hoxne_sleep_close
    local assert_over_lock, report_refused           = E.assert_over_lock, E.report_refused

    -- Private state, kept as upvalues rather than on E because only this file writes it.
    -- The caster pool is a set rather than a count: several characters may be casting on
    -- this one at once, and the gear is held until the LAST of them completes. The failsafe
    -- pair is what releases the slots if a completion message never arrives at all.
    local active_incoming_casters             = {}
    local cast_start_time                     = 0
    local failsafe_active                     = false
    local failsafe_trigger_time               = 0
    ------------------------------------------------------------------------------------------------
    -- SECTION 17 - MULTIBOX SPELL-RECEIVED TRACKING
    ------------------------------------------------------------------------------------------------
    -- The incoming half of the multibox feature: what this character does when told a spell
    -- is on its way. The outgoing half -- announcing this character's own casts -- lives with
    -- the action hooks.

    -- The received set each equip key names. This table is the only place that mapping
    -- exists: the set is fetched, named for the chat report, and warned about through it.
    local SR_SET_KEY = {
        cure_set          = 'Cure_Received',
        cursna_set        = 'Cursna_Received',
        phalanx_set       = 'Phalanx_Received',
        protect_shell_set = 'Protect_Shell_Received',
        regen_set         = 'Regen_Received',
        refresh_set       = 'Refresh_Received',
        waltz_set         = 'Waltz_Received',
    }

    -- The two announce tags this character acts on, and which lookup table each selects.
    -- A tag not in here is ignored, which is how a COMPLETE message falls through to its
    -- own branch rather than being treated as a new cast.
    local IPC_CAST_KIND = {
        SPELL   = 'spell',
        ABILITY = 'ability',
    }

    -- Does a comma-joined target list name this character, exactly?
    --
    -- The test is deliberately not a split-and-compare. It finds the name as a substring,
    -- then requires each end to sit against a comma or the edge of the field -- so a longer
    -- name that merely CONTAINS this one cannot answer for it, which a naive find would get
    -- wrong. Not splitting also means the cost does not grow with the size of the list, and
    -- this runs on every announce from every character.
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

    -- Give back every slot borrowed for an incoming cast and forget the casters. Does not
    -- re-equip -- each caller decides what to dress the character in afterwards.
    local function release_spell_received_gear()
        failsafe_active = false
        failsafe_trigger_time = 0
        active_incoming_casters = {}
        -- ORDER MATTERS. The registry is emptied BEFORE any slot is released, because
        -- release_slot reads that same table to work out who owns a slot. A slot still
        -- registered here would answer "spell-received owns it" and be left held by the
        -- very layer letting go of it. Swapping these two lines leaks every slot.
        local held = active_external_locks
        active_external_locks = {}
        for slot, _ in pairs(held) do
            release_slot(slot)
        end
    end

    -- Return the feature to a clean state, from either direction: finish anything this
    -- character was announcing outward, then hand back anything it borrowed inward. The
    -- commands component calls this on EVERY mode change, not only on the way to OFF,
    -- because both delivery paths claim into one registry and each releases under its own
    -- mode -- so a claim made in one mode and left behind by a switch would never come back.
    local function reset_spell_received_state()
        finish_outgoing_cast()
        release_spell_received_gear()
    end

    -- Which layers each hold in this file yields to, by the resolver's answer. The stack is
    -- the one the equip component's header states: received gear sits below the cast in
    -- progress and the Sleep hold, the Sleep hold below the Hoxne hold, and all below the
    -- disable and strip holds and an item use.
    local RECEIVED_YIELDS_TO = { ['ench'] = true, ['disable'] = true, ['strip'] = true, ['hoxne'] = true, ['sleep'] = true, ['implement'] = true }
    local SLEEP_YIELDS_TO    = { ['ench'] = true, ['disable'] = true, ['strip'] = true, ['hoxne'] = true }

    -- The slot precedence pre-pass every hold in this file runs before it equips. A hold
    -- outranks the layers below it, but an equip into a slot a lower layer has disabled
    -- would simply be diverted -- so the slots this hold may take are freed first, and
    -- only those come back to be claimed after the equip, so the claim covers what the set
    -- really dressed rather than what it asked for. A slot a higher layer holds is left
    -- strictly alone and named with its holder in the second return, so the caller can say
    -- why that piece did not go on; the second return is nil when nothing was refused.
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

    -- The pieces a hold took, as a set of their own, dressed over the weapon lock after the
    -- ordinary equip: the hold outranks the lock, so what the lock would have kept in a slot
    -- yields to what the hold put there.
    local function dress_over_lock(set, taken)
        local over
        for slot in pairs(taken) do
            over = over or {}
            over[slot] = set[slot]
        end
        if over then assert_over_lock(over) end
    end

    -- Wear the set for an incoming spell or ability, and hold those slots until the cast
    -- completes. Every unknown is reported rather than passed over: an id with no entry, an
    -- entry naming no set, and a named set the job file never declared are three different
    -- warnings, because they are three different mistakes on the player's side.
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
            -- Reported the way an ordinary cast reports its set, so received gear appears in
            -- the same running commentary. There is no fallback chain to trace: this set
            -- dresses the slots or nothing does.
            if set_name then
                if warn_if_empty(spell_received_set, set_name) then
                    info('[' .. set_name .. '][Not Usable] -> nothing to equip.')
                else
                    info('[' .. set_name .. '][Used]')
                end
            end
            -- The slot precedence pre-pass both delivery paths run: free what this layer
            -- may take, name what it may not, equip, then claim only what was freed.
            local taken, refused = free_slots(spell_received_set, RECEIVED_YIELDS_TO)
            report_refused('Received gear', refused)
            equip(spell_received_set)
            dress_over_lock(spell_received_set, taken)
            if state.SpellReceived.value == "ON" then
                -- Hold the slots so nothing else overwrites the received gear before the
                -- spell lands. Only the ones this set actually dressed: claiming a slot
                -- whose equip was diverted would hold gear that never went on, and nothing
                -- would ever be able to explain what was in it.
                for slot in pairs(taken) do
                    disable(slot)

                    if settings.debug then debug("Locking " .. tostring(slot)) end
                    active_external_locks[slot] = true
                end
            end
        end
    end


    -- The IPC listener: another character on this machine announcing a cast, or reporting
    -- one finished. Built as a closure here so the caster pool and failsafe pair stay
    -- upvalues rather than becoming shared state; the root registers it on 'ipc message'.
    --
    -- Wire format, both directions:
    --   RAHVIN|SPELL|<caster>|<comma-joined targets>|<spell id>|<time sent>
    --   RAHVIN|ABILITY|<caster>|<comma-joined targets>|<ability id>|<time sent>
    --   RAHVIN|COMPLETE|<caster>|<time sent>
    -- The tag is what a listener keys on, so a version whose tag differs is ignored
    -- silently on both sides rather than mis-parsed.
    E.sr_ipc_message = function(msg)
        if state.SpellReceived.value == 'OFF' then return end

        -- One pattern serves both announce kinds: SPELL and ABILITY differ only in the tag
        -- and in which lookup table the id is read from. A COMPLETE message carries two
        -- fields fewer, so it cannot match this shape at all and falls through below.
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

                -- The gear is equipped only for the FIRST caster in a window -- the test
                -- above is on an empty pool. A second caster arriving mid-cast joins the
                -- pool and pushes the failsafe out, but does not re-equip: the set is
                -- already worn and re-equipping would fight the slots it already holds.
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
        elseif msg:startswith('RAHVIN|COMPLETE|') then
            if next(active_incoming_casters) ~= nil then
                if settings.debug then debug("Targeted IPC Message Received: " .. msg) end
                local split_msg = msg:split("|")
                local caster_name = split_msg[3]
                local time_sent = tonumber(split_msg[4])
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

    -- The failsafe, on prerender. A completion message can fail to arrive -- the caster
    -- zoned, was interrupted in a way that reported nothing, or crashed -- and without this
    -- the borrowed slots would stay held indefinitely, leaving the character fighting in
    -- cure-potency gear. Armed on every announce and pushed out by each new one, so it fires
    -- only after the whole window has gone quiet for settings.delay seconds.
    --
    -- This is registered as its own prerender handler rather than folded into the other one:
    -- each handler on an event gets its own protected call, so this recovery path cannot be
    -- taken down by a fault in the tick it exists to recover from.
    E.sr_prerender = function()
        if not failsafe_active or state.SpellReceived.value == "OFF" then return end

        if os.clock() >= failsafe_trigger_time then
            if settings.debug then debug("Failsafe triggered! Sending equipment reset command.") end
            release_spell_received_gear()
            equip_set_command()
        end
    end

    -- The Sleep hold. Sleep gear exists to wear a drain piece that wakes the character on
    -- its first tick, so being slept dresses idle gear plus sets.Weapons.Sleep and holds the
    -- slots that set names -- only those, and only the ones no higher layer holds: an item
    -- use and the Hoxne hold outrank it, received gear and a lock mode yield to it. The
    -- registry is the equip component's, keyed by canonical slot and holding the item, so
    -- the resolver answers 'sleep' for the slot and a layer above handing it back can put
    -- the drain gear on again. An empty set holds nothing. Returns whether anything was held.
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
        -- set_combine, NOT merge_into. built_set above is an alias of the job file's own
        -- sets.Idle, not a copy, so an in-place merge would write the sleep gear permanently
        -- into the player's idle set.
        built_set = set_combine(built_set, sleep_set)
        local taken, refused = free_slots(sleep_set, SLEEP_YIELDS_TO)
        report_refused('Sleep gear', refused)
        -- Opened before the equip, so a range or ammo piece reaches its slot under
        -- ON-Allow Critical, whose filter would strip it from the request otherwise.
        hoxne_sleep_open(taken)
        equip(built_set)
        dress_over_lock(sleep_set, taken)
        local held = false
        for slot in pairs(taken) do
            disable(slot)
            sleep_held[CANON_SLOT[slot] or slot] = sleep_set[slot]
            held = true
        end
        return held
    end

    -- Waking hands every held slot to whoever is next in line. Each slot is deregistered
    -- FIRST, because release_slot reads this same registry: a slot still recorded here
    -- would answer 'sleep' and be re-asserted by the very call meant to let it go -- the
    -- trap the received-gear release above documents, from the other direction. The Hoxne
    -- window closes before the slots go, so the relock it sends finds range enabled when
    -- it lands. Returns whether anything was held.
    local function release_sleep_gear()
        if next(sleep_held) == nil then return false end
        hoxne_sleep_close(sleep_held)
        for canon in pairs(sleep_held) do
            sleep_held[canon] = nil
            release_slot(canon)
        end
        return true
    end

    -- Buff gained. Registered by the root on 'gain buff'. Three jobs: clear the two
    -- prediction flags, spend a status-removal item where the job file allows it, and equip
    -- and hold gear for the ailments that need it.
    --
    -- The ids handled: 2 sleep, 4 paralysis, 6 silence (mage jobs only), 7 petrification,
    -- 10 stun, 15 doom.
    E.sr_gain_buff = function(id)
        -- A prediction covers only the gap between issuing the ability and its buff becoming
        -- readable. Once the buff is here, the buff itself is the better answer and the
        -- guess is dropped.
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
            -- Stoneskin absorbs the hit that would wake the character, so it is canceled
            -- outright rather than waited out. Without this, being slept under Stoneskin
            -- means staying slept until the duration ends.
            if buffactive['Stoneskin'] then
                info('Cancel Stoneskin')
                cancel('Stoneskin')
            end
        elseif id == 7 or id == 10 then
            log(id == 7 and 'Petrification' or 'Stunned', ' - Checking Gear')
            equip(build_current_set())
        elseif id == 15 then
            info('DOOOOOOM!!!')
            -- Doom gear is equipped from here only while the multibox mode is OFF. With it
            -- ON, the character being doomed is expected to have a Cursna announced at it,
            -- and the IPC path above will dress and hold the same set -- doing both would
            -- have two owners claiming one slot.
            if state.SpellReceived.value == "OFF" then
                if sets.Cursna_Received then
                    warn_if_empty(sets.Cursna_Received, 'sets.Cursna_Received')
                    -- The same precedence pre-pass the IPC path uses: free what this may
                    -- take, name what outranks it, claim only what it actually got.
                    local taken, refused = free_slots(sets.Cursna_Received, RECEIVED_YIELDS_TO)
                    report_refused('Received gear', refused)
                    equip(sets.Cursna_Received)
                    dress_over_lock(sets.Cursna_Received, taken)
                    -- Both delivery paths claim into ONE registry. They are the same
                    -- feature and their modes are exclusive, so a claim made here is
                    -- released either by the doom handler below or by a mode switch,
                    -- whichever comes first -- and neither can leave the other's claim
                    -- stranded, because there is only one table to empty.
                    for slot in pairs(taken) do
                        disable(slot)
                        active_external_locks[slot] = true
                    end
                    info('Locking Cursna Received Gear')
                else
                    warn('sets.Cursna_Received not found!')
                end
            end
            if AutoItem then
                if player.inventory['Holy Water'] ~= nil then -- The nil test exists so the missing-item case can be reported
                    windower.chat.input('/item "Holy Water" <me>')
                else
                    info('No Holy Waters in inventory. Unable to cure DOOM status!')
                end
            end
        end
    end

    -- Buff lost. Registered by the root on 'lose buff'. Releases the gear the matching gain
    -- locked, and clears the two prediction flags. Only sleep and doom are handled here --
    -- the other ailments above equip but never hold, so they have nothing to give back.
    E.sr_lose_buff = function(id)
        -- Cleared here as well as on gain, because a prediction can end without its buff
        -- ever appearing: the charge was spent, the duration lapsed, or the buff was
        -- stripped. Whichever way it ended, the guess ends with it.
        if id == BUFF_ACCESSION then E.accession_predicted = false end
        if id == BUFF_DIVINE_SEAL then E.divine_seal_predicted = false end
        local buff = res.buffs[id]
        local name = buff and buff.en or tostring(id)
        local gain = false
        --Unlock cursna received gear if not tracking party spellcasting through IPC
        local doom = id == 15 and state.SpellReceived.value == "OFF"
        if doom or id == 2 then
            -- Deregister BEFORE unlocking. UnlockByMode skips any slot still claimed, so
            -- the slots either hold took would otherwise be passed over and never come
            -- back. Same ordering trap as the release path above, from the other direction.
            if doom then release_spell_received_gear() else release_sleep_gear() end
            UnlockByMode()
            local built_set = build_current_set()
            -- Silent when the job file defines no buff_change_custom: the ordinary
            -- buff-change path already warns about it once, and warning again on every
            -- sleep and doom would be noise.
            if buff_change_custom then
                merge_into(built_set, buff_change_custom(name, gain))
            end
            equip(built_set)
            info(doom and 'Unlocking Cursna Received Gear' or 'Unlocking Sleep Gear')
        end
    end

    -- Handed to E for the commands component, which calls it on every mode change.
    E.reset_spell_received_state = reset_spell_received_state
    -- A read-only accessor rather than the flag itself, so the debug box can show the
    -- failsafe without the flag leaving this file. Everything that reads it on a hot path
    -- above uses the upvalue directly; only the box pays for the call.
    E.sr_failsafe_active = function() return failsafe_active end

    -- Version stamp. The root asserts this against Rahvin_GS, so a stale copy of this file
    -- announces itself at load instead of running.
    return '2.0'
end
