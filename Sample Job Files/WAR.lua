-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: Warrior. A sample to copy into your character's folder and fill in.
--
-- How this file is laid out. The lines above get_sets() are your options: the offense, weapon and
-- job modes you cycle through in game, and the lockstyle and macro book the file sets when it
-- loads. get_sets() holds your gear sets, one section for each kind: weapons, idle, engaged
-- (sets.OffenseMode), precast, midcast, job abilities and weaponskills. The comment above each set
-- says when it is worn and what it is merged over. A set named for a mode, a spell, an ability or a
-- buff is merged over the set it sits under, and any slot it leaves empty keeps the gear from
-- underneath. Gear comes from the gear library as gear.<name>, or by its item name in quotes.
--
-- How to change it. Fill in the sets you use and leave the rest empty. An empty set is just a
-- placeholder. The engine tells you in chat when the set it picks for a spell's or a ranged
-- attack's midcast, or for an ability, weaponskill, item or pet move, is empty. It does not name
-- an empty precast set for a spell, or an empty idle or engaged set. gs c checksets shows how
-- many sets have gear and lists the empty ones, and gs c gearreporting shows which sets each
-- action used. Below the DO NOT EDIT line are the hooks for job-specific rules. The comment above
-- each hook says when it runs, and any table a hook returns is merged over the engine's gear.
--
-- A job file written for Mirdain-Include still loads once its include line is replaced by the two
-- lines at the top of this file (see Upgrading from Mirdain-Include in the README). Its job logic
-- lives in these same hooks, and whatever a hook returns is merged over the engine's sets, so any
-- slot it fills overrides the engine's buff, burst and mode sets. Only the gear the engine keeps for
-- the action goes on after it: Daybreak for Dispelga, the Impact cloak, a song's instrument, Yagrush
-- for a White Mage's Cursna, the item a Tomahawk or Angon throws, and the weapons a weaponskill keeps
-- in hand. It is best to convert an old file to this layout and move that logic into sets, so the
-- engine can layer each set where it belongs.

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
-- Every mode offered here needs both a sets.OffenseMode.<Mode> entry and a sets.Idle.<Mode> entry.
-- The engine warns in chat each time it looks for a missing one.
state.OffenseMode:options('TP','ACC','DT','PDT','MEVA','CRIT','SB')

-- The offense mode to start in.
state.OffenseMode:set('DT')

-- The weapon modes, each naming a sets.Weapons entry below, and the one to start in.
state.WeaponMode:options('Chango','Shining One','Savage Blade','Decimation','Axe','Aeolian Edge', 'Ukonvasara','Labraunda')
state.WeaponMode:set('Chango')

-- The weapon lock, and the one to start in. Unlocked lets any set change your weapons. Locked keeps
-- the pair your weapon mode names, and the TP on it, through every action, except where the engine
-- itself must put on a weapon: one a spell needs, sets.Weapons.Sleep while you are asleep, and a
-- Spell Received set.
state.WeaponLock:options('Unlocked','Locked')
state.WeaponLock:set('Unlocked')

