
--Turin

-- Load and initialize the include file.
include('GearSets-Include')
include('Mirdain-Include')

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "5"
MacroBook = "6"
MacroSet = "1"

-- Use "gs c food" to use the specified food item 
Food = "Sublime Sushi"

--Uses Items Automatically
AutoItem = false

--Upon Job change will use a random lockstyleset
Random_Lockstyle = false

--Lockstyle sets to randomly equip
Lockstyle_List = {1,2,6,12}

--Set default mode (TP,ACC,DT,PDL)
state.OffenseMode:set('DT')

--Weapons options
state.WeaponMode:options('Aeneas','Naegling','Evisceration')
state.WeaponMode:set('Aeneas')

-- Initialize Player
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- Weapon setup
	sets.Weapons = {}

	sets.Weapons['Aeneas'] = {
		main = gear.aeneas,
		sub = gear.gleti,
	}

	sets.Weapons['Naegling'] = {
		main=gear.naegling,
		sub=gear.crepuscularKnife,
	}

	sets.Weapons['Evisceration'] = {
		main=gear.tauret,
		sub = gear.aeneas,
	}

	sets.Weapons.Shield = {}
	sets.Weapons.Sleep = {
		sub=gear.mpuGandring,
	}

	-- Standard Idle set with -DT, Refresh, Regen and movement gear
	sets.Idle = {
		ammo=gear.staunchPlusOne,
		head=gear.nullMasque,
		body=gear.adamantiteArmor,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
		neck = gear.warderCharmPlusOne,
		waist=gear.nullWaist,
		left_ear = gear.odnowaPlusOne,
		right_ear=gear.sanareEarring,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back=gear.nullShawl,
    }
	sets.Idle.Resting = set_combine(sets.Idle, {})
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
	})

	sets.Movement = {
		feet=gear.fajinBoots,
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

	sets.OffenseMode = {}

	--Base TP set to build off
	sets.OffenseMode.TP = {
		ammo = gear.coiste,
		head = gear.adhemarHeadPlusOnePathA,
		body = gear.adhemarBodyPlusOnePathA,
		hands = gear.adhemarHandsPlusOnePathA,
		legs = gear.samnuhaTightsDA,
		feet = gear.gletiFeet,
		neck = gear.assassinGorgetPlusTwo,
		waist=gear.windbuffetPlusOne,
		right_ear=gear.skulkerEarringPlusOne,
		left_ear=gear.sherida,
		left_ring=gear.gereRing,
		right_ring=gear.lehkoHabhokaRing,
		back=gear.nullShawl,
	}

	--This set is used when OffenseMode is DT and Enaged (Augments the TP base set)
	sets.OffenseMode.DT = set_combine(sets.OffenseMode.TP, {
		head=gear.malignanceHead,
		body=gear.adamantiteArmor,
		hands=gear.malignanceHands,
		legs = gear.gletiLegs,
		feet=gear.malignanceFeet,
		left_ear = gear.odnowaPlusOne,
		left_ring = gear.moonlightRing,
		waist = gear.platinumMoogleBelt,
	})

	--This set is used when OffenseMode is ACC and Enaged (Augments the TP base set)
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode.TP, {})

	--Dual Wield need only 6 if not getting haste samba
	sets.DualWield = { 
	    --left_ear="Eabani Earring",
	    --waist="Reiki Yotai",
	}

	sets.Precast = {}

	-- Used for Magic Spells
	sets.Precast.FastCast = {
		ammo=gear.sapience, -- 2
		head = gear.herculeanHelmFC, -- 13
		body = gear.taeonTabardBFC, -- 8
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.herculeanTrousersFC, -- 6
		feet = gear.herculeanBootsFC, -- 6
		neck=gear.voltsurge, --4
		waist = gear.platinumMoogleBelt,
		left_ear=gear.etiolation, -- 1
		right_ear = gear.tuisto,
		left_ring=gear.prolix, -- 3
		right_ring = gear.gelatinousPlusOne,
	} -- 51 -- Need cape for another 10%

	sets.Enmity = {
	    ammo=gear.sapience, -- 2
	    left_ear=gear.crypticEarring, -- 4
		right_ear=gear.friomisi, --2
		left_ring=gear.petrov, -- 4
	}

	-- Used for Raises and Cure spells
	sets.Precast.QuickMagic = set_combine( sets.Precast.FastCast, {

	});

	--Base set for midcast - if not defined will notify and use your idle set for surviability
	sets.Midcast = set_combine(sets.Idle, {
	
	})
	--This set is used as base as is overwrote by specific gear changes (Spell Interruption Rate Down)
	sets.Midcast.SIRD = {}
	-- Cure Set
	sets.Midcast.Cure = {}
	-- Enhancing Skill
	sets.Midcast.Enhancing = {}
	-- High MACC for landing spells
	sets.Midcast.Enfeebling = {}
	-- Specific gear for spells
	sets.Midcast["Stoneskin"] = {
		waist=gear.siegel,
	}
	sets.JA = {}
	sets.JA["Perfect Dodge"] = {hands = gear.plundererHandsPlusThree,}
	sets.JA["Steal"] = {}
	sets.JA["Flee"] = {}
	sets.JA["Hide"] = {}
	sets.JA["Sneak Attack"] = {}
	sets.JA["Mug"] = {}
	sets.JA["Trick Attack"] = {}
	sets.JA["Accomplice"] = {}
	sets.JA["Feint"] = {}
	sets.JA["Despoil"] = {}
	sets.JA["Collaborator"] = {}
	sets.JA["Conspirator"] = {}
	sets.JA["Bully"] = {}
	sets.JA["Larceny"] = {}

	-- Dancer JA Section

	sets.Flourish = set_combine(sets.Idle.DT, {})

	sets.Jig = set_combine(sets.Idle.DT, {})

	sets.Step = set_combine(sets.OffenseMode.DT, {})

	sets.Samba = set_combine(sets.Idle.DT, {})

	-------------------------------------------------------------------------------
	-- Waltz Potency gear caps at 50%, while Waltz received potency caps at 30%. -- 
	-------------------------------------------------------------------------------
	sets.Waltz = set_combine(sets.OffenseMode.DT, {
		ammo=gear.yamarang, -- 5%
		head=gear.malignanceHead,
		body = gear.gletiBody, -- 10%
		hands=gear.slitherGlovesPlusOne, -- 5%
		legs=gear.dashingSubligar, -- 10%
		feet=gear.malignanceFeet,
		neck = gear.loricatePlusOne,
		waist=gear.platinumMoogleBelt,
		left_ear=gear.tuisto,
		right_ear = gear.odnowaPlusOne,
		right_ring=gear.defending,
		left_ring=gear.moonlightRing,
		back = gear.thfDA,
	}) -- 30% Potency

	--Default WS set base
	sets.WS = {
		ammo=gear.yetshilaPlusOne,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck=gear.fotiaNeck,
		waist=gear.fotiaWaist,
		left_ear=gear.sherida,
		right_ear = gear.moonshadeEarringAcc,
		left_ring=gear.gereRing,
		right_ring=gear.regalRing,
		back = gear.thfWSD,
	}
	--This set is used when OffenseMode is ACC and a WS is used (Augments the WS base set)
	sets.WS.ACC = {}

	sets.WS.MAB = set_combine( sets.WS, {
		ammo = gear.ghastlyTathlumPlusOne,
		neck=gear.sanctity,
		waist=gear.orpheusWaist,
		left_ear=gear.friomisi,
		right_ear = gear.moonshadeEarringAcc,
		left_ring=gear.karieyhRingPlusOne,
		right_ring=gear.epimanondas,
		back = gear.thfWSD,
	})
	--WS Sets
	sets.WS["Wasp Sting"] = {}
	sets.WS["Viper Bite"] = {}
	sets.WS["Shadowstich"] = {}
	sets.WS["Gust Slash"] = {}
	sets.WS["Cyclone"] = {}
	sets.WS["Energy Steal"] = {}
	sets.WS["Energy Drain"] = {}
	sets.WS["Dancing Edge"] = {}
	sets.WS["Shark Bite"] = {}
	sets.WS["Evisceration"] = {}
	sets.WS["Aeolian Edge"] = set_combine( sets.WS.MAB, {
		feet=gear.skulkerFeetPlusThree,
	})

	--Custome sets for each jobsetup
	sets.Custom = {}

	sets.TreasureHunter = {
		feet=gear.skulkerFeetPlusThree,
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

function check_buff_JA()
	local buff = 'None'
	--local ja_recasts = windower.ffxi.get_ability_recasts()
	return buff
end

function check_buff_SP()
	local buff = 'None'
	--local sp_recasts = windower.ffxi.get_spell_recasts()
	return buff
end

-- This function is called when the job file is unloaded
function user_file_unload()

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
