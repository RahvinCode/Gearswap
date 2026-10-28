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
--   Construction ...... E, the version check, and the components in load order
--   Section 23 ........ the event registrations, equip_set_command, and the startup schedule
--
-- This is the only file that wires anything. Every component builds its handlers, sets and
-- command tables and hands them back. Only this file includes an engine file, and only this
-- file registers a Windower event, so it is the one place to read for what runs when.
--
-- EXPORTS  Nothing onto E. One global, equip_set_command, which the components call. It
--          resolves late in every one of them, because this file defines it after they load.
-- LOADS    Last. This is the file a job file includes.

-- The do block keeps E, construct and the bindings below local to this file. A job file sees
-- sets, state, the interface globals and the globals the components define, and nothing
-- declared inside this block. Inside it, a local must be declared above its first use.
do
    -- The table every component shares. A component copies the immutable exports it needs
    -- into file-locals at construction, and reads the shared mutable fields through E at each
    -- use. A job file never sees it.
    local E = {}

    -- Construct one component and check it. Each component file returns a constructor that
    -- takes E and returns its version stamp. The first assert catches a file that returns no
    -- constructor, and the second catches a constructor from another engine version. Either
    -- way the load stops and names the file, rather than running a mismatched engine.
    local function construct(ctor, name)
        assert(type(ctor) == 'function', name .. ' did not return a constructor -- stale copy?')
        local v = ctor(E)
        assert(v == Rahvin_GS,
            name .. ' is version ' .. tostring(v) .. ' against engine ' .. Rahvin_GS .. ' -- stale copy?')
    end

    -- The components, in load order, which is not section order. state comes first because
    -- the components that use its cached handles bind them at construction, and it can come
    -- first because its initializers read only globals. core comes second with sections 7-9
    -- and 11. The rest follow section order through lifecycle.
    --
    -- include() does not cache, so each file appears here exactly once. A second inclusion
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

    -- The exports the code below reads directly. Everything else it uses is a global a
    -- component defined, or a handler on E.
    local hoxne = E.hoxne
    local resolve_weapon_lock = E.resolve_weapon_lock
    local bridge_weapon_lock = E.bridge_weapon_lock

    ------------------------------------------------------------------------------------------------
    -- SECTION 23 - EVENT REGISTRATION AND STARTUP
    ------------------------------------------------------------------------------------------------
    -- The Windower event registrations and the deferred startup schedule. Registration comes
    -- last because every handler, and every local it captures, must exist before Windower can
    -- call it. The components build the handlers as closures, so the state a handler reads
    -- stays an upvalue, and every one of them is registered here.

    -- Release every slot before anything else runs. GearSwap keeps a slot's disabled flag
    -- across job file loads, so a hold left by the previous load would otherwise refuse gear
    -- for the whole session. All sixteen are released, because no hold in this load exists yet.
    enable('main', 'sub', 'range', 'ammo', 'head', 'neck', 'lear', 'rear', 'body', 'hands', 'lring', 'rring', 'waist',
        'legs', 'feet', 'back')

    -- Three of the Treasure Hunter component's four handlers, and the polling engine. Two of
    -- the handlers do more than their names say: the incoming-chunk one also reads the
    -- automaton's TP for sets.Pet_WS, and the zone one releases everything that does not
    -- survive a zone. main_engine runs on each outgoing chunk, so the client's own traffic
    -- drives it rather than a timer.
    windower.register_event('target change', on_target_change_for_th)
    windower.raw_register_event('incoming chunk', on_incoming_chunk_for_th)
    windower.raw_register_event('outgoing chunk', main_engine)
    windower.raw_register_event('zone change', on_zone_change_for_th)

    -- Multibox: another character on this machine announcing a cast aimed at this one, and
    -- the eleven tracker's question and answer between characters after a load.
    windower.register_event('ipc message', E.sr_ipc_message)

    -- The two prerender drivers. prerender fires every frame whatever the client is sending,
    -- so these keep running while the character stands still, when main_engine may not tick.
    -- Each checks the clock before doing anything else.
    --
    -- They stay two registrations. Windower runs the handlers on one event in registration
    -- order and isolates their errors from each other, so an error in the Hoxne driver leaves
    -- the failsafe below running. One handler calling both would lose that.
    windower.raw_register_event('prerender', E.hoxne_prerender)

    -- The spell-received failsafe: it releases borrowed gear when a completion never arrives.
    windower.raw_register_event('prerender', E.sr_prerender)

    -- Buff gained: ends the buff's prediction, uses a status-removal item where the job file
    -- allows one, and dresses and holds gear for the ailments that need it.
    windower.register_event('gain buff', E.sr_gain_buff)

    -- Buff lost: releases what was held for that buff, ends the buff's prediction, and drops
    -- a Corsair roll from the eleven tracker.
    windower.register_event('lose buff', E.sr_lose_buff)

    -- Logout: both display boxes come down, with whatever the renderer standing owns. The
    -- boxes are not rebuilt until after the next login, so without this they stay drawn over
    -- the character list. The handler also latches the display shut, which stops the
    -- per-frame drivers and the polling tick from drawing it again. The saved visible and
    -- debug preferences are left alone, so the rebuild puts each box back the way it was set.
    --
    -- Registered raw because the handler equips nothing. The wrapped form would run
    -- GearSwap's globals refresh and full set pass for a few hides.
    windower.raw_register_event('logout', E.display_logout)

    -- GearSwap's own console words. '//gs disable <slot>' and '//gs enable <slot>' run gs c
    -- disable and gs c enable instead of GearSwap's own. The engine's holds shut slots with
    -- GearSwap's own disable, so these words go through the engine, which frees only a slot
    -- nothing else holds and names the hold that has any other. The bare words still go to
    -- GearSwap. The interception goes into GearSwap's own table here, and the job file's
    -- unload takes it out again.
    E.intercept_native_words()

    -- A worked example for a job file, commented out: reacting to a tell or to party chat.
    -- It registers nothing here.
    --[[
    windower.register_event('chat message', function(message, sender, mode, gm)
        -- Mode 3 is a tell and mode 4 is party chat. Anything else is ignored.
        if mode ~= 3 and mode ~= 4 then
            return
        end
        message = message:lower()
        -- A keyword in the message runs a command.
        if message:contains('hqzerg') then
            windower.send_command('sm on')
        end
    end)
    ]] --

    -- The Treasure Hunter component's fourth handler, and the widest registration here: every
    -- action packet in range reaches it. The end of this player's item use or interrupted
    -- cast, and Treasure Hunter tagging, read only this player's packets. The rest reads every
    -- actor's. A skillchain closed by anyone opens a burst window, and a later move can end
    -- it. A Corsair roll that lists this character carries its total to the eleven tracker.
    -- Another Blue Mage's Chain Affinity or Azure Lore, and another Scholar's Immanence, are
    -- noted, so their spells can end a window. A pet's finish packet or swing ends its move. A
    -- spell or ability from another player, or this character's own job ability, that gives
    -- this character a buff starts its prediction.
    windower.raw_register_event('action', E.th_action)

    -- This file's one global: ask for a gear rebuild by sending the self command that
    -- performs one. An equip made inside a raw event handler is never sent, and GearSwap runs
    -- a self command wrapped, so the rebuild lands. Components that load before this file
    -- call it, and it resolves late in every one of them.
    function equip_set_command()
        windower.send_command("gs c update auto")
    end

    -- The startup schedule, deferred and staggered, with every delay in seconds. Nothing here
    -- can run at load: the job file has not finished loading, so its sets do not exist yet,
    -- and the client has not settled. The steps run in the order each one needs. The
    -- placeholders the job file dropped are put back, its buff children discovered and its
    -- legacy set names aliased. The boxes appear. The Dual Wield trait and the main weapon's
    -- kind are read, and the weapon lock the job file may have set is bridged and resolved.
    -- Unlock frees every slot the lock does not hold and asks for a rebuild, and the polling
    -- engine runs a pass. The two notices come last, after everything they report on has run.
    --
    -- Two schedules at one delay run in no stated order, so steps share a delay only where
    -- their order does not matter. The eleven tracker's question shares discovery's, since
    -- every answer arrives in a later frame, after discovery has run. The main-weapon check and
    -- the weapon lock's two steps share another: the check touches neither, and the bridge
    -- resolves the lock itself whenever it changes it.
    coroutine.schedule(E.discover_buff_children, 1.9)
    coroutine.schedule(E.roll_query, 1.9)
    coroutine.schedule(display_box_update, 2.0)
    coroutine.schedule(dual_wield_check, 2.1)
    coroutine.schedule(two_hand_check, 2.2)
    coroutine.schedule(bridge_weapon_lock, 2.2)
    coroutine.schedule(resolve_weapon_lock, 2.2)
    coroutine.schedule(Unlock, 2.3)
    coroutine.schedule(main_engine, 2.4)
    coroutine.schedule(migration_notice, 2.5)
    coroutine.schedule(settings_reset_announce, 2.6)

    -- Arm the release of a Hoxne Ampulla left worn by a previous load, which the Hoxne tick
    -- performs while the mode is off. The first attempt comes after the startup equips above,
    -- so the release and those equips do not compete for range and ammo.
    hoxne.release_tries = 10
    hoxne.release_next  = os.clock() + 3
end
