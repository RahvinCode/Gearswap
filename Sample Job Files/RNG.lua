-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: Ranger. A sample to copy into your character's folder and fill in.
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
LockStylePallet = "14"
MacroBook = "13" -- A macro book per subjob can be set in sub_job_change_custom below
MacroSet = "1"

-- Use a Remedy on paralysis or silence, and a Holy Water on doom, automatically.
AutoItem = false

-- Pick a random lockstyle from Lockstyle_List each time this file loads.
Random_Lockstyle = false

-- The equip sets the random lockstyle picks from.
Lockstyle_List = { 1, 2, 6, 12 }

-- The food item "gs c food" uses.
Food = "Sublime Sushi"

-- Warn at precast when your ranged ammunition falls below this count.
Ammo_Warning_Limit = 99

-- The offense modes this file offers, and the one to start in. CRIT is here for critical hit builds
-- under Aftermath: Lv.3.
-- Every mode offered here needs both a sets.OffenseMode.<Mode> entry and a sets.Idle.<Mode> entry.
-- The engine warns in chat each time it looks for a missing one.
state.OffenseMode:options('TP', 'ACC', 'DT', 'CRIT', 'SB', 'True Shot')
state.OffenseMode:set('TP')

-- The weapon modes, each naming a sets.Weapons entry below, and the one to start in.
-- state.RAMode starts on Bullet, the type the starting weapon fires. Smart_Ammo below keeps it
-- matched to the weapon.
state.WeaponMode:options('Fomalhaut', 'Annihilator', 'Gastraphetes', 'Fail-Not', 'Yoichinoyumi', 'Naegling', 'Tauret',
	'Dolichenus')
state.WeaponMode:set('Fomalhaut')
state.RAMode:set('Bullet')

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

-- The name shown for JobMode in chat and on the status box. Leaving it empty hides the mode.
UI_Name = 'TP Mode'

-- The JobMode values, and the one to start in. The hooks below wear the sets.Weapons entry named
-- for the current value: Melee, Ranged and Subtle Blow each name a weapon pair there, and Standard
-- names none.
-- In Ranged, the engaged build also merges the idle set for the current offense mode.
state.JobMode:options('Standard', 'Melee', 'Ranged', 'Subtle Blow')
state.JobMode:set('Standard')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup(LockStylePallet, MacroBook, MacroSet)

