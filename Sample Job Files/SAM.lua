

-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The in-game equip set used for lockstyle, and the macro book and set to switch to on load.
LockStylePallet = "4"
MacroBook = "10"
MacroSet = "1"

-- Pick a random lockstyle from Lockstyle_List each time this file loads.
Random_Lockstyle = false

-- The equip sets the random lockstyle picks from.
Lockstyle_List = {1,2,6,12}

-- The food item "gs c food" uses.
Food = "Sublime Sushi"

-- Use a Remedy on paralysis or silence, and a Holy Water on doom, automatically.
AutoItem = false

-- The offense modes this file offers. The engine's defaults are TP, ACC and DT.
-- Every mode offered here needs both a sets.OffenseMode.<Mode> entry and a sets.Idle.<Mode> entry. The engine warns in chat each time it looks for a missing one.
state.OffenseMode:options('TP','ACC','DT','SB','PDL') -- ACC mode changes both the engaged and the weaponskill sets

-- The offense mode to start in.
state.OffenseMode:set('DT')

-- The weapon modes, each naming a sets.Weapons entry below, and the one to start in.
state.WeaponMode:options('Masamune', 'Dojikiri', 'Shining One', 'Yoichinoyumi', 'Soboro')
state.WeaponMode:set('Masamune')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- One weapon set per weapon mode, keyed by the mode's name.

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

	-- Worn in the offhand, idle or engaged, whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons.Shield = {}

	-- The arrow the ranged sets below name.
	Ammo.RA = "Yoichi's Arrow"

	-- Worn while idle. It is also the floor under every precast and midcast, so a slot an action's set leaves out keeps its idle piece.
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

	-- Idle sets per offense mode, merged over sets.Idle in the matching mode. sets.Idle.Resting is merged while you rest.
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

	-- Worn over the idle set while a Phantom Roll on you stands at 11.
	-- It is meant for the Roller's Ring, which every job can wear and which gives Refresh +1 and Regain +10 at an 11, e.g. right_ring="Roller's Ring".
	-- This set applies in every offense mode. sets.Idle.TP.XIRoll applies in TP mode only and is merged after it.
	-- It is worn only while idle, so any action swaps it out and it comes back when the action ends.
	-- While you move, a ring named here replaces the movement set's ring in the same slot. This file's sets.Movement names left_ring, so right_ring is the free slot.
	sets.Idle.XIRoll = {}
	-- The TP mode form of sets.Idle.XIRoll, merged after it.
	sets.Idle.TP.XIRoll = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = {
		left_ring = gear.gelatinousPlusOne,
		feet=gear.danzoSuneAte
    }

	-- Each is worn when another character on this machine, also running this engine, starts that spell or waltz on you. Spell Received mode must be ON.
	-- sets.Cursna_Received is also the doom set. With Spell Received OFF, it is worn and held while you are doomed.
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

	-- The ring slot Zodiac Ring takes on elemental magic that matches the day's element: "right_ring" or "left_ring".
	Elemental_Bonus_Ring_Slot = "right_ring"

	-- Worn when you use a Holy Water or Hallowed Water.
	sets.Holy_Water = {
	    neck=gear.nicander,
	}

	-- Subtle Blow gear. The engine never reads this set by name. It is merged into the SB engaged set and worn as the SB weaponskill set below.
	-- 10 + 19 for Auspice
	sets.Subtle_Blow = {
		body=gear.dagonBreastplate, -- SB II 10
		legs = gear.mpacaLegs, -- SB II 5
		left_ring=gear.niqmaddu, -- SB II 5
		head=gear.kendatsubaHeadPlusOne,  -- 8
		hands=gear.kendatsubaHandsPlusOne, -- 8
		feet=gear.kendatsubaFeetPlusOne, -- 8
		right_ear = gear.schere, -- 3
		right_ring=gear.chirichRingPlusOne, -- 10
		waist=gear.sarissaphoroi, -- 5
		--neck="Bathy Choker +1", -- 11 Not needed if using Pukatrice Eggs
	}

	-- The engaged base, worn in every offense mode. The set named for the current mode is merged over it, and the mode sets below start from a copy of it.
	sets.OffenseMode = {
		ammo = gear.coiste,
		head=gear.kasugaHeadPlusTwo,
		body=gear.kasugaBodyPlusThree,
		hands = gear.mpacaHands,
		legs=gear.kasugaLegsPlusTwo,
		feet = gear.mpacaFeet,
		neck = gear.samuraiNodowaPlusTwo,
		waist=gear.ioskehaBeltPlusOne,
		left_ear = gear.kasugaEarringPlusOneWSD,
		right_ear = gear.schere,
		left_ring=gear.niqmaddu,
		right_ring=gear.chirichRingPlusOne,
		back=gear.nullShawl,
	}

	-- TP mode: the base with these slots changed.
	sets.OffenseMode.TP = set_combine(sets.OffenseMode, {

	})

	-- DT mode: the base with these slots changed.
	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {
		head=gear.kasugaHeadPlusTwo,
		hands=gear.mpacaHands,
	})

	-- ACC mode: the base with these slots changed.
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {

	})

	-- SB mode: the base with the Subtle Blow set over it. Both wear Schere Earring in the right ear, as SB weaponskills do, so no earring changes ear.
	-- Subtle Blow caps at 75 in total, and at 50 for each of SB and SB II.
	sets.OffenseMode.SB = set_combine(sets.OffenseMode, sets.Subtle_Blow, {

	})
	sets.OffenseMode.PDL = set_combine(sets.OffenseMode, {})

	-- Worn over the engaged set in every offense mode while Seigan is up, and its slots win over the mode set.
	-- Kasuga Kabuto adds Counter under Seigan while Third Eye is down. Treasure Hunter gear still takes its slots whenever your TH mode wears it.
	sets.OffenseMode.Seigan = {
	    head=gear.kasugaHeadPlusTwo,
		body=gear.kasugaBodyPlusThree,
	}
	-- Worn while engaged with both Seigan and Third Eye up, merged after the Seigan set. Sakonji Haidate add Counter under Third Eye. Uncomment it to use it.
	-- sets.OffenseMode.Seigan['Third Eye'] = {
		--legs={ name="Sakonji Haidate +3", augments={'Enhances "Shikikoyo" effect',}},
	-- }

	-- The precast base for spells and ranged attacks.
	sets.Precast = {}

	-- Snapshot caps at 70. Rapid Shot works like Quick Magic, and Snapshot works like fast cast.

	-- The True Shot sweet spot, where ranged attacks and weaponskills deal more damage. Monster size changes these distances.
		-- Gun ~6.5 yalms
		-- Short Bow ~8.6 yalms
		-- Crossbow ~10.7 yalms
		-- Long Bow ~ 11.8 yalms

	-- Flurry is 15% Snapshot
	-- Flurry II 30% Snapshot

	-- Ranged attack precast, where snapshot gear goes.
	sets.Precast.RA = set_combine(sets.Precast, {
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
		left_ring = gear.gelatinousPlusOne,
		right_ring=gear.crepuscularRing,
		back = gear.samSnapshot,
    })	

	-- sets.Precast.RA has no per-mode children. Flurry and Flurry_II are the only children it reads.

	-- Merged over the ranged precast while Flurry is up. It needs 55 Snapshot.
	sets.Precast.RA.Flurry = set_combine(sets.Precast.RA, {

	}) 

	-- Merged over the ranged precast while Flurry II or Embrava is up. It needs 40 Snapshot.
	sets.Precast.RA.Flurry_II = set_combine( sets.Precast.RA.Flurry, { 

    })

	-- Worn at the start of every spell. Fast cast gear goes here.
	sets.Precast.FastCast = set_combine (sets.Idle.DT, {
		ammo=gear.sapience,
		hands = gear.leylineGlovesFCB,
		neck=gear.voltsurge,
		waist=gear.tempusFugit,
		left_ear=gear.etiolation,
		right_ear=gear.loquacious,
		left_ring=gear.prolix,
	})

	-- Enmity gear. The engine never reads this set by name. It is worn as the Provoke set below.
	sets.Precast.Enmity = set_combine (sets.Idle.DT, {
	    ammo=gear.sapience, -- 2
		neck=gear.warderCharmPlusOne, -- 1-8 
	    left_ear=gear.friomisi, --2
		right_ear=gear.crypticEarring, -- 4
		waist=gear.kasiriBelt, -- 3
		left_ring=gear.petrov, -- 4
		right_ring=gear.eihwazRing, -- 5
	})

	-- The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this set does not name keeps its idle piece.
	sets.Midcast = set_combine (sets.Idle.DT, { })

	-- Ranged attack midcast. In every offense mode but TP, the set named for the mode is merged over it.
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
		right_ring=gear.crepuscularRing,
		left_ring=gear.ilabrat,
		back = gear.samSTP,
    })

	-- ACC mode, for high accuracy.
    sets.Midcast.RA.ACC = set_combine(sets.Midcast.RA, {

    })

	-- PDL mode, for the physical damage limit.
    sets.Midcast.RA.PDL = set_combine(sets.Midcast.RA, {

    })

	-- CRIT mode, for a critical hit build. Add CRIT to the offense modes above to use it.
    sets.Midcast.RA.CRIT = set_combine(sets.Midcast.RA, {

    })
	
	-- Job abilities. sets.JA is the base for every job ability, and a set named for the ability is merged over it.
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

	-- The base for every weaponskill. A set named for the weaponskill is merged over it.
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
		left_ring=gear.niqmaddu,
		right_ring=gear.epimanondas,
		back = gear.samWSD,
	}

	-- Merged over sets.WS on every ranged weaponskill, in every offense mode, so the weaponskill fires the arrow.
	-- Without it the ammo slot keeps sets.WS's ammo, and the engine cancels a ranged weaponskill unless you carry at least two of what that slot holds.
	sets.WS.RA = { ammo = Ammo.RA }

	-- Weaponskill sets per offense mode, merged after the set named for the weaponskill so their slots win. Never merged in TP mode.
	-- Each names only the slots its mode changes, so a weaponskill's own set keeps every other slot.
	-- A weaponskill's own mode set, such as sets.WS['Tachi: Fudo'].ACC, is used in place of these where it exists.
	sets.WS.ACC = {}

	sets.WS.SB = sets.Subtle_Blow

	-- A building block for magical weaponskills. MAB is not an offense mode, so this set is worn only through the sets built from it.
	sets.WS.MAB = set_combine(sets.WS, {
		waist=gear.orpheusWaist,
		left_ear=gear.friomisi,
		neck=gear.fotiaNeck,
		waist=gear.orpheusWaist,
		left_ear=gear.friomisi,
		-- back={ name="Smertrios's Mantle", augments={'STR+20','Mag. Acc+20 Mag. Dmg.+20','Mag. Acc.+10','"Mag.Atk.Bns."+10','Damage taken-5%',}},
	})

	-- CRIT mode. Add CRIT to the offense modes above to use it.
	sets.WS.CRIT = {
		right_ear = gear.schere,
	    ammo = gear.coiste,
	}

	-- Sets named for one weaponskill, merged over sets.WS.
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
		right_ring=gear.sroda,
		legs = gear.mpacaLegs,
		feet=gear.kasugaFeetPlusTwo,
	})

	-- Buff sets for weaponskills. Uncomment one to use it. Each is worn on every weaponskill while its buff is up, and its slots win over the set named for the weaponskill.
	-- Worn on every weaponskill while Meikyo Shisui is up. Sakonji Sune-Ate strengthen Meikyo Shisui and must be worn for the weaponskill itself.
	-- sets.WS['Meikyo Shisui'] = {}
	-- Worn on the next weaponskill while Sekkanoki is up. With Kasuga Kote, that weaponskill also scales with the TP Sekkanoki leaves you.
	-- sets.WS.Sekkanoki = {}
	-- Worn on the next weaponskill while Sengikori is up. Kasuga Sune-Ate raise the bonus Sengikori gives the skillchain or magic burst that follows.
	-- sets.WS.Sengikori = {}

	-- Treasure Hunter gear. In every TH mode but None, it is worn on the action that tags a monster and while engaged on an untagged one.
	-- Full Time also wears it whenever you are engaged. Every job but Thief starts in None.
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
	-- A common use is switching the macro book or set.
