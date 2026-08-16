-- Maedhros

-- Load and initialize the include file.
include('GearSets-Include')
include('Mirdain-Include')

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "7"
MacroBook = "18"  -- Sub Job macro pallets can be defined in the sub_job_change_custom function below
MacroSet = "1"

-- Use "gs c food" to use the specified food item 
Food = "Sublime Sushi"

--Uses Items Automatically
AutoItem = false

--Upon Job change will use a random lockstyleset
Random_Lockstyle = false

--Lockstyle sets to randomly equip
Lockstyle_List = {1,2,6,12}

-- Add CRIT the base modes to allow AM3 Critical Builds
state.OffenseMode:options('TP','ACC','DT','PDL','CRIT','MEVA','SB')
state.OffenseMode:set('TP')

--Modes for specific to Corsair
state.WeaponMode:options('Fomalhaut','Death Penalty', 'Savage Blade', 'Aeolian Edge', 'Evisceration')
state.WeaponMode:set('Death Penalty')

--Enable JobMode for UI.
UI_Name = 'TP Mode'

--Melee or Ranged Mode
state.JobMode:options('Standard','Melee','Ranged','Subtle Blow')
state.JobMode:set('Standard')

-- Initialize Player
jobsetup (LockStylePallet,MacroBook,MacroSet)

-- Threshold for Ammunition Warning
Ammo_Warning_Limit = 99

