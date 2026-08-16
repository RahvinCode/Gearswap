
--Turin

-- Load and initialize the include file.
include('GearSets-Include')
include('Mirdain-Include')

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "10"
MacroBook = "1"
MacroSet = "1"

-- Use "gs c food" to use the specified food item 
Food = "Sublime Sushi"

--Uses Items Automatically
AutoItem = false

--Upon Job change will use a random lockstyleset
Random_Lockstyle = false

--Lockstyle sets to randomly equip
Lockstyle_List = {1,2,6,12}

--Set default mode (TP,ACC,DT)
state.OffenseMode:options('TP','ACC','DT','PDL','SB','MEVA') -- ACC effects WS and TP modes
state.OffenseMode:set('DT')

--Modes for specific to Ninja
state.WeaponMode:options('Kannagi','Savage Blade','Karambit','Aeolian Edge','Abyssea','Ninjitsu')
state.WeaponMode:set('Kannagi')

elemental_ws = S{'Aeolian Edge', 'Blade: Teki', 'Blade: To','Blade: Chi','Blade: Ei','Blade: Yu'}

jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()
	--Set the weapon options.  This is set below in job customization section

	-- Weapon setup
	sets.Weapons = {}

	sets.Weapons['Kannagi'] = {
		main = gear.kannagi,
		sub=gear.gokotai,
	}

	sets.Weapons['Ninjitsu'] = {
		main=gear.tauret,
		sub=gear.gokotai,
	}

	sets.Weapons['Savage Blade'] = {
		main=gear.naegling,
		sub=gear.blurredKnife,
	}

	sets.Weapons['Karambit'] = {
		main=gear.karambit,
		sub="empty",
	}

	sets.Weapons['Aeolian Edge'] = {
		main=gear.tauret,
		sub=gear.naegling,
	}

	sets.Weapons['Abyssea'] = {
		main="",
		sub="",
	}

	sets.Weapons.Shield = {}
	sets.Weapons.Sleep = {}

	-- Standard Idle set with -DT, Refresh, Regen and movement gear
	sets.Idle = {
		ammo=gear.staunchPlusOne,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.loricatePlusOne,
		waist=gear.carriers,
		left_ear=gear.etiolation,
		right_ear = gear.odnowaPlusOne,
		left_ring=gear.eihwazRing,
		right_ring = gear.gelatinousPlusOne,
		back = gear.ninDA,
    }

	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
	})

	--Defined below based off time of day
	sets.Movement = {}

	sets.Movement.Day = {
		feet=gear.danzoSuneAte,
	}
	sets.Movement.Night = {
		feet=gear.hachiyaFeetPlusOne,
	}
	sets.Movement.Dusk = {
		feet=gear.hachiyaFeetPlusOne,
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
		ammo=gear.happoShurikenPlusOne,
		head = gear.adhemarHeadPlusOnePathA,
		body=gear.kendatsubaSamuePlusOne,
		hands = gear.adhemarHandsPlusOnePathA,
		legs = gear.samnuhaTightsDA,
		feet=gear.kendatsubaFeetPlusOne,
		neck = gear.ninjaNodowaPlusTwo,
		waist = gear.sailfi,
		left_ear=gear.telos,
		right_ear=gear.hattoriEarringPlusOne,
		left_ring=gear.gereRing,
		right_ring=gear.eponas,
		back = gear.ninDA,
	}
	--This set is used when OffenseMode is DT and Enaged (Augments the TP base set)
	sets.OffenseMode.DT = set_combine (sets.OffenseMode.TP, {
	    head=gear.malignanceHead,
		body=gear.malignanceBody,
		hands=gear.malignanceHands,
		legs=gear.malignanceLegs,
		feet=gear.malignanceFeet,
	})
	--This set is used when OffenseMode is ACC and Enaged (Augments the TP base set)
	sets.OffenseMode.ACC = set_combine (sets.OffenseMode.TP, {
	    head=gear.kendatsubaJinpachiPlusOne,
		body=gear.kendatsubaSamuePlusOne,
		hands=gear.kendatsubaTekkoPlusOne,
		legs=gear.kendatsubaHakamaPlusOne,
		feet=gear.kendatsubaFeetPlusOne,
	})
	sets.OffenseMode.PDL = set_combine (sets.OffenseMode.TP, {
	    head=gear.malignanceHead,
		body=gear.malignanceBody,
		hands=gear.malignanceHands,
		legs=gear.malignanceLegs,
		feet=gear.malignanceFeet,
	})

	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode.DT,{
		neck = gear.warderCharmPlusOne,
	})

	sets.OffenseMode.SB = set_combine(sets.OffenseMode.DT,{ })

	sets.DualWield = {}

	sets.Precast = {}
	-- Used for Magic Spells
	sets.Precast.FastCast = {
		ammo=gear.sapience, -- 2
		head = gear.herculeanHelmFC, --13
		body = gear.taeonTabardBFC, -- 9
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.herculeanTrousersFC, -- 6
		feet = gear.herculeanBootsFC, -- 6
		neck=gear.voltsurge, -- 4
		waist=gear.platinumMoogleBelt,
		left_ear=gear.etiolation, -- 1
		right_ear=gear.loquacious, -- 2
		left_ring=gear.kishar, -- 4
		right_ring=gear.rahabRing, -- 2
		back = gear.ninFC, -- 10
	} -- 67

	sets.Precast.Utsusemi = {
		neck=gear.magoragaBeadNecklace, -- 10 FC (+6)
	}

	sets.Precast.QuickMagic = {

	}

	sets.Enmity = { -- Head and Back upgrade slots
		ammo=gear.sapience, --2
		body=gear.emetHarnessPlusOne, --10
		hands=gear.kurysGloves, --9
		--="Zoar Subligar +1", --6
		feet=gear.ahosiLeggings, --7
		neck=gear.moonlightNeck, --15
		waist=gear.kasiriBelt, --3
		left_ear=gear.crypticEarring, --4
		right_ear=gear.friomisi, --2
		left_ring=gear.petrov, --4
		right_ring=gear.eihwazRing, --5
	}

	--Base set for midcast - if not defined will notify and use your idle set for surviability
	sets.Midcast = set_combine(sets.Idle, {
	
	})
	-- Utsusemi Set
	sets.Midcast.Utsusemi = {
		back = gear.ninFC,
		feet=gear.hattoriFeetPlusOne,
	}
	--This set is used as base as is overwrote by specific gear changes (Spell Interruption Rate Down)
	sets.Midcast.SIRD = {}
	-- Cure Set
	sets.Midcast.Cure = {}
	-- Enhancing Skill
	sets.Midcast.Enhancing = {
		hands = gear.mochizukiTekkoPlusThree,
	}
	-- High MACC for landing spells
	sets.Midcast.Enfeebling = {
		ammo=gear.hydrocera,
		head=gear.hachiyaHeadPlusThree,
		body=gear.malignanceBody,
		hands = gear.mochizukiTekkoPlusThree,
		legs=gear.malignanceLegs,
		feet=gear.malignanceFeet,
		neck=gear.moonlightNeck,
		waist=gear.eschan,
		left_ear=gear.hermetic,
		right_ear=gear.crepuscularEar,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
		back = gear.ninFC,
	}
	-- High MAB for spells
	sets.Midcast.Nuke = {
    ammo = gear.ghastlyTathlumPlusOne,
    head = gear.mochizukiHeadPlusThree,
    body = gear.nyameBody,
    hands = gear.nyameHands,
    legs = gear.nyameLegs,
    feet = gear.mpacaFeet,
    neck=gear.sanctity,
    waist=gear.orpheusWaist,
    left_ear=gear.hermetic,
    right_ear=gear.friomisi,
	left_ring = gear.stikiniRingPlusOne1,
	right_ring = gear.stikiniRingPlusOne2,
    back = gear.ninFC,
	}

	-- Specific gear for spells
	sets.Midcast["Stoneskin"] = {waist=gear.siegel,}

	sets.JA = {}
	sets.JA["Futae"] = {} --hands="Hattori Tekko"
	sets.JA["Berserk"] = {}
	sets.JA["Warcry"] = {}
	sets.JA["Defender"] = {}
	sets.JA["Aggressor"] = {}
	sets.JA["Provoke"] = sets.Enmity
	sets.JA["Mijin Gakure"] = {}
	sets.JA["Yonin"] = {head = gear.mochizukiHeadPlusThree}
	sets.JA["Innin"] = {head = gear.mochizukiHeadPlusThree}
	sets.JA["Issekigan"] = {}
	sets.JA["Mikage"] = {}

	--Default WS set base
	sets.WS = {
		ammo=gear.yetshilaPlusOne,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.ninjaNodowaPlusTwo,
		waist = gear.sailfi,
		left_ear=gear.odr,
		right_ear=gear.ishvara,
		left_ring=gear.gereRing,
		right_ring=gear.eponas,
		back = gear.ninWSD,
	}

	sets.WS.WSD = set_combine({ sets.WS,
		left_ring=gear.epimanondas,
		right_ring=gear.karieyhRingPlusOne,
	})

	--This set is used when OffenseMode is ACC and a WS is used (Augments the WS base set)
	sets.WS.ACC = set_combine({ sets.WS,	    
		head=gear.kendatsubaJinpachiPlusOne,
		body=gear.kendatsubaSamuePlusOne,
		hands=gear.kendatsubaTekkoPlusOne,
		legs=gear.kendatsubaHakamaPlusOne,
		feet=gear.kendatsubaFeetPlusOne,
	})

	sets.WS.CRIT = {
		ammo=gear.yetshilaPlusOne,
		head = gear.adhemarHeadPlusOnePathA,
		body=gear.kendatsubaSamuePlusOne,
		hands = gear.adhemarHandsPlusOnePathA,
		legs = gear.samnuhaTightsDA,
		feet = gear.herculeanBootsCrit,
		neck = gear.ninjaNodowaPlusTwo,
		waist=gear.windbuffetPlusOne,
		left_ear=gear.ishvara,
		right_ear=gear.odr,
		left_ring=gear.gereRing,
		right_ring=gear.eponas,
		back = gear.ninDA,
	}
	sets.WS.MAB = set_combine({ sets.WS,
		ammo = gear.seethingBombletPlusOne,
		neck=gear.sanctity,
		waist=gear.eschan,
		left_ear=gear.friomisi,
		right_ear = gear.moonshadeEarringAcc,
		left_ring=gear.epimanondas,
		right_ring=gear.dingir,
		back = gear.ninFC,
	})

	--WS Sets
	sets.WS["Blade: Rin"] = sets.WS.CRIT
	sets.WS["Blade: Retsu"] = {}
	sets.WS["Blade: Teki"] = sets.WS.MAB
	sets.WS["Blade: To"] = sets.WS.MAB
	sets.WS["Blade: Chi"] = sets.WS.MAB
	sets.WS["Blade: Ei"] = set_combine(sets.WS.MAB, {head=gear.pixieHead, left_ring=gear.archonRing})
	sets.WS["Blade: Jin"] = sets.WS.CRIT
	sets.WS["Blade: Ten"] = {}
	sets.WS["Blade: Ku"] = {}
	sets.WS["Blade: Kamu"] = {}
	sets.WS["Blade: Yu"] = sets.WS.MAB
	sets.WS["Blade: Hi"] = sets.WS.CRIT
	sets.WS["Blade: Shun"] = {}

	sets.WS["Asuran Fists"] = {
	    ammo=gear.yetshilaPlusOne,
		head=gear.kendatsubaJinpachiPlusOne,
		body=gear.kendatsubaSamuePlusOne,
		hands=gear.kendatsubaTekkoPlusOne,
		legs=gear.kendatsubaHakamaPlusOne,
		feet=gear.kendatsubaFeetPlusOne,
		neck=gear.fotiaNeck,
		waist=gear.fotiaWaist,
		left_ear=gear.ishvara,
		right_ear=gear.odr,
		left_ring=gear.hetairoi,
		right_ring=gear.gereRing,
		back = gear.ninWSD,
	}

	sets.WS["Savage Blade"] = {
	    ammo=gear.oshashaTreatise,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.ninjaNodowaPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.ishvara,
		left_ring=gear.corneliaRing,
		right_ring=gear.epimanondas,
		back = gear.ninWSD,
	}

	sets.TreasureHunter = {
	    head=gear.volteHead,
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
--Function is called by the gearswap command
function self_command_custom(command)

end

-- This function is called when the job file is unloaded
function user_file_unload()

end

function check_buff_JA()
	local buff = 'None'
	local ja_recasts = windower.ffxi.get_ability_recasts()
	if player.sub_job == 'WAR' then
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

Cycle_Time = 1
function Cycle_Timer()
	if world.time >= 17*60 or world.time <= 7*60 then
		if world.time >= (18*60) or world.time <= (6*60) then
			sets.Movement = set_combine(sets.Movement, sets.Movement.Night)
			log('Night Feet')
		else
			sets.Movement = set_combine(sets.Movement, sets.Movement.Dusk)
			log('Dusk Feet')
		end
	else
		sets.Movement = set_combine(sets.Movement, sets.Movement.Day)
		log('Day Feet')
	end
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
