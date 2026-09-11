

-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Use "gs c food" to use the specified food item
Food = "Miso Ramen"

BlueNuke = S{'Spectral Floe','Entomb', 'Magic Hammer', 'Tenebral Crush'}
BlueHealing = S{'Magic Fruit'}
BlueSkill = S{'Occultation','Erratic Flutter','Nature\'s Meditation','Cocoon','Barrier Tusk','Metallic Body','Mighty Guard'}
BlueTank = S{'Jettatura','Geist Wall','Blank Gaze','Sheep Song','Sandspin','Healing Breeze'}

-- 'TP','ACC','DT' are standard Default modes.  You may add more and assign equipsets for them ( Idle.X and OffenseMode.X )
state.OffenseMode:options('TP','ACC','DT','PDT','MEVA') -- ACC affects WS and TP modes

-- Function used to change pallets based off sub job and modes
function Macro_Sub_Job()
	local macro = 1
	if player.sub_job == "BLU" then
		state.OffenseMode:set('DT')
		--Set you macro pallet for when you are /BLU
		macro = 1
		send_command('wait 2;aset set tanking')
	else
		state.OffenseMode:set('TP')
		--Set you macro pallet for when you are NOT /BLU
		macro = 1
	end
	return macro
end


--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "12"
MacroBook = "12"
MacroSet = Macro_Sub_Job()

--Modes for specific to Rune Fencer.  These are defined below in "Weapons".
state.WeaponMode:options('Epeolatry','Naegling','Club','Great Axe','Axe')
state.WeaponMode:set('Epeolatry')

--Job-specific mode slots. Name one with UI_Name / UI_Name2 to show it in the status box.
UI_Name = ''
UI_Name2 = ''

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

-- HP balancing: 3000 HP
-- MP balancing: 950 MP

