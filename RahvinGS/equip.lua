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
--   Section 12 - Everything standing between a gear request and the game, in five parts:
--     Set merging ......... the in-place merge every builder uses
--     Set diagnostics ..... placeholder tracking, empty-set warnings, gs c checksets
--     The merge report .... how an action names the set it actually wore
--     The Hoxne hold ...... the equip() override, and the two ways a slot is held
--     Slot ownership ...... the precedence stack, and the lock and unlock helpers
--
-- THIS FILE IS THE ARBITER. Forty-five exports, and eleven of the other fourteen files lean
--          on them -- every one except interface, state and core -- for one question above
--          all: WHO OWNS THIS SLOT. Nothing else decides that. Releasing a slot goes
--          through release_slot, which asks first -- the one deliberate exception is
--          Unlock, the manual override, which frees everything unconditionally because
--          that is what the player asked it to do.
--
-- THE PRECEDENCE STACK, highest first, is the idea the whole file is built around:
--     1. an enchanted item use  -- it asked for the slot explicitly and briefly
--     2. a disable hold         -- gs c disable: the slot keeps whatever it is wearing
--     3. a strip hold           -- gs c naked and its shapes: the slot is to stay bare
--     4. the Hoxne Ampulla hold -- a standing mode the player switched on
--     5. the Sleep hold         -- drain gear worn while slept, in the slots its set names
--     6. the cast in progress   -- an implement the engine owns for a spell, precast to aftercast
--     7. a lock mode            -- an item held in one slot by a mode the player switched on
--     8. the weapon lock        -- the weapon mode's pair: main and range shut, sub re-asserted
--     9. ordinary gear          -- no claim; the builders may dress it freely
--   Incoming spell-received gear sits between the cast in progress and a lock mode. A layer
--   never takes a slot from one above it, and the routine release paths ask slot_claim before
--   letting go -- which is what stops one layer handing back a slot another is still using.
--
-- IT OVERRIDES equip() ITSELF. The global every other component calls is defined here, and
--          it filters range and ammo under one Hoxne mode. gs_equip is the captured
--          original for paths that must bypass that filter.
--
-- EXPORTS  45 E fields handed over in the export block, plus six globals, plus the
--          cross-component mutables this file writes onto E directly. equip is called 23
--          times across five files; UnlockByMode from three. The importers are enchant,
--          spellreceived, builders, hoxne, hooks, monitor, th, display, commands,
--          lifecycle and the root. The `hoxne` state table is declared HERE rather than in
--          the Hoxne component, because slot ownership needs it and this is where
--          ownership lives.
-- LOADS    Fourth of fifteen, before every component that asks it anything.
--          equip_set_command resolves LATE -- it is declared in the root -- and so does
--          display_box_update, declared in the display component and called from every
--          path here that changes what the box shows.

