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
--   Section 21 - Everything reachable through 'gs c ...', in six parts:
--     Argument handling ... command_arg, and the mode validator every mode command shares
--     The keybinds ........ the table of the eight key-bound modes, the keyspec grammar every
--                           key passes through, the registry of the keys this load holds, and
--                           the bind, release and key-list functions that lifecycle.lua calls
--                           at load and unload and the keybind command calls on a change
--     The argument table .. which commands take an argument, and so match on their first word
--     The handlers ........ one per command, keyed by the exact command each answers
--     The dispatcher ...... self_command, and the fall-through into the job file
--     Native words ........ the advisory line for GearSwap's own //gs disable and //gs enable
--
-- The commands serve three audiences:
--     Typed by the player ... most of them: toggles, diagnostics and item shortcuts
--     Bound to a key ........ the eight modes lifecycle.lua binds, through keybind_apply, to
--                             the keys in settings.Keybinds. By default OffenseMode,
--                             TreasureHunter, WeaponLock and WeaponMode take F12 down to F9,
--                             and JobMode, JobMode2, Hoxne and SpellReceived take the same
--                             four keys with Ctrl.
--     Sent by the engine .... update auto, enchrepair, hoxnerelock and hoxnerelease. A raw
--                             event handler cannot equip, so it sends one of these, and the
--                             equip lands inside the wrapped command.
-- The key bindings send mixed case, such as 'gs c OffenseMode'. They resolve because the
-- dispatcher lowercases a command before it looks anything up.
--
-- DISPATCH A command reaches its handler by its whole string first, then by its first word
--          when that word is in the argument table, and never by a substring. 'gs c use
--          <item>' carries a free-text item name, so a dispatcher that looked for a command
--          name anywhere in the string would swallow it, and 'gs c use hoxne ampulla' would
--          cycle the Hoxne mode instead of using the item.
-- RETURNS  A handler that returns true has handled the command, and the job file's
--          self_command_custom never sees it. A handler that returns nothing leaves the hook
--          to run after it. weaponmode, jobmode and jobmode2 call the hook themselves, before
--          the gear rebuild, and then return true, so it runs once. Changing which commands
--          reach the hook changes job-file behavior with no error anywhere. The shipped RNG
--          file calls its ammunition routine from that hook on every command that reaches it.
-- EXPORTS  native_disable_notice, which the root registers on the addon command event, and
--          the keybind functions keybind_apply, keybind_release and keybind_list, which
--          lifecycle.lua calls at load and unload. The mode table keybind_modes, the key
--          registry keybinds_bound and the keyspec grammar are exported beside them:
--          keyspec_parse, keyspec_human and keyspec_valid_setting. self_command is a
--          global, which GearSwap looks up by name when a 'gs c' command arrives. The
--          dispatch table and its handlers stay private to this file.
-- LOADS    After every component it binds from, and before lifecycle.lua, which binds its
--          keybind functions. equip_set_command belongs to the root, which loads last, so it
--          is resolved when a command runs.

