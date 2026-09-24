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
-- COMPONENT: builders -- section 15: the gear set builders
----------------------------------------------------------------------------------------------------
-- CONTENTS
--   Section 15 - Turning the job file's declared sets into one table of gear, in five parts:
--     Shared merges ....... the Aftermath ladder, the weapon mode, the set families
--     The four builders ... choose_set, precastequip, midcastequip, aftercastequip
--     Conditional gear .... the element, day and weather bonus pieces
--     Bard songs .......... weapons, instruments, and the song-family ladder
--     Consumable checks ... ammunition and ninja tools, which can cancel the action
--
-- This is where the job file becomes gear. The builders hold one branch per kind of
-- action, and each branch merges a set the job file declared and names it to the merge
-- report.
--
-- Nothing here equips. Every builder returns a table and its caller equips it, so a build
-- can be reported, inspected or discarded without anything being worn.
--
-- interface.lua declares every set path and classification list this file reads without a
-- test. A set the job file never wrote is then an empty placeholder that merges nothing,
-- never a nil that throws. A path read here needs its placeholder there, or a test before
-- it is read.
--
-- The merge report is recorded here and printed elsewhere. Each builder opens it with
-- merge_report_begin and marks where its branch starts and ends. merge_report_flush, which
-- the hooks call after each build, turns that record into the line the player reads. A
-- merge made with merge_into rather than merge_report or merge_named is not recorded, so
-- that line does not name it.
--
-- EXPORTS  build_current_set, which hooks, commands, spellreceived and th take, and
--          apply_weapon_mode, reassert_pair and wears_yagrush, which hooks take. It also
--          writes the two prediction flags, accession_predicted and divine_seal_predicted,
--          which the state component declares and hooks and spellreceived also touch.
-- GLOBALS  choose_set, precastequip, midcastequip, aftercastequip and
--          check_equipment_spells, which the action hooks call. elemental_check,
--          build_song_weapons, build_song_set, equip_song_gear, equip_pianissimo_gear,
--          do_bullet_checks and do_Utsu_checks are called only from this file. They are
--          globals so the builders above them can call them, since a global resolves when
--          it is called.
-- LOADS    After the enchanted item engine, whose verify_locked_slots it binds. It calls no
--          global from a file that loads after it.

