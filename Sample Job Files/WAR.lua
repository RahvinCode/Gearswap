
-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The in-game equip set used for lockstyle, and the macro book and set to switch to on load.
LockStylePallet = "8"
MacroBook = "4"
MacroSet = "1"

-- The food item "gs c food" uses.
Food = "Sublime Sushi"

-- Use a Remedy on paralysis or silence, and a Holy Water on doom, automatically.
AutoItem = false

-- Pick a random lockstyle from Lockstyle_List each time this file loads.
Random_Lockstyle = false

-- The equip sets the random lockstyle picks from.
Lockstyle_List = {1,2,6,12}

-- The offense modes this file offers. The engine's defaults are TP, ACC and DT.
-- Every mode offered here needs both a sets.OffenseMode.<Mode> entry and a sets.Idle.<Mode> entry. The engine warns in chat each time it looks for a missing one.
state.OffenseMode:options('TP','PDL','ACC','DT','PDT','MEVA','CRIT','SB')

-- The offense mode to start in.
state.OffenseMode:set('DT')

-- The weapon modes, each naming a sets.Weapons entry below, and the one to start in.
state.WeaponMode:options('Chango','Shining One','Savage Blade','Decimation','Axe','Aeolian Edge', 'Ukonvasara','Labraunda')
state.WeaponMode:set('Chango')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- One weapon set per weapon mode, keyed by the mode's name.
	sets.Weapons = {}

	sets.Weapons['Chango'] = {
		main=gear.chango,
		sub=gear.utu,
	}
	sets.Weapons['Labraunda'] = {
		main = gear.labraunda,
		sub=gear.utu,
	}
	sets.Weapons['Shining One'] = {
		main=gear.shiningOne,
		sub=gear.utu,
	}
	sets.Weapons['Savage Blade'] = {
		main=gear.naegling,
		sub=gear.zantetsuken,
	}
	sets.Weapons['Decimation'] = {
		main=gear.dolichenus,
		sub=gear.zantetsuken,
	}
	sets.Weapons['Axe'] = {
		main=gear.ikengaAxe,
		sub=gear.zantetsuken,
	}
	sets.Weapons['Aeolian Edge'] = {
		main=gear.ternionDaggerPlusOne,
		sub=gear.naegling,
	}
	sets.Weapons['Ukonvasara'] = {
		main=gear.chango,
		sub=gear.utu,
	}
	-- Worn in the offhand, idle or engaged, whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons.Shield = {
		sub=gear.blurredShield,
	}
	-- Worn over the idle set when you are put to sleep, and held until the sleep ends. A piece that drains HP wakes you on its first tick.
	sets.Weapons.Sleep = {}

	-- Worn while idle. It is also the floor under every precast and midcast, so a slot an action's set leaves out keeps its idle piece.
	sets.Idle = {
		ammo=gear.staunchPlusOne,
		head=gear.sakpataHead,
		body=gear.sakpataBody,
		hands=gear.sakpataHands,
		legs=gear.sakpataLegs,
		feet=gear.sakpataFeet,
		neck = gear.loricatePlusOne,
		waist=gear.carriers,
		left_ear=gear.odnowaPlusOne,
		right_ear = gear.eabani,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.warDAAcc,
    }

	-- Idle sets per offense mode, merged over sets.Idle in the matching mode. sets.Idle.Resting is merged while you rest.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.PDT = set_combine(sets.Idle, {})
	sets.Idle.CRIT = set_combine(sets.Idle, {})
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
		feet=gear.hermesSandals,
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

	-- Subtle Blow gear. The engine never reads this set by name. It is worn as the SB weaponskill set below.
	-- 10 + 19 for Auspice
	sets.Subtle_Blow = {
		body=gear.dagonBreastplate, -- 10 SB II
		feet = gear.sakpataFeet, -- 15 SB I
		hands = gear.sakpataHands, -- 8 SB I
		left_ring=gear.niqmaddu, -- 5 SB II
	}

	--WAR Double attack
	--28% Job Trait
	--5% Merits

	-- The engaged base, worn in every offense mode. The set named for the current mode is merged over it, and the mode sets below start from a copy of it.
	sets.OffenseMode = {
		ammo = gear.coiste, -- 3 DA
		head=gear.flammaHeadPlusTwo,
		body=gear.dagonBreastplate,
		hands = gear.sakpataHands,
		legs=gear.pummelerLegsPlusThree,
		feet=gear.pummelerFeetPlusThree,
		neck = gear.warriorsBeadPlusTwo, -- 7 DA
		waist = gear.sailfi, -- 5 DA
		left_ear = gear.schere, -- 3 DA
		right_ear=gear.boiiEarringPlusOne, -- 8 DA
		left_ring=gear.niqmaddu,
		right_ring=gear.lehkoHabhokaRing,
		back=gear.nullShawl,
	}

	sets.OffenseMode.TP = set_combine( sets.OffenseMode, {})
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {})
	sets.OffenseMode.CRIT = set_combine(sets.OffenseMode, {})

	sets.OffenseMode.DT = set_combine( sets.OffenseMode, {
		head=gear.hjarrandiHead,
		body=gear.sakpataBody,
		hands=gear.sakpataHands, -- 6 DA
		legs=gear.sakpataLegs, -- 7 DA
		feet=gear.sakpataFeet, -- 4 DA
	}) -- 100% DA

	sets.OffenseMode.PDL = set_combine( sets.OffenseMode, {
		ammo=gear.crepuscularPebble,
		right_ring=gear.sroda,
	})

	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, {
		ammo = gear.coiste,
		head = gear.sakpataHead,
		neck = gear.warderCharmPlusOne,
		waist=gear.carriers,
		left_ring=gear.moonlightRing,
		right_ring=gear.lehkoHabhokaRing,
	})

	-- The most Subtle Blow this set reaches is SB 50 and SB II 15. It needs Auspice (29) to cap.
	sets.OffenseMode.SB = set_combine(sets.OffenseMode, { 
		head=gear.hjarrandiHead,
		body=gear.sakpataBody,
		legs=gear.sakpataLegs,
		feet=gear.sakpataFeet,
	})
	sets.OffenseMode.PDT = set_combine(sets.OffenseMode, {})

	-- Buff sets for the engaged set. Uncomment one to use it. Each is worn over the engaged set in every offense mode while its buff is up, and its slots win over the mode set.
	-- Worn while engaged with Restraint up. Restraint's weaponskill damage bonus builds from your melee hits, and Boii Mufflers raise that bonus. They need not be worn for the weaponskill itself.
	-- sets.OffenseMode.Restraint = {}
	-- Worn while engaged with Retaliation up. Boii Calligae and Pummeler's Mufflers raise the damage your retaliations deal.
	-- sets.OffenseMode.Retaliation = {}

	-- Aftermath sets, merged over the engaged set while the matching Aftermath is up.
	-- The engine uses the strongest active tier that has gear for the current weapon. A tier set applies with any weapon.

	sets.OffenseMode.AM = {}  -- This is for Relic AM only
	sets.OffenseMode.AM1 = {} -- All AM1 Types
	sets.OffenseMode.AM2 = {} -- All AM2 Types
	sets.OffenseMode.AM3 = {} -- All AM3 Types

	-- A child keyed by a weapon mode adds gear for that weapon alone. These are examples. The key must be a name in the state.WeaponMode options list above, or nothing reads it.
	sets.OffenseMode.AM['Bravura'] = {}
	sets.OffenseMode.AM1['Ukonvasara'] = {}
	sets.OffenseMode.AM2['Ukonvasara'] = {}
	sets.OffenseMode.AM3['Ukonvasara'] = {}
	sets.OffenseMode.AM3['Farsha'] = {}
	sets.OffenseMode.AM1['Conqueror'] = {}
	sets.OffenseMode.AM2['Laphria'] = {}

	-- Merged over the engaged set while the Dual Wield trait is active.
	sets.DualWield = {
		waist=gear.reiki,
		right_ear=gear.eabani,
	}

	-- The precast base for spells and ranged attacks.
	sets.Precast = set_combine(sets.Idle, {})

	-- Merged over the fast cast set for cures. Cure cast time reduction goes here.
	sets.Precast.Cure = {}

	-- Merged over the fast cast set for enhancing magic. Enhancing cast time reduction goes here.
	sets.Precast.Enhancing = {}

	-- Worn at the start of every spell. Fast cast gear goes here.
	sets.Precast.FastCast = {
		ammo=gear.sapience, --2
		head=gear.sakpataHead, --8
		body=gear.sacroBody, --10
		hands = gear.leylineGlovesFCB, --8
		neck=gear.voltsurge, -- 4
		left_ear=gear.etiolation, --1
		right_ear=gear.loquacious, -- 3
		left_ring=gear.prolix, -- 2
		right_ring = gear.gelatinousPlusOne,
	} --44%

	-- Enmity gear. The engine never reads this set by name. It is worn as the Provoke set below.
	sets.Precast.Enmity = {
		ammo=gear.sapience, -- 2
		head = gear.souveranHeadPlusOnePathC, --9
		body = gear.souveranBodyPlusOnePathC, --20
		hands = gear.souveranHandsPlusOnePathC, --9
		legs = gear.souveranLegsPlusOnePathC, --9
		feet = gear.souveranFeetPlusOnePathC, --9
		neck=gear.moonlightNeck, --15
		left_ear=gear.crypticEarring, --4
		right_ear=gear.truxEarring, --5
		left_ring=gear.petrov, --4
		right_ring=gear.eihwazRing, --5
	} --91

	-- A precast set named for one spell is merged over the fast cast set in place of that spell's family set.
	sets.Precast['Utsusemi: Ichi'] = {}
	sets.Precast['Utsusemi: Ni'] = {}

	-- Ranged attack precast, where snapshot gear goes. Flurry merges the Flurry set over it, and Flurry II or Embrava merges the Flurry_II set.
	sets.Precast.RA = {}
	sets.Precast.RA.Flurry = {}
	sets.Precast.RA.Flurry_II = {}

	-- The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {})

	-- Spell interruption rate down. Merged under every midcast except a ranged attack, so any specific set overwrites it.
	sets.Midcast.SIRD = {
	    ammo=gear.staunchPlusOne, --11
		--feet={ name="Odyssean Greaves", augments={'Attack+1','"Fast Cast"+6',}}, --20
		neck=gear.moonlightNeck, --15
		left_ear=gear.magneticEarring, --8
		waist=gear.audumbla, --10
	}

	-- Enhancing magic. Healing spells other than cures, such as Raise and the -na spells, use it too.
	-- sets.Midcast.Enhancing.Others is merged over it when the target is not you, or when Accession is up.
	sets.Midcast.Enhancing = {}
	sets.Midcast.Enhancing.Others = {}
	
	-- Enfeebling magic. The set below that lists the spell is merged over it.
	sets.Midcast.Enfeebling = {}
	-- Accuracy based ('Dispel','Aspir','Aspir II','Aspir III','Drain','Drain II','Drain III','Frazzle','Frazzle II','Stun','Poison','Poison II','Poisonga')
	sets.Midcast.Enfeebling.MACC = {}
	-- Potency based ('Paralyze','Paralyze II','Slow','Slow II','Addle','Addle II','Distract','Distract II','Distract III','Frazzle III','Blind','Blind II','Gravity','Gravity II')
	sets.Midcast.Enfeebling.Potency = {}
	-- Duration based ('Sleep','Sleep II','Sleepga','Sleepga II','Diaga','Dia','Dia II','Dia III','Bio','Bio II','Bio III','Silence','Inundation','Break','Breakga','Bind','Bindga')
	sets.Midcast.Enfeebling.Duration = {}

	-- Ranged attack midcast. In every offense mode but TP, the set named for the mode is merged over it.
    sets.Midcast.RA = {}
    sets.Midcast.RA.ACC = {}
    sets.Midcast.RA.PDL = {}
	sets.Midcast.RA.CRIT = {}
	sets.Midcast.RA.AM3 = {}

	-- Cures, and the Regen set merged over the enhancing set for Regen spells. The Curaga set starts from a copy of the Cure set.
	sets.Midcast.Cure = {}
	sets.Midcast.Curaga = set_combine(sets.Midcast.Cure, {})
	sets.Midcast.Regen = {}

	-- Dancer abilities, for the dancer subjob. Each family set is worn for every ability of its kind, and a set named for one ability is merged over it.
	sets.Flourish = set_combine(sets.Idle.DT, {})
	sets.Jig = set_combine(sets.Idle.DT, {})
	sets.Step = set_combine(sets.OffenseMode.DT, {})
	sets.Waltz = set_combine(sets.OffenseMode.DT, {})

	-- A set named for one spell replaces its family set for that spell, so Stoneskin skips the enhancing set. Cures are the exception and always take the Cure, Curaga or Cura set.
	sets.Midcast["Stoneskin"] = {
		waist=gear.siegel,
	}
	sets.Midcast['Utsusemi: Ichi'] = {}
	sets.Midcast['Utsusemi: Ni'] = {}

	-- Job abilities. sets.JA is the base for every job ability, and a set named for the ability is merged over it.
	sets.JA = {}
	sets.JA["Mighty Strikes"] = {}
	sets.JA["Berserk"] = {body=gear.pummelerBodyPlusThree}
	sets.JA["Warcry"] = {head = gear.agogeHeadPlusThree}
	sets.JA["Defender"] = {}
	sets.JA["Aggressor"] = {}
	sets.JA["Provoke"] = sets.Precast.Enmity
	sets.JA["Tomahawk"] = {ammo=gear.throwingTomahawk,} -- Need to add feet
	sets.JA["Retaliation"] = {}
	sets.JA["Restraint"] = {}
	sets.JA["Blood Rage"] = {}
	sets.JA["Brazen Rush"] = {}

	-- The base for every weaponskill. A set named for the weaponskill is merged over it.
	sets.WS = {
		ammo=gear.knobkierrie,
		head = gear.agogeHeadPlusThree,
		body=gear.pummelerBodyPlusThree,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.warriorsBeadPlusTwo,
		waist = gear.sailfi,
		left_ear=gear.thrud,
		right_ear=gear.boiiEarringPlusOne,
		left_ring=gear.karieyhRingPlusOne,
		right_ring=gear.regalRing,
		back = gear.warWSDSTR
	}
	sets.WS.RA = {}

	-- A building block for weaponskill damage sets. WSD is not an offense mode, so this set is worn only through the sets built from it.
	sets.WS.WSD = {}

	-- Weaponskill sets per offense mode, merged after the set named for the weaponskill so their slots win. Never merged in TP mode.
	-- Each names only the slots its mode changes, so a weaponskill's own set keeps every other slot.
	-- A weaponskill's own mode set, such as sets.WS['Savage Blade'].PDL, is used in place of these where it exists.
	sets.WS.MEVA = {
		head = gear.sakpataHead,
		body = gear.sakpataBody,
	    neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
	}

	-- In CRIT mode, lays these crit pieces over each weaponskill's own set. Slots it does not name keep the weaponskill's own.
	-- Decimation and Impulse Drive below use it as their own set, over sets.WS.
	sets.WS.CRIT = {
		ammo=gear.yetshilaPlusOne,
		head = gear.sakpataHead,
		body=gear.hjarrandiBody,
		hands = gear.sakpataHands,
		legs = gear.sakpataLegs,
		feet = gear.sakpataFeet,
		left_ear = gear.schere,
		left_ring=gear.niqmaddu,
		right_ring=gear.lehkoHabhokaRing,
	}
	sets.WS.RA.CRIT = {}

	sets.WS.ACC = {}
	sets.WS.RA.ACC = {}

	sets.WS.SB = sets.Subtle_Blow

	sets.WS.RA.SB = {}

	sets.WS.PDL = {}
	sets.WS.RA.PDL = {}

	-- Aftermath sets for weaponskills, merged after the weaponskill's own sets while the matching Aftermath is up. They work as the engaged Aftermath sets do.
	sets.WS.AM = {}
	sets.WS.AM1 = {}
	sets.WS.AM2 = {}
	sets.WS.AM3 = {}

	sets.WS.AM1['Ukonvasara'] = {}
	sets.WS.AM2['Ukonvasara'] = {}
	sets.WS.AM3['Ukonvasara'] = {}

	sets.WS.RA.AM = {}
	sets.WS.RA.AM1 = {}
	sets.WS.RA.AM2 = {}
	sets.WS.RA.AM3 = {}

	-- Ranged Aftermath children keyed by weapon mode, as examples. The key must be a name in the state.WeaponMode options list above, or nothing reads it.
	sets.WS.RA.AM1['Some Relic Gun'] = {}
	sets.WS.RA.AM2['Some Relic Gun'] = {}
	sets.WS.RA.AM3['Some Relic Gun'] = {}

	-- Great axe weaponskills
	sets.WS["Ukko's Fury"] = {
	    ammo=gear.yetshilaPlusOne,
		head = gear.sakpataHead,
		body = gear.sakpataBody,
		hands = gear.sakpataHands,
		legs = gear.sakpataLegs,
		feet = gear.sakpataFeet,
		neck = gear.warriorsBeadPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.schere,
		right_ear = gear.boiiEarringPlusOneCrit,
		left_ring=gear.niqmaddu,
		right_ring=gear.lehkoHabhokaRing,
		back = gear.warWSDSTR,
	}
	sets.WS["Upheaval"] = {
	    ammo=gear.knobkierrie,
		head = gear.agogeHeadPlusThree,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.warriorsBeadPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.thrud,
		left_ring=gear.niqmaddu,
		right_ring=gear.regalRing,
		back = gear.warWSDSTR,
	}
	sets.WS["Full Break"] = {
		ammo=gear.knobkierrie,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.warriorsBeadPlusTwo,
		waist = gear.sailfi,
		left_ear=gear.thrud,
		right_ear = gear.boiiEarringPlusOneCrit,
		left_ring=gear.karieyhRingPlusOne,
		right_ring=gear.regalRing,
		back = gear.warWSDSTR,
	}

	-- Axe weaponskills
	sets.WS["Raging Axe"] = {}
	sets.WS["Smash Axe"] = {}
	sets.WS["Gale Axe"] = {}
	sets.WS["Avalanche Axe"] = {}
	sets.WS["Spinning Axe"] = {}
	sets.WS["Rampage"] = {}
	sets.WS["Calamity"] = {}
	sets.WS["Mistral Axe"] = {}
	sets.WS["Decimation"] = sets.WS.CRIT
	sets.WS["Bora Axe"] = {}
	sets.WS["Cloudsplitter"] = {}

	-- Sword weaponskills
	sets.WS["Fast Blade"] = {}
	sets.WS["Burning Blade"] = {}
	sets.WS["Red Lotus Blade"] = {}
	sets.WS["Flat Blade"] = {}
	sets.WS["Shining Blade"] = {}
	sets.WS["Seraph Blade"] = {}
	sets.WS["Circle Blade"] = {}
	sets.WS["Spirits Within"] = {}
	sets.WS["Vorpal Blade"] = {}
	sets.WS["Savage Blade"] = set_combine(sets.WS.WSD, {})
	sets.WS["Savage Blade"]['PDL'] = set_combine(sets.WS.WSD, {
		head = gear.sakpataHead,
	})

	sets.WS["Sanguine Blade"] = {}
	sets.WS["Requiescat"] = {}

	-- Polearm weaponskills
	sets.WS["Impulse Drive"] = sets.WS.CRIT
	sets.WS["Leg Sweep"] = {
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.warriorsBeadPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear = gear.boiiEarringPlusOneCrit,
		left_ring=gear.karieyhRingPlusOne,
		right_ring=gear.regalRing,
		back = gear.warWSDSTR,
	}

	-- Treasure Hunter gear. In every TH mode but None, it is worn on the action that tags a monster and while engaged on an untagged one.
	-- Full Time also wears it whenever you are engaged. Every job but Thief starts in None.
	sets.TreasureHunter = {
		ammo=gear.perfectEgg,
		waist=gear.chaac,
		body=gear.volteJupon,
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
