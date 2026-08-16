--Hurin

-- Load and initialize the include file.
include('GearSets-Include')
include('Mirdain-Include')

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "13"
MacroBook = "2"
MacroSet = "1"

-- Use "gs c food" to use the specified food item 
Food = "Sublime Sushi"

--Uses Items Automatically
AutoItem = false

--Upon Job change will use a random lockstyleset
Random_Lockstyle = false

--Lockstyle sets to randomly equip
Lockstyle_List = {1,2,6,12}

-- Set to true to run organizer on job changes
Organizer = false

-- 'TP','ACC','DT' are standard Default modes.  You may add more and assign equipsets for them
state.OffenseMode:options('DT','TP','PDL','MEVA','ACC','SB','CRIT') -- ACC effects WS and TP modes
state.OffenseMode:set('DT')

--Modes for specific to Dragoon
state.WeaponMode:options('Trishula','Savage Blade','Shining One','Unlocked')
state.WeaponMode:set('Trishula')

-- Initialize Player
jobsetup(LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- Weapon setup
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

	-- This stops GS from chaning weapons (Abyssea Proc etc)
	sets.Weapons['Unlocked'] ={}

	sets.Weapons.Shield = {}

	-- Standard Idle set
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

	sets.Idle.Pet = set_combine(sets.Idle, {
		head=gear.peltastHeadPlusThree,
		neck = gear.dragoonCollar,

	})
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
	
	sets.Movement = {
		legs = gear.carmineLegsPlusOnePathA,
	}

	--Spell Received Sets
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

	--Base TP set to build off
	sets.OffenseMode.TP = set_combine(sets.OffenseMode, {})

	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {
		head=gear.hjarrandiHead,
		hands=gear.peltastHandsPlusThree,
		legs = gear.gletiLegs,
		feet=gear.peltastFeetPlusThree,
		neck = gear.dragoonCollar,
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
		left_ring=gear.niqmaddu, -- SB 5
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
		neck = gear.dragoonCollar,
		waist = gear.sailfi,
		left_ear=gear.sherida,
		right_ear=gear.peltastEarringPlusOne,
		left_ring=gear.niqmaddu,
		right_ring=gear.moonlightRing,
		back = gear.drgDADt,
	})
  
	sets.DualWield = {}

	sets.Precast = {}

	-- Used for Magic Spells (Fast Cast)
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
		left_ring=gear.weatherspoon, --5
		right_ring = gear.gelatinousPlusOne,
	}
		
	sets.Enmity = {}

	--Base set for midcast - if not defined will notify and use your idle set for surviability
	sets.Midcast = set_combine(sets.Idle, {})
	sets.Midcast.Enhancing = set_combine(sets.Idle, {})
	sets.Midcast.Enfeebling = set_combine(sets.Idle, {})
	
	--Job Abilities
	sets.JA = {}
	sets.JA["Berserk"] = {}
	sets.JA["Warcry"] = {}
	sets.JA["Defender"] = {}
	sets.JA["Aggressor"] = {}
	sets.JA["Provoke"] = sets.Precast.Enmity
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
		neck = gear.dragoonCollar,
	}
	sets.JA['Ancient Circle'] = {} --legs="Vishap Brais +3"
	sets.JA['Spirit Link'] = {
		--head="Vishap Armet +3",
		hands=gear.peltastHandsPlusThree,
		--feet={ name="Ptero. Greaves +3", augments={'Enhances "Empathy" effect',}},
		neck = gear.dragoonCollar,
	}

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
		left_ring=gear.crepuscularRing,
		right_ring=gear.moonlightRing,
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

		-- Wyvern Ability Gear Sets Below
	sets.Pet_Midcast = {}

	sets.Pet_Midcast['Steady Wing'] = {}

	sets.Pet_Midcast['Smiting Breath'] = {
		--head={ name="Ptero. Armet +3", augments={'Enhances "Deep Breathing" effect',}},
    	neck = gear.dragoonCollar,
	}

	sets.Pet_Midcast['Restoring Breath'] = {
		--head={ name="Ptero. Armet +3", augments={'Enhances "Deep Breathing" effect',}},
    	--legs="Vishap Brais +3",
    	--feet={ name="Ptero. Greaves +3", augments={'Enhances "Empathy" effect',}},
    	neck = gear.dragoonCollar,
	}

	sets.Pet_Midcast.Breath = {
		--head={ name="Ptero. Armet +3", augments={'Enhances "Deep Breathing" effect',}},
    	neck = gear.dragoonCollar,
	}

	sets.Pet_Midcast['Flame Breath'] = sets.Pet_Midcast.Breath
	sets.Pet_Midcast['Frost Breath'] = sets.Pet_Midcast.Breath
	sets.Pet_Midcast['Sand Breath'] = sets.Pet_Midcast.Breath
	sets.Pet_Midcast['Gust Breath'] = sets.Pet_Midcast.Breath
	sets.Pet_Midcast['Hydro Breath'] = sets.Pet_Midcast.Breath
	sets.Pet_Midcast['Lightning Breath'] = sets.Pet_Midcast.Breath
	 
	-- Used to Tag TH on a mob (TH4 is max in gear non-THF)
	sets.TreasureHunter = {
		waist=gear.chaac,
	}

	--WS Sets
	sets.WS = {
		ammo=gear.knobkierrie,
		head=gear.peltastHeadPlusThree,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.dragoonCollar,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.peltastEarringPlusOne,
		left_ring=gear.sroda,
		right_ring=gear.niqmaddu,
		back = gear.drgWSDDt,
	}

	sets.WS.ACC = set_combine(sets.WS, {})

	sets.WS.PDL = set_combine(sets.WS, {
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
	})

	sets.WS.WSD = set_combine(sets.WS, {
		right_ear=gear.thrud,
		hands = gear.pteroslaverHandsPlusThree,
	})

	sets.WS.CRIT = {
		ammo = gear.coiste,
		head = gear.gletiHead,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
		neck = gear.dragoonCollar,
		waist=gear.fotiaWaist,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.peltastEarringPlusOne,
		left_ring=gear.lehkoHabhokaRing,
		right_ring=gear.niqmaddu,
		back = gear.drgWSDDt,
	}

	-- Impulse Drive
	sets.WS['Impulse Drive'] = set_combine(sets.WS.CRIT, {
		ammo=gear.knobkierrie,
		head=gear.peltastHeadPlusThree,
		right_ear=gear.thrud,
		left_ring=gear.sroda,
		hands = gear.pteroslaverHandsPlusThree,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		waist = gear.sailfi,
	})
	sets.WS['Impulse Drive']['PDL'] = set_combine(sets.WS.CRIT, {
		ammo=gear.knobkierrie,
		head=gear.peltastHeadPlusThree,
		left_ring=gear.sroda,
		feet = gear.nyameFeet,
		waist = gear.sailfi,
	})

	-- Savage Blade
	sets.WS['Savage Blade'] = set_combine(sets.WS.WSD, {})
	sets.WS['Savage Blade']['PDL'] = set_combine(sets.WS.WSD, {
		right_ear=gear.peltastEarringPlusOne,
		body=gear.peltastBodyPlusThree,
		right_ring=gear.epimanondas,
	})

	-- Geirskogul
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

	-- Drakesbane
	sets.WS['Drakesbane'] = set_combine(sets.WS, {
		ammo = gear.coiste,
		head = gear.gletiHead,
		body=gear.hjarrandiBody,
		hands = gear.gletiHands,
		legs=gear.peltastLegsPlusThree,
		feet = gear.gletiFeet,
		neck = gear.dragoonCollar,
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

	-- Camlann's Torment
	sets.WS["Camlann's Torment"] = set_combine(sets.WS, {
		waist=gear.fotiaWaist,
	})
	sets.WS["Camlann's Torment"]['PDL'] = set_combine(sets.WS, {
		left_ear=gear.thrud,
		body = gear.gletiBody,
		legs = gear.gletiLegs,
	})

	-- Stardiver
	sets.WS['Stardiver'] = set_combine(sets.WS, {
		left_ring=gear.lehkoHabhokaRing,
		neck=gear.fotiaNeck,
		hands=gear.peltastHandsPlusThree,
		right_ear=gear.sherida,
		waist=gear.fotiaWaist,
	})
	sets.WS['Stardiver']['PDL'] = set_combine(sets.WS.CRIT, {
		neck = gear.dragoonCollar,
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
--Function is called when a self command is issued
function self_command_custom(command)

end
--Function is called when a lua is unloaded
function user_file_unload()

end

--Function used to automate Job Ability use
function check_buff_JA()
	local buff = 'None'
	local ja_recasts = windower.ffxi.get_ability_recasts()

	if player.sub_job == 'SAM' and player.sub_job_level == 49 then
		if not buffactive['Hasso'] and not buffactive['Seigan'] and ja_recasts[138] == 0 then
			buff = "Hasso"
		elseif not buffactive['Meditate'] and ja_recasts[134] == 0 then
			buff = "Meditate"
		end
	end

	if player.sub_job == 'WAR' and player.sub_job_level == 49 then
		if not buffactive['Berserk'] and ja_recasts[1] == 0 then
			buff = "Berserk"
		elseif not buffactive['Aggressor'] and ja_recasts[4] == 0 then
			buff = "Aggressor"
		elseif not buffactive['Warcry'] and ja_recasts[2] == 0 then
			buff = "Warcry"
		end
	end

	return buff
end

function check_buff_SP()
	local buff = 'None'
	--local sp_recasts = windower.ffxi.get_spell_recasts()
	return buff
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
