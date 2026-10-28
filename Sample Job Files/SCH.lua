-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: Scholar. A sample to copy into your character's folder and fill in.
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

-- The offense modes this file offers, and the one to start in. The engine's defaults are TP, ACC
-- and DT.
-- Every mode offered here needs both a sets.OffenseMode.<Mode> entry and a sets.Idle.<Mode> entry.
-- The engine warns in chat each time it looks for a missing one. Occult and MB are nuking modes,
-- read by the nuke and helix sets' children of the same name: Occult for Occult Acumen gear, MB for
-- burst gear on every nuke.
state.OffenseMode:options('TP', 'ACC', 'DT', 'PDT', 'MEVA', 'Occult', 'MB')
state.OffenseMode:set('DT')

-- The weapon modes, each naming a sets.Weapons entry below, and the one to start in.
state.WeaponMode:options('Musa', 'Mpaca')
state.WeaponMode:set('Mpaca')

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
jobsetup(LockStylePallet, MacroBook, MacroSet)

function get_sets()

	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

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

	-- Worn in the offhand, idle or engaged, whenever the main is one-handed and no dual-wield trait
	-- is active.
	sets.Weapons.Shield = {
		sub = gear.genmeiShield,
	}

	-- Worn over the idle set when you are put to sleep, and held until the sleep ends. A piece that
	-- drains HP wakes you on its first tick.
	sets.Weapons.Sleep = {
		main = gear.opashoro,
	}

	-- Merged whole over a Cure, Curaga or Cura cast on Lightsday or in Light weather. Its main and
	-- sub are worn unless the weapon lock holds them.
	-- When this set is empty, the engine puts Chatoyant Staff in main alone, if you carry one.
	-- Without a Chatoyant Staff, remove main and sub from this set. The game refuses its grip
	-- beside a one-handed main.
	sets.Weapons['Light Bonus'] = {}

	-- ===================================================================================================================
	--		sets.Idle
	-- ===================================================================================================================

	-- Worn while idle. Every precast and midcast also starts from this set, so any slot an action's
	-- set leaves empty keeps your idle gear.
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

	-- Idle sets per offense mode, merged over sets.Idle in the matching mode. sets.Idle.Resting is
	-- merged while you rest.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDT = set_combine(sets.Idle, {})
	sets.Idle.Resting = {}
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
	})
	-- Occult and MB modes start from copies of the DT idle set, so you sit in DT gear between
	-- casts in those modes.
	sets.Idle.Occult = set_combine(sets.Idle.DT, {})
	sets.Idle.MB = set_combine(sets.Idle.DT, {})

	-- Merged over the idle set while Sublimation is charging.
	sets.Idle.Sublimation = {
		head = gear.academicHeadPlusThree, -- +4 Sublimation when active
		right_ring = gear.defending,
		waist = gear.embla,        -- +3 Sublimation when active
	}

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
		feet = gear.heraldGaiters
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

	-- The engaged base, worn in every offense mode. The set named for the current mode is merged
	-- over it, and the mode sets below start from a copy of it.
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
	-- Occult and MB modes start from copies of the DT engaged set.
	sets.OffenseMode.Occult = set_combine(sets.OffenseMode.DT, {})
	sets.OffenseMode.MB = set_combine(sets.OffenseMode.DT, {})

	-- Aftermath sets, merged over the engaged set while the matching Aftermath is up. The engine
	-- uses the strongest active tier that has gear for the current weapon. A tier set applies with
	-- any weapon, and a child named for a weapon mode adds gear for that weapon only, such as
	-- sets.OffenseMode.AM3['Tupsimati'] once a 'Tupsimati' weapon mode is offered above.
	sets.OffenseMode.AM1 = {}
	sets.OffenseMode.AM2 = {}
	sets.OffenseMode.AM3 = {}

	-- Treasure Hunter gear. In every TH mode but None, it is worn on the action that tags a monster
	-- and while engaged on an untagged one. Full Time also wears it whenever you are engaged. Every
	-- job but Thief starts in None.
	sets.TreasureHunter = {
		ammo = gear.perfectEgg,
		head = gear.volteHead,
		legs = gear.volteHose,
		waist = gear.chaac,
	}

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Every precast starts from sets.Idle, except a pet command's. For a spell, sets.Precast is
	-- merged over it, then the fast cast set. Any slot left empty keeps your idle gear. Only HP, MP
	-- and fast cast matter here.
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

	-- Merged over the fast cast set when you cast enhancing magic.
	sets.Precast.Enhancing = set_combine(sets.Precast.FastCast, {})

	-- Merged over the fast cast set for cures.
	sets.Precast.Cure = set_combine(sets.Precast.FastCast, {})

	-- Merged over the fast cast set for Raise, Reraise, Arise, Esuna, Sacrifice and the -na spells.
	sets.Precast.Healing = set_combine(sets.Precast.FastCast, {})

	-- Grimoire fast cast swaps, worn through precast_custom below on white magic under Light Arts
	-- or Addendum: White, and on black magic under Dark Arts or Addendum: Black. With them, fast
	-- cast should total over 80%.
	sets.Precast.Grimoire = {}

	-- Merged over the fast cast set when you cast Impact. The engine then puts on the Impact cloak
	-- you carry and removes your head piece.
	sets.Precast['Impact'] = {}

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- The base for every cast, merged over sets.Idle on every midcast, so any slot it leaves empty
	-- keeps your idle gear.
	sets.Midcast = set_combine(sets.Idle, {})

	-- Spell interruption rate down. Used under every midcast except ranged attacks, so any more
	-- specific set overrides it.
	sets.Midcast.SIRD = {}

	-- Merged over sets.Midcast and sets.Midcast.SIRD when you cast any spell in ACC mode. The
	-- spell's own family set is merged after it, so that set wins any slot both fill.
	sets.Midcast.ACC = {}

	-- Each casting set below can take a child set named for an offense mode, such as
	-- sets.Midcast.Nuke.ACC. It is merged right over its set in that mode, so the sets merged after
	-- it still win any slot both fill. The DT and MEVA children are for damage taken and magic
	-- evasion gear. They ship commented out: uncomment one once you fill it in.

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

	-- Merged over the cure set when you cast a cure on yourself.
	sets.Midcast.Cure.Self = {}

	-- Merged over the cure set when you cast a cure on anyone else, or on yourself under Accession.
	sets.Midcast.Cure.Others = {}

	-- Merged over the cure set in DT or MEVA mode.
	-- sets.Midcast.Cure.DT = {}
	-- sets.Midcast.Cure.MEVA = {}

	-- Worn when you cast Curaga.
	sets.Midcast.Curaga = {}

	-- Merged over the Curaga set in DT or MEVA mode.
	-- sets.Midcast.Curaga.DT = {}
	-- sets.Midcast.Curaga.MEVA = {}

	-- Cursna, merged over the enhancing set. This one is the Cure set with these slots changed.
	sets.Midcast.Cursna = set_combine(sets.Midcast.Cure, {
		body = gear.pedagogyBodyPlusThree,
		legs = gear.academicLegsPlusThree,
		feet = gear.gendewithaGaloshesPlusOne,
		neck = gear.debilis,
		left_ring = gear.menelausRing,
		right_ring = gear.haomaRing,
	})

	-- Enhancing magic. Healing spells other than cures, such as Raise and the -na spells, use it
	-- too.
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
	sets.Midcast.Enhancing.Skill = {}

	-- Merged over the enhancing set when the target is not you, or when Accession is up.
	sets.Midcast.Enhancing.Others = {}

	-- Merged over the enhancing set in DT or MEVA mode, before the Others set.
	-- sets.Midcast.Enhancing.DT = {}
	-- sets.Midcast.Enhancing.MEVA = {}

	-- Elemental bar-spells, merged over the enhancing set.
	sets.Midcast.Enhancing.Elemental = {}

	-- Merged over the enhancing set for Phalanx, Regen and Refresh spells.
	sets.Midcast.Phalanx = {}

	sets.Midcast.Regen = {
		body = gear.telchineChasubleRegen,
		back = gear.bookwormCape,
		head = gear.arbatelHeadPlusThree,
	}

	sets.Midcast.Refresh = {}

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

	-- Merged over the enfeebling set for the spells the engine's lists name: MACC for
	-- accuracy-based spells, such as Dispel, and Potency for potency-based ones, such as Paralyze.
	sets.Midcast.Enfeebling.MACC = {}
	sets.Midcast.Enfeebling.Potency = {}

	-- Merged over the enfeebling set when you cast a spell on the engine's duration list, such as
	-- Sleep.
	sets.Midcast.Enfeebling.Duration = {}

	-- Merged over the enfeebling set in ACC, DT or MEVA mode, before the MACC, Potency or Duration
	-- set. ACC is for magic accuracy gear.
	sets.Midcast.Enfeebling.ACC = {}
	-- sets.Midcast.Enfeebling.DT = {}
	-- sets.Midcast.Enfeebling.MEVA = {}

	-- Merged over the enfeebling sets while Dark Arts or Light Arts is up. Academic's Gown raises
	-- enfeebling magic skill under Dark Arts, and Academic's Pants under Light Arts. Uncomment a line
	-- once you fill it in.
	-- sets.Midcast.Enfeebling['Dark Arts'] = {}
	-- sets.Midcast.Enfeebling['Light Arts'] = {}

	-- Dark magic. MACC and Absorb merge over it for the spells the engine's dark magic lists name:
	-- MACC for Kaustra, Absorb for the Absorb spells, such as Absorb-TP. MACC starts from the
	-- enfeebling MACC set's own pieces.
	sets.Midcast.Dark = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Dark.MACC = set_combine(sets.Midcast.Enfeebling.MACC, {})
	sets.Midcast.Dark.Absorb = {}

	-- Merged over the dark magic set in ACC, DT or MEVA mode, before the MACC or Absorb set.
	sets.Midcast.Dark.ACC = {}
	-- sets.Midcast.Dark.DT = {}
	-- sets.Midcast.Dark.MEVA = {}

	-- Used instead of the dark magic sets: the first when you cast Drain, the second when you cast
	-- Aspir.
	sets.Midcast.Drain = {}
	sets.Midcast.Aspir = {}

	-- Merged over the Drain or Aspir set when you cast that spell into a burst window of its
	-- element.
	sets.Midcast.Drain.Burst = {}
	sets.Midcast.Aspir.Burst = {}

	-- Merged over the Drain or Aspir set in ACC, DT or MEVA mode.
	sets.Midcast.Drain.ACC = {}
	sets.Midcast.Aspir.ACC = {}
	-- sets.Midcast.Drain.DT = {}
	-- sets.Midcast.Drain.MEVA = {}
	-- sets.Midcast.Aspir.DT = {}
	-- sets.Midcast.Aspir.MEVA = {}

	-- Worn when you cast divine magic, such as Flash or Repose.
	sets.Midcast.Divine = {}

	-- Merged over the divine set in ACC, DT or MEVA mode.
	sets.Midcast.Divine.ACC = {}
	-- sets.Midcast.Divine.DT = {}
	-- sets.Midcast.Divine.MEVA = {}

	-- Used instead of the enfeebling sets when you cast Dispelga. The engine puts on Daybreak
	-- itself, whatever this set names.
	sets.Midcast["Dispelga"] = set_combine(sets.Midcast.Enfeebling, {
		main = gear.daybreak,
		sub = gear.ammurapi,
	})

	-- Not read by the engine. Gear you put on by hand for Vagary (6k+ nuke no kill).
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

	-- Elemental magic nukes. A magic burst takes sets.Midcast.Burst instead, and an earth spell
	-- also takes sets.Midcast.Nuke.Earth.
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

	-- Merged over the nuke or burst set for earth nukes, Geohelix aside.
	sets.Midcast.Nuke.Earth = { neck = gear.quanpur, }

	-- Merged over the earth set when you cast an earth nuke into a burst window of its element.
	sets.Midcast.Nuke.Earth.Burst = {}

	-- Used instead of the nuke set when the engine expects your nuke to land on the skillchain's
	-- target while the burst window is open, with an element that skillchain carries. A skillchain
	-- of its element that lands on your target while you cast puts this set on too. A spell cast
	-- under Immanence never takes it.
	sets.Midcast.Burst = set_combine(sets.Midcast.Nuke, {})

	-- Merged over the nuke set in Occult mode, for Occult Acumen gear. A nuke the engine expects to
	-- burst uses the burst set instead, so in Occult mode it takes sets.Midcast.Burst.Occult.
	sets.Midcast.Nuke.Occult = {}
	sets.Midcast.Burst.Occult = {}

	-- Merged over the nuke set in MB mode, for wearing burst gear on every nuke. It goes on when the
	-- engine does not expect the nuke to burst. A nuke it does expect to burst uses the burst set as
	-- usual.
	sets.Midcast.Nuke.MB = {}

	-- Merged over the nuke set, or over the burst set, in ACC mode for magic accuracy gear, and in
	-- DT or MEVA mode once uncommented.
	sets.Midcast.Nuke.ACC = {}
	sets.Midcast.Burst.ACC = {}
	-- sets.Midcast.Nuke.DT = {}
	-- sets.Midcast.Nuke.MEVA = {}
	-- sets.Midcast.Burst.DT = {}
	-- sets.Midcast.Burst.MEVA = {}

	-- Helix spells, merged after the nuke or burst set. sets.Helix.Dark and sets.Helix.Light are
	-- merged over it for the dark and light helixes.
	sets.Helix = {
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
	}

	sets.Helix.Dark = {
		head = gear.pixieHead,
		left_ring = gear.archonRing,
	}

	-- Merged over the helix set when you cast a helix into a burst window of its element.
	sets.Helix.Burst = {}

	sets.Helix.Light = {
		main = gear.daybreak,
		left_ring = gear.weatherspoon
	}

	-- Merged over the helix set in its offense mode, burst or not, before the burst set above and
	-- the dark and light sets: ACC for magic accuracy gear, Occult for Occult Acumen gear, MB for
	-- burst gear on every helix, and DT or MEVA once uncommented.
	sets.Helix.ACC = {}
	sets.Helix.Occult = {}
	sets.Helix.MB = {}
	-- sets.Helix.DT = {}
	-- sets.Helix.MEVA = {}

	-- A set named for one spell replaces its family set for that spell, so Stoneskin skips the
	-- enhancing set. The exceptions are the cures, which always take the Cure, Curaga or Cura set,
	-- and Cursna, which takes the enhancing set with sets.Midcast.Cursna over it.
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

	-- Used instead of the dark magic sets when you cast Klimaform.
	sets.Midcast["Klimaform"] = set_combine(sets.Midcast.Enhancing, {})

	-- Used instead of the nuke set and the burst set when you cast Impact. The engine puts on the
	-- Impact cloak you carry and removes your head piece.
	sets.Midcast["Impact"] = set_combine(sets.Midcast.Enfeebling, {
		body = gear.crepuscularCloak,
	})

	-- Merged over the Impact set when you cast Impact into a burst window of its element.
	sets.Midcast["Impact"].Burst = {}

	-- Used instead of the dark magic set when you cast Kaustra. Uncomment the two lines below once
	-- you fill them in: once declared, the first replaces the dark magic set for Kaustra even if it
	-- is empty, and its burst child set is merged over it when you cast Kaustra into a burst window
	-- of its element.
	-- sets.Midcast["Kaustra"] = {}
	-- sets.Midcast["Kaustra"].Burst = {}

	-- Used instead of the enhancing set when you cast Embrava.
	sets.Midcast["Embrava"] = set_combine(sets.Midcast.Enhancing, {})

	-- Used instead of the dark magic sets when you cast Stun. It starts from the enfeebling set
	-- with the enfeebling MACC set's pieces over it.
	sets.Midcast["Stun"] = set_combine(sets.Midcast.Enfeebling, sets.Midcast.Enfeebling.MACC, {})

	-- Buff sets for the stratagems. Each is worn on every midcast while its buff is up, ranged
	-- attacks included, and its slots win over the spell's own sets.
	-- Treasure Hunter gear still takes its slots on an untagged monster. The engine's midcast line
	-- names each buff set it merges.
	-- Arbatel Bracers lengthen the duration Perpetuance adds to your next enhancing spell.
	sets.Midcast.Perpetuance = { hands = gear.arbatelHandsPlusThree, }
	-- Arbatel Bracers raise the skillchain bonus of the spell cast under Immanence.
	sets.Midcast.Immanence = { hands = gear.arbatelHandsPlusThree, }
	-- Arbatel Bonnet raises the potency bonus Ebullience gives your next black magic spell.
	sets.Midcast.Ebullience = { head = gear.arbatelHeadPlusThree, }
	-- Arbatel Bonnet raises the potency bonus Rapture gives your next white magic spell.
	sets.Midcast.Rapture = { head = gear.arbatelHeadPlusThree, }
	-- Arbatel Pants strengthen Penury. It ships commented out, so the legs keep their duration gear
	-- for spells such as Embrava. Uncomment it to use it.
	-- sets.Midcast.Penury = { legs = gear.arbatelLegsPlusThree, } -- not swapped due to duration
	-- Arbatel Pants strengthen Parsimony.
	sets.Midcast.Parsimony = { legs = gear.arbatelLegsPlusThree, }
	-- Worn on elemental magic while Klimaform is up, through midcast_custom below. Klimaform is
	-- also a spell name, so it cannot be a buff set under sets.Midcast.
	sets.Klimaform = { feet = gear.arbatelFeetPlusThree, }
	-- Merged over the enhancing set for the storm spells.
	sets.Storms = { feet = gear.pedagogyFeetPlusThree, }

	-- Blue magic, for a BLU subjob. The engine never merges sets.Midcast.BlueMagic itself, only the
	-- set for the engine's blue magic list that names the spell. ACC takes the enfeebles that only
	-- need to land, such as Cold Wave, Filamented Hold and Yawn. Enmity takes the enfeebles that
	-- build enmity, such as Geist Wall and Frightful Roar, so put magic accuracy gear there if you
	-- cast them to land their effect. Buff takes buffs such as Zephyr Mantle.
	sets.Midcast.BlueMagic = {}
	sets.Midcast.BlueMagic.ACC = {}
	sets.Midcast.BlueMagic.Enmity = {}
	sets.Midcast.BlueMagic.Buff = {}

	-- Merged over a blue magic set in DT or MEVA mode.
	-- sets.Midcast.BlueMagic.ACC.DT = {}
	-- sets.Midcast.BlueMagic.ACC.MEVA = {}
	-- sets.Midcast.BlueMagic.Enmity.DT = {}
	-- sets.Midcast.BlueMagic.Enmity.MEVA = {}
	-- sets.Midcast.BlueMagic.Buff.DT = {}
	-- sets.Midcast.BlueMagic.Buff.MEVA = {}

	-- Worn from the moment your avatar readies a debuff pact, such as Cait Sith's Mewing Lullaby
	-- from a SMN subjob, until the pact lands, for avatar magic accuracy and Summoning magic skill
	-- gear.
	sets.Pet_Midcast.Debuff = {}

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities and stratagems. sets.JA is merged over sets.Idle for all of them, then the set
	-- named for the ability is merged over it. Any slot left empty keeps your idle gear.
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

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- The base for every weaponskill, merged over sets.Idle. A set named for the weaponskill is
	-- merged over it. Any slot left empty keeps your idle gear.
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

	-- Merged in ACC mode after the set named for the weaponskill, so its gear wins. Only fill in
	-- the slots ACC mode should change. A weaponskill with its own ACC set uses that instead.
	sets.WS.ACC = {}

	-- Merged in DT mode after the set named for the weaponskill, so its gear wins, for damage taken
	-- gear. sets.WS.MEVA works the same way in MEVA mode, for magic evasion gear. A weaponskill
	-- with its own DT or MEVA set uses that instead. Every slot here costs some of the
	-- weaponskill's damage, so uncomment a line only once you fill it in.
	-- sets.WS.DT = {}
	-- sets.WS.MEVA = {}

	-- Merged over every weaponskill while Buff Level (Alt+F12) is set to HighBuff, for physical
	-- damage limit gear. At MidBuff, the default, no set is used here. A weaponskill's own HighBuff
	-- set, such as sets.WS['Shattersoul'].HighBuff once sets.WS['Shattersoul'] exists, replaces
	-- this one for that weaponskill, even if it is empty. In any offense mode except TP, the set
	-- for that mode and level is merged after it, such as sets.WS.ACC.HighBuff in ACC mode.
	sets.WS.HighBuff = {}
	sets.WS.ACC.HighBuff = {}

	-- Merged over sets.WS when you use Cataclysm or Earth Crusher. Both deal magic damage, so the
	-- engine adds the day, weather and distance pieces after them.
	sets.WS['Cataclysm'] = {}
	sets.WS['Earth Crusher'] = {}

	-- Aftermath sets for weaponskills, merged after the weaponskill's own sets while the matching
	-- Aftermath is up. They work as the engaged Aftermath sets do.
	sets.WS.AM1 = {}
	sets.WS.AM2 = {}
	sets.WS.AM3 = {}
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
-- Here it adds sets.Precast.Grimoire to white magic under Light Arts or Addendum: White, and to
-- black magic under Dark Arts or Addendum: Black.
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

-- Called while each action is in progress. The table it returns is merged over the engine's midcast
-- set, which is empty for abilities, weaponskills and items. Here it adds sets.Klimaform to
-- elemental magic cast under Klimaform. A buff child set cannot do this, because Klimaform is also
-- a spell name, and under sets.Midcast a spell name means that spell's own set.
function midcast_custom(spell)
	local equipSet = {}

	if buffactive["Klimaform"] and spell.skill == 'Elemental Magic' then
		log("Klimaform Set")
		equipSet = set_combine(equipSet, sets.Klimaform)
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
-- engaged set. If one of your own actions is still in progress, it is still called right away, but
-- the table it returns is not used, and the gear change happens when that action ends.
function buff_change_custom(name, gain)
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
function status_change_custom(new, old)
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
