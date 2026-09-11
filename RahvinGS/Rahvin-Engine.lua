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


-- The job file interface. Loaded first: engine internals below may read these
-- globals, and a job file overrides them after this file returns.
include('RahvinGS/interface')

----------------------------------------------------------------------------------------------------
-- COMPONENT: the composition root -- section 23: construction and event registration
----------------------------------------------------------------------------------------------------
-- CONTENTS
--   Above this block .. the license, and the job-file interface, included first
--   Construction ...... E, the version assert, and the thirteen components in load order
--   Section 23 ........ the eleven event registrations, equip_set_command, and startup
--
-- THIS FILE IS THE ONLY ONE THAT WIRES ANYTHING. Every other file BUILDS -- a handler
--          closure, a set, a command table -- and hands it back. Nothing else includes an
--          engine file, and nothing else registers an event. That is what makes this the one
--          place to read for what runs when, and the one place a load-order question is
--          answered.
--
-- CONSTRUCTION ORDER IS LOAD-BEARING, and is not the section order. state constructs FIRST
--          because core, builders, hooks, th and monitor bind its handles in their import
--          blocks, and every component that shares one of its mutable fields reaches that
--          field through E at runtime. core follows, holding sections 7-9 and 11. From there
--          it is section order to lifecycle, and this file is section 23, last.
--
-- REGISTRATION IS LAST, ON PURPOSE. Every handler and every local it captured has to exist
--          before Windower can call it. That is also why the components build closures
--          instead of registering their own: hot state stays an upvalue, and the order events
--          arrive in is decided here rather than scattered across fourteen files.
--
-- THE TWO prerender HANDLERS ARE TWO REGISTRATIONS, not one that calls both. Windower runs
--          handlers on the same event in registration order and isolates their errors from
--          each other, so a throw in one leaves the other running. Merging them would couple
--          the Hoxne driver's failure to the spell-received failsafe's.
--
-- EXPORTS  nothing onto E -- the only file that reads E without adding to it. One global,
--          equip_set_command: seven components call it, an eighth schedules it, and it
--          resolves LATE in every one of them, because this file loads after them all.
-- LOADS    Fifteenth of fifteen, and it is what a job file includes.

