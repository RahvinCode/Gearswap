
-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The lockstyle set, macro book and macro set that jobsetup applies at load.
LockStylePallet = "19"
MacroBook = "19"
MacroSet = "1"

-- When true, the engine uses a Remedy on paralysis or silence and a Holy Water on Doom.
AutoItem = false

-- The item that "gs c food" uses.
Food = "Sublime Sushi"

-- The offense modes this job cycles through, in place of the engine's default TP, ACC and DT.
-- Each mode needs a sets.OffenseMode.<Mode> and a sets.Idle.<Mode> below, and can also have
-- a sets.WS.<Mode>.
state.OffenseMode:options('TP','ACC','DT','PDT','PDL','SB','MEVA')

-- When true, each load picks a lockstyle set from Lockstyle_List in place of LockStylePallet.
Random_Lockstyle = false

-- Not read by this engine.
Organizer = false

-- The lockstyle sets Random_Lockstyle picks from.
Lockstyle_List = {1,2,6,12}

-- The offense mode selected at load.
state.OffenseMode:set('DT')

-- Weapon modes. Each one needs a sets.Weapons['<Mode>'] of the same name below.
state.WeaponMode:options('God Hands','Pole','Club')
state.WeaponMode:set('God Hands')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- Weapon sets, one per weapon mode above.
	sets.Weapons = {}

	sets.Weapons['God Hands'] = {
		main=gear.godhands,
		range = gear.neoAnimator,
		ammo=gear.canOfAutomatonOilPlusThree,
	}

	sets.Weapons['Club'] = {}

	sets.Weapons['Pole'] = {}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active,
	-- engaged or idle.
	sets.Weapons.Shield = {}

	-- Worn while idle. Every action's precast and midcast also start from this set, so a slot
	-- their sets leave out keeps its idle piece.
	sets.Idle = {
		head=gear.nyameHead,
		body=gear.nyameBody,
		hands=gear.nyameHands,
		legs=gear.nyameLegs,
		feet=gear.nyameFeet,
		neck = gear.loricatePlusOne,
		waist=gear.carriers,
		left_ear=gear.etiolation,
		right_ear = gear.odnowaPlusOne,
		left_ring=gear.regalRing,
		right_ring = gear.gelatinousPlusOne,
		back = gear.pupDA,
    }

	-- Worn over the idle set while a pet is out.
	sets.Idle.Pet = {}
	-- Worn over sets.Idle while idle in the matching offense mode. sets.Idle.Resting goes over
	-- them while resting.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDT = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
	})

	-- Worn over the idle set while a Phantom Roll on you stands at 11. It is for the Roller's
	-- Ring, which any job can wear and which gives Refresh +1 and Regain +10 at an 11, for example
	-- left_ring="Roller's Ring". It applies in every offense mode. It is worn only while idle, so
	-- any action swaps it out and it comes back when the action ends. While moving, a ring here
	-- replaces the movement set's ring in the same slot. This file's sets.Movement names no ring,
	-- so either slot is free.
	sets.Idle.XIRoll = {}

	-- The TP-mode form, merged after sets.Idle.XIRoll while idle in TP mode.
	sets.Idle.TP.XIRoll = {}

	-- Worn over the idle set while moving and not engaged.
	sets.Movement = {
		feet=gear.hermesSandals,
	}

	-- Worn when another character on this machine, running this engine, casts on you. Spell
	-- Received mode must be ON. sets.Cursna_Received is also the Doom set, worn when that mode is OFF.
	sets.Cure_Received = {}
	sets.Cursna_Received = {
	    neck=gear.nicander,
	    left_ring = gear.eshmun1,
		right_ring = gear.eshmun2,
		waist=gear.gishdubar,
	}
	sets.Phalanx_Received = {}
	sets.Protect_Shell_Received = {}
	sets.Regen_Received = {}
	sets.Refresh_Received = {}
	sets.Waltz_Received = {}

	-- The ring slot Zodiac Ring goes in when a spell's element matches the day: "right_ring" or
	-- "left_ring".
	Elemental_Bonus_Ring_Slot = "right_ring"

	-- Worn while using a Holy Water or Hallowed Water.
	sets.Holy_Water = {
	    neck=gear.nicander,
	}

	-- The engaged base, merged first in every offense mode. The mode's own set goes over it.
	sets.OffenseMode = {
		head=gear.mpacaHead,
		body = gear.mpacaBody,
		hands=gear.mpacaHands,
		legs=gear.mpacaLegs,
		feet=gear.mpacaFeet,
		neck=gear.combatantTorque,
		waist=gear.moonbowBeltPlusOne,
		left_ear=gear.macheEarringPlusOne,
		right_ear = gear.karagozEarringPlusOneSTP,
		left_ring=gear.gereRing,
		right_ring=gear.niqmaddu,
		back = gear.pupDA,
	}

	sets.OffenseMode.TP = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.DT = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.PDT = set_combine(sets.OffenseMode, { })
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode.TP,{
		neck=gear.warderCharmPlusOne,
	})

	-- SB mode. It lists its own pieces rather than building on another mode's set.
	-- Cap is 75% - 50% in either I or II
	sets.OffenseMode.SB = 
	{
		-- Belt SB II 15%
		-- Mpaca Legs SB II 5%
		-- Ring SB II 5%
		-- Earring SB I 6%
		head=gear.volteTiara, -- 6%
		body=gear.malignanceBody,
		hands=gear.volteMittens, -- 6%
		legs=gear.mpacaLegs, -- 5%
		feet=gear.volteSpats, -- 6%
		waist=gear.moonbowBeltPlusOne, -- 15%
		left_ear=gear.macheEarringPlusOne,
		right_ear=gear.karagozEarringPlusOne, -- 6%
		left_ring=gear.chirichRingPlusOne, -- 10%
		right_ring=gear.niqmaddu, -- 5%
		back = gear.pupDA,
	}
	sets.OffenseMode.PDL = set_combine(sets.OffenseMode, {})

	sets.Precast = {}

	-- Fast cast gear, worn at the start of every spell.
	sets.Precast.FastCast = {}

	-- An enmity set for Provoke below. The engine does not read it.
	sets.Precast.Enmity = {}

	-- The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this
	-- set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {})

	-- Worn while the automaton performs an action. A set named for the action goes over it.
	sets.Pet_Midcast = {}
	sets.Pet_Midcast['Bone Crusher'] = {}

	-- Job abilities. sets.JA is worn for every ability, and a set named for the ability goes over it.
	sets.JA = {}
	sets.JA['Overdrive'] = set_combine(sets.Idle, {})
	sets.JA['Activate'] = set_combine(sets.Idle, {})
	sets.JA['Repair'] = set_combine(sets.Idle, {})
	sets.JA['Role Reversal'] = set_combine(sets.Idle, {})
	sets.JA['Ventriloquy'] = set_combine(sets.Idle, {})
	sets.JA['Tactical Switch'] = set_combine(sets.Idle, {})
	sets.JA['Cooldown'] = set_combine(sets.Idle, {})
	sets.JA['Deus Ex Automata'] = set_combine(sets.Idle, {})
	sets.JA['Maintenance'] = set_combine(sets.Idle, {})
	sets.JA['Heady Artifice'] = set_combine(sets.Idle, {})

	-- Deploy, Deactivate, Retrieve and the maneuvers are type PetCommand. The engine merges no
	-- sets.JA child for one, and the midcast build that follows replaces whatever the precast
	-- wore, so a pet command has no set of its own. The automaton's own actions wear
	-- sets.Pet_Midcast.
	--
	-- This one is not the engine's: precast_custom below reads it by name for any action whose
	-- name contains Maneuver.
	sets.JA.Maneuver = set_combine(sets.Idle, {})

	sets.JA["Berserk"] = {}
	sets.JA["Warcry"] = {}
	sets.JA["Defender"] = {}
	sets.JA["Aggressor"] = {}
	sets.JA["Provoke"] = sets.Precast.Enmity

	-- Worn on every weaponskill. The set named for the weaponskill goes over it, then the offense
	-- mode's set.
	sets.WS = {
		head=gear.mpacaHead,
		body=gear.mpacaBody,
		hands=gear.mpacaHands,
		legs=gear.mpacaLegs,
		feet=gear.mpacaFeet,
		neck=gear.fotiaNeck,
		waist=gear.moonbowBeltPlusOne,
		left_ear=gear.macheEarringPlusOne,
		right_ear = gear.schere,
		left_ring=gear.regalRing,
		right_ring=gear.niqmaddu,
		back = gear.pupDA,
	}

	-- Subtle blow pieces for weaponskills in SB mode.
	sets.WS.SB = {}

	-- Worn on weaponskills in ACC mode, over the set named for the weaponskill. List only the
	-- pieces the mode changes, since every slot named here overrides the weaponskill's own set. A
	-- weaponskill with an ACC set of its own, sets.WS['<name>'].ACC, takes that instead. The other
	-- mode sets work the same way, except that sets.WS.TP is never merged.
	sets.WS.ACC = {}

	sets.WS.PDL = {}

	-- Sets named for each weaponskill.
	sets.WS["Combo"] = set_combine(sets.WS,{})
	sets.WS["Shoulder Tackle"] = set_combine(sets.WS,{})
	sets.WS["One Inch Punch"] = set_combine(sets.WS,{})
	sets.WS["Backhand Blow"] = set_combine(sets.WS,{})
	sets.WS["Raging Fists"] = set_combine(sets.WS,{})
	sets.WS["Spinning Attack"] = set_combine(sets.WS,{})
	sets.WS["Howling Fist"] = set_combine(sets.WS,{})
	sets.WS["Dragon Kick"] = set_combine(sets.WS,{})
	sets.WS["Asuran Fists"] = set_combine(sets.WS,{})
	sets.WS["Tornado Kick"] = set_combine(sets.WS,{})
	sets.WS["Victory Smite"] = set_combine(sets.WS,{})
	sets.WS["Shijin Spiral"] = set_combine(sets.WS,{})

	-- Treasure Hunter gear. While TH Mode is Tag or Full Time, it is worn for an action aimed at an
	-- untagged monster and while engaged on one. Full Time also keeps it on whenever engaged. TH
	-- Mode starts at None, which never wears it, on every job but Thief.
	sets.TreasureHunter = {

	}