-- requires: rahvings/core, rahvings/equip, rahvings/enchant, rahvings/hoxne, rahvings/builders, rahvings/spellreceived, rahvings/display
return function(E)
    -- The exports this file uses, bound once at construction. The shared mutable fields are
    -- never bound here. ench_active and lock_range are read through E at every touch,
    -- because a local copy would not be the one the other components read and write.
    --
    -- The requires line names only the components these bindings come from. The globals the
    -- handlers call, such as equip, use_enchantment and the display box updates, are
    -- resolved when a command runs, after every component has loaded, so they do not
    -- affect load order.
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
    local display_visible, min_value_cells = E.display_visible, E.min_value_cells
    local display_logged_out = E.display_logged_out

    ------------------------------------------------------------------------------------------------
    -- SECTION 21 - SELF COMMANDS
    ------------------------------------------------------------------------------------------------
    -- Everything reachable through 'gs c ...': what a player types, what the eight key
    -- bindings send, and the four commands the engine sends itself so that an equip lands
    -- inside a wrapped event.

    -- Argument handling ---------------------------------------------------------------------------

    -- Everything after the first word, trimmed, or nil when the command was bare. It reads
    -- the original cmd rather than the lowercased form, so an item or profile name keeps the
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

    -- Match a typed argument against a mode's options. Returns the option on an exact match,
    -- ignoring case. Otherwise it returns nil and, where one exists, the nearest option as a
    -- suggestion, trying a prefix match first and then a substring. The third value is the
    -- option list.
    --
    -- A partial match is never accepted. The near-miss passes only feed the message.
    -- Accepting a prefix would make 'gs c weaponmode c' mean whichever weapon is listed
    -- first, and that answer would change when a job file reorders its modes.
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

    -- Validate an argument and set the mode from it. Returns true when the mode was set, and
    -- false after printing why it was not. Every mode command shares this, so a bad argument
    -- reads the same for every mode, and the usage line lists the options the job file
    -- declared rather than a fixed set.
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

    -- The keybinds --------------------------------------------------------------------------------

    -- The eight key-bound modes in key-list order. Each row holds the command word, which is
    -- also the key under settings.Keybinds, the label chat prints, the line of the key list
    -- the row sits on, the shipped default in Windower's spelling, and the command the key
    -- sends. The two job-mode rows also name, as ui, the job-file global that carries their
    -- label. That name is read at print time, and the label here stands in when it is empty.
    -- The sent command is mixed case, and the dispatcher lowercases it.
    local keybind_modes = {
        { word = 'offensemode',    label = 'Stance',                    line = 1, default = 'f12',  command = 'gs c OffenseMode' },
        { word = 'weaponmode',     label = 'Weapon Mode',               line = 1, default = 'f9',   command = 'gs c WeaponMode' },
        { word = 'weaponlock',     label = 'Weapon Lock',               line = 1, default = 'f10',  command = 'gs c WeaponLock' },
        { word = 'treasurehunter', label = 'TH Mode',                   line = 1, default = 'f11',  command = 'gs c TreasureHunter' },
        { word = 'jobmode',        label = 'Job Mode',   ui = 'UI_Name',  line = 2, default = '^f12', command = 'gs c JobMode' },
        { word = 'jobmode2',       label = 'Job Mode 2', ui = 'UI_Name2', line = 2, default = '^f11', command = 'gs c JobMode2' },
        { word = 'hoxne',          label = 'Hoxne Ampulla',             line = 2, default = '^f10', command = 'gs c Hoxne' },
        { word = 'spellreceived',  label = 'Spell Received (Multibox)', line = 2, default = '^f9',  command = 'gs c SpellReceived' },
    }

    -- The job file's name for a job-mode row, which is empty when the file left the mode
    -- unnamed. Returns nil for every other row.
    local function keybind_ui_name(row)
        if row.ui == 'UI_Name' then return UI_Name end
        if row.ui == 'UI_Name2' then return UI_Name2 end
        return nil
    end

    -- The label a line prints for a row: the job file's name when it has one, else the
    -- table's own.
    local function keybind_label(row)
        local name = keybind_ui_name(row)
        if name and name ~= '' then return name end
        return row.label
    end

    -- The keyspec grammar: F1 to F12 alone, or with exactly one of Ctrl, Alt or Shift. The
    -- stored form is Windower's spelling, an optional ^ for Ctrl, ! for Alt or ~ for Shift
    -- followed by f1 to f12. It is the only form that reaches bind, unbind and the settings
    -- file. The command also accepts a human spelling, such as ctrl+f5, Ctrl F5, CONTROL-F12,
    -- alt f1 or shift+f12, and normalizes it here. Chat prints the human form, as in Ctrl+F5.
    local KEYSPEC_PREFIX = { ['ctrl'] = '^', ['control'] = '^', ['alt'] = '!', ['shift'] = '~' }
    local KEYSPEC_MODIFIER = { ['^'] = 'Ctrl', ['!'] = 'Alt', ['~'] = 'Shift' }

    -- The normalized spelling of a typed keyspec, or nil and the reason it was refused. The
    -- input is trimmed and lowercased, and each run of spaces collapses to one. A key number
    -- with a leading zero, such as f05, is refused. The reason names the text as given and
    -- the whole grammar. It also lists none and default, which the keybind command accepts
    -- though the grammar does not.
    local function keyspec_parse(text)
        local given = text
        text = type(text) == 'string' and text:lower() or ''
        text = text:gsub('^%s+', ''):gsub('%s+$', ''):gsub('%s+', ' ')
        local prefix, key = text:match('^([%^!~]?)f(%d+)$')
        if not prefix then
            local word, rest = text:match('^(%a+)[%+%- ]f(%d+)$')
            if word and KEYSPEC_PREFIX[word] then prefix, key = KEYSPEC_PREFIX[word], rest end
        end
        local n = tonumber(key)
        if not prefix or not n or n < 1 or n > 12 or key ~= tostring(n) then
            return nil, ("'%s' is not a key: F1 to F12 alone or with one of Ctrl, Alt or Shift "
                .. "(for example ^f5, alt+f5, none, default)"):format(tostring(given))
        end
        return prefix .. 'f' .. key
    end

    -- The human spelling of a normalized keyspec: f12 becomes F12, ^f5 becomes Ctrl+F5, and
    -- '' becomes none. Anything else comes back as given.
    local function keyspec_human(spec)
        if spec == '' then return 'none' end
        local prefix, key = tostring(spec):match('^([%^!~]?)(f%d+)$')
        if not prefix then return tostring(spec) end
        return (prefix ~= '' and KEYSPEC_MODIFIER[prefix] .. '+' or '') .. key:upper()
    end

    -- Whether a value read from settings may be bound: a string that is empty or already in
    -- the normalized spelling. A hand-edited Ctrl+F5 is not, and neither is a number the
    -- config library converted.
    local function keyspec_valid_setting(value)
        return type(value) == 'string' and (value == '' or keyspec_parse(value) == value)
    end

    -- The keys this load holds, as the keyspec bound under each mode word. A mode with no key
    -- has no entry. The table is changed in place and never reassigned, so the exported
    -- reference stays current. The release reads this registry and never settings. After a
    -- logout the live settings table is the file's global section, and at the next login it
    -- is the new character's block before the old file unloads.
    local bound = {}

    -- Bind every mode's key from settings.Keybinds, in key-list order, in three passes.
    --
    -- The first pass resolves what each row wants. A value that is not a keyspec falls back
    -- to the row's default, with one line, and is not written back. A key an earlier row
    -- already took leaves the later row with no key this session, also with one line. The
    -- second pass releases every key this load holds that its row no longer wants, and the
    -- third binds what is not yet bound.
    --
    -- Every release comes before every bind. So when two rows exchange keys in one call, the
    -- later row's release never removes the bind the earlier row just made. A key already
    -- bound as wanted sends nothing, so a second call in one load sends only what changed.
    local function keybind_apply()
        local taken, wants = {}, {}
        for i, row in ipairs(keybind_modes) do
            local want = settings.Keybinds[row.word]
            if not keyspec_valid_setting(want) then
                notice(("Keybinds: '%s' for %s is not a key; using the default [%s]."):format(
                    tostring(want), keybind_label(row), keyspec_human(row.default)))
                want = row.default
            end
            if want ~= '' and taken[want] then
                notice(('Keybinds: %s and %s both name [%s]; %s has no key this session.'):format(
                    keybind_label(row), keybind_label(taken[want]), keyspec_human(want),
                    keybind_label(row)))
                want = ''
            end
            if want ~= '' then taken[want] = row end
            wants[i] = want
        end
        for i, row in ipairs(keybind_modes) do
            local held = bound[row.word]
            if held and held ~= wants[i] then
                send_command('unbind ' .. held)
                bound[row.word] = nil
            end
        end
        for i, row in ipairs(keybind_modes) do
            local want = wants[i]
            if want ~= '' and bound[row.word] ~= want then
                send_command('bind ' .. want .. ' ' .. row.command)
                bound[row.word] = want
            end
        end
    end

    -- Release every key this load bound, in key-list order, and forget it. Reads the
    -- registry only.
    local function keybind_release()
        for _, row in ipairs(keybind_modes) do
            local spec = bound[row.word]
            if spec then
                send_command('unbind ' .. spec)
                bound[row.word] = nil
            end
        end
    end

    -- Print the key list on notice, from the registry. Each row prints as [<key>] <label>,
    -- with [none] for a row holding no key. The line-1 rows share one Keys: line and the
    -- line-2 rows the next, and a job-mode row appears only when the job file named it. A
    -- second line longer than 100 characters splits, with the job-mode rows on a line of
    -- their own before the rest. The game wraps a longer line, and the wrapped tail loses
    -- the channel color.
    local function keybind_list()
        local function entry(row)
            return ('[%s] %s'):format(keyspec_human(bound[row.word] or ''), keybind_label(row))
        end
        local first, jobs, rest = {}, {}, {}
        for _, row in ipairs(keybind_modes) do
            if row.line == 1 then
                first[#first + 1] = entry(row)
            elseif row.ui then
                local name = keybind_ui_name(row)
                if name and name ~= '' then jobs[#jobs + 1] = entry(row) end
            else
                rest[#rest + 1] = entry(row)
            end
        end
        notice('Keys: ' .. table.concat(first, '  '))
        local second = {}
        for i = 1, #jobs do second[#second + 1] = jobs[i] end
        for i = 1, #rest do second[#second + 1] = rest[i] end
        local line = 'Keys: ' .. table.concat(second, '  ')
        if #line > 100 then
            notice('Keys: ' .. table.concat(jobs, '  '))
            notice('Keys: ' .. table.concat(rest, '  '))
        else
            notice(line)
        end
    end

    -- The argument table ------------------------------------------------------------------------

    -- The commands that accept an argument, and so may be matched on their first word.
    -- Everything else matches only as a complete string. That is what lets 'warp' and
    -- 'warp club' both be handlers without one shadowing the other, and what makes
    -- 'gs c warp foo' unknown rather than a Warp Ring.
    --
    -- Adding a name here widens what its first word claims. Every command whose first word,
    -- split on whitespace, is that word then resolves to that handler instead of being
    -- unknown. A longer word that merely begins with it does not. 'nakedunlocked' is one
    -- word and looks up itself, never the 'naked' row, and the same holds for 'enableall'
    -- and 'enablebymode' beside the 'enable' row.
    --
    -- Whether the job file still sees a command depends on the handler, not on this table.
    -- A handler returning true takes the command away from every job file that answered it,
    -- while one returning nothing leaves the hook firing. The lock, strip and disable
    -- handlers return what their toggle returns: true on a refused argument, and nothing on
    -- every form it accepts. Every on/off command here shares that split.
    local command_takes_arg = {
        ["abysseaproc"] = true,
        ["aptitude"] = true,
        ["capacity"] = true,
        ["debug"] = true,
        ["display"] = true,
        ["displaycells"] = true,
        ["displaymode"] = true,
        ["displaypos"] = true,
        ["displaystyle"] = true,
        ["disable"] = true,
        ["dynamisrp"] = true,
        ["enable"] = true,
        ["enchinfo"] = true,
        ["gearreporting"] = true,
        ["help"] = true,
        ["mecisto"] = true,
        ["hoxne"] = true,
        ["info"] = true,
        ["jubilee"] = true,
        ["jobmode"] = true,
        ["jobmode2"] = true,
        ["keybind"] = true,
        ["naked"] = true,
        ["offensemode"] = true,
        ["profile"] = true,
        ["spellreceived"] = true,
        ["treasurehunter"] = true,
        ["use"] = true,
        ["warn"] = true,
        ["weaponlock"] = true,
        ["weaponmode"] = true,
        ["weaponsonly"] = true,
    }

    -- The handlers --------------------------------------------------------------------------------

    -- Every handler takes the same two arguments: cmd as the player typed it, and command as
    -- the lowercased, trimmed form the table is keyed on. A handler reads cmd where the
    -- original case has to survive, as the profile path does, and command everywhere else,
    -- including item names, which are looked up without regard to case.
    --
    -- Returning true suppresses the job file's hook. Most handlers below return nothing on
    -- success, so a job file can still act on the same command. A handler that starts
    -- returning true silently takes that command away from every job file.
    local command_handlers = {}

    -- Throttle on the [Empty] warning below, so a broken set list does not fill the log.
    local empty_set_gate = 0

    -- Rebuild the set the current modes call for, and wear it. equip_set_command sends this
    -- command, and lifecycle.lua sends it at the end of a job change. A raw event handler
    -- cannot equip, so code running inside one calls equip_set_command, and the equip lands
    -- here, inside a wrapped command.
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

    -- Refuse a command while the display is latched shut for a logout, and say so. Returns
    -- true when it refuses. The display words, debug among them, and the three channel
    -- toggles ask this before anything else, and the forms of keybind that write ask it
    -- too. A refused command reads nothing, writes nothing, and returns true.
    --
    -- The display words touch the display, and the channel toggles and keybind write
    -- settings. The two box toggles call show() on a box directly, and the style switch
    -- enters a renderer, which creates or shows the objects it owns, so those three would
    -- get past the display component's own draw gates. The rest would write into a settings
    -- table the config library has already replaced with the file's global section.
    --
    -- A broadcast can reach a client at character select, where the chat log is not on
    -- screen. The line is still written, so that a refusal is never silent.
    local function refuse_logged_out(label)
        if not display_logged_out() then return false end
        warn(('%s: logged out; nothing changes until the next login.'):format(label))
        return true
    end

    -- Put the status box in the top-left corner and the debug box a hundred pixels below it.
    -- This recovers a box dragged off-screen, where there is nothing left to grab.
    command_handlers["zero"] = function(cmd, command)
        if refuse_logged_out('Displays') then return true end
        display_zero_command()
    end

    -- The display words take an explicit value as well as their bare form: on or off for
    -- display, debug and displaymode, a position for displaypos, a number for displaycells
    -- and a name for displaystyle. So one string sent to every client with the Send addon
    -- leaves them all in the same state, whatever state each was in, which the bare toggles
    -- cannot do. An explicit value that matches the state already standing still runs its
    -- branch, prints and saves.
    --
    -- Arguments are matched without regard to case, as everywhere in this file, because a
    -- broadcast carries whatever the player typed.
    --
    -- A refused argument prints two lines, the value and then the usage, and returns true,
    -- so the job file's hook does not see it. Every form that is not refused returns
    -- nothing, so the hook fires for it. displaystyle is the exception, and returns true on
    -- every path.

    -- The largest magnitude a coordinate or a cell count may carry. Both are printed with
    -- %d, which takes a signed 32-bit value and prints a different number for anything past
    -- it, so a value the line cannot print is refused rather than stored.
    local DISPLAY_INT_MAX = 2147483647

    -- Read the explicit on or off an argument carries. Returns true or false, or nil after
    -- printing both refusal lines. label names the setting, and word is the command as the
    -- usage line spells it.
    local function on_off_arg(label, word, arg)
        local want = arg:lower()
        if want == 'on' then return true end
        if want == 'off' then return false end
        warn(('%s: "%s" is not on or off.'):format(label, tostring(arg)))
        warn(('Usage: //gs c %s [on|off]'):format(word))
        return nil
    end

    -- Switch the mode box between one line and several, and remember the choice.
    command_handlers["displaymode"] = function(cmd, command)
        if refuse_logged_out('Display mode') then return true end
        local arg = command_arg(cmd)
        if arg then
            local want = on_off_arg('Display mode', 'displaymode', arg)
            if want == nil then return true end
            settings.oneline = want
        else
            settings.oneline = not settings.oneline
        end
        notice('One line display is: [' .. (settings.oneline and "ON" or "OFF") .. ']')
        display_box_update()
        save_settings()
    end

    -- Put a box at a typed position, or report where both are. Two numbers move the status
    -- box, and a box word in front of them chooses which box. The words are read from the
    -- original string, so a refusal names what was typed, and compared lowercased. The
    -- coordinates are not checked against the screen, since gs c zero recovers a box put
    -- off-screen. display_pos_command moves the box, which writes its own settings block,
    -- and then prints the line and saves.
    command_handlers["displaypos"] = function(cmd, command)
        if refuse_logged_out('Display position') then return true end
        local usage = 'Usage: //gs c displaypos [status|debug] <x> <y>'
        local arg = command_arg(cmd)
        local words = {}
        if arg then
            for word in arg:gmatch('%S+') do words[#words + 1] = word end
        end

        if #words == 0 then
            local sx, sy = gs_status:pos()
            local dx, dy = gs_debug:pos()
            notice(('Display position: status [%d, %d], debug [%d, %d]'):format(sx, sy, dx, dy))
            return
        end

        local box, name = gs_status, 'status'
        local first = 1
        if #words == 3 then
            local word = words[1]:lower()
            if word == 'debug' then
                box, name = gs_debug, 'debug'
            elseif word ~= 'status' then
                warn(('Display position: "%s" is not a box.'):format(words[1]))
                warn(usage)
                return true
            end
            first = 2
        elseif #words ~= 2 then
            warn('Display position: needs two numbers.')
            warn(usage)
            return true
        end

        -- A coordinate is a whole pixel, finite, and inside what the line can print. The
        -- box and the line are given the same number, so the position reported is the
        -- position stored. An infinity passes tonumber and formats as a large negative
        -- rather than raising, so it is refused as not a number. A finite value past the
        -- printable range is refused as out of range. The range test runs on the floored
        -- number, so the two ends of the range behave differently. A fraction above the top
        -- floors onto it and is kept, while one below the bottom floors past it and is
        -- refused.
        local coords = {}
        for i = first, first + 1 do
            local n = tonumber(words[i])
            if not n or n >= math.huge or n <= -math.huge then
                warn(('Display position: "%s" is not a number.'):format(words[i]))
                warn(usage)
                return true
            end
            n = math.floor(n)
            if n > DISPLAY_INT_MAX or n < -DISPLAY_INT_MAX then
                warn(('Display position: "%s" is out of range.'):format(words[i]))
                warn(usage)
                return true
            end
            coords[#coords + 1] = n
        end
        display_pos_command(box, name, coords[1], coords[2])
    end

    -- Set the player's floor on the status box's value column, as a whole number of cells,
    -- or report the floor standing. Zero is the default and means no floor. The floor is
    -- applied when the cached column layout is measured, so the cache is dropped before the
    -- redraw. Otherwise the new width is not drawn until something else drops the cache.
    command_handlers["displaycells"] = function(cmd, command)
        if refuse_logged_out('Display cells') then return true end
        local arg = command_arg(cmd)
        if not arg then
            notice(('Display cells: [%d]'):format(min_value_cells()))
            return
        end
        -- Whole, zero or more, and finite. math.floor of an infinity is that infinity, so
        -- the whole-number test alone would let one through to be written and formatted.
        local n = tonumber(arg)
        if not n or n < 0 or n >= math.huge or n ~= math.floor(n) then
            warn(('Display cells: "%s" is not a whole number of zero or more.'):format(tostring(arg)))
            warn('Usage: //gs c displaycells <n>')
            return true
        end
        -- A whole finite count the saved line cannot print is refused rather than stored.
        if n > DISPLAY_INT_MAX then
            warn(('Display cells: "%s" is out of range.'):format(tostring(arg)))
            warn('Usage: //gs c displaycells <n>')
            return true
        end
        settings.Display_MinValueCells = n
        invalidate_layout()
        display_box_update()
        save_settings(('Display cells: [%d] saved'):format(n))
    end

    -- Choose which renderer draws the box. displaymode chooses how many lines it takes, and
    -- this chooses the renderer. Bare cycles through the styles on offer, an argument selects
    -- one by name, and a name not on offer is refused with the list. The choice is saved at
    -- once, as displaymode's is, in the settings file of the character playing, so each
    -- character keeps its own style.
    command_handlers["displaystyle"] = function(cmd, command)
        if refuse_logged_out('Display Style') then return true end
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
            -- Matched without regard to case, as every command that takes a name from a list
            -- is.
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

    -- Treasure Hunter mode, default key F11. It is the first of the eight mode commands, and
    -- shows the shape they share: bare cycles to the next value, and an argument sets one
    -- exactly. A rejected argument returns true without touching the mode, so a typo changes
    -- nothing and does not reach the job file either.
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

    -- Multibox received-gear tracking, default key Ctrl+F9. The same shape as the mode
    -- command above, plus a release of everything the feature is holding.
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
        -- Released on every switch, not only on the way to OFF. Both delivery paths claim
        -- into one registry and each releases under its own mode, so a claim made in one
        -- mode and left behind by a switch would never be handed back.
        reset_spell_received_state()
        equip_set_command()
        return true
    end

    -- Three of the four engine-internal commands. update auto, at the top of the table, is
    -- the fourth. A player does not type these. Each is sent by a raw event handler that
    -- needs an equip, and exists so that the equip lands here, inside a wrapped command.
    --
    -- Re-take the Ampulla. hoxne.lua sends it from its tick, and when a Sleep hold on range
    -- or ammo lets go. It does nothing if a borrow window opened while the command was in
    -- flight, so a late re-lock can never take the slot back from an instrument using it.
    command_handlers["hoxnerelock"] = function(cmd, command)
        if state.Hoxne.value ~= 'OFF' and not hoxne.window then
            hoxne_equip_ampulla()
            hoxne_arm_use_lockout()
            equip_set_command()
        end
        return true
    end

    -- Give a stranded Ampulla back. A reload resets the mode to OFF but cannot unequip, so
    -- the Ampulla stays worn with nothing left that believes it owns the slot. The Hoxne
    -- tick sends this until the release reports done.
    command_handlers["hoxnerelease"] = function(cmd, command)
        if state.Hoxne.value == 'OFF' then
            if hoxne_release_step() == 'done' then hoxne.release_tries = 0 end
        end
        return true
    end

    -- Put an enchanted item back on mid-use. Sent by enchant.lua's tick when the item it is
    -- holding has been dropped from the slot. It enables the slot, equips through GearSwap's
    -- original equip so the Hoxne filter cannot intercept it, then disables the slot again.
    command_handlers["enchrepair"] = function(cmd, command)
        local st = E.ench_active
        if st then
            enable(st.slot)
            gs_equip({ [st.slot] = st.name })
            disable(st.slot)
        end
        return true
    end

    -- Diagnostic, read-only: print the live extdata for one enchanted item, so the cooldown
    -- and activation the engine believes in can be compared with what the item says. Usage:
    -- gs c enchinfo warp ring. It answers on four separate paths, because an empty result
    -- has four causes worth telling apart: an unknown name, an item not carried, an item
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

    -- Diagnostic, read-only: every capacity point cape carried, what each one is worth,
    -- which copy the mode picks, and what is worn. Usage: gs c capinfo
    --
    -- This is the only view of a case the engine cannot detect for itself. Two copies of one
    -- name look the same in player.equipment, and an augment request that matches no carried
    -- copy leaves the slot alone, so a cape worn from the wrong copy reads as success on
    -- every other path. The check runs here, on demand, and not on the gear rebuild.
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

        -- Only the names can be compared, so a match is reported as a match of names and never
        -- as confirmation that the right copy is on.
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

    -- Diagnostic, read-only: sort every set into three groups, those carrying gear, those
    -- declared but empty, and engine placeholders the job file never declared. Usage: gs c
    -- checksets. It clears the set index and the warning throttles first, so running it
    -- twice in a row gives the same answer both times rather than a quieter one.
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

    -- The lock modes hold one item in its slot until told otherwise. Bare toggles the mode,
    -- and 'on' or 'off' sets it outright. Each returns true only on a refused argument, so a
    -- job file still sees every form the mode accepts.
    --
    -- The capacity point lock answers to three words that all run the same chooser. The
    -- word 'mecisto' names the mode and does not force a Mecisto cape. The item is chosen by
    -- scanning rather than fixed, so 'on' while already on scans again and re-issues the
    -- equip instead of re-asserting what it holds, and turning it off clears the choice.
    command_handlers["capacity"] = function(cmd, command)
        return lock_mode('capacity', command_arg(cmd))
    end

    command_handlers["aptitude"] = function(cmd, command)
        return lock_mode('aptitude', command_arg(cmd))
    end

    command_handlers["mecisto"] = function(cmd, command)
        return lock_mode('mecisto', command_arg(cmd))
    end

    -- The Dynamis Divergence neck lock. Its piece is chosen from the main job's three ranks
    -- rather than fixed, so 'on' while already on chooses again and wears a better rank
    -- acquired since. It works in any zone, and a zone change clears it with the other lock
    -- modes.
    command_handlers["dynamisrp"] = function(cmd, command)
        return lock_mode('dynamisrp', command_arg(cmd))
    end

    -- The Jubilee Ring lock. Setting it on while it is already on re-asserts the hold, so
    -- 'on' doubles as the repair when something took the slot behind the engine's back.
    command_handlers["jubilee"] = function(cmd, command)
        return lock_mode('jubilee', command_arg(cmd))
    end

    -- Hoxne Ampulla mode, default key Ctrl+F10. Switching this mode is the only command that
    -- both takes a slot and gives it back, and every step is answered before the next one
    -- is tried.
    command_handlers["hoxne"] = function(cmd, command)
        -- The disable and strip holds both outrank the Ampulla. While either holds range or
        -- ammo, the mode cannot move in either direction. The held slots are named and the
        -- command stops here, rather than setting a mode whose gear could not follow it.
        -- Both slots are asked because a hold can stand on range alone, as with gs c disable
        -- range, or a naked hold while an item use has the ammo slot. The ON path's enable
        -- and the OFF path's would both open it.
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
                -- Hoxne owns range above the weapon lock. A Locked+R lock is resolved again
                -- here, where it stands down to Locked before the Ampulla takes the slot,
                -- and the box is repainted for it.
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
                -- warnings, so without this line the answer to a deliberate command could be
                -- lost to a throttle the player never saw start.
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

    -- Close this game client.
    command_handlers["shutdown"] = function(cmd, command)
        send_command('terminate')
    end

    -- Write the settings file now, box positions included. The display component saves a
    -- box drag a second after it stops, and this command is the write on demand.
    command_handlers["save"] = function(cmd, command)
        save_settings()
    end

    -- The two box toggles. Each pairs visibility with draggability in both directions, so a
    -- hidden box cannot be dragged. Each repaints a box it shows, so the box never reappears
    -- holding whatever it last showed. gs c debug does double duty, because the setting that
    -- shows the debug box is the one that opens the log channel.
    --
    -- Both save their choice, so a broadcast reaches the settings file. The display toggle's
    -- confirmation is the save line itself, so it answers with one line. The debug toggle
    -- prints its own line and then the save line, as displaymode does.
    command_handlers["display"] = function(cmd, command)
        if refuse_logged_out('Display') then return true end
        local arg = command_arg(cmd)
        local want
        if arg then
            want = on_off_arg('Display', 'display', arg)
            if want == nil then return true end
        else
            want = settings.visible ~= true
        end
        if not want then
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
        save_settings(settings.visible and 'The UI is now shown; settings saved'
            or 'The UI is now hidden; settings saved')
    end

    command_handlers["debug"] = function(cmd, command)
        if refuse_logged_out('Debug') then return true end
        local arg = command_arg(cmd)
        local want
        if arg then
            want = on_off_arg('Debug', 'debug', arg)
            if want == nil then return true end
        else
            want = settings.debug ~= true
        end
        if not want then
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
        save_settings()
    end

    -- The three chat channel toggles: warn for set problems, gearreporting for the
    -- set-selection trace, and info for ordinary feedback. Each answers on notice, which has
    -- no gate, because the confirmation for switching a channel off cannot go out on the
    -- channel it just silenced. Each saves its choice, so it outlasts the session, and its
    -- line is followed by the save line, as displaymode's is. All three keys belong to the
    -- channels silo.
    --
    -- Each takes an explicit on or off beside its bare toggle, as the display words do, so
    -- one string sent to every client leaves the channel in the same state on each of them.
    command_handlers["warn"] = function(cmd, command)
        if refuse_logged_out('Set warning') then return true end
        local arg = command_arg(cmd)
        if arg then
            local want = on_off_arg('Set warning', 'warn', arg)
            if want == nil then return true end
            settings.warn = want
        else
            settings.warn = settings.warn ~= true
        end
        notice('The set warning is now [' .. (settings.warn and 'ON' or 'OFF') .. ']')
        save_settings()
    end

    command_handlers["gearreporting"] = function(cmd, command)
        if refuse_logged_out('Gear reporting') then return true end
        local arg = command_arg(cmd)
        if arg then
            local want = on_off_arg('Gear reporting', 'gearreporting', arg)
            if want == nil then return true end
            settings.gear_reporting = want
        else
            settings.gear_reporting = settings.gear_reporting ~= true
        end
        notice('Gear reporting is now [' .. (settings.gear_reporting and 'ON' or 'OFF') .. ']')
        save_settings()
    end

    command_handlers["info"] = function(cmd, command)
        if refuse_logged_out('Information') then return true end
        local arg = command_arg(cmd)
        if arg then
            local want = on_off_arg('Information', 'info', arg)
            if want == nil then return true end
            settings.info = want
        else
            settings.info = settings.info ~= true
        end
        notice('Information is now [' .. (settings.info and 'ON' or 'OFF') .. ']')
        save_settings()
    end

    -- Re-read the two-handed flag from the weapon the current mode names. The engine does
    -- this itself at load and on every weapon-mode change. The command runs the same check
    -- on demand, for when the flag and the worn weapon have drifted apart.
    command_handlers["two_hand_check"] = function(cmd, command)
        two_hand_check()
    end

    -- Drink the six Escha temporary items, in one chained command with a wait between each.
    command_handlers["temps"] = function(cmd, command)
        escha_temps()
    end

    -- Stop an enchanted item use that is under way. There are three answers, because the
    -- outcome depends on how far the use has gone: nothing running, already sent to the
    -- server and past recall, or stopped. It returns nothing, as the shortcuts below do, so
    -- a job file still sees the command.
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

    -- Tomahawk and Angon. The client refuses a typed /ja for either while the throwing item
    -- is not worn, so these equip it first and use the ability once the equip has landed.
    -- Every reason the ability could fail is answered before any gear moves. Moving gear for
    -- an action that cannot fire would leave the wrong ammo in place for the whole watchdog
    -- window.
    command_handlers["tomahawk"] = function(cmd, command)
        use_gated_ja(150)
    end

    command_handlers["angon"] = function(cmd, command)
        use_gated_ja(170)
    end

    -- Six shortcuts for the enchanted items worth a name of their own. Each makes the same
    -- call gs c use makes, with the item named here, so it need not be typed and cannot be
    -- misspelled. 'warp club' is a two-word handler key. It resolves because the whole
    -- string is tried first, and 'warp' takes no argument, so it never claims a longer string.
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

    -- Offense mode, default key F12. The plainest of the eight, with no state to release and
    -- no slot to take.
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

    -- Weapon mode, default key F9. It is the first of the three mode commands that call the
    -- job file's hook themselves before returning true. The hook runs between the echo and
    -- the gear rebuild, so a job file may change a macro book or another mode and have it
    -- land in the same rebuild rather than a second one. Before the box refreshes, the
    -- handler maps a job file's 'Unlocked' and 'Locked' weapon modes onto the weapon lock,
    -- given the mode it left, so the box shows the result. After the hook it runs the
    -- two-hand check, because the mode just set is what names the weapon.
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

    -- Weapon lock, default key F10. The shared mode shape, plus the resolution of the new
    -- value into the lock flags before the echo, so no build path reads the mode itself.
    -- Hoxne owns range above the lock, so Locked+R is refused while Hoxne is on. When it is
    -- given as an argument, the lock stays where it was. The cycle passes over it, since a
    -- cycle that stopped there could never unlock while Hoxne stayed on.
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

    -- The two job modes, default keys Ctrl+F12 and Ctrl+F11. Both call the job file's hook
    -- and then return true. A job file defines what these modes mean, so they are also the
    -- two modes it most often acts on.
    command_handlers["jobmode2"] = function(cmd, command)
        -- The job file names these modes, and when it has not, the fallback names them. The
        -- label serves the validation message and the echo alike, so both read the same way.
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

    -- Set, clear or reset the key a mode is bound to, or list the keys this load holds. Bare
    -- prints the key list. 'keybind default' puts every mode back on its shipped key, and
    -- 'keybind <mode> <key|none|default>' changes one mode. The mode is its command word.
    -- The key may be in either spelling the grammar accepts, and the normalized spelling is
    -- what is stored, bound and saved. A key another mode holds this load is refused, naming
    -- the holder, and nothing changes.
    --
    -- The two forms that write ask the logout latch first, as every settings word does,
    -- before the key is parsed. So a bad key or a collision while logged out gets the
    -- logged-out line. The list and the two refusals that need no key, for no such mode and
    -- no key given, never ask. A change binds before it saves, so the bind stands for the
    -- session whatever the save answers. Every refusal the command makes itself is one
    -- notice line, so the warn toggle never silences it. The logged-out line is the warn
    -- line the settings words share. Returns true on every path, since no job file handles
    -- the word.
    command_handlers["keybind"] = function(cmd, command)
        local arg = command_arg(cmd)
        if not arg then
            keybind_list()
            return true
        end
        local word, rest = arg:match('^(%S+)%s*(.-)$')
        local lowered = word:lower()
        if lowered == 'default' and rest == '' then
            if refuse_logged_out('Keybind') then return true end
            for _, row in ipairs(keybind_modes) do settings.Keybinds[row.word] = row.default end
            keybind_apply()
            notice('All eight keys reset to their defaults.')
            save_settings()
            return true
        end
        local row
        for _, r in ipairs(keybind_modes) do
            if r.word == lowered then row = r break end
        end
        if not row then
            local words = {}
            for _, r in ipairs(keybind_modes) do words[#words + 1] = r.word end
            notice(("'%s' is not a mode: %s"):format(word, table.concat(words, ', ')))
            return true
        end
        if rest == '' then
            notice(('keybind %s needs a key: gs c keybind %s <key|none|default>'):format(row.word, row.word))
            return true
        end
        if refuse_logged_out('Keybind') then return true end
        local spec
        local want = rest:lower()
        if want == 'none' then
            spec = ''
        elseif want == 'default' then
            spec = row.default
        else
            local reason
            spec, reason = keyspec_parse(rest)
            if not spec then
                notice(reason)
                return true
            end
        end
        if spec ~= '' then
            for _, other in ipairs(keybind_modes) do
                if other ~= row and bound[other.word] == spec then
                    notice(('[%s] is bound to %s; free it first (gs c keybind %s none) or choose another key.'):format(
                        keyspec_human(spec), keybind_label(other), other.word))
                    return true
                end
            end
        end
        settings.Keybinds[row.word] = spec
        keybind_apply()
        if spec == '' then
            notice(('%s has no key; gs c %s still cycles it.'):format(keybind_label(row), row.word))
        else
            notice(('%s bound to [%s]; any other Windower bind on this key is replaced.'):format(
                keybind_label(row), keyspec_human(spec)))
        end
        save_settings()
        return true
    end

    -- One row per command: the word, the index group it prints under, its argument form and
    -- a one-clause purpose. The words are the handler keys, one row each, and a row holds no
    -- other fact. A key's default lives in the mode table, and the key a mode row prints is
    -- read from the registry when it prints. The internal group holds the commands the
    -- engine sends itself and the words no player is meant to type. Those rows keep the
    -- table at one row per handler, and help never prints them.
    local help_table = {
        { word = 'offensemode',    group = 'modes',       args = '[<mode>]',                 purpose = 'cycle the offense mode, or set it by name' },
        { word = 'weaponmode',     group = 'modes',       args = '[<mode>]',                 purpose = 'cycle the weapon mode, or set it by name' },
        { word = 'weaponlock',     group = 'modes',       args = '[<mode>]',                 purpose = 'cycle the weapon lock, or set it by name' },
        { word = 'treasurehunter', group = 'modes',       args = '[<mode>]',                 purpose = 'cycle the Treasure Hunter mode, or set it by name' },
        { word = 'jobmode',        group = 'modes',       args = '[<mode>]',                 purpose = "cycle the job file's own mode, or set it by name" },
        { word = 'jobmode2',       group = 'modes',       args = '[<mode>]',                 purpose = "cycle the job file's second mode, or set it by name" },
        { word = 'hoxne',          group = 'modes',       args = '[<mode>]',                 purpose = 'cycle the Hoxne Ampulla mode, or set it by name' },
        { word = 'spellreceived',  group = 'modes',       args = '[<mode>]',                 purpose = 'cycle spell-received gear tracking, or set it by name' },
        { word = 'display',        group = 'display',     args = '[on|off]',                 purpose = 'show or hide the status box' },
        { word = 'displaymode',    group = 'display',     args = '[on|off]',                 purpose = 'switch the mode box between one line and several' },
        { word = 'displaystyle',   group = 'display',     args = '[<style>]',                purpose = 'cycle the renderer that draws the box, or choose one by name' },
        { word = 'displaypos',     group = 'display',     args = '[[status|debug] <x> <y>]', purpose = 'put a box at a typed position, or report where both are' },
        { word = 'displaycells',   group = 'display',     args = '[<n>]',                    purpose = "set the floor on the status box's value column, in cells" },
        { word = 'zero',           group = 'display',     args = '',                         purpose = 'put both boxes back in the top-left corner' },
        { word = 'save',           group = 'display',     args = '',                         purpose = 'write the settings file now, box positions included' },
        { word = 'update auto',    group = 'internal',    args = '',                         purpose = 'rebuild the set the current modes call for, and wear it' },
        { word = 'two_hand_check', group = 'internal',    args = '',                         purpose = 're-read the two-handed flag from the weapon the current mode names' },
        { word = 'naked',          group = 'holds',       args = '[on|off]',                 purpose = 'strip every slot and hold it bare' },
        { word = 'weaponsonly',    group = 'holds',       args = '[on|off]',                 purpose = 'strip and hold the twelve armor slots, leaving the weapons dressed' },
        { word = 'abysseaproc',    group = 'holds',       args = '[on|off]',                 purpose = 'strip and hold head, hands, legs and feet only' },
        { word = 'nakedunlocked',  group = 'holds',       args = '',                         purpose = 'strip every slot without holding it' },
        { word = 'disable',        group = 'holds',       args = '<slot>... | all',          purpose = 'hold the named slots wearing exactly what they already wear' },
        { word = 'enable',         group = 'holds',       args = '<slot>... | all',          purpose = 'end the hold on the named slots and hand each back' },
        { word = 'enableall',      group = 'holds',       args = '',                         purpose = 'free every slot unconditionally' },
        { word = 'enablebymode',   group = 'internal',    args = '',                         purpose = 'free only what the current mode allows' },
        { word = 'capacity',       group = 'locks',       args = '[on|off]',                 purpose = 'hold the capacity point cape the scan chooses, until told otherwise' },
        { word = 'aptitude',       group = 'locks',       args = '[on|off]',                 purpose = 'the capacity point lock under a second name' },
        { word = 'mecisto',        group = 'locks',       args = '[on|off]',                 purpose = 'the capacity point lock under a third name' },
        { word = 'dynamisrp',      group = 'locks',       args = '[on|off]',                 purpose = 'hold the Dynamis Divergence neck piece for the main job' },
        { word = 'jubilee',        group = 'locks',       args = '[on|off]',                 purpose = 'hold the Jubilee Ring in its slot until told otherwise' },
        { word = 'use',            group = 'items',       args = '<item>',                   purpose = 'use any enchanted item by name' },
        { word = 'cancel',         group = 'items',       args = '',                         purpose = 'stop an enchanted item use that is under way' },
        { word = 'food',           group = 'items',       args = '',                         purpose = 'eat whatever the job file named' },
        { word = 'temps',          group = 'items',       args = '',                         purpose = 'drink the six Escha temporary items' },
        { word = 'warp',           group = 'items',       args = '',                         purpose = 'shortcut for the Warp Ring' },
        { word = 'warp club',      group = 'items',       args = '',                         purpose = 'shortcut for the Warp Cudgel' },
        { word = 'holla',          group = 'items',       args = '',                         purpose = 'shortcut for the Dim. Ring (Holla)' },
        { word = 'dem',            group = 'items',       args = '',                         purpose = 'shortcut for the Dim. Ring (Dem)' },
        { word = 'mea',            group = 'items',       args = '',                         purpose = 'shortcut for the Dim. Ring (Mea)' },
        { word = 'trizek',         group = 'items',       args = '',                         purpose = 'shortcut for the Trizek Ring' },
        { word = 'tomahawk',       group = 'internal',    args = '',                         purpose = 'equip the throwing item, then use Tomahawk' },
        { word = 'angon',          group = 'internal',    args = '',                         purpose = 'equip the throwing item, then use Angon' },
        { word = 'keybind',        group = 'utility',     args = '[<mode> <key|none|default>|default]', purpose = 'set, clear or reset the key a mode answers to' },
        { word = 'help',           group = 'utility',     args = '[<group>]',                purpose = 'list the commands, or one group of them' },
        { word = 'version',        group = 'utility',     args = '',                         purpose = 'say which engine version is loaded' },
        { word = 'profile',        group = 'utility',     args = '<name>',                   purpose = 'run a Windower script chosen by the current job pairing' },
        { word = 'shutdown',       group = 'utility',     args = '',                         purpose = 'close this game client' },
        { word = 'checksets',      group = 'diagnostics', args = '',                         purpose = 'sort every declared set into carries gear, empty, and undeclared placeholder' },
        { word = 'gearreporting',  group = 'diagnostics', args = '[on|off]',                 purpose = 'switch the set-selection trace channel on or off' },
        { word = 'enchinfo',       group = 'diagnostics', args = '<item>',                   purpose = 'dump the live extdata for one enchanted item' },
        { word = 'capinfo',        group = 'diagnostics', args = '',                         purpose = 'every capacity point cape carried, which one the mode picks, and what is worn' },
        { word = 'hoxneinfo',      group = 'diagnostics', args = '',                         purpose = 'everything the Hoxne subsystem gates on, in one place' },
        { word = 'warn',           group = 'diagnostics', args = '[on|off]',                 purpose = 'switch the set-warning channel on or off' },
        { word = 'info',           group = 'diagnostics', args = '[on|off]',                 purpose = 'switch the ordinary-feedback channel on or off' },
        { word = 'debug',          group = 'diagnostics', args = '[on|off]',                 purpose = 'show or hide the debug box, and open or close its log channel' },
        { word = 'enchrepair',     group = 'internal',    args = '',                         purpose = 'put an enchanted item back on mid-use' },
        { word = 'hoxnerelock',    group = 'internal',    args = '',                         purpose = 're-take the Ampulla' },
        { word = 'hoxnerelease',   group = 'internal',    args = '',                         purpose = 'give a stranded Ampulla back' },
    }

    -- The index groups in print order. Each prints under its own name with the first letter
    -- capitalized, and these are the only groups help prints on request. internal is a group
    -- in the table but not in this list.
    local HELP_GROUPS = { 'modes', 'display', 'holds', 'locks', 'items', 'utility', 'diagnostics' }

    -- The key a mode row prints, from the registry: [none] for a mode holding no key.
    local function help_key(word)
        return '[' .. keyspec_human(bound[word] or '') .. ']'
    end

    -- Print the grouped index, or one group's rows. The index prints one line per group, with
    -- the words two spaces apart and each mode word followed by the key the registry holds.
    -- The modes take two lines, the key list's rows 1 to 4 and 5 to 8, and are not split
    -- further. The first line can pass 100 characters when each of its four modes has a
    -- distinct Shift key, the longest keys a player can bind.
    --
    -- A group prints one line per row: the word, its argument form and its purpose, with a
    -- mode row ending in its key. The table's rows keep every such line within 100
    -- characters. The group is matched in any case, and a group not in the printed list,
    -- internal included, is refused with the list of printed groups. Returns true on every
    -- path, since no job file handles the word.
    command_handlers["help"] = function(cmd, command)
        local arg = command_arg(cmd)
        if not arg then
            local lines = { {}, {} }
            for _, row in ipairs(keybind_modes) do
                local line = lines[row.line]
                line[#line + 1] = row.word .. ' ' .. help_key(row.word)
            end
            notice('Modes: ' .. table.concat(lines[1], '  '))
            notice('Modes: ' .. table.concat(lines[2], '  '))
            for i = 2, #HELP_GROUPS do
                local group, words = HELP_GROUPS[i], {}
                for _, row in ipairs(help_table) do
                    if row.group == group then words[#words + 1] = row.word end
                end
                notice(group:sub(1, 1):upper() .. group:sub(2) .. ': ' .. table.concat(words, '  '))
            end
            notice("gs c help <group> for each command's form, e.g. gs c help modes")
            return true
        end
        local group, printed = arg:lower(), false
        for _, g in ipairs(HELP_GROUPS) do
            if g == group then printed = true end
        end
        if not printed then
            notice(("No help group '%s': %s."):format(arg, table.concat(HELP_GROUPS, ', ')))
            return true
        end
        for _, row in ipairs(help_table) do
            if row.group == group then
                local line = row.word .. (row.args ~= '' and ' ' .. row.args or '') .. ' -- ' .. row.purpose
                if group == 'modes' then line = line .. '; key ' .. help_key(row.word) end
                notice(line)
            end
        end
        return true
    end

    -- Run a Windower script chosen by the current job pairing. The command is split into
    -- runs of letters and digits, and every run after the first is joined with underscores
    -- into a folder name. The script inside it is named main_sub_character. Any other
    -- character in the name is lost silently. A bare 'gs c profile' also reaches here, and
    -- sends an exec with an empty folder name.
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

    -- Eat the food the job file names. Food is a job-file global the engine never declares,
    -- so a job file that does not set it raises an error here when the command runs, not at
    -- load.
    command_handlers["food"] = function(cmd, command)
        windower.chat.input('/item "' .. Food .. '" <me>')
    end

    -- Use any enchanted item by name. It takes either the short or the long resource name,
    -- and works out the slot, the equip timeout and the cast time from the item itself. The
    -- slice drops the leading 'use ' and passes the rest through whole, spaces included.
    -- That free-text argument is what the dispatcher's whole-string-then-first-word
    -- resolution protects.
    command_handlers["use"] = function(cmd, command)
        use_enchantment(command:slice(5))
    end

    -- Say which engine version is loaded. It reads Rahvin_GS, the constant interface.lua
    -- declares and the root asserts every component against, so it reports what is running
    -- rather than what one component claims.
    command_handlers["version"] = function(cmd, command)
        notice('Include Version is [' .. Rahvin_GS .. ']')
    end

    -- Stripping commands, for procs and for capping damage at one -----------------------------

    -- Strip every slot and hold it bare, as a claim the whole engine can see. While the hold
    -- stands, nothing below an item use dresses a held slot, and every layer refused says so
    -- by name. Bare flips the hold, 'on' takes it again as the manual repair, and 'off' ends
    -- it.
    command_handlers["naked"] = function(cmd, command)
        return strip_mode('naked', command_arg(cmd))
    end

    -- Strip every slot without holding it, so the next action or poll dresses the character
    -- again. This is the momentary strip, for a cure read off a lower maximum HP or a Sortie
    -- objective that wants the character bare for an instant. A slot an item use or a
    -- disable hold is holding is left alone. Every other layer holding a slot shuts it again
    -- after the strip and dresses it at its own next chance.
    command_handlers["nakedunlocked"] = function(cmd, command)
        strip_sweep()
    end

    -- Strip and hold the twelve armor slots, leaving main, sub, range and ammo dressed, for
    -- procs that need a particular weapon on and everything else off. It is the same hold
    -- naked takes in a different shape, so typing it while naked stands hands the four
    -- weapon slots back and keeps the twelve.
    command_handlers["weaponsonly"] = function(cmd, command)
        return strip_mode('weaponsonly', command_arg(cmd))
    end

    -- Strip and hold only head, hands, legs and feet. weaponsonly takes eight more slots,
    -- and here body, neck, ears, rings, back and waist stay dressed for Abyssea red procs.
    command_handlers["abysseaproc"] = function(cmd, command)
        return strip_mode('abysseaproc', command_arg(cmd))
    end

    -- Hold the named slots wearing exactly what they already wear, as in gs c disable head
    -- ear1, or gs c disable all for all sixteen. While the hold stands, nothing below an item
    -- use dresses a held slot, and every layer refused says so by name. Bare prints the usage
    -- line and what stands. An unrecognized slot word refuses the whole command.
    command_handlers["disable"] = function(cmd, command)
        return disable_mode('disable', command_arg(cmd))
    end

    -- End the hold on the named slots, or on all of them, and hand each back to whoever is
    -- next in line. It never takes a slot. gs c disable is the only word that does.
    command_handlers["enable"] = function(cmd, command)
        return disable_mode('enable', command_arg(cmd))
    end

    -- The two releases, which are not interchangeable. enableall frees every slot the weapon
    -- lock does not hold and turns the lock modes off, which makes it the manual override
    -- when something is stuck. enablebymode frees only the slots no layer is claiming, and
    -- leaves every claim standing.
    command_handlers["enableall"] = function(cmd, command)
        Unlock()
    end

    command_handlers["enablebymode"] = function(cmd, command)
        UnlockByMode()
    end

    -- The dispatcher -----------------------------------------------------------------------------

    -- Resolve a command to its handler and run it. The whole string is tried first, then the
    -- first word for the commands that take an argument, and never a substring, so an
    -- argument is never read as a command name. Anything unresolved, and anything a handler
    -- did not claim by returning true, goes to the job file's own hook. That is how a job
    -- file adds commands of its own without the engine knowing about them.
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

    -- GearSwap's own '//gs disable <slot>' and '//gs enable <slot>' act on a slot at the
    -- addon's level, where the engine cannot see it. No claim is registered, no refusal
    -- names it, the status box shows nothing, and the next unlock re-enables the slot. This
    -- answers with one line pointing at the words that are tracked. It runs after GearSwap's
    -- own handler, so the native command has already acted, and the line only advises.
    -- Nothing here refuses, re-takes or equips.
    --
    -- A second word must follow. Bare '//gs disable' and '//gs enable' switch the whole user
    -- file off and on rather than a slot, and there is no 'gs c' word to point those to. The
    -- verb 'c' is the engine's own surface and answers for itself, which also keeps the
    -- rebuild the engine sends itself silent.
    local function native_disable_notice(first, second)
        if second == nil or type(first) ~= 'string' then return end
        local verb = first:lower()
        if verb == 'disable' then
            notice('Disable: //gs disable leaves the slot untracked -- use //gs c disable <slot>... instead.')
        elseif verb == 'enable' then
            notice('Disable: //gs enable is not tracked -- use //gs c enable <slot>..., or //gs c enableall for every slot.')
        end
    end

    -- The exports. The root registers native_disable_notice, and lifecycle.lua binds the keys
    -- at load and releases them at unload through the three keybind functions. The mode
    -- table, the key registry and the keyspec grammar are exported beside them. Every command
    -- in this file is reached through self_command, which GearSwap looks up by name.
    E.native_disable_notice = native_disable_notice
    E.keybind_modes = keybind_modes
    E.keybinds_bound = bound
    E.keybind_apply = keybind_apply
    E.keybind_release = keybind_release
    E.keybind_list = keybind_list
    E.keyspec_parse = keyspec_parse
    E.keyspec_human = keyspec_human
    E.keyspec_valid_setting = keyspec_valid_setting

    -- The version stamp. The root checks it against Rahvin_GS, so a stale copy of this file
    -- stops the load with an error that names it.
    return '2.1'
end