-- The buff level, and the one to start in. Only weaponskills read it: at HighBuff they wear their
-- HighBuff children, and at MidBuff only a weaponskill's own MidBuff child.
state.BuffLevel:options('MidBuff','HighBuff')
state.BuffLevel:set('MidBuff')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	-- One weapon set per weapon mode, keyed by the mode's name.
	sets.Weapons = {}

	sets.Weapons['Chango'] = {
		main = gear.chango,
		sub = gear.utu,
	}
	sets.Weapons['Labraunda'] = {
		main = gear.labraunda,
		sub = gear.utu,
	}
	sets.Weapons['Shining One'] = {
		main = gear.shiningOne,
		sub = gear.utu,
	}
	sets.Weapons['Savage Blade'] = {
		main = gear.naegling,
		sub = gear.zantetsuken,
	}
	sets.Weapons['Decimation'] = {
		main = gear.dolichenus,
		sub = gear.zantetsuken,
	}
	sets.Weapons['Axe'] = {
		main = gear.ikengaAxe,
		sub = gear.zantetsuken,
	}
	sets.Weapons['Aeolian Edge'] = {
		main = gear.ternionDaggerPlusOne,
		sub = gear.naegling,
	}
	sets.Weapons['Ukonvasara'] = {
		main = gear.chango,
		sub = gear.utu,
	}
	-- Worn in the offhand, idle or engaged, whenever the main is one-handed and no dual-wield trait
	-- is active.
	sets.Weapons.Shield = {
		sub = gear.blurredShield,
	}
	-- Worn over the idle set when you are put to sleep, and held until the sleep ends. A piece that
	-- drains HP wakes you on its first tick.
	sets.Weapons.Sleep = {}

	-- ===================================================================================================================
	--		sets.Idle
	-- ===================================================================================================================

	-- Worn while idle. Every precast and midcast also starts from this set, so any slot an action's
	-- set leaves empty keeps your idle gear.
	sets.Idle = {
		ammo = gear.staunchPlusOne,
		head = gear.sakpataHead,
		body = gear.sakpataBody,
		hands = gear.sakpataHands,
		legs = gear.sakpataLegs,
		feet = gear.sakpataFeet,
		neck = gear.loricatePlusOne,
		waist = gear.carriers,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.eabani,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.warDAAcc,
	}

	-- Idle sets per offense mode, merged over sets.Idle in the matching mode. sets.Idle.Resting is
	-- merged while you rest.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.Resting = {}
	sets.Idle.PDT = set_combine(sets.Idle, {})
	sets.Idle.CRIT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
	})

	-- Merged over the idle set while you have a Phantom Roll of 11. It is meant for Roller's Ring,
	-- which every job can wear and which gives Refresh +1 and Regain +10 on an 11, e.g.
	-- left_ring="Roller's Ring". This set applies in every offense mode. sets.Idle.TP.XIRoll
	-- applies in TP mode only and is merged after it. It is only worn while idle, so any action
	-- swaps it out and it comes back when the action ends. While you move, a ring here replaces the
	-- movement set's ring in the same slot. This file's sets.Movement has no ring, so either slot
	-- works.
	sets.Idle.XIRoll = {}
	-- The TP mode form of sets.Idle.XIRoll, merged after it.
	sets.Idle.TP.XIRoll = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = {
		feet = gear.hermesSandals,
	}

	-- Each is worn when another character on this machine, also running this engine, starts that
	-- spell or waltz on you. Spell Received mode must be ON.
	-- sets.Cursna_Received is also the doom set. With Spell Received OFF, it is worn and held while
	-- you are doomed.
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

	-- The ring slot Zodiac Ring takes on elemental magic that matches the day's element:
	-- "right_ring" or "left_ring".
	Elemental_Bonus_Ring_Slot = "right_ring"

	-- Worn when you use a Holy Water or Hallowed Water.
	sets.Holy_Water = {
		neck = gear.nicander,
	}

	-- Subtle Blow gear. The engine does not automatically merge this set into any others. It is
	-- worn as the SB weaponskill set below. 10 + 19 for Auspice
	sets.Subtle_Blow = {
		body = gear.dagonBreastplate, -- 10 SB II
		feet = gear.sakpataFeet, -- 15 SB I
		hands = gear.sakpataHands, -- 8 SB I
		left_ring = gear.niqmaddu, -- 5 SB II
	}

	--WAR Double attack
	--28% Job Trait
	--5% Merits

	-- ===================================================================================================================
	--		sets.OffenseMode
	-- ===================================================================================================================

	-- The engaged base, worn in every offense mode. The set named for the current mode is merged
	-- over it, and the mode sets below start from a copy of it.
	sets.OffenseMode = {
		ammo = gear.coiste, -- 3 DA
		head = gear.flammaHeadPlusTwo,
		body = gear.dagonBreastplate,
		hands = gear.sakpataHands,
		legs = gear.pummelerLegsPlusThree,
		feet = gear.pummelerFeetPlusThree,
		neck = gear.warriorsBeadPlusTwo, -- 7 DA
		waist = gear.sailfi, -- 5 DA
		left_ear = gear.schere, -- 3 DA
		right_ear = gear.boiiEarringPlusOne, -- 8 DA
		left_ring = gear.niqmaddu,
		right_ring = gear.lehkoHabhokaRing,
		back = gear.nullShawl,
	}

	sets.OffenseMode.TP = set_combine( sets.OffenseMode, {})
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {})
	sets.OffenseMode.CRIT = set_combine(sets.OffenseMode, {})

	sets.OffenseMode.DT = set_combine( sets.OffenseMode, {
		head = gear.hjarrandiHead,
		body = gear.sakpataBody,
		hands = gear.sakpataHands, -- 6 DA
		legs = gear.sakpataLegs, -- 7 DA
		feet = gear.sakpataFeet, -- 4 DA
	}) -- 100% DA

	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, {
		ammo = gear.coiste,
		head = gear.sakpataHead,
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
		left_ring = gear.moonlightRing,
		right_ring = gear.lehkoHabhokaRing,
	})

	-- The most Subtle Blow this set reaches is SB 50 and SB II 15. It needs Auspice (29) to cap.
	sets.OffenseMode.SB = set_combine(sets.OffenseMode, {
		head = gear.hjarrandiHead,
		body = gear.sakpataBody,
		legs = gear.sakpataLegs,
		feet = gear.sakpataFeet,
	})
	sets.OffenseMode.PDT = set_combine(sets.OffenseMode, {})

	-- Buff sets for the engaged set. Uncomment one to use it. Each is worn over the engaged set in
	-- every offense mode while its buff is up, and its slots win over the mode set.
	-- Worn while engaged with Restraint up. Restraint's weaponskill damage bonus builds from your
	-- melee hits, and Boii Mufflers raise that bonus. They need not be worn for the weaponskill
	-- itself.
	-- sets.OffenseMode.Restraint = {}
	-- Worn while engaged with Retaliation up. Boii Calligae and Pummeler's Mufflers raise the
	-- damage your retaliations deal.
	-- sets.OffenseMode.Retaliation = {}
	-- Worn while engaged with Defender up. Agoge Mufflers raise your chance to block with a shield
	-- while Defender is up.
	-- sets.OffenseMode.Defender = {}

	-- Aftermath sets, merged over the engaged set while the matching Aftermath is up.
	-- The engine uses the strongest active tier that has gear for the current weapon. A tier set
	-- applies with any weapon.

	sets.OffenseMode.AM = {}  -- This is for Relic AM only
	sets.OffenseMode.AM1 = {} -- All AM1 Types
	sets.OffenseMode.AM2 = {} -- All AM2 Types
	sets.OffenseMode.AM3 = {} -- All AM3 Types

	-- A child set named for a weapon mode adds gear for that weapon only, over the tier set. The
	-- engine reads a child only when its name is one of the state.WeaponMode options above, so the
	-- Ukonvasara sets below are worn in the Ukonvasara mode. The commented lines are examples for
	-- weapons this file has no mode for: add the mode, then uncomment its line.
	-- sets.OffenseMode.AM['Bravura'] = {}
	sets.OffenseMode.AM1['Ukonvasara'] = {}
	sets.OffenseMode.AM2['Ukonvasara'] = {}
	sets.OffenseMode.AM3['Ukonvasara'] = {}
	-- sets.OffenseMode.AM3['Farsha'] = {}
	-- sets.OffenseMode.AM1['Conqueror'] = {}
	-- sets.OffenseMode.AM2['Laphria'] = {}

	-- Merged over the engaged set while the Dual Wield trait is active and the main weapon is
	-- one-handed. A two-handed or hand-to-hand main skips it.
	sets.DualWield = {
		waist = gear.reiki,
		right_ear = gear.eabani,
	}

	-- Treasure Hunter gear. In every TH mode but None, it is worn on the action that tags a monster
	-- and while engaged on an untagged one. Full Time also wears it whenever you are engaged. Every
	-- job but Thief starts in None.
	sets.TreasureHunter = {
		ammo = gear.perfectEgg,
		waist = gear.chaac,
		body = gear.volteJupon,
	}

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Every precast starts from sets.Idle, except a pet command's. For a spell or a ranged attack,
	-- sets.Precast is merged over it, then the fast cast set for a spell or sets.Precast.RA for a
	-- ranged attack. Any slot left empty keeps your idle gear.
	sets.Precast = set_combine(sets.Idle, {})

	-- Worn at the start of every spell. Fast cast gear goes here.
	sets.Precast.FastCast = {
		ammo = gear.sapience, --2
		head = gear.sakpataHead, --8
		body = gear.sacroBody, --10
		hands = gear.leylineGlovesFCB, --8
		neck = gear.voltsurge, -- 4
		left_ear = gear.etiolation, --1
		right_ear = gear.loquacious, -- 3
		left_ring = gear.prolix, -- 2
		right_ring = gear.gelatinousPlusOne,
	} --44%

	-- Enmity gear for Provoke. sets.JA["Provoke"] below points to this same set. The engine does
	-- not automatically merge this set into any others.
	sets.Enmity = {
		ammo = gear.sapience, -- 2
		head = gear.souveranHeadPlusOnePathC, --9
		body = gear.souveranBodyPlusOnePathC, --20
		hands = gear.souveranHandsPlusOnePathC, --9
		legs = gear.souveranLegsPlusOnePathC, --9
		feet = gear.souveranFeetPlusOnePathC, --9
		neck = gear.moonlightNeck, --15
		left_ear = gear.crypticEarring, --4
		right_ear = gear.truxEarring, --5
		left_ring = gear.petrov, --4
		right_ring = gear.eihwazRing, --5
	} --91

	-- Merged over the fast cast set when you cast Utsusemi.
	sets.Precast.Utsusemi = {}

	-- A precast set named for one spell is merged over the fast cast set instead of that spell's
	-- family set, even when it is empty, so only uncomment a line after you fill it in.
	-- sets.Precast['Utsusemi: Ichi'] = {}
	-- sets.Precast['Utsusemi: Ni'] = {}

	-- Ranged attack precast, where snapshot gear goes. Flurry merges the Flurry set over it, and
	-- Flurry II or Embrava merges the Flurry_II set. Name the round you shoot here and in
	-- sets.Midcast.RA below. Without one the ammo slot keeps your idle ammo, and the engine cancels
	-- the shot unless you carry at least two of what that slot holds.
	sets.Precast.RA = {}
	sets.Precast.RA.Flurry = {}
	sets.Precast.RA.Flurry_II = {}

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- The base for every cast, merged over sets.Idle on every midcast, so any slot it leaves empty
	-- keeps your idle gear.
	sets.Midcast = set_combine(sets.Idle, {})

	-- Spell interruption rate down. Used under every midcast except ranged attacks, so any more
	-- specific set overrides it.
	sets.Midcast.SIRD = {
		ammo = gear.staunchPlusOne, --11
		--feet={ name="Odyssean Greaves", augments={'Attack+1','"Fast Cast"+6',}}, --20
		neck = gear.moonlightNeck, --15
		left_ear = gear.magneticEarring, --8
		waist = gear.audumbla, --10
	}

	-- Merged over the spell interruption set when you cast Utsusemi from your ninja subjob.
	sets.Midcast.Utsusemi = {}
	-- Merged over the Utsusemi set in DT or MEVA mode.
	-- sets.Midcast.Utsusemi.DT = {}
	-- sets.Midcast.Utsusemi.MEVA = {}

	-- Self-cast ninjutsu from your ninja subjob, such as Tonko and Monomi.
	sets.Midcast.Enhancing = {}
	-- Merged over the enhancing set in DT or MEVA mode.
	-- sets.Midcast.Enhancing.DT = {}
	-- sets.Midcast.Enhancing.MEVA = {}

	-- Enfeebling ninjutsu from your ninja subjob, such as Kurayami and Hojo.
	sets.Midcast.Enfeebling = {}
	-- Merged over the enfeebling set in DT or MEVA mode.
	-- sets.Midcast.Enfeebling.DT = {}
	-- sets.Midcast.Enfeebling.MEVA = {}

	-- Ranged attack midcast. In every offense mode but TP, the set named for the mode is merged
	-- over it. Name the same round here as in sets.Precast.RA, so the ammo slot keeps it through
	-- the shot.
	sets.Midcast.RA = {}
	sets.Midcast.RA.ACC = {}
	sets.Midcast.RA.CRIT = {}
	sets.Midcast.RA.AM3 = {}

	-- A midcast set named for one spell replaces its family set for that spell, even when it is
	-- empty, so only uncomment a line after you fill it in.
	-- sets.Midcast['Utsusemi: Ichi'] = {}
	-- sets.Midcast['Utsusemi: Ni'] = {}

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is merged over sets.Idle for every job ability, then the set named for
	-- the ability is merged over it. Any slot left empty keeps your idle gear.
	sets.JA = {}
	sets.JA["Mighty Strikes"] = {}
	sets.JA["Berserk"] = {body=gear.pummelerBodyPlusThree}
	sets.JA["Warcry"] = {head = gear.agogeHeadPlusThree}
	sets.JA["Defender"] = {}
	sets.JA["Aggressor"] = {}
	sets.JA["Provoke"] = sets.Enmity
	sets.JA["Tomahawk"] = {ammo=gear.throwingTomahawk,} -- Need to add feet
	sets.JA["Retaliation"] = {}
	sets.JA["Restraint"] = {}
	sets.JA["Blood Rage"] = {}
	sets.JA["Brazen Rush"] = {}

	-- Dancer abilities from your dancer subjob. Each of these sets is merged over sets.Idle for its
	-- kind of ability (they do not use sets.JA), and a set named for one ability is merged over it.
	-- Built from sets.OffenseMode.DT, each keeps you in that defensive gear while the ability goes
	-- off.
	sets.Step = set_combine(sets.OffenseMode.DT, {})
	sets.Waltz = set_combine(sets.OffenseMode.DT, {})

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- The base for every weaponskill, merged over sets.Idle. A set named for the weaponskill is
	-- merged over it. Any slot left empty keeps your idle gear.
	sets.WS = {
		ammo = gear.knobkierrie,
		head = gear.agogeHeadPlusThree,
		body = gear.pummelerBodyPlusThree,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.warriorsBeadPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.thrud,
		right_ear = gear.boiiEarringPlusOne,
		left_ring = gear.karieyhRingPlusOne,
		right_ring = gear.regalRing,
		back = gear.warWSDSTR
	}
	-- Merged over sets.WS on every ranged weaponskill. Name the round you shoot here. Without one
	-- the ammo slot keeps sets.WS's ammo, and the engine cancels a ranged weaponskill unless you
	-- carry at least two of what that slot holds.
	sets.WS.RA = {}

	-- A building block for weaponskill damage sets. WSD is not an offense mode, so this set is worn
	-- only through the sets built from it.
	sets.WS.WSD = {}

	-- Weaponskill sets for each offense mode, merged after the set named for the weaponskill so
	-- their gear wins. Never merged in TP mode. Each only fills in the slots its mode changes, so a
	-- weaponskill's own set keeps every other slot. A weaponskill's own mode set, such as
	-- sets.WS['Savage Blade'].ACC, is used instead of these where it exists.
	sets.WS.MEVA = {
		head = gear.sakpataHead,
		body = gear.sakpataBody,
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
	}

	-- In CRIT mode, lays these crit pieces over each weaponskill's own set. Slots it does not name
	-- keep the weaponskill's own.
	-- Decimation and Impulse Drive below use it as their own set, over sets.WS.
	sets.WS.CRIT = {
		ammo = gear.yetshilaPlusOne,
		head = gear.sakpataHead,
		body = gear.hjarrandiBody,
		hands = gear.sakpataHands,
		legs = gear.sakpataLegs,
		feet = gear.sakpataFeet,
		left_ear = gear.schere,
		left_ring = gear.niqmaddu,
		right_ring = gear.lehkoHabhokaRing,
	}
	sets.WS.RA.CRIT = {}

	sets.WS.ACC = {}
	sets.WS.RA.ACC = {}

	sets.WS.SB = sets.Subtle_Blow

	sets.WS.RA.SB = {}

	-- Aftermath sets for weaponskills, merged after the weaponskill's own sets while the matching
	-- Aftermath is up. They work as the engaged Aftermath sets do.
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

	-- Ranged Aftermath child sets named for a weapon mode, as examples. The engine reads one only
	-- when its name is one of the state.WeaponMode options above: add the mode, then uncomment its
	-- lines.
	-- sets.WS.RA.AM1['Some Relic Gun'] = {}
	-- sets.WS.RA.AM2['Some Relic Gun'] = {}
	-- sets.WS.RA.AM3['Some Relic Gun'] = {}

	-- Merged in DT mode after the set named for the weaponskill, so its gear wins, for damage taken
	-- gear. A weaponskill with its own DT set uses that instead. Every slot here costs some of the
	-- weaponskill's damage, so uncomment it only once you fill it in.
	-- sets.WS.DT = {}

	-- Merged over every weaponskill while Buff Level (Alt+F12) is set to HighBuff, for physical
	-- damage limit gear. At MidBuff, the default, no set is used here. In any offense mode except
	-- TP, the set for that mode and level is merged after it, such as sets.WS.ACC.HighBuff in ACC
	-- mode. A ranged weaponskill uses the same sets under sets.WS.RA instead, such as
	-- sets.WS.RA.HighBuff. A weaponskill's own child sets replace these for that weaponskill, as
	-- shown at the end of this section.
	sets.WS.HighBuff = {}
	sets.WS.ACC.HighBuff = {}
	sets.WS.RA.HighBuff = {}
	sets.WS.RA.ACC.HighBuff = {}

	-- Great axe weaponskills
	sets.WS["Ukko's Fury"] = {
		ammo = gear.yetshilaPlusOne,
		head = gear.sakpataHead,
		body = gear.sakpataBody,
		hands = gear.sakpataHands,
		legs = gear.sakpataLegs,
		feet = gear.sakpataFeet,
		neck = gear.warriorsBeadPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.schere,
		right_ear = gear.boiiEarringPlusOneCrit,
		left_ring = gear.niqmaddu,
		right_ring = gear.lehkoHabhokaRing,
		back = gear.warWSDSTR,
	}
	sets.WS["Upheaval"] = {
		ammo = gear.knobkierrie,
		head = gear.agogeHeadPlusThree,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.warriorsBeadPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear = gear.thrud,
		left_ring = gear.niqmaddu,
		right_ring = gear.regalRing,
		back = gear.warWSDSTR,
	}
	sets.WS["Full Break"] = {
		ammo = gear.knobkierrie,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.warriorsBeadPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.thrud,
		right_ear = gear.boiiEarringPlusOneCrit,
		left_ring = gear.karieyhRingPlusOne,
		right_ring = gear.regalRing,
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
	sets.WS["Savage Blade"].HighBuff = {
		head = gear.sakpataHead,
	}

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
		left_ring = gear.karieyhRingPlusOne,
		right_ring = gear.regalRing,
		back = gear.warWSDSTR,
	}

	-- Dagger weaponskills
	-- The Aeolian Edge mode's weaponskill. It is on the engine's list of magical weaponskills, so
	-- the day, weather and distance pieces the engine picks go on over this set.
	sets.WS["Aeolian Edge"] = {}

	-- Child sets for a single weaponskill, used instead of the general sets.WS ones: one for a
	-- mode, one for HighBuff, and one for the two together. Once declared, each one replaces the
	-- general set for that weaponskill even if it is empty, so only uncomment a line after you fill
	-- it in. The mode and HighBuff line also needs the mode line above it.
	-- sets.WS["Upheaval"].ACC = {}
	-- sets.WS["Upheaval"].HighBuff = {}
	-- sets.WS["Upheaval"].ACC.HighBuff = {}

