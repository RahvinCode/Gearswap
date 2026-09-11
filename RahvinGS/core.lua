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
--   Section 7  - Libraries and settings .... the four libraries, the saved settings file,
--                                           and the two on-screen boxes
--   Section 8  - Shared constants .......... the lookup tables more than one subsystem reads
--   Section 9  - Spell and ability data .... which incoming action calls for which set
--   Section 11 - Core utilities ............ the chat channels, the clock, the item and party
--                                           helpers, and the multibox cast announce
--
-- THIS FILE IS THE SUPPLY DEPOT. It drives nothing; it holds what the rest of the engine
--          reads. Forty-five exports and seven globals, and ELEVEN of the other fourteen
--          files draw on them -- every component except interface, state and the root. A
--          constant only one component uses belongs with that component; what is here is
--          here because two or more of them share it.
--
-- IT REPLACES TWO NAMES LUA PROVIDES, both deliberately. GearSwap gives the job file and
--          every file it includes ONE shared environment, so `print` declared below does not
--          add a name -- it takes over Lua's, for the engine and the job file alike, and it
--          reads its first argument as a chat mode. `debug` is the milder case: a file-local
--          shadowing the stdlib debug table, from its declaration to the end of this
--          constructor and inside every component that imports it.
--
-- SECTION ORDER AND LOAD ORDER DISAGREE HERE, and this is the one place in the engine where
--          they do. It owns sections 7-9 and 11 yet constructs THIRD, behind state and its
--          section 10, because it copies state's cached handles at construction. Section
--          numbers are a reading order; the manifest decides what runs when.
--
-- THE ONE PIECE OF LIVE STATE it keeps is the multibox announce debt -- E.outgoing_cast_active
--          and the deadline beside it. Any other character holding gear for an announced cast
--          is waiting on a completion this file owes it.
--
-- EXPORTS  45 fields plus seven globals: five chat channels, the writer beneath them, and
--          round. settings and res are the widest, at eight importers each.
-- LOADS    Third of fifteen. Takes get_mob_by_id, get_party and send_ipc from state. No
--          global it calls resolves late -- every name reached from here is already in hand.