-- requires: rahvings/state, rahvings/core, rahvings/equip, rahvings/enchant
return function(E)
    -- The exports this file uses, bound once at construction.
    local PLACEHOLDER_NAME, PRECAST_FINAL, Storms, UtsusemiSpell = E.PLACEHOLDER_NAME, E.PRECAST_FINAL, E.Storms,
        E.UtsusemiSpell
    local ability_info, spell_info, res, settings, th_info       = E.ability_info, E.spell_info, E.res, E.settings,
        E.th_info
    local action_tag, apply_buff_children                        = E.action_tag, E.apply_buff_children
    local announce_tracked_cast, debug, ensure_placeholders      = E.announce_tracked_cast, E.debug,
        E.ensure_placeholders
    local have_item, have_item_count                             = E.have_item, E.have_item_count
    local merge_into, merge_named, merge_report                  = E.merge_into, E.merge_named, E.merge_report
    local merge_report_begin, merge_report_branch_end            = E.merge_report_begin, E.merge_report_branch_end
    local merge_report_mark, mr_am, outgoing_cast_busy           = E.merge_report_mark, E.mr_am, E.outgoing_cast_busy
    local set_has_gear, verify_locked_slots                      = E.set_has_gear, E.verify_locked_slots
    local blank_instrument                                       = E.blank_instrument
    local lock_exempts, slot_claim                               = E.lock_exempts, E.slot_claim
    local ELEMENT_ID, BEATS, SASH_PCT, IRIDESCENCE, WEATHER_PCT  = E.ELEMENT_ID, E.BEATS, E.SASH_PCT,
        E.IRIDESCENCE, E.WEATHER_PCT
    local LIGHT_ID, NONE_ID, ELEMENTAL_MAGIC_SKILL, SASH         = E.LIGHT_ID, E.NONE_ID,
        E.ELEMENTAL_MAGIC_SKILL, E.SASH
    local elemental_choose                                       = E.elemental_choose

    -- Put an instrument in the range slot, unless the entry is blank. A bard file that omits
    -- one of section 2's Instrument keys reads the engine's empty placeholder, and an empty
    -- table is truthy. Merged, it would displace the song family set's range and reach
    -- GearSwap with no name to equip. The merge is not recorded, so the report does not name
    -- it. Declared above build_song_set, its only caller, because a local declared below its
    -- caller is a nil global there.
    local function merge_instrument(built_set, instrument, name)
        if blank_instrument(instrument, name) then return end
        merge_into(built_set, { range = instrument })
    end

    -- Rounds left of the ammunition the last build chose, recounted on every bullet check
    -- and read afterwards by the lines that report a shot.
    local available_bullets = 0

    -- Whether this cast wears Yagrush, asked of check_equipment_spells as the hooks ask it,
    -- so the spread prediction and the equip cannot disagree. Declared above precastequip,
    -- which reads it for its announce. The pretarget announce in hooks.lua reads it
    -- through E.
    local function wears_yagrush(spell)
        local implement = check_equipment_spells(spell)
        return implement ~= nil and implement.main == 'Yagrush'
    end
    ------------------------------------------------------------------------------------------------
    -- SECTION 15 - GEAR SET BUILDERS
    ------------------------------------------------------------------------------------------------
    -- Assemble the equipment for one moment. Each builder returns a table for its caller to
    -- equip, and none equips anything itself.

    -- Shared merges ------------------------------------------------------------------------------

    -- Merge the strongest Aftermath tier that is both active and declared under the given
    -- root, for the current weapon mode. Returns that tier's row, whose two labels the caller
    -- reports with, or nil when no tier applies.
    local apply_aftermath
    -- The tier table is scoped to this block, so only apply_aftermath reads it.
    do
        -- Strongest tier first, so the loop stops at the first match. Each row names the buff,
        -- the set key, and the label for the weaponskill line and for the ranged line.
        local AFTERMATH_TIER = {
            { buff = 'Aftermath: Lv.3', key = 'AM3', ws_label = 'Level 3 Aftermath', ra_label = 'Aftermath 3' },
            { buff = 'Aftermath: Lv.2', key = 'AM2', ws_label = 'Level 2 Aftermath', ra_label = 'Aftermath 2' },
            { buff = 'Aftermath: Lv.1', key = 'AM1', ws_label = 'Level 1 Aftermath', ra_label = 'Aftermath 1' },
            { buff = 'Aftermath',       key = 'AM',  ws_label = 'Aftermath',         ra_label = 'Aftermath' },
        }
        apply_aftermath = function(built_set, root)
            if not root then return nil end
            local mode = state.WeaponMode.value
            for i = 1, #AFTERMATH_TIER do
                local tier = AFTERMATH_TIER[i]
                local set = root[tier.key]
                if buffactive[tier.buff] and set then
                    -- The tier set dresses every weapon, and a weapon-mode child under it
                    -- refines that for one weapon. An engine placeholder counts as absent
                    -- and is not merged. The tier is returned when its set carries gear or a
                    -- child exists, never for an empty pair. mr_am brackets these merges so
                    -- the report can name the tier apart from the branch.
                    local child, dressed = set[mode], false
                    mr_am.from = E.mr_count + 1
                    if PLACEHOLDER_NAME[set] == nil then
                        merge_report(built_set, set)
                        dressed = set_has_gear(set)
                    end
                    if child then
                        merge_report(built_set, child)
                        dressed = true
                    end
                    mr_am.to = E.mr_count
                    if dressed then return tier end
                end
            end
            return nil
        end
    end

    -- Record the weapons this build resolved, in E.lock_pair, for the weapon lock to hold.
    -- Each slot is written only when the mode's set or the offhand set names it, so a slot
    -- the mode leaves unnamed keeps what the lock found worn. The offhand's sub wins over
    -- the mode set's, as it does in the merge. When the pair changes, E.lock_pair_changed is
    -- called if set. The equip component sets it to the weapon lock's take, so the held
    -- slots move with the pair.
    local function record_locked_weapons(mode_set, offhand)
        local pair = E.lock_pair
        local main, sub, range = pair.main, pair.sub, pair.range
        if mode_set then
            if mode_set.main ~= nil then main = mode_set.main end
            if mode_set.sub ~= nil then sub = mode_set.sub end
            if mode_set.range ~= nil then range = mode_set.range end
        end
        if offhand and offhand.sub ~= nil then sub = offhand.sub end
        if main ~= pair.main or sub ~= pair.sub or range ~= pair.range then
            pair.main, pair.sub, pair.range = main, sub, range
            if E.lock_pair_changed then E.lock_pair_changed() end
        end
    end

    -- Write the locked pair over a build. Under the weapon lock, main's slot is disabled but
    -- sub's stays open, so sub is held only by this re-assert. Main is written too, so the
    -- built set matches what is worn. Without it, any set naming sub could move it: a grip
    -- beside a two-hander, a shield the mode left unnamed, the song weapons' offhand, or a
    -- pet or movement overlay. Each builder calls this last, after every merge it makes, and
    -- so does the pet midcast hook. An action the lock exempts skips it. A job-file hook that
    -- merges after the build can still move the pair for its one action.
    local function reassert_pair(built_set)
        local pair = E.lock_pair
        if pair.main ~= nil then built_set.main = pair.main end
        if pair.sub ~= nil then built_set.sub = pair.sub end
    end

    -- Merge the weapons the current weapon mode calls for, and the offhand that goes with
    -- them. Under the weapon lock it also records the pair it resolved, which the builder
    -- writes back as its last line.
    --
    -- dual_wield_set offers sets.DualWield. shield_needs_mode_set withholds the shield when
    -- the mode has no set of its own. quiet suppresses every "not found" warning. hooks.lua
    -- calls it quietly to put the master's weapons on a pet midcast.
    local function apply_weapon_mode(built_set, dual_wield_set, shield_needs_mode_set, quiet)
        if not sets.Weapons then
            if not quiet then warn('sets.Weapons not found!') end
            return
        end
        local mode_set = sets.Weapons[state.WeaponMode.value]
        local offhand
        if mode_set then
            merge_report(built_set, mode_set)
        else
            -- The legacy weapon modes, 'Unlocked' and 'Locked', have no set of their own. The
            -- lock holds what is worn, and E.lock_legacy keeps this warning quiet for them.
            if not quiet and not E.lock_legacy then
                warn('sets.Weapons.' .. state.WeaponMode.value .. ' not found!')
            end
            if shield_needs_mode_set then
                if E.lock_main_sub then
                    record_locked_weapons(nil, nil)
                end
                return
            end
        end
        -- No offhand until both weapon traits are known. Each is nil from load until the
        -- startup pass reads it, and the rebuild after that pass dresses the offhand.
        if E.TwoHand ~= nil and E.DualWield ~= nil then
            if not E.TwoHand and not E.DualWield then
                if sets.Weapons.Shield then
                    offhand = sets.Weapons.Shield
                    merge_report(built_set, offhand)
                elseif not quiet then
                    warn('sets.Weapons.Shield not found!')
                end
            elseif dual_wield_set and E.DualWield then
                if sets.DualWield then
                    offhand = sets.DualWield
                    merge_report(built_set, offhand)
                elseif not quiet then
                    warn('sets.DualWield not found!')
                end
            end
        end
        if E.lock_main_sub then
            record_locked_weapons(mode_set, offhand)
        end
    end

    -- The precast action types whose gear is a family set plus an optional child named for
    -- the action, and the root each one reads. Several types share a root. The three
    -- Flourish types all read sets.Flourish, and Scholar, Ward, Rune and Effusion all read
    -- sets.JA. Every root named here needs its placeholder in interface.lua.
    local PRECAST_SET_FAMILY = {
        Scholar     = 'JA',
        Ward        = 'JA',
        Rune        = 'JA',
        Effusion    = 'JA',
        CorsairRoll = 'PhantomRoll',
        CorsairShot = 'QuickDraw',
        Waltz       = 'Waltz',
        Jig         = 'Jig',
        Samba       = 'Samba',
        Step        = 'Step',
        Flourish1   = 'Flourish',
        Flourish2   = 'Flourish',
        Flourish3   = 'Flourish',
    }

    -- Merge a family set and, where the job file declared one, the child named for this
    -- action. The root is looked up by name at each call, so a job file that replaces the
    -- whole parent table still resolves.
    local function apply_set_family(built_set, root_name, spell)
        local root = sets[root_name]
        if not root then
            warn('sets.' .. root_name .. ' not found!')
            return
        end
        merge_report(built_set, root)
        if root[spell.english] then
            merge_report(built_set, root[spell.english])
        end
    end

    -- The four builders ---------------------------------------------------------------------------

    -- Build what the character should wear while doing nothing in particular: the engaged
    -- and idle builder. It runs more often than any other builder, on every buff, status and
    -- pet change, on a movement change and on every gs c update auto, so it must stay cheap.
    -- It prints only a warn for a set the job file lacks, and a debug line.
    function choose_set()
        merge_report_begin()
        -- Above the Sleep return, so a held slot that something took is reclaimed even while
        -- asleep.
        verify_locked_slots()
        -- Asleep, the build is empty rather than idle gear, so the character keeps what it
        -- wore when it fell asleep. The update auto handler in commands.lua does not warn
        -- about this one empty build.
        if buffactive['Sleep'] then return {} end
        local built_set = {}
        if player.status == "Engaged" then
            if sets.OffenseMode then
                merge_report(built_set, sets.OffenseMode)
                merge_report_mark()
                if sets.OffenseMode[state.OffenseMode.value] then
                    merge_named(built_set, sets.OffenseMode, 'sets.OffenseMode', state.OffenseMode.value)
                    merge_report_branch_end()
                    -- Only the engaged build offers sets.DualWield.
                    apply_weapon_mode(built_set, true, false, false)
                    -- Under the Ranged job mode, the engaged build also takes the idle set's
                    -- offense-mode child.
                    if state.JobMode.value == "Ranged" then
                        log('Ranged Mode')
                        if sets.Idle and sets.Idle[state.OffenseMode.value] then
                            merge_named(built_set, sets.Idle, 'sets.Idle', state.OffenseMode.value)
                        else
                            warn('sets.Idle.' .. state.OffenseMode.value .. ' not found!')
                        end
                    end
                    apply_aftermath(built_set, sets.OffenseMode)
                    -- The buff children of sets.OffenseMode and of the mode child. They merge
                    -- after the weapon mode and the Aftermath tier, and before Treasure
                    -- Hunter, the ammunition and the pair. They sit inside the mode test, so
                    -- a mode with no set skips them along with the weapon mode, the tier and
                    -- Treasure Hunter.
                    apply_buff_children(built_set, sets.OffenseMode, 'sets.OffenseMode')
                    -- Treasure Hunter gear goes on while engaged in three cases. An untagged
                    -- target always gets it, whatever the mode, since the next swing applies
                    -- the tag. Otherwise it takes Full Time, or SATA with Sneak Attack, Trick
                    -- Attack or Feint up.
                    if state.TreasureMode.value ~= 'None' then
                        if sets.TreasureHunter then
                            if not th_info.tagged_mobs[player.target.id] then
                                merge_report(built_set, sets.TreasureHunter)
                            elseif state.TreasureMode.value == 'Full Time' then
                                merge_report(built_set, sets.TreasureHunter)
                            elseif state.TreasureMode.value == 'SATA' and (buffactive['Sneak Attack'] or buffactive['Trick Attack'] or buffactive['Feint']) then
                                merge_report(built_set, sets.TreasureHunter)
                            end
                        else
                            warn('sets.TreasureHunter not found!')
                        end
                    end
                else
                    warn('sets.OffenseMode.' .. state.OffenseMode.value .. ' not found!')
                end
            else
                warn('sets.OffenseMode not found!')
            end
            -- Not engaged. The idle base and its offense-mode child, with the Resting set
            -- while resting, then the weapon mode and the overlays that may all apply at
            -- once: a pet, Sublimation and movement. A later merge overwrites an earlier
            -- one, so movement wins over the pet and Sublimation sets.
        else
            if sets.Idle then
                merge_report(built_set, sets.Idle)
                merge_report_mark()

                merge_named(built_set, sets.Idle, 'sets.Idle', state.OffenseMode.value)

                if player.status == "Resting" then
                    merge_named(built_set, sets.Idle.Resting, 'sets.Idle.Resting')
                end
                merge_report_branch_end()

                apply_weapon_mode(built_set, false, false, false)

                if pet.isvalid then
                    merge_named(built_set, sets.Idle.Pet, 'sets.Idle.Pet')
                end
                -- Buff 187 is Sublimation: Activated, the charging state.
                if buffactive[187] then
                    merge_named(built_set, sets.Idle.Sublimation, 'sets.Idle.Sublimation')
                end
                if E.is_moving then
                    merge_named(built_set, sets.Movement, 'sets.Movement')
                end
                -- The buff children of sets.Idle and of the children the branch merged. They
                -- merge after every overlay above, and before the ammunition and the pair.
                apply_buff_children(built_set, sets.Idle, 'sets.Idle')
            else
                warn('sets.Idle not found!')
            end
        end

        -- The offense mode's round from the job file's Ammo table, for both branches. It is
        -- a bare slot with no set of its own, so the report names no set for it.
        if Ammo and Ammo[state.OffenseMode.value] then
            merge_report(built_set,
                { ammo = Ammo[state.OffenseMode.value] })
        end

        -- Under the lock the pair is written last, over every set above that could name main
        -- or sub.
        if E.lock_main_sub then reassert_pair(built_set) end
        return built_set
    end

    -- Build the gear for the start of an action: fast cast, ability gear or weaponskill gear.
    -- It also announces a tracked cast to the other characters when no announce is
    -- outstanding, and runs the consumable checks that can cancel an action.
    function precastequip(spell)
        log('precastequip Called')
        -- Put back the engine placeholders a job file removed by replacing a whole parent
        -- table, so a branch below merges an empty set instead of finding nil. It runs once
        -- per load, on the first build that calls it, and midcastequip calls it too.
        ensure_placeholders()
        merge_report_begin()
        if settings.debug then
            debug("spell.type = " ..
                spell.type ..
                " , spell.action_type = " ..
                spell.action_type .. " , spell.english = " .. spell.english .. " , spell.name = " .. spell.name)
        end
        -- While a pet is mid-action nothing is built, so the gear worn for the pet's action
        -- stays on.
        if pet.isvalid and pet_midaction() then return end
        -- Idle is the floor under every branch, so a build that matches no branch still
        -- dresses the character.
        local built_set = {}
        if sets.Idle then merge_report(built_set, sets.Idle) end
        merge_report_mark()
        if spell.type == 'WeaponSkill' then
            if sets.WS then
                merge_report(built_set, sets.WS)
                -- The facts are kept here and the info line is assembled below, past the
                -- settings gate, so a client with info off builds no text.
                local message, am_mode, show_bullets = '', nil, false
                -- Ranged and melee weaponskills take the same shape but different sets, and
                -- only the ranged side spends ammunition or reports a round count.
                if spell.skill == "Marksmanship" or spell.skill == "Archery" then
                    merge_named(built_set, sets.WS.RA, 'sets.WS.RA')

                    -- A set named for this weaponskill is merged first. Its offense-mode child
                    -- refines it, or else the offense-mode child of sets.WS.RA does. TP is the
                    -- default mode and has no child of its own.
                    if sets.WS[spell.english] then
                        merge_named(built_set, sets.WS, 'sets.WS', spell.english)
                        -- For example sets.WS['Last Stand'].PDL.
                        if sets.WS[spell.english][state.OffenseMode.value] then
                            merge_report(built_set, sets.WS[spell.english][state.OffenseMode.value])
                            -- Or else sets.WS.RA.PDL.
                        elseif state.OffenseMode.value ~= 'TP' and sets.WS.RA and sets.WS.RA[state.OffenseMode.value] then
                            merge_named(built_set, sets.WS.RA, 'sets.WS.RA', state.OffenseMode.value)
                        end
                    else
                        if state.OffenseMode.value ~= 'TP' and sets.WS.RA and sets.WS.RA[state.OffenseMode.value] then
                            merge_named(built_set, sets.WS.RA, 'sets.WS.RA', state.OffenseMode.value)
                        end
                    end

                    local am_tier = apply_aftermath(built_set, sets.WS.RA)
                    if am_tier then message = am_tier.ws_label end
                    if message ~= '' then am_mode = state.WeaponMode.value end

                    -- The buff children of every set this branch merged, read from the merge
                    -- record. No base is passed, since sets.WS is merged inside the branch and
                    -- the idle floor sits below the mark. They merge after the Aftermath tier
                    -- and before the Ammo table, so the mode's round beats a child's and the
                    -- count below reads the round that will fire.
                    apply_buff_children(built_set, nil, nil)

                    if Ammo and Ammo[state.OffenseMode.value] then
                        merge_report(built_set,
                            { ammo = Ammo[state.OffenseMode.value] })
                    end

                    -- Counted after the offense-mode round is merged, so the count reads the
                    -- round that will fire. A refusal means neither the sets nor the Ammo
                    -- table named one.
                    do_bullet_checks(spell, built_set)

                    show_bullets = true
                    -- The melee side. Same shape, one level shallower: there is no generic
                    -- parent between sets.WS and its offense-mode children.
                else
                    if sets.WS[spell.english] then
                        merge_named(built_set, sets.WS, 'sets.WS', spell.english)
                        if sets.WS[spell.english][state.OffenseMode.value] then
                            merge_report(built_set, sets.WS[spell.english][state.OffenseMode.value])
                        elseif state.OffenseMode.value ~= 'TP' and sets.WS[state.OffenseMode.value] then
                            merge_named(built_set, sets.WS, 'sets.WS', state.OffenseMode.value)
                        end
                    else
                        if state.OffenseMode.value ~= 'TP' and sets.WS[state.OffenseMode.value] then
                            merge_named(built_set, sets.WS, 'sets.WS', state.OffenseMode.value)
                        end
                    end

                    local am_tier = apply_aftermath(built_set, sets.WS)
                    if am_tier then message = am_tier.ws_label end
                    -- The same pass on this side, with no base for the same reason. It runs
                    -- before the elemental chooser below, which on a magical weaponskill
                    -- writes waist, back and the ring slot after the children, so its pick
                    -- wins on those three slots.
                    apply_buff_children(built_set, nil, nil)
                end

                -- A weaponskill on the job file's Elemental_WS list takes the day, weather
                -- and distance pieces a nuke takes.
                if Elemental_WS:contains(spell.name) then built_set = elemental_check(spell, built_set, 'magic') end

                -- The Aftermath tier and the round count only, since the merge report names
                -- the set. Assembled past the gate, so a client with info off builds no text.
                if settings.info and (message ~= '' or show_bullets) then
                    local text = message
                    if am_mode then text = text .. ' [' .. am_mode .. ']' end
                    if show_bullets then
                        text = (text ~= '' and text .. ' ' or '')
                            .. '[' .. available_bullets .. 'x]'
                    end
                    info(action_tag(spell) .. text)
                end
            else
                warn('sets.WS not found!')
            end
            -- A shot's precast, with a set for Flurry and one for Flurry II, which Embrava
            -- also takes.
        elseif spell.action_type == 'Ranged Attack' then
            if sets.Precast then
                merge_report(built_set, sets.Precast)
                if sets.Precast.RA then
                    merge_report(built_set, sets.Precast.RA)
                    if buffactive[265] then     -- Flurry
                        merge_named(built_set, sets.Precast.RA.Flurry, 'sets.Precast.RA.Flurry')
                    elseif buffactive[581] then -- Flurry II
                        merge_named(built_set, sets.Precast.RA.Flurry_II, 'sets.Precast.RA.Flurry_II')
                    elseif buffactive[228] then -- Embrava
                        merge_named(built_set, sets.Precast.RA.Flurry_II, 'sets.Precast.RA.Flurry_II')
                    end

                    if Ammo and Ammo[state.OffenseMode.value] then
                        merge_report(built_set,
                            { ammo = Ammo[state.OffenseMode.value] })
                    end
                else
                    warn('sets.Precast.RA not found!')
                end
            else
                warn('sets.Precast not found!')
            end

            -- Called unconditionally, as at the other two call sites. do_bullet_checks refuses
            -- an unnamed or emptied ammunition slot itself. A built set never carries a
            -- `ranged` key, because merge_into maps every slot to its canonical name.
            do_bullet_checks(spell, built_set)
            -- Job abilities take sets.JA and, where the job file named one, its child. Three
            -- need more: Double-Up takes sets.PhantomRoll instead of a child, the two jug-pet
            -- calls add the sets.Jugs child for the job mode, and Bounty Shot spends a round.
        elseif spell.type == 'JobAbility' then
            if sets.JA then
                merge_report(built_set, sets.JA)
                if spell.name == 'Double-Up' then
                    merge_named(built_set, sets.PhantomRoll, 'sets.PhantomRoll')
                elseif sets.JA[spell.english] then
                    merge_named(built_set, sets.JA, 'sets.JA', spell.english)
                    if spell.name == 'Bestial Loyalty' or spell.name == 'Call Beast' then
                        merge_named(built_set, sets.Jugs, 'sets.Jugs', state.JobMode.value)
                    end
                end
                if spell.name == 'Bounty Shot' then
                    do_bullet_checks(spell, built_set)
                end
            else
                warn('sets.JA not found!')
            end
            -- Divine Seal is predicted here rather than waited for. Its buff is not readable
            -- until the ability resolves, and a Cursna cast in that gap must already announce
            -- itself as spreading. The spell-received component clears the flag when the buff
            -- arrives or is lost.
            if spell.name == "Divine Seal" and not E.divine_seal_predicted then
                E.divine_seal_predicted = true
                if settings.debug then debug("Divine Seal detected while tracking. Divine_Seal_Predicted = True") end
            end
            -- Items take idle gear, except Holy Water and Hallowed Water, which take
            -- sets.Holy_Water.
        elseif spell.action_type == 'Item' or spell.prefix == '/item' then
            log('Item Use - Precast')
            if spell.english == "Holy Water" or spell.english == "Hallowed Water" then
                if sets.Holy_Water then
                    if sets.Idle then
                        merge_report(built_set, sets.Holy_Water)
                    else
                        warn('sets.Idle not found!')
                    end
                else
                    warn('sets.Holy_Water not found!')
                end
            else
                merge_named(built_set, sets.Idle, 'sets.Idle')
            end
            -- The set-family types, all merged by apply_set_family. The work that is not gear
            -- runs before that merge, and the Quick Draw pieces and the Waltz announce run
            -- after it.
        elseif PRECAST_SET_FAMILY[spell.type] then
            if spell.type == 'Scholar' then
                -- Predicted for the same reason as Divine Seal above: Accession widens the
                -- next spell before its buff is readable.
                if spell.name == "Accession" and not E.accession_predicted then
                    E.accession_predicted = true
                    if settings.debug then debug("Accession detected while tracking. Accession_Predicted = True") end
                end
            elseif spell.type == 'CorsairRoll' then
                log('CorsairRoll')
            elseif spell.type == 'Jig' then
                -- An active Sneak blocks the Sneak that Spectral Jig grants, so buff 71,
                -- Sneak, is canceled before the ability fires.
                if spell.name == "Spectral Jig" and buffactive["Sneak"] then
                    send_command('cancel 71;')
                end
            end

            apply_set_family(built_set, PRECAST_SET_FAMILY[spell.type], spell)

            -- The six Quick Draw shots on the element wheel, whose element ids sit below
            -- Light's, deal magic damage and take the day, weather and distance pieces a nuke
            -- takes. Light Shot and Dark Shot deal none.
            if spell.type == 'CorsairShot' then
                local eid = spell.element_id
                if eid and eid < LIGHT_ID then built_set = elemental_check(spell, built_set, 'magic') end
            end

            -- Tell the other characters a tracked Waltz is coming so they can dress for it.
            -- Waltz is the only ability family that ability_info tracks, so the type is
            -- tested as a literal.
            if spell.type == 'Waltz' and state.SpellReceived.value ~= "OFF" then
                local a_info = ability_info[spell.id]
                if a_info and player and spell.target.name and not outgoing_cast_busy() then
                    announce_tracked_cast('ABILITY', 'precast', spell, spell.target.name, a_info.aoe)
                end
            end
            -- Everything left is a spell. The fast-cast set is its floor, and the branches
            -- below refine it for what is being cast.
        else
            if sets.Precast then
                merge_report(built_set, sets.Precast)
                if sets.Precast.FastCast then
                    merge_report(built_set, sets.Precast.FastCast)
                    -- sets.Precast.Enhancing goes on for every enhancing spell, alongside
                    -- whichever branch below matches.
                    if spell.skill == 'Enhancing Magic' then
                        merge_named(built_set, sets.Precast.Enhancing, 'sets.Precast.Enhancing')
                    end
                    -- One branch wins, most specific first: a set named for this spell, the
                    -- cure family, the job file's Healing_Magic list, then the per-type sets.
                    if sets.Precast[spell.english] then
                        merge_named(built_set, sets.Precast, 'sets.Precast', spell.english)
                    elseif spell.name:contains('Cure') or spell.name:contains('Cura') then
                        merge_named(built_set, sets.Precast.Cure, 'sets.Precast.Cure')
                    elseif Healing_Magic:contains(spell.name) then
                        merge_named(built_set, sets.Precast.Healing, 'sets.Precast.Healing')
                    elseif spell.type == 'Ninjutsu' and UtsusemiSpell:contains(spell.name) then
                        -- The tool count runs at precast, so its warning comes before the cast.
                        do_Utsu_checks(spell)
                        merge_named(built_set, sets.Precast.Utsusemi, 'sets.Precast.Utsusemi')
                    elseif spell.type == 'BlueMagic' then
                        merge_named(built_set, sets.Precast.BlueMagic, 'sets.Precast.BlueMagic')
                    elseif spell.type == 'BardSong' then
                        -- Under Nightingale a song's cast leaves no time for a midcast swap,
                        -- so the whole midcast build is done here instead.
                        if buffactive['Nightingale'] then
                            merge_named(built_set, sets.Midcast, 'sets.Midcast')
                            build_song_set(spell, built_set)
                        else
                            merge_named(built_set, sets.Precast.Songs, 'sets.Precast.Songs')
                        end
                    end
                else
                    warn('sets.Precast.FastCast not found!')
                end
            else
                warn('sets.Precast not found!')
            end
            -- The same announce for a tracked spell, sent only when no announce is
            -- outstanding, so one pretarget sent is not repeated. A spell spreads beyond its
            -- target if it always does, or if Accession, Majesty or Divine Seal is up for a
            -- spell that effect widens. Accession and Divine Seal are also read from their
            -- prediction flags, which cover the gap before the buff is readable.
            local s_info = spell_info[spell.id]
            if s_info and spell.target.name and state.SpellReceived.value ~= "OFF" and not outgoing_cast_busy() then
                local active_buffs = buffactive
                local accession_active = active_buffs[366] or active_buffs['Accession']
                local majesty_active = active_buffs[621] or active_buffs['Majesty']
                local divine_veil_active = active_buffs[78] or active_buffs['Divine Seal']
                -- Yagrush counts as Divine Seal when check_equipment_spells dresses it for
                -- this cast, and only then.
                local has_yagrush = (s_info.divine and wears_yagrush(spell))
                local spreads = (s_info.aoe or ((E.accession_predicted or accession_active) and s_info.accession) or (majesty_active and s_info.majesty) or ((E.divine_seal_predicted or divine_veil_active or has_yagrush) and s_info.divine))
                announce_tracked_cast('SPELL', 'precast', spell, spell.target.name, spreads)
            end
        end

        merge_report_branch_end()

        -- The weapon mode, after the branch, only under the weapon lock and only for an
        -- action the lock does not exempt. The exempt actions are a friendly song under Songs
        -- and a Geomancy spell under Geomancy. With the lock off, or for an exempt action,
        -- the weapons are left to the sets and the hooks. The merge also records the pair
        -- the lock holds, and the pair is written back as this builder's last line. The
        -- shield is withheld when the mode has no set of its own.
        local held = E.lock_main_sub and not lock_exempts(spell)
        if held then
            log('Update Weapons - Precast')
            apply_weapon_mode(built_set, false, true, false)
        end

        -- The song weapons go on over that in every lock mode, Unlocked included, because a
        -- song needs its instrument. Under a lock the song is not exempt from, the pair is
        -- still written back over their main and sub at the end of the build.
        if spell.type == 'BardSong' then
            build_song_weapons(built_set, true)
        end

        -- Treasure Hunter gear goes on for an action against an untagged monster. White,
        -- black and blue magic, Trusts, songs and ninjutsu are left out, because they do not
        -- tag at precast. The midcast build dresses them when their tag lands.
        if state.TreasureMode.value ~= 'None' and spell.target.type == 'MONSTER' and not th_info.tagged_mobs[spell.target.id]
            and not (spell.type:endswith('Magic') or spell.type == 'Trust' or spell.type == 'BardSong' or spell.skill == 'Ninjutsu') then
            if sets.TreasureHunter then
                merge_report(built_set, sets.TreasureHunter)
                info('[' .. spell.english .. '] Set with Treasure Hunter')
            else
                warn('sets.TreasureHunter not found!')
            end
        end

        -- Under the lock the pair is written last, over the song weapons and the Treasure
        -- Hunter set. The build is returned, not equipped, and hooks.lua merges the job
        -- file's precast layer over it before anything is worn.
        if held then reassert_pair(built_set) end
        return built_set
    end

    -- Merge the accuracy, potency or duration set that the job file's lists assign this
    -- enfeebling spell, first match winning. A spell on none of the lists keeps the plain
    -- enfeebling set.
    --
    -- Dark magic passes skip_acc, so a dark spell takes its accuracy set only from the
    -- Dark_Acc list, never from Enfeeble_Acc.
    local function apply_enfeebling(built_set, spell, skip_acc)
        if not skip_acc and Enfeeble_Acc:contains(spell.name) then
            merge_named(built_set, sets.Midcast.Enfeebling.MACC, 'sets.Midcast.Enfeebling.MACC')
        elseif Enfeeble_Potency:contains(spell.name) then
            merge_named(built_set, sets.Midcast.Enfeebling.Potency, 'sets.Midcast.Enfeebling.Potency')
        elseif Enfeeble_Duration:contains(spell.name) then
            merge_named(built_set, sets.Midcast.Enfeebling.Duration, 'sets.Midcast.Enfeebling.Duration')
        end
    end

    -- Build the gear worn while an action is in flight, which decides how strong it lands.
    -- It has a branch for each kind of action that reaches midcast, and most of them are
    -- kinds of magic.
    function midcastequip(spell)
        ensure_placeholders()
        merge_report_begin()
        -- Abilities, items and weaponskills get no midcast build, because their precast
        -- gear is final. PRECAST_FINAL lists those types.
        if PRECAST_FINAL[spell.type] then
            log('abort midcast')
            return
        end
        if pet.isvalid and pet_midaction() then return end

        local built_set = {}
        -- Idle, then sets.Midcast, form the floor, so a cast that matches no branch below
        -- still comes out dressed rather than in its precast gear.
        if sets.Idle then merge_report(built_set, sets.Idle) end
        if sets.Midcast then
            merge_report(built_set, sets.Midcast)
            -- Spell interruption rate down, for every action except a ranged attack.
            if sets.Midcast.SIRD and spell.action_type ~= 'Ranged Attack' then
                merge_report(built_set,
                    sets.Midcast.SIRD)
            end
            merge_report_mark()

            -- A shot in flight. The info line names the offense mode the shot uses.
            if spell.action_type == 'Ranged Attack' then
                if sets.Midcast.RA then
                    -- The line is assembled below, past the gate, as in precast.
                    local message, am_label = '', nil
                    merge_report(built_set, sets.Midcast.RA)

                    if state.OffenseMode.value ~= 'TP' and sets.Midcast.RA[state.OffenseMode.value] then
                        merge_named(built_set, sets.Midcast.RA, 'sets.Midcast.RA', state.OffenseMode.value)
                        if state.OffenseMode.value == 'ACC' then
                            message = 'Ranged Attack with Accuracy'
                        elseif state.OffenseMode.value == 'PDL' then
                            message = 'Ranged Attack with Physical Damage Limit'
                        elseif state.OffenseMode.value == 'SB' then
                            message = 'Ranged Attack with Subtle Blow'
                        elseif state.OffenseMode.value == 'MEVA' then
                            message = 'Ranged Attack with Magic Evasion'
                        elseif state.OffenseMode.value == 'DT' then
                            message = 'Ranged Attack with Damage Taken'
                        elseif state.OffenseMode.value == 'PDT' then
                            message = 'Ranged Attack with Physical Damage Taken'
                        elseif state.OffenseMode.value == 'CRIT' then
                            message = 'Ranged Attack with Critical Hit'
                        elseif state.OffenseMode.value == 'True Shot' then
                            message = 'Ranged Attack with True Shot'
                        end
                    else
                        message = 'Ranged Attack Set'
                    end

                    local am_tier = apply_aftermath(built_set, sets.Midcast.RA)
                    if am_tier then am_label = am_tier.ra_label end

                    -- A multi-shot buff's set replaces the message and drops the Aftermath
                    -- label.
                    if buffactive['Triple Shot'] and sets.Midcast.RA.TripleShot then
                        merge_report(built_set, sets.Midcast.RA.TripleShot)
                        message, am_label = 'Using Triple Shot Set', nil
                    elseif buffactive['Double Shot'] and sets.Midcast.RA.DoubleShot then
                        merge_report(built_set, sets.Midcast.RA.DoubleShot)
                        message, am_label = 'Using Double Shot Set', nil
                    elseif buffactive['Barrage'] and sets.Midcast.RA.Barrage then
                        merge_report(built_set, sets.Midcast.RA.Barrage)
                        message, am_label = 'Using Barrage Set', nil
                    end

                    -- The round is merged after the branch end, with this builder's other
                    -- trailing merges. The line is assembled past the gate, since this runs
                    -- on every shot.
                    if settings.info then
                        if am_label then
                            message = message .. ' and with ' .. am_label
                                .. ' [' .. state.WeaponMode.value .. ']'
                        end
                        info(action_tag(spell) .. message .. ' [' .. available_bullets .. 'x]')
                    end
                else
                    warn('sets.Midcast.RA not found!')
                end
                -- Ninjutsu covers shadows, self-buffs, debuffs and nukes, so the ladder sorts
                -- by purpose. A named set wins, then Utsusemi, then anything self-targeted,
                -- then the job file's Enfeebling_Ninjitsu list. Whatever is left is a nuke.
            elseif spell.type == 'Ninjutsu' then
                if sets.Midcast[spell.english] then
                    merge_named(built_set, sets.Midcast, 'sets.Midcast', spell.english)
                    -- A named set for a nuke takes the day, weather and distance pieces the
                    -- fallthrough nuke takes. Utsusemi, a self-targeted spell and the job
                    -- file's Enfeebling_Ninjitsu take none, as in the ladder below.
                    if not UtsusemiSpell:contains(spell.name) and spell.target.type ~= 'SELF'
                        and not Enfeebling_Ninjitsu:contains(spell.english) then
                        built_set = elemental_check(spell, built_set, 'magic')
                    end
                elseif UtsusemiSpell:contains(spell.name) then
                    merge_named(built_set, sets.Midcast.Utsusemi, 'sets.Midcast.Utsusemi')
                elseif spell.target.type == 'SELF' then
                    merge_named(built_set, sets.Midcast.Enhancing, 'sets.Midcast.Enhancing')
                elseif Enfeebling_Ninjitsu:contains(spell.english) then
                    merge_named(built_set, sets.Midcast.Enfeebling, 'sets.Midcast.Enfeebling')
                else
                    merge_named(built_set, sets.Midcast.Nuke, 'sets.Midcast.Nuke')
                    built_set = elemental_check(spell, built_set, 'magic')
                end
                -- White magic. The cure tests match substrings, so their order matters.
                -- 'Curaga' contains 'Cura', so Curaga must be tested before Cura, or every
                -- Curaga would take the Cura set.
            elseif spell.type == 'WhiteMagic' then
                if spell.name:contains('Cure') then
                    merge_named(built_set, sets.Midcast.Cure, 'sets.Midcast.Cure')
                    built_set = elemental_check(spell, built_set, 'cure')
                elseif spell.name:contains('Curaga') then
                    merge_named(built_set, sets.Midcast.Curaga, 'sets.Midcast.Curaga')
                    built_set = elemental_check(spell, built_set, 'cura')
                elseif spell.name:contains('Cura') then
                    merge_named(built_set, sets.Midcast.Cura, 'sets.Midcast.Cura')
                    built_set = elemental_check(spell, built_set, 'cura')
                    -- Cursna takes sets.Midcast.Enhancing, with its own set over it.
                elseif spell.name == 'Cursna' then
                    merge_named(built_set, sets.Midcast.Enhancing, 'sets.Midcast.Enhancing')
                    merge_named(built_set, sets.Midcast.Cursna, 'sets.Midcast.Cursna')
                elseif sets.Midcast[spell.english] then
                    merge_named(built_set, sets.Midcast, 'sets.Midcast', spell.english)
                    -- Every other healing spell, such as Raise, Reraise and the status cures,
                    -- takes the plain enhancing set.
                elseif spell.skill == 'Healing Magic' then
                    merge_named(built_set, sets.Midcast.Enhancing, 'sets.Midcast.Enhancing')
                    -- Enhancing magic, the one ladder here with two layers. The Others set goes
                    -- on alongside whichever family set follows, and in the family ladder the
                    -- first match wins.
                elseif spell.skill == 'Enhancing Magic' then
                    if sets.Midcast.Enhancing then
                        merge_report(built_set, sets.Midcast.Enhancing)
                        -- A buff cast on someone else takes the Others set. Under Accession a
                        -- self-cast reaches the party too, so it counts as cast on others.
                        if spell.target.type ~= 'SELF' or (spell.target.type == 'SELF' and buffactive['Accession']) then
                            merge_named(built_set, sets.Midcast.Enhancing.Others, 'sets.Midcast.Enhancing.Others')
                        end
                        if spell.name:contains('Refresh') then
                            merge_named(built_set, sets.Midcast.Refresh, 'sets.Midcast.Refresh')
                        elseif spell.name:contains('Regen') then
                            merge_named(built_set, sets.Midcast.Regen, 'sets.Midcast.Regen')
                        elseif Storms:contains(spell.name) then
                            merge_named(built_set, sets.Storms, 'sets.Storms')
                        elseif spell.name:contains('Gain') then
                            merge_named(built_set, sets.Midcast.Enhancing.Gain, 'sets.Midcast.Enhancing.Gain')
                        elseif spell.name:contains('Phalanx') then
                            merge_named(built_set, sets.Midcast.Phalanx, 'sets.Midcast.Phalanx')
                        elseif Elemental_Bar:contains(spell.name) then
                            merge_named(built_set, sets.Midcast.Enhancing.Elemental, 'sets.Midcast.Enhancing.Elemental')
                        elseif Status_Bar:contains(spell.name) then
                            merge_named(built_set, sets.Midcast.Enhancing.Status, 'sets.Midcast.Enhancing.Status')
                        elseif Enhancing_Skill:contains(spell.name) then
                            merge_named(built_set, sets.Midcast.Enhancing.Skill, 'sets.Midcast.Enhancing.Skill')
                        end
                    else
                        warn('sets.Midcast.Enhancing not found!')
                    end
                elseif Divine_Skill:contains(spell.name) then
                    merge_named(built_set, sets.Midcast.Divine, 'sets.Midcast.Divine')
                    -- A missing sets.Midcast.Enfeebling is reported on info rather than warn,
                    -- here and in the black-magic arm below, since many jobs never declare it.
                elseif spell.skill == 'Enfeebling Magic' then
                    if sets.Midcast.Enfeebling then
                        merge_report(built_set, sets.Midcast.Enfeebling)
                        apply_enfeebling(built_set, spell)
                    else
                        info(action_tag(spell) .. 'No sets.Midcast.Enfeebling defined!')
                    end
                end
                -- Black magic, four skills sharing one type. The named-set branch tests the
                -- skill itself, so a nuke with its own set still gets the day, weather and
                -- distance pieces.
            elseif spell.type == 'BlackMagic' then
                if sets.Midcast[spell.english] then
                    merge_named(built_set, sets.Midcast, 'sets.Midcast', spell.english)
                    -- A named helix set takes the pieces a helix takes: the sash, the cape
                    -- and the ring, never an obi.
                    if spell.skill == 'Elemental Magic' then
                        built_set = elemental_check(spell, built_set,
                            spell.name:contains('helix') and 'helix' or 'magic')
                    end
                elseif spell.name:contains('Aspir') then
                    merge_named(built_set, sets.Midcast.Aspir, 'sets.Midcast.Aspir')
                elseif spell.name:contains('Drain') then
                    merge_named(built_set, sets.Midcast.Drain, 'sets.Midcast.Drain')
                elseif spell.skill == 'Enfeebling Magic' then
                    if sets.Midcast.Enfeebling then
                        merge_report(built_set, sets.Midcast.Enfeebling)
                        apply_enfeebling(built_set, spell)
                    else
                        info(action_tag(spell) .. 'No sets.Midcast.Enfeebling defined!')
                    end
                    -- Dark magic has its own three-way split, then falls back to the
                    -- enfeebling tiers without their accuracy set.
                elseif spell.skill == 'Dark Magic' then
                    if sets.Midcast.Dark then
                        merge_report(built_set, sets.Midcast.Dark)
                        if Dark_Acc:contains(spell.name) then
                            merge_named(built_set, sets.Midcast.Dark.MACC, 'sets.Midcast.Dark.MACC')
                        elseif Dark_Absorb:contains(spell.name) then
                            merge_named(built_set, sets.Midcast.Dark.Absorb, 'sets.Midcast.Dark.Absorb')
                        elseif Dark_Enhancing:contains(spell.name) then
                            merge_named(built_set, sets.Midcast.Dark.Enhancing, 'sets.Midcast.Dark.Enhancing')
                        else
                            apply_enfeebling(built_set, spell, true)
                        end
                    else
                        info(action_tag(spell) .. 'No sets.Midcast.Dark defined!')
                    end
                elseif spell.skill == 'Enhancing Magic' then
                    merge_named(built_set, sets.Midcast.Enhancing, 'sets.Midcast.Enhancing')
                    -- Elemental debuffs, on the job file's Elemental_Enfeeble list. They take
                    -- the enfeebling accuracy set directly, without the tier ladder.
                elseif Elemental_Enfeeble:contains(spell.name) then
                    if sets.Midcast.Enfeebling then
                        merge_report(built_set, sets.Midcast.Enfeebling)
                        merge_named(built_set, sets.Midcast.Enfeebling.MACC, 'sets.Midcast.Enfeebling.MACC')
                    else
                        warn('sets.Midcast.Enfeebling not found!')
                    end
                    -- Nukes. A magic burst needs three things: the mob the skillchain was made
                    -- on, a cast within eight seconds of the chain as run_burst recorded it,
                    -- and this spell's element among the chain's elements. Otherwise it is an
                    -- ordinary nuke.
                elseif spell.skill == 'Elemental Magic' then
                    local element = res.spells[spell.id].element
                    local element_name = res.elements[element].en
                    if spell.target.id == E.last_skillchain_id and os.clock() - E.last_skillchain_time < 8 and E.last_skillchain_elements[element_name] then
                        info(action_tag(spell) .. "Burst Detected!")
                        merge_named(built_set, sets.Midcast.Burst, 'sets.Midcast.Burst')
                    else
                        merge_named(built_set, sets.Midcast.Nuke, 'sets.Midcast.Nuke')
                    end
                    -- A helix takes sets.Helix and its Light or Dark child, then the bonus
                    -- pieces a helix can use: the sash, the cape and the ring, never an obi,
                    -- since the spell forces its own procs.
                    if spell.name:contains('helix') then
                        if sets.Helix then
                            merge_report(built_set, sets.Helix)
                            if spell.element == 'Dark' then
                                merge_named(built_set, sets.Helix.Dark, 'sets.Helix.Dark')
                            elseif spell.element == 'Light' then
                                merge_named(built_set, sets.Helix.Light, 'sets.Helix.Light')
                            end
                        else
                            warn('sets.Helix not found!')
                        end
                        built_set = elemental_check(spell, built_set, 'helix')
                    else
                        -- An Earth nuke also takes sets.Midcast.Nuke.Earth, when the job file
                        -- declares it, before the bonus pieces.
                        if spell.element == "Earth" and sets.Midcast.Nuke.Earth then
                            merge_report(built_set, sets.Midcast.Nuke.Earth)
                            info(action_tag(spell) .. 'Earth Element Detected!')
                        end
                        built_set = elemental_check(spell, built_set, 'magic')
                    end
                end
            elseif spell.type == 'BardSong' then
                build_song_set(spell, built_set)
                -- Blue magic is classified by the job file's lists, declared in interface.lua,
                -- because a blue spell's own data does not say whether it deals physical or
                -- breath damage or only applies a buff.
                --
                -- Only a blue nuke calls elemental_check, with a named set or without. The
                -- day, weather and distance pieces scale magic damage only.
            elseif spell.type == 'BlueMagic' then
                if sets.Midcast[spell.english] then
                    merge_named(built_set, sets.Midcast, 'sets.Midcast', spell.english)
                    if BlueNuke:contains(spell.english) then built_set = elemental_check(spell, built_set, 'magic') end
                else
                    if sets.Midcast.BlueMagic then
                        -- Physical: damage comes from the mainhand weapon, accuracy, DEX and
                        -- physical attack.
                        if BluePhysical:contains(spell.english) then
                            merge_named(built_set, sets.Midcast.BlueMagic.Physical, 'sets.Midcast.BlueMagic.Physical')
                            -- Breath: damage scales off the caster's own HP and level. Magic
                            -- attack, INT and blue magic skill contribute nothing at all.
                        elseif BlueBreath:contains(spell.english) then
                            merge_named(built_set, sets.Midcast.BlueMagic.Breath, 'sets.Midcast.BlueMagic.Breath')
                        elseif BlueNuke:contains(spell.english) then
                            merge_named(built_set, sets.Midcast.BlueMagic.Nuke, 'sets.Midcast.BlueMagic.Nuke')
                            built_set = elemental_check(spell, built_set, 'magic')
                        elseif BlueSkill:contains(spell.english) then
                            merge_named(built_set, sets.Midcast.BlueMagic.Skill, 'sets.Midcast.BlueMagic.Skill')
                            -- Fixed-potency buffs. Only their duration answers to gear, so
                            -- they must not borrow the skill set the arm above uses.
                        elseif BlueBuff:contains(spell.english) then
                            merge_named(built_set, sets.Midcast.BlueMagic.Buff, 'sets.Midcast.BlueMagic.Buff')
                        elseif BlueTank:contains(spell.english) then
                            merge_named(built_set, sets.Midcast.BlueMagic.Enmity, 'sets.Midcast.BlueMagic.Enmity')
                        elseif BlueHealing:contains(spell.english) then
                            merge_named(built_set, sets.Midcast.BlueMagic.Healing, 'sets.Midcast.BlueMagic.Healing')
                        elseif BlueACC:contains(spell.english) then
                            merge_named(built_set, sets.Midcast.BlueMagic.ACC, 'sets.Midcast.BlueMagic.ACC')
                        end
                        -- Diffusion applies over whichever arm matched, not instead of one:
                        -- it extends a blue buff to the party without changing what it does.
                        if buffactive["Diffusion"] then
                            if sets.Diffusion then
                                merge_report(built_set, sets.Diffusion)
                                info(action_tag(spell) .. 'Diffusion Augment')
                            else
                                warn('sets.Diffusion not found!')
                            end
                        end
                    else
                        warn('sets.Midcast.BlueMagic not found!')
                    end
                end
                -- Geomancy splits two ways: an Indicolure follows a target, and a bubble stays
                -- where it is cast. Both come from job-file lists. Only the Indi side has a
                -- further case, an Indicolure cast on another player through Entrust.
            elseif spell.type == 'Geomancy' then
                if sets.Geomancy then
                    if sets.Geomancy[spell.english] then
                        merge_named(built_set, sets.Geomancy, 'sets.Geomancy', spell.english)
                    elseif Indicolure_List:contains(spell.english) then
                        if sets.Geomancy.Indi then
                            merge_report(built_set, sets.Geomancy.Indi)
                            if spell.target.type ~= "SELF" then
                                if sets.Geomancy.Indi.Entrust then
                                    merge_report(built_set, sets.Geomancy.Indi.Entrust)
                                    info(action_tag(spell) .. 'Indicolure set - Entrust')
                                else
                                    warn('sets.Geomancy.Indi.Entrust not found!')
                                end
                            end
                        else
                            warn('sets.Geomancy.Indi not found!')
                        end
                    elseif Geomancy_List:contains(spell.english) then
                        merge_named(built_set, sets.Geomancy.Geo, 'sets.Geomancy.Geo')
                    end
                else
                    warn('sets.Geomancy not found!')
                end
                -- Nothing worn changes a Trust summon. sets.Midcast is merged again inside the
                -- branch so the report names the set the cast wore.
            elseif spell.type == 'Trust' then
                merge_report(built_set, sets.Midcast)
                -- Blood pacts take a set named for the pact, or sets.Midcast.BP. Under Astral
                -- Conduit, which removes the recast, the build is emptied, so nothing is
                -- swapped.
            elseif spell.type == "BloodPactWard" or spell.type == "BloodPactRage" then
                if not buffactive["Astral Conduit"] then
                    if sets.Midcast[spell.english] then
                        merge_named(built_set, sets.Midcast, 'sets.Midcast', spell.english)
                    elseif sets.Midcast.BP then
                        merge_report(built_set, sets.Midcast.BP)
                    else
                        warn('sets.Midcast.BP not found!')
                    end
                else
                    built_set = {}
                end
                -- Beastmaster Ready moves, which arrive as type Monster.
            elseif spell.type == 'Monster' then
                merge_named(built_set, sets.Ready, 'sets.Ready')
                -- The two summoning-magic cases, each falling back to a general set when the
                -- job file named none for the spell.
            elseif spell.name == "Elemental Siphon" then
                if sets.Midcast[spell.english] then
                    merge_named(built_set, sets.Midcast, 'sets.Midcast', spell.english)
                else
                    merge_named(built_set, sets.Midcast.SummoningMagic, 'sets.Midcast.SummoningMagic')
                end
            elseif spell.type == "SummonerPact" then
                if sets.Midcast[spell.english] then
                    merge_named(built_set, sets.Midcast, 'sets.Midcast', spell.english)
                else
                    merge_named(built_set, sets.Midcast.Summon, 'sets.Midcast.Summon')
                end
            end
        else
            warn('sets.Midcast not found!')
        end
        merge_report_branch_end()

        -- The buff children of sets.Midcast and of every set the branch merged for this
        -- action, read from the merge record. They merge after the branch end and before
        -- every trailing merge below, which win over them: the round, the weapon mode under
        -- the lock, the song weapons, Treasure Hunter and the pair. The elemental chooser
        -- wrote inside the branch, so a child naming waist, back or the ring slot wins over
        -- its pick. The call is gated on sets.Midcast because the mark is set only inside
        -- that test. Without the set, the span would cover the idle floor alone.
        if sets.Midcast then apply_buff_children(built_set, sets.Midcast, 'sets.Midcast') end

        -- The round a shot fires, after the children, so the Ammo table wins over a child's
        -- round as in every other build. A job file may set Ammo to nil, so it is tested
        -- before it is indexed, as at the other sites.
        if spell.action_type == 'Ranged Attack' and sets.Midcast and sets.Midcast.RA
            and Ammo and Ammo[state.OffenseMode.value] then
            merge_report(built_set,
                { ammo = Ammo[state.OffenseMode.value] })
        end

        -- Three spells that do not take hold over their own active buff, so the old buff is
        -- canceled by id at midcast: 37 Stoneskin, 71 Sneak and 66 Copy Image. Sneak is
        -- canceled only when self-cast, since only the player's own buff can be canceled.
        -- The Copy Image cancel waits half a second.
        if spell.name == "Stoneskin" and buffactive["Stoneskin"] then
            send_command('cancel 37;')
        elseif spell.name == "Sneak" and buffactive["Sneak"] and spell.target.type == "SELF" then
            send_command('cancel 71;')
        elseif spell.name == "Utsusemi: Ichi" and buffactive["Copy Image"] then
            send_command('wait .5;cancel 66;')
        end

        -- The weapon mode, as in precast: only under the weapon lock, for an action it does
        -- not exempt. Under Locked and Locked+R nothing is exempt, a Geomancy spell included.
        -- The pair is written back as this builder's last line.
        local held = E.lock_main_sub and not lock_exempts(spell)
        if held then
            apply_weapon_mode(built_set, false, false, false)
        end

        -- The song weapons, as in precast. Midcast also chooses a Pianissimo instrument. A
        -- song aimed at another player or a Trust takes the Pianissimo instrument for its
        -- family rather than the Potency one. A dummy song on the SongCount list is left out.
        if spell.type == 'BardSong' then
            build_song_weapons(built_set, false)

            if spell.target.id ~= player.id and not SongCount:contains(spell.name) and (spell.target.type == 'PLAYER' or spell.target.type == 'NPC') then
                log('Pianissimo Check')
                if Instrument then
                    if Instrument.Pianissimo then
                        -- Merged through the report, unlike the instruments in
                        -- build_song_set, so the gear report names the choice between a
                        -- family instrument and the general one. A blank entry is skipped,
                        -- and the family set keeps the slot.
                        local pianissimo = equip_pianissimo_gear(spell)
                        if not blank_instrument(pianissimo, 'Instrument.Pianissimo') then
                            merge_report(built_set, { range = pianissimo })
                        end
                    else
                        warn('Instrument.Pianissimo not found!')
                    end
                else
                    warn('Instrument not found!')
                end
            end
        end
        -- Treasure Hunter, with a looser test than precast's: an untagged monster target and
        -- a set to wear. This is where a spell's Treasure Hunter gear goes on.
        if state.TreasureMode.value ~= 'None' and spell.target.type == 'MONSTER' and not th_info.tagged_mobs[spell.target.id] and sets.TreasureHunter then
            merge_report(built_set, sets.TreasureHunter)
            info('[' .. spell.english .. '] Set with Treasure Hunter')
        end
        -- Under the lock the pair is written last, over the song weapons, the Pianissimo
        -- instrument and the Treasure Hunter set. The build is returned, and hooks.lua
        -- merges the job file's midcast layer over it before the equip.
        if held then reassert_pair(built_set) end
        return built_set
    end

    -- The engaged or idle build with the job file's choose_set_custom layer over it.
    -- choose_set is only the engine's half. This is what gs c update auto runs.
    local function build_current_set()
        local built_set = choose_set()
        if choose_set_custom then
            merge_into(built_set, choose_set_custom())
        else
            warn('choose_set_custom() not found!')
        end
        return built_set
    end

    -- What to wear once an action finishes: the current build. While a pet is mid-action
    -- this returns nothing and leaves the gear as it is. That path still resets the merge
    -- report, so the next build starts clean.
    function aftercastequip(spell)
        if pet_midaction() then
            merge_report_begin()
            return
        else
            return build_current_set()
        end
    end

    -- Conditional gear ---------------------------------------------------------------------------

    -- One piece of the bonus line: the slot written, the name, the expected gain to one
    -- decimal with its sign, and the word for the term that earns it.
    local function elemental_piece(slot, name, gain, word)
        return slot .. ': ' .. name .. ' (' .. ('%+.1f'):format(gain) .. '%, ' .. word .. ')'
    end

    -- Add the pieces that depend on the world rather than the spell: the waist, the cape and
    -- the ring that core.lua's chooser picks for this cast from the day, the weather and the
    -- target's distance, and the staff for a cure with a Light match.
    --
    -- kind comes from the call site. 'magic' is the plain case. 'helix' scores no obi,
    -- because the spell forces its own procs. 'cure' is a single-target cure, with no sash
    -- and no cape. 'cura' is Cura or Curaga, with no sash but the cape scored.
    --
    -- A slot the set already fills with a piece on the Bonus_Keep list is held: nothing is
    -- scored for it or written to it. Returns the set. The writes are plain slot writes,
    -- not reported layers, and they use the canonical slot names merge_into would produce.
    function elemental_check(spell, built_set, kind)
        -- Element ids throughout. spell.element_id is set on every action that carries an
        -- element, and ELEMENT_ID maps the day's and the weather's names to ids, in either
        -- language GearSwap writes them in. A nil id is an item or a ranged attack. Id 15 is
        -- an element-less spell, which no piece serves and which clear weather, also 15,
        -- would match.
        local eid = spell.element_id
        if not eid or eid == NONE_ID then return built_set end
        local dayi = ELEMENT_ID[world.day_element]
        local weai = ELEMENT_ID[world.weather_element]
        -- Each term's sign for this element: 1 matching, -1 penalizing, 0 neither. Clear
        -- weather is 15, which BEATS has no row for, so it scores 0. An intensity WEATHER_PCT
        -- does not know scores as clear rather than throwing out of the hook.
        local sd = dayi == eid and 1 or BEATS[dayi] == eid and -1 or 0
        local sw = weai == eid and 1 or BEATS[weai] == eid and -1 or 0
        local wmag = WEATHER_PCT[world.weather_intensity] or 0

        -- A cure with a Light match wears the job file's sets.Weapons['Light Bonus'] as
        -- written, main and sub included. When that set is undeclared or empty, a carried
        -- Chatoyant Staff goes in main alone. This runs before the waist is scored, because
        -- Iridescence is read from the main it leaves.
        local staff
        if (kind == 'cure' or kind == 'cura') and (sd == 1 or sw == 1) then
            local bonus = sets.Weapons['Light Bonus']
            if bonus and next(bonus) ~= nil then
                merge_into(built_set, bonus)
                staff = 'Light Bonus set'
            elseif have_item('Chatoyant Staff') then
                built_set.main = 'Chatoyant Staff'
                staff = 'main: Chatoyant Staff'
            end
        end
        -- Iridescence rides the weather proc, so the main is read only when the weather has
        -- a sign. A main written as a gear table carries its name in .name.
        local irid = 0
        if sw ~= 0 then
            local main = built_set.main
            if type(main) == 'table' then main = main.name end
            irid = IRIDESCENCE[main] or 0
        end
        -- The sash's affinity at the target's distance in whole yalms, row 13 serving every
        -- longer distance. It is nil for an unresolved subtarget, which the chooser treats
        -- as no sash.
        local d = spell.target and spell.target.distance
        local sash = d and SASH_PCT[d < 13 and d - d % 1 or 13]
        -- The ring's slot is the job file's Elemental_Bonus_Ring_Slot, read on every cast.
        -- The job file sets it inside get_sets, after the engine has loaded, so a read at
        -- load would see only the default. 'left_ring' picks the left ring, and any other
        -- value the right.
        local ring_slot = Elemental_Bonus_Ring_Slot == 'left_ring' and 'left_ring' or 'right_ring'
        -- The kept pieces. Each of the three slots is resolved to its item's name and looked
        -- up in Bonus_Keep, a plain table with no metatable, so the empty token's name,
        -- 'empty', finds nothing. A held waist leaves the cape scored alone, a held back
        -- leaves no pair to wear an obi for, and a held ring is never asked. The chooser
        -- returns nil for a held slot.
        local w, b, r = built_set.waist, built_set.back, built_set[ring_slot]
        if type(w) == 'table' then w = w.name end
        if type(b) == 'table' then b = b.name end
        if type(r) == 'table' then r = r.name end
        local hold_waist, hold_back, hold_ring = Bonus_Keep[w], Bonus_Keep[b], Bonus_Keep[r]
        local waist, waist_gain, back, back_gain, ring, ring_gain = elemental_choose(kind, eid,
            dayi, sd, sw, wmag, irid, sash,
            spell.skill_id == ELEMENTAL_MAGIC_SKILL and not hold_ring, hold_waist, hold_back)
        if waist then built_set.waist = waist end
        if back then built_set.back = back end
        if ring then built_set[ring_slot] = ring end

        -- One line naming each slot written and its piece's expected gain, assembled past the
        -- gate. The word names the term that pays. It is the day, the weather or both for an
        -- obi, the cape and the staff, the distance for the sash, and the day for the ring. A
        -- waist with no gain of its own, or a loss, is an obi worn to make the cape's bonus
        -- certain, because the pair beats the cape alone. The line prints that gain as it is
        -- and says it is for the cape.
        if settings.info and (staff or waist or back or ring) then
            local word = sd == 1 and (sw == 1 and 'day and weather' or 'day') or 'weather'
            local line, sep = action_tag(spell), ''
            if staff then
                line, sep = line .. staff .. ' (' .. word .. ')', ', '
            end
            if waist then
                if waist == SASH then
                    line = line .. sep .. elemental_piece('waist', waist, waist_gain, 'distance')
                elseif waist_gain == 0 then
                    line = line .. sep .. 'waist: ' .. waist .. ' (+0%, for the cape)'
                elseif waist_gain < 0 then
                    line = line .. sep .. elemental_piece('waist', waist, waist_gain, 'for the cape')
                else
                    line = line .. sep .. elemental_piece('waist', waist, waist_gain, word)
                end
                sep = ', '
            end
            if back then
                line, sep = line .. sep .. elemental_piece('back', back, back_gain, word), ', '
            end
            if ring then
                line = line .. sep .. elemental_piece(ring_slot, ring, ring_gain, 'day')
            end
            info(line)
        end
        return built_set
    end

    -- Bard songs ---------------------------------------------------------------------------------

    -- The song weapons, for precast or midcast. Each phase takes its own child of
    -- sets.Weapons.Songs, since the instrument that speeds a song is rarely the one that
    -- strengthens it. The shield merges last, only when the character is neither dual
    -- wielding nor holding a two-hander, and not at all while either trait is unknown, as
    -- in apply_weapon_mode.
    function build_song_weapons(built_set, precast)
        if not sets.Weapons then
            warn('sets.Weapons not found!')
            return built_set
        end
        if not sets.Weapons.Songs then
            warn('sets.Weapons.Songs not found!')
            return built_set
        end
        merge_report(built_set, sets.Weapons.Songs)
        if precast then
            merge_named(built_set, sets.Weapons.Songs.Precast, 'sets.Weapons.Songs.Precast')
        else
            merge_named(built_set, sets.Weapons.Songs.Midcast, 'sets.Weapons.Songs.Midcast')
        end
        if E.DualWield == nil or E.TwoHand == nil then return built_set end
        if not E.DualWield and not E.TwoHand then
            merge_named(built_set, sets.Weapons.Shield, 'sets.Weapons.Shield')
        end
        return built_set
    end

    -- The song gear ladder, which also chooses the song's instrument. Midcast calls it, and
    -- precast calls it under Nightingale.
    --
    -- A dummy song on the SongCount list only holds a song slot for the next song to
    -- overwrite, so it takes sets.Midcast.DummySongs and the Count instrument and nothing
    -- else.
    function build_song_set(spell, built_set)
        if SongCount:contains(spell.name) then
            merge_named(built_set, sets.Midcast.DummySongs, 'sets.Midcast.DummySongs')
            merge_instrument(built_set, Instrument.Count, 'Instrument.Count')
        else
            -- A set named for the song wins, with no instrument chosen here. Otherwise a
            -- Horde song takes the enfeebling set and the AOE_Sleep instrument, a song on the
            -- Enfeebling_Song list takes the enfeebling set and the Enfeebling instrument,
            -- and any other song is a buff and takes the Potency instrument.
            if sets.Midcast[spell.english] then
                merge_named(built_set, sets.Midcast, 'sets.Midcast', spell.english)
            elseif spell.name:contains('Horde') then
                merge_named(built_set, sets.Midcast.Enfeebling, 'sets.Midcast.Enfeebling')
                merge_instrument(built_set, Instrument.AOE_Sleep, 'Instrument.AOE_Sleep')
            elseif Enfeebling_Song:contains(spell.english) then
                merge_named(built_set, sets.Midcast.Enfeebling, 'sets.Midcast.Enfeebling')
                merge_instrument(built_set, Instrument.Enfeebling, 'Instrument.Enfeebling')
            else
                merge_instrument(built_set, Instrument.Potency, 'Instrument.Potency')
            end
            -- The family set goes on last, and the instrument chosen above is put back over
            -- it, so the family set's own range cannot displace it.
            local song_instrument = built_set['range']
            merge_report(built_set, equip_song_gear(spell))
            if song_instrument then
                merge_into(built_set, { range = song_instrument })
            end
        end
        return built_set
    end

    -- The song families, matched as substrings of a song's name and tested in this order.
    -- The lookup takes the first family the name carries that the caller has an entry for.
    -- No song in the game's data carries two family names, so the order changes no answer.
    -- A song that did carry two would be settled here by position, with no warning.
    local SONG_FAMILIES = {
        'Finale', 'Lullaby', 'Threnody', 'Elegy', 'Requiem', 'March', 'Minuet',
        'Madrigal', 'Ballad', 'Scherzo', 'Mazurka', 'Paeon', 'Carol', 'Minne',
        'Mambo', 'Etude', 'Prelude', 'Dirge', 'Sirvente', 'Aria', 'Fugue',
        'Hymnus', 'Hum', 'Virelai', 'Nocturne',
    }

    -- The entry for the first family this song name carries that the given table has an
    -- entry for, or nil. The table is a parameter because gear sets and instruments both use
    -- it. A family with no entry falls through to the next candidate, so a table with only
    -- some families still answers for the ones it has.
    local function song_family_entry(name, declared)
        if not declared then return nil end
        for i = 1, #SONG_FAMILIES do
            local family = SONG_FAMILIES[i]
            if string.find(name, family) and declared[family] then return declared[family] end
        end
    end

    -- The gear set for this song's family, or nil. It prints nothing. The caller merges the
    -- result through the report, which names the family set as the branch's set and warns
    -- when it is empty.
    function equip_song_gear(spell)
        return song_family_entry(spell.english, sets.Midcast)
    end

    -- The instrument for a Pianissimo song: the one named for its family, or the general
    -- Pianissimo instrument. Honor March and Aria of Passion return nothing, because each
    -- requires its own instrument, which check_equipment_spells supplies.
    function equip_pianissimo_gear(spell)
        if spell.english == "Honor March" or spell.english == "Aria of Passion" then return end
        if not Instrument then
            warn('Instrument not found!')
            return
        end
        if not Instrument.Pianissimo then
            warn('Instrument.Pianissimo not found!')
            return
        end
        log('Check Pianissimo Instrument')
        return song_family_entry(spell.english, Instrument.Pianissimo) or Instrument.Pianissimo
    end

    -- The layers an implement yields to, by slot_claim's answer: an item use, the disable
    -- hold, a strip hold, the Hoxne hold and the Sleep hold. Received gear, the lock modes
    -- and the weapon lock yield to the implement.
    local IMPLEMENT_YIELDS_TO = { ['ench'] = true, ['disable'] = true, ['strip'] = true,
        ['hoxne'] = true, ['sleep'] = true }

    -- The gear the engine owns for a spell, as a set or nil. That is what a spell cannot be
    -- cast without: Daybreak for Dispelga, Marsyas for Honor March, Loughnashade for Aria
    -- of Passion, and a cloak for Impact. It also covers Yagrush for a White Mage's Cursna.
    -- A job file cannot override these. hooks.lua merges the result over everything else
    -- the build chose, in both phases, and dresses it over the weapon lock.
    --
    -- An implement yields to every layer above it. When one of those holds any of its
    -- slots, nothing is returned, and the second return maps each held slot to its holder's
    -- claim, so the caller can say why the piece did not go on. The second return is nil
    -- when nothing was refused.
    --
    -- Cursna takes Yagrush only on a White Mage main job with Yagrush carried.
    -- wears_yagrush asks this same function for the spread prediction, so the two cannot
    -- disagree. Impact takes whichever cloak is carried, Crepuscular first, and empties
    -- head, because the cloak covers both slots.
    function check_equipment_spells(spell)
        local built_set
        if spell.name == "Dispelga" then
            built_set = { main = "Daybreak" }
        elseif spell.name == "Honor March" then
            built_set = { range = "Marsyas" }
        elseif spell.name == "Aria of Passion" then
            built_set = { range = "Loughnashade" }
        elseif spell.name == "Cursna" then
            if player.main_job == "WHM" and have_item("Yagrush") then
                built_set = { main = "Yagrush" }
            end
        elseif spell.name == "Impact" then
            local Crepuscular = have_item("Crepuscular Cloak")
            local Twilight = have_item("Twilight Cloak")
            if Crepuscular then
                log("Crepuscular Found")
                built_set = { head = empty, body = "Crepuscular Cloak", }
            elseif Twilight then
                log("Twilight Found")
                built_set = { head = empty, body = "Twilight Cloak", }
            end
        end
        if not built_set then return nil end
        local refused
        for slot in pairs(built_set) do
            local claim = slot_claim(slot)
            if claim and IMPLEMENT_YIELDS_TO[claim] then
                refused = refused or {}
                refused[slot] = claim
            end
        end
        if refused then return nil, refused end
        -- A one-handed implement in main cannot keep a two-hander's grip beside it, because
        -- the game empties sub. So the shield set's sub comes with it, when sub is free or
        -- held only by the weapon lock.
        if built_set.main and E.TwoHand == true then
            local shield = sets.Weapons and sets.Weapons.Shield
            local sub = shield and shield.sub
            if sub then
                local claim = slot_claim('sub')
                if claim == nil or claim == 'weapon' then built_set.sub = sub end
            end
        end
        return built_set
    end

    -- Consumable checks -------------------------------------------------------------------------

    -- Count the rounds left for this action and decide whether it may proceed. It is the
    -- only function in this file that cancels an action, and it runs while the ammunition
    -- slot is still being chosen.
    --
    -- No channel toggle silences it. The refusals and substitutions print on notice, and
    -- the low-ammunition banner writes straight to chat in color 167 and is echoed on the
    -- other characters.
    function do_bullet_checks(spell, built_set)
        if spell and built_set then
            local bullet_name = built_set.ammo
            -- A gear table names its round in .name, and the `empty` token is one such table.
            if type(bullet_name) == 'table' then bullet_name = bullet_name.name end
            -- No named round: the slot is undeclared, being emptied, or an empty string,
            -- which GearSwap's expand_entry treats as leaving the slot alone. Each would spend
            -- whatever is already loaded, so the action is refused. The refusal names which
            -- of the three it found, which points a player at a mistyped Ammo key. '' is
            -- truthy in Lua and is not 'empty', so it is tested on its own.
            if not bullet_name or bullet_name == 'empty' or bullet_name == '' then
                local shape = not bullet_name and 'undeclared'
                    or bullet_name == '' and 'blank' or 'empty'
                notice('No round named for ' .. tostring(spell.name)
                    .. ': ammo is ' .. shape .. ' in the built set. Canceling.')
                cancel_spell()
                return
            end
            log('Ammo name is: ', bullet_name)

            -- How many rounds this action could spend: more than one for a shot under a
            -- multi-shot buff, the most under Barrage, and one for anything else. The count
            -- must stay above this number, not merely reach it.
            local bullet_min_count = 1
            if spell.action_type == 'Ranged Attack' then
                if buffactive['Triple Shot'] then
                    bullet_min_count = 3
                elseif buffactive['Double Shot'] then
                    bullet_min_count = 2
                elseif buffactive['Barrage'] then
                    bullet_min_count = 8
                end
            end

            available_bullets = have_item_count(bullet_name)

            log('Bullet Count [', available_bullets, ']')

            if available_bullets == 0 then
                -- The one round a weaponskill may fall back on once its own has run out: the
                -- standard round for the current ranged type, Ammo[RAMode].RA or .TP.
                -- Anything else in the slot is being kept for its own purpose, so the action
                -- is canceled rather than spending it.
                local type_ammo = Ammo and Ammo[state.RAMode.value]
                local standard_ammo = type_ammo and (type_ammo.RA or type_ammo.TP)

                -- Out of the chosen round entirely. A Quick Draw with anything loaded, and a
                -- weaponskill with the standard round loaded, go ahead on what is worn.
                -- Anything else is canceled. A cancel here sends the other characters no
                -- completion, and none is owed, because no ranged action is announced.
                if spell.type == 'CorsairShot' and player.equipment.ammo ~= 'empty' then
                    notice('No Quick Draw ammo left.  Using what\'s currently equipped (' ..
                        player.equipment.ammo .. ').')
                    return
                elseif spell.type == 'WeaponSkill' and standard_ammo and player.equipment.ammo == standard_ammo then
                    notice('No weaponskill ammo left.  Using what\'s currently equipped (standard ranged ammo: ' ..
                        player.equipment.ammo .. ').')
                    return
                else
                    notice('No ammo (' .. tostring(bullet_name) .. ') available for that action.')
                    cancel_spell()
                    return
                end
            end

            -- The last rounds are kept back: a shot or weaponskill must leave more rounds than
            -- it could spend. Quick Draw may spend its last one.
            if spell.type ~= 'CorsairShot' and available_bullets <= bullet_min_count then
                notice('Not enough ammo.  Canceling.')
                cancel_spell()
                return
            end

            -- The low-ammunition banner, printed once. state.warned latches so a player nearly
            -- out is not told again on every shot. It resets when the count climbs back above
            -- Ammo_Warning_Limit, so restocking clears it.
            if spell.type ~= 'CorsairShot' and state.warned.value == false and available_bullets > 1 and available_bullets <= Ammo_Warning_Limit then
                local msg = '*****  LOW AMMO WARNING: ' .. tostring(available_bullets) .. 'x ' .. bullet_name .. ' *****'
                local border = string.rep('*', #msg)
                windower.send_command('send @others input /echo ' .. msg .. '')
                windower.add_to_chat(167, border)
                windower.add_to_chat(167, msg)
                windower.add_to_chat(167, border)
                state.warned:set()
            elseif available_bullets > Ammo_Warning_Limit and state.warned then
                state.warned:reset()
            end
        end
    end

    -- Warn when the ninja tools for Utsusemi are running low. Unlike the ammunition check it
    -- never cancels. Shihei is counted when carried, otherwise Shikanofuda, and fewer than
    -- ten warns. Carrying neither warns with a count of zero.
    function do_Utsu_checks(spell)
        if spell.name == 'Utsusemi: Ichi' or spell.name == 'Utsusemi: Ni' or spell.name == 'Utsusemi: San' then
            local display_message = false
            local warning_level = 10
            local count = 0
            local available_shihei = player.inventory['Shihei']
            local available_shiki = player.inventory['Shikanofuda']
            if available_shihei then
                if available_shihei.count < warning_level then
                    display_message = true
                    count = available_shihei.count
                end
            elseif available_shiki then
                if available_shiki.count < warning_level then
                    display_message = true
                    count = available_shiki.count
                end
            else
                display_message = true
            end
            -- Repeated on every cast while the tools are low, and echoed on the other
            -- characters. Unlike the ammunition banner, it does not latch.
            if display_message then
                local msg = '*****  LOW TOOL WARNING: ' .. tostring(count) .. 'x *****'
                local border = string.rep('*', #msg)
                windower.send_command('send @others input /echo ' .. msg .. '')
                windower.add_to_chat(167, border)
                windower.add_to_chat(167, msg)
                windower.add_to_chat(167, border)
            end
        end
    end

    E.apply_weapon_mode = apply_weapon_mode
    E.reassert_pair = reassert_pair
    E.build_current_set = build_current_set
    E.wears_yagrush = wears_yagrush

    -- The version stamp. The root checks it against Rahvin_GS, so a stale copy of this file
    -- stops the load with an error that names it.
    return '2.1'
end
