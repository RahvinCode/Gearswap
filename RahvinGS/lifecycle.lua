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
-- COMPONENT: lifecycle -- section 22: job file load, unload and subjob change
----------------------------------------------------------------------------------------------------
-- CONTENTS
--   Section 22 - Job lifecycle. Four global functions covering the whole life of a job
--   file: the setup call it makes itself, the startup notice about retired features, the
--   teardown that gives every held slot back, and the subjob-change refresh.
--
-- EXPORTS  Nothing onto E for another component to read. It CLEARS two E fields at
--          teardown -- ench_active and ench_held_slot, owned by the enchanted item engine --
--          because an item use must not survive the job file that started it.
-- CALLERS  None of the four is called by another engine file, and none is registered by the
--          root. They are reached from outside the engine instead:
--            jobsetup .......... called by the JOB FILE, at file scope
--            file_unload ....... called by GearSwap, which resolves it by name
--            sub_job_change .... called by GearSwap, which resolves it by name
--            migration_notice .. scheduled by the root at 2.5 s after load
--          Only migration_notice is reached from inside the engine at all. Grepping for
--          callers of the other three finds nothing, which is expected rather than a sign
--          this file is dead.
-- LOADS    Fourteenth of fifteen, so every function it calls directly is already defined.
--          The three it hands to coroutine.schedule are resolved when sub_job_change runs,
--          long after load, which is what lets it schedule equip_set_command from the root.

