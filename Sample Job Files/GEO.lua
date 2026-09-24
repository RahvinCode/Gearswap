
-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The lockstyle set, macro book and macro set that jobsetup applies at load.
LockStylePallet = "20"
MacroBook = "20"
MacroSet = "1"

-- The item that "gs c food" uses.
Food = "Tropical Crepe"

-- When true, the engine uses a Remedy on paralysis or silence and a Holy Water on Doom.
AutoItem = false

-- When true, each load picks a lockstyle set from Lockstyle_List in place of LockStylePallet.
Random_Lockstyle = false

-- The lockstyle sets Random_Lockstyle picks from.
Lockstyle_List = {1,2,6,12}

-- The offense modes this job cycles through, in place of the engine's default TP, ACC and DT.
-- Each mode needs a sets.OffenseMode.<Mode> and a sets.Idle.<Mode> below, and can also have
-- a sets.WS.<Mode>.
state.OffenseMode:options('TP','ACC','DT','PDL','SB','MEVA')

-- The offense mode selected at load.
state.OffenseMode:set('DT')

-- Weapon modes. Each one needs a sets.Weapons['<Mode>'] of the same name below.
state.WeaponMode:options('Idris','Black Halo','Mpaca')
state.WeaponMode:set('Mpaca')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

-- Goal 2200 HP/1400 MP
function get_sets()

	-- Weapon sets, one per weapon mode above.
	sets.Weapons = {}

	sets.Weapons['Idris'] = {
		main=gear.idris,
		sub=gear.genmeiShield,
	}

	sets.Weapons['Black Halo'] = {
		main=gear.maxentius,
		sub=gear.genmeiShield,
	}

	sets.Weapons['Mpaca'] = {
		main=gear.mpacaStaff,
		sub=gear.enki,
	}

	-- Worn with the idle set when this character is put to sleep. Its slots are held until the
	-- sleep ends, and nothing else changes gear while asleep.
	sets.Weapons.Sleep = {
		main=gear.lorgMor,
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active,
	-- engaged or idle.
	sets.Weapons.Shield = {
		sub=gear.genmeiShield,
	}

	-- Worn while idle. Every action's precast and midcast also start from this set, so a slot
	-- their sets leave out keeps its idle piece.
	sets.Idle = {
		range = gear.dunnaFC,
		head=gear.azimuthHeadPlusThree, -- 11/11
		body=gear.azimuthBodyPlusThree,
		hands=gear.azimuthHandsPlusThree, -- 12/12
		legs = gear.agwuLegs, -- 10/10
		feet=gear.azimuthFeetPlusThree, -- 10/10
		neck = gear.loricatePlusOne, -- 6/6
		waist=gear.carriers,
		left_ear=gear.sanareEarring,
		right_ear=gear.lugalbanda,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
		back = gear.geoPetRegen,
    } -- 50 PDT / 52 MDT (including shield)

	-- Worn over sets.Idle while idle in the matching offense mode. sets.Idle.Resting goes over
	-- them while resting.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})

	-- Worn over the idle set while a Phantom Roll on you stands at 11. It is for the Roller's
	-- Ring, which any job can wear and which gives Refresh +1 and Regain +10 at an 11, for example
	-- right_ring="Roller's Ring". It applies in every offense mode. It is worn only while idle, so
	-- any action swaps it out and it comes back when the action ends. While moving, a ring here
	-- replaces the movement set's ring in the same slot. This file's sets.Movement wears a
	-- Defending Ring in left_ring, so right_ring is the free slot.
	sets.Idle.XIRoll = {}

	-- The TP-mode form, merged after sets.Idle.XIRoll while idle in TP mode.
	sets.Idle.TP.XIRoll = {}

	-- Worn over the idle set while a pet is out.
	sets.Idle.Pet = set_combine( sets.Idle, { --2278/1482
		head=gear.azimuthHeadPlusThree, -- 11/11
		neck = gear.baguaCharmPlusTwo,
		body=gear.adamantiteArmor,
		feet = gear.baguaArmorFeetPlusFour,
		left_ring=gear.defending,
		hands=gear.geomancyHandsPlusFour,
    }) -- 54 PDT / 45 MDT (with shield)

	-- Worn over the idle set while moving and not engaged.
	sets.Movement = {
		left_ring=gear.defending,
		feet=gear.geomancyFeetPlusFour,
	}

	-- Worn when another character on this machine, running this engine, casts on you. Spell
	-- Received mode must be ON. sets.Cursna_Received is also the Doom set, worn when that mode is OFF.
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

	-- The ring slot Zodiac Ring goes in when a spell's element matches the day: "right_ring" or
	-- "left_ring".
	Elemental_Bonus_Ring_Slot = "right_ring"

	-- Worn while using a Holy Water or Hallowed Water.
	sets.Holy_Water = {
	    neck=gear.nicander,
	}

	-- Treasure Hunter gear. While TH Mode is Tag or Full Time, it is worn for an action aimed at an
	-- untagged monster and while engaged on one. Full Time also keeps it on whenever engaged. TH
	-- Mode starts at None, which never wears it, on every job but Thief.
	sets.TreasureHunter = {
		ammo=gear.perfectEgg,
		waist=gear.chaac,
		hands = gear.merlinicDastanasNukeB,
	}

	-- The engaged base, merged first in every offense mode. The mode's own set goes over it.
	sets.OffenseMode = {
		head=gear.azimuthHeadPlusThree,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet=gear.azimuthFeetPlusThree,
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
		left_ear=gear.crepuscularEar,
		right_ear=gear.telos,
		left_ring=gear.chirichRingPlusOne,
		right_ring=gear.chirichRingPlusOne,
		back = gear.geoPetRegen,
	}

	sets.OffenseMode.TP = set_combine(sets.OffenseMode,{})
	sets.OffenseMode.DT = set_combine(sets.OffenseMode,{})
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode,{})
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, {})
	sets.OffenseMode.PDL = set_combine(sets.OffenseMode, {})
	sets.OffenseMode.SB = set_combine(sets.OffenseMode, {})

	-- Worn while engaged with the Dual Wield trait active, over the mode's set.
	sets.DualWield = {
		left_ear=gear.eabani,
	}

	-- Precast sets, worn as an action starts.
	sets.Precast = {}

	-- Fast cast gear, worn at the start of every spell.
	sets.Precast.FastCast = {
		range = gear.dunnaFC, -- 3
		head = gear.merlinicHoodFC, -- 15
		body=gear.zendikRobe, -- 13
		hands = gear.agwuHands, -- 6
		legs=gear.geomancyLegsPlusFour, -- 15
		feet = gear.merlinicCrackowsFC, -- 12
		neck=gear.voltsurge, -- 4
		waist=gear.witful, -- 3 and 3 Quick Magic
		left_ear=gear.malignanceEar, -- 4
		right_ear=gear.etiolation, -- 1
		left_ring=gear.lebecheRing, -- 2 Quick Magic
		right_ring=gear.kishar, -- 4
		-- Have to use Fast Cast due to Head Locked out with Pet above 68%
		back = gear.geoFCB,
		--back="Perimede Cape", -- 4 Quick Magic
	} -- 80% Fast Cast with 9% Quick Magic

	-- Merged over the fast cast set for cures, enhancing magic, Utsusemi, blue magic and songs.
	sets.Precast.Cure = {}
	sets.Precast.Enhancing = {}
	sets.Precast.Utsusemi = {}
	sets.Precast.BlueMagic = {}
	sets.Precast.Songs = {}


	-- The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this
	-- set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {

	})

	-- Spell interruption rate down. Merged under every midcast except a ranged attack, so any
	-- specific set overwrites it.
	sets.Midcast.SIRD = {}

	-- Cure spells. Curaga takes its own set below.
	sets.Midcast.Cure = {
		main=gear.daybreak, -- 30
		sub=gear.genmeiShield,
		range = gear.dunnaFC,
		head = gear.vanyaHeadPathB, -- 10
		body = gear.vanyaBodyPathB,
		hands=gear.azimuthHandsPlusThree,
		legs = gear.vanyaLegsPathB,
		feet=gear.azimuthFeetPlusThree,
		neck = gear.loricatePlusOne,
		waist=gear.luminarySash,
		left_ear = gear.odnowaPlusOne,
		right_ear=gear.etiolation,
		left_ring = gear.stikiniRingPlusOne3,
		right_ring = gear.stikiniRingPlusOne2,
		back = gear.geoCure, -- 10
    }

	sets.Midcast.Curaga = set_combine( sets.Midcast.Cure, {})

	-- Enhancing magic. The family sets below go over it for the spells each one covers.
	sets.Midcast.Enhancing = {
		sub=gear.ammurapi,
		range = gear.dunnaFC,
		head = gear.telchineCapBEnhDur,
		body = gear.telchineChasubleBEnhDur,
		hands = gear.telchineGlovesCEnhDur,
		legs = gear.telchineBraconiBEnhDur,
		feet = gear.telchinePigachesC,
		neck=gear.loricatePlusOne,
		waist=gear.embla,
		left_ear = gear.odnowaPlusOne,
		right_ear=gear.etiolation,
		left_ring=gear.defending,
		right_ring = gear.gelatinousPlusOne,
		back = gear.geoPetRegen,
	}

	-- Elemental bar-spells: Barfire, Barblizzard, Baraero, Barstone, Barthunder, Barwater and
	-- their -ra forms.
	sets.Midcast.Enhancing.Elemental = {}

	-- Status bar-spells: Barsleep, Barpoison, Barparalyze, Barblind, Barvirus, Barpetrify,
	-- Baramnesia, Barsilence and their -ra forms.
	sets.Midcast.Enhancing.Status = {}

	-- Spells that scale with enhancing skill: Temper, Temper II, the first-tier en-spells and the
	-- Boost-stat spells.
	sets.Midcast.Enhancing.Skill = {}

	-- Enhancing spells cast on someone else, and self-casts under Accession. Merged after
	-- sets.Midcast.Enhancing and before the family set.
	sets.Midcast.Enhancing.Others = {}

	-- Enfeebling magic, built for magic accuracy so the spells land.
	sets.Midcast.Enfeebling = {
		main = gear.idris,
		sub=gear.ammurapi,
		range = gear.dunnaFC,
		head=gear.geomancyHeadPlusFour,
		body=gear.geomancyBodyPlusFour,
		hands=gear.azimuthHandsPlusThree,
		legs=gear.geomancyLegsPlusFour,
		feet=gear.geomancyFeetPlusFour,
		neck = gear.baguaCharmPlusTwo,
		waist=gear.luminarySash,
		left_ear=gear.malignanceEar,
		right_ear=gear.regalEarring,
		left_ring = gear.stikiniRingPlusOne3,
		right_ring = gear.stikiniRingPlusOne2,
		back = gear.geoNukePdt,
	}

	-- Merged over the enfeebling set for the accuracy-based spells the engine's list names.
	sets.Midcast.Enfeebling.MACC = set_combine(sets.Midcast.Enfeebling, {})

	-- Elemental nukes. A magic burst uses sets.Midcast.Burst instead.
	sets.Midcast.Nuke = {
		main = gear.idris,
		sub=gear.ammurapi,
		ammo = gear.ghastlyTathlumPlusOne,
		head=gear.eaHeadPlusOne,
		body=gear.eaBodyPlusOne,
		hands=gear.azimuthHandsPlusThree,
		legs=gear.azimuthLegsPlusThree,
		feet=gear.azimuthFeetPlusThree,
		neck=gear.mizukageNoKubikazari,
		waist = gear.acuityBeltPlusOne,
		left_ear=gear.malignanceEar,
		right_ear=gear.regalEarring,
		left_ring=gear.freke,
		right_ring = gear.metamorphPlusOne,
		back = gear.geoNukePdt,
	}

	-- Magic bursts, in place of sets.Midcast.Nuke. A nuke bursts when it lands on the skillchain's
	-- target within 8 seconds and its element matches the skillchain.
	sets.Midcast.Burst = set_combine( sets.Midcast.Nuke, {})

	-- Cursna, merged over sets.Midcast.Enhancing.
	sets.Midcast.Cursna = set_combine( sets.Midcast.Cure, {
	    left_ring=gear.menelausRing,
		right_ring=gear.haomaRing,
	})

	-- Sets named for one spell. Such a set takes the place of the spell's family set, which is why
	-- these start from the family set with set_combine.
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne3,
		waist=gear.siegel,
	})

	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, {
		head = gear.amalricHeadPlusOnePathA,
		hands=gear.regalCuffs,
	})

	sets.Midcast["Stun"] = set_combine( sets.Midcast.Nuke,{})

	sets.Midcast["Diaga"] = set_combine (sets.Midcast.Enfeebling, sets.TreasureHunter)

	sets.Midcast["Dispelga"] = set_combine (sets.Midcast.Enfeebling.MACC, sets.TreasureHunter,{
		main=gear.daybreak
	})

	sets.Midcast.Refresh = {}
	sets.Midcast.Aspir = {}
	sets.Midcast.Drain = {}
	sets.Midcast.Regen = {}
	sets.Midcast.Dark = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Dark.MACC = set_combine(sets.Midcast.Enfeebling.MACC, {})
	sets.Midcast.Dark.Absorb = set_combine(sets.Midcast.Enfeebling, {})

	-- Geomancy spells. The engine never merges sets.Geomancy itself. An Indi-spell takes .Indi and
	-- a Geo-spell takes .Geo, unless the spell has a set of its own.
	sets.Geomancy = {}

	-- Indi-spells, built for duration.
	-- Under the Geomancy weapon lock, the main and sub named in this family swap in for the cast,
	-- and the weapon mode's pair returns after it. Under Locked, the mode's pair is worn instead.
	sets.Geomancy.Indi = {
		main = gear.idris,
		sub=gear.genmeiShield,
		range = gear.dunnaFC,
		head = gear.baguaArmorHeadPlusFour,
		body=gear.azimuthBodyPlusThree,
		hands=gear.geomancyHandsPlusFour,
		legs = gear.baguaArmorLegsPlusFour, -- 21
		feet=gear.azimuthFeetPlusThree, -- 30
		neck = gear.baguaCharmPlusTwo,
		waist=gear.luminarySash,
		left_ear = gear.odnowaPlusOne,
		right_ear=gear.etiolation,
		left_ring=gear.defending,
		right_ring = gear.gelatinousPlusOne,
		back = gear.lifestreamCape,
	}

	-- Merged over .Indi when the Indi-spell is cast on someone else, through Entrust.
	sets.Geomancy.Indi.Entrust = set_combine(sets.Geomancy.Indi, {
		main = gear.gadaNuke,
	})

	-- Geo-spells, built for potency.
	sets.Geomancy.Geo = set_combine( sets.Geomancy.Indi, {
		legs = gear.nyameLegs, -- 8/8
		feet=gear.azimuthFeetPlusThree, -- 11/11
	})

	sets.Pet_Midcast = {}

	-- Keeps the Luopan's HP bonus. aftercast_custom wears it at the end of every Geo-spell. After
	-- that, Luopan() keeps it on in every build while a Bagua head is worn and the Luopan is above
	-- 68% HP.
	sets.Luopan = {
		head = gear.baguaArmorHeadPlusFour,
	}

	-- Job abilities. sets.JA is worn for every ability, and a set named for the ability goes over it.
	sets.JA = {}
	sets.JA["Collimated Fervor"] = {}
	sets.JA["Convert"] = {}
	sets.JA["Bolster"] = {
	    body = gear.baguaArmorBodyPlusFour, 
	}
	sets.JA["Full Circle"] = {
		head=gear.azimuthHeadPlusThree, -- 3
		hands = gear.baguaArmorHandsPlusFour,
	}
	sets.JA["Lasting Emanation"] = {}
	sets.JA["Ecliptic Attrition"] = {} 
	sets.JA["Life Cycle"] = {
		body=gear.geomancyBodyPlusFour,
		back = gear.geoPetRegen,
	}
	sets.JA["Blaze of Glory"] = {}
	sets.JA["Dematerialize"] = {}
	sets.JA["Theurgic Focus"] = {}
	sets.JA["Concentric Pulse"] = {}
	sets.JA["Mending Halation"] = {
	    legs = gear.baguaArmorLegsPlusFour,
	}
	sets.JA["Radial Arcana"] = {
	    feet = gear.baguaArmorFeetPlusFour,
	}
	sets.JA["Widened Compass"] = {}
	sets.JA["Entrust"] = {}

	-- Worn on every weaponskill. The set named for the weaponskill goes over it, then the offense
	-- mode's set.
	sets.WS = {
	    range = gear.dunnaFC,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.telos,
		left_ring=gear.epimanondas,
		right_ring=gear.corneliaRing,
		back = gear.geoPetRegen,
	}

	-- Worn on weaponskills in ACC mode, over the set named for the weaponskill. List only the
	-- pieces the mode changes, since every slot named here overrides the weaponskill's own set. A
	-- weaponskill with an ACC set of its own, sets.WS['<name>'].ACC, takes that instead. The other
	-- mode sets work the same way, except that sets.WS.TP is never merged.
	sets.WS.ACC = {}

