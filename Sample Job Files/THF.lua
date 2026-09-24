

-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The in-game equip set used for lockstyle, and the macro book and set to switch to on load.
LockStylePallet = "5"
MacroBook = "6"
MacroSet = "1"

-- The food item "gs c food" uses.
Food = "Sublime Sushi"

-- Use a Remedy on paralysis or silence, and a Holy Water on doom, automatically.
AutoItem = false

-- Pick a random lockstyle from Lockstyle_List each time this file loads.
Random_Lockstyle = false

-- The equip sets the random lockstyle picks from.
Lockstyle_List = {1,2,6,12}

-- The offense mode to start in. This file offers the engine's default modes, TP, ACC and DT.
state.OffenseMode:set('DT')

-- The weapon modes, each naming a sets.Weapons entry below, and the one to start in.
state.WeaponMode:options('Aeneas','Naegling','Evisceration')
state.WeaponMode:set('Aeneas')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- One weapon set per weapon mode, keyed by the mode's name.
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

	-- Worn in the offhand, idle or engaged, whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons.Shield = {}
	-- Worn over the idle set when you are put to sleep, and held until the sleep ends. A piece that drains HP wakes you on its first tick.
	sets.Weapons.Sleep = {
		sub=gear.mpuGandring,
	}

	-- Worn while idle. It is also the floor under every precast and midcast, so a slot an action's set leaves out keeps its idle piece.
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
	-- Idle sets per offense mode, merged over sets.Idle in the matching mode. sets.Idle.Resting is merged while you rest.
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

	-- Worn over the idle set while a Phantom Roll on you stands at 11.
	-- It is meant for the Roller's Ring, which every job can wear and which gives Refresh +1 and Regain +10 at an 11, e.g. left_ring="Roller's Ring".
	-- This set applies in every offense mode. sets.Idle.TP.XIRoll applies in TP mode only and is merged after it.
	-- It is worn only while idle, so any action swaps it out and it comes back when the action ends.
	-- While you move, a ring named here replaces the movement set's ring in the same slot. This file's sets.Movement names no ring, so either slot is free.
	sets.Idle.XIRoll = {}
	-- The TP mode form of sets.Idle.XIRoll, merged after it.
	sets.Idle.TP.XIRoll = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = {
		feet=gear.fajinBoots,
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

	-- Engaged sets. sets.OffenseMode is the base, and the set named for the current offense mode is merged over it.
	sets.OffenseMode = {}

	-- Worn while engaged in TP mode. The other modes below start from a copy of it.
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

	-- Worn while engaged in DT mode: the TP set with these slots changed.
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

	-- Worn while engaged in ACC mode: the TP set with these slots changed.
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode.TP, {})

	-- Buff sets for the engaged set. Uncomment one to use it. Each is worn over the engaged set in every offense mode while its buff is up, and its slots win over the mode set.
	-- Treasure Hunter gear still takes its slots whenever your TH mode wears it.
	-- Worn while engaged with Trick Attack up. Pillager's Armlets and Plunderer's Vest strengthen Trick Attack while they are worn.
	-- sets.OffenseMode['Trick Attack'] = {}
	-- Worn while engaged with Sneak Attack up. Its hit is a critical hit, so DEX and critical hit damage gear helps it.
	-- sets.OffenseMode['Sneak Attack'] = {}
	-- With both up, both are merged, Trick Attack's last. The nested form sets.OffenseMode['Sneak Attack']['Trick Attack'] holds gear for both at once and merges after them.

	-- Merged over the engaged set while the Dual Wield trait is active. You need only 6 Dual Wield here if you are not getting Haste Samba.
	sets.DualWield = {
	    --left_ear="Eabani Earring",
	    --waist="Reiki Yotai",
	}

	sets.Precast = {}

	-- Worn at the start of every spell. Fast cast gear goes here.
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

	-- Enmity gear. The engine never reads this set, so combine it into a job ability's set to use it.
	sets.Enmity = {
	    ammo=gear.sapience, -- 2
	    left_ear=gear.friomisi, --2
		right_ear=gear.crypticEarring, -- 4
		left_ring=gear.petrov, -- 4
	}

	-- The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {
	
	})
	-- Spell interruption rate down. Merged under every midcast except a ranged attack, so any specific set overwrites it.
	sets.Midcast.SIRD = {}
	sets.Midcast.Cure = {}
	-- Enhancing magic. Healing spells other than cures, such as Raise and the -na spells, use it too.
	sets.Midcast.Enhancing = {}
	-- Enfeebling magic, where magic accuracy decides whether the spell lands.
	sets.Midcast.Enfeebling = {}
	-- A set named for one spell replaces its family set for that spell, so Stoneskin skips the enhancing set. Cures are the exception and always take the Cure, Curaga or Cura set.
	sets.Midcast["Stoneskin"] = {
		waist=gear.siegel,
	}
	-- Job abilities. sets.JA is the base for every job ability, and a set named for the ability is merged over it.
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

	-- Dancer abilities, for the dancer subjob. Each family set is worn for every ability of its kind, and a set named for one ability is merged over it.

	sets.Flourish = set_combine(sets.Idle.DT, {})

	sets.Jig = set_combine(sets.Idle.DT, {})

	sets.Step = set_combine(sets.OffenseMode.DT, {})

	sets.Samba = set_combine(sets.Idle.DT, {})

	-- Waltz potency gear caps at 50%, and Waltz potency received caps at 30%.
	sets.Waltz = set_combine(sets.OffenseMode.DT, {
		ammo=gear.yamarang, -- 5%
		head=gear.malignanceHead,
		body = gear.gletiBody, -- 10%
		hands=gear.slitherGlovesPlusOne, -- 5%
		legs=gear.dashingSubligar, -- 10%
		feet=gear.malignanceFeet,
		neck = gear.loricatePlusOne,
		waist=gear.platinumMoogleBelt,
		left_ear=gear.odnowaPlusOne,
		right_ear = gear.tuisto,
		right_ring=gear.defending,
		left_ring=gear.moonlightRing,
		back = gear.thfDA,
	}) -- 30% Potency

	-- The base for every weaponskill. A set named for the weaponskill is merged over it.
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
	-- Worn on weaponskills in ACC mode, merged after the set named for the weaponskill so its slots win. It is skipped where sets.WS['<name>'].ACC exists.
	sets.WS.ACC = {}

	-- A building block for magical weaponskills. MAB is not an offense mode, so this set is worn only through the sets built from it.
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
	-- Sets named for one weaponskill, merged over sets.WS.
	sets.WS["Wasp Sting"] = {}
	sets.WS["Viper Bite"] = {}
	sets.WS["Shadowstitch"] = {}
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

	-- Buff sets for weaponskills. Uncomment one to use it. Each is worn on every weaponskill while its buff is up, and its slots win over the set named for the weaponskill.
	-- Treasure Hunter gear still takes its slots on an untagged monster.
	-- Worn on every weaponskill while Trick Attack is up. Pillager's Armlets and Plunderer's Vest strengthen Trick Attack while they are worn.
	-- sets.WS['Trick Attack'] = {}
	-- Worn on every weaponskill while Sneak Attack is up. Sneak Attack makes the first hit a critical hit, so DEX and critical hit damage gear helps it.
	-- sets.WS['Sneak Attack'] = {}
	-- With both up, both are merged, Trick Attack's last. The nested form sets.WS['Sneak Attack']['Trick Attack'] holds gear for both at once and merges after them. Declare it below the Sneak Attack set.

	-- Sets for your own hooks. The engine never reads sets.Custom, so use it from the hooks below.
	sets.Custom = {}

	-- Treasure Hunter gear. In every TH mode but None, it is worn on the action that tags a monster and while engaged on an untagged one.
	-- Full Time also wears it whenever you are engaged, and SATA while Sneak Attack, Trick Attack or Feint is up. Thief starts in Full Time.
	sets.TreasureHunter = {
		feet=gear.skulkerFeetPlusThree,
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
