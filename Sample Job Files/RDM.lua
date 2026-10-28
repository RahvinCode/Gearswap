-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: Red Mage. A sample to copy into your character's folder and fill in.
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

-- The lockstyle set, macro book and macro set that jobsetup applies at load.
LockStylePallet = "6"
MacroBook = "3"
MacroSet = "1"

-- When true, the engine uses a Remedy on paralysis or silence and a Holy Water on Doom.
AutoItem = false

-- When true, each load picks a lockstyle set from Lockstyle_List instead of LockStylePallet.
Random_Lockstyle = false

-- The lockstyle sets Random_Lockstyle picks from.
Lockstyle_List = { 1, 2, 6, 12 }

-- The item that "gs c food" uses.
Food = "Tropical Crepe"

-- The offense modes this job cycles through, instead of the engine's default TP, ACC and DT. Each
-- mode needs a sets.OffenseMode.<Mode> and a sets.Idle.<Mode> below, and can also have a
-- sets.WS.<Mode>. state.OffenseMode:set picks the mode you start in. Occult and MB are nuking
-- modes, read by the nuke sets' children of the same name: Occult for Occult Acumen gear, MB for
-- burst gear on every nuke.
state.OffenseMode:options('TP', 'ACC', 'DT', 'SB', 'MEVA', 'CRIT', 'Enspell', 'Occult', 'MB')
state.OffenseMode:set('DT')

-- Weapon modes. Each one needs a sets.Weapons['<Mode>'] of the same name below.
state.WeaponMode:options('Seraph Blade', 'Sanguine Blade', 'Chant du Cygne', 'Savage Blade', 'Evisceration',
	'Aeolian Edge', 'Black Halo', 'Ullr', 'Crocea')
state.WeaponMode:set('Sanguine Blade')

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

