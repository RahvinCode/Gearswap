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
--   Ampulla's equip, release and relock steps, the Sleep hold's window, the once-a-second
--   tick, and the prerender driver.
--
-- While a Hoxne mode is on, the Ampulla is kept in the ammo slot, used whenever its
-- enchantment is down and the item is ready, and put back whenever something knocks it
-- out. ON-Locked holds range and ammo outright. ON-Allow Critical opens a window for the
-- few actions that need those slots, and takes the slots back afterwards. Those actions
-- are bard songs, Geomancy, Tomahawk, Angon, and the Sleep hold when its set names range
-- or ammo.
--
-- The prerender driver at the end of this file runs three ticks at three rates from one
-- handler: the enchanted-item tick every 0.25 seconds, the Hoxne tick every second, and the
-- gated-ability tick every 0.1 seconds while one is in flight. The root registers it apart
-- from the spell-received failsafe, so an error in one leaves the other running.
--
-- The driver is a raw handler, and GearSwap discards an equip issued there. So no tick
-- changes gear directly. A tick sends a self command instead, and the command's wrapped
-- handler does the equipping. A function below marked "call only from a wrapped event" is
-- one of those landing points, and calling it from a tick has no effect.
--
-- player.equipment is stale inside a raw handler too, because GearSwap refreshes it only
-- when a wrapped event begins. Where a decision must be right, worn state comes from the
-- status byte of the item's bag copy. The tick's slot-repair test is the one exception. It
-- reads player.equipment.ammo, and a stale reading costs at most one extra relock a second
-- later.
--
-- STATE    The Hoxne state is the hoxne table, which the equip component declares beside
--          slot ownership. This file owns only ench_next_check and gated_ja.
-- EXPORTS  hoxne_locked_refusal, critical_force_slot and hoxne_resume_deadline go to hooks,
--          and th's interrupt path also takes hoxne_resume_deadline. hoxne_sleep_open and
--          hoxne_sleep_close go to spellreceived. use_gated_ja goes to commands, with
--          hoxne_equip_ampulla, hoxne_arm_use_lockout and hoxne_release_step for its
--          hoxnerelock, hoxnerelease and hoxne handlers. The root takes E.hoxne_prerender.
-- GLOBALS  critical_action_for, which the action hooks call.
-- LOADS    After the enchanted item engine, whose bag list, item lookup, timing read,
--          cooldown warning and tick it imports. equip_set_command is a global from the
--          root, which loads last, and resolves when called.