-- requires: rahvings/state, rahvings/core
return function(E)
    -- Immutable dependencies bound once at construction, so no call below repeats the lookup
    -- for them. The cross-component mutables are never bound here: the lock flags, the hold
    -- counts, mr_count, strip_shape and ench_held_slot are reached through E at every touch,
    -- because a file-local copy would not be the one the other components read and write.
    local CANON_SLOT, PRECAST_FINAL           = E.CANON_SLOT, E.PRECAST_FINAL
    local have_item, res, settings, unwearable_reason = E.have_item, E.res, E.settings, E.unwearable_reason

    ------------------------------------------------------------------------------------------------
    -- SECTION 12 - EQUIPMENT APPLICATION AND SLOT CONTROL
    ------------------------------------------------------------------------------------------------
    -- The five parts run in dependency order: merging, then what merging reports, then the
    -- two mechanisms that can refuse a merge its slot.

    -- Set merging ---------------------------------------------------------------------------------

    -- In-place equivalent of built_set = set_combine(built_set, layer). Avoids the
    -- table allocation set_combine performs on every call, which matters because the
    -- set builders below merge dozens of layers per action.
    local function merge_into(base, layer)
        if type(layer) ~= 'table' then
            -- A hook that returned nothing is normal; one that returned a value which
            -- is not a gear set is a job-file fault, and saying so costs nothing on
            -- the success path because this branch is already the failure branch.
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

    -- The section 2 placeholders, keyed by table identity, recorded before the job
    -- file declares anything. A gearless set still keyed here was never declared; a
    -- gearless set not keyed here was declared and left empty. PLACEHOLDER_LIST
    -- keeps the same names in parent-first order.
    local PLACEHOLDER_NAME = {}
    local PLACEHOLDER_LIST = {}
    do
        local function record(tbl, name)
            PLACEHOLDER_NAME[tbl] = name
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
    -- named by the same one on every load, in the report and in gs c checksets alike.
    -- Cold: the two walks below run once per job-file load.
    local function sorted_keys(t)
        local ks, n = {}, 0
        for k in pairs(t) do
            n = n + 1
            ks[n] = k
        end
        table.sort(ks, function(a, b) return tostring(a) < tostring(b) end)
        return ks
    end

    -- Walk every set reachable from the gear-set roots and classify it: carrying gear,
    -- declared but [Empty], or an untouched engine placeholder. Returns the three name
    -- lists, sorted. Slot values are gear, not sets, and are not entered; a declared
    -- gearless table that only holds child sets is structure, not a set, and is not
    -- reported.
    function set_diagnostics()
        ensure_placeholders()
        local gear, empty, undeclared = {}, {}, {}
        local seen = {}
        local function visit(t, name)
            if seen[t] then return end
            seen[t] = true
            if set_has_gear(t) then
                gear[#gear + 1] = name
            elseif PLACEHOLDER_NAME[t] then
                undeclared[#undeclared + 1] = name
            elseif next(t) == nil then
                empty[#empty + 1] = name
            end
            for _, k in ipairs(sorted_keys(t)) do
                local v = t[k]
                if type(v) == 'table'
                    and not (CANON_SLOT[k] or (type(k) == 'string' and CANON_SLOT[k:lower()])) then
                    visit(v, name .. '.' .. tostring(k))
                end
            end
        end
        for k, v in pairs(sets) do
            if type(v) == 'table' then visit(v, 'sets.' .. tostring(k)) end
        end
        for k, v in pairs(Instrument) do
            if type(v) == 'table' then visit(v, 'Instrument.' .. tostring(k)) end
        end
        table.sort(gear)
        table.sort(empty)
        table.sort(undeclared)
        return gear, empty, undeclared
    end

    -- Empty-set warnings, throttled per set ---------------------------------------------------------

    -- Each set warns at most once per window and reports what it held back.
    -- Must stay above warn_if_empty, which routes through it.
    local SET_WARN_WINDOW = 60
    local set_warn_until, set_warn_held = {}, {}
    local set_warn_hinted = false

    -- Forget the throttle, so the next use of every set reports again.
    local function reset_set_warnings()
        set_warn_until, set_warn_held = {}, {}
        set_warn_hinted = false
    end

    -- Warn that a chosen set wore nothing, naming whether it was never declared
    -- or declared and left empty. Silent while that set's window is open.
    local function warn_empty_set(name, undeclared)
        local now = os.clock()
        if (set_warn_until[name] or 0) > now then
            set_warn_held[name] = (set_warn_held[name] or 0) + 1
            return
        end
        set_warn_until[name] = now + SET_WARN_WINDOW

        local msg = '[' .. name .. (undeclared and '] not found!' or '] is empty!')
        -- The trace hint is worth saying once a load, not on every warning.
        if not set_warn_hinted then
            set_warn_hinted = true
            msg = msg .. '  Use gs c gearreporting to trace fallback pattern.'
        end
        local held = set_warn_held[name]
        set_warn_held[name] = nil
        if held then
            msg = msg .. ('  Silencing warnings for %ds (%d silenced since the last).')
                :format(SET_WARN_WINDOW, held)
        else
            msg = msg .. ('  Silencing warnings for %ds.'):format(SET_WARN_WINDOW)
        end
        warn(msg)
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
    -- merge it. A blank table is TRUTHY, so without this test it displaces the range slot
    -- and reaches GearSwap as a table with no .name -- which equip_processing skips, so the
    -- instrument is dropped rather than stripped and whatever the family set offered is
    -- lost with it.
    --
    -- The warn follows the same split warn_if_empty makes for gear sets: a key the bard
    -- file OMITTED is an engine placeholder with the family set to fall back on and passes
    -- in silence, while a key DECLARED and left empty has no fallback anyone intended and
    -- is named, on the shared throttle. Identity is the only discriminator -- the two are
    -- the same value.
    local function blank_instrument(t, name)
        if type(t) ~= 'table' or next(t) ~= nil then return false end
        if PLACEHOLDER_NAME[t] == nil then warn_empty_set(name, false) end
        return true
    end

    -- Identity to dotted name for every set in the live tree, built on first use
    -- and discarded when a job file loads. A table not in the index is an inline
    -- literal a builder merged, and misses in constant time.
    local SET_NAME

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

    -- Discard the cached index, forcing a rebuild on the next lookup. Called when
    -- a job file loads, and by gs c checksets as a manual refresh.
    function invalidate_set_index() SET_NAME = nil end

    -- Recover a set's dotted name. Warn and trace paths only.
    local function set_name_of(t)
        if not SET_NAME then build_set_index() end
        return SET_NAME[t]
    end

    -- merge_into plus fallback-path tracking. Each build records every merged set in
    -- order, bracketed by marks separating the base layers, the chosen-set branch and
    -- the trailing merges. mr_am spans the Aftermath layers within that history.
    local mr_history, mr_mark, mr_branch_end, mr_am = {}, 0, nil, { from = 0, to = 0 }
    -- Beside each merged layer, the path the merge ASKED for when it said one: the literal
    -- and the runtime key kept apart, so no string is built until a line prints. false for
    -- an unnamed merge, written every time so a stale entry from an earlier build is never
    -- read as this build's name. Every merge writes one slot; a named merge writes two.
    local mr_path, mr_key = {}, {}
    E.mr_count = 0

    -- Reset the tracking. Builders call this once at entry.
    local function merge_report_begin()
        E.mr_count, mr_mark, mr_branch_end = 0, 0, nil
        mr_am.from, mr_am.to = 0, 0
    end

    -- End of the base layers; the spell-type branch merges from here on.
    local function merge_report_mark()
        mr_mark = E.mr_count
    end

    -- End of the spell-type branch; weapon holds and instruments follow.
    local function merge_report_branch_end()
        mr_branch_end = E.mr_count
    end

    -- Merge one layer and record that it happened, so the report can later say which layers
    -- the build passed through. The counting half of merge_into: same merge, plus the
    -- bookkeeping the two marks above divide into base, branch and trailing sections.
    local function merge_report(base, layer)
        if type(layer) == 'table' then
            E.mr_count = E.mr_count + 1
            mr_history[E.mr_count] = layer
            mr_path[E.mr_count] = false
        end
        return merge_into(base, layer)
    end

    -- Merge a set and report it, or say which one is missing. The path is passed as a
    -- literal rather than derived, so a set deleted from this file is still named in the
    -- message; the merge itself still goes through merge_report, so the reported set name
    -- and the gear-report history are unchanged. Pass key for a set chosen by a runtime
    -- value: the message names path.key, and neither string is built unless it is needed.
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
        if key ~= nil then
            warn(path .. '.' .. tostring(key) .. ' not found!')
        else
            warn(path .. ' not found!')
        end
        return false
    end

    -- Name a merged layer. Engine placeholders are named from the include-time
    -- record; everything else is recovered from the live tree.
    local function mr_name(i, t)
        local p = mr_path[i]
        if p then
            local k = mr_key[i]
            if k ~= nil then return p .. '.' .. tostring(k) end
            return p
        end
        return PLACEHOLDER_NAME[t] or set_name_of(t)
    end

    -- The action a build was for, bracketed and ready to head an info line, or an empty
    -- string when there is no action to name. Every info line a build prints carries it:
    -- mid-combat a bare set name does not say what asked for the set.
    local function action_tag(spell)
        local n = spell and (spell.english or spell.name)
        return n and ('[' .. tostring(n) .. '] ') or ''
    end

    -- Report the finished build; the precast, midcast and aftercast hooks each
    -- call this after theirs. warn() and info() speak only for the phase that
    -- chose the action's final gear, gear_report() for every phase.
    local function merge_report_flush(phase, spell)
        local mark, last = mr_mark, mr_branch_end or E.mr_count
        local am_from, am_to = mr_am.from, mr_am.to
        E.mr_count, mr_mark, mr_branch_end = 0, 0, nil
        mr_am.from, mr_am.to = 0, 0

        -- Warnings and the info summary belong to the phase that chose the
        -- action's final gear: midcast for spells, precast for abilities, items
        -- and weaponskills. The trace covers every phase.
        local final_phase = phase == nil or phase == 'midcast'
            or (phase == 'precast' and spell ~= nil and PRECAST_FINAL[spell.type] ~= nil)
        local can_warn = final_phase and settings.warn
        local can_info = final_phase and settings.info
        -- Nothing can be printed: skip the naming work entirely.
        if not can_warn and not can_info and not settings.gear_reporting then return end
        local label = phase == 'precast' and 'Precast: '
            or phase == 'aftercast' and 'Aftercast: ' or ''
        local tag = action_tag(spell)

        -- The Aftermath overlay, named in a clause of its own rather than joined
        -- into the fallback chain. Built past the gate above, so silence is free.
        local am_info, am_trace = '', ''
        if am_from > 0 and am_to >= am_from then
            local parts, dressed_name, first_name = {}, nil, nil
            for j = am_from, am_to do
                local t = mr_history[j]
                local n = mr_name(j, t)
                if n then
                    first_name = first_name or n
                    if set_has_gear(t) then
                        parts[#parts + 1] = n .. ' [Filled]'
                        dressed_name = n
                    else
                        parts[#parts + 1] = n .. ' [Empty]'
                    end
                end
            end
            if #parts > 0 then
                am_trace = ' + Aftermath ' .. table.concat(parts, ' -> ')
                    .. (dressed_name and '' or ', added nothing')
                am_info = dressed_name and (' + [' .. dressed_name .. '][Used]')
                    or (' + [' .. first_name .. '][Empty]')
            end
        end

        -- The set the branch chose: the most specific nameable layer it merged. Inline
        -- literals are stepped over, and so are the Aftermath layers, which sit inside
        -- the branch in precastequip and would otherwise take the head.
        local i, head, name = last, nil, nil
        while i > mark do
            if i < am_from or i > am_to then
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
            if can_info then info(tag .. '[' .. name .. '][Used]' .. am_info) end
            if settings.gear_reporting then
                gear_report(label .. 'Using ' .. name .. ' [Filled]' .. am_trace)
            end
            return
        end

        -- The chosen set wore nothing. Name it, distinguishing a set that does
        -- not exist from one the job file declared and left empty.
        if can_warn then warn_empty_set(name, PLACEHOLDER_NAME[head] ~= nil) end

        -- Both remaining outputs need the walk; stop when neither can print.
        if not settings.gear_reporting and not can_info then return end

        -- Gearless: one step per layer the branch fell through, ending on the gear
        -- that covered. Base layers can only be that ending.
        local steps = { 'Attempted to use ' .. name .. ' [Empty]' }
        local covered, cover_name = false, nil
        i = i - 1
        while i > 0 do
            if i < am_from or i > am_to then
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
        if not covered then steps[#steps + 1] = 'nothing to equip.' end

        -- The compressed fallback: intended set and final cover only.
        if can_info then
            if covered then
                info(tag .. '[' .. name .. '][Not Usable] -> [' .. (cover_name or 'unnamed set')
                    .. '][Used]' .. am_info)
            else
                info(tag .. '[' .. name .. '][Not Usable] -> nothing to equip.' .. am_info)
            end
        end
        if settings.gear_reporting then
            gear_report(label .. table.concat(steps, ' falling back -> ') .. am_trace)
        end
    end

    -- Hoxne Ampulla slot hold ---------------------------------------------------------------------

    -- The item this mode holds, and the buff id that proves its enchantment is active.
    local HOXNE_AMPULLA = 'Hoxne Ampulla'
    local BUFF_ENCHANTMENT = 162 -- res.buffs[162] = "enchantment"

    -- Mode state. window marks an open critical window, expires is its deadline and owner
    -- the critical-action entry that opened or last refreshed it; next_check and recheck_at
    -- pace the tick, and use_not_before blocks a use attempt during the equip delay.
    local hoxne = {
        window         = false, -- a critical action currently owns one slot
        expires        = 0,     -- os.clock() deadline for that window
        owner          = nil,   -- the CRITICAL_JA / CRITICAL_TYPE entry behind the window; read only while window is true
        next_check     = 0,     -- os.clock() gate for hoxne_tick (1s; 2s after a relock)
        recheck_at     = 0,     -- os.clock() before which the bags are not re-scanned
        use_not_before = 0,     -- os.clock() before which no /item may be attempted
        release_tries  = 0,     -- remaining attempts to free a stranded Ampulla
        release_next   = 0,     -- os.clock() gate between those attempts
    }

    -- Ampulla equip delay (5s) plus the server activation latency and a margin. Also
    -- covers the moment after our own equip when extdata still reports the previous
    -- activation_time.
    local HOXNE_EQUIP_LOCKOUT = 9

    -- True in either ON mode.
    local function hoxne_on() return state.Hoxne.value ~= 'OFF' end

    -- THE TWO HOXNE MODES HOLD SLOTS BY DIFFERENT MECHANISMS, and this is the difference.
    --
    -- ON-Locked uses a real disable(), so the slot is genuinely shut. ON-Allow Critical
    -- cannot: a disabled range slot makes the gear-gated songs UNCASTABLE, because the game
    -- refuses them without their named instrument. So that mode holds the slots by
    -- FILTERING them out of equip requests instead, which keeps them nominally free.
    --
    -- gs_equip captures GearSwap's original equip before the override replaces it, for the
    -- paths that must bypass the filter -- the Hoxne code putting the Ampulla back, and an
    -- item use the player explicitly asked for in one of those slots. This capture MUST stay
    -- immediately above the override: moved below it, the name inside the override body is
    -- no longer in scope and resolves to a global nil, so every bypass raises. That is the
    -- same trap as the slot-ownership block further down, which is placed above its callers
    -- for the identical reason.
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

    -- Whether the Hoxne hold owns this slot in the sense a blanket enable must respect.
    -- Only ON-Locked actually disables anything, so only ON-Locked needs protecting from
    -- an unlock sweep -- ON-Allow Critical's filter is unaffected by enable().
    function hoxne_owns_slot(slot)
        if state.Hoxne.value ~= 'ON-Locked' then return false end
        local s = (slot == 'ranged') and 'range' or slot
        return s == 'range' or s == 'ammo'
    end

    -- Slot ownership ------------------------------------------------------------------------------
    --
    -- This block sits ABOVE Unlock and UnlockByMode because both call into it, and a local
    -- referenced above its own declaration resolves to a global nil rather than raising --
    -- so moving it down would break those two silently instead of loudly.

    -- The slot a running enchanted item use is holding, or nil when none is. Owned by the
    -- enchant component, which sets it beside its own disable() and clears it beside the
    -- matching enable(); it lives here because this is where ownership is arbitrated.
    E.ench_held_slot = nil

    -- The slots the lock modes are holding, keyed by canonical slot name. locked_n is kept
    -- alongside so the common idle case costs one integer test rather than a table walk --
    -- slot_claim runs on every slot of every set the engine builds.
    local locked = {}
    E.locked_n = 0

    -- The slots the Sleep hold is wearing drain gear in, keyed by canonical slot name and
    -- holding the item the set named there, so a layer above can hand the slot back dressed.
    -- Owned by the spell-received component, which writes it beside its own disable() and
    -- clears each entry before the matching release; it lives here because this is where
    -- ownership is arbitrated. Never reassigned: the resolver below holds the table itself.
    local sleep_held = {}

    -- The slots the weapon lock is holding, keyed by canonical slot name and holding the item
    -- the lock put there -- the weapon mode's pair as the builders last resolved it. Written
    -- by the weapon-lock block below, which takes the slots by disabling them; declared here,
    -- above the resolver that answers 'weapon' from it.
    local weapon_held = {}

    -- Which of the held weapon slots the lock DISABLES: main, and range under Locked+R. Sub
    -- is held by registration and re-assert alone, never disabled, because GearSwap's own
    -- spell check passes a spell an item grants -- Dispelga from Daybreak -- only while main
    -- or sub is enabled, and a hold that shut both would refuse the cast before any hook
    -- ran. Declared here, above the release path that reads it.
    local LOCK_DISABLES = { main = true, range = true }

    -- The slots an implement the engine owns is holding for the cast in progress, keyed by
    -- canonical slot name and holding the item, from the precast that dressed it to the
    -- aftercast that lets it go. Written by the two hold helpers in the weapon-lock block
    -- below; declared here, above the resolver that answers 'implement' from it.
    local implement_held = {}

    -- The slots a strip hold is holding, keyed by canonical slot name. The value is always
    -- true: the registry records that the slot is to be BARE, not gear that went on, which is
    -- why the release branch below equips empty rather than re-dressing from a record.
    -- strip_n is kept alongside so the idle case costs one integer test, the way locked_n
    -- does; E.strip_shape holds the standing shape's command word, or nil when nothing is
    -- held, and is a cross-component field because the status box names the standing shape.
    -- It starts nil, since no hold stands at load. All three are written only in this file,
    -- and E.strip_shape is read nowhere on the slot_claim path -- strip_n is what that test
    -- asks.
    local stripped = {}
    local strip_n = 0

    -- The slots a disable hold is holding, keyed by canonical slot name. The value is a
    -- record of what the slot was WEARING when the hold took it -- { name = ... }, and the
    -- name 'empty' where the slot was bare -- so the release branch below can put that
    -- same piece back rather than baring the slot as the strip does. E.disabled_n is kept
    -- alongside so the idle case costs one integer test, the way locked_n does, and is a
    -- cross-component field because the status box counts the hold.
    local disabled = {}
    E.disabled_n = 0

    -- The hold's own name, and the slots `gs c disable all` names: the sixteen canonical
    -- slots, which is the naked shape canonicalized. Both are declared here rather than
    -- beside the hold's helpers below because both are read above them -- the label by
    -- the release path, the slot list by the rank a refusal orders its slots with.
    local DISABLE_LABEL = 'Disable'
    local DISABLE_SLOTS = { 'main', 'sub', 'range', 'ammo', 'head', 'neck', 'left_ear',
        'right_ear', 'body', 'hands', 'left_ring', 'right_ring', 'back', 'waist', 'legs',
        'feet' }

    -- WHO OWNS THIS SLOT. Returns the highest-priority layer still claiming it, or nil when
    -- ordinary gear may have it. The tests below are in precedence order and the order is
    -- the contract -- see the stack in the file header. Everything that might take a slot
    -- asks this first.
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

    -- Hand a slot to whoever should hold it NEXT, rather than simply freeing it.
    --
    -- Every release path calls this instead of enable(). A bare enable would drop the slot
    -- all the way to ordinary gear even while a lower layer was still waiting for it -- so a
    -- lock mode would silently lose its item the first time an item use finished in the same
    -- slot. If a layer ABOVE still holds the slot there is nothing to do at all; if the Sleep
    -- hold or a lock is waiting underneath, its item is re-asserted here, and the enable,
    -- equip and disable must stay in that order and inside one event or the gear parked for
    -- the current state wins the flush instead.
    local function release_slot(slot)
        local claim = slot_claim(slot)
        if not claim then
            enable(slot)
            return
        end
        local canon = CANON_SLOT[slot] or slot

        -- A disable hold is next in line: the piece the hold recorded goes back on and the
        -- slot is shut again. Two guards. The first: a slot already wearing the record is
        -- only shut, because the strip release hands back every registered slot -- disabled
        -- ones included -- and a redundant packet is chat and bandwidth on six clients. The
        -- second: a recorded copy no longer carried can never come back, so the hold would
        -- shut the slot indefinitely for it; the slot is forgotten, freed and named instead.
        -- Like the strip branch, this must stay above the `claim ~= 'lock'` fall-through.
        if claim == 'disable' then
            local record = disabled[canon]
            if record.name ~= 'empty' and not have_item(record.name) then
                disabled[canon] = nil
                E.disabled_n = E.disabled_n - 1
                enable(slot)
                info(('%s: %s is no longer in your inventory or wardrobes; %s is free.')
                    :format(DISABLE_LABEL, record.name, canon))
                -- The status box counts this hold, and this is the one hand-back that
                -- drops a slot from it; repainted after the write it reads.
                display_box_update()
                return
            end
            -- Read defensively: a raw handler can reach this before player is readable --
            -- the lost-cast release in the movement handler runs above the guards that
            -- test it -- and a slot can be both implement-held and disabled at once. With
            -- no reading nothing is equipped; the slot is shut and the next build's sweep
            -- puts the record back.
            local worn = player and player.equipment and player.equipment[canon]
            if worn and worn ~= record.name then
                enable(slot)
                gs_equip({ [slot] = record.name == 'empty' and empty or record.name })
            end
            disable(slot)
            return
        end

        -- A strip hold is next in line: the slot goes back BARE and shut, not dressed. This
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
        -- The weapon lock is next in line: the mode's weapon goes back on, held as it was --
        -- shut where the lock shuts the slot, re-asserted and left open where it does not.
        if claim == 'weapon' then
            enable(slot)
            gs_equip({ [slot] = weapon_held[canon] })
            if LOCK_DISABLES[canon] then disable(slot) end
            return
        end
        if claim ~= 'lock' then return end
        local item = locked[canon]

        -- Confirm the item can still be worn BEFORE holding the slot for it. A lock whose
        -- item has left the bags, or dropped below what a level sync allows, would otherwise
        -- hold an empty slot shut indefinitely -- so the mode turns itself off, hands the
        -- slot back, and says which of the two happened.
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

    -- The player-facing name of each layer, so a refusal can say WHICH one is holding the
    -- slot rather than only that something is. A lock mode has no entry because a lock never
    -- refuses another layer -- it is the one that yields.
    -- The strip entry is overwritten at every take with the command word that took the hold,
    -- so a refusal names the word the player actually typed. The generic value here is only
    -- what a refusal would read before any take has happened, which nothing can reach. The
    -- disable entry is fixed, because that hold answers to one word.
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
    -- another, so a refusal naming several layers prints them highest first. HOLDER_NAME
    -- is keyed by claim, and a hash walks in no fixed order. The order is the file header's
    -- stack, with received gear in the place that stack gives it and the lock mode closed
    -- up over: a lock mode is absent from both tables, because it never refuses.
    local HOLDER_RANK = { ench = 1, disable = 2, strip = 3, hoxne = 4, sleep = 5,
        implement = 6, spell = 7, weapon = 8 }

    -- The canonical slots ranked down the body, off the sixteen names the disable hold
    -- already carries, so a refusal listing several slots lists them the same way twice:
    -- a refusal table is keyed by slot and pairs fixes no order either.
    local SLOT_RANK = {}
    for i, canon in ipairs(DISABLE_SLOTS) do SLOT_RANK[canon] = i end

    -- Say which slots a layer could not take and who has them, ONE LINE PER HOLDER, so a
    -- piece a set named and the [Used] line implied is explained rather than silently
    -- absent. `what` is the layer speaking -- 'Sleep gear', 'Received gear', or the spell
    -- an implement serves -- and the holder's name is the resolver's answer through
    -- HOLDER_NAME. Nothing is said when nothing was refused.
    --
    -- The slots are named with the spellings the caller passed, since those are the words
    -- the player's own set used, and ranked canonically inside their line; the holders are
    -- ranked by the precedence stack, highest first. Both orders are imposed rather than
    -- inherited, because a refusal table is keyed by slot and pairs walks a hash in no
    -- fixed order. A claim with no standing sorts last, by name, rather than vanishing.
    --
    -- `channel` chooses where the lines go, and the two kinds of caller want different
    -- answers. A refusal that answers a command the player just typed passes notice, which
    -- has no toggle. One raised while the engine was building gear on its own defaults to
    -- info, whatever the player had silenced.
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
    -- exactly what it already wears, at the second standing -- below an item use, above the
    -- strip hold and everything under it. gs c enable is what releases it.

    -- Take, or re-take, the named slots. A slot an item use is holding is refused, named,
    -- and NOT registered: the record is what the slot wears, and during a use what it wears
    -- is the use's item. Every other slot is recorded as worn and shut. Nothing is equipped
    -- and nothing is enabled -- the gear staying where it is is the whole point.
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
            -- The status box counts the hold: repainted after every write it reads.
            display_box_update()
        end
    end

    -- End the hold on the named slots and hand each to whoever is next in line.
    -- Deregistered FIRST, because release_slot reads this registry -- a slot still recorded
    -- would answer 'disable' and be re-asserted by the very call meant to free it. `whole`
    -- marks the `all` form, which reports the release without listing sixteen names and
    -- says nothing about the slots that were not standing.
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
    -- shuts -- an unclaimed slot, or sub, which the weapon lock registers but never disables.
    -- Issues no equip, so it is safe inside a raw handler. Returns the count it cleared and
    -- the label, so the caller can say what it ended.
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
    -- slot words, or `all` for the sixteen; a bare command answers with its usage line, and
    -- disable adds what stands, in the canonical order rather than the registry's.
    --
    -- One unrecognized word refuses the WHOLE command before any slot is touched: GearSwap's
    -- own disable() RAISES on a slot name it does not know, so a word that failed to
    -- canonicalize can never be passed through and hoped for.
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
                    return
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

    -- THE STRIP HOLD. gs c naked takes every slot its shape names and holds it BARE at the
    -- third standing -- below an item use and a disable hold, above every other layer. The
    -- shape word selects which slots; one hold stands at a time.
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
    -- and named, and registered anyway: the registry records that the slot is to be bare, so
    -- the layer above's end hands it back bare through release_slot rather than dressed --
    -- which is what lets gs c enable while naked stands bare the slot it frees. Every other
    -- slot is enabled, emptied through the captured equip -- the override would let the Hoxne
    -- filter strip range and ammo out of the request -- and disabled again, in that order and
    -- inside one event.
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
        -- The status box names the standing shape: repainted after every write it reads.
        display_box_update()
    end

    -- End the hold and hand every slot to whoever is next in line. Deregistered FIRST,
    -- because release_slot reads this registry -- a slot still recorded would answer 'strip'
    -- and be re-stripped by the very call meant to free it. The rebuild that follows dresses
    -- the freed slots for the current state.
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
    -- A slot a lower disabling layer holds stays shut for that layer. Issues no equip, so it
    -- is safe inside a raw handler. Returns the count it cleared and the standing label, so
    -- the caller can say what it ended.
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

    -- Strip every slot the naked shape names for an INSTANT, registering nothing: the body
    -- of gs c nakedunlocked. A slot an item use or a disable hold is holding is refused and
    -- named. Every other slot is enabled, emptied through the captured equip -- the override
    -- would let the Hoxne filter strip range and ammo out of the request -- and then shut
    -- again only where its own layer shuts it: the Hoxne hold, a Sleep set, an implement,
    -- received gear, a lock mode, a strip hold already standing, and the weapon lock's main
    -- and range but never its sub. A slot nothing claims is left open, so the next build
    -- dresses it.
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
    -- not cover is forgotten FIRST and then handed back through release_slot -- to the
    -- weapon lock, an implement, a lock mode, or simply enabled -- and the new shape is then
    -- taken whole, which re-issues empties over the slots the two shapes share.
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

    -- The command surface behind the three stripping words: bare flips the hold when this
    -- word's own shape is standing and switches to it when another's is, on takes, re-takes
    -- as the manual repair or switches, off releases whatever stands or says it was already
    -- off, and anything else warns with the usage. One hold stands at a time.
    local function strip_mode(word, arg)
        local label = STRIP_LABEL[word]
        local standing = strip_n > 0
        local same = standing and E.strip_shape == word
        local want
        if arg == 'on' then
            want = true
        elseif arg == 'off' then
            want = false
        elseif arg then
            warn(('%s: "%s" is not on or off.'):format(label, tostring(arg)))
            warn(('Usage: //gs c %s [on|off]'):format(word))
            return
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

    -- Turn one lock off: forget it, then hand the slot back. Deregistered FIRST, because
    -- release_slot reads this same registry -- a lock still recorded here would answer
    -- 'lock' and be re-asserted by the very call meant to let it go.
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

    -- Turn every lock mode off at once, and report how many were on so the caller can tell
    -- the player. Used where the locks cannot survive -- a zone, and job file teardown.
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
    -- The weapon mode's pair, held by DISABLING the slots it dresses. E.lock_pair is the pair
    -- as the builders last resolved it; weapon_held above is what this block put in each slot,
    -- and the resolver answers 'weapon' from it. Taking runs enable, equip, disable in one
    -- event, the same way a lock mode re-asserts, and every path that must dress a held slot
    -- over the lock -- an implement, the Sleep hold, received gear -- does the same through
    -- assert_over_lock. Range is held only under Locked+R.

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
    -- first; then every covered slot no higher layer claims is enabled, dressed from the pair
    -- through the captured equip, disabled and registered. A slot a higher layer holds is left
    -- to it and comes back through release_slot when that layer lets go. Hung on
    -- E.lock_pair_changed, so a build that moves the pair -- the engaged offhand, a weapon-mode
    -- change -- re-takes at once. A slot the strip or disable hold has is registered WITHOUT
    -- being dressed, so a pair that moves while one of them stands is what the release puts on.
    local function weapon_lock_take()
        local pair = E.lock_pair
        for slot in pairs(weapon_held) do
            if pair[slot] == nil or not lock_covers(slot) then
                weapon_held[slot] = nil
                release_slot(slot)
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
        end
    end

    -- Let every held slot go: deregistered FIRST, slot by slot, because release_slot reads
    -- this registry and a slot still recorded would answer 'weapon' and be re-taken by the
    -- call meant to free it.
    local function weapon_lock_drop()
        for slot in pairs(weapon_held) do
            weapon_held[slot] = nil
            release_slot(slot)
        end
    end

    -- Dress a set's slots over the lock, for the layers that outrank it -- an implement a
    -- spell needs, the Sleep hold, received gear. Each slot the lock holds is enabled, dressed
    -- through the captured equip and disabled again, in one event; a slot a higher layer holds
    -- is left to it. Nothing happens when the lock is off.
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
    -- the three layers above it -- received gear, a hook, the weapon lock's own sweep --
    -- moves it before the aftercast. Registered after the dress, keyed canonically, and shut
    -- the way every layer above received gear shuts what it holds: an equip into the slot is
    -- diverted until the release enables it again. Only a slot the implement actually took
    -- is registered: one a layer above already holds -- received gear in it first -- was
    -- never dressed, and a claim on it would name gear that did not go on.
    local function hold_implement(set)
        for slot, item in pairs(set) do
            local canon = CANON_SLOT[slot] or slot
            local claim = slot_claim(canon)
            if claim == nil or claim == 'weapon' then
                implement_held[canon] = item
                disable(canon)
            end
        end
    end

    -- Let the cast's implements go: deregistered FIRST, slot by slot, because release_slot
    -- reads this registry and a slot still recorded would answer 'implement' and be
    -- re-dressed by the call meant to free it; then each slot is handed to whoever is next
    -- in line -- the weapon lock re-dresses its pair, an idle slot is enabled. Runs at
    -- aftercast, when a busy window expires with no aftercast, on a zone, and from the
    -- blanket unlock.
    local function release_implement()
        for slot in pairs(implement_held) do
            implement_held[slot] = nil
            release_slot(slot)
        end
    end

    -- Reclaim a held weapon slot that something took without telling the engine -- an
    -- in-game /equipset -- on the path where gear is chosen, the way the lock modes do. Yields
    -- to a higher layer holding the slot: that layer hands it back itself.
    local function verify_weapon_lock()
        for slot, item in pairs(weapon_held) do
            if player.equipment[slot] ~= item_name(item) and slot_claim(slot) == 'weapon' then
                release_slot(slot)
            end
        end
    end

    -- Put back what a held slot was recorded wearing when something opened or re-dressed
    -- it without telling the engine -- a console enable, an in-game /equipset -- on the
    -- path where gear is chosen, the way the strip hold, the lock modes and the weapon
    -- lock do. Yields to an item use, which is holding the slot legitimately, and reads
    -- nothing at all while no hold stands.
    --
    -- The hand-back does the work, so the re-assert and the one line a lost record earns
    -- are written once. The worn reading is defensive: this runs from a build, and a
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

    -- Re-strip a held slot that something dressed without telling the engine -- an in-game
    -- /equipset -- on the path where gear is chosen, the way the lock modes and the weapon
    -- lock do. Yields to an item use, which is holding the slot legitimately.
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

    -- Resolve the weapon lock into the three flags that stand for it, as plain booleans.
    -- Called on every lock change and once at the deferred startup pass, and never from a
    -- build path: the mode's value is read here and nowhere else. Unlocked holds nothing;
    -- Locked holds main and sub; Locked+R holds range as well, unless Hoxne is on, in which
    -- case it stands down to Locked here, said with its cause since the lock moved without
    -- its own command; Songs holds main and sub and exempts a friendly song. The pair
    -- starts as what is worn, so a slot the mode names nothing for is held as found, and
    -- the slots are taken at once; every build the mode runs in then overwrites the slots
    -- it does name and the hold moves with them. Unlocking clears the pair and lets every
    -- held slot go.
    local function resolve_weapon_lock()
        local v = state.WeaponLock.value
        if v == 'Locked+R' and hoxne_on() then
            v = 'Locked'
            state.WeaponLock:set(v)
            notice('Weapon Lock: [Locked] (Hoxne Ampulla holds range)')
        end
        E.lock_main_sub = v == 'Locked' or v == 'Locked+R' or v == 'Songs'
        E.lock_range    = v == 'Locked+R'
        E.lock_songs    = v == 'Songs'
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

    -- Whether the lock stands aside for this action: under Songs, a song sung at oneself, at
    -- another player, or at a Trust -- the one NPC a song can reach. A song aimed at a monster
    -- stays locked, and so does every other action. The builders skip the mode's re-assert
    -- for an exempt action and the hooks dress its whole build over the held slots.
    local function lock_exempts(spell)
        if not E.lock_songs or spell.type ~= 'BardSong' then return false end
        local target = spell.target.type
        return target == 'SELF' or target == 'PLAYER' or target == 'NPC'
    end

    -- The legacy bridge. A job file may still offer the old 'Unlocked' and 'Locked' weapon
    -- modes: entering either sets the lock to match, leaving either returns it to Unlocked,
    -- and a lock set by hand does not survive passing through them -- though one that never
    -- passes through them is left alone. Runs at the deferred startup pass, with no previous
    -- mode, and after every weapon-mode change with the mode it left. Records in
    -- E.lock_legacy whether the current mode is one of the two strings, which is what keeps
    -- the builders' mode-set lookup quiet under them: a legacy mode has no set of its own,
    -- the lock holds what is worn, and a "not found" on every build would say nothing true.
    -- Resolves the flags itself when it changes the lock, says so with the cause, since the
    -- lock moved without its own command, and repaints the box, which at startup was painted
    -- before this ran. Returns whether it changed anything.
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

    -- Release every slot the weapon lock does not hold, unconditionally. The manual override
    -- behind gs c enableall, and the startup pass that clears anything a previous load left
    -- held.
    --
    -- It turns the lock modes off as it goes, so they cannot immediately retake what it just
    -- freed -- an override the player asked for should not be undone a second later. The
    -- Hoxne hold is deliberately NOT turned off: its tick re-asserts the slots within a
    -- second, which is what the message below tells the player. The slots the weapon lock
    -- shuts stay shut: the lock is a mode, and gs c weaponlock is what turns it off; sub,
    -- which the lock never shuts, is freed with the rest. A cast in progress loses its claim
    -- here, since the override frees the slot it was holding.
    --
    -- The holds are cleared FIRST and highest first -- the disable hold, then the strip,
    -- then the lock modes: a lower layer's release would otherwise meet a higher one's claim
    -- and re-assert the very slot this override is freeing.
    function Unlock()
        log('Unlock Called')
        local disable_n, disable_label = disable_clear()
        if disable_n > 0 then notice(disable_label .. ': [OFF]') end
        local stripped_n, strip_label = strip_clear()
        if stripped_n > 0 then notice(strip_label .. ': [OFF]') end
        if clear_locked_slots() > 0 then notice('Lock modes off; releasing every slot.') end
        for s in pairs(implement_held) do implement_held[s] = nil end
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
        -- Repainted after both clears, so the box drops the hold tokens with the holds. The
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

    -- Release every slot the current mode allows, leaving every claim intact. This is the
    -- routine unlock, and it runs often -- on a zone, when Doom or Sleep wears off, and at
    -- the end of every item use -- which is exactly why it must go through the claim-aware
    -- path above rather than enabling outright. All sixteen slots are offered: no slot is
    -- exempt anywhere, and what keeps a piece on is the claim its layer registered.
    function UnlockByMode()
        log('Unlock By Mode Called')
        enable_except_held({ 'main', 'sub', 'range', 'ammo', 'head', 'neck', 'ear1', 'ear2',
            'body', 'hands', 'ring1', 'ring2', 'waist', 'legs', 'feet', 'back' })
    end

    -- Handed to E. Forty-five of them, and eleven of the other fourteen files depend on
    -- this set -- every one except interface, state and core.
    E.merge_into = merge_into
    E.PLACEHOLDER_NAME = PLACEHOLDER_NAME
    E.ensure_placeholders = ensure_placeholders
    E.set_has_gear = set_has_gear
    E.reset_set_warnings = reset_set_warnings
    E.warn_if_empty = warn_if_empty
    E.blank_instrument = blank_instrument
    E.mr_am = mr_am
    E.merge_report_begin = merge_report_begin
    E.merge_report_mark = merge_report_mark
    E.merge_report_branch_end = merge_report_branch_end
    E.merge_report = merge_report
    E.merge_named = merge_named
    E.merge_report_flush = merge_report_flush
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

    -- Version stamp. The root asserts this against Rahvin_GS, so a stale copy of this file
    -- announces itself at load instead of running.
    return '2.0'
end
