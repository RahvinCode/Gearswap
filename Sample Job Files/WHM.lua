

-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The in-game equip set used for lockstyle, and the macro book and set to switch to on load.
LockStylePallet = "2"
MacroBook = "11"
MacroSet = "1"

-- The food item "gs c food" uses.
Food = "Miso Ramen"

-- Use a Remedy on paralysis or silence, and a Holy Water on doom, automatically.
AutoItem = false

-- Pick a random lockstyle from Lockstyle_List each time this file loads.
Random_Lockstyle = false

-- The equip sets the random lockstyle picks from.
Lockstyle_List = {1,2,6,12}

-- The offense modes this file offers, and the one to start in. The engine's defaults are TP, ACC and DT.
-- Every mode offered here needs both a sets.OffenseMode.<Mode> entry and a sets.Idle.<Mode> entry. The engine warns in chat each time it looks for a missing one.
state.OffenseMode:options('TP','ACC','DT','PDT','MEVA')
state.OffenseMode:set('DT')

-- Not read by this engine.
Organizer = false

-- The weapon modes, each naming a sets.Weapons entry below, and the one to start in.
state.WeaponMode:options('Seraph Strike','Black Halo','Asclepius','Mpaca')
state.WeaponMode:set('Mpaca')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

-- Balance 2100 HP / 1500 MP
function get_sets()

	-- One weapon set per weapon mode, keyed by the mode's name.
	sets.Weapons = {}

	sets.Weapons['Seraph Strike'] = {
		main=gear.daybreak,
	}

	sets.Weapons['Black Halo'] = {
		main=gear.maxentius,
		sub=gear.cathPalugHammer,
	}

	sets.Weapons['Asclepius'] = {
		main=gear.asclepius,
	}

	-- Worn in the offhand, idle or engaged, whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons['Shield'] = {
		sub=gear.genmeiShield,
	}

	-- Worn over the idle set when you are put to sleep, and held until the sleep ends. A piece that drains HP wakes you on its first tick.
	sets.Weapons['Sleep'] ={
		main=gear.lorgMor,
	}

	-- Merged whole over a Cure, Curaga or Cura cast on Lightsday or in Light weather. Its main and sub are worn unless the weapon lock holds them.
	-- When this set is empty, the engine puts Chatoyant Staff in main alone, if you carry one.
	-- Without a Chatoyant Staff, remove main and sub from this set. The game refuses its grip beside a one-handed main.
	sets.Weapons['Light Bonus'] = {
		main=gear.chatoyantStaff,
		sub=gear.enki,
		left_ring=gear.murky,
		right_ring = gear.gelatinousPlusOne,
		right_ear = gear.tuisto,
		waist=gear.hachirinNoObi,
	}

	sets.Weapons['Mpaca'] = {
		main=gear.mpacaStaff,
		sub=gear.enki,
	}

	-- Worn while idle. It is also the floor under every precast and midcast, so a slot an action's set leaves out keeps its idle piece.
	sets.Idle = {
		ammo=gear.staunchPlusOne,
		head = gear.bunziHead,
		body=gear.ebersBodyPlusThree,
		hands = gear.bunziHands,
		legs=gear.ebersLegsPlusThree,
		feet = gear.chironicSlippersRefresh, -- +2 Refresh
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
		left_ear = gear.alabaster,
		right_ear = gear.etiolation, -- 1
		left_ring = gear.stikiniRingPlusOne1, -- +1 Refresh
		right_ring = gear.stikiniRingPlusOne2, -- +1 Refresh
		back = gear.whmFC,
    }

	-- Idle sets per offense mode, merged over sets.Idle in the matching mode. sets.Idle.Resting is merged while you rest.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {
		body = gear.adamantiteArmor,
		waist = gear.platinumMoogleBelt,
		right_ear=gear.heartyEarring,
	})
	sets.Idle.PDT = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle.DT, {
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
	})
	-- Merged over the idle set while Sublimation is charging.
	sets.Idle.Sublimation = set_combine(sets.Idle, {
	    waist=gear.embla, -- +3 Submlimation when active
	})
	sets.Idle.Resting = set_combine(sets.Idle, {})

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
		feet=gear.heraldGaiters,
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

	-- The engaged base, worn in every offense mode. The set named for the current mode is merged over it, and the mode sets below start from a copy of it.
	sets.OffenseMode = {
		ammo=gear.hastyPinionPlusOne,
		head=gear.bunziHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.unmovingPlusOne,
		waist=gear.grunfeldRope,
		left_ear=gear.crepuscularEar,
		right_ear=gear.telos,
		left_ring=gear.lehkoHabhokaRing,
		right_ring = gear.chirichPlusOne2,
		back = gear.whmDA,
	}

	sets.OffenseMode.TP = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.DT = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.PDT = set_combine(sets.OffenseMode, { })
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, { })

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	sets.Precast = {}

	-- Worn at the start of every spell. Fast cast gear goes here, and fast cast caps at 80%.
	sets.Precast.FastCast = {
		main=gear.asclepius,
		ammo=gear.impatiens, -- Quick Cast 2%
		head=gear.ebersHeadPlusThree, -- FC 13%
		body=gear.pingaBodyPlusOne, -- FC 15%
		hands = gear.gendewithaGagesPlusOneBCureFC, -- FC 7%
		legs=gear.pingaLegsPlusOne, -- FC 13%
		feet=gear.volteGaiters, -- FC 6%
		neck = gear.clericTorquePlusTwo,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.alabaster,
		right_ear = gear.etiolation,  -- FC 1%
		left_ring=gear.lehkoHabhokaRing,
		right_ring=gear.weatherspoon, -- FC 5%
		back = gear.whmFC, -- FC 10%
	} -- 80% FC 25% Haste 3k+ HP

	-- Merged over the fast cast set for cures.
	-- 3k HP, 80% Cast Speed, 25% gear haste
	sets.Precast.Cure = set_combine(sets.Precast.FastCast, { })

	-- Merged over the fast cast set for enhancing magic.
	sets.Precast.Enhancing = set_combine(sets.Precast.FastCast, { })

	-- Merged over the fast cast set for Raise, Reraise, Arise, Esuna, Sacrifice and the -na spells.
	sets.Precast.Healing = set_combine(sets.Precast.FastCast, { })

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, sets.Idle.DT, { })

	-- Spell interruption rate down. Merged under every midcast except a ranged attack, so any specific set overwrites it.
	sets.Midcast.SIRD = {}

	-- Single-target cures, Cure through Cure VI.
	sets.Midcast.Cure = {
		main = gear.asclepius,
		sub=gear.ammurapi,
		ammo=gear.staunchPlusOne,
		head=gear.ebersHeadPlusThree,
		body=gear.ebersBodyPlusThree,
		hands=gear.theophanyHandsPlusFour,
		legs=gear.ebersLegsPlusThree,
		feet=gear.pietyFeetPlusFour,
		neck = gear.clericTorquePlusTwo,
		waist = gear.platinumMoogleBelt,
		left_ear=gear.alabaster,
		right_ear = gear.ebersEarringPlusOneMacc,
		left_ring=gear.lebecheRing,
		right_ring=gear.najiLoop,
		back = gear.whmFC,
    }

	-- Worn on Cure through Cure VI while Afflatus Solace is up. Uncomment it to use it.
	-- Ebers Bliaut and Alaunus's Cape raise the Stoneskin that Solace grants from the HP each cure restores.
	-- It is for Cure only. Curaga and Cura below are copies of the Cure set and do not carry it, and Solace's bonus comes from Cure.
	-- sets.Midcast.Cure['Afflatus Solace'] = {}

	-- Curaga, the Cure set with these slots changed.
	sets.Midcast.Curaga = set_combine(sets.Midcast.Cure, { body=gear.theophanyBodyPlusFour,})

	-- Cura, the Cure set with these slots changed.
	sets.Midcast.Cura = set_combine(sets.Midcast.Cure, {
		main = gear.asclepius, body=gear.theophanyBodyPlusFour,
	})

	-- Enhancing magic, where duration gear goes. Cursna and the healing spells with no set of their own, such as Raise, use it too.
	-- sets.Midcast.Enhancing.Others is merged over it when the target is not you, or when Accession is up.
	sets.Midcast.Enhancing = {
		main = gear.asclepius,
		sub=gear.ammurapi,
		ammo=gear.staunchPlusOne,
		head = gear.telchineCapRegen,
		body = gear.telchineChasubleRegen,
		hands = gear.telchineGlovesRegen,
		legs = gear.telchineBraconiRegen,
		feet=gear.theophanyFeetPlusFour,
		neck=gear.unmovingPlusOne,
		waist=gear.embla,
		left_ear=gear.alabaster,
		right_ear=gear.odnowaPlusOne,
		left_ring=gear.murky,
		right_ring=gear.defending,
		back = gear.whmFC,
	}
	sets.Midcast.Enhancing.Others = set_combine(sets.Midcast.Enhancing, {});

	-- Status bar-spells, merged over the enhancing set. Enhancing skill caps at 500 for bar-spells.
	--'Barsleepra','Barpoisonra','Barparalyzra','Barblindra','Barvira','Barpetra','Baramnesra','Barsilencera','Barsleep','Barpoison','Barparalyze','Barblind','Barvirus','Barpetrify','Baramnesia','Barsilence'
	sets.Midcast.Enhancing.Status = set_combine(sets.Midcast.Enhancing, {
		ammo=gear.staunchPlusOne,
		head=gear.ebersHeadPlusThree,
		body=gear.ebersBodyPlusThree,
		hands=gear.ebersHandsPlusThree,
		legs = gear.pietyLegsPlusFour,
		feet=gear.ebersFeetPlusThree,
		left_ear=gear.alabaster,
		right_ear=gear.ebersEarringPlusOne,
		left_ring=gear.murky,
	})

	-- Elemental bar-spells, merged over the enhancing set. This is the status bar-spell set with these slots changed.
	--'Barfire','Barblizzard','Baraero','Barstone','Barthunder','Barwater','Barfira','Barblizzara','Baraera','Barstonra','Barthundra','Barwatera'
	sets.Midcast.Enhancing.Elemental = set_combine(sets.Midcast.Enhancing.Status, {
		main=gear.beneficus,
	})

	-- Skill-based enhancing spells, merged over the enhancing set. Enhancing skill caps at 500 for Gain spells.
	--'Temper','Temper II','Enaero','Enstone','Enthunder','Enwater','Enfire','Enblizzard','Boost-STR','Boost-DEX','Boost-VIT','Boost-AGI','Boost-INT','Boost-MND','Boost-CHR'
	sets.Midcast.Enhancing.Skill = set_combine(sets.Midcast.Enhancing, { })

	-- Enfeebling magic, where magic accuracy decides whether the spell lands. The set below that lists the spell is merged over it.
	sets.Midcast.Enfeebling = {
		main = gear.asclepius,
		sub=gear.ammurapi,
		ammo=gear.pemphredoTathlum,
		head=gear.theophanyHeadPlusFour,
		body=gear.theophanyBodyPlusFour,
		hands=gear.theophanyHandsPlusFour,
		legs = gear.chironicHoseNukeB,
		feet=gear.theophanyFeetPlusFour,
		neck=gear.nullLoop,
		waist=gear.obstinateSash,
		left_ear=gear.alabaster,
		right_ear = gear.ebersEarringPlusOneMacc,
		left_ring=gear.stikiniRingPlusOne,
		right_ring=gear.stikiniRingPlusOne,
		back=gear.nullShawl,
	}

	-- Accuracy based ('Dispel','Aspir','Aspir II','Aspir III','Drain','Drain II','Drain III','Frazzle','Frazzle II','Stun','Poison','Poison II','Poisonga')
	sets.Midcast.Enfeebling.MACC = set_combine(sets.Midcast.Enfeebling, {})

	-- Potency based ('Paralyze','Paralyze II','Slow','Slow II','Addle','Addle II','Distract','Distract II','Distract III','Frazzle III','Blind','Blind II','Gravity','Gravity II')
	sets.Midcast.Enfeebling.Potency = set_combine(sets.Midcast.Enfeebling, { })

	-- Duration based ('Sleep','Sleep II','Sleepga','Sleepga II','Diaga','Dia','Dia II','Dia III','Bio','Bio II','Bio III','Silence','Inundation','Break','Breakga','Bind','Bindga')
	sets.Midcast.Enfeebling.Duration = set_combine(sets.Midcast.Enfeebling, { 
		left_ring=gear.kishar,
		hands=gear.regalCuffs,
	})

	sets.Midcast.Phalanx = set_combine(sets.Midcast.Enhancing.Skill, { })
	sets.Midcast.Dark = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Dark.MACC = set_combine(sets.Midcast.Enfeebling.MACC, {})
	sets.Midcast.Dark.Absorb = set_combine(sets.Midcast.Enfeebling, {})

	-- Cursna, merged over the enhancing set.
	sets.Midcast["Cursna"] = {
		main=gear.yagrush,
		sub=gear.ammurapi,
		ammo=gear.staunchPlusOne,
		head = gear.vanyaHeadPathD,
		body=gear.ebersBodyPlusThree,
		hands = gear.fanaticGlovesFC,
		legs=gear.theophanyLegsPlusThree,
		feet = gear.gendewithaGaloshesPlusOneBCureFC,
		neck=gear.debilis,
		waist=gear.platinumMoogleBelt,
		left_ear=gear.alabaster,
		right_ear = gear.ebersEarringPlusOneMacc,
		left_ring=gear.haomaRing,
		right_ring=gear.menelausRing,
		back = gear.whmFC,
	}

	-- Status-removal spells with sets of their own. Each set replaces the enhancing set for its spell.
	sets.Midcast["Erase"] = set_combine(sets.Midcast, {
		main=gear.yagrush,
		neck = gear.clericTorquePlusTwo,
	})

	sets.Midcast["Esuna"] = set_combine(sets.Midcast, {
		main=gear.asclepius,
	})

	sets.Midcast["Silena"] = set_combine(sets.Midcast, {
		hands=gear.ebersHandsPlusThree,
		main=gear.yagrush
	})

	sets.Midcast["Poisona"] = set_combine(sets.Midcast, {
		hands=gear.ebersHandsPlusThree,
		main=gear.yagrush
	})

	sets.Midcast["Paralyna"] = set_combine(sets.Midcast, {
		hands=gear.ebersHandsPlusThree,
		main=gear.yagrush
	})

	sets.Midcast["Stona"] = set_combine(sets.Midcast, {
		hands=gear.ebersHandsPlusThree,
		main=gear.yagrush
	})

	sets.Midcast["Blindna"] = set_combine(sets.Midcast, {
		hands=gear.ebersHandsPlusThree,
		main=gear.yagrush
	})

	sets.Midcast["Viruna"] = set_combine(sets.Midcast, {
		hands=gear.ebersHandsPlusThree,
		main=gear.yagrush
	})

	-- Buff sets for Divine Caress, worn while it is up on the status-removal spells above. Each of those spells has a set of its own, so the buff set sits under each one.
	-- Ebers Mitts and Mending Cape strengthen the resistance Divine Caress grants against the ailment a -na spell removes.
	-- The spells share one table, so fill it once. To use it, uncomment the table line and the line for each spell you want.
	-- local divine_caress = {}
	-- sets.Midcast["Cursna"]['Divine Caress'] = divine_caress
	-- sets.Midcast["Erase"]['Divine Caress'] = divine_caress
	-- sets.Midcast["Esuna"]['Divine Caress'] = divine_caress
	-- sets.Midcast["Silena"]['Divine Caress'] = divine_caress
	-- sets.Midcast["Poisona"]['Divine Caress'] = divine_caress
	-- sets.Midcast["Paralyna"]['Divine Caress'] = divine_caress
	-- sets.Midcast["Stona"]['Divine Caress'] = divine_caress
	-- sets.Midcast["Blindna"]['Divine Caress'] = divine_caress
	-- sets.Midcast["Viruna"]['Divine Caress'] = divine_caress

	-- Enhancing spells with sets of their own, each a copy of the enhancing set with these slots changed.
	sets.Midcast["Auspice"] = set_combine(sets.Midcast.Enhancing, {
		feet=gear.ebersFeetPlusThree,
	})

	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, {
		main=gear.vadoseRod,
		sub=gear.ammurapi,
		ammo=gear.impatiens,
		head = gear.chironicHatFC,
		body=gear.adamantiteArmor,
		hands=gear.regalCuffs,
		legs=gear.shedirSeraweels,
		feet=gear.theophanyFeetPlusFour,
		neck=gear.loricatePlusOne,
		waist=gear.platinumMoogleBelt,
		left_ear=gear.alabaster,
		right_ear = gear.ebersEarringPlusOneMacc,
		left_ring=gear.murky,
		right_ring=gear.defending,
		back = gear.whmFC,
	})

	-- Merged over the enhancing set for Regen spells.
	sets.Midcast.Regen = {
		main=gear.bolelabunga,
		sub=gear.ammurapi,
		ammo=gear.staunchPlusOne,
		head=gear.inyangaHeadPlusTwo,
		body=gear.pietyBodyPlusFour,
		hands=gear.ebersHandsPlusThree,
		legs=gear.theophanyLegsPlusThree,
		feet=gear.bunziFeet,
		neck=gear.unmovingPlusOne,
		waist=gear.embla,
		left_ear=gear.alabaster,
		right_ear=gear.etiolation,
		left_ring=gear.murky,
		right_ring=gear.defending,
		back = gear.whmFC,
	}

	-- A set named for one spell replaces its family set for that spell, so Stoneskin skips the enhancing set. Cures are the exception and always take the Cure, Curaga or Cura set.
	sets.Midcast["Stoneskin"] = {
		main = gear.asclepius,
		sub=gear.genmeiShield,
		ammo=gear.staunchPlusOne,
		head=gear.nullMasque,
		body=gear.adamantiteArmor,
		hands=gear.ebersHandsPlusThree,
		legs=gear.shedirSeraweels,
		feet=gear.ebersFeetPlusThree,
		neck=gear.nodens,
		waist=gear.siegel,
		left_ear=gear.alabaster,
		right_ear=gear.earthcryEarring,
		left_ring=gear.stikiniRingPlusOne,
		right_ring=gear.stikiniRingPlusOne,
		back = gear.whmFC,
	}

	sets.Midcast.Refresh = {}

	-- Job abilities. sets.JA is the base for every job ability, and a set named for the ability is merged over it.
	sets.JA = {}
	sets.JA["Benediction"] = {
		body = gear.pietyBodyPlusFour,
	}
	sets.JA["Divine Seal"] = {}
	sets.JA["Convert"] = {}
	sets.JA["Devotion"] = {
		head = gear.pietyHeadPlusFour,
	}
	sets.JA["Afflatus Solace"] = {}
	sets.JA["Afflatus Misery"] = {}
	sets.JA["Sacrosanctity"] = {}
	sets.JA["Asylum"] = {}

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- The base for every weaponskill. A set named for the weaponskill is merged over it.
	sets.WS = {
	    ammo=gear.oshashaTreatise,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck=gear.fotiaNeck,
		waist=gear.fotiaWaist,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.ishvara,
		left_ring=gear.ilabrat,
		right_ring=gear.epimanondas,
		back = gear.whmDA,
	}

	-- Worn on weaponskills in ACC mode, merged after the set named for the weaponskill so its slots win. It is skipped where sets.WS['<name>'].ACC exists.
	sets.WS.ACC = {}

	-- Treasure Hunter gear. In every TH mode but None, it is worn on the action that tags a monster and while engaged on an untagged one.
	-- Full Time also wears it whenever you are engaged. Every job but Thief starts in None.
	sets.TreasureHunter = {}

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
	-- A chat reminder after every action while neither Afflatus Solace nor Afflatus Misery is up.
	if not buffactive['Afflatus Solace'] and not buffactive['Afflatus Misery'] then
		add_to_chat(8,'You are not in a stance')
	end
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