function get_sets()

	sets.Weapons = {}

	sets.Weapons['Epeolatry'] = {
		main=gear.epeolatry,
		sub=gear.utu,
	}

	sets.Weapons['Naegling'] = {
		main=gear.naegling,
		sub=gear.dolichenus,
	}

	sets.Weapons['Axe'] = {
		main=gear.dolichenus,
		sub=gear.naegling,
	}

	sets.Weapons['Great Axe'] = {
		main=gear.lycurgos,
		sub=gear.utu,
	}

	sets.Weapons['Club'] = {
		main = gear.loxoticPlusOne,
	}

	--Worn in the offhand whenever the main is one-handed and no dual-wield trait is active, engaged or idle.
	sets.Weapons.Shield = {}
	-- Worn when this character is put to sleep, and held until the sleep ends; nothing else re-dresses while asleep.
	sets.Weapons.Sleep = {}

	-- Standard Idle set
	sets.Idle = {
		ammo=gear.homiliary, -- 1 Refresh
		head = gear.nyameHead, -- 7/7
		body=gear.erilazBodyPlusThree,
		hands=gear.erilazHandsPlusThree, -- 11/11
		legs=gear.erilazLegsPlusThree, -- 13/13
		feet=gear.erilazFeetPlusThree, -- 11/11
		neck = gear.futharkTorquePlusTwo, -- 7/7
		waist=gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne, -- 3/5
		right_ear=gear.sanareEarring, -- Upgrade to +1/+2 Earring
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.runEnmity, -- 5/5
    } -- 75 PDT / 58 MDT		3571 HP/ 1149 MP

	sets.Idle.PDT = set_combine( sets.Idle, {
		neck = gear.loricatePlusOne,
		waist=gear.flumeBeltPlusOne, -- 4/0
		left_ear=gear.tuisto,
		left_ring = gear.gelatinousPlusOne, -- 7/-1
	})

	sets.Idle.MEVA = set_combine( sets.Idle, {
		ammo=gear.staunchPlusOne,
		neck = gear.warderCharmPlusOne,
		head=gear.erilazHeadPlusThree,
		body=gear.runeistBodyPlusThree,
		waist=gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne, -- 3/5
		right_ear=gear.sanareEarring,
	})

	sets.Idle.DT = set_combine( sets.Idle, {
		ammo=gear.yamarang,
		head=gear.erilazHeadPlusThree,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.tuisto,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	})

	-- Set is used for midcast during MEVA OffenseMode
	sets.MEVA = {
		ammo=gear.staunchPlusOne,
		neck = gear.warderCharmPlusOne,
		body=gear.runeistBodyPlusThree,
		hands=gear.erilazHandsPlusThree, -- 11/11
		legs=gear.erilazLegsPlusThree, -- 13/13
		feet=gear.erilazFeetPlusThree, -- 11/11
		waist=gear.platinumMoogleBelt,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		left_ear = gear.odnowaPlusOne, -- 3/5
	}

	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})

	-- This gear will be equiped when the player is moving and not engaged
	sets.Movement = {
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		legs = gear.carmineLegsPlusOnePathA,
    } -- 73 PDT / 33 MDT		3028 HP / 963 MP

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

	sets.Embolden = { back = gear.evasionistCapeDA,}

	sets.OffenseMode = {
		ammo = gear.coiste,
		head=gear.erilazHeadPlusThree,
		body=gear.asheraHarness,
		hands=gear.erilazHandsPlusThree,
		legs=gear.erilazLegsPlusThree,
		feet=gear.erilazFeetPlusThree,
		neck = gear.futharkTorquePlusTwo,
		waist=gear.windbuffetPlusOne,
		left_ear=gear.sherida,
		right_ear=gear.telos,
		left_ring=gear.niqmaddu,
		right_ring=gear.eponas,
		back = gear.runSTP,
	}

	--DPS set for tanking
	sets.OffenseMode.TP = {
		head=gear.erilazHeadPlusThree,
		head = gear.adhemarHeadPlusOnePathA,
		hands = gear.adhemarHandsPlusOnePathA,
		legs = gear.samnuhaTightsDA,
	}

	-- Gear to swap in for ACC when TP
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, { })

	--Physical Damage Taken set for tanking
	sets.OffenseMode.PDT = set_combine(sets.OffenseMode, {
		head = gear.nyameHead,
		body=gear.adamantiteArmor,
		hands=gear.turmsHandsPlusOne,
		neck = gear.unmovingPlusOne,
		waist = gear.sailfi,
		back=gear.nullShawl,
	}) -- Maintains Capped PDT with some DPS mixed in

	--Magic Evasion set for tanking
	sets.OffenseMode.MEVA = set_combine(sets.Idle.MEVA, {

	}) -- Focus on Magic Evasion with some DPS mixed in

	-- Standard Tanking TP set
	sets.OffenseMode.DT = set_combine(sets.Idle.DT, {	
		body=gear.asheraHarness,
		waist = gear.sailfi,
		left_ear=gear.sherida,
		right_ear=gear.telos,
		back = gear.runSTP,
	})

	-- Set used for hate generation on Job abilities
	sets.Enmity = { -- 23 Epo
		ammo=gear.sapience, -- 2
		head=gear.erilazHeadPlusThree,
		body=gear.erilazBodyPlusThree,
		hands=gear.erilazHandsPlusThree,
		legs=gear.erilazLegsPlusThree, -- 11
		feet=gear.erilazFeetPlusThree, -- 8 
		neck = gear.unmovingPlusOne, -- 10
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.crypticEarring, -- 4
		left_ring = gear.eihwazRing, -- 5
		right_ring = gear.moonlightRing4,
		back = gear.runEnmity, -- 10
	} -- 99 Enmity 2884 HP / 840 MP

	--Spell interruption rate down. This is the job file's own set, folded into the midcast sets below with set_combine, so a specific set overwrites it.
	sets.SIRD = set_combine(sets.Idle.DT, {
		ammo=gear.staunchPlusOne, -- 11
		head=gear.erilazHeadPlusThree, -- 20
		hands=gear.regalGauntlets, -- 10
		legs = gear.carmineLegsPlusOnePathA, -- 20
		neck=gear.moonlightNeck, -- 15
		waist=gear.audumbla, -- 10
		back = gear.runFC, -- 10
	})	-- 104 With Merits

	sets.Precast = {}
	-- Used for Magic Spells

	sets.Precast.FastCast = {
		ammo=gear.sapience, -- 2
		head=gear.runeistHeadPlusThree, -- 14
		body=gear.erilazBodyPlusThree, -- 13
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.futharkLegsPlusThree,
		feet = gear.carmineFeetPlusOnePathD, -- 8
		neck=gear.voltsurge,
		waist = gear.platinumMoogleBelt,
		right_ear = gear.etiolation,
		left_ear = gear.tuisto,
		left_ring=gear.kishar, -- 4
		right_ring = gear.gelatinousPlusOne,
		back = gear.runFC, -- 10
	} --65 FC

	sets.Precast.Enhancing = set_combine(sets.Precast.FastCast, {
		legs = gear.futharkLegsPlusThree, -- 7  (15 - 8) 
		waist=gear.siegel, -- 8
	}) -- 80+ FC

	sets.Precast.BlueMagic = set_combine (sets.Precast.FastCast, {})

	--The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, sets.Enmity, sets.SIRD, {})

	-- Enhancing Skill
	sets.Midcast.Enhancing = {
		ammo=gear.staunchPlusOne,
	    head=gear.erilazHeadPlusThree,
		body=gear.runeistBodyPlusThree,
		hands = gear.regalGauntlets,
		legs = gear.futharkLegsPlusThree,
		feet=gear.erilazFeetPlusThree,
		neck = gear.warderCharmPlusOne,
		waist=gear.carriers,
		left_ear=gear.tuisto,
		right_ear=gear.mimir,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.runEnmity, -- 5/5
	}

	-- Elemental
	sets.Midcast.Enhancing.Elemental = set_combine(sets.Midcast.Enhancing, {})

	-- Enhancing Duration on OTHERS
	sets.Midcast.Enhancing.Others = set_combine(sets.Midcast.Enhancing, {})

	-- Status
	sets.Midcast.Enhancing.Status = set_combine(sets.Midcast.Enhancing, {})

	-- Skill
	sets.Midcast.Enhancing.Skill = set_combine(sets.Midcast.Enhancing, {})

	-- Regen Sets
	sets.Midcast.Regen = set_combine(sets.Midcast.Enhancing, {})

	sets.Midcast.Refresh = set_combine(sets.Midcast.Enhancing, {})

	sets.Midcast.Cure = {}

	-- Blue Magic
	sets.Midcast.BlueMagic = {}
	sets.Midcast.BlueMagic.Skill = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Nuke = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Healing = set_combine(sets.Midcast.Cure, {})
	sets.Midcast.BlueMagic.ACC = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Enmity = set_combine(sets.Enmity, {})

	-- High MACC for landing spells
	sets.Midcast.Enfeebling = {}

	-- Divine magic skill, which Vivacious Pulse scales its cure from
	sets.Midcast.Divine = {}

	-- Specific gear for spells
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		waist=gear.siegel,
	})

	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, sets.SIRD, {
		body=gear.runeistBodyPlusThree,
	})

	sets.Midcast["Phalanx"] = set_combine(sets.Midcast.Enhancing, {
		head = gear.futharkHeadPlusThree, --7
		neck = gear.warderCharmPlusOne,
		waist=gear.carriers,
		left_ear=gear.tuisto,
		right_ear = gear.etiolation,
		body=gear.runeistBodyPlusThree,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	})

	sets.Midcast["Flash"] = set_combine(sets.Enmity, {
		neck = gear.warderCharmPlusOne,
		waist=gear.carriers,
		left_ear=gear.tuisto,
		hands=gear.erilazHandsPlusThree,
		body=gear.runeistBodyPlusThree,
		right_ear = gear.etiolation,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	})

	sets.Midcast["Foil"] = set_combine(sets.Enmity, {
		neck = gear.warderCharmPlusOne,
		waist=gear.carriers,
		left_ear=gear.tuisto,
		hands=gear.erilazHandsPlusThree,
		body=gear.runeistBodyPlusThree,
		right_ear = gear.etiolation,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	})

	-- JOB ABILITIES --
	sets.JA = {}
    sets.JA["Elemental Sforzo"] = set_combine(sets.Enmity, { body=gear.futharkBodyPlusThree })
    sets.JA["Gambit"] = set_combine(sets.Enmity, { hands=gear.runeistHandsPlusThree,})
    sets.JA["Rayke"] = set_combine(sets.Enmity, { feet=gear.futharkFeetPlusThree })
    sets.JA["Liement"] = set_combine(sets.Enmity, { body=gear.futharkBodyPlusThree })
    sets.JA["One for All"] = sets.Idle
    sets.JA["Valiance"] = set_combine(sets.Enmity, {
        body=gear.runeistBodyPlusThree,
		back = gear.runEnmity, -- 5/5
        legs=gear.futharkLegsPlusThree
    })
    sets.JA["Vallation"] = set_combine(sets.Enmity, {
        body=gear.runeistBodyPlusThree,
		back = gear.runEnmity, -- 5/5
        legs=gear.futharkLegsPlusThree
    })
    sets.JA["Pflug"] = set_combine(sets.Enmity, { feet=gear.runeistFeetPlusThree })
    sets.JA["Battuta"] = set_combine(sets.Enmity, { head=gear.futharkHeadPlusThree })
    sets.JA["Vivacious Pulse"] = set_combine(sets.Midcast.Divine, { head=gear.erilazHeadPlusThree })
    sets.JA["Embolden"] = set_combine(sets.Enmity, sets.Embolden)
    sets.JA["Swordplay"] = set_combine(sets.Enmity, { hands=gear.futharkHandsPlusThree })
	sets.JA["Provoke"] = sets.Enmity


	--Default WS set base
	sets.WS = {
		ammo=gear.knobkierrie,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck=gear.fotiaNeck,
		waist=gear.fotiaWaist,
		left_ear=gear.sherida,
		right_ear=gear.odr,
		left_ring=gear.niqmaddu,
		right_ring=gear.epimanondas,
		back = gear.runWSD,
	}
	--Merged after the set named for the weaponskill, so its slots win. Skipped where sets.WS['<name>'].ACC exists. Never merged in TP mode.
	sets.WS.ACC = {}
	sets.WS.WSD = {}
	sets.WS.CRIT = {}

	--Great Sword WS
	sets.WS["Hard Slash"] = {}
	sets.WS["Frostbite"] = {}
	sets.WS["Freezebite"] = {}
	sets.WS["Shockwave"] = {}
	sets.WS["Crescent Moon"] = {}
	sets.WS["Sickle Moon"] = {}
	sets.WS["Spinning Slash"] = {}
	sets.WS["Herculean Slash"] = {}
	sets.WS["Resolution"] = {}
	sets.WS["Dimidiation"] = {}

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

	return equipSet
