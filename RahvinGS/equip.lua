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
-- COMPONENT: equip -- section 12: equipment application and slot ownership
----------------------------------------------------------------------------------------------------
-- CONTENTS
--   Section 12 - Everything standing between a gear request and the game:
--     Set merging ......... the in-place merge every builder uses
--     Set diagnostics ..... placeholder tracking, empty-set warnings, gs c checksets
--     The merge report .... the record of what a build merged, and how a set is named
--     Buff children ....... sets merged while a named buff is active
--     The finished build .. the report's lines, and the last adjustments before the equip
--     The Hoxne hold ...... the equip() override, and the two ways a slot is held
--     Slot ownership ...... the precedence stack, the holds, and the release paths
--     The weapon lock ..... the weapon mode's pair, held against the layers below it
--     Slot locking ........ the blanket and routine unlocks
--
-- THIS FILE IS THE ARBITER. Every engine file except interface, state and core leans on it
--          for one question above all: who owns this slot. Nothing else decides that. A
--          routine release goes through release_slot, which asks slot_claim first and hands
--          the slot to the next layer in line. Unlock, the manual override, is the one
--          exception. It frees every slot the weapon lock does not shut, because that is
--          what the player asked for.
--
-- THE PRECEDENCE STACK is the idea the whole file is built around. Highest first:
--      1. item use ........... an enchanted item use, which asked for its slot explicitly
--      2. disable hold ....... gs c disable, which keeps the slot wearing what it wears
--      3. strip hold ......... gs c naked and its other shapes, which keep the slot bare
--      4. Hoxne hold ......... the Hoxne Ampulla mode the player switched on
--      5. Sleep hold ......... drain gear worn while asleep, in the slots its set names
--      6. cast in progress ... an implement the engine owns for a spell, precast to aftercast
--      7. received gear ...... a set worn for a spell cast on this character, or for Doom
--      8. lock mode .......... an item held in one slot by a mode the player switched on
--      9. weapon lock ........ the weapon mode's pair: main shut, range too under Locked+R,
--                              and sub re-asserted
--     10. ordinary gear ...... no claim, so the builders may dress the slot freely
--   A layer never takes a slot from one above it. The routine release paths ask slot_claim
--   before letting go, which stops one layer handing back a slot another is still using.
--
-- IT OVERRIDES equip() ITSELF. The global equip every other component calls is defined
--          here, and it filters range and ammo under ON-Allow Critical. gs_equip is the
--          captured original, for the paths that must bypass that filter.
--
-- EXPORTS  The E fields in the export block at the end, the shared fields this file writes
--          onto E directly, and six globals: equip, set_diagnostics, invalidate_set_index,
--          hoxne_owns_slot, Unlock and UnlockByMode. The importers are enchant,
--          spellreceived, builders, hoxne, hooks, monitor, th, display, commands, lifecycle
--          and the root. The hoxne state table is declared here rather than in the Hoxne
--          component, because the equip override and slot ownership both read it.
-- LOADS    After state and core, and before every component that asks it anything. Four
--          names it uses belong to files that load later. equip_set_command, declared in
--          the root, and display_box_update, declared in the display component, are globals
--          read at call time. E.cast_proper_in_flight, the hooks component's predicate, and
--          E.repaint_slot, the display component's one-cell recolor, are read from E at the
--          call, because the import block runs before either exists.

