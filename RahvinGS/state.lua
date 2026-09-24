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
-- COMPONENT: state -- section 10, the cross-component runtime state
----------------------------------------------------------------------------------------------------
-- CONTENTS
--   Section 10 - Runtime state. The mutable fields more than one component touches, the
--   Windower API handles resolved once, and the Treasure Hunter tagged-mob registry.
--
-- EXPORTS  These fields, and the components that read and write each:
--   is_moving ............... read by builders, display, enchant, hoxne. Written by monitor.
--   DualWield, TwoHand ...... read by builders, display. Written by monitor.
--   lock_main_sub ........... read by builders, hooks, equip, display. Written by equip.
--   lock_range .............. read by equip, commands. Written by equip.
--   lock_songs .............. read by equip for the Songs exemption. Written by equip.
--   lock_geomancy ........... read by equip for the Geomancy exemption. Written by equip.
--   lock_legacy ............. read by builders. Written by equip.
--   lock_pair ............... read and written by builders and equip.
--   lock_pair_changed ....... a callback, called by builders and set by equip.
--   outgoing_cast_active .... read by display and hooks. Read and written by core.
--   accession_predicted,
--   divine_seal_predicted ... read and written by builders and hooks. Cleared by
--                             spellreceived when the buff arrives or wears off.
--   last_skillchain_* ....... read by builders. Read and written by monitor.
--   SpellCastTime ........... read and written by hooks and monitor.
--   Spellstart .............. read by monitor. Read and written by hooks.
--   th_info ................. read by builders. Read and written by th.
--   get_mob_by_id ........... bound by core, monitor and th.
--   get_ability_recasts ..... bound by hooks. Core and hoxne call windower.ffxi's own
--                             get_ability_recasts directly instead.
--   get_spell_recasts ....... bound by hooks.
--   get_party, send_ipc ..... bound by core and spellreceived.
--
-- LOADS    The root constructs this component first. Its initializers read only globals, so
--          it needs no other component, and every later component can bind its handles at
--          construction.
--
-- Every field here is shared by two or more components. A shared field that one subsystem
-- owns is declared with that subsystem instead. The equip component declares
-- ench_held_slot, locked_n, disabled_n, strip_shape and mr_count, and the enchanted item
-- engine declares ench_active. SpellCastTime, accession_predicted and divine_seal_predicted
-- are two-way state rather than one-way exports. Every component that reads one also
-- writes it, so moving one changes a contract between components, not just an export.