-- Everything below is engine internals held in a single scope so job files cannot reach it.
-- The scope is the boundary: a job file gets `sets`, `state` and the interface globals, and
-- nothing declared inside this block. Locals still must be declared before first use; globals
-- resolve at call time, which is what lets equip_set_command be called before it is defined.
do
    -- The one table every component shares. Immutable exports are copied out of it into
    -- file-locals at construction; the mutable fields stay here and are read through it.
    -- Engine-internal -- a job file never sees this name.
    local E = {}

    -- Construct one component and prove it is the right one. Each component file returns a
    -- constructor taking E, and that constructor returns its version stamp. TWO asserts, and
    -- they catch different mistakes: a file that is not a constructor at all fails the first,
    -- and a constructor from another version of the engine fails the second. Either way the
    -- load stops naming the file, instead of the engine half-running.
    local function construct(ctor, name)
        assert(type(ctor) == 'function', name .. ' did not return a constructor -- stale copy?')
        local v = ctor(E)
        assert(v == Rahvin_GS,
            name .. ' is version ' .. tostring(v) .. ' against engine ' .. Rahvin_GS .. ' -- stale copy?')
    end

    -- The thirteen components, in the order the engine ships -- one of several the requires
    -- lines allow, and the one the section numbers are cut for. state is FIRST because the
    -- components that read it bind its handles at construction, and it CAN be first because
    -- its own initializers read nothing but globals. Everything after that is section order --
    -- which is why core, holding sections 7-9 and 11, sits second rather than where its
    -- numbers would put it.
    --
    -- include() does not cache, so each name appears here exactly once: a second inclusion
    -- would run the component's constructor twice against the same E.
    construct(include('RahvinGS/state'), 'RahvinGS/state')                 -- section 10
    construct(include('RahvinGS/core'), 'RahvinGS/core')                   -- sections 7-9, 11
    construct(include('RahvinGS/equip'), 'RahvinGS/equip')                 -- section 12
    construct(include('RahvinGS/enchant'), 'RahvinGS/enchant')             -- section 13
    construct(include('RahvinGS/hoxne'), 'RahvinGS/hoxne')                 -- section 14
    construct(include('RahvinGS/builders'), 'RahvinGS/builders')           -- section 15
    construct(include('RahvinGS/hooks'), 'RahvinGS/hooks')                 -- section 16
    construct(include('RahvinGS/spellreceived'), 'RahvinGS/spellreceived') -- section 17
    construct(include('RahvinGS/th'), 'RahvinGS/th')                       -- section 18
    construct(include('RahvinGS/monitor'), 'RahvinGS/monitor')             -- section 19
    construct(include('RahvinGS/display'), 'RahvinGS/display')             -- section 20
    construct(include('RahvinGS/commands'), 'RahvinGS/commands')           -- section 21
    construct(include('RahvinGS/lifecycle'), 'RahvinGS/lifecycle')         -- section 22

    -- The component exports the block below still reads directly, one local each. Everything
    -- else it needs is either a global the components declared or a closure hanging off E.
    local hoxne = E.hoxne
    local resolve_weapon_lock = E.resolve_weapon_lock
    local bridge_weapon_lock = E.bridge_weapon_lock

    ------------------------------------------------------------------------------------------------
    -- SECTION 23 - EVENT REGISTRATION AND STARTUP
    ------------------------------------------------------------------------------------------------
    -- The eleven Windower registrations and the deferred startup pass. Eleven handlers, built
    -- by five components: Treasure Hunter owns four of them, spell-received four, and the
    -- polling engine, the Hoxne driver and the command surface one each.

    -- Release every slot before anything else runs. A hold placed by a previous load survives
    -- into this one, and a slot still disabled here would silently refuse the whole session's
    -- gear. All sixteen, unconditionally, because nothing yet has a claim worth respecting.
    enable('main', 'sub', 'range', 'ammo', 'head', 'neck', 'lear', 'rear', 'body', 'hands', 'lring', 'rring', 'waist',
        'legs', 'feet', 'back')

    -- Three of Treasure Hunter's four hooks, plus the polling engine. All raw except the
    -- target change. main_engine rides the outgoing chunk rather than a timer, so the client's
    -- own traffic is what drives it.
    windower.register_event('target change', on_target_change_for_th)
    windower.raw_register_event('incoming chunk', on_incoming_chunk_for_th)
    windower.raw_register_event('outgoing chunk', main_engine)
    windower.raw_register_event('zone change', on_zone_change_for_th)

    -- Multibox: another character on this machine announcing a cast aimed at this one.
    windower.register_event('ipc message', E.sr_ipc_message)

    -- The two prerender drivers. prerender fires every frame whether or not the client is
    -- sending anything, which is the whole reason they are not folded into main_engine --
    -- they have to keep working while the character stands still. Each gates itself on a
    -- clock read before doing anything else.
    --
    -- KEPT AS TWO REGISTRATIONS DELIBERATELY. Handlers on one event are error-isolated from
    -- each other, so a throw in the Hoxne driver leaves the failsafe below still running.
    -- One handler calling both would lose that.
    windower.raw_register_event('prerender', E.hoxne_prerender)

    -- The spell-received failsafe: hands back borrowed gear when a completion never arrives.
    windower.raw_register_event('prerender', E.sr_prerender)

    -- Buff gained: gear for the ailments that need it, and a status-removal item where the
    -- job file allows one.
    windower.register_event('gain buff', E.sr_gain_buff)

    -- Buff lost: release whatever was being held for that buff.
    windower.register_event('lose buff', E.sr_lose_buff)

    -- GearSwap's own console words. Its handler for '//gs ...' was registered when the addon
    -- loaded, so it runs first and has already acted; this one only prints the line pointing a
    -- player at the tracked 'gs c' words. WRAPPED, not raw: raw exists to keep the per-frame
    -- drivers out of the equip wrapper, and this fires once per typed command, where the
    -- wrapper's gate is worth having -- it holds the line back while the user file itself
    -- stands switched off, which is exactly when the engine has nothing to say.
    windower.register_event('addon command', E.native_disable_notice)

    -- A worked example, left commented out on purpose: how a player would hook party chat or
    -- a tell. It registers nothing as it stands.
    --[[
    windower.register_event('chat message', function(message, sender, mode, gm)
        --Future Hooks for PT chat or tells
        -- Mode 3 is tell
        -- Mode 4 is party
        --Ignore it if it's not party chat or a tell
        if mode ~= 3 and mode ~= 4 then
            return
        end
        message = message:lower()
        -- Example Use
        if message:contains('hqzerg') then
            windower.send_command('sm on')
        end
    end)
    ]] --

    -- Treasure Hunter's fourth hook, and the widest registration in this file: every action
    -- packet in range reaches it. Most of what it does is gated on the actor being this
    -- player; the skillchain dispatch at the end deliberately is not, so a chain closed by
    -- anybody opens a burst window here.
    windower.raw_register_event('action', E.th_action)

    -- This file's one global, and the whole of it: ask for a gear rebuild by sending the
    -- self command that performs one. It exists because a raw event handler cannot equip --
    -- deferring into a command GearSwap wraps is what makes the equip land. Seven components
    -- call it and an eighth schedules it, and in every one of them it resolves LATE, since
    -- this file loads after them all.
    function equip_set_command()
        windower.send_command("gs c update auto")
    end

    -- Startup, deferred and staggered. Nothing here can run at load: the job file has not
    -- finished loading, so its sets do not exist yet, and the client has not settled. The
    -- order is what each step needs -- the boxes appear, the two weapon traits are read and
    -- the weapon lock the job file may have set is resolved, then Unlock frees every slot the
    -- lock does not hold AND re-equips, then the polling engine takes over. The two notices
    -- come last, after everything they report on has run.
    coroutine.schedule(display_box_update, 2.0)
    coroutine.schedule(dual_wield_check, 2.1)
    coroutine.schedule(two_hand_check, 2.2)
    coroutine.schedule(bridge_weapon_lock, 2.2)
    coroutine.schedule(resolve_weapon_lock, 2.2)
    coroutine.schedule(Unlock, 2.3)
    coroutine.schedule(main_engine, 2.4)
    coroutine.schedule(migration_notice, 2.5)
    coroutine.schedule(settings_reset_announce, 2.6)

    -- Arm the stranded-Ampulla release, which the Hoxne tick performs. Ten attempts, the
    -- first three seconds out -- past the startup equips above, so the release is not
    -- fighting them for the same slots.
    hoxne.release_tries = 10
    hoxne.release_next  = os.clock() + 3
end