end

-- Called before an action's precast, after the engine's own checks. Call cancel_spell() here to stop the action.
function pretarget_custom(spell,action)

end

-- Called at precast. Gear in the returned table is worn over the engine's precast set.
function precast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called at midcast. Gear in the returned table is worn over the engine's midcast set.
function midcast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called when an action ends. Gear in the returned table is worn over the idle or engaged set.
function aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called when you gain or lose a buff, except while your own cast is in progress. Gear in the returned table is worn over the idle or engaged set.
function buff_change_custom(name,gain)
	local equipSet = {}

	return equipSet
end

-- Called whenever the engine builds your idle or engaged set. Gear in the returned table is worn over it.
function choose_set_custom()
	local equipSet = {}

	return equipSet
end

-- Called when your status changes, such as engaging, disengaging or resting. Gear in the returned table is worn over the idle or engaged set.
function status_change_custom(new,old)
	local equipSet = {}

	return equipSet
end

-- Called for a "gs c" command the engine did not handle, and by the Weapon Mode, Job Mode and Job Mode 2 commands before their gear rebuild. The command arrives in lowercase.
function self_command_custom(command)

end

-- Called when the job file is unloaded.
function user_file_unload()

end

-- Called when a pet is summoned or released. Gear in the returned table is worn over the idle or engaged set.
function pet_change_custom(pet,gain)
	local equipSet = {}
	
	return equipSet
end

-- Called when a pet's action ends. Gear in the returned table is worn over the idle or engaged set.
function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called while a pet's action is in flight. Gear in the returned table is worn over the pet midcast sets.
function pet_midcast_custom(spell)
	local equipSet = {}

	return equipSet
end
