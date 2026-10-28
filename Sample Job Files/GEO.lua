-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: Geomancer. A sample to copy into your character's folder and fill in.
--
-- How this file is laid out. The lines above get_sets() are your options: the offense, weapon and
-- job modes you cycle through in game, and the lockstyle and macro book the file sets when it
-- loads. get_sets() holds your gear sets, one section for each kind: weapons, idle, engaged
-- (sets.OffenseMode), precast, midcast, pet gear, job abilities and weaponskills. The comment above
-- each set says when it is worn and what it is merged over. A set named for a mode, a spell, an
-- ability or a buff is merged over the set it sits under, and any slot it leaves empty keeps the
-- gear from underneath. Gear comes from the gear library as gear.<name>, or by its item name in
-- quotes.
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

-- The lockstyle set, macro book and macro set that jobsetup applies at load.
LockStylePallet = "20"
MacroBook = "20"
MacroSet = "1"

-- The item that "gs c food" uses.
Food = "Tropical Crepe"

-- When true, the engine uses a Remedy on paralysis or silence and a Holy Water on Doom.
AutoItem = false

-- When true, each load picks a lockstyle set from Lockstyle_List instead of LockStylePallet.
Random_Lockstyle = false

-- The lockstyle sets Random_Lockstyle picks from.
Lockstyle_List = {1,2,6,12}

-- The offense modes this job cycles through, instead of the engine's default TP, ACC and DT. Each
-- mode needs a sets.OffenseMode.<Mode> and a sets.Idle.<Mode> below, and can also have a
-- sets.WS.<Mode>. Occult and MB are for your nukes, and their midcast sets are beside the nuke
-- sets below.
state.OffenseMode:options('TP','ACC','DT','SB','MEVA','Occult','MB')

-- The offense mode selected at load.
state.OffenseMode:set('DT')

-- Weapon modes. Each one needs a sets.Weapons['<Mode>'] of the same name below.
state.WeaponMode:options('Idris','Black Halo','Mpaca')
state.WeaponMode:set('Mpaca')

-- The weapon lock, and the one to start in. Unlocked lets any set change your weapons. Locked keeps
-- the pair your weapon mode names, and the TP on it, through every action, except where the engine
-- itself must put on a weapon: one a spell needs, sets.Weapons.Sleep while you are asleep, and a
-- Spell Received set. Geomancy is Locked, except that a Geomancy spell's set may change your
-- weapons.
state.WeaponLock:options('Unlocked','Locked','Geomancy')
state.WeaponLock:set('Unlocked')

-- The buff level, and the one to start in. Only weaponskills read it: at HighBuff they wear their
-- HighBuff children, and at MidBuff only a weaponskill's own MidBuff child.
state.BuffLevel:options('MidBuff','HighBuff')
state.BuffLevel:set('MidBuff')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

