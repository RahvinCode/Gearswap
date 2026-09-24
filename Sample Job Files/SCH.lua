-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The in-game equip set used for lockstyle, and the macro book and set to switch to on load.
LockStylePallet = "13"
MacroBook = "19"
MacroSet = "1"

-- Use a Remedy on paralysis or silence, and a Holy Water on doom, automatically.
AutoItem = false

-- Pick a random lockstyle from Lockstyle_List each time this file loads.
Random_Lockstyle = false

-- The equip sets the random lockstyle picks from.
Lockstyle_List = { 1, 2, 6, 12 }

-- The food item "gs c food" uses.
Food = "Tropical Crepe"

-- The offense modes this file offers, and the one to start in. The engine's defaults are TP, ACC and DT.
-- Every mode offered here needs both a sets.OffenseMode.<Mode> entry and a sets.Idle.<Mode> entry. The engine warns in chat each time it looks for a missing one.
state.OffenseMode:options('TP', 'ACC', 'DT', 'PDT', 'MEVA')
state.OffenseMode:set('DT')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup(LockStylePallet, MacroBook, MacroSet)

-- The weapon modes, each naming a sets.Weapons entry below, and the one to start in.
state.WeaponMode:options('Musa', 'Mpaca')
state.WeaponMode:set('Mpaca')