function get_sets()

	--Set the weapon options.  This is set below in job customization section

	-- Weapon setup
	sets.Weapons = {}

	sets.Weapons['Savage Blade'] = {
		main=gear.naegling,
		sub = gear.gleti,
		range = gear.anarchyPlusTwoB,
	}

	sets.Weapons['Evisceration'] = {
		main=gear.tauret,
		sub = gear.gleti,
		range = gear.fomalhaut,
	}

	sets.Weapons['Fomalhaut'] = {
		main = gear.rostam4,
		sub = gear.rostam2,
		range = gear.fomalhaut,
	}

	sets.Weapons['Death Penalty'] = {
		main = gear.rostam4,
		sub=gear.tauret,
		range = gear.deathPenalty,
	}

	sets.Weapons['Aeolian Edge'] = {
		ammo=Ammo.Bullet.MAG_WS,
		main = gear.rostam4,
		sub=gear.tauret,
		range = gear.anarchyPlusTwoB,
	}

	sets.Weapons.Melee = {
		sub = gear.gleti,
	}

	sets.Weapons['Subtle Blow'] = {
		sub = gear.gleti, -- Used for SB II
	}

	sets.Weapons.Ranged = {
		sub = gear.kustawiPlusOne,
	}

	sets.Weapons.Shield = {
		sub = gear.nusku,
	}

	sets.Weapons.Sleep = {
		range=gear.earp,
	}

	-- Ammo Selection
	Ammo.Bullet.RA = "Chrono Bullet"		-- TP Ammo
	Ammo.Bullet.WS = "Chrono Bullet"		-- Physical Weaponskills
	Ammo.Bullet.CRIT = "Chrono Bullet"		-- Critical Hit Mode
	Ammo.Bullet.PDL = "Chrono Bullet"		-- Physical Damage Mode
	Ammo.Bullet.SB = "Chrono Bullet"		-- Subtle Blow Mode
	Ammo.Bullet.MAB = "Living Bullet"		-- Magical Weaponskills
	Ammo.Bullet.MACC = "Chrono Bullet"		-- Magic Accuracy
	Ammo.Bullet.QD = "Hauksbok Bullet"		-- Quick Draw
	Ammo.Bullet.MAG_WS = "Living Bullet"	-- Magic Weapon Skills

	-- Standard Idle set with -DT,Refresh,Regen with NO movement gear
	sets.Idle = {
		ammo = Ammo.Bullet.RA,
		head = gear.nyameHead,
		body=gear.adamantiteArmor,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.loricatePlusOne,
		waist=gear.carriers,
		left_ear=gear.sanareEarring,
		right_ear = gear.odnowaPlusOne,
		left_ring = gear.gelatinousPlusOne,
		right_ring=gear.shadowRing,
		back = gear.corDAPdt,
    }
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.CRIT = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})

	sets.Movement = {
		legs = gear.carmineLegsPlusOnePathA,
		right_ring=gear.defending,
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

	sets.Subtle_Blow = {
		neck=gear.bathyPlusOne,
		right_ring = gear.chirichPlusOne2,
	}

	--The following sets augment the base TP set above for Dual Wielding
	sets.DualWield = {
		waist=gear.reiki,
		right_ear=gear.eabani,
	}

	sets.OffenseMode = {
		ammo = Ammo.Bullet.RA,
		head=gear.malignanceHead,
		body=gear.malignanceBody,
		hands=gear.malignanceHands,
		legs = gear.samnuhaTightsDA,
		feet=gear.malignanceFeet,
		neck=gear.iskur,
		waist = gear.sailfi,
		left_ear=gear.telos,
		right_ear=gear.crepuscularEar,
		left_ring=gear.lehkoHabhokaRing,
		right_ring=gear.eponas,
		back=gear.nullShawl,
	}

	--Base TP set to build off when melee'n
	sets.OffenseMode.TP = set_combine(sets.OffenseMode, {})

	--This set is used when OffenseMode is DT and Enaged
	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {
	    legs=gear.chasseurLegsPlusThree,
		right_ear = gear.odnowaPlusOne,
	})

	--This set is used when OffenseMode is PDL and Enaged
	sets.OffenseMode.PDL = set_combine(sets.OffenseMode, {
		legs=gear.malignanceLegs,
	})

	--This set is used when OffenseMode is CRIT and Enaged
	sets.OffenseMode.CRIT = set_combine(sets.OffenseMode, {
	    head=gear.nullMasque,
		body = gear.ikengaBody,
		hands=gear.chasseurHandsPlusThree,
		legs=gear.malignanceLegs,
		feet=gear.oshosiLeggingsPlusOne,
		neck=gear.nullLoop,
		waist=gear.reiki,
		left_ear=gear.telos,
		right_ear=gear.chasseurEarringPlusOne,
		left_ring=gear.lehkoHabhokaRing,
		right_ring=gear.eponas,
		back = gear.corCrit,
	})

	--This set is used when OffenseMode is ACC and Enaged (Augments the TP base set)
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {})

	-- Subtle Blow Set
	sets.OffenseMode.SB = set_combine(sets.OffenseMode, {
		body=gear.adamantiteArmor,
		legs=gear.chasseurLegsPlusThree,
		neck=gear.nullLoop,
		right_ear = gear.odnowaPlusOne,
		left_ring = gear.chirichPlusOne1,
		right_ring = gear.chirichPlusOne2,
	})

	--This set is used when OffenseMode is MEVA and Enaged
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode.DT, {
		head=gear.malignanceHead,
		body=gear.malignanceBody,
		hands=gear.malignanceHands,
		legs=gear.chasseurLegsPlusThree,
		feet=gear.malignanceFeet,
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
		left_ear=gear.telos,
		right_ear = gear.odnowaPlusOne,
		left_ring=gear.lehkoHabhokaRing,
		right_ring=gear.defending,
		back = gear.corDAPdt,
	})

	sets.Precast = {}
	-- 70 snapshot is Cap.  Need 60 due to 10 from gifts
	-- Snapshot / Rapidshot
	-- Rapid shot is like quick magic
	-- Snapshot is like Fast Cast
	-- Flurry is 15% Snapshot
	-- Flurry II 30% Snapshot

	--No flurry - 60 Snapshot needed
	sets.Precast.RA = {
		ammo=Ammo.Bullet.RA,
		head=gear.chasseurHeadPlusThree, -- 0/14
		body=gear.oshosiVestPlusOne, -- 14/0
		hands = gear.carmineHandsPlusOnePathD, -- 8/11
		legs = gear.adhemarLegsPlusOnePathD, -- 10/13
		feet=gear.meghanadaFeetPlusTwo, -- 10/0
		left_ear = gear.tuisto,
		right_ear = gear.etiolation,
		left_ring=gear.dingir,
		right_ring=gear.crepuscularRing, -- 3/0
		neck = gear.commodoreCharm, -- 4/0
		waist=gear.yemaya, -- 0/5
		back = gear.corSnapshot, -- 10/0
    } -- Totals 59/43

	-- Flurry - 45 Snapshot Needed
	sets.Precast.RA.Flurry = set_combine(sets.Precast.RA, {
		body=gear.laksamanaBodyPlusFour, -- 0/20
	}) -- Totals 45/63

	-- Flurry II - 30 Snapshot Needed
	sets.Precast.RA.Flurry_II = set_combine( sets.Precast.RA.Flurry, { 
		feet = gear.pursuerFeetPathD -- 0/10
    }) -- Totals 35/73

	-- Fast Cast for Magic
	sets.Precast.FastCast = {
	    head = gear.carmineHeadPlusOnePathD, -- 14
		body = gear.taeonTabardFC, -- 9
		hands = gear.leylineGlovesFC, -- 7  Need to update
		legs = gear.herculeanTrousersBFC,  -- 6
		feet = gear.carmineFeetPlusOnePathD, -- 8
		neck=gear.voltsurge, -- 4
		waist=gear.platinumMoogleBelt,
		left_ear=gear.loquacious, -- 2
		right_ear=gear.etiolation, -- 1
		left_ring=gear.lebecheRing,
		right_ring=gear.kishar, -- 4
		back = gear.corFC, -- 10
	} -- 65 FC

	--Base set for midcast - if not defined will notify and use your idle set for surviability
	sets.Midcast = set_combine(sets.Idle, {})

	-- Ranged Attack Gear (Normal Midshot)
    sets.Midcast.RA = set_combine(sets.Midcast, {
		ammo=Ammo.Bullet.RA,
		head=gear.ikengaHead,
		body=gear.ikengaBody,
		hands=gear.ikengaHands,
		legs=gear.chasseurLegsPlusThree,
		feet=gear.ikengaFeet,
		neck=gear.iskur,
		waist=gear.yemaya,
		left_ear=gear.telos,
		right_ear=gear.crepuscularEar,
		left_ring=gear.ilabrat,
		right_ring=gear.crepuscularRing,
		back = gear.corSTP,
    })

	sets.Midcast.RA.ACC = set_combine(sets.Midcast.RA, {})

	-- Ranged PDL
	sets.Midcast.RA.PDL = set_combine(sets.Midcast.RA, {
		left_ring=gear.sroda,
    })

	-- Ranged Attack Gear (Critical Build)
    sets.Midcast.RA.SB = set_combine(sets.Midcast.RA, {
		-- 10 II from gleti's Knife
		head = gear.ikengaHead, -- 5 II
		hands = gear.ikengaHands, -- 15
		left_ring = gear.chirichPlusOne1, -- 10
		right_ring = gear.chirichPlusOne2, -- 10
    })

	-- Ranged CRIT
	sets.Midcast.RA.CRIT = set_combine(sets.Midcast.RA, {
		head = gear.ikengaHead,
		feet=gear.oshosiLeggingsPlusOne,
		legs=gear.ikengaLegs,
		waist=gear.kwahuKachinaBeltPlusOne,
		left_ring=gear.chirichRingPlusOne,
		right_ring=gear.chirichRingPlusOne,
		right_ear=gear.chasseurEarringPlusOne,
		back = gear.corCrit,
    })

	-- Ranged Attack Gear (Triple Shot Midshot)
	sets.Midcast.RA.TripleShot = set_combine(sets.Midcast.RA, {
        head=gear.oshosiMaskPlusOne, -- Missing
        body=gear.chasseurBodyPlusThree, --14
        hands=gear.lanunHandsPlusFour, -- Tripple shot becomes Quad shot
        legs=gear.oshosiTrousersPlusOne, -- Missing
        feet=gear.oshosiLeggingsPlusOne, --3
    }) --28

	sets.Midcast.Utsusemi = set_combine(sets.Idle, {})

	-- Quick Draw Gear Sets
	sets.QuickDraw = {}

	sets.QuickDraw.ACC = {
		ammo = Ammo.Bullet.QD,
		head=gear.malignanceHead,
		body=gear.malignanceBody,
		hands=gear.malignanceHands,
		legs=gear.malignanceLegs,
		feet=gear.malignanceFeet,
		neck = gear.commodoreCharm,
		waist=gear.eschan,
		left_ear=gear.hermetic,
		right_ear=gear.crepuscularEar,
		left_ring=gear.kishar,
		right_ring=gear.crepuscularRing,
		back = gear.corSTP,
	}

	sets.QuickDraw.DMG = {
		ammo = Ammo.Bullet.QD,
		head = gear.nyameHead,
		body = gear.lanunBodyPlusThree,
		hands=gear.nyameHands,
		legs=gear.nyameLegs,
		feet=gear.chasseurFeetPlusThree,
		neck = gear.commodoreCharm,
		waist=gear.orpheusWaist,
		left_ear=gear.friomisi,
		right_ear = gear.moonshadeEarringAcc,
		left_ring=gear.dingir,
		right_ring=gear.ilabrat,
		back = gear.corWSDAgi,
	}

	sets.QuickDraw.STP = {
		ammo = Ammo.Bullet.QD,
		head=gear.malignanceHead,
		body=gear.malignanceBody,
		hands=gear.malignanceHands,
		legs=gear.chasseurLegsPlusThree,
		feet=gear.malignanceFeet,
		neck=gear.iskur,
		waist=gear.yemaya,
		left_ear=gear.telos,
		right_ear=gear.crepuscularEar,
		left_ring=gear.crepuscularRing,
		right_ring=gear.ilabrat,
		back = gear.corSTP,
	}

	-- Quick Draw 
	sets.QuickDraw["Fire Shot"] = set_combine( sets.QuickDraw.DMG, {})
	sets.QuickDraw["Ice Shot"] = set_combine( sets.QuickDraw.DMG, {})
	sets.QuickDraw["Wind Shot"] = set_combine( sets.QuickDraw.DMG, {})
	sets.QuickDraw["Earth Shot"] = set_combine( sets.QuickDraw.DMG, {})
	sets.QuickDraw["Thunder Shot"] = set_combine( sets.QuickDraw.DMG, {})
	sets.QuickDraw["Water Shot"] = set_combine( sets.QuickDraw.DMG, {})
	sets.QuickDraw["Light Shot"] = set_combine( sets.QuickDraw.DMG, {})
	sets.QuickDraw["Dark Shot"] = set_combine( sets.QuickDraw.DMG, {
	    right_ring=gear.archonRing,
	    head=gear.pixieHead,
	})

	-- Job Abilities
	sets.JA = {}
	sets.JA["Wild Card"] = {
	    feet = gear.lanunFeetPlusFour,
	}
	sets.JA["Phantom Roll"] = {}
	sets.JA["Random Deal"] = {
	    body = gear.lanunBodyPlusThree,
	}
	sets.JA["Snake Eye"] = {
	    legs = gear.lanunLegsPlusThree,
	}
	sets.JA["Fold"] = {}			-- Use gloves for bust
	sets.JA["Triple Shot"] = {}		-- Gear to be worn during Midshot
	sets.JA["Cutting Cards"] = {}
	sets.JA["Crooked Cards"] = {}
	sets.JA["Double-Up"] = {
		right_ring=gear.luzaf, -- 16 yalm range
	}

	sets.Waltz = set_combine(sets.OffenseMode.DT, {
		ammo=gear.yamarang, -- 5
		hands=gear.slitherGlovesPlusOne, -- 5
		legs=gear.dashingSubligar, -- 10
	}) -- 20% Potency

	sets.Fold = {hands = gear.lanunHandsPlusFour}

	--Base Set used for all rolls
	sets.PhantomRoll = {
		main = gear.rostam2, -- +8 Effect and 60 sec Duration
		sub = gear.nusku,
		range=gear.compensator, -- 20 sec Duration
		head = gear.lanunHeadPlusFour, -- 50% Job ability Bonus
		hands=gear.chasseurHandsPlusThree, --60 sec Duration
		neck=gear.regalNeck, -- 20 sec Duration
		right_ring=gear.luzaf, -- 16 yalm range
		back = gear.corSnapshot, -- 30 sec Duration
	}

	sets.PhantomRoll["Fighter's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Monk's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Healer's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Wizard's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Warlock's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Rogue's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Gallant's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Chaos Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Beast Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Choral Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Hunter's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Samurai Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Ninja Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Drachen Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Evoker's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Magus's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Corsair's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Puppet Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Dancer's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Scholar's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Bolter's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Caster's Roll"] = set_combine(sets.PhantomRoll, {legs=gear.chasseurLegsPlusThree,})
	sets.PhantomRoll["Tactician's Roll"] = set_combine(sets.PhantomRoll, {body=gear.chasseurBodyPlusThree})
	sets.PhantomRoll["Allies' Roll"] = set_combine(sets.PhantomRoll, {hands=gear.chasseurHandsPlusThree})
	sets.PhantomRoll["Miser's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Companion's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Avenger's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Naturalist's Roll"] = sets.PhantomRoll
    sets.PhantomRoll["Courser's Roll"] = set_combine(sets.PhantomRoll, {feet=gear.chasseurFeetPlusThree})
    sets.PhantomRoll["Blitzer's Roll"] = set_combine(sets.PhantomRoll, {head=gear.chasseurHeadPlusThree})

	-- Melee Base set
	sets.WS = {
		ammo=Ammo.Bullet.WS,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands=gear.chasseurHandsPlusThree,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.commodoreCharm,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.ishvara,
		left_ring=gear.regalRing,
		right_ring=gear.epimanondas,
		back = gear.corWSDStr,
	}

	-- Critical Hit set used in OffenseMode.CRIT
	sets.WS.CRIT = set_combine(sets.WS, { })

	-- Accuracy sets used in OffenseMode.ACC
	sets.WS.ACC = set_combine(sets.WS, {})

	-- Equipment to augment WS for Physical Damage Limit (Capped Attack)
	sets.WS.PDL = set_combine(sets.WS, {
		left_ring=gear.sroda,
	})

	sets.WS.SB = sets.Subtle_Blow

	sets.WS.MAB = set_combine(sets.WS, {
		ammo=Ammo.Bullet.MAB,
		feet = gear.lanunFeetPlusFour,
		waist=gear.eschan,
		left_ear=gear.friomisi,
		right_ear=gear.crematioEarring,
		back = gear.corWSDAgi,
	})

	sets.WS.MEVA = set_combine(sets.WS, {
	    neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
	})

	-- Ranged Base Set (Augments the sets.WS)
	sets.WS.RA = {
		head = gear.lanunHeadPlusFour,
		body = gear.ikengaBody,
		hands=gear.chasseurHandsPlusThree,
		legs = gear.ikengaLegs,
		feet = gear.ikengaFeet,
		neck=gear.fotiaNeck,
		waist=gear.fotiaWaist,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.ishvara,
		left_ring=gear.regalRing,
		right_ring=gear.dingir,
		back = gear.corWSDDt,
	}

	sets.WS.RA.ACC = set_combine(sets.WS.RA, {})

	sets.WS.RA.PDL = set_combine(sets.WS.RA, {
		left_ring=gear.sroda,
		head=gear.ikengaHead,
		legs=gear.ikengaLegs,
		feet=gear.ikengaFeet,
	})

	sets.WS.RA.CRIT = set_combine(sets.WS.RA, { })

	--These set are used when a weaponskill is used with that level of aftermath with the correct weapon
	--They Augment any built weaponskill set - Same formatting as the OffenseModes
	sets.WS.AM = {}
	sets.WS.AM1 = {}
	sets.WS.AM2 = {}
	sets.WS.AM3 = {}

	sets.WS.RA.AM = {}
	sets.WS.RA.AM1 = {}
	sets.WS.RA.AM2 = {}
	sets.WS.RA.AM3 = {}
	sets.WS.RA.AM1['Armageddon'] = {}
	sets.WS.RA.AM2['Armageddon'] = {}
	sets.WS.RA.AM3['Armageddon'] = {}

	sets.WS['Aeolian Edge'] = set_combine(sets.WS.MAB, {
		right_ear = gear.moonshadeEarringAcc,
	})

	sets.WS["Savage Blade"] = set_combine(sets.WS, {
		left_ring=gear.sroda,
	})

	sets.WS["Fast Blade"] = set_combine(sets.WS, {})
	sets.WS["Burning Blade"] = set_combine(sets.WS, {})
	sets.WS["Flat Blade"] = set_combine(sets.WS, {})
	sets.WS["Shining Blade"] = set_combine(sets.WS, {})
	sets.WS["Circle Blade"] = set_combine(sets.WS, {})
	sets.WS["Spirits Within"] = set_combine(sets.WS, {})
	sets.WS["Requiescat"] = set_combine(sets.WS, {})

	-- Ranged WS
	sets.WS["Hot Shot"] = set_combine(sets.WS, sets.WS.RA, {})
	sets.WS["Split Shot"] = set_combine(sets.WS, sets.WS.RA, {})
	sets.WS["Sniper Shot"] = set_combine(sets.WS, sets.WS.RA, { -- MAX ACC for skillchaining
	    head=gear.chasseurHeadPlusThree,
		body=gear.chasseurBodyPlusThree,
		hands=gear.chasseurHandsPlusThree,
		legs=gear.chasseurLegsPlusThree,
		feet = gear.ikengaFeet,
		neck=gear.iskur,
		waist = gear.tellenBelt,
		left_ear=gear.telos,
		right_ear=gear.crepuscularEar,
		left_ring=gear.crepuscularRing,
		right_ring=gear.karieyh,
		back = gear.corWSDDt,
	})
	sets.WS["Numbing Shot"] = set_combine(sets.WS, sets.WS.RA, {})
	sets.WS["Slug Shot"] = set_combine(sets.WS, sets.WS.RA, {
		
	})

	sets.WS["Last Stand"] = set_combine(sets.WS, sets.WS.RA, {

	})

	sets.WS["Wildfire"] = set_combine(sets.WS.MAB, {

	})

	sets.WS["Leaden Salute"] = set_combine(sets.WS.MAB, {
		head=gear.pixieHead,
		right_ring=gear.archonRing,
		right_ear = gear.moonshadeEarringAcc,
		waist=gear.svelt,   -- Changes based off elemental function
	})

	sets.TreasureHunter = {
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
	if spell.english == 'Fold' and buffactive['Bust'] == 2 then
		equipSet = set_combine(equipSet, sets.Fold)
    end
	equipSet = Job_Mode_Check(equipSet)
	return equipSet
end
-- Augment basic equipment sets
function midcast_custom(spell)
	local equipSet = {}
	if spell.english == 'Fold' and buffactive['Bust'] == 2 then
		equipSet = set_combine(equipSet, sets.Fold)
    end
	equipSet = Job_Mode_Check(equipSet)
	return equipSet
end
-- Augment basic equipment sets
function aftercast_custom(spell)
	local equipSet = Job_Mode_Check({})
	return equipSet
end
--Function is called when the player gains or loses a buff
function buff_change_custom(name,gain)
	local equipSet = Job_Mode_Check({})
	return equipSet
end
--This function is called when a update request the correct equipment set
function choose_set_custom()
	local equipSet = Job_Mode_Check({})
	return equipSet
end
--Function is called when the player changes states
function status_change_custom(new,old)
	local equipSet = Job_Mode_Check({})
	return equipSet
end

--Function is called when a self command is issued
function self_command_custom(command)
end

function user_file_unload()
	--send_command('lua u autocor')
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
	return buff
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
