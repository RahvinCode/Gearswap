
-- Turin

-- Load and initialize the include file.
include('GearSets-Include')
include('Mirdain-Include')

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "4"
MacroBook = "10"
MacroSet = "1"

--Upon Job change will use a random lockstyleset
Random_Lockstyle = false

--Lockstyle sets to randomly equip
Lockstyle_List = {1,2,6,12}

-- Use "gs c food" to use the specified food item 
Food = "Sublime Sushi"

--Uses Items Automatically
AutoItem = false

-- 'TP','ACC','DT' are standard Default modes.  You may add more and assigne equipsets for them ( Idle.X and OffenseMode.X )
state.OffenseMode:options('TP','ACC','DT','SB','PDL') -- ACC effects WS and TP modes

--Set default mode (TP,ACC,DT,PDL) etc
state.OffenseMode:set('DT')

--Weapons specific to Samurai
state.WeaponMode:options('Masamune', 'Dojikiri', 'Shining One', 'Yoichinoyumi', 'Soboro')
state.WeaponMode:set('Masamune')

jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- Weapon setup

	sets.Weapons['Dojikiri'] = {
		main = gear.dojikiriYasutsuna,
		sub=gear.utu,
	}

	sets.Weapons['Masamune'] = {
		main = gear.masamune,
		sub=gear.utu,
	}
	
	sets.Weapons['Yoichinoyumi'] = {
		main = gear.dojikiriYasutsuna,
		sub=gear.utu,
		range=gear.yoichinoyumi,
		ammo=gear.yoichiArrow,
	}

	sets.Weapons['Soboro'] = {
		main=gear.soboroSukehiro,
		sub=gear.utu,
	}

	sets.Weapons['Shining One'] = {
		main=gear.shiningOne,
		sub=gear.utu,
	}

	sets.Weapons.Shield = {}

	--Default arrow to use
	Ammo.RA = "Yoichi's Arrow"

	-- Standard Idle set with -DT, Refresh and Regen gear
	sets.Idle = {
		ammo=gear.staunchPlusOne,
		head = gear.nyameHead,
		body=gear.adamantiteArmor,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.warderCharmPlusOne,
		waist=gear.platinumMoogleBelt,
		left_ear=gear.sanareEarring,
		right_ear = gear.odnowaPlusOne,
		left_ring=gear.lehkoHabhokaRing,
		right_ring=gear.shadowRing,
		back=gear.nullShawl,
    }

	-- 'TP','PDL','ACC','DT','PDT','MEVA'
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.PDT = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
	})

	sets.Movement = {
		left_ring = gear.gelatinousPlusOne,
		feet=gear.danzoSuneAte
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

	-- 10 + 19 for Auspice
	sets.Subtle_Blow = {
		body=gear.dagonBreastplate, -- SB II 10
		legs = gear.mpacaLegs, -- SB II 5
		left_ring=gear.niqmaddu, -- SB II 5
		head=gear.kendatsubaJinpachiPlusOne,  -- 8
		hands=gear.kendatsubaTekkoPlusOne, -- 8
		feet=gear.kendatsubaFeetPlusOne, -- 8
		right_ear = gear.schere, -- 3
		left_ring=gear.chirichRingPlusOne, -- 10
		waist=gear.sarissaphoroi, -- 5
		--neck="Bathy Choker +1", -- 11 Not needed if using Pukatrice Eggs
	}

	sets.OffenseMode = {
		ammo = gear.coiste,
		head=gear.kasugaHeadPlusTwo,
		body=gear.kasugaBodyPlusThree,
		hands = gear.mpacaHands,
		legs=gear.kasugaLegsPlusTwo,
		feet = gear.mpacaFeet,
		neck = gear.samuraiNodowaPlusTwo,
		waist=gear.ioskehaBeltPlusOne,
		left_ear = gear.schere,
		right_ear = gear.kasugaEarringPlusOneWSD,
		left_ring=gear.niqmaddu,
		right_ring=gear.chirichRingPlusOne,
		back=gear.nullShawl,
	}

	--Base TP set to build off
	sets.OffenseMode.TP = set_combine(sets.OffenseMode, {

	})

	--This set is used when OffenseMode is DT and Enaged (Augments the TP base set)
	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {
		head=gear.kasugaHeadPlusTwo,
		hands=gear.mpacaHands,
	})

	--This set is used when OffenseMode is ACC and Enaged (Augments the TP base set)
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {

	})

	--This set is used when OffenseMode is ACC and Enaged (Augments the TP base set)
	-- 75 total cap - Max 50 in each category
	sets.OffenseMode.SB = set_combine(sets.OffenseMode, sets.Subtle_Blow, {

	})

	sets.Precast = {}

	-- 70 snapshot is Cap
	-- Rapid shot is like quick magic
	-- Snapshot is like Fast Cast

	-- True Shot Ranges (Increases RA and WS)
		-- Distances listed below are effected by Monster Size
		-- Gun ~6.5 yalms
		-- Short Bow ~8.6 yalms
		-- Crossbow ~10.7 yalms
		-- Long Bow ~ 11.8 yalms

	-- Flurry is 15% Snapshot
	-- Flurry II 30% Snapshot

	-- Snapshot / Rapidshot
	sets.Precast.RA = set_combine(sets.Precast, { -- 5 Snapshot on Perun +1 Augment if used
		ammo=Ammo.RA,
		head = gear.acroHelmRapidShot,
		body = gear.acroSurcoatRapidShot,
		hands = gear.acroGauntletsRapidShot,
		legs = gear.acroBreechesRapidShot,
		feet = gear.acroLeggingsRapidShot,
		neck = gear.unmovingPlusOne,
		waist=gear.yemaya,
		left_ear=gear.tuisto,
		right_ear = gear.odnowaPlusOne,
		left_ring=gear.crepuscularRing,
		right_ring = gear.gelatinousPlusOne,
		back = gear.samSnapshot,
    })	

	-- Only the bullet needs to be set for ACC sets (so that it will match the sets.Midcast.RA.ACC)
    sets.Precast.RA.ACC = set_combine(sets.Precast.RA, {
		ammo=Ammo.ACC,
    })

	-- Flurry - 55 Snapshot Needed
	sets.Precast.RA.Flurry = set_combine(sets.Precast.RA, {

	}) 

	-- Flurry II - 40 Snapshot Needed
	sets.Precast.RA.Flurry_II = set_combine( sets.Precast.RA.Flurry, { 

    })

	-- Used for Magic Spells (Fast Cast)
	sets.Precast.FastCast = set_combine (sets.Idle.DT, {
		ammo=gear.sapience,
		hands = gear.leylineGlovesFCB,
		neck=gear.voltsurge,
		waist=gear.tempusFugit,
		left_ear=gear.etiolation,
		right_ear=gear.loquacious,
		left_ring=gear.prolix,
	})

	sets.Precast.Enmity = set_combine (sets.Idle.DT, {
	    ammo=gear.sapience, -- 2
		neck=gear.warderCharmPlusOne, -- 1-8 
	    left_ear=gear.crypticEarring, -- 4
		right_ear=gear.friomisi, --2
		waist=gear.kasiriBelt, -- 3
		left_ring=gear.petrov, -- 4
		right_ring=gear.eihwazRing, -- 5
	})

	--Base set for midcast - if not defined will notify and use your idle set for surviability
	sets.Midcast = set_combine (sets.Idle.DT, { })

	-- Ranged Attack Gear (Normal Midshot)
    sets.Midcast.RA = set_combine(sets.Midcast, {
		ammo=Ammo.RA,
		head = gear.sakonjiHeadPlusThree,
		body=gear.kasugaBodyPlusThree,
		hands=gear.volteMittens,
		legs=gear.wakidoLegsPlusThree,
		feet=gear.volteSpats,
		neck = gear.samuraiNodowaPlusTwo,
		waist=gear.yemaya,
		left_ear=gear.telos,
		right_ear=gear.crepuscularEar,
		right_ring=gear.ilabrat,
		left_ring=gear.crepuscularRing,
		back = gear.samSTP,
    })

	-- Ranged Attack Gear (High Accuracy Midshot)
    sets.Midcast.RA.ACC = set_combine(sets.Midcast.RA, {
		ammo=Ammo.ACC,
    })

	-- Ranged Attack Gear (Physical Damage Limit)
    sets.Midcast.RA.PDL = set_combine(sets.Midcast.RA, {

    })

	-- Ranged Attack Gear (Critical Build)
    sets.Midcast.RA.CRIT = set_combine(sets.Midcast.RA, {

    })
	
	--Job Abilities
	sets.JA = {}
	sets.JA["Meikyo Shisui"] = {}
	sets.JA["Berserk"] = {}
	sets.JA["Warcry"] = {}
	sets.JA["Defender"] = {}
	sets.JA["Aggressor"] = {}
	sets.JA["Provoke"] = sets.Precast.Enmity
	sets.JA["Third Eye"] = {}
	sets.JA["Meditate"] = {
	    head=gear.wakidoHeadPlusThree,
		hands = gear.sakonjiHandsPlusThree,
		back = gear.samSTPDt,
	}
	sets.JA["Warding Circle"] = {
		head=gear.wakidoHeadPlusThree,
	}
	sets.JA["Shikikoyo"] = {}
	sets.JA["Hasso"] = {}
	sets.JA["Seigan"] = {}
	sets.JA["Sengikori"] = {}
	sets.JA["Hamanoha"] = {}
	sets.JA["Hagakure"] = {}
	sets.JA["Konzen-ittai"] = {}
	sets.JA["Yaegasumi"] = {}

	--Default Weapon Skill set base
	sets.WS = {
		ammo=gear.knobkierrie,
		head = gear.mpacaHead,
		body=gear.nyameBody,
		hands=gear.kasugaHandsPlusTwo,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.samuraiNodowaPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.thrud,
		left_ring=gear.epimanondas,
		right_ring=gear.niqmaddu,
		back = gear.samWSD,
	}

	--This set is used when OffenseMode is ACC and a WS is used (Augments the WS base set)
	sets.WS.ACC = set_combine (sets.WS, {

	})

	sets.WS.SB = sets.Subtle_Blow

	sets.WS.MAB = set_combine(sets.WS, {		
		waist=gear.orpheusWaist,
		left_ear=gear.friomisi,
		neck=gear.fotiaNeck,
		waist=gear.orpheusWaist,
		left_ear=gear.friomisi,
		-- back={ name="Smertrios's Mantle", augments={'STR+20','Mag. Acc+20 Mag. Dmg.+20','Mag. Acc.+10','"Mag.Atk.Bns."+10','Damage taken-5%',}},
	})

	sets.WS.CRIT = set_combine(sets.WS,{
		right_ear = gear.schere,
	    ammo = gear.coiste,
	})

	--WS Sets
	sets.WS["Tachi: Enpi"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Hobaku"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Jinpu"] = set_combine (sets.WS.MAB, {})
	sets.WS["Tachi: Goten"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Kagero"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Koki"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Yukikaze"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Gekko"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Kasha"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Rana"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Ageha"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Fudo"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Shoha"] = set_combine (sets.WS, 
	{
		left_ring=gear.sroda,
		legs = gear.mpacaLegs,
		feet=gear.kasugaFeetPlusTwo,
	})

	sets.Seigan = {
	    head=gear.kasugaHeadPlusTwo,
		body=gear.kasugaBodyPlusThree,
	}
	sets.ThirdEye = {
		--legs={ name="Sakonji Haidate +3", augments={'Enhances "Shikikoyo" effect',}},
	}

	-- Used to Tag TH on a mob (TH4 is max in gear non-THF)
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

	return equipSet
