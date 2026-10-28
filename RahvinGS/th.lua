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
--   Section 18 - Treasure Hunter tracking. The target change, incoming packet and zone
--   change handlers and a timed sweep decide whether a mob still needs Treasure Hunter
--   gear. The packet handler also passes the pet's status packets on. The action handler
--   stamps tags, ends an item use or an interrupted cast, feeds the burst windows, the
--   eleven tracker, the blue affinities and Immanence, ends a pet's move, and starts and
--   ends buff predictions.
--
-- EXPORTS  E.th_action, which the root registers on the raw 'action' event.
-- GLOBALS  on_target_change_for_th, on_incoming_chunk_for_th and on_zone_change_for_th,
--          which the root registers on their events, and cleanup_tagged_mobs, which the
--          polling engine calls on its 30 second pass.
-- STATE    The tagged-mob table is th_info.tagged_mobs. The state component owns th_info,
--          this file writes it, and the gear builders read it. Both files bind the th_info
--          reference once at construction, so th_info is changed in place and never
--          replaced. A replaced th_info would leave the builders reading the old one. The
--          zone handler also empties E.burst_records, the monitor component's chain records.
--          The action and zone handlers mark E.pet_move, the record of a pet's move in
--          flight, as ended.
-- LOADS    After every component whose exports it binds. run_burst, note_blue_affinity and
--          note_immanence from the monitor component, display_box_update from the display
--          component and equip_set_command from the root are globals from files that load
--          after this one. They resolve when called, so none of them may be bound in the
--          import block.
--
-- The zone handler does more than its name suggests, and its steps run in a required
-- order. Read the note above it before moving anything inside it.

