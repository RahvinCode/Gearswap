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
-- COMPONENT: display -- section 20: the on-screen status and debug boxes
----------------------------------------------------------------------------------------------------
-- CONTENTS
--   Section 20 - On-screen display. Appearance constants, the cached column layout and
--   the code that measures it, the hold group, the status-box renderer registry, the
--   hold map and its legend, the debug box, and the settings save that every position
--   change goes through.
--
-- EXPORTS  E.save_settings, taken by the commands component so gs c save and the drag
--          handler share one implementation and one refusal message; E.display_styles and
--          E.set_display_style for the style command; E.display_visible for the display
--          toggle; E.display_unload for the lifecycle component's teardown.
-- GLOBALS  display_box_update, one of the two most-called cross-file globals in the engine
--          -- fifteen call sites in commands, seven in equip (its holds and the legacy
--          bridge), two in enchant's lock mode, one in th's zone handler, two here (the
--          style switch and the position reset), plus the root, which hands it to a
--          scheduled call
--          -- then display_box_reset,
--          debug_box_update, debug_box_reset,
--          display_zero_command, settings_reset_announce, which the root schedules once
--          the client has settled, and invalidate_layout, which the lifecycle component
--          calls on a subjob change.
-- LOADS    Twelfth of fifteen. It calls out to nothing that loads later, but FOUR files that
--          load before it call in -- equip (fourth), enchant (fifth), th (tenth) and monitor
--          (eleventh) all reach display_box_update or debug_box_update as a global resolved
--          at call time.
--
-- Redrawing is deliberately cheap: the column layout is measured once and cached; the status
-- box paints through a per-object guard that skips handing a text object a string it is
-- already showing; and the debug box has a guard of its own above that, comparing its six
-- values and its hold map against the last frame and returning when none moved, so it
-- writes its text object directly. Both boxes are redrawn from paths that can run many
-- times a second.

