
--Hurin

-- Load and initialize the include file.
include('GearSets-Include')
include('Mirdain-Include')

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "15"
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
Organizer = true

-- 'TP','ACC','DT' are standard Default modes.  You may add more and assign equipsets for them
state.OffenseMode:options('DT','TP','PDL','ACC','SB') -- ACC effects WS and TP modes
state.OffenseMode:set('DT')

--Weapon Modes
state.WeaponMode:options('Scythe','Great Sword','Sword','Club','Axe')
state.WeaponMode:set('Scythe')

-- Initialize Player
jobsetup(LockStylePallet,MacroBook,MacroSet)

function get_sets()

	sets.Weapons = {}

	sets.Weapons['Scythe'] = {
		main=gear.anguta,
		sub=gear.utu,
	}

	sets.Weapons['Great Sword'] = {
		--main={ name="Trishula", augments={'Path: A',}},
		sub=gear.utu,
	}

	sets.Weapons['Sword'] = {
		main=gear.naegling,
		sub = gear.ternionDaggerPlusOne,
	}

	sets.Weapons['Club'] = {
		main = gear.loxoticPlusOne,
		sub=gear.blurredShield,
	}

	sets.Weapons['Axe'] = {
		main=gear.dolichenus,
		sub = gear.ternionDaggerPlusOne,
	}

	sets.Weapons.Shield = 
	{
		sub=gear.blurredShield,
	}

	sets.Idle = {
		ammo=gear.staunchPlusOne,
		head=gear.sakpataHead,
		body=gear.sakpataBody,
		hands=gear.sakpataHands,
		legs=gear.sakpataLegs,
		feet=gear.sakpataFeet,
		neck = gear.loricatePlusOne,
		waist=gear.carriers,
		left_ear = gear.odnowaPlusOne,
		right_ear=gear.etiolation,
		left_ring = gear.gelatinousPlusOne,
		right_ring=gear.moonlightRing,
		back = gear.drkDA,
	}

	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
	})
	
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

	-- This caps with Auspice from WHM
	sets.Subtle_Blow = {
		body=gear.dagonBreastplate,
		feet=gear.sakpataFeet,
		hands=gear.sakpataHands,
		right_ring=gear.niqmaddu,
	}

	-- Max HP for Dread Spikes
	sets.Max_HP = {
		ammo=gear.staunchPlusOne,
		head=gear.ratriSalletPlusOne,
		body=gear.ratriBreastplatePlusOne,
		hands=gear.ratriGadlingsPlusOne,
		legs=gear.ratriCuissesPlusOne,
		feet=gear.ratriSolleretsPlusOne,
		neck = gear.unmovingPlusOne,
		waist=gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		right_ear=gear.tuisto,
		left_ring = gear.gelatinousPlusOne,
		right_ring=gear.moonlightRing,
		back = gear.drkFC,
	}

	sets.OffenseMode = {
		ammo=gear.coiste,
		head=gear.flammaHeadPlusTwo,
		body=gear.sakpataBody,
		hands=gear.sakpataHands,
		legs=gear.sakpataLegs,
		feet=gear.flammaFeetPlusTwo,
		neck = gear.vimPlusOne,
		waist = gear.sailfi,
		left_ear=gear.telos,
		right_ear = gear.schere,
		left_ring=gear.moonlightRing,
		right_ring=gear.niqmaddu,
		back=gear.nullShawl,
	}

	--Base TP set to build off
	sets.OffenseMode.TP = set_combine(sets.OffenseMode, {

	})

	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {
		head=gear.hjarrandiHead,
		body=gear.hjarrandiBody,
		feet = gear.sakpataFeet,
		neck=gear.nullLoop,
		left_ring=gear.lehkoHabhokaRing,
	})
	
	--Same TP set but WSD can be altered also
	sets.OffenseMode.PDL = set_combine(sets.OffenseMode, {

	})

	sets.OffenseMode.ACC = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.PDT = set_combine(sets.OffenseMode, { })
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, { })
	sets.OffenseMode.SB =  set_combine(sets.OffenseMode, {
		head=gear.hjarrandiHead,
		body=gear.hjarrandiBody,
		feet = gear.sakpataFeet,
		neck=gear.nullLoop,
		right_ear=gear.tuisto,
		left_ring=gear.lehkoHabhokaRing,
	})

	sets.DualWield = {}

	sets.Precast = {}

	-- Used for Magic Spells (Fast Cast)
	sets.Precast.FastCast = {
		ammo=gear.sapience, -- 2
		head = gear.carmineHeadPlusOnePathD, -- 14
		body=gear.sacroBody, -- 10
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.odysseanCuissesFC, -- 6
		feet = gear.odysseanGreavesBFC, -- 13
		neck=gear.voltsurge, -- 4
		waist=gear.platinumMoogleBelt,
		left_ear=gear.malignanceEar, -- 4
		right_ear=gear.etiolation, -- 1
		left_ring=gear.weatherspoon, -- 5
		right_ring=gear.kishar, -- 4
		back = gear.drkFC, -- 10
	}
		
	sets.Enmity = {}

	--Base set for midcast - if not defined will notify and use your idle set for surviability
	sets.Midcast = set_combine(sets.Idle, {})
	sets.Midcast.SIRD = set_combine(sets.Midcast, {})
	sets.Midcast.Enhancing = set_combine(sets.Midcast, {})

	sets.Midcast.Enfeebling = set_combine(sets.Midcast, {})
	sets.Midcast.Enfeebling.MACC = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Enfeebling.Potency = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Enfeebling.Duration = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Enfeebling.Drain = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Enfeebling.Aspir = set_combine(sets.Midcast.Enfeebling, {})

	sets.Midcast.Dark = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Dark.MACC = set_combine(sets.Midcast.Enfeebling.MACC, {})
	sets.Midcast.Dark.Absorb = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Dark.Enhancing = set_combine(sets.Midcast.Enhancing, {})
	
	--Job Abilities
	sets.JA = {}
	sets.JA["Provoke"] = sets.Precast.Enmity
	sets.JA["Blood Weapon"] = {}
	sets.JA["Souleater"] = {}
	sets.JA["Arcane Circle"] = {}
	sets.JA["Weapon Bash"] = {}
	sets.JA["Nether Void"] = {}
	sets.JA["Arcane Crest"] = {}
	sets.JA["Scarlet Delirium"] = {}
	sets.JA["Soul Enslavement"] = {}
	sets.JA["Consume Mana"] = {}


	--WS Sets
	sets.WS = {
		ammo=gear.knobkierrie,
		head = gear.nyameHead, -- Need Heathen
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck=gear.fotiaNeck,
		waist=gear.fotiaWaist,
		left_ear = gear.moonshadeEarringAcc,
		right_ear = gear.schere,
		left_ring=gear.epimanondas,
		right_ring=gear.niqmaddu,
		back = gear.drkWSD,
	}

	--This set is used when OffenseMode is ACC and a WS is used (Augments the WS base set)
	sets.WS.ACC = set_combine(sets.WS, {})

	sets.WS.PDL = set_combine(sets.WS, {})

	sets.WS.WSD = set_combine(sets.WS, {})

	sets.WS.CRIT = set_combine(sets.WS, {})

	sets.WS.Multi_Hit = set_combine(sets.WS, {})

	sets.WS.SB = sets.Subtle_Blow

	sets.WS['Catastrophe'] = set_combine(sets.WS, { 
		left_ear=gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
	})

	sets.WS['Origin'] = set_combine(sets.WS, { 
		right_ear=gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
	})

	sets.WS['Entropy'] = set_combine(sets.WS, { 
		ammo = gear.coiste,
		left_ring = gear.metamorphPlusOne,
	})

	sets.WS['Quietus'] = set_combine(sets.WS, { 
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
	})

	sets.WS['Cross Reaper'] = set_combine(sets.WS, { 
		right_ear=gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
		left_ring=gear.regalRing,
	})

	sets.WS['Insurgency'] = set_combine(sets.WS, { 
		right_ear=gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
		left_ring=gear.regalRing,
	})

	sets.WS['Torcleaver'] = set_combine(sets.WS, { 
		right_ear=gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
	})

	sets.WS['Fimbulvetr'] = set_combine(sets.WS, { 
		right_ear=gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
		left_ring=gear.regalRing,
	})

	sets.WS['Scourge'] = set_combine(sets.WS, { 
		left_ear=gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
		left_ring=gear.regalRing,
	})

	sets.WS['Resolution'] = set_combine(sets.WS, { 
		neck = gear.abyssalBeadNecklacePlusTwo,
		left_ring=gear.sroda,
	})

	sets.WS['Judgment'] = set_combine(sets.WS, { 
		right_ear=gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
	})


-- Used to Tag TH on a mob (TH4 is max in gear non-THF)
	sets.TreasureHunter = {
		ammo=gear.perfectEgg,
		legs=gear.volteHose,
	    feet=gear.volteBoots,
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
	if spell.name == "Dread Spikes" then
		equipSet = set_combine( sets.Max_HP, { main=gear.crepuscularScythe })
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