end
-- Augment basic equipment sets
function midcast_custom(spell)
	local equipSet = {}
	equipSet = set_combine(equipSet, Embolden_Check(spell))

	if state.OffenseMode.value == 'MEVA' then
		equipSet = set_combine(equipSet, sets.MEVA)
	end

	return equipSet
end
-- Augment basic equipment sets
function aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end
--Function is called when the player gains or loses a buff
function buff_change_custom(name,gain)
	local equipSet = {}

	return equipSet
end
--This function is called when a update request the correct equipment set
function choose_set_custom()
	local equipSet = {}

	return equipSet
end
--Function is called when the player changes states
function status_change_custom(new,old)
	local equipSet = {}

	return equipSet
end
--Called for a "gs c" command the engine did not handle itself, and for the Weapon Mode, Job Mode and Job Mode 2 commands, which call it before the gear rebuild.
function self_command_custom(command)

end

-- This function is called when the job file is unloaded
function user_file_unload()

end

-- Swaps back when embolden buff is active to extend duration
function Embolden_Check(spell)
	local equipSet = {}
	if spell.target.id == player.id then
		if buffactive['Embolden'] then
			equipSet = sets.Embolden
			info('Embolden Set')
		end
	end
	return equipSet
end

function pet_change_custom(pet,gain)
	local equipSet = {}
	
	return equipSet
end

function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

function pet_midcast_custom(spell)
	local equipSet = {}

	return equipSet
end