-- Goal 2100 hp and 1300 MP
function get_sets()
	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	-- Weapon sets, one per weapon mode above.
	sets.Weapons = {}

	sets.Weapons['Seraph Blade'] = {
		main = gear.croceaMors,
		sub = gear.daybreak
	}

	sets.Weapons['Sanguine Blade'] = {
		main = gear.croceaMors,
		sub = gear.demersalDegenPlusOne,
	}

	sets.Weapons['Chant du Cygne'] = {
		main = gear.croceaMors,
		sub = gear.demersalDegenPlusOne,
	}

	sets.Weapons['Savage Blade'] = {
		main = gear.naegling,
		sub = gear.demersalDegenPlusOne,
	}

	sets.Weapons['Evisceration'] = {
		main = gear.tauret,
		sub = gear.gleti,
	}

	sets.Weapons['Aeolian Edge'] = {
		main = gear.tauret,
		sub = gear.demersalDegenPlusOne,
	}

	sets.Weapons['Black Halo'] = {
		main = gear.maxentius,
		sub = gear.machaeraPlusTwo,
	}

	sets.Weapons['Ullr'] = {
		main = gear.crocea1,
		sub = gear.crocea2,
		range = gear.ullr,
		ammo = gear.berylliumArrow,
	}

	sets.Weapons['Crocea'] = {
		main = gear.croceaMors,
		sub = gear.demersalDegenPlusOne,
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active,
	-- engaged or idle.
	sets.Weapons.Shield = {
		sub = gear.sacroBulwark,
	}

	-- Merged over the idle set when you are put to sleep. The slots it names stay locked until you
	-- wake up. Put gear here that wakes you, such as a piece that drains HP.
	sets.Weapons.Sleep = {
		sub = gear.caliburnus,
	}

	-- Merged whole over a Cure, Curaga or Cura cast on Lightsday or in Light weather. Its main and
	-- sub are worn unless the weapon lock holds them.
	-- When this set is empty, the engine puts Chatoyant Staff in main alone, if you carry one.
	-- Without a Chatoyant Staff, remove main and sub from this set. The game refuses its grip
	-- beside a one-handed main.
	sets.Weapons['Light Bonus'] = {}

	-- The arrow for the Ullr weapon mode. RA is not an offense mode, so the engine never puts
	-- Ammo.RA in a set on its own. The ranged sets below name it: the shot's precast and midcast,
	-- and ranged weaponskills. No offense mode has an Ammo entry here, so idle and melee keep their
	-- own ammo in every mode.
	Ammo.RA = "Beryllium Arrow"

	-- ===================================================================================================================
	--		sets.Idle
	-- ===================================================================================================================

	-- Worn while idle. Every action's precast and midcast also start from this set, so any slot
	-- their sets leave empty keeps your idle gear.
	sets.Idle = {
		ammo = gear.staunchPlusOne,      -- 3/3
		head = gear.vitiationChapeauPlusFour, -- +3 Refresh
		body = gear.lethargyBodyPlusThree, -- 14/14  +4 Refresh
		hands = gear.lethargyHandsPlusThree, -- 11/11
		legs = gear.bunziLegs,           -- 9/9
		feet = gear.bunziFeet,           -- 6/6
		neck = gear.loricatePlusOne,     -- 6/6
		waist = gear.carriers,
		left_ear = gear.etiolation,      -- Used to Keep HP/MP pool
		right_ear = gear.odnowaPlusOne,  --3/5
		left_ring = gear.stikiniRingPlusOne1, -- +1 Refresh
		right_ring = gear.stikiniRingPlusOne2, -- +1 Refresh
		back = gear.rdmFCPdt,            -- 10/0
	}
	-- Every offense mode but Occult and MB shares the base idle set in this file: each of those
	-- mode keys below is the same table as sets.Idle. Occult and MB start from copies of the DT
	-- idle set, so you sit in DT gear between casts. sets.Idle.Resting is a set of its own, merged
	-- over the idle set while you rest.
	sets.Idle.TP = sets.Idle
	sets.Idle.ACC = sets.Idle
	sets.Idle.DT = sets.Idle
	sets.Idle.SB = sets.Idle
	sets.Idle.MEVA = sets.Idle
	sets.Idle.CRIT = sets.Idle
	sets.Idle.Enspell = sets.Idle
	sets.Idle.Occult = set_combine(sets.Idle.DT, {})
	sets.Idle.MB = set_combine(sets.Idle.DT, {})
	sets.Idle.Resting = {}

	-- Worn over the idle set while a Phantom Roll on you stands at 11. It is for the Roller's
	-- Ring, which any job can wear and which gives Refresh +1 and Regain +10 at an 11, for example
	-- left_ring="Roller's Ring". It applies in every offense mode. sets.Idle.TP is the same table
	-- as sets.Idle in this file, so TP mode shares this set. It is only worn while idle, so any
	-- action swaps it out and it comes back when the action ends. While moving, a ring here
	-- replaces the movement set's ring in the same slot. This file's sets.Movement has no ring, so
	-- either slot works.
	sets.Idle.XIRoll = {}

	-- Worn over the idle set while Sublimation is charging.
	sets.Idle.Sublimation = {
		waist = gear.embla, -- +3 Sublimation when active
	}

	-- Worn over the idle set while moving and not engaged.
	sets.Movement = {
		legs = gear.carmineLegsPlusOnePathA,
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

	-- Subtle blow gear. sets.WS.SB below is this same table, so weaponskills in SB mode wear it.
	sets.Subtle_Blow = {}

	-- ===================================================================================================================
	--		sets.OffenseMode
	-- ===================================================================================================================

	-- The engaged base, merged first in every offense mode. The mode's own set is merged over it.
	sets.OffenseMode = {
		ammo = gear.coiste,
		head = gear.malignanceHead,
		body = gear.malignanceBody,
		hands = gear.malignanceHands,
		legs = gear.malignanceLegs,
		feet = gear.malignanceFeet,
		neck = gear.anu,
		waist = gear.sailfi,
		left_ear = gear.sherida,
		right_ear = gear.lethargyEarringPlusOne,
		left_ring = gear.chirichPlusOne1,
		right_ring = gear.chirichPlusOne2,
		back = gear.nullShawl,
	}

	sets.OffenseMode.TP = set_combine(sets.OffenseMode, {})
	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {})
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {})
	-- The engaged set for a PDT mode, which this file does not offer. It is read once you add
	-- 'PDT' to state.OffenseMode:options above, with sets.Idle.PDT = sets.Idle beside the other
	-- idle modes, and uncomment it.
	-- sets.OffenseMode.PDT = set_combine(sets.OffenseMode, {})
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, {})
	-- Occult and MB modes start from copies of the DT engaged set.
	sets.OffenseMode.Occult = set_combine(sets.OffenseMode.DT, {})
	sets.OffenseMode.MB = set_combine(sets.OffenseMode.DT, {})

	sets.OffenseMode.SB = set_combine(sets.OffenseMode, {
		hands = gear.volteMittens,
		legs = gear.volteTights,
		neck = gear.bathyPlusOne,
		waist = gear.sarissaphoroi,
	})

	sets.OffenseMode.CRIT = set_combine(sets.OffenseMode, {
		ammo = gear.yetshilaPlusOne,
		head = gear.blisteringSalletPlusOne,
		body = gear.adamantiteArmor,
		hands = gear.lethargyHandsPlusThree,
		legs = gear.bunziLegs,
		feet = gear.thereoidGreaves,
		neck = gear.nullLoop,
		waist = gear.reiki,
		left_ear = gear.sherida,
		right_ear = gear.lethargyEarringPlusOneDA,
		left_ring = gear.lehkoHabhokaRing,
		right_ring = gear.gelatinousPlusOne,
		back = gear.rdmCrit,
	})

	sets.OffenseMode.Enspell = set_combine(sets.OffenseMode, {
		range = gear.ullr,
		head = gear.umuthiHat,
		body = gear.lethargyBodyPlusThree,
		hands = gear.ayanmoHandsPlusTwo,
		legs = gear.vitiationTightsPlusThree,
		feet = gear.lethargyFeetPlusThree,
		neck = gear.quanpur,
		waist = gear.orpheusWaist,
		left_ear = gear.malignanceEar,
		right_ear = gear.lethargyEarringPlusOne,
		left_ring = gear.metamorphPlusOne,
		right_ring = gear.freke,
		back = gear.nullShawl,
	})

	-- Aftermath sets, merged over the engaged set while the matching Aftermath is up. The engine
	-- uses the strongest active tier that has gear for the current weapon. A tier set applies with
	-- any weapon, and a child named for a weapon mode adds gear for that weapon only, such as
	-- sets.OffenseMode.AM3['Murgleis'] once a 'Murgleis' weapon mode is offered above.
	sets.OffenseMode.AM1 = {}
	sets.OffenseMode.AM2 = {}
	sets.OffenseMode.AM3 = {}

	-- Worn over the mode's set while you are engaged with the Dual Wield trait active and a
	-- one-handed weapon in your main hand.
	sets.DualWield = {
		waist = gear.reiki,
		left_ear = gear.eabani,
	}

	-- Treasure Hunter gear. While TH Mode is Tag or Full Time, it is worn for an action aimed at an
	-- untagged monster and while engaged on one. Full Time also keeps it on whenever engaged. TH
	-- Mode starts at None, which never wears it, on every job but Thief.
	sets.TreasureHunter = {
		ammo = gear.perfectEgg,
		head = gear.volteHead,
		legs = gear.volteHose,
		waist = gear.chaac,
	}

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Every precast starts from sets.Idle, except a pet command's. For a spell or a ranged attack,
	-- sets.Precast is merged over it, then the fast cast set for a spell or sets.Precast.RA for a
	-- ranged attack. Any slot left empty keeps your idle gear.
	sets.Precast = {}

	-- Fast cast gear, worn at the start of every spell.
	-- 42% Fast Cast is needed on RDM (Fast Cast IX - 38%)
	-- 10% is Quick Magic limit
	sets.Precast.FastCast = {
		ammo = gear.impatiens,         -- 2 Quick Magic
		head = gear.bunziHead,         -- 10
		body = gear.vitiationBodyPlusThree, -- 15
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.kaykausLegsPlusOnePathB, -- 7
		feet = gear.bunziFeet,
		neck = gear.unmovingPlusOne,
		waist = gear.witful,               -- 3 Quick Magic
		left_ear = gear.etiolation,        -- Used to Keep HP/MP pool
		right_ear = gear.lethargyEarringPlusOne, -- 8
		left_ring = gear.lebecheRing,      -- 2 Quick Magic
		right_ring = gear.etanaRing,
		back = gear.perimedeCape,          -- 4 Quick Magic
	}                                      -- 50%+ total Fast Cast and 11% Quick Magic

	-- Merged over the fast cast set when you cast enhancing magic.
	sets.Precast.Enhancing = set_combine(sets.Precast.FastCast, {})

	-- Merged over the fast cast set for Cure, Curaga and Cura spells.
	sets.Precast.Cure = set_combine(sets.Precast.FastCast, {})

	-- Merged over the fast cast set when you cast a healing spell other than a cure, such as Raise
	-- or a -na spell.
	sets.Precast.Healing = {}

	-- Ranged attacks. The Flurry sets below go over it while Flurry is on you.
	sets.Precast.RA = set_combine(sets.Precast, {
		ammo = Ammo.RA,
		waist = gear.yemaya,         -- 0 / 5
		right_ring = gear.crepuscularRing, -- 3
	})

	-- While Flurry is on you.
	sets.Precast.RA.Flurry = set_combine(sets.Precast.RA, {})

	-- While Flurry II or Embrava is on you.
	sets.Precast.RA.Flurry_II = set_combine(sets.Precast.RA.Flurry, {})

	-- Merged over the fast cast set when you cast blue magic.
	sets.Precast.BlueMagic = set_combine(sets.Precast.FastCast, {})

	-- Merged over the fast cast set when you cast Utsusemi.
	sets.Precast.Utsusemi = {}

	-- Merged over the fast cast set when you cast Impact. The engine then puts on the Impact cloak
	-- you carry and removes your head piece.
	sets.Precast['Impact'] = {}

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- The base for every cast, merged over sets.Idle on every midcast, so any slot it leaves empty
	-- keeps your idle gear.
	sets.Midcast = set_combine(sets.Idle, {})

	-- Worn when you cast Utsusemi.
	sets.Midcast.Utsusemi = {}
	-- Merged over the Utsusemi set in DT or MEVA mode.
	-- sets.Midcast.Utsusemi.DT = {}
	-- sets.Midcast.Utsusemi.MEVA = {}

	-- Ranged attacks, while the shot is in flight. It has the arrow, so every shot keeps it on in
	-- every mode instead of the idle set's Staunch Tathlum +1. A set named for the offense mode is
	-- merged over it, except in TP mode.
	sets.Midcast.RA = set_combine(sets.Midcast, { ammo = Ammo.RA })

	sets.Midcast.RA.ACC = set_combine(sets.Midcast.RA, {
		ammo = Ammo.RA,
	})

	sets.Midcast.RA.CRIT = set_combine(sets.Midcast.RA, {})

	-- Spell interruption rate down. Used under every midcast except ranged attacks, so any more
	-- specific set overrides it.
	sets.Midcast.SIRD = {}

	-- Merged over sets.Midcast and sets.Midcast.SIRD when you cast any spell in ACC mode. The
	-- spell's own family set is merged after it, so that set wins any slot both fill. Enfeebles
	-- also use sets.Midcast.Enfeebling.ACC below.
	sets.Midcast.ACC = {}

	-- Each casting set below can take a child set named for an offense mode, such as
	-- sets.Midcast.Enfeebling.ACC. It is merged right over its set in that mode, so the sets merged
	-- after it still win any slot both fill. The DT and MEVA children are for damage taken and
	-- magic evasion gear. They ship commented out: uncomment one once you fill it in.

	-- Cure spells. Curaga takes its own set below.
	sets.Midcast.Cure = {
		ammo = gear.staunchPlusOne,
		head = gear.kaykausHeadPlusOnePathB, -- 11
		body = gear.kaykausBodyPlusOnePathD, -- 6
		hands = gear.kaykausHandsPlusOnePathB, -- 11
		legs = gear.kaykausLegsPlusOnePathB, -- 11
		feet = gear.kaykausFeetPlusOnePathB, -- 11
		neck = gear.loricatePlusOne,
		waist = gear.sacroCord,
		left_ear = gear.etiolation, -- Used to Keep HP/MP pool
		right_ear = gear.odnowaPlusOne,
		right_ring = gear.gelatinousPlusOne,
		left_ring = gear.defending,
		back = gear.rdmFCPdt,
	} -- 50% Cure I, 16% Cure II

	-- Merged over the cure set when you cast a cure on yourself.
	sets.Midcast.Cure.Self = {}

	-- Merged over the cure set when you cast a cure on anyone else, or on yourself under Accession.
	sets.Midcast.Cure.Others = {}

	-- Merged over the cure set in DT or MEVA mode.
	-- sets.Midcast.Cure.DT = {}
	-- sets.Midcast.Cure.MEVA = {}

	-- Worn when you cast Curaga.
	sets.Midcast.Curaga = set_combine(sets.Midcast.Cure, {})

	-- Merged over the Curaga set in DT or MEVA mode.
	-- sets.Midcast.Curaga.DT = {}
	-- sets.Midcast.Curaga.MEVA = {}

	-- Regen spells, over sets.Midcast.Enhancing.
	sets.Midcast.Regen = {
		feet = gear.bunziFeet,
	}

	-- Enhancing magic, built for duration. Every enhancing spell starts from this set, and the sets
	-- below go over it.
	sets.Midcast.Enhancing = {
		sub = gear.ammurapi,
		ammo = gear.staunchPlusOne,
		head = gear.telchineCapRegen,
		body = gear.vitiationBodyPlusThree, --15
		hands = gear.atrophyHandsPlusThree, -- 20
		legs = gear.telchineBraconiRegen,
		feet = gear.lethargyFeetPlusThree, -- 35
		neck = gear.duelistTorquePlusTwo,         --25
		waist = gear.embla,                --10
		left_ear = gear.etiolation,        -- Used to Keep HP/MP pool
		right_ear = gear.lethargyEarringPlusOne, -- 8
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
		back = gear.rdmFCPdt, -- 20
	}                   -- 150% Duration

	-- Merged over the enhancing set when you cast an enhancing spell on yourself without Accession.
	sets.Midcast.Enhancing.Self = {}

	-- Enhancing spells cast on someone else, and self-casts under Accession. Merged after
	-- sets.Midcast.Enhancing and before the family set.
	sets.Midcast.Enhancing.Others = {
		head = gear.lethargyHeadPlusThree,
		body = gear.lethargyBodyPlusThree,
		legs = gear.lethargyLegsPlusThree,
	}

	-- Worn on enhancing spells cast on someone else, or under Accession, while Composure is up.
	-- The Lethargy set bonus lengthens those spells under Composure and does nothing for a spell on
	-- yourself.
	-- sets.Midcast.Enhancing.Others.Composure = {}

	-- Merged over the enhancing set in DT or MEVA mode, before the Self or Others set.
	-- sets.Midcast.Enhancing.DT = {}
	-- sets.Midcast.Enhancing.MEVA = {}

	-- Spells that scale with enhancing skill: Temper, the first-tier en-spells and the Boost-stat
	-- spells. RDM needs only 500 skill for these. Temper II, which wants more, has a set of its own
	-- below.
	sets.Midcast.Enhancing.Skill = {
		sub = gear.ammurapi,
		head = gear.befouledCrown,
		body = gear.vitiationBodyPlusThree,
		hands = gear.vitiationGlovesPlusThree,
		legs = gear.atrophyLegsPlusThree,
		feet = gear.lethargyFeetPlusThree,
		neck = gear.incanterTorque,
		waist = gear.olympus,
		left_ear = gear.andoaaEarring,
		right_ear = gear.mimir,
	}

	-- Gain spells, over sets.Midcast.Enhancing.
	sets.Midcast.Enhancing.Gain = {
		hands = gear.vitiationGlovesPlusThree,
	}

	-- Merged over the enhancing set for elemental bar-spells.
	sets.Midcast.Enhancing.Elemental = {}

	-- Merged over the enhancing set for status bar-spells.
	sets.Midcast.Enhancing.Status = {}

	-- Blue magic, for a BLU subjob. The engine never merges sets.Midcast.BlueMagic itself, only the
	-- set for the engine's blue magic list that names the spell: Physical, Breath, Nuke, Skill,
	-- Buff, Enmity for the enfeebles that build enmity, Healing, or ACC for the enfeebles that only
	-- need to land.
	sets.Midcast.BlueMagic = {}
	sets.Midcast.BlueMagic.Physical = {}
	sets.Midcast.BlueMagic.Breath = {}
	sets.Midcast.BlueMagic.Skill = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Nuke = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Buff = {}
	sets.Midcast.BlueMagic.Healing = set_combine(sets.Midcast.Cure, {})
	sets.Midcast.BlueMagic.ACC = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Enmity = set_combine(sets.Enmity, {})

	-- Merged over a blue magic set in DT or MEVA mode.
	-- sets.Midcast.BlueMagic.Physical.DT = {}
	-- sets.Midcast.BlueMagic.Physical.MEVA = {}
	-- sets.Midcast.BlueMagic.Breath.DT = {}
	-- sets.Midcast.BlueMagic.Breath.MEVA = {}
	-- sets.Midcast.BlueMagic.Skill.DT = {}
	-- sets.Midcast.BlueMagic.Skill.MEVA = {}
	-- sets.Midcast.BlueMagic.Nuke.DT = {}
	-- sets.Midcast.BlueMagic.Nuke.MEVA = {}
	-- sets.Midcast.BlueMagic.Buff.DT = {}
	-- sets.Midcast.BlueMagic.Buff.MEVA = {}
	-- sets.Midcast.BlueMagic.Healing.DT = {}
	-- sets.Midcast.BlueMagic.Healing.MEVA = {}
	-- sets.Midcast.BlueMagic.ACC.DT = {}
	-- sets.Midcast.BlueMagic.ACC.MEVA = {}
	-- sets.Midcast.BlueMagic.Enmity.DT = {}
	-- sets.Midcast.BlueMagic.Enmity.MEVA = {}

	-- Enfeebling magic. The engine adds .MACC, .Potency or .Duration from its own spell lists.
	sets.Midcast.Enfeebling = {
		ammo = gear.regalGem,
		head = gear.vitiationChapeauPlusFour,
		body = gear.atrophyBodyPlusFour,
		hands = gear.lethargyHandsPlusThree,
		legs = gear.chironicHoseNuke,
		feet = gear.vitiationBootsPlusThree,
		neck = gear.duelistTorquePlusTwo,
		waist = gear.obstinateSash,
		left_ear = gear.snotra,
		right_ear = gear.regalEarring,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
		back = gear.rdmFCPdt,
	}

	-- Enfeebles that only need to land, such as Dispel, Frazzle and Poison. The elemental debuffs,
	-- such as Burn and Frost, take this set too.
	sets.Midcast.Enfeebling.MACC = {}

	-- Potency-based enfeebles, such as Paralyze, Slow, Addle, Distract, Blind and Gravity.
	sets.Midcast.Enfeebling.Potency = {
		ammo = gear.regalGem,          -- 10%
		body = gear.lethargyBodyPlusThree, -- 14%
		back = gear.rdmFCPdt,          -- 10%
		feet = gear.vitiationBootsPlusThree, -- 10%
		neck = gear.duelistTorquePlusTwo,     -- 10%
	}

	-- Merged over the potency set when you cast Frazzle III or Distract III, for enfeebling magic
	-- skill gear.
	sets.Midcast.Enfeebling.Potency['Frazzle III'] = {}
	sets.Midcast.Enfeebling.Potency['Distract III'] = {}

	-- Duration-based enfeebles, such as Sleep, Dia, Bio, Silence, Bind, Break and Inundation.
	sets.Midcast.Enfeebling.Duration = {
		head = gear.vitiationChapeauPlusFour, -- 15s (3 seconds x 5 merits)
		hands = gear.regalCuffs,        --20% swaps out with Saboteur active
		left_ear = gear.snotra,         -- 10%
		right_ring = gear.kishar,       -- 10%
		waist = gear.obstinateSash,     -- 5%
		neck = gear.duelistTorquePlusTwo,      -- 25%
	}

	-- Merged over the enfeebling set when you cast an enfeeble in ACC mode, before the MACC,
	-- Potency or Duration set, for magic accuracy gear.
	sets.Midcast.Enfeebling.ACC = {}

	-- Merged over the enfeebling set in DT or MEVA mode, before the MACC, Potency or Duration set.
	-- sets.Midcast.Enfeebling.DT = {}
	-- sets.Midcast.Enfeebling.MEVA = {}

	-- Worn while Saboteur is up on every spell that merges sets.Midcast.Enfeebling, which includes
	-- the elemental debuffs, enfeebling ninjutsu and enfeebling songs. The Lethargy Gantherots
	-- raise Saboteur's bonus and must be worn during the cast. Diaga and Dispelga have sets of
	-- their own below, which take the place of this family set, so the same table sits under each
	-- of them.
	sets.Midcast.Enfeebling.Saboteur = { hands = gear.lethargyHandsPlusThree, }

	-- Sets named for one spell. A spell with its own set uses it instead of the family set, which
	-- is why these start from the family set with set_combine.
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		neck = gear.nodens,
		waist = gear.siegel,
		left_ear = gear.earthcryEarring,
	})

	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, {
		hands = gear.regalCuffs,
		head = gear.amalricCoifPlusOne
	})

	-- Temper II keeps scaling with enhancing skill past 500, so it has a skill set of its own.
	sets.Midcast["Temper II"] = set_combine(sets.Midcast.Enhancing, {
		ammo = gear.psilomene,
		head = gear.befouledCrown,
		hands = gear.vitiationGlovesPlusThree,
		legs = gear.atrophyLegsPlusThree,
		neck = gear.incanterTorque,
		left_ear = gear.andoaaEarring,
		right_ear = gear.mimir,
		waist = gear.olympus,
		back = gear.perimedeCape,
	}) -- Max Enhancing 672

	sets.Midcast["Diaga"] = set_combine(sets.Midcast.Enfeebling, sets.TreasureHunter)
	sets.Midcast["Dispelga"] = set_combine(sets.Midcast.Enfeebling, sets.TreasureHunter)
	-- The Saboteur table from sets.Midcast.Enfeebling again, for the two spells above.
	sets.Midcast["Diaga"].Saboteur = sets.Midcast.Enfeebling.Saboteur
	sets.Midcast["Dispelga"].Saboteur = sets.Midcast.Enfeebling.Saboteur

	-- Merged over the enhancing set when you cast Refresh.
	sets.Midcast.Refresh = {
		head = gear.amalricCoifPlusOne,
		body = gear.atrophyBodyPlusFour,
		legs = gear.lethargyLegsPlusThree,
	}

	-- Merged over the enhancing set when you cast Phalanx.
	sets.Midcast.Phalanx = set_combine(sets.Midcast.Enhancing.Skill, {})

	-- Merged over the enhancing set when you cast Cursna.
	sets.Midcast.Cursna = {}

	-- Worn when you cast divine magic, such as Holy or Repose.
	sets.Midcast.Divine = {}

	-- Merged over the divine set when you cast a divine spell, such as Holy, into a burst window of
	-- its element.
	sets.Midcast.Divine.Burst = {}

	-- Merged over the divine set in ACC, DT or MEVA mode, before the burst set.
	sets.Midcast.Divine.ACC = {}
	-- sets.Midcast.Divine.DT = {}
	-- sets.Midcast.Divine.MEVA = {}

	-- Dark magic. MACC, Absorb and Enhancing merge over it for the spells the engine's dark magic
	-- lists name: MACC for Stun, Absorb for the Absorb spells, such as Absorb-TP, and Enhancing
	-- for Tractor. MACC starts from the enfeebling MACC set's own pieces.
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

	-- Elemental nukes. A magic burst uses sets.Midcast.Burst instead.
	sets.Midcast.Nuke = {
		sub = gear.ammurapi,
		ammo = gear.ghastlyTathlumPlusOne,
		head = gear.lethargyHeadPlusThree,
		body = gear.lethargyBodyPlusThree,
		hands = gear.lethargyHandsPlusThree,
		legs = gear.lethargyLegsPlusThree,
		feet = gear.lethargyFeetPlusThree,
		neck = gear.mizukageNoKubikazari,
		waist = gear.acuityBeltPlusOne,
		left_ear = gear.malignanceEar,
		right_ear = gear.regalEarring,
		left_ring = gear.metamorphPlusOne,
		right_ring = gear.freke,
		back = gear.rdmFCPdt,
	}

	-- Used instead of sets.Midcast.Nuke when the engine expects your nuke to land on the
	-- skillchain's target while the burst window is open, with an element that skillchain carries.
	-- A skillchain of its element that lands on your target while you cast puts this set on too.
	sets.Midcast.Burst = set_combine(sets.Midcast.Nuke, {
		left_ring = gear.mujinBand,
		neck = gear.mizukageNoKubikazari,
	})

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

	-- Used instead of the nuke set and the burst set when you cast Impact, for magic accuracy gear.
	-- The engine puts on the Crepuscular or Twilight Cloak you carry and removes your head piece.
	-- Uncomment the two lines below once you fill them in: once declared, the first replaces both
	-- for Impact even if it is empty, and its burst child set is merged over it when you cast
	-- Impact into a burst window of its element.
	-- sets.Midcast['Impact'] = set_combine(sets.Midcast.Nuke, {})
	-- sets.Midcast['Impact'].Burst = {}

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is merged over sets.Idle for every job ability, then the set named for
	-- the ability is merged over it. Any slot left empty keeps your idle gear.
	sets.JA = {}
	sets.JA["Chainspell"] = { body = gear.vitiationBodyPlusThree }
	sets.JA["Saboteur"] = {}
	sets.JA["Spontaneity"] = {}
	sets.JA["Stymie"] = {}
	sets.JA["Convert"] = {}
	sets.JA["Composure"] = {}

	-- Steps from your dancer subjob, merged over sets.Idle (Steps do not use sets.JA). A set named
	-- for one Step is merged over it. Built from sets.OffenseMode.DT, it keeps you in that defensive
	-- gear while the Step goes off.
	sets.Step = set_combine(sets.OffenseMode.DT, {})

	-- Waltzes from your dancer subjob, merged over sets.Idle the same way, and built the same way.
	-------------------------------------------------------------------------------
	-- Waltz Potency gear caps at 50%, while Waltz received potency caps at 30%. --
	-------------------------------------------------------------------------------
	sets.Waltz = set_combine(sets.OffenseMode.DT, {
		legs = gear.dashingSubligar, -- 10
		--ammo="Yamarang", -- 5
		--body={ name="Gleti's Cuirass", augments={'Path: A',}}, -- 10
		--hands="Slither Gloves +1", -- 5
	}) -- 10% Potency

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- Merged over sets.Idle for every weaponskill. The set named for the weaponskill is merged over
	-- it, then the offense mode's set. Any slot left empty keeps your idle gear.
	sets.WS = {
		ammo = gear.coiste,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.lethargyFeetPlusThree,
		neck = gear.duelistTorquePlusTwo,
		waist = gear.sailfi,
		left_ear = gear.sherida,
		right_ear = gear.lethargyEarringPlusOne,
		left_ring = gear.sroda,
		right_ring = gear.epimanondas,
		back = gear.rdmWSDDt,
	}

	-- Worn on weaponskills in ACC mode, over the set named for the weaponskill. List only the
	-- pieces the mode changes, since every slot named here overrides the weaponskill's own set. A
	-- weaponskill with an ACC set of its own, sets.WS['<name>'].ACC, takes that instead. The other
	-- mode sets work the same way, except that sets.WS.TP is never merged.
	sets.WS.ACC = {}

	-- WSD and MAB are not offense modes here. They are shared sets for the weaponskills below to
	-- point to.
	sets.WS.WSD = set_combine(sets.WS,
		{
			ammo = gear.oshashaTreatise,
			left_ear = gear.ishvara,
		})

	sets.WS.MAB = set_combine(sets.WS,
		{
			ammo = gear.oshashaTreatise,
			neck = gear.sanctity,
			waist = gear.orpheusWaist,
			left_ear = gear.malignanceEar,
			right_ear = gear.regalEarring,
		})

	-- CRIT mode. Chant du Cygne below uses this same table as its own set.
	sets.WS.CRIT = {
		ammo = gear.yetshilaPlusOne,
		head = gear.blisteringSalletPlusOne,
		neck = gear.fotiaNeck,
		waist = gear.fotiaWaist,
		right_ring = gear.hetairoi,
		back = gear.rdmCrit,
	}

	-- Ranged weaponskills, over sets.WS. It names the arrow, so a ranged weaponskill fires Ammo.RA
	-- in every offense mode.
	sets.WS.RA = { ammo = Ammo.RA }

	sets.WS.SB = sets.Subtle_Blow

	-- Merged in DT mode after the set named for the weaponskill, so its gear wins, for damage taken
	-- gear. sets.WS.MEVA works the same way in MEVA mode, for magic evasion gear. A weaponskill
	-- with its own DT or MEVA set uses that instead. Every slot here costs some of the
	-- weaponskill's damage, so uncomment a line only once you fill it in.
	-- sets.WS.DT = {}
	-- sets.WS.MEVA = {}

	-- Merged over every weaponskill while Buff Level (Alt+F12) is set to HighBuff, for physical
	-- damage limit gear. At MidBuff, the default, no set is used here. A ranged weaponskill uses
	-- sets.WS.RA.HighBuff instead. In any offense mode except TP, the set for that mode and level
	-- is merged after it, such as sets.WS.ACC.HighBuff in ACC mode.
	sets.WS.HighBuff = {
		ammo = gear.crepuscularPebble,
	}
	sets.WS.ACC.HighBuff = {}
	sets.WS.RA.HighBuff = {}

	-- Sets named for each weaponskill.
	sets.WS["Seraph Blade"] = set_combine(sets.WS.MAB, {
		right_ring = gear.weatherspoon,
		right_ear = gear.moonshadeEarringAcc,
	})

	sets.WS["Sanguine Blade"] = set_combine(sets.WS.MAB, {
		head = gear.pixieHead,
		right_ring = gear.archonRing,
	})

	sets.WS["Aeolian Edge"] = set_combine(sets.WS.MAB, {
		right_ear = gear.moonshadeEarringAcc,
	})

	sets.WS["Red Lotus Blade"] = sets.WS.MAB

	sets.WS["Chant du Cygne"] = sets.WS.CRIT

	sets.WS["Savage Blade"] = sets.WS.WSD

	sets.WS["Black Halo"] = sets.WS.WSD

	sets.WS["Evisceration"] = {}

	-- Aftermath sets for weaponskills, merged after the weaponskill's own sets while the matching
	-- Aftermath is up. They work as the engaged Aftermath sets do.
	sets.WS.AM1 = {}
	sets.WS.AM2 = {}
	sets.WS.AM3 = {}

	-- Child sets for a single weaponskill, used instead of the general sets.WS ones: one for a
	-- mode, one for HighBuff, and one for the two together. Once declared, each one replaces the
	-- general set for that weaponskill even if it is empty, so only uncomment a line after you fill
	-- it in. The mode and HighBuff line also needs the mode line above it. Savage Blade's set above
	-- is the same table as sets.WS.WSD, which Black Halo also uses, so the first line gives Savage
	-- Blade its own copy. Otherwise its child sets would apply to both.
	-- sets.WS['Savage Blade'] = set_combine(sets.WS.WSD, {})
	-- sets.WS['Savage Blade'].ACC = {}
	-- sets.WS['Savage Blade'].HighBuff = {}
	-- sets.WS['Savage Blade'].ACC.HighBuff = {}
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
function pretarget_custom(spell, action)

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