-- requires: rahvings/state
return function(E)
    -- The cached API handles state.lua resolved once, bound here so no call below reaches
    -- through E. Two other windower.ffxi calls in this file -- the client language and the
    -- stratagem recast read -- go through that table directly, with no cached handle.
    local get_mob_by_id, get_party, send_ipc = E.get_mob_by_id, E.get_party, E.send_ipc

    ------------------------------------------------------------------------------------------------
    -- SECTION 7 - LIBRARIES AND USER SETTINGS
    ------------------------------------------------------------------------------------------------
    -- Everything the engine borrows from outside itself, plus the settings that survive a
    -- reload and the two boxes those settings dress.

    -- The four libraries the engine leans on: config writes the settings file back to disk,
    -- res is the game's own resource tables, socket gives a wall clock in milliseconds, and
    -- extdata decodes the per-item blob holding enchantment charges and timers. `require` is
    -- GearSwap's own include here, not Lua's -- it hands back the table the addon already
    -- loaded, which is how three of these four resolve, and searches its paths only for the
    -- one the addon has not, config.
    local config = require('config')
    local res = require('resources')
    local socket = require('socket')
    local extdata = require('extdata')

    -- What the settings file holds on a first run, and the shape config.load merges a saved
    -- file into. The six booleans are the toggles commands.lua flips; delay is the multibox
    -- announce window in seconds, which spellreceived.lua's failsafe also times against.
    local default = {
        visible = true,
        oneline = false,
        -- Which renderer draws the status box, beside the one-line flag above: that is the
        -- VIEW axis and this is the RENDERER axis. A saved file that already carries either
        -- key keeps its own value through the merge below, so a change to either reaches an
        -- installed file only through the display silo's version.
        Display_Style = 'lattice',
        -- A floor of the player's own for the status box's value column, in characters;
        -- zero leaves the column sized by the widest mode option and the header. It is
        -- listed here because a setting reaches the engine ONLY through this table: the
        -- config library lowercases every tag it parses and maps it back onto a default's
        -- own spelling, so a key absent from here lands under a name nothing reads.
        Display_MinValueCells = 0,
        debug = false,
        info = true,
        warn = true,
        gear_reporting = false,
        -- The lattice style's panel: the body behind the text, the strip behind the header
        -- line, the border and its width, and how far the panel reaches past the text at
        -- the sides (pad) and below (pad_bottom); above, the strip meets the border. Colors
        -- are red, green, blue and alpha, as the boxes' own are.
        -- The rig: a four-by-four grid of gear slots in cols text columns the layout keeps
        -- clear at the right of every mode row, plus a gutter column, in the stacked view
        -- only; gap is the space between cells and inset the recess's margin around the
        -- grid. Every hue is the color that layer already draws elsewhere on the box, so
        -- nothing already read has to be relearned: a strip hold the orange of its own
        -- token, the disable hold the cyan of its DIS token, a lock mode and the weapon
        -- lock the one violet the LCK row and the lock tokens share, Hoxne the green of
        -- its own header square. ench is the only layer with no color of its own today.
        -- other is for a held slot whose layer has no hue, and socket for a slot nothing
        -- holds.
        Lattice = {
            body = { red = 0, green = 0, blue = 0, alpha = 190 },
            strip = { red = 30, green = 30, blue = 50, alpha = 220 },
            border = { red = 110, green = 110, blue = 110, alpha = 255, width = 1 },
            pad = 4,
            -- The clear space below the last line. There is no matching value above it:
            -- the panel's top is whatever the crown's band needs to meet the border, and
            -- that band is derived from the measured line height rather than set here, so
            -- it holds when the box changes size.
            pad_bottom = 2,
            rig = {
                enabled = true,
                -- The grid is measured in TEXT COLUMNS, not pixels: it reserves this many
                -- at the right of every mode row and sizes its cells to fill them, so it
                -- scales with the font instead of pinning a pixel size to one setup.
                cols = 9, gap = 2, inset = 3,
                -- Columns kept empty between the widest mode row and the grid, so the
                -- two never touch whatever the crown's spacing rounds to. Part of the
                -- layout's reservation, not of the grid's width.
                gutter = 1,
                recess = { red = 0, green = 0, blue = 0, alpha = 235 },
                socket = { red = 70, green = 82, blue = 104, alpha = 235 },
                -- Keyed by slot_claim's own return strings, and every key is spelled AS a
                -- quoted string: strip and hoxne are also exported names, and a bare key
                -- is indistinguishable from a use of the name it shares.
                hue = {
                    ['strip']  = { red = 255, green = 132, blue = 64,  alpha = 255 },
                    ['disable'] = { red = 90, green = 200, blue = 255, alpha = 255 },
                    ['lock']   = { red = 186, green = 150, blue = 255, alpha = 255 },
                    ['weapon'] = { red = 186, green = 150, blue = 255, alpha = 255 },
                    ['hoxne']  = { red = 80,  green = 220, blue = 110, alpha = 255 },
                    ['ench']   = { red = 236, green = 236, blue = 140, alpha = 255 },
                    ['other']  = { red = 235, green = 235, blue = 235, alpha = 255 },
                },
            },
        },
        -- The halo style: no background on any object, four text objects at one
        -- position. Three satellite blocks, each with its plane's stroke, weight and
        -- color -- font, size, padding and edge anchoring are copied from Display_Box at
        -- entry, so the four share one grid; the mode box's own stroke and weight while
        -- the style stands; the plane hues; and the cap on a value's width in cells,
        -- zero for none. Every stroke is width 2: weight and hue carry the separation.
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
        -- One stamp per versioned silo, per character: the version of that silo the
        -- character last loaded, under the character's lowercased name.
        Settings_Version = { display = {}, halo = {} },
    }

    -- Every setting belongs to one silo, so a version reset can name what it returns to
    -- default and leave the rest alone. An entry written as a.b is a sub-block another
    -- silo's key carries, kept through that key's reset. A silo listed in SETTINGS_VERSIONS
    -- resets when the version stamped for the character playing is behind the engine's; a
    -- silo with no version never resets.
    local SETTINGS_SILOS = {
        display   = { 'Display_Box', 'Debug_Box', 'Display_Style', 'Lattice', 'oneline', 'visible',
                      'Display_MinValueCells' },
        -- The halo style's blocks are their own silo: a calibration change delivers its
        -- new defaults without resetting the boxes, the style or the view.
        halo      = { 'Halo' },
        positions = { 'Display_Box.pos', 'Debug_Box.pos' },
        channels  = { 'debug', 'info', 'warn', 'gear_reporting' },
        timing    = { 'delay' },
        stamps    = { 'Settings_Version' },
    }
    -- The engine's current version of each silo that can reset. Raising a number here is
    -- what delivers a changed default in that silo to settings files already saved: every
    -- key the silo names goes back to the default above, while the sub-blocks another silo
    -- names -- both box positions -- are kept as the player left them.
    local SETTINGS_VERSIONS = { display = 2, halo = 1 }

    -- The sub-blocks other silos keep under a key a reset replaces.
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
    -- keeping the sub-blocks other silos own, and stamp every versioned silo current. The
    -- stamps are kept per character because the config library carries a new key into
    -- the global block at the first save, so one shared stamp would read as current for
    -- every other character. Returns the silos reset, sorted.
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

    -- The live settings table: eight components read it, as many as res. A write here
    -- changes behavior immediately but survives nothing -- display.lua is the only caller
    -- of config.save, and it saves only while logged in.
    local settings = config.load(default)

    -- The silos whose stamp for this character is behind are reset before anything reads
    -- them, so the boxes below are built on the reset values; the root announces the reset
    -- and saves it once the client has settled.
    local settings_reset = settings_reset_stale(settings, player.name:lower())

    -- Push one box's saved appearance and position onto it. Four of the keys read here --
    -- text.fonts and the italic, right and bottom flags -- are absent from the default table
    -- above; texts.new fills them in from the text library's own defaults. So this runs AFTER
    -- the box exists, or unpack(cfg.text.fonts) unpacks a nil.
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
    -- their text, commands.lua shows and hides them, and lifecycle.lua destroys them at unload.
    local gs_status = texts.new("", settings.Display_Box, settings)
    local gs_debug = texts.new("", settings.Debug_Box, settings)

    -- Restore both boxes, then state draggability and visibility explicitly, BOTH WAYS.
    -- The hide() call is not redundant: texts.new records a new box as hidden in the library's
    -- own table without telling the primitive underneath, so a box that is only ever shown
    -- leaves an empty background sitting on screen when its setting is off. Dragging is
    -- allowed only while a box is visible, and commands.lua keeps that pairing when it toggles.
    apply_box_settings(gs_status, settings.Display_Box)
    apply_box_settings(gs_debug, settings.Debug_Box)
    gs_status:draggable(settings.visible and true or false)
    gs_debug:draggable(settings.debug and true or false)
    if settings.visible then gs_status:show() else gs_status:hide() end
    if settings.debug then gs_debug:show() else gs_debug:hide() end

    ------------------------------------------------------------------------------------------------
    -- SECTION 8 - SHARED CONSTANTS AND LOOKUP TABLES
    ------------------------------------------------------------------------------------------------
    -- The tables two or more subsystems read. A constant with one reader belongs beside that
    -- reader; these are here because moving any of them would leave a component reaching
    -- across the engine for it.

    -- Action classification -----------------------------------------------------------------------

    -- Spell types that carry a recast timer. pretargetcheck consults it before spending a
    -- get_spell_recasts call, so a type absent here is never checked for cooldown at all.
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

    -- Spell types long enough to need a busy window: precast sizes one from the listed cast
    -- time, aftercast leaves a 2.5 second tail. The same eight types as the table above, and
    -- separate on purpose -- they answer different questions, and adding a type to one is not
    -- adding it to the other.
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

    -- Buff and action-type names, so the comparison sites read as words instead of literals.
    -- The first two are numeric because spellreceived matches them against the id in a buff
    -- packet; the six below are strings because hooks keys them into buffactive, whose
    -- incapacitation entries arrive by name.
    local BUFF_ACCESSION                      = 366
    local BUFF_DIVINE_SEAL                    = 78
    local BUFF_SLEEP, BUFF_STUN, BUFF_KO      = 'Sleep', 'Stun', 'KO'
    local BUFF_PETRI, BUFF_CHARM, BUFF_TERROR = 'Petrification', 'Charm', 'Terror'
    local TYPE_JA, TYPE_WS, TYPE_MS, TYPE_SCH = 'JobAbility', 'WeaponSkill', 'Magic', 'Scholar'

    -- Action categories that count as tagging a mob for Treasure Hunter. th.lua stamps the
    -- target with the clock on any of them, so a mob still being fought never ages out of the
    -- tagged table; a category absent here refreshes no tag, whatever it does in game.
    local TaggingCategories                   = S { 1, 2, 3, 4, 6, 11, 14 }

    -- Action-message ids reporting a death, the same six GearSwap itself treats as fatal.
    -- th.lua drops a mob from the tagged table on any of them, ahead of the 180 second sweep
    -- that would otherwise retire it. Keyed rather than S{} so the test is a plain index.
    local DeathMessages                       = {
        [6] = true,   -- <actor> defeats <target>.
        [20] = true,  -- <target> falls to the ground.
        [113] = true, -- <actor> casts <spell>. <target> falls to the ground.
        [406] = true, -- <actor> uses <weapon skill>. <target> falls to the ground.
        [605] = true, -- Additional effect: <target> falls to the ground.
        [646] = true, -- <actor> uses <ability>. <target> falls to the ground.
    }

    -- Job, zone and element reference -------------------------------------------------------------

    -- The sixteen storm spells. builders.lua merges sets.Storms over the enhancing midcast
    -- build for any of them; interface.lua declares that set empty, so a job file that never
    -- fills it loses nothing.
    local Storms                              = S { "Aurorastorm", "Voidstorm", "Firestorm", "Sandstorm", "Rainstorm", "Windstorm", "Hailstorm", "Thunderstorm",
        "Aurorastorm II", "Voidstorm II", "Firestorm II", "Sandstorm II", "Rainstorm II", "Windstorm II", "Hailstorm II", "Thunderstorm II" }

    -- The three Utsusemi tiers. builders.lua routes them to sets.Precast.Utsusemi and
    -- sets.Midcast.Utsusemi, and runs the shadow count check on the precast side.
    local UtsusemiSpell                       = S { 'Utsusemi: Ichi', 'Utsusemi: Ni', 'Utsusemi: San' }

    -- The four Dynamis Divergence zones. The zone handler names them at entry, pointing the
    -- player at the neck lock; what holds a Dynamis neck on is that mode's claim, and no
    -- slot is treated specially inside these zones by any release path.
    local Divergence_Zones                    = S { "Dynamis - San d'Oria [D]", "Dynamis - Bastok [D]", "Dynamis - Windurst [D]", "Dynamis - Jeuno [D]" }

    -- Jobs for which Silence is worth spending a Remedy. spellreceived.lua tests main and sub
    -- against it, so a listed sub job qualifies; Paralysis spends one on any job, Silence
    -- only on these.
    local Mage_Job                            = S { 'BLM', 'RDM', 'WHM', 'BRD', 'BLU', 'GEO', 'SCH', 'NIN', 'PLD', 'RUN', 'DRK', 'SMN' }

    -- The town zones. Nothing reads this list today -- monitor.lua binds it and never asks
    -- it -- and both the list and that binding are kept deliberately rather than deleted.
    local Cities                              = S { "Ru'Lude Gardens", "Upper Jeuno", "Lower Jeuno", "Port Jeuno", "Port Windurst", "Windurst Waters", "Windurst Woods", "Windurst Walls", "Heavens Tower", "Port San d'Oria", "Northern San d'Oria",
        "Southern San d'Oria", "Chateau d'Oraguille", "Port Bastok", "Bastok Markets", "Bastok Mines", "Metalworks", "Aht Urhgan Whitegate", "The Colosseum", "Tavnazian Safehold", "Nashmau", "Selbina",
        "Mhaura", "Rabao", "Norg", "Kazham", "Eastern Adoulin", "Western Adoulin", "Celennia Memorial Library", "Mog Garden", "Leafallia" }

    -- The client's language, lowercased to index a resource row. monitor.lua names it to pull
    -- buff names out of res.buffs when matching a cancel pattern. Read once at construction,
    -- because it cannot change without a client restart.
    local Language                            = windower.ffxi.get_info().language:lower()

    -- Skillchains keyed by add-effect message id: 288-301 chain damage, 385-398 chain healing,
    -- 767-770 the Umbra and Radiance chains. run_burst records the elements, and the gear
    -- builders use them to dress a nuke landing inside the burst window. Only elements is
    -- read; id restates the key and english names the chain for anyone reading the table.
    --
    -- THE THIRTY-TWO ROWS MUST COVER THOSE THREE RANGES EXACTLY. run_burst tests the id
    -- against the ranges, then indexes here and reads .elements without a nil guard -- so an
    -- id admitted by the range test but missing a row throws inside an event handler.
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

    -- Action types whose precast gear is their final gear. builders.lua returns from the
    -- midcast build immediately for these, and equip.lua counts a precast for one of them as
    -- the phase that names the set in the merge report -- because no later phase will.
    local PRECAST_FINAL                       = {
        WeaponSkill = true,
        JobAbility  = true,
        Item        = true,
        Scholar     = true,
        Ward        = true,
        Rune        = true,
        Effusion    = true,
        CorsairRoll = true,
        CorsairShot = true,
        Waltz       = true,
        Jig         = true,
        Samba       = true,
        Step        = true,
        Flourish1   = true,
        Flourish2   = true,
        Flourish3   = true,
    }

    -- Equipment slots -----------------------------------------------------------------------------

    -- Every spelling of a slot, folded onto one name. A job file may write ear1, lear,
    -- learring or left_ear and mean the same slot; merge_into canonicalizes through this
    -- before assigning, so the last of them wins instead of four keys surviving side by side.
    -- Slot ownership canonicalizes for the same reason, or a held left_ear would not match a
    -- request for ear1.
    --
    -- THE 27 KEYS ARE EXACTLY GEARSWAP'S OWN slot_map. A key missing here is a slot the
    -- engine silently drops from a set that GearSwap would have equipped.
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

    ------------------------------------------------------------------------------------------------
    -- SECTION 9 - SPELL AND ABILITY DATA
    ------------------------------------------------------------------------------------------------
    -- The two tables the multibox spell-received system runs on: whether an incoming action is
    -- tracked at all, which set it calls for, and who besides the named target will receive it.

    -- Tracked spells by spell id, and the gate on the whole feature: a spell absent here is
    -- never announced and never dresses a receiver. equip names the received set through
    -- spellreceived's SR_SET_KEY; aoe means the spell always reaches a party, and accession,
    -- majesty and divine mean it does while that one effect is up. name and category are unread.
    local spell_info                          = {
        -- Single-target enhancements, widened by Accession. Two rows differ: Phalanx II
        -- spreads under nothing at all, and Cursna is the table's only divine row -- Divine
        -- Seal, or a Yagrush in the Cursna set, widens it as well.
        [20] = { name = "Cursna", category = 'track_cursna', equip = "cursna_set", aoe = false, majesty = false, accession = true, divine = true },
        [106] = { name = "Phalanx", category = 'track_phalanx', equip = "phalanx_set", aoe = false, majesty = false, accession = true, divine = false },
        [107] = { name = "Phalanx II", category = 'track_phalanx', equip = "phalanx_set", aoe = false, majesty = false, accession = false, divine = false },
        [108] = { name = "Regen", category = 'track_regen', equip = "regen_set", aoe = false, majesty = false, accession = true, divine = false },
        [110] = { name = "Regen II", category = 'track_regen', equip = "regen_set", aoe = false, majesty = false, accession = true, divine = false },
        [111] = { name = "Regen III", category = 'track_regen', equip = "regen_set", aoe = false, majesty = false, accession = true, divine = false },
        [477] = { name = "Regen IV", category = 'track_regen', equip = "regen_set", aoe = false, majesty = false, accession = true, divine = false },
        [504] = { name = "Regen V", category = 'track_regen', equip = "regen_set", aoe = false, majesty = false, accession = true, divine = false },
        -- Protect and Shell, both families sharing one received set. The -ra forms are already
        -- party-wide. Of the single-target forms, Accession widens both lines and Majesty only
        -- the Protect line -- which is why the two lines are flagged differently.
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
        -- Cure, Curaga and Cura. Majesty widens every single-target Cure; Accession only the
        -- first four, so V and VI spread under Majesty alone. The -ga and Cura forms are
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

    -- Tracked job abilities, keyed by ability id and read the same way as spell_info. Two of
    -- the widening flags are absent, having no ability equivalent; accession is carried on
    -- every row and read by nothing.
    --
    -- WHAT THIS TABLE HOLDS DECIDES WHETHER FOUR CANCEL PATHS ARE CORRECT. An announced cast
    -- leaves other characters holding slots until a completion arrives, and four paths that
    -- cancel an action do not send one: the ON-Locked refusal in the precast hook, and the
    -- three ammunition cancels (no round named, none in the bags, not enough). They are safe
    -- only because the actions they reject -- Tomahawk, Angon, a ranged attack -- are not in
    -- this table and so never announced. Adding a non-Waltz entry here makes all four live,
    -- and the symptom appears on another character.
    local ability_info                        = {
        [190] = { name = "Curing Waltz", category = 'track_waltz', equip = "waltz_set", aoe = false, accession = false },
        [191] = { name = "Curing Waltz II", category = 'track_waltz', equip = "waltz_set", aoe = false, accession = false },
        [192] = { name = "Curing Waltz III", category = 'track_waltz', equip = "waltz_set", aoe = false, accession = false },
        [193] = { name = "Curing Waltz IV", category = 'track_waltz', equip = "waltz_set", aoe = false, accession = false },
        [311] = { name = "Curing Waltz V", category = 'track_waltz', equip = "waltz_set", aoe = false, accession = false },
        [195] = { name = "Divine Waltz", category = 'track_waltz', equip = "waltz_set", aoe = true, accession = false },
        [262] = { name = "Divine Waltz II", category = 'track_waltz', equip = "waltz_set", aoe = true, accession = false },
    }

    -- The moment receivers stop waiting on an announced cast. Past it E.outgoing_cast_active
    -- is stale, and outgoing_cast_busy clears it on the next read rather than on a timer.
    local outgoing_cast_deadline              = 0

    -- Scratch list for the party scan below, reused so a scan costs no table.
    local NEARBY_MEMBERS_BUFFER               = {}

    ------------------------------------------------------------------------------------------------
    -- SECTION 11 - CORE UTILITIES
    ------------------------------------------------------------------------------------------------
    -- The helpers with no subsystem of their own: everything the engine says out loud, the
    -- clock it says it at, the questions it asks about carried gear and the party, and the
    -- announce that tells the other characters a cast is on its way.

    -- Chat output ---------------------------------------------------------------------------------

    -- Flatten varargs into one string, tolerating nil and non-string arguments. The single
    -- argument case returns it untouched, so an existing string is not re-built.
    local function join(...)
        if select('#', ...) < 2 then return (...) end
        local parts = {}
        for i = 1, select('#', ...) do parts[i] = tostring((select(i, ...))) end
        return table.concat(parts)
    end

    -- The three gated channels, each behind its own toggle and its own chat mode: log traces
    -- for whoever is reading the engine, info is ordinary feedback, warn is a problem the
    -- player should act on. Ten of the fourteen other files speak through these three;
    -- counting notice and gear_report below, eleven speak through the block as a whole.
    --
    -- A CHAT MODE BELONGS TO ITS CHANNEL. Writing 8, 80, 121, 123, 207 or 221 into a raw
    -- add_to_chat anywhere else goes around the channel that owns it. The confirmation for
    -- switching a channel OFF cannot go out on the channel it just silenced, which is what
    -- notice(), the one channel with no toggle of its own, is there for.
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
    -- The one channel with no gate, because a command the player just typed must be answered
    -- whatever the toggles say. commands.lua is far and away its heaviest caller.
    function notice(...)
        print(221, join(...))
    end

    -- The set-selection trace: which set was tried, which was merged, which was missing. Off
    -- by default and turned on with 'gs c gearreporting'. equip.lua is the only caller, and it
    -- reports every phase, where warn and info speak only for the phase that chose the gear.
    function gear_report(...)
        if settings.gear_reporting then print(207, join(...)) end
    end

    -- The writer under all five channels. Takes a chat mode and a value, dispatches on the
    -- value's type, and walks a table one entry per line to four levels. Long lines are not
    -- wrapped here -- the game breaks them itself, wherever they happen to fall.
    --
    -- THIS IS LUA'S print, REPLACED. GearSwap hands the job file and every file it includes one
    -- shared environment, so the name declared here is the one both of them get. It reads its
    -- FIRST argument as a chat mode, so a bare print(value) hands the value to add_to_chat
    -- where the mode belongs; a stray debugging print does not behave the way Lua's would.
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

    -- The debug channel. Takes one already-built string, not varargs, and four components
    -- import it. Because Lua builds that string before the call, a caller wraps its own site
    -- in `if settings.debug then` -- the gate inside here stops the printing, never the
    -- concatenation. This local also shadows Lua's stdlib debug table from here down.
    local function debug(message)
        if not settings.debug then return end
        windower.add_to_chat(121, "[Rahvin Debug] " .. message)
    end

    -- General helpers -----------------------------------------------------------------------------

    -- Wall clock in whole milliseconds. socket rather than os.clock because every timestamp
    -- this returns crosses to another game client over IPC, and os.clock counts from each
    -- process's own start. Deadlines nobody else reads stay on os.clock, which is compared
    -- only against itself.
    local function get_time()
        return math.floor(socket.gettime() * 1000)
    end

    -- Spell-received announces -------------------------------------------------------------------

    -- Pay the completion an announce owes its receivers, and clear the flag. Receivers equip
    -- and HOLD slots the moment the announce arrives, so an action that ends after announcing
    -- has a debt: unpaid, those characters wear received gear until their own failsafe expires.
    -- Idempotent, so a path that cannot tell whether it already paid may just call it again.
    local function finish_outgoing_cast()
        if not E.outgoing_cast_active then return end
        E.outgoing_cast_active = false
        send_ipc(string.format("RAHVIN|COMPLETE|%s|%.0f", player.name, get_time()))
    end

    -- Is an announce still outstanding? builders.lua asks before announcing another, so two
    -- casts in quick succession do not leave receivers holding gear for the first. A flag past
    -- its deadline is stale and is cleared here rather than by any timer -- the expiry costs
    -- nothing until somebody asks.
    local function outgoing_cast_busy()
        if not E.outgoing_cast_active then return false end
        if os.clock() < outgoing_cast_deadline then return true end
        E.outgoing_cast_active = false
        return false
    end

    -- Table, number and gear-set helpers ----------------------------------------------------------

    -- Count the entries at the top level of a table, including the string-keyed ones the
    -- length operator cannot see. spellreceived.lua uses it to report how many casters it is
    -- currently tracking.
    local function count_keys(tbl)
        local count = 0
        for _ in pairs(tbl) do
            count = count + 1
        end
        return count
    end

    -- Round to a given number of decimal places, or to a whole number when none is given.
    -- A nil input returns nil rather than throwing. One caller: builders.lua, formatting a
    -- target distance into a message.
    function round(num, numDecimalPlaces)
        if num ~= nil then
            local mult = 10 ^ (numDecimalPlaces or 0)
            return math.floor(num * mult + 0.5) / mult
        end
    end

    -- Party and target helpers --------------------------------------------------------------------

    -- Is the named character in this player's party right now? Walks p0-p5 only, so an
    -- alliance member outside the party answers false -- which is the answer the caller below
    -- wants, because no tracked spell reaches past the party.
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
    -- actually reach, so each receiver can recognize itself in the announce. Returns the name
    -- unchanged when the target is outside the party, or when nobody is in range -- an
    -- announce naming nobody would leave the real target undressed.
    local function resolve_aoe_target_name(target_mob, target_name)
        local party = get_party()
        if not (party and is_target_in_party(target_name, party)) then
            return target_name
        end

        local count = 0
        for k in pairs(NEARBY_MEMBERS_BUFFER) do NEARBY_MEMBERS_BUFFER[k] = nil end

        -- Every tracked area spell is party-scope, so only p0-p5 can receive one. get_party
        -- also returns the a10-a25 alliance entries, and walking them would name characters
        -- the spell cannot touch.
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
    -- one now owes them. The caller has already decided the action is tracked and whether it
    -- spreads; the name expansion, the send and the trace of exactly what went out live here.
    --
    -- Called from two phases on purpose: hooks.lua at pretarget, the earliest point a target
    -- is known, and builders.lua at precast for whatever did not announce there -- the precast
    -- site asks outgoing_cast_busy first, so it never repeats an announce already sent. The
    -- deadline is os.clock because only this file reads it; the timestamp in the message is
    -- get_time because the receivers do.
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
            -- The mob table is fetched only on this branch: a single-target announce carries
            -- the name it was given and needs no position at all.
            local target_mob = get_mob_by_id(spell.target.id)
            if target_mob then target_name = resolve_aoe_target_name(target_mob, target_name) end
        end

        local message = string.format('RAHVIN|%s|%s|%s|%s|%.0f', kind, player.name,
            target_name, spell.id, get_time())
        if settings.debug then debug('IPC message sent: ' .. message) end
        send_ipc(message)
    end

    -- Recast helpers ------------------------------------------------------------------------------

    -- How many Scholar stratagem charges are in hand, and how many seconds until the next one
    -- returns. hooks.lua refuses a Scholar art at zero and names the wait.
    --
    -- THE SECOND VALUE IS NIL IN TWO DIFFERENT CASES -- a full pool, and a character with no
    -- stratagems at all -- so a caller must test it rather than format it. Those two cases
    -- deserve different messages, and only the caller can tell them apart, by the first value.
    local function get_current_stratagem_count()
        -- Ability 231 is the stratagem charge pool. ABSENT IS NOT ZERO: the recast table omits
        -- abilities this character cannot use, so a missing key means no stratagems at all,
        -- while a zero means the pool is full.
        local charge_cooldown = windower.ffxi.get_ability_recasts()[231]
        if charge_cooldown == nil then return 0 end

        -- Pool size and regen period by Scholar level, main or sub. Every bracket multiplies
        -- out to the same 240 second pool -- 1x240, 2x120, 3x80, 4x60, 5x48 -- which is what
        -- makes the whole ladder one rule rather than five.
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

        -- The one exception to that rule. At 550 job points a main Scholar regains a charge
        -- every 33 seconds, so its pool is 5 x 33 = 165 seconds, not 240. Job point traits
        -- belong to the MAIN job, so a /SCH sub never earns this however much its main has
        -- spent -- which is why this test names main_job rather than sch_level.
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
        -- period IS the wait for the next one. One modulo on values already in hand, with no
        -- second read of the recast table.
        return math.max(0, current_charges), charge_cooldown % charge_regen_time
    end

    -- Carried gear --------------------------------------------------------------------------------

    -- The nine bags gear can be equipped from, keyed by item name the way GearSwap presents
    -- them. The bags gear cannot be equipped from -- safe, storage, satchel, sack, case -- are
    -- not listed, so an item sitting in one answers no to both questions below.
    local CARRY_BAGS = {
        'inventory', 'wardrobe', 'wardrobe2', 'wardrobe3', 'wardrobe4',
        'wardrobe5', 'wardrobe6', 'wardrobe7', 'wardrobe8',
    }

    -- Is this item carried at all? Stops at the first bag holding it, and returns nil rather
    -- than false when none does. The gear builders ask before merging a conditional piece, so
    -- a set naming an item this character is not carrying is skipped rather than merged.
    local function have_item(name)
        for i = 1, #CARRY_BAGS do
            local bag = player[CARRY_BAGS[i]]
            if bag and bag[name] then return true end
        end
    end

    -- Why this item cannot be worn right now, phrased for the player, or nil when it can be.
    -- Takes a resource row rather than a name, because job, level, race and slots all live
    -- there. It mirrors the checks GearSwap would apply, so the engine can refuse with a
    -- reason instead of sending an equip that quietly does nothing.
    local function unwearable_reason(row)
        local job_level = (player.jobs and player.jobs[player.main_job]) or player.main_job_level
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

    -- How many of the item are carried, summed across every bag -- so unlike have_item this
    -- cannot stop at the first hit. builders.lua counts bullets with it, where a stack in one
    -- wardrobe and a stack in another are still one supply.
    local function have_item_count(name)
        local total = 0
        for i = 1, #CARRY_BAGS do
            local bag = player[CARRY_BAGS[i]]
            local entry = bag and bag[name]
            if entry then total = total + entry.count end
        end
        return total
    end


    -- Everything above, handed to the eleven components that load after this one. Nothing here
    -- is written again once construction ends -- the one mutable this file owns,
    -- E.outgoing_cast_active, is declared in state.lua and set from the functions above.
    E.config = config
    E.res = res
    E.extdata = extdata
    E.settings = settings
    -- The silos this load reset, for the root's announce, and each silo's current version.
    E.settings_reset = settings_reset
    E.settings_versions = SETTINGS_VERSIONS
    E.gs_status = gs_status
    E.gs_debug = gs_debug
    E.HasRecastTimer = HasRecastTimer
    E.RecastTimers = RecastTimers
    E.BUFF_ACCESSION = BUFF_ACCESSION
    E.BUFF_DIVINE_SEAL = BUFF_DIVINE_SEAL
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
    E.Divergence_Zones = Divergence_Zones
    E.Mage_Job = Mage_Job
    E.Cities = Cities
    E.Language = Language
    E.skillchains = skillchains
    E.PRECAST_FINAL = PRECAST_FINAL
    E.CANON_SLOT = CANON_SLOT
    E.spell_info = spell_info
    E.ability_info = ability_info
    E.debug = debug
    E.get_time = get_time
    E.finish_outgoing_cast = finish_outgoing_cast
    E.outgoing_cast_busy = outgoing_cast_busy
    E.count_keys = count_keys
    E.announce_tracked_cast = announce_tracked_cast
    E.get_current_stratagem_count = get_current_stratagem_count
    E.have_item = have_item
    E.unwearable_reason = unwearable_reason
    E.have_item_count = have_item_count

    -- Version stamp, asserted by the root against the engine's own version constant. A stale
    -- copy of this file shadowing the current one announces itself at load, not later.
    return '2.0'
end