-- Goal 2200 HP/1400 MP
function get_sets()

	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	-- Weapon sets, one per weapon mode above.
	sets.Weapons = {}

	sets.Weapons['Idris'] = {
		main = gear.idris,
		sub = gear.genmeiShield,
	}

	sets.Weapons['Black Halo'] = {
		main = gear.maxentius,
		sub = gear.genmeiShield,
	}

	sets.Weapons['Mpaca'] = {
		main = gear.mpacaStaff,
		sub = gear.enki,
	}

	-- Merged over the idle set when you are put to sleep. The slots it names stay locked until you
	-- wake up. Put gear here that wakes you, such as a piece that drains HP.
	sets.Weapons.Sleep = {
		main = gear.lorgMor,
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active,
	-- engaged or idle. It also comes with Daybreak, which Dispelga puts in your main hand, when your
	-- main is a staff.
	sets.Weapons.Shield = {
		sub = gear.genmeiShield,
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

	-- Worn while idle. Every action's precast and midcast also start from this set, so any slot
	-- their sets leave empty keeps your idle gear.
	sets.Idle = {
		range = gear.dunnaFC,
		head = gear.azimuthHeadPlusThree, -- 11/11
		body = gear.azimuthBodyPlusThree,
		hands = gear.azimuthHandsPlusThree, -- 12/12
		legs = gear.agwuLegs, -- 10/10
		feet = gear.azimuthFeetPlusThree, -- 10/10
		neck = gear.loricatePlusOne, -- 6/6
		waist = gear.carriers,
		left_ear = gear.sanareEarring,
		right_ear = gear.lugalbanda,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
		back = gear.geoPetRegen,
	} -- 50 PDT / 52 MDT (including shield)

	-- Merged over sets.Idle while idle in the matching offense mode. sets.Idle.Resting is merged
	-- over them while resting.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {})
	-- Occult and MB modes start from copies of the DT idle set, so you sit in DT gear between
	-- casts in those modes.
	sets.Idle.Occult = set_combine(sets.Idle.DT, {})
	sets.Idle.MB = set_combine(sets.Idle.DT, {})
	sets.Idle.Resting = {}

	-- Merged over the idle set while Sublimation is charging.
	sets.Idle.Sublimation = {}

	-- Worn over the idle set while a Phantom Roll on you stands at 11. It is for the Roller's
	-- Ring, which any job can wear and which gives Refresh +1 and Regain +10 at an 11, for example
	-- right_ring="Roller's Ring". It applies in every offense mode. It is worn only while idle, so
	-- any action swaps it out and it comes back when the action ends. While moving, a ring here
	-- replaces the movement set's ring in the same slot. This file's sets.Movement wears a
	-- Defending Ring in left_ring, so right_ring is the free slot.
	sets.Idle.XIRoll = {}

	-- The TP-mode form, merged after sets.Idle.XIRoll while idle in TP mode.
	sets.Idle.TP.XIRoll = {}

	-- Worn over the idle set while moving and not engaged.
	sets.Movement = {
		left_ring = gear.defending,
		feet = gear.geomancyFeetPlusFour,
	}

	-- Worn when another character on this machine, running this engine, casts on you. Spell
	-- Received mode must be ON. sets.Cursna_Received is also the Doom set, worn when that mode is
	-- OFF.
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

	-- The ring slot Zodiac Ring goes in when a spell's element matches the day: "right_ring" or
	-- "left_ring".
	Elemental_Bonus_Ring_Slot = "right_ring"

	-- Worn while using a Holy Water or Hallowed Water.
	sets.Holy_Water = {
		neck = gear.nicander,
	}

	-- ===================================================================================================================
	--		sets.OffenseMode
	-- ===================================================================================================================

	-- The engaged base, merged first in every offense mode. The mode's own set is merged over it.
	sets.OffenseMode = {
		head = gear.azimuthHeadPlusThree,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.azimuthFeetPlusThree,
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
		left_ear = gear.crepuscularEar,
		right_ear = gear.telos,
		left_ring = gear.chirichRingPlusOne,
		right_ring = gear.chirichRingPlusOne,
		back = gear.geoPetRegen,
	}

	sets.OffenseMode.TP = set_combine(sets.OffenseMode,{})
	sets.OffenseMode.DT = set_combine(sets.OffenseMode,{})
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode,{})
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, {})
	sets.OffenseMode.SB = set_combine(sets.OffenseMode, {})
	-- Occult and MB modes start from copies of the DT engaged set.
	sets.OffenseMode.Occult = set_combine(sets.OffenseMode.DT, {})
	sets.OffenseMode.MB = set_combine(sets.OffenseMode.DT, {})

	-- Aftermath sets, merged over the engaged set while the matching Aftermath is up. The engine
	-- uses the strongest active tier that has gear for the current weapon. A tier set applies with
	-- any weapon, and a child named for a weapon mode adds gear for that weapon only, such as the
	-- Idris one below.
	sets.OffenseMode.AM1 = {}
	sets.OffenseMode.AM2 = {}
	sets.OffenseMode.AM3 = {}
	sets.OffenseMode.AM3['Idris'] = {}

	-- Treasure Hunter gear. While TH Mode is Tag or Full Time, it is worn for an action aimed at an
	-- untagged monster and while engaged on one. Full Time also keeps it on whenever engaged. TH
	-- Mode starts at None, which never wears it, on every job but Thief.
	sets.TreasureHunter = {
		ammo = gear.perfectEgg,
		waist = gear.chaac,
		hands = gear.merlinicDastanasNukeB,
	}

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Every precast starts from sets.Idle, except a pet command's. For a spell, sets.Precast is
	-- merged over it, then the fast cast set. Any slot left empty keeps your idle gear.
	sets.Precast = {}

	-- Fast cast gear, worn at the start of every spell.
	sets.Precast.FastCast = {
		range = gear.dunnaFC, -- 3
		head = gear.merlinicHoodFC, -- 15
		body = gear.zendikRobe, -- 13
		hands = gear.agwuHands, -- 6
		legs = gear.geomancyLegsPlusFour, -- 15
		feet = gear.merlinicCrackowsFC, -- 12
		neck = gear.voltsurge, -- 4
		waist = gear.witful, -- 3 and 3 Quick Magic
		left_ear = gear.malignanceEar, -- 4
		right_ear = gear.etiolation, -- 1
		left_ring = gear.lebecheRing, -- 2 Quick Magic
		right_ring = gear.kishar, -- 4
		-- Have to use Fast Cast due to Head Locked out with Pet above 68%
		back = gear.geoFCB,
		--back="Perimede Cape", -- 4 Quick Magic
	} -- 80% Fast Cast with 9% Quick Magic

	-- Merged over the fast cast set for cures and for enhancing magic.
	sets.Precast.Cure = {}
	sets.Precast.Enhancing = {}

	-- Merged over the fast cast set when you cast a healing spell other than a cure, such as Raise
	-- or a -na spell.
	sets.Precast.Healing = {}

	-- Merged over the fast cast set when you cast Impact. The engine then puts on the Impact cloak
	-- you carry and removes your head piece.
	sets.Precast['Impact'] = {}

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- The base for every cast, merged over sets.Idle on every midcast, so any slot it leaves empty
	-- keeps your idle gear.
	sets.Midcast = set_combine(sets.Idle, {

	})

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

	-- Cure spells. Curaga takes its own set below.
	sets.Midcast.Cure = {
		main = gear.daybreak, -- 30
		sub = gear.genmeiShield,
		range = gear.dunnaFC,
		head = gear.vanyaHeadPathB, -- 10
		body = gear.vanyaBodyPathB,
		hands = gear.azimuthHandsPlusThree,
		legs = gear.vanyaLegsPathB,
		feet = gear.azimuthFeetPlusThree,
		neck = gear.loricatePlusOne,
		waist = gear.luminarySash,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.etiolation,
		left_ring = gear.stikiniRingPlusOne3,
		right_ring = gear.stikiniRingPlusOne2,
		back = gear.geoCure, -- 10
	}

	-- Merged over the cure set when you cast a cure on yourself.
	sets.Midcast.Cure.Self = {}

	-- Merged over the cure set when you cast a cure on anyone else, or on yourself under Accession.
	sets.Midcast.Cure.Others = {}

	-- Merged over the cure set in DT or MEVA mode.
	-- sets.Midcast.Cure.DT = {}
	-- sets.Midcast.Cure.MEVA = {}

	sets.Midcast.Curaga = set_combine( sets.Midcast.Cure, {})

	-- Merged over the Curaga set in DT or MEVA mode.
	-- sets.Midcast.Curaga.DT = {}
	-- sets.Midcast.Curaga.MEVA = {}

	-- Enhancing magic. The family sets below go over it for the spells each one covers.
	sets.Midcast.Enhancing = {
		sub = gear.ammurapi,
		range = gear.dunnaFC,
		head = gear.telchineCapBEnhDur,
		body = gear.telchineChasubleBEnhDur,
		hands = gear.telchineGlovesCEnhDur,
		legs = gear.telchineBraconiBEnhDur,
		feet = gear.telchinePigachesC,
		neck = gear.loricatePlusOne,
		waist = gear.embla,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.etiolation,
		left_ring = gear.defending,
		right_ring = gear.gelatinousPlusOne,
		back = gear.geoPetRegen,
	}

	-- Elemental bar-spells: Barfire, Barblizzard, Baraero, Barstone, Barthunder, Barwater and their
	-- -ra forms.
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

	-- Merged over the enhancing set in DT or MEVA mode.
	-- sets.Midcast.Enhancing.DT = {}
	-- sets.Midcast.Enhancing.MEVA = {}

	-- Enfeebling magic, built for magic accuracy so the spells land.
	sets.Midcast.Enfeebling = {
		main = gear.idris,
		sub = gear.ammurapi,
		range = gear.dunnaFC,
		head = gear.geomancyHeadPlusFour,
		body = gear.geomancyBodyPlusFour,
		hands = gear.azimuthHandsPlusThree,
		legs = gear.geomancyLegsPlusFour,
		feet = gear.geomancyFeetPlusFour,
		neck = gear.baguaCharmPlusTwo,
		waist = gear.luminarySash,
		left_ear = gear.malignanceEar,
		right_ear = gear.regalEarring,
		left_ring = gear.stikiniRingPlusOne3,
		right_ring = gear.stikiniRingPlusOne2,
		back = gear.geoNukePdt,
	}

	-- Merged over the enfeebling set in ACC, DT or MEVA mode, before the MACC, Potency or Duration
	-- set. ACC is for magic accuracy gear.
	sets.Midcast.Enfeebling.ACC = {}
	-- sets.Midcast.Enfeebling.DT = {}
	-- sets.Midcast.Enfeebling.MEVA = {}

	-- Merged over the enfeebling set for the accuracy-based spells the engine's list names.
	sets.Midcast.Enfeebling.MACC = {}

	-- Merged over the enfeebling set when you cast a spell on the engine's potency list, such as
	-- Slow or Paralyze.
	sets.Midcast.Enfeebling.Potency = {}

	-- Merged over the enfeebling set when you cast a spell on the engine's duration list, such as
	-- Sleep, Bind or Silence.
	sets.Midcast.Enfeebling.Duration = {}

	-- Elemental nukes. A magic burst uses sets.Midcast.Burst instead.
	sets.Midcast.Nuke = {
		main = gear.idris,
		sub = gear.ammurapi,
		ammo = gear.ghastlyTathlumPlusOne,
		head = gear.eaHeadPlusOne,
		body = gear.eaBodyPlusOne,
		hands = gear.azimuthHandsPlusThree,
		legs = gear.azimuthLegsPlusThree,
		feet = gear.azimuthFeetPlusThree,
		neck = gear.mizukageNoKubikazari,
		waist = gear.acuityBeltPlusOne,
		left_ear = gear.malignanceEar,
		right_ear = gear.regalEarring,
		left_ring = gear.freke,
		right_ring = gear.metamorphPlusOne,
		back = gear.geoNukePdt,
	}

	-- Used instead of sets.Midcast.Nuke when the engine expects your nuke to land on the
	-- skillchain's target while the burst window is open, with an element that skillchain carries.
	-- A skillchain of its element that lands on your target while you cast puts this set on too.
	sets.Midcast.Burst = set_combine( sets.Midcast.Nuke, {})

	-- Merged over the nuke set in Occult mode, for Occult Acumen gear. A nuke the engine expects to
	-- burst uses the burst set instead, so in Occult mode it takes sets.Midcast.Burst.Occult. The
	-- mode's idle and engaged sets are TP mode's.
	sets.Midcast.Nuke.Occult = {}
	sets.Midcast.Burst.Occult = {}

	-- Merged over the nuke set in MB mode, for wearing burst gear on every nuke. It goes on when the
	-- engine does not expect the nuke to burst. A nuke it does expect to burst uses the burst set as
	-- usual. The mode's idle and engaged sets are TP mode's.
	sets.Midcast.Nuke.MB = {}

	-- Merged over the nuke set, or over the burst set, in ACC mode for magic accuracy gear, and in
	-- DT or MEVA mode once uncommented.
	sets.Midcast.Nuke.ACC = {}
	sets.Midcast.Burst.ACC = {}
	-- sets.Midcast.Nuke.DT = {}
	-- sets.Midcast.Nuke.MEVA = {}
	-- sets.Midcast.Burst.DT = {}
	-- sets.Midcast.Burst.MEVA = {}

	-- Used instead of the nuke set and the burst set when you cast Impact. The engine puts on the
	-- Crepuscular or Twilight Cloak you carry and removes your head piece. Uncomment the two lines
	-- below once you fill them in: once declared, the first replaces both for Impact even if it is
	-- empty, and its burst child set is merged over it when you cast Impact into a burst window of
	-- its element.
	-- sets.Midcast['Impact'] = set_combine(sets.Midcast.Nuke, {})
	-- sets.Midcast['Impact'].Burst = {}

	-- Cursna, merged over sets.Midcast.Enhancing.
	sets.Midcast.Cursna = set_combine( sets.Midcast.Cure, {
		left_ring = gear.menelausRing,
		right_ring = gear.haomaRing,
	})

	-- Sets named for one spell. A spell with its own set uses it instead of its family set, which
	-- is why each of these starts from a family set with set_combine.
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne3,
		waist = gear.siegel,
	})

	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, {
		head = gear.amalricHeadPlusOnePathA,
		hands = gear.regalCuffs,
	})

	sets.Midcast["Stun"] = set_combine( sets.Midcast.Nuke,{})

	sets.Midcast["Diaga"] = set_combine (sets.Midcast.Enfeebling, sets.TreasureHunter)

	sets.Midcast["Dispelga"] = set_combine (sets.Midcast.Enfeebling, sets.Midcast.Enfeebling.MACC, sets.TreasureHunter,{
		main = gear.daybreak
	})

	sets.Midcast.Refresh = {}
	sets.Midcast.Aspir = {}
	sets.Midcast.Drain = {}

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

	sets.Midcast.Regen = {}

	-- Dark magic, such as Bio. Aspir, Drain and Stun have sets of their own. Under /DRK, an absorb
	-- spell such as Absorb-TP takes the Absorb set merged over this one.
	sets.Midcast.Dark = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Dark.Absorb = {}

	-- Merged over the dark magic set in ACC, DT or MEVA mode, before the Absorb set or an enfeebling
	-- tier set.
	sets.Midcast.Dark.ACC = {}
	-- sets.Midcast.Dark.DT = {}
	-- sets.Midcast.Dark.MEVA = {}

	-- Geomancy spells. The engine never merges sets.Geomancy itself. An Indi-spell takes .Indi and
	-- a Geo-spell takes .Geo, unless the spell has a set of its own.
	sets.Geomancy = {}

	-- Indi-spells, built for duration.
	-- Under the Geomancy weapon lock, the main and sub named in this family swap in for the cast,
	-- and the weapon mode's pair returns after it. Under Locked, the mode's pair is worn instead.
	sets.Geomancy.Indi = {
		main = gear.idris,
		sub = gear.genmeiShield,
		range = gear.dunnaFC,
		head = gear.baguaArmorHeadPlusFour,
		body = gear.azimuthBodyPlusThree,
		hands = gear.geomancyHandsPlusFour,
		legs = gear.baguaArmorLegsPlusFour, -- 21
		feet = gear.azimuthFeetPlusThree, -- 30
		neck = gear.baguaCharmPlusTwo,
		waist = gear.luminarySash,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.etiolation,
		left_ring = gear.defending,
		right_ring = gear.gelatinousPlusOne,
		back = gear.lifestreamCape,
	}

	-- Merged over .Indi when the Indi-spell is cast on someone else, through Entrust.
	sets.Geomancy.Indi.Entrust = {
		main = gear.gadaNuke,
	}

	-- Geo-spells, built for potency.
	sets.Geomancy.Geo = set_combine( sets.Geomancy.Indi, {
		legs = gear.nyameLegs, -- 8/8
		feet = gear.azimuthFeetPlusThree, -- 11/11
	})

	-- Merged over .Indi or .Geo in DT or MEVA mode.
	-- sets.Geomancy.Indi.DT = {}
	-- sets.Geomancy.Indi.MEVA = {}
	-- sets.Geomancy.Geo.DT = {}
	-- sets.Geomancy.Geo.MEVA = {}

	-- ===================================================================================================================
	--		Pet gear, by when the game reads it
	-- ===================================================================================================================

	-- Gear read at your command. Worn from your pet command until it completes, merged over your
	-- idle or engaged set. The game checks delay and recast gear at the command, and the rest comes
	-- off before your pet acts, so gear for the move itself goes in the sets worn during your pet's
	-- move. The luopan takes no commands, so a Geomancer has no set here.

	-- Gear read during your pet's move. Worn from the moment your pet readies a move until it
	-- finishes, merged over the idle or engaged set you have on. This is when the game checks the
	-- move's damage, accuracy and potency gear. The luopan only uses a move when Radial Arcana,
	-- Mending Halation or Concentric Pulse makes it, and this set is worn for that move, with a set
	-- named for the move merged over it.
	sets.Pet_Midcast = {}

	-- Gear read while your pet is out. While you are idle with a pet out, sets.Idle.Pet is merged
	-- over your idle set and its offense mode set, then its own child set for your offense mode. It
	-- only needs the slots it changes, and the rest of your offense mode's idle gear stays on
	-- underneath.
	sets.Idle.Pet = { --2278/1482
		head = gear.azimuthHeadPlusThree, -- 11/11
		neck = gear.baguaCharmPlusTwo,
		body = gear.adamantiteArmor,
		feet = gear.baguaArmorFeetPlusFour,
		left_ring = gear.defending,
		hands = gear.geomancyHandsPlusFour,
	} -- 54 PDT / 45 MDT (with shield)

	-- Gear read while your pet fights. While your pet fights and you are idle,
	-- sets.Idle.Pet.Engaged is merged over sets.Idle.Pet, then its child set for your offense mode.
	-- When you fight too, your offense mode's sets hold the pet gear, so add an offense mode for
	-- fighting alongside your pet. Never name a mode Pet, since sets.Idle.Pet would then be used as
	-- that mode's idle set. The luopan never fights, so a Geomancer needs no set here.

	-- Keeps the Luopan's HP bonus. aftercast_custom wears it at the end of every Geo-spell. After
	-- that, Luopan() keeps it on in every build while a Bagua head is worn and the Luopan is above
	-- 68% HP.
	sets.Luopan = {
		head = gear.baguaArmorHeadPlusFour,
	}

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is merged over sets.Idle for every job ability, then the set named for
	-- the ability is merged over it. Any slot left empty keeps your idle gear.
	sets.JA = {}
	sets.JA["Collimated Fervor"] = {}
	sets.JA["Bolster"] = {
		body = gear.baguaArmorBodyPlusFour,
	}
	sets.JA["Full Circle"] = {
		head = gear.azimuthHeadPlusThree, -- 3
		hands = gear.baguaArmorHandsPlusFour,
	}
	sets.JA["Lasting Emanation"] = {}
	sets.JA["Ecliptic Attrition"] = {}
	sets.JA["Life Cycle"] = {
		body = gear.geomancyBodyPlusFour,
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

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- Merged over sets.Idle for every weaponskill. The set named for the weaponskill is merged over
	-- it, then the offense mode's set. Any slot left empty keeps your idle gear.
	sets.WS = {
		range = gear.dunnaFC,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
		left_ear = gear.moonshadeEarringAcc,
		right_ear = gear.telos,
		left_ring = gear.epimanondas,
		right_ring = gear.corneliaRing,
		back = gear.geoPetRegen,
	}

	-- Worn on weaponskills in ACC mode, over the set named for the weaponskill. List only the
	-- pieces the mode changes, since every slot named here overrides the weaponskill's own set. A
	-- weaponskill with an ACC set of its own, sets.WS['<name>'].ACC, takes that instead. The other
	-- mode sets work the same way, except that sets.WS.TP is never merged.
	sets.WS.ACC = {}

	-- Merged in DT mode after the set named for the weaponskill, so its gear wins, for damage taken
	-- gear. sets.WS.MEVA works the same way in MEVA mode, for magic evasion gear. A weaponskill
	-- with its own DT or MEVA set uses that instead. Every slot here costs some of the
	-- weaponskill's damage, so uncomment a line only once you fill it in.
	-- sets.WS.DT = {}
	-- sets.WS.MEVA = {}

	-- Merged over every weaponskill while Buff Level (Alt+F12) is set to HighBuff, for physical
	-- damage limit gear. At MidBuff, the default, no set is used here. In any offense mode except
	-- TP, the set for that mode and level is merged after it, such as sets.WS.ACC.HighBuff in ACC
	-- mode. A weaponskill's own HighBuff set, such as sets.WS['Black Halo'].HighBuff once
	-- sets.WS['Black Halo'] exists, replaces this one for that weaponskill, even if it is empty.
	sets.WS.HighBuff = {}
	sets.WS.ACC.HighBuff = {}

	-- Aftermath sets for weaponskills, merged after the weaponskill's own sets while the matching
	-- Aftermath is up. They work as the engaged Aftermath sets do.
	sets.WS.AM1 = {}
	sets.WS.AM2 = {}
	sets.WS.AM3 = {}
	sets.WS.AM3['Idris'] = {}

end

-------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE UNLESS YOU NEED TO MAKE JOB SPECIFIC RULES
-------------------------------------------------------------------------------------------------------------------

-- Called when the subjob changes.
function sub_job_change_custom(new, old)
	-- Typically used to change the macro book or set.
end

-- Called before each action, after the engine's own checks. Call cancel_spell() here to stop the
-- action.
function pretarget_custom(spell,action)

end

-- Called as each action starts. The table it returns is merged over the engine's precast set.
function precast_custom(spell)
	local equipSet = {}
	equipSet = set_combine(equipSet, Luopan())
	return equipSet
end

-- Called while each action is in progress. The table it returns is merged over the engine's midcast
-- set, which is empty for abilities, weaponskills and items.
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
-- engaged set. If one of your own actions is still in progress, it is still called right away, but
-- the table it returns is not used, and the gear change happens when that action ends.
function buff_change_custom(name,gain)
	local equipSet = {}
	-- Wear sets.Luopan when Blaze of Glory wears off, as after a Geo-spell.
	if name == "Blaze of Glory" and not gain then
		equipSet = set_combine(equipSet, sets.Luopan)
	end
	equipSet = set_combine(equipSet, Luopan())
	return equipSet
end

-- Called whenever the engine rebuilds the idle or engaged set, which it does after each action, on
-- a buff or status change, and when movement starts or stops. The table it returns is merged over
-- that set.
function choose_set_custom()
	local equipSet = {}
	equipSet = set_combine(equipSet, Luopan())
	return equipSet
end

-- Called when the player's status changes, such as engaging, disengaging or resting. The table it
-- returns is merged over the rebuilt idle or engaged set. If one of your own actions is still in
-- progress, the table is not used, and the gear change happens when that action ends.
function status_change_custom(new,old)
	local equipSet = {}
	equipSet = set_combine(equipSet, Luopan())
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
	equipSet = set_combine(equipSet, Luopan())
	return equipSet
end

-- Called when a pet's action ends. The table it returns is merged over the idle or engaged set the
-- engine rebuilds. If one of your own actions is still in progress, it is still called, but the
-- table it returns is not used, and the gear change happens when that action ends.
function pet_aftercast_custom(spell)
	local equipSet = {}
	-- The rebuilt set already carries Luopan() through choose_set_custom.
	return equipSet
end

-- Called while your pet's action is in progress. The table it returns is merged over the pet's
-- midcast sets.
function pet_midcast_custom(spell)
	local equipSet = {}
	equipSet = set_combine(equipSet, Luopan())
	return equipSet
end

-- Returns sets.Luopan while a Luopan is out above 68% HP and a Bagua head is already worn, so the
-- head's Luopan HP bonus stays on through every build. Otherwise it returns nothing, which
-- set_combine treats as an empty set. The gear hooks above call it, so it returns as early as it
-- can and builds no table. The log arguments are passed separately, so the text is joined only when
-- debug is on.
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

-- The engine calls Cycle_Timer about every 2 seconds. It skips the call during an action and while
-- you are dead, charmed or asleep.
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