end

-------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE UNLESS YOU NEED TO MAKE JOB SPECIFIC RULES
-------------------------------------------------------------------------------------------------------------------

-- Called when the subjob changes.
function sub_job_change_custom(new, old)
	-- A common use is switching the macro book or set.
end

-- Called before each action, after the engine's own checks. Call cancel_spell() here to stop the
-- action.
function pretarget_custom(spell,action)

end

-- Called as each action starts. The table it returns is merged over the engine's precast set.
function precast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called while each action is in progress. The table it returns is merged over the engine's midcast
-- set, which is empty for abilities, weaponskills and items.
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

-- Called when a buff is gained or lost. The table it returns is merged over the rebuilt idle or
-- engaged set. If one of your own actions is still in progress, it is still called right away, but
-- the table it returns is not used, and the gear change happens when that action ends.
function buff_change_custom(name,gain)
	local equipSet = {}

	return equipSet
end

-- Called whenever the engine rebuilds the idle or engaged set, which it does after each action, on
-- a buff or status change, and when movement starts or stops. The table it returns is merged over
-- that set.
function choose_set_custom()
	local equipSet = {}

	return equipSet
end

-- Called when the player's status changes, such as engaging, disengaging or resting. The table it
-- returns is merged over the rebuilt idle or engaged set. If one of your own actions is still in
-- progress, the table is not used, and the gear change happens when that action ends.
function status_change_custom(new,old)
	local equipSet = {}

	return equipSet
end

-- Called with any "gs c" command the engine does not handle itself, in lowercase. Use it to add
-- your own commands. The Weapon Mode, Job Mode and Job Mode 2 commands also call it, before they
-- change your gear.
function self_command_custom(command)

end

-- Called when the job file unloads, after the engine releases its keybinds and slot holds.
function user_file_unload()

end

-- Called when a pet is summoned or lost. The table it returns is merged over the rebuilt idle or
-- engaged set. If one of your own actions is still in progress, it is still called, but the table
-- it returns is not used, and the gear change happens when that action ends.
function pet_change_custom(pet,gain)
	local equipSet = {}

	return equipSet
end

-- Called when a pet's action ends. The table it returns is merged over the idle or engaged set the
-- engine rebuilds. If one of your own actions is still in progress, it is still called, but the
-- table it returns is not used, and the gear change happens when that action ends.
function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called while your pet's action is in progress. The table it returns is merged over the pet's
-- midcast sets.
function pet_midcast_custom(spell)
	local equipSet = {}

	return equipSet
end
