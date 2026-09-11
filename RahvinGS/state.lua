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
-- EXPORTS  23 fields. Who READS each, and who WRITES it:
--   is_moving ............... read by builders, display, enchant, hoxne; written by monitor
--   DualWield, TwoHand ...... read by builders, display;                written by monitor
--   lock_main_sub ........... read by builders, hooks, equip, display;    written by equip
--   lock_range .............. read by equip, commands;                    written by equip
--   lock_songs .............. read by equip (the Songs exemption);        written by equip
--   lock_legacy ............. read by builders;                            written by equip
--   lock_pair ............... read by equip;                 written by builders and equip
--   lock_pair_changed ....... a callback slot: called by builders, hung by equip or nil
--   outgoing_cast_active .... read by display and hooks;       read and written by core
--   accession_predicted,
--   divine_seal_predicted ... read and written by builders and hooks; written (never read)
--                             by spellreceived, which clears them when the buff arrives
--   last_skillchain_* (3) ... read by builders;               read and written by monitor
--   SpellCastTime ........... read and written by hooks and monitor
--   Spellstart .............. read by monitor;               read and written by hooks
--   th_info ................. read by builders;                        written by th
--   get_mob_by_id ........... core, monitor, th
--   get_ability_recasts ..... hooks -- and core and hoxne reach the same function through
--                             windower.ffxi directly rather than taking this handle
--   get_spell_recasts ....... hooks only
--   get_party, send_ipc ..... core
--
-- ORDER    Constructed first of the do-block components. Every initializer here touches only
--          globals, so it needs no component before it -- which is what lets the constants
--          and utilities load afterwards and still find these fields present.
--
-- A field lives here only because two or more components share it. State belonging to one
-- subsystem is declared inside that subsystem. Three of the fields below are shared mutable
-- state rather than one-way exports -- SpellCastTime, accession_predicted and
-- divine_seal_predicted have no reader that does not also write them -- so moving one
-- changes a contract between components, not just an export. Two more shared mutables are
-- declared elsewhere, ench_held_slot and locked_n, both in the equip component, where slot
-- ownership is arbitrated.

