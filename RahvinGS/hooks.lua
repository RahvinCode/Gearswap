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
--   precast, midcast and aftercast, buff_change and status_change, and the three pet
--   hooks. Beside them is pretargetcheck, the validation pretarget runs first.
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
--          find out. pretarget_custom, pet_midcast_custom and pet_aftercast_custom may be
--          missing in silence.
--
-- THREE THINGS ARE THREADED THROUGH THESE HOOKS, and none of them is local to one function.
--   * The BUSY WINDOW is armed in precast, sized from the action, and restarted as a short
--     tail in aftercast. Precast and the polling engine both expire a stale one, so a lost
--     aftercast cannot leave the engine stuck.
--   * The HOXNE CRITICAL WINDOW opens in pretarget, opens or refreshes in precast, and gets
--     its real countdown in aftercast. A path that cancels before aftercast sets that
--     countdown itself.
--   * THE MULTIBOX DEBT. pretargetcheck announces a tracked cast to the other characters,
--     which then hold gear and slots for it. A path that cancels an announced cast must
--     call finish_outgoing_cast, or those characters wait out their failsafe in the
--     received gear. pretarget pays it when the job file cancels in pretarget_custom,
--     precast pays it at the busy gate, and aftercast pays it when the cast completes.
--
-- EXPORTS  cast_proper_in_flight, a predicate over the cast-proper flag below and the busy
--          window. The equip component's set_roll_eleven reads it from E at the call. The
--          hooks write four fields the state component declares: SpellCastTime and
--          Spellstart, which make the busy window, and the two prediction flags.
-- LOADS    After every component it calls into, so nothing it uses resolves late.

