
-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The in-game lockstyle set, macro book and macro set this file applies on load.
LockStylePallet = "13"
MacroBook = "2"
MacroSet = "1"

-- The food "gs c food" uses.
Food = "Sublime Sushi"

-- Use a Remedy for paralysis or silence, and a Holy Water for doom, automatically.
AutoItem = false

-- Pick a random lockstyle from Lockstyle_List on each load, in place of LockStylePallet.
Random_Lockstyle = false

-- The lockstyle sets the random pick chooses from.
Lockstyle_List = {1,2,6,12}

-- Not read by this engine.
Organizer = false

-- Offense modes, and the one the file starts in. TP, ACC and DT are the engine's defaults, and more can be added.
-- Each mode picks its own engaged, idle and weaponskill sets, so each one offered needs a sets.OffenseMode.<Mode> and a sets.Idle.<Mode> below.
state.OffenseMode:options('DT','TP','PDL','MEVA','ACC','SB','CRIT')
state.OffenseMode:set('DT')

-- Weapon modes. Each name needs a matching sets.Weapons entry.
state.WeaponMode:options('Trishula','Savage Blade','Shining One')
state.WeaponMode:set('Trishula')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup(LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- Weapon sets, one per weapon mode.
	sets.Weapons = {}

	sets.Weapons['Trishula'] = {
		main=gear.trishula,
		sub=gear.utu,
	}

	sets.Weapons['Shining One'] = {
		main=gear.shiningOne,
		sub=gear.utu,
	}

	sets.Weapons['Savage Blade'] = {
		main=gear.naegling,
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons.Shield = {}

	-- Worn whenever you are not engaged. It is also the floor under every action, so a slot an action's sets leave unnamed keeps its idle piece.
	sets.Idle = {
	    ammo=gear.staunchPlusOne,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.loricatePlusOne,
		waist=gear.carriers,
		left_ear = gear.odnowaPlusOne,
		right_ear=gear.eabani,
		left_ring = gear.gelatinousPlusOne,
		right_ring=gear.defending,
		back = gear.drgDADt,
	}

	-- Merged over the idle set while your wyvern is out.
	sets.Idle.Pet = set_combine(sets.Idle, {
		head=gear.peltastHeadPlusThree,
		neck = gear.dragoonCollarPlusTwo,

	})
	-- Idle sets for each offense mode, merged over the idle set, and Resting, merged over them while you rest.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.CRIT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
	})
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
		legs = gear.carmineLegsPlusOnePathA,
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
		head=gear.flammaHeadPlusTwo,
		body=gear.hjarrandiBody,
		hands=gear.flammaManopolasPlusTwo,
		legs = gear.nyameLegs,
		feet=gear.flammaFeetPlusTwo,
		neck = gear.vimPlusOne,
		waist = gear.sailfi,
		left_ear=gear.sherida,
		right_ear=gear.peltastEarringPlusOne,
		left_ring=gear.lehkoHabhokaRing,
		right_ring=gear.niqmaddu,
		back=gear.nullShawl,
	}

	sets.OffenseMode.TP = set_combine(sets.OffenseMode, {})

	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {
		head=gear.hjarrandiHead,
		hands=gear.peltastHandsPlusThree,
		legs = gear.gletiLegs,
		feet=gear.peltastFeetPlusThree,
		neck = gear.dragoonCollarPlusTwo,
	})
	
	sets.OffenseMode.PDL = set_combine(sets.OffenseMode, {
	    head = gear.gletiHead,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
	})

	sets.OffenseMode.CRIT = set_combine(sets.OffenseMode, {
	    head = gear.gletiHead,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
	})

	-- With 29 Auspice 70 Subtle Blow
	sets.OffenseMode.SB =  set_combine(sets.OffenseMode, {
		left_ear=gear.sherida, -- SB II 5
		body=gear.dagonBreastplate, -- SB II 10
		-- Niqmaddu Ring (SB 5) is worn in the right ring slot, from sets.OffenseMode.
		legs = gear.gletiLegs, -- SB 15
		right_ear=gear.peltastEarringPlusOne, -- SB 6
	})

	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {})

	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, {
		ammo = gear.coiste,
		head=gear.peltastHeadPlusThree,
		body = gear.gletiBody,
		hands=gear.peltastHandsPlusThree,
		legs=gear.peltastLegsPlusThree,
		feet=gear.peltastFeetPlusThree,
		neck = gear.dragoonCollarPlusTwo,
		waist = gear.sailfi,
		left_ear=gear.sherida,
		right_ear=gear.peltastEarringPlusOne,
		left_ring=gear.moonlightRing,
		right_ring=gear.niqmaddu,
		back = gear.drgDADt,
	})
  
	-- Merged over the engaged set while a dual-wield trait is active.
	sets.DualWield = {}

	sets.Precast = {}

	-- Fast cast, worn at the start of every spell.
	sets.Precast.FastCast = {
		ammo=gear.sapience, --2
		head = gear.carmineHeadPlusOnePathD, --14
		body = gear.taeonTabardFC, --9
		hands = gear.leylineGlovesFCB, --8
		legs = gear.carmineLegsPlusOnePathA,
		feet = gear.carmineFeetPlusOnePathD, --8
		neck=gear.voltsurge, --4
		left_ear=gear.etiolation, --1
		right_ear=gear.tuisto,
		left_ring = gear.gelatinousPlusOne,
		right_ring=gear.weatherspoon, --5
	}
		
	-- Not read by the engine. sets.JA["Provoke"] below is this same table.
	sets.Enmity = {}

	--The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {})
	sets.Midcast.Enhancing = set_combine(sets.Idle, {})
	sets.Midcast.Enfeebling = set_combine(sets.Idle, {})
	
	-- Job abilities. sets.JA is worn for every job ability, and the set named for the ability merges over it.
	sets.JA = {}
	sets.JA["Berserk"] = {}
	sets.JA["Warcry"] = {}
	sets.JA["Defender"] = {}
	sets.JA["Aggressor"] = {}
	sets.JA["Provoke"] = sets.Enmity
	sets.JA["Third Eye"] = {}
	sets.JA["Meditate"] = {}
	sets.JA["Warding Circle"] = {}
	sets.JA["Hasso"] = {}
	sets.JA["Seigan"] = {}
	sets.JA['Call Wyvern'] = {
		body = gear.pteroslaverBodyPlusThree,
	}
	sets.JA['Spirit Surge'] = {
		body = gear.pteroslaverBodyPlusThree,
		--legs="Vishap Brais +3",
		--feet={ name="Ptero. Greaves +3", augments={'Enhances "Empathy" effect',}},
		neck = gear.dragoonCollarPlusTwo,
	}
	sets.JA['Ancient Circle'] = {} --legs="Vishap Brais +3"
	sets.JA['Spirit Link'] = {
		--head="Vishap Armet +3",
		hands=gear.peltastHandsPlusThree,
		--feet={ name="Ptero. Greaves +3", augments={'Enhances "Empathy" effect',}},
		neck = gear.dragoonCollarPlusTwo,
	}

	-- Not read by the engine. The jump sets below build on it.
	sets.Jump = {
		ammo = gear.coiste,
		head=gear.hjarrandiHead,
		body=gear.hjarrandiBody,
		hands=gear.flammaManopolasPlusTwo,
		legs = gear.gletiLegs,
		feet=gear.flammaFeetPlusTwo,
		neck = gear.vimPlusOne,
		waist=gear.reiki,
		left_ear=gear.sherida,
		right_ear=gear.telos,
		left_ring=gear.moonlightRing,
		right_ring=gear.crepuscularRing,
		back = gear.drgDADt,
	}

	sets.JA['Jump'] = set_combine(sets.Jump, {})

	sets.JA['High Jump'] = set_combine(sets.Jump, {})

	sets.JA['Spirit Jump'] = set_combine(sets.Jump, {
		legs=gear.peltastLegsPlusThree,
		feet=gear.peltastFeetPlusThree,
	})

	sets.JA['Soul Jump'] = set_combine(sets.Jump, {
		legs=gear.peltastLegsPlusThree,
	})
	
	sets.JA['Super Jump'] = set_combine(sets.Jump, {
	})
	
	sets.JA['Angon'] = {
		ammo=gear.angon,
		hands = gear.pteroslaverHandsPlusThree,
	}

	-- Worn while your wyvern acts. The engine wears sets.Pet_Midcast and then the set named for the action.
	sets.Pet_Midcast = {}

	sets.Pet_Midcast['Steady Wing'] = {}

	sets.Pet_Midcast['Smiting Breath'] = {
		--head={ name="Ptero. Armet +3", augments={'Enhances "Deep Breathing" effect',}},
    	neck = gear.dragoonCollarPlusTwo,
	}

	sets.Pet_Midcast['Restoring Breath'] = {
		--head={ name="Ptero. Armet +3", augments={'Enhances "Deep Breathing" effect',}},
    	--legs="Vishap Brais +3",
    	--feet={ name="Ptero. Greaves +3", augments={'Enhances "Empathy" effect',}},
    	neck = gear.dragoonCollarPlusTwo,
	}

	-- Breath is not an action name. The six breath sets below are this same table.
	sets.Pet_Midcast.Breath = {
		--head={ name="Ptero. Armet +3", augments={'Enhances "Deep Breathing" effect',}},
    	neck = gear.dragoonCollarPlusTwo,
	}

	sets.Pet_Midcast['Flame Breath'] = sets.Pet_Midcast.Breath
	sets.Pet_Midcast['Frost Breath'] = sets.Pet_Midcast.Breath
	sets.Pet_Midcast['Sand Breath'] = sets.Pet_Midcast.Breath
	sets.Pet_Midcast['Gust Breath'] = sets.Pet_Midcast.Breath
	sets.Pet_Midcast['Hydro Breath'] = sets.Pet_Midcast.Breath
	sets.Pet_Midcast['Lightning Breath'] = sets.Pet_Midcast.Breath
	 
	-- Treasure Hunter gear, worn on an action or melee swing against a monster not yet tagged, and throughout a fight in Full Time mode. It is never worn in None mode, where every job but Thief starts.
	sets.TreasureHunter = {
		waist=gear.chaac,
	}

	-- Weaponskill base, worn for every weaponskill. The set named for the weaponskill merges over it.
	sets.WS = {
		ammo=gear.knobkierrie,
		head=gear.peltastHeadPlusThree,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.dragoonCollarPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.peltastEarringPlusOne,
		left_ring=gear.sroda,
		right_ring=gear.niqmaddu,
		back = gear.drgWSDDt,
	}

	-- Merged in ACC mode after the set named for the weaponskill, so its slots win. Name only the slots ACC mode should change. A weaponskill with an ACC set of its own skips it.
	-- PDL and CRIT below work the same way in their modes.
	sets.WS.ACC = {}

	sets.WS.PDL = {
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
	}

	-- WSD is not an offense mode. It is worn only through the weaponskill sets below that are built from it.
	sets.WS.WSD = set_combine(sets.WS, {
		right_ear=gear.thrud,
		hands = gear.pteroslaverHandsPlusThree,
	})

	-- CRIT names only what it changes over sets.WS, so the sets below that build on it combine sets.WS and sets.WS.CRIT.
	sets.WS.CRIT = {
		ammo = gear.coiste,
		head = gear.gletiHead,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
		waist=gear.fotiaWaist,
		left_ring=gear.lehkoHabhokaRing,
	}

	-- Sets named for one weaponskill, merged over sets.WS. Each ['PDL'] child is worn in PDL mode in place of sets.WS.PDL.
	sets.WS['Impulse Drive'] = set_combine(sets.WS, sets.WS.CRIT, {
		ammo=gear.knobkierrie,
		head=gear.peltastHeadPlusThree,
		right_ear=gear.thrud,
		left_ring=gear.sroda,
		hands = gear.pteroslaverHandsPlusThree,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		waist = gear.sailfi,
	})
	sets.WS['Impulse Drive']['PDL'] = set_combine(sets.WS, sets.WS.CRIT, {
		ammo=gear.knobkierrie,
		head=gear.peltastHeadPlusThree,
		left_ring=gear.sroda,
		feet = gear.nyameFeet,
		waist = gear.sailfi,
	})

	sets.WS['Savage Blade'] = set_combine(sets.WS.WSD, {})
	sets.WS['Savage Blade']['PDL'] = set_combine(sets.WS.WSD, {
		right_ear=gear.peltastEarringPlusOne,
		body=gear.peltastBodyPlusThree,
		right_ring=gear.epimanondas,
	})

	sets.WS['Geirskogul'] = set_combine(sets.WS, {
		neck=gear.fotiaNeck,
		left_ear=gear.sherida,
		left_ring=gear.regalRing,
	})
	sets.WS['Geirskogul']['PDL'] = set_combine(sets.WS, {
		left_ring=gear.epimanondas,
		left_ear=gear.peltastEarringPlusOne,
		body = gear.gletiBody,
		waist=gear.fotiaWaist,
	})

	sets.WS['Drakesbane'] = set_combine(sets.WS, {
		ammo = gear.coiste,
		head = gear.gletiHead,
		body=gear.hjarrandiBody,
		hands = gear.gletiHands,
		legs=gear.peltastLegsPlusThree,
		feet = gear.gletiFeet,
		neck = gear.dragoonCollarPlusTwo,
		left_ring=gear.lehkoHabhokaRing,
	})
	sets.WS['Drakesbane']['PDL'] = set_combine(sets.WS, {
		ammo=gear.crepuscularPebble,
		head = gear.gletiHead,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs=gear.peltastLegsPlusThree,
		feet = gear.gletiFeet,
		left_ring=gear.lehkoHabhokaRing,
		left_ear=gear.thrud,
	})

	sets.WS["Camlann's Torment"] = set_combine(sets.WS, {
		waist=gear.fotiaWaist,
	})
	sets.WS["Camlann's Torment"]['PDL'] = set_combine(sets.WS, {
		left_ear=gear.thrud,
		body = gear.gletiBody,
		legs = gear.gletiLegs,
	})

	sets.WS['Stardiver'] = set_combine(sets.WS, {
		left_ring=gear.lehkoHabhokaRing,
		neck=gear.fotiaNeck,
		hands=gear.peltastHandsPlusThree,
		left_ear=gear.sherida,
		right_ear=gear.moonshadeEarringAcc,
		waist=gear.fotiaWaist,
	})
	sets.WS['Stardiver']['PDL'] = set_combine(sets.WS, sets.WS.CRIT, {
		neck = gear.dragoonCollarPlusTwo,
		left_ring=gear.sroda,
		feet = gear.nyameFeet,
	})

	sets.WS['Sonic Thrust'] = sets.WS.CRIT
	sets.WS['Raiden Thrust'] = sets.WS.WSD
	sets.WS['Thunder Thrust'] = sets.WS.WSD
	sets.WS['Leg Sweep'] = sets.WS.WSD
	sets.WS['Diarmuid'] = sets.WS.WSD
	
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
-- Gear returned here merges over the engine's precast set for the action.
function precast_custom(spell)
	local equipSet = {}

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

	return equipSet
