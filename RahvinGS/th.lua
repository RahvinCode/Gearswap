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
-- COMPONENT: th -- section 18: Treasure Hunter tracking, and the action handler
----------------------------------------------------------------------------------------------------
-- CONTENTS
--   Section 18 - Treasure Hunter tracking. Four handler bodies and one housekeeping sweep
--   that together decide whether a mob still needs Treasure Hunter gear, plus the action
--   handler that both records a tagging and dispatches skillchain bursts.
--
-- EXPORTS  E.th_action, the body registered on the raw 'action' event.
-- GLOBALS  on_target_change_for_th, on_incoming_chunk_for_th, on_zone_change_for_th and
--          cleanup_tagged_mobs are declared as globals: the composition root registers the
--          first three on their events, and the polling engine calls the fourth on its
--          30 second pass.
-- STATE    The tagged-mob table is th_info, owned by the state component and shared: this
--          file writes it, the gear builders read it. The table REFERENCE is bound to a
--          local below and captured as an upvalue by every closure here, which is safe
--          because the reference never changes -- only its contents do. Never replace the
--          table itself, or the builders keep reading the old one.
-- LATE     This file loads tenth of fifteen, and three of the globals it calls are declared
--          in files that load AFTER it: run_burst (monitor), display_box_update (display)
--          and equip_set_command (the root). They work only because Lua resolves a global at
--          call time; none of them may be bound to a local in the import block above, and a
--          reader looking for them will not find them earlier in the load order.
--
-- The zone handler is larger than its name suggests and its ordering is load-bearing; see
-- the note on it below before moving anything inside it.

