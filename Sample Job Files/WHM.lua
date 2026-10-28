-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: White Mage. A sample to copy into your character's folder and fill in.
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
LockStylePallet = "2"
MacroBook = "11"
MacroSet = "1"

-- The food item "gs c food" uses.
Food = "Miso Ramen"

-- Use a Remedy on paralysis or silence, and a Holy Water on doom, automatically.
AutoItem = false

-- Pick a random lockstyle from Lockstyle_List each time this file loads.
Random_Lockstyle = false

-- The equip sets the random lockstyle picks from.
Lockstyle_List = {1,2,6,12}

-- The offense modes this file offers, and the one to start in. The engine's defaults are TP, ACC
-- and DT.
-- Every mode offered here needs both a sets.OffenseMode.<Mode> entry and a sets.Idle.<Mode> entry.
-- The engine warns in chat each time it looks for a missing one.
state.OffenseMode:options('TP','ACC','DT','PDT','MEVA')
state.OffenseMode:set('DT')

-- The weapon modes, each naming a sets.Weapons entry below, and the one to start in.
state.WeaponMode:options('Seraph Strike','Black Halo','Asclepius','Mpaca')
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
jobsetup (LockStylePallet,MacroBook,MacroSet)

-- Balance 2100 HP / 1500 MP
function get_sets()

	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	-- One weapon set per weapon mode, keyed by the mode's name.
	sets.Weapons = {}

	sets.Weapons['Seraph Strike'] = {
		main = gear.daybreak,
	}

	sets.Weapons['Black Halo'] = {
		main = gear.maxentius,
		sub = gear.cathPalugHammer,
	}

	sets.Weapons['Asclepius'] = {
		main = gear.asclepius,
	}

	-- Worn in the offhand, idle or engaged, whenever the main is one-handed and no dual-wield trait
	-- is active.
	sets.Weapons['Shield'] = {
		sub = gear.genmeiShield,
	}

	-- Worn over the idle set when you are put to sleep, and held until the sleep ends. A piece that
	-- drains HP wakes you on its first tick.
	sets.Weapons['Sleep'] ={
		main = gear.lorgMor,
	}

	-- Merged whole over a Cure, Curaga or Cura cast on Lightsday or in Light weather. Its main and
	-- sub are worn unless the weapon lock holds them.
	-- When this set is empty, the engine puts Chatoyant Staff in main alone, if you carry one.
	-- Without a Chatoyant Staff, remove main and sub from this set. The game refuses its grip
	-- beside a one-handed main.
	sets.Weapons['Light Bonus'] = {
		main = gear.chatoyantStaff,
		sub = gear.enki,
		left_ring = gear.murky,
		right_ring = gear.gelatinousPlusOne,
		right_ear = gear.tuisto,
		waist = gear.hachirinNoObi,
	}

	sets.Weapons['Mpaca'] = {
		main = gear.mpacaStaff,
		sub = gear.enki,
	}

	-- ===================================================================================================================
	--		sets.Idle
	-- ===================================================================================================================

	-- Worn while idle. Every precast and midcast also starts from this set, so any slot an action's
	-- set leaves empty keeps your idle gear.
	sets.Idle = {
		ammo = gear.staunchPlusOne,
		head = gear.bunziHead,
		body = gear.ebersBodyPlusThree,
		hands = gear.bunziHands,
		legs = gear.ebersLegsPlusThree,
		feet = gear.chironicSlippersRefresh, -- +2 Refresh
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
		left_ear = gear.alabaster,
		right_ear = gear.etiolation, -- 1
		left_ring = gear.stikiniRingPlusOne1, -- +1 Refresh
		right_ring = gear.stikiniRingPlusOne2, -- +1 Refresh
		back = gear.whmFC,
	}

	-- Idle sets per offense mode, merged over sets.Idle in the matching mode. sets.Idle.Resting is
	-- merged while you rest.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {
		body = gear.adamantiteArmor,
		waist = gear.platinumMoogleBelt,
		right_ear = gear.heartyEarring,
	})
	sets.Idle.PDT = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle.DT, {
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
	})
	-- Merged over the idle set while Sublimation is charging.
	sets.Idle.Sublimation = {
		waist = gear.embla, -- +3 Sublimation when active
	}
	sets.Idle.Resting = {}

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
		feet = gear.heraldGaiters,
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
		ammo = gear.hastyPinionPlusOne,
		head = gear.bunziHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.unmovingPlusOne,
		waist = gear.grunfeldRope,
		left_ear = gear.crepuscularEar,
		right_ear = gear.telos,
		left_ring = gear.lehkoHabhokaRing,
		right_ring = gear.chirichPlusOne2,
		back = gear.whmDA,
	}

	sets.OffenseMode.TP = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.DT = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.PDT = set_combine(sets.OffenseMode, { })
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, { })

	-- Aftermath sets, merged over the engaged set while the matching Aftermath is up. The engine
	-- uses the strongest active tier that has gear for the current weapon. A tier set applies with
	-- any weapon, and a child named for a weapon mode adds gear for that weapon only, such as
	-- sets.OffenseMode.AM3['Tishtrya'] once a 'Tishtrya' weapon mode is offered above.
	sets.OffenseMode.AM1 = {}
	sets.OffenseMode.AM2 = {}
	sets.OffenseMode.AM3 = {}

	-- Merged over the mode's set while you are engaged with the Dual Wield trait active and a
	-- one-handed weapon in your main hand.
	sets.DualWield = {}

	-- Treasure Hunter gear. In every TH mode but None, it is worn on the action that tags a monster
	-- and while engaged on an untagged one. Full Time also wears it whenever you are engaged. Every
	-- job but Thief starts in None.
	sets.TreasureHunter = {}

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Every precast starts from sets.Idle, except a pet command's. For a spell, sets.Precast is
	-- merged over it, then the fast cast set. Any slot left empty keeps your idle gear.
	sets.Precast = {}

	-- Worn at the start of every spell. Fast cast gear goes here, and fast cast caps at 80%.
	sets.Precast.FastCast = {
		main = gear.asclepius,
		ammo = gear.impatiens, -- Quick Cast 2%
		head = gear.ebersHeadPlusThree, -- FC 13%
		body = gear.pingaBodyPlusOne, -- FC 15%
		hands = gear.gendewithaGagesPlusOneBCureFC, -- FC 7%
		legs = gear.pingaLegsPlusOne, -- FC 13%
		feet = gear.volteGaiters, -- FC 6%
		neck = gear.clericTorquePlusTwo,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.alabaster,
		right_ear = gear.etiolation,  -- FC 1%
		left_ring = gear.lehkoHabhokaRing,
		right_ring = gear.weatherspoon, -- FC 5%
		back = gear.whmFC, -- FC 10%
	} -- 80% FC 25% Haste 3k+ HP

	-- Merged over the fast cast set for cures.
	-- 3k HP, 80% Cast Speed, 25% gear haste
	sets.Precast.Cure = set_combine(sets.Precast.FastCast, { })

	-- Merged over the fast cast set when you cast enhancing magic.
	sets.Precast.Enhancing = set_combine(sets.Precast.FastCast, { })

	-- Merged over the fast cast set for Raise, Reraise, Arise, Esuna, Sacrifice and the -na spells.
	sets.Precast.Healing = set_combine(sets.Precast.FastCast, { })

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
	sets.Midcast = set_combine(sets.Idle, sets.Idle.DT, { })

	-- Spell interruption rate down. Used under every midcast except ranged attacks, so any more
	-- specific set overrides it.
	sets.Midcast.SIRD = {}

	-- Merged over sets.Midcast and sets.Midcast.SIRD when you cast any spell in ACC mode. The
	-- spell's own family set is merged after it, so that set wins any slot both fill.
	sets.Midcast.ACC = {}

	-- Each casting set below can take a child set named for an offense mode, such as
	-- sets.Midcast.Enfeebling.ACC. It is merged right over its set in that mode, so the sets merged
	-- after it still win any slot both fill. The DT and MEVA children are for damage taken and
	-- magic evasion gear. They ship commented out: uncomment one once you fill it in.

	-- Single-target cures, Cure through Cure VI.
	sets.Midcast.Cure = {
		main = gear.asclepius,
		sub = gear.ammurapi,
		ammo = gear.staunchPlusOne,
		head = gear.ebersHeadPlusThree,
		body = gear.ebersBodyPlusThree,
		hands = gear.theophanyHandsPlusFour,
		legs = gear.ebersLegsPlusThree,
		feet = gear.pietyFeetPlusFour,
		neck = gear.clericTorquePlusTwo,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.alabaster,
		right_ear = gear.ebersEarringPlusOneMacc,
		left_ring = gear.lebecheRing,
		right_ring = gear.najiLoop,
		back = gear.whmFC,
	}

	-- Worn on Cure through Cure VI while Afflatus Solace is up. Uncomment it to use it.
	-- Ebers Bliaut and Alaunus's Cape raise the Stoneskin that Solace grants from the HP each cure
	-- restores.
	-- It is for Cure only. Curaga and Cura below are copies of the Cure set and do not carry it,
	-- and Solace's bonus comes from Cure.
	-- sets.Midcast.Cure['Afflatus Solace'] = {}

	-- Merged over the cure set when you cast Cure through Cure VI on yourself.
	sets.Midcast.Cure.Self = {}

	-- Merged over the cure set when you cast Cure through Cure VI on anyone else, or on yourself
	-- under Accession. Curaga and Cura below only copy the cure set's gear, not its child sets.
	sets.Midcast.Cure.Others = {}

	-- Merged over the cure set in DT or MEVA mode.
	-- sets.Midcast.Cure.DT = {}
	-- sets.Midcast.Cure.MEVA = {}

	-- Curaga, the Cure set with these slots changed.
	sets.Midcast.Curaga = set_combine(sets.Midcast.Cure, { body=gear.theophanyBodyPlusFour,})

	-- Cura, the Cure set with these slots changed.
	sets.Midcast.Cura = set_combine(sets.Midcast.Cure, {
		main = gear.asclepius, body=gear.theophanyBodyPlusFour,
	})

	-- Merged over the Curaga or Cura set in DT or MEVA mode.
	-- sets.Midcast.Curaga.DT = {}
	-- sets.Midcast.Curaga.MEVA = {}
	-- sets.Midcast.Cura.DT = {}
	-- sets.Midcast.Cura.MEVA = {}

	-- Enhancing magic, where duration gear goes. Cursna and the healing spells with no set of their
	-- own, such as Raise, use it too.
	-- sets.Midcast.Enhancing.Others is merged over it when the target is not you, or when Accession
	-- is up.
	sets.Midcast.Enhancing = {
		main = gear.asclepius,
		sub = gear.ammurapi,
		ammo = gear.staunchPlusOne,
		head = gear.telchineCapRegen,
		body = gear.telchineChasubleRegen,
		hands = gear.telchineGlovesRegen,
		legs = gear.telchineBraconiRegen,
		feet = gear.theophanyFeetPlusFour,
		neck = gear.unmovingPlusOne,
		waist = gear.embla,
		left_ear = gear.alabaster,
		right_ear = gear.odnowaPlusOne,
		left_ring = gear.murky,
		right_ring = gear.defending,
		back = gear.whmFC,
	}
	sets.Midcast.Enhancing.Others = {}

	-- Merged over the enhancing set in DT or MEVA mode.
	-- sets.Midcast.Enhancing.DT = {}
	-- sets.Midcast.Enhancing.MEVA = {}

	-- Status bar-spells, merged over the enhancing set. Enhancing skill caps at 500 for bar-spells.
	--'Barsleepra','Barpoisonra','Barparalyzra','Barblindra','Barvira','Barpetra','Baramnesra','Barsilencera','Barsleep','Barpoison','Barparalyze','Barblind','Barvirus','Barpetrify','Baramnesia','Barsilence'
	sets.Midcast.Enhancing.Status = {
		ammo = gear.staunchPlusOne,
		head = gear.ebersHeadPlusThree,
		body = gear.ebersBodyPlusThree,
		hands = gear.ebersHandsPlusThree,
		legs = gear.pietyLegsPlusFour,
		feet = gear.ebersFeetPlusThree,
		left_ear = gear.alabaster,
		right_ear = gear.ebersEarringPlusOne,
		left_ring = gear.murky,
	}

	-- Elemental bar-spells, merged over the enhancing set. This is the status bar-spell set with
	-- these slots changed.
	--'Barfire','Barblizzard','Baraero','Barstone','Barthunder','Barwater','Barfira','Barblizzara','Baraera','Barstonra','Barthundra','Barwatera'
	sets.Midcast.Enhancing.Elemental = set_combine(sets.Midcast.Enhancing.Status, {
		main = gear.beneficus,
	})

	-- Skill-based enhancing spells, such as the Boost spells, merged over the enhancing set.
	--'Temper','Temper II','Enaero','Enstone','Enthunder','Enwater','Enfire','Enblizzard','Boost-STR','Boost-DEX','Boost-VIT','Boost-AGI','Boost-INT','Boost-MND','Boost-CHR'
	sets.Midcast.Enhancing.Skill = { }

	-- Enfeebling magic, where magic accuracy decides whether the spell lands. The set below that
	-- lists the spell is merged over it.
	sets.Midcast.Enfeebling = {
		main = gear.asclepius,
		sub = gear.ammurapi,
		ammo = gear.pemphredoTathlum,
		head = gear.theophanyHeadPlusFour,
		body = gear.theophanyBodyPlusFour,
		hands = gear.theophanyHandsPlusFour,
		legs = gear.chironicHoseNukeB,
		feet = gear.theophanyFeetPlusFour,
		neck = gear.nullLoop,
		waist = gear.obstinateSash,
		left_ear = gear.alabaster,
		right_ear = gear.ebersEarringPlusOneMacc,
		left_ring = gear.stikiniRingPlusOne,
		right_ring = gear.stikiniRingPlusOne,
		back = gear.nullShawl,
	}

	-- Merged over the enfeebling set for an accuracy-based spell: Dispel, Frazzle, Frazzle II,
	-- Poison, Poison II or Poisonga. Aspir and Drain take sets of their own, and Stun takes the dark
	-- magic sets.
	sets.Midcast.Enfeebling.MACC = {}

	-- Merged over the enfeebling set for a potency-based spell: Paralyze, Paralyze II, Slow, Slow
	-- II, Addle, Addle II, Distract, Distract II, Distract III, Frazzle III, Blind, Blind II, Gravity
	-- or Gravity II.
	sets.Midcast.Enfeebling.Potency = {}

	-- Merged over the enfeebling set for a duration-based spell: Sleep, Sleep II, Sleepga, Sleepga
	-- II, Dia, Dia II, Dia III, Diaga, Bio, Bio II, Bio III, Silence, Inundation, Break, Breakga,
	-- Bind or Bindga. Bio is dark magic, and takes this set over the dark magic set.
	sets.Midcast.Enfeebling.Duration = {
		left_ring = gear.kishar,
		hands = gear.regalCuffs,
	}

	-- Merged over the enfeebling set in ACC, DT or MEVA mode, before the MACC, Potency or Duration
	-- set. ACC is for magic accuracy gear.
	sets.Midcast.Enfeebling.ACC = {}
	-- sets.Midcast.Enfeebling.DT = {}
	-- sets.Midcast.Enfeebling.MEVA = {}

	-- Merged over the enhancing set when you cast Phalanx.
	sets.Midcast.Phalanx = set_combine(sets.Midcast.Enhancing.Skill, { })

	-- Worn when you cast dark magic, such as Stun or Bio. MACC and Absorb merge over it for the
	-- spells the engine's dark magic lists name: MACC for Stun, Absorb for the Absorb spells, such
	-- as Absorb-TP. MACC starts from the enfeebling MACC set's own pieces.
	sets.Midcast.Dark = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Dark.MACC = set_combine(sets.Midcast.Enfeebling.MACC, {})
	sets.Midcast.Dark.Absorb = {}

	-- Merged over the dark magic set in ACC, DT or MEVA mode, before the MACC or Absorb set.
	sets.Midcast.Dark.ACC = {}
	-- sets.Midcast.Dark.DT = {}
	-- sets.Midcast.Dark.MEVA = {}

	-- Worn when you cast divine magic: Banish, Holy, Flash or Repose.
	sets.Midcast.Divine = {}

	-- Merged over the divine set when you cast Repose, for magic accuracy gear. A set named for any
	-- divine spell, such as Flash, merges over the divine set the same way.
	sets.Midcast.Divine['Repose'] = {}

	-- Merged over the divine set when you cast a divine spell, such as Holy or Banish, into a burst
	-- window of its element.
	sets.Midcast.Divine.Burst = {}

	-- Merged over the divine set in ACC, DT or MEVA mode, before the Repose or burst set.
	sets.Midcast.Divine.ACC = {}
	-- sets.Midcast.Divine.DT = {}
	-- sets.Midcast.Divine.MEVA = {}

	-- Cursna, merged over the enhancing set.
	sets.Midcast["Cursna"] = {
		main = gear.yagrush,
		sub = gear.ammurapi,
		ammo = gear.staunchPlusOne,
		head = gear.vanyaHeadPathD,
		body = gear.ebersBodyPlusThree,
		hands = gear.fanaticGlovesFC,
		legs = gear.theophanyLegsPlusThree,
		feet = gear.gendewithaGaloshesPlusOneBCureFC,
		neck = gear.debilis,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.alabaster,
		right_ear = gear.ebersEarringPlusOneMacc,
		left_ring = gear.haomaRing,
		right_ring = gear.menelausRing,
		back = gear.whmFC,
	}

	-- Status-removal spells with sets of their own. Each set replaces the enhancing set for its
	-- spell.
	sets.Midcast["Erase"] = {
		main = gear.yagrush,
		neck = gear.clericTorquePlusTwo,
	}

	sets.Midcast["Esuna"] = {
		main = gear.asclepius,
	}

	sets.Midcast["Silena"] = {
		hands = gear.ebersHandsPlusThree,
		main = gear.yagrush
	}

	sets.Midcast["Poisona"] = {
		hands = gear.ebersHandsPlusThree,
		main = gear.yagrush
	}

	sets.Midcast["Paralyna"] = {
		hands = gear.ebersHandsPlusThree,
		main = gear.yagrush
	}

	sets.Midcast["Stona"] = {
		hands = gear.ebersHandsPlusThree,
		main = gear.yagrush
	}

	sets.Midcast["Blindna"] = {
		hands = gear.ebersHandsPlusThree,
		main = gear.yagrush
	}

	sets.Midcast["Viruna"] = {
		hands = gear.ebersHandsPlusThree,
		main = gear.yagrush
	}

	-- Buff sets for Divine Caress, worn while it is up on the status-removal spells above. Each of
	-- those spells has a set of its own, so the buff set sits under each one.
	-- Ebers Mitts and Mending Cape strengthen the resistance Divine Caress grants against the
	-- ailment a -na spell removes.
	-- The spells share one table, so fill it once. To use it, uncomment the table line and the line
	-- for each spell you want.
	-- local divine_caress = {}
	-- sets.Midcast["Cursna"]['Divine Caress'] = divine_caress
	-- sets.Midcast["Erase"]['Divine Caress'] = divine_caress
	-- sets.Midcast["Esuna"]['Divine Caress'] = divine_caress
	-- sets.Midcast["Silena"]['Divine Caress'] = divine_caress
	-- sets.Midcast["Poisona"]['Divine Caress'] = divine_caress
	-- sets.Midcast["Paralyna"]['Divine Caress'] = divine_caress
	-- sets.Midcast["Stona"]['Divine Caress'] = divine_caress
	-- sets.Midcast["Blindna"]['Divine Caress'] = divine_caress
	-- sets.Midcast["Viruna"]['Divine Caress'] = divine_caress

	-- Enhancing spells with sets of their own, each a copy of the enhancing set with these slots
	-- changed.
	sets.Midcast["Auspice"] = set_combine(sets.Midcast.Enhancing, {
		feet = gear.ebersFeetPlusThree,
	})

	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, {
		main = gear.vadoseRod,
		sub = gear.ammurapi,
		ammo = gear.impatiens,
		head = gear.chironicHatFC,
		body = gear.adamantiteArmor,
		hands = gear.regalCuffs,
		legs = gear.shedirSeraweels,
		feet = gear.theophanyFeetPlusFour,
		neck = gear.loricatePlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.alabaster,
		right_ear = gear.ebersEarringPlusOneMacc,
		left_ring = gear.murky,
		right_ring = gear.defending,
		back = gear.whmFC,
	})

	-- Merged over the enhancing set for Regen spells.
	sets.Midcast.Regen = {
		main = gear.bolelabunga,
		sub = gear.ammurapi,
		ammo = gear.staunchPlusOne,
		head = gear.inyangaHeadPlusTwo,
		body = gear.pietyBodyPlusFour,
		hands = gear.ebersHandsPlusThree,
		legs = gear.theophanyLegsPlusThree,
		feet = gear.bunziFeet,
		neck = gear.unmovingPlusOne,
		waist = gear.embla,
		left_ear = gear.alabaster,
		right_ear = gear.etiolation,
		left_ring = gear.murky,
		right_ring = gear.defending,
		back = gear.whmFC,
	}

	-- A set named for one spell replaces its family set for that spell, so Stoneskin skips the
	-- enhancing set. The exceptions are the cures, which always take the Cure, Curaga or Cura set,
	-- and Cursna, which takes the enhancing set with sets.Midcast.Cursna over it.
	sets.Midcast["Stoneskin"] = {
		main = gear.asclepius,
		sub = gear.genmeiShield,
		ammo = gear.staunchPlusOne,
		head = gear.nullMasque,
		body = gear.adamantiteArmor,
		hands = gear.ebersHandsPlusThree,
		legs = gear.shedirSeraweels,
		feet = gear.ebersFeetPlusThree,
		neck = gear.nodens,
		waist = gear.siegel,
		left_ear = gear.alabaster,
		right_ear = gear.earthcryEarring,
		left_ring = gear.stikiniRingPlusOne,
		right_ring = gear.stikiniRingPlusOne,
		back = gear.whmFC,
	}

	-- Merged over the enhancing set when you cast Refresh.
	sets.Midcast.Refresh = {}

	-- Worn when you cast Utsusemi, for spell interruption and damage taken gear.
	sets.Midcast.Utsusemi = {}
	-- Merged over the Utsusemi set in DT or MEVA mode.
	-- sets.Midcast.Utsusemi.DT = {}
	-- sets.Midcast.Utsusemi.MEVA = {}

	-- Used instead of the nuke set and the burst set when you cast Impact, for magic accuracy gear.
	-- The engine puts on the Crepuscular or Twilight Cloak you carry and removes your head piece.
	-- Uncomment the two lines below once you fill them in: once declared, the first replaces both
	-- for Impact even if it is empty, and its burst child set is merged over it when you cast
	-- Impact into a burst window of its element.
	-- sets.Midcast['Impact'] = {}
	-- sets.Midcast['Impact'].Burst = {}

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is merged over sets.Idle for every job ability, then the set named for
	-- the ability is merged over it. Any slot left empty keeps your idle gear.
	sets.JA = {}
	sets.JA["Benediction"] = {
		body = gear.pietyBodyPlusFour,
	}
	sets.JA["Divine Seal"] = {}
	sets.JA["Devotion"] = {
		head = gear.pietyHeadPlusFour,
	}
	sets.JA["Afflatus Solace"] = {}
	sets.JA["Afflatus Misery"] = {}
	sets.JA["Sacrosanctity"] = {}
	sets.JA["Asylum"] = {}

	-- Merged over sets.Idle when you use a Waltz. Waltzes do not use sets.JA.
	sets.Waltz = {}

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
		neck = gear.fotiaNeck,
		waist = gear.fotiaWaist,
		left_ear = gear.moonshadeEarringAcc,
		right_ear = gear.ishvara,
		left_ring = gear.ilabrat,
		right_ring = gear.epimanondas,
		back = gear.whmDA,
	}

	-- Worn on weaponskills in ACC mode, merged after the set named for the weaponskill so its slots
	-- win. It is skipped where sets.WS['<name>'].ACC exists.
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
	-- mode. A weaponskill's own HighBuff set, such as sets.WS['Black Halo'].HighBuff, replaces this
	-- one for that weaponskill, even if it is empty.
	sets.WS.HighBuff = {}
	sets.WS.ACC.HighBuff = {}

	-- Merged over sets.WS when you use Black Halo or Seraph Strike. Seraph Strike deals magic
	-- damage, so the engine adds the day, weather and distance pieces after it.
	sets.WS['Black Halo'] = {}
	sets.WS['Seraph Strike'] = {}

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
	-- A chat reminder after every action while neither Afflatus Solace nor Afflatus Misery is up.
	if not buffactive['Afflatus Solace'] and not buffactive['Afflatus Misery'] then
		add_to_chat(8,'You are not in a stance')
	end
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
