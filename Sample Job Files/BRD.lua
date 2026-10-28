-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: Bard. A sample to copy into your character's folder and fill in.
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

-- The in-game lockstyle set, macro book and macro set this file applies on load.
LockStylePallet = "9"
MacroBook = "9"
MacroSet = "1"

-- The food "gs c food" uses.
Food = "Tropical Crepe"

-- Weapon modes. Each name needs a matching sets.Weapons entry.
state.WeaponMode:options('Mordant Rime', 'Aeolian Edge', 'Shining Strike', 'Shining Blade', 'Savage Blade',
	'Evisceration', 'Rudra\'s Storm', 'Staff')
state.WeaponMode:set('Mordant Rime')

-- The weapon lock, and the one to start in. Unlocked lets any set change your weapons. Locked keeps
-- the pair your weapon mode names, and the TP on it, through every action, except where the engine
-- itself must put on a weapon: one a spell needs, sets.Weapons.Sleep while you are asleep, and a
-- Spell Received set. Songs is Locked, except that a song you sing on yourself, another player or a
-- Trust may change your weapons.
state.WeaponLock:options('Unlocked','Locked','Songs')
state.WeaponLock:set('Unlocked')

-- The buff level, and the one to start in. Only weaponskills read it: at HighBuff they wear their
-- HighBuff children, and at MidBuff only a weaponskill's own MidBuff child.
state.BuffLevel:options('MidBuff','HighBuff')
state.BuffLevel:set('MidBuff')

-- Offense modes. TP, ACC and DT are the engine's defaults, and more can be added. Each mode picks
-- its own engaged, idle and weaponskill sets, so each one offered needs a sets.OffenseMode.<Mode>
-- and a sets.Idle.<Mode> below.
state.OffenseMode:options('TP', 'ACC', 'DT', 'SB', 'MEVA', 'CRIT')

-- The offense mode the file starts in.
state.OffenseMode:set('TP')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup(LockStylePallet, MacroBook, MacroSet)

