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
-- COMPONENT: monitor -- section 19: the polling engine, movement, traits and bursts
----------------------------------------------------------------------------------------------------
-- CONTENTS
--   Section 19 - Automation and combat monitoring. The main polling engine and the
--   movement detection inside it, the two weapon-trait checks, skillchain burst tracking,
--   buff cancellation, and the Escha temporary-item macro.
--
-- EXPORTS  Nothing onto E. Its functions are globals. It writes these fields the state
--          component declares: is_moving, DualWield and TwoHand, the three
--          last_skillchain_* fields, and SpellCastTime, which it zeroes when a busy window
--          expires.
-- CALLERS  The root registers main_engine on the outgoing chunk event. th.lua calls
--          run_burst, commands.lua calls two_hand_check and escha_temps, and
--          spellreceived.lua calls cancel. The root and the lifecycle component also hand
--          dual_wield_check and two_hand_check to coroutine.schedule, so a search for
--          "dual_wield_check(" misses those uses.
-- LOADS    After every component whose exports it binds. Two globals it calls are declared
--          in files that load later: debug_box_update in the display component and
--          equip_set_command in the root. Neither may be bound in the import block below.
--          Both resolve because Lua reads a global at call time, and main_engine never runs
--          before the load completes. E.drag_settle, from the display component, is read
--          from E at the call for the same reason.
--
-- The reverse also holds. th.lua and spellreceived.lua load before this file, and their
-- calls to run_burst and cancel resolve at call time in the same way.

