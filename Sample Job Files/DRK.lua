

-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The lockstyle set, macro book and macro set that jobsetup applies at load.
LockStylePallet = "15"
MacroBook = "2"
MacroSet = "1"

-- The item that "gs c food" uses.
Food = "Sublime Sushi"

-- When true, the engine uses a Remedy on paralysis or silence and a Holy Water on Doom.
AutoItem = false

-- When true, each load picks a lockstyle set from Lockstyle_List in place of LockStylePallet.
Random_Lockstyle = false

-- The lockstyle sets Random_Lockstyle picks from.
Lockstyle_List = {1,2,6,12}

-- Not read by this engine.
Organizer = true

-- The offense modes this job cycles through, in place of the engine's default TP, ACC and DT.
-- Each mode needs a sets.OffenseMode.<Mode> and a sets.Idle.<Mode> below, and can also have
-- a sets.WS.<Mode>. state.OffenseMode:set picks the mode selected at load.
state.OffenseMode:options('DT','TP','PDL','ACC','SB','MEVA')
state.OffenseMode:set('DT')

-- Weapon modes. Each one needs a sets.Weapons['<Mode>'] of the same name below.
state.WeaponMode:options('Scythe','Great Sword','Sword','Club','Axe')
state.WeaponMode:set('Scythe')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup(LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- Weapon sets, one per weapon mode above.
	sets.Weapons = {}

	sets.Weapons['Scythe'] = {
		main=gear.anguta,
		sub=gear.utu,
	}

	sets.Weapons['Great Sword'] = {
		main = gear.caladbolg,
		sub=gear.utu,
	}

	sets.Weapons['Sword'] = {
		main=gear.naegling,
		sub = gear.ternionDaggerPlusOne,
	}

	sets.Weapons['Club'] = {
		main = gear.loxoticPlusOne,
		sub=gear.blurredShield,
	}

	sets.Weapons['Axe'] = {
		main=gear.dolichenus,
		sub = gear.ternionDaggerPlusOne,
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active,
	-- engaged or idle.
	sets.Weapons.Shield =
	{
		sub=gear.blurredShield,
	}

	-- Worn while idle. Every action's precast and midcast also start from this set, so a slot
	-- their sets leave out keeps its idle piece.
	sets.Idle = {
		ammo=gear.staunchPlusOne,
		head=gear.sakpataHead,
		body=gear.sakpataBody,
		hands=gear.sakpataHands,
		legs=gear.sakpataLegs,
		feet=gear.sakpataFeet,
		neck = gear.loricatePlusOne,
		waist=gear.carriers,
		left_ear = gear.odnowaPlusOne,
		right_ear=gear.etiolation,
		left_ring = gear.moonlightRing,
		right_ring=gear.gelatinousPlusOne,
		back = gear.drkDA,
	}

	-- Worn over sets.Idle while idle in the matching offense mode. sets.Idle.Resting goes over
	-- them while resting.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})
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

	-- Worn over the idle set while moving and not engaged.
	sets.Movement = {
		legs = gear.carmineLegsPlusOnePathA,
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

	-- Subtle blow gear. sets.WS.SB below is this same table, so weaponskills in SB mode wear it.
	-- This caps with Auspice from WHM.
	sets.Subtle_Blow = {
		body=gear.dagonBreastplate,
		feet=gear.sakpataFeet,
		hands=gear.sakpataHands,
		right_ring=gear.niqmaddu,
	}

	-- Max HP gear for Dread Spikes. midcast_custom below wears it, with a Crepuscular Scythe, for
	-- that spell.
	sets.Max_HP = {
		ammo=gear.staunchPlusOne,
		head=gear.ratriHeadPlusOne,
		body=gear.ratriBodyPlusOne,
		hands=gear.ratriHandsPlusOne,
		legs=gear.ratriLegsPlusOne,
		feet=gear.ratriFeetPlusOne,
		neck = gear.unmovingPlusOne,
		waist=gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		right_ear=gear.tuisto,
		left_ring = gear.moonlightRing,
		right_ring=gear.gelatinousPlusOne,
		back = gear.drkFC,
	}

	-- The engaged base, merged first in every offense mode. The mode's own set goes over it.
	sets.OffenseMode = {
		ammo=gear.coiste,
		head=gear.flammaHeadPlusTwo,
		body=gear.sakpataBody,
		hands=gear.sakpataHands,
		legs=gear.sakpataLegs,
		feet=gear.flammaFeetPlusTwo,
		neck = gear.vimPlusOne,
		waist = gear.sailfi,
		left_ear=gear.telos,
		right_ear = gear.schere,
		left_ring=gear.moonlightRing,
		right_ring=gear.niqmaddu,
		back=gear.nullShawl,
	}

	sets.OffenseMode.TP = set_combine(sets.OffenseMode, {

	})

	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {
		head=gear.hjarrandiHead,
		body=gear.hjarrandiBody,
		feet = gear.sakpataFeet,
		neck=gear.nullLoop,
		left_ring=gear.lehkoHabhokaRing,
	})
	
	-- Weaponskills in PDL mode also take sets.WS.PDL below.
	sets.OffenseMode.PDL = set_combine(sets.OffenseMode, {

	})

	sets.OffenseMode.ACC = set_combine(sets.OffenseMode,{ })
	-- A placeholder. PDT is not offered above. To offer it, add 'PDT' to state.OffenseMode:options
	-- and add a sets.Idle.PDT with the other idle modes. This engaged set is ready.
	sets.OffenseMode.PDT = set_combine(sets.OffenseMode, { })
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, { })
	sets.OffenseMode.SB =  set_combine(sets.OffenseMode, {
		head=gear.hjarrandiHead,
		body=gear.hjarrandiBody,
		feet = gear.sakpataFeet,
		neck=gear.nullLoop,
		right_ear=gear.tuisto,
		left_ring=gear.lehkoHabhokaRing,
	})

	-- Worn over the engaged set in every offense mode while Souleater is up. Souleater gear, such
	-- as the Ignominy Burgeonet, raises the share of HP each hit spends on extra damage.
	-- sets.OffenseMode.Souleater = {}

	-- Worn while engaged with the Dual Wield trait active, over the mode's set.
	sets.DualWield = {}

	sets.Precast = {}

	-- Fast cast gear, worn at the start of every spell.
	sets.Precast.FastCast = {
		ammo=gear.sapience, -- 2
		head = gear.carmineHeadPlusOnePathD, -- 14
		body=gear.sacroBody, -- 10
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.odysseanCuissesFC, -- 6
		feet = gear.odysseanGreavesBFC, -- 13
		neck=gear.voltsurge, -- 4
		waist=gear.platinumMoogleBelt,
		left_ear=gear.malignanceEar, -- 4
		right_ear=gear.etiolation, -- 1
		left_ring=gear.weatherspoon, -- 5
		right_ring=gear.kishar, -- 4
		back = gear.drkFC, -- 10
	}
		
	-- An enmity set for Provoke below. The engine does not read it.
	sets.Enmity = {}

	-- The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this
	-- set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {})
	-- Spell interruption rate down. Merged under every midcast except a ranged attack, so any
	-- specific set overwrites it.
	sets.Midcast.SIRD = set_combine(sets.Midcast, {})
	sets.Midcast.Enhancing = set_combine(sets.Midcast, {})

	-- Enfeebling magic. The engine adds .MACC, .Potency or .Duration from its own spell lists.
	sets.Midcast.Enfeebling = set_combine(sets.Midcast, {})
	sets.Midcast.Enfeebling.MACC = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Enfeebling.Potency = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Enfeebling.Duration = set_combine(sets.Midcast.Enfeebling, {})
	-- Drain and Aspir spells take these two sets in place of the Dark Magic sets below.
	sets.Midcast.Drain = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Aspir = set_combine(sets.Midcast.Enfeebling, {})

	-- Other dark magic. Absorb spells add .Absorb, Stun adds .MACC, and Dread Spikes, Endark and
	-- Tractor add .Enhancing.
	sets.Midcast.Dark = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Dark.MACC = set_combine(sets.Midcast.Enfeebling.MACC, {})
	sets.Midcast.Dark.Absorb = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Dark.Enhancing = set_combine(sets.Midcast.Enhancing, {})

	-- Worn on Absorb spells while Dark Seal is up. Dark Seal gear, such as the Fallen's Burgeonet,
	-- lengthens the spell's effect and must be worn during the cast.
	-- sets.Midcast.Dark.Absorb['Dark Seal'] = {}
	-- Worn on Drain spells while Dark Seal is up, for the same bonus.
	-- sets.Midcast.Drain['Dark Seal'] = {}
	-- Worn on Absorb spells while Nether Void is up. Nether Void gear, such as the Heathen's
	-- Flanchard, raises how much the next Absorb or Drain spell absorbs.
	-- sets.Midcast.Dark.Absorb['Nether Void'] = {}
	-- Worn on Drain spells while Nether Void is up, for the same bonus.
	-- sets.Midcast.Drain['Nether Void'] = {}

	-- Job abilities. sets.JA is worn for every ability, and a set named for the ability goes over it.
	sets.JA = {}
	sets.JA["Provoke"] = sets.Enmity
	sets.JA["Blood Weapon"] = {}
	sets.JA["Souleater"] = {}
	sets.JA["Arcane Circle"] = {}
	sets.JA["Weapon Bash"] = {}
	sets.JA["Nether Void"] = {}
	sets.JA["Arcane Crest"] = {}
	sets.JA["Scarlet Delirium"] = {}
	sets.JA["Soul Enslavement"] = {}
	sets.JA["Consume Mana"] = {}


	-- Worn on every weaponskill. The set named for the weaponskill goes over it, then the offense
	-- mode's set.
	sets.WS = {
		ammo=gear.knobkierrie,
		head = gear.nyameHead, -- Need Heathen
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck=gear.fotiaNeck,
		waist=gear.fotiaWaist,
		left_ear = gear.moonshadeEarringAcc,
		right_ear = gear.schere,
		left_ring=gear.epimanondas,
		right_ring=gear.niqmaddu,
		back = gear.drkWSD,
	}

	-- Worn on weaponskills in ACC mode, over the set named for the weaponskill. List only the
	-- pieces the mode changes, since every slot named here overrides the weaponskill's own set. A
	-- weaponskill with an ACC set of its own, sets.WS['<name>'].ACC, takes that instead. The other
	-- mode sets work the same way, except that sets.WS.TP is never merged.
	sets.WS.ACC = {}

	sets.WS.PDL = {}

	-- Placeholders. WSD, CRIT and Multi_Hit are not offense modes here, and no weaponskill set
	-- below uses them. To use one as a mode, add its name to state.OffenseMode:options with its
	-- engaged and idle sets, and list here only the pieces the mode changes.
	sets.WS.WSD = {}

	sets.WS.CRIT = {}

	sets.WS.Multi_Hit = {}

	sets.WS.SB = sets.Subtle_Blow

	-- Worn on every weaponskill while Souleater is up, for the same bonus.
	-- sets.WS.Souleater = {}

	-- Sets named for each weaponskill.
	sets.WS['Catastrophe'] = set_combine(sets.WS, {
		left_ear=gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
	})

	sets.WS['Origin'] = set_combine(sets.WS, { 
		right_ear=gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
	})

	sets.WS['Entropy'] = set_combine(sets.WS, { 
		ammo = gear.coiste,
		left_ring = gear.metamorphPlusOne,
	})

	sets.WS['Quietus'] = set_combine(sets.WS, { 
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
	})

	sets.WS['Cross Reaper'] = set_combine(sets.WS, { 
		right_ear=gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
		left_ring=gear.regalRing,
	})

	sets.WS['Insurgency'] = set_combine(sets.WS, { 
		right_ear=gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
		left_ring=gear.regalRing,
	})

	sets.WS['Torcleaver'] = set_combine(sets.WS, { 
		right_ear=gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
	})

	sets.WS['Fimbulvetr'] = set_combine(sets.WS, { 
		right_ear=gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
		left_ring=gear.regalRing,
	})

	sets.WS['Scourge'] = set_combine(sets.WS, { 
		left_ear=gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
		left_ring=gear.regalRing,
	})

	sets.WS['Resolution'] = set_combine(sets.WS, { 
		neck = gear.abyssalBeadNecklacePlusTwo,
		left_ring=gear.sroda,
	})

	sets.WS['Judgment'] = set_combine(sets.WS, { 
		right_ear=gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
	})


	-- Treasure Hunter gear. While TH Mode is Tag or Full Time, it is worn for an action aimed at an
	-- untagged monster and while engaged on one. Full Time also keeps it on whenever engaged. TH
	-- Mode starts at None, which never wears it, on every job but Thief.
	sets.TreasureHunter = {
		ammo=gear.perfectEgg,
		legs=gear.volteHose,
	    feet=gear.volteBoots,
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
	if spell.name == "Dread Spikes" then
		equipSet = set_combine( sets.Max_HP, { main=gear.crepuscularScythe })
	end
	return equipSet
end
-- Called when each action ends. The table it returns is merged over the idle or engaged set the
-- engine rebuilds.
function aftercast_custom(spell)
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

-- Called when a pet is summoned or lost. The table it returns is merged over the rebuilt idle or
-- engaged set.
function pet_change_custom(pet,gain)
	local equipSet = {}
	
	return equipSet
end

-- Called when a pet's action ends. The table it returns is merged over the idle or engaged set
-- the engine rebuilds.
function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called while a pet's action is in flight. The table it returns is merged over sets.Pet_Midcast
-- and the set named for the action.
function pet_midcast_custom(spell)
	local equipSet = {}

	return equipSet
end