end

-------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE UNLESS YOU NEED TO MAKE JOB SPECIFIC RULES
-------------------------------------------------------------------------------------------------------------------

-- Called when the subjob changes.
function sub_job_change_custom(new, old)
	-- Typically used to change the macro book or set.
end

-- Called before each action, after the engine's own checks. Call cancel_spell() here to stop
-- the action.
function pretarget_custom(spell,action)

end
-- Called as each action starts. The table it returns is merged over the engine's precast set.
function precast_custom(spell)
	local equipSet = {}
	equipSet = set_combine(equipSet, Luopan())
	return equipSet
end
-- Called while each action is in flight. The table it returns is merged over the engine's
-- midcast set, which is empty for abilities, weaponskills and items.
function midcast_custom(spell)
	local equipSet = {}
	equipSet = set_combine(equipSet, Luopan())
	return equipSet
end
-- Called when each action ends. The table it returns is merged over the idle or engaged set the
-- engine rebuilds.
function aftercast_custom(spell)
	local equipSet = {}
	-- After a Geo-spell, always wear sets.Luopan. After anything else, Luopan() decides.
	if Geomancy_List:contains(spell.english) then
		equipSet = set_combine(equipSet, sets.Luopan)
	else
		equipSet = set_combine(equipSet, Luopan())
	end
	return equipSet
