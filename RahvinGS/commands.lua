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
-- COMPONENT: commands -- section 21: the self commands
----------------------------------------------------------------------------------------------------
-- CONTENTS
--   Section 21 - Everything reachable through 'gs c ...', in five parts:
--     Argument handling ... command_arg, and the mode validator every mode command shares
--     The argument table .. which commands take an argument, and so match on one word
--     The handlers ........ one per command, keyed by the exact command each answers
--     The dispatcher ...... self_command, and the fall-through into the job file
--     Native words ........ the advisory line for GearSwap's own //gs disable and //gs enable
--
-- THE COMMAND SET SERVES THREE AUDIENCES, and most of this file's design follows from that:
--     Typed by the player ... the bulk of it -- toggles, diagnostics, item shortcuts
--     Bound to a key ........ the four modes lifecycle.lua binds on F12 down to F9 --
--                             OffenseMode, TreasureHunter, WeaponLock and WeaponMode -- and
--                             JobMode, JobMode2, Hoxne and SpellReceived on those same four
--                             keys with Ctrl
--     Sent by the engine .... FOUR -- update auto, enchrepair, hoxnerelock, hoxnerelease. A
--                             raw event handler cannot equip, so it sends itself one of these
--                             and the equip lands inside the wrapped command instead
--   The key bindings send mixed case, 'gs c OffenseMode'. They resolve only because the
--   dispatcher lowercases before it looks anything up.
--
-- RESOLUTION IS WHOLE STRING, THEN FIRST WORD, AND NEVER A SUBSTRING. 'gs c use <item>'
--          carries a free-text item name, so a dispatcher that looked for a command keyword
--          anywhere in the string would swallow it -- 'gs c use hoxne ampulla' cycled the
--          Hoxne mode instead of using the item. A command reaches its handler by its exact
--          name, or by its first word when that word is in the argument table below.
--
-- RETURNING true MEANS HANDLED, and it decides whether the job file ever sees the command.
--          The split is stated once, at the command_handlers declaration below; a handler
--          returning nothing leaves the job file's self_command_custom running and its own
--          handling working.
--          Three handlers -- weaponmode, jobmode, jobmode2 -- call that hook themselves and
--          then return true, so it fires once, before the gear rebuild rather than after.
--          CHANGING WHICH COMMANDS REACH THE HOOK CHANGES JOB-FILE BEHAVIOR WITH NO ERROR
--          ANYWHERE: the shipped RNG file calls its ammunition routine from that hook on every
--          command that reaches it, and would simply stop being called.
--
-- EXPORTS  one name, native_disable_notice, which the root registers on the addon command
--          event. self_command is a global, and GearSwap looks it up by name when a 'gs c'
--          arrives; the dispatch table and every handler in it stay private to this file.
-- LOADS    Thirteenth of fifteen. equip_set_command resolves LATE -- it belongs to the root,
--          which loads last.

