-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: Summoner. A sample to copy into your character's folder and fill in.
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

-- The in-game equip set used for lockstyle, and the macro book and set to switch to on load.
LockStylePallet = "1"
MacroBook = "2"
MacroSet = "1"

-- The food item "gs c food" uses.
Food = "Grape Daifuku"

-- Use a Remedy on paralysis or silence, and a Holy Water on doom, automatically.
AutoItem = false

-- Pick a random lockstyle from Lockstyle_List each time this file loads.
Random_Lockstyle = false

-- The equip sets the random lockstyle picks from.
Lockstyle_List = {1,2,6,12}

-- The offense mode to start in. This file offers the engine's default modes, TP, ACC and DT.
state.OffenseMode:set('DT')

-- The weapon modes, each naming a sets.Weapons entry below, and the one to start in.
state.WeaponMode:options('Nirvana','Mpaca')
state.WeaponMode:set('Nirvana')

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

-- The pet mode, the second job mode (Ctrl+F11). Under Auto, Pet_Modes below gives the value for the
-- pet you summon, and a value you pick by hand holds on every pet until you cycle back to Auto. The
-- value names a child of sets.Idle.Pet and of sets.Idle.Pet.Engaged, and, while a pet is out, of
-- your offense mode's set.
UI_Name2 = 'Pet Mode'
state.JobMode2:options('Auto','Spirit','Carbuncle','Cait Sith')
state.JobMode2:set('Auto')