function get_sets()
	-- One weapon set per weapon mode, keyed by the mode's name.
	sets.Weapons = {}

	sets.Weapons['Musa'] = {
		main = gear.musa,
		sub = gear.enki,
	}

	sets.Weapons['Mpaca'] = {
		main = gear.mpacaStaff,
		sub = gear.enki,
	}

	-- Worn in the offhand, idle or engaged, whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons.Shield = {
		sub = gear.genmeiShield,
	}

	-- Worn over the idle set when you are put to sleep, and held until the sleep ends. A piece that drains HP wakes you on its first tick.
	sets.Weapons.Sleep = {
		main = gear.opashoro,
	}

	-- Worn while idle. It is also the floor under every precast and midcast, so a slot an action's set leaves out keeps its idle piece.
	sets.Idle = { -- HP:2151 MP:1493
		ammo = gear.staunchPlusOne,    -- 3/3
		head = gear.arbatelHeadPlusThree, -- 10/10
		body = gear.arbatelBodyPlusThree, -- 12/12 -- +3 Refresh
		hands = gear.nyameHands,       -- 7/7
		legs = gear.arbatelLegsPlusThree, -- 12/12
		feet = gear.chironicSlippersRefresh, -- +2 Refresh
		neck = gear.loricatePlusOne,   -- 6/6
		waist = gear.carriers,
		left_ear = gear.lugalbanda,
		right_ear = gear.etiolation,     -- 0/3
		left_ring = gear.stikiniRingPlusOne1, -- +1 Refresh
		right_ring = gear.stikiniRingPlusOne2, -- +1 Refresh
		back = gear.schFCDt,             -- 5/5
	}                                    -- 57 PDT / 58 MDT

	-- Idle sets per offense mode, merged over sets.Idle in the matching mode. sets.Idle.Resting is merged while you rest.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDT = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
	})

	-- Merged over the idle set while Sublimation is charging.
	sets.Idle.Sublimation = set_combine(sets.Idle, {
		head = gear.academicHeadPlusThree, -- +4 Submlimation when active
		right_ring = gear.defending,
		waist = gear.embla,        -- +3 Submlimation when active
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
		feet = gear.heraldGaiters
	}

	-- Each is worn when another character on this machine, also running this engine, starts that spell or waltz on you. Spell Received mode must be ON.
	-- sets.Cursna_Received is also the doom set. With Spell Received OFF, it is worn and held while you are doomed.
	sets.Cure_Received = {}
	sets.Cursna_Received = {
		neck = gear.nicander,
		left_ring = gear.eshmun1,
		right_ring = gear.eshmun2,
		waist = gear.gishdubar,
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
		neck = gear.nicander,
	}

	-- The engaged base, worn in every offense mode. The set named for the current mode is merged over it, and the mode sets below start from a copy of it.
	sets.OffenseMode = {
		ammo = gear.staunchPlusOne,
		head = gear.arbatelHeadPlusThree,
		body = gear.arbatelBodyPlusThree,
		hands = gear.nyameHands,
		legs = gear.arbatelLegsPlusThree,
		feet = gear.nyameFeet,
		neck = gear.loricatePlusOne,
		waist = gear.grunfeldRope,
		left_ear = gear.crepuscularEar,
		right_ear = gear.telos,
		left_ring = gear.chirichRingPlusOne,
		right_ring = gear.chirichRingPlusOne,
		back = gear.schFCDt,
	}

	sets.OffenseMode.TP = set_combine(sets.OffenseMode, {})
	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {})
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {})
	sets.OffenseMode.PDT = set_combine(sets.OffenseMode, {})
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, {})

	-- Merged over the engaged set while the Dual Wield trait is active.
	sets.DualWield = {}

	-- The precast base for spells and ranged attacks. Only HP, MP and fast cast matter here.
	sets.Precast = {}

	-- Worn at the start of every spell. Fast cast gear goes here.
	sets.Precast.FastCast = {
		-- 10 FC from Musa staff
		main = gear.musa,
		sub = gear.clerisyStrapPlusOne,
		ammo = gear.impatiens,              -- Quick Magic
		head = gear.pedagogyMortarboardPlusThree, -- 13% Grimoire, 6% Haste
		body = gear.pingaBodyPlusOne,       -- 15% FC, Haste
		hands = gear.academicHandsPlusThree, -- 9% FC, 3% Haste
		legs = gear.pingaLegsPlusOne,       -- 13% FC, 5% Haste
		feet = gear.academicFeetPlusThree,  -- 12% Grimoire, 3% Haste
		neck = gear.voltsurge,              -- 4% FC
		waist = gear.witful,                -- 3% FC and 3 Quick Magic
		left_ear = gear.malignanceEar,      -- 4% FC
		right_ear = gear.etiolation,        -- 1% FC
		left_ring = gear.weatherspoon,      -- 5% FC 3 Quick Magic
		right_ring = gear.lebecheRing,      -- 2 Quick Magic
		back = gear.schFCDt,                -- 10% FC
	}                                       -- 80 Fastcast, and 25% Grimoire all in one

	-- Merged over the fast cast set for enhancing magic.
	sets.Precast.Enhancing = set_combine(sets.Precast.FastCast, {})

	-- Merged over the fast cast set for cures.
	sets.Precast.Cure = set_combine(sets.Precast.FastCast, {})

	-- Merged over the fast cast set for Raise, Reraise, Arise, Esuna, Sacrifice and the -na spells.
	sets.Precast.Healing = set_combine(sets.Precast.FastCast, {})

	-- Grimoire fast cast swaps, worn through precast_custom below on white magic under Light Arts or Addendum: White,
	-- and on black magic under Dark Arts or Addendum: Black. With them, fast cast should total over 80%.
	sets.Precast.Grimoire = {}

	-- Job abilities and stratagems. sets.JA is the base for all of them, and a set named for the ability is merged over it.
	sets.JA = {}
	sets.JA["Light Arts"] = {}
	sets.JA["Penury"] = {}
	sets.JA["Celerity"] = {}
	sets.JA["Rapture"] = {}
	sets.JA["Accession"] = {}
	sets.JA["Perpetuance"] = {}
	sets.JA["Addendum: White"] = {}

	sets.JA["Dark Arts"] = {}
	sets.JA["Parsimony"] = {}
	sets.JA["Alacrity"] = {}
	sets.JA["Ebullience"] = {}
	sets.JA["Manifestation"] = {}
	sets.JA["Focalization"] = {}
	sets.JA["Immanence"] = {}
	sets.JA["Addendum: Black"] = {}

	sets.JA["Sublimation"] = {}
	sets.JA["Tabula Rasa"] = { legs = gear.pedagogyLegsPlusThree }
	sets.JA["Modus Veritas"] = {}
	sets.JA["Libra"] = {}
	sets.JA["Caper Emissarius"] = {}

	sets.JA["Convert"] = {}

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {})

	-- Single-target cures, Cure through Cure VI.
	sets.Midcast.Cure = {
		main = gear.musa,
		sub = gear.enki,
		ammo = gear.hastyPinionPlusOne,
		head = gear.arbatelHeadPlusThree,
		body = gear.kaykausBodyPlusOnePathD,
		hands = gear.kaykausHandsPlusOnePathB,
		legs = gear.kaykausLegsPlusOnePathB,
		feet = gear.kaykausFeetPlusOnePathB,
		neck = gear.nodens,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.mendicantEarring,
		left_ring = gear.najiLoop,
		right_ring = gear.defending,
		back = gear.schFCDt,
	}

	-- Cursna, merged over the enhancing set. This one is the Cure set with these slots changed.
	sets.Midcast.Cursna = set_combine(sets.Midcast.Cure, {
		body = gear.pedagogyBodyPlusThree,
		legs = gear.academicLegsPlusThree,
		feet = gear.gendewithaGaloshesPlusOne,
		neck = gear.debilis,
		left_ring = gear.menelausRing,
		right_ring = gear.haomaRing,
	})

	-- Enhancing magic. Healing spells other than cures, such as Raise and the -na spells, use it too.
	sets.Midcast.Enhancing = {
		main = gear.musa,
		sub = gear.enki,
		ammo = gear.psilomene,
		head = gear.telchineCapRegen,
		body = gear.pedagogyBodyPlusThree,
		hands = gear.telchineGlovesRegen,
		legs = gear.telchineBraconiRegen,
		feet = gear.telchinePigachesRegen,
		neck = gear.incanterTorque,
		waist = gear.embla,
		left_ear = gear.mimir,
		right_ear = gear.etiolation,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne3,
		back = gear.schFCDt,
	}

	-- Skill-based enhancing spells, merged over the enhancing set.
	sets.Midcast.Enhancing.Skill = set_combine(sets.Midcast.Enhancing, {})

	-- Merged over the enhancing set when the target is not you, or when Accession is up.
	sets.Midcast.Enhancing.Others = set_combine(sets.Midcast.Enhancing, {})

	-- Elemental bar-spells, merged over the enhancing set.
	sets.Midcast.Enhancing.Elemental = set_combine(sets.Midcast.Enhancing, {})

	-- Merged over the enhancing set for Phalanx, Regen and Refresh spells.
	sets.Midcast.Phalanx = set_combine(sets.Midcast.Enhancing, {})

	sets.Midcast.Regen = set_combine(sets.Midcast.Enhancing, {
		body = gear.telchineChasubleRegen,
		back = gear.bookwormCape,
		head = gear.arbatelHeadPlusThree,
	})

	sets.Midcast.Refresh = set_combine(sets.Midcast.Enhancing, {})

	-- Enfeebling magic, where magic accuracy decides whether the spell lands.
	sets.Midcast.Enfeebling = {
		ammo = gear.ghastlyTathlumPlusOne,
		head = gear.academicHeadPlusThree,
		body = gear.academicBodyPlusThree,
		hands = gear.academicHandsPlusThree,
		legs = gear.arbatelLegsPlusThree,
		feet = gear.academicFeetPlusThree,
		neck = gear.arguteStolePlusTwo,
		waist = gear.obstinateSash,
		left_ear = gear.crepuscularEar,
		right_ear = gear.regalEarring,
		left_ring = gear.stikiniRingPlusOne,
		right_ring = gear.stikiniRingPlusOne,
		back = gear.schNuke,
	}

	-- The accuracy and potency enfeebling sets, merged over it for the spells each lists, and the dark magic sets.
	sets.Midcast.Enfeebling.MACC = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Enfeebling.Potency = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Dark = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Dark.MACC = set_combine(sets.Midcast.Enfeebling.MACC, {})
	sets.Midcast.Dark.Absorb = set_combine(sets.Midcast.Enfeebling, {})

	sets.Midcast["Dispelga"] = set_combine(sets.Midcast.Enfeebling, {
		main = gear.daybreak,
		sub = gear.ammurapi,
	})

	-- Used for Vagary (6k+ nuke no kill)
	sets.Midcast.Vagary = {
		main = gear.chatoyantStaff,
		ammo = gear.hastyPinionPlusOne,
		head = gear.vanyaHeadPathD,
		body = gear.zendikRobe,
		hands = gear.gendewithaGagesPlusOne,
		legs = gear.pingaLegsPlusOne,
		feet = gear.merlinicCrackowsFCB,
		neck = gear.unmovingPlusOne,
		waist = gear.embla,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.etiolation,
		left_ring = gear.weatherspoon,
		right_ring = gear.kishar,
		back = gear.schFCDt,
	}

	-- Elemental magic nukes. A magic burst takes sets.Midcast.Burst instead, and an earth spell also takes sets.Midcast.Nuke.Earth.
	sets.Midcast.Nuke = {
		main = gear.bunzi,
		sub = gear.ammurapi,
		ammo = gear.ghastlyTathlumPlusOne,
		head = gear.pedagogyMortarboardPlusThree,
		body = gear.arbatelBodyPlusThree,
		hands = gear.agwuHands,
		legs = gear.agwuLegs,
		feet = gear.arbatelFeetPlusThree,
		neck = gear.arguteStolePlusTwo,
		waist = gear.acuityBeltPlusOne,
		left_ear = gear.malignanceEar,
		right_ear = gear.regalEarring,
		left_ring = gear.metamorphPlusOne,
		right_ring = gear.freke,
		back = gear.schNuke,
	}

	sets.Midcast.Nuke.Earth = set_combine(sets.Midcast.Nuke, { neck = gear.quanpur, })

	sets.Midcast.Burst = set_combine(sets.Midcast.Nuke, {})

	-- Helix spells, merged after the nuke set. sets.Helix.Dark and sets.Helix.Light are merged over it for the dark and light helixes.
	sets.Helix = set_combine(sets.Midcast.Nuke, {
		ammo = gear.ghastlyTathlumPlusOne,
		head = gear.agwuHead,
		body = gear.agwuBody,
		hands = gear.agwuHands,
		legs = gear.agwuLegs,
		feet = gear.arbatelFeetPlusThree,
		neck = gear.arguteStolePlusTwo,
		waist = gear.acuityBeltPlusOne,
		left_ear = gear.malignanceEar,
		right_ear = gear.regalEarring,
		left_ring = gear.metamorphPlusOne,
		right_ring = gear.freke,
		back = gear.schNuke,
	})

	sets.Helix.Dark = set_combine(sets.Helix, {
		head = gear.pixieHead,
		left_ring = gear.archonRing,
	})

	sets.Helix.Light = set_combine(sets.Helix, {
		main = gear.daybreak,
		left_ring = gear.weatherspoon
	})

	-- A set named for one spell replaces its family set for that spell, so Stoneskin skips the enhancing set. Cures are the exception and always take the Cure, Curaga or Cura set.
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		ammo = gear.hastyPinionPlusOne,
		head = gear.arbatelHeadPlusThree,
		body = gear.arbatelBodyPlusThree,
		hands = gear.nyameHands,
		legs = gear.arbatelLegsPlusThree,
		feet = gear.nyameFeet,
		waist = gear.siegel,
		left_ring = gear.gelatinousPlusOne,
		right_ring = gear.defending,
		neck = gear.nodens,
		left_ear = gear.earthcryEarring,
	})

	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, {
		head = gear.amalricCoifPlusOne
	})

	sets.Midcast["Klimaform"] = set_combine(sets.Midcast.Enhancing, {})

	sets.Midcast["Impact"] = set_combine(sets.Midcast.Enfeebling, {
		body = gear.crepuscularCloak,
	})

	sets.Midcast["Embrava"] = set_combine(sets.Midcast.Enhancing, {})

	sets.Midcast["Stun"] = set_combine(sets.Midcast.Enfeebling.MACC, {})

	-- Buff sets for the stratagems. Each is worn on every midcast while its buff is up, ranged attacks included, and its slots win over the spell's own sets.
	-- Treasure Hunter gear still takes its slots on an untagged monster. The engine's midcast line names each buff set it merges.
	-- Arbatel Bracers lengthen the duration Perpetuance adds to your next enhancing spell.
	sets.Midcast.Perpetuance = { hands = gear.arbatelHandsPlusThree, }
	-- Arbatel Bracers raise the skillchain bonus of the spell cast under Immanence.
	sets.Midcast.Immanence = { hands = gear.arbatelHandsPlusThree, }
	-- Arbatel Bonnet raises the potency bonus Ebullience gives your next black magic spell.
	sets.Midcast.Ebullience = { head = gear.arbatelHeadPlusThree, }
	-- Arbatel Bonnet raises the potency bonus Rapture gives your next white magic spell.
	sets.Midcast.Rapture = { head = gear.arbatelHeadPlusThree, }
	-- Arbatel Pants strengthen Penury. It ships commented out, so the legs keep their duration gear for spells such as Embrava. Uncomment it to use it.
	-- sets.Midcast.Penury = { legs = gear.arbatelLegsPlusThree, } -- not swapped due to duration
	-- Arbatel Pants strengthen Parsimony.
	sets.Midcast.Parsimony = { legs = gear.arbatelLegsPlusThree, }
	-- Worn on elemental magic while Klimaform is up, through midcast_custom below. Klimaform is also a spell name, so it cannot be a buff set under sets.Midcast.
	sets.Klimaform = { feet = gear.arbatelFeetPlusThree, }
	-- Merged over the enhancing set for the storm spells.
	sets.Storms = { feet = gear.pedagogyFeetPlusThree, }

	-- The base for every weaponskill. A set named for the weaponskill is merged over it.
	sets.WS = {
		ammo = gear.oshashaTreatise,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.sanctity,
		waist = gear.eschan,
		left_ear = gear.crepuscularEar,
		right_ear = gear.telos,
		left_ring = gear.corneliaRing,
		right_ring = gear.epimanondas,
		back = gear.schFCDt,
	}

	-- Treasure Hunter gear. In every TH mode but None, it is worn on the action that tags a monster and while engaged on an untagged one.
	-- Full Time also wears it whenever you are engaged. Every job but Thief starts in None.
	sets.TreasureHunter = {
		ammo = gear.perfectEgg,
		head = gear.volteHead,
		legs = gear.volteHose,
		waist = gear.chaac,
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
function pretarget_custom(spell, action)

end

-- Called at precast. Gear in the returned table is worn over the engine's precast set.
-- Here it adds sets.Precast.Grimoire to white magic under Light Arts or Addendum: White, and to black magic under Dark Arts or Addendum: Black.
function precast_custom(spell)
	local equipSet = {}
	if spell.type == "WhiteMagic" and (buffactive["Light Arts"] or buffactive["Addendum: White"]) then
		log("Grimoire Set (White)")
		equipSet = set_combine(equipSet, sets.Precast.Grimoire)
	elseif spell.type == "BlackMagic" and (buffactive["Dark Arts"] or buffactive["Addendum: Black"]) then
		log("Grimoire Set (Dark)")
		equipSet = set_combine(equipSet, sets.Precast.Grimoire)
	end
	return equipSet
end

-- Called at midcast. Gear in the returned table is worn over the engine's midcast set.
-- Here it adds sets.Klimaform to elemental magic cast under Klimaform.
function midcast_custom(spell)
	local equipSet = {}

	if buffactive["Klimaform"] and spell.skill == 'Elemental Magic' then
		log("Klimaform Set")
		equipSet = set_combine(equipSet, sets.Klimaform)
	end

	return equipSet
end

-- Called when an action ends. Gear in the returned table is worn over the idle or engaged set.
function aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called when you gain or lose a buff, except while your own cast is in progress. Gear in the returned table is worn over the idle or engaged set.
function buff_change_custom(name, gain)
	local equipSet = {}

	return equipSet
end

-- Called whenever the engine builds your idle or engaged set. Gear in the returned table is worn over it.
function choose_set_custom()
	local equipSet = {}

	return equipSet
end

-- Called when your status changes, such as engaging, disengaging or resting. Gear in the returned table is worn over the idle or engaged set.
function status_change_custom(new, old)
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
function pet_change_custom(pet, gain)
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