-- requires: rahvings/state, rahvings/core, rahvings/equip
return function(E)
    -- The exports this file uses, bound once at construction. The shared mutable fields are
    -- never bound here. The state fields this file writes, and Spellstart, are read and
    -- written through E, because a local copy would not be the one the other components see.
    local Cities, Language, skillchains = E.Cities, E.Language, E.skillchains
    local get_mob_by_id, res, settings  = E.get_mob_by_id, E.res, E.settings
    local release_implement             = E.release_implement

    -- main_engine's three clocks: the 30 second housekeeping pass, the 2 second job-file
    -- Cycle_Timer, and the 0.1 second floor on the engine body. Each is stamped on its own,
    -- so one running late does not shift the others.
    local UpdateTime1                         = os.clock()
    local UpdateTime2                         = os.clock()
    local main_engine_time                    = os.clock()

    -- The last position read from an outgoing 0x015 packet, and the clock it was read at.
    -- The fields follow the packet's order: X, then Z, then Y.
    local Location                            = { x = 0, z = 0, y = 0, t = 0 }

    -- Raised when the movement flag changes. The gated body turns it into one rebuild
    -- request on its next pass that is not busy, then lowers it. Changes that arrive while
    -- busy wait and cost one rebuild between them.
    local Require_Update                      = false
    ------------------------------------------------------------------------------------------------
    -- SECTION 19 - AUTOMATION AND COMBAT MONITORING
    ------------------------------------------------------------------------------------------------
    -- The polling engine and its movement detection, the two weapon-trait checks, skillchain
    -- tracking, buff cancellation, and the Escha drink macro.

    -- Drink the six Escha temporary items in sequence. One chained command, because each
    -- use has to wait out the one before it.
    function escha_temps()
        info('Escha Temps')
        windower.send_command(
            "input /item \"Monarch's Drink\" <me>;wait 2.5;input /item \"Braver's Drink\" <me>;wait 2.5;input /item \"Fighter's Drink\" <me>;wait 2.5;input /item \"Champion's Drink\" <me>;wait 2.5;input /item \"Soldier's Drink\" <me>;wait 2.5;input /item \"Barbarian's Drink\" <me>")
    end

    -- Record a skillchain so a following nuke can burst on it, or clear the record when a
    -- weaponskill closes the window. The action handler in th.lua calls this for every
    -- actor, not just the player, so a chain closed by anyone opens the window. This stores
    -- the elements and the time. The builders decide whether a cast falls inside the window
    -- and matches an element.
    function run_burst(data)
        local target = data.targets[1]
        local action = target and target.actions[1]
        if not action then return end
        -- The three add-effect message ranges that report a skillchain: ordinary
        -- skillchain damage, skillchain healing, and the Umbra and Radiance chains.
        if (action.add_effect_message > 287 and action.add_effect_message < 302)
            or (action.add_effect_message > 384 and action.add_effect_message < 399)
            or (action.add_effect_message > 766 and action.add_effect_message < 771)
        then
            log('There was a skillchain')
            local t = get_mob_by_id(data.targets[1].id)
            -- spawn_type 16 is a monster, and 21 yalms is burst range. A chain on anything
            -- else, or too far away, is not recorded.
            if t and t.spawn_type == 16 and t.distance:sqrt() < 21 then
                E.last_skillchain_id = t.id
                E.last_skillchain_time = os.clock()
                E.last_skillchain_elements = {}
                log('Skillchain detected')
                local skillchain = skillchains[action.add_effect_message]
                -- Stored keyed by element rather than as a list, so the builders test
                -- membership with one table read instead of a scan.
                for index, element in pairs(skillchain.elements) do
                    E.last_skillchain_elements[element] = element
                end
                log(E.last_skillchain_elements)
            end
        -- A weaponskill landing on the tracked mob closes the window, so the record is
        -- dropped and a later nuke is not dressed for a burst that can no longer happen.
        elseif data.category == 3 and data.param ~= 0 then
            -- The action data already carries the target id, so no mob lookup is needed here.
            if E.last_skillchain_id ~= 0 and data.targets[1].id == E.last_skillchain_id then
                log('Skillchain is closed for [', E.last_skillchain_id, ']')
                E.last_skillchain_elements = {}
                E.last_skillchain_id = 0
                E.last_skillchain_time = 0
            end
        end
    end

    -- Cancel buffs by name or id. Accepts several comma-separated patterns and cancels
    -- every active buff any of them matches, so one call can clear a family.
    function cancel(...)
        local command = table.concat({ ... }, ' ')
        if not command then return end
        local status_id_tab = command:split(',')
        status_id_tab.n = nil
        for _, v in pairs(player.buffs) do
            for _, r in pairs(status_id_tab) do
                -- Matched against both the localized buff name and the raw id, so a caller
                -- may pass either, and wc_match allows wildcards in the pattern.
                if windower.wc_match(res.buffs[v][Language], r) or windower.wc_match(tostring(v), r) then
                    cancel_buff(v)
                    break
                end
            end
        end
    end

    -- Cancel one buff by id, by injecting the game's own cancel packet (0xF1). The id is
    -- written little-endian across two bytes.
    function cancel_buff(id)
        windower.packets.inject_outgoing(0xF1, string.char(0xF1, 0x04, 0, 0, id % 256, math.floor(id / 256), 0, 0))
    end

    -- Re-read whether the character has the Dual Wield trait, job trait 18, which decides the
    -- offhand the builders choose. It is scheduled after load and after a subjob change, and
    -- the housekeeping pass runs it every 30 seconds.
    function dual_wield_check()
        local current_abilities = windower.ffxi.get_abilities()
        if table.contains(current_abilities.job_traits, 18) then
            E.DualWield = true
        else
            E.DualWield = false
        end
    end

    -- Whether a named weapon is two-handed. res.items:with scans the whole item table, and
    -- the answer for a name never changes, so each name is resolved once per load and
    -- remembered. Misses are remembered too, or an unknown name would rescan on every check.
    local name_is_two_handed
    -- The skill table and the memo are scoped to this block, so only name_is_two_handed can
    -- reach them.
    do
        -- The six weapon skills the game treats as two-handed: Great Sword, Great Axe,
        -- Scythe, Polearm, Great Katana and Staff.
        local TWO_HAND_SKILL = { [4] = true, [6] = true, [7] = true, [8] = true, [10] = true, [12] = true }
        local two_hand_memo = {}
        name_is_two_handed = function(name)
            local known = two_hand_memo[name]
            if known == nil then
                local row = res.items:with('en', name)
                known = row ~= nil and TWO_HAND_SKILL[row.skill] ~= nil
                two_hand_memo[name] = known
            end
            return known
        end
    end

    -- Re-read the two-handed flag from the weapon the current mode names. The builders read
    -- the flag to choose the offhand.
    --
    -- Two shapes of a missing main are handled differently. A mode with no main entry
    -- answers from the weapon worn. After a mode change that is the weapon the previous mode
    -- left in hand, and at load it is whatever the character logged in holding. A mode whose
    -- main is a table with no name clears the flag.
    function two_hand_check()
        local weapon_set = sets.Weapons[state.WeaponMode.value]
        local weapon_name = weapon_set and weapon_set.main
        if not weapon_name then weapon_name = player.equipment.main end
        if type(weapon_name) == 'table' then weapon_name = weapon_name.name end
        if weapon_name == nil then
            E.TwoHand = false
            return
        end
        E.TwoHand = name_is_two_handed(weapon_name)
    end

    -- The main polling engine. The root registers it on the raw outgoing chunk event, and
    -- that has two consequences. It runs only when the client sends a packet, so it is not
    -- a reliable timer, and anything that must run on schedule belongs on prerender. And
    -- every outgoing packet enters here, so the body is gated to once per 0.1 seconds, with
    -- the movement check above the gate.
    --
    -- The 0.1 second rate is a product requirement. Make a tick cheaper, never rarer.
    function main_engine(id, data)
        local now = os.clock()
        -- A box drag settles here, on the clock just read, above every gate and early
        -- return. A character who is dead, asleep or mid-action can still drag a box, and
        -- the save is owed either way. It returns at once when nothing was dragged. It is
        -- read from E at the call because the display component loads after this file.
        E.drag_settle(now)
        -- Expire a busy window whose completion never arrived, so a lost message cannot
        -- leave the engine stuck and refusing to re-dress the character.
        if is_Busy and now - E.Spellstart > E.SpellCastTime then
            is_Busy = false
            E.SpellCastTime = 0
            -- A cast whose completion was lost lets its implement go here too. This is a raw
            -- handler, so any equip the release sends is discarded. The claim and the slot's
            -- hold are still cleared, and the next build's sweep completes the dress.
            release_implement()
        end
        -- Movement detection, read from the 0x015 packet this handler already carries: X,
        -- Z and Y as three floats at offset 0x04. It sits above the 0.1 second gate below
        -- because any outgoing packet uses up that window, while only 0x015 reports a
        -- position. Under the gate, a position update would be lost whenever another packet
        -- went first. It keeps its own 0.1 second floor instead, the interval the half-yalm
        -- threshold below assumes.
        --
        -- It is skipped while mounted, busy, dead, charmed or asleep. In each case the
        -- position cannot change usefully, or gear must not move.
        if id == 0x15 and now - Location.t >= .1 and not is_Busy and player
            and player.status ~= "Dead" and player.status ~= "Engaged dead"
            and not buffactive['Charm'] and not buffactive['Sleep']
            and not buffactive['Mounted'] then
            local px, pz, py = data:unpack('fff', 5)
            if px then
                Location.t = now
                -- Squared distance against a squared threshold, which avoids a square root
                -- on a path that runs up to ten times a second.
                local dx = px - Location.x
                local dz = pz - Location.z
                local dy = py - Location.y
                local movement = (dx * dx + dz * dz + dy * dy) > 0.25 -- 0.5 yalms, squared
                -- The flag is raised only while disengaged, but lowered whenever motion
                -- stops. So engaging partway through a run leaves it raised until the
                -- character halts.
                if movement and not E.is_moving then
                    if player.status ~= "Engaged" then
                        E.is_moving = true
                        Require_Update = true
                    end
                elseif not movement and E.is_moving then
                    E.is_moving = false
                    Require_Update = true
                end
                Location.x = px
                Location.z = pz
                Location.y = py
            end
        end
        -- The 0.1 second gate. main_engine_time is stamped at the end of a full pass and
        -- just before the early return below, so the throttle holds on both paths.
        if now - main_engine_time < .1 then return end
        if settings.debug then debug_box_update() end
        -- Local copies for the tests below, so each global is read once.
        local active_buffs = buffactive
        local player_status = player and player.status
        -- Nothing past this point may act on a character who cannot act. The clock is
        -- stamped here as well. While the character is dead, charmed or asleep, the debug
        -- box above still updates ten times a second rather than on every outgoing packet,
        -- and the first full pass after recovery waits out the rest of the window. The
        -- housekeeping clocks below stamp their own when they fire.
        if not player or player_status == "Dead" or player_status == "Engaged dead" or active_buffs['Charm'] or active_buffs['Sleep'] then
            main_engine_time = now
            return
        end

        -- The deferred rebuild, held off while busy so it cannot overwrite gear an action is
        -- still using. A raw handler cannot equip, so the rebuild is requested as a self
        -- command.
        if Require_Update and not is_Busy then
            equip_set_command()
            Require_Update = false
        end

        -- Housekeeping, every 30 seconds: re-read the dual wield trait, and expire tagged
        -- mobs the player has not touched in three minutes.
        if now - UpdateTime1 > 30 then
            dual_wield_check()
            cleanup_tagged_mobs()
            UpdateTime1 = now
        end

        -- The job file's own periodic hook, every 2 seconds, and only when the job file
        -- defines one. Skipped while busy so it cannot fight an action for the gear slots.
        if Cycle_Timer and now - UpdateTime2 > 2 and not is_Busy then
            Cycle_Timer()
            UpdateTime2 = now
        end

        main_engine_time = now
    end

    -- The version stamp. The root checks it against Rahvin_GS, so a stale copy of this file
    -- stops the load with an error that names it.
    return '2.1'
end
