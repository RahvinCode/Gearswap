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
--   Section 16 - The ten functions GearSwap calls as an action moves through it:
--   pretargetcheck and pretarget, precast, midcast, aftercast, buff_change,
--   status_change, and the three pet hooks.
--
-- THE TEN ARE GLOBALS THAT NOTHING IN THE ENGINE CALLS. GearSwap resolves these names
--          itself out of the job file's environment, so no other engine file calls one and
--          the root registers none of them -- grepping for callers finds nothing, which is
--          expected rather than a sign the file is dead. One qualification: pretarget calls
--          pretargetcheck directly, here in this file.
--
-- THE SHAPE IS THE SAME EVERY TIME: ask the builders for the engine's set, flush the merge
--          report, merge whatever the job file's matching _custom hook returns, then equip.
--          Six of them warn once per action when their _custom counterpart is missing --
--          precast, midcast, aftercast, buff change, status change and pet change -- because
--          a job file that meant to define one has no other way to find out.
--          pretarget_custom, pet_midcast_custom and pet_aftercast_custom pass silently when
--          they are missing.
--
-- THREE THINGS ARE THREADED THROUGH THESE HOOKS and none of them is local to one function:
--   * The BUSY WINDOW is armed in precast, sized from the action, and reset in aftercast.
--     Both places also expire a stale one, so a lost aftercast cannot wedge the engine.
--   * The HOXNE CRITICAL WINDOW opens in pretarget, is re-opened or refreshed in precast for
--     actions that skip pretarget, and gets its real countdown in aftercast.
--   * THE MULTIBOX DEBT. pretargetcheck announces a cast to the other characters, which then
--     hold gear and slots for it. Every path that cancels afterwards MUST call
--     finish_outgoing_cast, or those characters wait out their failsafe in cure gear. There
--     are three such paths -- a job file canceling in pretarget_custom, the busy gate in
--     precast, and the ordinary completion in aftercast.
--
-- EXPORTS  Nothing of its own. It WRITES four fields the state component declares:
--          SpellCastTime and Spellstart (the busy window), and the two prediction flags the
--          gear builders read.
-- LOADS    Eighth of fifteen, after every component it calls into. Nothing resolves late.

