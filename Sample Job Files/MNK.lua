

-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "3"
MacroBook = "7"
MacroSet = "1"

-- Use "gs c food" to use the specified food item
Food = "Sublime Sushi"

--Uses Items Automatically
AutoItem = false

--Upon Job change will use a random lockstyleset
Random_Lockstyle = false

--Lockstyle sets to randomly equip
Lockstyle_List = {1,2,6,12}

-- 'TP','ACC','DT' are standard Default modes.  You may add more and assign equipsets for them ( Idle.X and OffenseMode.X )
state.OffenseMode:options('TP','ACC','DT','PDL','SB','MEVA','CRIT') -- ACC affects WS and TP modes

--Set Mode to Damage Taken as Default
state.OffenseMode:set('DT')

--Modes for weapons.  You must define the set in sets.Weapons['X']
state.WeaponMode:options('Verethragna','Karambit','Pole','Club')
state.WeaponMode:set('Verethragna')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- Weapon sets
	sets.Weapons['Verethragna'] = {
		main = gear.verethragna,
	}
	sets.Weapons['Karambit'] = {
		main=gear.karambit,
	}
	sets.Weapons['Pole'] = {
		main=gear.malignancePole,
		sub=gear.alberStrap,
	}
	sets.Weapons['Club'] = {
		main=gear.warpCudgel,
	}

	--Worn in the offhand whenever the main is one-handed and no dual-wield trait is active, engaged or idle.
	sets.Weapons.Shield = {}
	-- Worn when this character is put to sleep, and held until the sleep ends; nothing else re-dresses while asleep.
	sets.Weapons.Sleep = {}

	-- Idle sets
	sets.Idle = {
		ammo=gear.staunchPlusOne,
		head=gear.nullMasque,
		body=gear.adamantiteArmor,
		hands = gear.mpacaHands,
		legs = gear.mpacaLegs,
		feet = gear.mpacaFeet,
		neck = gear.warderCharmPlusOne,
		waist=gear.nullWaist,
		left_ear=gear.sanareEarring,
		right_ear = gear.odnowaPlusOne,
		left_ring=gear.purityRing,
		right_ring=gear.shadowRing,
		back = gear.mnkDADex,
    }
	sets.Idle.Resting = set_combine(sets.Idle, {})
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.CRIT = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
	})

	-- Engaged Sets
	sets.OffenseMode = {}
	sets.OffenseMode.TP = {
		ammo = gear.coiste,
		head = gear.adhemarHeadPlusOnePathA,
		body=gear.kendatsubaBodyPlusOne,
		hands = gear.adhemarHandsPlusOnePathA,
		legs = gear.hesychastLegsPlusFour,
		feet=gear.anchoriteFeetPlusFour,
		neck = gear.monkNodowaPlusTwo,
		waist=gear.moonbowBeltPlusOne,
		left_ear=gear.sherida,
		right_ear = gear.schere,
		left_ring=gear.lehkoHabhokaRing,
		right_ring=gear.gereRing,
		back = gear.mnkDADex,
	}

	sets.OffenseMode.ACC = set_combine(sets.OffenseMode.TP,{
	    head=gear.kendatsubaHeadPlusOne,
		body=gear.kendatsubaBodyPlusOne,
		hands=gear.kendatsubaHandsPlusOne,
		legs=gear.kendatsubaLegsPlusOne,
		feet=gear.kendatsubaFeetPlusOne,
	})

	sets.OffenseMode.DT = set_combine(sets.OffenseMode.TP,{
		head = gear.mpacaHead,
		body = gear.mpacaBody,
		hands = gear.mpacaHands,
		legs=gear.bhikkuLegsPlusThree,
		feet = gear.mpacaFeet,
	})

	sets.OffenseMode.PDL = set_combine(sets.OffenseMode.DT,{
	    ammo=gear.crepuscularPebble,
		legs = gear.mpacaLegs,
	})

	--This set is used when OffenseMode is SB and Engaged (Augments the TP base set)
	-- MNK gets 35 Native Subtle Blow
	-- Cap is 75% - 50% caps either I or II
	sets.OffenseMode.SB = set_combine(sets.OffenseMode[state.OffenseMode.value], {
		waist=gear.moonbowBeltPlusOne, -- SB II 15
		left_ear=gear.sherida, -- SB II 5
		left_ring=gear.niqmaddu, -- SB II 5
		right_ring=gear.chirichRingPlusOne, -- SB 10
		ammo=gear.coiste, -- SB 3
		right_ear = gear.schere, -- SB 3
	}) -- 35 + 16% SB I + %25 SB II = 76 one under

	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode.DT,{
		neck = gear.warderCharmPlusOne,
	})

	sets.OffenseMode.CRIT = set_combine(sets.OffenseMode,{
		head = gear.mpacaHead,
		body = gear.mpacaBody,
		hands = gear.mpacaHands,
		legs = gear.mpacaLegs,
		feet=gear.kendatsubaFeetPlusOne,
		left_ring=gear.niqmaddu,
		right_ring=gear.lehkoHabhokaRing,
		back = gear.mnkDADex,
	})

	-- Augments the engaged set while the Footwork buff is up
	sets.Foot_Work = { feet=gear.anchoriteFeetPlusFour, }

	--Used to swap into movement gear when the player is moving and not engaged
	sets.Movement = {
		feet=gear.hermesSandals,
	}

	--Impetus set has priority over any other modes
	sets.Impetus = {
		body=gear.bhikkuBodyPlusThree,
	}

	sets.Boost = {
		waist=gear.askSash,
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

	sets.Enmity = {
	    ammo=gear.sapience, -- 2
		head=gear.nullMasque,
		neck=gear.moonlightNeck, -- 15
		body=gear.emetHarnessPlusOne, -- 10
		hands=gear.kurysGloves, -- 9
		legs=gear.bhikkuLegsPlusThree,
		feet=gear.ahosiLeggings, -- 7
		waist=gear.platinumMoogleBelt,
	    left_ear=gear.crypticEarring, -- 4
		right_ear=gear.truxEarring, -- 5
		left_ring=gear.eihwazRing, -- 5
		right_ring=gear.petrov, -- 4
	} -- 61

	-- Used for Magic Spells
	sets.Precast = {}
	sets.Precast.FastCast = {
		ammo=gear.sapience, -- 2
		head = gear.herculeanHelmFC, --13
		body = gear.taeonTabardBFC, --9
		hands = gear.leylineGlovesFCB, --8
		legs = gear.herculeanTrousersFC, --6
		feet = gear.herculeanBootsFC, --6
		neck=gear.voltsurge, --4
		waist = gear.platinumMoogleBelt,
		left_ear=gear.etiolation, --1
		right_ear=gear.loquacious, --2
		left_ring=gear.prolix, --3
		right_ring=gear.rahabRing, -- 2
		back = gear.mnkFC, --10
	} -- FC 66

	--The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {
	
	})

	sets.JA = {}
	sets.JA["Hundred Fists"] = {legs = gear.hesychastLegsPlusFour}
	sets.JA["Berserk"] = {}
	sets.JA["Warcry"] = {}
	sets.JA["Defender"] = {}
	sets.JA["Aggressor"] = {}
	sets.JA["Provoke"] = sets.Enmity
	sets.JA["Focus"] = {}
	sets.JA["Dodge"] = {}
	sets.JA["Chakra"] = {
		ammo=gear.ironGobbet,
		head=gear.nullMasque,
		body=gear.anchoriteBodyPlusFour,
		hands = gear.hesychastHandsPlusThree,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.unmovingPlusOne,
		waist=gear.platinumMoogleBelt,
		left_ear=gear.tuisto,
		right_ear = gear.odnowaPlusOne,
		left_ring=gear.regalRing,
		right_ring = gear.gelatinousPlusOne,
		back = gear.mnkDADex,
	}
	sets.JA["Boost"] = {}
	sets.JA["Counterstance"] = {}
	sets.JA["Chi Blast"] = {
		head = gear.hesychastHeadPlusFour,
	}
	sets.JA["Mantra"] = {}
	sets.JA["Footwork"] = {}
	sets.JA["Perfect Counter"] = {}
	sets.JA["Impetus"] = {}
	sets.JA["Inner Strength"] = {}

	--Default WS set base
	sets.WS = { -- VS Base with Impetus Down
		ammo = gear.coiste,
		head=gear.mpacaHead,
		body=gear.mpacaBody,
		hands=gear.mpacaHands,
		legs=gear.mpacaLegs,
		feet=gear.mpacaFeet,
		neck=gear.fotiaNeck,
		waist=gear.moonbowBeltPlusOne,
		left_ear=gear.sherida,
		right_ear = gear.schere,
		left_ring=gear.niqmaddu,
		right_ring=gear.gereRing,
		back = gear.mnkCrit,
	}

	-- 35% SB I for MNK
	-- Belt SB II 15%
	-- Mpaca Legs -- SB II 5%
	-- Earring / Ring SB II 10%
	-- Need 4% SB
	sets.WS.SB = set_combine( sets.WS, { -- This maximize SB
		waist=gear.moonbowBeltPlusOne, -- SB II 15
		left_ear=gear.sherida, -- SB II 5
		left_ring=gear.niqmaddu, -- SB II 5
		legs=gear.mpacaLegs, -- SB II 5
		ammo=gear.coiste, -- SB 3
		right_ear = gear.schere, -- SB 3
	})

	sets.WS.MEVA = set_combine( sets.WS, {
		neck = gear.warderCharmPlusOne,
		left_ring=gear.defending,
	})

	--Merged after the set named for the weaponskill, so its slots win. Skipped where sets.WS['<name>'].ACC exists. Never merged in TP mode.
	sets.WS.ACC = set_combine(sets.WS,{})

	sets.WS.PDL = set_combine(sets.WS,{})

	sets.WS.Kicks = {
		ammo=gear.crepuscularPebble,
		head=gear.mpacaHead,
		body=gear.kendatsubaBodyPlusOne,
		hands = gear.ryuoHandsPlusOnePathA,
		legs = gear.hesychastLegsPlusFour,
		feet=gear.anchoriteFeetPlusFour,
		neck = gear.monkNodowaPlusTwo,
		waist=gear.moonbowBeltPlusOne,
		left_ear=gear.sherida,
		right_ear=gear.odr,
		--left_ring="Niqmaddu Ring",
		right_ring=gear.gereRing,
		back = gear.mnkCrit,
	}

	--WS Sets
	sets.WS["Combo"] = set_combine(sets.WS,{})
	sets.WS["Shoulder Tackle"] = set_combine(sets.WS,{})
	sets.WS["One Inch Punch"] = set_combine(sets.WS,{})
	sets.WS["Backhand Blow"] = set_combine(sets.WS,{})
	sets.WS["Raging Fists"] = set_combine(sets.WS,{
		neck=gear.monkNodowaPlusTwo,
		feet=gear.kendatsubaFeetPlusOne,
	})
	sets.WS["Spinning Attack"] = set_combine(sets.WS,{})
	sets.WS["Howling Fist"] = set_combine(sets.WS,{
		neck=gear.monkNodowaPlusTwo,
		feet=gear.kendatsubaFeetPlusOne,
	})
	sets.WS["Dragon Kick"] = sets.WS.Kicks
	sets.WS["Asuran Fists"] = set_combine(sets.WS,{})
	sets.WS["Tornado Kick"] = sets.WS.Kicks
	sets.WS["Victory Smite"] = set_combine(sets.WS,{})
	sets.WS["Shijin Spiral"] = set_combine(sets.WS,{
		back = gear.mnkDADex,
	})

	-- Worn on the action that tags a monster. The engine merges it only while TH Mode is not None, and every job but Thief starts at None.
	sets.TreasureHunter = {
		ammo=gear.perfectEgg,
		body=gear.volteJupon,
		waist=gear.chaac,
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
		if buffactive.Impetus then
			equipSet = sets.Impetus
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
	if player.status == "Engaged" then
		if buffactive['Impetus'] then
			equipSet = sets.Impetus
		end	
		if buffactive['Footwork'] then
			equipSet = set_combine(equipSet, sets.Foot_Work)
		end	
	end
	if buffactive['Boost'] then
		equipSet = set_combine(equipSet, sets.Boost)
	end
	return equipSet
end

-- This function is called when the job file is unloaded
function user_file_unload()

end