-- Goal is 2000 HP
function get_sets()

	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	-- One weapon set per weapon mode, keyed by the mode's name.
	sets.Weapons = {}

	sets.Weapons['Naegling'] = {
		main = gear.naegling,
		sub = gear.gleti,
		range = gear.anarchyPlusTwo,
	}

	sets.Weapons['Fomalhaut'] = {
		main = gear.perunPlusOne,
		sub = gear.kustawiPlusOne,
		range = gear.fomalhaut,
	}

	sets.Weapons['Annihilator'] = {
		main = gear.gleti,
		sub = gear.kustawiPlusOne,
		range = gear.annihilator,
	}

	sets.Weapons['Gastraphetes'] = {
		main = gear.perunPlusOne,
		sub = gear.gleti,
		range = gear.gastraphetes,
	}

	sets.Weapons['Fail-Not'] = {
		main = gear.perunPlusOne,
		sub = gear.kustawiPlusOne,
		range = gear.failNot,
	}

	sets.Weapons['Tauret'] = {
		main = gear.tauret,
		sub = gear.ternionDaggerPlusOne,
		range = gear.anarchyPlusTwo,
	}

	sets.Weapons['Yoichinoyumi'] = {
		main = gear.perunPlusOne,
		sub = gear.kustawiPlusOne,
		range = gear.yoichinoyumi,
	}

	sets.Weapons['Dolichenus'] = {
		main = gear.dolichenus,
		sub = gear.crepuscularKnife,
		range = gear.anarchyPlusTwo,
	}

	-- Weapon sets named for the JobMode values. The hooks below wear the one for the current
	-- JobMode over every build.
	sets.Weapons.Melee = {
		main = gear.gleti,
		sub = gear.ternionDaggerPlusOne,
	}

	sets.Weapons.Ranged = {
		main = gear.perunPlusOne,
		sub = gear.kustawiPlusOne,
	}

	sets.Weapons['Subtle Blow'] = {
		main = gear.ternionDaggerPlusOne, -- SB 9
		sub = gear.gleti,           -- Used for SB II
	}

	-- Worn in the offhand, idle or engaged, whenever the main is one-handed and no dual-wield trait
	-- is active.
	sets.Weapons.Shield = {
		sub = gear.nusku,
	}

	-- The ammunition type each weapon mode fires: Bullet, Arrow or Bolt. Smart_Ammo below checks it
	-- when the weapon mode changes. That is what lets a set use ammo = Ammo.TP and get the right
	-- ammunition for the weapon.
	Ranged_Weapons = {
		{ WeaponMode = "Naegling",     Type = "Bullet" },
		{ WeaponMode = "Dolichenus",   Type = "Bullet" },
		{ WeaponMode = "Fomalhaut",    Type = "Bullet" },
		{ WeaponMode = "Annihilator",  Type = "Bullet" },
		{ WeaponMode = "Fail-Not",     Type = "Arrow" },
		{ WeaponMode = "Yoichinoyumi", Type = "Arrow" },
		{ WeaponMode = "Gastraphetes", Type = "Bolt" },
		{ WeaponMode = "Tauret",       Type = "Bullet" },
	}

	-- The rounds for each ammunition type, keyed by purpose.
	Ammo.Bullet.TP = "Chrono Bullet"     -- TP Ammo
	Ammo.Bullet.ACC = "Eradicating Bullet" -- Accuracy Ammo
	Ammo.Bullet.CRIT = "Eradicating Bullet" -- Critical Hit Mode Ammo
	Ammo.Bullet.WS = "Chrono Bullet"     -- Default WS Ammo
	Ammo.Bullet.WSD = "Chrono Bullet"    -- Weaponskill Damage
	Ammo.Bullet.MAB = "Chrono Bullet"    -- Magic Attack Bonus
	Ammo.Bullet.MACC = "Chrono Bullet"   -- Magic Accuracy
	Ammo.Bullet.MAG_WS = "Chrono Bullet" -- Magic Weaponskills
	Ammo.Bullet.PHY_WS = "Chrono Bullet" -- Physical Weaponskills

	Ammo.Arrow.TP = "Chrono Arrow"       -- TP Ammo
	Ammo.Arrow.ACC = "Chrono Arrow"      -- Accuracy Ammo
	Ammo.Arrow.CRIT = "Chrono Arrow"     -- Critical Hit Mode Ammo
	Ammo.Arrow.WS = "Chrono Arrow"       -- Default WS Ammo
	Ammo.Arrow.WSD = "Chrono Arrow"      -- Weaponskill Damage
	Ammo.Arrow.MAB = "Chrono Arrow"      -- Magic Attack Bonus
	Ammo.Arrow.MACC = "Chrono Arrow"     -- Magic Accuracy
	Ammo.Arrow.MAG_WS = "Chrono Arrow"   -- Magic Weaponskills
	Ammo.Arrow.PHY_WS = "Chrono Arrow"   -- Physical Weaponskills

	Ammo.Bolt.TP = "Quelling Bolt"       -- TP Ammo
	Ammo.Bolt.ACC = "Quelling Bolt"      -- Accuracy Ammo
	Ammo.Bolt.CRIT = "Quelling Bolt"     -- Critical Hit Mode Ammo
	Ammo.Bolt.WS = "Quelling Bolt"       -- Default WS Ammo
	Ammo.Bolt.WSD = "Quelling Bolt"      -- Weaponskill Damage
	Ammo.Bolt.MAB = "Quelling Bolt"      -- Magical Weaponskills
	Ammo.Bolt.MACC = "Quelling Bolt"     -- Magic Accuracy
	Ammo.Bolt.MAG_WS = "Quelling Bolt"   -- Magic Weaponskills
	Ammo.Bolt.PHY_WS = "Quelling Bolt"   -- Physical Weaponskills

	-- The flat keys the sets read, taken from the table for the current ammunition type. Smart_Ammo
	-- re-runs get_sets() to refresh them when the type changes.
	-- The engine also merges Ammo[<offense mode>] into the idle, engaged and ranged builds, so the
	-- TP, ACC and CRIT keys follow those modes.
	Ammo.TP = Ammo[state.RAMode.value].TP
	Ammo.ACC = Ammo[state.RAMode.value].ACC
	Ammo.CRIT = Ammo[state.RAMode.value].CRIT
	Ammo.WS = Ammo[state.RAMode.value].WS
	Ammo.WSD = Ammo[state.RAMode.value].WSD
	Ammo.MAB = Ammo[state.RAMode.value].MAB
	Ammo.MACC = Ammo[state.RAMode.value].MACC
	Ammo.MAG_WS = Ammo[state.RAMode.value].MAG_WS
	Ammo.PHY_WS = Ammo[state.RAMode.value].PHY_WS

	-- ===================================================================================================================
	--		sets.Idle
	-- ===================================================================================================================

	-- Worn while idle. Every precast and midcast also starts from this set, so any slot an action's
	-- set leaves empty keeps your idle gear.
	sets.Idle = {
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.malignanceLegs,
		feet = gear.nyameFeet,
		neck = gear.loricatePlusOne,
		waist = gear.carriers,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.sanareEarring,
		left_ring = gear.gelatinousPlusOne,
		right_ring = gear.defending,
		back = gear.rngDW,
	}
	-- Idle sets per offense mode, merged over sets.Idle in the matching mode. sets.Idle.Resting is
	-- merged while you rest.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.CRIT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {
		sub = gear.gleti,
	})
	sets.Idle.Resting = {}
	sets.Idle['True Shot'] = set_combine(sets.Idle, {})

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
		legs = gear.carmineLegsPlusOnePathA,
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

	-- ===================================================================================================================
	--		sets.OffenseMode
	-- ===================================================================================================================

	-- The engaged base, worn in every offense mode while you melee. The set named for the current
	-- mode is merged over it.
	sets.OffenseMode = {
		ammo = Ammo.TP,
		head = gear.adhemarHeadPlusOnePathA,
		body = gear.adhemarBodyPlusOnePathA,
		hands = gear.adhemarHandsPlusOnePathA,
		legs = gear.samnuhaTightsDA,
		feet = gear.malignanceFeet,
		neck = gear.scoutGorgetPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.telos,
		right_ear = gear.sherida,
		left_ring = gear.lehkoHabhokaRing,
		right_ring = gear.eponas,
		back = gear.rngDW,
	}

	-- TP mode, built for TP gain.
	sets.OffenseMode.TP = set_combine(sets.OffenseMode, {})

	-- DT mode: the base with these slots changed.
	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {
		head = gear.malignanceHead,
		body = gear.malignanceBody,
		hands = gear.aminiHandsPlusThree,
		legs = gear.aminiLegsPlusThree,
		feet = gear.malignanceFeet,
	})

	-- ACC mode: the base with these slots changed.
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {})

	-- CRIT, SB and True Shot modes, each a copy of the DT set.
	sets.OffenseMode.CRIT = set_combine(sets.OffenseMode.DT, {})

	sets.OffenseMode.SB = set_combine(sets.OffenseMode.DT, {})

	sets.OffenseMode['True Shot'] = set_combine(sets.OffenseMode.DT, {})

	-- Merged over the engaged set while you have the Dual Wield trait and your main weapon is
	-- one-handed.
	sets.DualWield = {
		back = gear.rngDW,
	}

	-- Treasure Hunter gear. In every TH mode but None, it is worn on the action that tags a monster
	-- and while engaged on an untagged one. Full Time also wears it whenever you are engaged. Every
	-- job but Thief starts in None.
	sets.TreasureHunter = {
		body = gear.volteJupon,
		feet = gear.volteBoots,
		waist = gear.chaac,
	}

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Every precast starts from sets.Idle, except a pet command's. For a spell or a ranged attack,
	-- sets.Precast is merged over it, then the fast cast set for a spell or sets.Precast.RA for a
	-- ranged attack. Any slot left empty keeps your idle gear.
	sets.Precast = { ammo = Ammo.TP, }

	-- Snapshot caps at 70. Velocity Shot is a separate term.
	-- Rapid Shot works like Quick Magic, and Snapshot works like fast cast.

	-- The True Shot sweet spot, where ranged attacks and weaponskills deal more damage. Monster
	-- size changes these distances.
	-- Gun ~6.5 yalms
	-- Short Bow ~8.6 yalms
	-- Crossbow ~10.7 yalms
	-- Long Bow ~ 11.8 yalms

	-- Flurry is 15% Snapshot
	-- Flurry II 30% Snapshot

	-- Rapid Shot is a Ranger job trait worth 30%.

	-- Ranged attack precast, where snapshot gear goes. Without Flurry, 60 Snapshot is needed,
	-- assuming 10% from merits.
	-- The numbers below read Snapshot / Rapid Shot.
	sets.Precast.RA = set_combine(sets.Precast, { -- 5 Snapshot on Perun +1 Augment if used
		head = gear.taeonChapeauSnapshot,      -- 10
		body = gear.aminiBodyPlusThree,        -- 11% Velocity Shot
		hands = gear.carmineHandsPlusOnePathD, -- 8 / 11
		legs = gear.orionLegsPlusThree,        -- 15
		feet = gear.adhemarFeetPlusOnePathD,   -- 10 / 13
		neck = gear.scoutGorgetPlusTwo,               -- 4
		waist = gear.yemaya,                   -- 0 / 5
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.tuisto,
		left_ring = gear.gelatinousPlusOne,
		right_ring = gear.crepuscularRing, -- 3
		back = gear.rngSnapshotB,    -- 10 with 2% Velocity Shot
	})                               --60 Snapshot / 29 Rapidshot / 11% Velocity Shot

	-- Merged over the ranged precast while Flurry is up. It needs 45 Snapshot.
	sets.Precast.RA.Flurry = set_combine(sets.Precast.RA, {
		head = gear.orionHeadPlusThree,
		legs = gear.adhemarLegsPlusOnePathD, -- 10/13
	})                                 --45 Snapshot / 60 Rapidshot / 11% Velocity Shot

	-- Merged over the ranged precast while Flurry II or Embrava is up. It needs 30 Snapshot.
	sets.Precast.RA.Flurry_II = set_combine(sets.Precast.RA.Flurry, {
		feet = gear.pursuerFeetPathD,
	}) --35 Snapshot / 70 Rapidshot / 11% Velocity Shot

	-- Worn at the start of every spell, such as Utsusemi. Fast cast gear goes here.
	sets.Precast.FastCast = {
		head = gear.carmineHeadPlusOnePathD, --14
		body = gear.taeonTabardFCB,    -- 9
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.herculeanTrousersFCB, --6
		feet = gear.carmineFeetPlusOnePathD, -- 8
		neck = gear.voltsurge,         --8
		waist = gear.siegel,           -- 8, enhancing magic only, so not for Utsusemi
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.etiolation,   -- 1
		left_ring = gear.gelatinousPlusOne,
		right_ring = gear.weatherspoon, -- 5
		back = gear.rngRangedSTP,      -- Need to upgrade Cape with 10% FC
	}                                  -- 77 FC, less the sash's 8 for Utsusemi (80 is cap)

	-- Merged over the fast cast set when you cast Utsusemi.
	sets.Precast.Utsusemi = {}

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- The base for every cast, merged over sets.Idle on every midcast, so any slot it leaves empty
	-- keeps your idle gear.
	sets.Midcast = set_combine(sets.Idle, {})

	-- Spell interruption rate down. Used under every midcast except ranged attacks, so any more
	-- specific set overrides it.
	sets.Midcast.SIRD = {}

	-- Ranged attack midcast. In every offense mode but TP, the set named for the mode is merged
	-- over it.
	sets.Midcast.RA = set_combine(sets.Midcast, {
		ammo = Ammo.TP,
		head = gear.arcadianHeadPlusThree,
		body = gear.aminiBodyPlusThree,
		hands = gear.aminiHandsPlusThree,
		legs = gear.aminiLegsPlusThree,
		feet = gear.ikengaFeet,
		neck = gear.iskur,
		waist = gear.tellenBelt,
		left_ear = gear.telos,
		right_ear = gear.crepuscularEar,
		left_ring = gear.chirichRingPlusOne,
		right_ring = gear.crepuscularRing,
		back = gear.rngRangedSTP,
	}) -- With Recycle Merits 101 Recycle for TP bonus and Ammo Save

	-- ACC mode, for high accuracy.
	sets.Midcast.RA.ACC = set_combine(sets.Midcast.RA, {
		ammo = Ammo.ACC,
	})

	-- CRIT mode, for a critical hit build.
	sets.Midcast.RA.CRIT = set_combine(sets.Midcast.RA, {
		head = gear.ikengaHead,
		hands = gear.ikengaHands,
		legs = gear.aminiLegsPlusThree,
		feet = gear.ikengaFeet, -- 10
		neck = gear.scoutGorgetPlusTwo,
		waist = gear.kwahuKachinaBeltPlusOne,
		right_ear = gear.sherida, -- 5 II
		left_ear = gear.odr,
		left_ring = gear.lehkoHabhokaRing,
		right_ring = gear.chirichPlusOne2, -- 10
		back = gear.rngCrit,
	})

	-- SB mode, for a Subtle Blow build.
	sets.Midcast.RA.SB = set_combine(sets.Midcast.RA, {
		-- 10 II from gleti's Knife
		neck = gear.bathyPlusOne,
		head = gear.ikengaHead,      -- 5 II
		right_ear = gear.sherida,    -- 5 II
		left_ear = gear.odr,
		hands = gear.ikengaHands,    -- 15
		waist = gear.tellenBelt,     -- 5
		left_ring = gear.chirichPlusOne1, -- 10
		right_ring = gear.chirichPlusOne2, -- 10
	})

	-- True Shot mode.
	sets.Midcast.RA['True Shot'] = set_combine(sets.Midcast.RA, {
		body = gear.nisrochBody,  -- 10
		legs = gear.aminiLegsPlusThree, -- 8
		feet = gear.ikengaFeet,   -- 10
		waist = gear.tellenBelt,  -- 5
	})

	-- Merged over the ranged midcast while Double Shot is up.
	sets.Midcast.RA.DoubleShot = {
		body = gear.arcadianBodyPlusThree,
		legs = gear.oshosiLegsPlusOne,
		hands = gear.oshosiHandsPlusOne,
		feet = gear.oshosiFeetPlusOne,
	}

	-- Merged over the ranged midcast while Barrage is up.
	sets.Midcast.RA.Barrage = { hands = gear.orionHandsPlusThree, }

	-- Ranged Aftermath sets, merged over the ranged midcast while the matching Aftermath is up.
	-- This one is the relic's.
	sets.Midcast.RA.AM = {}
	--sets.Midcast.RA.AM['Annihilator'] = {}

	-- The empyrean and mythic Aftermath tiers.
	sets.Midcast.RA.AM3 = {}
	--sets.Midcast.RA.AM3['Gastraphetes'] = { }
	sets.Midcast.RA.AM2 = {}
	--sets.Midcast.RA.AM2['Gastraphetes'] = { }
	sets.Midcast.RA.AM1 = {}
	--sets.Midcast.RA.AM1['Gastraphetes'] = { }

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is merged over sets.Idle for every job ability, then the set named for
	-- the ability is merged over it. Any slot left empty keeps your idle gear.
	sets.JA = {}
	sets.JA["Eagle Eye Shot"] = { legs = gear.arcadianLegsPlusThree, }
	sets.JA["Scavenge"] = {}
	sets.JA["Shadowbind"] = { hands = gear.orionHandsPlusThree, }
	sets.JA["Camouflage"] = { body = gear.arcadianBodyPlusThree, }
	sets.JA["Sharpshot"] = { legs = gear.orionLegsPlusThree, }
	sets.JA["Barrage"] = {} -- Worn on the Barrage ability itself. The shots are dressed by sets.Midcast.RA.Barrage.
	sets.JA["Unlimited Shot"] = {}
	sets.JA["Velocity Shot"] = {}
	sets.JA["Double Shot"] = {} -- Worn on the Double Shot ability itself. The shots are dressed by sets.Midcast.RA.DoubleShot.
	sets.JA["Bounty Shot"] = { ammo = Ammo.TP, hands = gear.aminiHandsPlusThree, } -- Upgrade to TH4
	sets.JA["Decoy Shot"] = {}
	sets.JA["Overkill"] = {}
	sets.JA["Hover Shot"] = {}


	-- Steps and Waltzes from your dancer subjob. Each of these sets is merged over sets.Idle for
	-- its kind of ability (they do not use sets.JA), and a set named for one ability is merged over
	-- it. Built on sets.OffenseMode.DT, they keep you in that defensive gear while the ability goes
	-- off.

	sets.Step = set_combine(sets.OffenseMode.DT, {})

	sets.Waltz = set_combine(sets.OffenseMode.DT, {
		ammo = gear.yamarang,        -- 5
		--body={ name="Gleti's Cuirass", augments={'Path: A',}}, -- 10
		hands = gear.slitherGlovesPlusOne, -- 5
		legs = gear.dashingSubligar, -- 10
	})                               -- 30% Potency

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- The base for every weaponskill, merged over sets.Idle. A set named for the weaponskill is
	-- merged over it. Any slot left empty keeps your idle gear.
	sets.WS = {
		ammo = Ammo.WS,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.scoutGorgetPlusTwo,
		waist = gear.fotiaWaist,
		left_ear = gear.enervatingEarring,
		right_ear = gear.ishvara,
		left_ring = gear.regalRing,
		right_ring = gear.epimanondas,
		back = gear.rngWSD, -- Add Melee Cape
	}

	-- Melee weaponskill sets for each offense mode, merged after the set named for the weaponskill
	-- so their gear wins. Never merged in TP mode. Each only fills in the slots its mode changes,
	-- so a weaponskill's own set keeps every other slot. A weaponskill's own mode set, such as
	-- sets.WS['Savage Blade'].ACC, is used instead of these where it exists.
	sets.WS.SB = {}

	sets.WS.ACC = {}

	sets.WS.CRIT = {}

	-- A building block for melee weaponskill damage. WSD is not an offense mode, so this set is
	-- worn only through the sets built from it.
	sets.WS.WSD = set_combine(sets.WS, {
		ammo = Ammo.PHY_WS,
		neck = gear.scoutGorgetPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear = gear.ishvara,
		left_ring = gear.regalRing,
		right_ring = gear.epimanondas,
		back = gear.rngWSD,
	})

	-- A building block for magical weaponskills. MAB is not an offense mode, so this set is worn
	-- only through the sets built from it.
	sets.WS.MAB = set_combine(sets.WS, {
		ammo = Ammo.MAB,
		waist = gear.eschan, -- Orpheus/Obi Swap
		left_ear = gear.moonshadeEarringAcc,
		right_ear = gear.friomisi,
		right_ring = gear.dingir,
	})

	-- The base for ranged weaponskills, merged over sets.WS. Its mode sets below are merged in
	-- their offense mode, never in TP mode. They are merged after the set named for the weaponskill
	-- and only fill in the slots their mode changes, so that set keeps every other slot.
	sets.WS.RA = set_combine(sets.WS, {
		ammo = Ammo.WSD,
		head = gear.orionHeadPlusThree,
		body = gear.aminiBodyPlusThree,
		hands = gear.nyameHands,
		legs = gear.arcadianLegsPlusThree,
		feet = gear.aminiFeetPlusThree,
		neck = gear.scoutGorgetPlusTwo,
		waist = gear.fotiaWaist,
		left_ear = gear.telos,
		right_ear = gear.ishvara,
		left_ring = gear.dingir,
		right_ring = gear.epimanondas,
		back = gear.rngWSD,
	})

	sets.WS.RA.ACC = {
		ammo = Ammo.ACC, -- Smart_Ammo() picks the Bullet/Arrow/Bolt table this reads from
	}

	sets.WS.RA.CRIT = {
		ammo = Ammo.CRIT -- Smart_Ammo() picks the Bullet/Arrow/Bolt table this reads from
	}

	sets.WS.RA.SB = {
		-- 10 II from gleti's Knife
		neck = gear.bathyPlusOne,
		head = gear.ikengaHead,      -- 5 II
		right_ear = gear.sherida,    -- 5 II
		hands = gear.ikengaHands,    -- 15
		left_ring = gear.chirichPlusOne1, -- 10
		right_ring = gear.chirichPlusOne2, -- 10
	}

	-- Ranged weaponskill Aftermath sets, merged after the weaponskill's own sets while the matching
	-- Aftermath is up.
	-- A child keyed by a weapon mode adds gear for that weapon alone.

	-- The relic's Aftermath.
	sets.WS.RA.AM = {}
	sets.WS.RA.AM['Annihilator'] = {}

	-- The empyrean and mythic Aftermath tiers.
	sets.WS.RA.AM3 = {}
	sets.WS.RA.AM3['Gastraphetes'] = {}
	sets.WS.RA.AM2 = {}
	sets.WS.RA.AM2['Gastraphetes'] = {}
	sets.WS.RA.AM1 = {}
	sets.WS.RA.AM1['Gastraphetes'] = {}

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
	sets.WS.RA.HighBuff = {
		head = gear.ikengaHead,
		hands = gear.ikengaHands,
		legs = gear.ikengaLegs,
		feet = gear.ikengaFeet,
		left_ring = gear.sroda,
		right_ring = gear.dingir,
	}
	sets.WS.RA.ACC.HighBuff = {}

	-- Gun weaponskills
	sets.WS["Hot Shot"] = set_combine(sets.WS.MAB, {})
	sets.WS["Split Shot"] = set_combine(sets.WS.RA, {})
	sets.WS["Sniper Shot"] = set_combine(sets.WS.RA, {})
	sets.WS["Blast Shot"] = set_combine(sets.WS.RA, {})
	sets.WS["Heavy Shot"] = set_combine(sets.WS.RA, {})
	sets.WS["Detonator"] = set_combine(sets.WS.RA, {})
	sets.WS["Numbing Shot"] = set_combine(sets.WS.RA, {})
	sets.WS["Wildfire"] = set_combine(sets.WS.MAB, {
		-- Get Cremation Earring, since Wildfire does not scale with TP
	})
	sets.WS["Last Stand"] = set_combine(sets.WS.RA, {})

	sets.WS["Coronach"] = set_combine(sets.WS.RA, {
		head = gear.orionHeadPlusThree,
		body = gear.ikengaBody,
		hands = gear.nyameHands,
		legs = gear.arcadianLegsPlusThree,
		feet = gear.aminiFeetPlusThree,
		neck = gear.fotiaNeck,
		waist = gear.fotiaWaist,
		left_ear = gear.telos,
		right_ear = gear.ishvara,
		left_ring = gear.regalRing,
		right_ring = gear.epimanondas,
		back = gear.rngWSD,
	})

	sets.WS["Slug Shot"] = set_combine(sets.WS.RA, {
		head = gear.orionHeadPlusThree,
		body = gear.ikengaBody,
		hands = gear.nyameHands,
		legs = gear.arcadianLegsPlusThree,
		feet = gear.aminiFeetPlusThree,
		neck = gear.fotiaNeck,
		waist = gear.fotiaWaist,
		left_ear = gear.telos,
		right_ear = gear.ishvara,
		left_ring = gear.regalRing,
		right_ring = gear.epimanondas,
		back = gear.rngWSD,
	})

	-- Archery weaponskills
	sets.WS["Flaming Arrow"] = set_combine(sets.WS.MAB, {})
	sets.WS["Piercing Arrow"] = set_combine(sets.WS.RA, {})
	sets.WS["Dulling Arrow"] = set_combine(sets.WS.RA, {})
	sets.WS["Sidewinder"] = set_combine(sets.WS.RA, {})
	sets.WS["Blast Arrow"] = set_combine(sets.WS.RA, {})
	sets.WS["Arching Arrow"] = set_combine(sets.WS.RA, {})
	sets.WS["Refulgent Arrow"] = set_combine(sets.WS.RA, {})
	sets.WS["Jishnu's Radiance"] = set_combine(sets.WS.RA, {})
	sets.WS["Apex Arrow"] = set_combine(sets.WS.RA, {})
	sets.WS["Namas Arrow"] = {
		head = gear.orionHeadPlusThree,
		body = gear.aminiBodyPlusThree,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.aminiFeetPlusTwo,
		neck = gear.fotiaNeck,
		waist = gear.fotiaWaist,
		left_ear = gear.telos,
		right_ear = gear.ishvara,
		left_ring = gear.regalRing,
		right_ring = gear.epimanondas,
		back = gear.rngWSD,
	}

	-- Sword weaponskills
	sets.WS["Fast Blade"] = set_combine(sets.WS.WSD, {})
	sets.WS["Burning Blade"] = set_combine(sets.WS.MAB, {})
	sets.WS["Flat Blade"] = set_combine(sets.WS.WSD, {})
	sets.WS["Shining Blade"] = set_combine(sets.WS.WSD, {})
	sets.WS["Circle Blade"] = set_combine(sets.WS.WSD, {})
	sets.WS["Spirits Within"] = set_combine(sets.WS.WSD, {})
	sets.WS["Savage Blade"] = set_combine(sets.WS.WSD, {})

	-- Dagger weaponskills
	sets.WS["Wasp Sting"] = set_combine(sets.WS.WSD, {})
	sets.WS["Viper Bite"] = set_combine(sets.WS.WSD, {})
	sets.WS["Shadowstitch"] = set_combine(sets.WS.WSD, {})
	sets.WS["Gust Slash"] = set_combine(sets.WS.WSD, {})
	sets.WS["Cyclone"] = set_combine(sets.WS.WSD, {})
	sets.WS["Energy Steal"] = set_combine(sets.WS.WSD, {})
	sets.WS["Energy Drain"] = set_combine(sets.WS.WSD, {})
	sets.WS["Evisceration"] = set_combine(sets.WS.WSD, {})
	sets.WS['Aeolian Edge'] = set_combine(sets.WS.MAB, {})

	-- Decimation, for the Dolichenus weapon mode.
	sets.WS["Decimation"] = {}

	-- Crossbow weaponskills
	sets.WS["Trueflight"] = set_combine(sets.WS.MAB, {
		neck = gear.scoutGorgetPlusTwo,
		waist = gear.eschan,
		left_ear = gear.moonshadeEarringAcc,
		right_ear = gear.friomisi,
		left_ring = gear.dingir,
		right_ring = gear.weatherspoon,
		back = gear.rngWSD,
	})

	-- Child sets for a single weaponskill, used instead of the general sets.WS.RA ones: one for a
	-- mode, one for HighBuff, and one for the two together. Once declared, each one replaces the
	-- general set for that weaponskill even if it is empty, so only uncomment a line after you fill
	-- it in. The mode and HighBuff line also needs the mode line above it.
	-- sets.WS["Last Stand"].ACC = {}
	-- sets.WS["Last Stand"].HighBuff = {}
	-- sets.WS["Last Stand"].ACC.HighBuff = {}
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
function pretarget_custom(spell, action)

