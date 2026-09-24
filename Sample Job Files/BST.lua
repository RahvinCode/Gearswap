

-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The in-game lockstyle set, macro book and macro set this file applies on load.
LockStylePallet = "19"
MacroBook = "19"
MacroSet = "1"

-- Use a Remedy for paralysis or silence, and a Holy Water for doom, automatically.
AutoItem = false

-- The food "gs c food" uses.
Food = "Sublime Sushi"

-- Offense modes. TP, ACC and DT are the engine's defaults, and more can be added. Each mode picks its own engaged, idle and weaponskill sets, so each one offered needs a sets.OffenseMode.<Mode> and a sets.Idle.<Mode> below.
state.OffenseMode:options('TP','ACC','DT','PDL','SB','MEVA')

-- Pick a random lockstyle from Lockstyle_List on each load, in place of LockStylePallet.
Random_Lockstyle = false

-- Not read by this engine.
Organizer = false

-- The lockstyle sets the random pick chooses from.
Lockstyle_List = {1,2,6,12}

-- The offense mode the file starts in.
state.OffenseMode:set('DT')

-- Weapon modes. Each name needs a matching sets.Weapons entry.
state.WeaponMode:options('Decimation','Pangu')
state.WeaponMode:set('Decimation')

-- Naming JobMode shows it in chat and on the status box.
UI_Name = 'Pet'