-- requires: rahvings/state, rahvings/core, rahvings/equip, rahvings/enchant
return function(E)
    -- The exports this file uses, bound once at construction. The shared mutable fields
    -- ench_active and is_moving are never bound here. They are read through E at every use,
    -- because a local copy would not be the one the other components write.
    local BUFF_ENCHANTMENT, CANON_SLOT, ENCH_BAGS = E.BUFF_ENCHANTMENT, E.CANON_SLOT, E.ENCH_BAGS
    local HOXNE_AMPULLA, HOXNE_EQUIP_LOCKOUT      = E.HOXNE_AMPULLA, E.HOXNE_EQUIP_LOCKOUT
    local TYPE_JA, res, gs_equip, hoxne, hoxne_on = E.TYPE_JA, E.res, E.gs_equip, E.hoxne, E.hoxne_on
    local enchantment_tick, enchantment_waits     = E.enchantment_tick, E.enchantment_waits
    local find_enchantment, warn_unavailable      = E.find_enchantment, E.warn_unavailable
    local slot_claim                              = E.slot_claim

    -- When the driver next runs the enchanted-item tick. The Hoxne tick's own clock is
    -- hoxne.next_check.
    local ench_next_check = 0
    ------------------------------------------------------------------------------------------------
    -- SECTION 14 - HOXNE AMPULLA AUTOMATION
    ------------------------------------------------------------------------------------------------
    -- Two jobs that share one set of state: keeping the Ampulla worn and used, and standing
    -- aside for an action that needs the slot it is holding.

    -- The actions allowed to borrow a slot under ON-Allow Critical. Job abilities are keyed
    -- by ability id, 150 Tomahawk and 170 Angon, and everything else by spell type. The two
    -- abilities borrow ammo for their throwing items, Thr. Tomahawk (item 18258) and Angon
    -- (item 18259), and give it back half a second after the ability ends. Songs and
    -- Geomancy borrow range for the instrument or handbell and give it back five seconds
    -- after the last cast, so a rotation of casts is one window.
    local CRITICAL_JA = {
        [150] = { slot = 'ammo', force = 'Thr. Tomahawk', item_id = 18258, resume = 'aftercast' },
        [170] = { slot = 'ammo', force = 'Angon', item_id = 18259, resume = 'aftercast' },
    }
    local CRITICAL_TYPE = {
        ['BardSong'] = { slot = 'range', resume = 'delay', delay = 5 },
        ['Geomancy'] = { slot = 'range', resume = 'delay', delay = 5 },
    }

    -- The critical-action entry for an action, or nil when it is not one. A global, which the
    -- action hooks call at pretarget, precast and aftercast.
    function critical_action_for(spell)
        if not spell then return nil end
        if spell.type == TYPE_JA then return CRITICAL_JA[spell.id] end
        return CRITICAL_TYPE[spell.type]
    end

    -- The clock time at which a critical window closes once its action is over, however the
    -- action ended. An entry that resumes on a delay, a song or Geomancy, keeps the window
    -- open for that delay, so a rotation reads as one window. Anything else closes it after
    -- half a second. Applied by aftercast, by precast's busy gate and by the action
    -- handler's interrupt path. The interrupt path passes the window's recorded owner, so a
    -- nil entry must take the half second rather than raise inside a raw handler.
    local function hoxne_resume_deadline(crit)
        local resume = crit and crit.resume
        return os.clock() + ((resume == 'delay') and (crit.delay or 5) or 0.5)
    end

    -- The line explaining why ON-Locked refuses a gated ability, or nil when it does not.
    -- The tomahawk and angon commands and a typed /ja at precast all use it, so they give
    -- the same reason. Without it the ability would go out with its slot still held, and
    -- the server refuses it without saying why.
    local function hoxne_locked_refusal(ja_id)
        if state.Hoxne.value ~= 'ON-Locked' then return nil end
        local crit = CRITICAL_JA[ja_id]
        if not crit then return nil end
        local row = res.job_abilities[ja_id]
        return ('Hoxne ON-Locked holds %s. Use ON-Allow Critical or OFF for %s.')
            :format(crit.slot, (row and row.en) or tostring(ja_id))
    end

    -- The slot and item a gated ability needs forced into place, or nil when the built set
    -- already wears the ability's own item there. Precast asks after every merge, so the
    -- throwing item replaces whatever the sets put in that slot.
    local function critical_force_slot(built_set, spell)
        if not spell or spell.type ~= TYPE_JA then return nil end
        local crit = CRITICAL_JA[spell.id]
        if not crit or not crit.force then return nil end
        local want = CANON_SLOT[crit.slot] or crit.slot
        if type(built_set) == 'table' then
            for k, v in pairs(built_set) do
                local canon = type(k) == 'string' and CANON_SLOT[k:lower()]
                if canon == want then
                    -- Only the ability's own item counts as already dressed. Any other ammo
                    -- leaves the ability unusable, and that is the common case: an empty
                    -- sets.JA entry falls back to a general set that names ordinary ammo.
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

    -- The gated ability waiting for its throwing item to show as worn, or nil. It is set only
    -- while that equip is in flight, and cleared by its three-second deadline at the latest.
    local gated_ja = nil

    -- Fire the pending ability as soon as the item's bag copy reports it worn, or give up at
    -- the deadline with a warning.
    --
    -- The bag status byte is live server state, the same state the client tests a typed /ja
    -- against. So the ability fires one round trip after the equip, on the confirmation
    -- rather than on a guessed timer.
    local function gated_ja_tick(now)
        local st = gated_ja
        if now > st.deadline then
            gated_ja = nil
            warn(st.item_name .. ' never equipped. ' .. st.ja_name .. ' not used.')
            return
        end
        -- Every equippable bag is scanned, because GearSwap equips whichever stack it picks
        -- and the worn copy may be in any wardrobe. Status 5 on a bag copy means worn.
        -- player.equipment is not used, because a stale reading would fire the ability into
        -- a refusal.
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

    -- Equip a job ability's throwing item, then issue the ability once the equip is
    -- confirmed. Backs gs c tomahawk and gs c angon. Call only from a wrapped event, because
    -- it equips.
    --
    -- Every refusal is answered before any gear moves, in this order: the ON-Locked hold,
    -- an ability this character cannot use, a recast still running, and an item not carried.
    -- Gear moved for an ability that cannot fire would leave the wrong ammo on for the whole
    -- watchdog window.
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
        -- An absent key is not zero. The recast table omits every ability the character
        -- cannot use and lists a usable one at 0 when it is ready, so a missing key means
        -- the ability is unavailable. Read with `or 0`, it would move gear for an ability the
        -- server will refuse, and the deadline warning three seconds later would wrongly
        -- blame the equip.
        if not wait then
            notice(('%s is not available (wrong job or level).'):format(ja_name))
            return
        end
        if wait > 0 then
            notice(('%s is on cooldown [%d:%02d].'):format(ja_name, math.floor(wait / 60), math.floor(wait % 60)))
            return
        end
        -- Every stack in every equippable bag, and the scan goes past the first match. A
        -- worn copy in any bag settles the question. Stopping at the first match would read
        -- a worn later stack as merely carried, and the tick would then wait out the full
        -- deadline for an equip that had already happened.
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
            hoxne.expires = os.clock() + 20 -- a watchdog, until aftercast sets the real countdown
        end
        if worn then
            -- Already worn, so the ability is issued at once and the tick is not needed.
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

    -- Put the Ampulla back and re-assert the hold. Call only from a wrapped event.
    --
    -- Under ON-Locked the enable, the equip and the disable must run in that order and
    -- inside one event. The slot is held disabled, so an equip without the enable is
    -- diverted. A slot left enabled past the end of the event lets the gear parked for the
    -- current state win the flush instead.
    --
    -- A disable or strip hold on either slot stands this down entirely, because the
    -- ON-Locked enable would open a slot that hold keeps shut. The test lives here and not
    -- only in the callers, because the hoxnerelock handler has no hold test of its own and
    -- the tick's critical-window branch sends that command from above the tick's hold test.
    -- It prints nothing, since the tick can reach it once a second.
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

    -- Re-arm the lockout that stops a use from being tried too soon after the engine's own
    -- re-equip, and return the recast still to run so the caller can report it.
    --
    -- The larger of two waits governs: the equip lockout, since a re-equip restarts the
    -- item's equip delay, and any recast still running. The lockout is also a floor. Just
    -- after an equip, the item's extdata still reports the previous activation, so a recast
    -- read at that moment cannot be trusted alone.
    local function hoxne_arm_use_lockout()
        local _, hx_ext = find_enchantment(HOXNE_AMPULLA)
        local hx_recast = enchantment_waits(hx_ext) or 0
        hoxne.use_not_before = os.clock() + math.max(HOXNE_EQUIP_LOCKOUT, hx_recast)
        return hx_recast
    end

    -- Free an Ampulla left stranded in the ammo slot, one step per call. Returns 'done',
    -- 'wait', 'resync' or 'release', so the caller can decide whether to come back. Call
    -- only from a wrapped event.
    --
    -- The mode goes OFF on a reload, on a zone and on command, but nothing unequips the
    -- Ampulla, so it can be left worn. After a reload, GearSwap's record of what is worn can
    -- disagree with the game. So the first step re-asserts what is truly worn, to bring
    -- that record back in line, and only then can the second step release it.
    local function hoxne_release_step()
        local _, _, carried, equipped = find_enchantment(HOXNE_AMPULLA)
        if carried and not equipped then return 'done' end
        -- A missing item is inconclusive, not done. Bags read as empty for a few seconds
        -- after zoning, so "not found" could abandon an Ampulla that is still stranded. The
        -- bounded retry count settles it either way.
        if not carried then return 'wait' end
        if player.equipment.ammo ~= HOXNE_AMPULLA then
            -- The true state of both slots is known without a read. A worn Ampulla rules out
            -- a range item, and both ON modes held range empty, so asserting the pair is
            -- safe.
            gs_equip({ range = empty, ammo = HOXNE_AMPULLA })
            return 'resync'
        end
        gs_equip({ ammo = empty })
        equip_set_command()
        return 'release'
    end

    -- Close the critical window and send gs c hoxnerelock, whose wrapped handler puts the
    -- Ampulla back. The tick reaches this from a raw handler, where an equip is discarded.
    local function hoxne_relock()
        hoxne.window = false
        windower.send_command('gs c hoxnerelock')
        log('Hoxne: critical window closed, re-locking Ampulla.')
    end

    -- The Sleep hold borrows the window too. While no window is open, ON-Allow Critical
    -- strips range and ammo from every equip, so a Sleep set naming either would lose it.
    -- This entry opens the window for those two slots, the way a song opens it for its
    -- instrument, and gives the interrupt path a song's five-second resume. A sleep that
    -- outlasts the watchdog loses nothing. By then the Sleep hold has the slot disabled, so
    -- the relock's range write is diverted until the wake hands the slot back and relocks.
    local CRITICAL_SLEEP = { slot = 'range', resume = 'delay', delay = 5 }

    -- Whether a set of slots, keyed by any spelling, names range or ammo, the two slots the
    -- ON-Allow Critical filter strips.
    local function names_range_or_ammo(slots)
        for slot in pairs(slots) do
            local canon = CANON_SLOT[slot] or (type(slot) == 'string' and CANON_SLOT[slot:lower()])
            if canon == 'range' or canon == 'ammo' then return true end
        end
        return false
    end

    -- Open the window for the slots the Sleep hold is about to take. It opens only under
    -- ON-Allow Critical and only when range or ammo is among them, so a hold on main alone
    -- leaves the tick to its work. Call it before the equip. Returns whether it opened.
    local function hoxne_sleep_open(taken)
        if state.Hoxne.value ~= 'ON-Allow Critical' or not names_range_or_ammo(taken) then
            return false
        end
        hoxne.window  = true
        hoxne.owner   = CRITICAL_SLEEP
        hoxne.expires = os.clock() + 20 -- a watchdog: the wake closes the window, or this does
        log('Hoxne: critical window open for Sleep gear')
        return true
    end

    -- The wake's half: close the window and put the Ampulla back. The relock also clears
    -- range, since nothing else writes that slot under this mode, and the drain implement
    -- would otherwise stay on after waking. The test reads the mode at the wake and the
    -- slots the hold covered, never whether the open above ran. A window the watchdog
    -- already closed still needs the relock, and a mode switched off mid-sleep needs
    -- nothing. Returns whether it relocked.
    local function hoxne_sleep_close(held)
        if state.Hoxne.value ~= 'ON-Allow Critical' or not names_range_or_ammo(held) then
            return false
        end
        hoxne_relock()
        return true
    end

    -- The once-a-second tick. With a mode on it has four jobs, in order: close an expired
    -- critical window, re-assert the hold, repair the slot when the game clears it, and use
    -- the item once its enchantment has dropped and it is ready. The early returns form a
    -- precedence list, and their order matters.
    local function hoxne_tick(now)
        if not hoxne_on() then
            -- Mode OFF still has work, because the Ampulla may be left worn. This branch only
            -- paces the release attempts, one every two seconds. The hoxnerelease handler
            -- does the releasing, and zeroes the count once the slot is free.
            if hoxne.release_tries > 0 and now >= hoxne.release_next then
                hoxne.release_next  = now + 2
                hoxne.release_tries = hoxne.release_tries - 1
                windower.send_command('gs c hoxnerelease')
            end
            return
        end

        -- While a critical window is open, the tick only compares the clock. It neither
        -- reads nor writes equipment, so a borrowed instrument, handbell or throwing item
        -- cannot be overwritten before the window closes. Any equipment access added above
        -- this return breaks the window.
        if hoxne.window then
            if now >= hoxne.expires then hoxne_relock() end
            return
        end

        -- An item use in progress owns its slot outright and outranks this.
        if E.ench_active then return end

        -- A disable or strip hold outranks the tick too, and while either stands the repair
        -- below must not move the Ampulla. Both slots are asked, because a hold can stand on
        -- range alone, as with gs c disable range, or a strip hold while an item use has
        -- ammo. Once the hold is released, the next tick takes the slots back.
        local range_claim, ammo_claim = slot_claim('range'), slot_claim('ammo')
        if range_claim == 'strip' or range_claim == 'disable'
            or ammo_claim == 'strip' or ammo_claim == 'disable' then
            return
        end

        -- ON-Locked re-asserts its disable on every tick, which also takes the slots back a
        -- second after gs c enableall frees them. ON-Allow Critical must never disable here.
        -- That is the whole difference between the two modes.
        if state.Hoxne.value == 'ON-Locked' then
            disable('range', 'ammo')
        end

        -- Above the repair branch, because the ammo slot cannot be filled while dead.
        -- Without this return, a death with the Ampulla displaced would scan every bag and
        -- send a relock every two seconds until the character is raised. The hold above
        -- still re-asserts first.
        if player.status == 'Dead' or player.status == 'Engaged dead' then return end

        -- Neither mode can stop the game from clearing the slot. Equipping an instrument
        -- empties ammo, and an in-game /equipset bypasses GearSwap entirely. So the slot is
        -- repaired here, through the hoxnerelock self command, because an equip from this
        -- raw handler would be discarded.
        if player.equipment.ammo ~= HOXNE_AMPULLA then
            local _, _, carried = find_enchantment(HOXNE_AMPULLA)
            if not carried then return end
            windower.send_command('gs c hoxnerelock')
            hoxne.next_check = now + 2
            return
        end

        -- The enchantment is still up, so there is nothing to renew.
        if buffactive[BUFF_ENCHANTMENT] then return end
        -- Busy, moving or mid-action. A use would be refused, or would fight the action.
        if is_Busy or E.is_moving or midaction() or pet_midaction() then return end
        -- The client refuses item use while mounted. This returns before any throttle below
        -- is armed, so the first tick after dismounting tries at once.
        if buffactive['Mounted'] then return end

        -- Inside the lockout window after the engine's own re-equip, where the item is not
        -- yet usable and its extdata cannot be trusted.
        if now < hoxne.use_not_before then return end

        -- The bag-scan throttle. The scan below is skipped until recheck_at, during a known
        -- wait. It gates the scan only: the tick still runs every second, and the hold above
        -- still re-asserts.
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
            -- An equip delay, not a cooldown. It clears on its own in a few seconds, so it
            -- is waited out silently, where the recast above is reported.
            hoxne.recheck_at = now + math.min(activation, 5)
            return
        end
        -- The throttle is armed before the use, as if the use lands. If it lands, the
        -- enchantment buff stops this function before the throttle matters. If it does
        -- not, the capped wait retries within five seconds.
        hoxne.recheck_at = now + math.min(row.recast_delay or 60, 5)

        log('/item "', HOXNE_AMPULLA, '" <me>')
        windower.chat.input('/item "' .. HOXNE_AMPULLA .. '" <me>')
    end


    -- The prerender driver, run every frame: three ticks at three rates from one handler.
    --
    --   enchanted-item tick   every 0.25 s   always
    --   Hoxne tick            every 1.00 s   always
    --   gated-ability tick    every 0.10 s   only while an equip is in flight
    --
    -- Built as a closure, so every name it touches stays an upvalue, and registered by the
    -- root as a raw handler. No tick below may change equipment directly.
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
        -- gated_ja is set only while an equip is in flight. The rest of the time this third
        -- tick is one nil test.
        if gated_ja and now >= gated_ja.next_check then
            gated_ja.next_check = now + 0.1
            gated_ja_tick(now)
        end
    end

    E.hoxne_locked_refusal = hoxne_locked_refusal
    E.critical_force_slot = critical_force_slot
    E.hoxne_resume_deadline = hoxne_resume_deadline
    E.hoxne_sleep_open = hoxne_sleep_open
    E.hoxne_sleep_close = hoxne_sleep_close
    E.use_gated_ja = use_gated_ja
    E.hoxne_equip_ampulla = hoxne_equip_ampulla
    E.hoxne_arm_use_lockout = hoxne_arm_use_lockout
    E.hoxne_release_step = hoxne_release_step

    -- The version stamp. The root checks it against Rahvin_GS, so a stale copy of this file
    -- stops the load with an error that names it.
    return '2.1'
end