end
-- Called when a buff is gained or lost. The table it returns is merged over the rebuilt idle or
-- engaged set. A change during one of your own actions is dressed when the action ends instead.
function buff_change_custom(name,gain)
	local equipSet = {}
	-- Wear sets.Luopan when Blaze of Glory wears off, as after a Geo-spell.
	if name == "Blaze of Glory" and not gain then
		equipSet = set_combine(equipSet, sets.Luopan)
	end
	equipSet = set_combine(equipSet, Luopan())
	return equipSet
end
-- Called whenever the engine rebuilds the idle or engaged set, which it does after each action,
-- on a buff or status change, and when movement starts or stops. The table it returns is merged
-- over that set.
function choose_set_custom()
	local equipSet = {}
	equipSet = set_combine(equipSet, Luopan())
	return equipSet
end
-- Called when the player's status changes, such as engaging, disengaging or resting. The table
-- it returns is merged over the rebuilt idle or engaged set.
function status_change_custom(new,old)
	local equipSet = {}
	equipSet = set_combine(equipSet, Luopan())
	return equipSet
end

-- Called when a pet is summoned or lost. The table it returns is merged over the rebuilt idle or
-- engaged set.
function pet_change_custom(pet,gain)
	local equipSet = {}
	equipSet = set_combine(equipSet, Luopan())
	return equipSet
