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
-- THIS IS WHERE THE JOB FILE BECOMES GEAR. It is one of the largest files in the engine because it
--          holds one branch per way FFXI distinguishes an action, and every one of those
--          branches ends in the same two moves: merge a set the job file declared, and name
--          it to the report. Other components reach into `sets` for one named set apiece;
--          this is the only file that walks the whole tree.
--
-- NOTHING HERE EQUIPS. Every builder RETURNS a table and the caller equips it. That is what
--          lets the same build be reported, inspected and discarded -- and it is why an
--          action's gear can be traced without anything having been worn.
--
-- A JOB FILE CANNOT BREAK A BUILD BY OMISSION. interface.lua declares every set path and
--          every classification list this file reads, so an undeclared set is an empty
--          placeholder that merges nothing rather than a nil that throws. Three arms of the
--          placeholder check enforce the direction that matters: a set path reachable from
--          here and NOT declared there fails the suite.
--
-- THE MERGE REPORT IS BRACKETED, NOT PRINTED. Each builder opens with merge_report_begin,
--          marks where the fallback chain starts, closes the branch, and equip.lua's flush
--          turns that into the one line the player reads. A new branch that merges without
--          naming its path is invisible in that line.
--
-- EXPORTS  three onto E -- apply_weapon_mode, build_current_set and wears_yagrush -- plus
--          writes to the two prediction flags state.lua declares and hooks and
--          spellreceived also touch.
--          Twelve globals, of which hooks.lua calls five: the three phase builders,
--          choose_set and check_equipment_spells. The other seven are this file's own.
-- LOADS    Seventh of fifteen, and calls no global that resolves late.