end

-- Called as each action starts. The table it returns is merged over the engine's precast set.
-- This hook and the five gear hooks after it each add the weapon set named for the current
-- JobMode, through Job_Mode_Check.
function precast_custom(spell)
	local equipSet = {}
	equipSet = Job_Mode_Check(equipSet)
	return equipSet
end

-- Called while each action is in progress. The table it returns is merged over the engine's midcast
-- set, which is empty for abilities, weaponskills and items.
function midcast_custom(spell)
	local equipSet = {}
	equipSet = Job_Mode_Check(equipSet)
	return equipSet
end

-- Called when each action ends. The table it returns is merged over the idle or engaged set the
-- engine rebuilds.
function aftercast_custom(spell)
	local equipSet = {}
	equipSet = Job_Mode_Check(equipSet)
	return equipSet
end

-- Called when a buff is gained or lost. The table it returns is merged over the rebuilt idle or
-- engaged set. If one of your own actions is still in progress, it is still called right away, but
-- the table it returns is not used, and the gear change happens when that action ends.
function buff_change_custom(name, gain)
	local equipSet = {}
	equipSet = Job_Mode_Check(equipSet)
	return equipSet
end

-- Called whenever the engine rebuilds the idle or engaged set, which it does after each action, on
-- a buff or status change, and when movement starts or stops. The table it returns is merged over
-- that set.
function choose_set_custom()
	local equipSet = {}
	equipSet = Job_Mode_Check(equipSet)
	return equipSet
