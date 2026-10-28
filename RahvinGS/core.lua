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
-- COMPONENT: core -- sections 7-9 and 11: libraries, settings, constants, data and utilities
----------------------------------------------------------------------------------------------------
-- CONTENTS
--   Section 7  - Libraries and settings .... the libraries, the saved settings file, and
--                                           the two on-screen boxes
--   Section 8  - Shared constants .......... the constants and lookup tables the engine
--                                           reads
--   Section 9  - Spell and ability data .... the spells and abilities spell-received
--                                           tracking announces, and the set each calls for
--   Section 11 - Core utilities ............ the chat channels, the clock, the cast-time
--                                           estimate, the busy window's limit, the
--                                           multibox cast announce, the buff prediction,
--                                           the stratagem count, the item and party
--                                           helpers, and the elemental bonus chooser
--
-- This file holds what the rest of the engine reads. It registers no event. The one
-- subsystem it holds, the buff prediction, runs only when another component calls it.
--
-- GLOBALS  print, and the chat channels written through it: log, info, warn, notice and
--          gear_report. GearSwap gives the job file and every file it includes one shared
--          environment, so this print replaces Lua's for the engine and the job file alike.
--          It reads its first argument as a chat mode. debug is not a global. It is a
--          file-local that shadows Lua's debug table here and in every component that
--          imports it.
-- STATE    The live settings table. The multibox announce debt, the completion this
--          character owes the others after it announces a cast: the flag
--          E.outgoing_cast_active, which state.lua declares, and the deadline beside it.
--          While the debt stands, other characters may be holding gear for that cast. The
--          buff prediction's record, the buffs written into GearSwap's list before GearSwap
--          lists them itself. Only this file's functions write the record, and every
--          component reads it through the one table it binds at construction.
-- EXPORTS  The settings table and what its load reported, the two boxes, the config,
--          resource and extdata libraries, the shared constants and data tables, and the
--          helper functions, all as E fields.
-- LOADS    After state.lua, because it binds state's cached handles at construction:
--          get_mob_by_id, get_party and send_ipc. This is the one place load order departs
--          from section order, since state holds section 10. Every global it calls exists
--          before it loads.