end

-- Called when a pet's action ends. The table it returns is merged over the idle or engaged set
-- the engine rebuilds.
function pet_aftercast_custom(spell)
	local equipSet = {}
	-- The rebuilt set already carries Luopan() through choose_set_custom.
	return equipSet
end

-- Called while a pet's action is in flight. The table it returns is merged over sets.Pet_Midcast
-- and the set named for the action.
function pet_midcast_custom(spell)
	local equipSet = {}
	equipSet = set_combine(equipSet, Luopan())
	return equipSet
end

-- Called with each "gs c" command, in lowercase, that the engine's own commands leave unclaimed.
-- Use it to add commands of your own. The Weapon Mode, Job Mode and Job Mode 2 commands also call
-- it, before their gear rebuild.
function self_command_custom(command)

end
-- Called when the job file unloads, after the engine releases its keybinds and slot holds.
function user_file_unload()

end

-- Returns sets.Luopan while a Luopan is out above 68% HP and a Bagua head is already worn, so the
-- head's Luopan HP bonus stays on through every build. Otherwise it returns nothing, which
-- set_combine treats as an empty set. The gear hooks above call it, so it returns as early as it
-- can and builds no table. The log arguments are passed separately, so the text is joined only
-- when debug is on.
function Luopan()
	if not pet.isvalid then return end
	local head_item = player.equipment.head
	if not (head_item and head_item:contains("Bagua")) then return end
	log('Regen [', pet.hpp, ']% HP')
	-- Keep the Bagua head on while the Luopan is above 68% HP.
	if pet.hpp > 68 then return sets.Luopan end
end

-- Whether the Luopan was last seen above 68% HP, so the timer below asks for a rebuild only when
-- that changes.
Luopan_Was_High = false

-- The engine calls Cycle_Timer about every 2 seconds. It skips the call during an action and
-- while you are dead, charmed or asleep.
function Cycle_Timer()
	if player.status ~= "Idle" then return end
	-- A change in the Luopan's HP starts no rebuild by itself. While idle, this watches for the
	-- Luopan crossing 68% and asks for a rebuild when it does, and the rebuild reaches Luopan()
	-- through choose_set_custom. Calling Luopan() here would only compute a set with nowhere to go.
	local high = (pet.isvalid and pet.hpp > 68) and true or false
	if high ~= Luopan_Was_High then
		Luopan_Was_High = high
		equip_set_command()
	end
end