-- requires: rahvings/core, rahvings/equip, rahvings/enchant, rahvings/hoxne, rahvings/builders, rahvings/spellreceived, rahvings/display
return function(E)
    -- Bound once at construction, so no handler repeats the lookup for them. The
    -- cross-component mutables are never bound here: ench_active and lock_range are reached
    -- through E at every touch, because a file-local copy would not be the one the other
    -- components read and write.
    -- The requires line above names only the components THESE come from. The globals handlers
    -- also call -- equip, escha_temps, two_hand_check, the display box updates -- are
    -- resolved when the command runs, long after every component has loaded, so they
    -- constrain nothing about load order and are deliberately not declared there.
    local BUFF_ENCHANTMENT, EXTDATA_TS_CORRECTION, HOXNE_AMPULLA = E.BUFF_ENCHANTMENT, E.EXTDATA_TS_CORRECTION, E.HOXNE_AMPULLA
    local build_current_set, cancel_enchantment, enchantment_waits = E.build_current_set, E.cancel_enchantment, E.enchantment_waits
    local find_enchantment, gs_debug, gs_equip, gs_status = E.find_enchantment, E.gs_debug, E.gs_equip, E.gs_status
    local hoxne, hoxne_arm_use_lockout, hoxne_equip_ampulla = E.hoxne, E.hoxne_arm_use_lockout, E.hoxne_equip_ampulla
    local hoxne_release_step, lock_mode, reset_set_warnings = E.hoxne_release_step, E.lock_mode, E.reset_set_warnings
    local reset_spell_received_state, save_settings, settings = E.reset_spell_received_state, E.save_settings, E.settings
    local best_capacity_cape, locked_capacity_slot = E.best_capacity_cape, E.locked_capacity_slot
    local scan_capacity_capes, use_gated_ja = E.scan_capacity_capes, E.use_gated_ja
    local resolve_weapon_lock, strip_sweep = E.resolve_weapon_lock, E.strip_sweep
    local bridge_weapon_lock, slot_claim, strip_mode = E.bridge_weapon_lock, E.slot_claim, E.strip_mode
    local disable_mode = E.disable_mode
    local report_refused = E.report_refused
    local display_styles, set_display_style = E.display_styles, E.set_display_style
    local display_visible = E.display_visible

    ------------------------------------------------------------------------------------------------
    -- SECTION 21 - SELF COMMANDS
    ------------------------------------------------------------------------------------------------
    -- Everything reachable through 'gs c ...' -- what a player types, what the eight key
    -- bindings send, and the four commands the engine sends itself to get an equip inside a
    -- wrapped event.

    -- Argument handling ---------------------------------------------------------------------------

    -- Everything after the first word, trimmed, or nil when the command was bare. Reads the
    -- ORIGINAL cmd rather than its lowercased form, so an item or profile name keeps the
    -- capitalization the player typed.
    local function command_arg(cmd)
        local arg = cmd:match('^%s*%S+%s+(.-)%s*$')
        if not arg or arg == '' then return nil end
        return arg
    end

    -- The values a mode will accept, in cycle order. Returns an empty list for anything that
    -- is not a list-backed mode, which is what keeps the validator below from throwing on a
    -- job file that declared a mode some other way.
    local function mode_options(m)
        local opts = T {}
        if type(m) == 'table' and m._track and m._track._type == 'list' then
            for _, v in ipairs(m) do opts:insert(tostring(v)) end
        end
        return opts
    end

    -- Match a typed argument against a mode's options. Returns the canonical option on a
    -- case-insensitive EXACT match; otherwise nil and, where one exists, the nearest option as
    -- a suggestion -- prefix first, then substring.
    --
    -- A PARTIAL MATCH IS NEVER SILENTLY ACCEPTED. The near-miss passes are for the message
    -- only. Accepting a prefix would make 'gs c weaponmode c' mean whichever weapon happens to
    -- be listed first, and that answer would change when a job file reorders its own modes.
    local function match_mode_value(m, arg)
        local opts = mode_options(m)
        if not arg then return nil, nil, opts end
        local want = arg:lower()
        for _, v in ipairs(opts) do
            if v:lower() == want then return v, nil, opts end
        end
        for _, v in ipairs(opts) do
            local lv = v:lower()
            if lv:startswith(want) or want:startswith(lv) then return nil, v, opts end
        end
        for _, v in ipairs(opts) do
            local lv = v:lower()
            if lv:contains(want) or want:contains(lv) then return nil, v, opts end
        end
        return nil, nil, opts
    end

    -- Validate an argument and set the mode from it. True when the mode changed; false after
    -- it has already said why not. Every mode command shares this, which is why a bad argument
    -- reads the same whichever mode it was aimed at, and why the usage line always lists the
    -- options the job file actually declared rather than a fixed set.
    local function set_mode_arg(m, label, usage, arg)
        local value, suggestion, opts = match_mode_value(m, arg)
        if value then
            m:set(value)
            return true
        end
        if arg then
            warn(('%s: "%s" is not a valid mode.%s'):format(
                label, tostring(arg), suggestion and (' Did you mean [' .. suggestion .. ']?') or ''))
        else
            warn(('%s: no mode given.'):format(label))
        end
        warn(('Usage: //gs c %s [%s]'):format(usage, opts:concat('|')))
        return false
    end

    -- The argument table ------------------------------------------------------------------------

    -- The commands that accept an argument, and so may be matched on their first word.
    -- Everything else matches only as a complete string -- which is what lets 'warp' and
    -- 'warp club' both be handlers without one shadowing the other, and what makes
    -- 'gs c warp foo' unknown rather than a Warp Ring.
    --
    -- ADDING A NAME HERE WIDENS WHAT ITS FIRST WORD SWALLOWS: every command whose first
    -- whitespace-delimited word IS that word now resolves to that handler instead of being
    -- unknown. A longer word merely beginning with it does not -- 'nakedunlocked' is one
    -- token and looks up itself, never the 'naked' row, and so are 'enableall' and
    -- 'enablebymode' beside the 'enable' row. Whether the job file
    -- still sees it depends on the handler, not on this table -- one returning true takes the
    -- command away from every job file that was answering it, while one returning nothing
    -- leaves the trailing hook firing as before. The lock modes return nothing.
    local command_takes_arg = {
        ["abysseaproc"] = true,
        ["aptitude"] = true,
        ["capacity"] = true,
        ["displaystyle"] = true,
        ["disable"] = true,
        ["dynamisrp"] = true,
        ["enable"] = true,
        ["enchinfo"] = true,
        ["mecisto"] = true,
        ["hoxne"] = true,
        ["jubilee"] = true,
        ["jobmode"] = true,
        ["jobmode2"] = true,
        ["naked"] = true,
        ["offensemode"] = true,
        ["profile"] = true,
        ["spellreceived"] = true,
        ["treasurehunter"] = true,
        ["use"] = true,
        ["weaponlock"] = true,
        ["weaponmode"] = true,
        ["weaponsonly"] = true,
    }

    -- The handlers --------------------------------------------------------------------------------

    -- Every handler takes the same two arguments: cmd as the player typed it, and command as
    -- the lowercased, trimmed form the table was keyed on. Read cmd where the original case
    -- has to survive -- the profile path does -- and command everywhere else, including the
    -- item names, which are looked up case-insensitively anyway.
    --
    -- RETURNING true SUPPRESSES THE JOB FILE'S HOOK. Most of the handlers below do not, on
    -- purpose, so a job file still gets to act on the same command. A handler that starts
    -- returning true silently takes that command away from every job file.
    local command_handlers = {}

    -- Throttle on the [Empty] warning below, so a broken set list does not fill the log.
    local empty_set_gate = 0

    -- Rebuild the set the current modes call for, and wear it.
    --
    -- EVERY GEAR REBUILD IN THE ENGINE ARRIVES HERE. equip_set_command is nothing but a send
    -- of this command; seven components call it, an eighth schedules it, and lifecycle also
    -- sends the command itself at the end of a job change. That indirection is the point: a
    -- raw event handler cannot equip, so the work is deferred into a wrapped self command.
    command_handlers["update auto"] = function(cmd, command)
        local built_set = build_current_set()
        -- An empty result means no chosen set carries any gear, which is nearly always a job
        -- file mistake. Sleep is the one deliberate empty set, so it is excluded, and the
        -- warning repeats at most every 30 seconds.
        if next(built_set) == nil and not buffactive['Sleep'] and os.clock() >= empty_set_gate then
            empty_set_gate = os.clock() + 30
            warn('Chosen set is [Empty] - nothing to equip. gs c checksets lists your sets.')
        end
        equip(built_set)
        return true
    end

    -- Put both boxes back in the top-left corner. The recovery for a box dragged off-screen,
    -- where there is nothing left to grab.
    command_handlers["zero"] = function(cmd, command)
        display_zero_command()
    end

    -- Switch the mode box between one line and several, and remember the choice.
    command_handlers["displaymode"] = function(cmd, command)
        settings.oneline = not settings.oneline
        notice('One line display is: [' .. (settings.oneline and "ON" or "OFF") .. ']')
        display_box_update()
        save_settings()
    end

    -- The renderer axis, beside the view axis displaymode flips: which renderer draws the
    -- box, rather than how many lines it takes. Bare cycles through the styles this build
    -- offers, an argument selects one by name, and a name that is not on offer is refused
    -- with the list. The choice is written to settings straight away, the way displaymode
    -- writes its own -- under the character playing, so each one keeps its own style.
    command_handlers["displaystyle"] = function(cmd, command)
        local styles = display_styles()
        local arg = command_arg(cmd)
        local want
        if not arg then
            local at = 1
            for i, s in ipairs(styles) do
                if s == settings.Display_Style then at = i end
            end
            want = styles[at % #styles + 1]
        else
            -- Matched without regard to case, as every command taking a name from a list
            -- does: the keybinds this engine installs spell their commands in mixed case, so
            -- a player spelling the style the same way gets it rather than a refusal.
            local wanted = arg:lower()
            for _, s in ipairs(styles) do
                if s:lower() == wanted then want = s end
            end
            if not want then
                warn(('Display Style: "%s" is not a style.'):format(tostring(arg)))
                warn(('Usage: //gs c displaystyle [%s]'):format(table.concat(styles, '|')))
                return true
            end
        end
        set_display_style(want)
        notice('Display Style: [' .. want .. ']')
        save_settings()
        return true
    end

    -- The first of the eight mode commands, and the shape they all share: bare cycles to the
    -- next value, an argument sets one exactly. A rejected argument returns true without
    -- touching the mode, so a typo changes nothing and does not reach the job file either.
    -- Bound to F11 as well as typed.
    command_handlers["treasurehunter"] = function(cmd, command)
        if command == "treasurehunter" then
            state.TreasureMode:cycle()
            notice('Treasure Hunter Mode: [' .. state.TreasureMode.value .. ']')
            display_box_update()
        elseif set_mode_arg(state.TreasureMode, 'Treasure Hunter', 'TreasureHunter', command_arg(cmd)) then
            notice('Treasure Hunter Mode: [' .. state.TreasureMode.value .. ']')
            display_box_update()
        else
            return true
        end
        equip_set_command()
        return true
    end

    -- Multibox received-gear tracking, on ^F9. Same shape as the mode command above, plus a
    -- release of everything the feature is holding.
    command_handlers["spellreceived"] = function(cmd, command)
        if command == "spellreceived" then
            state.SpellReceived:cycle()
            notice('Spell Received Mode: [' .. state.SpellReceived.value .. ']')
            display_box_update()
        elseif set_mode_arg(state.SpellReceived, 'Spell Received', 'SpellReceived', command_arg(cmd)) then
            notice('Spell Received Mode: [' .. state.SpellReceived.value .. ']')
            display_box_update()
        else
            return true
        end
        -- Released on EVERY switch, not only on the way to OFF. Both delivery paths claim
        -- into one registry and each releases under its own mode, so a claim made in one mode
        -- and left behind by a switch would never be handed back.
        reset_spell_received_state()
        equip_set_command()
        return true
    end

    -- Three of the four engine-internal commands, together; update auto at the top of the
    -- table is the fourth. Nothing a player types: each is sent by a raw event handler that
    -- needs an equip, and exists only so that equip lands here, inside a wrapped command.
    --
    -- Re-take the Ampulla. Sent by hoxne.lua's prerender driver. Skips if a borrow window
    -- opened while the command was in flight, so an asynchronous re-lock can never take the
    -- slot back from an instrument that is using it.
    command_handlers["hoxnerelock"] = function(cmd, command)
        if state.Hoxne.value ~= 'OFF' and not hoxne.window then
            hoxne_equip_ampulla()
            hoxne_arm_use_lockout()
            equip_set_command()
        end
        return true
    end

    -- Give a stranded Ampulla back. A reload resets the mode to OFF but cannot unequip, so
    -- the Ampulla stays worn with nothing left that believes it owns the slot; the tick sends
    -- this until the release reports done.
    command_handlers["hoxnerelease"] = function(cmd, command)
        if state.Hoxne.value == 'OFF' then
            if hoxne_release_step() == 'done' then hoxne.release_tries = 0 end
        end
        return true
    end

    -- Put an enchanted item back on mid-use. Sent by enchant.lua's tick when the item it is
    -- holding has been dropped from the slot. Enables the slot, equips through the captured
    -- original so the Hoxne filter cannot intercept it, then disables it again.
    command_handlers["enchrepair"] = function(cmd, command)
        local st = E.ench_active
        if st then
            enable(st.slot)
            gs_equip({ [st.slot] = st.name })
            disable(st.slot)
        end
        return true
    end

    -- Diagnostic, read-only: dump the live extdata for one enchanted item, so the cooldown
    -- and activation the engine believes in can be compared against what the item actually
    -- says. Usage: gs c enchinfo warp ring. Answers on four separate paths, because "nothing
    -- happened" has four different causes worth telling apart -- unknown name, not carried,
    -- carried but undecodable, and a full reading.
    command_handlers["enchinfo"] = function(cmd, command)
        local name = command_arg(cmd)
        local row, ext, carried, equipped = find_enchantment(name or '')
        if not row then
            notice('enchinfo: unknown item [' .. tostring(name) .. ']')
        elseif not carried then
            notice(row.en .. ': not in inventory or wardrobes.')
        elseif not ext then
            notice(row.en .. ': carried, but extdata did not decode.')
        else
            local now_t = os.time() - EXTDATA_TS_CORRECTION
            local recast, activation = enchantment_waits(ext)
            notice(('%s: equipped=%s usable=%s charges=%s activation %+ds next_use %+ds (epoch-corrected)'):format(
                row.en, tostring(equipped), tostring(ext.usable), tostring(ext.charges_remaining),
                (ext.activation_time or now_t) - now_t, (ext.next_use_time or now_t) - now_t))
            notice(('  -> engine sees: cooldown %ds (warns/refuses), equip delay %ds (waits quietly)'):format(
                recast or 0, activation or 0))
        end
        return true
    end

    -- Diagnostic, read-only: every capacity point cape carried, what each one is worth, which
    -- copy the mode picks, and what is actually worn. Usage: gs c capinfo
    --
    -- This is the only view of the case the engine cannot detect for itself. Two copies of one
    -- name are indistinguishable in player.equipment, and when an augment request matches no
    -- carried copy nothing is unequipped -- the slot is simply left alone -- so a cape worn
    -- from the wrong copy reads as success on every other path. Closing that continuously
    -- would put a nine-bag walk with extdata decodes on the gear rebuild, so it is closed
    -- here instead, on demand and off every hot path.
    command_handlers["capinfo"] = function(cmd, command)
        local carried = scan_capacity_capes() or {}
        if #carried == 0 then
            notice('capinfo: no capacity point cape carried, or none currently wearable.')
            return true
        end

        local best, spare = best_capacity_cape(carried)
        local chosen = best or spare
        local slot = locked_capacity_slot()
        notice(('capinfo: %d carried; mode %s'):format(#carried,
            slot and ('[ON] holding ' .. slot .. '.') or '[OFF].'))

        for _, c in ipairs(carried) do
            notice(('  %-19s %-11s %s%s'):format(
                c.row.en,
                c.value and ('+' .. c.value .. '%') or 'unreadable',
                c.augments and table.concat(c.augments, ', ') or '-',
                c == chosen and '   <- chosen' or ''))
        end

        -- Name against name is the whole comparison available, so a match is reported as a
        -- match of NAMES and never as confirmation that the right copy is on.
        if slot then
            local worn = player.equipment[slot]
            if worn ~= chosen.row.en then
                notice(('  %s holds [%s], which is NOT the chosen cape.'):format(
                    slot, tostring(worn)))
            elseif chosen.augments then
                notice(('  %s holds %s -- the name matches; which copy is worn cannot be read.'):format(
                    slot, tostring(worn)))
            else
                notice(('  %s holds %s -- matches.'):format(slot, tostring(worn)))
            end
        end
        return true
    end

    -- Diagnostic, read-only: everything the Hoxne subsystem gates on, in one place.
    -- Usage: gs c hoxneinfo
    command_handlers["hoxneinfo"] = function(cmd, command)
        local row, ext, carried, equipped = find_enchantment(HOXNE_AMPULLA)
        local recast, activation = enchantment_waits(ext)
        -- The two sources are printed separately, and labeled, because they can disagree:
        -- after a reload player.equipment may read inverted while the bag status stays
        -- correct. When these two lines contradict each other, believe the second.
        notice(('Hoxne [%s]  buff=%s  window=%s  release attempts left=%d'):format(
            state.Hoxne.value, tostring(buffactive[BUFF_ENCHANTMENT] and true or false),
            tostring(hoxne.window), hoxne.release_tries))
        notice(('  player.equipment: ammo=[%s] range=[%s]'):format(
            tostring(player.equipment.ammo), tostring(player.equipment.range)))
        notice(('  live bag status:  ampulla carried=%s equipped=%s cooldown=%ds equip delay=%ds'):format(
            tostring(carried), tostring(equipped), recast or 0, activation or 0))
        return true
    end

    -- Diagnostic, read-only: sort every declared set into carries gear, declared but empty,
    -- and engine placeholder the job file never declared. Usage: gs c checksets. It clears the
    -- set index and the warning throttles first, so running it twice in a row gives the same
    -- answer both times rather than a quieter one.
    command_handlers["checksets"] = function(cmd, command)
        invalidate_set_index()
        reset_set_warnings()
        local gear, empty, undeclared = set_diagnostics()
        notice(('Sets with gear: %d.  Engine placeholders left undeclared: %d.'):format(#gear, #undeclared))
        if #empty == 0 then
            notice('Declared [Empty] sets: none.')
        else
            notice('Declared [Empty] sets: ' .. table.concat(empty, ', '))
        end
        return true
    end

    -- The lock modes: hold one item in its slot until told otherwise. Bare toggles, 'on' and
    -- 'off' set it outright. None returns true, so a job file still sees the command.
    --
    -- The capacity point lock answers to three words, all running the same chooser: 'mecisto'
    -- names the mode, it does not force a Mecisto. Its item is chosen by scanning rather than
    -- fixed, so 'on' while already on re-scans and re-issues instead of re-asserting what it
    -- holds, and turning it off clears the choice.
    command_handlers["capacity"] = function(cmd, command)
        lock_mode('capacity', command_arg(cmd))
    end

    command_handlers["aptitude"] = function(cmd, command)
        lock_mode('aptitude', command_arg(cmd))
    end

    command_handlers["mecisto"] = function(cmd, command)
        lock_mode('mecisto', command_arg(cmd))
    end

    -- The Dynamis Divergence neck lock. Its piece is chosen from the main job's three ranks
    -- rather than fixed, so 'on' while already on chooses afresh and wears a better rank
    -- acquired since. Usable anywhere; a zone change clears it with the other lock modes.
    command_handlers["dynamisrp"] = function(cmd, command)
        lock_mode('dynamisrp', command_arg(cmd))
    end

    -- Setting this one already on re-asserts the hold, which is what makes the bare command
    -- double as the repair when something took the slot behind the engine's back.
    command_handlers["jubilee"] = function(cmd, command)
        lock_mode('jubilee', command_arg(cmd))
    end

    -- Hoxne Ampulla mode, on ^F10. The longest handler in the file, because switching this
    -- mode is the only command that both takes a slot and gives it back, and every step has
    -- to be answered before the next one is attempted.
    command_handlers["hoxne"] = function(cmd, command)
        -- The disable and strip holds both outrank the Ampulla. While either holds EITHER
        -- slot the mode cannot move in either direction: the held slots are named and the
        -- command stops here, rather than setting a mode whose gear could not follow it.
        -- Both slots are asked because a hold can stand on range alone -- gs c disable
        -- range, or a naked hold while an item use has ammo -- and both the ON path's
        -- enable and the OFF path's would open it.
        local held
        local range_claim, ammo_claim = slot_claim('range'), slot_claim('ammo')
        if range_claim == 'strip' or range_claim == 'disable' then
            held = { range = range_claim }
        end
        if ammo_claim == 'strip' or ammo_claim == 'disable' then
            held = held or {}
            held.ammo = ammo_claim
        end
        if held then
            report_refused('Hoxne Ampulla', held, notice)
            return true
        end
        if command == "hoxne" then
            state.Hoxne:cycle()
            notice('Hoxne Ampulla Mode: [' .. state.Hoxne.value .. ']')
            display_box_update()
        elseif set_mode_arg(state.Hoxne, 'Hoxne Ampulla', 'Hoxne', command_arg(cmd)) then
            notice('Hoxne Ampulla Mode: [' .. state.Hoxne.value .. ']')
            display_box_update()
        else
            return true
        end
        if state.Hoxne.value ~= 'OFF' then
            local _, _, carried = find_enchantment(HOXNE_AMPULLA)
            if carried then
                -- Hoxne owns range above the weapon lock: a Locked+R lock is re-resolved
                -- here, which is where it stands down to Locked, before the Ampulla takes
                -- the slot, and the box is repainted for it.
                if E.lock_range then
                    resolve_weapon_lock()
                    display_box_update()
                end
                hoxne.window     = false
                hoxne.recheck_at = 0
                if state.Hoxne.value == 'ON-Allow Critical' then
                    -- Allow-Critical holds the Ampulla without disabling the slots. The enable
                    -- also clears a hold left behind by switching straight over from
                    -- ON-Locked, which would otherwise survive into a mode that never set it.
                    enable('range', 'ammo')
                end
                hoxne_equip_ampulla()
                local hx_recast = hoxne_arm_use_lockout()
                -- Said once, here, because the player just asked. The tick throttles its own
                -- warnings, so without this the answer to a deliberate command could be
                -- swallowed by a throttle the player never saw start.
                if hx_recast > 0 then
                    notice(('Hoxne Ampulla is on cooldown for %ds; it will be used as soon as it is ready.')
                        :format(math.ceil(hx_recast)))
                end
                if state.Hoxne.value == 'ON-Allow Critical' then
                    notice('Hoxne locked. Songs, Geomancy, Tomahawk and Angon may borrow range/ammo.')
                else
                    notice('Hoxne locked. Range and ammo are held; instruments and Angon/Tomahawk will not equip.')
                end
            else
                warn("Hoxne Ampulla not found.  Not locking range/ammo")
                state.Hoxne:set('OFF')
                notice('Hoxne Ampulla Mode: [' .. state.Hoxne.value .. ']')
                display_box_update()
            end
        else
            hoxne.window     = false
            hoxne.recheck_at = 0
            enable('range', 'ammo')
            -- Start the release here and let the tick confirm it. One call is not enough when
            -- GearSwap's picture of what is worn has drifted from the server's, so five
            -- retries are armed and the first is two seconds out.
            if hoxne_release_step() ~= 'done' then
                hoxne.release_tries = 5
                hoxne.release_next  = os.clock() + 2
            end
            notice('Hoxne mode disabled.  Range and ammo unlocked.')
        end
        equip_set_command()
        return true
    end

    -- Close this game client. The one command here that does not come back.
    command_handlers["shutdown"] = function(cmd, command)
        send_command('terminate')
    end

    -- Write the settings file now, box positions included. The text library also writes it
    -- when a box drag ends, because the boxes are created with the settings root; this
    -- command is the on-demand write for everything else.
    command_handlers["save"] = function(cmd, command)
        save_settings()
    end

    -- The two box toggles. Each pairs visibility with draggability in both directions, so a
    -- hidden box cannot be dragged, and each repaints on the way back rather than letting the
    -- box reappear holding whatever it last showed. gs c debug does double duty: the same
    -- setting that shows the debug box is the one that opens the log channel.
    command_handlers["display"] = function(cmd, command)
        if settings.visible == true then
            settings.visible = false
            gs_status:hide()
            gs_status:draggable(false)
            display_visible(false)
        else
            settings.visible = true
            gs_status:draggable(true)
            gs_status:show()
            display_visible(true)
            display_box_reset()
            display_box_update()
        end
        notice(settings.visible and 'The UI is now shown' or 'The UI is now hidden')
    end

    command_handlers["debug"] = function(cmd, command)
        if settings.debug == true then
            settings.debug = false
            gs_debug:hide()
            gs_debug:draggable(false)
        else
            settings.debug = true
            gs_debug:draggable(true)
            gs_debug:show()
            debug_box_reset()
            debug_box_update()
        end
        notice('Debugging is now [' .. (settings.debug and 'ON' or 'OFF') .. ']')
    end

    -- The three chat channel toggles: warn for set problems, gearreporting for the
    -- set-selection trace, info for ordinary feedback. Each answers on notice, which has no
    -- gate of its own -- the confirmation for switching a channel OFF cannot go out on the
    -- channel it just silenced. None of the three saves, so the change lasts until the next
    -- reload unless gs c save follows it.
    command_handlers["warn"] = function(cmd, command)
        if settings.warn == true then
            settings.warn = false
        else
            settings.warn = true
        end
        notice('The set warning is now [' .. (settings.warn and 'ON' or 'OFF') .. ']')
    end

    command_handlers["gearreporting"] = function(cmd, command)
        if settings.gear_reporting == true then
            settings.gear_reporting = false
        else
            settings.gear_reporting = true
        end
        notice('Gear reporting is now [' .. (settings.gear_reporting and 'ON' or 'OFF') .. ']')
    end

    command_handlers["info"] = function(cmd, command)
        if settings.info == true then
            settings.info = false
        else
            settings.info = true
        end
        notice('Information is now [' .. (settings.info and 'ON' or 'OFF') .. ']')
    end

    -- Re-read the two-handed flag from the weapon the current mode names. The engine does this
    -- itself at load and on every weapon-mode change; the command is the manual repair for
    -- when the flag and the worn weapon have drifted apart.
    command_handlers["two_hand_check"] = function(cmd, command)
        two_hand_check()
    end

    -- Drink the six Escha temporary items, one chained command with a wait between each.
    command_handlers["temps"] = function(cmd, command)
        escha_temps()
    end

    -- Stop an enchanted item use that is under way. Three answers, because the outcome depends
    -- on how far the use had got: nothing running, already sent to the server and past
    -- recalling, or stopped. Does not return true, matching the shortcuts below, so a job file
    -- still sees the command.
    command_handlers["cancel"] = function(cmd, command)
        local name, sent = cancel_enchantment()
        if not name then
            notice('Nothing to cancel.')
        elseif sent then
            warn(name .. ': already sent and cannot be recalled; move to interrupt it.')
        else
            notice('Canceled [' .. name .. '].')
        end
    end

    -- Tomahawk and Angon. The client refuses a typed /ja for either while the throwing item is
    -- not worn, so these equip it first and issue the ability once the equip has landed. Every
    -- reason the ability could fail is answered before any gear moves -- moving gear for an
    -- action that cannot fire parks the wrong ammo for the whole watchdog window.
    command_handlers["tomahawk"] = function(cmd, command)
        use_gated_ja(150)
    end

    command_handlers["angon"] = function(cmd, command)
        use_gated_ja(170)
    end

    -- Six shortcuts for the enchanted items worth a name of their own. Each is the same call
    -- gs c use makes, with the item named here so it need not be typed and cannot be
    -- misspelled. 'warp club' is a two-word handler key, and it works because resolution
    -- tries the whole string before the first word -- otherwise 'warp' would claim it.
    command_handlers["warp"] = function(cmd, command)
        use_enchantment("Warp Ring")
    end

    command_handlers["warp club"] = function(cmd, command)
        use_enchantment("Warp Cudgel")
    end

    command_handlers["holla"] = function(cmd, command)
        use_enchantment("Dim. Ring (Holla)")
    end

    command_handlers["dem"] = function(cmd, command)
        use_enchantment("Dim. Ring (Dem)")
    end

    command_handlers["mea"] = function(cmd, command)
        use_enchantment("Dim. Ring (Mea)")
    end

    command_handlers["trizek"] = function(cmd, command)
        use_enchantment("Trizek Ring")
    end

    -- Offense mode, on F12. The plainest of the eight: no state to release, no slot to take.
    command_handlers["offensemode"] = function(cmd, command)
        if command == 'offensemode' then
            state.OffenseMode:cycle()
        elseif not set_mode_arg(state.OffenseMode, 'Offense Mode', 'OffenseMode', command_arg(cmd)) then
            return true
        end
        notice('Offense Mode: [' .. state.OffenseMode.value .. ']')
        display_box_update()
        equip_set_command()
        return true
    end

    -- Weapon mode, on F9, and the first of the three that CALL THE JOB FILE'S HOOK THEMSELVES
    -- before returning true. The hook fires between the echo and the gear rebuild, so a job
    -- file may change a macro book or another mode and have it land in the same rebuild rather
    -- than causing a second one. It also runs the two-hand check, because the mode it just set
    -- is what names the weapon, and bridges the legacy 'Unlocked'/'Locked' weapon modes to
    -- the lock with the mode it left, before the box refreshes so the box shows the result.
    command_handlers["weaponmode"] = function(cmd, command)
        local before = state.WeaponMode.value
        if command == 'weaponmode' then
            state.WeaponMode:cycle()
        elseif not set_mode_arg(state.WeaponMode, 'Weapon Mode', 'WeaponMode', command_arg(cmd)) then
            return true
        end
        notice('Weapon Mode: [' .. state.WeaponMode.value .. ']')
        bridge_weapon_lock(before)
        display_box_update()
        if self_command_custom then self_command_custom(command) end
        two_hand_check()
        equip_set_command()
        return true
    end

    -- Weapon lock, on F10. The shared mode shape, plus the resolution of the new value into
    -- the three lock flags before the echo, so no build path ever reads the mode itself.
    -- Hoxne owns range above the lock, so Locked+R is refused while Hoxne is on: by
    -- argument the lock stays where it was; on the cycle it is passed over, since a cycle
    -- that stopped there could never unlock while Hoxne stayed on.
    command_handlers["weaponlock"] = function(cmd, command)
        local previous = state.WeaponLock.value
        if command == 'weaponlock' then
            state.WeaponLock:cycle()
        elseif not set_mode_arg(state.WeaponLock, 'Weapon Lock', 'WeaponLock', command_arg(cmd)) then
            return true
        end
        if state.WeaponLock.value == 'Locked+R' and state.Hoxne.value ~= 'OFF' then
            notice('Weapon Lock: [Locked+R] refused; Hoxne Ampulla holds range.')
            if command ~= 'weaponlock' then
                state.WeaponLock:set(previous)
                return true
            end
            state.WeaponLock:cycle()
        end
        resolve_weapon_lock()
        notice('Weapon Lock: [' .. state.WeaponLock.value .. ']')
        display_box_update()
        equip_set_command()
        return true
    end

    -- The two job modes, on ^F11 and ^F12. Both call the job file's hook and then return true.
    -- These are the modes a job file defines the meaning of, which is why they are also the
    -- two most likely to be acted on there.
    command_handlers["jobmode2"] = function(cmd, command)
        -- The job file names these modes; when it has not, the fallback names them. Used for
        -- the validation message and the echo alike, so both read the same way.
        local label = UI_Name2 ~= '' and UI_Name2 or 'Job Mode 2'
        if command == 'jobmode2' then
            state.JobMode2:cycle()
        elseif not set_mode_arg(state.JobMode2, label, 'JobMode2', command_arg(cmd)) then
            return true
        end
        notice(label .. ': [' .. state.JobMode2.value .. ']')
        display_box_update()
        if self_command_custom then self_command_custom(command) end
        equip_set_command()
        return true
    end

    command_handlers["jobmode"] = function(cmd, command)
        -- As above. A job file that sets neither name still gets a labeled echo rather than a
        -- bare ': [Melee]'.
        local label = UI_Name ~= '' and UI_Name or 'Job Mode'
        if command == 'jobmode' then
            state.JobMode:cycle()
        elseif not set_mode_arg(state.JobMode, label, 'JobMode', command_arg(cmd)) then
            return true
        end
        notice(label .. ': [' .. state.JobMode.value .. ']')
        display_box_update()
        if self_command_custom then self_command_custom(command) end
        equip_set_command()
        return true
    end

    -- Run a Windower script chosen by the current job pairing: everything after the first word
    -- becomes a directory path, and the file inside it is named main_sub_character. The words
    -- are split on alphanumerics only, so a path containing anything else loses that part
    -- silently. A bare 'gs c profile' reaches here too and sends an exec with an empty path.
    command_handlers["profile"] = function(cmd, command)
        local modes = {}
        for mode in string.gmatch(cmd, "(%w+)") do
            table.insert(modes, mode)
        end
        local smModePath = table.concat(modes, '_', 2, #modes)
        notice('Profile: [' .. modes[#modes] .. ']')
        windower.send_command('exec ' .. smModePath .. '/' .. player.main_job ..
            '_' .. player.sub_job .. '_' .. player.name)
    end

    -- Eat whatever the job file named. Food is a JOB FILE GLOBAL the engine never declares, so
    -- this concatenates whatever the file left there; every job file in the tree sets it, and
    -- one that did not would fail here rather than at load. It is also the command job files
    -- send most: every one of them has a macro or a rule that reaches it.
    command_handlers["food"] = function(cmd, command)
        windower.chat.input('/item "' .. Food .. '" <me>')
    end

    -- Use any enchanted item by name. Takes either the short or the long resource name, and
    -- works out the slot, the equip timeout and the cast time from the item itself. The slice
    -- drops the leading 'use ' and passes the rest through untouched -- including spaces,
    -- which is exactly the free-text argument the whole-string-then-first-word resolution
    -- above exists to protect.
    command_handlers["use"] = function(cmd, command)
        use_enchantment(command:slice(5))
    end

    -- Say which engine version is loaded, read from the constant interface.lua declares and
    -- the root asserts every component against -- so it reports what is actually running
    -- rather than what any one component claims for itself.
    command_handlers["version"] = function(cmd, command)
        notice('Include Version is [' .. Rahvin_GS .. ']')
    end

    -- Stripping commands, for procs and for capping damage at one -----------------------------

    -- Strip every slot and HOLD it bare, as a claim the whole engine can see. Nothing below an
    -- item use dresses a held slot while it stands, and every layer that is refused says so by
    -- name. Bare flips the hold, on re-takes it as the manual repair, off ends it.
    command_handlers["naked"] = function(cmd, command)
        strip_mode('naked', command_arg(cmd))
    end

    -- Strip every slot WITHOUT holding it, so the next action or poll dresses the character
    -- again on its own. The momentary version, for a cure read off a lower maximum HP or a
    -- Sortie objective that wants the character bare for one instant. Every layer that was
    -- holding a slot keeps it shut and dresses it again at its own next chance.
    command_handlers["nakedunlocked"] = function(cmd, command)
        strip_sweep()
    end

    -- Strip and hold the twelve armor slots, leaving main, sub, range and ammo dressed. For
    -- procs that need a particular weapon on and everything else off it. This is the same
    -- hold naked takes in a different shape, so typing it while naked stands hands the four
    -- weapon slots back and keeps the twelve.
    command_handlers["weaponsonly"] = function(cmd, command)
        strip_mode('weaponsonly', command_arg(cmd))
    end

    -- Strip and hold the four armor pieces only -- head, hands, legs, feet. Lighter than
    -- weaponsonly, which takes eight more, and the difference is the point: body, neck, ears,
    -- rings, back and waist stay dressed for Abyssea red proccing.
    command_handlers["abysseaproc"] = function(cmd, command)
        strip_mode('abysseaproc', command_arg(cmd))
    end

    -- Hold the named slots wearing exactly what they already wear -- gs c disable head ear1,
    -- or gs c disable all for the sixteen. Nothing below an item use dresses a held slot
    -- while it stands, and every layer that is refused says so by name. Bare prints the
    -- usage line and what stands; an unrecognized slot word refuses the whole command.
    command_handlers["disable"] = function(cmd, command)
        disable_mode('disable', command_arg(cmd))
    end

    -- End the hold on the named slots, or on all of them, and hand each back to whoever is
    -- next in line. It never takes: gs c disable is the only word that does.
    command_handlers["enable"] = function(cmd, command)
        disable_mode('enable', command_arg(cmd))
    end

    -- The two releases, and they are not interchangeable. enableall frees every slot
    -- unconditionally, which is what makes it the manual override when something is stuck.
    -- enablebymode frees only what the current mode allows, and asks before taking a
    -- slot back from a layer still using it.
    command_handlers["enableall"] = function(cmd, command)
        Unlock()
    end

    command_handlers["enablebymode"] = function(cmd, command)
        UnlockByMode()
    end

    -- The dispatcher -----------------------------------------------------------------------------

    -- Resolve a command to its handler and run it. Whole string first, then the first word for
    -- the commands that take an argument -- never a substring, so an argument can never be
    -- read as a command name. Anything unresolved, and anything a handler did not claim by
    -- returning true, goes to the job file's own hook, which is how a job file adds commands
    -- of its own without the engine knowing about them.
    function self_command(cmd)
        local command = cmd:lower():trim()

        local handler = command_handlers[command]
        if not handler then
            local verb = command:match('^(%S+)')
            if verb and command_takes_arg[verb] then
                handler = command_handlers[verb]
            end
        end
        if handler and handler(cmd, command) then return end

        if self_command_custom then self_command_custom(command) end
    end

    -- The native console words -------------------------------------------------------------------

    -- GearSwap's own '//gs disable <slot>' and '//gs enable <slot>' disable a slot at the addon's
    -- level, where the engine cannot see it: no claim is registered, no refusal names it, the
    -- status box shows nothing, and the next Unlock re-enables it. This answers with one line
    -- pointing at the words that are tracked. It runs AFTER GearSwap's own handler, so the native
    -- disable has already happened and the line is advisory -- nothing here refuses, re-takes or
    -- equips.
    --
    -- A SECOND WORD MUST FOLLOW. Bare '//gs disable' and '//gs enable' switch the whole user file
    -- off and on rather than a slot, and there is no 'gs c' word to steer those to. The verb 'c'
    -- is the engine's own surface and answers for itself, which also keeps the rebuild the engine
    -- sends itself silent.
    local function native_disable_notice(first, second)
        if second == nil or type(first) ~= 'string' then return end
        local verb = first:lower()
        if verb == 'disable' then
            notice('Disable: //gs disable leaves the slot untracked -- use //gs c disable <slot>... instead.')
        elseif verb == 'enable' then
            notice('Disable: //gs enable is not tracked -- use //gs c enable <slot>..., or //gs c enableall for every slot.')
        end
    end

    -- The one export, and the root registers it. Every other command surface in this file is
    -- reached through self_command, which GearSwap looks up by name.
    E.native_disable_notice = native_disable_notice

    -- Version stamp, asserted by the root against the engine's own version constant. A stale
    -- copy of this file shadowing the current one announces itself at load, not later.
    return '2.0'
end