-- The value Auto gives each pet, by its name. The spirits share Spirit, and Carbuncle and Cait Sith
-- have hands of their own. An avatar not listed wears the pet sets alone.
Pet_Modes = {
	FireSpirit = 'Spirit', IceSpirit = 'Spirit', AirSpirit = 'Spirit', EarthSpirit = 'Spirit',
	ThunderSpirit = 'Spirit', WaterSpirit = 'Spirit', LightSpirit = 'Spirit', DarkSpirit = 'Spirit',
	Carbuncle = 'Carbuncle',
	['Cait Sith'] = 'Cait Sith',
}

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	-- One weapon set per weapon mode, keyed by the mode's name.
	sets.Weapons = {}

	sets.Weapons['Nirvana'] = {
		main = gear.nirvana,
		sub = gear.elanStrapPlusOne,
	}

	sets.Weapons['Mpaca'] = {
		main = gear.mpacaStaff,
		sub = gear.enki,
	}

	-- Worn in the offhand, idle or engaged, whenever the main is one-handed and no dual-wield trait
	-- is active. It also comes with Daybreak, which Dispelga puts in your main hand, when your main
	-- is a staff.
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

	-- Worn while idle. Every precast and midcast also starts from this set, except a blood pact's
	-- or another pet command's, so any slot an action's set leaves empty keeps your idle gear. A
	-- pet command starts from the idle or engaged set you have on. This set has no weapon, since
	-- the weapon mode handles the staff and grip.
	sets.Idle = {
		ammo = gear.sancusSachetPlusOne,
		head = gear.beckonerHeadPlusOne,
		body = gear.bunziBody,
		hands = gear.bunziHands,
		legs = gear.bunziLegs,
		feet = gear.bunziFeet,
		neck = gear.summonerCollarPlusTwo,
		waist = gear.regalBelt,
		left_ear = gear.cathPalugEarring,
		right_ear = gear.beckonerEarringPlusOne,
		left_ring = gear.defending,
		right_ring = gear.cathPalugRing,
		back = gear.smnPetRegen,
	}

	-- Idle sets per offense mode, merged over sets.Idle in the matching mode. sets.Idle.Resting is
	-- merged while you rest.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.Resting = {}

	-- SB and PDT are not offered in this file, so their idle sets are read only once you offer
	-- them: list them in a state.OffenseMode:options(...) line at the top of this file, then
	-- uncomment these lines and give each mode a sets.OffenseMode set as well.
	-- sets.Idle.SB = set_combine(sets.Idle, {})
	-- sets.Idle.PDT = set_combine(sets.Idle, {})

	-- Merged over the idle set while Sublimation is charging.
	sets.Idle.Sublimation = {}

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

	-- Worn over the idle set while Avatar's Favor is up, merged after sets.Idle.Pet so its slots
	-- win. Uncomment it to use it.
	-- Favor's potency depends on your summoning magic skill and the Avatar's Favor gear in your
	-- idle set, such as Beckoner's Horn.
	-- sets.Idle["Avatar's Favor"] = {}

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

	-- Engaged sets. sets.OffenseMode is the base, and the set named for the current offense mode is
	-- merged over it.
	sets.OffenseMode = {}
	sets.OffenseMode.TP = {}
	sets.OffenseMode.ACC = {}
	sets.OffenseMode.DT = {}

	-- Merged over your offense mode's set while you are engaged with a pet out: the child named for
	-- your pet mode. Asteria Mitts +1 halve Carbuncle's perpetuation, and Lamassu Mitts +1 raise
	-- Cait Sith's level, as in the children of sets.Idle.Pet.
	sets.OffenseMode.TP.Carbuncle = {
		hands = gear.asteriaMittsPlusOne,
	}
	sets.OffenseMode.TP['Cait Sith'] = {
		hands = gear.lamassuMittsPlusOne,
	}
	sets.OffenseMode.ACC.Carbuncle = {
		hands = gear.asteriaMittsPlusOne,
	}
	sets.OffenseMode.ACC['Cait Sith'] = {
		hands = gear.lamassuMittsPlusOne,
	}
	sets.OffenseMode.DT.Carbuncle = {
		hands = gear.asteriaMittsPlusOne,
	}
	sets.OffenseMode.DT['Cait Sith'] = {
		hands = gear.lamassuMittsPlusOne,
	}

	-- MEVA is not offered in this file either, so this set is read only once you offer it: list it
	-- in a state.OffenseMode:options(...) line at the top of this file, then uncomment it and add a
	-- sets.Idle.MEVA set as well.
	-- sets.OffenseMode.MEVA = {}

	-- Aftermath sets, merged over the engaged set while the matching Aftermath is up. The engine
	-- uses the strongest active tier that has gear for the current weapon. A tier set applies with
	-- any weapon, and a child named for a weapon mode adds gear for that weapon only, such as the
	-- Nirvana one below.
	sets.OffenseMode.AM1 = {}
	sets.OffenseMode.AM2 = {}
	sets.OffenseMode.AM3 = {}
	sets.OffenseMode.AM3['Nirvana'] = {}

	-- Treasure Hunter gear. In every TH mode but None, it is worn on the action that tags a monster
	-- and while engaged on an untagged one. Full Time also wears it whenever you are engaged. Every
	-- job but Thief starts in None.
	sets.TreasureHunter = {
		waist = gear.chaac,
	}

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Every precast starts from sets.Idle, except a pet command's. For a spell, sets.Precast is
	-- merged over it, then the fast cast set. Any slot left empty keeps your idle gear.
	sets.Precast = {}

	-- Worn at the start of every spell. Fast cast gear goes here.
	sets.Precast.FastCast = {
		ammo = gear.sancusSachetPlusOne,
		head = gear.merlinicHoodFC,
		body = gear.inyangaBodyPlusTwo,
		hands = gear.merlinicDastanasFC,
		legs = gear.merlinicShalwarFC,
		feet = gear.merlinicCrackowsFC,
		neck = gear.voltsurge,
		waist = gear.embla,
		left_ear = gear.malignanceEar,
		right_ear = gear.etiolation,
		left_ring = gear.kishar,
		right_ring = gear.gelatinousPlusOne,
		back = gear.smnFCB,
	}

	-- Merged over the fast cast set for cures.
	sets.Precast.Cure = set_combine(sets.Precast.FastCast, {})

	-- Merged over the fast cast set when you cast enhancing magic.
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
	sets.Midcast.SIRD = {

	}

	-- Each casting set below can take a child set named for an offense mode, such as
	-- sets.Midcast.Enfeebling.ACC. It is merged right over its set in that mode, so the sets merged
	-- after it still win any slot both fill. The DT and MEVA children are for damage taken and
	-- magic evasion gear. They ship commented out: uncomment one once you fill it in. This file
	-- offers no MEVA mode, so a MEVA child is read only once you offer one.

	-- Single-target cures, Cure through Cure VI.
	sets.Midcast.Cure = {
		head = gear.vanyaHeadPathB,
		body = gear.bunziBody,
		hands = gear.vanyaHandsPathB,
		legs = gear.vanyaLegsPathB,
		feet = gear.vanyaFeetPathB,
		neck = gear.loricatePlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.roundelEarring,
		right_ear = gear.etiolation,
		left_ring = gear.najiLoop,
		right_ring = gear.lehkoHabhokaRing,
		back = gear.smnFCB,
	}

	-- Merged over the cure set when you cast a cure on yourself.
	sets.Midcast.Cure.Self = {}

	-- Merged over the cure set when you cast a cure on anyone else, or on yourself under Accession.
	sets.Midcast.Cure.Others = {}

	-- Merged over the cure set in DT or MEVA mode.
	-- sets.Midcast.Cure.DT = {}
	-- sets.Midcast.Cure.MEVA = {}

	-- Worn when you cast Curaga from your white mage subjob. It does not use the cure set above.
	sets.Midcast.Curaga = {}

	-- Merged over the Curaga set in DT or MEVA mode.
	-- sets.Midcast.Curaga.DT = {}
	-- sets.Midcast.Curaga.MEVA = {}

	-- Enhancing magic. Healing spells other than cures, such as Raise and the -na spells, use it
	-- too.
	sets.Midcast.Enhancing = {
		ring1 = gear.stikiniRingPlusOne,
		ring2 = gear.stikiniRingPlusOne,
	}

	-- Merged over the enhancing set when you cast an enhancing spell on someone else, or on
	-- yourself under Accession.
	sets.Midcast.Enhancing.Others = {}

	-- Merged over the enhancing set in DT or MEVA mode.
	-- sets.Midcast.Enhancing.DT = {}
	-- sets.Midcast.Enhancing.MEVA = {}

	-- Merged over the enhancing set when you cast Cursna, from your white mage or scholar subjob.
	sets.Midcast.Cursna = {}

	-- Enfeebling magic, where magic accuracy decides whether the spell lands.
	sets.Midcast.Enfeebling = {
		main = gear.grioavolrNukeB,
		ammo = gear.sancusSachetPlusOne,
		head = gear.amalricHeadPlusOnePathA,
		body = gear.inyangaBodyPlusTwo,
		hands = gear.amalricHandsPlusOnePathD,
		legs = gear.inyangaLegsPlusTwo,
		feet = gear.mediumSabotsCureB,
		neck = gear.sanctity,
		waist = gear.luminarySash,
		left_ear = gear.dignitary,
		right_ear = gear.hermetic,
		left_ring = gear.stikiniRingPlusOne2,
		right_ring = gear.stikiniRingPlusOne1,
		back = gear.smnFC,
	}

	-- Merged over the enfeebling set in ACC, DT or MEVA mode, before the MACC, Potency or Duration
	-- set. ACC is for magic accuracy gear.
	sets.Midcast.Enfeebling.ACC = {}
	-- sets.Midcast.Enfeebling.DT = {}
	-- sets.Midcast.Enfeebling.MEVA = {}

	-- Merged over the enfeebling set when you cast a spell on the engine's accuracy list, such as
	-- Dispel.
	sets.Midcast.Enfeebling.MACC = {}

	-- Elemental magic nukes.
	sets.Midcast.Nuke = {
		main = gear.grioavolrNukeB,
		ammo = gear.sancusSachetPlusOne,
		head = gear.amalricHeadPlusOnePathA,
		body = gear.inyangaBodyPlusTwo,
		hands = gear.amalricHandsPlusOnePathD,
		legs = gear.inyangaLegsPlusTwo,
		feet = gear.mediumSabotsCureB,
		neck = gear.sanctity,
		waist = gear.luminarySash,
		left_ear = gear.dignitary,
		right_ear = gear.hermetic,
		left_ring = gear.stikiniRingPlusOne2,
		right_ring = gear.stikiniRingPlusOne1,
		back = gear.smnFC,
	}

	-- Merged over the nuke set in DT or MEVA mode.
	-- sets.Midcast.Nuke.DT = {}
	-- sets.Midcast.Nuke.MEVA = {}

	-- Used instead of the nuke set when you cast Impact, and built from the enfeebling set for its
	-- magic accuracy. The engine puts on the Crepuscular or Twilight Cloak you carry and removes your
	-- head piece. Uncomment the two lines below once you fill them in: once declared, the first
	-- replaces the nuke set for Impact even if it is empty, and its burst child set is merged over it
	-- when you cast Impact into a burst window of its element.
	-- sets.Midcast['Impact'] = set_combine(sets.Midcast.Enfeebling, {})
	-- sets.Midcast['Impact'].Burst = {}

	-- Worn while summoning an avatar or spirit.
	sets.Midcast.Summon = {
		body = gear.baayamiBodyPlusOne
	}

	-- Merged over the summoning set in DT or MEVA mode.
	-- sets.Midcast.Summon.DT = {}
	-- sets.Midcast.Summon.MEVA = {}

	-- A set named for one spell replaces its family set for that spell, so Stoneskin skips the
	-- enhancing set. Cures are the exception and always take the Cure, Curaga or Cura set.
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		waist = gear.siegel,
		neck = gear.nodens,
	})

	-- Merged over the enhancing set for Refresh spells.
	sets.Midcast.Refresh = {
		head = gear.amalricCoifPlusOne,
		waist = gear.gishdubar
	}

	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, {
		head = gear.amalricCoifPlusOne
	})

	-- ===================================================================================================================
	--		Pet gear, by when the game reads it
	-- ===================================================================================================================

	-- Gear read at your command. Worn from your pet command until it completes, merged over your
	-- idle or engaged set. The game checks delay and recast gear at the command, and the rest comes
	-- off before your pet acts, so gear for the move itself goes in the sets worn during your pet's
	-- move. Under Astral Conduit no set is worn at the command, since the pact's recast is already
	-- zero. Every blood pact uses sets.Pet_Command.BloodPact, and a set named for one pact,
	-- sets.Pet_Command['<pact>'], is merged over it.
	sets.Pet_Command.BloodPact = {
		ammo = gear.sancusSachetPlusOne,
		body = gear.convokerBodyPlusThree,
	}

	-- Gear read during your pet's move.
	-- Worn from the moment your avatar readies a move until it finishes, merged over the idle or
	-- engaged set you have on. This is when the game checks the move's damage, accuracy and potency
	-- gear. A spirit's own spells get no gear here: gear put on when the spell starts would stay on
	-- for a cast of up to 13 seconds, so spirit gear goes in the sets worn while your pet fights.
	-- Each set below is merged over the one above it:
	--   sets.Pet_Midcast              every pet move
	--   sets.Pet_Midcast.BloodPact    every blood pact
	--   the pact's category           Physical, Magical, Hybrid, Buff, Debuff or Healing, from the
	--                                 engine's Pet_Moves table
	--   the category's mode set       such as sets.Pet_Midcast.Magical.ACC, in ACC mode
	--   sets.Pet_Midcast.TPBonus      for a pact whose damage depends on your avatar's TP
	--   a set named for the pact      such as sets.Pet_Midcast['Flaming Crush']
	-- Only fill in the slots a set changes. A weapon here goes on when the pact is readied and
	-- stays on until it finishes, unless your weapons are locked.
	sets.Pet_Midcast = {}

	-- Merged over sets.Pet_Midcast when your avatar readies any blood pact. A pact with no
	-- category, such as Raise II, uses this set and then only its own set.
	sets.Pet_Midcast.BloodPact = {}

	-- Physical pacts, such as Volt Strike and Predator Claws: avatar attack and accuracy, and Blood
	-- Pact damage.
	sets.Pet_Midcast.Physical = {
		main = gear.nirvana,
		sub = gear.elanStrapPlusOne,
		ammo = gear.sancusSachetPlusOne,
		head = gear.apogeeHeadPlusOnePathB,
		body = gear.convokerBodyPlusThree,
		hands = gear.merlinicDastanasNukeBloodPact,
		legs = gear.apogeeLegsPlusOnePathD,
		feet = gear.apogeeFeetPlusOnePathC,
		neck = gear.summonerCollarPlusTwo,
		waist = gear.incarnationSash,
		left_ear = gear.lugalbanda,
		right_ear = gear.kyreneEarring,
		left_ring = gear.vararRingPlusOne,
		right_ring = gear.cathPalugRing,
		back = gear.smnPetRegen,
	}
	-- Merged over the physical set when your avatar readies a physical pact in ACC mode.
	sets.Pet_Midcast.Physical.ACC = {}
	-- Magical pacts, such as the tier II and IV nukes and the merit pacts: avatar magic attack
	-- bonus and magic accuracy, and Blood Pact damage.
	sets.Pet_Midcast.Magical = {
		main = gear.grioavolrNukeBloodPact,
		sub = gear.elanStrapPlusOne,
		ammo = gear.sancusSachetPlusOne,
		head = gear.cathPalugCrown,
		body = gear.convokerBodyPlusThree,
		hands = gear.merlinicDastanasNukeBloodPact,
		legs = gear.enticerPantsMaccPetMacc,
		feet = gear.apogeeFeetPlusOnePathB,
		neck = gear.summonerCollarPlusTwo,
		waist = gear.regalBelt,
		left_ear = gear.lugalbanda,
		right_ear = gear.beckonerEarringPlusOne,
		left_ring = gear.vararRingPlusOne2,
		right_ring = gear.vararRingPlusOne1,
		back = gear.smnPetRegenB,
	}
	-- In ACC mode, the staff with more magic accuracy for the avatar.
	sets.Pet_Midcast.Magical.ACC = {
		main = gear.grioavolrMaccBloodPact,
	}
	-- Hybrid pacts, Flaming Crush and Burning Strike: physical hits and a magical one, so both
	-- kinds of gear count.
	sets.Pet_Midcast.Hybrid = {
		main = gear.grioavolrNukeBloodPact,
		sub = gear.elanStrapPlusOne,
		ammo = gear.sancusSachetPlusOne,
		head = gear.apogeeHeadPlusOnePathB,
		body = gear.convokerBodyPlusThree,
		hands = gear.merlinicDastanasNukeBloodPact,
		legs = gear.apogeeLegsPlusOnePathD,
		feet = gear.apogeeFeetPlusOnePathC,
		neck = gear.summonerCollarPlusTwo,
		waist = gear.regalBelt,
		left_ear = gear.lugalbanda,
		right_ear = gear.kyreneEarring,
		left_ring = gear.vararRingPlusOne,
		right_ring = gear.cathPalugRing,
		back = gear.smnFCB,
	}
	sets.Pet_Midcast.Hybrid.ACC = {
		main = gear.grioavolrMaccBloodPact,
	}
	-- Buff wards, such as Hastega II and Perfect Defense: Summoning magic skill lengthens most of
	-- them and strengthens some.
	sets.Pet_Midcast.Buff = {
		main = gear.nirvana,
		sub = gear.elanStrapPlusOne,
		ammo = gear.sancusSachetPlusOne,
		head = gear.baayamiHeadPlusOne,
		body = gear.baayamiBodyPlusOne,
		hands = gear.baayamiHandsPlusOne,
		legs = gear.baayamiLegs,
		feet = gear.baayamiFeetPlusOne,
		neck = gear.summonerCollarPlusTwo,
		waist = gear.luciditySash,
		left_ear = gear.cathPalugEarring,
		right_ear = gear.lugalbanda,
		left_ring = gear.stikiniRingPlusOne,
		right_ring = gear.stikiniRingPlusOne,
		back = gear.smnFC,
	}
	-- Debuff wards, such as Sleepga and Shock Squall: avatar magic accuracy lands them, and
	-- Summoning magic skill adds to it.
	sets.Pet_Midcast.Debuff = set_combine(sets.Pet_Midcast.Buff, {})
	-- Healing wards, such as Healing Ruby II: the avatar's maximum HP sets how much they heal.
	sets.Pet_Midcast.Healing = set_combine(sets.Pet_Midcast.Buff, {})

	-- The avatar TP bonus piece, for pacts whose damage or healing depends on your avatar's TP,
	-- such as the tier II and IV nukes, the merit pacts and Healing Ruby II. It is merged over the
	-- category set.
	sets.Pet_Midcast.TPBonus = {
		legs = gear.enticerPants,
	}

	-- Gear read while your pet is out. While you are idle with a pet out, sets.Idle.Pet is merged
	-- over your idle set and its offense mode set, then its own child set for your offense mode. It
	-- only needs the slots it changes, and the rest of your offense mode's idle gear stays on
	-- underneath. Its child set for your pet mode is merged last. Perpetuation and refresh gear
	-- goes here, since your avatar costs MP for as long as it is out.
	sets.Idle.Pet = {
		waist = gear.luciditySash,
		feet = gear.apogeeFeetPlusOnePathB,
	}

	-- Carbuncle's and Cait Sith's own hands: Asteria Mitts +1 halve Carbuncle's perpetuation and
	-- raise its level, and Lamassu Mitts +1 raise Cait Sith's. Each is worn while the pet fights
	-- too, unless sets.Idle.Pet.Engaged names hands.
	sets.Idle.Pet.Carbuncle = {
		hands = gear.asteriaMittsPlusOne,
	}
	sets.Idle.Pet['Cait Sith'] = {
		hands = gear.lamassuMittsPlusOne,
	}

	-- Gear read while your pet fights. While your pet fights and you are idle,
	-- sets.Idle.Pet.Engaged is merged over sets.Idle.Pet, then its child set for your offense mode.
	-- When you fight too, your offense mode's sets hold the pet gear, so add an offense mode for
	-- fighting alongside your pet. Never name a mode Pet, since sets.Idle.Pet would then be used as
	-- that mode's idle set. Each set's child set for your pet mode is merged last, and while you
	-- fight with a pet out, so is your offense mode's, such as sets.OffenseMode.TP.Spirit. A
	-- spirit's gear goes in sets.Idle.Pet.Engaged.Spirit, worn the whole time, since its own spells
	-- get no gear.
	sets.Idle.Pet.Engaged = {}
	sets.Idle.Pet.Engaged.Spirit = {}

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is merged over sets.Idle for every job ability, then the set named for
	-- the ability is merged over it. Any slot left empty keeps your idle gear.
	sets.JA = {}
	sets.JA["Astral Flow"] = {}
	sets.JA["Elemental Siphon"] = {}
	sets.JA["Mana Cede"] = {}
	sets.JA["Astral Conduit"] = {}
	sets.JA["Apogee"] = {}

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- The base for every weaponskill, merged over sets.Idle. A set named for the weaponskill is
	-- merged over it. Any slot left empty keeps your idle gear.
	sets.WS = {}
	-- Worn on weaponskills in ACC mode, merged after the set named for the weaponskill so its slots
	-- win. It is skipped where sets.WS['<name>'].ACC exists.
	sets.WS.ACC = {}

	-- Merged in DT mode after the set named for the weaponskill, so its gear wins, for damage taken
	-- gear. A weaponskill with its own DT set uses that instead. Every slot here costs some of the
	-- weaponskill's damage, so uncomment it only once you fill it in.
	-- sets.WS.DT = {}

	-- Merged over every weaponskill while Buff Level (Alt+F12) is set to HighBuff, for physical
	-- damage limit gear. At MidBuff, the default, no set is used here. In any offense mode except
	-- TP, the set for that mode and level is merged after it, such as sets.WS.ACC.HighBuff in ACC
	-- mode. A weaponskill's own HighBuff set replaces this one for that weaponskill, even if it is
	-- empty. The three weaponskill sets further below are one table, sets.WS.MAB, so give one its
	-- own copy before adding a child set to it.
	sets.WS.HighBuff = {}
	sets.WS.ACC.HighBuff = {}

	-- Aftermath sets for weaponskills, merged after the weaponskill's own sets while the matching
	-- Aftermath is up. They work as the engaged Aftermath sets do.
	sets.WS.AM1 = {}
	sets.WS.AM2 = {}
	sets.WS.AM3 = {}
	sets.WS.AM3['Nirvana'] = {}

	-- A building block for magical weaponskills, used as the three weaponskill sets below. It has
	-- no weapon, since the engine keeps your weapons on through a weaponskill.
	sets.WS.MAB = {
		ammo = gear.sancusSachetPlusOne,
		head = gear.amalricHeadPlusOnePathA,
		body = gear.inyangaBodyPlusTwo,
		hands = gear.amalricHandsPlusOnePathD,
		legs = gear.amalricLegsPlusOnePathA,
		feet = gear.amalricFeetPlusOnePathA,
		neck = gear.sanctity,
		waist = gear.eschan,
		left_ear = gear.moonshadeEarringAcc,
		right_ear = gear.friomisi,
		left_ring = gear.stikiniRingPlusOne2,
		right_ring = gear.stikiniRingPlusOne1,
		back = gear.smnFC,
	}
	sets.WS["Garland of Bliss"] = sets.WS.MAB
	sets.WS["Shattersoul"] = sets.WS.MAB
	sets.WS["Cataclysm"] = sets.WS.MAB

	-- Sets for your own hooks. The engine never uses sets.Custom on its own, so use it from the
	-- hooks below.
	sets.Custom = {}
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
	-- A chat reminder after every action while an avatar is out and Avatar's Favor is down.
	if pet.isvalid and not buffactive["Avatar\'s Favor"] and spell.name ~= "Avatar\'s Favor" then
		add_to_chat(8,'Avatar\'s Favor is Down')
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
	-- Switches to the macro set for the avatar summoned, and back to set 1 when the avatar leaves.
	-- Change or delete this block if your macro books are laid out differently.
	if pet and gain then
		log('Macro Change ['..pet.name..']')
		if pet.name=='Fenrir' then
			send_command('input /macro book '..MacroBook..';wait .1;input /macro set 2')
		elseif pet.name=='Ifrit' then
			send_command('input /macro book '..MacroBook..';wait .1;input /macro set 3')
		elseif pet.name=='Titan' then
			send_command('input /macro book '..MacroBook..';wait .1;input /macro set 4')
		elseif pet.name=='Leviathan' then
			send_command('input /macro book '..MacroBook..';wait .1;input /macro set 5')
		elseif pet.name=='Garuda' then
			send_command('input /macro book '..MacroBook..';wait .1;input /macro set 6')
		elseif pet.name=='Shiva' then
			send_command('input /macro book '..MacroBook..';wait .1;input /macro set 7')
		elseif pet.name=='Ramuh' then
			send_command('input /macro book '..MacroBook..';wait .1;input /macro set 8')
		elseif pet.name=='Diabolos' then
			send_command('input /macro book '..MacroBook..';wait .1;input /macro set 9')
		elseif pet.name=='Cait Sith' then
			send_command('input /macro book '..MacroBook..';wait .1;input /macro set 10')
		end
	else
		log('Macro Change (No Avatar)')
		send_command('input /macro book '..MacroBook..';wait .1;input /macro set 1')
	end
	return equipSet
end

-- Called when your avatar's pact finishes or is interrupted. The table it returns is merged over
-- the idle or engaged set the engine rebuilds. If one of your own actions is still in progress, it
-- is still called, but the table it returns is not used, and the gear change happens when that
-- action ends.
function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called when your avatar readies a pact. The table it returns is merged over the pet sets, which
-- the engine has already chosen for the pact.
function pet_midcast_custom(spell)
	local equipSet = {}

	return equipSet
end
