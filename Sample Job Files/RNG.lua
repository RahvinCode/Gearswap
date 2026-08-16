-- Luthien

-- Load and initialize the include file.
include('GearSets-Include')
include('Mirdain-Include')

--Uses Items Automatically
AutoItem = false

--Upon Job change will use a random lockstyleset
Random_Lockstyle = false

--Lockstyle sets to randomly equip
Lockstyle_List = {1,2,6,12}

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "14"
MacroBook = "13"  -- Sub Job macro pallets can be defined in the sub_job_change_custom function below
MacroSet = "1"

-- Use "gs c food" to use the specified food item 
Food = "Sublime Sushi"

-- Threshold for Ammunition Warning
Ammo_Warning_Limit = 99

-- Add CRIT the base modes to allow AM3 Critical Builds
state.OffenseMode:options('TP','ACC','DT','PDL','CRIT','SB','True Shot')
state.OffenseMode:set('TP')

--Modes for specific to Ranger
state.WeaponMode:options('Fomalhaut','Annihilator','Gastraphetes','Fail-Not','Yoichinoyumi','Naegling', 'Tauret', 'Dolichenus')
state.WeaponMode:set('Fomalhaut')

--Enable JobMode for UI.
UI_Name = 'TP Mode'

--Melee or Ranged Mode
state.JobMode:options('Standard','Melee','Ranged','Subtle Blow')
state.JobMode:set('Standard')

-- Initialize Player
jobsetup (LockStylePallet,MacroBook,MacroSet)