-- requires: rahvings/core, rahvings/equip, rahvings/display
return function(E)
    -- Immutable dependencies bound once at construction, so no call below repeats the lookup
    -- for them. The cross-component mutables are never bound here: ench_active and
    -- ench_held_slot are reached through E at every touch, because a file-local copy would
    -- not be the one the other components read and write.
    local clear_locked_slots, gs_debug, gs_status, hoxne, reset_set_warnings =
        E.clear_locked_slots, E.gs_debug, E.gs_status, E.hoxne, E.reset_set_warnings
    local display_unload = E.display_unload
    local weapon_lock_drop, release_implement = E.weapon_lock_drop, E.release_implement
    local strip_clear, disable_clear = E.strip_clear, E.disable_clear

    ------------------------------------------------------------------------------------------------
    -- SECTION 22 - JOB LIFECYCLE
    ------------------------------------------------------------------------------------------------
    -- The four entry points a job file passes through, in the order they occur: setup on
    -- load, the retired-feature notice shortly after, the subjob-change refresh, and
    -- teardown on unload.

    -- Apply the job file's macro book, lockstyle and keybinds, and print the key list.
    -- The job file calls this itself, so anything raised here aborts the job file.
    function jobsetup(LockStylePallet, MacroBook, MacroSet)
        -- math.random(0) raises, and an empty Lockstyle_List would reach it. That error
        -- would abort the whole job file, because jobsetup is called at file scope above
        -- get_sets -- so an empty list warns and keeps the pallet it was given instead.
        if Random_Lockstyle then
            if #Lockstyle_List > 0 then
                LockStylePallet = Lockstyle_List[math.random(#Lockstyle_List)]
            else
                warn('Random_Lockstyle is on but Lockstyle_List is empty; using pallet ' ..
                    tostring(LockStylePallet) .. '.')
            end
        end

        -- One chained command rather than separate sends: the waits sequence the game's own
        -- responses, and the closing update auto dresses the character once the lockstyle
        -- has been applied.
        windower.send_command('wait 1;input /macro book ' ..
            MacroBook ..
            ';wait 1;input /macro set ' ..
            MacroSet ..
            ';gs validate;wait 3;input /lockstyleset ' ..
            LockStylePallet .. ';input /echo Change Complete;gs c update auto;')

        -- Every bind is a self command, so each key has a typeable equivalent and a player
        -- can rebind any of them without touching the engine. file_unload releases all eight.
        send_command('bind f12 gs c OffenseMode')
        send_command('bind f11 gs c TreasureHunter')
        send_command('bind f10 gs c WeaponLock')
        send_command('bind f9 gs c WeaponMode')
        send_command('bind ^f12 gs c JobMode')
        send_command('bind ^f11 gs c JobMode2')
        send_command('bind ^f10 gs c Hoxne')
        send_command('bind ^f9 gs c SpellReceived')

        -- The startup key list. The two job-mode keys are announced only when the job file
        -- named that slot, since an unnamed slot is hidden from the status box as well.
        notice('Stance - ' .. string.format('[%s]', 'F12'))
        notice('TH Mode - ' .. string.format('[%s]', 'F11'))
        notice('Weapon Lock - ' .. string.format('[%s]', 'F10'))
        notice('Weapon Mode - ' .. string.format('[%s]', 'F9'))
        if UI_Name ~= '' then
            notice(UI_Name .. ' - ' .. string.format('[%s]', 'Ctrl + F12'))
        end
        if UI_Name2 ~= '' then
            notice(UI_Name2 .. ' - ' .. string.format('[%s]', 'Ctrl + F11'))
        end
        notice('Hoxne Ampulla Mode - ' .. string.format('[%s]', 'Ctrl + F10'))
        notice('Spell Received Gear Mode (Multibox Only) - ' .. string.format('[%s]', 'Ctrl + F9'))
    end

    -- Tell a player their job file still carries a feature the engine has retired, so the
    -- leftover is found without hunting for it. Scheduled rather than called inline: it has
    -- to run after the job file's main chunk has defined its hooks, or the tests below read
    -- nil for functions that do exist. The channel is deliberately ungated -- nothing else
    -- reports this, so a silenced channel would hide it entirely.
    function migration_notice()
        if check_buff_JA or check_buff_SP then
            notice('Auto Buff was removed: this job file still defines check_buff_JA or ' ..
                'check_buff_SP and nothing calls them. They can be deleted.')
        end
        if UI_Name == 'Auto Tank' or UI_Name == 'Runes'
            or UI_Name2 == 'Auto Tank' or UI_Name2 == 'Runes' then
            notice('Auto Tank and Runes were removed: this job file still names one, so ' ..
                'the mode is still shown but now drives nothing.')
        end
    end

    -- Tear the job file down: destroy the display boxes, release every key, and give back
    -- every slot this engine is holding. GearSwap calls this when the file unloads.
    --
    -- Each hold is cleared directly rather than through its owning subsystem, because those
    -- subsystems are being torn down in the same breath, and this engine equips nothing from
    -- here; GearSwap itself may send an item it withheld for a disabled slot once the slot is
    -- enabled. GearSwap's slot flags outlive the job file, so a slot left disabled stays disabled for
    -- whatever loads next; the root's load-time release of all sixteen covers only the case
    -- where the next file is this engine.
    function file_unload(file_name)
        -- The renderer standing steps aside first, while the status box still exists:
        -- leaving gives the box its background back, and a destroyed object raises on it.
        display_unload()
        if gs_status then
            gs_status:destroy()
        end
        if gs_debug then
            gs_debug:destroy()
        end

        send_command('unbind ^f9')
        send_command('unbind ^f10')
        send_command('unbind ^f11')
        send_command('unbind ^f12')
        send_command('unbind f9')
        send_command('unbind f10')
        send_command('unbind f11')
        send_command('unbind f12')

        -- The two holds go first, highest first: every layer below is torn down after them,
        -- and nothing here re-dresses, so a claim left standing would keep slots shut past
        -- the unload.
        disable_clear()
        strip_clear()

        -- An in-flight item use and the Hoxne hold both own slots; drop their state rather
        -- than waiting for a tick that will not come. The item use held whatever slot its
        -- item occupies, so that slot is enabled by the name it recorded; range and ammo
        -- cover the Hoxne pair.
        local held = E.ench_held_slot
        E.ench_active      = nil
        E.ench_held_slot   = nil
        if held then enable(held) end
        hoxne.window     = false
        hoxne.recheck_at = 0
        enable('range', 'ammo')

        -- Slots held for received gear. The table is a job-file-visible global declared in
        -- the interface, so it is emptied here rather than reallocated somewhere the job
        -- file would not see.
        if active_external_locks and next(active_external_locks) ~= nil then
            for slot, _ in pairs(active_external_locks) do
                enable(slot)
            end
            active_external_locks = {}
        end

        -- A cast in progress lets its implement go, the layer above the lock modes.
        release_implement()

        -- Lock modes last, once no layer above them can still claim a slot: each lock is
        -- deregistered before its slot is released, so the release is a bare enable. The
        -- weapon lock's slots go the same way, after them.
        if clear_locked_slots() > 0 then notice('Lock modes released (unloaded).') end
        weapon_lock_drop()

        if user_file_unload then
            user_file_unload()
        else
            info('user_file_unload() not found!')
        end
    end

    -- Refresh everything a subjob change invalidates. GearSwap calls this by name.
    --
    -- The three scheduled calls are staggered on purpose and the order matters: both trait
    -- checks must land before the rebuild, or the rebuild dresses the character from a stale
    -- flag. Dual Wield is the one a subjob change actually moves; two_hand_check reads the
    -- weapon the current mode names, which a subjob change does not alter, so it is here for
    -- the case where a job file's own sub_job_change_custom switches weapon mode. They are
    -- scheduled rather than called because the game has not finished applying the subjob at
    -- the moment this fires.
    function sub_job_change(new, old)
        invalidate_layout()
        invalidate_set_index()
        reset_set_warnings()
        coroutine.schedule(dual_wield_check, 2)
        coroutine.schedule(two_hand_check, 2.1)
        coroutine.schedule(equip_set_command, 2.2)
        if sub_job_change_custom then
            sub_job_change_custom(new, old)
        end
    end

    -- Version stamp. The root asserts this against Rahvin_GS, so a stale copy of this file
    -- announces itself at load instead of running.
    return '2.0'
end
