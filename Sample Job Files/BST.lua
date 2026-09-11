

-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "19"
MacroBook = "19"
MacroSet = "1"

--Uses Items Automatically
AutoItem = false

-- Use "gs c food" to use the specified food item
Food = "Sublime Sushi"

-- 'TP','ACC','DT' are standard Default modes.  You may add more and assign equipsets for them ( Idle.X and OffenseMode.X )
state.OffenseMode:options('TP','ACC','DT','PDL','SB','MEVA') -- ACC affects WS and TP modes

--Upon Job change will use a random lockstyleset
Random_Lockstyle = false

-- Not read by this engine.
Organizer = false

--Lockstyle sets to randomly equip
Lockstyle_List = {1,2,6,12}

--Set Mode to Damage Taken as Default
state.OffenseMode:set('DT')

--Modes for specific to Beastmaster
state.WeaponMode:options('Decimation','Pangu')
state.WeaponMode:set('Decimation')

--Enable JobMode for UI.
UI_Name = 'Pet'

--Modes for specific Pets
state.JobMode:options('None','FatsoFargann','ScissorlegXerin','GenerousArthur','BlackbeardRandy','AcuexFamiliar')
state.JobMode:set('FatsoFargann')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- This uses a set Jug based off the Pet selected in the "JobMode"
	sets.Jugs = {}
	sets.Jugs['FatsoFargann'] = {ammo=gear.jugOfCurdledPlasmaBroth }
	sets.Jugs['AcuexFamiliar'] = {ammo=gear.jugOfVenomousBroth}
	sets.Jugs['GenerousArthur'] = {ammo=gear.jugOfDireBroth}
	sets.Jugs['BlackbeardRandy'] = {ammo=gear.jugOfMeatyBroth}
	sets.Jugs['ScissorlegXerin'] = {ammo=gear.jugOfSpicyBroth}

	-- Weapon setup
	sets.Weapons = {}

	sets.Weapons['Decimation'] = {
		main=gear.dolichenus,
		sub=gear.ikengaAxe,
	}

	sets.Weapons['Pangu'] = {
		main=gear.pangu,
		sub=gear.ikengaAxe,
	}

	--Worn in the offhand whenever the main is one-handed and no dual-wield trait is active, engaged or idle.
	sets.Weapons['Shield'] = {}
	-- Worn when this character is put to sleep, and held until the sleep ends; nothing else re-dresses while asleep.
	sets.Weapons['Sleep'] = {}

	-- Standard Idle set with -DT, Refresh, Regen and movement gear
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

	sets.Idle.Pet = set_combine(sets.Idle,{
		hands = gear.gletiHands,
		feet = gear.gletiFeet,
	    right_ear=gear.nukumiEarringPlusOne,
		right_ring=gear.cathPalugRing,
		back = gear.bstPetRegen,
	})

	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})

	--Used to swap into movement gear when the player is moving and not engaged
	sets.Movement = {
		--feet="Hermes' Sandals",
	}

	--Worn when another character on this machine, running this engine, casts on you; Spell Received Mode must be ON. sets.Cursna_Received is also the Doom set, worn when that mode is OFF.
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
	sets.Holy_Water = {
	    neck=gear.nicander,
	}

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

	--Base TP set to build off
	sets.OffenseMode.TP = set_combine (sets.OffenseMode, {})

	--This set is used when OffenseMode is DT and Engaged (Augments the TP base set)
	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {
		body=gear.malignanceBody,
		legs=gear.malignanceLegs,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.bstSTP,
	})

	--This set is used when OffenseMode is ACC and Engaged (Augments the TP base set)
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {})

	sets.OffenseMode.PDL = set_combine(sets.OffenseMode,{})

	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, {
		neck=gear.warderCharmPlusOne,
	})

	--This set is used when OffenseMode is SB and Engaged (Augments the TP base set)
	-- Cap is 75% - 50% limit in I or II
	sets.OffenseMode.SB = {}

	sets.DualWield = {
		left_ear=gear.eabani,
		waist=gear.reiki,
	}

	sets.Precast = {}

	-- Used for Magic Spells
	sets.Precast.FastCast = {}

	sets.Precast.Enmity = {}

	--The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {})

	-- Pet Moves

	-- Default
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

	-- TP based Ready moves
	sets.Pet_Midcast.TP = set_combine(sets.Pet_Midcast, {})

	-- Magic Attack Bonus Ready moves
	sets.Pet_Midcast.MAB = set_combine(sets.Pet_Midcast, {})

	-- Debuff moves that need MACC
	sets.Pet_Midcast.MACC = set_combine(sets.Pet_Midcast, {
		ammo = gear.hesperiidae,
		left_ear=gear.crepuscularEar,
		back = gear.bstPetRegen,
	})

	sets.Pet_Midcast.Multi = set_combine(sets.Pet_Midcast, {

	})

	-- Example for a specific move overwrite
	sets.Pet_Midcast['TP Drainkiss'] = set_combine(sets.Pet_Midcast.MACC, { })

	-- Worn on a Ready move, which arrives as type Monster. The engine merges this set whole and
	-- reads no child under it, so sets.Ready.Magic, .TP, .Debuff and .Standard are placeholders.
	sets.Ready = {
		hands=gear.nukumiHandsPlusOne,
		legs = gear.gletiLegs,
	}

	-- Job Abilities
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
	-- precast wore, so a pet command has no set of its own. A ready move arrives as type Monster
	-- and wears sets.Ready; the pet's own action wears sets.Pet_Midcast.

	--Default WS set base
	sets.WS = {
		ammo = gear.coiste,
		head = gear.gletiHead,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
		neck=gear.beastmasterCollarPlusTwo,
		waist = gear.sailfi,
		left_ear=gear.sherida,
		right_ear=gear.nukumiEarringPlusOne,
		left_ring=gear.gereRing,
		right_ring=gear.eponas,
		back = gear.bstDA,
	}

	sets.WS.SB = set_combine( sets.WS, { -- This maximize SB

	})

	--Merged after the set named for the weaponskill, so its slots win. Skipped where sets.WS['<name>'].ACC exists. Never merged in TP mode.
	sets.WS.ACC = set_combine(sets.WS,{})

	sets.WS.PDL = set_combine(sets.WS,{})

	--WS Sets
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

	-- Worn on the action that tags a monster. The engine merges it only while TH Mode is not None, and every job but Thief starts at None.
	sets.TreasureHunter = {

	}