-- requires: rahvings/state, rahvings/core, rahvings/equip, rahvings/enchant, rahvings/hoxne, rahvings/builders, rahvings/hooks, rahvings/spellreceived
return function(E)
    -- The exports this file uses, bound once at construction.
    local DeathMessages, TaggingCategories, get_mob_by_id = E.DeathMessages, E.TaggingCategories, E.get_mob_by_id
    local build_current_set, cancel_enchantment           = E.build_current_set, E.cancel_enchantment
    local clear_locked_slots, debug, hoxne                = E.clear_locked_slots, E.debug, E.hoxne
    local close_window_at_zone                            = E.close_window_at_zone
    local hoxne_resume_deadline, settings, th_info        = E.hoxne_resume_deadline, E.settings, E.th_info
    local strip_clear, disable_clear                      = E.strip_clear, E.disable_clear
    local Divergence_Zones, res                           = E.Divergence_Zones, E.res
    local roll_action, roll_clear                         = E.roll_action, E.roll_clear
    local pet_move_holds, merge_into                      = E.pet_move_holds, E.merge_into
    local rebuild_waits                                   = E.rebuild_waits
    local pet_tp_packet                                   = E.pet_tp_packet
    local buff_prediction, predict_from_action            = E.buff_prediction, E.predict_from_action
    local end_ending_buff_predictions                     = E.end_ending_buff_predictions
    local end_all_buff_predictions                        = E.end_all_buff_predictions

    ------------------------------------------------------------------------------------------------
    -- SECTION 18 - TREASURE HUNTER TRACKING
    ------------------------------------------------------------------------------------------------
    -- A mob needs Treasure Hunter gear until it has been tagged. Every mob the player acts on
    -- is stamped in th_info.tagged_mobs. The entry is dropped when the mob dies, when the
    -- player zones, or after three minutes with no action on it. The builders read the table
    -- to decide when Treasure Hunter gear gives its slots back.

    -- Rebuild the equipped set when the player picks a different target while engaged with a
    -- Treasure Hunter mode on, so a newly targeted mob gets Treasure Hunter gear. Runs on the
    -- wrapped 'target change' event.
    function on_target_change_for_th(new_index, old_index)
        -- A real target change needs the player's current target to be the mob the event
        -- names, and to differ from the last target this handler rebuilt for, so picking the
        -- same mob again rebuilds nothing. The event fires when the player retargets by hand
        -- and when the client moves on from a target that died, and both want the rebuild.
        if player.status == 'Engaged' and state.TreasureMode.value ~= 'None' then
            if player.target.index == new_index and new_index ~= th_info.last_player_target_index then
                th_info.last_player_target_index = player.target.index
                -- While a held pet's move is in flight the rebuild waits, and the move's end
                -- rebuilds instead. A hold gone stale ends here, and the layer it kept goes on
                -- with this rebuild. A cast in flight makes the rebuild wait too, and the
                -- cast's aftercast dresses for the target recorded above.
                local move = E.pet_move
                if not (move and pet_move_holds(true)) and not rebuild_waits() then
                    local built_set = build_current_set()
                    if move and move.held and move.layer then merge_into(built_set, move.layer) end
                    equip(built_set)
                end
            end
        end
    end

    -- Drop a mob from the tagged table when an action message reports its death, so a mob
    -- that respawns on the same spot is tagged again. Runs on the raw 'incoming chunk' event,
    -- where packet 0x29 is the action message. The pet status packets, 0x067 and 0x068, go
    -- to the builders' reader of the automaton's TP, which sets.Pet_WS follows.
    function on_incoming_chunk_for_th(id, data, modified, injected, blocked)
        if id == 0x067 or id == 0x068 then
            pet_tp_packet(id, data)
        elseif id == 0x29 and state.TreasureMode.value ~= 'None' then
            local target_id = data:unpack('I', 0x09)
            -- Every action message reaches this handler and few name a tagged mob, so the
            -- table lookup comes first and the message id is read only on a hit. The target
            -- id is the 4-byte value at 0x09, and the message id is the low fifteen bits of
            -- the 2-byte value at 0x19. unpack counts positions from 1, so each is one past
            -- the field's offset in the packet. The mask clears the top bit. Without it, a
            -- packet carrying that bit matches no death message, and the mob stays tagged
            -- until the three-minute sweep drops it.
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

    -- Release everything that does not survive a zone, then clear the tagged table. Runs on
    -- the raw 'zone change' event.
    --
    -- The order matters. Every hold below is released before UnlockByMode runs, because
    -- UnlockByMode enables only the slots nothing claims and would skip a slot still held.
    -- An equip issued inside a raw handler is discarded, so the Ampulla cannot be taken off
    -- from here. Instead the Hoxne mode is switched off and the release tick is armed, and
    -- the tick removes the item through the hoxnerelease self command.
    --
    -- The disable hold and then the strip hold, highest first, are cleared before anything
    -- else. Each outranks every layer below it, so a lower layer released first would meet
    -- the hold's claim and shut the slot again. Neither clear issues an equip, which makes
    -- them safe in a raw handler.
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
        -- An item use does not survive the zone. Its /item never lands, and its slot would
        -- stay claimed in the new zone. The cancel is quiet, so this handler's own repaint
        -- at the end is the only one it makes.
        local zoned_use = cancel_enchantment(true)
        if zoned_use then notice('Canceled [' .. zoned_use .. '] (zoned).') end
        -- Lock modes do not survive a zone either.
        if clear_locked_slots() > 0 then notice('Lock modes released (zoned).') end
        -- Nor does a cast in progress, since GearSwap empties its record of actions at the zone.
        -- Its busy window closes and its implement lets go before the routine unlock, so the
        -- rebuild below does not wait for it.
        close_window_at_zone()
        UnlockByMode()
        -- Nor does a Corsair roll, since every roll leaves a character that zones. The
        -- eleven tracker is cleared above the rebuild below, so the eleven flag is settled
        -- before that rebuild is queued. When the flag changes, its setter queues a rebuild
        -- of its own, which also lands after every release above.
        roll_clear()
        -- Nor does a buff's prediction. Each ends before the rebuild below, so that rebuild
        -- dresses the buffs the new zone's list holds.
        if buff_prediction.n > 0 then end_all_buff_predictions() end
        -- Nor does a pet's move in flight. Its hold ends before the rebuild below, which
        -- would otherwise wait on it, and that rebuild closes the record with the layer a
        -- held status or buff change kept on it.
        local move = E.pet_move
        if move then move.ended, move.held = true, false end

        -- Dress for the new zone once every mode above has let its slots go. Freeing a slot
        -- only lifts its disable flag, and whatever the mode held stays worn until something
        -- rebuilds. The rebuild comes after every release, so it never dresses a slot that
        -- is about to be released. It runs on every zone, because UnlockByMode frees slots
        -- whether or not a hold was standing. It is a send rather than an equip, so the
        -- rebuild lands in a wrapped command.
        equip_set_command()

        -- On entering a Dynamis Divergence zone, point the player at the neck lock. The zone
        -- comes from the event's id, because world.area inside a raw handler may still name
        -- the zone just left. It prints on notice, so it reaches a player with info off.
        local zone = res.zones[new_zone]
        if zone and Divergence_Zones:contains(zone.en) then
            notice('Entering Dynamis Divergence - Use "gs c dynamisrp" to equip and lock your JSE neck.')
        end

        if settings.debug then debug('Zoning. Clearing tagged mobs table.') end
        th_info.tagged_mobs:clear()
        -- A skillchain's burst window ends with the zone too, so every record goes.
        local records = E.burst_records
        for id in pairs(records) do records[id] = nil end

        -- Repaint the status box once, after every hold above has let go, so its hold
        -- tokens leave with them.
        display_box_update()
    end

    -- Drop every mob the player has not acted on for three minutes. This covers the cases
    -- no event reports: a mob that deaggros, and one left behind when the player dies. Only
    -- the player's own actions refresh an entry, so an untouched mob always ages out.
    -- Called from the polling engine's 30 second pass.
    function cleanup_tagged_mobs()
        local current_time = os.clock()

        -- Assigning nil to an existing key during a pairs() walk is defined in Lua 5.1, so a
        -- stale entry is removed where it is found.
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


    -- The action handler, which the root registers on the raw 'action' event. Its jobs run in
    -- the order below, and each says whose actions it reads.
    --
    --   1. Completion routing, the player's own. An item use that finishes or is interrupted
    --      gives back the slot the enchanted item engine held. An interrupted cast pulls in
    --      the Hoxne window's deadline and queues a rebuild.
    --   2. Treasure Hunter tagging, the player's own. An action against a mob stamps it in
    --      the tagged table.
    --   3. Skillchain bursts, every actor's, so a chain made by someone else still opens a
    --      burst window.
    --   4. The eleven tracker, the blue affinities and Immanence, every actor's. Each job
    --      ability packet goes to all of them. A Corsair roll that lists this character
    --      carries its total there, another Blue Mage's Chain Affinity or Azure Lore lets that
    --      Blue Mage's physical spells end a burst window, and another Scholar's Immanence
    --      lets her next spell Immanence carries end one.
    --   5. A pet's move in flight, the pet's own. The move ends at the pet's finish packet for
    --      it, or at its next swing, and the rebuild the held events waited for is queued.
    --   6. The buff prediction, through core.lua. Another player's spell or ability that gives
    --      this character a buff starts one, and so does the player's own job ability. The
    --      player's own result ends those its aftercast marked, after every read above.
    E.th_action = function(data)
        if data ~= nil then
            if data.actor_id == player.id then
                -- Category 2: ranged attack finished.
                if data.category == 2 then
                    if data.param == 26739 then
                        log('Player finished Shooting')
                    end
                -- Category 4: cast finished.
                elseif data.category == 4 then
                    log('Casting Finished')
                -- Category 9: item use started, param 24931, or interrupted, param 28787.
                -- Categories 8 and 12 use the same two params. An interrupted use has to give
                -- the slot back here, since no completion will arrive.
                elseif data.category == 9 then
                    if data.param == 24931 then
                        log('Item use')
                    elseif data.param == 28787 then
                        log('Item Use Interupted')
                        enchantment_completed()
                        UnlockByMode()
                        equip_set_command()
                    end
                -- Category 5: item use finished. Not gated on param, because on completion the
                -- field carries the item id, and any single value would match one item only.
                elseif data.category == 5 then
                    log('Item Use Finished')
                    enchantment_completed()
                    UnlockByMode()
                    equip_set_command()
                -- Category 8: cast started, or interrupted.
                elseif data.category == 8 then
                    if data.param == 28787 then
                        log('Spell Interupt')
                        -- The Hoxne window gets its countdown here by the rule aftercast
                        -- applies, keyed on the action that opened the window rather than
                        -- the one interrupted. The deadline is only ever pulled in, so an
                        -- unrelated cast interrupted inside a song's five seconds leaves
                        -- the window where it was.
                        if hoxne.window then
                            local deadline = hoxne_resume_deadline(hoxne.owner)
                            if deadline < hoxne.expires then hoxne.expires = deadline end
                        end
                        equip_set_command()
                    elseif data.param == 24931 then
                        log('Casting Spell')
                    end
                -- Category 12: ranged attack started, or interrupted.
                elseif data.category == 12 then
                    if data.param == 24931 then
                        log(player.name, ' is Shooting')
                    elseif data.param == 28787 then
                        log('Shooting is interrupted')
                    end
                end
                -- Treasure Hunter tagging. A tagging-category action against an NPC stamps it
                -- with the current clock, which also keeps a mob still being fought from
                -- aging out. Outside Full Time, a tag on a mob the table did not hold queues a
                -- rebuild, so the build can drop Treasure Hunter gear once the mob is tagged. A
                -- mob already in the table is only restamped, because the build already reads
                -- it as tagged. A target the mob lookup cannot find, or one that is not an NPC,
                -- only has its stamp refreshed, and only when it is already in the table.
                if state.TreasureMode.value ~= 'None' and TaggingCategories:contains(data.category) then
                    local target = data.targets[1]
                    local target_mob = target and get_mob_by_id(target.id)
                    if target_mob and target_mob.is_npc then
                        local first_tag = not th_info.tagged_mobs[target.id]
                        th_info.tagged_mobs[target.id] = os.clock()
                        if first_tag and state.TreasureMode.value ~= 'Full Time' then
                            equip_set_command()
                        end
                    elseif target and th_info.tagged_mobs[target.id] then
                        th_info.tagged_mobs[target.id] = os.clock()
                    end
                end
            end
            -- Outside the actor test, so every actor counts: a chain, a roll, an affinity, a
            -- buff or a pet's move can come from someone else. Most actions are none of
            -- these, so the category is read once.
            --
            -- Categories 3, 4, 11 and 13 are a weaponskill, a spell, an NPC's or a pet's TP
            -- move, and an avatar's blood pact. Any of them, from anyone, can make a
            -- skillchain the player may burst on, and run_burst records the chain on its
            -- monster. A later weaponskill, TP move or blood pact with a skillchain property
            -- that lands on that monster closes the window. So does a physical blue spell
            -- under Chain Affinity or Azure Lore, or a Scholar's elemental spell under
            -- Immanence, when it hits. Category 11 also carries every monster's TP move. Most
            -- make no chain, and on a monster with no window they change nothing.
            local category = data.category
            if category == 3 then
                -- A param of 0 names no weaponskill, so the packet is not handed on.
                if data.param ~= 0 then run_burst(data) end
            elseif category == 4 or category == 11 or category == 13 then
                run_burst(data)
                -- The finish packet of the pet whose move is recorded ends the move, whether or
                -- not GearSwap calls pet_aftercast for it. A refusal of the master's command can
                -- take the move's entry, and GearSwap's registry can drop a move before it
                -- finishes. The rebuild this asks for closes the record. During a cast of the
                -- master's in flight that rebuild waits, and the cast's aftercast closes the
                -- record instead. A move still awaiting its readying is not the one finishing.
                local move = E.pet_move
                if move and not move.ended and not move.awaiting and data.actor_id == move.actor then
                    move.ended, move.held = true, false
                    equip_set_command()
                end
                -- Another player's spell may give this character a buff GearSwap does not list
                -- yet. This character's own spells predict nothing.
                if category == 4 and data.actor_id ~= player.id then predict_from_action(data) end
            elseif category == 6 then
                -- A job ability goes to the eleven tracker, because a roll's total travels on
                -- the roller's packet, to the notes of another Blue Mage's Chain Affinity or
                -- Azure Lore and another Scholar's Immanence, and to the buff prediction.
                roll_action(data)
                note_blue_affinity(data)
                note_immanence(data)
                predict_from_action(data)
            elseif category == 1 then
                -- A melee swing by the pet whose move is recorded ends the move. A raw handler
                -- cannot equip, so the move is marked ended for the rebuild it asks for, which
                -- closes the record, or waits for a cast of the master's in flight, as above. A
                -- swing before the readying of a move the hold still awaits comes before that
                -- move, so the hold stands.
                local move = E.pet_move
                if move and not move.ended and not move.awaiting and data.actor_id == move.actor then
                    move.ended, move.held = true, false
                    equip_set_command()
                end
            elseif category == 14 or category == 15 then
                -- A Dancer's or a Rune Fencer's ability, which can give this character a buff.
                predict_from_action(data)
            end
            -- The player's own result ends the predictions its aftercast marked, after every
            -- read above has seen them.
            if buff_prediction.n > 0 and data.actor_id == player.id then end_ending_buff_predictions() end
        end
    end

    -- The version stamp. The root checks it against Rahvin_GS, so a stale copy of this file
    -- stops the load with an error that names it.
    return '2.2'
end
