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
-- COMPONENT: hoxne -- section 14: Hoxne Ampulla automation, and the prerender driver
----------------------------------------------------------------------------------------------------
-- CONTENTS
--   Section 14 - Hoxne Ampulla automation. The critical-action tables and the three
--   questions asked of them, the gated job-ability path for Tomahawk and Angon, the
--   Ampulla equip/release/relock steps, the once-a-second tick, and the prerender driver.
--
-- WHAT IT DOES  While a Hoxne mode is on, the Ampulla is kept in the ammo slot, used
--          whenever its enchantment is down and it is ready, and put back whenever anything
--          knocks it out. ON-Locked holds range and ammo outright; ON-Allow Critical opens
--          a window for the handful of things that genuinely need those slots -- bard
--          songs, Geomancy, Tomahawk, Angon and a Sleep set's drain implement -- and takes
--          them back afterwards.
--
-- THE PRERENDER DRIVER IS THIS FILE'S MOST IMPORTANT EXPORT. It runs THREE subsystems at
--          three rates from one handler: the enchanted-item tick every 0.25 s, the Hoxne
--          tick every 1 s, and the gated-ability tick every 0.1 s while one is in flight.
--          It is one of only two prerender registrations in the engine, kept apart from the
--          other so a fault in one cannot take down the other's protected call.
--
-- THE RAW-HANDLER CONSTRAINT governs the whole file. A prerender handler is raw, and an
--          equip() issued from a raw handler is DISCARDED. So nothing on the tick path
--          changes gear directly: it sends itself a self command, and the wrapped command
--          handler does the equipping. Any function below marked "call from a wrapped
--          event" is one of those landing points; calling it from the tick has no effect.
--
--          player.equipment is also stale on this path, refreshed only when a wrapped event
--          begins. Where a decision must be right, worn state comes from the bag copy's
--          status byte instead. The tick's slot-repair test is the one deliberate exception
--          -- it reads player.equipment.ammo, and a stale reading there costs at worst one
--          redundant relock a second later.
--
-- STATE    The mutable Hoxne state is the `hoxne` table, and it is declared in the EQUIP
--          component, not here -- slot ownership needs it, so it lives with slot ownership.
--          Seven files reference it. This file owns only ench_next_check.
-- EXPORTS  Nine functions plus hoxne_prerender. Four go to commands (use_gated_ja and the
--          three wrapped landing points), three to hooks (the refusal message, the forced
--          slot and the window's resume deadline, which th's interrupt path also reads),
--          two to spellreceived (the Sleep hold's window open and close), and the driver
--          to the root. critical_action_for is a global, called four times from hooks.
-- LOADS    Sixth of fifteen, deliberately AFTER enchant: five of its imports come from the
--          enchanted-item engine, which this is built on top of. equip_set_command resolves
--          LATE -- it is declared in the root, fifteenth.

-- requires: rahvings/state, rahvings/core, rahvings/equip, rahvings/enchant
return function(E)
    -- Immutable dependencies bound once at construction, so no call below repeats the lookup
    -- for them. The cross-component mutables are never bound here: ench_active and is_moving
    -- are reached through E at every touch, because a file-local copy would not be the one
    -- the other components read and write.
    -- The Ampulla is 'Hoxne Ampulla', its enchantment is buff 162, and the equip lockout is
    -- 9 seconds -- the item's 5 second equip delay plus server latency and a margin.
    local BUFF_ENCHANTMENT, CANON_SLOT, ENCH_BAGS = E.BUFF_ENCHANTMENT, E.CANON_SLOT, E.ENCH_BAGS
    local HOXNE_AMPULLA, HOXNE_EQUIP_LOCKOUT      = E.HOXNE_AMPULLA, E.HOXNE_EQUIP_LOCKOUT
    local TYPE_JA, res, gs_equip, hoxne, hoxne_on = E.TYPE_JA, E.res, E.gs_equip, E.hoxne, E.hoxne_on
    local enchantment_tick, enchantment_waits     = E.enchantment_tick, E.enchantment_waits
    local find_enchantment, warn_unavailable      = E.find_enchantment, E.warn_unavailable
    local slot_claim                              = E.slot_claim

    -- The enchanted-item tick's own clock, the one piece of state this file owns outright.
    -- Everything else it schedules against lives in the shared hoxne table.
    local ench_next_check = 0
    ------------------------------------------------------------------------------------------------
    -- SECTION 14 - HOXNE AMPULLA AUTOMATION
    ------------------------------------------------------------------------------------------------
    -- Two jobs that share one set of state: keeping the Ampulla worn and used, and standing
    -- aside for an action that genuinely needs the slot it is holding.

    -- The actions allowed to borrow a slot under ON-Allow Critical. Job abilities are keyed
    -- by ability id and everything else by spell type, because that is how each arrives.
    -- Tomahawk (item 18258) and Angon (18259) take AMMO and are handed back the moment the
    -- ability resolves. Instruments and handbells take RANGE and resume on a delay instead,
    -- because songs and Geomancy are cast in waves -- reclaiming the slot between two casts
    -- would fight the player for the whole rotation.
    local CRITICAL_JA = {
        [150] = { slot = 'ammo', force = 'Thr. Tomahawk', item_id = 18258, resume = 'aftercast' },
        [170] = { slot = 'ammo', force = 'Angon', item_id = 18259, resume = 'aftercast' },
    }
    local CRITICAL_TYPE = {
        ['BardSong'] = { slot = 'range', resume = 'delay', delay = 5 },
        ['Geomancy'] = { slot = 'range', resume = 'delay', delay = 5 },
    }

    -- The critical-action entry for an action, or nil if it is not one. A global rather than
    -- an export because the action hooks ask it four times across the cast pipeline.
    function critical_action_for(spell)
        if not spell then return nil end
        if spell.type == TYPE_JA then return CRITICAL_JA[spell.id] end
        return CRITICAL_TYPE[spell.type]
    end

    -- How long a critical window stays open once its action is over, whichever way the
    -- action ended. Songs and Geomancy get their full debounce so a whole rotation reads as
    -- one window; a job ability resumes almost at once, because nothing follows it. Applied
    -- by aftercast, by precast's busy gate, and by the action handler's interrupt path, which
    -- reads the window's recorded owner -- so a nil entry takes the ability's half second
    -- rather than raising inside a raw handler.
    local function hoxne_resume_deadline(crit)
        local resume = crit and crit.resume
        return os.clock() + ((resume == 'delay') and (crit.delay or 5) or 0.5)
    end

    -- The reason ON-Locked turns a gated ability down, or nil when it does not turn it down.
    --
    -- Written once and shared by both entry points -- the command and a typed /ja -- so the
    -- two can never drift into different explanations of the same refusal. It exists at all
    -- because the alternative is silence: ON-Locked holds the slot disabled, so the equip is
    -- diverted, the action reaches the server wearing nothing, and the server's own refusal
    -- names the character and no reason whatsoever.
    local function hoxne_locked_refusal(ja_id)
        if state.Hoxne.value ~= 'ON-Locked' then return nil end
        local crit = CRITICAL_JA[ja_id]
        if not crit then return nil end
        local row = res.job_abilities[ja_id]
        return ('Hoxne ON-Locked holds %s. Use ON-Allow Critical or OFF for %s.')
            :format(crit.slot, (row and row.en) or tostring(ja_id))
    end

    -- The slot and item a gated ability needs forced into place, or nil when the set already
    -- handles it. Asked during the build so the throwing item is not overwritten by whatever
    -- the job file's own sets would have put in that slot.
    local function critical_force_slot(built_set, spell)
        if not spell or spell.type ~= TYPE_JA then return nil end
        local crit = CRITICAL_JA[spell.id]
        if not crit or not crit.force then return nil end
        local want = CANON_SLOT[crit.slot] or crit.slot
        if type(built_set) == 'table' then
            for k, v in pairs(built_set) do
                local canon = type(k) == 'string' and CANON_SLOT[k:lower()]
                if canon == want then
                    -- Only the ability's OWN item counts as already dressed. Any other
                    -- ammo in that slot leaves the action unusable, and this case is
                    -- routine rather than exotic: an empty sets.JA entry falls back to a
                    -- more general set, which dresses the slot with ordinary ammo.
                    local name = (type(v) == 'table' and v.name) or v
                    if type(name) == 'string' and name:lower() == crit.force:lower() then
                        return nil
                    end
                    return want, crit.force
                end
            end
        end
        return want, crit.force
    end

    -- The one gated ability waiting for its throwing item to be confirmed worn, or nil when
    -- none is in flight. Only ever set for the few hundred milliseconds an equip takes.
    local gated_ja = nil

    -- Fire the pending ability the instant the item's bag copy reports itself worn.
    --
    -- The bag status byte is LIVE SERVER STATE -- it is the same thing the client tests a
    -- typed /ja against -- so the ability follows the confirmation rather than a guessed
    -- timer. That is the difference between firing one round trip after the equip and either
    -- firing too early into a refusal or waiting out a pessimistic delay.
    local function gated_ja_tick(now)
        local st = gated_ja
        if now > st.deadline then
            gated_ja = nil
            warn(st.item_name .. ' never equipped. ' .. st.ja_name .. ' not used.')
            return
        end
        -- Every equippable bag, not just the one the item was found in. GearSwap equips
        -- whichever stack it picks, so watching a single recorded bag would let the
        -- deadline expire on an item that is already worn out of another wardrobe.
        -- The bag copy's status byte is used rather than player.equipment because this
        -- decision must be right the first time: firing the ability against a stale reading
        -- sends it to a server that will refuse it.
        for _, bag_id in ipairs(ENCH_BAGS) do
            local bag = windower.ffxi.get_items(bag_id)
            if bag then
                for _, it in ipairs(bag) do
                    if type(it) == 'table' and it.id == st.item_id and it.status == 5 then
                        gated_ja = nil
                        log('/ja "', st.ja_name, '" <t>')
                        windower.chat.input('/ja "' .. st.ja_name .. '" <t>')
                        return
                    end
                end
            end
        end
    end

    -- Equip a job ability's throwing item, then issue the ability once that equip is
    -- confirmed. Backs gs c tomahawk and gs c angon.
    --
    -- Every refusal is answered before any gear moves, in this order: the ON-Locked hold,
    -- the ability being unusable by this character, the ability being on cooldown, and the
    -- item not being carried. That ordering is the point of the function -- moving gear for
    -- an action that cannot fire parks the wrong ammo for the whole watchdog window.
    --
    -- CALL ONLY FROM A WRAPPED EVENT; it equips.
    local function use_gated_ja(ja_id)
        local crit = CRITICAL_JA[ja_id]
        local ja_name = res.job_abilities[ja_id].en
        local refusal = hoxne_locked_refusal(ja_id)
        if refusal then
            notice(refusal)
            return
        end
        local recasts = windower.ffxi.get_ability_recasts()
        local wait = recasts and recasts[res.job_abilities[ja_id].recast_id]
        -- ABSENT IS NOT ZERO, and this is the trap the whole guard exists for. The recast
        -- table omits every ability the character cannot use, and carries a usable one at 0
        -- even when it is ready -- so a missing key means "cannot use", never "off
        -- cooldown". Reading it with `or 0` inverts that and moves gear for an ability the
        -- server will refuse, after which the watchdog blames the equip three seconds later
        -- and sends the player looking for an item they already have.
        if not wait then
            notice(('%s is not available (wrong job or level).'):format(ja_name))
            return
        end
        if wait > 0 then
            notice(('%s is on cooldown [%d:%02d].'):format(ja_name, math.floor(wait / 60), math.floor(wait % 60)))
            return
        end
        -- Every stack in every equippable bag, and the scan does not stop at the first id
        -- match. These items expend from wherever they are equipped, wardrobes included, so
        -- a worn copy anywhere settles the question -- while stopping early would read a
        -- worn later stack as merely carried and then wait out the full deadline for an
        -- equip that had already happened.
        local carried, worn = false, false
        for _, bag_id in ipairs(ENCH_BAGS) do
            local bag = windower.ffxi.get_items(bag_id)
            if bag then
                for _, it in ipairs(bag) do
                    if type(it) == 'table' and it.id == crit.item_id then
                        carried = true
                        if it.status == 5 then
                            worn = true
                            break
                        end
                    end
                end
            end
            if worn then break end
        end
        if not carried then
            notice(crit.force .. ': not found in inventory or wardrobes.')
            return
        end
        if state.Hoxne.value == 'ON-Allow Critical' then
            hoxne.window  = true
            hoxne.owner   = crit
            hoxne.expires = os.clock() + 20 -- watchdog; aftercast sets the real countdown
        end
        if worn then
            -- Already worn, so the client will accept the ability immediately and there is
            -- nothing to wait on. Skips the tick entirely.
            windower.chat.input('/ja "' .. ja_name .. '" <t>')
            return
        end
        equip({ [crit.slot] = crit.force })
        notice('Equipping [' .. crit.force .. '] and using [' .. ja_name .. ']')
        gated_ja = {
            item_id    = crit.item_id,
            item_name  = crit.force,
            ja_name    = ja_name,
            deadline   = os.clock() + 3,
            next_check = 0,
        }
    end

    -- Put the Ampulla back and re-assert the hold.
    --
    -- Under ON-Locked the enable, equip and disable must all happen in THAT order and
    -- inside ONE event. The slot is held disabled, so equipping without enabling first is
    -- diverted; and leaving it enabled past the end of the event lets whatever gear is
    -- parked for the current state win the flush instead. CALL ONLY FROM A WRAPPED EVENT.
    --
    -- A disable or strip hold on EITHER slot stands this down entirely and nothing is
    -- opened: the ON-Locked enable would hand a held slot back to the builders. The
    -- stand-down is here rather than only in the callers because gs c hoxnerelock has no
    -- guard of its own and the tick's critical-window branch sends that command from
    -- above the tick's own guard. It says nothing -- the tick can reach it once a second.
    local function hoxne_equip_ampulla()
        local range_claim, ammo_claim = slot_claim('range'), slot_claim('ammo')
        if range_claim == 'disable' or range_claim == 'strip'
            or ammo_claim == 'disable' or ammo_claim == 'strip' then
            return
        end
        if state.Hoxne.value == 'ON-Locked' then
            enable('range', 'ammo')
            gs_equip({ range = empty, ammo = HOXNE_AMPULLA })
            disable('range', 'ammo')
        else
            gs_equip({ range = empty, ammo = HOXNE_AMPULLA })
        end
    end

    -- Re-arm the lockout that stops a use being attempted too soon after the engine's own
    -- re-equip, and hand back the recast still to run so the caller can report it.
    --
    -- Two different waits are in play and the larger governs. Re-equipping restarts the
    -- item's equip delay, but an outstanding recast may outlast it. The equip lockout is
    -- also a floor rather than merely one of the two candidates: immediately after an equip
    -- the item's extdata still reports the PREVIOUS activation, so a recast read in that
    -- moment cannot be trusted on its own.
    local function hoxne_arm_use_lockout()
        local _, hx_ext = find_enchantment(HOXNE_AMPULLA)
        local hx_recast = enchantment_waits(hx_ext) or 0
        hoxne.use_not_before = os.clock() + math.max(HOXNE_EQUIP_LOCKOUT, hx_recast)
        return hx_recast
    end

    -- Free an Ampulla left stranded in the ammo slot, one step per call, returning what it
    -- did so the caller can decide whether to come back.
    --
    -- This is the reload recovery. A reload resets the mode to OFF but cannot unequip, so
    -- the Ampulla can be left worn with no set able to displace it. Two steps are needed
    -- rather than one: GearSwap's model of what is equipped disagrees with reality after a
    -- reload, so step one re-asserts the gear that is TRULY worn to resync the model, and
    -- only then can step two release through it. CALL FROM A WRAPPED EVENT.
    local function hoxne_release_step()
        local _, _, carried, equipped = find_enchantment(HOXNE_AMPULLA)
        if carried and not equipped then return 'done' end
        -- A missing item is INCONCLUSIVE, not finished. Bags read as empty for a few
        -- seconds after zoning, so treating "not found" as done would abandon a genuinely
        -- stranded Ampulla. The bounded retry count is what settles it either way.
        if not carried then return 'wait' end
        if player.equipment.ammo ~= HOXNE_AMPULLA then
            -- Both halves of the true state are known without reading anything: a worn
            -- Ampulla rules out a range implement, and both ON modes held range empty.
            -- That is what makes it safe to assert the pair rather than query for them.
            gs_equip({ range = empty, ammo = HOXNE_AMPULLA })
            return 'resync'
        end
        gs_equip({ ammo = empty })
        equip_set_command()
        return 'release'
    end

    -- Close the critical window and put the Ampulla back. The work is routed through a self
    -- command rather than done here, because this is reached from the raw tick, where an
    -- equip would be discarded.
    local function hoxne_relock()
        hoxne.window = false
        windower.send_command('gs c hoxnerelock')
        log('Hoxne: critical window closed, re-locking Ampulla.')
    end

    -- Being slept borrows the window too. ON-Allow Critical strips range and ammo from
    -- every equip while no window is open, so a Sleep set naming either would lose it: a
    -- song opens the window for its instrument, and the Sleep hold opens it for these two.
    -- The entry gives the interrupt path a song's five-second resume rather than an
    -- ability's half second. The watchdog closes a window the sleep outlasts, and that
    -- costs nothing: by then the slot is held disabled, so the relock's range write is
    -- diverted until the wake hands the slot back and relocks again.
    local CRITICAL_SLEEP = { slot = 'range', resume = 'delay', delay = 5 }

    -- Whether a set of slots, keyed by any spelling, names range or ammo -- the two the
    -- filter strips, and the only reason the Sleep hold touches the window at all.
    local function names_range_or_ammo(slots)
        for slot in pairs(slots) do
            local canon = CANON_SLOT[slot] or (type(slot) == 'string' and CANON_SLOT[slot:lower()])
            if canon == 'range' or canon == 'ammo' then return true end
        end
        return false
    end

    -- Open the window for the slots the Sleep hold is about to take. Only under
    -- ON-Allow Critical, and only when range or ammo is among them: a hold on main alone
    -- leaves the tick to its work. CALL BEFORE THE EQUIP. Returns whether it opened.
    local function hoxne_sleep_open(taken)
        if state.Hoxne.value ~= 'ON-Allow Critical' or not names_range_or_ammo(taken) then
            return false
        end
        hoxne.window  = true
        hoxne.owner   = CRITICAL_SLEEP
        hoxne.expires = os.clock() + 20 -- watchdog; the wake closes it, or this does
        log('Hoxne: critical window open for Sleep gear')
        return true
    end

    -- The wake's half: close the window and put the Ampulla back, which is also what clears
    -- range -- nothing else writes that slot under this mode, so the drain implement would
    -- stay worn after waking otherwise. Keyed on the mode as it stands now and on what the
    -- hold covered, never on whether the open above ran: a window the watchdog already
    -- closed still needs the relock, and a mode switched off mid-sleep needs nothing.
    -- Returns whether it relocked.
    local function hoxne_sleep_close(held)
        if state.Hoxne.value ~= 'ON-Allow Critical' or not names_range_or_ammo(held) then
            return false
        end
        hoxne_relock()
        return true
    end

    -- The once-a-second tick. Four jobs in a deliberate order: close an expired critical
    -- window, re-assert the hold, repair the slot when the game clears it, and use the item
    -- once its enchantment has dropped and it is ready.
    --
    -- Read the early returns as a precedence list. Each one is a state in which acting would
    -- be wrong rather than merely wasteful, and every one of them has cost something.
    local function hoxne_tick(now)
        if not hoxne_on() then
            -- Mode OFF still has work: a reload cannot unequip, so the Ampulla may be worn
            -- with no set able to displace it. This branch only PACES the attempts -- the
            -- wrapped command does the releasing, and zeroes the count once the slot is
            -- confirmed free.
            if hoxne.release_tries > 0 and now >= hoxne.release_next then
                hoxne.release_next  = now + 2
                hoxne.release_tries = hoxne.release_tries - 1
                windower.send_command('gs c hoxnerelease')
            end
            return
        end

        -- While a critical window is open this tick is a PASSIVE OBSERVER. It compares the
        -- clock and nothing else -- it neither reads nor writes equipment -- so a borrowed
        -- instrument, handbell or throwing item cannot be overwritten before the window
        -- closes. Adding any equipment access above this return breaks the whole feature.
        if hoxne.window then
            if now >= hoxne.expires then hoxne_relock() end
            return
        end

        -- An item use in progress owns its slot outright and outranks this.
        if E.ench_active then return end

        -- A disable or strip hold outranks this too: the Ampulla is off the body, or held
        -- where it is, for as long as either stands, and the repair below must not move it.
        -- BOTH slots are asked, because a hold can stand on range alone -- gs c disable
        -- range, or a naked hold while an item use has ammo. The hold's release re-takes
        -- the slots on the next tick, within a second, exactly as gs c enableall does.
        local range_claim, ammo_claim = slot_claim('range'), slot_claim('ammo')
        if range_claim == 'strip' or range_claim == 'disable'
            or ammo_claim == 'strip' or ammo_claim == 'disable' then
            return
        end

        -- ON-Locked re-asserts its hold on every tick. It is cheap, and it makes the hold
        -- self-healing: gs c enableall is a deliberate manual override, and this is what
        -- takes the slots back a second later. ON-Allow Critical must NEVER disable here --
        -- that is the entire difference between the two modes.
        if state.Hoxne.value == 'ON-Locked' then
            disable('range', 'ammo')
        end

        -- Placed ABOVE the repair branch on purpose. The ammo slot cannot be filled while
        -- dead, so a death with the Ampulla displaced would otherwise scan every bag and
        -- send a relock every two seconds until the character is raised. The hold above
        -- still re-asserts, so nothing is lost by stopping here.
        if player.status == 'Dead' or player.status == 'Engaged dead' then return end

        -- Neither hold can stop the GAME from clearing the slot. Equipping an instrument
        -- empties ammo as a side effect, and an in-game /equipset bypasses GearSwap
        -- entirely -- so the slot is repaired here rather than assumed intact. Routed
        -- through a self command because an equip from this raw handler is discarded.
        if player.equipment.ammo ~= HOXNE_AMPULLA then
            local _, _, carried = find_enchantment(HOXNE_AMPULLA)
            if not carried then return end
            windower.send_command('gs c hoxnerelock')
            hoxne.next_check = now + 2
            return
        end

        -- The enchantment is still up, so there is nothing to renew.
        if buffactive[BUFF_ENCHANTMENT] then return end
        -- Mid-action in any sense: the use would be refused or would fight the action.
        if is_Busy or E.is_moving or midaction() or pet_midaction() then return end
        -- The client refuses item use while mounted. This returns WITHOUT arming any
        -- throttle below, so the first tick after dismounting retries immediately rather
        -- than serving out a delay that was set during the ride.
        if buffactive['Mounted'] then return end

        -- Inside the lockout window after the engine's own re-equip, where the item is not
        -- yet usable and its extdata cannot be trusted.
        if now < hoxne.use_not_before then return end

        -- The bag-scan throttle. Scanning every bag is the expensive part of this tick, so
        -- it is skipped during a known recast gap. This gates the SCAN only -- the tick
        -- itself still runs once a second and the hold above still re-asserts.
        if now < hoxne.recheck_at then return end

        local row, ext = find_enchantment(HOXNE_AMPULLA)
        if not row then return end
        local recast, activation = enchantment_waits(ext)
        recast, activation = recast or 0, activation or 0
        if recast > 0 then
            warn_unavailable(row, recast)
            hoxne.recheck_at = now + math.min(recast, 5)
            return
        end
        if activation > 0 then
            -- An equip delay, not a cooldown. It resolves on its own in a few seconds and
            -- the player has done nothing wrong, so it is waited out silently -- unlike the
            -- recast above, which is reported.
            hoxne.recheck_at = now + math.min(activation, 5)
            return
        end
        -- The throttle is armed BEFORE the use, on the assumption that it lands. If it did,
        -- the enchantment buff short-circuits this function long before the gate matters;
        -- if it did not, the capped wait means a retry within five seconds either way.
        hoxne.recheck_at = now + math.min(row.recast_delay or 60, 5)

        log('/item "', HOXNE_AMPULLA, '" <me>')
        windower.chat.input('/item "' .. HOXNE_AMPULLA .. '" <me>')
    end


    -- The prerender driver: three subsystems, three rates, one handler.
    --
    --   enchanted-item tick   every 0.25 s   always
    --   Hoxne tick            every 1.00 s   always
    --   gated-ability tick    every 0.10 s   only while an equip is in flight
    --
    -- Built as a closure here so every name it touches on this per-frame path stays an
    -- upvalue rather than a global lookup; the root registers it. This is a RAW handler,
    -- which is what forbids equipment changes anywhere below it -- see the file header.
    E.hoxne_prerender = function()
        local now = os.clock()
        if now >= ench_next_check then
            ench_next_check = now + 0.25
            enchantment_tick(now)
        end
        if now >= hoxne.next_check then
            hoxne.next_check = now + 1.0
            hoxne_tick(now)
        end
        -- gated_ja is non-nil only for the few hundred milliseconds an equip is in flight,
        -- so the steady-state cost of this third tick is a single nil test per frame.
        if gated_ja and now >= gated_ja.next_check then
            gated_ja.next_check = now + 0.1
            gated_ja_tick(now)
        end
    end

    -- Handed to E. The first three go to the action hooks, which ask them during a cast (the
    -- deadline rule also to the action handler's interrupt path); the next two to the
    -- spell-received component, whose Sleep hold borrows the window; the last four go to the
    -- commands component: use_gated_ja, which backs the two typed gated-ability commands,
    -- and three WRAPPED LANDING POINTS the raw tick reaches by sending itself a self command.
    E.hoxne_locked_refusal = hoxne_locked_refusal
    E.critical_force_slot = critical_force_slot
    E.hoxne_resume_deadline = hoxne_resume_deadline
    E.hoxne_sleep_open = hoxne_sleep_open
    E.hoxne_sleep_close = hoxne_sleep_close
    E.use_gated_ja = use_gated_ja
    E.hoxne_equip_ampulla = hoxne_equip_ampulla
    E.hoxne_arm_use_lockout = hoxne_arm_use_lockout
    E.hoxne_release_step = hoxne_release_step

    -- Version stamp. The root asserts this against Rahvin_GS, so a stale copy of this file
    -- announces itself at load instead of running.
    return '2.0'
end