-- requires: rahvings/state, rahvings/core, rahvings/equip, rahvings/enchant, rahvings/hoxne, rahvings/builders
return function(E)
    -- Immutable dependencies bound once at construction, so no call below reaches through E.
    local DeathMessages, TaggingCategories, get_mob_by_id = E.DeathMessages, E.TaggingCategories, E.get_mob_by_id
    local build_current_set, cancel_enchantment           = E.build_current_set, E.cancel_enchantment
    local clear_locked_slots, debug, hoxne                = E.clear_locked_slots, E.debug, E.hoxne
    local release_implement                               = E.release_implement
    local hoxne_resume_deadline, settings, th_info        = E.hoxne_resume_deadline, E.settings, E.th_info
    local strip_clear, disable_clear                      = E.strip_clear, E.disable_clear
    local Divergence_Zones, res                           = E.Divergence_Zones, E.res

    ------------------------------------------------------------------------------------------------
    -- SECTION 18 - TREASURE HUNTER TRACKING
    ------------------------------------------------------------------------------------------------
    -- A mob is worth Treasure Hunter gear until it has been tagged once. Every mob the player
    -- acts on is stamped in th_info.tagged_mobs, and the entry is dropped when the mob dies,
    -- when the player zones, or after three minutes without further action on it. The Tag
    -- mode reads that table to decide when to give the slots back to damage gear.

    -- Rebuild the equipped set when the player picks a different target while engaged, so a
    -- newly-targeted mob gets Treasure Hunter gear. Runs on the wrapped 'target change' event.
    function on_target_change_for_th(new_index, old_index)
        -- Two things have to be true before this is a real target change: the player must be
        -- engaged with the mob the event names, and it must differ from the one last acted on.
        -- The second test is what stops a re-target to the same mob rebuilding the set. The
        -- event fires both when the player retargets by hand and when the current target
        -- dies and the client moves them on, and both paths want the same rebuild.
        if player.status == 'Engaged' and state.TreasureMode.value ~= 'None' then
            if player.target.index == new_index and new_index ~= th_info.last_player_target_index then
                th_info.last_player_target_index = player.target.index
                equip(build_current_set())
            end
        end
    end

    -- Drop a mob from the tagged table when an action packet reports its death, so a mob that
    -- respawns on the same spot is tagged again. Runs on the raw 'incoming chunk' event.
    function on_incoming_chunk_for_th(id, data, modified, injected, blocked)
        if id == 0x29 and state.TreasureMode.value ~= 'None' then
            local target_id = data:unpack('I', 0x09)
            -- The tagged-table lookup comes first and the message id is read inside it: every
            -- action packet reaches this handler, and few of them name a mob being held. The
            -- target id is the long at 0x09. The message id is the low fifteen bits of the
            -- halfword at 0x19, and the mask is what clears the top bit -- drop it and a
            -- packet carrying that bit matches no death message, leaving the mob in the table
            -- until the 180 second sweep takes it.
            if th_info.tagged_mobs[target_id] then
                local message_id = data:unpack('H', 0x19) % 32768
                if DeathMessages[message_id] then
                    if settings.debug then
                        debug('Mob ' .. target_id .. ' died. Removing from tagged mobs table.')
                    end
                    th_info.tagged_mobs[target_id] = nil
                end
            end
        end
    end

    -- Release everything a zone invalidates, then clear the tagged table. Runs on the raw
    -- 'zone change' event.
    --
    -- The order is load-bearing. Each of the holds below has to be released BEFORE
    -- UnlockByMode runs, because UnlockByMode builds its list from the slots nothing claims
    -- and would skip any slot still held. The Ampulla itself cannot be unequipped from here --
    -- equips issued inside a raw handler are discarded -- so the mode is switched off and the
    -- release tick is armed to take the item out through a wrapped command instead.
    --
    -- The two holds go first of all and highest first -- the disable hold, then the strip:
    -- each outranks every layer beneath it, so a release below one would meet its claim and
    -- re-assert the very slot it was freeing. Neither issues an equip, which is what makes
    -- them safe here.
    function on_zone_change_for_th(new_zone, old_zone)
        local disable_n, disable_label = disable_clear()
        if disable_n > 0 then notice(disable_label .. ': [OFF] (zoned)') end
        local stripped_n, strip_label = strip_clear()
        if stripped_n > 0 then notice(strip_label .. ': [OFF] (zoned)') end
        if state.Hoxne.value ~= 'OFF' then
            state.Hoxne:set('OFF')
            hoxne.window        = false
            hoxne.release_tries = 10
            hoxne.release_next  = os.clock() + 3
            notice('Hoxne Ampulla Mode: [OFF] (zoned)')
        end
        -- An item use cannot survive the zone: the /item never lands, and the slot it is
        -- holding would ride into the new zone still claimed.
        local zoned_use = cancel_enchantment()
        if zoned_use then notice('Canceled [' .. zoned_use .. '] (zoned).') end
        -- Lock modes do not survive a zone either.
        if clear_locked_slots() > 0 then notice('Lock modes released (zoned).') end
        -- Nor does a cast in progress: its implement lets go before the routine unlock.
        release_implement()
        UnlockByMode()

        -- Dress for the new zone, once every mode above has let its slots go. Freeing a
        -- slot only lifts its disable flag: whatever the mode was holding stays worn until
        -- something rebuilds, so without this the gear rides into the new zone. Last on
        -- purpose -- rebuilt any earlier it would dress slots that are about to be released
        -- again. Unconditional, because UnlockByMode frees slots on every zone whether or
        -- not a lock was held. This is a send rather than an equip: equips issued inside a
        -- raw handler are discarded, and the send lands the rebuild in a wrapped command.
        equip_set_command()

        -- Entering Divergence, name the neck lock. The zone is read from the EVENT's id
        -- rather than from world.area, which inside a raw handler may still name the zone
        -- just left. Ungated, so it reaches a player running with gs c info off.
        local zone = res.zones[new_zone]
        if zone and Divergence_Zones:contains(zone.en) then
            notice('Entering Dynamis Divergence - Use "gs c dynamisrp" to equip and lock your JSE neck.')
        end

        if settings.debug then debug('Zoning. Clearing tagged mobs table.') end
        th_info.tagged_mobs:clear()

        -- The status box is repainted last, once, after every hold has let go and the zone
        -- has been dressed: the tokens leave with the holds, and nothing above this line
        -- waits on the compose.
        display_box_update()
    end

    -- Drop every mob the player has not acted on for three minutes. This is what covers the
    -- cases no event reports: a mob that deaggros, and one left behind when the player dies.
    -- Only the player's own actions refresh an entry, so an untouched mob always ages out.
    -- Called from the polling engine's 30 second pass.
    function cleanup_tagged_mobs()
        local current_time = os.clock()

        -- Assigning nil to a key that already exists is defined behavior during a pairs()
        -- walk in Lua 5.1, so a stale entry is removed where it is found rather than
        -- collected into a second table and deleted afterwards.
        for target_id, action_time in pairs(th_info.tagged_mobs) do
            if current_time - action_time > 180 then
                th_info.tagged_mobs[target_id] = nil
                if settings.debug then
                    debug('Over 3 minutes since last action on mob ' ..
                        target_id .. '. Removing from tagged mobs list.')
                end
            end
        end
    end


    -- The action handler, registered by the root on the raw 'action' event. It does three
    -- jobs, and only the first two are gated on the actor being the player:
    --
    --   1. Completion routing. An item use that finishes or is interrupted, and a song
    --      interrupted mid-cast, each release state that aftercast would otherwise have
    --      released -- an interrupted cast never reaches aftercast at all.
    --   2. Treasure Hunter tagging. An action against a mob stamps it in the tagged table.
    --   3. Skillchain bursts, for EVERY actor, so a chain closed by someone else still opens
    --      a burst window.
    E.th_action = function(data)
        if data ~= nil then
            if data.actor_id == player.id then
                -- Ranged attack finished.
                if data.category == 2 then
                    if data.param == 26739 then
                        log('Player finished Shooting')
                    end
                -- Cast finished.
                elseif data.category == 4 then
                    log('Casting Finished')
                -- Item use started, or was interrupted before it landed. An interrupt has to
                -- hand the slot back itself, since no completion will arrive.
                elseif data.category == 9 then
                    if data.param == 24931 then
                        log('Item use')
                    elseif data.param == 28787 then
                        log('Item Use Interupted')
                        enchantment_completed()
                        UnlockByMode()
                        equip_set_command()
                    end
                -- Item use finished. Deliberately not gated on param: on completion the field
                -- carries the item id, so testing any single value would match one item only.
                elseif data.category == 5 then
                    log('Item Use Finished')
                    enchantment_completed()
                    UnlockByMode()
                    equip_set_command()
                -- Cast started, or was interrupted.
                elseif data.category == 8 then
                    if data.param == 28787 then
                        log('Spell Interupt')
                        -- An interrupted cast never reaches aftercast, so the Hoxne borrow
                        -- window gets its real countdown here, from the rule aftercast
                        -- applies, keyed on what opened the window rather than on what was
                        -- interrupted. The deadline is only ever pulled in: an unrelated
                        -- cast interrupted inside a song's debounce leaves the wave's
                        -- window where it was.
                        if hoxne.window then
                            local deadline = hoxne_resume_deadline(hoxne.owner)
                            if deadline < hoxne.expires then hoxne.expires = deadline end
                        end
                        equip_set_command()
                    elseif data.param == 24931 then
                        log('Casting Spell')
                    end
                -- Ranged attack started, or was interrupted.
                elseif data.category == 12 then
                    if data.param == 24931 then
                        log(player.name, ' is Shooting')
                    elseif data.param == 28787 then
                        log('Shooting is interrupted')
                    end
                end
                -- Treasure Hunter tagging. A tagging-category action against a mob stamps it
                -- with the current clock. An action against something already tagged only
                -- refreshes the stamp, which is what keeps a mob still being fought from
                -- aging out of the table. Outside Full Time the set is rebuilt on the tag,
                -- because that is the moment Treasure Hunter gear stops earning its slots.
                if state.TreasureMode.value ~= 'None' and TaggingCategories:contains(data.category) then
                    local target = data.targets[1]
                    local target_mob = target and get_mob_by_id(target.id)
                    if target_mob and target_mob.is_npc then
                        th_info.tagged_mobs[target.id] = os.clock()
                        if state.TreasureMode.value ~= 'Full Time' then
                            equip_set_command()
                        end
                    elseif target and th_info.tagged_mobs[target.id] then
                        th_info.tagged_mobs[target.id] = os.clock()
                    end
                end
            end
            -- Burst dispatch, outside the actor test: a weaponskill or cast from anyone can
            -- close a skillchain the player is able to burst on.
            if data.category == 3 and data.param ~= 0 then
                run_burst(data)
            elseif data.category == 4 then
                run_burst(data)
            end
        end
    end

    -- Version stamp. The root asserts this against Rahvin_GS, so a stale copy of this file
    -- announces itself at load instead of running.
    return '2.0'
end
