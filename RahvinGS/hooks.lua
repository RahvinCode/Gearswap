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
-- COMPONENT: hooks -- section 16: the GearSwap action hooks
----------------------------------------------------------------------------------------------------
-- CONTENTS
--   Section 16 - The functions GearSwap calls as an action moves through it: pretarget,
--   precast, midcast and aftercast, buff_change and status_change, and the pet hooks.
--   Beside them is pretargetcheck, the validation pretarget runs first.
--
-- THE HOOKS ARE GLOBALS THAT NOTHING IN THE ENGINE CALLS. GearSwap looks these names up in
--          the job file's environment, so no other engine file calls one and the root
--          registers none of them. A search for callers finds none, and that is expected.
--          pretargetcheck is the exception, called by pretarget here in this file.
--
-- THE SHAPE REPEATS. Each hook asks the builders for the engine's set, merges whatever the
--          job file's matching _custom hook returns, then equips. Precast, midcast,
--          aftercast and pet_midcast also flush the merge report. Precast, midcast,
--          aftercast, buff_change, status_change and pet_change warn when their _custom
--          hook is missing, because a job file that meant to define one has no other way to
--          find out. pretarget_custom, pet_midcast_custom, pet_aftercast_custom and
--          pet_status_change_custom may be missing in silence.
--
-- FOUR THINGS ARE THREADED THROUGH THESE HOOKS, and none of them is local to one function.
--   * The BUSY WINDOW is armed in precast for every action but an item used on an NPC, and
--     restarted as a short tail in aftercast, or in pet_aftercast when GearSwap ends the
--     master's own pet command there. It follows GearSwap's own signals for a cast GearSwap
--     ends with no aftercast. precast closes it for an action canceled there, buff_change
--     for a cast GearSwap dropped at a disabling buff, and th.lua's zone handler at a zone
--     change, all in silence. For an end that never arrives it lasts as long as GearSwap
--     keeps the command, and precast and the polling engine both expire it then, with one
--     line naming the action, so a lost aftercast cannot leave the engine stuck. While the
--     cast proper is in flight, status and buff changes and the rebuilds the engine asks of
--     itself wait. The cast's aftercast makes the rebuild, or whichever path ends the cast
--     hands it on.
--   * The PET'S MOVE IN FLIGHT, E.pet_move, is recorded at the move's readying, in
--     pet_midcast. While the job file's PetMoveHold is on, a move that follows the master's
--     own pet command is held, and the hold starts earlier, at the command's completion.
--     Until it ends, pretarget and precast refuse the master's actions, and status_change,
--     buff_change, pet_status_change, the Treasure Hunter target change and the rebuilds the
--     engine asks of itself wait. The move's end makes the one rebuild they waited for.
--   * The HOXNE CRITICAL WINDOW opens in pretarget, opens or refreshes in precast, and gets
--     its real countdown in aftercast. A path that cancels before aftercast sets that
--     countdown itself.
--   * THE MULTIBOX DEBT. pretargetcheck announces a tracked cast to the other characters,
--     which then hold gear and slots for it. A path that cancels an announced cast must
--     call finish_outgoing_cast, or those characters wait out their failsafe in the
--     received gear. pretarget pays it when the job file cancels in pretarget_custom,
--     precast pays it at the busy gate and for an action canceled in precast, buff_change
--     pays it for a cast GearSwap dropped with no aftercast, the zone close for a cast the
--     zone ended, pet_aftercast for the master's own pet command GearSwap ends there, and
--     aftercast pays it when the cast completes.
--
-- EXPORTS  cast_proper_in_flight, a predicate over the cast-proper flag below and the busy
--          window, which the equip component's set_roll_eleven and the builders'
--          pet_tp_packet read from E at the call. dress_midcast, the midcast hook's body,
--          which the burst re-dress command in commands.lua runs for a cast already in
--          flight. pet_move_holds and rebuild_waits, which that file's rebuild, th.lua's
--          target change and spellreceived.lua's Doom and Sleep release ask before they
--          rebuild, and
--          take_waiting_rebuild, which the polling engine asks when it expires a busy window.
--          expire_window, which the polling engine expires a window through, and
--          close_window_at_zone, which th.lua's zone handler closes one through. The hooks
--          write these fields the state component declares: SpellCastTime and Spellstart,
--          which make the busy window, burst_pending, which aftercast clears, and pet_move.
-- PREDICTED BUFFS  Every hook writes core.lua's buff prediction into GearSwap's list as its
--          first act, since GearSwap rebuilds the list before most of them. aftercast starts a
--          prediction for a job ability this character aims at itself, when the number its
--          result carries names a buff of the ability. It also marks every standing
--          prediction to end once a spell, shot or weaponskill ends.
-- LOADS    After every component whose exports it binds. Some names it uses belong to files
--          that load later. equip_set_command, declared in the root, and display_box_update,
--          declared in the display component, are globals read at call time. aftercast and
--          buff_change read merge_move_layers, which commands.lua exports, from E at the call.

