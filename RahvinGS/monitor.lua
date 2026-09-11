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
-- EXPORTS  Nothing new onto E. It WRITES seven fields the state component declares:
--          is_moving (read by builders, display, enchant, hoxne), DualWield and TwoHand
--          (builders, display), the three last_skillchain_* fields (builders), and
--          SpellCastTime, which it zeroes when a busy window expires.
-- CALLERS  run_burst <- th.lua, two_hand_check and escha_temps <- commands.lua, and
--          cancel <- spellreceived.lua. dual_wield_check and two_hand_check are also handed
--          to coroutine.schedule by the root and by the lifecycle component rather than
--          called, so a search for "dual_wield_check(" will not find those two uses.
-- LOADS    Eleventh of fifteen. Two globals it calls resolve LATE -- debug_box_update
--          (display, twelfth) and equip_set_command (the root, fifteenth) -- so neither may
--          be bound to a local in the import block above. Both work only because Lua
--          resolves a global at call time, and both are called from inside main_engine,
--          which never runs before the load completes.
--
-- Two files that load BEFORE this one call into it -- th.lua takes run_burst, and
-- spellreceived.lua takes cancel -- which is the mirror of the same late-resolution
-- arrangement seen from the other side.

-- requires: rahvings/state, rahvings/core, rahvings/equip
return function(E)
    -- Immutable dependencies bound once at construction, so no call below repeats the lookup
    -- for them. The cross-component mutables are never bound here: the state fields this file
    -- writes, and Spellstart, are reached through E at every touch, because a file-local copy
    -- would not be the one the other components read and write.
    local Cities, Language, skillchains = E.Cities, E.Language, E.skillchains
    local get_mob_by_id, res, settings  = E.get_mob_by_id, E.res, E.settings
    local release_implement             = E.release_implement

    -- main_engine's three independent clocks: the 30 second housekeeping pass, the 2 second
    -- job-file Cycle_Timer, and the 0.1 second floor on the engine body itself. Each is
    -- stamped separately so a slow pass cannot make the others drift.
    local UpdateTime1                         = os.clock()
    local UpdateTime2                         = os.clock()
    local main_engine_time                    = os.clock()

    -- The last position read from an outgoing 0x015, and the clock it was read at. Field
    -- order is the packet's own -- X, then Z, then Y -- not the order a reader expects.
    local Location                            = { x = 0, z = 0, y = 0, t = 0 }

    -- Raised when something has changed that the equipped set should reflect; main_engine
    -- consumes it on its next pass and lowers it. Deferring the rebuild this way means
    -- several changes in one tick cost one rebuild rather than several.
    local Require_Update                      = false
    ------------------------------------------------------------------------------------------------
    -- SECTION 19 - AUTOMATION AND COMBAT MONITORING
    ------------------------------------------------------------------------------------------------
    -- Everything driven by time or by packets rather than by a player action: the polling
    -- engine and its movement detection, the two weapon-trait checks, skillchain tracking,
    -- buff cancellation, and the Escha drink macro.

    -- Drink the six Escha temporary items in sequence. One chained command, because each
    -- use has to wait out the one before it.
    function escha_temps()
        info('Escha Temps')
        windower.send_command(
            "input /item \"Monarch's Drink\" <me>;wait 2.5;input /item \"Braver's Drink\" <me>;wait 2.5;input /item \"Fighter's Drink\" <me>;wait 2.5;input /item \"Champion's Drink\" <me>;wait 2.5;input /item \"Soldier's Drink\" <me>;wait 2.5;input /item \"Barbarian's Drink\" <me>")
    end

    -- Record a skillchain so a following nuke can be timed to burst on it, or clear the
    -- record when a weaponskill closes the window. Called from the action handler in th.lua
    -- for EVERY actor, not just the player, so a chain closed by anyone opens the window.
    -- The elements and the time are stored here; the gear builders decide whether a given
    -- cast falls inside the window and matches an element.
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
            -- else, or too far away, is recorded as nothing.
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

    -- Re-read whether the character currently has the Dual Wield trait (job trait 18), which
    -- decides whether the builders may put anything in the offhand. Scheduled after load and
    -- after a subjob change, and run again on every 30 second housekeeping pass.
    function dual_wield_check()
        local current_abilities = windower.ffxi.get_abilities()
        if table.contains(current_abilities.job_traits, 18) then
            E.DualWield = true
        else
            E.DualWield = false
        end
    end

    -- Whether a named weapon is two-handed. res.items:with scans the entire item database,
    -- and the answer for a given name never changes, so every name is resolved once per load
    -- and remembered -- misses included, or an unknown name would rescan on every check.
    local name_is_two_handed
    -- The skill table and the memo live inside a closed block so nothing else in the file can
    -- reach them; only the forward-declared name_is_two_handed escapes. Lua caps a function's
    -- locals at 200, and a constructor is one function; the import block binds only what this
    -- file uses.
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

    -- Re-read the two-handed flag from the weapon the current mode names, which suppresses
    -- the sub-slot swaps a two-hander cannot allow.
    --
    -- Two shapes of "no main" are handled differently. A mode with no main entry at all
    -- answers from the weapon actually worn: after a mode change that is the weapon
    -- inherited from the previous mode, so the answer is the one that was already right;
    -- at load it is whatever the character logged in holding. A mode whose main is a
    -- table carrying no name clears the flag instead.
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

    -- The main polling engine, registered by the root on the raw outgoing chunk event.
    --
    -- Two consequences of that choice, and both are constraints rather than details. It is
    -- driven by the client sending packets, so it does NOT tick reliably while the character
    -- stands still doing nothing -- anything that must run regardless belongs on prerender
    -- instead. And every outgoing chunk enters here, which is why the body is gated to 0.1
    -- seconds and why the movement block below sits ABOVE that gate.
    --
    -- The 0.1 second rate is a product requirement, not a tuning choice. Make a tick cheaper;
    -- do not make it rarer.
    function main_engine(id, data)
        local now = os.clock()
        -- Expire a busy window whose completion message never arrived, so a lost message
        -- cannot leave the engine wedged and refusing to re-dress the character.
        if is_Busy and now - E.Spellstart > E.SpellCastTime then
            is_Busy = false
            E.SpellCastTime = 0
            -- A cast whose completion was lost lets its implement go here too. From this
            -- raw handler the re-dress itself is discarded; the claim and the slot's hold
            -- are cleared, and the next build's sweep completes the dress.
            release_implement()
        end
        -- Movement detection, read from the 0x015 this handler already carries: X, Z and Y
        -- as three floats at packet offset 0x04. It sits above the 0.1 second gate below
        -- because ANY outgoing chunk consumes that window while only 0x015 reports a
        -- position -- gating it would drop position updates whenever the client happened to
        -- send something else first. It keeps its own 0.1 second floor instead, which is the
        -- interval the half-yalm threshold below is paired with.
        --
        -- Skipped while mounted, mid-action, dead, charmed or asleep: in each of those the
        -- position either cannot change usefully or must not move gear.
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
                -- Movement gear is only taken up while disengaged, but it is dropped whenever
                -- motion stops -- so engaging part-way through a run leaves the flag raised
                -- until the character halts.
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
        -- Hoisted out of the repeated reads below; both are resolved by GearSwap on access.
        local active_buffs = buffactive
        local player_status = player and player.status
        -- Nothing past this point should act on a character who cannot act. The clock is
        -- stamped here as well, so while the character is dead, charmed or asleep the debug
        -- box above still updates ten times a second rather than on every outgoing chunk,
        -- and the first full pass after recovery waits out whatever is left of the window.
        -- The housekeeping clocks below each stamp their own when they fire.
        if not player or player_status == "Dead" or player_status == "Engaged dead" or active_buffs['Charm'] or active_buffs['Sleep'] then
            main_engine_time = now
            return
        end

        -- The deferred rebuild. Held off while busy so it cannot overwrite gear an action
        -- is still using.
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

    -- Version stamp. The root asserts this against Rahvin_GS, so a stale copy of this file
    -- announces itself at load instead of running.
    return '2.0'
end