-- requires: rahvings/state, rahvings/core, rahvings/equip, rahvings/hoxne, rahvings/builders
return function(E)
    -- Immutable dependencies bound once at construction. This is the widest import block in
    -- the engine: these hooks are where the builders, the slot arbiter, the Hoxne window and
    -- the multibox announce all meet.
    local BUFF_SLEEP, BUFF_STUN, BUFF_KO, BUFF_PETRI, BUFF_CHARM, BUFF_TERROR =
        E.BUFF_SLEEP, E.BUFF_STUN, E.BUFF_KO, E.BUFF_PETRI, E.BUFF_CHARM, E.BUFF_TERROR
    local TYPE_JA, TYPE_WS, TYPE_MS, TYPE_SCH   = E.TYPE_JA, E.TYPE_WS, E.TYPE_MS, E.TYPE_SCH
    local HasRecastTimer, RecastTimers          = E.HasRecastTimer, E.RecastTimers
    local ability_info, spell_info, res, settings = E.ability_info, E.spell_info, E.res, E.settings
    local announce_tracked_cast, debug, get_time  = E.announce_tracked_cast, E.debug, E.get_time
    local apply_weapon_mode, build_current_set    = E.apply_weapon_mode, E.build_current_set
    local assert_over_lock, lock_exempts          = E.assert_over_lock, E.lock_exempts
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

    ------------------------------------------------------------------------------------------------
    -- SECTION 16 - GEARSWAP ACTION HOOKS
    ------------------------------------------------------------------------------------------------
    -- In the order an action passes through them: validation, then the three cast phases,
    -- then the state-change and pet hooks.

    -- Refuse an action that would fail, before GearSwap composes its packet, and say why.
    --
    -- This is what turns a silent server rejection into an explanation. Every branch that
    -- refuses calls cancel_spell and returns; the checks are ordered so the ones that stop
    -- everything come first, then the per-action-type ones.
    --
    -- It also does one thing that is not validation at all: it ANNOUNCES a tracked cast to
    -- the other characters, in the ability and spell branches. That announce is why the
    -- cancel paths further down the pipeline owe those characters a completion.
    function pretargetcheck(spell, action)
        if pet.isvalid and pet_midaction() then
            cancel_spell()
            return
        end

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

        -- From here the checks are per action type, and each type has its own recast units:
        -- ability recasts are SECONDS and spell recasts are FRAMES, which is why the two
        -- branches below divide differently before formatting the same way.
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

            -- Abilities Handling
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
            -- before it lands. Divine Seal is flagged as it is used rather than when its
            -- buff appears, because the prediction has to cover exactly the gap between
            -- the two.
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

            -- The same announce for spells, plus the question of WHO it will reach. A spell
            -- is treated as spreading if it is inherently area-of-effect, or if one of the
            -- three widening effects is up: Accession, Majesty, or Divine Seal -- the last
            -- of which Yagrush also provides, when the implement tier dresses it for this
            -- cast. Each buff is tested against both its live buff and its prediction flag,
            -- so the gap before the buff becomes readable is covered.
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
                -- A nil wait means nothing is pending, which HERE means the character has
                -- no stratagems at all rather than none to spare -- so the refusal says
                -- that instead of naming a countdown that will never arrive.
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
    -- The window is opened BETWEEN the engine's guards and the job file's, and that position
    -- is deliberate: instrument or ammunition handling written in either one then flows
    -- through an already-open window instead of fighting the hold.
    function pretarget(spell, action)
        --Calls the function in the include file for basic checks
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
                    hoxne.expires = os.clock() + 20 -- watchdog only; aftercast sets the real countdown
                    -- Two kinds of action need gear at this instant. A gear-gated song
                    -- cannot even be cast without its named implement, and Tomahawk and
                    -- Angon need their throwing item. Ordinary songs and Geomancy need
                    -- nothing here -- their instruments arrive with the normal sets.
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

        --Calls the job specific function
        if pretarget_custom then pretarget_custom(spell, action) end

        -- The job file canceled, after pretargetcheck may already have announced. The other
        -- characters are holding gear and locked slots for a cast that is not coming, so
        -- they are told rather than left to time out on their failsafe.
        if _global.cancel_spell then finish_outgoing_cast() end

        -- The same cancel, from the window's point of view. It is collapsed SOON rather than
        -- immediately: two seconds covers the common cancel-equip-reissue pattern, where the
        -- re-issued command re-opens the window before the tick would have re-locked, and
        -- the player never sees the Ampulla flicker back in.
        if hoxne_opened and _global.cancel_spell then
            hoxne.expires = os.clock() + 2
            log('Hoxne: pretarget_custom canceled [', spell.english, ']; window closing in 2s')
        end
    end

    -- Runs after the packet is composed but before it is sent, which is the last moment gear
    -- can still reach the action. Arms the busy window, and is where the fast-cast and
    -- ability-opener sets are worn.
    function precast(spell)
        -- The ON-Locked refusal sits ABOVE the busy gate so it is answered even when the
        -- engine is mid-action -- otherwise a gated ability pressed during a cast would be
        -- refused for the wrong reason.
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
            -- Size the busy window from the action. A spell's window is its listed cast time
            -- taken at 20% -- an assumed 80% fast cast -- plus a margin; anything else is
            -- roughly a second. The window only has to outlast the action, so an
            -- over-estimate costs nothing and an under-estimate rebuilds gear mid-cast.
            if RecastTimers[spell.type] then
                local cast_spell = res.spells[spell.id]
                E.SpellCastTime = cast_spell.cast_time * .2 + 2.5
                -- Both of these finish a cast in about a second regardless of its listed
                -- time, so the estimate above would hold the window far too long.
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
        else
            log('Player is Busy [', spell.english, ']')
            -- The busy gate, and the second place the multibox debt is paid. pretargetcheck
            -- may already have announced this cast, so the other characters are holding gear
            -- and locked slots for it right now -- they are told rather than left waiting.
            finish_outgoing_cast()
            cancel_spell()
            -- A canceled cast NEVER REACHES AFTERCAST, so the critical window has to be
            -- closed from here, using the same deadline aftercast would have set. Without
            -- this the window stays open on its twenty-second watchdog instead. A gated
            -- ability gets the same half second here that it gets at aftercast: its
            -- throwing item comes off on the next tick, and a retry equips it again.
            local crit = hoxne.window and critical_action_for(spell) or nil
            if crit then hoxne.expires = hoxne_resume_deadline(crit) end
            return
        end
        -- The same window opened again, for actions that never reached pretarget at all --
        -- a cast started from the game's own menu is the common case. Without this the equip
        -- wrapper would strip the instrument from every menu-cast song.
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
        -- Gear the engine owns for the action -- a named instrument, the Impact cloak,
        -- Yagrush for a White Mage's Cursna -- which outranks anything the sets chose. A
        -- slot a layer above the implements holds is named with its holder here, once per
        -- cast, so the piece the tier stood down from is explained.
        local equipment_spell_set, refused = check_equipment_spells(spell)
        report_refused(spell.english, refused)
        if equipment_spell_set then merge_into(built_set, equipment_spell_set) end
        -- The floor under a job file that declares no set for a gated ability. Applied
        -- LAST, after every merge, so a file that dressed the slot itself keeps its choice
        -- and only a slot nobody filled gets the forced item.
        local force_slot, force_item = critical_force_slot(built_set, spell)
        if force_slot then built_set[force_slot] = force_item end
        equip(built_set)
        -- The implements outrank the weapon lock: a slot the lock holds is dressed from
        -- them on top of the equip above, so the lock's hold never keeps Daybreak off
        -- Dispelga. An action the lock exempts -- a friendly song under Songs -- has its
        -- whole build dressed over the held slots the same way, song weapons and all; the
        -- end of the cast puts the mode's weapons back.
        if lock_exempts(spell) then
            assert_over_lock(built_set)
        elseif equipment_spell_set then
            assert_over_lock(equipment_spell_set)
        end
        -- The implement then holds its slot for the cast: nothing below an item use, the
        -- Hoxne hold and the Sleep hold moves it until the aftercast lets it go.
        if equipment_spell_set then hold_implement(equipment_spell_set) end
    end

    -- Runs while the action is in flight, and is where potency, accuracy and recast gear is
    -- worn. Same three-step shape as precast, without the window and busy handling -- those
    -- are already settled by the time this runs.
    function midcast(spell)
        local built_set = midcastequip(spell) or {}
        merge_report_flush('midcast', spell)
        if midcast_custom then
            merge_into(built_set, midcast_custom(spell))
        else
            warn('midcast_custom() not found!')
        end
        -- Asked again here, not only at precast: Treasure Hunter gear in particular belongs
        -- at midcast for a spell, because that is when the tag actually lands.
        local equipment_spell_set = check_equipment_spells(spell)
        if equipment_spell_set then merge_into(built_set, equipment_spell_set) end
        equip(built_set)
        if lock_exempts(spell) then
            assert_over_lock(built_set)
        elseif equipment_spell_set then
            assert_over_lock(equipment_spell_set)
        end
    end

    -- Runs when the action completes or is interrupted. Returns the character to idle or
    -- engaged gear, resets the busy window, and starts the critical window's real countdown.
    function aftercast(spell)
        -- The third and ordinary place the multibox debt is paid: the cast finished, so the
        -- other characters are told they may release the gear they were holding.
        if state.SpellReceived.value ~= 'OFF' and E.outgoing_cast_active then
            if settings.debug then
                debug(string.format("IPC message sent: RAHVIN|COMPLETE|%s|%.0f", player.name,
                    get_time()))
            end
            finish_outgoing_cast()
        end
        -- The cast is over, so its implement lets go of its slot first: under the weapon
        -- lock the mode's weapon goes back on here, explicitly, before the build below.
        release_implement()
        local built_set = aftercastequip(spell) or {}
        merge_report_flush('aftercast', spell)
        if aftercast_custom then
            merge_into(built_set, aftercast_custom(spell))
        else
            warn('aftercast_custom() not found!')
        end
        equip(built_set)
        -- A short busy window is left standing rather than cleared outright, because the
        -- server enforces its own delay after an action and rebuilding gear inside it
        -- achieves nothing. Spells carry the longest of these; abilities almost none.
        if RecastTimers[spell.type] then
            E.SpellCastTime = 2.5
        elseif spell.action_type == 'Ranged Attack' then
            E.SpellCastTime = 1.1
        else
            E.SpellCastTime = 0
        end
        E.Spellstart = os.clock()

        -- Replace the twenty-second watchdog with the real countdown now that the action is
        -- known to have finished. This is the normal path; the two cancel paths above set
        -- the same deadline themselves precisely because they never arrive here.
        local crit = hoxne.window and critical_action_for(spell) or nil
        if crit then
            hoxne.expires = hoxne_resume_deadline(crit)
        end
    end

    -- Runs on any buff gained or lost, and re-dresses the character for the new state --
    -- Aftermath appearing, a Sublimation charge, a food effect ending.
    --
    -- Gated on not being busy, which is the whole reason a buff landing mid-cast does not
    -- rebuild the character out of their cast gear.
    function buff_change(name, gain)
        if not is_Busy then
            local built_set = build_current_set()
            if buff_change_custom then
                merge_into(built_set, buff_change_custom(name, gain))
            else
                warn('buff_change_custom(name,gain) not found!')
            end
            equip(built_set)
        end
    end

    -- Runs when the player's status changes -- engaged, idle, resting, dead. Deliberately
    -- NOT gated on busy: a status change is exactly the kind of event that must re-dress the
    -- character even mid-action.
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

    -- Runs while a pet's own action is in flight -- a wyvern breath, a blood pact, a jug
    -- pet's ready move. Reports its set the way a cast does, so pet actions appear in the
    -- same running commentary.
    --
    -- The base set is merged into a FRESH table rather than used directly. Aliasing
    -- sets.Pet_Midcast here and merging into it would write the specific action's gear
    -- permanently into the job file's own general set.
    function pet_midcast(spell)
        ensure_placeholders()
        merge_report_begin()
        if sets.Pet_Midcast then
            local built_set = {}
            -- The branch starts at the mark with no base layers beneath it, because
            -- sets.Pet_Midcast is itself the set the report should name when it falls back.
            merge_report_mark()
            merge_report(built_set, sets.Pet_Midcast)
            -- Specific sets are defined
            if sets.Pet_Midcast[spell.english] then
                merge_named(built_set, sets.Pet_Midcast, 'sets.Pet_Midcast', spell.english)
            end
            merge_report_branch_end()
            -- User level commands
            if pet_midcast_custom then
                merge_into(built_set, pet_midcast_custom(spell))
            end
            -- The master's own weapons still apply during a pet action, so the weapon mode
            -- is layered on -- under the weapon lock; unlocked, a pet action leaves the
            -- master's weapons alone.
            if E.lock_main_sub then
                -- Quietly, and without a shield when the mode named no set of its own: a
                -- pet action is not the place to report a missing weapon set, and the
                -- master's offhand should not change because their pet acted.
                apply_weapon_mode(built_set, false, true, true)
                log('Midcast set equiping Offense Mode Gear')
            end
            merge_report_flush('midcast', spell)
            equip(built_set)
        else
            warn('sets.Pet_Midcast not found!')
        end
    end

    -- Runs when a pet action completes, returning the master to whatever their own state
    -- calls for. No busy window is involved: the pet acted, not the player.
    function pet_aftercast(spell)
        local built_set = choose_set()
        if pet_aftercast_custom then
            merge_into(built_set, pet_aftercast_custom(spell))
        end
        equip(built_set)
    end

    -- Version stamp. The root asserts this against Rahvin_GS, so a stale copy of this file
    -- announces itself at load instead of running.
    return '2.0'
end
