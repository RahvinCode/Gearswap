
-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The in-game lockstyle set, macro book and macro set this file applies on load.
LockStylePallet = "14"
MacroBook = "20"
MacroSet = "1"

-- Use a Remedy for paralysis or silence, and a Holy Water for doom, automatically.
AutoItem = false

-- Pick a random lockstyle from Lockstyle_List on each load, in place of LockStylePallet.
Random_Lockstyle = false

-- The lockstyle sets the random pick chooses from.
Lockstyle_List = {1,2,6,12}

-- The food "gs c food" uses.
Food = "Tropical Crepe"

-- Offense modes, and the one the file starts in. Each mode offered needs its own sets.OffenseMode.<Mode> and sets.Idle.<Mode> below.
state.OffenseMode:options('TP','ACC','DT','PDT','MEVA')
state.OffenseMode:set('DT')

-- Weapon modes. Each name needs a matching sets.Weapons entry.
state.WeaponMode:options('Nuke','Mpaca')
state.WeaponMode:set('Nuke')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	sets.Weapons = {}

	sets.Weapons['Nuke'] ={
		main = gear.mpacaStaff,
		sub=gear.enki,
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons.Shield ={}

	sets.Weapons['Mpaca'] ={
		main = gear.mpacaStaff,
		sub=gear.enki,
	}

	-- Worn whenever you are not engaged. It is also the floor under every action, so a slot an action's sets leave unnamed keeps its idle piece.
	sets.Idle = {
		ammo=gear.staunchPlusOne,
		head=gear.wicceHeadPlusThree, --11
		body=gear.wicceBodyPlusThree,
		hands=gear.wicceHandsPlusThree, --13
		legs=gear.wicceLegsPlusThree,
		feet=gear.wicceFeetPlusThree, --11 (removed while moving)
		neck = gear.loricatePlusOne, --6
		waist=gear.carriers,
		left_ear=gear.lugalbanda,
		right_ear=gear.etiolation,
		left_ring=gear.defending, --10
		right_ring=gear.stikiniRingPlusOne,
		back = gear.blmNuke,
    }

	-- Idle sets for each offense mode, merged over the idle set.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDT = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
	})
	-- Merged over the idle set while Sublimation is charging.
	sets.Idle.Sublimation = set_combine(sets.Idle, {
	    waist=gear.embla, -- +3 Submlimation when active
	})
	sets.Idle.Resting = set_combine(sets.Idle, {})

	-- Worn over the idle set while a Phantom Roll on you stands at 11.
	-- It is meant for Roller's Ring, which every job can wear and which grants Refresh +1 and Regain +10 at an 11, e.g. left_ring="Roller's Ring".
	-- This set applies in every offense mode. The TP set below applies only in TP mode and merges after it.
	-- It is worn only while idle, so any action swaps it out, and it comes back when the action ends.
	-- While you move, a ring named here replaces a movement ring in the same slot. This file's sets.Movement names no ring, so either slot is free.
	sets.Idle.XIRoll = {}
	-- The TP mode version, merged after the one above.
	sets.Idle.TP.XIRoll = {}

	-- Worn over the idle set while Mana Wall is up. Gear that enhances Mana Wall, such as Wicce Sabots +3 (feet) or Taranus's Cape (back), cuts the damage further before Mana Wall takes it from your MP.
	-- Feet named here replace the movement set's feet while you move.
	-- sets.Idle['Mana Wall'] = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = {
		feet=gear.heraldGaiters,
	}

	-- Worn when another character on this machine, running this engine, starts casting one of these spells on you, while Spell Received mode is ON. sets.Cursna_Received is also the Doom set, worn and held while you are doomed with that mode OFF.
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

	-- The ring slot Zodiac Ring goes in when an elemental spell matches the day's element: "right_ring" or "left_ring".
	Elemental_Bonus_Ring_Slot = "right_ring"

	-- Worn when you use a Holy Water or Hallowed Water.
	sets.Holy_Water = {
	    neck=gear.nicander,
	}

	-- Engaged sets. sets.OffenseMode is worn in every offense mode, and the current mode's set merges over it.
	sets.OffenseMode = {}
	sets.OffenseMode.TP = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.DT = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.PDT = set_combine(sets.OffenseMode, { })
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, { })

	-- Worn over the engaged set in every offense mode while Mana Wall is up, for the same Mana Wall gear as the idle one above.
	-- sets.OffenseMode['Mana Wall'] = {}

	sets.Precast = {}

	-- Fast cast, worn at the start of every spell.
	sets.Precast.FastCast = {
		ammo = gear.ghastlyTathlumPlusOne,
		head = gear.merlinicHoodFCB, -- 14
		body = gear.merlinicJubbahFC, -- 13
		hands = gear.merlinicDastanasBFC, -- 7
		legs=gear.agwuLegs, -- 7
		feet = gear.merlinicCrackowsBFC, -- 12
		neck = gear.unmovingPlusOne, 
		waist=gear.embla, -- 5
		left_ear=gear.malignanceEar, -- 4
		right_ear=gear.etiolation, -- 1
		left_ring=gear.weatherspoon, -- 5
		right_ring=gear.kishar, -- 4
		back = gear.blmFC, -- 10
	} -- 80% FC

	-- Merged over the fast-cast set for enhancing magic.
	sets.Precast.Enhancing = set_combine(sets.Precast.FastCast, {})

	sets.Precast["Impact"] = set_combine(sets.Precast.FastCast,{
	    ammo=gear.sapience,
		neck=gear.voltsurge,
		body=gear.twilightCloak,
	})

	-- Job abilities. sets.JA is worn for every job ability, and the set named for the ability merges over it.
	sets.JA = {}
	sets.JA["Manafont"] = {}
	sets.JA["Elemental Seal"] = {}
	sets.JA["Mana Wall"] = {}
	sets.JA["Cascade"] = {}
	sets.JA["Enmity Douse"] = {}
	sets.JA["Manawell"] = {}
	sets.JA["Subtle Sorcery"] = {}

	-- Geomancer abilities a GEO subjob can use.
	sets.JA["Full Circle"] = {}
	sets.JA["Lasting Emanation"] = {}
	sets.JA["Ecliptic Attrition"] = {}
	sets.JA["Collimated Fervor"] = {}

	-- Red Mage ability an RDM subjob can use.
	sets.JA["Convert"] = {}

	--The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {
	
	})

	--Spell interruption rate down. Merged under every midcast except a ranged attack, so any specific set overwrites it.
	sets.Midcast.SIRD = {

	}

	-- Merged over every spell's midcast while Mana Wall is up, so its gear is back on for the cast. No precast set can carry it, so the fast-cast set's pieces are worn at the start of each spell.
	-- sets.Midcast['Mana Wall'] = {}

	sets.Midcast.Cure = {

    }

	-- Enhancing magic, and the base the enhancing sets below copy. Raise, Reraise and the -na spells take it too.
	sets.Midcast.Enhancing = {
		main=gear.daybreak,
		sub=gear.ammurapi,
		ammo = gear.ghastlyTathlumPlusOne,
		head = gear.telchineCapBEnhDur,
		body = gear.telchineChasubleBEnhDur,
		hands = gear.telchineGlovesBRegen,
		legs = gear.telchineBraconiBEnhDur,
		feet = gear.telchinePigachesBEnhDur,
		neck=gear.incanterTorque,
		waist=gear.embla,
		left_ear=gear.mimir,
		right_ear=gear.etiolation,
		left_ring = gear.gelatinousPlusOne,
		right_ring=gear.stikiniRingPlusOne,
		back=gear.perimedeCape,
	}
	-- Merged over the enhancing set: Others when the target is someone else, Status for status bar spells, Skill for skill-based buffs.
	sets.Midcast.Enhancing.Others = set_combine(sets.Midcast.Enhancing, {});
	sets.Midcast.Enhancing.Status = set_combine(sets.Midcast.Enhancing, {});
	sets.Midcast.Enhancing.Skill = set_combine(sets.Midcast.Enhancing, {});

	-- Enfeebling magic, dressed for magic accuracy.
	sets.Midcast.Enfeebling = {
	    main=gear.daybreak,
		sub=gear.ammurapi,
		ammo = gear.ghastlyTathlumPlusOne,
		head=gear.wicceHeadPlusThree,
		body=gear.wicceBodyPlusThree,
		hands=gear.wicceHandsPlusThree,
		legs=gear.wicceLegsPlusThree,
		feet=gear.wicceFeetPlusThree,
		neck=gear.incanterTorque,
		waist=gear.luminarySash,
		left_ear=gear.malignanceEar,
		right_ear=gear.wicceEarringPlusOne,
		left_ring=gear.weatherspoon,
		right_ring=gear.stikiniRingPlusOne,
		back = gear.blmNuke,
	}

	-- Merged over the enfeebling set for the spells the engine's lists name: MACC for accuracy-based spells, Potency for potency-based ones, Duration for duration-based ones.
	sets.Midcast.Enfeebling.MACC = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Enfeebling.Potency = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Enfeebling.Duration = set_combine(sets.Midcast.Enfeebling, {})
	-- Drain and Aspir take their own sets, sets.Midcast.Drain and sets.Midcast.Aspir, ahead of any enfeebling or dark magic set.
	sets.Midcast.Drain = set_combine(sets.Midcast.Enfeebling, {})

	-- Dark magic. MACC, Absorb and Enhancing merge over it for the spells the engine's dark magic lists name.
	sets.Midcast.Dark = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Dark.MACC = set_combine(sets.Midcast.Enfeebling.MACC, {})
	sets.Midcast.Dark.Absorb = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Dark.Enhancing = set_combine(sets.Midcast.Enhancing, {})

	-- Elemental nukes. After this set, the engine may put an obi, sash, cape or Zodiac Ring in the waist, back and ring slots when the day, weather or distance favors one.
	sets.Midcast.Nuke = {
		ammo = gear.ghastlyTathlumPlusOne,
		head=gear.eaHeadPlusOne,
		body=gear.wicceBodyPlusThree,
		hands = gear.agwuHands,
		legs=gear.wicceLegsPlusThree,
		feet = gear.agwuFeet,
		neck = gear.sorcererStolePlusTwo,
		waist = gear.acuityBeltPlusOne,
		left_ear=gear.malignanceEar,
		right_ear=gear.regalEarring,
		left_ring = gear.metamorphPlusOne,
		right_ring=gear.freke,
		back = gear.blmNuke,
	}

	-- Worn in place of the nuke set when the spell lands a magic burst on the last skillchain.
	sets.Midcast.Burst = set_combine(sets.Midcast.Nuke, { })

	-- Merged over the nuke or burst set for earth spells.
	sets.Midcast.Nuke.Earth = {
	    neck=gear.quanpur,
	}

	sets.Midcast['Impact'] = set_combine(sets.Midcast.Nuke, {
		hands=gear.wicceHandsPlusThree,
		legs=gear.wicceLegsPlusThree,
		feet=gear.wicceFeetPlusThree,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
	})

	sets.Midcast.Curaga = sets.Midcast.Cure

	sets.Midcast.Cursna = {}

	-- Not read by the engine. midcast_custom below wears it on an elemental nuke cast below 30% MP.
	sets.MP_Recover = {
	    body=gear.spaekonaBodyPlusThree,
	}

	-- Merged over the enhancing set for elemental bar spells.
	sets.Midcast.Enhancing.Elemental = {}

	-- Sets named for one spell. Each replaces the family set for that spell.
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		right_ring=gear.stikiniRingPlusOne,
		waist=gear.siegel,
		neck=gear.nodens,
	})

	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, {
		head=gear.amalricCoifPlusOne
	})

	sets.Midcast.Refresh = set_combine(sets.Midcast.Enhancing, {
		head = gear.amalricCoifPlusOne
	})

	sets.Midcast.Aspir = {}

	-- Weaponskill base, worn for every weaponskill. The set named for the weaponskill merges over it.
	sets.WS = {}

	-- Merged in ACC mode after the set named for the weaponskill, so its slots win. Name only the slots ACC mode should change. A weaponskill with an ACC set of its own skips it.
	sets.WS.ACC = {}

	sets.WS["Myrkr"] = {
		ammo = gear.ghastlyTathlumPlusOne,
		head = gear.amalricHeadPlusOnePathA,
		body = gear.amalricBodyPlusOnePathA,
		hands = gear.vanyaHandsPathA,
		legs = gear.amalricLegsPlusOnePathA,
		feet = gear.vanyaFeetPathA,
		neck=gear.sanctity,
		waist=gear.luminarySash,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.etiolation,
		left_ring = gear.metamorphPlusOne,
		right_ring=gear.etanaRing,
		back = gear.blmNuke,
	}

	-- Treasure Hunter gear, worn on an action or melee swing against a monster not yet tagged, and throughout a fight in Full Time mode. It is never worn in None mode, where every job but Thief starts.
	sets.TreasureHunter = { }