-- requires: rahvings/state, rahvings/core
return function(E)
    -- The exports this file uses, bound once at construction. The shared mutable fields are
    -- never bound here. The lock flags, the hold counts, mr_count, strip_shape and
    -- ench_held_slot are read and written through E, because a local copy would not be the
    -- one the other components see.
    local CANON_SLOT, PRECAST_FINAL           = E.CANON_SLOT, E.PRECAST_FINAL
    local have_item, res, settings, unwearable_reason = E.have_item, E.res, E.settings, E.unwearable_reason

    ------------------------------------------------------------------------------------------------
    -- SECTION 12 - EQUIPMENT APPLICATION AND SLOT CONTROL
    ------------------------------------------------------------------------------------------------
    -- The parts run in dependency order: merging, then what merging reports, then the Hoxne
    -- filter and slot ownership, the two mechanisms that can keep a merged piece out of its
    -- slot.

    -- Set merging ---------------------------------------------------------------------------------

    -- The in-place form of built_set = set_combine(built_set, layer), without the table
    -- set_combine allocates on every call. The builders merge many layers per action. Each
    -- slot key is canonicalized, so every spelling of a slot lands on one key, and a key
    -- that is not a slot is skipped. Returns base.
    local function merge_into(base, layer)
        if type(layer) ~= 'table' then
            -- A hook that returns nothing is normal. One that returns something other than
            -- a table is a job-file fault, and the warning costs nothing on the success
            -- path.
            if layer ~= nil then
                warn('a hook returned a ' .. type(layer) .. ', not a gear set; ignored')
            end
            return base
        end
        for slot, item in pairs(layer) do
            local canon = CANON_SLOT[slot] or (type(slot) == 'string' and CANON_SLOT[slot:lower()])
            if canon then base[canon] = item end
        end
        return base
    end

    -- Set diagnostics -----------------------------------------------------------------------------

    -- The section 2 placeholders, recorded before the job file declares anything.
    -- PLACEHOLDER_NAME keys each placeholder table to its dotted name. A gearless set still
    -- keyed there was never declared, and a gearless set not keyed there was declared and
    -- left empty. PLACEHOLDER_LIST holds the same names, parent first. PLACEHOLDER_PATH keys
    -- the names by path instead of table, for a reader that holds a path. A job file that
    -- replaces a family's table keeps the path, so the path still answers that section 2
    -- declares it.
    local PLACEHOLDER_NAME = {}
    local PLACEHOLDER_LIST = {}
    local PLACEHOLDER_PATH = {}
    do
        local function record(tbl, name)
            PLACEHOLDER_NAME[tbl] = name
            PLACEHOLDER_PATH[name] = true
            PLACEHOLDER_LIST[#PLACEHOLDER_LIST + 1] = name
            for k, v in pairs(tbl) do
                if type(v) == 'table' then record(v, name .. '.' .. tostring(k)) end
            end
        end
        record(sets, 'sets')
        record(Instrument, 'Instrument')
    end

    -- Job files replace whole parents (sets.Midcast = { ... }), which removes every
    -- engine placeholder beneath them. Re-create any placeholder path the job file
    -- dropped, so the merge guards see the tree section 2 promised. Runs once, on
    -- the first set build after a load.
    local placeholders_ensured = false
    local function ensure_placeholders()
        if placeholders_ensured then return end
        placeholders_ensured = true
        local created = false
        for i = 1, #PLACEHOLDER_LIST do
            local name = PLACEHOLDER_LIST[i]
            local segs = {}
            for seg in name:gmatch('[^%.]+') do segs[#segs + 1] = seg end
            if #segs >= 2 then
                local node = segs[1] == 'sets' and sets or segs[1] == 'Instrument' and Instrument
                for j = 2, #segs - 1 do
                    node = type(node) == 'table' and node[segs[j]] or nil
                end
                if type(node) == 'table' and node[segs[#segs]] == nil then
                    local fresh = {}
                    node[segs[#segs]] = fresh
                    PLACEHOLDER_NAME[fresh] = name
                    created = true
                end
            end
        end
        if created then invalidate_set_index() end
    end

    -- True when a set table carries at least one wearable slot key.
    local function set_has_gear(t)
        for slot in pairs(t) do
            if CANON_SLOT[slot] or (type(slot) == 'string' and CANON_SLOT[slot:lower()]) then
                return true
            end
        end
        return false
    end

    -- The keys of a set table in one fixed order, so a table reachable by two paths is
    -- named by the same path on every load, in the report and in gs c checksets alike. The
    -- walks that use it run once per load or on demand, never per build.
    local function sorted_keys(t)
        local ks, n = {}, 0
        for k in pairs(t) do
            n = n + 1
            ks[n] = k
        end
        table.sort(ks, function(a, b) return tostring(a) < tostring(b) end)
        return ks
    end

    -- Walk every set reachable from sets and Instrument and classify it: carrying gear,
    -- declared but empty, or an untouched engine placeholder. Returns the three name lists,
    -- sorted. Slot values are gear, not sets, and are not entered. A declared gearless
    -- table that only holds child sets is structure, not a set, and is not reported. One
    -- table can sit under several names, as one Impetus table does under the offense-mode
    -- and weaponskill sets. An empty one is listed under every name, so each line shows a
    -- name the file declares. It is counted and walked once, and its children are named
    -- under the first of its paths in sorted order, so their names are the same on every
    -- load.
    function set_diagnostics()
        ensure_placeholders()
        local gear, empty, undeclared = {}, {}, {}
        local seen = {}
        local function visit(t, name)
            local first = not seen[t]
            seen[t] = true
            if set_has_gear(t) then
                if first then gear[#gear + 1] = name end
            elseif PLACEHOLDER_NAME[t] then
                if first then undeclared[#undeclared + 1] = name end
            elseif next(t) == nil then
                empty[#empty + 1] = name
            end
            if not first then return end
            for _, k in ipairs(sorted_keys(t)) do
                local v = t[k]
                if type(v) == 'table'
                    and not (CANON_SLOT[k] or (type(k) == 'string' and CANON_SLOT[k:lower()])) then
                    visit(v, name .. '.' .. tostring(k))
                end
            end
        end
        for _, k in ipairs(sorted_keys(sets)) do
            local v = sets[k]
            if type(v) == 'table' then visit(v, 'sets.' .. tostring(k)) end
        end
        for _, k in ipairs(sorted_keys(Instrument)) do
            local v = Instrument[k]
            if type(v) == 'table' then visit(v, 'Instrument.' .. tostring(k)) end
        end
        table.sort(gear)
        table.sort(empty)
        table.sort(undeclared)
        return gear, empty, undeclared
    end

    -- Empty-set warnings, throttled per set -------------------------------------------------------

    -- The throttle's state. Each set warns at most once per window and reports how many
    -- warnings it held back. These locals must stay above the functions below that read
    -- them.
    local SET_WARN_WINDOW = 60
    local set_warn_until, set_warn_held = {}, {}
    local set_warn_hinted = false

    -- Forget the throttle, so the next use of every set reports again.
    local function reset_set_warnings()
        set_warn_until, set_warn_held = {}, {}
        set_warn_hinted = false
    end

    -- The per-set window every throttled warning passes through. While the set's window is
    -- open, the call is counted and nil is returned. Otherwise the window opens and the
    -- silence notice is returned, with the count held back since the last one. Must stay
    -- above warn_empty_set and keep_weaponskill_weapons, which call it.
    local function set_warn_gate(name)
        local now = os.clock()
        if (set_warn_until[name] or 0) > now then
            set_warn_held[name] = (set_warn_held[name] or 0) + 1
            return nil
        end
        set_warn_until[name] = now + SET_WARN_WINDOW
        local held = set_warn_held[name]
        set_warn_held[name] = nil
        if held then
            return ('  Silencing warnings for %ds (%d silenced since the last).')
                :format(SET_WARN_WINDOW, held)
        end
        return ('  Silencing warnings for %ds.'):format(SET_WARN_WINDOW)
    end

    -- Warn that a chosen set wore nothing, naming whether it was never declared
    -- or declared and left empty. Silent while that set's window is open.
    local function warn_empty_set(name, undeclared)
        local silence = set_warn_gate(name)
        if not silence then return end

        local msg = '[' .. name .. (undeclared and '] not found!' or '] is empty!')
        -- The trace hint is worth saying once, not on every warning.
        if not set_warn_hinted then
            set_warn_hinted = true
            msg = msg .. '  Use gs c gearreporting to trace fallback pattern.'
        end
        warn(msg .. silence)
    end

    -- Warn when a set about to be worn carries no gear, naming it and whether it was
    -- never declared or declared empty. Returns true when the set was empty, whether
    -- or not the throttle let anything print.
    local function warn_if_empty(t, name)
        if type(t) ~= 'table' or set_has_gear(t) then return false end
        warn_empty_set(name, PLACEHOLDER_NAME[t] ~= nil)
        return true
    end

    -- True when an instrument entry carries nothing, in which case the caller must not
    -- merge it. A blank table is truthy. Merged, it would displace the range slot and reach
    -- GearSwap as a table with no name, which GearSwap's equip processing skips. The
    -- instrument would be dropped rather than stripped, and whatever the family set offered
    -- would be lost with it.
    --
    -- The warning follows the split warn_if_empty makes for gear sets. A key the job file
    -- omitted is an engine placeholder, with the family set to fall back on, and passes in
    -- silence. A key declared and left empty has no intended fallback and is named, on the
    -- shared throttle. Table identity is the only way to tell the two apart, since both are
    -- empty tables.
    local function blank_instrument(t, name)
        if type(t) ~= 'table' or next(t) ~= nil then return false end
        if PLACEHOLDER_NAME[t] == nil then warn_empty_set(name, false) end
        return true
    end

    -- The merge report ----------------------------------------------------------------------------

    -- Identity to dotted name for every set in the live tree. Built on first use, and
    -- discarded whenever the tree may have changed. A table not in the index is an inline
    -- literal a builder merged, and misses in constant time.
    local SET_NAME

    -- Walk sets and Instrument in sorted key order. A table two paths share takes the first
    -- path the walk reaches, the same one on every load.
    local function build_set_index()
        SET_NAME = {}
        local seen = {}
        local function visit(t, name)
            if seen[t] then return end
            seen[t] = true
            SET_NAME[t] = name
            for _, k in ipairs(sorted_keys(t)) do
                local v = t[k]
                if type(v) == 'table'
                    and not (CANON_SLOT[k] or (type(k) == 'string' and CANON_SLOT[k:lower()])) then
                    visit(v, name .. '.' .. tostring(k))
                end
            end
        end
        visit(sets, 'sets')
        visit(Instrument, 'Instrument')
    end

    -- Discard the cached index, forcing a rebuild on the next lookup. Called on a subjob
    -- change, by gs c checksets as a manual refresh, and in this file whenever the tree
    -- gains a path.
    function invalidate_set_index() SET_NAME = nil end

    -- Recover a set's dotted name. Warn and trace paths only.
    local function set_name_of(t)
        if not SET_NAME then build_set_index() end
        return SET_NAME[t]
    end

    -- The report's record. Each build records every merged set in order in mr_history,
    -- with marks separating the base layers, the chosen-set branch and the trailing merges.
    -- mr_am spans the Aftermath layers within that history, and the builders write it.
    local mr_history, mr_mark, mr_branch_end, mr_am = {}, 0, nil, { from = 0, to = 0 }
    -- The buff children's span within the same history. Two plain numbers rather than a
    -- table like mr_am, because nothing outside this file writes them.
    local mr_bc_from, mr_bc_to = 0, 0
    -- The count the last flush reset: how far into mr_history that build's layers reach,
    -- for a reader that runs after the flush, as keep_weaponskill_weapons does. The entries
    -- themselves survive the flush.
    local mr_flushed = 0
    -- Beside each merged layer, the path its merge asked for, if it named one. The literal
    -- and the runtime key are kept apart, so no string is built until a line prints. An
    -- unnamed merge writes false, every time, so a stale entry from an earlier build is
    -- never read as this build's name. A buff child's entry holds its parent's index in
    -- this history in place of a literal, beside the child's key. The child is then named
    -- under the path the parent's own merge asked for. For a table two keys share, that is
    -- the key the build reached for, not the first key a walk of the tree reached.
    local mr_path, mr_key = {}, {}
    -- The number of layers this build has recorded. An E field, because the builders read
    -- it to mark the Aftermath span.
    E.mr_count = 0

    -- Reset the record. Builders call this once at entry.
    local function merge_report_begin()
        E.mr_count, mr_mark, mr_branch_end = 0, 0, nil
        mr_am.from, mr_am.to = 0, 0
        mr_bc_from, mr_bc_to = 0, 0
    end

    -- Mark the end of the base layers. The chosen-set branch merges from here on.
    local function merge_report_mark()
        mr_mark = E.mr_count
    end

    -- Mark the end of the chosen-set branch. Weapon and instrument merges follow it.
    local function merge_report_branch_end()
        mr_branch_end = E.mr_count
    end

    -- Merge one layer and record it, so the report can later say which layers the build
    -- passed through. The same merge as merge_into, plus the record the two marks above
    -- divide into base, branch and trailing sections.
    local function merge_report(base, layer)
        if type(layer) == 'table' then
            E.mr_count = E.mr_count + 1
            mr_history[E.mr_count] = layer
            mr_path[E.mr_count] = false
        end
        return merge_into(base, layer)
    end

    -- Merge a set and record it, or warn that it is missing. The path is passed as a
    -- literal rather than derived, so a set the job file never declared is still named in
    -- the warning. Pass key for a set chosen by a runtime value. The warning then names
    -- path.key, and neither string is built unless it is needed. Returns whether the set
    -- was found.
    local function merge_named(built_set, t, path, key)
        local layer = t
        if key ~= nil then layer = t and t[key] end
        if layer then
            merge_report(built_set, layer)
            -- The name this merge asked for, so the report names the set the builder
            -- reached for rather than whichever path the index walked first.
            if type(layer) == 'table' then
                mr_path[E.mr_count], mr_key[E.mr_count] = path, key
            end
            return true
        end
        -- tostring on the path as well as the key. A caller whose layer the record cannot
        -- name passes nil, and a raise here would take the build down instead of printing
        -- the warning.
        if key ~= nil then
            warn(tostring(path) .. '.' .. tostring(key) .. ' not found!')
        else
            warn(tostring(path) .. ' not found!')
        end
        return false
    end

    -- Name a merged layer from its record: the path its merge asked for, or, for a buff
    -- child, its parent's name and its own key. A layer with no recorded path is named from
    -- the placeholder record taken at load, or else from the live tree. A buff child whose
    -- parent cannot be named is left unnamed, and an unnamed layer is left out of every
    -- line.
    local function mr_name(i, t)
        local p = mr_path[i]
        if type(p) == 'number' then
            local parent = mr_name(p, mr_history[p])
            return parent and (parent .. '.' .. tostring(mr_key[i])) or nil
        elseif p then
            local k = mr_key[i]
            if k ~= nil then return p .. '.' .. tostring(k) end
            return p
        end
        return PLACEHOLDER_NAME[t] or set_name_of(t)
    end

    -- Buff children -------------------------------------------------------------------------------

    -- A buff child is a set the job file declares under a set the build merges, keyed by a
    -- buff's English name in any casing. It merges whenever that buff is active. Which keys
    -- are children is discovered from the keys themselves, checked against the buff
    -- resource, so a declared child is never silently dead. The only way to get one wrong
    -- is a misspelling, which is named where naming is allowed. One key is not a buff name:
    -- XIRoll, in any casing, stands in for a Corsair roll at eleven on this character. It
    -- merges wherever a buff child does while the eleven flag is up. A child may carry
    -- children of its own, each merging while every condition on its chain holds, up to
    -- three conditions. A table nested deeper than that is never merged.

    -- Every English buff name, lowercased, with the Aftermath tiers held apart. buffactive
    -- folds case on every read, so a key matches in whatever casing the job file spelled it.
    -- The Aftermath names belong to the tier ladder, not to this convention. Both tables are
    -- built on the first walk and kept for the load.
    local BUFF_NAME, AFTERMATH_NAME
    -- The spell and weaponskill names, lowercased, built only if a key reaches the test that
    -- needs one: a declared key must already be a buff name to get that far.
    local SPELL_NAME, WS_NAME

    -- Every English name in a resource, as a lowercased set.
    local function name_set(rows)
        local names = {}
        for _, row in pairs(rows) do
            if row.en then names[row.en:lower()] = true end
        end
        return names
    end

    local function build_buff_names()
        BUFF_NAME, AFTERMATH_NAME = {}, {}
        for _, row in pairs(res.buffs) do
            if row.en then
                local lower = row.en:lower()
                if lower:sub(1, 9) == 'aftermath' then
                    AFTERMATH_NAME[lower] = true
                else
                    BUFF_NAME[lower] = true
                end
            end
        end
    end

    -- The keys reserved under a walked parent, whatever they spell: the offense-mode values,
    -- which key the engaged mode child and the idle one alike, Resting, and RA, which marks
    -- the ranged branch. MODE_VALUE holds the offense-mode values alone. Under sets.OffenseMode
    -- or sets.Idle, a key in it names a mode child, which is walked strictly. Rebuilt with
    -- each scheduled pass, because a job file names its own offense modes while it loads.
    local RESERVED, MODE_VALUE
    local function build_reserved()
        local modes, reserved = {}, { Resting = true, RA = true }
        for i = 1, #state.OffenseMode do
            local value = state.OffenseMode[i]
            modes[value] = true
            reserved[value] = true
        end
        RESERVED, MODE_VALUE = reserved, modes
    end

    -- Return one parent's buff children as a list of keys, sorted by name. The list's xi
    -- field holds the XIRoll stand-in's key as the file spelled it, or nil when the parent
    -- declares none. It is never in the array, which the buff loops test against
    -- buffactive. The list's lc field holds each key lowercased. Every other key is refused,
    -- each by its own rule. The path serves only the warnings and is not kept, because a
    -- child is named from its parent's entry in the merge record and one table can sit
    -- under several paths. Only the scheduled pass sets announce, because the lazy walk runs
    -- inside a builder, which may not print. strict marks a parent whose keys, other than
    -- slots, can only be children.
    local function walk_children(parent, path, announce, strict)
        local list = {}
        if type(parent) ~= 'table' then return list end
        if not BUFF_NAME then build_buff_names() end
        if not RESERVED then build_reserved() end
        local under_midcast = path ~= nil
            and (path == 'sets.Midcast' or path:sub(1, 13) == 'sets.Midcast.')
        for key, value in pairs(parent) do
            if type(key) == 'string' and type(value) == 'table' then
                local lower = key:lower()
                if CANON_SLOT[key] or CANON_SLOT[lower] or RESERVED[key] then
                    -- a slot carrying its augments, or a branch the builders index themselves
                elseif AFTERMATH_NAME[lower] then
                    -- The tier ladder reads AM3, AM2, AM1 and AM on the set each site
                    -- passes it, so the warning has to name that set. A reader told only
                    -- to use AM3 might write it under a mode child, where the ladder never
                    -- looks.
                    if announce and path then
                        warn(path .. '.' .. key .. ' is reserved to the Aftermath tiers -- '
                            .. 'AM3, AM2, AM1 and AM are read on the base set, never under a child')
                    end
                elseif lower == 'xiroll' then
                    -- One stand-in per set: the list holds the first spelling the walk
                    -- reaches, and a second is never merged, so the scheduled pass names it.
                    if list.xi == nil then
                        list.xi = key
                    elseif announce and path then
                        warn(path .. '.' .. key .. ': a second XIRoll key under one set')
                    end
                elseif not BUFF_NAME[lower] then
                    if announce and strict and path then
                        warn(path .. '.' .. key .. ' is not a buff name')
                    end
                elseif not (path and PLACEHOLDER_PATH[path .. '.' .. key]) then
                    -- A buff name that is also a placeholder path, a weaponskill name, or
                    -- under sets.Midcast a spell name, keys that action's own set instead.
                    if not WS_NAME then WS_NAME = name_set(res.weapon_skills) end
                    if under_midcast and not SPELL_NAME then SPELL_NAME = name_set(res.spells) end
                    if not WS_NAME[lower] and not (under_midcast and SPELL_NAME[lower]) then
                        list[#list + 1] = key
                    end
                end
            end
        end
        table.sort(list)
        -- Each key's lowercased form beside it. buffactive stores lowercased English names
        -- and folds case on every read, so reading the job file's own spelling costs a
        -- miss, the metamethod and a string.lower, where the lowercased form is a direct
        -- hit. The declared key still indexes the child and is what the report records.
        local lower = {}
        for i = 1, #list do lower[i] = list[i]:lower() end
        list.lc = lower
        return list
    end

    -- The walked answer for each parent table. Weak-keyed, so a set the job file replaces
    -- drops its entry with it. A parent with no buff child and no stand-in shares the one
    -- empty list, NO_CHILDREN, so the common case allocates nothing and every caller can
    -- iterate the answer and read its xi without testing it.
    local NO_CHILDREN = {}
    local children_of = setmetatable({}, { __mode = 'k' })
    -- Whether any parent in this tree declares a buff child, which opens the per-build
    -- pass. The XIRoll stand-in does not open it. The eleven flag opens the pass in a file
    -- that declares a stand-in, so a file whose only child is the stand-in skips the pass
    -- while no eleven stands. A buff child nested under the stand-in is a buff child here
    -- and opens it. The gate starts open and stays open until the scheduled pass has run,
    -- because a build can arrive before the pass and must still find its children. The
    -- pass then decides the gate from what the tree declares, aliases included, and a job
    -- change runs the pass again. A buff child a lazy walk finds opens the gate at once. A
    -- file that declares no child pays the gate's reads per build and nothing else, whether
    -- an eleven stands or not.
    local children_possible = true
    -- Set by a lazy walk that found a buff child, and never cleared. The pass walks only the
    -- roots, to depth three, so a table it never saw is only ever discovered lazily: one
    -- assigned after the pass ran, or one nested deeper. Without this, a pass that found
    -- nothing under its roots would close the gate over a child already in the cache. This
    -- closure is fresh on every load and job change, so it needs no reset.
    local lazy_found = false
    -- Whether any parent declares an XIRoll stand-in, the eleven flag's half of the gate.
    -- The scheduled pass decides it with the gate. A lazy walk that finds a stand-in sets it
    -- and marks lazy_xi_found, which the next pass keeps, as it keeps lazy_found.
    local stand_in_possible = false
    local lazy_xi_found = false
    -- Whether a Corsair roll on this character stands at eleven. Only the setter below
    -- writes it, called by the eleven tracker after each of its own writes. The pass reads
    -- it as an upvalue, for the XIRoll stand-in. It is false at load until the next roll or
    -- Double-Up lands on this character, or another character on this machine answers the
    -- question the tracker sends at load. No packet carries a roll's total after the fact.
    local roll_eleven = false

    -- Store the tracker's answer. When it changes, ask for the rebuild that dresses it,
    -- unless this character's own cast proper is in flight, because the aftercast build
    -- that follows every action reads the flag instead. A repeat does nothing, and nothing
    -- prints. cast_proper_in_flight is read from E at the call, because the hooks component
    -- that exports it loads after this one.
    local function set_roll_eleven(up)
        up = up and true or false
        if up ~= roll_eleven then
            roll_eleven = up
            if not E.cast_proper_in_flight() then equip_set_command() end
        end
    end

    -- A parent's buff children, from the cache or from a lazy walk that fills it. Must stay
    -- above merge_nested and apply_buff_children, which both call it.
    local function buff_children_of(parent, path)
        if type(parent) ~= 'table' then return NO_CHILDREN end
        local list = children_of[parent]
        if list == nil then
            list = walk_children(parent, path)
            -- A buff child found here opens the gate at once, and a stand-in lets the eleven
            -- flag open it. Each is marked for the next scheduled pass to keep.
            if #list > 0 then lazy_found, children_possible = true, true end
            if list.xi ~= nil then
                lazy_xi_found, stand_in_possible = true, true
            elseif #list == 0 then
                list = NO_CHILDREN
            end
            children_of[parent] = list
        end
        return list
    end

    -- Merge the children nested in the children one parent merged, starting from the
    -- history index of that parent's first child. For each merged table, its own active
    -- buff children merge in sorted order, then its stand-in, each recorded under that
    -- table's index and its key as declared. Then the same runs over what that level
    -- merged. The parent's own children are the first of three conditions, so under one
    -- parent every one-condition child merges before any two-condition child. No chain runs
    -- past its third table, however a job file nests its tables, even a table nested inside
    -- itself. A table no walk has cached is walked here, named the way the branch loop names
    -- a layer. Prints nothing.
    local function merge_nested(built_set, lo)
        local hi = E.mr_count
        for _ = 2, 3 do
            for k = lo, hi do
                local t = mr_history[k]
                local list = children_of[t]
                if list == nil then list = buff_children_of(t, mr_name(k, t)) end
                local lc = list.lc
                for j = 1, #list do
                    if buffactive[lc[j]] then
                        local child = t[list[j]]
                        if type(child) == 'table' then
                            merge_report(built_set, child)
                            mr_path[E.mr_count], mr_key[E.mr_count] = k, list[j]
                        end
                    end
                end
                local xi = list.xi
                if xi and roll_eleven then
                    local child = t[xi]
                    if type(child) == 'table' then
                        merge_report(built_set, child)
                        mr_path[E.mr_count], mr_key[E.mr_count] = k, xi
                    end
                end
            end
            if E.mr_count == hi then return end
            lo, hi = hi + 1, E.mr_count
        end
    end

    -- Merge the active buff children of the layers this build merged: the base when the
    -- caller passes one, then every layer of the chosen-set branch in merge order. The
    -- Aftermath span is stepped over, because the tier ladder owns it. Each layer's XIRoll
    -- stand-in merges after that layer's buff children while the eleven flag is up, and the
    -- children nested under what the layer merged follow before the next layer's. The
    -- branch's end is read before the loop, so the children this adds to the history are
    -- not walked as layers themselves. The merges are bracketed in a span of their own,
    -- which the report steps over so it keeps naming the branch's real set. Prints nothing,
    -- because it runs on every engaged and idle build, movement included.
    local function apply_buff_children(built_set, base, base_path)
        if not (children_possible or (roll_eleven and stand_in_possible)) then return end
        local from = E.mr_count + 1
        if base then
            local list, lc = buff_children_of(base, base_path), nil
            lc = list.lc
            -- The history index of the base's first child merge, nil until one merges.
            local first
            for i = 1, #list do
                if buffactive[lc[i]] then
                    -- merge_report and the path pair written in place: the entries
                    -- merge_named writes, in the same order, with one call frame fewer. A
                    -- key that went away after the walk is skipped in silence, where
                    -- merge_named would warn.
                    local child = base[list[i]]
                    if type(child) == 'table' then
                        merge_report(built_set, child)
                        local n = E.mr_count
                        mr_path[n], mr_key[n] = base_path, list[i]
                        first = first or n
                    end
                end
            end
            -- The stand-in, merged and recorded the same way while the eleven flag is up.
            local xi = list.xi
            if xi and roll_eleven then
                local child = base[xi]
                if type(child) == 'table' then
                    merge_report(built_set, child)
                    local n = E.mr_count
                    mr_path[n], mr_key[n] = base_path, xi
                    first = first or n
                end
            end
            if first then merge_nested(built_set, first) end
        end
        local last, am_from, am_to = mr_branch_end or E.mr_count, mr_am.from, mr_am.to
        for i = mr_mark + 1, last do
            if i < am_from or i > am_to then
                local layer = mr_history[i]
                local list = children_of[layer]
                -- Naming the layer costs a walk of the tree, so it is asked for only on the
                -- miss that is about to record the answer.
                if list == nil then list = buff_children_of(layer, mr_name(i, layer)) end
                local lc = list.lc
                local first
                for j = 1, #list do
                    if buffactive[lc[j]] then
                        local child = layer[list[j]]
                        if type(child) == 'table' then
                            merge_report(built_set, child)
                            -- The parent's index, an integer, in place of a path. The
                            -- name is assembled only when a line prints, and it follows
                            -- the path this layer's own merge asked for. The walk reaches
                            -- a table two keys share under one key only, so a path taken
                            -- from the walk could name the child under a key the build
                            -- did not reach for.
                            local n = E.mr_count
                            mr_path[n], mr_key[n] = i, list[j]
                            first = first or n
                        end
                    end
                end
                local xi = list.xi
                if xi and roll_eleven then
                    local child = layer[xi]
                    if type(child) == 'table' then
                        merge_report(built_set, child)
                        local n = E.mr_count
                        mr_path[n], mr_key[n] = i, xi
                        first = first or n
                    end
                end
                if first then merge_nested(built_set, first) end
            end
        end
        mr_bc_from, mr_bc_to = from, E.mr_count
    end

    -- Every set a build can reach a child through: the engaged and idle bases, the
    -- weaponskill and midcast roots, and the five sets the midcast chain merges from outside
    -- sets.Midcast. The lazy walk sits behind the gate, so a root missing here leaves a child
    -- under it dead in a file that declares no other child.
    --
    -- LEGACY_BUFF_SETS maps three legacy set names onto the convention. A job file that
    -- declares sets.Impetus, sets.Foot_Work or sets.Boost gets the same table under the
    -- buff's name in each listed parent before the walk, so the convention discovers it. A
    -- file that declares both names keeps the buff-named one. A file whose own hook code
    -- still merges the legacy set merges that table twice, which writes the same slots.
    local BUFF_CHILD_ROOTS = { 'Idle', 'OffenseMode', 'WS', 'Midcast',
        'Helix', 'Storms', 'Geomancy', 'Diffusion', 'Ready' }
    local LEGACY_BUFF_SETS = {
        { legacy = 'Impetus',   buff = 'Impetus',  parents = { 'OffenseMode', 'WS' } },
        { legacy = 'Foot_Work', buff = 'Footwork', parents = { 'OffenseMode' } },
        { legacy = 'Boost',     buff = 'Boost',    parents = { 'OffenseMode', 'Idle' } },
    }

    -- Record one parent's children and walk its descendants, to depth three counting the
    -- root as one, so a subfamily can carry children of its own. Anything deeper is left to
    -- the walk a builder makes on first use. A mode child under sets.OffenseMode or
    -- sets.Idle, and a buff child's or stand-in's own table, are parents where a key that is
    -- not a slot can only be a child, so they are walked strictly.
    --
    -- sets.Midcast.SIRD can never carry a child. The midcast build merges it as a base layer
    -- below the mark, so the per-build pass never reaches it, and the branch loop, which
    -- starts above the mark, never asks for it. This pass is the only place that can say
    -- so. It warns once per key, on the channel the misspelling warning uses, and records no
    -- children for SIRD. The key neither opens the gate nor is walked, and nothing below it
    -- is visited.
    local function record_parent(parent, path, depth, strict, seen)
        -- One table, one walk per pass, whatever else names it. A job file that assigns
        -- sets.Idle to itself under every offense mode puts one table under many paths.
        -- Entering it again under a mode path would walk the base's own keys strictly and
        -- warn about them for every mode, on every load. The first path the pass reaches
        -- wins, and that is deterministic: the roots in BUFF_CHILD_ROOTS order, then the
        -- keys sorted.
        if type(parent) ~= 'table' or seen[parent] then return end
        if path == 'sets.Midcast.SIRD' then
            -- Not marked seen: a table this path shares with a real parent is still
            -- walked under that parent's own path when the pass reaches it.
            for _, key in ipairs(sorted_keys(parent)) do
                if type(key) == 'string' and type(parent[key]) == 'table'
                    and not (CANON_SLOT[key] or CANON_SLOT[key:lower()]) then
                    warn(path .. '.' .. key .. ': SIRD carries no children')
                end
            end
            children_of[parent] = NO_CHILDREN
            return
        end
        seen[parent] = true
        local list = walk_children(parent, path, true, strict)
        if #list > 0 then children_possible = true end
        if list.xi ~= nil then stand_in_possible = true end
        children_of[parent] = (#list == 0 and list.xi == nil) and NO_CHILDREN or list
        if depth >= 3 then return end
        local mode_parent = path == 'sets.OffenseMode' or path == 'sets.Idle'
        for _, key in ipairs(sorted_keys(parent)) do
            local value = parent[key]
            if type(key) == 'string' and type(value) == 'table'
                and not (CANON_SLOT[key] or CANON_SLOT[key:lower()]) then
                local strict_walk = mode_parent and MODE_VALUE[key] or key == list.xi
                for i = 1, #list do
                    if list[i] == key then strict_walk = true end
                end
                record_parent(value, path .. '.' .. key, depth + 1, strict_walk, seen)
            end
        end
    end

    -- Apply the legacy aliases and record every declared parent's children, once per load.
    -- The root schedules it after the job file's own load. The job file calls jobsetup
    -- above get_sets, so nothing called from there can see a set, and a load that failed
    -- leaves sets nil. It walks every parent whether or not it is cached, because it is the
    -- only pass allowed to name a key it refused. A build that reached a parent first has
    -- already cached it, in silence.
    local function discover_buff_children()
        if type(sets) ~= 'table' then return end
        build_reserved()
        local aliased = false
        for i = 1, #LEGACY_BUFF_SETS do
            local row = LEGACY_BUFF_SETS[i]
            local legacy = sets[row.legacy]
            if type(legacy) == 'table' then
                for j = 1, #row.parents do
                    local parent = sets[row.parents[j]]
                    if type(parent) == 'table' and parent[row.buff] == nil then
                        parent[row.buff] = legacy
                        aliased = true
                    end
                end
            end
        end
        -- The tree gained a path, so the name index built from it is stale.
        if aliased then invalidate_set_index() end
        -- The pass decides the gate. It stays closed unless a walk below finds a buff child,
        -- and an alias above counts like any other child, since it is already in the tree.
        -- The stand-in flag likewise stays down unless a walk finds an XIRoll key.
        children_possible, stand_in_possible = false, false
        local seen = {}
        for i = 1, #BUFF_CHILD_ROOTS do
            local name = BUFF_CHILD_ROOTS[i]
            record_parent(sets[name], 'sets.' .. name, 1, false, seen)
        end
        -- A buff child or a stand-in a build already found outside those roots keeps its
        -- half of the gate.
        children_possible = children_possible or lazy_found
        stand_in_possible = stand_in_possible or lazy_xi_found
    end

    -- The finished build --------------------------------------------------------------------------

    -- The action a build was for, bracketed and ready to head an info line, or an empty
    -- string when there is no action to name. Every info line a build prints carries it:
    -- mid-combat a bare set name does not say what asked for the set.
    local function action_tag(spell)
        local n = spell and (spell.english or spell.name)
        return n and ('[' .. tostring(n) .. '] ') or ''
    end

    -- Report the finished build. The precast, midcast and aftercast hooks, and pet_midcast,
    -- call this after their build. The warning and the info line speak only for the phase
    -- that chose the action's final gear, and the gear report speaks for every phase.
    --
    -- custom and custom_name are a job-file hook's layer, merged after the build and before
    -- this call, and the name the report gives it. pet_midcast passes them. When nothing in
    -- the build covered the empty chosen set but that layer carries gear, the info line and
    -- the trace name the hook as what dressed, in place of nothing to equip.
    local function merge_report_flush(phase, spell, custom, custom_name)
        local mark, last = mr_mark, mr_branch_end or E.mr_count
        local am_from, am_to = mr_am.from, mr_am.to
        local bc_from, bc_to = mr_bc_from, mr_bc_to
        mr_flushed = E.mr_count
        E.mr_count, mr_mark, mr_branch_end = 0, 0, nil
        mr_am.from, mr_am.to = 0, 0
        mr_bc_from, mr_bc_to = 0, 0

        -- Warnings and the info summary belong to the phase that chose the
        -- action's final gear: midcast for spells, precast for abilities, items
        -- and weaponskills. The trace covers every phase.
        local final_phase = phase == nil or phase == 'midcast'
            or (phase == 'precast' and spell ~= nil and PRECAST_FINAL[spell.type] ~= nil)
        local can_warn = final_phase and settings.warn
        local can_info = final_phase and settings.info
        -- Nothing can print, so the naming work is skipped entirely.
        if not can_warn and not can_info and not settings.gear_reporting then return end
        local label = phase == 'precast' and 'Precast: '
            or phase == 'aftercast' and 'Aftercast: ' or ''
        local tag = action_tag(spell)

        -- The two clauses below build their text only for the channel that prints it. The
        -- trace list, one entry per layer joined by table.concat, is built only while gear
        -- reporting is on. The info bracket is built only while the info line can print.
        -- Under warn alone neither prints, so neither loop runs and the flush goes on to
        -- the empty-set warning. Either way, each layer is named and read once. The trace
        -- list is the one table a clause allocates per flush, and a weaponskill's flush
        -- runs on every cast.
        local trace_on = settings.gear_reporting
        local clauses = can_info or trace_on

        -- The Aftermath overlay, named in a clause of its own rather than joined
        -- into the fallback chain. Built past the gate above, so silence is free.
        local am_info, am_trace = '', ''
        if clauses and am_from > 0 and am_to >= am_from then
            local parts, dressed_name, first_name = trace_on and {} or nil, nil, nil
            for j = am_from, am_to do
                local t = mr_history[j]
                local n = mr_name(j, t)
                if n then
                    first_name = first_name or n
                    if set_has_gear(t) then
                        if parts then parts[#parts + 1] = n .. ' [Filled]' end
                        dressed_name = n
                    elseif parts then
                        parts[#parts + 1] = n .. ' [Empty]'
                    end
                end
            end
            if first_name then
                if parts then
                    am_trace = ' + Aftermath ' .. table.concat(parts, ' -> ')
                        .. (dressed_name and '' or ', added nothing')
                end
                if can_info then
                    am_info = dressed_name and (' + [' .. dressed_name .. '][Used]')
                        or (' + [' .. first_name .. '][Empty]')
                end
            end
        end

        -- The buff children, in a clause of the same shape after the Aftermath one. It
        -- prints one bracket per child in merge order, because each child is a different
        -- buff, where the Aftermath clause names the one tier that dressed. Each child is
        -- named from its parent's entry in the record. A child of a layer the record
        -- could not name is left out, as an unnamed layer is everywhere else. Any build
        -- that spans children carries this clause, the aftercast trace of the engaged and
        -- idle builds included.
        local bc_info, bc_trace = '', ''
        if clauses and bc_from > 0 and bc_to >= bc_from then
            local parts, dressed = trace_on and {} or nil, false
            for j = bc_from, bc_to do
                local t = mr_history[j]
                local n = mr_name(j, t)
                if n then
                    if set_has_gear(t) then
                        if parts then parts[#parts + 1] = n .. ' [Filled]' end
                        if can_info then bc_info = bc_info .. ' + [' .. n .. '][Used]' end
                        dressed = true
                    else
                        if parts then parts[#parts + 1] = n .. ' [Empty]' end
                        if can_info then bc_info = bc_info .. ' + [' .. n .. '][Empty]' end
                    end
                end
            end
            if parts and #parts > 0 then
                bc_trace = ' + Buff children ' .. table.concat(parts, ' -> ')
                    .. (dressed and '' or ', added nothing')
            end
        end

        -- The set the branch chose: the most specific nameable layer it merged. Inline
        -- literals are stepped over, and so are the Aftermath layers and the buff
        -- children. Both sit inside the branch in precastequip and would otherwise take
        -- the head from the set the build reached for. The midcast build merges its
        -- children past the branch end, above where this walk starts.
        local i, head, name = last, nil, nil
        while i > mark do
            if (i < am_from or i > am_to) and (i < bc_from or i > bc_to) then
                name = mr_name(i, mr_history[i])
                if name then
                    head = mr_history[i]
                    break
                end
            end
            i = i - 1
        end
        if not head then return end

        -- The build wore the set it reached for: name it as the one it used.
        if set_has_gear(head) then
            if can_info then info(tag .. '[' .. name .. '][Used]' .. am_info .. bc_info) end
            if settings.gear_reporting then
                gear_report(label .. 'Using ' .. name .. ' [Filled]' .. am_trace .. bc_trace)
            end
            return
        end

        -- The chosen set wore nothing. Name it, distinguishing a set that does
        -- not exist from one the job file declared and left empty.
        if can_warn then warn_empty_set(name, PLACEHOLDER_NAME[head] ~= nil) end

        -- Both remaining outputs need the walk, so stop when neither can print.
        if not settings.gear_reporting and not can_info then return end

        -- The head is gearless. Walk one step per layer the branch fell through, ending on
        -- the gear that covered. A base layer can only be that ending. The children's span
        -- is stepped over here to match the head-finder above. The children are the last
        -- nameable merges of every branch, since the ranged arm's ammo literal after them
        -- cannot be a head. So the head sits below the span, and as the builders stand this
        -- walk never enters it.
        local steps = { 'Attempted to use ' .. name .. ' [Empty]' }
        local covered, cover_name = false, nil
        i = i - 1
        while i > 0 do
            if (i < am_from or i > am_to) and (i < bc_from or i > bc_to) then
                local t = mr_history[i]
                local n = mr_name(i, t)
                if set_has_gear(t) then
                    if n then steps[#steps + 1] = 'Using ' .. n .. ' [Filled]' end
                    covered, cover_name = true, n
                    break
                end
                if i > mark and n then
                    steps[#steps + 1] = 'Attempted to use ' .. n .. ' [Empty]'
                end
            end
            i = i - 1
        end
        -- Nothing in the build covered, but a hook layer carrying gear dressed the action.
        -- The line and the trace both name the hook in place of nothing to equip.
        local hooked = not covered and type(custom) == 'table' and set_has_gear(custom)
        if not covered and not hooked then steps[#steps + 1] = 'nothing to equip.' end

        -- The compressed fallback: intended set and final cover only.
        if can_info then
            if covered then
                info(tag .. '[' .. name .. '][Not Usable] -> [' .. (cover_name or 'unnamed set')
                    .. '][Used]' .. am_info .. bc_info)
            elseif hooked then
                info(tag .. '[' .. name .. '][Empty] + [' .. tostring(custom_name) .. '][Used]'
                    .. am_info .. bc_info)
            else
                info(tag .. '[' .. name .. '][Not Usable] -> nothing to equip.' .. am_info .. bc_info)
            end
        end
        if settings.gear_reporting then
            gear_report(label .. table.concat(steps, ' falling back -> ')
                .. (hooked and (' + ' .. tostring(custom_name) .. ' [Filled]') or '')
                .. am_trace .. bc_trace)
        end
    end

    -- Keep the weapons in hand through a weaponskill. Main and sub leave the finished build
    -- on every job, and range on every job but Bard and Geomancer, whose instrument or
    -- handbell still swaps in. The precast and midcast hooks run this after every merge and
    -- after the flush, and the build's layers are read from mr_history up to mr_flushed.
    --
    -- When a slot left, one warning names the sets that carried the slots, on the per-set
    -- window above. Each slot is attributed to the last recorded layer that names it, under
    -- any spelling, and that the report can name. The groups print in merge order, and the
    -- window is keyed on the joined set names as the line shows them. A slot no such layer
    -- carries is not named, and with none named nothing prints and no window opens. The
    -- build is never compared against what is worn, and ammo is not a weapon slot here.
    -- While E.lock_main_sub is set, or while settings.warn is off, the slots still leave and
    -- nothing else happens. Must stay below mr_name and action_tag, which it calls.
    local function keep_weaponskill_weapons(built_set, spell)
        local main, sub = built_set.main ~= nil, built_set.sub ~= nil
        local job = player.main_job
        local range = built_set.range ~= nil and job ~= 'BRD' and job ~= 'GEO'
        if not (main or sub or range) then return end
        if main then built_set.main = nil end
        if sub then built_set.sub = nil end
        if range then built_set.range = nil end
        if E.lock_main_sub then return end
        if not settings.warn then return end

        -- at[slot] is the layer index a held slot is attributed to, 0 until a nameable
        -- recorded layer carries it. name_of[i] caches that layer's name, or false for none.
        local at = { main = main and 0 or nil, sub = sub and 0 or nil, range = range and 0 or nil }
        local name_of, open = {}, (main and 1 or 0) + (sub and 1 or 0) + (range and 1 or 0)
        for i = mr_flushed, 1, -1 do
            if open == 0 then break end
            local layer = mr_history[i]
            for k in pairs(layer) do
                local canon = CANON_SLOT[k] or (type(k) == 'string' and CANON_SLOT[k:lower()])
                if canon and at[canon] == 0 then
                    local n = name_of[i]
                    if n == nil then
                        n = mr_name(i, layer) or false
                        name_of[i] = n
                    end
                    if n then
                        at[canon] = i
                        open = open - 1
                    end
                end
            end
        end

        -- One group per attributed layer, in merge order. The window key is the same names
        -- without the slots. With no group there is nothing to say.
        local line, key
        for i = 1, mr_flushed do
            local name = name_of[i]
            if name then
                local slots
                if at.main == i then slots = 'main' end
                if at.sub == i then slots = slots and (slots .. ', sub') or 'sub' end
                if at.range == i then slots = slots and (slots .. ', range') or 'range' end
                if slots then
                    line = (line and (line .. ', ') or '') .. name .. ' names ' .. slots
                    key = (key and (key .. ', ') or '') .. name
                end
            end
        end
        if not key then return end
        local silence = set_warn_gate(key)
        if silence then
            warn(action_tag(spell) .. line .. '; a weaponskill keeps the weapons in hand.' .. silence)
        end
    end

    -- A spell's ammo displaces the handbell or instrument in hand. Ammo that a precast build
    -- names strips a worn handbell or instrument when the two are exclusive. GearSwap's
    -- model of worn gear learns of that strip only from the server's reply for the range
    -- slot, which lands after the midcast has built. The midcast's bell then reads as
    -- already worn and is never sent. So the precast build clears the range slot itself. The
    -- unequip keeps GearSwap's model right, and the midcast's range item goes out.
    --
    -- RANGE_YIELDS holds the resource skills that yield: 41 and 42, the instruments, and
    -- 45, the handbell. A bow, a gun or an animator keeps its slot. The lookup is memoized
    -- per item name, as the two-hand test's is.
    local RANGE_YIELDS = { [41] = true, [42] = true, [45] = true }
    local range_yields_memo = {}
    local function range_yields_to_ammo(name)
        local known = range_yields_memo[name]
        if known == nil then
            local row = res.items:with('en', name)
            known = row ~= nil and RANGE_YIELDS[row.skill] == true
            range_yields_memo[name] = known
        end
        return known
    end
    -- Clear range in a spell's precast build when its ammo would strip the worn handbell or
    -- instrument. Nothing changes when the build names no ammo or clears it, when that ammo
    -- is already worn, or when range is bare. A range item the build names stands as its own
    -- choice, unless it is the item already worn. Every precast build carries that item from
    -- the idle floor, and the equip would drop it as worn, so it is no choice and the slot
    -- is cleared. Runs on the precast hook for a spell, right before the equip.
    local function yield_range_to_ammo(built_set)
        local ammo = built_set.ammo
        if ammo == nil or ammo == empty then return end
        local worn = player.equipment.range
        if worn == nil or worn == 'empty' then return end
        local named_range = built_set.range
        if named_range ~= nil then
            local range_name = named_range == empty and 'empty'
                or (type(named_range) == 'table' and named_range.name or named_range)
            if range_name ~= worn then return end
        end
        local named = type(ammo) == 'table' and ammo.name or ammo
        if named == player.equipment.ammo then return end
        if not range_yields_to_ammo(worn) then return end
        built_set.range = empty
    end

    -- Hoxne Ampulla slot hold ---------------------------------------------------------------------

    -- The item this mode holds, and the buff id that proves its enchantment is active.
    local HOXNE_AMPULLA = 'Hoxne Ampulla'
    local BUFF_ENCHANTMENT = 162 -- res.buffs[162] = "enchantment"

    -- The Hoxne mode's state, read and written across the engine. The equip override, the
    -- action hooks and the Hoxne tick share the window, and the tick paces itself with the
    -- clocks.
    local hoxne = {
        window         = false, -- true while a critical action or Sleep gear may take range and ammo
        expires        = 0,     -- os.clock() deadline for that window
        owner          = nil,   -- the critical-action entry behind the window, read only while it is open
        next_check     = 0,     -- os.clock() gate for hoxne_tick, 1 s apart or 2 s after a relock request
        recheck_at     = 0,     -- os.clock() before which the bags are not re-scanned
        use_not_before = 0,     -- os.clock() before which no /item may be attempted
        release_tries  = 0,     -- remaining attempts to free a stranded Ampulla
        release_next   = 0,     -- os.clock() gate between those attempts
    }

    -- The Ampulla's 5 second equip delay, plus the server's activation latency and a margin.
    -- It also covers the moment after the engine's own equip, when extdata still reports
    -- the previous activation_time.
    local HOXNE_EQUIP_LOCKOUT = 9

    -- True in either ON mode.
    local function hoxne_on() return state.Hoxne.value ~= 'OFF' end

    -- THE TWO HOXNE MODES HOLD SLOTS BY DIFFERENT MECHANISMS.
    --
    -- ON-Locked uses a real disable(), so the slot is truly shut. ON-Allow Critical cannot,
    -- because a disabled range slot makes the gear-gated songs uncastable: the game refuses
    -- them without their named instrument. So that mode holds the slots by filtering them
    -- out of equip requests, which leaves them nominally free. Outside ON-Allow Critical, or
    -- while a critical window is open, the override passes every request straight through.
    -- Otherwise it removes range and ammo from a copy of each set, never from the job file's
    -- set itself.
    --
    -- gs_equip captures GearSwap's original equip before the override replaces it, for the
    -- paths that must bypass the filter: the Hoxne code putting the Ampulla back, and an
    -- item use the player asked for in one of those slots. The capture must stay on the
    -- line immediately above the override. Moved below it, the name inside the override
    -- body would be a global nil, and every bypass would raise. The slot-ownership block
    -- further down sits above its callers for the same reason.
    local gs_equip = equip
    function equip(...)
        if state.Hoxne.value ~= 'ON-Allow Critical' or hoxne.window then
            return gs_equip(...)
        end
        local n = select('#', ...)
        local args = { ... }
        for i = 1, n do
            local set = args[i]
            if type(set) == 'table' then
                local cleaned
                for k in pairs(set) do
                    local canon = type(k) == 'string' and CANON_SLOT[k:lower()]
                    if canon == 'range' or canon == 'ammo' then
                        if not cleaned then
                            cleaned = {}
                            for k2, v2 in pairs(set) do cleaned[k2] = v2 end
                        end
                        cleaned[k] = nil
                    end
                end
                if cleaned then args[i] = cleaned end
            end
        end
        return gs_equip(unpack(args, 1, n))
    end

    -- Whether the Hoxne hold owns this slot in the sense a blanket enable must respect. Only
    -- ON-Locked disables anything, so only ON-Locked needs protecting from an unlock sweep.
    -- ON-Allow Critical's filter is unaffected by enable().
    function hoxne_owns_slot(slot)
        if state.Hoxne.value ~= 'ON-Locked' then return false end
        local s = (slot == 'ranged') and 'range' or slot
        return s == 'range' or s == 'ammo'
    end

    -- Slot ownership ------------------------------------------------------------------------------
    --
    -- This block sits above Unlock and UnlockByMode because both call into it. A local
    -- referenced above its own declaration resolves to a global nil rather than raising, so
    -- moving the block down would break those two silently.

    -- The slot a running enchanted item use is holding, or nil when none is. The enchant
    -- component sets it when a use takes its slot and clears it when the use ends. It is
    -- declared here because this is where ownership is arbitrated.
    E.ench_held_slot = nil

    -- The slots the lock modes are holding, keyed by canonical slot name, each holding the
    -- item's id, name and augments. The enchant component adds an entry when a lock mode
    -- takes a slot. E.locked_n counts the entries, so slot_claim and build_is_worn can skip
    -- the registry with one integer test while no lock stands.
    local locked = {}
    E.locked_n = 0

    -- The slots the Sleep hold is wearing drain gear in, keyed by canonical slot name and
    -- holding the item the set named there, so a layer above can hand the slot back dressed.
    -- The spell-received component writes each entry beside its own disable() and clears it
    -- before the matching release. The job file's teardown in the lifecycle component
    -- empties it and enables each slot it held. It is declared here because this is where
    -- ownership is arbitrated. The table is never reassigned, because the resolver below
    -- holds the table itself.
    local sleep_held = {}

    -- The slots the weapon lock is holding, keyed by canonical slot name and holding the item
    -- the lock put there, the weapon mode's pair as the builders last resolved it. The
    -- weapon-lock block below writes it. It is declared here, above the resolver that
    -- answers 'weapon' from it.
    local weapon_held = {}

    -- Which of the held weapon slots the lock disables: main, and range under Locked+R. Sub
    -- is held by registration and re-assert alone, never disabled. GearSwap's own spell
    -- check passes a spell an item grants, such as Dispelga from Daybreak, only while main
    -- or sub is enabled, so a hold that shut both would refuse the cast before any hook ran.
    -- Declared here, above the release path that reads it.
    local LOCK_DISABLES = { main = true, range = true }

    -- The slots an implement is holding for the cast in progress, keyed by canonical slot
    -- name and holding the item, from the precast that dressed it to the aftercast that
    -- lets it go. The two hold helpers in the weapon-lock block below write it. It is
    -- declared here, above the resolver that answers 'implement' from it.
    local implement_held = {}

    -- The slots a strip hold is holding, keyed by canonical slot name. The value is always
    -- true. The registry records that the slot is to stay bare, not gear that went on, which
    -- is why the release branch below equips empty rather than re-dressing from a record.
    -- strip_n counts the entries, so the idle case costs one integer test, as with locked_n.
    -- E.strip_shape holds the standing shape's command word, or nil when no hold stands, as
    -- at load. It is an E field because the status box names the standing shape. Only this
    -- file writes the three, and slot_claim tests strip_n, never E.strip_shape.
    local stripped = {}
    local strip_n = 0

    -- The slots a disable hold is holding, keyed by canonical slot name. Each value records
    -- what the slot was wearing when the hold took it, as a table whose name is the item, or
    -- 'empty' where the slot was bare. The release branch below can then put that same piece
    -- back, rather than baring the slot as the strip hold does. E.disabled_n counts the
    -- entries, so the idle case costs one integer test, as with locked_n. It is an E field
    -- because the status box counts the hold.
    local disabled = {}
    E.disabled_n = 0

    -- The disable hold's name, and the slots gs c disable all names: the sixteen canonical
    -- slots, the naked shape canonicalized. Both are declared here rather than beside the
    -- hold's helpers below, because code above those helpers reads them. The release path
    -- reads the label, and the refusal's slot ranking reads the list.
    local DISABLE_LABEL = 'Disable'
    local DISABLE_SLOTS = { 'main', 'sub', 'range', 'ammo', 'head', 'neck', 'left_ear',
        'right_ear', 'body', 'hands', 'left_ring', 'right_ring', 'back', 'waist', 'legs',
        'feet' }

    -- Who owns this slot. Returns the highest layer still claiming it, or nil when ordinary
    -- gear may have it. The tests run in the precedence order of the stack in the file
    -- header, and that order is the contract. Everything that might take a slot asks this
    -- first.
    local function slot_claim(slot)
        local s = CANON_SLOT[slot] or slot
        if E.ench_held_slot and (CANON_SLOT[E.ench_held_slot] or E.ench_held_slot) == s then
            return 'ench'
        end
        if E.disabled_n > 0 and disabled[s] then return 'disable' end
        if strip_n > 0 and stripped[s] then return 'strip' end
        if hoxne_owns_slot(s) then return 'hoxne' end
        if sleep_held[s] then return 'sleep' end
        if implement_held[s] then return 'implement' end
        -- This registry is keyed by whatever spelling the job file's own set happened to
        -- use, so both sides are canonicalized before comparing.
        for held in pairs(active_external_locks) do
            if (CANON_SLOT[held] or held) == s then return 'spell' end
        end
        if E.locked_n > 0 and locked[s] then return 'lock' end
        if weapon_held[s] then return 'weapon' end
    end

    -- Whether a build is already worn, slot for slot, by GearSwap's own test, the one its
    -- equip applies at the end of every event. For each slot, the worn item's name matches
    -- the entry's, the entry names no bag or the bag the item is in, and the entry names no
    -- augments or a list the worn copy's extdata satisfies. True means an equip of this
    -- build would send nothing, so the hook that built it may return without calling equip.
    -- Anything short of proof answers false, and the caller equips as usual: a hold
    -- standing, a slot of the build disabled or encumbered, an equip packet still in flight,
    -- a proposal already made in this event, or a piece of GearSwap's state missing.
    --
    -- The state is read through gearswap, the global table GearSwap hands to every user
    -- file. It is read fresh on every call, because GearSwap replaces some of these tables
    -- outright and a reference kept between calls goes stale. The registry lists carry an n
    -- field, and a list absent for any slot is not proof.
    --
    -- The augment verdict is remembered per augment list, item id and extdata string. An
    -- entry's name, bag id and augment list are resolved once per entry table. Both memos
    -- are weak-keyed on the entry or list table, so an entry mutated in place after its
    -- first build keeps its first resolution. A bag name is normalized the way GearSwap
    -- normalizes one, spaces removed and lowercased, against the same resource rows
    -- GearSwap's bag lookup is built from. A bag that is not a string is no constraint, as
    -- GearSwap reads it. The disable table and the in-flight registry are read for the
    -- build's own slots alone, because an equip sends nothing for a slot it does not name.
    local VERDICT = setmetatable({}, { __mode = 'k' })
    local ENTRY = setmetatable({}, { __mode = 'k' })
    local BAG_ID = {}
    local BAG_API, SLOT_ID
    local function build_is_worn(built)
        if E.disabled_n > 0 or strip_n > 0 or E.locked_n > 0 or E.ench_held_slot
            or next(sleep_held) or next(implement_held) or next(weapon_held)
            or next(active_external_locks) or state.Hoxne.value == 'ON-Locked' then
            return false
        end
        local g = gearswap
        if type(g) ~= 'table' then return false end
        local items, ext, gres, match, dt, reg, slots, proposed, enc =
            g.items, g.extdata, g.res, g.name_match, g.disable_table,
            g.injected_equipment_registry, g.default_slot_map, g.equip_list, g.encumbrance_table
        if type(items) ~= 'table' or type(ext) ~= 'table' or type(gres) ~= 'table'
            or type(match) ~= 'function' or type(dt) ~= 'table' or type(reg) ~= 'table'
            or type(slots) ~= 'table' or type(proposed) ~= 'table' or type(enc) ~= 'table' then
            return false
        end
        -- GearSwap empties its proposal at the start of every event, so anything in it now was
        -- equipped from inside this hook, and that equip will run.
        if next(proposed) ~= nil then return false end
        local equipment, ritems, bags = items.equipment, gres.items, gres.bags
        if type(equipment) ~= 'table' or type(ritems) ~= 'table' or type(bags) ~= 'table' then
            return false
        end
        if not BAG_API then
            BAG_API, SLOT_ID = {}, {}
            for id, row in pairs(bags) do
                if type(row) == 'table' and type(row.en) == 'string' then
                    BAG_API[id] = (row.en:gsub(' ', '')):lower()
                end
            end
            for id, name in pairs(slots) do SLOT_ID[name] = id end
        end
        local empty = g.empty
        -- Under ON-Allow Critical with no window open, the equip override above strips range
        -- and ammo from every request before GearSwap sees them, so neither slot decides this.
        local skip_hoxne = state.Hoxne.value == 'ON-Allow Critical' and not hoxne.window
        for slot, entry in pairs(built) do
            local sid = SLOT_ID[slot]
            local r = sid and reg[sid]
            if not r or dt[sid] or enc[sid] or (r.n or 0) > 0 then return false end
            local eq = equipment[slot]
            if not eq then return false end
            local index = eq.slot
            if skip_hoxne and (slot == 'range' or slot == 'ammo') then
                -- filtered out of the request, so there is nothing to prove
            elseif index == nil or index == empty then
                if entry ~= empty then return false end
            elseif entry == empty then
                return false
            else
                local name, bag, augs = entry, false, false
                if type(entry) == 'table' then
                    local e = ENTRY[entry]
                    if not e then
                        e = { name = entry.name, bag = false, augs = false }
                        local b = entry.bag
                        if type(b) == 'string' then
                            local bid = BAG_ID[b]
                            if bid == nil then
                                bid = false
                                local want = (b:gsub(' ', '')):lower()
                                for id, key in pairs(BAG_API) do
                                    if key == want then bid = id; break end
                                end
                                BAG_ID[b] = bid
                            end
                            e.bag = bid
                        end
                        local a = entry.augments or (entry.augment ~= nil and { entry.augment }) or false
                        if a and #a == 0 then a = nil end
                        e.augs = a
                        ENTRY[entry] = e
                    end
                    name, bag, augs = e.name, e.bag, e.augs
                end
                if type(name) ~= 'string' or augs == nil then return false end
                local api = BAG_API[eq.bag_id]
                local bagtab = api and items[api]
                local row = bagtab and bagtab[index]
                if not row then return false end
                local rrow = ritems[row.id]
                if not rrow then return false end
                if rrow.en ~= name and not match(row.id, name) then return false end
                if bag and bag ~= eq.bag_id then return false end
                if augs then
                    local extdata = row.extdata
                    if type(extdata) ~= 'string' then return false end
                    local by_id = VERDICT[augs]
                    if not by_id then by_id = {}; VERDICT[augs] = by_id end
                    local by_copy = by_id[row.id]
                    if not by_copy then by_copy = {}; by_id[row.id] = by_copy end
                    local verdict = by_copy[extdata]
                    if verdict == nil then
                        local ok, decoded = pcall(ext.decode, row)
                        verdict = ok and type(decoded) == 'table'
                            and ext.compare_augments(augs, decoded.augments) == true
                        by_copy[extdata] = verdict
                    end
                    if not verdict then return false end
                end
            end
        end
        return true
    end

    -- Hand a slot to the next layer that claims it, rather than simply freeing it.
    --
    -- The routine release paths call this instead of enable(). A bare enable would drop the
    -- slot to ordinary gear even while a lower layer was waiting for it, so a lock mode
    -- would silently lose its item the first time an item use finished in its slot. When
    -- nothing claims the slot, it is enabled. When an item use, the Hoxne hold or received
    -- gear claims it, nothing is done, because that layer holds the slot itself. Any other
    -- claimer's item is re-asserted here. The enable, equip and disable must stay in that
    -- order and inside one event, or the gear parked for the current state wins the flush
    -- instead.
    local function release_slot(slot)
        local claim = slot_claim(slot)
        if not claim then
            enable(slot)
            return
        end
        local canon = CANON_SLOT[slot] or slot

        -- A disable hold is next in line: the piece the hold recorded goes back on and the
        -- slot is shut again, behind two guards. A recorded copy no longer carried can never
        -- come back, and the hold would shut the slot indefinitely for it, so the slot is
        -- forgotten, freed and named instead. A slot already wearing the record is only
        -- shut, because the strip release hands back every registered slot, disabled ones
        -- included, and a redundant equip is wasted traffic. Like the strip branch, this must
        -- stay above the `claim ~= 'lock'` fall-through.
        if claim == 'disable' then
            local record = disabled[canon]
            if record.name ~= 'empty' and not have_item(record.name) then
                disabled[canon] = nil
                E.disabled_n = E.disabled_n - 1
                enable(slot)
                info(('%s: %s is no longer in your inventory or wardrobes; %s is free.')
                    :format(DISABLE_LABEL, record.name, canon))
                -- The status box counts this hold, and this is the one hand-back that
                -- drops a slot from it, so the box is repainted after the write.
                display_box_update()
                return
            end
            -- Read defensively. A raw handler can reach this before player is readable,
            -- since the lost-cast release in the polling engine runs above the guards that
            -- test it, and a slot can be implement-held and disabled at once. With no
            -- reading nothing is equipped. The slot is shut, and the next build's sweep puts
            -- the record back.
            local worn = player and player.equipment and player.equipment[canon]
            if worn and worn ~= record.name then
                enable(slot)
                gs_equip({ [slot] = record.name == 'empty' and empty or record.name })
            end
            disable(slot)
            return
        end

        -- A strip hold is next in line: the slot goes back bare and shut, not dressed. This
        -- branch must stay above the `claim ~= 'lock'` fall-through below, which would
        -- otherwise swallow it.
        if claim == 'strip' then
            enable(slot)
            gs_equip({ [slot] = empty })
            disable(slot)
            return
        end

        -- The Sleep hold is next in line: the drain gear goes back on, held as it was, so a
        -- tick in it still wakes the character once the layer above has let go.
        if claim == 'sleep' then
            enable(slot)
            gs_equip({ [slot] = sleep_held[canon] })
            disable(slot)
            return
        end
        -- The cast in progress is next in line: its implement goes back on, shut again the
        -- way the hold shut it.
        if claim == 'implement' then
            enable(slot)
            gs_equip({ [slot] = implement_held[canon] })
            disable(slot)
            return
        end
        -- The weapon lock is next in line: the mode's weapon goes back on, held as it was.
        -- It is shut where the lock shuts the slot, and left open where the lock only
        -- re-asserts it.
        if claim == 'weapon' then
            enable(slot)
            gs_equip({ [slot] = weapon_held[canon] })
            if LOCK_DISABLES[canon] then disable(slot) end
            return
        end
        if claim ~= 'lock' then return end
        local item = locked[canon]

        -- Confirm the item can still be worn before holding the slot for it. A lock whose
        -- item has left the bags, or that a level sync no longer allows, would otherwise
        -- hold an empty slot shut indefinitely. So the mode turns itself off, hands the slot
        -- back, and says which of the two happened.
        local why
        if not have_item(item.name) then
            why = item.name .. ' is no longer in your inventory or wardrobes.'
        else
            local row = res.items[item.id]
            why = row and unwearable_reason(row)
        end
        if why then
            locked[canon] = nil
            E.locked_n = E.locked_n - 1
            enable(slot)
            notice(why)
            notice(item.name .. ': mode [OFF]. Re-enable it when the item is back.')
            -- The status box names this hold, so the whole box is repainted after the
            -- write, its token and its cell going together.
            display_box_update()
            return
        end

        -- Rebuilt exactly as the lock first issued it. A lock whose item was chosen among
        -- several copies of one name recorded the augments identifying its copy, and a
        -- re-assert by bare name would let any copy answer.
        enable(slot)
        gs_equip({
            [slot] = item.augments and { name = item.name, augments = item.augments }
                or item.name
        })
        disable(slot)
    end

    -- The player-facing name of each layer, so a refusal can say which one is holding the
    -- slot. A lock mode has no entry, because a lock never refuses another layer. It is the
    -- one that yields. Each strip take overwrites the strip entry with its command word, so
    -- a refusal names the word the player typed. The generic value here stands only until
    -- the first take, and no refusal can read it before then. The disable entry is fixed,
    -- because that hold answers to one word.
    local HOLDER_NAME = {
        ench      = 'an item use',
        disable   = 'gs c disable',
        strip     = 'a strip hold',
        hoxne     = 'the Hoxne hold',
        sleep     = 'Sleep gear',
        implement = 'the cast in progress',
        spell     = 'received gear',
        weapon    = 'the weapon lock',
    }

    -- The precedence stack as a rank, one entry per layer that can hold a slot against
    -- another, so a refusal naming several layers prints them highest first. HOLDER_NAME is
    -- keyed by claim, and a hash walks in no fixed order. The order is the file header's
    -- stack with the lock mode left out, since a lock mode never refuses and is absent from
    -- both tables.
    local HOLDER_RANK = { ench = 1, disable = 2, strip = 3, hoxne = 4, sleep = 5,
        implement = 6, spell = 7, weapon = 8 }

    -- The canonical slots ranked down the body, from the sixteen names the disable hold
    -- already carries, so a refusal listing several slots always lists them in the same
    -- order. A refusal table is keyed by slot, and pairs fixes no order either.
    local SLOT_RANK = {}
    for i, canon in ipairs(DISABLE_SLOTS) do SLOT_RANK[canon] = i end

    -- Say which slots a layer could not take and who holds them, one line per holder, so a
    -- piece a set named is explained rather than silently absent. `what` is the layer
    -- speaking: 'Sleep gear', 'Received gear', or the spell an implement serves. The
    -- holder's name comes from HOLDER_NAME. Nothing is said when nothing was refused.
    --
    -- The slots are named with the spellings the caller passed, the words the player's own
    -- set used, and ranked canonically inside their line. The holders are ranked by the
    -- precedence stack, highest first. Both orders are imposed, because a refusal table is
    -- keyed by slot and pairs walks a hash in no fixed order. A claim with no rank sorts
    -- last, by name, rather than vanishing.
    --
    -- `channel` chooses where the lines go. A refusal that answers a command the player
    -- just typed passes notice, which cannot be silenced. One raised while the engine
    -- builds gear on its own defaults to info, which the player may silence.
    local function report_refused(what, refused, channel)
        if not refused then return end
        local say = channel or info
        local by_holder, holders = {}, {}
        for slot, claim in pairs(refused) do
            local slots = by_holder[claim]
            if not slots then
                slots = {}
                by_holder[claim] = slots
                holders[#holders + 1] = claim
            end
            slots[#slots + 1] = slot
        end
        table.sort(holders, function(a, b)
            local ra, rb = HOLDER_RANK[a], HOLDER_RANK[b]
            if ra ~= rb then return (ra or math.huge) < (rb or math.huge) end
            return a < b
        end)
        for _, claim in ipairs(holders) do
            local slots = by_holder[claim]
            table.sort(slots, function(a, b)
                local ra, rb = SLOT_RANK[CANON_SLOT[a] or a], SLOT_RANK[CANON_SLOT[b] or b]
                if ra ~= rb then return (ra or math.huge) < (rb or math.huge) end
                return a < b
            end)
            say(('%s: %s %s held by %s right now.'):format(what, table.concat(slots, ', '),
                #slots > 1 and 'are' or 'is', HOLDER_NAME[claim]))
        end
    end

    -- THE DISABLE HOLD. gs c disable takes the slots it is given and holds each one wearing
    -- exactly what it already wears. It is second in the precedence stack, below an item use
    -- and above the strip hold and everything under it. gs c enable releases it.

    -- Take, or re-take, the named slots. A slot an item use is holding is refused, named,
    -- and not registered, because the record is what the slot wears, and during a use that
    -- is the use's item. Every other slot is recorded as worn and shut. Nothing is equipped
    -- and nothing is enabled, because keeping the gear where it is is the whole point.
    local function disable_take(canons)
        local refused, taken, seen = nil, {}, {}
        for _, canon in ipairs(canons) do
            if not seen[canon] then
                seen[canon] = true
                if slot_claim(canon) == 'ench' then
                    refused = refused or {}
                    refused[canon] = 'ench'
                else
                    if not disabled[canon] then E.disabled_n = E.disabled_n + 1 end
                    disabled[canon] = { name = player.equipment[canon] or 'empty' }
                    disable(canon)
                    taken[#taken + 1] = canon
                end
            end
        end
        report_refused(DISABLE_LABEL, refused, notice)
        if #taken > 0 then
            notice(DISABLE_LABEL .. ': [ON] ' .. table.concat(taken, ', '))
            -- The status box counts the hold, so it is repainted after every write it reads.
            display_box_update()
        end
    end

    -- End the hold on the named slots and hand each to the next layer in line. Each slot is
    -- deregistered first, because release_slot reads this registry, and a slot still
    -- recorded would answer 'disable' and be re-asserted by the very call meant to free it.
    -- `whole` marks the all form, which reports the release without listing sixteen names
    -- and says nothing about the slots that were not held.
    local function disable_release(canons, whole)
        local released, absent, seen = {}, {}, {}
        for _, canon in ipairs(canons) do
            if not seen[canon] then
                seen[canon] = true
                if disabled[canon] then
                    disabled[canon] = nil
                    E.disabled_n = E.disabled_n - 1
                    released[#released + 1] = canon
                else
                    absent[#absent + 1] = canon
                end
            end
        end
        if #released == 0 then
            if whole then
                notice(DISABLE_LABEL .. ': already [OFF]')
            else
                for _, canon in ipairs(absent) do
                    notice(('%s: %s already [OFF]'):format(DISABLE_LABEL, canon))
                end
            end
            return
        end
        for _, canon in ipairs(released) do release_slot(canon) end
        -- release_slot only lifts the disable flag where no lower layer is waiting, and an
        -- enabled slot is still wearing whatever was held until the next gear event, so the
        -- freed slots are dressed for the current state at once.
        equip_set_command()
        if whole then
            notice(DISABLE_LABEL .. ': [OFF]')
        else
            for _, canon in ipairs(absent) do
                notice(('%s: %s already [OFF]'):format(DISABLE_LABEL, canon))
            end
            notice(DISABLE_LABEL .. ': [OFF] ' .. table.concat(released, ', '))
        end
        display_box_update()
    end

    -- Forget the hold without equipping anything, and enable only the slots nothing below it
    -- shuts: an unclaimed slot, or sub, which the weapon lock registers but never disables.
    -- It issues no equip, so it is safe inside a raw handler. Returns the count it cleared
    -- and the label, so the caller can say what it ended.
    local function disable_clear()
        if E.disabled_n == 0 then return 0 end
        local list = {}
        for canon in pairs(disabled) do list[#list + 1] = canon end
        for _, canon in ipairs(list) do disabled[canon] = nil end
        local n = E.disabled_n
        E.disabled_n = 0
        local free = {}
        for _, canon in ipairs(list) do
            local claim = slot_claim(canon)
            if claim == nil or (claim == 'weapon' and not LOCK_DISABLES[canon]) then
                free[#free + 1] = canon
            end
        end
        if #free > 0 then enable(unpack(free)) end
        return n, DISABLE_LABEL
    end

    -- The command surface behind gs c disable and gs c enable. The argument is a list of
    -- slot words, or all for the sixteen. A bare command answers with its usage line, and a
    -- bare disable also lists the held slots, in canonical order rather than the registry's.
    --
    -- One unrecognized word refuses the whole command before any slot is touched.
    -- GearSwap's own disable() raises on a slot name it does not know, so a word that fails
    -- to canonicalize must never reach it.
    local function disable_mode(verb, arg)
        local usage = ('Usage: //gs c %s <slot>... | all'):format(verb)
        if not arg then
            warn(usage)
            if verb == 'disable' and E.disabled_n > 0 then
                local standing = {}
                for _, canon in ipairs(DISABLE_SLOTS) do
                    if disabled[canon] then standing[#standing + 1] = canon end
                end
                notice(DISABLE_LABEL .. ': [ON] ' .. table.concat(standing, ', '))
            end
            return
        end
        local canons, whole = {}, false
        for word in arg:lower():gmatch('%S+') do
            if word == 'all' then
                whole = true
                for _, canon in ipairs(DISABLE_SLOTS) do canons[#canons + 1] = canon end
            else
                local canon = CANON_SLOT[word]
                if not canon then
                    warn(('%s: "%s" is not a slot.'):format(DISABLE_LABEL, word))
                    warn(usage)
                    -- Refused, so it returns true, which keeps the command from the job
                    -- file's hook, as every refusal here does. Every form that is not
                    -- refused, the bare report included, returns nothing and leaves the hook
                    -- firing.
                    return true
                end
                canons[#canons + 1] = canon
            end
        end
        if verb == 'enable' then
            disable_release(canons, whole)
        else
            disable_take(canons)
        end
    end

    -- THE STRIP HOLD. gs c naked and its sibling words take every slot their shape names and
    -- hold it bare. It is third in the precedence stack, below an item use and a disable
    -- hold and above every other layer. The word selects the shape, and one hold stands at a
    -- time.
    local STRIP_SHAPES = {
        naked = { 'main', 'sub', 'range', 'ammo', 'head', 'neck', 'ear1', 'ear2', 'body',
            'hands', 'ring1', 'ring2', 'back', 'waist', 'legs', 'feet' },
        weaponsonly = { 'head', 'neck', 'ear1', 'ear2', 'body', 'hands', 'ring1', 'ring2',
            'back', 'waist', 'legs', 'feet' },
        abysseaproc = { 'head', 'hands', 'legs', 'feet' },
    }
    local STRIP_LABEL = {
        naked = 'Naked',
        weaponsonly = 'Weapons only',
        abysseaproc = 'Abyssea proc',
    }

    -- Take, or re-take, the hold. A slot an item use or a disable hold is holding is refused
    -- and named, and registered anyway. The registry records that the slot is to be bare, so
    -- when the layer above lets go, release_slot hands the slot back bare rather than
    -- dressed. That is what lets gs c enable, while naked stands, bare the slot it frees.
    -- Every other slot is enabled, emptied and disabled again, in that order and inside one
    -- event. The empties go through the captured equip, because the override would let the
    -- Hoxne filter strip range and ammo out of the request.
    local function strip_take(word)
        local shape, label = STRIP_SHAPES[word], STRIP_LABEL[word]
        local refused, wanted
        for _, slot in ipairs(shape) do
            local claim = slot_claim(slot)
            if claim == 'ench' or claim == 'disable' then
                refused = refused or {}
                refused[slot] = claim
            else
                wanted = wanted or {}
                wanted[slot] = empty
                enable(slot)
            end
        end
        if wanted then
            gs_equip(wanted)
            for slot in pairs(wanted) do disable(slot) end
        end
        for _, slot in ipairs(shape) do
            local canon = CANON_SLOT[slot] or slot
            if not stripped[canon] then
                stripped[canon] = true
                strip_n = strip_n + 1
            end
        end
        E.strip_shape = word
        HOLDER_NAME.strip = 'gs c ' .. word
        report_refused(label, refused, notice)
        notice(label .. ': [ON]')
        -- The status box names the standing shape, so it is repainted after every write it
        -- reads.
        display_box_update()
    end

    -- End the hold and hand every slot to the next layer in line. The slots are deregistered
    -- first, because release_slot reads this registry, and a slot still recorded would
    -- answer 'strip' and be stripped again by the very call meant to free it. The rebuild
    -- that follows dresses the freed slots for the current state.
    local function strip_release()
        local label = STRIP_LABEL[E.strip_shape] or STRIP_LABEL.naked
        local list = {}
        for canon in pairs(stripped) do list[#list + 1] = canon end
        for _, canon in ipairs(list) do stripped[canon] = nil end
        strip_n, E.strip_shape = 0, nil
        for _, canon in ipairs(list) do release_slot(canon) end
        equip_set_command()
        notice(label .. ': [OFF]')
        display_box_update()
    end

    -- Forget the hold without equipping anything, and enable only the slots nothing below it
    -- shuts: an unclaimed slot, or sub, which the weapon lock registers but never disables.
    -- A slot a lower disabling layer holds stays shut for that layer. It issues no equip, so
    -- it is safe inside a raw handler. Returns the count it cleared and the standing label,
    -- so the caller can say what it ended.
    local function strip_clear()
        if strip_n == 0 then return 0 end
        local label = STRIP_LABEL[E.strip_shape] or STRIP_LABEL.naked
        local list = {}
        for canon in pairs(stripped) do list[#list + 1] = canon end
        for _, canon in ipairs(list) do stripped[canon] = nil end
        local n = strip_n
        strip_n, E.strip_shape = 0, nil
        local free = {}
        for _, canon in ipairs(list) do
            local claim = slot_claim(canon)
            if claim == nil or (claim == 'weapon' and not LOCK_DISABLES[canon]) then
                free[#free + 1] = canon
            end
        end
        if #free > 0 then enable(unpack(free)) end
        return n, label
    end

    -- Strip every slot the naked shape names for an instant, registering nothing: the body
    -- of gs c nakedunlocked. A slot an item use or a disable hold is holding is refused and
    -- named. Every other slot is enabled and emptied through the captured equip, since the
    -- override would let the Hoxne filter strip range and ammo out of the request. Each is
    -- then shut again only where its own layer shuts it: the Hoxne hold, a Sleep set, an
    -- implement, received gear, a lock mode, a strip hold already standing, and the weapon
    -- lock's main and range but never its sub. A slot nothing claims is left open, so the
    -- next build dresses it.
    local function strip_sweep()
        local refused, wanted
        for _, slot in ipairs(STRIP_SHAPES.naked) do
            local claim = slot_claim(slot)
            if claim == 'ench' or claim == 'disable' then
                refused = refused or {}
                refused[slot] = claim
            else
                wanted = wanted or {}
                wanted[slot] = empty
                enable(slot)
            end
        end
        if wanted then
            gs_equip(wanted)
            for slot in pairs(wanted) do
                local canon = CANON_SLOT[slot] or slot
                local claim = slot_claim(canon)
                if claim and (claim ~= 'weapon' or LOCK_DISABLES[canon]) then disable(slot) end
            end
        end
        report_refused(STRIP_LABEL.naked, refused, notice)
    end

    -- Move the standing hold into another shape. Every registered slot the new shape does
    -- not cover is forgotten first, then handed back through release_slot: to the weapon
    -- lock, an implement or a lock mode, or simply enabled. The new shape is then taken
    -- whole, which re-issues empties over the slots the two shapes share.
    local function strip_switch(word)
        local keep = {}
        for _, slot in ipairs(STRIP_SHAPES[word]) do keep[CANON_SLOT[slot] or slot] = true end
        local list = {}
        for canon in pairs(stripped) do
            if not keep[canon] then list[#list + 1] = canon end
        end
        for _, canon in ipairs(list) do
            stripped[canon] = nil
            strip_n = strip_n - 1
        end
        for _, canon in ipairs(list) do release_slot(canon) end
        strip_take(word)
    end

    -- The command surface behind the three stripping words. A bare word releases the hold
    -- when its own shape stands, and otherwise takes its shape or switches to it. on takes,
    -- re-takes as the manual repair, or switches. off releases whatever stands, or says it
    -- was already off. Anything else warns with the usage. One hold stands at a time.
    local function strip_mode(word, arg)
        local label = STRIP_LABEL[word]
        local standing = strip_n > 0
        local same = standing and E.strip_shape == word
        -- The argument is compared lowercased, as every on/off command's is, and the
        -- refusal names it as the player typed it. A refusal returns true, which keeps the
        -- command from the job file's hook. Every other form returns nothing and leaves the
        -- hook firing.
        local want
        local said = arg and arg:lower()
        if said == 'on' then
            want = true
        elseif said == 'off' then
            want = false
        elseif arg then
            warn(('%s: "%s" is not on or off.'):format(label, tostring(arg)))
            warn(('Usage: //gs c %s [on|off]'):format(word))
            return true
        else
            want = not same
        end

        if not want then
            if standing then
                strip_release()
            else
                notice(label .. ': already [OFF]')
            end
            return
        end
        if standing and not same then
            strip_switch(word)
        else
            strip_take(word)
        end
    end

    -- Which slot this item is currently locked in, or nil when its mode is off. Searched by
    -- item id rather than by slot, because the caller knows the item and not where it went.
    local function locked_slot_of(id)
        for canon, held in pairs(locked) do
            if held.id == id then return canon end
        end
    end

    -- Turn one lock off: forget it, then hand the slot back. The lock is deregistered first,
    -- because release_slot reads this same registry, and a lock still recorded would answer
    -- 'lock' and be re-asserted by the very call meant to let it go. Returns whether a lock
    -- was on.
    local function unlock_slot(slot)
        local canon = CANON_SLOT[slot] or slot
        if not locked[canon] then return false end
        locked[canon] = nil
        E.locked_n = E.locked_n - 1
        release_slot(canon)

        -- release_slot only lifts the disable flag when no lower layer is waiting, and an
        -- enabled slot is still wearing whatever the lock put there until the next gear
        -- event. Rebuild here so the slot is dressed for the current state at once, as the
        -- blanket Unlock pairs its enable with one. Guarded by the early return above, so a
        -- mode turned off while already off sends nothing.
        equip_set_command()
        return true
    end

    -- Turn every lock mode off at once, and return how many were on so the caller can tell
    -- the player. Used where the locks cannot survive: a zone, the job file's teardown, and
    -- Unlock.
    local function clear_locked_slots()
        local n = 0
        for canon in pairs(locked) do
            locked[canon] = nil
            E.locked_n = E.locked_n - 1
            release_slot(canon)
            n = n + 1
        end
        return n
    end

    -- The weapon lock -----------------------------------------------------------------------------
    --
    -- The weapon mode's pair, held by disabling main, and range under Locked+R, and by
    -- re-asserting sub. E.lock_pair is the pair as the builders last resolved it. weapon_held
    -- above is what this block put in each slot, and the resolver answers 'weapon' from it.
    -- Taking runs enable, equip and disable in one event, the way a lock mode re-asserts.
    -- Every path that must dress a held slot over the lock, whether an implement, the Sleep
    -- hold or received gear, does the same through assert_over_lock.

    local WEAPON_SLOTS = { 'main', 'sub', 'range' }

    -- Whether the lock holds this slot at all under the current mode.
    local function lock_covers(slot)
        return slot ~= 'range' or E.lock_range
    end

    -- The name a worn-gear read shows for an item as a set names it: the empty sentinel
    -- reads as 'empty', an augmented item as its name.
    local function item_name(v)
        if v == empty then return 'empty' end
        if type(v) == 'table' then return v.name end
        return v
    end

    -- Take, or re-take, the slots the lock holds. A slot the pair no longer covers is let go
    -- first. Then every covered slot no higher layer claims is enabled, dressed from the pair
    -- through the captured equip, and registered, and main and range are disabled again. A
    -- slot a higher layer holds is left to it and comes back through release_slot when that
    -- layer lets go. A slot the strip or disable hold has is registered without being
    -- dressed, so a pair that moves while one of them stands is what the release puts on.
    -- This is set as E.lock_pair_changed, so a build that moves the pair, through the
    -- engaged offhand or a weapon-mode change, re-takes at once. Every slot let go or dressed
    -- has its rig cell recolored as it changes hands.
    local function weapon_lock_take()
        local pair = E.lock_pair
        for slot in pairs(weapon_held) do
            if pair[slot] == nil or not lock_covers(slot) then
                weapon_held[slot] = nil
                release_slot(slot)
                E.repaint_slot(slot)
            end
        end
        local wanted
        for _, slot in ipairs(WEAPON_SLOTS) do
            if lock_covers(slot) and pair[slot] ~= nil then
                local claim = slot_claim(slot)
                if claim == nil or claim == 'weapon' then
                    wanted = wanted or {}
                    wanted[slot] = pair[slot]
                    enable(slot)
                elseif claim == 'strip' or claim == 'disable' then
                    weapon_held[slot] = pair[slot]
                end
            end
        end
        if not wanted then return end
        gs_equip(wanted)
        for slot, item in pairs(wanted) do
            if LOCK_DISABLES[slot] then disable(slot) end
            weapon_held[slot] = item
            E.repaint_slot(slot)
        end
    end

    -- Let every held slot go. Each is deregistered first, because release_slot reads this
    -- registry and a slot still recorded would answer 'weapon' and be re-taken by the call
    -- meant to free it. Each is then handed on, and its rig cell recolored.
    local function weapon_lock_drop()
        for slot in pairs(weapon_held) do
            weapon_held[slot] = nil
            release_slot(slot)
            E.repaint_slot(slot)
        end
    end

    -- Dress a set's slots over the lock, for the layers that outrank it: an implement a
    -- spell needs, the Sleep hold, and received gear. Each slot the lock holds is enabled,
    -- dressed through the captured equip, and disabled again where the lock disables it, all
    -- in one event. A slot a higher layer holds is left to it. Nothing happens when the lock
    -- is off.
    local function assert_over_lock(set)
        if not E.lock_main_sub then return end
        local wanted
        for slot, item in pairs(set) do
            local canon = CANON_SLOT[slot] or slot
            if slot_claim(canon) == 'weapon' then
                wanted = wanted or {}
                wanted[canon] = item
                enable(canon)
            end
        end
        if not wanted then return end
        gs_equip(wanted)
        for canon in pairs(wanted) do
            if LOCK_DISABLES[canon] then disable(canon) end
        end
    end

    -- Hold the slots an implement was dressed in for the cast in progress, so nothing below
    -- it moves the piece before aftercast: not received gear, a job-file hook, or the weapon
    -- lock's own sweep. Each slot is registered after the dress, keyed canonically, and
    -- disabled, so an equip into it is diverted until the release enables it again. Only a
    -- slot the implement actually took is registered. A slot another layer already holds,
    -- received gear included, was never dressed, and a claim on it would name gear that did
    -- not go on. Each slot registered has its rig cell recolored.
    local function hold_implement(set)
        for slot, item in pairs(set) do
            local canon = CANON_SLOT[slot] or slot
            local claim = slot_claim(canon)
            if claim == nil or claim == 'weapon' then
                implement_held[canon] = item
                disable(canon)
                E.repaint_slot(canon)
            end
        end
    end

    -- Let the cast's implements go. Each slot is deregistered first, because release_slot
    -- reads this registry and a slot still recorded would answer 'implement' and be
    -- re-dressed by the call meant to free it. Each is then handed to the next layer in
    -- line, so the weapon lock re-dresses its pair and an unclaimed slot is enabled, and its
    -- rig cell is recolored. Runs at aftercast, when a busy window expires with no
    -- aftercast, on a zone, and at the job file's unload.
    local function release_implement()
        for slot in pairs(implement_held) do
            implement_held[slot] = nil
            release_slot(slot)
            E.repaint_slot(slot)
        end
    end

    -- Reclaim a held weapon slot that something changed without telling the engine, such as
    -- an in-game /equipset. It runs on the path where gear is chosen, as the lock modes'
    -- sweep does. It yields to a higher layer holding the slot, which hands the slot back
    -- itself.
    local function verify_weapon_lock()
        for slot, item in pairs(weapon_held) do
            if player.equipment[slot] ~= item_name(item) and slot_claim(slot) == 'weapon' then
                release_slot(slot)
            end
        end
    end

    -- Put back what a held slot was recorded wearing, when something opened or re-dressed
    -- it without telling the engine, such as a console enable or an in-game /equipset. It
    -- runs on the path where gear is chosen, as the strip hold's, the lock modes' and the
    -- weapon lock's sweeps do. It yields to an item use, which holds the slot legitimately,
    -- and reads nothing at all while no hold stands.
    --
    -- release_slot does the work, so the re-assert and the one line a lost record earns are
    -- written once. The worn reading is defensive, because this runs from a build, and a
    -- build can be reached before player is readable.
    local function verify_disabled_slots()
        if E.disabled_n == 0 then return end
        local worn = player and player.equipment
        if not worn then return end
        for canon, record in pairs(disabled) do
            if worn[canon] ~= record.name and slot_claim(canon) == 'disable' then
                release_slot(canon)
            end
        end
    end

    -- Strip again a held slot that something dressed without telling the engine, such as an
    -- in-game /equipset. It runs on the path where gear is chosen, as the lock modes' and
    -- the weapon lock's sweeps do. It yields to an item use or a disable hold, which hold
    -- the slot legitimately.
    local function verify_stripped_slots()
        if strip_n == 0 then return end
        for canon in pairs(stripped) do
            if player.equipment[canon] ~= 'empty' and slot_claim(canon) == 'strip' then
                enable(canon)
                gs_equip({ [canon] = empty })
                disable(canon)
            end
        end
    end

    -- Resolve the weapon lock into the four flags that stand for it, as plain booleans.
    -- Called on every lock change and once at the deferred startup pass, never from a build
    -- path, so no build reads the mode itself. Unlocked holds nothing. Locked holds main and
    -- sub. Locked+R holds range as well, unless Hoxne is on. Then it stands down to Locked
    -- here and says why, since the lock moved without its own command. Songs holds main and
    -- sub and exempts a friendly song. Geomancy holds main and sub and exempts a Geomancy
    -- spell. The pair starts as what is worn, so a slot the mode names nothing for is held
    -- as found, and the slots are taken at once. Every build under the mode then overwrites
    -- the slots it names, and the hold moves with them. Unlocking clears the pair and lets
    -- every held slot go.
    local function resolve_weapon_lock()
        local v = state.WeaponLock.value
        if v == 'Locked+R' and hoxne_on() then
            v = 'Locked'
            state.WeaponLock:set(v)
            notice('Weapon Lock: [Locked] (Hoxne Ampulla holds range)')
        end
        E.lock_main_sub = v == 'Locked' or v == 'Locked+R' or v == 'Songs' or v == 'Geomancy'
        E.lock_range    = v == 'Locked+R'
        E.lock_songs    = v == 'Songs'
        E.lock_geomancy = v == 'Geomancy'
        local pair, worn = E.lock_pair, player.equipment
        if E.lock_main_sub then
            pair.main, pair.sub = worn.main, worn.sub
            pair.range = E.lock_range and worn.range or nil
            weapon_lock_take()
        else
            pair.main, pair.sub, pair.range = nil, nil, nil
            weapon_lock_drop()
        end
    end

    -- Whether the lock stands aside for this action. Under Geomancy, that is every Geomancy
    -- spell, whatever it targets: an Indicolure on oneself or, through Entrust, on another
    -- player, or a bubble on a monster or an ally. Under Songs, it is a song sung at
    -- oneself, at another player, or at a Trust, the one NPC a song can reach. A song aimed
    -- at a monster stays locked, and so does every other action. The builders skip the
    -- mode's re-assert for an exempt action, and the hooks dress its whole build over the
    -- held slots.
    local function lock_exempts(spell)
        if E.lock_geomancy then return spell.type == 'Geomancy' end
        if not E.lock_songs or spell.type ~= 'BardSong' then return false end
        local target = spell.target.type
        return target == 'SELF' or target == 'PLAYER' or target == 'NPC'
    end

    -- The legacy bridge. A job file may offer 'Unlocked' and 'Locked' as weapon modes.
    -- Entering either sets the lock to match, and leaving either returns the lock to
    -- Unlocked. A lock set by hand does not survive passing through them, but one that never
    -- passes through them is left alone. Runs at the deferred startup pass, with no previous
    -- mode, and after every weapon-mode change, with the mode it left. It records in
    -- E.lock_legacy whether the current mode is one of the two names. That keeps the
    -- builders' mode-set lookup quiet under them, because a legacy mode has no set of its
    -- own, the lock holds what is worn, and a warning on every build would say nothing true.
    -- When it changes the lock, it resolves the flags itself, says so with the cause, since
    -- the lock moved without its own command, and repaints the box, which at startup was
    -- painted before this ran. Returns whether it changed anything.
    local LEGACY_LOCK = { ['Unlocked'] = 'Unlocked', ['Locked'] = 'Locked' }
    local function bridge_weapon_lock(previous)
        local mode = state.WeaponMode.value
        local want = LEGACY_LOCK[mode]
        E.lock_legacy = want ~= nil
        if not want and not (previous and LEGACY_LOCK[previous]) then return false end
        want = want or 'Unlocked'
        if state.WeaponLock.value == want then return false end
        state.WeaponLock:set(want)
        resolve_weapon_lock()
        notice('Weapon Lock: [' .. want .. '] (from weapon mode ' .. mode .. ')')
        display_box_update()
        return true
    end
    E.bridge_weapon_lock = bridge_weapon_lock

    E.lock_pair_changed = weapon_lock_take

    -- Slot locking --------------------------------------------------------------------------------

    -- Release every slot the weapon lock does not shut, unconditionally. This is the manual
    -- override behind gs c enableall, and the startup pass that clears anything a previous
    -- load left held.
    --
    -- It turns the lock modes off as it goes, so they cannot retake what it just freed. An
    -- override the player asked for should not be undone a second later. The Hoxne hold is
    -- not turned off. Its tick re-asserts the slots within a second, which the message below
    -- tells the player. The slots the weapon lock shuts stay shut, because the lock is a
    -- mode and gs c weaponlock turns it off. Sub, which the lock never shuts, is freed with
    -- the rest. A cast in progress loses its claim here, since the override frees the slot
    -- it was holding.
    --
    -- The holds are cleared first, highest first: the disable hold, then the strip hold,
    -- then the lock modes. Otherwise a lower layer's release would meet a higher one's claim
    -- and re-assert the very slot this override is freeing.
    function Unlock()
        log('Unlock Called')
        local disable_n, disable_label = disable_clear()
        if disable_n > 0 then notice(disable_label .. ': [OFF]') end
        local stripped_n, strip_label = strip_clear()
        if stripped_n > 0 then notice(strip_label .. ': [OFF]') end
        if clear_locked_slots() > 0 then notice('Lock modes off; releasing every slot.') end
        -- The cast's implements are let go here too, each slot's rig cell recolored as it
        -- goes. The repaint below recolors the rig from the hold map, which the implement's
        -- own recolors never write, so it would leave those cells as they were.
        for s in pairs(implement_held) do
            implement_held[s] = nil
            E.repaint_slot(s)
        end
        if state.Hoxne.value ~= 'OFF' then
            notice('Hoxne Ampulla Mode is [' .. state.Hoxne.value .. ']; its hold returns shortly.')
        end
        local free = {}
        for _, s in ipairs({ 'main', 'sub', 'range', 'ammo', 'head', 'neck', 'ear1', 'ear2', 'body',
            'hands', 'ring1', 'ring2', 'waist', 'legs', 'feet', 'back' }) do
            if not (weapon_held[s] and LOCK_DISABLES[s]) then free[#free + 1] = s end
        end
        enable(unpack(free))
        equip_set_command()
        -- Repainted after the clears, so the box drops the hold tokens with the holds. The
        -- root schedules this call after the weapon lock resolves, so this paint is also the
        -- first to draw a job file's resolved lock.
        display_box_update()
    end

    -- Enable a list of slots, passing over any that a layer still claims. This is the
    -- selective counterpart to the blanket Unlock above: it frees what is genuinely free and
    -- leaves every claim standing, so a routine unlock cannot strip an item use or a hold.
    -- Claims are matched through the canonical slot names, never by the spelling used.
    local function enable_except_held(slots)
        local list = {}
        for _, s in ipairs(slots) do
            if not slot_claim(s) then list[#list + 1] = s end
        end
        if #list > 0 then enable(unpack(list)) end
    end

    -- Release every slot no layer claims, leaving every claim intact. This is the routine
    -- unlock. It runs on a zone, when Doom or Sleep wears off, at the end of every item use,
    -- and on gs c enablebymode, which is why it must go through the claim-aware path above
    -- rather than enabling outright. All sixteen slots are offered. No slot is exempt, and
    -- what keeps a piece on is the claim its layer registered.
    function UnlockByMode()
        log('Unlock By Mode Called')
        enable_except_held({ 'main', 'sub', 'range', 'ammo', 'head', 'neck', 'ear1', 'ear2',
            'body', 'hands', 'ring1', 'ring2', 'waist', 'legs', 'feet', 'back' })
    end

    -- The exports. Every engine file except interface, state and core binds some of them.
    E.merge_into = merge_into
    E.PLACEHOLDER_NAME = PLACEHOLDER_NAME
    E.ensure_placeholders = ensure_placeholders
    E.set_has_gear = set_has_gear
    E.reset_set_warnings = reset_set_warnings
    E.warn_if_empty = warn_if_empty
    E.keep_weaponskill_weapons = keep_weaponskill_weapons
    E.yield_range_to_ammo = yield_range_to_ammo
    E.blank_instrument = blank_instrument
    E.mr_am = mr_am
    E.merge_report_begin = merge_report_begin
    E.merge_report_mark = merge_report_mark
    E.merge_report_branch_end = merge_report_branch_end
    E.merge_report = merge_report
    E.merge_named = merge_named
    E.merge_report_flush = merge_report_flush
    E.apply_buff_children = apply_buff_children
    E.set_roll_eleven = set_roll_eleven
    E.discover_buff_children = discover_buff_children
    E.action_tag = action_tag
    E.HOXNE_AMPULLA = HOXNE_AMPULLA
    E.BUFF_ENCHANTMENT = BUFF_ENCHANTMENT
    E.hoxne = hoxne
    E.hoxne_on = hoxne_on
    E.HOXNE_EQUIP_LOCKOUT = HOXNE_EQUIP_LOCKOUT
    E.gs_equip = gs_equip
    E.locked = locked
    E.sleep_held = sleep_held
    E.implement_held = implement_held
    E.weapon_lock_drop = weapon_lock_drop
    E.assert_over_lock = assert_over_lock
    E.hold_implement = hold_implement
    E.release_implement = release_implement
    E.verify_weapon_lock = verify_weapon_lock
    E.slot_claim = slot_claim
    E.build_is_worn = build_is_worn
    E.release_slot = release_slot
    E.HOLDER_NAME = HOLDER_NAME
    E.report_refused = report_refused
    E.locked_slot_of = locked_slot_of
    E.unlock_slot = unlock_slot
    E.clear_locked_slots = clear_locked_slots
    E.resolve_weapon_lock = resolve_weapon_lock
    E.lock_exempts = lock_exempts
    E.strip_mode = strip_mode
    E.strip_sweep = strip_sweep
    E.strip_clear = strip_clear
    E.verify_stripped_slots = verify_stripped_slots
    E.verify_disabled_slots = verify_disabled_slots
    E.disable_mode = disable_mode
    E.disable_clear = disable_clear

    -- The version stamp. The root checks it against Rahvin_GS, so a stale copy of this file
    -- stops the load with an error that names it.
    return '2.1'
end
