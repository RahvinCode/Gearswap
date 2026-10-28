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
-- COMPONENT: monitor -- section 19: the polling engine, movement, traits and bursts
----------------------------------------------------------------------------------------------------
-- CONTENTS
--   Section 19 - Automation and combat monitoring. The main polling engine and the
--   movement detection inside it, the Dual Wield and two-handed weapon checks, skillchain
--   burst tracking, buff cancellation, and the Escha temporary-item macro.
--
-- EXPORTS  Nothing onto E. Its functions are globals. It writes these fields the state
--          component declares: is_moving, DualWield, TwoHand and HandToHand, and the burst
--          records. It expires a busy window through hooks.lua's expire_window, then takes
--          any rebuild that waited for the lost cast from hooks.lua and sends it. It reads
--          the pending burst re-dress when a chain lands or a window ends, and marks it and
--          sends gs c burstredress when that changes whether the cast bursts. It keeps,
--          privately, other Blue Mages' Chain Affinity and Azure Lore and other Scholars'
--          Immanence.
-- CALLERS  The root registers main_engine on the outgoing chunk event, and schedules one
--          pass of it after load. th.lua calls run_burst, note_blue_affinity and
--          note_immanence, commands.lua calls two_hand_check and escha_temps, and
--          spellreceived.lua calls cancel. The root and the lifecycle component also hand
--          dual_wield_check and two_hand_check to coroutine.schedule, so a search for
--          "dual_wield_check(" misses those uses.
-- LOADS    After every component whose exports it binds. Two globals it calls are declared
--          in files that load later: debug_box_update in the display component and
--          equip_set_command in the root. Neither may be bound in the import block below.
--          Both resolve because Lua reads a global at call time, and main_engine never runs
--          before the load completes. E.drag_settle, from the display component, is read
--          from E at the call for the same reason.
--
-- The reverse also holds. th.lua and spellreceived.lua load before this file, and their
-- calls to run_burst, note_blue_affinity, note_immanence and cancel resolve at call time in
-- the same way.