end

-------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE UNLESS YOU NEED TO MAKE JOB SPECIFIC RULES
-------------------------------------------------------------------------------------------------------------------

-- Called when the subjob changes.
function sub_job_change_custom(new, old)
	-- Typically used to change the macro book or set.
end

-- Called before each action, after the engine's own checks. Call cancel_spell() here to stop
-- the action.
function pretarget_custom(spell,action)

end
-- Called as each action starts. The table it returns is merged over the engine's precast set.
-- Maneuvers wear sets.JA.Maneuver, and weaponskills in MEVA mode keep the magic evasion neck.
function precast_custom(spell)
	local equipSet = {}
	if spell.name:contains('Maneuver') then
		equipSet = sets.JA.Maneuver
	elseif spell.type == 'WeaponSkill' then
		if state.OffenseMode.value == "MEVA" then
			equipSet = { neck=gear.warderCharmPlusOne, }
		end
	end
	return equipSet
end
-- Called while each action is in flight. The table it returns is merged over the engine's
-- midcast set, which is empty for abilities, weaponskills and items.
function midcast_custom(spell)
	local equipSet = {}

	return equipSet
end
-- Called when each action ends. The table it returns is merged over the idle or engaged set the
-- engine rebuilds.
function aftercast_custom(spell)
	local equipSet = {}

	return choose_gear()