return function(E)
    ------------------------------------------------------------------------------------------------
    -- SECTION 10 - RUNTIME STATE
    ------------------------------------------------------------------------------------------------
    -- The shared mutable state, in four groups: combat and timing, the multibox prediction
    -- flags, the cached Windower handles, and the Treasure Hunter registry. Nothing here is
    -- private to a subsystem, and nothing here is a constant.

    -- Combat, movement and timing -----------------------------------------------------------------

    -- Weapon traits the gear builders read when deciding whether an offhand or a sub-slot
    -- swap is possible. Both start nil -- unknown, not "one-handed and not dual wielding"
    -- -- and the builders withhold the whole offhand while either is nil. Both are written
    -- by the monitor component, on a scheduled call after load and after a subjob change;
    -- DualWield is re-read again on every 30 second housekeeping pass, and TwoHand
    -- additionally on a weapon-mode change and on gs c two_hand_check.
    E.DualWield                               = nil
    E.TwoHand                                 = nil

    -- The weapon lock, resolved from state.WeaponLock by the equip component on every lock
    -- change and once at startup: whether main and sub are held, whether range is held with
    -- them (Corsair's Locked+R), and whether a friendly song is exempt (Bard's Songs). The
    -- builders read the first at every phase and skip the weapon block when it is false;
    -- the third is read by the exemption the builders and hooks ask about each action.
    E.lock_main_sub                           = false
    E.lock_range                              = false
    E.lock_songs                              = false

    -- Whether the current weapon mode is one of the two legacy strings, 'Unlocked' or
    -- 'Locked', which the bridge in the equip component records at startup and on every
    -- weapon-mode change. A legacy mode has no set of its own, so the builders' mode-set
    -- lookup stays quiet while this is true.
    E.lock_legacy                             = false

    -- The weapons the lock holds: main, sub and range as the mode last resolved them, one
    -- table mutated in place. The equip component pins what is worn into it when the lock
    -- resolves; the builders overwrite each slot the mode names on every build, and call
    -- lock_pair_changed -- when a component has hung one -- on any change.
    E.lock_pair                               = {}
    E.lock_pair_changed                       = nil

    -- The post-action busy window. Precast arms both, sizing SpellCastTime from the action
    -- it is starting, and is_Busy stays set until os.clock() - Spellstart passes it. The
    -- polling engine expires it; aftercast resets it to a short tail.
    -- While it is set, is_Busy gates every automation that must not fire mid-action: the
    -- item-use tick, the Hoxne tick, the deferred rebuild and the job file's Cycle_Timer.
    -- Two paths expire the window -- the polling engine and the hook path -- and each clears
    -- is_Busy and zeroes SpellCastTime, so a lost completion message cannot wedge the engine.
    E.SpellCastTime                           = 0
    E.Spellstart                              = os.clock()

    -- Whether the character is moving. The poll raises it only while disengaged and lowers
    -- it when motion stops, so engaging part-way through a run leaves it raised until the
    -- player halts. Raised is not the same as movement gear being worn: sets.Movement is
    -- merged in the IDLE build only, so through that engaged-while-raised window the flag
    -- is true and the movement set is not applied.
    E.is_moving                               = false

    -- The last skillchain observed on the player's target, its time, and the elements it
    -- closed with. A nuke cast inside the window that matches a recorded element wears the
    -- burst set instead of the nuke set.
    E.last_skillchain_id                      = 0
    E.last_skillchain_time                    = 0
    E.last_skillchain_elements                = {}
    -- Multibox spell-received tracking ------------------------------------------------------------

    -- True between announcing a tracked cast to the other characters and that cast
    -- completing. It gates the release that hands their borrowed gear back. Written by the
    -- core announce and completion helpers; the action hooks and the debug box only read it.
    E.outgoing_cast_active                    = false

    -- Prediction flags for the two abilities that widen a spell's reach before their own buff
    -- is readable. Each is set on the attempt and cleared when its buff arrives, so it covers
    -- only the gap between the two. The pool of characters casting on us, and the failsafe
    -- that releases gear when no completion arrives, are private to the spell-received
    -- component rather than shared here.
    E.accession_predicted                     = false
    E.divine_seal_predicted                   = false
    -- Cached API handles --------------------------------------------------------------------------

    -- Windower entry points resolved once at construction, each called from a per-frame,
    -- per-tick or per-cast path. Taking the handle once avoids repeating the lookup on every
    -- call -- two reads for the four under windower.ffxi, one for send_ipc_message. Caching
    -- here is not exclusive: core and hoxne reach get_ability_recasts through windower.ffxi
    -- directly, so a change to that handle would not reach every call site.
    local ffxi                                = windower.ffxi
    local get_ability_recasts                 = ffxi.get_ability_recasts
    local get_spell_recasts                   = ffxi.get_spell_recasts
    local get_mob_by_id                       = ffxi.get_mob_by_id
    local get_party                           = ffxi.get_party
    local send_ipc                            = windower.send_ipc_message
    -- Treasure Hunter -----------------------------------------------------------------------------

    -- The tagged-mob registry, shared by the tracker that fills it and the builders that ask
    -- whether a target still needs Treasure Hunter gear. tagged_mobs maps a mob id to the
    -- os.clock() it was tagged at; last_player_target_index latches the player's target so a
    -- change is acted on once rather than on every pass. Entries leave on the mob's death, on
    -- zoning, and after three minutes without activity.
    local th_info                             = {}
    th_info.tagged_mobs                       = T {}
    th_info.last_player_target_index          = 0

    -- Handed to E so later components and the composition root share these exact values
    -- rather than resolving their own.
    E.get_ability_recasts = get_ability_recasts
    E.get_spell_recasts   = get_spell_recasts
    E.get_mob_by_id       = get_mob_by_id
    E.get_party           = get_party
    E.send_ipc            = send_ipc
    E.th_info             = th_info

    -- Version stamp; the root asserts it against Rahvin_GS at load.
    return '2.0'
end