-- requires: rahvings/state, rahvings/core, rahvings/equip, rahvings/enchant
return function(E)
    -- Bound once at construction, so no branch below reaches through E while building.
    local PLACEHOLDER_NAME, PRECAST_FINAL, Storms, UtsusemiSpell = E.PLACEHOLDER_NAME, E.PRECAST_FINAL, E.Storms,
        E.UtsusemiSpell
    local ability_info, spell_info, res, settings, th_info       = E.ability_info, E.spell_info, E.res, E.settings,
        E.th_info
    local action_tag                                             = E.action_tag
    local announce_tracked_cast, debug, ensure_placeholders      = E.announce_tracked_cast, E.debug,
        E.ensure_placeholders
    local have_item, have_item_count                             = E.have_item, E.have_item_count
    local merge_into, merge_named, merge_report                  = E.merge_into, E.merge_named, E.merge_report
    local merge_report_begin, merge_report_branch_end            = E.merge_report_begin, E.merge_report_branch_end
    local merge_report_mark, mr_am, outgoing_cast_busy           = E.merge_report_mark, E.mr_am, E.outgoing_cast_busy
    local set_has_gear, verify_locked_slots                      = E.set_has_gear, E.verify_locked_slots
    local blank_instrument                                       = E.blank_instrument
    local lock_exempts, slot_claim                               = E.lock_exempts, E.slot_claim

    -- Dress the range slot in an instrument, unless that instrument carries nothing. A bard
    -- file that omits one of section 2's Instrument keys gets the engine's {} placeholder
    -- back, and a blank table is truthy -- merged, it displaces whatever the song family set
    -- offered and then reaches GearSwap with no .name to equip. Declared here, above every
    -- caller, because midcastequip's Pianissimo branch is one of them and sits well above
    -- build_song_set: a local declared between the two would be a nil global at the first.
    local function merge_instrument(built_set, instrument, name)
        if blank_instrument(instrument, name) then return end
        merge_into(built_set, { range = instrument })
    end

    -- Rounds left of the ammunition the last build chose, recounted on every bullet check
    -- and read afterwards by the lines that report a shot.
    local available_bullets = 0

    -- Whether this cast wears Yagrush: what the implement tier answers for it, asked the same
    -- way the hooks ask, so the spread prediction and the equip cannot disagree. Declared
    -- here, above precastequip, which reads it for its announce; the pretarget announce in
    -- hooks.lua reads it through E.
    local function wears_yagrush(spell)
        local implement = check_equipment_spells(spell)
        return implement ~= nil and implement.main == 'Yagrush'
    end
    ------------------------------------------------------------------------------------------------
    -- SECTION 15 - GEAR SET BUILDERS
    ------------------------------------------------------------------------------------------------
    -- Assemble the equipment for one moment. Each builder returns a table for its caller to
    -- equip; none equips anything itself.

    -- Shared merges ------------------------------------------------------------------------------

    -- Merge the strongest Aftermath tier that is BOTH active and defined by the given root,
    -- for the current weapon mode. Returns that tier's row, whose two label spellings the
    -- caller reports with, or nil when no tier applies.
    local apply_aftermath
    -- The tier table sits inside a closed block rather than beside the function, so nothing
    -- outside it reaches the table and only apply_aftermath escapes. Lua caps a function's
    -- locals at 200, and a constructor is one function; the import block binds only what
    -- this file uses.
    do
        -- Strongest tier first, so the loop below can stop at the first match. Each row is
        -- one fact: the buff to look for, the set key, and how it is spelled in each report.
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
                    -- The tier set dresses every weapon; a weapon-mode child under it
                    -- refines that for one weapon. An untouched placeholder counts as
                    -- absent and is not merged, so a job file that declared the tier and
                    -- filled only the child still reports honestly -- the tier is returned
                    -- when the base carries gear OR a child exists, never for an empty pair.
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

    -- Record the weapons the mode resolved in this build for the weapon lock to hold: the
    -- pair on E.lock_pair, written slot by slot as the mode's set and the offhand set name
    -- them, so a slot the mode leaves unnamed keeps what the lock found worn when it
    -- resolved. The offhand's sub outranks the mode set's, as it does in the merge. A change
    -- to the pair is announced through E.lock_pair_changed when a component has hung a
    -- callback there, so an enforcement that holds slots can move with the pair.
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

    -- Sub is held by re-assert, never shut: under the lock the pair is written last into
    -- every build -- main for the built set's honesty, its slot being shut anyway; sub because
    -- its slot is open, so a set naming one -- a grip beside a two-hander, a shield the mode
    -- left unnamed, the song weapons' offhand -- cannot move it. A hook merging after the
    -- build still can, for its one action.
    local function reassert_pair(built_set)
        local pair = E.lock_pair
        if pair.main ~= nil then built_set.main = pair.main end
        if pair.sub ~= nil then built_set.sub = pair.sub end
    end

    -- Put the weapons the current mode calls for into a build, and whatever goes in the
    -- offhand with them. Under the weapon lock the pair it resolves is recorded as well, and
    -- the lock holds that pair against everything that merges after this.
    --
    -- The three flags are all about what a caller is willing to say out loud or withhold:
    -- dual_wield_set offers sets.DualWield, quiet suppresses every "not found" warning, and
    -- shield_needs_mode_set stops the shield being merged when the mode named no set of its
    -- own. It is exported because hooks.lua layers the master's weapons onto a pet midcast,
    -- and does so quietly -- a pet action is not the moment to report a missing weapon set.
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
            -- A legacy weapon mode ('Unlocked', 'Locked') has no set of its own by design:
            -- the lock holds what is worn, and the bridge's flag keeps this quiet for it.
            if not quiet and not E.lock_legacy then
                warn('sets.Weapons.' .. state.WeaponMode.value .. ' not found!')
            end
            if shield_needs_mode_set then
                if E.lock_main_sub then
                    record_locked_weapons(nil, nil)
                    reassert_pair(built_set)
                end
                return
            end
        end
        -- The offhand waits until both traits have been read. Between load and the
        -- monitor's first pass each flag is nil, which is not an answer, and the rebuild
        -- that follows the reads dresses the offhand then.
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
            reassert_pair(built_set)
        end
    end

    -- The thirteen precast action types whose gear is a family parent plus an optional child
    -- named for the action, and which declared root each one reads. Several types share a
    -- root -- the three Flourishes are all sets.Flourish, and four Scholar-family types are
    -- all sets.JA -- so a job file declares eight roots, not thirteen.
    --
    -- The placeholder check reads this table by name and requires every root in it to be
    -- declared: adding a type here without adding its root fails the suite rather than
    -- silently merging nothing.
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

    -- Merge a family parent and, where the job file defined one, the child named for this
    -- action. The root is looked up BY NAME at call time rather than captured at load, so a
    -- job file that replaces the whole parent table still resolves -- which is what most of
    -- them do.
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

    -- Build what the character should be wearing right now, doing nothing in particular. The
    -- engaged and idle builder, and the one called most: on movement, on a buff change, on a
    -- status change and on every gs c update auto. It must stay cheap, and it must NEVER
    -- write to chat -- warn and info here would fire ten times a second while moving.
    function choose_set()
        merge_report_begin()
        -- Above the Sleep return on purpose: being put to sleep is not a reason to hand back
        -- a slot something else is holding.
        verify_locked_slots()
        -- Sleep returns an EMPTY set, not idle gear, so the character keeps whatever it was
        -- wearing when it went down. equip.lua treats an empty build as the one deliberate
        -- empty set and does not warn about it.
        if buffactive['Sleep'] then return {} end
        local built_set = {}
        if player.status == "Engaged" then
            if sets.OffenseMode then
                merge_report(built_set, sets.OffenseMode)
                merge_report_mark()
                if sets.OffenseMode[state.OffenseMode.value] then
                    merge_named(built_set, sets.OffenseMode, 'sets.OffenseMode', state.OffenseMode.value)
                    merge_report_branch_end()
                    -- The engaged build is the only one that offers sets.DualWield: an
                    -- offhand weapon is worth wearing while swinging and not otherwise.
                    apply_weapon_mode(built_set, true, false, false)
                    -- Ranged job mode borrows the idle set's offense child while engaged,
                    -- because a character shooting is standing still and wants idle stats.
                    if state.JobMode.value == "Ranged" then
                        log('Ranged Mode')
                        if sets.Idle and sets.Idle[state.OffenseMode.value] then
                            merge_named(built_set, sets.Idle, 'sets.Idle', state.OffenseMode.value)
                        else
                            warn('sets.Idle.' .. state.OffenseMode.value .. ' not found!')
                        end
                    end
                    apply_aftermath(built_set, sets.OffenseMode)
                    -- Three ways Treasure Hunter gear earns its slots while engaged, and the
                    -- order is the point. An untagged target always does, whatever the mode,
                    -- because that is the swing that would apply the tag. Past that it takes
                    -- Full Time, or SATA with one of its three abilities up.
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
            -- Not engaged. The idle base and its offense-mode child, then the overlays
            -- that may all apply at once: resting, a pet, Sublimation, movement. Order
            -- decides the outcome, because a later merge overwrites the slots an earlier
            -- one filled -- movement is last so it wins, which is what a character who is
            -- moving wants.
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
                -- 187 is Sublimation: Activated -- charging it, not spending it, which is the
                -- state that wants its own idle set.
                if buffactive[187] then
                    merge_named(built_set, sets.Idle.Sublimation, 'sets.Idle.Sublimation')
                end
                if E.is_moving then
                    merge_named(built_set, sets.Movement, 'sets.Movement')
                end
            else
                warn('sets.Idle not found!')
            end
        end

        -- Ammunition chosen by offense mode, applied to both branches. Merged as a bare
        -- slot rather than a named path, because it comes from the job file's Ammo table
        -- and has no set of its own to report.
        if Ammo and Ammo[state.OffenseMode.value] then
            merge_report(built_set,
                { ammo = Ammo[state.OffenseMode.value] })
        end

        return built_set
    end

    -- Build the gear for the opening of an action: fast cast, ability gear, weaponskill
    -- gear. This is also where a tracked cast is announced to the other characters, and
    -- where the consumable checks that can cancel an action run.
    function precastequip(spell)
        log('precastequip Called')
        -- Re-seed the engine's placeholders. A job file that assigned a whole parent table
        -- wholesale removed every placeholder under it, and this puts them back so a branch
        -- below merges an empty set instead of finding nil. It runs once, on the first build
        -- after a load, and is called from both this builder and midcastequip because either
        -- may be the first.
        ensure_placeholders()
        merge_report_begin()
        if settings.debug then
            debug("spell.type = " ..
                spell.type ..
                " , spell.action_type = " ..
                spell.action_type .. " , spell.english = " .. spell.english .. " , spell.name = " .. spell.name)
        end
        -- A summoner whose avatar is mid-action builds nothing: the pet's own gear is what
        -- matters, and re-dressing the master here would interrupt it.
        if pet.isvalid and pet_midaction() then return end
        -- Idle is the floor under every branch, so a build that falls through them all still
        -- dresses the character rather than returning bare slots.
        local built_set = {}
        if sets.Idle then merge_report(built_set, sets.Idle) end
        merge_report_mark()
        if spell.type == 'WeaponSkill' then
            if sets.WS then
                merge_report(built_set, sets.WS)
                -- Facts now, text later: the line is assembled past the settings gate below,
                -- so a client with info off pays nothing to not print it.
                local message, am_mode, show_bullets = '', nil, false
                -- Ranged and melee weaponskills take the same shape but different sets, and
                -- only the ranged side spends ammunition or reports a round count.
                if spell.skill == "Marksmanship" or spell.skill == "Archery" then
                    merge_named(built_set, sets.WS.RA, 'sets.WS.RA')

                    -- A set named for this weaponskill wins; otherwise the offense-mode child
                    -- of the generic ranged set stands in. TP is the default mode and has no
                    -- child of its own, so it falls through to the plain set.
                    if sets.WS[spell.english] then
                        merge_named(built_set, sets.WS, 'sets.WS', spell.english)
                        -- sets.WS['Savage Blade'].PDL, refining the named set for one mode.
                        if sets.WS[spell.english][state.OffenseMode.value] then
                            merge_report(built_set, sets.WS[spell.english][state.OffenseMode.value])
                            -- Or sets.WS.RA.ACC, refining the generic ranged set instead.
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

                    if Ammo and Ammo[state.OffenseMode.value] then
                        merge_report(built_set,
                            { ammo = Ammo[state.OffenseMode.value] })
                    end

                    -- Counted after the offense-mode round is merged, as the ranged-attack
                    -- site counts: the count reads the round that will fire, and a refusal
                    -- means neither the set nor the Ammo table named one.
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
                end

                -- Magic-damage weaponskills take the day, weather and distance pieces the
                -- spells take; the job file's own list decides which ones qualify.
                if Elemental_WS:contains(spell.name) then built_set = elemental_check(spell, built_set) end

                -- Aftermath and the round count only. The set itself is named by the merge
                -- report, so repeating it here would say the same thing twice. Assembled past
                -- the gate because a weaponskill is frequent and a silenced client should pay
                -- nothing for a line it will not print.
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
            -- A shot's precast is about speed, so the three buffs that shorten it each get
            -- their own set. Embrava shares Flurry II's, being the same effect from a
            -- different source.
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

            -- Unconditional, as at the other two call sites: an unfilled or deliberately
            -- emptied ammunition slot is refused by do_bullet_checks' own early-out, which
            -- is the only place it belongs. A guard here cannot key on `ranged`:
            -- merge_into canonicalizes the slot to `range` through CANON_SLOT, so that key
            -- never exists on a built set.
            do_bullet_checks(spell, built_set)
            -- Job abilities take sets.JA and, where the job file named one, its child. Three
            -- abilities need something extra the name alone does not give: Double-Up borrows
            -- the roll set for its range, the two jug-pet calls pick a pet by job mode, and
            -- Bounty Shot spends a round.
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
            -- Divine Seal is predicted here, not waited for. The buff does not become
            -- readable until after the ability resolves, and a Cure cast in that gap has to
            -- announce itself as party-wide already; spellreceived clears the flag when the
            -- real buff arrives.
            if spell.name == "Divine Seal" and not E.divine_seal_predicted then
                E.divine_seal_predicted = true
                if settings.debug then debug("Divine Seal detected while tracking. Divine_Seal_Predicted = True") end
            end
            -- Items are dressed in idle gear, since nothing a player wears changes what one
            -- does. The two curative waters are the exception the job file may dress
            -- separately, for the HP they restore.
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
            -- The thirteen family types, all merged the same way by apply_set_family below.
            -- What differs is the work that is NOT gear, and it is placed on the side of
            -- that merge it has to happen on: everything here runs BEFORE the merge, because
            -- each of these changes what the merge or the cast should do.
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
                -- An active Sneak blocks the Sneak that Spectral Jig grants, so 71, Sneak,
                -- is canceled before the ability fires rather than after it fails.
                if spell.name == "Spectral Jig" and buffactive["Sneak"] then
                    send_command('cancel 71;')
                end
            end

            apply_set_family(built_set, PRECAST_SET_FAMILY[spell.type], spell)

            -- Tell the other characters a tracked Waltz is coming so they can dress for it.
            -- Waltz is the only ability family in the tracking table today, which is why the
            -- type test is written as a literal rather than read from the table.
            if spell.type == 'Waltz' and state.SpellReceived.value ~= "OFF" then
                local a_info = ability_info[spell.id]
                if a_info and player and spell.target.name and not outgoing_cast_busy() then
                    announce_tracked_cast('ABILITY', 'precast', spell, spell.target.name, a_info.aoe)
                end
            end
            -- Everything left is a spell, and a spell's precast is about one thing: getting
            -- it off faster. The fast-cast set is the floor; the branches below refine it for
            -- what is being cast.
        else
            if sets.Precast then
                merge_report(built_set, sets.Precast)
                if sets.Precast.FastCast then
                    merge_report(built_set, sets.Precast.FastCast)
                    -- Enhancing is additive, not exclusive: it applies alongside whichever
                    -- branch below matches, because enhancing duration is set at precast.
                    if spell.skill == 'Enhancing Magic' then
                        merge_named(built_set, sets.Precast.Enhancing, 'sets.Precast.Enhancing')
                    end
                    -- One branch wins, most specific first: a set named for this exact spell,
                    -- then the cure family, then the job file's healing list, then the
                    -- per-type sets.
                    if sets.Precast[spell.english] then
                        merge_named(built_set, sets.Precast, 'sets.Precast', spell.english)
                    elseif spell.name:contains('Cure') or spell.name:contains('Cura') then
                        merge_named(built_set, sets.Precast.Cure, 'sets.Precast.Cure')
                    elseif Healing_Magic:contains(spell.name) then
                        merge_named(built_set, sets.Precast.Healing, 'sets.Precast.Healing')
                    elseif spell.type == 'Ninjutsu' and UtsusemiSpell:contains(spell.name) then
                        -- The tool count happens here, in precast, because a warning about
                        -- running low is only useful before the cast rather than during it.
                        do_Utsu_checks(spell)
                        merge_named(built_set, sets.Precast.Utsusemi, 'sets.Precast.Utsusemi')
                    elseif spell.type == 'BlueMagic' then
                        merge_named(built_set, sets.Precast.BlueMagic, 'sets.Precast.BlueMagic')
                    elseif spell.type == 'BardSong' then
                        -- Nightingale removes a song's cast time, so the precast IS the
                        -- midcast: the whole midcast build is done here instead, because
                        -- there will be no useful window to do it in later.
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
            -- The same announce for spells, and the harder question: who besides the named
            -- target will receive it. A spell spreads if it always does, or if one of the
            -- three widening effects is up -- each tested against both the live buff and the
            -- prediction flag, so the gap before a buff becomes readable is covered.
            local s_info = spell_info[spell.id]
            if s_info and spell.target.name and state.SpellReceived.value ~= "OFF" and not outgoing_cast_busy() then
                local active_buffs = buffactive
                local accession_active = active_buffs[366] or active_buffs['Accession']
                local majesty_active = active_buffs[621] or active_buffs['Majesty']
                local divine_veil_active = active_buffs[78] or active_buffs['Divine Seal']
                -- Yagrush stands in for the veil when the implement tier dresses it for
                -- this cast, and only then.
                local has_yagrush = (s_info.divine and wears_yagrush(spell))
                local spreads = (s_info.aoe or ((E.accession_predicted or accession_active) and s_info.accession) or (majesty_active and s_info.majesty) or ((E.divine_seal_predicted or divine_veil_active or has_yagrush) and s_info.divine))
                announce_tracked_cast('SPELL', 'precast', spell, spell.target.name, spreads)
            end
        end

        merge_report_branch_end()

        -- Weapons, after the branch rather than inside it, so every action gets the same
        -- treatment -- and only under the weapon lock. Unlocked leaves an action's weapons
        -- to its sets and hooks, and so does an action the lock exempts, a friendly song
        -- under Songs; Locked re-asserts the mode here, which is also what records this
        -- build's pair for the lock to hold. The shield is withheld when the mode named no
        -- set of its own.
        local held = E.lock_main_sub and not lock_exempts(spell)
        if held then
            log('Update Weapons - Precast')
            apply_weapon_mode(built_set, false, true, false)
        end

        -- Song weapons override that, in every mode including Unlocked: an instrument is
        -- not optional equipment for a song, it is what makes the song work. Under a lock
        -- the song does not stand aside from, the block still runs for what else it carries
        -- and the pair is written back over its main and sub.
        if spell.type == 'BardSong' then
            build_song_weapons(built_set, true)
            if held then reassert_pair(built_set) end
        end

        -- Treasure Hunter gear goes on for the action that will TAG the mob, and only that
        -- one -- so an untagged monster target, and not a spell, a Trust, a song or a
        -- ninjutsu, none of which tag.
        if state.TreasureMode.value ~= 'None' and spell.target.type == 'MONSTER' and not th_info.tagged_mobs[spell.target.id]
            and not (spell.type:endswith('Magic') or spell.type == 'Trust' or spell.type == 'BardSong' or spell.skill == 'Ninjutsu') then
            if sets.TreasureHunter then
                merge_report(built_set, sets.TreasureHunter)
                info('[' .. spell.english .. '] Set with Treasure Hunter')
            else
                warn('sets.TreasureHunter not found!')
            end
        end

        -- Returned, not equipped -- and not final either: the job file's own precast layer
        -- runs over this in hooks.lua before anything is worn.
        return built_set
    end

    -- Merge whichever of accuracy, potency or duration the job file classified this
    -- enfeebling spell as, first match winning. The lists are the job file's, so a spell in
    -- none of them takes the plain enfeebling set and nothing further.
    --
    -- Dark Magic passes skip_acc because it has already tested its own accuracy list against
    -- sets.Midcast.Dark.MACC; without it, a dark spell in both lists would take the general
    -- accuracy set over the dark one it was given.
    local function apply_enfeebling(built_set, spell, skip_acc)
        if not skip_acc and Enfeeble_Acc:contains(spell.name) then
            merge_named(built_set, sets.Midcast.Enfeebling.MACC, 'sets.Midcast.Enfeebling.MACC')
        elseif Enfeeble_Potency:contains(spell.name) then
            merge_named(built_set, sets.Midcast.Enfeebling.Potency, 'sets.Midcast.Enfeebling.Potency')
        elseif Enfeeble_Duration:contains(spell.name) then
            merge_named(built_set, sets.Midcast.Enfeebling.Duration, 'sets.Midcast.Enfeebling.Duration')
        end
    end

    -- Build the gear worn while an action is in flight, which is what decides how strong it
    -- lands. The longest builder in the engine, and the one with the most branches, because
    -- this is where every distinction FFXI draws between kinds of magic has to be drawn again.
    function midcastequip(spell)
        ensure_placeholders()
        merge_report_begin()
        -- Abilities, items and weaponskills never reach a midcast: precast already chose
        -- their final gear, and the shared table above says which types those are.
        if PRECAST_FINAL[spell.type] then
            log('abort midcast')
            return
        end
        if pet.isvalid and pet_midaction() then return end

        local built_set = {}
        -- Idle under midcast, both as a floor. A cast that matches no branch below still
        -- comes out dressed rather than in whatever the precast left on.
        if sets.Idle then merge_report(built_set, sets.Idle) end
        if sets.Midcast then
            merge_report(built_set, sets.Midcast)
            -- Spell interruption rate down applies to everything that can be interrupted,
            -- which a shot cannot -- so it is merged for every action except a ranged attack.
            if sets.Midcast.SIRD and spell.action_type ~= 'Ranged Attack' then
                merge_report(built_set,
                    sets.Midcast.SIRD)
            end
            merge_report_mark()

            -- A shot in flight. Eight offense modes each get their own phrasing, because the
            -- point of the line is telling the player which set they are actually shooting in.
            if spell.action_type == 'Ranged Attack' then
                if sets.Midcast.RA then
                    -- Facts now, text later, as in precast: assembled past the gate below.
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

                    -- A multi-shot buff replaces the message outright and DROPS the Aftermath
                    -- label: firing several rounds is the more useful thing to have been told,
                    -- and two labels on one line reads as noise.
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

                    -- Indexed bare, where every other ammunition site guards with `Ammo and`
                    -- first. interface.lua declares the table, so both forms work and the
                    -- difference carries no meaning.
                    if Ammo[state.OffenseMode.value] then
                        merge_report(built_set,
                            { ammo = Ammo[state.OffenseMode.value] })
                    end

                    -- Assembled past the gate: this runs on every single shot.
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
                -- Ninjutsu has no single purpose: the same skill covers shadows, self-buffs,
                -- debuffs and nukes, so the ladder sorts by what the spell is FOR. A named
                -- set wins, then shadows, then anything self-targeted, then the job file's
                -- debuff list; whatever is left is treated as damage.
            elseif spell.type == 'Ninjutsu' then
                if sets.Midcast[spell.english] then
                    merge_named(built_set, sets.Midcast, 'sets.Midcast', spell.english)
                elseif UtsusemiSpell:contains(spell.name) then
                    merge_named(built_set, sets.Midcast.Utsusemi, 'sets.Midcast.Utsusemi')
                elseif spell.target.type == 'SELF' then
                    merge_named(built_set, sets.Midcast.Enhancing, 'sets.Midcast.Enhancing')
                elseif Enfeebling_Ninjitsu:contains(spell.english) then
                    merge_named(built_set, sets.Midcast.Enfeebling, 'sets.Midcast.Enfeebling')
                else
                    merge_named(built_set, sets.Midcast.Nuke, 'sets.Midcast.Nuke')
                    built_set = elemental_check(spell, built_set)
                end
                -- White magic. Note the order of the three cure tests: Cura contains no
                -- 'Cure', but Curaga contains 'Cura', so Curaga MUST be tested before Cura or
                -- every Curaga would take the Cura set.
            elseif spell.type == 'WhiteMagic' then
                if spell.name:contains('Cure') then
                    merge_named(built_set, sets.Midcast.Cure, 'sets.Midcast.Cure')
                    built_set = elemental_check(spell, built_set)
                elseif spell.name:contains('Curaga') then
                    merge_named(built_set, sets.Midcast.Curaga, 'sets.Midcast.Curaga')
                    built_set = elemental_check(spell, built_set)
                elseif spell.name:contains('Cura') then
                    merge_named(built_set, sets.Midcast.Cura, 'sets.Midcast.Cura')
                    built_set = elemental_check(spell, built_set)
                    -- Cursna is layered rather than exclusive: it wants the enhancing base
                    -- underneath its own set, because removing a curse scales off both.
                elseif spell.name == 'Cursna' then
                    merge_named(built_set, sets.Midcast.Enhancing, 'sets.Midcast.Enhancing')
                    merge_named(built_set, sets.Midcast.Cursna, 'sets.Midcast.Cursna')
                elseif sets.Midcast[spell.english] then
                    merge_named(built_set, sets.Midcast, 'sets.Midcast', spell.english)
                    -- Everything else on the healing skill -- Raise, Reraise, the status
                    -- cures -- takes the plain enhancing set. None of them scales with the
                    -- cure sub-sets above, so none of them gets a category of its own.
                elseif spell.skill == 'Healing Magic' then
                    merge_named(built_set, sets.Midcast.Enhancing, 'sets.Midcast.Enhancing')
                    -- Enhancing magic, and the one ladder here with TWO layers. Others is
                    -- additive and applies alongside whichever family follows; the family
                    -- ladder itself is exclusive, first match winning.
                elseif spell.skill == 'Enhancing Magic' then
                    if sets.Midcast.Enhancing then
                        merge_report(built_set, sets.Midcast.Enhancing)
                        -- A buff cast on someone else wants duration gear. Under Accession a
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
                    -- The missing enfeebling set announces itself on info rather than warn:
                    -- most white-magic jobs never cast one, so an absent set is usually a
                    -- choice, not a mistake. The black-magic arm below reads the same way.
                elseif spell.skill == 'Enfeebling Magic' then
                    if sets.Midcast.Enfeebling then
                        merge_report(built_set, sets.Midcast.Enfeebling)
                        apply_enfeebling(built_set, spell)
                    else
                        info(action_tag(spell) .. 'No sets.Midcast.Enfeebling defined!')
                    end
                end
                -- Black magic, which is four unrelated skills sharing a type. The named-set
                -- branch has to re-test the skill for itself, because a job file naming a set
                -- for one nuke should still get the day, weather and distance pieces.
            elseif spell.type == 'BlackMagic' then
                if sets.Midcast[spell.english] then
                    merge_named(built_set, sets.Midcast, 'sets.Midcast', spell.english)
                    -- Helix spells are excluded here and dressed by their own branch below.
                    if spell.skill == 'Elemental Magic' and not spell.name:contains('helix') then
                        built_set =
                            elemental_check(spell, built_set)
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
                    -- Dark magic gets its own three-way split before falling back to the
                    -- shared enfeebling tiers, which is what the skip_acc argument is for:
                    -- the accuracy question has already been answered against the dark list.
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
                    -- Elemental spells that debuff rather than damage. They take the
                    -- enfeebling accuracy set directly, skipping the tier ladder, because
                    -- landing them is the whole job.
                elseif Elemental_Enfeeble:contains(spell.name) then
                    if sets.Midcast.Enfeebling then
                        merge_report(built_set, sets.Midcast.Enfeebling)
                        merge_named(built_set, sets.Midcast.Enfeebling.MACC, 'sets.Midcast.Enfeebling.MACC')
                    else
                        warn('sets.Midcast.Enfeebling not found!')
                    end
                    -- Nukes. Three conditions have to hold together for a magic burst: the
                    -- same mob the chain closed on, inside the eight second window monitor.lua
                    -- stamped, and this spell's element among the ones that chain opened.
                    -- Miss any and it is an ordinary nuke, dressed for damage instead.
                elseif spell.skill == 'Elemental Magic' then
                    local element = res.spells[spell.id].element
                    local element_name = res.elements[element].en
                    if spell.target.id == E.last_skillchain_id and os.clock() - E.last_skillchain_time < 8 and E.last_skillchain_elements[element_name] then
                        info(action_tag(spell) .. "Burst Detected!")
                        merge_named(built_set, sets.Midcast.Burst, 'sets.Midcast.Burst')
                    else
                        merge_named(built_set, sets.Midcast.Nuke, 'sets.Midcast.Nuke')
                    end
                    -- Helix takes its own parent and a light or dark child, and takes no
                    -- elemental bonus piece -- which is why the named-set branch above
                    -- excluded it too.
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
                    else
                        -- Earth nukes get an extra child before the bonus pieces. Merged
                        -- directly rather than by name because the parent is already known
                        -- present -- the nuke branch above merged it.
                        if spell.element == "Earth" and sets.Midcast.Nuke.Earth then
                            merge_report(built_set, sets.Midcast.Nuke.Earth)
                            info(action_tag(spell) .. 'Earth Element Detected!')
                        end
                        built_set = elemental_check(spell, built_set)
                    end
                end
            elseif spell.type == 'BardSong' then
                build_song_set(spell, built_set)
                -- Blue magic is classified by the job file, not by the game: eight lists in
                -- interface.lua decide which set each spell takes, because nothing in a blue
                -- spell's own data says whether it does physical damage, breath damage or
                -- nothing but apply a buff.
                --
                -- Which arms call elemental_check is the substantive part. Only the nuke arm
                -- does: the day, weather and distance pieces scale MAGIC damage, so applying
                -- them to a physical or breath spell would wear gear that does nothing.
            elseif spell.type == 'BlueMagic' then
                if sets.Midcast[spell.english] then
                    merge_named(built_set, sets.Midcast, 'sets.Midcast', spell.english)
                    if BlueNuke:contains(spell.english) then built_set = elemental_check(spell, built_set) end
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
                            built_set = elemental_check(spell, built_set)
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
                -- Geomancy splits two ways: an Indicolure follows a target, a bubble stays
                -- where it is cast. Both come from job-file lists, and only the Indi side has
                -- a further case, for casting one on somebody else through Entrust.
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
                -- Nothing worn changes a Trust summon. The base is re-merged anyway so the
                -- report can name the set the cast actually wore, rather than leaving the
                -- one cast in the session that reports nothing.
            elseif spell.type == 'Trust' then
                merge_report(built_set, sets.Midcast)
                -- Blood pacts want recast-reducing gear -- unless Astral Conduit is up, which
                -- removes the recast for its duration. The build is then emptied outright
                -- rather than left as the idle floor, so nothing is swapped for a timer that
                -- is not running.
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
                -- Beastmaster Ready moves. The only place the Monster type appears in the
                -- engine.
            elseif spell.type == 'Monster' then
                merge_named(built_set, sets.Ready, 'sets.Ready')
                -- The two summoning-magic cases, both falling back to a general set when the
                -- job file named none for the specific one.
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

        -- Three spells that overwrite a weaker version of themselves, canceled by buff id so
        -- the new cast is not wasted: 37 Stoneskin, 71 Sneak, 66 Copy Image. Sneak only when
        -- self-targeted, since canceling somebody else's is not on offer. The Utsusemi wait
        -- is what keeps the cancel from landing before the new shadows exist.
        if spell.name == "Stoneskin" and buffactive["Stoneskin"] then
            send_command('cancel 37;')
        elseif spell.name == "Sneak" and buffactive["Sneak"] and spell.target.type == "SELF" then
            send_command('cancel 71;')
        elseif spell.name == "Utsusemi: Ichi" and buffactive["Copy Image"] then
            send_command('wait .5;cancel 66;')
        end

        -- Weapons, as in precast: only under the weapon lock and for an action it does not
        -- exempt, Geomancy included.
        local held = E.lock_main_sub and not lock_exempts(spell)
        if held then
            apply_weapon_mode(built_set, false, false, false)
        end

        -- Song weapons in every mode, as in precast, the pair written back over them under a
        -- lock the song does not stand aside from -- plus the instrument question this phase
        -- has and precast does not. A song aimed at one other player through Pianissimo
        -- wants an instrument chosen for the song FAMILY rather than the potency instrument,
        -- and a dummy song is excluded because it is not aimed at anyone.
        if spell.type == 'BardSong' then
            build_song_weapons(built_set, false)
            if held then reassert_pair(built_set) end

            if spell.target.id ~= player.id and not SongCount:contains(spell.name) and (spell.target.type == 'PLAYER' or spell.target.type == 'NPC') then
                log('Pianissimo Check')
                if Instrument then
                    if Instrument.Pianissimo then
                        -- Reported rather than merged quietly, unlike the four in
                        -- build_song_set: this one is a genuine choice between a
                        -- per-family instrument and the general one, so the gear report
                        -- names it. Blank still skips -- the family set keeps the slot.
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
        -- Treasure Hunter, and looser than the precast test: by midcast the action is
        -- committed, so the only questions left are whether the target is an untagged monster
        -- and whether a set exists to wear.
        if state.TreasureMode.value ~= 'None' and spell.target.type == 'MONSTER' and not th_info.tagged_mobs[spell.target.id] and sets.TreasureHunter then
            merge_report(built_set, sets.TreasureHunter)
            info('[' .. spell.english .. '] Set with Treasure Hunter')
        end
        -- Returned for the caller to equip, with the job file's midcast layer still to come.
        return built_set
    end

    -- The current-state build with the job file's own layer over it -- the complete answer to
    -- "what should this character be wearing", where choose_set is only the engine's half.
    -- Four components take this export, and it is what gs c update auto runs.
    local function build_current_set()
        local built_set = choose_set()
        if choose_set_custom then
            merge_into(built_set, choose_set_custom())
        else
            warn('choose_set_custom() not found!')
        end
        return built_set
    end

    -- What to wear once an action finishes: whatever the character should be wearing anyway.
    -- A pet still mid-action is the exception -- its gear is what matters, so this returns
    -- nothing and leaves the master dressed as it is. The report is opened and abandoned on
    -- that path so the next build starts from a clean one rather than an unclosed branch.
    function aftercastequip(spell)
        if pet_midaction() then
            merge_report_begin()
            return
        else
            return build_current_set()
        end
    end

    -- Conditional gear ---------------------------------------------------------------------------

    -- Add the pieces that answer to the world rather than to the spell: the elemental obi and
    -- staff on a matching day or weather, and Orpheus's Sash at close range. Returns the set,
    -- because the merges here are unnamed slot writes rather than reported layers.
    --
    -- Cures take a different path from everything else, and that is the split below. A cure
    -- benefits from a light-element bonus, and Cura and Curaga alone can also use a cape --
    -- so the cure arm is written for those items rather than reusing the general one.
    function elemental_check(spell, built_set)
        if spell.name:contains('Cure') or spell.name:contains('Cura') then
            if world.weather_element == spell.element or spell.element == world.day_element then
                -- Asked once, before either arm, because both want the same three answers.
                local Obi = have_item("Hachirin-no-Obi")
                local Staff = have_item("Chatoyant Staff")
                -- The cape is held for Cura and Curaga only. A single-target cure is better
                -- served by a cape the job file chose, and this would displace it.
                local Cape = have_item("Twilight Cape")

                -- Day and weather are checked separately and say so separately, because the
                -- player wants to know WHICH one is paying for the swap.
                if spell.element == world.day_element then
                    if Obi then merge_into(built_set, { waist = "Hachirin-no-Obi" }) end
                    if Staff then
                        merge_into(built_set, sets.Weapons['Light Bonus'])
                        merge_into(built_set, { main = "Chatoyant Staff" })
                    end
                    if Cape and spell.name:contains('Cura') then merge_into(built_set, { back = "Twilight Cape" }) end
                    info(action_tag(spell) .. '[' .. tostring(world.day_element) .. '] day - using Bonus Gear')
                elseif world.weather_element == spell.element then
                    if Obi then merge_into(built_set, { waist = "Hachirin-no-Obi" }) end
                    if Staff then
                        merge_into(built_set, sets.Weapons['Light Bonus'])
                        merge_into(built_set, { main = "Chatoyant Staff" })
                    end
                    if Cape and spell.name:contains('Cura') then merge_into(built_set, { back = "Twilight Cape" }) end
                    info(action_tag(spell) .. 'Weather is [' .. tostring(world.weather_element) .. '] - using Bonus Gear')
                end
            end
            -- Everything that is not a cure: one waist slot, and four ways to earn it.
        else
            -- Every arm below tests a world or distance condition as well as the item, so the
            -- bags are asked only once a condition could still match -- the three obi arms
            -- all imply obi_wanted, and the sash arm IS the distance test.
            local sash_wanted = spell.target and spell.target.distance
                and spell.target.model_size
                and spell.target.distance < (6 + spell.target.model_size)
            local Osash = sash_wanted and have_item("Orpheus's Sash")

            local obi_wanted = spell.element == world.day_element
                or spell.element == world.weather_element
            local Obi = obi_wanted and have_item("Hachirin-no-Obi")

            -- Four arms for one slot, strongest bonus first: double weather, then day and
            -- weather together, then close range, then either day or weather alone. The
            -- distance arm sits third so the sash only wins where no elemental match applies.
            if spell.element == world.weather_element and world.weather_intensity == 2 and Obi then
                merge_into(built_set, { waist = "Hachirin-no-Obi" })
                info(action_tag(spell) .. 'Weather is Double [' .. world.weather_element .. '] - using Hachirin-no-Obi')
            elseif spell.element == world.day_element and spell.element == world.weather_element and Obi then
                merge_into(built_set, { waist = "Hachirin-no-Obi" })
                info(action_tag(spell) .. '[' ..
                    world.day_element .. '] day and weather is [' .. world.weather_element .. '] - using Hachirin-no-Obi')
                -- Within six yalms of the target's edge, model size included. Both fields are
                -- tested before the arithmetic: a target the client has not resolved yet --
                -- an unpicked subtarget -- carries neither, and either one nil would throw.
            elseif spell.target.distance and spell.target.model_size
                and spell.target.distance < (6 + spell.target.model_size) and Osash then
                merge_into(built_set, { waist = "Orpheus's Sash" })
                info(action_tag(spell) .. 'Distance is [' .. round(spell.target.distance, 2) .. '] using Orpheus Sash')
            elseif (spell.element == world.day_element or spell.element == world.weather_element) and Obi then
                merge_into(built_set, { waist = "Hachirin-no-Obi" })
                info(action_tag(spell) .. '[' ..
                    world.day_element .. '] day and weather is [' .. world.weather_element .. '] - using Hachirin-no-Obi')
            end
        end
        return built_set
    end

    -- Bard songs ---------------------------------------------------------------------------------

    -- The song weapon block, shared by both phases and told which one it is running in. Each
    -- phase reads its own child set, because the instrument that speeds a song up is rarely
    -- the one that makes it strong. The shield merges last and only when neither a second
    -- weapon nor a two-hander is being worn -- and not at all while either trait is still
    -- unread (nil), the same rule as the weapon-mode block above.
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

    -- The song gear ladder, and where the instrument for a song is decided. Midcast always
    -- calls it; precast calls it too while Nightingale is up, because there is no midcast
    -- window left to call it in.
    --
    -- A dummy song is the one case with no potency question at all: it exists to be
    -- overwritten by the next song, so it takes the dummy set and the count instrument and
    -- nothing else.
    function build_song_set(spell, built_set)
        if SongCount:contains(spell.name) then
            merge_named(built_set, sets.Midcast.DummySongs, 'sets.Midcast.DummySongs')
            merge_instrument(built_set, Instrument.Count, 'Instrument.Count')
        else
            -- Three kinds of real song, each with its own instrument: a set named for this
            -- song, an area sleep, an ordinary debuff, or -- falling through -- a buff, which
            -- wants the potency instrument.
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
            -- The family set goes on last, then the instrument is put back over it. Without
            -- that the family set's own range slot would displace the instrument chosen
            -- above, and a song would be sung on the wrong one.
            local song_instrument = built_set['range']
            merge_report(built_set, equip_song_gear(spell))
            if song_instrument then
                merge_into(built_set, { range = song_instrument })
            end
        end
        return built_set
    end

    -- The twenty-five song families, matched as substrings of a song's name and tested in this
    -- order. The lookup below takes the first family a name carries THAT THE CALLER DECLARED,
    -- so the order would decide the answer for a song name containing two of these -- but no
    -- spell in the game's table carries two, so today the order settles nothing. A new song
    -- that did carry two would be settled here, by position, with nothing announcing it.
    local SONG_FAMILIES = {
        'Finale', 'Lullaby', 'Threnody', 'Elegy', 'Requiem', 'March', 'Minuet',
        'Madrigal', 'Ballad', 'Scherzo', 'Mazurka', 'Paeon', 'Carol', 'Minne',
        'Mambo', 'Etude', 'Prelude', 'Dirge', 'Sirvente', 'Aria', 'Fugue',
        'Hymnus', 'Hum', 'Virelai', 'Nocturne',
    }

    -- The first family this song name carries that the given table has an entry for. Used for
    -- both gear sets and instruments, which is why the table is a parameter.
    --
    -- BEING DECLARED IS PART OF THE MATCH. A family the caller has no entry for falls through
    -- to the next candidate rather than matching and selecting nothing -- so a job file that
    -- declares only some families still gets the right answer for the ones it did declare.
    local function song_family_entry(name, declared)
        if not declared then return nil end
        for i = 1, #SONG_FAMILIES do
            local family = SONG_FAMILIES[i]
            if string.find(name, family) and declared[family] then return declared[family] end
        end
    end

    -- The gear set for this song's family, or nil. Deliberately silent: the caller merges the
    -- result, so an undeclared family becomes the merge report's head and is named there
    -- through the usual channels. Warning here would say it twice.
    function equip_song_gear(spell)
        return song_family_entry(spell.english, sets.Midcast)
    end

    -- The instrument for a Pianissimo song: the one named for its family, or the general
    -- Pianissimo instrument. Two songs return nothing at all, because they each REQUIRE a
    -- specific instrument that check_equipment_spells supplies instead -- choosing one here
    -- would displace it.
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

    -- The layers an implement yields to, by the resolver's answer: an item use, the disable
    -- hold, the strip hold, the Hoxne hold and the Sleep hold. Received gear and the weapon
    -- lock yield to the implement.
    local IMPLEMENT_YIELDS_TO = { ['ench'] = true, ['disable'] = true, ['strip'] = true,
        ['hoxne'] = true, ['sleep'] = true }

    -- The gear the engine owns for a spell, returned as a set or nil: what the spell cannot
    -- be cast without -- Daybreak for Dispelga, the two named instruments, the Impact
    -- cloaks -- and what the engine owns by design, Yagrush for a White Mage's Cursna. Not
    -- preferences a job file may override: hooks.lua merges the result OVER everything
    -- else the build chose, in both phases, and dresses it over the weapon lock. An
    -- implement yields to every layer above it in the precedence stack: when any of its
    -- slots is held by one, nothing is returned and the second return names each such slot
    -- with its holder's claim, so the caller can say why the piece did not go on. The
    -- second return is nil when nothing was refused.
    --
    -- Cursna is gated three ways -- White Mage main job, never a subjob; Yagrush carried;
    -- main free -- and the spread prediction asks this same function through
    -- wears_yagrush, so the two cannot disagree. Impact is the one with a choice, because
    -- two cloaks grant it and a character may carry either. Both clear the head slot as
    -- well -- the cloak occupies both.
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
        -- A one-handed implement in main cannot keep a two-hander's grip beside it -- the
        -- game empties the slot -- so the offhand the mode gives a one-hander, the shield,
        -- comes with it, when the slot is the implement's to take.
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

    -- Count the rounds left for this action and decide whether it may proceed. The one place
    -- in this file that CANCELS rather than dresses, and the reason it lives beside the
    -- builders: the count has to happen while the ammunition slot is still being chosen.
    --
    -- Its messages cannot be silenced by a channel toggle, deliberately: the ammunition
    -- refusals and substitutions go through notice(), the one ungated engine channel, and
    -- the low-ammo banner writes on raw chat color 167.
    function do_bullet_checks(spell, built_set)
        if spell and built_set then
            local bullet_name = built_set.ammo
            -- A gear table names its round in .name; the `empty` sentinel is one such table.
            if type(bullet_name) == 'table' then bullet_name = bullet_name.name end
            -- No named round: the slot is undeclared, being cleared, or carries an empty
            -- string, which GearSwap's expand_entry treats as "leave the slot alone". All
            -- three would spend whatever is already loaded -- a weaponskill-only round left
            -- there by a Quick Draw or the idle default -- so the action is refused, and the
            -- refusal names the shape, which is what a player with a mistyped Ammo key needs
            -- to read. '' is truthy in Lua and is not 'empty', so it is named on its own.
            if not bullet_name or bullet_name == 'empty' or bullet_name == '' then
                local shape = not bullet_name and 'undeclared'
                    or bullet_name == '' and 'blank' or 'empty'
                notice('No round named for ' .. tostring(spell.name)
                    .. ': ammo is ' .. shape .. ' in the built set. Canceling.')
                cancel_spell()
                return
            end
            log('Ammo name is: ', bullet_name)

            -- How many rounds this one action could consume. A shot under a multi-shot buff
            -- spends more than one, and Barrage the most; anything else spends a single
            -- round. The number is a floor to stay ABOVE, not the number required.
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
                -- The one ammunition a weaponskill may be finished on once its own has run
                -- out: the standard round for the ranged type currently in use. Job files
                -- spell that key .RA or .TP; anything else sitting in the slot is being held
                -- back for a purpose of its own, and the action is canceled rather than
                -- spending it.
                local type_ammo = Ammo and Ammo[state.RAMode.value]
                local standard_ammo = type_ammo and (type_ammo.RA or type_ammo.TP)

                -- Out of the chosen ammunition entirely. Two of the three ways out let the
                -- action proceed on whatever is already loaded; the third cancels it. Both
                -- cancels here owe a multibox completion they do not send -- safe today only
                -- because no ranged action is in the tracked-ability table to have announced.
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

            -- The last rounds are held back: a shot or weaponskill has to leave more than it
            -- would spend. Quick Draw is exempt because its ammunition is what is being
            -- reserved, so it is allowed to spend down to nothing.
            if spell.type ~= 'CorsairShot' and available_bullets <= bullet_min_count then
                notice('Not enough ammo.  Canceling.')
                cancel_spell()
                return
            end

            -- The low-stock banner, said ONCE. state.warned latches so a player who is nearly
            -- out is not told again on every shot, and resets only when the count climbs back
            -- above the job file's threshold -- which is what makes restocking clear it.
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

    -- Warn when the ninja tools for Utsusemi are running low. Unlike the ammunition check
    -- this only reports -- it never cancels, because casting the last shadows is exactly what
    -- a player out of tools wants to do.
    --
    -- Two tools count, and only the FIRST found is examined: the ordinary Shihei, or the
    -- Shikanofuda that stands in for a stack of them. Carrying neither reports a shortage of
    -- zero, which is the honest answer.
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
            -- Repeated on every cast, unlike the ammunition banner, which latches. A tool
            -- count only falls, so there is no restock to reset against.
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

    -- Only three, because almost everything this file offers is a global the action hooks
    -- call by name rather than an E field. These three are exported instead, and hooks.lua
    -- binds all of them as file-locals at construction like any other cross-component
    -- dependency.
    E.apply_weapon_mode = apply_weapon_mode
    E.build_current_set = build_current_set
    E.wears_yagrush = wears_yagrush

    -- Version stamp, asserted by the root against the engine's own version constant. A stale
    -- copy of this file shadowing the current one announces itself at load, not later.
    return '2.0'
end