end

-- Called when the player's status changes, such as engaging, disengaging or resting. The table it
-- returns is merged over the rebuilt idle or engaged set. If one of your own actions is still in
-- progress, the table is not used, and the gear change happens when that action ends.
function status_change_custom(new, old)
	local equipSet = {}
	equipSet = Job_Mode_Check(equipSet)
	return equipSet
end

-- Called with any "gs c" command the engine does not handle itself, in lowercase. Use it to add
-- your own commands. The Weapon Mode, Job Mode and Job Mode 2 commands also call it, before they
-- change your gear. Here it runs Smart_Ammo, so changing the weapon mode also switches the
-- ammunition type.
function self_command_custom(command)
	Smart_Ammo()
end

-- Called when the job file unloads, after the engine releases its keybinds and slot holds.
function user_file_unload()

end

-- Called when a pet is summoned or lost. The table it returns is merged over the rebuilt idle or
-- engaged set. If one of your own actions is still in progress, it is still called, but the table
-- it returns is not used, and the gear change happens when that action ends.
function pet_change_custom(pet, gain)
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

-- Matches state.RAMode to the ammunition type the current weapon mode fires, from Ranged_Weapons.
-- When the type changes it prints the type, re-runs get_sets() so the flat Ammo keys follow, and
-- equips that type's TP round.
function Smart_Ammo()
	for i = 1, #Ranged_Weapons do
		if state.WeaponMode.value == Ranged_Weapons[i].WeaponMode then
			if state.RAMode.value ~= Ranged_Weapons[i].Type then
				state.RAMode:set(Ranged_Weapons[i].Type)
				windower.add_to_chat(8, 'Ammo Mode is [' .. state.RAMode.value .. ']')
				get_sets()
				equip({ ammo = Ammo.TP })
			end
			return
		end
	end
end