-- Job mode picks the jug pet. Call Beast and Bestial Loyalty equip the sets.Jugs entry the current job mode names.
state.JobMode:options('None','FatsoFargann','ScissorlegXerin','GenerousArthur','BlackbeardRandy','AcuexFamiliar')
state.JobMode:set('FatsoFargann')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- The jug for each pet in the job mode list, keyed by the job mode value.
	sets.Jugs = {}
	sets.Jugs['FatsoFargann'] = {ammo=gear.jugOfCurdledPlasmaBroth }
	sets.Jugs['AcuexFamiliar'] = {ammo=gear.jugOfVenomousBroth}
	sets.Jugs['GenerousArthur'] = {ammo=gear.jugOfDireBroth}
	sets.Jugs['BlackbeardRandy'] = {ammo=gear.jugOfMeatyBroth}
	sets.Jugs['ScissorlegXerin'] = {ammo=gear.jugOfSpicyBroth}

	-- Weapon sets, one per weapon mode.
	sets.Weapons = {}

	sets.Weapons['Decimation'] = {
		main=gear.dolichenus,
		sub=gear.ikengaAxe,
	}

	sets.Weapons['Pangu'] = {
		main=gear.pangu,
		sub=gear.ikengaAxe,
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons['Shield'] = {}
	-- Worn over the idle set when you are put to sleep. Its slots stay held until you wake, and the engine re-dresses nothing else while you sleep.
	-- Put gear here that wakes you, such as a piece that drains HP.
	sets.Weapons['Sleep'] = {}

	-- Worn whenever you are not engaged. It is also the floor under every action, so a slot an action's sets leave unnamed keeps its idle piece.
	sets.Idle = {
		ammo=gear.staunchPlusOne,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
		left_ear=gear.etiolation,
		right_ear = gear.odnowaPlusOne,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.bstSTP,
    }

	-- Merged over the idle set while a pet is out.
	sets.Idle.Pet = set_combine(sets.Idle,{
		hands = gear.gletiHands,
		feet = gear.gletiFeet,
	    right_ear=gear.nukumiEarringPlusOne,
		right_ring=gear.cathPalugRing,
		back = gear.bstPetRegen,
	})

	-- Idle sets for each offense mode, merged over the idle set, and Resting, merged over them while you rest.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})

	-- Worn over the idle set while a Phantom Roll on you stands at 11.
	-- It is meant for Roller's Ring, which every job can wear and which grants Refresh +1 and Regain +10 at an 11, e.g. left_ring="Roller's Ring".
	-- This set applies in every offense mode. The TP set below applies only in TP mode and merges after it.
	-- It is worn only while idle, so any action swaps it out, and it comes back when the action ends.
	-- While you move, a ring named here replaces a movement ring in the same slot. This file's sets.Movement names no ring, so either slot is free.
	sets.Idle.XIRoll = {}
	-- The TP mode version, merged after the one above.
	sets.Idle.TP.XIRoll = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = {
		--feet="Hermes' Sandals",
	}

	-- Worn when another character on this machine, running this engine, starts casting one of these spells on you, while Spell Received mode is ON. sets.Cursna_Received is also the Doom set, worn and held while you are doomed with that mode OFF.
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

	-- The ring slot Zodiac Ring goes in when an elemental spell matches the day's element: "right_ring" or "left_ring".
	Elemental_Bonus_Ring_Slot = "right_ring"

	-- Worn when you use a Holy Water or Hallowed Water.
	sets.Holy_Water = {
	    neck=gear.nicander,
	}

	-- Engaged sets. sets.OffenseMode is worn in every offense mode, and the current mode's set merges over it.
	sets.OffenseMode = {
		ammo = gear.coiste,
		head=gear.malignanceHead,
		body = gear.gletiBody,
		hands=gear.malignanceHands,
		legs = gear.gletiLegs,
		feet=gear.malignanceFeet,
		neck=gear.anu,
		waist = gear.sailfi,
		left_ear=gear.crepuscularEar,
		right_ear=gear.sherida,
		left_ring=gear.gereRing,
		right_ring=gear.eponas,
		back=gear.nullShawl,
	}

	sets.OffenseMode.TP = set_combine (sets.OffenseMode, {})

	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {
		body=gear.malignanceBody,
		legs=gear.malignanceLegs,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.bstSTP,
	})

	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {})

	sets.OffenseMode.PDL = set_combine(sets.OffenseMode,{})

	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, {
		neck=gear.warderCharmPlusOne,
	})

	-- Cap is 75% - 50% limit in I or II
	sets.OffenseMode.SB = {}

	-- Merged over the engaged set while a dual-wield trait is active.
	sets.DualWield = {
		left_ear=gear.eabani,
		waist=gear.reiki,
	}

	sets.Precast = {}

	-- Fast cast, worn at the start of every spell.
	sets.Precast.FastCast = {}

	--The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {})

	-- Worn while your pet performs an action. The set named for the action merges over it, and then pet_midcast_custom below adds the set for each Ready list the move is in.
	sets.Pet_Midcast = {
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.gletiFeet,
		neck = gear.beastmasterCollarPlusTwo,
		waist=gear.incarnationSash,
		left_ear=gear.ferineEarring,
		right_ear=gear.nukumiEarringPlusOne,
		right_ring=gear.cathPalugRing,
		back = gear.bstSTP,
	}

	-- TP-based Ready moves, in the engine's Ready_TP list.
	sets.Pet_Midcast.TP = set_combine(sets.Pet_Midcast, {})

	-- Ready moves in the Ready_Magic list, dressed for magic attack bonus.
	sets.Pet_Midcast.MAB = set_combine(sets.Pet_Midcast, {})

	-- Debuff moves in the Ready_Debuff list, dressed for magic accuracy.
	sets.Pet_Midcast.MACC = set_combine(sets.Pet_Midcast, {
		ammo = gear.hesperiidae,
		left_ear=gear.crepuscularEar,
		back = gear.bstPetRegen,
	})

	-- Multi-hit moves in the Ready_Multi list.
	sets.Pet_Midcast.Multi = set_combine(sets.Pet_Midcast, {

	})

	-- A set named for one pet action merges over sets.Pet_Midcast. pet_midcast_custom's list set merges after it, so on a slot both name, the list set wins.
	sets.Pet_Midcast['TP Drainkiss'] = set_combine(sets.Pet_Midcast.MACC, { })

	-- Worn on a Ready move, which arrives as type Monster. The engine merges this set whole. Its Magic, TP, Debuff and Standard children are
	-- placeholders the engine never reads, though a child keyed by a buff name merges while that buff is up.
	sets.Ready = {
		hands=gear.nukumiHandsPlusOne,
		legs = gear.gletiLegs,
	}

	-- Job abilities. sets.JA is worn for every job ability, and the set named for the ability merges over it.
	sets.JA = {}
	sets.JA['Familiar'] = set_combine(sets.Idle,
	{
		legs = gear.ankusaLegsPlusThree,
	})
	sets.JA['Charm'] = set_combine(sets.Idle, 
	{
		legs = gear.ankusaLegsPlusThree,
	})
	sets.JA['Gauge'] = set_combine(sets.Idle, {})
	sets.JA['Tame'] = set_combine(sets.Idle, 
	{
		head=gear.totemicHeadPlusThree,
	})
	sets.JA['Reward'] = set_combine(sets.Idle, 
	{ 
		head=gear.bisonWarbonnet,
		body=gear.totemicBodyPlusThree,
		legs = gear.ankusaLegsPlusThree,
		feet = gear.ankusaFeetPlusThree,
		left_ear=gear.ferineEarring,
		ammo=gear.petFoodThetaBiscuit,
	})
	sets.JA['Call Beast'] = set_combine(sets.Idle, 
	{
	    hands = gear.ankusaHandsPlusThree,
	})
	sets.JA['Feral Howl'] = set_combine(sets.Idle, 
	{
	    body = gear.ankusaBodyPlusThree,
	})
	sets.JA['Unleash'] = set_combine(sets.Idle, {})
	sets.JA['Bestial Loyalty'] = set_combine(sets.Idle, 
	{
		hands = gear.ankusaHandsPlusThree,
	})
	sets.JA['Killer Instinct'] = set_combine(sets.Idle, 
	{
		head = gear.ankusaHeadPlusThree,
	})

	-- Fight, Heel, Leave, Stay, Snarl, Spur, Ready and Run Wild are type PetCommand. The engine
	-- merges no sets.JA child for one, and the midcast build that follows replaces whatever the
	-- precast wore, so a pet command has no set of its own. A Ready move arrives as type Monster
	-- and wears sets.Ready. The pet's own action wears sets.Pet_Midcast.

	-- Weaponskill base, worn for every weaponskill. The set named for the weaponskill merges over it.
	sets.WS = {
		ammo = gear.coiste,
		head = gear.gletiHead,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
		neck=gear.beastmasterCollarPlusTwo,
		waist = gear.sailfi,
		left_ear=gear.nukumiEarringPlusOne,
		right_ear=gear.sherida,
		left_ring=gear.gereRing,
		right_ring=gear.eponas,
		back = gear.bstDA,
	}

	-- Worn on every weaponskill while Killer Instinct is up. Killer Instinct shares your pet's killer effect, and a body that augments
	-- killer effects, such as Nukumi Gausape +3, adds half your total killer effect to the damage you deal.
	-- sets.WS['Killer Instinct'] = {}

	-- Merged over the weaponskill sets in SB mode. Subtle Blow gear goes here.
	sets.WS.SB = {}

	-- Merged in ACC mode after the set named for the weaponskill, so its slots win. Name only the slots ACC mode should change. A weaponskill with an ACC set of its own skips it.
	sets.WS.ACC = {}

	-- Merged over the weaponskill sets in PDL mode, the same way.
	sets.WS.PDL = {}

	-- Sets named for one weaponskill, merged over sets.WS.
	sets.WS["Raging Axe"] = set_combine(sets.WS,{})
	sets.WS["Smash Axe"] = set_combine(sets.WS,{})
	sets.WS["Gale Axe"] = set_combine(sets.WS,{})
	sets.WS["Avalanche Axe"] = set_combine(sets.WS,{})
	sets.WS["Spinning Axe"] = set_combine(sets.WS,{})
	sets.WS["Rampage"] = set_combine(sets.WS,{})
	sets.WS["Calamity"] = set_combine(sets.WS,{})
	sets.WS["Mistral Axe"] = set_combine(sets.WS,{})
	sets.WS["Decimation"] = set_combine(sets.WS,{})
	sets.WS["Bora Axe"] = set_combine(sets.WS,{})

	-- Treasure Hunter gear, worn on an action or melee swing against a monster not yet tagged, and throughout a fight in Full Time mode. It is never worn in None mode, where every job but Thief starts.
	sets.TreasureHunter = {

	}