-- requires: rahvings/state, rahvings/core, rahvings/equip, rahvings/hoxne, rahvings/builders
return function(E)
    -- The exports these hooks use, bound once at construction. The builders, the slot
    -- arbiter, the Hoxne window and the multibox announce all meet here.
    local BUFF_SLEEP, BUFF_STUN, BUFF_KO, BUFF_PETRI, BUFF_CHARM, BUFF_TERROR =
        E.BUFF_SLEEP, E.BUFF_STUN, E.BUFF_KO, E.BUFF_PETRI, E.BUFF_CHARM, E.BUFF_TERROR
    local TYPE_JA, TYPE_WS, TYPE_MS, TYPE_SCH   = E.TYPE_JA, E.TYPE_WS, E.TYPE_MS, E.TYPE_SCH
    local HasRecastTimer, RecastTimers          = E.HasRecastTimer, E.RecastTimers
    local ability_info, spell_info, res, settings = E.ability_info, E.spell_info, E.res, E.settings
    local announce_tracked_cast, debug, get_time  = E.announce_tracked_cast, E.debug, E.get_time
    local apply_weapon_mode, build_current_set    = E.apply_weapon_mode, E.build_current_set
    local reassert_pair                           = E.reassert_pair
    local assert_over_lock, lock_exempts          = E.assert_over_lock, E.lock_exempts
    local keep_weaponskill_weapons                = E.keep_weaponskill_weapons
    local yield_range_to_ammo                     = E.yield_range_to_ammo
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

    ------------------------------------------------------------------------------------------------
    -- SECTION 16 - GEARSWAP ACTION HOOKS
    ------------------------------------------------------------------------------------------------
    -- In the order an action passes through them: validation, then the three cast phases,
    -- then the state-change and pet hooks.

    -- Whether the cast proper is in flight. Precast sets it beside the busy window, and
    -- aftercast clears it first thing, which an interrupted action reaches too. It is not
    -- the busy window, which outlives the action by a tail. A buff that lands inside the
    -- tail must still dress its buff child. buff_change tests both, so a flag left stale by
    -- an action that never reached aftercast heals when the polling engine clears is_Busy.
    -- Pet actions never touch it, because GearSwap routes them to pet_midcast and
    -- pet_aftercast.
    local cast_in_flight = false
    -- The flag's one way out of this file: the same test buff_change makes, as a predicate
    -- for the equip component's set_roll_eleven, which skips its rebuild while it holds. A
    -- function rather than the flag, so only this file writes the flag. The equip component
    -- reads it from E at the call, because that component loads before this one. No build
    -- path calls it, since buff_change reads the flag and is_Busy directly.
    E.cast_proper_in_flight = function() return cast_in_flight and is_Busy end

    -- Refuse an action that would fail, before GearSwap composes its packet. Where the
    -- player would otherwise see only the server's refusal, the refusal names its reason.
    -- Every refusing branch calls cancel_spell and returns. The checks that stop every
    -- action come first, then the checks for each action type.
    --
    -- It also announces a tracked cast to the other characters, in the ability and spell
    -- branches. That announce is why the cancel paths later in the pipeline owe those
    -- characters a completion.
    function pretargetcheck(spell, action)
        if pet.isvalid and pet_midaction() then
            cancel_spell()
            return
        end

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
            -- before it lands. Divine Seal is flagged as it is used, because the prediction
            -- covers the gap before its buff appears.
            if state.SpellReceived.value ~= "OFF" then
                if spell.name == "Divine Seal" then
                    E.divine_seal_predicted = true
                    if settings.debug then debug("Divine Seal detected while tracking. Divine_Seal_Predicted = True") end
                end
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
            -- check_equipment_spells dresses it for this cast. Accession and Divine Seal are
            -- also read from their prediction flags, which cover the gap before the buff is
            -- readable.
            local s_info = spell_info[spell.id]
            if s_info and spell.target.name and state.SpellReceived.value ~= "OFF" then
                local accession_active = active_buffs[366] or active_buffs['Accession']
                local majesty_active = active_buffs[621] or active_buffs['Majesty']
                local divine_veil_active = active_buffs[78] or active_buffs['Divine Seal']
                local has_yagrush = (s_info.divine and wears_yagrush(spell))
                local spreads = (s_info.aoe or ((E.accession_predicted or accession_active) and s_info.accession) or (majesty_active and s_info.majesty) or ((E.divine_seal_predicted or divine_veil_active or has_yagrush) and s_info.divine))
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
            elseif spell.name == "Accession" then
                E.accession_predicted = true
                if settings.debug then debug("Accession detected while tracking. Accession_Predicted = True") end
            end
        end
    end

    -- The first hook GearSwap calls. Runs the validation above, opens the Hoxne critical
    -- window, then hands to the job file.
    --
    -- The window opens after the engine's guards and before the job file's
    -- pretarget_custom. Instrument or ammunition handling in the job file's hook, and in
    -- every later phase, then passes through an open window instead of fighting the hold.
    function pretarget(spell, action)
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
        -- same test for the same reason.
        if is_Busy and os.clock() - E.Spellstart > E.SpellCastTime then
            is_Busy = false
            E.SpellCastTime = 0
            release_implement()
        end
        if not is_Busy then
            -- Size the busy window from the action. A spell's window is 20% of its listed
            -- cast time, which assumes 80% fast cast, plus a 2.5 second margin. Anything
            -- else gets about a second. The estimate only has to outlast the action, because
            -- aftercast replaces it with a short tail. Too long costs little, and too short
            -- lets a rebuild pull cast gear off mid-cast.
            if RecastTimers[spell.type] then
                local cast_spell = res.spells[spell.id]
                E.SpellCastTime = cast_spell.cast_time * .2 + 2.5
                -- Chainspell and Nightingale finish a cast in about a second whatever its
                -- listed time, so the estimate above would hold the window far too long.
                if buffactive["Chainspell"] or buffactive["Nightingale"] then
                    E.SpellCastTime = 1
                end
            elseif spell.action_type == 'Ranged Attack' then
                E.SpellCastTime = 1.1
            else
                E.SpellCastTime = 1
            end
            E.Spellstart = os.clock()
            is_Busy = true
            cast_in_flight = true
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
        -- For a spell, ammo in this build strips a handbell or instrument worn in range.
        -- The range slot is cleared in this build, so GearSwap's model of worn gear sees
        -- that strip and the midcast's bell or instrument is sent.
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
        -- The implement then holds its slots for the cast. No layer below it can move them
        -- until aftercast lets them go.
        if equipment_spell_set then hold_implement(equipment_spell_set) end
    end

    -- Runs while the action is in flight, and wears the potency, accuracy and recast gear.
    -- The same shape as precast, without the window and busy handling, which precast has
    -- already settled.
    function midcast(spell)
        local built_set = midcastequip(spell) or {}
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
    end

    -- Runs when the action completes or is interrupted. Returns the character to idle or
    -- engaged gear, restarts the busy window as a short tail, and starts the critical
    -- window's real countdown.
    function aftercast(spell)
        -- The cast proper is over, whatever became of it. GearSwap routes an interrupted
        -- action here too, so this one line covers both endings. It is the first line, so a
        -- raise below, such as one in the job file's aftercast_custom, still leaves the flag
        -- down.
        cast_in_flight = false
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
        -- lock, the mode's weapon goes back on here, before the build below.
        release_implement()
        local built_set = aftercastequip(spell) or {}
        merge_report_flush('aftercast', spell)
        if aftercast_custom then
            merge_into(built_set, aftercast_custom(spell))
        else
            warn('aftercast_custom() not found!')
        end
        equip(built_set)
        -- A short busy tail is left standing rather than cleared, because the server
        -- enforces its own delay after an action and a rebuild inside it achieves nothing.
        -- Spells keep the longest tail, ranged attacks a shorter one, and other actions none.
        if RecastTimers[spell.type] then
            E.SpellCastTime = 2.5
        elseif spell.action_type == 'Ranged Attack' then
            E.SpellCastTime = 1.1
        else
            E.SpellCastTime = 0
        end
        E.Spellstart = os.clock()

        -- Replace the twenty-second watchdog with the real countdown, now that the action
        -- has finished. The two cancel paths above set the same deadline themselves,
        -- because a canceled action never arrives here.
        local crit = hoxne.window and critical_action_for(spell) or nil
        if crit then
            hoxne.expires = hoxne_resume_deadline(crit)
        end
    end

    -- Runs on any buff gained or lost, and re-dresses the character for the new state, such
    -- as Aftermath appearing, Sublimation charging, or a food effect ending.
    --
    -- It is skipped while the cast proper is in flight, so a buff landing mid-cast does not
    -- pull the character out of cast gear. The busy window alone is not the gate. It
    -- outlives the action by a tail, and a self-cast spell's buff arrives inside that tail
    -- and must still dress its buff child. Testing both also heals a stale flag, because
    -- the polling engine clears is_Busy on its deadline. When the gate passes, the build is
    -- always made. The equip is skipped only when build_is_worn proves every slot already
    -- worn by GearSwap's own test, the one case in which the equip would send nothing.
    function buff_change(name, gain)
        if not (cast_in_flight and is_Busy) then
            local built_set = build_current_set()
            if buff_change_custom then
                merge_into(built_set, buff_change_custom(name, gain))
            else
                warn('buff_change_custom(name,gain) not found!')
            end
            if build_is_worn(built_set) then return end
            equip(built_set)
        end
    end

    -- Runs when the player's status changes: engaged, idle, resting or dead. It is not gated
    -- on the busy window, because a status change must re-dress the character even
    -- mid-action.
    function status_change(new, old)
        local built_set = build_current_set()
        if status_change_custom then
            merge_into(built_set, status_change_custom(new, old))
        else
            warn('status_change_custom(new,old) not found!')
        end
        equip(built_set)
    end

    -- Runs when a pet is summoned or dismissed, so the idle build can pick up or drop its
    -- pet layer.
    function pet_change(pet, gain)
        local built_set = build_current_set()
        if pet_change_custom then
            merge_into(built_set, pet_change_custom(pet, gain))
        else
            warn('pet_change_custom() not found!')
        end
        equip(built_set)
    end

    -- Runs while a pet's own action is in flight, such as a wyvern breath, a blood pact or a
    -- jug pet's ready move. It reports its set the way a cast does, so pet actions appear in
    -- the same info and gear-report lines.
    --
    -- The base set is merged into a fresh table rather than used directly. Merging into
    -- sets.Pet_Midcast itself would write the action's gear permanently into the job file's
    -- general set.
    function pet_midcast(spell)
        ensure_placeholders()
        merge_report_begin()
        if sets.Pet_Midcast then
            local built_set = {}
            -- The branch starts at the mark with no base layers beneath it, because
            -- sets.Pet_Midcast is itself the set the report should name when it falls back.
            merge_report_mark()
            merge_report(built_set, sets.Pet_Midcast)
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
            -- master's weapons still apply during a pet action. Unlocked, a pet action
            -- leaves the master's weapons alone.
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
        else
            warn('sets.Pet_Midcast not found!')
        end
    end

    -- Runs when a pet action completes, returning the master to whatever their own state
    -- calls for. No busy window is involved: the pet acted, not the player.
    function pet_aftercast(spell)
        local built_set = build_current_set()
        if pet_aftercast_custom then
            merge_into(built_set, pet_aftercast_custom(spell))
        end
        equip(built_set)
    end

    -- The version stamp. The root checks it against Rahvin_GS, so a stale copy of this file
    -- stops the load with an error that names it.
    return '2.1'
end