-- requires: rahvings/state, rahvings/core, rahvings/equip, rahvings/hooks
return function(E)
    -- The exports this file uses, bound once at construction. The shared mutable fields are
    -- never bound here. The state fields this file reads or writes are reached through E,
    -- because a local copy would not be the one the other components see.
    local Cities, Language, skillchains    = E.Cities, E.Language, E.skillchains
    local BURST_WINDOW, BURST_WINDOW_FLOOR = E.BURST_WINDOW, E.BURST_WINDOW_FLOOR
    local HELIX_SPELL, HELIX_WINDOW_BONUS  = E.HELIX_SPELL, E.HELIX_WINDOW_BONUS
    local BURST_ENDER_RESOURCE             = E.BURST_ENDER_RESOURCE
    local SKILL_MISS_MESSAGE               = E.SKILL_MISS_MESSAGE
    local BLUE_PHYSICAL, SPELL_DAMAGE_MESSAGE = E.BLUE_PHYSICAL, E.SPELL_DAMAGE_MESSAGE
    local BLUE_AFFINITY_HOLD, CHAIN_AFFINITY_ID = E.BLUE_AFFINITY_HOLD, E.CHAIN_AFFINITY_ID
    local ABILITY_USED_MESSAGE             = E.ABILITY_USED_MESSAGE
    local IMMANENCE_ID, IMMANENCE_HOLD     = E.IMMANENCE_ID, E.IMMANENCE_HOLD
    local IMMANENCE_SPELL                  = E.IMMANENCE_SPELL
    local res, settings                    = E.res, E.settings
    local expire_window                    = E.expire_window
    local take_waiting_rebuild             = E.take_waiting_rebuild
    local buff_prediction, write_buff_predictions = E.buff_prediction, E.write_buff_predictions

    -- main_engine's clocks: the 30 second housekeeping pass, the 2 second job-file
    -- Cycle_Timer, and the 0.1 second floor on the engine body. Each is stamped on its own,
    -- so one running late does not shift the others.
    local UpdateTime1                         = os.clock()
    local UpdateTime2                         = os.clock()
    local main_engine_time                    = os.clock()

    -- The last position read from an outgoing 0x015 packet, and the clock it was read at.
    -- The fields follow the packet's order: X, then Z, then Y.
    local Location                            = { x = 0, z = 0, y = 0, t = 0 }

    -- Raised when the movement flag changes. The gated body turns it into one rebuild
    -- request on its next pass that is not busy, then lowers it. Changes that arrive while
    -- busy wait and cost one rebuild between them.
    local Require_Update                      = false
    ------------------------------------------------------------------------------------------------
    -- SECTION 19 - AUTOMATION AND COMBAT MONITORING
    ------------------------------------------------------------------------------------------------
    -- The polling engine and its movement detection, the Dual Wield and two-handed weapon
    -- checks, skillchain tracking, buff cancellation, and the Escha drink macro.

    -- Drink the Escha temporary items in sequence. One chained command, because each use has
    -- to wait out the one before it.
    function escha_temps()
        info('Escha Temps')
        windower.send_command(
            "input /item \"Monarch's Drink\" <me>;wait 2.5;input /item \"Braver's Drink\" <me>;wait 2.5;input /item \"Fighter's Drink\" <me>;wait 2.5;input /item \"Champion's Drink\" <me>;wait 2.5;input /item \"Soldier's Drink\" <me>;wait 2.5;input /item \"Barbarian's Drink\" <me>")
    end

    -- Other Blue Mages' Chain Affinity and Azure Lore, as their ability packets reported
    -- them: by the Blue Mage's actor id, a table from the ability's id to the clock its hold
    -- runs out. note_blue_affinity writes it, and run_burst reads it and drops Chain Affinity
    -- at that Blue Mage's next physical spell. A write sweeps the Blue Mages whose holds have
    -- all run out. This character's own Blue Mage reads its buff list instead.
    local blue_affinity = {}

    -- Whether a Blue Mage's entry still holds an affinity at the clock now.
    local function affinity_held(held, now)
        for _, ends in pairs(held) do
            if ends > now then return true end
        end
        return false
    end

    -- Note another Blue Mage's Chain Affinity or Azure Lore from its ability packet, so that
    -- Blue Mage's physical spells can end a burst window. th.lua's action handler hands this
    -- every job ability from any actor. Only the abilities BLUE_AFFINITY_HOLD names are
    -- noted, and only from a packet that says the ability was used, so a paralyzed attempt
    -- notes nothing. This character's own packets are passed over: its buff list says
    -- whether its own affinity is up. A malformed packet with no actor id is ignored, since a
    -- nil key would raise inside the raw handler.
    function note_blue_affinity(data)
        local hold = BLUE_AFFINITY_HOLD[data.param]
        if not hold then return end
        local actor = data.actor_id
        if actor == nil or actor == player.id then return end
        local target = data.targets[1]
        local action = target and target.actions[1]
        if not (action and action.message == ABILITY_USED_MESSAGE) then return end
        local now = os.clock()
        for id, held in pairs(blue_affinity) do
            if not affinity_held(held, now) then blue_affinity[id] = nil end
        end
        local held = blue_affinity[actor]
        if not held then
            held = {}
            blue_affinity[actor] = held
        end
        held[data.param] = now + hold
    end

    -- Whether a physical blue spell's caster had Chain Affinity or Azure Lore up, asked at the
    -- spell's finish. This character's own Blue Mage reads its buff list, which the game
    -- clears when a spell uses Chain Affinity up. The buff prediction is written into the list
    -- first, as at the start of every hook, so an affinity whose result has come counts before
    -- GearSwap lists it. The spell's own end marked any prediction to end after this result,
    -- and this write keeps it for the read. Another Blue Mage's entry answers, and its Chain
    -- Affinity goes with this spell, whatever the spell did.
    local function cast_under_affinity(actor, now)
        if actor == player.id then
            if buff_prediction.n > 0 then write_buff_predictions(false) end
            return buffactive['Chain Affinity'] ~= nil or buffactive['Azure Lore'] ~= nil
        end
        local held = blue_affinity[actor]
        if not held then return false end
        local up = affinity_held(held, now)
        held[CHAIN_AFFINITY_ID] = nil
        return up
    end

    -- Other Scholars' Immanence, as their ability packets reported it: by the Scholar's actor
    -- id, the clock its hold runs out. note_immanence writes it, and cast_under_immanence
    -- reads it and drops it at that Scholar's next spell Immanence carries. run_burst reads it
    -- too, so a chain-closing spell Immanence carries, from a Scholar with a note, uses the
    -- note up. A write sweeps the holds that have run out. This character's own Scholar reads
    -- its buff list instead.
    local immanence = {}

    -- Note another Scholar's Immanence from its ability packet, so that Scholar's next spell
    -- Immanence carries can end a burst window. th.lua's action handler hands this every job
    -- ability from any actor. Only a packet for Immanence that says it was used is noted, so
    -- a paralyzed attempt notes nothing. This character's own packets and a malformed packet
    -- with no actor id are passed over, as note_blue_affinity passes them over.
    function note_immanence(data)
        if data.param ~= IMMANENCE_ID then return end
        local actor = data.actor_id
        if actor == nil or actor == player.id then return end
        local target = data.targets[1]
        local action = target and target.actions[1]
        if not (action and action.message == ABILITY_USED_MESSAGE) then return end
        local now = os.clock()
        for id, ends in pairs(immanence) do
            if ends <= now then immanence[id] = nil end
        end
        immanence[actor] = now + IMMANENCE_HOLD
    end

    -- Whether a spell's caster had Immanence up for it, asked at the spell's finish. Only a
    -- spell IMMANENCE_SPELL names can carry it. Another Scholar's note answers, and that
    -- Scholar's next such spell uses it up, whatever the spell did. Any other spell leaves the
    -- note, since an area spell cast under Immanence does not use Immanence up. This
    -- character's own Scholar reads its buff list, which still lists Immanence when the
    -- spell's result arrives, with the buff prediction written into it first, as
    -- cast_under_affinity writes it. Most spells are neither kind, and cost two table reads.
    local function cast_under_immanence(actor, spell_id)
        local ends = immanence[actor]
        if ends then
            if not IMMANENCE_SPELL[spell_id] then return false end
            immanence[actor] = nil
            return ends > os.clock()
        end
        if not IMMANENCE_SPELL[spell_id] or actor ~= player.id then return false end
        if buff_prediction.n > 0 then write_buff_predictions(false) end
        return buffactive['Immanence'] ~= nil
    end

    -- Re-dress the cast in flight on a monster whose burst just changed, when the change
    -- differs from what the cast is dressed for. chain is the chain that landed there, or nil
    -- when the monster's window ended, and the cast now bursts only on a chain carrying its
    -- element. A raw handler cannot equip, so the record is marked with the burst to dress,
    -- and gs c burstredress does the equip. That command checks the cast is still in flight
    -- when it runs, since by then the cast may have ended and another may have left its own
    -- record. A change back before the command runs clears the mark.
    local function redress_pending(id, chain)
        local pending = E.burst_pending
        if not pending or pending.target ~= id then return end
        local bursts = chain ~= nil and chain.element_ids[pending.element] == true
        if bursts == pending.burst then
            pending.redress = nil
        else
            pending.redress = bursts
            windower.send_command('gs c burstredress')
        end
    end

    -- Record a skillchain so a cast landing inside its window can burst on it, or end the
    -- window when a move that can end one hits the same monster and makes no chain. The
    -- action handler in th.lua calls this for every actor, not just the player, so a chain
    -- closed by anyone opens a window. A weaponskill, a spell, an NPC's or a pet's TP move
    -- and an avatar's blood pact can each close a chain. A weaponskill, a TP move or a blood
    -- pact with a skillchain property can end a window, and so can a physical blue spell
    -- under Chain Affinity or Azure Lore and an elemental spell cast under Immanence. Most TP
    -- moves are a monster's, land on a player and make no chain, so once the first action is
    -- read the chain lookup is the first test, and a TP move that fails it reads little more
    -- than the record table. Each monster keeps its own record in E.burst_records, so a chain
    -- on one leaves another's window open. Nothing is looked up about the monster: a record
    -- matters only to a cast on that monster, and a cast proves its own range. The builders
    -- decide whether a cast lands inside the window. A chain or a window's end also
    -- re-dresses a cast already in flight on its monster, through gs c burstredress.
    function run_burst(data)
        local target = data.targets[1]
        local action = target and target.actions[1]
        if not action then return end
        local chain = skillchains[action.add_effect_message]
        if chain then
            local id = target.id
            -- A malformed packet with no target id is ignored, since a nil key would raise
            -- inside the raw handler.
            if id == nil then return end
            local records = E.burst_records
            local now = os.clock()
            -- A chain continued inside its monster's live window is one step further on.
            -- After the window has closed, a chain starts again as a first chain, step 2.
            local live = records[id]
            local step = 2
            if live and live.ends > now then step = live.step + 1 end
            local window = BURST_WINDOW[step] or BURST_WINDOW_FLOOR
            -- A helix closes a chain as a spell's finish, category 4, whose param is the
            -- spell's id. The category is tested too, because other actions carry ids from
            -- other tables, and a monster's TP move can share a helix's id.
            if data.category == 4 and HELIX_SPELL[data.param] then
                window = window + HELIX_WINDOW_BONUS
            end
            -- Expired records go with each write, so the table holds only open windows.
            for mob, rec in pairs(records) do
                if rec.ends <= now then records[mob] = nil end
            end
            records[id] = { elements = chain.element_ids, at = now, ends = now + window, step = step }
            log('Skillchain on [', id, ']: ', chain.english, ', step ', step, ', window ', window, 's')
            -- A physical blue spell that closes a chain uses up its caster's Chain Affinity,
            -- as any physical spell does. Another Scholar's spell that closes a chain under
            -- Immanence uses up that Scholar's Immanence, so the Scholar's next spell, a burst
            -- into this window, leaves the window open.
            if data.category == 4 then
                if BLUE_PHYSICAL[data.param] then
                    cast_under_affinity(data.actor_id, now)
                elseif immanence[data.actor_id] then
                    cast_under_immanence(data.actor_id, data.param)
                end
            end
            -- A cast already in flight on this monster re-dresses when this chain changes
            -- whether it bursts: into burst gear when the chain carries its element, however
            -- little of the cast is left, and out of it when the chain does not, while enough
            -- of the cast is left for the game to read the change. A re-dress that arrives
            -- after the spell has landed changes nothing for that spell.
            redress_pending(id, chain)
        -- A physical blue spell that hits a monster with a record ends its window while its
        -- caster has Chain Affinity or Azure Lore up, as a weaponskill with a property does.
        -- So does a single-target elemental spell cast under Immanence. A spell that lands no
        -- hit, and every other spell, leaves the window open.
        elseif data.category == 4 then
            if BLUE_PHYSICAL[data.param] then
                if not cast_under_affinity(data.actor_id, os.clock()) then return end
            elseif not cast_under_immanence(data.actor_id, data.param) then
                return
            end
            local records = E.burst_records
            local id = target.id
            if records[id] and SPELL_DAMAGE_MESSAGE[action.message] then
                records[id] = nil
                log('Skillchain window closed for [', id, ']')
                redress_pending(id)
            end
        -- A weaponskill, a TP move or a blood pact landing on a monster with a record ends its
        -- window, unless it carries no skillchain property, as Sanguine Blade does, or misses
        -- outright. Each is read from its own category's resource, and a TP move's row may
        -- carry no property fields at all. The resource is read only for a monster with a
        -- record. A weaponskill id the resource has no row for ends the window too, while a TP
        -- move or a pact with no row leaves it open, its property unknown. The read is
        -- guarded, because an index error would throw inside the action handler.
        else
            local table_name = BURST_ENDER_RESOURCE[data.category]
            if not table_name then return end
            local records = E.burst_records
            local id = target.id
            if records[id] and not SKILL_MISS_MESSAGE[action.message] then
                local row = res[table_name][data.param]
                local ends
                if row then ends = (row.skillchain_a or '') ~= '' else ends = data.category == 3 end
                if ends then
                    records[id] = nil
                    log('Skillchain window closed for [', id, ']')
                    redress_pending(id)
                end
            end
        end
    end

    -- Cancel buffs by name or id. Accepts several comma-separated patterns and cancels
    -- every active buff any of them matches, so one call can clear a family.
    function cancel(...)
        local command = table.concat({ ... }, ' ')
        if not command then return end
        local status_id_tab = command:split(',')
        status_id_tab.n = nil
        for _, v in pairs(player.buffs) do
            for _, r in pairs(status_id_tab) do
                -- Matched against both the localized buff name and the raw id, so a caller
                -- may pass either, and wc_match allows wildcards in the pattern.
                if windower.wc_match(res.buffs[v][Language], r) or windower.wc_match(tostring(v), r) then
                    cancel_buff(v)
                    break
                end
            end
        end
    end

    -- Cancel one buff by id, by injecting the game's own cancel packet (0xF1). The id is
    -- written little-endian across two bytes.
    function cancel_buff(id)
        windower.packets.inject_outgoing(0xF1, string.char(0xF1, 0x04, 0, 0, id % 256, math.floor(id / 256), 0, 0))
    end

    -- Re-read whether the character has the Dual Wield trait, job trait 18, which decides the
    -- offhand the builders choose. It is scheduled after load and after a subjob change, and
    -- the housekeeping pass runs it every 30 seconds.
    function dual_wield_check()
        local current_abilities = windower.ffxi.get_abilities()
        if table.contains(current_abilities.job_traits, 18) then
            E.DualWield = true
        else
            E.DualWield = false
        end
    end

    -- Whether a named weapon is two-handed, and whether it is a hand-to-hand weapon.
    -- res.items:with scans the whole item table, and a name's weapon skill never changes, so
    -- each name's skill is resolved once per load and remembered. Misses are remembered too,
    -- or an unknown name would rescan on every check.
    local name_is_two_handed, name_is_hand_to_hand
    -- The skill tables and the memo are scoped to this block, so only the two tests can reach
    -- them.
    do
        -- The six weapon skills the game treats as two-handed: Great Sword, Great Axe,
        -- Scythe, Polearm, Great Katana and Staff. Hand-to-Hand is neither one-handed nor
        -- two-handed, yet it holds the sub slot as well (res/skills.lua, id 1).
        local TWO_HAND_SKILL = { [4] = true, [6] = true, [7] = true, [8] = true, [10] = true, [12] = true }
        local HAND_TO_HAND_SKILL = 1
        local two_hand_memo = {}
        local function skill_of(name)
            local known = two_hand_memo[name]
            if known == nil then
                local row = res.items:with('en', name)
                known = row ~= nil and row.skill or false
                two_hand_memo[name] = known
            end
            return known
        end
        name_is_two_handed = function(name)
            return TWO_HAND_SKILL[skill_of(name)] ~= nil
        end
        name_is_hand_to_hand = function(name)
            return skill_of(name) == HAND_TO_HAND_SKILL
        end
    end

    -- Re-read the two-handed and hand-to-hand flags from the weapon the current mode names.
    -- The builders read them to choose the offhand.
    --
    -- Two shapes of a missing main are handled differently. A mode with no main entry
    -- answers from the weapon worn. After a mode change that is the weapon the previous mode
    -- left in hand, and at load it is whatever the character logged in holding. A mode whose
    -- main is a table with no name clears both flags.
    function two_hand_check()
        local weapon_set = sets.Weapons[state.WeaponMode.value]
        local weapon_name = weapon_set and weapon_set.main
        if not weapon_name then weapon_name = player.equipment.main end
        if type(weapon_name) == 'table' then weapon_name = weapon_name.name end
        if weapon_name == nil then
            E.TwoHand, E.HandToHand = false, false
            return
        end
        E.TwoHand, E.HandToHand = name_is_two_handed(weapon_name), name_is_hand_to_hand(weapon_name)
    end

    -- The main polling engine. The root registers it on the raw outgoing chunk event, and
    -- that has two consequences. It runs only when the client sends a packet, so it is not
    -- a reliable timer, and anything that must run on schedule belongs on prerender. And
    -- every outgoing packet enters here, so the body is gated to once per 0.1 seconds, with
    -- the movement check above the gate.
    --
    -- The 0.1 second rate is a product requirement. Make a tick cheaper, never rarer.
    function main_engine(id, data)
        local now = os.clock()
        -- A box drag settles here, on the clock just read, above every gate and early
        -- return. A character who is dead, asleep or mid-action can still drag a box, and
        -- the save is owed either way. It returns at once when nothing was dragged. It is
        -- read from E at the call because the display component loads after this file.
        E.drag_settle(now)
        -- Expire a busy window on its deadline, so a lost completion cannot leave the engine
        -- stuck and refusing to re-dress the character. The deadline is the age at which
        -- GearSwap drops the command, so by then no aftercast will come.
        if is_Busy and now - E.Spellstart > E.SpellCastTime then
            -- The window closes and the cast lets its implement go, with one line when the
            -- cast's end was lost. This is a raw handler, so any equip the release sends is
            -- discarded. The claim and the slot's hold are still cleared, and the next build's
            -- sweep completes the dress.
            expire_window()
            -- A rebuild that waited for that cast is sent now, since no aftercast will come to
            -- make it.
            if take_waiting_rebuild() then equip_set_command() end
        end
        -- Movement detection, read from the 0x015 packet this handler already carries: X,
        -- Z and Y as three floats at offset 0x04. It sits above the 0.1 second gate below
        -- because any outgoing packet uses up that window, while only 0x015 reports a
        -- position. Under the gate, a position update would be lost whenever another packet
        -- went first. It keeps its own 0.1 second floor instead, the interval the half-yalm
        -- threshold below assumes.
        --
        -- It is skipped while mounted, busy, dead, charmed or asleep. In each case the
        -- position cannot change usefully, or gear must not move.
        if id == 0x15 and now - Location.t >= .1 and not is_Busy and player
            and player.status ~= "Dead" and player.status ~= "Engaged dead"
            and not buffactive['Charm'] and not buffactive['Sleep']
            and not buffactive['Mounted'] then
            local px, pz, py = data:unpack('fff', 5)
            if px then
                Location.t = now
                -- Squared distance against a squared threshold, which avoids a square root
                -- on a path that runs up to ten times a second.
                local dx = px - Location.x
                local dz = pz - Location.z
                local dy = py - Location.y
                local movement = (dx * dx + dz * dz + dy * dy) > 0.25 -- 0.5 yalms, squared
                -- The flag is raised only while disengaged, but lowered whenever motion
                -- stops. So engaging partway through a run leaves it raised until the
                -- character halts.
                if movement and not E.is_moving then
                    if player.status ~= "Engaged" then
                        E.is_moving = true
                        Require_Update = true
                    end
                elseif not movement and E.is_moving then
                    E.is_moving = false
                    Require_Update = true
                end
                Location.x = px
                Location.z = pz
                Location.y = py
            end
        end
        -- The 0.1 second gate. main_engine_time is stamped at the end of a full pass and
        -- just before the early return below, so the throttle holds on both paths.
        if now - main_engine_time < .1 then return end
        if settings.debug then debug_box_update() end
        -- Local copies for the tests below, so each global is read once.
        local active_buffs = buffactive
        local player_status = player and player.status
        -- Nothing past this point may act on a character who cannot act. The clock is
        -- stamped here as well. While the character is dead, charmed or asleep, the debug
        -- box above still updates ten times a second rather than on every outgoing packet,
        -- and the first full pass after recovery waits out the rest of the window. The
        -- housekeeping clocks below stamp their own when they fire.
        if not player or player_status == "Dead" or player_status == "Engaged dead" or active_buffs['Charm'] or active_buffs['Sleep'] then
            main_engine_time = now
            return
        end

        -- The deferred rebuild, held off while busy so it cannot overwrite gear an action is
        -- still using. A raw handler cannot equip, so the rebuild is requested as a self
        -- command.
        if Require_Update and not is_Busy then
            equip_set_command()
            Require_Update = false
        end

        -- Housekeeping, every 30 seconds: re-read the dual wield trait, and expire tagged
        -- mobs the player has not touched in three minutes.
        if now - UpdateTime1 > 30 then
            dual_wield_check()
            cleanup_tagged_mobs()
            UpdateTime1 = now
        end

        -- The job file's own periodic hook, every 2 seconds, and only when the job file
        -- defines one. Skipped while busy so it cannot fight an action for the gear slots.
        if Cycle_Timer and now - UpdateTime2 > 2 and not is_Busy then
            Cycle_Timer()
            UpdateTime2 = now
        end

        main_engine_time = now
    end

    -- The version stamp. The root checks it against Rahvin_GS, so a stale copy of this file
    -- stops the load with an error that names it.
    return '2.2'
end