end

-------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE UNLESS YOU NEED TO MAKE JOB SPECIFIC RULES
-------------------------------------------------------------------------------------------------------------------

-- Called when the player's subjob changes.
function sub_job_change_custom(new, old)
	-- A common use is switching the macro book or set.
end

-- Called before each action, after the engine's own checks. Cancel the action here with cancel_spell(). Nothing it returns is used.
function pretarget_custom(spell,action)

end
-- Gear returned here merges over the engine's precast set for the action. In MEVA mode a weaponskill keeps the magic evasion neck.
function precast_custom(spell)
	local equipSet = {}
	if spell.type == 'WeaponSkill' then
		if state.OffenseMode.value == "MEVA" then
			equipSet = { neck=gear.warderCharmPlusOne, }
		end
	end
	return equipSet
end
-- Gear returned here merges over the engine's midcast set for the action.
function midcast_custom(spell)
	local equipSet = {}

	return equipSet
end
-- Gear returned here merges over the idle or engaged set worn when an action ends.
function aftercast_custom(spell)
	local equipSet = {}

	return choose_gear()
end

-- Called when a pet is summoned, dismissed or dies. Gear returned here merges over the idle or engaged set.
function pet_change_custom(pet,gain)
	local equipSet = {}

	return equipSet
end

-- Called while your pet's action is in flight. Gear returned here merges over sets.Pet_Midcast and the set named for the action.
-- This one adds the set for each Ready list the move is in, and prints which set it added last, or Pet Not Set when the move is in none.
function pet_midcast_custom(spell)
	local equipSet = {}
		local message = 'Pet Not Set'
		if Ready_Standard[spell.name] then
			equipSet = set_combine(equipSet, sets.Pet_Midcast)
			message = 'Pet Standard Set'
		end
		if Ready_TP[spell.name] then
			equipSet = set_combine(equipSet, sets.Pet_Midcast.TP)
			message = 'Pet TP Set'
		end
		if Ready_Magic[spell.name] then
			equipSet = set_combine(equipSet, sets.Pet_Midcast.MAB)
			message = 'Pet Magic Set'
		end
		if Ready_Debuff[spell.name] then
			equipSet = set_combine(equipSet, sets.Pet_Midcast.MACC)
			message = 'Pet Magic Accuracy Set'
		end
		if Ready_Multi[spell.name] then
			equipSet = set_combine(equipSet, sets.Pet_Midcast.Multi)
			message = 'Pet Multi-Attack Set'
		end
		info(message)
	return equipSet
end

-- Called when your pet's action ends. Gear returned here merges over the idle or engaged set.
function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called when a buff is gained or lost, except while an action is in flight. Gear returned here merges over the idle or engaged set.
function buff_change_custom(name,gain)
	local equipSet = {}

	return choose_gear()
end

-- Gear returned here merges over every idle and engaged build: after each action, on a buff, status or mode change, and when you start or stop moving.
function choose_set_custom()
	local equipSet = {}

	return choose_gear()
end
-- Called when your status changes, such as engaging, disengaging or resting. Gear returned here merges over the idle or engaged set that follows.
function status_change_custom(new,old)
	local equipSet = {}

	return choose_gear()
end
-- Called for a "gs c" command the engine does not handle itself, and for the weapon mode, job mode and job mode 2 commands, which call it before the gear rebuild. The command arrives in lowercase.
function self_command_custom(command)

end
-- A helper this file's aftercast, buff change, status change and choose_set_custom hooks all return, so gear logic written here reaches every idle and engaged build.
function choose_gear()
	local equipSet = {}

	return equipSet
end

-- Called when the job file unloads, after the engine has released its keys and held slots.
function user_file_unload()

end