-- requires: rahvings/state
return function(E)
    -- The API handles state.lua caches, bound once so no call below reaches through E. The
    -- other windower.ffxi calls in this file, for the client language and the stratagem
    -- recasts, have no cached handle and call windower.ffxi directly.
    local get_mob_by_id, get_party, send_ipc = E.get_mob_by_id, E.get_party, E.send_ipc

    ------------------------------------------------------------------------------------------------
    -- SECTION 7 - LIBRARIES AND USER SETTINGS
    ------------------------------------------------------------------------------------------------
    -- The libraries the engine uses, the settings that persist across reloads, and the two
    -- on-screen boxes those settings describe.

    -- The libraries the engine uses. config reads and writes the settings file, res holds
    -- the game's resource tables, socket supplies a wall clock, and extdata decodes the
    -- per-item data that holds enchantment charges and timers.
    --
    -- require here is GearSwap's include, not Lua's. It returns the table already loaded
    -- under that name in package.loaded. GearSwap has loaded each of these before any job
    -- file runs, and the files and xml libraries the settings load uses below too, so every
    -- call returns the addon's own copy.
    local config = require('config')
    local res = require('resources')
    local socket = require('socket')
    local extdata = require('extdata')

    -- What the settings file holds on a first run, and the shape config.load merges a saved
    -- file into. The top-level booleans are the toggles commands.lua flips. delay is the
    -- multibox announce window in seconds, and the spell-received failsafe times against it
    -- too.
    --
    -- Every setting needs a key here. The config library lowercases each tag it parses and
    -- maps it back onto a default's spelling, so a key absent from this table lands under a
    -- lowercase name nothing reads.
    local default = {
        visible = true,
        oneline = false,
        -- Which renderer draws the status box. oneline above chooses the view, and this
        -- chooses the renderer. A saved file that carries either key keeps its own value
        -- through the merge, so a changed default for either reaches an installed file only
        -- when the display silo's version is raised.
        Display_Style = 'lattice',
        -- The player's floor on the width of the status box's value column, in characters.
        -- Zero leaves the column sized by the widest mode option and the header.
        Display_MinValueCells = 0,
        debug = false,
        info = true,
        warn = true,
        gear_reporting = false,
        -- The lattice style's panel: the body behind the text, the strip behind the header
        -- line, and the border with its width. pad is how far the panel reaches past the box
        -- at each side, and pad_bottom how far below it, both in pixels. At the top, the strip
        -- meets the border. Colors are red, green, blue and alpha, as the boxes' own are.
        --
        -- The rig is a four-by-four grid of gear slots, drawn in the stacked view only. It
        -- sits in the cols text columns the layout keeps clear at the right of every mode
        -- row, beside a gutter column. gap is the space between cells, and inset is the
        -- recess's margin around the grid, both in pixels.
        --
        -- A held slot's hue follows its layer, and a layer that already has a color on the
        -- box keeps it here. A strip hold takes the orange of its token, the disable hold
        -- the cyan of its DIS token, a lock mode and the weapon lock the violet the LCK row
        -- and the lock tokens share, and Hoxne the green of its header square. The item use,
        -- Sleep gear, the cast implement and received gear have no color elsewhere, so each
        -- has its own here. other is for a held slot whose layer has no hue, and socket for a
        -- slot nothing holds.
        Lattice = {
            body = { red = 0, green = 0, blue = 0, alpha = 190 },
            strip = { red = 30, green = 30, blue = 50, alpha = 220 },
            border = { red = 110, green = 110, blue = 110, alpha = 255, width = 1 },
            pad = 4,
            -- The clear space below the last line. There is no matching value for the top.
            -- The panel's top is wherever the strip meets the border, and the strip's depth
            -- comes from the measured line height, so it holds when the box changes size.
            pad_bottom = 2,
            rig = {
                enabled = true,
                -- The grid is measured in text columns, not pixels. It reserves cols columns
                -- at the right of every mode row and sizes its cells to fill them, so it
                -- scales with the font.
                cols = 9, gap = 2, inset = 3,
                -- Columns kept empty between the widest mode row and the grid, so the two
                -- never touch however the spacing rounds. They are part of the layout's
                -- reservation, not of the grid's width.
                gutter = 1,
                recess = { red = 0, green = 0, blue = 0, alpha = 235 },
                socket = { red = 70, green = 82, blue = 104, alpha = 235 },
                -- Keyed by the strings slot_claim returns. Each key is written as a quoted
                -- string, because strip and hoxne are also exported names.
                hue = {
                    ['strip']  = { red = 255, green = 132, blue = 64,  alpha = 255 },
                    ['disable'] = { red = 90, green = 200, blue = 255, alpha = 255 },
                    ['lock']   = { red = 186, green = 150, blue = 255, alpha = 255 },
                    ['weapon'] = { red = 186, green = 150, blue = 255, alpha = 255 },
                    ['hoxne']  = { red = 80,  green = 220, blue = 110, alpha = 255 },
                    ['ench']   = { red = 236, green = 236, blue = 140, alpha = 255 },
                    ['sleep']  = { red = 110, green = 120, blue = 255, alpha = 255 },
                    ['implement'] = { red = 240, green = 80, blue = 80, alpha = 255 },
                    ['spell']  = { red = 255, green = 110, blue = 200, alpha = 255 },
                    ['other']  = { red = 235, green = 235, blue = 235, alpha = 255 },
                },
            },
        },
        -- The halo style draws four text objects at one position, none with a background.
        -- crown, labels and hold are the three satellite objects, each with its own stroke,
        -- weight and color. Their font, size, padding and edge anchoring are copied from
        -- Display_Box when the style is entered, so all four share one grid. values is the
        -- status box's own stroke and weight while the style stands. hue holds the text
        -- colors, and value_cap caps a value's width in cells, with zero for no cap. Every
        -- stroke is width 2, so weight and hue carry the separation.
        Halo = {
            crown = { text = { red = 246, green = 246, blue = 240, alpha = 255, stroke = { width = 2, alpha = 255, red = 8, green = 8, blue = 10 } }, pos = { x = 0, y = 0 }, bg = { visible = false, red = 0, green = 0, blue = 0, alpha = 0 }, flags = { bold = true, draggable = false }, padding = 3 },
            labels = { text = { red = 168, green = 176, blue = 186, alpha = 255, stroke = { width = 2, alpha = 255, red = 8, green = 8, blue = 10 } }, pos = { x = 0, y = 0 }, bg = { visible = false, red = 0, green = 0, blue = 0, alpha = 0 }, flags = { bold = false, draggable = false }, padding = 3 },
            hold = { text = { red = 246, green = 246, blue = 240, alpha = 255, stroke = { width = 2, alpha = 255, red = 8, green = 8, blue = 10 } }, pos = { x = 0, y = 0 }, bg = { visible = false, red = 0, green = 0, blue = 0, alpha = 0 }, flags = { bold = true, draggable = false }, padding = 3 },
            values = { stroke_width = 2, bold = true },
            hue = {
                label = { red = 168, green = 176, blue = 186 },
                value = { red = 246, green = 246, blue = 240 },
                idle = { red = 92, green = 98, blue = 108 },
                good = { red = 96, green = 226, blue = 150 },
                warn = { red = 255, green = 190, blue = 80 },
                cyan = { red = 96, green = 196, blue = 255 },
            },
            value_cap = 20,
        },
        Display_Box = { text = { size = 11, font = 'Consolas', red = 255, green = 255, blue = 255, alpha = 255, stroke = { width = 2, alpha = 255, red = 15, green = 15, blue = 15 } }, pos = { x = 0, y = 0 }, bg = { visible = true, red = 0, green = 0, blue = 0, alpha = 190 }, flags = { bold = true }, padding = 3 },
        Debug_Box = { text = { size = 11, font = 'Consolas', red = 255, green = 255, blue = 255, alpha = 255, stroke = { width = 2, alpha = 255, red = 15, green = 15, blue = 15 } }, pos = { x = 0, y = 50 }, bg = { visible = true, red = 0, green = 0, blue = 0, alpha = 190 }, flags = { bold = true }, padding = 3 },
        delay = 3,
        -- The key each mode is bound to, under the mode's command word, or '' for a mode with
        -- no key. A value is in Windower's spelling: f1 to f12, with ^ for Ctrl, ! for Alt or
        -- ~ for Shift in front. Only keybind_apply reads them, and it validates each value
        -- before binding it. The keys are quoted strings because hoxne is also an exported
        -- name. commands.lua's mode table holds the same defaults, for gs c keybind default
        -- and for a saved value that is not a key, so a changed default goes in both.
        Keybinds = {
            ['offensemode'] = 'f12', ['treasurehunter'] = 'f11', ['weaponlock'] = 'f10',
            ['weaponmode'] = 'f9', ['jobmode'] = '^f12', ['jobmode2'] = '^f11',
            ['hoxne'] = '^f10', ['spellreceived'] = '^f9', ['bufflevel'] = '!f12',
        },
        -- One stamp per versioned silo, per character: the version of that silo the
        -- character last loaded, under the character's lowercased name.
        Settings_Version = { display = {}, halo = {} },
    }

    -- Every setting belongs to one silo, so a version reset returns one silo to its
    -- defaults and leaves the rest alone. An entry written as a.b is a sub-block carried
    -- under another silo's key, and it is kept through that key's reset. A silo listed in
    -- SETTINGS_VERSIONS resets when the version stamped for the character playing is behind
    -- the engine's. A silo with no version never resets.
    local SETTINGS_SILOS = {
        display   = { 'Display_Box', 'Debug_Box', 'Display_Style', 'Lattice', 'oneline', 'visible',
                      'Display_MinValueCells' },
        -- The halo style's blocks are a silo of their own, so a new halo version resets them
        -- and leaves the boxes, the style and the view alone.
        halo      = { 'Halo' },
        positions = { 'Display_Box.pos', 'Debug_Box.pos' },
        channels  = { 'debug', 'info', 'warn', 'gear_reporting' },
        timing    = { 'delay' },
        -- Unversioned, so a player's keys survive every engine update. A changed default
        -- here does not reach a file that already carries the block. A mode added to the
        -- block does, at its default, because the config library starts from a copy of
        -- the defaults and merges only the keys the saved file carries.
        keybinds  = { 'Keybinds' },
        stamps    = { 'Settings_Version' },
    }
    -- The engine's current version of each silo that can reset. Raising a number here
    -- delivers that silo's changed defaults to settings files already saved. Every key the
    -- silo names goes back to its default above, while the sub-blocks another silo names,
    -- the two box positions, are kept as the player left them.
    local SETTINGS_VERSIONS = { display = 2, halo = 1 }

    -- The names of the sub-blocks other silos keep under key, which a reset of key carries
    -- over.
    local function settings_kept_under(key)
        local kept = {}
        for _, keys in pairs(SETTINGS_SILOS) do
            for _, entry in ipairs(keys) do
                local parent, sub = entry:match('^([^.]+)%.(.+)$')
                if parent == key then kept[#kept + 1] = sub end
            end
        end
        return kept
    end

    -- Reset every versioned silo whose stamp for this character is behind the engine's,
    -- keeping the sub-blocks other silos own, then stamp every versioned silo as current.
    -- Returns the names of the silos reset, sorted.
    --
    -- The stamps are kept per character. The config library carries a new key into the
    -- global block at the first save, so a single shared stamp would read as current for
    -- every other character.
    local function settings_reset_stale(settings, name)
        local reset = {}
        for silo, current in pairs(SETTINGS_VERSIONS) do
            local map = settings.Settings_Version[silo]
            if (tonumber(map[name]) or 0) < current then
                for _, key in ipairs(SETTINGS_SILOS[silo]) do
                    local fresh = default[key]
                    if type(fresh) == 'table' then
                        fresh = table.copy(fresh)
                        local kept = settings_kept_under(key)
                        for i = 1, #kept do
                            fresh[kept[i]] = settings[key][kept[i]]
                        end
                    end
                    settings[key] = fresh
                end
                reset[#reset + 1] = silo
            end
            map[name] = current
        end
        table.sort(reset)
        return reset
    end

    -- The shared settings file in the data folder, which seeds a character's own file the
    -- first time that character loads. A migration load reads it. Nothing writes, deletes or
    -- renames it.
    local SHARED_SETTINGS_PATH = 'data/settings.xml'

    -- Every settings file the config library writes ends with this tag and one newline.
    local SETTINGS_TAIL = '</settings>'

    -- Why a settings file cannot be loaded, or nil when it can. The text is read once, and
    -- its tail is checked before the parser runs. The XML parser has no end-of-input test
    -- and answers a truncated file with its innermost open element as the root, which
    -- loads as bare defaults and reports nothing. The parse below is the one xml.read
    -- performs once a file exists.
    local function settings_refusal(fileobj)
        local text = fileobj:read() or ''
        -- Anchored at the end, so only a file ending in the tag passes. None of the tag's
        -- characters is special in a pattern, and the trailing %s* admits the newline the
        -- library writes, or a CRLF.
        if not text:find(SETTINGS_TAIL .. '%s*$') then
            return 'does not end with ' .. SETTINGS_TAIL
        end
        local parsed, err = require('xml').parse(text)
        if not parsed then return err or 'XML error' end
    end

    -- Load this character's own settings file, data/<Character>/settings.xml, beside the
    -- character's job files. The name uses the game's capitalization, and Windows matches
    -- the folder name without regard to case. Returns the settings table and, for a file
    -- that will not load, a record of its path and the reason.
    --
    -- A refused file is never handed to the config library. The library keeps every table
    -- config.load returns for the life of the client, and its load, logout and login
    -- handler re-parses each one and reprints its error line at every logout and login.
    -- The session runs on a copy of the defaults instead, and nothing prints here.
    -- display.lua prints the path and the reason once the client has settled, and refuses
    -- every save while the record stands.
    --
    -- A character with no file of its own is migrated when the shared file exists. A load
    -- of the shared file returns its global section merged with this character's section,
    -- and config.load writes that seed as the new file's global section, so every position,
    -- style, toggle and version stamp carries over. A refused shared file creates no file
    -- for this character, and the next load tries the migration again.
    --
    -- The seed's metatable is removed before the seed is passed back. table.copy keeps the
    -- metatable of the table it copies, and the table config.load returned carries the
    -- library's metatable, whose __index is a function. Handed back to config.load as
    -- defaults, that __index answers the table library's request for an iterator with the
    -- wrong function. With the metatable in place, the migration raises inside config.load
    -- before any file is written, and the job file fails to load.
    local function load_settings(name)
        local files = require('files')
        local path = 'data/' .. name .. '/settings.xml'
        local own = files.new(path)
        if own:exists() then
            local reason = settings_refusal(own)
            if reason then return table.copy(default), { path = path, reason = reason } end
            return config.load(path, default)
        end
        local shared = files.new(SHARED_SETTINGS_PATH)
        if not shared:exists() then return config.load(path, default) end
        local reason = settings_refusal(shared)
        if reason then
            return table.copy(default), { path = SHARED_SETTINGS_PATH, reason = reason }
        end
        local seed = table.copy(config.load(SHARED_SETTINGS_PATH, default))
        setmetatable(seed, nil)
        return config.load(path, seed)
    end

    -- The live settings table. A write to it changes behavior at once but is not saved by
    -- itself. display.lua is the only caller of config.save, and it saves only while logged
    -- in and only when the load that produced this table was not refused.
    local settings, settings_refused = load_settings(player.name)

    -- The silos whose stamp for this character is behind are reset before anything reads
    -- them, so the boxes below are built on the reset values. display.lua announces the
    -- reset and saves it, in a call the root schedules once the client has settled.
    local settings_reset = settings_reset_stale(settings, player.name:lower())

    -- Apply one box's saved appearance and position to it. Four of the keys read here are
    -- absent from the default table above: text.fonts and the italic, right and bottom
    -- flags. texts.new fills them in from the text library's defaults, so this must run
    -- after the box is created, or unpack(cfg.text.fonts) unpacks a nil.
    local function apply_box_settings(box, cfg)
        box:pos(cfg.pos.x, cfg.pos.y)
        box:font(cfg.text.font, unpack(cfg.text.fonts))
        box:size(cfg.text.size)
        box:color(cfg.text.red, cfg.text.green, cfg.text.blue)
        box:alpha(cfg.text.alpha)
        box:stroke_width(cfg.text.stroke.width)
        box:stroke_color(cfg.text.stroke.red, cfg.text.stroke.green, cfg.text.stroke.blue)
        box:stroke_alpha(cfg.text.stroke.alpha)
        box:bg_color(cfg.bg.red, cfg.bg.green, cfg.bg.blue)
        box:bg_alpha(cfg.bg.alpha)
        box:bg_visible(cfg.bg.visible)
        box:bold(cfg.flags.bold)
        box:italic(cfg.flags.italic)
        box:right_justified(cfg.flags.right)
        box:bottom_justified(cfg.flags.bottom)
        box:pad(cfg.padding)
    end

    -- The two on-screen boxes: the mode display and the debug readout. display.lua writes
    -- their text, commands.lua shows and hides them, and lifecycle.lua destroys them at
    -- unload.
    --
    -- Neither box is given the settings root. Given the root, the text library writes the
    -- whole settings file when the box is created and again whenever a drag is released,
    -- and it registers a refresh callback that destroying the box never removes. Without
    -- the root, the library applies the block and nothing else, and every save is the
    -- engine's own. A box's position call still writes x and y into its own block by
    -- reference, so a drag reaches the settings table as it happens, and display.lua's
    -- drag settle saves it.
    local gs_status = texts.new("", settings.Display_Box)
    local gs_debug = texts.new("", settings.Debug_Box)

    -- Restore both boxes, then set draggability and visibility explicitly, in both
    -- directions. texts.new records a new box as hidden in the library's own table without
    -- telling the text object, so a box that is shown but never hidden leaves an empty
    -- background on screen when its setting is off. A box can be dragged only while it is
    -- visible, and commands.lua keeps that pairing when it toggles a box.
    apply_box_settings(gs_status, settings.Display_Box)
    apply_box_settings(gs_debug, settings.Debug_Box)
    gs_status:draggable(settings.visible and true or false)
    gs_debug:draggable(settings.debug and true or false)
    if settings.visible then gs_status:show() else gs_status:hide() end
    if settings.debug then gs_debug:show() else gs_debug:hide() end

    ------------------------------------------------------------------------------------------------
    -- SECTION 8 - SHARED CONSTANTS AND LOOKUP TABLES
    ------------------------------------------------------------------------------------------------
    -- The constants and lookup tables the engine reads. Most are exported at the end of this
    -- file and bound in their reader's import block. Those only this file's elemental bonus
    -- chooser and buff prediction read stay private.

    -- Action classification -----------------------------------------------------------------------

    -- Spell types that carry a recast timer. pretargetcheck reads the spell recasts only for
    -- these types, so a type absent here is never checked for cooldown.
    local HasRecastTimer                      = {
        ['WhiteMagic']   = true,
        ['BlackMagic']   = true,
        ['BlueMagic']    = true,
        ['Ninjutsu']     = true,
        ['BardSong']     = true,
        ['Geomancy']     = true,
        ['SummonerPact'] = true,
        ['Trust']        = true,
    }

    -- Spell types whose aftercast leaves a 2.5 second busy tail, and whose end ends every
    -- standing buff prediction. It holds the same types as the table above but answers a
    -- different question, so a type added to one is not added to the other. The burst
    -- checks ask only these types too, Geomancy excepted, because only they carry a spell's
    -- id for expected_cast_seconds to read.
    local RecastTimers                        = {
        ['WhiteMagic']   = true,
        ['BlackMagic']   = true,
        ['BlueMagic']    = true,
        ['Ninjutsu']     = true,
        ['BardSong']     = true,
        ['Geomancy']     = true,
        ['SummonerPact'] = true,
        ['Trust']        = true,
    }

    -- Buff and action-type names, so the comparison sites read as words. The incapacitation
    -- buffs are names, because hooks.lua indexes buffactive with them. TYPE_JA, TYPE_WS and
    -- TYPE_SCH match spell.type, and TYPE_MS matches spell.action_type.
    local BUFF_SLEEP, BUFF_STUN, BUFF_KO      = 'Sleep', 'Stun', 'KO'
    local BUFF_PETRI, BUFF_CHARM, BUFF_TERROR = 'Petrification', 'Charm', 'Terror'
    local TYPE_JA, TYPE_WS, TYPE_MS, TYPE_SCH = 'JobAbility', 'WeaponSkill', 'Magic', 'Scholar'

    -- Action categories that count as tagging a mob for Treasure Hunter: 1 melee, 2 ranged
    -- attack, 3 weapon skill, 4 spell, 6 job ability, 11 monster TP move and 14 unblinkable
    -- job ability. While the Treasure Hunter mode is anything but None, th.lua stamps the
    -- target of this character's own action in any of them with the clock, so a mob still
    -- being fought never ages out of the tagged table. A category absent here refreshes no
    -- tag.
    local TaggingCategories                   = S { 1, 2, 3, 4, 6, 11, 14 }

    -- Action-message ids that report a death, the same set GearSwap treats as fatal. th.lua
    -- drops a mob from the tagged table on any of them, ahead of the 180 second sweep that
    -- would otherwise retire it. The table is keyed by id, so the test is a plain index.
    local DeathMessages                       = {
        [6] = true,   -- <actor> defeats <target>.
        [20] = true,  -- <target> falls to the ground.
        [113] = true, -- <actor> casts <spell>. <target> falls to the ground.
        [406] = true, -- <actor> uses <weapon skill>. <target> falls to the ground.
        [605] = true, -- Additional effect: <target> falls to the ground.
        [646] = true, -- <actor> uses <ability>. <target> falls to the ground.
    }

    -- Job, zone and element reference -------------------------------------------------------------

    -- The storm spells, both tiers. builders.lua merges sets.Storms over the enhancing
    -- midcast build for any of them. interface.lua declares that set empty, so a job file
    -- that never fills it loses nothing.
    local Storms                              = S { "Aurorastorm", "Voidstorm", "Firestorm", "Sandstorm", "Rainstorm", "Windstorm", "Hailstorm", "Thunderstorm",
        "Aurorastorm II", "Voidstorm II", "Firestorm II", "Sandstorm II", "Rainstorm II", "Windstorm II", "Hailstorm II", "Thunderstorm II" }

    -- The Utsusemi tiers. builders.lua routes them to sets.Precast.Utsusemi and
    -- sets.Midcast.Utsusemi, and counts the ninja tools at precast.
    local UtsusemiSpell                       = S { 'Utsusemi: Ichi', 'Utsusemi: Ni', 'Utsusemi: San' }

    -- The enhancing families whose tier-one spell has the family set's own name. builders.lua's
    -- named-set test in the white magic branch passes over these names, so Refresh, Regen and
    -- Phalanx take the enhancing ladder as their higher tiers do: the enhancing set, its Others
    -- set when cast on someone else, then the family set.
    local ENHANCING_FAMILY_SPELL              = { Refresh = true, Regen = true, Phalanx = true }

    -- The phrase a shot's info line gives an offense mode that has a ranged set of its own,
    -- keyed by the mode. Any other mode with a set, such as one a job file adds, is named on
    -- the line instead, by builders.lua's ranged branch.
    local RA_MODE_PHRASE                      = {
        ['ACC']       = 'Ranged Attack with Accuracy',
        ['PDL']       = 'Ranged Attack with Physical Damage Limit',
        ['SB']        = 'Ranged Attack with Subtle Blow',
        ['MEVA']      = 'Ranged Attack with Magic Evasion',
        ['DT']        = 'Ranged Attack with Damage Taken',
        ['PDT']       = 'Ranged Attack with Physical Damage Taken',
        ['CRIT']      = 'Ranged Attack with Critical Hit',
        ['True Shot'] = 'Ranged Attack with True Shot',
    }

    -- The Dynamis Divergence zones. On entering one, the zone handler prints a line pointing
    -- the player at gs c dynamisrp, the neck lock. That lock mode's claim is what holds a
    -- Dynamis neck on, and no release path treats any slot specially inside these zones.
    local Divergence_Zones                    = S { "Dynamis - San d'Oria [D]", "Dynamis - Bastok [D]", "Dynamis - Windurst [D]", "Dynamis - Jeuno [D]" }

    -- Jobs for which Silence is worth a Remedy. spellreceived.lua tests the main job and the
    -- sub job against it, so a listed sub job qualifies. With AutoItem on, Paralysis spends
    -- a Remedy on any job, and Silence only on these.
    local Mage_Job                            = S { 'BLM', 'RDM', 'WHM', 'BRD', 'BLU', 'GEO', 'SCH', 'NIN', 'PLD', 'RUN', 'DRK', 'SMN' }

    -- The town zones. monitor.lua binds this list, and nothing in the engine reads it.
    local Cities                              = S { "Ru'Lude Gardens", "Upper Jeuno", "Lower Jeuno", "Port Jeuno", "Port Windurst", "Windurst Waters", "Windurst Woods", "Windurst Walls", "Heavens Tower", "Port San d'Oria", "Northern San d'Oria",
        "Southern San d'Oria", "Chateau d'Oraguille", "Port Bastok", "Bastok Markets", "Bastok Mines", "Metalworks", "Aht Urhgan Whitegate", "The Colosseum", "Tavnazian Safehold", "Nashmau", "Selbina",
        "Mhaura", "Rabao", "Norg", "Kazham", "Eastern Adoulin", "Western Adoulin", "Celennia Memorial Library", "Mog Garden", "Leafallia" }

    -- The client's language, lowercased to index a resource row. monitor.lua uses it to read
    -- buff names from res.buffs when matching a cancel pattern. It is read once, because it
    -- cannot change without a client restart.
    local Language                            = windower.ffxi.get_info().language:lower()

    -- Action types whose precast gear is their final gear. builders.lua returns from the
    -- midcast build at once for these. equip.lua counts a precast for one of them as the
    -- phase that names the set in the merge report, since no later phase will.
    local PRECAST_FINAL                       = {
        WeaponSkill   = true,
        JobAbility    = true,
        Item          = true,
        Scholar       = true,
        Ward          = true,
        Rune          = true,
        Effusion      = true,
        CorsairRoll   = true,
        CorsairShot   = true,
        Waltz         = true,
        Jig           = true,
        Samba         = true,
        Step          = true,
        Flourish1     = true,
        Flourish2     = true,
        Flourish3     = true,
        BloodPactRage = true,
        BloodPactWard = true,
        Monster       = true,
        PetCommand    = true,
    }

    -- The action types a master gives a pet: a blood pact, a Ready move's command, which
    -- GearSwap types Monster, and every other pet command, such as Fight, Sic, Smiting
    -- Breath or Deploy. None has a cast time, so each is in PRECAST_FINAL too. builders.lua
    -- dresses one at precast over the idle or engaged build: sets.Pet_Command, then the
    -- command's family set, then its own set, with no spell layer. hooks.lua reads it to
    -- tell the master's own pet command from a cast of the master's in flight.
    local PET_COMMAND_TYPES                   = {
        BloodPactRage = true,
        BloodPactWard = true,
        Monster       = true,
        PetCommand    = true,
    }

    -- The jobs that keep a pet of their own. On these the second job mode is the pet mode,
    -- read by builders.lua for the children of the pet sets and of the offense mode's set.
    -- Off them it stays the job file's own mode.
    local PET_JOBS                            = {
        SMN = true,
        BST = true,
        DRG = true,
        PUP = true,
        GEO = true,
    }

    -- The spirits, by the name GearSwap gives the pet, one word each. A spirit casts its own
    -- spells, and hooks.lua dresses nothing for them. A spirit's gear is worn the whole time
    -- instead, in the child set the pet mode's value names, such as
    -- sets.Idle.Pet.Engaged.Spirit.
    local SPIRITS                             = {
        FireSpirit    = true,
        IceSpirit     = true,
        AirSpirit     = true,
        EarthSpirit   = true,
        ThunderSpirit = true,
        WaterSpirit   = true,
        LightSpirit   = true,
        DarkSpirit    = true,
    }

    -- How long a pet's move may hold the master's actions and rebuilds when none of the
    -- events that end it arrives, in seconds from its readying. The master's own next
    -- action, movement or status change compares against it, at that event alone.
    local PET_MOVE_STALE                      = 3

    -- The pet commands of type PetCommand that make the pet act. Every pact and every Ready
    -- move's command does too. A move the pet readies within PET_COMMAND_WINDOW seconds of
    -- one is the master's own, which hooks.lua holds. Any other move is the pet's own doing.
    local PET_MOVE_COMMANDS                   = {
        ['Sic']              = true,
        ['Smiting Breath']   = true,
        ['Restoring Breath'] = true,
    }
    local PET_COMMAND_WINDOW                  = 2

    -- The family set under sets.Pet_Command that a pet command wears, by its type, then by
    -- its name for a command of type PetCommand. Sic shares the Ready moves' timer and their
    -- delay gear, and the maneuvers all read the same gear.
    local PET_COMMAND_FAMILY                  = {
        BloodPactRage = 'BloodPact',
        BloodPactWard = 'BloodPact',
        Monster       = 'Ready',
    }
    local PET_COMMAND_FAMILY_BY_NAME          = {
        ['Sic']              = 'Ready',
        ['Fire Maneuver']    = 'Maneuver',
        ['Ice Maneuver']     = 'Maneuver',
        ['Wind Maneuver']    = 'Maneuver',
        ['Earth Maneuver']   = 'Maneuver',
        ['Thunder Maneuver'] = 'Maneuver',
        ['Water Maneuver']   = 'Maneuver',
        ['Light Maneuver']   = 'Maneuver',
        ['Dark Maneuver']    = 'Maneuver',
    }

    -- Equipment slots -----------------------------------------------------------------------------

    -- Every spelling of a slot, folded onto one name. A job file may write ear1, lear,
    -- learring or left_ear for the same slot. merge_into folds each key through this table
    -- before assigning, so the last spelling wins instead of four keys surviving side by
    -- side. Slot ownership folds them too, or a held left_ear would not match a request for
    -- ear1.
    --
    -- The keys match GearSwap's own slot_map exactly. A key missing here is a slot the
    -- engine silently drops from a set GearSwap would have equipped.
    local CANON_SLOT                          = {
        main = 'main',
        sub = 'sub',
        range = 'range',
        ranged = 'range',
        ammo = 'ammo',
        head = 'head',
        body = 'body',
        hands = 'hands',
        legs = 'legs',
        feet = 'feet',
        neck = 'neck',
        waist = 'waist',
        back = 'back',
        ear1 = 'left_ear',
        ear2 = 'right_ear',
        lear = 'left_ear',
        rear = 'right_ear',
        learring = 'left_ear',
        rearring = 'right_ear',
        left_ear = 'left_ear',
        right_ear = 'right_ear',
        ring1 = 'left_ring',
        ring2 = 'right_ring',
        lring = 'left_ring',
        rring = 'right_ring',
        left_ring = 'left_ring',
        right_ring = 'right_ring',
    }

    -- Elemental bonus gear ------------------------------------------------------------------------
    -- The tables the elemental bonus chooser and builders.lua's per-cast inputs read: the
    -- day, weather and distance mechanics as numbers, each stated once.

    -- Element name to id, under both of each element's names. GearSwap's refresh.lua writes
    -- world.day_element and world.weather_element in the language GearSwap's own setting
    -- holds. That is English until a job file calls set_language('japanese'), which switches
    -- them mid-session, so the table maps the English and the Japanese names alike and
    -- follows the setting without reading it. A spell needs no lookup, because
    -- spell.element_id carries the number. Clear weather is 'None', id 15. The only spells
    -- whose element is 15 are the element-less ones, Meteor among them, which the chooser's
    -- caller refuses by id.
    local function element_ids()
        local ids = {}
        for id, entry in pairs(res.elements) do
            ids[entry.english] = id
            ids[entry.japanese] = id
        end
        return ids
    end
    local ELEMENT_ID                          = element_ids()
    local LIGHT_ID                            = 6
    local DARK_ID                             = 7
    local NONE_ID                             = 15
    -- Elemental Magic's skill id in res/skills.lua, the skill whose spells Zodiac Ring
    -- serves. It is compared by id, because GearSwap writes spell.skill in the language its
    -- own setting holds and stamps the id beside it on every spell row.
    local ELEMENTAL_MAGIC_SKILL               = 36

    -- The element that a day or weather of the keyed element penalizes. Fire penalizes Ice,
    -- and so on around the cycle Fire > Ice > Wind > Earth > Lightning > Water > Fire. Light
    -- and Dark penalize each other. There is no row for 15, because clear weather penalizes
    -- nothing. No Windower resource carries this wheel.
    local BEATS                               = { [0] = 1, [1] = 2, [2] = 3, [3] = 4, [4] = 5, [5] = 0, [6] = 7, [7] = 6 }

    -- The single-element obi for each spell element, by id. Each forces the day and weather
    -- procs of its own element only, so for a spell of that element it can force a bonus
    -- and never a penalty. Hachirin-no-Obi forces every proc, penalties included.
    local SINGLE_OBI                          = {
        [0] = 'Karin Obi', [1] = 'Hyorin Obi', [2] = 'Furin Obi', [3] = 'Dorin Obi',
        [4] = 'Rairin Obi', [5] = 'Suirin Obi', [6] = 'Korin Obi', [7] = 'Anrin Obi',
    }
    local HACHIRIN                            = 'Hachirin-no-Obi'
    local SASH                                = "Orpheus's Sash"
    local CAPE                                = 'Twilight Cape'
    local RING                                = 'Zodiac Ring'

    -- Orpheus's Sash: its elemental affinity in percent, by whole yalms to the target's
    -- center, with row 13 serving every longer distance. The rows follow a straight line from
    -- +15 within two yalms to +1 at thirteen, rounded. Only the two endpoints are known, and
    -- the rows between them are interpolated.
    local SASH_PCT                            = {
        [0] = 15, [1] = 15, [2] = 15, [3] = 14, [4] = 12, [5] = 11, [6] = 10,
        [7] = 9, [8] = 7, [9] = 6, [10] = 5, [11] = 4, [12] = 2, [13] = 1,
    }
    -- Below this affinity, which means beyond ten yalms, the sash is not a candidate and the
    -- job file's own waist stays.
    local SASH_MIN_PCT                        = 5

    -- Iridescence by staff name: the percent it adds to a matching weather's bonus and to an
    -- opposing weather's penalty. It rides the weather proc and never touches the day term.
    -- It is read against the main the built set carries, cures included.
    local IRIDESCENCE                         = { ['Chatoyant Staff'] = 10, ['Iridal Staff'] = 5 }

    -- The weather term by world.weather_intensity: clear, single, double.
    local WEATHER_PCT                         = { [0] = 0, [1] = 10, [2] = 25 }

    -- The day term, Twilight Cape's and Zodiac Ring's additions, and the cap on the whole
    -- day-and-weather term, in percent. PROC is the chance that an unforced day or weather
    -- effect procs. The cap holds for cures as it does for damage.
    local DAY_PCT                             = 10
    local CAPE_PCT                            = 5
    local RING_PCT                            = 3
    local PROC                                = 1 / 3
    local CAP_PCT                             = 40

    -- Each candidate's resource row, for the wearability test that runs before its bag read.
    -- GearSwap's unpack_equip_list, in equip_processing.lua, drops an item on four tests, and
    -- these pieces can fail two of them: the job mask and the level. A piece GearSwap would
    -- drop must never displace the job file's own. Twilight Cape is the one piece not every
    -- job can wear, and the rest are listed so one code path serves every candidate.
    local CANDIDATE_ROW                       = {
        ['Karin Obi']       = res.items[15435],
        ['Hyorin Obi']      = res.items[15436],
        ['Furin Obi']       = res.items[15437],
        ['Dorin Obi']       = res.items[15438],
        ['Rairin Obi']      = res.items[15439],
        ['Suirin Obi']      = res.items[15440],
        ['Korin Obi']       = res.items[15441],
        ['Anrin Obi']       = res.items[15442],
        ['Hachirin-no-Obi'] = res.items[28419],
        ["Orpheus's Sash"]  = res.items[26359],
        ['Twilight Cape']   = res.items[16259],
        ['Zodiac Ring']     = res.items[15858],
    }

    -- Skillchains and magic bursts ----------------------------------------------------------------
    -- The tables run_burst records and ends a monster's burst window with, one record per
    -- monster, and the midcast build predicts a burst from.

    -- Skillchains keyed by add-effect message id: 288 to 301 are chain damage, 385 to 398
    -- chain healing, and 767 to 770 the Umbra and Radiance chains. run_burst finds a chain
    -- with one index on the message id, so an id with no row here is no chain. id repeats
    -- the key, english names the chain for the debug log, and elements names the elements a
    -- magic burst on it can match.
    local skillchains                         = {
        [288] = { id = 288, english = 'Light', elements = { 'Light', 'Lightning', 'Wind', 'Fire' } },
        [289] = { id = 289, english = 'Darkness', elements = { 'Dark', 'Ice', 'Water', 'Earth' } },
        [290] = { id = 290, english = 'Gravitation', elements = { 'Dark', 'Earth' } },
        [291] = { id = 291, english = 'Fragmentation', elements = { 'Lightning', 'Wind' } },
        [292] = { id = 292, english = 'Distortion', elements = { 'Ice', 'Water' } },
        [293] = { id = 293, english = 'Fusion', elements = { 'Light', 'Fire' } },
        [294] = { id = 294, english = 'Compression', elements = { 'Dark' } },
        [295] = { id = 295, english = 'Liquefaction', elements = { 'Fire' } },
        [296] = { id = 296, english = 'Induration', elements = { 'Ice' } },
        [297] = { id = 297, english = 'Reverberation', elements = { 'Water' } },
        [298] = { id = 298, english = 'Transfixion', elements = { 'Light' } },
        [299] = { id = 299, english = 'Scission', elements = { 'Earth' } },
        [300] = { id = 300, english = 'Detonation', elements = { 'Wind' } },
        [301] = { id = 301, english = 'Impaction', elements = { 'Lightning' } },
        [385] = { id = 385, english = 'Light', elements = { 'Light', 'Lightning', 'Wind', 'Fire' } },
        [386] = { id = 386, english = 'Darkness', elements = { 'Dark', 'Ice', 'Water', 'Earth' } },
        [387] = { id = 387, english = 'Gravitation', elements = { 'Dark', 'Earth' } },
        [388] = { id = 388, english = 'Fragmentation', elements = { 'Lightning', 'Wind' } },
        [389] = { id = 389, english = 'Distortion', elements = { 'Ice', 'Water' } },
        [390] = { id = 390, english = 'Fusion', elements = { 'Light', 'Fire' } },
        [391] = { id = 391, english = 'Compression', elements = { 'Dark' } },
        [392] = { id = 392, english = 'Liquefaction', elements = { 'Fire' } },
        [393] = { id = 393, english = 'Induration', elements = { 'Ice' } },
        [394] = { id = 394, english = 'Reverberation', elements = { 'Water' } },
        [395] = { id = 395, english = 'Transfixion', elements = { 'Light' } },
        [396] = { id = 396, english = 'Scission', elements = { 'Earth' } },
        [397] = { id = 397, english = 'Detonation', elements = { 'Wind' } },
        [398] = { id = 398, english = 'Impaction', elements = { 'Lightning' } },
        [767] = { id = 767, english = 'Radiance', elements = { 'Light', 'Lightning', 'Wind', 'Fire' } },
        [768] = { id = 768, english = 'Umbra', elements = { 'Dark', 'Ice', 'Water', 'Earth' } },
        [769] = { id = 769, english = 'Radiance', elements = { 'Light', 'Lightning', 'Wind', 'Fire' } },
        [770] = { id = 770, english = 'Umbra', elements = { 'Dark', 'Ice', 'Water', 'Earth' } },
    }

    -- Give each chain its elements as a set keyed by element id, built once here, which a
    -- spell's element_id indexes directly. A chain's record holds its chain's set rather than
    -- a copy. A name ELEMENT_ID lacks is left out of the set, so that element never bursts
    -- on the chain. Returns every element some chain carries, CHAIN_ELEMENT, the set a
    -- cast's element must be in for a chain to re-dress it.
    local function chain_element_ids(chains)
        local any = {}
        for _, chain in pairs(chains) do
            local ids = {}
            for i = 1, #chain.elements do
                local id = ELEMENT_ID[chain.elements[i]]
                if id then
                    ids[id] = true
                    any[id] = true
                end
            end
            chain.element_ids = ids
        end
        return any
    end
    local CHAIN_ELEMENT                       = chain_element_ids(skillchains)

    -- The magic burst window, in seconds from the chain's packet, by the chain's step on its
    -- monster. A monster's first chain, made by the second weaponskill, is step 2, and each
    -- chain continued inside the window is one step more. Every step past the table's last
    -- row gets BURST_WINDOW_FLOOR. A chain a helix closes gets HELIX_WINDOW_BONUS more.
    local BURST_WINDOW                        = { [2] = 9, [3] = 8, [4] = 7, [5] = 6 }
    local BURST_WINDOW_FLOOR                  = 5
    local HELIX_WINDOW_BONUS                  = 2

    -- How much later than expected_cast_seconds a spell lands, in seconds. The burst
    -- prediction adds it, and so does the re-dress record's predicted landing, so a cast is
    -- judged at its landing.
    local BURST_LANDING_LEAD                  = 0.6

    -- The actions that end a monster's burst window when they carry a skillchain property,
    -- land, and make no chain, by action category, each with the resource its id is read
    -- from: a weaponskill, an NPC's or a pet's TP move, and an avatar's blood pact.
    local BURST_ENDER_RESOURCE                = { [3] = 'weapon_skills', [11] = 'monster_abilities', [13] = 'job_abilities' }

    -- The game's messages for a move that lands no hit: a weaponskill or a TP move that
    -- misses (188), an ability that misses (158, 324, 658), and shadows that take the hit
    -- (31). Such a move leaves a burst window open. A move that lands any hit carries a
    -- damage message instead, even a multi-hit weaponskill some of whose hits miss.
    local SKILL_MISS_MESSAGE                  = { [31] = true, [158] = true, [188] = true, [324] = true, [658] = true }

    -- The helix spells by id, found by the word every helix's English name contains. A helix
    -- that closes a chain arrives as a spell's finish, with the spell's id as its param.
    local function helix_spell_ids()
        local ids = {}
        for id, row in pairs(res.spells) do
            if row.en and row.en:find('helix', 1, true) then ids[id] = true end
        end
        return ids
    end
    local HELIX_SPELL                         = helix_spell_ids()

    -- A spell's damage messages: a hit (2) and a magic burst's hit (252). A physical blue
    -- spell under Chain Affinity or Azure Lore, or a spell Immanence carries, that lands one
    -- on a monster ends that monster's burst window. Any other message, a resist or shadows
    -- taking the hit among them, leaves the window open.
    local SPELL_DAMAGE_MESSAGE                = { [2] = true, [252] = true }

    -- The two Blue Mage abilities that let a physical blue spell end a burst window, by job
    -- ability id, each with how long another Blue Mage's use of it is held, in seconds. Chain
    -- Affinity (94) lasts 30 seconds, and that Blue Mage's next physical spell uses it up.
    -- Azure Lore (93) lasts 30 seconds, or 40 with the relic hands. Another character cannot
    -- see which hands are worn, so the longer is held, and no spell uses it up. A use counts
    -- only when its packet carries ABILITY_USED_MESSAGE, the game's line for an ability used.
    local BLUE_AFFINITY_HOLD                  = { [94] = 30, [93] = 40 }
    local CHAIN_AFFINITY_ID                   = 94
    local ABILITY_USED_MESSAGE                = 100

    -- The physical blue spells by id. Under Chain Affinity or Azure Lore one that hits ends a
    -- burst window, and under Burst Affinity alone one never bursts. Built once, while the
    -- job file includes the engine, from interface.lua's BluePhysical as the engine ships it.
    -- So a job file's own BluePhysical sorts its gear and never changes which spells end a
    -- window or can burst.
    local function blue_physical_ids()
        local ids = {}
        for id, row in pairs(res.spells) do
            if row.type == 'BlueMagic' and row.en and BluePhysical:contains(row.en) then ids[id] = true end
        end
        return ids
    end
    local BLUE_PHYSICAL                       = blue_physical_ids()

    -- Immanence, the Scholar stratagem that lets an elemental spell close a skillchain, by job
    -- ability id, and how long another Scholar's use of it is held, in seconds, which is its
    -- duration. That Scholar's next spell Immanence carries uses it up. A use counts only when
    -- its packet carries ABILITY_USED_MESSAGE.
    local IMMANENCE_ID                        = 317
    local IMMANENCE_HOLD                      = 60

    -- The spells Immanence carries into a skillchain, by id: the Elemental Magic spells a
    -- Scholar (job 20) learns, all of them single-target. Only these end a burst window under
    -- Immanence, and only these use up the note of another Scholar's Immanence. Built once
    -- from the resource.
    local function immanence_spell_ids()
        local ids = {}
        for id, row in pairs(res.spells) do
            if row.skill == ELEMENTAL_MAGIC_SKILL and row.levels and row.levels[20] then ids[id] = true end
        end
        return ids
    end
    local IMMANENCE_SPELL                     = immanence_spell_ids()

    -- The least time, in seconds, between a re-dress out of a burst set and the cast's
    -- predicted landing for the game to read the gear it puts on. A window that ends with
    -- less of the cast left leaves the cast in its burst set.
    local BURST_REDRESS_GAP                   = 0.6

    -- How long a predicted buff waits for GearSwap's list to show the real one, in seconds
    -- from the result that predicted it. It is set past the slowest wait seen in play.
    local BUFF_PREDICTION_SECONDS             = 2
    -- The messages of a result entry that gives this character a buff its number names: a
    -- spell on its first target (230), the same spell on each other target (266), and an
    -- ability (319).
    local BUFF_GAIN_MESSAGE                   = { [230] = true, [266] = true, [319] = true }
    -- The messages of an entry that receives a Phantom Roll, on its first target (420) and on
    -- each other (421), and of a Double-Up that raises it (424). Their number is the roll's
    -- total, so the buff is named by the roll. A bust, or a roll that takes no effect, carries
    -- another message and gives nothing.
    local ROLL_GAIN_MESSAGE                   = { [420] = true, [421] = true, [424] = true }
    -- The message of an entry that loses its roll to a Double-Up's bust. The action names the
    -- roll, as a Double-Up that raises it does.
    local ROLL_BUST_MESSAGE                   = 426

    ------------------------------------------------------------------------------------------------
    -- SECTION 9 - SPELL AND ABILITY DATA
    ------------------------------------------------------------------------------------------------
    -- The two tables multibox spell-received tracking runs on. They say whether an action is
    -- tracked at all, which set it calls for, and who besides the named target receives it.

    -- Tracked spells by spell id, and the gate on the whole feature: a spell absent here is
    -- never announced and never dresses a receiver. equip names the received set through
    -- spellreceived.lua's SR_SET_KEY. aoe means the spell always reaches the party, and
    -- accession, majesty and divine mean it does while that effect is up. name and category
    -- are not read.
    local spell_info                          = {
        -- Single-target enhancements, widened by Accession. Two rows differ. Phalanx II
        -- spreads under nothing, and Cursna is the only divine row, so Divine Seal, or a
        -- Yagrush worn for the cast, widens it as well.
        [20] = { name = "Cursna", category = 'track_cursna', equip = "cursna_set", aoe = false, majesty = false, accession = true, divine = true },
        [106] = { name = "Phalanx", category = 'track_phalanx', equip = "phalanx_set", aoe = false, majesty = false, accession = true, divine = false },
        [107] = { name = "Phalanx II", category = 'track_phalanx', equip = "phalanx_set", aoe = false, majesty = false, accession = false, divine = false },
        [108] = { name = "Regen", category = 'track_regen', equip = "regen_set", aoe = false, majesty = false, accession = true, divine = false },
        [110] = { name = "Regen II", category = 'track_regen', equip = "regen_set", aoe = false, majesty = false, accession = true, divine = false },
        [111] = { name = "Regen III", category = 'track_regen', equip = "regen_set", aoe = false, majesty = false, accession = true, divine = false },
        [477] = { name = "Regen IV", category = 'track_regen', equip = "regen_set", aoe = false, majesty = false, accession = true, divine = false },
        [504] = { name = "Regen V", category = 'track_regen', equip = "regen_set", aoe = false, majesty = false, accession = true, divine = false },
        -- Protect and Shell, both families sharing one received set. The -ra forms are
        -- already party-wide. Of the single-target forms, Accession widens both lines and
        -- Majesty only the Protect line, which is why the two lines are flagged differently.
        [43] = { name = "Protect", category = 'track_protect_shell', equip = "protect_shell_set", aoe = false, majesty = true, accession = true, divine = false },
        [44] = { name = "Protect II", category = 'track_protect_shell', equip = "protect_shell_set", aoe = false, majesty = true, accession = true, divine = false },
        [45] = { name = "Protect III", category = 'track_protect_shell', equip = "protect_shell_set", aoe = false, majesty = true, accession = true, divine = false },
        [46] = { name = "Protect IV", category = 'track_protect_shell', equip = "protect_shell_set", aoe = false, majesty = true, accession = true, divine = false },
        [47] = { name = "Protect V", category = 'track_protect_shell', equip = "protect_shell_set", aoe = false, majesty = true, accession = true, divine = false },
        [125] = { name = "Protectra", category = 'track_protect_shell', equip = "protect_shell_set", aoe = true, majesty = true, accession = false, divine = false },
        [126] = { name = "Protectra II", category = 'track_protect_shell', equip = "protect_shell_set", aoe = true, majesty = true, accession = false, divine = false },
        [127] = { name = "Protectra III", category = 'track_protect_shell', equip = "protect_shell_set", aoe = true, majesty = true, accession = false, divine = false },
        [128] = { name = "Protectra IV", category = 'track_protect_shell', equip = "protect_shell_set", aoe = true, majesty = true, accession = false, divine = false },
        [129] = { name = "Protectra V", category = 'track_protect_shell', equip = "protect_shell_set", aoe = true, majesty = true, accession = false, divine = false },
        [48] = { name = "Shell", category = 'track_protect_shell', equip = "protect_shell_set", aoe = false, majesty = false, accession = true, divine = false },
        [49] = { name = "Shell II", category = 'track_protect_shell', equip = "protect_shell_set", aoe = false, majesty = false, accession = true, divine = false },
        [50] = { name = "Shell III", category = 'track_protect_shell', equip = "protect_shell_set", aoe = false, majesty = false, accession = true, divine = false },
        [51] = { name = "Shell IV", category = 'track_protect_shell', equip = "protect_shell_set", aoe = false, majesty = false, accession = true, divine = false },
        [52] = { name = "Shell V", category = 'track_protect_shell', equip = "protect_shell_set", aoe = false, majesty = false, accession = true, divine = false },
        [130] = { name = "Shellra", category = 'track_protect_shell', equip = "protect_shell_set", aoe = true, majesty = false, accession = false, divine = false },
        [131] = { name = "Shellra II", category = 'track_protect_shell', equip = "protect_shell_set", aoe = true, majesty = false, accession = false, divine = false },
        [132] = { name = "Shellra III", category = 'track_protect_shell', equip = "protect_shell_set", aoe = true, majesty = false, accession = false, divine = false },
        [133] = { name = "Shellra IV", category = 'track_protect_shell', equip = "protect_shell_set", aoe = true, majesty = false, accession = false, divine = false },
        [134] = { name = "Shellra V", category = 'track_protect_shell', equip = "protect_shell_set", aoe = true, majesty = false, accession = false, divine = false },
        -- Cure, Curaga and Cura. Majesty widens every single-target Cure, and Accession only
        -- the first four, so V and VI spread under Majesty alone. The -ga and Cura forms are
        -- already party-wide.
        [1] = { name = "Cure", category = 'track_cure', equip = "cure_set", aoe = false, majesty = true, accession = true, divine = false },
        [2] = { name = "Cure II", category = 'track_cure', equip = "cure_set", aoe = false, majesty = true, accession = true, divine = false },
        [3] = { name = "Cure III", category = 'track_cure', equip = "cure_set", aoe = false, majesty = true, accession = true, divine = false },
        [4] = { name = "Cure IV", category = 'track_cure', equip = "cure_set", aoe = false, majesty = true, accession = true, divine = false },
        [5] = { name = "Cure V", category = 'track_cure', equip = "cure_set", aoe = false, majesty = true, accession = false, divine = false },
        [6] = { name = "Cure VI", category = 'track_cure', equip = "cure_set", aoe = false, majesty = true, accession = false, divine = false },
        [7] = { name = "Curaga", category = 'track_cure', equip = "cure_set", aoe = true, majesty = false, accession = false, divine = false },
        [8] = { name = "Curaga II", category = 'track_cure', equip = "cure_set", aoe = true, majesty = false, accession = false, divine = false },
        [9] = { name = "Curaga III", category = 'track_cure', equip = "cure_set", aoe = true, majesty = false, accession = false, divine = false },
        [10] = { name = "Curaga IV", category = 'track_cure', equip = "cure_set", aoe = true, majesty = false, accession = false, divine = false },
        [11] = { name = "Curaga V", category = 'track_cure', equip = "cure_set", aoe = true, majesty = false, accession = false, divine = false },
        [93] = { name = "Cura", category = 'track_cure', equip = "cure_set", aoe = true, majesty = false, accession = false, divine = false },
        [474] = { name = "Cura II", category = 'track_cure', equip = "cure_set", aoe = true, majesty = false, accession = false, divine = false },
        [475] = { name = "Cura III", category = 'track_cure', equip = "cure_set", aoe = true, majesty = false, accession = false, divine = false },
        -- Refresh. Only the first tier is widened, and only by Accession.
        [109] = { name = "Refresh", category = 'track_refresh', equip = "refresh_set", aoe = false, majesty = false, accession = true, divine = false },
        [473] = { name = "Refresh II", category = 'track_refresh', equip = "refresh_set", aoe = false, majesty = false, accession = false, divine = false },
        [894] = { name = "Refresh III", category = 'track_refresh', equip = "refresh_set", aoe = false, majesty = false, accession = false, divine = false },
    }

    -- Tracked job abilities, keyed by ability id and read the same way as spell_info. The
    -- majesty and divine flags are absent, since no ability has an equivalent. accession is
    -- carried on every row and read by nothing.
    --
    -- Some cancel paths depend on what this table holds. An announced action leaves other
    -- characters holding slots until a completion arrives, and these paths cancel an action
    -- without sending one: the ON-Locked refusal in the precast hook, and the ammunition
    -- cancels for no round named, none carried, and too few carried. They are safe because
    -- nothing they cancel is tracked: Tomahawk, Angon, ranged attacks, ranged weapon skills
    -- and Bounty Shot. A tracked entry for any of those would leave the other characters
    -- holding gear until their own failsafe expires.
    local ability_info                        = {
        [190] = { name = "Curing Waltz", category = 'track_waltz', equip = "waltz_set", aoe = false, accession = false },
        [191] = { name = "Curing Waltz II", category = 'track_waltz', equip = "waltz_set", aoe = false, accession = false },
        [192] = { name = "Curing Waltz III", category = 'track_waltz', equip = "waltz_set", aoe = false, accession = false },
        [193] = { name = "Curing Waltz IV", category = 'track_waltz', equip = "waltz_set", aoe = false, accession = false },
        [311] = { name = "Curing Waltz V", category = 'track_waltz', equip = "waltz_set", aoe = false, accession = false },
        [195] = { name = "Divine Waltz", category = 'track_waltz', equip = "waltz_set", aoe = true, accession = false },
        [262] = { name = "Divine Waltz II", category = 'track_waltz', equip = "waltz_set", aoe = true, accession = false },
    }

    -- The os.clock time an outstanding announce expires. Past it E.outgoing_cast_active is
    -- stale, and outgoing_cast_busy clears it at the next read rather than on a timer.
    local outgoing_cast_deadline              = 0

    -- Scratch list for the party scan below, reused so a scan costs no table.
    local NEARBY_MEMBERS_BUFFER               = {}

    ------------------------------------------------------------------------------------------------
    -- SECTION 11 - CORE UTILITIES
    ------------------------------------------------------------------------------------------------
    -- The shared helpers: the chat channels, the clock, the cast-time estimate and the busy
    -- window's limit, the announce that tells the other characters a cast is on its way, the
    -- buff prediction, the questions the engine asks about the party, the stratagem charges
    -- and carried gear, and the elemental bonus chooser.

    -- Chat output ---------------------------------------------------------------------------------

    -- Join the arguments into one string, converting each with tostring. A single argument
    -- is returned untouched, so a string is not rebuilt and a table or nil reaches print as
    -- it is.
    local function join(...)
        if select('#', ...) < 2 then return (...) end
        local parts = {}
        for i = 1, select('#', ...) do parts[i] = tostring((select(i, ...))) end
        return table.concat(parts)
    end

    -- The everyday channels, each with its own chat mode. log traces the engine's work for a
    -- maintainer and is gated by the debug setting. info is ordinary feedback and warn is a
    -- problem the player should act on, and each has a toggle of its own.
    --
    -- A chat mode belongs to its channel. Writing 8, 80, 121, 123, 207 or 221 into a raw
    -- add_to_chat anywhere else goes around the channel that owns it. The confirmation for
    -- switching a channel off cannot go out on the channel it just silenced, and notice, the
    -- one channel with no toggle, exists for that.
    function log(...)
        if settings.debug then print(80, join(...)) end
    end

    function info(...)
        if settings.info then print(8, join(...)) end
    end

    function warn(...)
        if settings.warn then print(123, join(...)) end
    end

    -- Mode changes, setting confirmations, and the answer to a command that asked a question.
    -- It is the one channel with no gate, because a command the player just typed must be
    -- answered whatever the toggles say.
    function notice(...)
        print(221, join(...))
    end

    -- The set-selection trace: which set was tried, which was merged and which was missing.
    -- It is off by default and turned on with gs c gearreporting. equip.lua is the only
    -- caller, and it reports every phase, where warn and info speak only for the phase that
    -- chose the gear.
    function gear_report(...)
        if settings.gear_reporting then print(207, join(...)) end
    end

    -- The writer under the channels above. It takes a chat mode and a value, writes the
    -- value by its type, and walks a table one entry per line, four levels deep. Long lines
    -- are not wrapped here. The game breaks them itself, wherever they fall.
    --
    -- This replaces Lua's print. GearSwap gives the job file and every file it includes one
    -- shared environment, so the job file gets this print too. It reads its first argument
    -- as a chat mode, so a bare print(value) sends 'Value is Nil' with the value as the
    -- mode, and a debugging print does not behave the way Lua's would.
    function print(mode, msg)
        if msg == nil then
            windower.add_to_chat(mode, 'Value is Nil')
        elseif type(msg) == "table" then
            for index, value in pairs(msg) do
                if type(value) == "table" then
                    for index2, value2 in pairs(value) do
                        if type(value2) == "table" then
                            for index3, value3 in pairs(value2) do
                                if type(value3) == "table" then
                                    for index4, value4 in pairs(value3) do
                                        windower.add_to_chat(mode,
                                            '---- [' ..
                                            tostring(index) ..
                                            '] [' ..
                                            tostring(index2) ..
                                            '] [' ..
                                            tostring(index3) .. '] [' ..
                                            tostring(index4) .. '] ' .. tostring(value4) .. ' ----')
                                    end
                                else
                                    windower.add_to_chat(mode,
                                        '---- [' ..
                                        tostring(index) ..
                                        '] [' ..
                                        tostring(index2) .. '] [' .. tostring(index3) .. '] ' ..
                                        tostring(value3) .. ' ----')
                                end
                            end
                        else
                            windower.add_to_chat(mode,
                                '---- [' .. tostring(index) .. '] [' .. tostring(index2) ..
                                '] ' .. tostring(value2) .. ' ----')
                        end
                    end
                else
                    windower.add_to_chat(mode, '---- [' .. tostring(index) .. '] ' .. tostring(value) .. ' ----')
                end
            end
        elseif type(msg) == "number" then
            windower.add_to_chat(mode, tostring(msg))
        elseif type(msg) == "string" then
            windower.add_to_chat(mode, msg)
        elseif type(msg) == "boolean" then
            windower.add_to_chat(mode, tostring(msg))
        else
            windower.add_to_chat(mode, 'Unknown Message')
        end
    end

    -- The debug channel. It takes one string, already built, not varargs. Lua builds that
    -- string before the call, so each caller wraps its site in `if settings.debug then`. The
    -- gate inside stops the printing, never the concatenation. This local shadows Lua's
    -- debug table from here to the end of the constructor.
    local function debug(message)
        if not settings.debug then return end
        windower.add_to_chat(121, "[Rahvin Debug] " .. message)
    end

    -- General helpers -----------------------------------------------------------------------------

    -- Wall clock in whole milliseconds. Its timestamps are compared across game clients over
    -- IPC, and os.clock counts from each process's own start, so it reads socket instead. A
    -- deadline no other client reads stays on os.clock.
    local function get_time()
        return math.floor(socket.gettime() * 1000)
    end

    -- How long a spell takes to cast, in seconds, as the engine estimates it: a fifth of its
    -- listed cast time, which assumes 80% fast cast. Under Chainspell or Nightingale a cast
    -- finishes in about a second whatever its listed time, so the estimate is one second. The
    -- burst prediction reads it, and so does the re-dress record for the cast's predicted
    -- landing. Only a type in RecastTimers may ask, because only those types carry a spell's
    -- id.
    local function expected_cast_seconds(spell)
        if buffactive['Chainspell'] or buffactive['Nightingale'] then return 1 end
        return res.spells[spell.id].cast_time * .2
    end

    -- How long GearSwap keeps a command whose end never arrives, in seconds. Its registry
    -- drops the command at this age, calls no aftercast for it, and stops reporting it in
    -- flight. The busy window stands this long for an action whose end is lost.
    --
    -- A spell, or an item whose resource row lists a use time, is kept its listed time
    -- x 1.1 + 2 seconds, whatever Nightingale or Chainspell does to the cast. A pet command
    -- is kept 5 seconds. Anything else is kept what GearSwap's own table gives its action
    -- type, a ranged shot 10 seconds and a job ability or weaponskill 3, and 3 when the table
    -- names none. A job file's precast delay is added, as GearSwap adds it. These are the
    -- figures GearSwap's registry sweep uses. The sweep compares them with an age in whole
    -- seconds, so the limit is rounded up to the whole second at which the sweep drops the
    -- command. Until then the action can still end, and the window stands.
    local function lost_end_seconds(spell, delay)
        local limit
        if spell.cast_time then
            limit = spell.cast_time * 1.1 + 2
        elseif spell.prefix == '/pet' then
            limit = 5
        else
            local ages = type(gearswap) == 'table' and gearswap.delay_map_to_action_type
            limit = type(ages) == 'table' and ages[spell.action_type] or 3
        end
        return math.ceil(limit + (delay or 0))
    end

    -- Spell-received announces -------------------------------------------------------------------

    -- Send the completion an announce owes its receivers, and clear the flag. Receivers
    -- equip and hold slots as soon as the announce arrives. Without the completion, they
    -- wear the received gear until their own failsafe expires. A second call does nothing,
    -- so a path that cannot tell whether the completion went out may call it again.
    local function finish_outgoing_cast()
        if not E.outgoing_cast_active then return end
        E.outgoing_cast_active = false
        send_ipc(string.format("RAHVIN|COMPLETE|%s|%.0f", player.name, get_time()))
    end

    -- Whether an announce is still outstanding. builders.lua asks at precast and announces
    -- only when none is, so a cast already announced at pretarget is not announced twice. A
    -- flag past its deadline is stale and is cleared here, when asked, rather than by a timer.
    local function outgoing_cast_busy()
        if not E.outgoing_cast_active then return false end
        if os.clock() < outgoing_cast_deadline then return true end
        E.outgoing_cast_active = false
        return false
    end

    -- Table, number and gear-set helpers ----------------------------------------------------------

    -- Count the entries at the top level of a table, including the string keys the length
    -- operator cannot see. spellreceived.lua uses it to report how many casters it is
    -- tracking.
    local function count_keys(tbl)
        local count = 0
        for _ in pairs(tbl) do
            count = count + 1
        end
        return count
    end

    -- Party and target helpers --------------------------------------------------------------------

    -- Whether the named character is in this player's party now. It walks p0 to p5 only, so
    -- an alliance member outside the party answers false, which both callers want. No
    -- tracked spell reaches past the party, and neither does a Corsair roll, which the
    -- spell-received component's eleven tracker asks about.
    local function is_target_in_party(target_name, party_info)
        if not target_name then return false end

        if not party_info then return false end

        for i = 0, 5 do
            local member = party_info['p' .. i]
            if member and member.name == target_name then
                return true
            end
        end

        return false
    end

    -- Turn one target name into the comma-separated list of party members the spell will
    -- reach, so each receiver can find itself in the announce. Returns the name unchanged
    -- when the target is outside the party or nobody is in range, because an announce
    -- naming nobody would leave the real target undressed.
    local function resolve_aoe_target_name(target_mob, target_name)
        local party = get_party()
        if not (party and is_target_in_party(target_name, party)) then
            return target_name
        end

        local count = 0
        for k in pairs(NEARBY_MEMBERS_BUFFER) do NEARBY_MEMBERS_BUFFER[k] = nil end

        -- Every tracked area spell reaches the party only, so only p0 to p5 can receive one.
        -- get_party also returns the alliance entries a10 to a25, and walking them would
        -- name characters the spell cannot reach.
        for i = 0, 5 do
            local member = party['p' .. i]
            if member and member.name then
                -- Each party entry already carries its member's mob table, so the position
                -- test below needs no second lookup.
                local m_mob = member.mob
                if m_mob then
                    local dx = m_mob.x - target_mob.x
                    local dy = m_mob.y - target_mob.y
                    local dz = m_mob.z - target_mob.z
                    -- 100 is 10 yalms squared. Comparing squared distances answers the same
                    -- question as a radius test without the square root.
                    if ((dx * dx) + (dy * dy) + (dz * dz)) <= 100 then
                        if settings.debug then debug(member.name .. " is WITHIN 10 yalms of " .. target_mob.name) end
                        count = count + 1
                        NEARBY_MEMBERS_BUFFER[count] = member.name
                    else
                        if settings.debug then debug(member.name .. " is OUT of aoe range from " .. target_mob.name) end
                    end
                else
                    if settings.debug then debug(member.name .. " data unavailable (Too far away).") end
                end
            end
        end

        if count > 0 then
            return table.concat(NEARBY_MEMBERS_BUFFER, ",")
        end
        return target_name
    end

    -- Tell the other characters a tracked action is on its way, and arm the completion this
    -- character now owes them. The caller has already decided that the action is tracked and
    -- whether it spreads. The name expansion, the send and the debug trace of what went out
    -- happen here.
    --
    -- Two phases call it. hooks.lua calls it at pretarget, the earliest point a target is
    -- known, and builders.lua at precast for an action that did not announce there. The
    -- precast site asks outgoing_cast_busy first, so it never repeats an announce already
    -- sent. The deadline uses os.clock because only this file reads it. The timestamp in the
    -- message uses get_time because the receivers read it.
    local function announce_tracked_cast(kind, phase, spell, target_name, aoe)
        E.outgoing_cast_active = true
        outgoing_cast_deadline = os.clock() + settings.delay

        local noun = (kind == 'ABILITY') and 'ability' or 'spell'
        if settings.debug then
            debug(player.name .. ' is using tracked ' .. noun .. ' measured at ' .. phase ..
                ': ' .. spell.name .. ' on ' .. target_name .. ' at ' .. get_time())
        end

        if aoe then
            if settings.debug then debug('AoE ' .. noun .. ' cast detected. Calculating targets.') end
            -- The mob table is fetched only on this branch. A single-target announce carries
            -- the name it was given and needs no position.
            local target_mob = get_mob_by_id(spell.target.id)
            if target_mob then target_name = resolve_aoe_target_name(target_mob, target_name) end
        end

        local message = string.format('RAHVIN|%s|%s|%s|%s|%.0f', kind, player.name,
            target_name, spell.id, get_time())
        if settings.debug then debug('IPC message sent: ' .. message) end
        send_ipc(message)
    end

    -- The buff prediction -------------------------------------------------------------------------

    -- GearSwap lists a buff a moment after the result that gives it, and an action sent in
    -- that gap reads a list without it. A prediction writes the buff into GearSwap's own list,
    -- buffactive, from that result until the real buff arrives: its lowercased English name and
    -- its id, the two keys GearSwap lists a buff under, wherever the list lacks them. GearSwap
    -- rebuilds the list from the game's own before most of its events, so the engine writes the
    -- predictions again as the first act of every hook it runs for an action, a buff, a status,
    -- a pet or a command, and of the idle and engaged build. Those hooks, and the job file's
    -- hooks each of them calls, then read the predictions. Inside the raw action event, the
    -- burst checks that read a Blue Mage's affinity or a Scholar's Immanence off this
    -- character's own list write them just before that read. Any other raw event handler
    -- that reads the list, and the job file's Cycle_Timer, reads it as GearSwap left it.
    --
    -- A prediction starts from a result: this character's own job ability that reaches it, or
    -- this character's entry in another player's spell or ability. A buff the list already
    -- holds is never predicted. A prediction ends when Windower reports the buff gained or
    -- lost, when this character's next spell, shot or weaponskill ends, at a zone change, for a
    -- roll at the bust that takes it away, or BUFF_PREDICTION_SECONDS after its result. The
    -- deadline is checked at each write, never on a timer, and a prediction that reaches it
    -- prints one info line. Every end but the buff's arrival takes the written entries back out
    -- of the list, unless the game's own list holds the buff.

    -- The standing predictions, by the buff's lowercased English name, and how many. Every
    -- write site reads n first and does nothing more while it is zero. The table is never
    -- replaced, so each component binds it once.
    local buff_prediction = { n = 0, by_name = {} }

    -- Every id each lowercased English buff name carries, built the first time a name is
    -- looked up.
    local buff_ids_by_name

    -- The ids a lowercased buff name carries, or nil for a name no buff carries.
    local function buff_ids_of(name)
        if not buff_ids_by_name then
            buff_ids_by_name = {}
            for id, row in pairs(res.buffs) do
                if type(row) == 'table' and row.en then
                    local key = row.en:lower()
                    local ids = buff_ids_by_name[key]
                    if not ids then
                        ids = {}
                        buff_ids_by_name[key] = ids
                    end
                    ids[#ids + 1] = id
                end
            end
        end
        return buff_ids_by_name[name]
    end

    -- Whether the game's own list holds a buff of the prediction's name. GearSwap keeps that
    -- list in player.buffs, ids only, and no prediction is ever written there.
    local function buff_held(rec)
        local held, all = player.buffs, rec.all
        if not held then return false end
        for _, id in pairs(held) do
            for i = 1, #all do
                if all[i] == id then return true end
            end
        end
        return false
    end

    -- Write one prediction into GearSwap's list: its name and each of its ids, wherever the
    -- list lacks one. An entry the list holds is left as GearSwap counted it.
    local function write_prediction(rec)
        if buffactive[rec.name] == nil then buffactive[rec.name] = 1 end
        local ids = rec.ids
        for i = 1, #ids do
            if buffactive[ids[i]] == nil then buffactive[ids[i]] = 1 end
        end
    end

    -- End one prediction. unwrite takes its entries back out of GearSwap's list, unless the
    -- game's own list holds the buff, so no reader finds a prediction that has ended. The
    -- buff's arrival leaves them, since GearSwap lists the buff itself from then on.
    local function drop_prediction(rec, unwrite)
        local by_name = buff_prediction.by_name
        if by_name[rec.name] ~= rec then return end
        by_name[rec.name] = nil
        buff_prediction.n = buff_prediction.n - 1
        if unwrite and not buff_held(rec) then
            buffactive[rec.name] = nil
            local ids = rec.ids
            for i = 1, #ids do buffactive[ids[i]] = nil end
        end
    end

    -- Start a prediction, unless GearSwap's list holds the buff's name already or a prediction
    -- of it stands. Given id, the buff a result names, it writes that id and the buff's name.
    -- Given a name instead, a buff named by its ability, lowercased, it writes the name and
    -- every id the name carries, since the result does not say which one the game will list.
    -- from names the action, for the line a lapse prints. The prediction is written at once,
    -- so the rest of the event that starts it reads it.
    local function predict_buff(id, name, from)
        local ids
        if id then
            local row = res.buffs[id]
            if not (row and row.en) then return end
            name, ids = row.en:lower(), { id }
        else
            ids = name and buff_ids_of(name)
            if not ids then return end
        end
        if buffactive[name] ~= nil or buff_prediction.by_name[name] then return end
        local all = buff_ids_of(name)
        local rec = { name = name, ids = ids, all = all, label = res.buffs[all[1]].en, from = from,
            ends = os.clock() + BUFF_PREDICTION_SECONDS, ending = false }
        buff_prediction.by_name[name] = rec
        buff_prediction.n = buff_prediction.n + 1
        write_prediction(rec)
        log('Predicting ', rec.label, ' from ', tostring(from), ' until the buff list shows it')
    end

    -- Write every standing prediction into GearSwap's list. One past its deadline ends here
    -- instead and prints its line. at_hook is true when GearSwap called the engine for this
    -- event. Then a prediction an action's end has marked ends here with no info line, since
    -- the raw action event of that end has passed or is not coming. The burst checks inside
    -- the raw action event pass false, because the result they read may be the one that
    -- ends the prediction. Assigning nil to an existing key during a pairs walk is defined in
    -- Lua 5.1, so an ended prediction is dropped where it is found.
    local function write_buff_predictions(at_hook)
        local now = os.clock()
        for _, rec in pairs(buff_prediction.by_name) do
            if at_hook and rec.ending then
                drop_prediction(rec, true)
                log('Prediction of ', rec.label, ' ended with your action')
            elseif now >= rec.ends then
                drop_prediction(rec, true)
                info('[' .. tostring(rec.from) .. '] ' .. rec.label .. ' did not reach your buff list within '
                    .. BUFF_PREDICTION_SECONDS .. ' s of its result: no longer predicted.')
            else
                write_prediction(rec)
            end
        end
    end

    -- Windower reported a buff gained or lost, so the prediction of that buff's name ends. A
    -- gain leaves the written entries, which GearSwap's list now backs.
    local function end_buff_prediction(id, gained)
        local row = res.buffs[id]
        local rec = row and row.en and buff_prediction.by_name[row.en:lower()]
        if not rec then return end
        drop_prediction(rec, not gained)
        log('Prediction of ', rec.label, gained and ' ended: the buff arrived' or ' ended: the buff was lost')
    end

    -- This character's spell, shot or weaponskill ended, at its aftercast, and every standing
    -- prediction ends with it. GearSwap's aftercast runs ahead of the raw action event of the
    -- same result, so each is only marked here, and the raw handler, which reads the list for
    -- that result, ends it after its reads.
    local function mark_buff_predictions_ending()
        for _, rec in pairs(buff_prediction.by_name) do rec.ending = true end
    end

    -- At the raw action event of this character's own result, the predictions its aftercast
    -- marked end, as any other end does.
    local function end_ending_buff_predictions()
        for _, rec in pairs(buff_prediction.by_name) do
            if rec.ending then drop_prediction(rec, true) end
        end
    end

    -- A zone change ends every prediction.
    local function end_all_buff_predictions()
        for _, rec in pairs(buff_prediction.by_name) do drop_prediction(rec, true) end
    end

    -- Whether a set keyed by a buff, or picked on it by the engine, is dressed on a
    -- prediction: one of the buff's name stands and the game's own list does not hold it. buff
    -- is a name in any casing or an id. The report asks only while a prediction stands.
    local function buff_shown_predicted(buff)
        local name = buff
        if type(buff) == 'number' then
            local row = res.buffs[buff]
            name = row and row.en
        end
        if type(name) ~= 'string' then return false end
        local rec = buff_prediction.by_name[name:lower()]
        return rec ~= nil and not buff_held(rec)
    end

    -- The buff a job ability's result gives. First the buff the result's number names, when
    -- that buff is the ability's own: named like the ability, or the one the ability's
    -- resource row lists. Otherwise, unless by_number, a buff named like the ability, by its
    -- lowercased name, since the result does not say which id. Otherwise the row's buff.
    -- Returns the id, or nil and the name, or nil alone.
    local function ability_buff(ability_id, number, by_number)
        local row = res.job_abilities[ability_id]
        if not (row and row.en) then return nil end
        local named = number and res.buffs[number]
        if named and named.en and (named.en:lower() == row.en:lower() or row.status == number) then
            return number
        end
        if by_number then return nil end
        local name = row.en:lower()
        if buff_ids_of(name) then return nil, name end
        if row.status and res.buffs[row.status] then return row.status end
        return nil
    end

    -- Start or end a prediction from a spell's or a job ability's result, handed over by the
    -- raw action event. A bust that takes a roll from this character ends that roll's
    -- prediction. On this character's own job ability, its own entry carrying the game's line
    -- for an ability used or for a roll received starts one for the buff ability_buff names.
    -- When the ability was aimed at this character, its aftercast has already predicted any
    -- buff the result's number names. On another player's spell or ability, this character's
    -- entry giving a buff by its number, or a roll by the ability, starts one. Only a player's
    -- action starts one, never a monster's, a pet's or a trust's, and the actor is looked up
    -- only once this character's entry gives a buff.
    local function predict_from_action(data)
        local me = player.id
        local targets = data.targets
        local entry
        for i = 1, #targets do
            if targets[i].id == me then
                entry = targets[i]
                break
            end
        end
        local action = entry and entry.actions and entry.actions[1]
        if not action then return end
        local message = action.message
        local actor, category = data.actor_id, data.category
        -- A bust takes the roll away from this character, and a roll the game never listed sends
        -- no loss, so the roll's prediction ends here, at once and with no info line, whoever
        -- busted.
        if category == 6 and message == ROLL_BUST_MESSAGE then
            local id, name = ability_buff(data.param, nil)
            local row = id and res.buffs[id]
            local rec = buff_prediction.by_name[row and row.en and row.en:lower() or name or '']
            if rec then
                drop_prediction(rec, true)
                log('Prediction of ', rec.label, ' ended: the roll busted')
            end
            return
        end
        if actor == me then
            if category == 4 or not (message == ABILITY_USED_MESSAGE or ROLL_GAIN_MESSAGE[message]) then return end
            local id, name = ability_buff(data.param, action.param)
            if id or name then predict_buff(id, name, res.job_abilities[data.param].en) end
            return
        end
        local id, name
        if BUFF_GAIN_MESSAGE[message] then
            id = action.param
            if not res.buffs[id] then return end
        elseif category ~= 4 and ROLL_GAIN_MESSAGE[message] then
            id, name = ability_buff(data.param, action.param)
            if not (id or name) then return end
        else
            return
        end
        local mob = get_mob_by_id(actor)
        if not mob or mob.is_npc then return end
        local row = category == 4 and res.spells[data.param] or res.job_abilities[data.param]
        predict_buff(id, name, row and row.en)
    end

    -- Recast helpers ------------------------------------------------------------------------------

    -- How many Scholar stratagem charges are in hand, and how many seconds until the next one
    -- returns. hooks.lua refuses a stratagem at zero charges and names the wait.
    --
    -- The second value is nil in two different cases: a full pool, and a character with no
    -- stratagems at all. A caller must test it before formatting it, and can tell the two
    -- cases apart by the first value.
    local function get_current_stratagem_count()
        -- Recast id 231 is the stratagem charge pool. A missing key is not a zero. The recast
        -- table omits abilities this character cannot use, so a missing key means no
        -- stratagems at all, while a zero means the pool is full.
        local charge_cooldown = windower.ffxi.get_ability_recasts()[231]
        if charge_cooldown == nil then return 0 end

        -- Pool size and regen period by Scholar level, main or sub. Every bracket multiplies
        -- out to the same 240 second pool: 1 x 240, 2 x 120, 3 x 80, 4 x 60 and 5 x 48.
        local max_charges = 1
        local charge_regen_time = 240

        local sch_level = 0
        if player.main_job == 'SCH' then
            sch_level = player.main_job_level
        elseif player.sub_job == 'SCH' then
            sch_level = player.sub_job_level
        end

        if sch_level >= 90 then
            max_charges = 5
            charge_regen_time = 48
        elseif sch_level >= 70 then
            max_charges = 4
            charge_regen_time = 60
        elseif sch_level >= 50 then
            max_charges = 3
            charge_regen_time = 80
        elseif sch_level >= 30 then
            max_charges = 2
            charge_regen_time = 120
        elseif sch_level >= 10 then
            max_charges = 1
            charge_regen_time = 240
        end

        -- The one exception. With 550 job points spent, a main Scholar regains a charge
        -- every 33 seconds, so its pool is 5 x 33 = 165 seconds, not 240. Job point bonuses
        -- belong to the main job, so a Scholar sub job never earns this, which is why the
        -- test reads main_job rather than sch_level.
        if player.main_job == 'SCH' and player.main_job_level >= 99 then
            local jp = player.job_points and player.job_points.sch
            if jp and (jp.jp_spent or 0) >= 550 then
                charge_regen_time = 33
            end
        end

        -- The raw recast beside the bracket it resolved to, because a wrong charge count is
        -- almost always a wrong bracket rather than a wrong reading.
        if settings.debug then
            debug('stratagem recast=' .. tostring(charge_cooldown) .. ' lvl=' .. tostring(sch_level)
                .. ' max=' .. tostring(max_charges) .. ' regen=' .. tostring(charge_regen_time))
        end

        if charge_cooldown == 0 then return max_charges end

        local full_recharge_window = max_charges * charge_regen_time
        local current_charges = math.floor((full_recharge_window - charge_cooldown) / charge_regen_time)

        -- Charges come back one regen period apart, so the remainder past the last whole
        -- period is the wait for the next one.
        return math.max(0, current_charges), charge_cooldown % charge_regen_time
    end

    -- Carried gear --------------------------------------------------------------------------------

    -- The bags gear can be equipped from. GearSwap presents each as a table of the player's
    -- items keyed by item name. The safe, storage, satchel, sack and case are not listed, so
    -- an item sitting in one answers no to both questions below.
    local CARRY_BAGS = {
        'inventory', 'wardrobe', 'wardrobe2', 'wardrobe3', 'wardrobe4',
        'wardrobe5', 'wardrobe6', 'wardrobe7', 'wardrobe8',
    }

    -- Whether this item is carried in any bag gear can be equipped from. It stops at the
    -- first bag holding the item, and returns nil rather than false when none does. The
    -- builders ask it before equipping a piece the job file did not name, and the slot holds
    -- and the enchanted item engine ask it before relying on an item.
    local function have_item(name)
        for i = 1, #CARRY_BAGS do
            local bag = player[CARRY_BAGS[i]]
            if bag and bag[name] then return true end
        end
    end

    -- The main job's level as the level test in GearSwap's unpack_equip_list reads it: the
    -- job's real level from player.jobs, never the synced one. main_job_level is the fallback
    -- when that table is absent. Both wearability tests below read the level here.
    local function main_job_level()
        return (player.jobs and player.jobs[player.main_job]) or player.main_job_level
    end

    -- Why this item cannot be worn now, phrased for the player, or nil when it can be. It
    -- takes a resource row rather than a name, because job, level, race and slots all live
    -- there. It mirrors GearSwap's four drop tests, so the engine can refuse with a reason
    -- instead of sending an equip that quietly does nothing.
    local function unwearable_reason(row)
        local job_level = main_job_level()
        if row.jobs and not row.jobs[player.main_job_id] then
            return row.en .. ' cannot be worn by this job.'
        elseif row.level and job_level and row.level > job_level then
            return ('%s requires level %d; your %s is %d.'):format(
                row.en, row.level, tostring(player.main_job), job_level)
        elseif row.races and not row.races[player.race_id] then
            return row.en .. ' cannot be worn by your race.'
        elseif not row.slots then
            return row.en .. ' cannot be worn.'
        end
    end

    -- How many of the item are carried, summed across every bag, so unlike have_item it
    -- cannot stop at the first hit. builders.lua counts ammunition with it, where a stack in
    -- one wardrobe and a stack in another are one supply.
    local function have_item_count(name)
        local total = 0
        for i = 1, #CARRY_BAGS do
            local bag = player[CARRY_BAGS[i]]
            local entry = bag and bag[name]
            if entry then total = total + entry.count end
        end
        return total
    end

    -- Elemental bonus gear ------------------------------------------------------------------------
    -- Which of the day, weather and distance pieces a cast should wear, computed from the
    -- mechanics in section 8's tables. Each candidate's expected multiplier on the cast's
    -- output is scored, and the best carried, wearable one is worn. builders.lua's
    -- elemental_check computes the cast's inputs and calls elemental_choose. The functions
    -- above elemental_choose are its arithmetic and its wearability test.

    -- The expected day-and-weather term of one cast, in percent, for one choice of which
    -- procs are forced. sd and sw are the day's and the weather's sign for the spell's
    -- element: 1 matching, -1 penalizing and 0 neither. wmag is the weather term for its
    -- intensity, and irid is the main's Iridescence, which rides the weather proc and its
    -- sign. force_day and force_wx say whether an obi forces those procs, penalties
    -- included. A helix forces them itself. cape says whether Twilight Cape is worn. Its +5
    -- arrives on any matching proc: certainly when one is forced, and otherwise with the
    -- chance that not every matching event misses. ring says whether Zodiac Ring is worn,
    -- and its +3 needs no proc. An unforced proc counts at its one-in-three chance.
    --
    -- The cap applies to the expected value rather than to each proc outcome. That can
    -- overstate an unforced total by at most two points, and only for a candidate without
    -- an obi, which an obi already beats by nineteen points.
    local function elemental_dw(sd, sw, wmag, irid, force_day, force_wx, cape, ring)
        local dw = sd * DAY_PCT * (force_day and 1 or PROC)
            + sw * (wmag + irid) * (force_wx and 1 or PROC)
        if ring then dw = dw + RING_PCT end
        if cape then
            if (force_day and sd == 1) or (force_wx and sw == 1) then
                dw = dw + CAPE_PCT
            else
                local miss = 1
                if sd == 1 then miss = miss * (1 - PROC) end
                if sw == 1 then miss = miss * (1 - PROC) end
                dw = dw + CAPE_PCT * (1 - miss)
            end
        end
        if dw > CAP_PCT then dw = CAP_PCT end
        return dw
    end

    -- A candidate's gain over the bare cast, in percent of output. Its day-and-weather term
    -- and its affinity multiply, (100 + dw) x (100 + aff) / 100, and the result is measured
    -- against 100 plus the bare cast's own term. It is negative only for an obi that forces
    -- a penalty the cast would otherwise only risk.
    local function elemental_gain(base, sd, sw, wmag, irid, force_day, force_wx, cape, aff)
        return (100 + elemental_dw(sd, sw, wmag, irid, force_day, force_wx, cape, false))
            * (100 + aff) / 100 - 100 - base
    end

    -- The best waist-and-cape pair still possible, from the seven scores: Hachirin, the
    -- spell's own obi and the sash, each alone and with the cape, and the cape alone. A nil
    -- score is a pair ruled out, either ineligible or holding a piece the bags refused.
    -- Returns the waist, whether the cape is in the pair, and the pair's score. The waist is
    -- 1 for Hachirin, 2 for the spell's obi, 3 for the sash, or nil for none. When nothing
    -- beats the baseline it returns nil, false, 0.
    --
    -- The order decides ties. Hachirin comes before the spell's obi, because it is far more
    -- likely to be carried, and the single obi wins outright whenever a penalty exists.
    -- Either obi comes before the sash, for the magic accuracy a forced proc carries. Each
    -- waist without the cape comes before the same waist with it, so a cape that adds
    -- nothing at the cap is not swapped in. The cape alone wins a tie against any pair. A
    -- pair can tie it only when its waist adds nothing, and then the cape alone is the same
    -- gain with one swap fewer.
    local function elemental_pick(sH, sHC, sS, sSC, sO, sOC, sNC)
        local w, c, s = nil, false, 0
        if sH and sH > s then w, c, s = 1, false, sH end
        if sHC and sHC > s then w, c, s = 1, true, sHC end
        if sS and sS > s then w, c, s = 2, false, sS end
        if sSC and sSC > s then w, c, s = 2, true, sSC end
        if sO and sO > s then w, c, s = 3, false, sO end
        if sOC and sOC > s then w, c, s = 3, true, sOC end
        if sNC and sNC > 0 and sNC >= s then w, c, s = nil, true, sNC end
        return w, c, s
    end

    -- Whether the main job can wear this candidate, by the first two drop tests in GearSwap's
    -- unpack_equip_list: the job mask and the job's level. A piece GearSwap would drop never
    -- displaces the job file's own. Unlike unwearable_reason it builds no message, since it
    -- runs on every elemental cast and weapon skill, and the cape fails the job mask on most
    -- melee jobs.
    local function candidate_wearable(name)
        local row = CANDIDATE_ROW[name]
        local job_level = main_job_level()
        return row.jobs[player.main_job_id] ~= nil and not (job_level and row.level > job_level)
    end

    -- Wearable, and then carried: the bags are asked only for a piece the job could wear.
    local function candidate_carried(name)
        return candidate_wearable(name) and have_item(name) == true
    end

    -- Choose the elemental bonus pieces for one cast: the waist from the spell's own obi,
    -- Hachirin-no-Obi and Orpheus's Sash, Twilight Cape together with it, and then Zodiac
    -- Ring. Every candidate is scored as if carried. The pairs that beat the baseline are
    -- then tried best first, and a pair is taken once each of its pieces is carried and
    -- wearable. So the bags are asked at most once per piece, and never for a piece that
    -- could not win. A piece the bags refuse rules out every pair holding it, and the walk
    -- moves to the runner-up.
    --
    -- kind is 'magic', 'helix', 'cure' or 'cura'. A helix forces its own procs, so no obi
    -- can add to it, and only the sash, the cape and the ring can. A cure takes no sash. A
    -- single-target cure, 'cure', takes no cape either and keeps the job file's own back,
    -- while Cura and Curaga, 'cura', take the cape.
    --
    -- eid is the spell's element id and dayi the day's. sd, sw, wmag and irid are as
    -- elemental_dw takes them. sash is the sash's affinity in percent at the target's
    -- distance, nil or 0 when the distance is unknown. An unresolved subtarget must never
    -- throw here, since a throw ends the midcast hook. ring_ok says whether the spell's skill
    -- admits the ring, and it is false for a held ring too. hold_waist and hold_back say the
    -- slot holds a piece Bonus_Keep lists, so no candidate is scored for it. A held waist
    -- leaves the cape scored alone, and a held back leaves no pair.
    --
    -- Returns the waist name or nil with its expected gain in percent, then the same two
    -- values for the back and for the right ring.
    local function elemental_choose(kind, eid, dayi, sd, sw, wmag, irid, sash, ring_ok,
                                    hold_waist, hold_back)
        local helix = kind == 'helix'
        local cure = kind == 'cure' or kind == 'cura'
        local single = (not helix and not hold_waist and (sd == 1 or sw == 1)) and SINGLE_OBI[eid] or nil
        local hachirin = not helix and not hold_waist and (sd ~= 0 or sw ~= 0)
        sash = sash or 0
        local sash_ok = not cure and not hold_waist and sash >= SASH_MIN_PCT
        -- The cape's wearability is settled here, before any pair is scored. On a job outside
        -- its mask no pair holds it, so no waist is asked for a pair that could never
        -- complete. The other candidates fit every job's mask, and each is tested when asked.
        local cape_ok = not hold_back and kind ~= 'cure' and (sd == 1 or sw == 1) and candidate_wearable(CAPE)

        -- The seven scores, nil where a pair is not eligible. The bare cast forces nothing,
        -- or everything for a helix.
        local base = elemental_dw(sd, sw, wmag, irid, helix, helix, false, false)
        local sH, sHC, sS, sSC, sO, sOC, sNC
        if hachirin then
            sH = elemental_gain(base, sd, sw, wmag, irid, true, true, false, 0)
            if cape_ok then sHC = elemental_gain(base, sd, sw, wmag, irid, true, true, true, 0) end
        end
        if single then
            sS = elemental_gain(base, sd, sw, wmag, irid, sd == 1, sw == 1, false, 0)
            if cape_ok then sSC = elemental_gain(base, sd, sw, wmag, irid, sd == 1, sw == 1, true, 0) end
        end
        if sash_ok then
            sO = elemental_gain(base, sd, sw, wmag, irid, helix, helix, false, sash)
            if cape_ok then sOC = elemental_gain(base, sd, sw, wmag, irid, helix, helix, true, sash) end
        end
        if cape_ok then sNC = elemental_gain(base, sd, sw, wmag, irid, helix, helix, true, 0) end

        -- Pick the best pair, ask the bags for its pieces, and walk on after a refusal. Each
        -- piece is asked once, and its own_ variable is nil until then. There are at most
        -- five picks: four refusals and the empty pick after them.
        local own_h, own_s, own_o, own_c
        local w, c, s
        while true do
            w, c, s = elemental_pick(sH, sHC, sS, sSC, sO, sOC, sNC)
            if not w and not c then break end
            local have = true
            if w == 1 then
                if own_h == nil then own_h = candidate_carried(HACHIRIN) end
                if not own_h then sH, sHC, have = nil, nil, false end
            elseif w == 2 then
                if own_s == nil then own_s = candidate_carried(single) end
                if not own_s then sS, sSC, have = nil, nil, false end
            elseif w == 3 then
                if own_o == nil then own_o = candidate_carried(SASH) end
                if not own_o then sO, sOC, have = nil, nil, false end
            end
            if have and c then
                if own_c == nil then own_c = have_item(CAPE) == true end
                if not own_c then sHC, sSC, sOC, sNC, have = nil, nil, nil, nil, false end
            end
            if have then break end
        end

        -- The waist's own gain is its score without the cape, and the cape's gain is what the
        -- pair adds to that. The chosen waist decides what the ring's gain is measured
        -- against. With no pair taken, the ring is measured against the bare cast, so a
        -- carried ring is still worn on its day when no obi or cape is.
        local waist, waist_gain, force_day, force_wx, aff = nil, 0, helix, helix, 0
        if w == 1 then
            waist, waist_gain, force_day, force_wx = HACHIRIN, sH, true, true
        elseif w == 2 then
            waist, waist_gain, force_day, force_wx = single, sS, sd == 1, sw == 1
        elseif w == 3 then
            waist, waist_gain, aff = SASH, sO, sash
        end
        local back, back_gain
        if c then back, back_gain = CAPE, s - waist_gain end

        -- The ring serves Elemental Magic on its matching day, never on Lightsday or
        -- Darksday, and only where its +3 fits under the cap on top of what is already worn.
        -- A helix qualifies, since its forced procs make no difference to a piece that needs
        -- none. A cure never can, since a Light spell's matching day is Lightsday.
        local ring, ring_gain
        if ring_ok and sd == 1 and dayi ~= LIGHT_ID and dayi ~= DARK_ID then
            ring_gain = (elemental_dw(sd, sw, wmag, irid, force_day, force_wx, c, true)
                - elemental_dw(sd, sw, wmag, irid, force_day, force_wx, c, false)) * (100 + aff) / 100
            if ring_gain > 0 and candidate_carried(RING) then
                ring = RING
            else
                ring_gain = nil
            end
        end
        return waist, waist and waist_gain or nil, back, back_gain, ring, ring_gain
    end


    -- The exports, for the components that load after this one. None of these fields is
    -- reassigned after construction. The one mutable field this file writes,
    -- E.outgoing_cast_active, is declared in state.lua and set by the functions above.
    E.config = config
    E.res = res
    E.extdata = extdata
    E.settings = settings
    -- The path and reason of a settings file that would not load, or nil when the load was
    -- clean. display.lua names both in the line it prints once the client has settled,
    -- names the path in every refused save, and writes nothing while the record stands.
    E.settings_refused = settings_refused
    -- The silos this load reset, and each silo's current version, for display.lua's reset
    -- announce.
    E.settings_reset = settings_reset
    E.settings_versions = SETTINGS_VERSIONS
    E.gs_status = gs_status
    E.gs_debug = gs_debug
    E.HasRecastTimer = HasRecastTimer
    E.RecastTimers = RecastTimers
    E.BUFF_SLEEP = BUFF_SLEEP
    E.BUFF_STUN = BUFF_STUN
    E.BUFF_KO = BUFF_KO
    E.BUFF_PETRI = BUFF_PETRI
    E.BUFF_CHARM = BUFF_CHARM
    E.BUFF_TERROR = BUFF_TERROR
    E.TYPE_JA = TYPE_JA
    E.TYPE_WS = TYPE_WS
    E.TYPE_MS = TYPE_MS
    E.TYPE_SCH = TYPE_SCH
    E.TaggingCategories = TaggingCategories
    E.DeathMessages = DeathMessages
    E.Storms = Storms
    E.UtsusemiSpell = UtsusemiSpell
    E.ENHANCING_FAMILY_SPELL = ENHANCING_FAMILY_SPELL
    E.RA_MODE_PHRASE = RA_MODE_PHRASE
    E.Divergence_Zones = Divergence_Zones
    E.Mage_Job = Mage_Job
    E.Cities = Cities
    E.Language = Language
    E.skillchains = skillchains
    E.BURST_WINDOW = BURST_WINDOW
    E.BURST_WINDOW_FLOOR = BURST_WINDOW_FLOOR
    E.HELIX_WINDOW_BONUS = HELIX_WINDOW_BONUS
    E.BURST_LANDING_LEAD = BURST_LANDING_LEAD
    E.BURST_ENDER_RESOURCE = BURST_ENDER_RESOURCE
    E.SKILL_MISS_MESSAGE = SKILL_MISS_MESSAGE
    E.HELIX_SPELL = HELIX_SPELL
    E.CHAIN_ELEMENT = CHAIN_ELEMENT
    E.SPELL_DAMAGE_MESSAGE = SPELL_DAMAGE_MESSAGE
    E.BLUE_AFFINITY_HOLD = BLUE_AFFINITY_HOLD
    E.CHAIN_AFFINITY_ID = CHAIN_AFFINITY_ID
    E.ABILITY_USED_MESSAGE = ABILITY_USED_MESSAGE
    E.BLUE_PHYSICAL = BLUE_PHYSICAL
    E.IMMANENCE_ID = IMMANENCE_ID
    E.IMMANENCE_HOLD = IMMANENCE_HOLD
    E.IMMANENCE_SPELL = IMMANENCE_SPELL
    E.BURST_REDRESS_GAP = BURST_REDRESS_GAP
    E.PRECAST_FINAL = PRECAST_FINAL
    E.PET_COMMAND_TYPES = PET_COMMAND_TYPES
    E.PET_JOBS = PET_JOBS
    E.SPIRITS = SPIRITS
    E.PET_MOVE_STALE = PET_MOVE_STALE
    E.PET_MOVE_COMMANDS = PET_MOVE_COMMANDS
    E.PET_COMMAND_WINDOW = PET_COMMAND_WINDOW
    E.PET_COMMAND_FAMILY = PET_COMMAND_FAMILY
    E.PET_COMMAND_FAMILY_BY_NAME = PET_COMMAND_FAMILY_BY_NAME
    E.CANON_SLOT = CANON_SLOT
    -- The elemental tables builders.lua reads for its per-cast inputs, the three ids its
    -- guards compare, and the sash's name, which its info line tests. NONE_ID marks the
    -- element-less spell, LIGHT_ID gates Quick Draw, and ELEMENTAL_MAGIC_SKILL admits the
    -- ring. The obi names, the candidate rows and the other constants stay private to the
    -- chooser, their only reader.
    E.ELEMENT_ID = ELEMENT_ID
    E.BEATS = BEATS
    E.SASH_PCT = SASH_PCT
    E.IRIDESCENCE = IRIDESCENCE
    E.WEATHER_PCT = WEATHER_PCT
    E.LIGHT_ID = LIGHT_ID
    E.NONE_ID = NONE_ID
    E.ELEMENTAL_MAGIC_SKILL = ELEMENTAL_MAGIC_SKILL
    E.SASH = SASH
    E.spell_info = spell_info
    E.ability_info = ability_info
    E.debug = debug
    E.get_time = get_time
    E.expected_cast_seconds = expected_cast_seconds
    E.lost_end_seconds = lost_end_seconds
    E.finish_outgoing_cast = finish_outgoing_cast
    E.outgoing_cast_busy = outgoing_cast_busy
    E.count_keys = count_keys
    E.is_target_in_party = is_target_in_party
    E.announce_tracked_cast = announce_tracked_cast
    E.get_current_stratagem_count = get_current_stratagem_count
    E.have_item = have_item
    E.unwearable_reason = unwearable_reason
    E.have_item_count = have_item_count
    E.elemental_choose = elemental_choose
    -- The buff prediction: its record, which every write site reads, the start and the write
    -- the hooks and the builders call, the exits, the report's question, the aftercast's
    -- lookup of the buff a job ability gives, and the result reader th.lua's action handler
    -- hands spells and abilities to.
    E.buff_prediction = buff_prediction
    E.predict_buff = predict_buff
    E.write_buff_predictions = write_buff_predictions
    E.end_buff_prediction = end_buff_prediction
    E.mark_buff_predictions_ending = mark_buff_predictions_ending
    E.end_ending_buff_predictions = end_ending_buff_predictions
    E.end_all_buff_predictions = end_all_buff_predictions
    E.buff_shown_predicted = buff_shown_predicted
    E.ability_buff = ability_buff
    E.predict_from_action = predict_from_action

    -- The version stamp. The root checks it against Rahvin_GS, so a stale copy of this file
    -- stops the load with an error that names it.
    return '2.2'
end