end

-------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE UNLESS YOU NEED TO MAKE JOB SPECIFIC RULES
-------------------------------------------------------------------------------------------------------------------

-- Called when the player's subjob changes.
function sub_job_change_custom(new, old)
	-- Typically used for Macro pallet changing
end

--Adjust custom precast actions
function pretarget_custom(spell,action)

end
-- Augment basic equipment sets
function precast_custom(spell)
	local equipSet = {}
	if spell.type == 'WeaponSkill' then
		if state.OffenseMode.value == "MEVA" then
			equipSet = { neck=gear.warderCharmPlusOne, }
		end
	end
	return equipSet
end
-- Augment basic equipment sets
function midcast_custom(spell)
	local equipSet = {}

	return equipSet
end
-- Augment basic equipment sets
function aftercast_custom(spell)
	local equipSet = {}

	return choose_gear()
end

-- Called when the pet dies or is summoned
function pet_change_custom(pet,gain)
	local equipSet = {}

	return equipSet
end

-- Called during a pet midcast
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

-- Called after the pet performs an action
function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

--Function is called when the player gains or loses a buff
function buff_change_custom(name,gain)
	local equipSet = {}

	return choose_gear()
end

--This function is called when a update request the correct equipment set
function choose_set_custom()
	local equipSet = {}

	return choose_gear()
end
--Function is called when the player changes states
function status_change_custom(new,old)
	local equipSet = {}

	return choose_gear()
end
--Called for a "gs c" command the engine did not handle itself, and for the Weapon Mode, Job Mode and Job Mode 2 commands, which call it before the gear rebuild.
function self_command_custom(command)

end
--Custom Function
function choose_gear()
	local equipSet = {}

	return equipSet
end

-- This function is called when the job file is unloaded
function user_file_unload()

end