end

-- Augment basic equipment sets
function aftercast_custom(spell)
	local equipSet = {}
	equipSet = choose_Seigan()
	return equipSet
end

--Function is called when the player gains or loses a buff
function buff_change_custom(name,gain)
	local equipSet = {}
	equipSet = choose_Seigan()
	return equipSet
end

--This function is called when a update request the correct equipment set
function choose_set_custom()
	local equipSet = {}
	equipSet = choose_Seigan()
	return equipSet
end

--Function is called when the player changes states
function status_change_custom(new,old)
	local equipSet = {}
	equipSet = choose_Seigan()
	return equipSet
end

--Function is called when a self command is issued
function self_command_custom(command)

end

--Custom Function
function choose_Seigan()
	local equipSet = {}
		if player.status == "Engaged" then
			if buffactive.Seigan then
				--Equip the Seigan custom set when active
				equipSet = sets.Seigan
				if buffactive["Third Eye"] then
					--Equip the Third Eye custom set when active
					equipSet = set_combine(equipSet, sets.ThirdEye)
				end
			end
		end
	return equipSet
end

--Function used to automate Job Ability use
function check_buff_JA()
	local buff = 'None'
	local ja_recasts = windower.ffxi.get_ability_recasts()
	if not buffactive['Hasso'] and not buffactive['Seigan'] and ja_recasts[138] == 0 then
		buff = "Hasso"
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

--Function used to automate Spell use
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