-- requires: rahvings/state, rahvings/core, rahvings/equip, rahvings/hoxne, rahvings/builders
return function(E)
    -- The exports these hooks use, bound once at construction. The builders, slot ownership,
    -- the Hoxne window and the multibox announce all meet here.
    local BUFF_SLEEP, BUFF_STUN, BUFF_KO, BUFF_PETRI, BUFF_CHARM, BUFF_TERROR =
        E.BUFF_SLEEP, E.BUFF_STUN, E.BUFF_KO, E.BUFF_PETRI, E.BUFF_CHARM, E.BUFF_TERROR
    local TYPE_JA, TYPE_WS, TYPE_MS, TYPE_SCH   = E.TYPE_JA, E.TYPE_WS, E.TYPE_MS, E.TYPE_SCH
    local HasRecastTimer, RecastTimers          = E.HasRecastTimer, E.RecastTimers
    local ability_info, spell_info, res, settings = E.ability_info, E.spell_info, E.res, E.settings
    local announce_tracked_cast, debug, get_time  = E.announce_tracked_cast, E.debug, E.get_time
    local lost_end_seconds                        = E.lost_end_seconds
    local apply_weapon_mode, build_current_set    = E.apply_weapon_mode, E.build_current_set
    local reassert_pair                           = E.reassert_pair
    local assert_over_lock, lock_exempts          = E.assert_over_lock, E.lock_exempts
    local keep_weaponskill_weapons                = E.keep_weaponskill_weapons
    local yield_range_to_ammo                     = E.yield_range_to_ammo
    local yield_ammo_to_instrument                = E.yield_ammo_to_instrument
    local report_refused, wears_yagrush           = E.report_refused, E.wears_yagrush
    local hold_implement, release_implement       = E.hold_implement, E.release_implement
    local critical_force_slot, hoxne_locked_refusal, hoxne = E.critical_force_slot, E.hoxne_locked_refusal, E.hoxne
    local hoxne_resume_deadline                   = E.hoxne_resume_deadline
    local ensure_placeholders, finish_outgoing_cast = E.ensure_placeholders, E.finish_outgoing_cast
    local get_ability_recasts, get_spell_recasts    = E.get_ability_recasts, E.get_spell_recasts
    local get_current_stratagem_count             = E.get_current_stratagem_count
    local merge_into, merge_report, merge_report_begin    = E.merge_into, E.merge_report, E.merge_report_begin
    local merge_report_branch_end, merge_report_flush     = E.merge_report_branch_end, E.merge_report_flush
    local merge_report_mark, merge_named                  = E.merge_report_mark, E.merge_named
    local build_is_worn                                   = E.build_is_worn
    local mr_am, action_tag                               = E.mr_am, E.action_tag
    local PET_COMMAND_TYPES, PET_MOVE_STALE               = E.PET_COMMAND_TYPES, E.PET_MOVE_STALE
    local PET_MOVE_COMMANDS, PET_COMMAND_WINDOW           = E.PET_MOVE_COMMANDS, E.PET_COMMAND_WINDOW
    local set_declared, forget_pet                        = E.set_declared, E.forget_pet
    local take_pet_ws_worn, set_has_gear                  = E.take_pet_ws_worn, E.set_has_gear
    local SPIRITS                                         = E.SPIRITS
    local buff_prediction, write_buff_predictions         = E.buff_prediction, E.write_buff_predictions
    local predict_buff, ability_buff                      = E.predict_buff, E.ability_buff
    local mark_buff_predictions_ending                    = E.mark_buff_predictions_ending

    ------------------------------------------------------------------------------------------------
    -- SECTION 16 - GEARSWAP ACTION HOOKS
    ------------------------------------------------------------------------------------------------
    -- In the order an action passes through them: validation and pretarget, then the three
    -- cast phases, then the state-change and pet hooks.

    -- Whether the cast proper is in flight. Precast sets it beside the busy window. Aftercast
    -- clears it first thing, which an interrupted action reaches too, and so does every close
    -- of the window. It is not the busy window, which outlives the action by a tail, and a
    -- buff that lands inside the tail must still dress its buff child. A pet's own move never
    -- sets it, since GearSwap routes the move to pet_midcast and pet_aftercast. pet_aftercast
    -- clears it when GearSwap ends the master's own pet command there.
    local cast_in_flight = false
    -- Whether GearSwap has marked that cast in flight, which it does just before the midcast
    -- hook. Until then a buff change cannot tell a dropped cast from one a job file's precast
    -- delay is still holding back, since midaction() answers no cast for either.
    local cast_marked = false
    -- The name of the action that opened the busy window, for the line a lost end prints.
    local busy_action = nil
    -- The same action, as the table GearSwap handed precast. GearSwap hands pet_aftercast that
    -- very table when it ends the master's own pet command there.
    local busy_spell = nil
    -- The cast-proper test, the flag and is_Busy together, as a predicate for two functions in
    -- files that load before this one: the equip component's set_roll_eleven and the
    -- builders' pet_tp_packet. Each skips the rebuild it would ask for while the test holds,
    -- because the cast's aftercast rebuilds. It is a function rather than the flag, so only
    -- this file writes the flag, and both read it from E at the call.
    E.cast_proper_in_flight = function() return cast_in_flight and is_Busy end

    -- Whether a rebuild of the idle or engaged set waited for the cast proper in flight.
    -- Status and buff changes wait, and so do the Treasure Hunter target change, the Doom and
    -- Sleep release, and gs c update auto, whatever sent it. So the cast keeps its midcast
    -- set, and a song its instrument, until the cast ends. The burst re-dress, received gear
    -- and the midcast dress take their own paths and still reach the cast. A stun or
    -- petrification also rebuilds at once, since GearSwap drops the cast at either. The cast's
    -- aftercast is the rebuild that waited, and it dresses the new status and modes. A cast
    -- GearSwap ends with no aftercast hands the rebuild on instead: the buff change that finds
    -- it dropped builds it, a cancel in precast sends it, pet_aftercast builds it for the
    -- master's own pet command, the zone handler's rebuild stands for it, and for a lost end
    -- the polling engine sends it when the busy window expires. From then a rebuild no longer
    -- waits.
    local rebuild_waiting = false

    -- The test every rebuild that waits makes: true while the cast proper is in flight, with
    -- the wait recorded for the cast's end. It is cast_proper_in_flight's own test, so a
    -- rebuild in the busy tail after aftercast goes out at once.
    local function rebuild_waits()
        if not (cast_in_flight and is_Busy) then return false end
        rebuild_waiting = true
        return true
    end

    -- Take the waiting rebuild for a path that ends a cast with no aftercast: true, and the
    -- wait ended, when one waited. The caller then makes the rebuild itself, or stands its own
    -- rebuild in for it.
    local function take_waiting_rebuild()
        if not rebuild_waiting then return false end
        rebuild_waiting = false
        return true
    end

    -- Close the busy window at once, for an action GearSwap ended with no aftercast or a window
    -- past its deadline. The cast proper is over, and its implement lets go of its slots.
    -- A waiting rebuild is left for the caller to hand on. The midcast's mark may stay, since
    -- the window it is read beside is down until the next precast clears it.
    local function close_window()
        is_Busy = false
        E.SpellCastTime = 0
        cast_in_flight = false
        release_implement()
    end

    -- Expire a busy window past its deadline, for the polling engine and precast's stale check.
    -- A cast proper still in flight then lost its end, since GearSwap drops the command at that
    -- age, and one notice line says so: with debug off, the busy refusals before it printed
    -- nothing. The tail after an aftercast expires in silence. A waiting rebuild is left for the
    -- caller.
    local function expire_window()
        if cast_in_flight then
            notice(('[%s] sent no end: actions were held %.1f s.'):format(tostring(busy_action), E.SpellCastTime))
        end
        close_window()
    end

    -- Replace the busy window with the short tail an action's end leaves, rather than clearing
    -- it, because the server enforces its own delay after an action and a rebuild inside it
    -- achieves nothing. Spells keep the longest tail, ranged attacks a shorter one, and other
    -- actions none.
    local function start_tail(spell)
        if RecastTimers[spell.type] then
            E.SpellCastTime = 2.5
        elseif spell.action_type == 'Ranged Attack' then
            E.SpellCastTime = 1.1
        else
            E.SpellCastTime = 0
        end
        E.Spellstart = os.clock()
    end

    -- A zone change ends any cast in flight, since GearSwap empties its registry and calls no
    -- hook for it. The zone handler closes the window before its own rebuild, which stands for
    -- the rebuild that waited, and the other characters are told the cast is over.
    local function close_window_at_zone()
        close_window()
        finish_outgoing_cast()
        take_waiting_rebuild()
    end

    -- pet_midcast records each pet move in E.pet_move at its readying, a spirit's own spell
    -- and the automaton's weaponskill aside, with the spell table GearSwap handed it, by which
    -- a later end of the move knows it. A move that follows the master's own pet command
    -- within PET_COMMAND_WINDOW seconds is the master's. While the job file's PetMoveHold is
    -- on, it is held as the master's own cast in flight is, from the command's completion,
    -- which aftercast records ahead of the readying. Every action of the master's is refused,
    -- and status changes, buff changes, the pet's status changes, the Treasure Hunter target
    -- change and the rebuilds the engine asks of itself wait. Their job-file hooks still run
    -- on time, and the last one's layer rides the rebuild that ends the move, unless a cast of
    -- the master's is in flight then. A move the pet makes on its own holds nothing, so the
    -- master's next action dresses over it.
    --
    -- The move ends at its finish or interruption, through pet_aftercast, or through the
    -- master's own aftercast when GearSwap ends it there on its target's death, paralysis or
    -- range failure. It also ends at the pet's change, a zone change, its finish packet, or the
    -- pet's next swing, the last three through the rebuild they send. Each of those makes the
    -- rebuild the held events waited for. Failing all of them, a held move readied more than
    -- PET_MOVE_STALE seconds before ends at the next status change, Treasure Hunter target
    -- change or rebuild the engine asks of itself, such as movement's, and each of those
    -- rebuilds with the kept layer. Or it ends at the master's next action, which dresses over
    -- the move as it dresses over any layer. A hold still awaiting its readying ends at the
    -- readying, at a refusal of the command, at the pet's change or a zone change, or at any of
    -- those events once the command is more than PET_COMMAND_WINDOW seconds old, and also at a
    -- buff change or the pet's status change then.

    -- When the master last sent a pet command that makes the pet act. pet_midcast spends it.
    local pet_command_at = nil

    -- Whether a pet command makes the pet act: every pact, every Ready move's command, and the
    -- commands of type PetCommand that PET_MOVE_COMMANDS names.
    local function commands_pet_move(spell)
        if spell.type == 'PetCommand' then return PET_MOVE_COMMANDS[spell.english] == true end
        return PET_COMMAND_TYPES[spell.type] == true
    end

    -- Whether a held pet's move holds the event asking. releases says the asker ends a stale
    -- hold rather than wait on it: the master's own action, a status change, a Treasure Hunter
    -- target change or a rebuild the engine asks of itself. Each rebuilding asker then applies
    -- the layer the move kept. A move that readied is stale PET_MOVE_STALE seconds after its
    -- readying, and a hold still awaiting its readying PET_COMMAND_WINDOW seconds after the
    -- command. The age is compared here, at that event, and never on a pass of the polling
    -- engine.
    local function pet_move_holds(releases)
        local move = E.pet_move
        if not (move and move.held) then return false end
        if releases and os.clock() - move.at > (move.awaiting and PET_COMMAND_WINDOW or PET_MOVE_STALE) then
            E.pet_move = nil
            return false
        end
        return true
    end

    -- Refuse the master's action while a pet's move is in flight, naming the move the way the
    -- other refusals name their reason. pretargetcheck asks first. precast asks for a menu
    -- action, which skips pretarget. Both ask before anything is announced to the other
    -- characters, so a refusal owes them nothing.
    local function refuse_during_pet_move(spell)
        if not pet_move_holds(true) then return false end
        local move = E.pet_move
        notice("Can't use " .. spell.name .. ' while ' .. move.pet .. "'s " .. move.name .. ' is in flight.')
        cancel_spell()
        return true
    end

    -- Whether a cast of the master's is in flight by GearSwap's own record, and that cast.
    -- The master's own pet command never counts, because the pet can ready its move before
    -- the command's completion arrives.
    local function master_cast_in_flight()
        local busy, cast = midaction()
        if busy and type(cast) == 'table' and not PET_COMMAND_TYPES[cast.type] then return true, cast end
        return false
    end

    -- Whether the layers of sets.Pet_WS a build merges hold gear: the set, its child for the
    -- automaton's frame and its child for the offense mode.
    local function pet_ws_holds_gear()
        local ws = sets.Pet_WS
        if type(ws) ~= 'table' then return false end
        if set_has_gear(ws) then return true end
        local frame, mode = ws[pet.frame], ws[state.OffenseMode.value]
        return type(frame) == 'table' and set_has_gear(frame) or type(mode) == 'table' and set_has_gear(mode)
    end

    -- The line for the automaton's weaponskill at its readying: whether sets.Pet_WS was on for
    -- it, and if not, the first reason that applies. The set goes on only on a Puppetmaster
    -- main job, under the Pet WS mode, from a threshold that is a number, and only where its
    -- layers hold gear. A cast of the master's in flight wore its own gear over the set. worn
    -- says a build carried the set since the last weaponskill, and ready that the automaton's
    -- TP last read at the threshold. While the master sleeps the idle and engaged build is
    -- empty, so a set put on before the sleep stayed on and one due after it never went on. A
    -- TP read at the threshold with no build since came in the weaponskill's own moment,
    -- before the rebuild it asked for. The Pet WS mode is named as the job file names its
    -- first job mode.
    local function pet_ws_line(worn, ready)
        local mode = state.JobMode.value
        local mode_name = type(UI_Name) == 'string' and UI_Name ~= '' and UI_Name or 'Pet WS'
        local threshold = tonumber(PetWSThreshold)
        local reason
        if player.main_job ~= 'PUP' then
            reason = 'it is worn on a Puppetmaster main job only.'
        elseif mode ~= 'Always' and mode ~= 'Idle' then
            reason = mode_name .. ' is ' .. tostring(mode) .. '.'
        elseif mode == 'Idle' and player.status == 'Engaged' then
            reason = mode_name .. ' is Idle and you are engaged.'
        elseif not threshold then
            reason = 'PetWSThreshold is not a number.'
        elseif not pet_ws_holds_gear() then
            reason = 'it holds no gear.'
        else
            local casting, cast = master_cast_in_flight()
            if casting then
                reason = tostring(cast.name) .. ' was in flight.'
            elseif worn then
                return "wore sets.Pet_WS, put on from the automaton's TP."
            elseif buffactive['Sleep'] then
                reason = 'you are asleep.'
            elseif ready then
                reason = 'its TP read ' .. threshold .. ' too late for the set to go on.'
            else
                reason = 'its TP never read ' .. threshold .. ' before it.'
            end
        end
        return 'went without sets.Pet_WS: ' .. reason
    end

    -- The rebuild a pet's move owes when it ends: the current build, the layer a held status
    -- or buff change kept, then the job file's hook for the event that ended it, called with
    -- that event's arguments. A cast of the master's in flight keeps its gear, and its own
    -- aftercast rebuilds, so then only the hook runs and the kept layer is dropped.
    local function rebuild_after_move(move, hook, ...)
        if master_cast_in_flight() then
            if hook then hook(...) end
            return
        end
        local built_set = build_current_set()
        if move and move.layer then merge_into(built_set, move.layer) end
        if hook then merge_into(built_set, hook(...)) end
        equip(built_set)
    end

    -- Refuse an action that would fail, before GearSwap composes its packet. Where the
    -- player would otherwise see only the server's refusal, the refusal names its reason.
    -- Every refusing branch calls cancel_spell and returns. The checks that stop every
    -- action come first, then the checks for each action type.
    --
    -- It also announces a tracked cast to the other characters, in the ability and spell
    -- branches. That announce is why the cancel paths later in the pipeline owe those
    -- characters a completion.
    function pretargetcheck(spell, action)
        if E.pet_move and refuse_during_pet_move(spell) then return end

        -- An incapacitated character cannot act. Sleep also dresses the idle set and the
        -- Sleep weapons, and stun, petrification and terror dress the idle set.
        local active_buffs = buffactive
        if active_buffs[BUFF_SLEEP] then
            cancel_spell()
            if sets.Idle then equip(sets.Idle) else warn('sets.Idle not found!') end
            if sets.Weapons then
                if sets.Weapons.Sleep then equip(sets.Weapons.Sleep) else warn('sets.Weapons.Sleep not found!') end
            else
                warn('sets.Weapons not found!')
            end
            return
        elseif active_buffs[BUFF_STUN] or active_buffs[BUFF_PETRI] or active_buffs[BUFF_TERROR] then
            cancel_spell()
            if sets.Idle then equip(sets.Idle) else warn('sets.Idle not found!') end
            return
        elseif active_buffs[BUFF_KO] or active_buffs[BUFF_CHARM] then
            cancel_spell()
            return
        end

        -- With AutoItem on, a job ability under paralysis or a spell under silence uses a
        -- carried Remedy instead, unless Muddle forbids items.
        if AutoItem and not active_buffs['Muddle'] then
            local inv = player.inventory
            if (active_buffs['Paralysis'] and spell.type == TYPE_JA) or (spell.action_type == TYPE_MS and active_buffs['Silence']) then
                if inv['Remedy'] then
                    cancel_spell()
                    windower.chat.input('/item "Remedy" <me>')
                    return
                end
            end
        end

        -- From here the checks are per action type. Ability recasts come in seconds and
        -- spell recasts in frames, which is why the two branches below divide differently
        -- before formatting the same way.
        local s_type = spell.type
        if s_type == TYPE_WS then
            if player.tp < 1000 then
                cancel_spell()
                return
            elseif active_buffs['Amnesia'] then
                cancel_spell()
                notice("Can't Weapon Skill due to amnesia.")
                return
            end
        elseif s_type == TYPE_JA or s_type == 'Waltz' or s_type == 'BloodPactWard' or s_type == 'BloodPactRage' or s_type == 'PetCommand' then
            local recast_time = get_ability_recasts()[spell.recast_id]
            if recast_time and recast_time > 0 then
                local total_sec = recast_time
                notice(spell.name ..
                    ' [' .. math.floor(total_sec / 60) .. ':' .. string.format("%02d", total_sec % 60) .. ']')
                cancel_spell()
                return
            end
            if spell.type == 'Waltz' then
                local ja_resource = res.job_abilities[spell.id]
                if ja_resource and ja_resource.tp_cost then
                    if player.tp < ja_resource.tp_cost then
                        cancel_spell()
                        notice('Insufficient TP for ' ..
                            spell.name .. ' [' .. player.tp .. '/' .. ja_resource.tp_cost .. ']')
                        return
                    end
                end
            end

            -- Tell the other characters this ability is coming, so they can dress for it
            -- before it lands.
            if state.SpellReceived.value ~= "OFF" then
                local a_info = ability_info[spell.id]
                if a_info and player and spell.target.name then
                    announce_tracked_cast('ABILITY', 'pretarget', spell, spell.target.name, a_info.aoe)
                end
            end
        elseif HasRecastTimer[s_type] then
            local recast_time = get_spell_recasts()[spell.recast_id]
            if recast_time and recast_time > 0 then
                local total_sec = recast_time / 60
                notice(spell.name ..
                    ' [' .. math.floor(total_sec / 60) .. ':' .. string.format("%02d", total_sec % 60) .. ']')
                cancel_spell()
                return
            end

            -- The same announce for spells, plus whom it will reach. A spell spreads if it
            -- is area-of-effect by nature, or if a widening effect it answers to is up:
            -- Accession, Majesty or Divine Seal. Yagrush counts as Divine Seal when
            -- check_equipment_spells dresses it for this cast. A buff whose result has come
            -- and that GearSwap does not list yet is read from its prediction, which pretarget
            -- wrote into the list first.
            local s_info = spell_info[spell.id]
            if s_info and spell.target.name and state.SpellReceived.value ~= "OFF" then
                local accession_active = active_buffs[366] or active_buffs['Accession']
                local majesty_active = active_buffs[621] or active_buffs['Majesty']
                local divine_veil_active = active_buffs[78] or active_buffs['Divine Seal']
                local has_yagrush = (s_info.divine and wears_yagrush(spell))
                local spreads = (s_info.aoe or (accession_active and s_info.accession) or (majesty_active and s_info.majesty) or ((divine_veil_active or has_yagrush) and s_info.divine))
                announce_tracked_cast('SPELL', 'pretarget', spell, spell.target.name, spreads)
            end
        elseif s_type == TYPE_SCH then
            local available_charges, next_charge = get_current_stratagem_count()
            if available_charges == 0 then
                cancel_spell()
                -- At zero charges, a nil wait means the character has no stratagems at
                -- all. The refusal says so, instead of naming a countdown that will never
                -- arrive.
                if next_charge then
                    notice(('Unable to use strategems. Next charge in [%d:%02d].')
                        :format(math.floor(next_charge / 60), math.floor(next_charge % 60)))
                else
                    notice('Unable to use strategems. Available charges = 0')
                end
            end
        end
    end

    -- The first hook GearSwap calls. Writes the buff prediction into the list GearSwap has
    -- just rebuilt, runs the validation above, opens the Hoxne critical window, then hands to
    -- the job file. Every hook below writes the prediction first in the same way.
    --
    -- The window opens after the engine's guards and before the job file's
    -- pretarget_custom. Instrument or ammunition handling in the job file's hook, and in
    -- every later phase, then passes through an open window instead of fighting the hold.
    function pretarget(spell, action)
        if buff_prediction.n > 0 then write_buff_predictions(true) end
        pretargetcheck(spell, action)

        local hoxne_opened = false
        if state.Hoxne.value == 'ON-Allow Critical' then
            local crit = critical_action_for(spell)
            if crit then
                if _global.cancel_spell then
                    log('Hoxne: window not opened; pretargetcheck canceled [', spell.english, ']')
                else
                    hoxne_opened  = true
                    hoxne.window  = true
                    hoxne.owner   = crit
                    hoxne.expires = os.clock() + 20 -- a watchdog until aftercast sets the real countdown
                    -- Two kinds of action need gear at this instant. A gear-gated song
                    -- cannot be cast without its named instrument, and Tomahawk and Angon
                    -- need their throwing item. Ordinary songs and Geomancy need nothing
                    -- here, because their instruments arrive with the normal sets.
                    local gated   = check_equipment_spells(spell)
                    if gated then
                        equip(gated)
                    elseif crit.force then
                        equip({ [crit.slot] = crit.force })
                    end
                    log('Hoxne: critical window open for ', spell.english, ' (', crit.slot, ')')
                end
            end
        end

        if pretarget_custom then pretarget_custom(spell, action) end

        -- The job file canceled, after pretargetcheck may already have announced. The other
        -- characters are holding gear and locked slots for a cast that is not coming, so
        -- they are told rather than left to time out on their failsafe.
        if _global.cancel_spell then finish_outgoing_cast() end

        -- The same cancel, for the window. It closes in two seconds rather than at once. That
        -- covers the common pattern of cancel, equip and reissue, where the reissued command
        -- opens the window again before the tick would relock, so the Ampulla never flickers
        -- back in.
        if hoxne_opened and _global.cancel_spell then
            hoxne.expires = os.clock() + 2
            log('Hoxne: pretarget_custom canceled [', spell.english, ']; window closing in 2s')
        end
    end

    -- Runs after GearSwap composes the packet and before it is sent, the last moment gear
    -- can still reach the action. It arms the busy window and wears the precast set: fast
    -- cast for a spell, and the action's own set for an ability or a weaponskill.
    function precast(spell)
        if buff_prediction.n > 0 then write_buff_predictions(true) end
        -- A menu action skips pretarget, so a pet's move in flight refuses it here, above
        -- everything that arms a window or announces a cast.
        if E.pet_move and refuse_during_pet_move(spell) then return end
        -- The ON-Locked refusal sits above the busy gate, so a gated ability pressed
        -- mid-action is refused for the right reason. It sends no multibox completion,
        -- which is safe only because the gated abilities are never announced.
        if spell.type == TYPE_JA then
            local locked = hoxne_locked_refusal(spell.id)
            if locked then
                notice(locked)
                cancel_spell()
                return
            end
        end
        -- Expire a busy window whose aftercast never arrived, so a lost completion cannot
        -- leave the engine refusing every following action. The polling engine carries the
        -- same test for the same reason. A rebuild that waited for the lost cast waits on for
        -- this action, whose own end makes it. An item used on an NPC has no end, so its
        -- precast sends that rebuild below.
        if is_Busy and os.clock() - E.Spellstart > E.SpellCastTime then
            expire_window()
        end
        if not is_Busy then
            -- The window stands until the action's aftercast, which replaces it with a short
            -- tail. For an end that never arrives it stands as long as GearSwap keeps the
            -- command, since GearSwap then drops it with no aftercast. A job file's precast
            -- delay is added at the end of this hook, because GearSwap counts it too. The
            -- action's name is kept for the line a lost end prints. An item used on an NPC
            -- opens no window: GearSwap types it a Trade and never ends one, and the NPC's own
            -- event stops the player in the game.
            if spell.action_type ~= 'Trade' then
                E.SpellCastTime = lost_end_seconds(spell)
                busy_action, busy_spell = spell.name, spell
                E.Spellstart = os.clock()
                is_Busy = true
                cast_in_flight = true
                cast_marked = false
            elseif take_waiting_rebuild() then
                equip_set_command()
            end
        else
            log('Player is Busy [', spell.english, ']')
            -- The busy gate, where precast pays the multibox debt. pretargetcheck may already
            -- have announced this cast, so the other characters may be holding gear and
            -- locked slots for it. They are told rather than left waiting.
            finish_outgoing_cast()
            cancel_spell()
            -- A canceled cast never reaches aftercast, so the critical window gets its
            -- deadline here, the one aftercast would have set. Without it the window would
            -- stay open until its twenty-second watchdog. A gated ability gets the same half
            -- second it gets at aftercast. Its throwing item comes off on the next tick, and
            -- a retry equips it again.
            local crit = hoxne.window and critical_action_for(spell) or nil
            if crit then hoxne.expires = hoxne_resume_deadline(crit) end
            return
        end
        -- The same window, opened here for an action that never reached pretarget. A cast
        -- started from the game's own menu is the common case. Without this, the equip
        -- override would strip the instrument from every menu-cast song.
        if state.Hoxne.value == 'ON-Allow Critical' then
            local crit = critical_action_for(spell)
            if crit then
                if not hoxne.window then
                    hoxne.window  = true
                    hoxne.owner   = crit
                    hoxne.expires = os.clock() + 20
                    if crit.force then equip({ [crit.slot] = crit.force }) end
                    log('Hoxne: critical window open at precast for ', spell.english, ' (', crit.slot, ')')
                else
                    -- A new critical action arriving inside an open window pushes the
                    -- deadline back out and becomes the window's owner. Without this it
                    -- would inherit the previous action's countdown and could expire
                    -- mid-song.
                    hoxne.owner   = crit
                    hoxne.expires = os.clock() + 20
                    log('Hoxne: critical window refreshed at precast for ', spell.english)
                end
            end
        end

        -- The engine's set, then the job file's additions on top of it.
        local built_set = precastequip(spell) or {}
        merge_report_flush('precast', spell)
        if precast_custom then
            merge_into(built_set, precast_custom(spell))
        else
            warn('precast_custom() not found!')
        end
        -- Gear the engine owns for the action outranks anything the sets chose: Daybreak for
        -- Dispelga, a named instrument, the Impact cloak, and Yagrush for a White Mage's
        -- Cursna. When a higher layer holds one of its slots, report_refused names the slot
        -- and its holder once per cast, which explains the missing piece.
        local equipment_spell_set, refused = check_equipment_spells(spell)
        report_refused(spell.english, refused)
        if equipment_spell_set then merge_into(built_set, equipment_spell_set) end
        -- A gated ability's throwing item, forced into its slot after every merge. The
        -- build keeps its own entry there only when that entry is the same item.
        local force_slot, force_item = critical_force_slot(built_set, spell)
        if force_slot then built_set[force_slot] = force_item end
        -- A weaponskill keeps the weapons in hand. Main and sub leave the build here, after
        -- every merge and right before the equip, and so does range on every job but Bard
        -- and Geomancer.
        if spell.type == TYPE_WS then
            keep_weaponskill_weapons(built_set, spell)
        end
        -- At precast the instrument wins over the ammo only where this build carries the song's
        -- own instrument. Under Nightingale this build is the song's whole build. Honor March and
        -- Aria of Passion carry their required instrument from the implements. Any other song's
        -- precast is left to the ammo rule below, and its instrument goes on at midcast. This
        -- runs before that rule, so the rule never clears an instrument these builds name.
        local instrument
        if spell.type == 'BardSong'
            and ((equipment_spell_set and equipment_spell_set.range) or buffactive['Nightingale']) then
            instrument = yield_ammo_to_instrument(built_set)
        end
        -- For a spell, ammo in this build strips a handbell or instrument in range, worn or
        -- named by the build. The range slot is cleared in this build, so GearSwap's model of
        -- worn gear sees that strip and the midcast's bell or instrument is sent.
        if spell.action_type == 'Magic' then
            yield_range_to_ammo(built_set)
        end
        equip(built_set)
        -- The implements outrank the weapon lock. A slot the lock holds is dressed from them
        -- after the equip above, so the lock never keeps Daybreak off Dispelga. An action the
        -- lock exempts, a friendly song under Songs or a Geomancy spell under Geomancy, has
        -- its whole build dressed over the held slots the same way, weapons included. The
        -- end of the cast puts the mode's weapons back.
        if lock_exempts(spell) then
            assert_over_lock(built_set)
        elseif equipment_spell_set then
            assert_over_lock(equipment_spell_set)
        end
        -- GearSwap deletes an action canceled in this hook, by the engine's ammunition check
        -- or the job file's layer, and sends it no midcast or aftercast. Its window closes
        -- here, so nothing is refused or held for it. The other characters are told the cast
        -- is over, and a rebuild that waited goes out, since no end will make it. The critical
        -- window gets the deadline aftercast would have set, as at the busy gate. A pet
        -- command canceled here marks nothing.
        if _global.cancel_spell then
            close_window()
            finish_outgoing_cast()
            if take_waiting_rebuild() then equip_set_command() end
            local crit = hoxne.window and critical_action_for(spell) or nil
            if crit then hoxne.expires = hoxne_resume_deadline(crit) end
            return
        end
        local delay = _global.precast_cast_delay
        if delay and delay > 0 then E.SpellCastTime = lost_end_seconds(spell, delay) end
        -- The implement then holds its slots for the cast. No layer below it can move them
        -- until aftercast lets them go. Honor March's and Aria of Passion's instrument holds
        -- the ammo slot empty beside it, so no ammo knocks it off mid-song.
        if equipment_spell_set then hold_implement(instrument or equipment_spell_set) end
        -- A pet command that makes the pet act marks its moment, so the move the pet readies
        -- after it counts as the master's own, and is held while PetMoveHold is on.
        if commands_pet_move(spell) then pet_command_at = os.clock() end
    end

    -- The midcast dress: the engine's build, the job file's midcast layer over it, the
    -- implements, and the equip. The same shape as precast, without the window and busy
    -- handling, which precast has already settled. GearSwap's midcast runs it, and so does
    -- the burst re-dress command for a cast already in flight, passing burst to force the
    -- burst on or off. A re-dress runs the job file's midcast_custom again for that cast.
    local function dress_midcast(spell, burst)
        local built_set = midcastequip(spell, burst) or {}
        merge_report_flush('midcast', spell)
        if midcast_custom then
            merge_into(built_set, midcast_custom(spell))
        else
            warn('midcast_custom() not found!')
        end
        -- The implements again, merged over the midcast build so its sets cannot displace
        -- them. Precast already named any refused slot, so the second return is ignored.
        local equipment_spell_set = check_equipment_spells(spell)
        if equipment_spell_set then merge_into(built_set, equipment_spell_set) end
        -- A song's instrument empties the ammo here too, after the implements, so no ammo
        -- from the sets or the job file's layer removes it mid-cast.
        local instrument
        if spell.type == 'BardSong' then
            instrument = yield_ammo_to_instrument(built_set)
        end
        -- A weaponskill's midcast build is empty, so this list is the job file's layer and
        -- the implements. It loses its weapon slots too, right before the equip.
        if spell.type == TYPE_WS then
            keep_weaponskill_weapons(built_set, spell)
        end
        equip(built_set)
        if lock_exempts(spell) then
            assert_over_lock(built_set)
        elseif equipment_spell_set then
            assert_over_lock(equipment_spell_set)
        end
        -- A song's instrument then holds range, and the ammo slot empty, through the
        -- implement hold until aftercast lets them go. Received gear's range or ammo is
        -- refused meanwhile, and a job file's equip into either slot is diverted. A burst
        -- re-dress finds both already held, and its own equip into them is diverted too.
        if instrument then hold_implement(instrument) end
    end

    -- Runs while the action is in flight, and wears the potency, accuracy and recast gear.
    -- GearSwap has just marked the action in flight, so a buff change can now tell when
    -- GearSwap drops it.
    function midcast(spell)
        if buff_prediction.n > 0 then write_buff_predictions(true) end
        cast_marked = true
        dress_midcast(spell)
    end

    -- Runs when the action completes or is interrupted. Returns the character to idle or
    -- engaged gear, restarts the busy window as a short tail, and starts the critical
    -- window's real countdown. It predicts the buff a job ability this character aims at
    -- itself gives, and marks every standing prediction to end once a spell, shot or
    -- weaponskill ends.
    function aftercast(spell)
        if buff_prediction.n > 0 then write_buff_predictions(true) end
        -- A pet's move or spell that GearSwap ends here, on its target's death or a paralysis
        -- or range failure, rather than at pet_aftercast. GearSwap hands this hook the very
        -- table pet_midcast was handed. The move ends, and the master's own cast state below is
        -- left alone, since no cast of the master's ended. An action message refusing the
        -- master is handed GearSwap's newest command instead, marked as an interruption, and
        -- that can be the move. Then the master's own action ends below, and the move goes on.
        local move = E.pet_move
        if move and spell == move.spell and spell.action_type ~= 'Interruption' then
            -- A move the action handler already ended waits for the rebuild it asked for, with
            -- the job file's layer kept for it.
            if move.ended then
                if aftercast_custom then move.after_layer = aftercast_custom(spell) end
                return
            end
            E.pet_move = nil
            rebuild_after_move(move, aftercast_custom, spell)
            return
        end
        -- The cast proper is over, whatever became of it. GearSwap routes an interrupted
        -- action here too, so these first lines cover both endings. They run before anything
        -- that can raise, such as the job file's aftercast_custom or choose_set_custom, so a
        -- raise below still leaves the flag down, the cast out of reach of a burst re-dress
        -- and the busy window already the action's short tail. The raise then costs only this
        -- action's gear.
        cast_in_flight = false
        cast_marked = false
        E.burst_pending = nil
        start_tail(spell)
        -- A pet command the game refused readies nothing, so its mark goes. The completion of
        -- one it took arrives just before the readying, which still needs the mark.
        if spell.interrupted and commands_pet_move(spell) then pet_command_at = nil end
        -- The ordinary place the multibox debt is paid. The cast finished, so the other
        -- characters are told they may release the gear they were holding.
        if state.SpellReceived.value ~= 'OFF' and E.outgoing_cast_active then
            if settings.debug then
                debug(string.format("IPC message sent: RAHVIN|COMPLETE|%s|%.0f", player.name,
                    get_time()))
            end
            finish_outgoing_cast()
        end
        -- The cast is over, so its implement lets go of its slots first. Under the weapon
        -- lock, the mode's weapon goes back on here, before the build below. GearSwap fires
        -- the piece last diverted into each freed slot, such as a received set's ammo refused
        -- mid-song, and the build below, equipped in this same event, replaces it wherever the
        -- build names that slot.
        release_implement()
        -- A job ability this character aims at itself, and that was not interrupted, predicts
        -- here the buff its result's number names, where that buff is the ability's own, ahead
        -- of the build below, so the idle or engaged set dresses for it at once. The aftercast
        -- sees only that number, not the result's message. A result whose number names no such
        -- buff is read at the raw action event a moment later, which reads the message.
        if spell.prefix == '/jobability' and not spell.interrupted and spell.target and spell.target.type == 'SELF' then
            local id = ability_buff(spell.id, spell.value, true)
            if id then predict_buff(id, nil, spell.english) end
        end
        -- The master's own aftercast while a held move's set is on: the master's pet command
        -- completing after the readying. The pet's set stays on, so nothing is built, and only
        -- the job file's layer below goes on.
        local keep_pet_set = move ~= nil and move.held and move.dressed
        local built_set = keep_pet_set and {} or aftercastequip(spell) or {}
        merge_report_flush('aftercast', spell)
        -- This build is the rebuild that waited for the cast, whichever event asked for it, and
        -- it dresses the new status, target and modes. It also pays a pet's move what the
        -- update command pays at any rebuild: an ended move's record closed and its kept layers
        -- on, under the job file's layer below. A move that still holds is left to its own end,
        -- which rebuilds, and so is a held move's set kept on above.
        if rebuild_waiting then
            rebuild_waiting = false
            local pending = E.pet_move
            if not keep_pet_set and not (pending and pet_move_holds(true)) then
                E.merge_move_layers(built_set, pending)
            end
        end
        if aftercast_custom then
            merge_into(built_set, aftercast_custom(spell))
        else
            warn('aftercast_custom() not found!')
        end
        equip(built_set)
        -- While PetMoveHold is on, the hold starts here. The completion of a pet command the
        -- game took arrives before the pet readies its move, so an action begun in that gap is
        -- refused, naming the command, rather than going out under the move. The readying
        -- replaces this record, and failing one, the hold ends at the master's next event once
        -- the command is PET_COMMAND_WINDOW seconds old. A move that readied first keeps its
        -- own record.
        if PetMoveHold and pet_command_at and not spell.interrupted and pet.isvalid and commands_pet_move(spell) then
            local prev = E.pet_move
            if not (prev and not prev.awaiting and prev.at >= pet_command_at) then
                E.pet_move = { name = spell.name, pet = pet.name, actor = pet.id, at = pet_command_at,
                    awaiting = true, dressed = false, held = true, layer = prev and prev.layer }
            end
        end
        -- Replace the twenty-second watchdog with the real countdown, now that the action
        -- has finished. The cancel paths above set the same deadline themselves, because a
        -- canceled action never arrives here.
        local crit = hoxne.window and critical_action_for(spell) or nil
        if crit then
            hoxne.expires = hoxne_resume_deadline(crit)
        end

        -- A spell, shot or weaponskill ended, interrupted or not, so every standing prediction
        -- ends with it. Each is only marked here, after this event's build has read it, and ends
        -- at the raw action event of this result, which reads it first.
        if buff_prediction.n > 0 and (RecastTimers[spell.type] or spell.type == TYPE_WS or spell.prefix == '/range') then
            mark_buff_predictions_ending()
        end
    end

    -- Runs on any buff gained or lost, and re-dresses the character for the new state, such
    -- as Aftermath appearing, Sublimation charging, or a food effect ending.
    --
    -- While the cast proper is in flight it builds nothing, so a buff landing mid-cast does
    -- not pull the character out of cast gear. The job file's hook still runs at the change,
    -- so its chat lines and commands come on time, and its table is dropped, as the status
    -- hook's is. The wait is recorded, so the action's end dresses for the new buff. The busy
    -- window alone is not the gate. It outlives the action by a tail, and a self-cast
    -- spell's buff arrives inside that tail and must still dress its buff child. When the
    -- gate passes, the build is always made. The equip is skipped only when build_is_worn
    -- proves every slot already worn by GearSwap's own test, the one case in which the equip
    -- would send nothing.
    --
    -- A held pet's move holds it too, whatever its age. The job file's hook still runs, and
    -- its layer waits on the move's record for the rebuild that ends the move. A hold still
    -- awaiting its readying holds it only until the command window passes: past it no readying
    -- came and no move is in flight, so this event ends that hold, and its rebuild applies the
    -- layer the hold kept.
    --
    -- GearSwap ends the cast in flight with no aftercast when a disabling buff lands, such as
    -- sleep, stun or terror: it deletes the cast before it calls this hook. So once the midcast
    -- has marked the cast, a buff change that finds nothing marked in flight closes the busy
    -- window, lets the implement go and tells the other characters. Any cast still marked keeps
    -- the window, since GearSwap's drop removes every one at once. The build below then dresses
    -- as at a buff change outside a cast, and it is also the rebuild that waited, paying what a
    -- pet's move owes that rebuild.
    function buff_change(name, gain)
        if buff_prediction.n > 0 then write_buff_predictions(true) end
        local waited = false
        if cast_marked and is_Busy and not midaction() then
            close_window()
            finish_outgoing_cast()
            waited = take_waiting_rebuild()
        end
        local move = E.pet_move
        if move and pet_move_holds(move.awaiting == true) then
            if buff_change_custom then move.layer = buff_change_custom(name, gain) end
            return
        end
        if rebuild_waits() then
            if buff_change_custom then buff_change_custom(name, gain) end
            return
        end
        local built_set = build_current_set()
        if waited then
            E.merge_move_layers(built_set, move)
        elseif move and move.held and move.layer then
            merge_into(built_set, move.layer)
        end
        if buff_change_custom then
            merge_into(built_set, buff_change_custom(name, gain))
        else
            warn('buff_change_custom(name,gain) not found!')
        end
        if build_is_worn(built_set) then return end
        equip(built_set)
    end

    -- Runs when the player's status changes: engaged, idle, resting or dead. A held pet's
    -- move holds it, and the move's end rebuilds. The job file's hook still runs, and its
    -- layer waits on the move's record for that rebuild. A status change is one of the
    -- master's own events, so a stale hold ends here instead, and this rebuild applies the
    -- layer the move kept, under the change's own. The master's own action starting ends a
    -- stale hold too, so none stands while the master's cast is in flight.
    --
    -- While the cast proper is in flight it waits, so a disengage mid-song leaves the
    -- instrument and the midcast set on. The job file's hook runs on time and its layer is
    -- dropped, as a pet's status change mid-cast drops its own. The cast's aftercast dresses
    -- the new status, with the job file's aftercast layer. In the busy tail after aftercast
    -- it re-dresses at once.
    function status_change(new, old)
        if buff_prediction.n > 0 then write_buff_predictions(true) end
        local move = E.pet_move
        if move and pet_move_holds(true) then
            if status_change_custom then move.layer = status_change_custom(new, old) end
            return
        end
        if rebuild_waits() then
            if status_change_custom then status_change_custom(new, old) end
            return
        end
        local built_set = build_current_set()
        if move and move.held and move.layer then merge_into(built_set, move.layer) end
        if status_change_custom then
            merge_into(built_set, status_change_custom(new, old))
        else
            warn('status_change_custom(new,old) not found!')
        end
        equip(built_set)
    end

    -- Runs when a pet is summoned or dismissed, so the idle build can pick up or drop its
    -- pet layer. A move in flight ends with its pet, and this build is the rebuild the held
    -- events waited for. A cast of the master's in flight keeps its gear instead, and its
    -- own aftercast rebuilds. What was read of the last pet is forgotten, its pet-mode value
    -- and its weaponskill readiness, and under Auto the status box is repainted to show the
    -- new pet's.
    function pet_change(pet, gain)
        if buff_prediction.n > 0 then write_buff_predictions(true) end
        forget_pet()
        local move = E.pet_move
        E.pet_move = nil
        rebuild_after_move(move, pet_change_custom, pet, gain)
        if not pet_change_custom then warn('pet_change_custom() not found!') end
        if state.JobMode2.value == 'Auto' then display_box_update() end
    end

    -- Runs when GearSwap reports the pet engaged, idle or dead, so the idle build can put on
    -- or take off sets.Idle.Pet.Engaged. A held pet's move keeps the job file's layer for the
    -- rebuild that ends the move. This event is the pet's, so it never ends a stale hold,
    -- except a hold still awaiting its readying past the command window, which it ends as
    -- buff_change does. While the cast proper is in flight it builds nothing, and the cast's
    -- aftercast rebuilds with the pet's new status. The job file's hook runs on time either
    -- way, and mid-cast its layer is dropped. The equip is skipped when build_is_worn proves
    -- the build already worn.
    function pet_status_change(new, old)
        if buff_prediction.n > 0 then write_buff_predictions(true) end
        local move = E.pet_move
        if move and pet_move_holds(move.awaiting == true) then
            if pet_status_change_custom then move.layer = pet_status_change_custom(new, old) end
            return
        end
        if cast_in_flight and is_Busy then
            if pet_status_change_custom then pet_status_change_custom(new, old) end
            return
        end
        local built_set = build_current_set()
        if move and move.held and move.layer then merge_into(built_set, move.layer) end
        if pet_status_change_custom then merge_into(built_set, pet_status_change_custom(new, old)) end
        if build_is_worn(built_set) then return end
        equip(built_set)
    end

    -- Runs when a pet readies its own move, such as a wyvern breath, a blood pact or a jug
    -- pet's Ready move. The game reads the move's potency gear from here to its finish, so
    -- this is where that gear goes on. It reports its set the way a cast does, so pet moves
    -- appear in the same info and gear-report lines. Two kinds dress nothing: a spirit's own
    -- spell, and the automaton's weaponskill, which it decides before the readying arrives.
    --
    -- The sets merge in this order, each over the last. First sets.Pet_Midcast, then the
    -- move's family, sets.Pet_Midcast.BloodPact, .Ready or .Wyvern. Then its category, such
    -- as .Physical or .Healing, and that category's child for the offense mode. Then
    -- sets.Pet_Midcast.TPBonus for a move whose effect follows the pet's TP, then the set
    -- named for the move, and then the job file's pet_midcast_custom layer. Under the weapon
    -- lock the master's weapon mode and the locked pair go on last. Pet_Moves gives each
    -- move's family, category and TP mark. A family, category or TP bonus set the job file
    -- never declared is skipped. A move the table does not list, or whose type disagrees
    -- with its family, takes sets.Pet_Midcast and its own set. On a Beastmaster main job,
    -- every move of the pet takes the Ready family as well, listed or not.
    --
    -- The base set is merged into a fresh table rather than used directly. Merging into
    -- sets.Pet_Midcast itself would write the move's gear permanently into the job file's
    -- general set.
    function pet_midcast(spell)
        if buff_prediction.n > 0 then write_buff_predictions(true) end
        -- A spirit's own spell dresses nothing. A set put on at its casting start would hold the
        -- master's gear through a cast of up to thirteen seconds. A spirit's gear works as well
        -- worn the whole time, in the set worn while it fights. The job file's hook still runs.
        if SPIRITS[pet.name] and spell.action_type == 'Magic' then
            if pet_midcast_custom then pet_midcast_custom(spell) end
            return
        end
        -- The automaton decides its weaponskill before the readying reaches GearSwap, which
        -- brings the finish in the same moment, so a set put on here is too late. Its gear goes
        -- on from the automaton's TP, in sets.Pet_WS. The line says whether that set was on, and
        -- the job file's hook still runs. The readying is taken even with the info lines off, so
        -- each weaponskill reads its own cycle. Its spells dress as any pet move does.
        if Automaton_Weaponskills and Automaton_Weaponskills[spell.english] then
            local worn, ready = take_pet_ws_worn()
            if settings.info then
                info(action_tag(spell) .. pet_ws_line(worn, ready))
            end
            if pet_midcast_custom then pet_midcast_custom(spell) end
            return
        end
        -- The move is the master's own when it readies within the window after the master's
        -- pet command, and the readying spends the mark.
        local commanded = pet_command_at ~= nil and os.clock() - pet_command_at <= PET_COMMAND_WINDOW
        pet_command_at = nil
        -- A move whose end never came hands on the layer its held events kept, so this move's end
        -- applies it.
        local prev = E.pet_move
        local move_record = { name = spell.name, pet = pet.name, actor = pet.id, at = os.clock(),
            dressed = false, spell = spell, held = false, layer = prev and prev.layer }
        E.pet_move = move_record
        -- A cast of the master's in flight at the readying keeps its gear, as a cast keeps the
        -- gear it dressed until it completes, so the move goes without its set, says so and
        -- holds nothing. The job file's hook still runs.
        local casting, cast = master_cast_in_flight()
        if casting then
            if settings.info then
                info(action_tag(spell) .. 'went without its set: ' .. tostring(cast.name) .. ' was in flight.')
            end
            if pet_midcast_custom then pet_midcast_custom(spell) end
            return
        end
        move_record.held = commanded and PetMoveHold and true or false
        ensure_placeholders()
        merge_report_begin()
        if sets.Pet_Midcast then
            local built_set = {}
            -- The branch starts at the mark with no base layers beneath it, because
            -- sets.Pet_Midcast is itself the set the report should name when it falls back.
            merge_report_mark()
            merge_report(built_set, sets.Pet_Midcast)
            -- A Ready move is a monster ability, which carries no type. A pact and a wyvern
            -- move are typed as pacts. Any other move named like one of these is neither, so
            -- it takes no family. Every move of a Beastmaster's pet, jug or charmed, is a monster
            -- ability and takes the Ready family, with a category only where the table lists
            -- the move as a Ready move, so a charmed pet's Sand Breath takes no wyvern category.
            local move = Pet_Moves and Pet_Moves[spell.english]
            local family = move and move[1]
            if spell.type == nil and player.main_job == 'BST' then
                if family ~= 'Ready' then move = nil end
                family = 'Ready'
            elseif family == 'Ready' then
                if spell.type ~= nil then family = nil end
            elseif spell.type ~= 'BloodPactRage' and spell.type ~= 'BloodPactWard' then
                family = nil
            end
            -- A family, category or TP bonus set merges only where the job file declared it, so
            -- an engine placeholder left untouched neither dresses nor names the line.
            if family then
                if set_declared(sets.Pet_Midcast[family]) then
                    merge_named(built_set, sets.Pet_Midcast, 'sets.Pet_Midcast', family)
                end
                local category = move and move[2]
                if category then
                    local by_category, mode = sets.Pet_Midcast[category], state.OffenseMode.value
                    if set_declared(by_category) then
                        merge_named(built_set, sets.Pet_Midcast, 'sets.Pet_Midcast', category)
                    end
                    -- The offense mode's child of the category alone. sets.Pet_Midcast's own
                    -- children are the families, the categories and the moves, never a mode.
                    -- A mode child is the job file's own, merged only where it declared one,
                    -- under the path of the category the move chose.
                    if type(by_category) == 'table' and type(by_category[mode]) == 'table' then
                        local category_path = 'sets.Pet_Midcast.' .. category
                        merge_named(built_set, by_category, category_path, mode)
                    end
                end
                -- The TP bonus set is an overlay in the report, named beside the set the move
                -- chose rather than as it.
                if move and move.tp and set_declared(sets.Pet_Midcast.TPBonus) then
                    mr_am.from, mr_am.label = E.mr_count + 1, 'TP bonus'
                    merge_named(built_set, sets.Pet_Midcast, 'sets.Pet_Midcast', 'TPBonus')
                    mr_am.to = E.mr_count
                end
            end
            if sets.Pet_Midcast[spell.english] then
                merge_named(built_set, sets.Pet_Midcast, 'sets.Pet_Midcast', spell.english)
            end
            merge_report_branch_end()
            -- The hook's layer is kept for the report, which names the hook when it alone
            -- dressed the action.
            local custom
            if pet_midcast_custom then
                custom = pet_midcast_custom(spell)
                merge_into(built_set, custom)
            end
            -- Under the weapon lock, the master's weapon mode is layered on, because the
            -- master's weapons still apply during a pet action. Unlocked, the engine adds no
            -- weapon of its own, so a pet set's main and sub stand.
            if E.lock_main_sub then
                -- Quietly, with no Dual Wield set, and with no shield when the mode names
                -- no set of its own. A pet action is not the place to report a missing
                -- weapon set, and the master's offhand should not change because the pet
                -- acted. The pair is written last, as every builder writes it.
                apply_weapon_mode(built_set, false, true, true)
                reassert_pair(built_set)
                log('Midcast set equiping Offense Mode Gear')
            end
            merge_report_flush('midcast', spell, custom, 'pet_midcast_custom')
            equip(built_set)
            move_record.dressed = true
        else
            warn('sets.Pet_Midcast not found!')
        end
    end

    -- Runs when a pet's move finishes or is interrupted, returning the master to whatever
    -- their own state calls for. It ends the move, and this build is the rebuild the held
    -- events waited for. A cast of the master's in flight keeps its gear, and its own
    -- aftercast rebuilds. A pet's own move opens no busy window, since the pet acted and not
    -- the player. GearSwap can also end the master's own pet command here, and then the
    -- command's busy window closes as aftercast closes it.
    function pet_aftercast(spell)
        if buff_prediction.n > 0 then write_buff_predictions(true) end
        -- GearSwap ends the master's own pet command here rather than at aftercast when its
        -- target dies, or the command is refused for paralysis or range, before its
        -- completion, and hands this hook the very table precast was handed. The command ends
        -- as aftercast ends an action: the busy window becomes its tail, which is none, its
        -- implement lets go and the other characters are told. Its mark goes, since no move of
        -- its follows, and the rebuild below is the one that waited for it.
        if spell == busy_spell and cast_in_flight then
            cast_in_flight, cast_marked = false, false
            start_tail(spell)
            pet_command_at = nil
            finish_outgoing_cast()
            release_implement()
            rebuild_waiting = false
        end
        local move = E.pet_move
        -- A spirit's own spell and the automaton's weaponskill put nothing on, so their end takes
        -- nothing off. A spirit's spell cut off mid-cast arrives here relabeled an Interruption,
        -- and is skipped the same way. The hook still runs.
        if not move and (SPIRITS[pet.name]
                and (spell.action_type == 'Magic' or spell.action_type == 'Interruption')
                or Automaton_Weaponskills and Automaton_Weaponskills[spell.english]) then
            if pet_aftercast_custom then pet_aftercast_custom(spell) end
            return
        end
        -- The action handler already ended this move, at its finish packet, the pet's swing or
        -- a zone change, and asked for the rebuild that closes it. The job file's layer is kept
        -- for that rebuild, so the move's end rebuilds once.
        if move and move.ended then
            if pet_aftercast_custom then move.after_layer = pet_aftercast_custom(spell) end
            return
        end
        -- While the master's command's hold awaits its readying, the end of a move the pet readied
        -- before it is not the command's end: that end rebuilds and the hold stands. A refusal of
        -- the command, which GearSwap marks interrupted, is its end and ends the hold below.
        if move and move.awaiting and not spell.interrupted then
            rebuild_after_move(nil, pet_aftercast_custom, spell)
            return
        end
        E.pet_move = nil
        rebuild_after_move(move, pet_aftercast_custom, spell)
    end

    -- The midcast dress, for the burst re-dress command. The pet move's hold and the rebuild's
    -- wait for the cast in flight, for the rebuild command, the Treasure Hunter target change
    -- and the Doom and Sleep release, and the wait's hand-off, for the polling
    -- engine. The busy window's expiry, for the polling engine, and its close at a zone
    -- change, for the zone handler. spellreceived.lua, th.lua, monitor.lua and commands.lua
    -- load after this file and bind them at construction.
    E.dress_midcast = dress_midcast
    E.pet_move_holds = pet_move_holds
    E.rebuild_waits = rebuild_waits
    E.take_waiting_rebuild = take_waiting_rebuild
    E.expire_window = expire_window
    E.close_window_at_zone = close_window_at_zone

    -- The version stamp. The root checks it against Rahvin_GS, so a stale copy of this file
    -- stops the load with an error that names it.
    return '2.2'
end
