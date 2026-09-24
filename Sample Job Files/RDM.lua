-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The lockstyle set, macro book and macro set that jobsetup applies at load.
LockStylePallet = "6"
MacroBook = "3"
MacroSet = "1"

-- When true, the engine uses a Remedy on paralysis or silence and a Holy Water on Doom.
AutoItem = false

-- When true, each load picks a lockstyle set from Lockstyle_List in place of LockStylePallet.
Random_Lockstyle = false

-- The lockstyle sets Random_Lockstyle picks from.
Lockstyle_List = { 1, 2, 6, 12 }

-- The item that "gs c food" uses.
Food = "Tropical Crepe"

-- The offense modes this job cycles through, in place of the engine's default TP, ACC and DT.
-- Each mode needs a sets.OffenseMode.<Mode> and a sets.Idle.<Mode> below, and can also have
-- a sets.WS.<Mode>. state.OffenseMode:set picks the mode selected at load.
state.OffenseMode:options('TP', 'ACC', 'DT', 'PDL', 'SB', 'MEVA', 'CRIT', 'Enspell')
state.OffenseMode:set('DT')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup(LockStylePallet, MacroBook, MacroSet)

-- Weapon modes. Each one needs a sets.Weapons['<Mode>'] of the same name below.
state.WeaponMode:options('Seraph Blade', 'Sanguine Blade', 'Chant du Cygne', 'Savage Blade', 'Evisceration',
	'Aeolian Edge', 'Black Halo', 'Ullr', 'Crocea')