end

-------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE UNLESS YOU NEED TO MAKE JOB SPECIFIC RULES
-------------------------------------------------------------------------------------------------------------------

-- Called when the player's subjob changes.
function sub_job_change_custom(new, old)
	-- A common use is switching the macro book or set.
end

-- Called before each action, after the engine's own checks. Cancel the action here with cancel_spell(). Nothing it returns is used.
function pretarget_custom(spell,action)

end
-- Gear returned here merges over the engine's precast set for the action.
function precast_custom(spell)
	local equipSet = {}

	return equipSet
end
-- Gear returned here merges over the engine's midcast set for the action.
function midcast_custom(spell)
	local equipSet = {}
	if spell.skill == 'Elemental Magic' and not Elemental_Enfeeble:contains(spell.name) and player.MPP < 30 then
		windower.add_to_chat(8,'Player Less than 30% MP - Recover MP!')
		equipSet = sets.MP_Recover
	end
	return equipSet
end
-- Gear returned here merges over the idle or engaged set worn when an action ends.
function aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end
-- Called when a buff is gained or lost, except while an action is in flight. Gear returned here merges over the idle or engaged set.
function buff_change_custom(name,gain)
	local equipSet = {}

	return equipSet
end
-- Gear returned here merges over every idle and engaged build: after each action, on a buff, status or mode change, and when you start or stop moving.
function choose_set_custom()
	local equipSet = {}

	return equipSet
end
-- Called when your status changes, such as engaging, disengaging or resting. Gear returned here merges over the idle or engaged set that follows.
function status_change_custom(new,old)
	local equipSet = {}

	return equipSet
end

-- Called when a pet is summoned or lost. Gear returned here merges over the idle or engaged set.
function pet_change_custom(pet,gain)
	local equipSet = {}

	return equipSet
end

-- Called when a pet's action ends. Gear returned here merges over the idle or engaged set.
function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called while a pet's action is in flight. Gear returned here merges over sets.Pet_Midcast and the set named for the action.
function pet_midcast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called for a "gs c" command the engine does not handle itself, and for the weapon mode, job mode and job mode 2 commands, which call it before the gear rebuild. The command arrives in lowercase.
function self_command_custom(command)

end

-- Called when the job file unloads, after the engine has released its keys and held slots.
function user_file_unload()

end