end

-- Called when a pet is summoned or lost. The table it returns is merged over the rebuilt idle or
-- engaged set.
function pet_change_custom(pet,gain)
	local equipSet = {}

	return equipSet
end

-- Called while a pet's action is in flight. The table it returns is merged over sets.Pet_Midcast
-- and the set named for the action.
function pet_midcast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called when a pet's action ends. The table it returns is merged over the idle or engaged set
-- the engine rebuilds.
function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called when a buff is gained or lost. The table it returns is merged over the rebuilt idle or
-- engaged set. A change during one of your own actions is dressed when the action ends instead.
function buff_change_custom(name,gain)
	local equipSet = {}

	return choose_gear()
end
-- Called whenever the engine rebuilds the idle or engaged set, which it does after each action,
-- on a buff or status change, and when movement starts or stops. The table it returns is merged
-- over that set.
function choose_set_custom()
	local equipSet = {}

	return choose_gear()
end
-- Called when the player's status changes, such as engaging, disengaging or resting. The table
-- it returns is merged over the rebuilt idle or engaged set.
function status_change_custom(new,old)
	local equipSet = {}

	return choose_gear()
end
-- Called with each "gs c" command, in lowercase, that the engine's own commands leave unclaimed.
-- Use it to add commands of your own. The Weapon Mode, Job Mode and Job Mode 2 commands also call
-- it, before their gear rebuild.
function self_command_custom(command)

end
-- Shared by the aftercast, buff change, rebuild and status change hooks above, so a rule placed
-- here applies to all four.
function choose_gear()
	local equipSet = {}

	return equipSet
end

-- Called when the job file unloads, after the engine releases its keybinds and slot holds.
function user_file_unload()

end