state.WeaponMode:set('Sanguine Blade')

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

	-- Worn with the idle set when this character is put to sleep. Its slots are held until the
	-- sleep ends, and nothing else changes gear while asleep.
	sets.Weapons.Sleep = {
		sub = gear.caliburnus,
	}

	-- The arrow for the Ullr weapon mode. RA is not an offense mode, so the engine never puts
	-- Ammo.RA in a set on its own. The ranged sets below name it: the shot's precast, the shot in
	-- ACC mode, and ranged weaponskills. No offense mode has an Ammo entry here, so idle and melee
	-- keep their own ammo in every mode.
	Ammo.RA = "Beryllium Arrow"

	-- ===================================================================================================================
	--		sets.Idle
	-- ===================================================================================================================

	-- Worn while idle. Every action's precast and midcast also start from this set, so a slot
	-- their sets leave out keeps its idle piece.
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
	-- Every offense mode, and resting, share the base idle set in this file. Each key below is the
	-- same table as sets.Idle.
	sets.Idle.TP = sets.Idle
	sets.Idle.ACC = sets.Idle
	sets.Idle.DT = sets.Idle
	sets.Idle.PDL = sets.Idle
	sets.Idle.SB = sets.Idle
	sets.Idle.MEVA = sets.Idle
	sets.Idle.CRIT = sets.Idle
	sets.Idle.Enspell = sets.Idle
	sets.Idle.Resting = sets.Idle

	-- Worn over the idle set while a Phantom Roll on you stands at 11. It is for the Roller's
	-- Ring, which any job can wear and which gives Refresh +1 and Regain +10 at an 11, for example
	-- left_ring="Roller's Ring". It applies in every offense mode. sets.Idle.TP is the same table
	-- as sets.Idle in this file, so TP mode shares this set. It is worn only while idle, so any
	-- action swaps it out and it comes back when the action ends. While moving, a ring here
	-- replaces the movement set's ring in the same slot. This file's sets.Movement names no ring,
	-- so either slot is free.
	sets.Idle.XIRoll = {}

	-- Worn over the idle set while Sublimation is charging.
	sets.Idle.Sublimation = set_combine(sets.Idle, {
		waist = gear.embla, -- +3 Submlimation when active
	})

	-- Worn over the idle set while moving and not engaged.
	sets.Movement = {
		legs = gear.carmineLegsPlusOnePathA,
	}

	-- Worn when another character on this machine, running this engine, casts on you. Spell
	-- Received mode must be ON. sets.Cursna_Received is also the Doom set, worn when that mode is OFF.
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

	-- The engaged base, merged first in every offense mode. The mode's own set goes over it.
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
	-- A placeholder. PDT is not offered above. To offer it, add 'PDT' to state.OffenseMode:options
	-- and add sets.Idle.PDT = sets.Idle with the other idle modes. This engaged set is ready.
	sets.OffenseMode.PDT = set_combine(sets.OffenseMode, {})
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, {})

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
	sets.OffenseMode.PDL = set_combine(sets.OffenseMode, {})

	-- Worn while engaged with the Dual Wield trait active, over the mode's set.
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

	-- Precast sets, worn as an action starts.
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

	-- Merged over the fast cast set for enhancing magic.
	sets.Precast.Enhancing = set_combine(sets.Precast.FastCast, {})

	-- Merged over the fast cast set for Cure, Curaga and Cura spells.
	sets.Precast.Cure = set_combine(sets.Precast.FastCast, {})

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

	sets.Precast.BlueMagic = set_combine(sets.Precast.FastCast, {})

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this
	-- set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {})

	sets.Midcast.Utsusemi = set_combine(sets.Midcast, {})

	-- Ranged attacks, while the shot is in flight. It names the arrow, so every shot keeps it on in
	-- every mode instead of the idle set's Staunch Tathlum +1. A set named for the offense mode
	-- goes over it, except in TP mode.
	sets.Midcast.RA = set_combine(sets.Midcast, { ammo = Ammo.RA })

	sets.Midcast.RA.ACC = set_combine(sets.Midcast.RA, {
		ammo = Ammo.RA,
	})

	sets.Midcast.RA.PDL = set_combine(sets.Midcast.RA, {})

	sets.Midcast.RA.CRIT = set_combine(sets.Midcast.RA, {})

	-- Spell interruption rate down. Merged under every midcast except a ranged attack, so any
	-- specific set overwrites it.
	sets.Midcast.SIRD = {}

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

	sets.Midcast.Curaga = set_combine(sets.Midcast.Cure, {})

	-- Regen spells, over sets.Midcast.Enhancing.
	sets.Midcast.Regen = {
		feet = gear.bunziFeet,
	}

	-- Enhancing magic, built for duration. Every enhancing spell starts from this set, and the
	-- sets below go over it.
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

	-- Enhancing spells cast on someone else, and self-casts under Accession. Merged after
	-- sets.Midcast.Enhancing and before the family set.
	sets.Midcast.Enhancing.Others = set_combine(sets.Midcast.Enhancing, {
		head = gear.lethargyHeadPlusThree,
		body = gear.lethargyBodyPlusThree,
		legs = gear.lethargyLegsPlusThree,
	})

	-- Worn on enhancing spells cast on someone else, or under Accession, while Composure is up.
	-- The Lethargy set bonus lengthens those spells under Composure and does nothing for a spell
	-- on yourself.
	-- sets.Midcast.Enhancing.Others.Composure = {}

	-- Spells that scale with enhancing skill: Temper, the first-tier en-spells and the Boost-stat
	-- spells. RDM needs only 500 skill for these. Temper II, which wants more, has a set of its own
	-- below.
	sets.Midcast.Enhancing.Skill = set_combine(sets.Midcast.Enhancing, {
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
	})

	-- Gain spells, over sets.Midcast.Enhancing.
	sets.Midcast.Enhancing.Gain = set_combine(sets.Midcast.Enhancing, {
		hands = gear.vitiationGlovesPlusThree,
	})

	-- Elemental bar-spells.
	sets.Midcast.Enhancing.Elemental = set_combine(sets.Midcast.Enhancing, {})

	-- Status bar-spells.
	sets.Midcast.Enhancing.Status = set_combine(sets.Midcast.Enhancing, {})

	-- Blue magic, for a BLU subjob. The engine never merges sets.Midcast.BlueMagic itself, only the
	-- family set a spell's list names.
	sets.Midcast.BlueMagic = {}
	sets.Midcast.BlueMagic.Skill = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Nuke = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Healing = set_combine(sets.Midcast.Cure, {})
	sets.Midcast.BlueMagic.ACC = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Enmity = set_combine(sets.Enmity, {})

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
	sets.Midcast.Enfeebling.MACC = set_combine(sets.Midcast.Enfeebling, {})

	-- Potency-based enfeebles, such as Paralyze, Slow, Addle, Distract, Blind and Gravity.
	sets.Midcast.Enfeebling.Potency = set_combine(sets.Midcast.Enfeebling, {
		ammo = gear.regalGem,          -- 10%
		body = gear.lethargyBodyPlusThree, -- 14%
		back = gear.rdmFCPdt,          -- 10%
		feet = gear.vitiationBootsPlusThree, -- 10%
		neck = gear.duelistTorquePlusTwo,     -- 10%
	})

	-- Duration-based enfeebles, such as Sleep, Dia, Bio, Silence, Bind, Break and Inundation.
	sets.Midcast.Enfeebling.Duration = set_combine(sets.Midcast.Enfeebling, {
		head = gear.vitiationChapeauPlusFour, -- 15s (3 seconds x 5 merits)
		hands = gear.regalCuffs,        --20% swaps out with Saboteur active
		left_ear = gear.snotra,         -- 10%
		right_ring = gear.kishar,       -- 10%
		waist = gear.obstinateSash,     -- 5%
		neck = gear.duelistTorquePlusTwo,      -- 25%
	})

	-- Worn while Saboteur is up on every spell that merges sets.Midcast.Enfeebling, which includes
	-- the elemental debuffs, enfeebling ninjutsu and enfeebling songs. The Lethargy Gantherots
	-- raise Saboteur's bonus and must be worn during the cast. Diaga and Dispelga have sets of their
	-- own below, which take the place of this family set, so the same table sits under each of them.
	sets.Midcast.Enfeebling.Saboteur = { hands = gear.lethargyHandsPlusThree, }

	-- Sets named for one spell. Such a set takes the place of the spell's family set, which is why
	-- these start from the family set with set_combine.
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

	sets.Midcast.Refresh = set_combine(sets.Midcast.Enhancing, {
		head = gear.amalricCoifPlusOne,
		body = gear.atrophyBodyPlusFour,
		legs = gear.lethargyLegsPlusThree,
	})

	sets.Midcast.Phalanx = set_combine(sets.Midcast.Enhancing.Skill, {})

	sets.Midcast.Dark = set_combine(sets.Midcast.Enfeebling, {})

	sets.Midcast.Dark.MACC = set_combine(sets.Midcast.Enfeebling.MACC, {})

	sets.Midcast.Dark.Absorb = set_combine(sets.Midcast.Enfeebling, {})

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

	-- Magic bursts, in place of sets.Midcast.Nuke. A nuke bursts when it lands on the skillchain's
	-- target within 8 seconds and its element matches the skillchain.
	sets.Midcast.Burst = set_combine(sets.Midcast.Nuke, {
		left_ring = gear.mujinBand,
		neck = gear.mizukageNoKubikazari,
	})

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is worn for every ability, and a set named for the ability goes over it.
	sets.JA = {}
	sets.JA["Chainspell"] = { body = gear.vitiationBodyPlusThree }
	sets.JA["Saboteur"] = {}
	sets.JA["Spontaneity"] = {}
	sets.JA["Stymie"] = {}
	sets.JA["Convert"] = {}
	sets.JA["Composure"] = {}

	-- Dancer abilities, for a DNC subjob. Each family set is worn for its abilities, with a set
	-- named for one ability over it.
	sets.Flourish = set_combine(sets.Idle.DT, {})

	sets.Jig = set_combine(sets.Idle.DT, {})

	sets.Step = set_combine(sets.OffenseMode.DT, {})

	sets.Samba = set_combine(sets.Idle.DT, {})

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

	-- Worn on every weaponskill. The set named for the weaponskill goes over it, then the offense
	-- mode's set.
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

	sets.WS.PDL = {
		ammo = gear.crepuscularPebble,
	}

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
function pretarget_custom(spell, action)

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

-- Called when a buff is gained or lost. The table it returns is merged over the rebuilt idle or
-- engaged set. A change during one of your own actions is dressed when the action ends instead.
function buff_change_custom(name, gain)
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
function status_change_custom(new, old)
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
function pet_change_custom(pet, gain)
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