function get_sets()

	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	-- Weapon sets, one per weapon mode.
	sets.Weapons = {}

	sets.Weapons['Mordant Rime'] = {
		main = gear.carnwenhan,
		sub = gear.crepuscularKnife,
	}

	sets.Weapons['Aeolian Edge'] = {
		main = gear.carnwenhan,
		sub = gear.gleti,
	}

	sets.Weapons['Shining Strike'] = {
		main = gear.daybreak,
		sub = gear.gleti,
	}

	sets.Weapons['Shining Blade'] = {
		main = gear.naegling,
		sub = gear.daybreak,
	}

	sets.Weapons['Savage Blade'] = {
		main = gear.naegling,
		sub = gear.fusettoPlusTwo,
	}

	sets.Weapons['Staff'] = {
		main = gear.xoanon,
		sub = gear.alberStrap,
	}

	sets.Weapons['Evisceration'] = {
		main = 'Tauret',
		sub = gear.gleti,
	}

	sets.Weapons['Rudra\'s Storm'] = {
		main = gear.carnwenhan,
		sub = gear.gleti,
	}

	-- Weapons worn for every song, with the Precast or Midcast child merged over them in that
	-- phase.
	-- A weapon lock that does not exempt the song keeps the locked main and sub.
	sets.Weapons.Songs = {
		main = gear.carnwenhan,
		sub = gear.kaliPathD,
	}

	sets.Weapons.Songs.Precast = {}

	sets.Weapons.Songs.Midcast = {}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons.Shield = { sub = gear.genmeiShield, }

	-- Merged over the idle set when you are put to sleep. The slots it names stay locked until you
	-- wake up. Put gear here that wakes you, such as a piece that drains HP.
	sets.Weapons.Sleep = { range = gear.loughnashade, }

	-- Merged whole over a Cure, Curaga or Cura cast on Lightsday or in Light weather. Its main and
	-- sub are worn unless the weapon lock holds them.
	-- When this set is empty, the engine puts Chatoyant Staff in main alone, if you carry one.
	-- Without a Chatoyant Staff, remove main and sub from this set. The game refuses its grip
	-- beside a one-handed main.
	sets.Weapons['Light Bonus'] = {}

	-- Instruments the engine equips for songs: Count for dummy songs, Enfeebling for the engine's
	-- enfeebling songs (Requiem, Elegy, Threnody, Magic Finale and Pining Nocturne), AOE_Sleep for
	-- Horde Lullaby, Potency for every other song, Foe Lullaby and Maiden's Virelai included, and
	-- Pianissimo for a song sung on another player or a Trust.
	Instrument = {}
	Instrument.Count = { name = "Daurdabla" }
	Instrument.Potency = { name = "Gjallarhorn" }
	Instrument.Enfeebling = { name = "Gjallarhorn" }
	Instrument.Pianissimo = { name = "Gjallarhorn" }

	-- A family entry under Pianissimo, such as Ballad, replaces the general one when a song of that
	-- family is sung on another player or a Trust.
	-- Honor March and Aria of Passion always take their required instrument instead.
	Instrument.Pianissimo.Ballad = { name = "Miracle Cheer" }
	Instrument.AOE_Sleep = { name = "Daurdabla" }

	-- Linos variants this file names in its own sets below. The engine does not read these.
	Instrument.Idle = { name = "Linos", augments = { 'Mag. Evasion+15', '"Waltz" potency +4%', 'HP+20', } }
	Instrument.TP = { name = "Linos", augments = { 'Accuracy+20', '"Store TP"+4', 'Quadruple Attack +3', } }
	Instrument.Mordant = { name = "Linos", augments = { 'Accuracy+15 Attack+15', 'Weapon skill damage +3%', 'CHR+8', } }
	Instrument.QuickMagic = { name = "Linos", augments = { 'Mag. Evasion+15', 'Occ. quickens spellcasting +4%', 'HP+20', } }
	Instrument.FastCast = { name = "Linos", augments = { 'Mag. Evasion+15', '"Fast Cast"+6', 'HP+20', } }
	Instrument.WS = { name = "Linos", augments = { 'Accuracy+15 Attack+15', 'Weapon skill damage +3%', 'STR+8', } }
	Instrument.MAB = { name = "Linos", augments = { 'Mag.Atk.Bns."+15', 'Weapon skill damage +3%', 'INT+8', } }

	-- ===================================================================================================================
	--		sets.Idle
	-- ===================================================================================================================

	-- Worn whenever you are not engaged. Every action also starts from this set, so any slot an
	-- action's sets leave empty keeps your idle gear.
	sets.Idle = {
		range = Instrument.Idle, -- 4/0
		head = gear.filiHeadPlusThree, -- 11/11
		body = gear.adamantiteArmor, -- 20/20
		hands = gear.bunziHands, -- 8/8
		legs = gear.filiLegsPlusThree, -- 13/13
		feet = gear.filiFeetPlusThree, -- 18% Movement
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
		left_ear = gear.odnowaPlusOne, -- 3/3
		right_ear = gear.sanareEarring,
		left_ring = gear.wardenRing,
		right_ring = gear.shadowRing,
		back = gear.brdWaltz,
	}

	-- Merged over the idle sets while you rest.
	sets.Idle.Resting = {}

	-- Merged over the idle set while Sublimation is charging.
	sets.Idle.Sublimation = {}

	-- Idle sets for each offense mode, merged over the idle set.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {})
	sets.Idle.CRIT = set_combine(sets.Idle, {})

	-- Merged over the idle set while you have a Phantom Roll of 11. It is meant for Roller's Ring,
	-- which every job can wear and which gives Refresh +1 and Regain +10 on an 11, e.g.
	-- left_ring="Roller's Ring". This set applies in every offense mode. The TP set below applies
	-- only in TP mode and is merged after it. It is only worn while idle, so any action swaps it
	-- out, and it comes back when the action ends. While you move, a ring here replaces a movement
	-- ring in the same slot. This file's sets.Movement has no ring, so either slot works.
	sets.Idle.XIRoll = {}
	-- The TP mode version, merged after the one above.
	sets.Idle.TP.XIRoll = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = { feet = gear.filiFeetPlusThree }

	-- Worn when another character on this machine, running this engine, starts casting one of these
	-- spells on you, while Spell Received mode is ON. sets.Cursna_Received is also the Doom set,
	-- worn and held while you are doomed with that mode OFF.
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

	-- The ring slot Zodiac Ring goes in when an elemental spell matches the day's element:
	-- "right_ring" or "left_ring".
	Elemental_Bonus_Ring_Slot = "right_ring"

	-- Worn when you use a Holy Water or Hallowed Water.
	sets.Holy_Water = {
		neck = gear.nicander,
	}

	-- ===================================================================================================================
	--		sets.OffenseMode
	-- ===================================================================================================================

	-- Engaged sets. sets.OffenseMode is worn in every offense mode, and the current mode's set
	-- merges over it.
	sets.OffenseMode = {}

	-- TP mode, and the base most other modes build on.
	sets.OffenseMode.TP = {
		range = Instrument.TP,
		head = gear.bunziHead,
		body = gear.asheraHarness,
		hands = gear.bunziHands,
		legs = gear.volteTights,
		feet = gear.nyameFeet,
		neck = gear.bardCharmPlusTwo,
		waist = gear.windbuffetPlusOne, -- swapped out with Dual Wield
		left_ear = gear.telos,
		right_ear = gear.balderEarringPlusOne,
		left_ring = gear.lehkoHabhokaRing,
		right_ring = gear.chirichPlusOne2,
		back = gear.nullShawl,
	}

	sets.OffenseMode.DT = set_combine(sets.OffenseMode.TP, {
		legs = gear.filiLegsPlusThree,
		right_ring = gear.moonlightRing2,
	})

	sets.OffenseMode.ACC = set_combine(sets.OffenseMode.TP, {})

	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode.DT, {
		waist = gear.carriers,
	})

	sets.OffenseMode.SB = set_combine(sets.OffenseMode.TP, {
		left_ring = gear.chirichPlusOne1,
		right_ring = gear.chirichPlusOne2,
	})

	sets.OffenseMode.CRIT = set_combine(sets.OffenseMode.TP, {
		body = gear.adamantiteArmor,
		right_ring = gear.moonlightRing,
	})

	-- Aftermath sets, merged over the engaged set while the matching Aftermath is up. The engine
	-- uses the strongest active tier that has gear for the current weapon. A tier set applies with
	-- any weapon, and a child named for a weapon mode adds gear for that weapon only, such as
	-- sets.OffenseMode.AM3['Mordant Rime'] for the Carnwenhan in that weapon mode.
	sets.OffenseMode.AM1 = {}
	sets.OffenseMode.AM2 = {}
	sets.OffenseMode.AM3 = {}

	-- Merged over the engaged set while a dual-wield trait is active and a one-handed weapon is in
	-- your main hand.
	-- Only 9 is needed with Haste Samba and /DNC. /NIN needs 11 without Haste Samba and none with
	-- it.
	sets.DualWield = {
		waist = gear.reiki,
		--left_ear="Eabani Earring",
	}

	-- Treasure Hunter gear, worn on an action or melee swing against a monster not yet tagged, and
	-- throughout a fight in Full Time mode. It is never worn in None mode, where every job but
	-- Thief starts.
	sets.TreasureHunter = {
		body = gear.volteJupon,
		legs = gear.volteHose,
		waist = gear.chaac,
	}

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Every precast starts from sets.Idle, except a pet command's. For a spell, sets.Precast is
	-- merged over it, then the fast cast set. Any slot left empty keeps your idle gear.
	sets.Precast = {}

	-- Fast cast, worn at the start of every spell.
	sets.Precast.FastCast = {
		range = Instrument.QuickMagic, -- 4 Quick Magic
		head = gear.bunziHead,   -- 10
		body = gear.inyangaBodyPlusTwo, -- 14
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.volteLegs,   -- 9
		feet = gear.filiFeetPlusThree, -- 13
		neck = gear.voltsurge,   -- 4
		waist = gear.witful,     -- 3 3 Quick Magic
		left_ear = gear.etiolation, -- 1
		right_ear = gear.tuisto,
		left_ring = gear.kishar, -- 4
		right_ring = gear.weatherspoon, -- 5 3 Quick Magic
		back = gear.brdFCPdt,    -- 10
	}                            -- 81 FC and 10 Quick Magic

	-- Merged over the fast-cast set for songs. Fast cast is easy to cap, so this can stay empty.
	-- Under Nightingale a song's precast wears its whole midcast build instead, since the cast
	-- leaves no time to change gear.
	sets.Precast.Songs = {}
	-- Merged over the fast-cast set for cures.
	sets.Precast.Cure = {}
	-- Merged over the fast cast set when you cast a healing spell other than a cure, such as Raise
	-- or a -na spell.
	sets.Precast.Healing = {}
	-- Merged over the fast-cast set for enhancing magic.
	sets.Precast.Enhancing = {}
	-- Merged over the fast-cast set for Utsusemi.
	sets.Precast.Utsusemi = {}

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- The base for every cast, merged over sets.Idle on every midcast, so any slot it leaves empty
	-- keeps your idle gear.
	sets.Midcast = set_combine(sets.Idle, {
		waist = gear.carriers,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.alabaster,
		left_ring = gear.murky,
		right_ring = gear.defending,
	})

	-- Worn for every song but a dummy song, over the base above, and dressed for song duration and
	-- potency.
	-- A song's family set merges over it, and so does sets.Midcast.Enfeebling for Horde Lullaby and
	-- the engine's enfeebling songs (Requiem, Elegy, Threnody, Magic Finale and Pining Nocturne).
	sets.Midcast.Songs = {
		head = gear.filiHeadPlusThree, -- 11
		body = gear.filiBodyPlusThree,
		hands = gear.filiHandsPlusThree, -- 11
		legs = gear.inyangaLegsPlusTwo,
		feet = gear.briosoFeetPlusFour,
		neck = gear.moonbowWhistlePlusOne,
		back = gear.brdFCPdt,
	}

	-- Each casting set below but sets.Midcast.SIRD can take a child set named for an offense mode,
	-- such as sets.Midcast.Enfeebling.ACC. It is merged right over its set in that mode, so the sets
	-- merged after it still win any slot both fill. The DT and MEVA children are for damage taken
	-- and magic evasion gear. They ship commented out: uncomment one once you fill it in.

	-- Merged over the song set in DT or MEVA mode, before the enfeebling and family sets.
	-- sets.Midcast.Songs.DT = {}
	-- sets.Midcast.Songs.MEVA = {}

	-- Worn for dummy songs (the ones on the engine's SongCount list) instead of sets.Midcast.Songs,
	-- to keep a dummy song's duration low. Ballad is the lowest duration song.
	sets.Midcast.DummySongs = set_combine(sets.Idle, {})

	-- Spell interruption rate down. Used under every midcast except ranged attacks, so any more
	-- specific set overrides it.
	sets.Midcast.SIRD = {}

	-- Merged over sets.Midcast and sets.Midcast.SIRD when you cast any spell or song in ACC mode.
	-- The song set and the spell's own family set are merged after it, so they win any slot both
	-- fill. Enfeebling songs and spells also use sets.Midcast.Enfeebling.ACC below.
	sets.Midcast.ACC = {}

	-- Cure spells. Curaga shares this table below.
	sets.Midcast.Cure = {
		range = gear.linosFC,
		head = gear.kaykausHeadPlusOnePathB,
		body = gear.kaykausBodyPlusOnePathD,
		hands = gear.kaykausHandsPlusOnePathB,
		legs = gear.kaykausLegsPlusOnePathB,
		feet = gear.kaykausFeetPlusOnePathB,
		neck = gear.loricatePlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.alabaster,
		left_ring = gear.murky,
		right_ring = gear.defending,
		back = gear.brdFCPdt,
	} -- 50% Cure Potency / 15% Cure Potency II

	-- Merged over the cure set when you cast a cure on yourself. Curaga uses the same set as Cure,
	-- so the child sets below apply to it too.
	sets.Midcast.Cure.Self = {}

	-- Merged over the cure set when you cast a cure on anyone else, or on yourself under Accession.
	sets.Midcast.Cure.Others = {}

	-- Merged over the cure set in DT or MEVA mode.
	-- sets.Midcast.Cure.DT = {}
	-- sets.Midcast.Cure.MEVA = {}

	-- Each merged over the enhancing set: the first when you cast Regen, the second when you cast
	-- Refresh.
	sets.Midcast.Regen = {}
	sets.Midcast.Refresh = {}

	-- Enhancing magic, dressed for duration. Raise, Reraise and the -na spells take it too.
	sets.Midcast.Enhancing = {
		sub = gear.ammurapi,
		range = gear.linosFC,
		head = gear.telchineCapBEnhDur,
		body = gear.telchineChasubleBEnhDur,
		hands = gear.telchineGlovesCEnhDur,
		legs = gear.telchineBraconiBEnhDur,
		feet = gear.telchinePigachesBEnhDur,
		neck = gear.incanterTorque,
		waist = gear.embla,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.alabaster,
		left_ring = gear.murky,
		right_ring = gear.moonlightRing,
		back = gear.brdFCPdt,
	}

	-- Merged over the enhancing set: Elemental for elemental bar spells, Status for status bar
	-- spells, Skill for skill-based buffs.
	sets.Midcast.Enhancing.Elemental = {}
	sets.Midcast.Enhancing.Status = {}
	sets.Midcast.Enhancing.Skill = {}

	-- Merged over the enhancing set when you cast an enhancing spell on someone else, or on
	-- yourself under Accession.
	sets.Midcast.Enhancing.Others = {}

	-- Merged over the enhancing set in DT or MEVA mode, before the Others set.
	-- sets.Midcast.Enhancing.DT = {}
	-- sets.Midcast.Enhancing.MEVA = {}

	-- Curaga works differently from Cure but uses the same set here. Give it a set of its own to
	-- wear different gear for it.
	sets.Midcast.Curaga = sets.Midcast.Cure

	-- Cursna, merged over the enhancing set.
	sets.Midcast.Cursna = set_combine(sets.Midcast.Cure, {
		range = gear.linosFC,
		head = gear.kaykausHeadPlusOnePathB,
		body = gear.adamantiteArmor,
		hands = gear.inyangaHandsPlusTwo,
		legs = gear.kaykausLegsPlusOnePathB,
		feet = gear.gendewithaGaloshesPlusOne,
		neck = gear.loricatePlusOne,
		waist = gear.witful,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.alabaster,
		left_ring = gear.menelausRing,
		right_ring = gear.haomaRing,
		back = gear.brdFCPdt,
	})

	-- Worn when you cast divine magic, such as Banish or Repose.
	sets.Midcast.Divine = {}

	-- Merged over the divine set in ACC, DT or MEVA mode.
	sets.Midcast.Divine.ACC = {}
	-- sets.Midcast.Divine.DT = {}
	-- sets.Midcast.Divine.MEVA = {}

	-- Merged over the enhancing set when you cast Phalanx.
	sets.Midcast.Phalanx = {}

	-- Enfeebling magic, dressed for magic accuracy. Horde Lullaby and the engine's enfeebling songs
	-- take it too, over sets.Midcast.Songs, with their family set merged over it.
	sets.Midcast.Enfeebling = {
		sub = gear.ammurapi,
		range = Instrument.Potency,
		head = gear.briosoHeadPlusFour,
		body = gear.briosoBodyPlusFour,
		hands = gear.briosoHandsPlusFour,
		legs = gear.filiLegsPlusThree,
		feet = gear.briosoFeetPlusFour,
		neck = gear.moonbowWhistlePlusOne,
		waist = gear.nullWaist,
		left_ear = gear.crepuscularEar,
		right_ear = gear.regalEarring,
		left_ring = gear.stikiniRingPlusOne,
		right_ring = gear.stikiniRingPlusOne,
		back = gear.brdFCPdt,
	}

	-- Merged over the enfeebling set for the spells the engine's lists name: MACC for
	-- accuracy-based spells, Potency for potency-based ones, Duration for duration-based ones.
	sets.Midcast.Enfeebling.MACC = {}
	sets.Midcast.Enfeebling.Potency = {}
	sets.Midcast.Enfeebling.Duration = {}

	-- Merged over the enfeebling set in ACC, DT or MEVA mode, before the MACC, Potency or Duration
	-- set and the song family set. ACC is for magic accuracy gear.
	sets.Midcast.Enfeebling.ACC = {}
	-- sets.Midcast.Enfeebling.DT = {}
	-- sets.Midcast.Enfeebling.MEVA = {}

	-- Song family sets, merged over a song's other midcast sets. Every song belongs to one family,
	-- and dummy songs skip these.

	-- Lullaby, dressed for duration. Horde Lullaby takes it over the enfeebling set. Foe Lullaby
	-- takes no enfeebling set, so the child below, named for Foe Lullaby and Foe Lullaby II, is the
	-- enfeebling set with this set's pieces over it.
	sets.Midcast.Lullaby = {
		body = gear.filiBodyPlusThree,
		legs = gear.inyangaLegsPlusTwo,
	}
	sets.Midcast.Lullaby['Foe Lullaby'] = set_combine(sets.Midcast.Enfeebling, sets.Midcast.Lullaby)
	sets.Midcast.Lullaby['Foe Lullaby II'] = sets.Midcast.Lullaby['Foe Lullaby']

	sets.Midcast.Finale = {}
	sets.Midcast.Requiem = {}
	sets.Midcast.Elegy = {}
	sets.Midcast.Prelude = {}
	sets.Midcast.Madrigal = { head = gear.filiHeadPlusThree }
	sets.Midcast.Minuet = { body = gear.filiBodyPlusThree }
	sets.Midcast.March = { hands = gear.filiHandsPlusThree }
	sets.Midcast.Ballad = { legs = gear.filiLegsPlusThree }
	sets.Midcast.Scherzo = { feet = gear.filiFeetPlusThree }
	sets.Midcast.Mazurka = {}
	sets.Midcast.Paeon = { head = gear.briosoHeadPlusFour }
	sets.Midcast.Threnody = { body = gear.mousaiBodyPlusOne }
	sets.Midcast.Minne = { legs = gear.mousaiLegsPlusOne }
	sets.Midcast.Mambo = {}
	sets.Midcast.Carol = { hands = gear.mousaiHandsPlusOne }
	sets.Midcast.Etude = { head = gear.mousaiHeadPlusOne }
	sets.Midcast.Dirge = {}
	sets.Midcast.Sirvente = {}
	sets.Midcast.Aria = {}
	sets.Midcast.Hymnus = {}
	sets.Midcast.Virelai = {}
	sets.Midcast.Nocturne = {}

	-- Sets named for one spell. Each replaces the family set for that spell.
	sets.Midcast["Stoneskin"] = {
		waist = gear.siegel,
	}

	-- Worn when you cast Utsusemi, for spell interruption and damage taken gear.
	sets.Midcast.Utsusemi = {}
	-- Merged over the Utsusemi set in DT or MEVA mode.
	-- sets.Midcast.Utsusemi.DT = {}
	-- sets.Midcast.Utsusemi.MEVA = {}

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is merged over sets.Idle for every job ability, then the set named for
	-- the ability is merged over it. Any slot left empty keeps your idle gear.
	sets.JA = {}
	sets.JA["Nightingale"] = { feet = gear.bihuFeetPlusFour }
	sets.JA["Troubadour"] = { body = gear.bihuBodyPlusFour, }
	sets.JA["Soul Voice"] = { legs = gear.bihuLegsPlusFour }
	sets.JA["Tenuto"] = {}
	sets.JA["Marcato"] = {}
	sets.JA["Clarion Call"] = {}
	sets.JA["Pianissimo"] = {}

	-- Waltzes from your dancer subjob, merged over sets.Idle (Waltzes do not use sets.JA). A set
	-- named for one Waltz is merged over it. Built from sets.Idle.DT, it keeps you in that defensive
	-- gear while the Waltz goes off.
	sets.Waltz = set_combine(sets.Idle.DT, {
		range = Instrument.Idle, -- 4
		legs = gear.dashingSubligar, -- 10
		back = gear.brdWaltz, --10
	})                       -- 24% Potency

	-- Steps from your dancer subjob, merged over sets.Idle the same way (Steps do not use sets.JA).
	-- A set named for one Step is merged over it. Built from sets.Idle.DT, it keeps you in that
	-- defensive gear while the Step goes off.
	sets.Step = set_combine(sets.Idle.DT, {})

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- Weaponskill base, merged over sets.Idle for every weaponskill. The set named for the
	-- weaponskill is merged over it. Any slot left empty keeps your idle gear.
	sets.WS = {
		range = Instrument.WS,
		head = gear.nyameHead,
		body = gear.bihuBodyPlusFour,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.republicanPlatinumMedal,
		waist = gear.sailfi,
		left_ear = gear.moonshade,
		right_ear = gear.regalEarring,
		left_ring = gear.sroda,
		right_ring = gear.epimanondas,
		back = gear.brdWSDDt,
	}

	-- WSD and MAB are not offense modes. They are worn only through the weaponskill sets below that
	-- are built from them.
	sets.WS.WSD = set_combine(sets.WS, {

	})

	sets.WS.MAB = set_combine(sets.WS, {
		range = Instrument.MAB,
		neck = gear.sibylScarf,
		waist = gear.orpheusWaist,
		body = gear.nyameBody,
		left_ring = gear.metamorphPlusOne,
		back = gear.brdWSDInt,
	})

	-- Merged in ACC mode after the set named for the weaponskill, so its gear wins. Only fill in
	-- the slots ACC mode should change. A weaponskill with its own ACC set uses that instead.
	sets.WS.ACC = {}

	-- MEVA, CRIT and SB merge over the weaponskill sets in those modes, the same way.
	sets.WS.MEVA = {
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
	}

	sets.WS.CRIT = {
		neck = gear.fotiaNeck,
		waist = gear.fotiaWaist,
		left_ring = gear.hetairoi,
		right_ring = gear.ilabrat,
		back = gear.brdWSDDt,
	}

	sets.WS.SB = {
		left_ring = gear.chirichPlusOne1,
		right_ring = gear.chirichPlusOne2,
	}

	-- Merged in DT mode after the set named for the weaponskill, so its gear wins, for damage taken
	-- gear. A weaponskill with its own DT set uses that instead. Every slot here costs some of the
	-- weaponskill's damage, so uncomment it only once you fill it in.
	-- sets.WS.DT = {}

	-- Merged over every weaponskill while Buff Level (Alt+F12) is set to HighBuff, for physical
	-- damage limit gear. At MidBuff, the default, no set is used here. In any offense mode except
	-- TP, the set for that mode and level is merged after it, such as sets.WS.ACC.HighBuff in ACC
	-- mode. A weaponskill's own child sets replace these for that weaponskill, as shown at the end
	-- of this section.
	sets.WS.HighBuff = {
		body = gear.bunziBody,
	}
	sets.WS.ACC.HighBuff = {}

	sets.WS["Savage Blade"] = set_combine(sets.WS.WSD, {})

	sets.WS["Mordant Rime"] = set_combine(sets.WS, {
		range = Instrument.Mordant,
		neck = gear.bardCharmPlusTwo,
		waist = gear.grunfeldRope,
		left_ear = gear.ishvara,
		left_ring = gear.metamorphPlusOne,
		back = gear.brdWSDChr,
	})

	sets.WS["Evisceration"] = sets.WS.CRIT

	sets.WS["Aeolian Edge"] = set_combine(sets.WS.MAB, {
	})

	sets.WS["Burning Blade"] = sets.WS.MAB
	sets.WS["Shining Blade"] = set_combine(sets.WS.MAB, {
		right_ring = gear.weatherspoon,
	})
	sets.WS["Shining Strike"] = set_combine(sets.WS.MAB, {
		right_ring = gear.weatherspoon,
	})

	sets.WS["Shell Crusher"] = set_combine(sets.WS.WSD, {
	})

	sets.WS["Rudra's Storm"] = {}

	-- Aftermath sets for weaponskills, merged after the weaponskill's own sets while the matching
	-- Aftermath is up. They work as the engaged Aftermath sets do.
	sets.WS.AM1 = {}
	sets.WS.AM2 = {}
	sets.WS.AM3 = {}

	-- Child sets for a single weaponskill, used instead of the general sets.WS ones: one for a
	-- mode, one for HighBuff, and one for the two together. Once declared, each one replaces the
	-- general set for that weaponskill even if it is empty, so only uncomment a line after you fill
	-- it in. The mode and HighBuff line also needs the mode line above it.
	-- sets.WS["Savage Blade"].ACC = {}
	-- sets.WS["Savage Blade"].HighBuff = {}
	-- sets.WS["Savage Blade"].ACC.HighBuff = {}
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