end
-- Called when a buff is gained or lost, except while an action is in flight. Gear returned here merges over the idle or engaged set.
function buff_change_custom(name,gain)
	local equipSet = {}

	return equipSet
end
-- Gear returned here merges over every idle and engaged build: after each action, on a buff, status or mode change, and when you start or stop moving.
function choose_set_custom()
	local equipSet = {}

	return equipSet
end
-- Called when your status changes, such as engaging, disengaging or resting. Gear returned here merges over the idle or engaged set that follows.
function status_change_custom(new,old)
	local equipSet = {}

	return equipSet
end
-- Called for a "gs c" command the engine does not handle itself, and for the weapon mode, job mode and job mode 2 commands, which call it before the gear rebuild. The command arrives in lowercase.
function self_command_custom(command)

end
-- Called when the job file unloads, after the engine has released its keys and held slots.
function user_file_unload()

end

-- Called when your wyvern is called or lost. Gear returned here merges over the idle or engaged set.
function pet_change_custom(pet,gain)
	local equipSet = {}

	return equipSet
end

-- Called when your wyvern's action ends. Gear returned here merges over the idle or engaged set.
function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called while your wyvern's action is in flight. Gear returned here merges over sets.Pet_Midcast and the set named for the action.
function pet_midcast_custom(spell)
	local equipSet = {}

	return equipSet
end
