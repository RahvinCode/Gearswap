

-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The lockstyle set, macro book and macro set that jobsetup applies at load.
LockStylePallet = "3"
MacroBook = "7"
MacroSet = "1"

-- The item that "gs c food" uses.
Food = "Sublime Sushi"

-- When true, the engine uses a Remedy on paralysis or silence and a Holy Water on Doom.
AutoItem = false

-- When true, each load picks a lockstyle set from Lockstyle_List in place of LockStylePallet.
Random_Lockstyle = false

-- The lockstyle sets Random_Lockstyle picks from.
Lockstyle_List = {1,2,6,12}

-- The offense modes this job cycles through, in place of the engine's default TP, ACC and DT.
-- Each mode needs a sets.OffenseMode.<Mode> and a sets.Idle.<Mode> below, and can also have
-- a sets.WS.<Mode>.
state.OffenseMode:options('TP','ACC','DT','PDL','SB','MEVA','CRIT')

-- The offense mode selected at load.
state.OffenseMode:set('DT')

-- Weapon modes. Each one needs a sets.Weapons['<Mode>'] of the same name below.
state.WeaponMode:options('Verethragna','Karambit','Pole','Club')
state.WeaponMode:set('Verethragna')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- Weapon sets, one per weapon mode above.
	sets.Weapons['Verethragna'] = {
		main = gear.verethragna,
	}
	sets.Weapons['Karambit'] = {
		main=gear.karambit,
	}
	sets.Weapons['Pole'] = {
		main=gear.malignancePole,
		sub=gear.alberStrap,
	}
	sets.Weapons['Club'] = {
		main=gear.warpCudgel,
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active,
	-- engaged or idle.
	sets.Weapons.Shield = {}
	-- Worn with the idle set when this character is put to sleep. Its slots are held until the
	-- sleep ends, and nothing else changes gear while asleep.
	sets.Weapons.Sleep = {}

	-- Worn while idle. Every action's precast and midcast also start from this set, so a slot
	-- their sets leave out keeps its idle piece.
	sets.Idle = {
		ammo=gear.staunchPlusOne,
		head=gear.nullMasque,
		body=gear.adamantiteArmor,
		hands = gear.mpacaHands,
		legs = gear.mpacaLegs,
		feet = gear.mpacaFeet,
		neck = gear.warderCharmPlusOne,
		waist=gear.nullWaist,
		left_ear=gear.sanareEarring,
		right_ear = gear.odnowaPlusOne,
		left_ring=gear.purityRing,
		right_ring=gear.shadowRing,
		back = gear.mnkDADex,
    }
	-- Worn over sets.Idle while idle in the matching offense mode. sets.Idle.Resting goes over
	-- them while resting.
	sets.Idle.Resting = set_combine(sets.Idle, {})
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.CRIT = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
	})

	-- Worn over the idle set while a Phantom Roll on you stands at 11. It is for the Roller's
	-- Ring, which any job can wear and which gives Refresh +1 and Regain +10 at an 11, for example
	-- left_ring="Roller's Ring". It applies in every offense mode. It is worn only while idle, so
	-- any action swaps it out and it comes back when the action ends. While moving, a ring here
	-- replaces the movement set's ring in the same slot. This file's sets.Movement names no ring,
	-- so either slot is free.
	sets.Idle.XIRoll = {}

	-- The TP-mode form, merged after sets.Idle.XIRoll while idle in TP mode.
	sets.Idle.TP.XIRoll = {}

	-- Engaged sets. sets.OffenseMode is merged first in every offense mode, and the mode's own set
	-- goes over it.
	sets.OffenseMode = {}
	sets.OffenseMode.TP = {
		ammo = gear.coiste,
		head = gear.adhemarHeadPlusOnePathA,
		body=gear.kendatsubaBodyPlusOne,
		hands = gear.adhemarHandsPlusOnePathA,
		legs = gear.hesychastLegsPlusFour,
		feet=gear.anchoriteFeetPlusFour,
		neck = gear.monkNodowaPlusTwo,
		waist=gear.moonbowBeltPlusOne,
		left_ear=gear.sherida,
		right_ear = gear.schere,
		left_ring=gear.lehkoHabhokaRing,
		right_ring=gear.gereRing,
		back = gear.mnkDADex,
	}

	sets.OffenseMode.ACC = set_combine(sets.OffenseMode.TP,{
	    head=gear.kendatsubaHeadPlusOne,
		body=gear.kendatsubaBodyPlusOne,
		hands=gear.kendatsubaHandsPlusOne,
		legs=gear.kendatsubaLegsPlusOne,
		feet=gear.kendatsubaFeetPlusOne,
	})

	sets.OffenseMode.DT = set_combine(sets.OffenseMode.TP,{
		head = gear.mpacaHead,
		body = gear.mpacaBody,
		hands = gear.mpacaHands,
		legs=gear.bhikkuLegsPlusThree,
		feet = gear.mpacaFeet,
	})

	sets.OffenseMode.PDL = set_combine(sets.OffenseMode.DT,{
	    ammo=gear.crepuscularPebble,
		legs = gear.mpacaLegs,
	})

	-- SB mode, built on the TP set.
	-- MNK gets 35 Native Subtle Blow
	-- Cap is 75% - 50% caps either I or II
	sets.OffenseMode.SB = set_combine(sets.OffenseMode.TP, {
		waist=gear.moonbowBeltPlusOne, -- SB II 15
		left_ear=gear.sherida, -- SB II 5
		left_ring=gear.niqmaddu, -- SB II 5
		right_ring=gear.chirichRingPlusOne, -- SB 10
		ammo=gear.coiste, -- SB 3
		right_ear = gear.schere, -- SB 3
	}) -- 35 + 16% SB I + %25 SB II = 76 one under

	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode.DT,{
		neck = gear.warderCharmPlusOne,
	})

	-- CRIT mode, built on the TP set.
	sets.OffenseMode.CRIT = set_combine(sets.OffenseMode.TP,{
		head = gear.mpacaHead,
		body = gear.mpacaBody,
		hands = gear.mpacaHands,
		legs = gear.mpacaLegs,
		feet=gear.kendatsubaFeetPlusOne,
		left_ring=gear.niqmaddu,
		right_ring=gear.lehkoHabhokaRing,
		back = gear.mnkDADex,
	})

	-- Worn over the engaged set in every offense mode while Footwork is up.
	sets.OffenseMode.Footwork = { feet=gear.anchoriteFeetPlusFour, }

	-- Worn over the idle set while moving and not engaged.
	sets.Movement = {
		feet=gear.hermesSandals,
	}

	-- Worn over the engaged set in every offense mode while Impetus is up. The same table sits
	-- under sets.WS below, so every weaponskill wears it too.
	sets.OffenseMode.Impetus = {
		body=gear.bhikkuBodyPlusThree,
	}

	-- Worn while Boost is up, as one table under three keys: over the engaged set here, over the
	-- idle set on the next line, and on every weaponskill through sets.WS.Boost below.
	sets.OffenseMode.Boost = {
		waist=gear.askSash,
	}
	sets.Idle.Boost = sets.OffenseMode.Boost

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

	-- An enmity set for Provoke below. The engine does not read it.
	sets.Enmity = {
	    ammo=gear.sapience, -- 2
		head=gear.nullMasque,
		neck=gear.moonlightNeck, -- 15
		body=gear.emetHarnessPlusOne, -- 10
		hands=gear.kurysGloves, -- 9
		legs=gear.bhikkuLegsPlusThree,
		feet=gear.ahosiLeggings, -- 7
		waist=gear.platinumMoogleBelt,
	    left_ear=gear.crypticEarring, -- 4
		right_ear=gear.truxEarring, -- 5
		left_ring=gear.eihwazRing, -- 5
		right_ring=gear.petrov, -- 4
	} -- 61

	sets.Precast = {}
	-- Fast cast gear, worn at the start of every spell.
	sets.Precast.FastCast = {
		ammo=gear.sapience, -- 2
		head = gear.herculeanHelmFC, --13
		body = gear.taeonTabardBFC, --9
		hands = gear.leylineGlovesFCB, --8
		legs = gear.herculeanTrousersFC, --6
		feet = gear.herculeanBootsFC, --6
		neck=gear.voltsurge, --4
		waist = gear.platinumMoogleBelt,
		left_ear=gear.etiolation, --1
		right_ear=gear.loquacious, --2
		left_ring=gear.prolix, --3
		right_ring=gear.rahabRing, -- 2
		back = gear.mnkFC, --10
	} -- FC 66

	-- The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this
	-- set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {

	})

	-- Job abilities. sets.JA is worn for every ability, and a set named for the ability goes over it.
	sets.JA = {}
	sets.JA["Hundred Fists"] = {legs = gear.hesychastLegsPlusFour}
	sets.JA["Berserk"] = {}
	sets.JA["Warcry"] = {}
	sets.JA["Defender"] = {}
	sets.JA["Aggressor"] = {}
	sets.JA["Provoke"] = sets.Enmity
	sets.JA["Focus"] = {}
	sets.JA["Dodge"] = {}
	sets.JA["Chakra"] = {
		ammo=gear.ironGobbet,
		head=gear.nullMasque,
		body=gear.anchoriteBodyPlusFour,
		hands = gear.hesychastHandsPlusThree,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.unmovingPlusOne,
		waist=gear.platinumMoogleBelt,
		left_ear=gear.tuisto,
		right_ear = gear.odnowaPlusOne,
		left_ring=gear.regalRing,
		right_ring = gear.gelatinousPlusOne,
		back = gear.mnkDADex,
	}
	sets.JA["Boost"] = {}
	sets.JA["Counterstance"] = {}
	sets.JA["Chi Blast"] = {
		head = gear.hesychastHeadPlusFour,
	}
	sets.JA["Mantra"] = {}
	sets.JA["Footwork"] = {}
	sets.JA["Perfect Counter"] = {}
	sets.JA["Impetus"] = {}
	sets.JA["Inner Strength"] = {}

	-- Worn on every weaponskill. The set named for the weaponskill goes over it, then the offense
	-- mode's set.
	sets.WS = { -- VS Base with Impetus Down
		ammo = gear.coiste,
		head=gear.mpacaHead,
		body=gear.mpacaBody,
		hands=gear.mpacaHands,
		legs=gear.mpacaLegs,
		feet=gear.mpacaFeet,
		neck=gear.fotiaNeck,
		waist=gear.moonbowBeltPlusOne,
		left_ear=gear.sherida,
		right_ear = gear.schere,
		left_ring=gear.niqmaddu,
		right_ring=gear.gereRing,
		back = gear.mnkCrit,
	}

	-- The Impetus table again, worn on every weaponskill while Impetus is up. A child of sets.WS
	-- must come after the sets.WS declaration above, which replaces the whole table.
	sets.WS.Impetus = sets.OffenseMode.Impetus
	-- The Boost table again, worn on a weaponskill while Boost is up. Boost ends with the next
	-- attack or weaponskill, so this is for a Boost used just before a weaponskill, between
	-- auto-attacks.
	sets.WS.Boost = sets.OffenseMode.Boost
	-- A child under one weaponskill's set applies to that weaponskill alone, for example
	-- sets.WS['Dragon Kick'].Footwork = { feet=gear.anchoriteFeetPlusFour, }. It must come after
	-- that weaponskill's set below. Dragon Kick and Tornado Kick share the sets.WS.Kicks table, so
	-- a child on either one applies to both.

	-- 35% SB I for MNK
	-- Belt SB II 15%
	-- Mpaca Legs -- SB II 5%
	-- Earring / Ring SB II 10%
	-- Need 4% SB
	sets.WS.SB = { -- Maximizes subtle blow
		waist=gear.moonbowBeltPlusOne, -- SB II 15
		left_ear=gear.sherida, -- SB II 5
		left_ring=gear.niqmaddu, -- SB II 5
		legs=gear.mpacaLegs, -- SB II 5
		ammo=gear.coiste, -- SB 3
		right_ear = gear.schere, -- SB 3
	}

	sets.WS.MEVA = {
		neck = gear.warderCharmPlusOne,
		left_ring=gear.defending,
	}

	-- Worn on weaponskills in ACC mode, over the set named for the weaponskill. List only the
	-- pieces the mode changes, since every slot named here overrides the weaponskill's own set. A
	-- weaponskill with an ACC set of its own, sets.WS['<name>'].ACC, takes that instead. The other
	-- mode sets work the same way, except that sets.WS.TP is never merged.
	sets.WS.ACC = {}

	sets.WS.PDL = {}

	-- Shared by Dragon Kick and Tornado Kick below.
	sets.WS.Kicks = {
		ammo=gear.crepuscularPebble,
		head=gear.mpacaHead,
		body=gear.kendatsubaBodyPlusOne,
		hands = gear.ryuoHandsPlusOnePathA,
		legs = gear.hesychastLegsPlusFour,
		feet=gear.anchoriteFeetPlusFour,
		neck = gear.monkNodowaPlusTwo,
		waist=gear.moonbowBeltPlusOne,
		left_ear=gear.sherida,
		right_ear=gear.odr,
		--left_ring="Niqmaddu Ring",
		right_ring=gear.gereRing,
		back = gear.mnkCrit,
	}

	-- Sets named for each weaponskill.
	sets.WS["Combo"] = set_combine(sets.WS,{})
	sets.WS["Shoulder Tackle"] = set_combine(sets.WS,{})
	sets.WS["One Inch Punch"] = set_combine(sets.WS,{})
	sets.WS["Backhand Blow"] = set_combine(sets.WS,{})
	sets.WS["Raging Fists"] = set_combine(sets.WS,{
		neck=gear.monkNodowaPlusTwo,
		feet=gear.kendatsubaFeetPlusOne,
	})
	sets.WS["Spinning Attack"] = set_combine(sets.WS,{})
	sets.WS["Howling Fist"] = set_combine(sets.WS,{
		neck=gear.monkNodowaPlusTwo,
		feet=gear.kendatsubaFeetPlusOne,
	})
	sets.WS["Dragon Kick"] = sets.WS.Kicks
	sets.WS["Asuran Fists"] = set_combine(sets.WS,{})
	sets.WS["Tornado Kick"] = sets.WS.Kicks
	sets.WS["Victory Smite"] = set_combine(sets.WS,{})
	sets.WS["Shijin Spiral"] = set_combine(sets.WS,{
		back = gear.mnkDADex,
	})

	-- Treasure Hunter gear. While TH Mode is Tag or Full Time, it is worn for an action aimed at an
	-- untagged monster and while engaged on one. Full Time also keeps it on whenever engaged. TH
	-- Mode starts at None, which never wears it, on every job but Thief.
	sets.TreasureHunter = {
		ammo=gear.perfectEgg,
		body=gear.volteJupon,
		waist=gear.chaac,
	}

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

	return equipSet