return function(E)
    ------------------------------------------------------------------------------------------------
    -- SECTION 10 - RUNTIME STATE
    ------------------------------------------------------------------------------------------------
    -- The shared runtime state, in four groups: combat, movement and timing, the multibox
    -- flags, the cached Windower handles, and the Treasure Hunter registry.

    -- Combat, movement and timing -----------------------------------------------------------------

    -- The two weapon traits the builders read to choose an offhand: whether the character
    -- has Dual Wield, and whether the current weapon is two-handed. Both start nil, which
    -- means unknown, and the builders add no offhand until both are known. The monitor
    -- component writes both after load and after a subjob change. It re-reads DualWield on
    -- every 30 second housekeeping pass, and TwoHand on every weapon-mode change and on
    -- gs c two_hand_check.
    E.DualWield                               = nil
    E.TwoHand                                 = nil

    -- The weapon lock as four flags, resolved from state.WeaponLock by the equip component
    -- at startup and on every lock change. lock_main_sub says main and sub are held, and
    -- lock_range says range is held with them under the Corsair's Locked+R. lock_songs
    -- exempts a friendly song under the Bard's Songs, and lock_geomancy exempts a Geomancy
    -- spell under the Geomancer's Geomancy. The builders merge the weapon mode into precast
    -- and midcast only while lock_main_sub is true. The two exemptions are read through
    -- lock_exempts, which the builders and hooks ask about each action.
    E.lock_main_sub                           = false
    E.lock_range                              = false
    E.lock_songs                              = false
    E.lock_geomancy                           = false

    -- Whether the current weapon mode is 'Unlocked' or 'Locked', the two legacy mode names.
    -- The bridge in the equip component sets it at startup and on every weapon-mode change.
    -- A legacy mode has no set of its own, so the builders skip the missing-set warning
    -- while this is true.
    E.lock_legacy                             = false

    -- The weapons the lock holds, as main, sub and range. One table, mutated in place. When
    -- the lock resolves, the equip component fills it from what is worn. On every build under
    -- the lock, the builders overwrite each slot the weapon mode names and call
    -- lock_pair_changed when the pair moves. The equip component sets that callback to the
    -- take that moves the hold with the pair.
    E.lock_pair                               = {}
    E.lock_pair_changed                       = nil

    -- The busy window. Precast sets Spellstart and sizes SpellCastTime from the action it
    -- starts, and the is_Busy global stays true until SpellCastTime seconds have passed since
    -- Spellstart. Aftercast restarts the window with a short tail. While is_Busy is true,
    -- precast refuses a new action, and the movement check, the deferred rebuild, the job
    -- file's Cycle_Timer and the Hoxne tick all wait. Two paths expire the window, the
    -- polling engine and precast. Each clears is_Busy and zeroes SpellCastTime, so a lost
    -- completion cannot leave the engine stuck.
    E.SpellCastTime                           = 0
    E.Spellstart                              = os.clock()

    -- Whether the character is moving. The poll raises it only while disengaged and lowers
    -- it when motion stops, so engaging partway through a run leaves it raised until the
    -- character halts. A raised flag does not mean movement gear is worn. sets.Movement is
    -- merged in the idle build only, so while engaged the flag can be true with no movement
    -- set applied.
    E.is_moving                               = false

    -- The last skillchain seen on a monster within 21 yalms: the monster's id, the time, and
    -- the elements a magic burst on it can match. An elemental nuke on that monster
    -- within eight seconds, of a matching element, wears sets.Midcast.Burst in place of
    -- sets.Midcast.Nuke.
    E.last_skillchain_id                      = 0
    E.last_skillchain_time                    = 0
    E.last_skillchain_elements                = {}
    -- Multibox spell-received tracking ------------------------------------------------------------

    -- True from the moment a tracked cast is announced to the other characters until that
    -- cast completes. It gates the completion message that lets them release the gear they
    -- hold for it. The core announce and completion helpers write it. The action hooks and
    -- the debug box only read it.
    E.outgoing_cast_active                    = false

    -- Prediction flags for Accession and Divine Seal, two of the effects that widen a spell
    -- to the party. Each is set when the ability is used and cleared when its buff arrives
    -- or wears off, so it covers the gap before the buff is readable. The rest of the
    -- multibox state is private to the spell-received component.
    E.accession_predicted                     = false
    E.divine_seal_predicted                   = false
    -- Cached API handles --------------------------------------------------------------------------

    -- Windower functions looked up once here, because each is called on a per-frame,
    -- per-tick or per-cast path. Not every caller uses these handles. Core and hoxne call
    -- windower.ffxi.get_ability_recasts directly, so a wrapper placed on this handle would
    -- not reach them.
    local ffxi                                = windower.ffxi
    local get_ability_recasts                 = ffxi.get_ability_recasts
    local get_spell_recasts                   = ffxi.get_spell_recasts
    local get_mob_by_id                       = ffxi.get_mob_by_id
    local get_party                           = ffxi.get_party
    local send_ipc                            = windower.send_ipc_message
    -- Treasure Hunter -----------------------------------------------------------------------------

    -- The tagged-mob registry. The Treasure Hunter tracker fills it, and the builders read it
    -- to decide whether a target still needs Treasure Hunter gear. tagged_mobs maps a mob id
    -- to the os.clock() of the player's last action on it. An entry leaves when the mob dies,
    -- when the player zones, or after three minutes with no action from the player.
    -- last_player_target_index is the target the target-change handler last rebuilt for, so
    -- a re-target to the same mob does not rebuild again.
    local th_info                             = {}
    th_info.tagged_mobs                       = T {}
    th_info.last_player_target_index          = 0

    -- The exports. Later components bind these in their import blocks, so every caller
    -- shares the same handles and the same registry.
    E.get_ability_recasts = get_ability_recasts
    E.get_spell_recasts   = get_spell_recasts
    E.get_mob_by_id       = get_mob_by_id
    E.get_party           = get_party
    E.send_ipc            = send_ipc
    E.th_info             = th_info

    -- The version stamp. The root checks it against Rahvin_GS, so a stale copy of this file
    -- stops the load with an error that names it.
    return '2.1'
end