-- requires: rahvings/core, rahvings/equip, rahvings/spellreceived
return function(E)
    -- Immutable dependencies bound once at construction. The debug box reaches the
    -- spell-received failsafe through the E.sr_failsafe_active() accessor rather than a
    -- field, because that state is an upvalue private to the spell-received component.
    local config, gs_debug, gs_status, settings = E.config, E.gs_debug, E.gs_status, E.settings

    -- The lock, sleep and implement registries, bound by identity: the equip component
    -- assigns each once and only ever mutates it in place, so these references stay the live
    -- tables. The lock count beside them and the standing strip shape are mutable and are
    -- read as E fields at every use. slot_claim is the arbiter the hold map asks.
    local locked, sleep_held, implement_held = E.locked, E.sleep_held, E.implement_held
    local slot_claim = E.slot_claim

    ------------------------------------------------------------------------------------------------
    -- SECTION 20 - ON-SCREEN DISPLAY
    ------------------------------------------------------------------------------------------------
    -- The mode box, which is always available, and the debug box, which is hidden unless the
    -- debug channel is on. Everything below divides into appearance constants, layout
    -- measurement, and the code that draws the two boxes.

    -- Appearance ----------------------------------------------------------------------------------

    -- Glyphs for the indicators. `on` and `off` are deliberately the SAME character: an
    -- indicator's state is carried entirely by its color, so the two squares align and the
    -- row never reflows when a mode is toggled.
    local GLYPH = {
        on    = string.char(0xE2, 0x96, 0xA0), -- U+25A0 Black Square
        off   = string.char(0xE2, 0x96, 0xA0), -- U+25A0 Black Square
        prev  = string.char(0xE2, 0x97, 0x84), -- U+25C4 Black left-pointing arrow
        next  = string.char(0xE2, 0x96, 0xBA), -- U+25BA Black right-pointing arrow
        trunc = string.char(0xE2, 0x80, 0xA6), -- U+2026 Elipsis
        free  = string.char(0xE2, 0x94, 0x80), -- U+2500 Box drawings light horizontal: a map cell no layer holds
        unknown = '?',                         -- a map cell whose holder has no letter in the legend
    }
    local COLOR = {
        label = '150,150,150',
        value = '235,235,235',
        chev = '110,110,110',
        idle = '120,120,120', -- A dimmed "off" square, and an unlit rail letter
        good = '80,220,110',  -- Fully on - green
        warn = '255,170,60',  -- Partially on - amber: the TH tag, and Hoxne allowing a critical
        cyan = '90,200,255',  -- TH SATA mode, and the disable hold's DIS token
        strip = '255,132,64',  -- A strip hold - orange
        lock = '186,150,255',  -- A lock mode's token, and the LCK row under the weapon lock
    }

    -- Wrap a string in a Windower color tag. The tags occupy no display columns, which is
    -- why width has to be measured separately -- see cells() below.
    local function cs(color, s) return '\\cs(' .. color .. ')' .. s .. '\\cr' end

    -- Column separator, used between header entries and between one-line cells.
    local SEP = '  '

    -- The three modes drawn as a colored square instead of a labeled value: the value that
    -- counts as off, and the color class each active value takes -- a key of COLOR, and
    -- of the halo style's own hues. A mode listed here shows state and nothing more,
    -- which is what keeps the header one row regardless of option lists.
    local GLYPH_FIELDS = {
        {
            label = 'SR',
            mode = 'SpellReceived',
            off = 'OFF',
            classes = { ['ON'] = 'good' }
        },
        {
            label = 'TH',
            mode = 'TreasureMode',
            off = 'None',
            classes = { ['Tag'] = 'warn', ['Full Time'] = 'good', ['SATA'] = 'cyan' }
        },
        {
            label = 'HOX',
            mode = 'Hoxne',
            off = 'OFF',
            classes = { ['ON-Allow Critical'] = 'warn', ['ON-Locked'] = 'good' }
        },
    }

    -- The color class an indicator's value draws in: idle at the off value, the class the
    -- field names for an on value, and the fully-on class for a value it does not name,
    -- so an unrecognized value is still visible as active.
    local function glyph_class(g, v)
        if v == g.off then return 'idle' end
        return g.classes[v] or 'good'
    end

    -- Derive a three-letter status-box label from a job file's mode name. The alias table is
    -- consulted first; otherwise a single word gives its first three letters and a multi-word
    -- name gives two letters of the first word plus the initial of the last. The result is
    -- padded and cut to exactly three, so an unknown name can never widen the label column.
    local derive_short
    -- The alias table lives inside a closed block, so nothing outside it reaches the table
    -- and only derive_short escapes. Lua caps a function's locals at 200, and a
    -- constructor is one function; the import block binds only what this file uses.
    do
        -- Names that would derive badly, or that a player expects to see abbreviated a
        -- particular way. The last four are for job files naming a mode this engine has
        -- retired -- the mode itself does nothing, but a file that still names one gets a
        -- correct label rather than a mangled one.
        local UI_SHORT_ALIASES = {
            ['mode'] = 'MDE',
            ['pet'] = 'PET',
            ['tp mode'] = 'TPM',
            ['auto tank'] = 'TNK',
            ['tank'] = 'TNK',
            ['runes'] = 'RUN',
            ['rune'] = 'RUN',
        }
        derive_short = function(name)
            local alias = UI_SHORT_ALIASES[name:lower()]
            if alias then return alias end

            local words = {}
            for w in name:gmatch('%a+') do words[#words + 1] = w end

            local short
            if #words == 0 then
                short = name:upper()
            elseif #words == 1 then
                short = words[1]:upper()
            else
                short = (words[1]:sub(1, 2) .. words[#words]:sub(1, 1)):upper()
            end
            return (short .. '   '):sub(1, 3)
        end
    end

    -- Layout --------------------------------------------------------------------------------------

    -- Text from a job file with the text library's variable syntax broken apart: the
    -- library reads ${...} in a string it is handed as a variable to substitute, and a
    -- mode option or a UI_Short is the job file's own text.
    local function no_token(s)
        return (s:gsub('%${', '$ {'))
    end

    -- The label for a job-defined mode. A job file's explicit UI_Short always wins, and
    -- unlike a derived label it is used as given -- so it may be longer than three
    -- characters and widen the label column for every row.
    local function status_label(explicit, name)
        if explicit and explicit ~= '' then return no_token(explicit) end
        return derive_short(name)
    end

    -- Width in display columns of UNTAGGED text. Counting the bytes that are not UTF-8
    -- continuation bytes gives the column count of a plain run, which is what the box glyphs
    -- need: they are three bytes each and one column wide. A color tag is counted the same
    -- way, byte by byte, and it occupies no columns at all -- so a string already wrapped in
    -- tags measures far wider than it draws. Measure the text first, wrap it afterwards.
    local function cells(s)
        local n = 0
        for i = 1, #s do
            local b = s:byte(i)
            if b < 0x80 or b >= 0xC0 then n = n + 1 end
        end
        return n
    end

    -- The first w display columns of UNTAGGED text. Cutting by byte instead splits a
    -- multi-byte glyph down the middle, which hands the box an invalid fragment and leaves
    -- the run a column short of the count the caller then pads against; walking to the byte
    -- that begins the w+1'th column cannot. A width of nothing yields nothing, where a byte
    -- cut at w-1 = -1 would return the whole string.
    --
    -- w is a whole number of columns. A fractional one never equals the running count and
    -- the whole string comes back, which is why every width reaching here is floored where
    -- it is read rather than where it is used.
    local function cut(s, w)
        if w <= 0 then return '' end
        local n = 0
        for i = 1, #s do
            local b = s:byte(i)
            if b < 0x80 or b >= 0xC0 then
                if n == w then return s:sub(1, i - 1) end
                n = n + 1
            end
        end
        return s
    end

    -- A mode's current value as the box draws it.
    local function mode_value(f)
        return no_token(tostring(state[f.mode].value))
    end

    -- The cached column layout. nil means rebuild on the next draw; invalidate_layout is
    -- what sets it back to nil, and a subjob change is the event that calls it.
    local layout

    -- The width of the widest value a mode can ever show, measured from its whole option
    -- list rather than its current value. That is what stops the box resizing as a mode is
    -- cycled -- the column is sized once for the widest option and stays there.
    local function option_cells(m)
        local w = 0
        if type(m) == 'table' and m._track and m._track._type == 'list' then
            for _, v in ipairs(m) do
                local n = #no_token(tostring(v))
                if n > w then w = n end
            end
        end
        return w
    end

    -- The rows the box shows, in order, and the width of the label column they share.
    -- Every renderer starts here: the engine's fixed three, then whichever job-mode slots
    -- the file named, and a label column as wide as the widest label among them.
    --
    -- Modes are held by NAME rather than by object. A job file may replace a state
    -- table wholesale, and a cached object reference would then render the old one.
    local function status_fields()
        local fields = {
            { label = 'STN', mode = 'OffenseMode' },
            { label = 'DPS', mode = 'WeaponMode' },
            { label = 'LCK', mode = 'WeaponLock' },
        }
        if UI_Name ~= '' then
            fields[#fields + 1] = { label = status_label(UI_Short, UI_Name), mode = 'JobMode' }
        end
        if UI_Name2 ~= '' then
            fields[#fields + 1] = { label = status_label(UI_Short2, UI_Name2), mode = 'JobMode2' }
        end

        -- Measured in columns, not bytes: a job file's own UI_Short is used verbatim, and a
        -- label carrying a multi-byte glyph occupies fewer columns than it does bytes.
        local label_w = 3
        for _, f in ipairs(fields) do
            local n = cells(f.label)
            if n > label_w then label_w = n end
        end
        return fields, label_w
    end

    -- The job the crown opens with: main and sub where a sub is worn, main alone where it
    -- is not. Read from the client at compose time; a job change invalidates the layout, so
    -- the width this contributes is measured again before it is used.
    local function job_label()
        local p = player
        local main = p and p.main_job
        if not main then return '' end
        local sub = p.sub_job
        if sub and sub ~= '' and sub ~= 'NON' then return main .. '/' .. sub end
        return main
    end

    -- The crown's width in cells: the three indicators, each a label plus a space and its
    -- square, single-separated, with the job in front of them unless with_job is false --
    -- classic's stacked view leaves it out. No renderer draws a box narrower than this, so
    -- every layout measures against it as a floor.
    local function header_cells(with_job)
        with_job = with_job ~= false
        local w = with_job and #job_label() or 0
        for i, g in ipairs(GLYPH_FIELDS) do
            if with_job or i > 1 then w = w + #SEP end -- a separator before every entry but the first
            w = w + #g.label + 2 -- label + space + glyph
        end
        return w
    end

    -- Spread the crown's entries across a box w cells wide: the first hard left, the last
    -- hard right, the rest between them with the leftover space split into equal gaps --
    -- three gaps with the job in front, two without it. Equal gaps put a middle entry dead
    -- center only when its neighbours are the same width, which they are not; it sits a
    -- fraction of a column off center.
    --
    -- The gaps must be equal or the crown looks crooked, and free space that does not
    -- divide by the gap count cannot be split evenly. Widening the box by a cell or two
    -- makes it divide, which costs a column and buys a crown whose spacing is exact -- so
    -- the width actually used comes back beside the pads, and a caller widened here widens
    -- its own rows to match. The third pad is empty when there is no job for it to follow.
    local function header_pads(w, with_job)
        with_job = with_job ~= false
        local used = with_job and #job_label() or 0
        for _, g in ipairs(GLYPH_FIELDS) do used = used + #g.label + 2 end
        local gaps = with_job and 3 or 2
        local free = w - used
        local over = free % gaps
        if over ~= 0 then
            w, free = w + (gaps - over), free + (gaps - over)
        end
        local gap = math.max(free / gaps, 1)
        local s = string.rep(' ', gap)
        return s, s, with_job and s or '', w
    end

    -- The player's floor on a value column, as a whole number of cells. A settings file is
    -- hand-editable and the config library stores whatever it parses, so this is read
    -- through tonumber -- a string reaching math.max raises and the box stops drawing.
    -- Values that pass that test and still cannot be used as a width read as no floor,
    -- which is the setting's own default: a fractional one is kept by the arithmetic and
    -- truncated by string.rep, which draws a box whose header and rows are a cell apart,
    -- and a non-finite one pads nothing at all. A merely enormous one is left alone --
    -- it is a whole number of columns and the box it asks for is the box it gets.
    local function min_value_cells()
        local n = tonumber(settings.Display_MinValueCells)
        if not n or n ~= n or n == math.huge or n == -math.huge then return 0 end
        return math.floor(n)
    end

    -- Measure every column once and cache the result. Called on the first draw after the
    -- layout has been invalidated, never on an ordinary redraw.
    -- reserve: text columns to keep clear at the right of every mode row, for a renderer
    -- that draws something there. Zero for a renderer that draws only text.
    -- crown_job: whether the stacked crown carries the job in front of the indicators.
    -- False only for classic, whose stacked view leaves it out; its one-line view adds the
    -- job itself and reads only the field list here, so the layout is the same in both views.
    local function build_layout(reserve, crown_job)
        crown_job = crown_job ~= false
        local fields, label_w = status_fields()

        local value_w = 0
        for _, f in ipairs(fields) do
            value_w = math.max(value_w, option_cells(state[f.mode]))
        end

        -- The value column is the widest option that column can ever show, and nothing
        -- else: the crown is wider than the rows and the difference is paid in blank space
        -- at the right of each row, not by stretching the values away from their chevrons.
        value_w = math.max(value_w, min_value_cells())

        -- A row is label_w + space + chevron + space + value_w + space + chevron, hence
        -- the 5. The box is the wider of the crown and a row plus whatever the caller has
        -- reserved on the right, and every row pads out to it.
        local row_w = label_w + value_w + 5
        local pad1, pad2, pad3, spread = header_pads(
            math.max(row_w + (reserve or 0), header_cells(crown_job)), crown_job)

        layout = {
            fields = fields,
            label_w = label_w,
            value_w = value_w,
            row_w = row_w,
            box_w = spread,
            crown_job = crown_job,
            head_pad1 = pad1,
            head_pad2 = pad2,
            head_pad3 = pad3,
        }
    end

    -- The classic layout: no columns reserved, and a stacked crown without the job, so the
    -- crown is never wider than the widest row.
    local function classic_layout()
        build_layout(0, false)
    end

    -- The harness layout. Every mode gets a cell of its own -- the shared label column, a
    -- space, and a value column sized from THAT mode's option list rather than from one
    -- column wide enough for the widest option any mode offers. A cell sized from its own
    -- list is as wide as every value the mode can be cycled to, so cycling one never moves
    -- anything to its right; a value from outside the list is the case mode_cell truncates.
    --
    -- Cells are packed two to a row, and the box is as wide as the widest packed row or the
    -- header, whichever is greater. Display_MinValueCells is a floor on the value column
    -- and there is one per mode here, so it applies to every one of them.
    local function harness_layout()
        local fields, label_w = status_fields()

        local floor = min_value_cells()
        local cell_w = {}
        for i, f in ipairs(fields) do
            cell_w[i] = math.max(option_cells(state[f.mode]), floor)
        end

        local box_w = header_cells()
        for i = 1, #fields, 2 do
            local row = label_w + 1 + cell_w[i]
            if fields[i + 1] then row = row + #SEP + label_w + 1 + cell_w[i + 1] end
            box_w = math.max(box_w, row)
        end

        -- There is no single value column to pay for the header's parity correction, so the
        -- box takes the extra cells and the rows pad out to it. The crown is the floor: a
        -- box narrower than the crown would have the crown running past its own edge.
        local pad1, pad2, pad3, spread = header_pads(math.max(box_w, header_cells()))

        layout = {
            fields = fields,
            label_w = label_w,
            cell_w = cell_w,
            box_w = spread,
            crown_job = true,
            head_pad1 = pad1,
            head_pad2 = pad2,
            head_pad3 = pad3,
        }
    end

    -- Drop the cached layout so the next redraw measures again. Called when something that
    -- feeds the measurement may have changed -- a subjob change, which can bring different
    -- mode option lists with it.
    function invalidate_layout() layout = nil end

    -- Render one indicator: its label, then a square colored for the mode's current value.
    local function glyph_entry(g)
        local m = state[g.mode]
        local v = m and tostring(m.value) or ''
        return cs(COLOR.label, g.label) .. ' ' .. cs(COLOR[glyph_class(g, v)], GLYPH.on)
    end

    -- Center a value inside the value column with a chevron on each side. The chevrons hug
    -- the value with one space each and move with it rather than sitting at the column
    -- edges, so the pair reads as a control around the current setting. A value too wide
    -- for the column is truncated and given an ellipsis. The value is drawn in the color
    -- given, or in the ordinary value color.
    local function chevroned(v, w, color)
        local n = cells(v)
        if n > w then
            if w < 1 then
                v, n = '', 0 -- no room for the ellipsis either; the chevrons stand alone
            else
                v, n = cut(v, w - 1) .. GLYPH.trunc, w
            end
        end
        local pad = w - n
        local left = math.floor(pad / 2)
        return string.rep(' ', left)
            .. cs(COLOR.chev, GLYPH.prev) .. ' '
            .. cs(color or COLOR.value, v) .. ' '
            .. cs(COLOR.chev, GLYPH.next)
            .. string.rep(' ', pad - left)
    end

    -- The hold group -------------------------------------------------------------------------------

    -- Which layer holding a slot gets a token on the status box, and what it is called. A
    -- layer with a mode name and nowhere else on the box to be gets a three-letter token
    -- behind an HLD anchor; a layer with a place of its own -- Hoxne, the weapon lock -- is
    -- colored there instead; a transient layer with no mode name gets nothing here and shows
    -- on the debug box. Every token is pure ASCII, so the status box gains no new codepoint.
    local STRIP_TOKEN = {
        naked = 'NKD',
        weaponsonly = 'WPO',
        abysseaproc = 'PRC',
    }

    -- The disable hold's token. It answers to a COUNT rather than to a mode word, so it
    -- stands on its own instead of in a table: one token however many slots are disabled.
    local DISABLE_TOKEN = 'DIS'

    -- The lock modes, by the canonical slot each one's item resolves to, in emission order.
    -- The two ring keys carry the same token and are adjacent, so one Jubilee Ring is named
    -- once whichever ring it took.
    local LOCK_TOKENS = {
        { 'back', 'CAP' },
        { 'neck', 'DYN' },
        { 'left_ring', 'JUB' },
        { 'right_ring', 'JUB' },
    }

    -- The tokens for every hold now standing, in a fixed order, and the columns the group
    -- will occupy: the anchor plus a space and three cells per token, never measured. Idle
    -- costs one field read and two integer tests.
    --
    -- Emission order is the precedence stack's own, so the group never reflows as holds come
    -- and go: the disable hold stands directly below an item use and above the strip, and
    -- leads. Its token is drawn once however many slots it holds -- the hold is a count, not
    -- a mode word, and sixteen disabled slots are one hold to the reader.
    --
    -- Returning nothing when the walk emits nothing is the load-bearing part. locked_n counts
    -- every slot a lock mode holds and the table above names four; a mode holding any other
    -- slot would otherwise pass the gate, emit no token, and leave the box showing a bare
    -- anchor for a hold the reader cannot identify. The count the walk produced decides the
    -- anchor, not the gate that let it run.
    local function hold_tokens()
        if not E.strip_shape and E.locked_n == 0 and E.disabled_n == 0 then return nil, 0 end
        local t = {}
        if E.disabled_n > 0 then
            t[#t + 1] = cs(COLOR.cyan, DISABLE_TOKEN)
        end
        local shape = STRIP_TOKEN[E.strip_shape]
        if shape then t[#t + 1] = cs(COLOR.strip, shape) end
        if E.locked_n > 0 then
            local last
            for _, entry in ipairs(LOCK_TOKENS) do
                if locked[entry[1]] and entry[2] ~= last then
                    t[#t + 1] = cs(COLOR.lock, entry[2])
                    last = entry[2]
                end
            end
        end
        if #t == 0 then return nil, 0 end
        return t, 3 + 4 * #t
    end

    -- The color a mode's value is drawn in. The weapon lock has a row of its own, so a
    -- standing lock shows there as color rather than as a token in the hold group: the
    -- LCK value takes the lock color while the engine holds main and sub, and the
    -- ordinary value color otherwise -- the renderer's own where it passes one. Read
    -- from the resolved lock, not from the mode's value: a value set and not yet
    -- resolved draws plain.
    local function value_color(f, plain)
        if f.mode == 'WeaponLock' and E.lock_main_sub then return COLOR.lock end
        return plain or COLOR.value
    end

    -- The hold group as drawn: the HLD anchor in the label color -- the renderer's own
    -- where it passes one -- a space, then the tokens single-space separated. The anchor
    -- is padded out to the label column the way every other label is, so the tokens
    -- start under the values; a one-line view pads no label and passes nothing.
    -- Untagged, the group measures label_pad more than the width hold_tokens returned.
    local function hold_group(tokens, label_pad, color)
        return cs(color or COLOR.label, 'HLD' .. string.rep(' ', label_pad)) .. ' '
            .. table.concat(tokens, ' ')
    end

    -- The hold group as the last row of a stacked view, padded out to the box width. Five
    -- tokens draw twenty-three columns, six past the seventeen-cell crown classic's stacked
    -- view keeps, and that row runs past the box's edge uncut: string.rep pads nothing on
    -- a negative count. A crown carrying the job holds its box at nineteen or more --
    -- twenty-two with a bare main, twenty-six with a sub -- so no other row overruns.
    local function hold_row(tokens, hold_w)
        local label_pad = layout.label_w - 3
        return hold_group(tokens, label_pad)
            .. string.rep(' ', layout.box_w - label_pad - hold_w)
    end

    -- Rendering -----------------------------------------------------------------------------------

    -- The last string handed to each text object, so a redraw that composed the same box
    -- again does not hand it over a second time. Setting a text object's string discards its
    -- token tables, rescans the whole string for a substitution variable and crosses into the
    -- renderer, none of which is free at the rate these boxes redraw -- and one transition
    -- pays it twice today, since the weapon-mode handler repaints after the legacy bridge it
    -- calls has already repainted. Keyed on the OBJECT rather than on the box, so a renderer
    -- owning more than one text object carries a last string for each.
    local painted = {}

    -- The write comes before the record, so the cache only ever holds a string the object
    -- actually took: setting the text of a destroyed object raises, and recording first
    -- would leave the cache claiming a paint that never happened.
    local function paint(obj, str)
        if painted[obj] == str then return false end
        obj:text(str)
        painted[obj] = str
        return true
    end

    -- Forget what every object last showed, so the next redraw paints unconditionally. The
    -- twin of debug_box_reset, and used for the same reason: a box turned back on must draw
    -- rather than reappear holding whatever it last showed, and hiding a text object leaves
    -- its string in place.
    function display_box_reset() painted = {} end

    -- The renderer registry ------------------------------------------------------------------------

    -- Which renderer draws the status box. Every member is four keys bound to file-scope
    -- functions carrying names of their own, never functions written inline in the table: a
    -- name declared once can be lifted and driven on its own, where several members each
    -- spelling `enter = function(...)` inline would put several declarations of one name in
    -- the file.
    --
    -- classic is the engine's default box, and the fallback when a saved style names no
    -- renderer. Its enter and leave have nothing to build or tear down -- it owns the one
    -- text object, created at load and destroyed at unload -- and reset the paint guard,
    -- which is what every renderer's entry and exit owes the next one: a cache entry left by
    -- the renderer that just stepped aside would otherwise suppress the incoming renderer's
    -- first paint.

    -- The crown row: the three indicators, with the job in front of them where the layout
    -- carries it, spread across the box with one equal gap between each pair. Every stacked
    -- text style draws it, so the spacing is decided once here and in header_pads rather
    -- than in each composer.
    local function crown_row(label_color)
        local t = {}
        if layout.crown_job then
            local job = job_label()
            t[1] = job ~= '' and cs(label_color or COLOR.label, job) or ''
        end
        for _, g in ipairs(GLYPH_FIELDS) do t[#t + 1] = glyph_entry(g) end
        local row = t[1] .. layout.head_pad1 .. t[2] .. layout.head_pad2 .. t[3]
        if t[4] then row = row .. layout.head_pad3 .. t[4] end
        return row
    end

    -- The classic box as a single line: the job, the three indicators, then every mode as a
    -- chevroned value, with a standing hold as the last cell. Deliberately unpadded -- it
    -- flexes with the current values to stay as short as possible, so no column measurement
    -- applies to it.
    local function classic_compose_oneline(hold)
        local head = T {}
        local job = job_label()
        if job ~= '' then head:insert(cs(COLOR.label, job)) end
        for _, g in ipairs(GLYPH_FIELDS) do head:insert(glyph_entry(g)) end
        for _, f in ipairs(layout.fields) do
            head:insert(cs(COLOR.label, f.label) .. ' '
                .. cs(COLOR.chev, GLYPH.prev) .. ' '
                .. cs(value_color(f), mode_value(f)) .. ' '
                .. cs(COLOR.chev, GLYPH.next))
        end
        if hold then head:insert(hold_group(hold, 0)) end
        return head:concat(SEP)
    end

    -- The stacked view: the spread header, one padded row per field, and the hold group as
    -- a last row while any hold stands.
    local function classic_compose_stacked(hold, hold_w)
        local lines = T { crown_row() }
        for _, f in ipairs(layout.fields) do
            lines:insert(cs(COLOR.label, f.label .. string.rep(' ', layout.label_w - cells(f.label)))
                .. ' ' .. chevroned(mode_value(f), layout.value_w, value_color(f))
                .. string.rep(' ', math.max(0, layout.box_w - layout.row_w)))
        end
        if hold then lines:insert(hold_row(hold, hold_w)) end
        return lines:concat('\n')
    end

    -- Every renderer's compose takes the standing holds and their width, which the redraw
    -- asks for once and hands to whichever member draws.
    local function classic_compose(hold, hold_w)
        if settings.oneline then return classic_compose_oneline(hold) end
        return classic_compose_stacked(hold, hold_w)
    end

    local function classic_enter() display_box_reset() end
    local function classic_leave() display_box_reset() end

    -- harness packs the modes two to a row and retires the chevrons: a label is told from
    -- its value by color alone. It owns the same single text object classic does, so its
    -- entry and exit have nothing to build or tear down either.

    -- One mode as a fixed-width cell: the label padded out to the shared label column, a
    -- space, then the value padded out to the column measured for this mode. A value the
    -- option list does not offer -- a job file setting one outside its own options -- is
    -- truncated with the ellipsis the way a chevroned value is, so a cell can never overrun
    -- the width the layout measured for it. A column measured at nothing has no room even
    -- for the ellipsis and shows the label alone.
    local function mode_cell(f, vw)
        local v = mode_value(f)
        local n = cells(v)
        if n > vw then
            if vw < 1 then
                v, n = '', 0
            else
                v, n = cut(v, vw - 1) .. GLYPH.trunc, vw
            end
        end
        return cs(COLOR.label, f.label .. string.rep(' ', layout.label_w - cells(f.label)))
            .. ' ' .. cs(value_color(f), v) .. string.rep(' ', vw - n)
    end

    -- The stacked view: the spread header, then the cells packed two to a row, each row
    -- padded out to the box width so every line comes out one width, and the hold group
    -- as a last row of its own while any hold stands -- never packed beside a lone cell,
    -- so no mode row moves when a hold comes or goes.
    local function harness_compose_stacked(hold, hold_w)
        local lines = T { crown_row() }
        local fields, cell_w, label_w = layout.fields, layout.cell_w, layout.label_w
        for i = 1, #fields, 2 do
            local row, w = mode_cell(fields[i], cell_w[i]), label_w + 1 + cell_w[i]
            if fields[i + 1] then
                row = row .. SEP .. mode_cell(fields[i + 1], cell_w[i + 1])
                w = w + #SEP + label_w + 1 + cell_w[i + 1]
            end
            lines:insert(row .. string.rep(' ', layout.box_w - w))
        end
        if hold then lines:insert(hold_row(hold, hold_w)) end
        return lines:concat('\n')
    end

    -- The one-line view: the same label and value, padded nowhere, so the line stays as
    -- short as the current values make it -- the rule classic's one-line view follows too.
    -- A standing hold is the last cell.
    local function harness_compose_oneline(hold)
        local head = T {}
        local job = job_label()
        if job ~= '' then head:insert(cs(COLOR.label, job)) end
        for _, g in ipairs(GLYPH_FIELDS) do head:insert(glyph_entry(g)) end
        for _, f in ipairs(layout.fields) do
            head:insert(cs(COLOR.label, f.label) .. ' '
                .. cs(value_color(f), mode_value(f)))
        end
        if hold then head:insert(hold_group(hold, 0)) end
        return head:concat(SEP)
    end

    local function harness_compose(hold, hold_w)
        if settings.oneline then return harness_compose_oneline(hold) end
        return harness_compose_stacked(hold, hold_w)
    end

    local function harness_enter() display_box_reset() end
    local function harness_leave() display_box_reset() end

    -- LATTICE ------------------------------------------------------------------------------------

    -- The hold map, defined with the debug box far below and read by the rig here. Declared
    -- above its first use: read above its declaration a local is a global nil.
    local hold_state

    -- classic's text over a drawn panel: a body where the box's own background would be, a
    -- border one width wide around it, and in the stacked view a strip behind the header
    -- line. Six primitives, none overlapping, written through windower.prim directly; the
    -- text object draws over them. Every color and inset is a setting.
    local LATTICE_PRIMS = {
        'gs_lattice_strip', 'gs_lattice_body',
        'gs_lattice_top', 'gs_lattice_bottom', 'gs_lattice_left', 'gs_lattice_right',
    }
    -- The recess the grid sits in: one rectangle behind the sixteen, framing them by an
    -- inset on every side so the cells read as raised out of it rather than floating.
    local LATTICE_RIGBG = 'gs_lattice_rigbg'
    -- The rig: one primitive per gear slot, in the order the game's own equipment window
    -- lays them out, which is SLOT_ORDER's. Cell k draws SLOT_ORDER[k]. A second list, not
    -- appended to the six: the border loop below colors everything past the second name, and
    -- the show loops carry a rule the cells do not share -- the body in either view, the
    -- strip and the four edges only while the box has more than one line.
    local LATTICE_CELLS = {
        'gs_lattice_cell1',  'gs_lattice_cell2',  'gs_lattice_cell3',  'gs_lattice_cell4',
        'gs_lattice_cell5',  'gs_lattice_cell6',  'gs_lattice_cell7',  'gs_lattice_cell8',
        'gs_lattice_cell9',  'gs_lattice_cell10', 'gs_lattice_cell11', 'gs_lattice_cell12',
        'gs_lattice_cell13', 'gs_lattice_cell14', 'gs_lattice_cell15', 'gs_lattice_cell16',
    }
    local chassis = false     -- true while the panel's primitives stand
    local last_fit = false    -- the placement last written: x, y, w, h, the line count, the band
    local last_lines = 1      -- lines in the string last painted, which decides the strip
    local refit_armed = false -- a deferred fit is scheduled and has not run yet
    local rig_fresh = false   -- the next color pass writes all sixteen, whatever the map says
    -- How long after a paint the panel is fitted. The renderer answers a box's size from
    -- its last render, not from the text just written, so the fit waits for a frame.
    local LATTICE_REFIT_DELAY = 0.05

    -- The box's top-left in screen pixels. The text library keeps a position relative to
    -- the right or bottom edge when the box is anchored there and adds the screen size when
    -- it places the object; the panel adds the same, reading the screen size only when an
    -- anchor flag is set.
    local function lattice_box()
        local x, y = gs_status:pos()
        local flags = settings.Display_Box.flags
        if flags.right or flags.bottom then
            local screen = windower.get_windower_settings()
            if flags.right then x = x + screen.ui_x_res end
            if flags.bottom then y = y + screen.ui_y_res end
        end
        return x, y
    end

    -- How many text columns the layout sets aside at the right of every mode row: the
    -- grid's own, plus a gutter between the widest row and the grid so the two never touch
    -- whatever the crown's three-gap rounding happens to leave. The grid lives inside the
    -- box rather than in a band beside it, so the crown -- which is wider than the rows and
    -- spans the whole panel -- has that space under its right-hand end and the grid draws
    -- there. Zero where the rig is off, and the box is then the box classic would have
    -- measured, to the column.
    --
    -- This is a property of the LAYOUT, and the layout is the same in both views -- the
    -- one-line view simply draws no grid over the columns (lattice_rig_metrics). It must
    -- not read the view: the view toggle flips the flag and rebuilds nothing, so a layout
    -- built one-line would carry no reservation into the stacked view and the grid would be
    -- drawn over the rows' own columns.
    local function lattice_rig_cols()
        local rig = settings.Lattice.rig
        if not rig.enabled then return 0 end
        local cols = math.max(math.floor(tonumber(rig.cols) or 0), 0)
        if cols == 0 then return 0 end
        return cols + math.max(math.floor(tonumber(rig.gutter) or 0), 0)
    end

    -- The layout LATTICE measures: classic's, with the rig's columns reserved.
    local function lattice_layout()
        build_layout(lattice_rig_cols())
    end

    -- The rig's cell WIDTH for reserved columns rw wide, and the width the four columns
    -- occupy, both zero where no grid is drawn. The grid hangs from the BOTTOM of the
    -- strip -- the first mode row's line -- and stays there whatever the row count, so a
    -- hold appearing below never moves it. The height is not
    -- decided here: the rows ride the text's line grid so that each lines up with the mode
    -- row beside it, which makes their depth a property of the font, not of the panel.
    -- What this must still refuse is a grid with nowhere to go -- four rows at the line's
    -- pitch need four mode rows under the crown, and a box carrying only the three modes
    -- every job has cannot hold one.
    local function lattice_rig_metrics(rw)
        local rig = settings.Lattice.rig
        if not rig.enabled or settings.oneline or rw <= 0 then return 0, 0 end
        local cell = math.floor((rw - 2 * rig.inset - 3 * rig.gap) / 4)
        if cell < 1 then return 0, 0 end
        return cell, 4 * cell + 3 * rig.gap
    end

    -- How deep one row of the grid is, and how tall a cell in it. Four rows at the text's
    -- own line pitch line each cell up with the mode row beside it, and that is what ships
    -- wherever there are four mode rows under the crown to line up WITH. A box carrying
    -- only the three modes every job has cannot hold four aligned rows, so there the grid
    -- compresses to the depth that is free instead: alignment is the thing given up, never
    -- the grid itself.
    local function lattice_rig_rows(line_h, n, room, gap)
        -- Four mode rows under the crown: the rows take the line's pitch whatever depth
        -- is free, because the PANEL grows to hold them (lattice_place). Fewer: compress.
        if (n - 1) >= 4 then
            return line_h, math.max(1, math.floor(line_h) - gap)
        end
        local cell_h = math.floor((room - 3 * gap) / 4)
        return cell_h + gap, cell_h
    end

    -- Write the six positions, and the six sizes when asked, for a box at x, y measuring w
    -- by h and holding n lines; then the recess and the sixteen where a grid is drawn. The
    -- strip is the top band inside the border, the box's padding plus one line deep, and
    -- has no height for a one-line box; the body is the rest, and the panel is as deep as
    -- the deeper of the box and an aligned grid. Returns the grid's width, zero where none
    -- is drawn, which the caller records: the show and hide arms need it and cannot
    -- recompute it.
    local function lattice_place(x, y, w, h, n, sizes)
        local L = settings.Lattice
        local pad, bw = L.pad, L.border.width
        -- Everything about the crown's band is derived from the box the renderer was
        -- handed, because the box changes with the job, the mode values and the font.
        -- h is the box's whole footprint and carries its padding at both ends, so the
        -- line height is (h - 2 * box_pad) / n and never h / n, which over-counts by the
        -- padding.
        local box_pad = tonumber(settings.Display_Box.padding) or 0
        local line_h = n > 0 and (h - 2 * box_pad) / n or h
        -- The band runs from the box's top edge to the first mode row's line: the box's
        -- own padding plus one line. So the panel's top edge is the box's, the band ends
        -- exactly where STN's line begins, and on a 19 px line the crown sits 8 px above
        -- its ink and 5.6 below -- a shade high of center by the box's padding, which is
        -- the price of the panel not starting inside the text object. The band must not
        -- grow past that line: the slack under the crown's ink IS the row gap, so any
        -- extra band depth is taken out of it pixel for pixel. In the one-line view there
        -- is no band.
        local band_y = y
        local sh = n > 1 and math.floor(box_pad + line_h) or 0
        local band_bottom = n > 1 and band_y + sh or y
        local x0, y0 = x - pad - bw, y - bw
        local W = w + 2 * pad + 2 * bw
        local ix, iy, iw = x0 + bw, y0 + bw, W - 2 * bw
        -- One column in pixels, measured from the box itself: its rendered TEXT width --
        -- the footprint less the box's own padding at each side, inside w the way it is
        -- inside h -- over its column count. Nothing here assumes a font. The grid takes
        -- the LAST rig.cols columns, and the gutter the layout reserved beside them stays
        -- empty between the widest row and the grid; res_x is that boundary exactly, not
        -- the padded footprint less an over-measured reservation.
        local cols = L.rig.enabled and math.max(math.floor(tonumber(L.rig.cols) or 0), 0) or 0
        local box_cols = (layout and layout.box_w and layout.box_w > 0) and layout.box_w or 0
        local pc = box_cols > 0 and (w - 2 * box_pad) / box_cols or 0
        local rw = (cols > 0 and pc > 0) and math.floor(cols * pc) or 0
        local res_x = x + box_pad + math.floor((box_cols - cols) * pc)
        local cell, side = lattice_rig_metrics(rw)
        -- The grid rides the TEXT's line grid, not the panel's. Its recess sits ON the
        -- band's bottom edge -- the first mode row's line -- and the cells start one
        -- inset below that, so row r's cell top lands a pixel above mode row r's ink,
        -- which is where "lined up" is seen; the vertical pitch IS line_h, and nothing else
        -- -- a pitch built from `cell + gap` rounds away from the text's grid and drifts
        -- apart from it down the panel.
        --
        -- An aligned grid is four lines deep plus its recess, one pixel more than a
        -- five-line box: the PANEL grows to hold the grid, never the grid to fit the
        -- panel. Under four mode rows there is nothing to line up with, and the grid
        -- compresses into the depth that is free.
        local gap, inset = L.rig.gap, L.rig.inset
        local gy = band_bottom
        local interior_bottom = y + h + L.pad_bottom
        local pitch, cell_h, frame_w, frame_h
        if side > 0 then
            local room = interior_bottom - inset - (gy + inset)
            pitch, cell_h = lattice_rig_rows(line_h, n, room, gap)
            if cell_h >= 1 then
                frame_w = side + 2 * inset
                frame_h = math.floor(3 * pitch) + cell_h + 2 * inset
                interior_bottom = math.max(interior_bottom, gy + frame_h)
            else
                side = 0
            end
        end
        local H = interior_bottom - y + 2 * bw
        local ih = H - 2 * bw
        local prim = windower.prim
        prim.set_position('gs_lattice_strip', ix, band_y)
        prim.set_position('gs_lattice_body', ix, band_bottom)
        prim.set_position('gs_lattice_top', x0, y0)
        prim.set_position('gs_lattice_bottom', x0, y0 + H - bw)
        prim.set_position('gs_lattice_left', x0, y0 + bw)
        prim.set_position('gs_lattice_right', x0 + W - bw, y0 + bw)
        if sizes then
            prim.set_size('gs_lattice_strip', iw, sh)
            prim.set_size('gs_lattice_body', iw, iy + ih - band_bottom)
            prim.set_size('gs_lattice_top', W, bw)
            prim.set_size('gs_lattice_bottom', W, bw)
            prim.set_size('gs_lattice_left', bw, ih)
            prim.set_size('gs_lattice_right', bw, ih)
        end
        -- Nothing is written for the sixteen where no grid is drawn: they are hidden there,
        -- and placing primitives nobody shows is thirty-two crossings for no picture.
        if side > 0 then
            local rx = res_x + math.floor((rw - frame_w) / 2)
            prim.set_position('gs_lattice_rigbg', rx, gy)
            local gx, cy = rx + inset, gy + inset
            for k = 1, #LATTICE_CELLS do
                local col, row = (k - 1) % 4, math.floor((k - 1) / 4)
                prim.set_position(LATTICE_CELLS[k],
                    gx + col * (cell + gap), math.floor(cy + row * pitch))
            end
            if sizes then
                prim.set_size('gs_lattice_rigbg', frame_w, frame_h)
                for k = 1, #LATTICE_CELLS do prim.set_size(LATTICE_CELLS[k], cell, cell_h) end
            end
        end
        return side
    end

    -- Place the six for a box at x, y from the size the renderer answers now: nothing is
    -- written while the placement is the one last written; the six are shown on their
    -- first placement if the box is shown -- the body in either view, the strip and the
    -- four edges of the border only while the box has more than one line -- and those
    -- five flip when the line count crosses one. A one-line box is the body alone: no
    -- band and no ring around it.
    local function lattice_settle(x, y)
        local w, h = gs_status:extents()
        local n = last_lines
        local f = last_fit
        if f and f.x == x and f.y == y and f.w == w and f.h == h and f.n == n then return end
        local side = lattice_place(x, y, w, h, n, not f or f.w ~= w or f.h ~= h or f.n ~= n)
        local prim = windower.prim
        if not f then
            if settings.visible then
                for i = 1, #LATTICE_PRIMS do
                    local name = LATTICE_PRIMS[i]
                    prim.set_visibility(name, name == 'gs_lattice_body' or n > 1)
                end
                prim.set_visibility(LATTICE_RIGBG, side > 0)
                for i = 1, #LATTICE_CELLS do prim.set_visibility(LATTICE_CELLS[i], side > 0) end
            end
        elseif settings.visible then
            -- The two crossings a settle can carry. A view change reaches the panel here and
            -- never through lattice_visible, which only the display toggle calls -- so the
            -- rig needs its own arm beside the strip and border's or it stands on in a
            -- one-line box that draws no grid.
            if (f.n > 1) ~= (n > 1) then
                for i = 1, #LATTICE_PRIMS do
                    local name = LATTICE_PRIMS[i]
                    if name ~= 'gs_lattice_body' then prim.set_visibility(name, n > 1) end
                end
            end
            if (f.side > 0) ~= (side > 0) then
                prim.set_visibility(LATTICE_RIGBG, side > 0)
                for i = 1, #LATTICE_CELLS do prim.set_visibility(LATTICE_CELLS[i], side > 0) end
            end
        end
        last_fit = { x = x, y = y, w = w, h = h, n = n, side = side }
    end

    -- The deferred fit, a frame after a paint that changed the text, once the box has
    -- rendered at its new size.
    local function lattice_refit()
        refit_armed = false
        if not chassis then return end
        local x, y = lattice_box()
        lattice_settle(x, y)
    end

    -- Color the sixteen from the hold map: the layer holding each slot, or the socket color
    -- where the slot is free. Asked under the rig's own name, so the answer is "changed
    -- since the RIG last asked" and the debug box's own answer is left alone. A hue the
    -- settings do not name -- the three layers with no color of their own, and any layer
    -- slot_claim grows later -- draws the neutral, never the socket: a dark cell means free,
    -- and saying free about a held slot is the interface misleading its reader.
    local function lattice_rig_colors()
        local map, _, moved = hold_state('rig')
        if not moved and not rig_fresh then return end
        rig_fresh = false
        local rig = settings.Lattice.rig
        local prim = windower.prim
        for k = 1, #LATTICE_CELLS do
            local owner = map[k]
            local c = owner == nil and rig.socket or rig.hue[owner] or rig.hue.other
            prim.set_color(LATTICE_CELLS[k], c.alpha, c.red, c.green, c.blue)
        end
    end

    -- Fit the panel after a redraw. A paint that wrote arms the deferred fit, once, and
    -- places nothing itself; a box that only moved is placed at once, its rendered size
    -- being current.
    --
    -- The color pass runs FIRST, above every return below it. A cell's owner does not
    -- depend on the box's rendered size, so it must not wait for the deferred fit; and four
    -- of the eight layers put no token in the string, so their repaints arrive with wrote
    -- false and a box that has not moved -- which is every return this function has.
    local function lattice_fit(wrote)
        if not chassis then return end
        lattice_rig_colors()
        if wrote then
            if not refit_armed then
                refit_armed = true
                coroutine.schedule(lattice_refit, LATTICE_REFIT_DELAY)
            end
            return
        end
        local x, y = lattice_box()
        local f = last_fit
        if f and f.x == x and f.y == y then return end
        lattice_settle(x, y)
    end

    -- The box's drag event: the text library has already moved the box when it fires, so
    -- the panel is placed at the box's new position with the sizes it already has.
    local function lattice_on_drag()
        local f = last_fit
        if not chassis or not f then return end
        local x, y = lattice_box()
        local side = lattice_place(x, y, f.w, f.h, f.n, false)
        f.x, f.y = x, y
        -- A drag inside the window between a subjob change and its repaint has no layout
        -- to place the grid from, so the sixteen and their recess stay where they were:
        -- the placement is forgotten, and the settle the repaint arms places them too.
        if side ~= f.side then last_fit = nil end
    end

    -- Show or hide the six with the box: the body wherever the box is, the strip and the
    -- four edges only where they are drawn, which is the stacked view. Six not yet placed
    -- stay hidden; the fit that places them shows them.
    local function lattice_visible(on)
        if not chassis then return end
        if on and not last_fit then return end
        local prim = windower.prim
        local stacked = on and (last_fit and last_fit.n or 1) > 1 or false
        local cells = on and (last_fit and last_fit.side or 0) > 0 or false
        for i = 1, #LATTICE_PRIMS do
            local name = LATTICE_PRIMS[i]
            prim.set_visibility(name, name == 'gs_lattice_body' and on or stacked)
        end
        prim.set_visibility(LATTICE_RIGBG, cells)
        for i = 1, #LATTICE_CELLS do prim.set_visibility(LATTICE_CELLS[i], cells) end
    end

    -- Turn the box's own background off and follow its drags, then create and color the
    -- six. The box is touched first: a destroyed box raises on it, and raising before any
    -- primitive exists leaves none standing with no owner. A second entry while the panel
    -- stands creates nothing.
    local function lattice_enter()
        if not chassis then
            -- The text library keeps the box's settings block as its own and writes the
            -- background flag into it, so the saved value is put back after the write: the
            -- background is off while the panel stands, while what a save persists, and
            -- what leave restores from, stays the value the player had.
            local bg = settings.Display_Box.bg
            local saved = bg.visible
            gs_status:bg_visible(false)
            bg.visible = saved
            gs_status:register_event('drag', lattice_on_drag)
            local L, prim = settings.Lattice, windower.prim
            for i = 1, #LATTICE_PRIMS do prim.create(LATTICE_PRIMS[i]) end
            prim.set_color('gs_lattice_strip', L.strip.alpha, L.strip.red, L.strip.green, L.strip.blue)
            prim.set_color('gs_lattice_body', L.body.alpha, L.body.red, L.body.green, L.body.blue)
            for i = 3, #LATTICE_PRIMS do
                prim.set_color(LATTICE_PRIMS[i], L.border.alpha, L.border.red, L.border.green, L.border.blue)
            end
            -- The rig is created AFTER the six because primitives draw in creation order
            -- and these are the ones that overlap: the recess over the body, the cells over
            -- the recess. The recess's color is fixed, so it is set here; the cells' comes
            -- from the first repaint, never from entry, so one function owns it.
            prim.create(LATTICE_RIGBG)
            local R = L.rig.recess
            prim.set_color(LATTICE_RIGBG, R.alpha, R.red, R.green, R.blue)
            for i = 1, #LATTICE_CELLS do prim.create(LATTICE_CELLS[i]) end
            -- Hidden until the first fit places them, whatever a new primitive's own
            -- visibility is.
            for i = 1, #LATTICE_PRIMS do prim.set_visibility(LATTICE_PRIMS[i], false) end
            prim.set_visibility(LATTICE_RIGBG, false)
            for i = 1, #LATTICE_CELLS do prim.set_visibility(LATTICE_CELLS[i], false) end
            chassis = true
        end
        last_fit = false
        -- Sixteen primitives with no color yet, so the next pass writes all of them however
        -- long the map has stood still.
        rig_fresh = true
        display_box_reset()
    end

    -- Delete every primitive the panel created and give the box its background back.
    local function lattice_leave()
        if chassis then
            local prim = windower.prim
            gs_status:unregister_event('drag', lattice_on_drag)
            for i = 1, #LATTICE_PRIMS do prim.delete(LATTICE_PRIMS[i]) end
            prim.delete(LATTICE_RIGBG)
            for i = 1, #LATTICE_CELLS do prim.delete(LATTICE_CELLS[i]) end
            gs_status:bg_visible(settings.Display_Box.bg.visible)
            chassis = false
        end
        last_fit = false
        rig_fresh = true
        display_box_reset()
    end

    -- HALO ---------------------------------------------------------------------------------------

    -- No background on any object, and four text objects at one position, one per plane:
    -- the crown row of state tokens, the mode labels, the mode values and the hold
    -- tokens, each object carrying its own stroke width, weight and hue. Every plane's
    -- string is the whole grid with spaces where the other planes draw, so the renderer's
    -- monospace grid aligns them and nothing is positioned. The mode box is the values
    -- plane and the drag anchor; the other three are satellites created on entry and
    -- destroyed on leaving, following the box's drags.
    local HALO_PLANES = { 'crown', 'labels', 'hold' } -- the satellites, in creation order
    local satellites = false      -- name -> text object while the style stands
    local satellite_text = {}     -- what each satellite is to show, composed beside the box's string
    local halo_hue = {}           -- the plane hues as color strings, read from the settings at entry
    local halo_placed = false     -- the box position the satellites were last placed at: x, y

    -- A mode's value for the values plane: cut to the cap with the ellipsis when a cap
    -- is set, the whole value otherwise. The cap is a setting, read through tonumber the
    -- way the value-column floor is; nothing usable as a width means no cap.
    local function halo_value(f)
        local v = mode_value(f)
        local cap = tonumber(settings.Halo.value_cap)
        if not cap or cap ~= cap or cap < 1 or cap == math.huge then return v end
        cap = math.floor(cap)
        if cells(v) > cap then v = cut(v, cap - 1) .. GLYPH.trunc end
        return v
    end

    -- The crown: the three indicators as their labels alone, each in the hue of its
    -- state, one line, the same in both views.
    local function halo_crown()
        local t = {}
        local job = job_label()
        if job ~= '' then t[1] = cs(halo_hue.label, job) end
        for _, g in ipairs(GLYPH_FIELDS) do
            local m = state[g.mode]
            local v = m and tostring(m.value) or ''
            t[#t + 1] = cs(halo_hue[glyph_class(g, v)], g.label)
        end
        return table.concat(t, SEP)
    end

    -- The stacked view: the crown on the first row; the labels at the left edge and the
    -- values one column past the label column, one row per field; the hold group on the
    -- row after the last field while any hold stands. Returns the four planes' strings:
    -- crown, labels, values, hold.
    local function halo_compose_stacked(hold)
        local fields, label_w = layout.fields, layout.label_w
        local labels, values = {}, {}
        local indent = string.rep(' ', label_w + 1)
        for i, f in ipairs(fields) do
            labels[i] = f.label
            values[i] = indent .. cs(value_color(f, halo_hue.value), halo_value(f))
        end
        local hold_str = ''
        if hold then
            hold_str = string.rep('\n', 1 + #fields) .. hold_group(hold, 0, halo_hue.label)
        end
        return halo_crown(), '\n' .. table.concat(labels, '\n'),
            '\n' .. table.concat(values, '\n'), hold_str
    end

    -- The one-line view: the crown, then each field as its label, a space and its value,
    -- then the hold group, separated by SEP -- and each plane's string carries spaces
    -- where the cells of the other planes fall, measured on the untagged text, so the
    -- four lines lie on one grid. A plane ends at its last cell; a plane with nothing on
    -- the line is empty.
    local function halo_compose_oneline(hold, hold_w)
        -- Every cell on the line in order: the plane drawing it, its text, its width.
        local line = {}
        local function cell(plane, text, w)
            line[#line + 1] = { plane = plane, text = text, w = w }
        end
        -- The crown's width must count everything halo_crown draws, the job included, or
        -- the planes to its right are placed over the columns it occupies.
        local crown_w = 0
        local job = job_label()
        if job ~= '' then crown_w = #job + #SEP end
        for i, g in ipairs(GLYPH_FIELDS) do
            crown_w = crown_w + #g.label
            if i > 1 then crown_w = crown_w + #SEP end
        end
        cell('crown', halo_crown(), crown_w)
        for _, f in ipairs(layout.fields) do
            local v = halo_value(f)
            cell('sep', SEP, #SEP)
            cell('labels', f.label, cells(f.label))
            cell('sep', ' ', 1)
            cell('values', cs(value_color(f, halo_hue.value), v), cells(v))
        end
        if hold then
            cell('sep', SEP, #SEP)
            cell('hold', hold_group(hold, 0, halo_hue.label), hold_w)
        end
        local function plane_string(plane)
            local out, last = {}, 0
            for i, c in ipairs(line) do
                if c.plane == plane then
                    out[i] = c.text
                    last = i
                else
                    out[i] = string.rep(' ', c.w)
                end
            end
            if last == 0 then return '' end
            return table.concat(out, '', 1, last)
        end
        return plane_string('crown'), plane_string('labels'), plane_string('values'),
            plane_string('hold')
    end

    -- Every composer takes the standing holds; this one composes all four planes, keeps
    -- the three satellites' strings for the fit that follows the box's paint, and returns
    -- the values plane, which is the box's own string.
    local function halo_compose(hold, hold_w)
        local crown, labels, values, hold_str
        if settings.oneline then
            crown, labels, values, hold_str = halo_compose_oneline(hold, hold_w)
        else
            crown, labels, values, hold_str = halo_compose_stacked(hold, hold_w)
        end
        satellite_text.crown, satellite_text.labels, satellite_text.hold = crown, labels, hold_str
        return values
    end

    -- HALO measures nothing but the fields and the label column.
    local function halo_layout()
        local fields, label_w = status_fields()
        layout = { fields = fields, label_w = label_w }
    end

    -- Put the three satellites where the box is. A satellite the entry did not finish
    -- constructing is skipped, here and below, so a raise mid-entry leaves nothing that
    -- raises again on the way out.
    local function halo_place(x, y)
        for i = 1, #HALO_PLANES do
            local t = satellites[HALO_PLANES[i]]
            if t then t:pos(x, y) end
        end
        halo_placed.x, halo_placed.y = x, y
    end

    -- The box's drag event: the text library has already moved the box when it fires.
    local function halo_on_drag()
        if not satellites then return end
        halo_place(gs_status:pos())
    end

    -- After the box's paint: each satellite takes its string through the guard, and the
    -- three follow the box if it moved without a drag, as gs c zero moves it.
    local function halo_fit()
        if not satellites then return end
        for i = 1, #HALO_PLANES do
            local name = HALO_PLANES[i]
            local t = satellites[name]
            if t then paint(t, satellite_text[name] or '') end
        end
        local x, y = gs_status:pos()
        if x ~= halo_placed.x or y ~= halo_placed.y then halo_place(x, y) end
    end

    -- Show or hide the three with the box.
    local function halo_visible(on)
        if not satellites then return end
        for i = 1, #HALO_PLANES do
            local t = satellites[HALO_PLANES[i]]
            if t then
                if on then t:show() else t:hide() end
            end
        end
    end

    -- Make the box the values plane and create the three satellites. The text library
    -- keeps the box's settings block as its own and writes every setter into it, so the
    -- saved background flag, stroke width and weight are put back after the writes: what
    -- a save persists and what leave restores is the value the player had. Each
    -- satellite is constructed on its own block with no root settings, so the library
    -- neither saves the settings file nor registers the object at construction; the
    -- block takes the box's font, size, padding and edge anchoring first, so the four
    -- share one grid, and its position is the box's. Dragging is refused at construction
    -- and stated again after it. A second entry while the three stand creates nothing.
    local function halo_enter()
        display_box_reset()
        if satellites then return end
        local H, box = settings.Halo, settings.Display_Box
        local bg, width, bold = box.bg.visible, box.text.stroke.width, box.flags.bold
        gs_status:bg_visible(false)
        gs_status:stroke_width(H.values.stroke_width)
        gs_status:bold(H.values.bold)
        box.bg.visible, box.text.stroke.width, box.flags.bold = bg, width, bold
        gs_status:register_event('drag', halo_on_drag)
        for name, c in pairs(H.hue) do
            halo_hue[name] = c.red .. ',' .. c.green .. ',' .. c.blue
        end
        local x, y = gs_status:pos()
        satellites = {}
        halo_placed = { x = x, y = y }
        for i = 1, #HALO_PLANES do
            local name = HALO_PLANES[i]
            local blk = H[name]
            blk.text.font, blk.text.size, blk.padding = box.text.font, box.text.size, box.padding
            blk.text.fonts = { unpack(box.text.fonts) }
            blk.flags.right, blk.flags.bottom = box.flags.right, box.flags.bottom
            blk.flags.draggable = false
            blk.bg.visible = false
            blk.pos.x, blk.pos.y = x, y
            local t = texts.new('', blk)
            t:draggable(false)
            if settings.visible then t:show() else t:hide() end
            -- A new object shows nothing, which the guard records so an empty plane is
            -- not written a second time.
            painted[t] = ''
            satellites[name] = t
        end
    end

    -- Destroy the three and give the box back its own background, stroke and weight,
    -- from its block, which entry left untouched.
    local function halo_leave()
        if satellites then
            gs_status:unregister_event('drag', halo_on_drag)
            for i = 1, #HALO_PLANES do
                local t = satellites[HALO_PLANES[i]]
                if t then t:destroy() end
            end
            satellites = false
            halo_placed = false
            satellite_text = {}
            local box = settings.Display_Box
            gs_status:bg_visible(box.bg.visible)
            gs_status:stroke_width(box.text.stroke.width)
            gs_status:bold(box.flags.bold)
        end
        display_box_reset()
    end

    -- What a renderer owning no object of its own answers a fit or a visibility change with.
    local function renderer_noop()
    end

    local RENDERERS = {
        classic = {
            enter = classic_enter,
            leave = classic_leave,
            layout = classic_layout,
            compose = classic_compose,
            fit = renderer_noop,
            visible = renderer_noop,
        },
        harness = {
            enter = harness_enter,
            leave = harness_leave,
            layout = harness_layout,
            compose = harness_compose,
            fit = renderer_noop,
            visible = renderer_noop,
        },
        lattice = {
            enter = lattice_enter,
            leave = lattice_leave,
            layout = lattice_layout,
            compose = classic_compose,
            fit = lattice_fit,
            visible = lattice_visible,
        },
        halo = {
            enter = halo_enter,
            leave = halo_leave,
            layout = halo_layout,
            compose = halo_compose,
            fit = halo_fit,
            visible = halo_visible,
        },
    }

    -- The renderer the style names, or classic. An unknown style falls back rather than
    -- refusing: the setting is a plain string a player can put in the settings file by hand,
    -- and a box that stops drawing is worse than one that draws the default.
    local function active_renderer()
        return RENDERERS[settings.Display_Style] or RENDERERS.classic
    end

    -- Whether the renderer the settings name has been entered. A style switch enters and
    -- leaves on its own; the first redraw enters whatever style was saved, so a client
    -- loading with a style saved gets that renderer's objects.
    local renderer_entered = false

    -- Redraw the mode box from current state. Called from every command that changes
    -- anything the box shows, which is why it has to be cheap on the common path.
    function display_box_update()
        if not renderer_entered then
            renderer_entered = true
            active_renderer().enter()
        end
        -- Nothing to paint while the box is hidden. The display toggle sets this flag
        -- BEFORE calling back here, so turning the box on still produces a repaint.
        if not settings.visible then return end
        local renderer = active_renderer()
        if not layout then renderer.layout() end
        -- The standing holds are asked for once, here, and handed to whichever member
        -- draws: the answer is the same for every renderer and every view.
        local str = renderer.compose(hold_tokens())
        local wrote = paint(gs_status, str)
        -- The line count is what a panel behind the box needs, and it is counted only
        -- when the string actually changed.
        if wrote then
            local n, at = 1, 0
            while true do
                at = str:find('\n', at + 1, true)
                if not at then break end
                n = n + 1
            end
            last_lines = n
        end
        renderer.fit(wrote)
    end

    -- The order the styles are offered and cycled in. Membership is the registry's -- a
    -- name here that has no member is not offered -- so this list decides presentation
    -- order only, and a style cannot be selected before its renderer exists.
    local STYLE_ORDER = { 'classic', 'harness', 'lattice', 'halo' }

    -- The styles this build actually offers, in that order.
    local function display_styles()
        local out = {}
        for _, name in ipairs(STYLE_ORDER) do
            if RENDERERS[name] then out[#out + 1] = name end
        end
        return out
    end

    -- Switch renderers: the one standing steps aside, the new one takes over, and the box is
    -- redrawn. A name the registry does not offer is refused, so the caller can say what the
    -- choices are. Selecting the style already standing repaints and nothing else.
    local function set_display_style(word)
        if not RENDERERS[word] then return false end
        if settings.Display_Style ~= word then
            -- The outgoing renderer's measurement leaves with it. The column layout is one
            -- cache shared by every member, so a renderer that measures its columns its own
            -- way would otherwise compose against whichever one happened to build it first.
            if renderer_entered then active_renderer().leave() end
            invalidate_layout()
            settings.Display_Style = word
            active_renderer().enter()
            renderer_entered = true
        end
        display_box_update()
        return true
    end

    -- The display toggle's word to the renderer standing: a renderer owning objects of
    -- its own shows or hides them with the box.
    local function display_visible(on)
        active_renderer().visible(on)
    end

    -- The teardown's first step: the renderer standing steps aside while the status box
    -- still exists, since leaving touches the box.
    local function display_unload()
        if renderer_entered then
            renderer_entered = false
            active_renderer().leave()
        end
    end

    -- Write settings to disk, and say what happened. Every save in the engine goes through
    -- this one function, including the silent one a box drag performs.
    --
    -- The logged-in test is the point of it. The config library will not write while no
    -- character is resolvable, which is the case throughout a zone, and it fails quietly --
    -- so a save attempted mid-zone would look successful and be lost. Refusing here means
    -- the caller is told, and gets a boolean it can act on.
    local function save_settings(saved_msg)
        if not windower.ffxi.get_info().logged_in then
            notice('Cannot save while zoning - try again in a moment.')
            return false
        end
        config.save(settings)
        notice(saved_msg or 'Settings saved')
        return true
    end

    -- Say which silos the load reset, and save the stamps and the reset values. Scheduled
    -- by the root once the client has settled. A save refused while zoning leaves the stamp
    -- unsaved, and the next load repeats the reset onto values that are already default.
    function settings_reset_announce()
        local reset = E.settings_reset
        if not reset or #reset == 0 then return end
        for i = 1, #reset do
            local silo = reset[i]
            local line = silo:sub(1, 1):upper() .. silo:sub(2) .. ' settings reset to defaults (version '
                .. tostring(E.settings_versions[silo]) .. ')'
            if silo == 'display' then line = line .. '; box positions kept' end
            notice(line)
        end
        save_settings()
    end

    -- Put both boxes back where they can be seen: the mode box in the top-left corner and
    -- the debug box a hundred pixels below it, so they do not land on top of each other.
    -- The recovery for a box dragged off-screen.
    function display_zero_command()
        gs_status:pos_x(0)
        gs_status:pos_y(0)
        gs_debug:pos_x(0)
        gs_debug:pos_y(100)
        -- The redraw moves whatever the renderer standing draws around the box.
        display_box_update()
        save_settings("Displays reset and settings saved")
    end

    -- The hold map --------------------------------------------------------------------------------

    -- The sixteen canonical slot names, in the order the game's own equipment window lays
    -- them out, which is the order the debug box and the rig both draw them in: the set
    -- every spelling in CANON_SLOT maps onto, and the keys every hold registry is kept by.
    local SLOT_ORDER = {
        'main', 'sub', 'range', 'ammo',
        'head', 'neck', 'left_ear', 'right_ear',
        'body', 'hands', 'left_ring', 'right_ring',
        'back', 'waist', 'legs', 'feet',
    }

    -- Whether any layer holds any slot: one operand per layer of the precedence stack, in
    -- its order, each the cheapest read that layer offers, so the idle answer is nine reads
    -- and no walk. The Hoxne hold takes range and ammo together, so asking about range
    -- answers for both. active_external_locks is read as the global it is: the spell-received
    -- component replaces that table wholesale, so a reference taken at construction would
    -- go on answering for a table nothing writes to.
    local function any_hold()
        return E.ench_held_slot ~= nil
            or E.disabled_n > 0
            or E.strip_shape ~= nil
            or hoxne_owns_slot('range')
            or next(sleep_held) ~= nil
            or next(implement_held) ~= nil
            or next(active_external_locks) ~= nil
            or E.locked_n > 0
            or E.lock_main_sub
    end

    -- The owner of every slot, in one table reused across calls: entry i is the layer
    -- holding SLOT_ORDER[i], or nil where ordinary gear may have it. The second result says
    -- whether anything is held at all; the third whether any entry has changed since the
    -- NAMED caller last asked, so each caller drawing the map can skip a redraw that would
    -- show the one it already drew. While nothing is held the sixteen claims are not asked;
    -- the map is cleared once, on the first idle call after a hold, and comes back empty
    -- until a hold stands again.
    --
    -- The third result is per caller because there are two of them and the map is shared.
    -- Answered globally it belongs to whoever asks first: the rig runs on every status
    -- repaint, so it would take every change and leave the debug box reading "unchanged"
    -- about a map that had moved. A version counted here and the version each caller last
    -- saw costs one integer per caller and keeps both answers exact. A caller that has
    -- never asked sees no version and is told the map moved, which is what a first draw
    -- needs.
    local hold_map = {}
    local hold_map_dirty = false
    local hold_map_version = 0
    local hold_map_seen = {}
    function hold_state(who)
        local changed = false
        if not any_hold() then
            if hold_map_dirty then
                for i = 1, #SLOT_ORDER do
                    if hold_map[i] ~= nil then
                        hold_map[i] = nil
                        changed = true
                    end
                end
                hold_map_dirty = false
            end
            if changed then hold_map_version = hold_map_version + 1 end
            local moved = hold_map_seen[who] ~= hold_map_version
            hold_map_seen[who] = hold_map_version
            return hold_map, false, moved
        end
        for i = 1, #SLOT_ORDER do
            local owner = slot_claim(SLOT_ORDER[i])
            if hold_map[i] ~= owner then
                hold_map[i] = owner
                changed = true
            end
        end
        hold_map_dirty = true
        if changed then hold_map_version = hold_map_version + 1 end
        local moved = hold_map_seen[who] ~= hold_map_version
        hold_map_seen[who] = hold_map_version
        return hold_map, true, moved
    end

    -- The legend the debug box draws the hold map with: the nine layers in the order
    -- slot_claim tests them, which is the order of the rail, and the letter each draws on
    -- the rail and in the map. Every layer slot_claim can answer is named here; a holder it
    -- does not name draws GLYPH.unknown.
    local LAYER_ORDER = { 'ench', 'disable', 'strip', 'hoxne', 'sleep', 'implement', 'spell', 'lock', 'weapon' }
    local LAYER_LETTER = {
        ['ench']      = 'E', -- an item use
        ['disable']   = 'D', -- a disable hold
        ['strip']     = 'S', -- a strip hold
        ['hoxne']     = 'H', -- the Hoxne hold
        ['sleep']     = 'Z', -- Sleep gear
        ['implement'] = 'I', -- the cast in progress
        ['spell']     = 'R', -- received gear
        ['lock']      = 'L', -- a lock mode
        ['weapon']    = 'W', -- the weapon lock
    }

    -- The two lines the debug box draws from the hold map: the rail, every layer's letter
    -- in test order with the layers holding a slot in the value color and the rest dimmed,
    -- and the map, one cell per SLOT_ORDER entry in four groups of four, the holder's
    -- letter or the free glyph. Color carries the rail's state, so its letters never move.
    -- layer_seen is reused across calls, so composing allocates only the lists it joins
    -- and the two strings it returns.
    local layer_seen = {}
    local function hold_lines(map)
        for i = 1, #LAYER_ORDER do layer_seen[LAYER_ORDER[i]] = nil end
        local cells = {}
        for i = 1, #SLOT_ORDER do
            local owner = map[i]
            if owner == nil then
                cells[i] = GLYPH.free
            elseif LAYER_LETTER[owner] then
                layer_seen[owner] = true
                cells[i] = LAYER_LETTER[owner]
            else
                cells[i] = GLYPH.unknown
            end
        end
        local letters = {}
        for i = 1, #LAYER_ORDER do
            local layer = LAYER_ORDER[i]
            letters[i] = cs(layer_seen[layer] and COLOR.value or COLOR.idle, LAYER_LETTER[layer])
        end
        local groups = {}
        for g = 0, 3 do groups[g + 1] = table.concat(cells, '', g * 4 + 1, g * 4 + 4) end
        return table.concat(letters, ' '), table.concat(groups, ' ')
    end

    -- The debug box ------------------------------------------------------------------------------

    -- The six values as they were last painted, so a redraw that would change nothing can be
    -- skipped. This guard is load-bearing rather than cosmetic: the polling engine calls
    -- debug_box_update on every tick that clears its tenth-of-a-second gate, whether or not
    -- any of the six has moved, so without it the box recomposes ten times a second while
    -- nothing on it changes. The hold map is the seventh value, and hold_state keeps that
    -- one, answering whether it moved since the last time it was asked.
    local debug_box_state = {}

    -- Forget the last painted values, so the next call repaints unconditionally. Used when
    -- the box is turned on, where the cached values would otherwise suppress the first draw.
    function debug_box_reset() debug_box_state = {} end

    -- Redraw the debug box, returning immediately when none of the six values has moved and
    -- the hold map is the one last drawn. Each of the six value lines pads its bracketed
    -- value out to a fixed column, so all six come out one width for the true, false and
    -- nil these flags take and the box does not jitter as a boolean changes length; the
    -- rail and the map beneath them are fixed at seventeen and nineteen columns. is_Busy is a
    -- job-file global: a value wider than its column overruns it and leaves that one line
    -- longer than the rest.
    function debug_box_update()
        local map, _, map_moved = hold_state('debug')
        if not map_moved
            and debug_box_state.busy == is_Busy
            and debug_box_state.moving == E.is_moving
            and debug_box_state.dual_wield == E.DualWield
            and debug_box_state.two_hand == E.TwoHand
            and debug_box_state.casting == E.outgoing_cast_active
            and debug_box_state.failsafe == E.sr_failsafe_active() then
            return
        end
        debug_box_state.busy = is_Busy
        debug_box_state.moving = E.is_moving
        debug_box_state.dual_wield = E.DualWield
        debug_box_state.two_hand = E.TwoHand
        debug_box_state.casting = E.outgoing_cast_active
        debug_box_state.failsafe = E.sr_failsafe_active()
        local rail, cells = hold_lines(map)
        local lines = T {}
        lines:insert('is_Busy' .. string.format('[%s]', tostring(is_Busy)):lpad(' ', 12))
        lines:insert('is_Moving' .. string.format('[%s]', tostring(E.is_moving)):lpad(' ', 10))
        lines:insert('DualWield' .. string.format('[%s]', tostring(E.DualWield)):lpad(' ', 10))
        lines:insert('TwoHand' .. string.format('[%s]', tostring(E.TwoHand)):lpad(' ', 12))
        lines:insert('Casting' .. string.format('[%s]', tostring(E.outgoing_cast_active)):lpad(' ', 12))
        lines:insert('Failsafe' .. string.format('[%s]', tostring(E.sr_failsafe_active())):lpad(' ', 11))
        lines:insert(rail)
        lines:insert(cells)
        gs_debug:text(lines:concat('\n'))
    end


    -- Handed to E so the commands component saves through this exact implementation, and
    -- inherits its zoning refusal rather than writing settings a second way.
    E.save_settings = save_settings

    -- The renderer axis, for the command that selects it: the list to offer and cycle
    -- through, and the switch that steps one renderer aside for another.
    E.display_styles = display_styles
    E.set_display_style = set_display_style

    -- The renderer standing, told by the display toggle that the box was shown or hidden,
    -- and by the teardown that it is time to step aside.
    E.display_visible = display_visible
    E.display_unload = display_unload

    -- Version stamp. The root asserts this against Rahvin_GS, so a stale copy of this file
    -- announces itself at load instead of running.
    return '2.0'
end