end
-- Called while each action is in flight. The table it returns is merged over the engine's
-- midcast set, which is empty for abilities, weaponskills and items.
function midcast_custom(spell)
	local equipSet = {}

	return equipSet
end
-- Called when each action ends. The table it returns is merged over the idle or engaged set the
-- engine rebuilds.
function aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called when a pet is summoned or lost. The table it returns is merged over the rebuilt idle or
-- engaged set.
function pet_change_custom(pet,gain)
	local equipSet = {}

	return equipSet
end

-- Called while a pet's action is in flight. The table it returns is merged over sets.Pet_Midcast
-- and the set named for the action.
function pet_midcast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called when a pet's action ends. The table it returns is merged over the idle or engaged set
-- the engine rebuilds.
function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called when a buff is gained or lost. The table it returns is merged over the rebuilt idle or
-- engaged set. A change during one of your own actions is dressed when the action ends instead.
function buff_change_custom(name,gain)
	local equipSet = {}

	return equipSet
end

-- Called whenever the engine rebuilds the idle or engaged set, which it does after each action,
-- on a buff or status change, and when movement starts or stops. The table it returns is merged
-- over that set.
function choose_set_custom()
	local equipSet = {}

	return equipSet
end

-- Called when the player's status changes, such as engaging, disengaging or resting. The table
-- it returns is merged over the rebuilt idle or engaged set.
function status_change_custom(new,old)
	local equipSet = {}

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