-- Goal is 2000 HP
function get_sets()
	-- Weapon setup
	sets.Weapons = {}

	sets.Weapons['Naegling'] = {
		main=gear.naegling,
		sub = gear.gleti,
		range = gear.anarchyPlusTwoB,
	}

	sets.Weapons['Fomalhaut'] = {
		main = gear.perunPlusOne,
		sub = gear.kustawiPlusOne,
		range = gear.fomalhaut,
	}

	sets.Weapons['Annihilator'] = {
		main = gear.gleti,
		sub = gear.kustawiPlusOne,
		range = gear.annihilator,
	}

	sets.Weapons['Gastraphetes'] = {
		main = gear.perunPlusOne,
		sub = gear.gleti,
		range = gear.gastraphetes,
	}

	sets.Weapons['Fail-Not'] = {
		main = gear.perunPlusOne,
		sub = gear.kustawiPlusOne,
		range = gear.failNot,
	}

	sets.Weapons['Tauret'] = {
		main=gear.tauret,
		sub=gear.ternionDaggerPlusOne,
		range = gear.anarchyPlusTwoB,
	}

	sets.Weapons['Yoichinoyumi'] = {
		main = gear.perunPlusOne,
		sub = gear.kustawiPlusOne,
		range=gear.yoichinoyumi,
	}

	sets.Weapons['Dolichenus'] = {
		main=gear.dolichenus,
		sub=gear.crepuscularKnife,
		range = gear.anarchyPlusTwoB,
	}

	sets.Weapons.Melee = {
		main=gear.gleti,
		sub=gear.ternionDaggerPlusOne,
	}

	sets.Weapons.Ranged = {		
		main = gear.perunPlusOne,
		sub = gear.kustawiPlusOne,
	}

	sets.Weapons['Subtle Blow'] = {		
		main = gear.ternionDaggerPlusOne, -- SB 9
		sub = gear.gleti, -- Used for SB II
	}

	sets.Weapons.Shield = {
		sub=gear.nusku,
	}

	--Set the ammo type for each WeaponMode (above): Bullet, Arrow, Bolt
	--This allows for generic gear sets such as ammo=Ammo.RA for Midcast.RA as an example.
	Ranged_Weapons = {
		{WeaponMode = "Naegling", Type = "Bullet"},
		{WeaponMode = "Dolichenus", Type = "Bullet"},
		{WeaponMode = "Fomalhaut", Type = "Bullet"},
		{WeaponMode = "Annihilator", Type = "Bullet"},
		{WeaponMode = "Fail-Not", Type = "Arrow"},
		{WeaponMode = "Yoichinoyumi", Type = "Arrow"},
		{WeaponMode = "Gastraphetes", Type = "Bolt"},
		{WeaponMode = "Tauret", Type = "Bullet"},
	}

	-- Ammo Selection - will choose based off equiped weapon and the OffenseMode
	Ammo.Bullet.TP = "Chrono Bullet"		-- TP Ammo
	Ammo.Bullet.ACC = "Eradicating Bullet"	-- Accuracy Ammo
	Ammo.Bullet.CRIT = "Eradicating Bullet"	-- Critical Hit Mode Ammo
	Ammo.Bullet.WS = "Chrono Bullet"		-- Default WS Ammo
	Ammo.Bullet.WSD = "Chrono Bullet"		-- Weaponskill Damage
	Ammo.Bullet.MAB = "Chrono Bullet"		-- Magic Attack Bonus
	Ammo.Bullet.MACC = "Chrono Bullet"		-- Magic Accuracy
	Ammo.Bullet.MAG_WS = "Chrono Bullet"	-- Magic Weaponskills
	Ammo.Bullet.PHY_WS = "Chrono Bullet"	-- Physical Weaponskills

	Ammo.Arrow.TP = "Chrono Arrow"			-- TP Ammo
	Ammo.Arrow.ACC = "Chrono Arrow"			-- Accuracy Ammo
	Ammo.Arrow.CRIT = "Chrono Arrow"		-- Critical Hit Mode Ammo
	Ammo.Arrow.WS = "Chrono Arrow"			-- Default WS Ammo
	Ammo.Arrow.WSD = "Chrono Arrow"			-- Weaponskill Damage
	Ammo.Arrow.MAB = "Chrono Arrow"			-- Magic Attack Bonus
	Ammo.Arrow.MACC = "Chrono Arrow"		-- Magic Accuracy
	Ammo.Arrow.MAG_WS = "Chrono Arrow"		-- Magic Weaponskills
	Ammo.Arrow.PHY_WS = "Chrono Arrow"		-- Physical Weaponskills

	Ammo.Bolt.TP = "Quelling Bolt"			-- TP Ammo
	Ammo.Bolt.ACC = "Quelling Bolt"			-- Accuracy Ammo
	Ammo.Bolt.CRIT = "Quelling Bolt"		-- Critical Hit Mode Ammo
	Ammo.Bolt.WS = "Quelling Bolt"			-- Default WS Ammo
	Ammo.Bolt.WSD = "Quelling Bolt"			-- Weaponskill Damage
	Ammo.Bolt.MAB = "Quelling Bolt"			-- Magical Weaponskills
	Ammo.Bolt.MACC = "Quelling Bolt"		-- Magic Accuracy
	Ammo.Bolt.MAG_WS = "Quelling Bolt"		-- Magic Weaponskills
	Ammo.Bolt.PHY_WS = "Quelling Bolt"		-- Physical Weaponskills

	--Modes to select correct ammo based off weapon type
	Ammo.TP = Ammo[state.RAMode.value].TP
	Ammo.ACC = Ammo[state.RAMode.value].ACC
	Ammo.CRIT = Ammo[state.RAMode.value].CRIT
	Ammo.WS = Ammo[state.RAMode.value].WS
	Ammo.WSD = Ammo[state.RAMode.value].WSD
	Ammo.MAB = Ammo[state.RAMode.value].MAB
	Ammo.MACC = Ammo[state.RAMode.value].MACC
	Ammo.MAG_WS = Ammo[state.RAMode.value].MAG_WS
	Ammo.PHY_WS = Ammo[state.RAMode.value].PHY_WS

	-- Standard Idle set with -DT,Refresh,Regen with NO movement gear
	sets.Idle = {
		head=gear.nyameHead,
		body=gear.nyameBody,
		hands=gear.nyameHands,
		legs=gear.malignanceLegs,
		feet=gear.nyameFeet,
		neck = gear.loricatePlusOne,
		waist=gear.carriers,
		left_ear = gear.odnowaPlusOne,
		right_ear=gear.sanareEarring,
		left_ring = gear.gelatinousPlusOne,
		right_ring=gear.defending,
		back = gear.rngDW,
    }
	-- 'TP','ACC','DT','PDL','CRIT'
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.CRIT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {
		sub = gear.gleti,
	})
	sets.Idle.Resting = set_combine(sets.Idle, {})
	sets.Idle['True Shot'] = set_combine(sets.Idle, {})

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

	--Base TP set to build off when melee'n
	sets.OffenseMode = {
		ammo=Ammo.TP,
		head = gear.adhemarHeadPlusOnePathA,
		body = gear.adhemarBodyPlusOnePathA,
		hands = gear.adhemarHandsPlusOnePathA,
		legs = gear.samnuhaTightsDA,
		feet=gear.malignanceFeet,
		neck = gear.scoutGorget,
		waist = gear.sailfi,
		left_ear=gear.telos,
		right_ear=gear.sherida,
		left_ring=gear.lehkoHabhokaRing,
		right_ring=gear.eponas,
		back = gear.rngDW,
	}

	--Set focuses on maximum TP gain
	sets.OffenseMode.TP = set_combine(sets.OffenseMode, {})

	--This set is used when OffenseMode is set to DT and enaged
	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {
	    head=gear.malignanceHead,
		body=gear.malignanceBody,
		hands=gear.aminiHandsPlusThree,
		legs=gear.aminiLegsPlusThree,
		feet=gear.malignanceFeet,
	})

	--This set is used when OffenseMode is set to PDL and enaged
	sets.OffenseMode.PDL = set_combine(sets.OffenseMode, {
		head=gear.malignanceHead,
		body=gear.aminiBodyPlusThree,
		hands=gear.malignanceHands,
		legs=gear.malignanceLegs,
		feet=gear.malignanceFeet,
	})

	--This set is used when OffenseMode is ACC and Enaged (Augments the TP base set)
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {})

	--This set is used when OffenseMode is CRIT and Engaged
	sets.OffenseMode.CRIT = set_combine(sets.OffenseMode.DT, {})

	sets.OffenseMode.SB = set_combine(sets.OffenseMode.DT, {})

	sets.OffenseMode['True Shot'] = set_combine(sets.OffenseMode.DT, {})

	--The following sets augment the OffenseMode set above for Dual Wielding
	sets.DualWield = {
		back = gear.rngDW,
	}

	sets.Precast = { ammo=Ammo.TP,}

	-- 70 snapshot is Cap
	-- Velocity Shot is seperate term - JA of Ranger
	-- Rapid shot is like quick magic
	-- Snapshot is like Fast Cast

	-- True Shot Ranges (Increases RA and WS and)
		-- Distances listed below are effected by Monster Size
		-- Gun ~6.5 yalms
		-- Short Bow ~8.6 yalms
		-- Crossbow ~10.7 yalms
		-- Long Bow ~ 11.8 yalms

	-- Flurry is 15% Snapshot
	-- Flurry II 30% Snapshot

	-- Rapid Shot is a Job Trait of Ranger - 30%

	--No flurry - 60 Snapshot needed (Assuming 10% from Merits)
	-- Snapshot / Rapidshot
	sets.Precast.RA = set_combine(sets.Precast, { -- 5 Snapshot on Perun +1 Augment if used
	    head = gear.taeonChapeauSnapshot, -- 10
		body=gear.aminiBodyPlusThree, -- 11% Velocity Shot
		hands = gear.carmineHandsPlusOnePathD, -- 8 / 11
		legs=gear.orionLegsPlusThree, -- 15
		feet = gear.adhemarFeetPlusOnePathD, -- 10 / 13
		neck = gear.scoutGorget, -- 4
		waist=gear.yemaya, -- 0 / 5
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.tuisto,
		left_ring = gear.gelatinousPlusOne,
		right_ring=gear.crepuscularRing, -- 3
		back = gear.rngSnapshotB, -- 10 with 2% Velocity Shot
    })	--60 Snapshot / 29 Rapidshot / 11% Velocity Shot

	-- Flurry - 45 Snapshot Needed
	sets.Precast.RA.Flurry = set_combine(sets.Precast.RA, {
		head=gear.orionHeadPlusThree,
	    legs = gear.adhemarLegsPlusOnePathD, -- 10/13
	}) --45 Snapshot / 60 Rapidshot / 11% Velocity Shot

	-- Flurry II - 30 Snapshot Needed
	sets.Precast.RA.Flurry_II = set_combine( sets.Precast.RA.Flurry, { 
		feet = gear.pursuerFeetPathD,
    })	--35 Snapshot / 70 Rapidshot / 11% Velocity Shot

	-- Fast Cast for magic such as Utsusemi
	sets.Precast.FastCast = {
	    head = gear.carmineHeadPlusOnePathD, --14
		body = gear.taeonTabardFCB, -- 9
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.herculeanTrousersFCB, --6
		feet = gear.carmineFeetPlusOnePathD, -- 8
		neck=gear.voltsurge, --8
		waist=gear.siegel, -- 8 (Enhancing Magic only - Utsusemi)
		left_ear = gear.odnowaPlusOne,
		right_ear=gear.etiolation, -- 1
		left_ring = gear.gelatinousPlusOne,
		right_ring=gear.weatherspoon, -- 5
		back = gear.rngRangedSTP, -- Need to upgrade Cape with 10% FC
	} -- 77 FC for Utsusemi (80 is cap)
	 
	--Base set for midcast - if not defined will notify and use your idle set for surviability
	sets.Midcast = set_combine(sets.Idle, {})

	-- Ranged Attack Gear (Normal Midshot)
    sets.Midcast.RA = set_combine(sets.Midcast, {
		ammo=Ammo.RA,
		head = gear.arcadianHeadPlusThree,
		body=gear.aminiBodyPlusThree,
		hands=gear.aminiHandsPlusThree,
		legs=gear.aminiLegsPlusThree,
		feet = gear.ikengaFeet,
		neck=gear.iskur,
		waist = gear.tellenBelt,
		left_ear=gear.telos,
		right_ear=gear.crepuscularEar,
		left_ring=gear.chirichRingPlusOne,
		right_ring=gear.crepuscularRing,
		back = gear.rngRangedSTP,
    }) -- With Recycle Merits 101 Recycle for TP bonus and Ammo Save

	-- Ranged Attack Gear (High Accuracy Midshot)
    sets.Midcast.RA.ACC = set_combine(sets.Midcast.RA, {
		ammo=Ammo.ACC,
    })

	-- Ranged Attack Gear (Physical Damage Limit)
    sets.Midcast.RA.PDL = set_combine(sets.Midcast.RA, {
		head = gear.ikengaHead,
		body = gear.ikengaBody,
		hands = gear.ikengaHands,
		legs = gear.ikengaLegs,
		feet = gear.ikengaFeet,
		left_ring=gear.sroda,
    })

	-- Ranged Attack Gear (Critical Build)
    sets.Midcast.RA.CRIT = set_combine(sets.Midcast.RA, {
		head = gear.ikengaHead,
		hands = gear.ikengaHands,
		legs=gear.aminiLegsPlusThree,
		feet = gear.ikengaFeet, -- 10
		neck = gear.scoutGorget,
		waist=gear.kwahuKachinaBeltPlusOne,
		right_ear=gear.sherida, -- 5 II
		left_ear=gear.odr,
		left_ring=gear.lehkoHabhokaRing,
		right_ring = gear.chirichPlusOne2, -- 10
		back = gear.rngCrit,
    })

	-- Ranged Attack Gear (Critical Build)
    sets.Midcast.RA.SB = set_combine(sets.Midcast.RA, {
		-- 10 II from gleti's Knife
		neck=gear.bathyPlusOne,
		head = gear.ikengaHead, -- 5 II
		right_ear=gear.sherida, -- 5 II
		left_ear=gear.odr,
		hands = gear.ikengaHands, -- 15
		waist = gear.tellenBelt, -- 5
		left_ring = gear.chirichPlusOne1, -- 10
		right_ring = gear.chirichPlusOne2, -- 10
    })

	sets.Midcast.RA['True Shot'] = set_combine(sets.Midcast.RA, {
		body=gear.nisrochBody, -- 10
		legs=gear.aminiLegsPlusThree, -- 8
		feet = gear.ikengaFeet, -- 10
		waist = gear.tellenBelt, -- 5
    })

	-- Ranged Attack Gear (Double Shot Midshot)
	sets.Midcast.RA.DoubleShot = {
		body = gear.arcadianBodyPlusThree,
		legs=gear.oshosiTrousersPlusOne,
		hands=gear.oshosiGlovesPlusOne,
		feet=gear.oshosiLeggingsPlusOne,
    }

	-- Ranged Attack Gear (Barrage active)
	sets.Midcast.RA.Barrage = { hands=gear.orionHandsPlusThree, }

	-- Relic Aftermath
	sets.Midcast.RA.AM = {}
	--sets.Midcast.RA.AM['Annihilator'] = {}

	-- Empy/Mythic Aftermath
	sets.Midcast.RA.AM3 = {}
	--sets.Midcast.RA.AM3['Gastraphetes'] = { }
	sets.Midcast.RA.AM2 = {}
	--sets.Midcast.RA.AM2['Gastraphetes'] = { }
	sets.Midcast.RA.AM1 = {}
	--sets.Midcast.RA.AM1['Gastraphetes'] = { }

	-- Job Abilities
	sets.JA = {}
	sets.JA["Eagle Eye Shot"] = {legs = gear.arcadianLegsPlusThree,}
	sets.JA["Scavenge"] = {}
	sets.JA["Shadowbind"] = { hands=gear.orionHandsPlusThree,}
	sets.JA["Camouflage"] = {body = gear.arcadianBodyPlusThree,}
	sets.JA["Sharpshot"] = { legs=gear.orionLegsPlusThree,}
	sets.JA["Barrage"] = {} -- Midcast.RA.Barrage set
	sets.JA["Unlimited Shot"] = {}
	sets.JA["Velocity Shot"] = {}
	sets.JA["Double Shot"] = {} -- Midcast.RA.Double Shot set
	sets.JA["Bounty Shot"] = { ammo= Ammo.RA, hands=gear.aminiHandsPlusThree,} -- Upgrade to TH4
	sets.JA["Decoy Shot"] = {}
	sets.JA["Overkill"] = {}
	sets.JA["Hover Shot"] = {}


	-- Dancer JA Section

	sets.Flourish = set_combine(sets.Idle.DT, {})

	sets.Jig = set_combine(sets.Idle.DT, { })

	sets.Step = set_combine(sets.OffenseMode.DT, {})

	sets.Samba = set_combine(sets.Idle.DT, {})

	sets.Waltz = set_combine(sets.OffenseMode.DT, {
		ammo=gear.yamarang, -- 5
		--body={ name="Gleti's Cuirass", augments={'Path: A',}}, -- 10
		hands=gear.slitherGlovesPlusOne, -- 5
		legs=gear.dashingSubligar, -- 10
	}) -- 30% Potency

	sets.PhantomRoll = {}

	-- Base Weapon Skill set
	sets.WS = {
		ammo = Ammo.WS,
	    head=gear.nyameHead,
		body=gear.nyameBody,
		hands=gear.nyameHands,
		legs=gear.nyameLegs,
		feet=gear.nyameFeet,
		neck = gear.scoutGorget,
		waist=gear.fotiaWaist,
		left_ear=gear.ishvara,
		right_ear=gear.enervatingEarring,
		left_ring=gear.regalRing,
		right_ring=gear.epimanondas,
		back = gear.rngWSD, -- Add Melee Cape
	}

	-- Subtle Blow set used in OffenseMode.SB
	sets.WS.SB = set_combine(sets.WS, { })

	-- Physical Damage Limit set used in OffenseMode.PDL
	sets.WS.PDL = set_combine(sets.WS, { })

	-- Accuracy set used in OffenseMode.ACC
	sets.WS.ACC = set_combine(sets.WS, { })

	-- Critical Hit set used in OffenseMode.SB
	sets.WS.CRIT = set_combine(sets.WS, { })

	-- Weapon Skill Damage (Melee)
	sets.WS.WSD = set_combine(sets.WS, {
		ammo=Ammo.PHY_WS,
		neck = gear.scoutGorget,
		waist = gear.sailfi,
		left_ear=gear.ishvara,
		right_ear = gear.moonshadeEarringAcc,
		left_ring=gear.regalRing,
		right_ring=gear.epimanondas,
		back = gear.rngWSD,
	})

	-- Magic Attack Bonus
	sets.WS.MAB = set_combine(sets.WS, {
		ammo=Ammo.MAB,
		waist=gear.eschan, -- Orpheus/Obi Swap
		left_ear=gear.friomisi,
		right_ear = gear.moonshadeEarringAcc,
		right_ring=gear.dingir,
	})

	-- Ranged Weapon Skills
	sets.WS.RA = set_combine(sets.WS, {
		ammo=Ammo.WSD,
		head=gear.orionHeadPlusThree,
		body=gear.aminiBodyPlusThree,
		hands = gear.nyameHands,
		legs = gear.arcadianLegsPlusThree,
		feet=gear.aminiFeetPlusThree,
		neck = gear.scoutGorget,
		waist=gear.fotiaWaist,
		left_ear=gear.ishvara,
		right_ear=gear.telos,
		left_ring=gear.dingir,
		right_ring=gear.epimanondas,
		back = gear.rngWSD,
	})

	sets.WS.RA.PDL = set_combine(sets.WS.RA, { 
		head = gear.ikengaHead,
		body=gear.aminiBodyPlusThree,
		hands = gear.ikengaHands,
		legs = gear.ikengaLegs,
		feet = gear.ikengaFeet,
		neck = gear.scoutGorget,
		waist=gear.fotiaWaist,
		left_ear=gear.ishvara,
		right_ear=gear.telos,
		left_ring=gear.sroda,
		right_ring=gear.dingir,
		back = gear.rngWSD,
	})

	sets.WS.RA.ACC = set_combine(sets.WS.RA, {
		ammo=Ammo.ACC, -- Smart_Ammo() will select from your XXXX.RA type
	})

	sets.WS.RA.CRIT = set_combine(sets.WS.RA, {
		ammo=Ammo.CRIT -- Smart_Ammo() will select from your XXXX.RA type
	})

	sets.WS.RA.SB = set_combine(sets.WS.RA, {
		-- 10 II from gleti's Knife
		neck=gear.bathyPlusOne,
		head = gear.ikengaHead, -- 5 II
		right_ear=gear.sherida, -- 5 II
		hands = gear.ikengaHands, -- 15
		left_ring = gear.chirichPlusOne1, -- 10
		right_ring = gear.chirichPlusOne2, -- 10
	})

	-- Below swaps gear based off Aftermath

	-- Relic Aftermath
	sets.WS.RA.AM = {}
	sets.WS.RA.AM['Annihilator'] = {}

	-- Empy/Mythic Aftermath
	sets.WS.RA.AM3 = {}
	sets.WS.RA.AM3['Gastraphetes'] = { }
	sets.WS.RA.AM2 = {}
	sets.WS.RA.AM2['Gastraphetes'] = { }
	sets.WS.RA.AM1 = {}
	sets.WS.RA.AM1['Gastraphetes'] = { }

	-- Gun Weaponskills
	sets.WS["Hot Shot"] = set_combine(sets.WS.MAB, {})
	sets.WS["Split Shot"] = set_combine(sets.WS.RA, {})
	sets.WS["Sniper Shot"] = set_combine(sets.WS.RA, {})
	sets.WS["Blast Shot"] = set_combine(sets.WS.RA, {})
	sets.WS["Heavy Shot"] = set_combine(sets.WS.RA, {})
	sets.WS["Detonator"] = set_combine(sets.WS.RA, {})
	sets.WS["Numbing Shot"] = set_combine(sets.WS.RA, {})
	sets.WS["Wildfire"] = set_combine(sets.WS.MAB, {
		-- Get Cremation Earring since doesn't scale with TP
	})
	sets.WS["Last Stand"] = set_combine(sets.WS.RA, {})

	sets.WS["Coronach"] = set_combine(sets.WS.RA, { 		
		head=gear.orionHeadPlusThree,
		body = gear.ikengaBody,
		hands = gear.nyameHands,
		legs = gear.arcadianLegsPlusThree,
		feet=gear.aminiFeetPlusThree,
		neck=gear.fotiaNeck,
		waist=gear.fotiaWaist,
		left_ear=gear.ishvara,
		right_ear=gear.telos,
		left_ring=gear.regalRing,
		right_ring=gear.epimanondas,
		back = gear.rngWSD,
	})

	sets.WS["Slug Shot"] = set_combine(sets.WS.RA, {		
		head=gear.orionHeadPlusThree,
		body = gear.ikengaBody,
		hands = gear.nyameHands,
		legs = gear.arcadianLegsPlusThree,
		feet=gear.aminiFeetPlusThree,
		neck=gear.fotiaNeck,
		waist=gear.fotiaWaist,
		left_ear=gear.ishvara,
		right_ear=gear.telos,
		left_ring=gear.regalRing,
		right_ring=gear.epimanondas,
		back = gear.rngWSD,
	})

	-- Archery Weaponskills
	sets.WS["Flaming Arrow"] = set_combine(sets.WS.MAB, {})
	sets.WS["Piercing Arrow"] = set_combine(sets.WS.RA, {})
	sets.WS["Dulling Arrow"] = set_combine(sets.WS.RA, {})
	sets.WS["Sidewinder"] = set_combine(sets.WS.RA, {})
	sets.WS["Blast Arrow"] = set_combine(sets.WS.RA, {})
	sets.WS["Arching Arrow"] = set_combine(sets.WS.RA, {})
	sets.WS["Refulgent Arrow"] = set_combine(sets.WS.RA, {})
	sets.WS["Jishnu's Radiance"] = set_combine(sets.WS.RA, {})
	sets.WS["Apex Arrow"] = set_combine(sets.WS.RA, {})
	sets.WS["Namas Arrow"] = {		
		head=gear.orionHeadPlusThree,
		body=gear.aminiBodyPlusThree,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet=gear.aminiFeetPlusTwo,
		neck=gear.fotiaNeck,
		waist=gear.fotiaWaist,
		left_ear=gear.ishvara,
		right_ear=gear.telos,
		left_ring=gear.regalRing,
		right_ring=gear.epimanondas,
		back = gear.rngWSD,
	}

	-- Sword Weaponskills
	sets.WS["Fast Blade"] = set_combine(sets.WS.WSD, {})
	sets.WS["Burning Blade"] = set_combine(sets.WS.MAB, {})
	sets.WS["Flat Blade"] = set_combine(sets.WS.WSD, {})
	sets.WS["Shining Blade"] = set_combine(sets.WS.WSD, {})
	sets.WS["Circle Blade"] = set_combine(sets.WS.WSD, {})
	sets.WS["Spirits Within"] = set_combine(sets.WS.WSD, {})
	sets.WS["Savage Blade"] = set_combine(sets.WS.WSD, {})

	-- Dagger Weaponskills
	sets.WS["Wasp Sting"] = set_combine(sets.WS.WSD, {})
	sets.WS["Viper Bite"] = set_combine(sets.WS.WSD, {})
	sets.WS["Shadowstitch"] = set_combine(sets.WS.WSD, {})
	sets.WS["Gust Slash"] = set_combine(sets.WS.WSD, {})
	sets.WS["Cyclone"] = set_combine(sets.WS.WSD, {})
	sets.WS["Energy Steal"] = set_combine(sets.WS.WSD, {})
	sets.WS["Energy Drain"] = set_combine(sets.WS.WSD, {})
	sets.WS["Evisceration"] = set_combine(sets.WS.WSD, {})
	sets.WS['Aeolian Edge'] = set_combine(sets.WS.MAB, {})

	-- Crossbow Weaponskills
	sets.WS["Trueflight"] = set_combine(sets.WS.MAB, {
		neck = gear.scoutGorget,
		waist=gear.eschan,
		left_ear=gear.friomisi,
		right_ear = gear.moonshadeEarringAcc,
		left_ring=gear.dingir,
		right_ring=gear.weatherspoon,
		back = gear.rngWSD,
	})

	sets.TreasureHunter = { 
		body=gear.volteJupon,
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
	equipSet = Job_Mode_Check(equipSet)
	return equipSet
end
-- Augment basic equipment sets
function midcast_custom(spell)
	local equipSet = {}
	equipSet = Job_Mode_Check(equipSet)
	return equipSet
end
-- Augment basic equipment sets
function aftercast_custom(spell)
	local equipSet = {}
	equipSet = Job_Mode_Check(equipSet)
	return equipSet
end
--Function is called when the player gains or loses a buff
function buff_change_custom(name,gain)
	local equipSet = {}
	equipSet = Job_Mode_Check(equipSet)
	return equipSet
end
--This function is called when a update request the correct equipment set
function choose_set_custom()
	local equipSet = {}
	equipSet = Job_Mode_Check(equipSet)
	return equipSet
end
--Function is called when the player changes states
function status_change_custom(new,old)
	local equipSet = {}
	equipSet = Job_Mode_Check(equipSet)
	return equipSet
end

--Function is called when a self command is issued
function self_command_custom(command)
	Smart_Ammo()
end

-- Function is called whn lua is unloaded
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

function Smart_Ammo()
	for i = 1, #Ranged_Weapons do
		if state.WeaponMode.value == Ranged_Weapons[i].WeaponMode then
			if state.RAMode.value ~= Ranged_Weapons[i].Type then
				state.RAMode:set(Ranged_Weapons[i].Type)
				windower.add_to_chat(8,'Ammo Mode is ['..state.RAMode.value..']')
				get_sets()
				equip({ammo=Ammo.RA})
			end
			return
		end
	end
end

function Job_Mode_Check(equipSet)
	if state.JobMode.value == 'Melee' then
		equipSet = set_combine(equipSet, sets.Weapons.Melee)
	elseif state.JobMode.value == 'Ranged' then
		equipSet = set_combine(equipSet, sets.Weapons.Ranged)
	elseif state.JobMode.value == 'Subtle Blow' then
		equipSet = set_combine(equipSet, sets.Weapons['Subtle Blow'])
	end
	if DualWield == false then
		if TwoHand == false then
			equipSet = set_combine(equipSet, sets.Weapons.Shield)
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
