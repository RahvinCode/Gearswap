--------------------------------------------------------------------------
--===              RahvinGS -- GearSwap Engine for FFXI              ===--
--===       DO NOT MODIFY THIS FILE - ONLY MODIFY JOB FILES          ===--
--------------------------------------------------------------------------
-- Copyright (c) 2026 Rahvin
-- Released under the MIT License. See LICENSE.md.
--
-- Derived from Mirdain-Include (github.com/Mirdain/Gearswap) Copyright (c)
-- 2020 Mirdain, used with the author's permission. The monolithic include
-- has been decomposed into components and substantially rewritten; portions
-- of the original remain, and the job-file API is preserved for compatibility.
--
-- See https://github.com/rahvincode for the latest version.
-- README.md covers installation, features, commands and troubleshooting.
--------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- SECTIONS 1-6 - THE JOB FILE INTERFACE
----------------------------------------------------------------------------------------------------
-- CONTENTS
--   Section 1 - Version and shared globals
--   Section 2 - Gear set placeholders: the set paths the engine reads, created empty
--   Section 3 - Mode definitions: the M{} state variables and the ammunition tables
--   Section 4 - The busy flag, job file options, and the Job_Mode_Check helper
--   Section 5 - Action classification lists: which bucket each spell or move falls into
--   Section 6 - Display labels for the two job-defined modes
--
-- Everything here is global. A job file reads these names, writes them and overrides what
-- it needs, so these comments speak to players who edit job files as well as to maintainers.
--
-- This is the one component with no constructor. Every other component returns a
-- function(E) that the root builds. This file runs at the top level, exports nothing onto E,
-- and loads before any other engine file. The rest of the engine can therefore count on
-- these globals, and nothing here may read an engine internal, because none exists yet.
--
-- Job_Mode_Check, in section 4, is the only function here. Nothing in the engine calls it.
-- It is a helper for job files.

----------------------------------------------------------------------------------------------------
-- SECTION 1 - VERSION AND SHARED GLOBALS
----------------------------------------------------------------------------------------------------
-- The version, the Modes library and the received-gear registry, which the rest of the
-- engine expects to exist before it loads.

-- The version every component stamps itself against. The root compares each component's
-- returned stamp with this one, so a file left over from another version stops the load with
-- an error that names it, rather than running mismatched.
Rahvin_GS = '2.2'

-- GearSwap's Modes library, which supplies the M{} class every state variable in section 3
-- is built from. It is included here because those declarations run in this file, before
-- any component exists.
include('Modes')

-- The slots received gear is holding, Doom's Cursna set included, keyed by the slot name the
-- set uses. It is a global so the lifecycle teardown can empty it without reaching into the
-- spell-received component. That component replaces the table whole on every release, so
-- every reader looks the global up at each use rather than keeping a reference.
active_external_locks = {}

----------------------------------------------------------------------------------------------------
-- SECTION 2 - GEAR SET PLACEHOLDERS
----------------------------------------------------------------------------------------------------
-- The set paths the engine reads, created empty. A job file declares only the sets it uses,
-- and a set it leaves out merges as nothing rather than failing to exist. A few building
-- blocks the engine never reads are declared here too, and each one's comment says so.
--
-- A job file replaces these tables inside get_sets(), which drops the placeholders under any
-- table it replaces. The engine puts the dropped ones back once the job file has loaded, and
-- again at the next build after the job file replaces a table the engine had to fill, as a
-- file that re-runs get_sets() does. The engine records each placeholder before the job file
-- declares its sets, so its warnings can tell a set the job file never declared from one it
-- declared and left empty.

-- Weapons. The job file adds one child per WeaponMode option. Sleep is worn and held while
-- you are asleep. Shield is the offhand worn with a one-handed main, not a hand-to-hand
-- weapon, when you lack the Dual Wield trait. Songs holds the bard's song weapons.
sets.Weapons = {}
sets.Weapons.Sleep = {}
sets.Weapons.Shield = {}
sets.Weapons.Songs = {}
sets.Weapons.Songs.Precast = {}
sets.Weapons.Songs.Midcast = {}

-- Idle. The base of the idle build, and the floor under every precast and midcast but a pet
-- command's. A pet command stands on the idle or engaged build instead, and the engine
-- dresses nothing at the command of a blood pact under Astral Conduit. In the idle build a
-- child named for the current OffenseMode goes over the base, and Resting, Pet and
-- Sublimation go on in those states. Pet goes on while a pet is out, then Pet.Engaged while
-- it fights, each followed by its own child named for the current OffenseMode, then, on a
-- pet job, its child named for the pet mode.
sets.Idle = {}
sets.Idle.Pet = {}
sets.Idle.Pet.Engaged = {}
sets.Idle.Sublimation = {}
sets.Idle.Resting = {}
sets.Idle.TP = {}
sets.Idle.ACC = {}
sets.Idle.DT = {}

-- Worn over the idle build, its pet and Sublimation sets included, while you move and are
-- not engaged.
sets.Movement = {}

-- The received sets, worn while another character on this machine casts on this one with
-- SpellReceived ON. Each serves one family of incoming spell or ability. The Cursna set is
-- also dressed and held on Doom while SpellReceived is OFF.
sets.Cure_Received = {}
sets.Cursna_Received = {}
sets.Phalanx_Received = {}
sets.Protect_Shell_Received = {}
sets.Regen_Received = {}
sets.Refresh_Received = {}
sets.Waltz_Received = {}

-- Worn when a Holy Water or Hallowed Water is used, where gear that raises their potency
-- changes whether the cure for Doom lands.
sets.Holy_Water = {}

-- The engaged build. sets.OffenseMode is the base and always applies, and the child named for
-- the current OffenseMode goes over it. A mode with no child warns, and the build then adds
-- nothing past the base but the mode's round from Ammo and, under the weapon lock, the
-- locked weapons, so every mode a job file offers needs one. The AM tiers go on while the
-- matching Aftermath is up, and each can take a child named for the weapon mode.
sets.OffenseMode = {}
sets.OffenseMode.AM = {}
sets.OffenseMode.AM1 = {}
sets.OffenseMode.AM2 = {}
sets.OffenseMode.AM3 = {}

-- Worn with the weapon set in the engaged build, in the shield's place, while you have the
-- Dual Wield trait and a one-handed main that is not a hand-to-hand weapon.
sets.DualWield = {}

-- Precast for spells and ranged attacks. Every spell takes sets.Precast and its FastCast
-- child, then the first of these that applies: a set named for the spell, the cure set, the
-- healing set, Utsusemi's, blue magic's or the song set. Every enhancing spell also takes
-- sets.Precast.Enhancing. Under Nightingale a song wears its whole midcast build here in the
-- song set's place, since its cast leaves no time for a midcast swap. A shot takes
-- sets.Precast, then sets.Precast.RA for its snapshot gear, with Flurry over that under
-- Flurry, and Flurry_II under Flurry II or Embrava. The midcast build replaces this gear
-- once the cast starts.
sets.Precast = {}
sets.Precast.FastCast = {}
sets.Precast.BlueMagic = {}
sets.Precast.Enhancing = {}
sets.Precast.Cure = {}
sets.Precast.Healing = {}
sets.Precast.Utsusemi = {}
sets.Precast.Songs = {}

sets.Precast.RA = {}
sets.Precast.RA.Flurry = {}
sets.Precast.RA.Flurry_II = {}

-- Midcast children. Under sets.Midcast, under the set a spell's family takes, such as
-- sets.Midcast.Nuke, and under a spell's own set, a job file may declare children keyed by
-- the cast. Each merges right after its parent while its key matches, so every set merged
-- after it, and the day, weather and distance pieces, still win over it:
--   the offense mode   sets.Midcast.Nuke.Occult, in Occult mode
--   Self or Others     sets.Midcast.Cure.Others, for a cure on anyone else, or on yourself
--                      under Accession
--   the spell's name   sets.Midcast.Nuke['Fire IV']
--   Burst              sets.Midcast.Nuke.Burst, for a cast predicted to magic burst, or put
--                      in its burst gear when a skillchain carrying its element lands on its
--                      target mid-cast
-- A cast in its burst gear is taken back out of it when a move that makes no chain ends its
-- target's window, or a chain without its element lands there, while enough of the cast is
-- left for the change to count.
--
-- A child may carry children of its own, up to three keys in any order, as in
-- sets.Midcast.Nuke.Occult['Fire IV']. sets.Midcast itself reads only its mode and Self or
-- Others children, merged before every family set, and sets.Midcast.ACC is its child in ACC
-- mode. No midcast children are read under sets.Idle, sets.Midcast.SIRD or the
-- sets.Midcast.BlueMagic container, whose subcategories do read them, nor for a ranged
-- attack, nor under the weapon, song weapon, instrument and Treasure Hunter sets that go on
-- after the family set.
-- The pet sets read only each category's offense-mode child, and the pet command sets none.
-- Every set declared below keeps its own role in an offense mode of the same name, and so
-- does sets.Midcast.Nuke.Earth, so a mode named MACC does not make
-- sets.Midcast.Enfeebling.MACC a child.
--
-- Midcast for ranged attacks. A child named for the current OffenseMode goes over
-- sets.Midcast.RA, such as sets.Midcast.RA['True Shot'] in a True Shot mode, and TP, the
-- default, reads none. TripleShot, DoubleShot or Barrage goes over that while the matching
-- buff is up.
sets.Midcast = {}
sets.Midcast.RA = {}
sets.Midcast.RA['True Shot'] = {}
sets.Midcast.RA.TripleShot = {}
sets.Midcast.RA.DoubleShot = {}
sets.Midcast.RA.Barrage = {}

-- Every enfeebling spell takes sets.Midcast.Enfeebling, then the first of its three tiers
-- whose list in section 5 names the spell. An enfeeble is routed by what improves it,
-- accuracy, potency or duration, rather than by its school.
sets.Midcast.Enfeebling = {}
sets.Midcast.Enfeebling.MACC = {}
sets.Midcast.Enfeebling.Potency = {}
sets.Midcast.Enfeebling.Duration = {}

-- Midcast for the magic schools: the nuke and burst sets, the cure family and enhancing
-- magic. SIRD goes on over sets.Midcast under every midcast but a ranged attack's, so every
-- set after it, the family set included, wins over it. A black magic nuke with no set of its
-- own wears sets.Midcast.Burst in the nuke set's place while it is dressed for a burst, as
-- the Burst child above describes. A file that leaves the burst set undeclared bursts in
-- sets.Midcast.Nuke and its Burst child. An enhancing spell takes sets.Midcast.Enhancing,
-- with Enhancing.Others over it for a cast on anyone else or on yourself under Accession,
-- then the first family set that matches it, such as Refresh, Regen or a bar spell's.
sets.Midcast.SIRD = {}
sets.Midcast.Nuke = {}
sets.Midcast.Burst = {}
sets.Midcast.Cure = {}
sets.Midcast.Curaga = {}
sets.Midcast.Cura = {}
sets.Midcast.Cursna = {}
sets.Midcast.Regen = {}
sets.Midcast.Refresh = {}
sets.Midcast.Enhancing = {}
sets.Midcast.Enhancing.Others = {}
sets.Midcast.Enhancing.Gain = {}
sets.Midcast.Enhancing.Elemental = {}
sets.Midcast.Enhancing.Status = {}
sets.Midcast.Enhancing.Skill = {}

-- Aspir and Drain take sets.Midcast.Aspir and sets.Midcast.Drain, and no dark magic list.
-- Every other dark spell takes sets.Midcast.Dark, then the child its list in section 5
-- names. Summoning an avatar or a spirit takes sets.Midcast.Summon when no set is named for
-- it.
sets.Midcast.Aspir = {}
sets.Midcast.Drain = {}
sets.Midcast.Dark = {}
sets.Midcast.Dark.MACC = {}
sets.Midcast.Dark.Absorb = {}
sets.Midcast.Dark.Enhancing = {}
sets.Midcast.Summon = {}

-- Utsusemi, Phalanx and the divine spells each take their own set. A helix takes sets.Helix,
-- then its Dark or Light child, over the nuke or burst set.
sets.Midcast.Utsusemi = {}
sets.Midcast.Phalanx = {}
sets.Midcast.Divine = {}
sets.Helix = {}
sets.Helix.Dark = {}
sets.Helix.Light = {}

-- Midcast for blue magic, split by mechanic rather than by element or school. The blue magic
-- lists in section 5 decide which of these a spell reaches, and say what improves each one.
-- sets.Midcast.BlueMagic itself is never worn, so its gear goes in the sets below it.
sets.Midcast.BlueMagic = {}
sets.Midcast.BlueMagic.Physical = {}
sets.Midcast.BlueMagic.Breath = {}
sets.Midcast.BlueMagic.Nuke = {}
sets.Midcast.BlueMagic.Skill = {}
sets.Midcast.BlueMagic.Buff = {}
sets.Midcast.BlueMagic.Enmity = {}
sets.Midcast.BlueMagic.Healing = {}
sets.Midcast.BlueMagic.ACC = {}

-- Midcast for bard songs. Songs is the gear for every song but a dummy song, worn under the
-- song's own set or the enfeebling set and under its family set, so each of those wins over
-- it. Then one set per song family. Every castable song but a dummy song belongs to exactly
-- one family, so it always has a set to reach for. DummySongs serves the dummy songs listed
-- in section 5, in place of Songs.
sets.Midcast.Songs = {}
sets.Midcast.DummySongs = {}
sets.Midcast.Finale = {}
sets.Midcast.Lullaby = {}
sets.Midcast.Threnody = {}
sets.Midcast.Elegy = {}
sets.Midcast.Requiem = {}
sets.Midcast.March = {}
sets.Midcast.Minuet = {}
sets.Midcast.Madrigal = {}
sets.Midcast.Ballad = {}
sets.Midcast.Scherzo = {}
sets.Midcast.Mazurka = {}
sets.Midcast.Paeon = {}
sets.Midcast.Carol = {}
sets.Midcast.Minne = {}
sets.Midcast.Mambo = {}
sets.Midcast.Etude = {}
sets.Midcast.Prelude = {}
sets.Midcast.Dirge = {}
sets.Midcast.Sirvente = {}
sets.Midcast.Aria = {}
sets.Midcast.Fugue = {}
sets.Midcast.Hum = {}
sets.Midcast.Hymnus = {}
sets.Midcast.Virelai = {}
sets.Midcast.Nocturne = {}

-- Midcast Aftermath tiers, for ranged attacks only. No builder merges an Aftermath tier into
-- a spell's midcast, so a spell tier a job file declared would do nothing.
sets.Midcast.RA.AM = {}
sets.Midcast.RA.AM1 = {}
sets.Midcast.RA.AM2 = {}
sets.Midcast.RA.AM3 = {}

-- Weaponskills. sets.WS is the base, and a set named for the weaponskill goes over it.
-- Three children follow, each the named set's own where it declares one, otherwise
-- sets.WS's child of the same key over the named set. First the child for the current
-- OffenseMode, then the child for the current BuffLevel, then the two together, nested
-- stance first, as sets.WS['Savage Blade'].ACC.HighBuff. Nested the other way, level first,
-- they are never read. An own child declared empty still skips sets.WS's. TP, the default
-- stance, reads no stance child of sets.WS's, and MidBuff, the default level, no level child
-- of sets.WS's, so a pair holding either reads only the named set's own. The AM tiers go on
-- over those while the matching Aftermath is up, and read no BuffLevel child. A ranged
-- weaponskill merges sets.WS.RA over sets.WS and reads the children of sets.WS.RA in place of
-- sets.WS's, so those keys read RA first: sets.WS.RA.ACC, never sets.WS.ACC.RA, which the
-- engine does not read.
sets.WS = {}
sets.WS.RA = {}
sets.WS.ACC = {}
sets.WS.RA.ACC = {}
sets.WS.PDL = {}
sets.WS.RA.PDL = {}
sets.WS.SB = {}
sets.WS.RA.SB = {}
sets.WS.CRIT = {}
sets.WS.RA.CRIT = {}
sets.WS.MEVA = {}
sets.WS.RA.MEVA = {}
sets.WS.HighBuff = {}
sets.WS.RA.HighBuff = {}
sets.WS.AM = {}
sets.WS.RA.AM = {}
sets.WS.AM1 = {}
sets.WS.RA.AM1 = {}
sets.WS.AM2 = {}
sets.WS.RA.AM2 = {}
sets.WS.AM3 = {}
sets.WS.RA.AM3 = {}

-- Job abilities and their families. sets.JA is the base of a job ability's precast, and a
-- child named for the ability goes over it. Stratagems, wards, runes and effusions read
-- sets.JA the same way. Phantom Roll, Quick Draw and the Dancer's abilities read their own
-- family set below instead, with a child named for the ability, and a pet command reads
-- sets.Pet_Command. Double-Up takes its child of sets.JA where the job file declares one,
-- even empty, and sets.PhantomRoll where it declares none. Call Beast and Bestial Loyalty
-- add the child of sets.Jugs named for the job mode, so the jug the game needs goes in the
-- ammo slot, whether or not the call has a set of its own under sets.JA.
-- sets.TreasureHunter goes on as its mode in section 3 says.
sets.JA = {}
sets.Waltz = {}
sets.Jig = {}
sets.Samba = {}
sets.Step = {}
sets.Flourish = {}
sets.Jugs = {}
sets.PhantomRoll = {}
sets.TreasureHunter = {}
sets.QuickDraw = {}

-- The midcast families kept outside sets.Midcast. sets.Storms goes over the enhancing set
-- for a Scholar's storm. sets.Diffusion goes over a blue spell's set while Diffusion is up,
-- but a blue spell with a set of its own does not take it. A Geomancy spell takes a set
-- named for it under sets.Geomancy, else Geo for a bubble or Indi for an Indicolure, with
-- Indi.Entrust over Indi for one cast on another player.
-- sets.Enmity is not read by the engine. It is a building block job files combine into
-- their enmity abilities' sets.
sets.Storms = {}
sets.Enmity = {}
sets.Diffusion = {}
sets.Geomancy = {}
sets.Geomancy.Geo = {}
sets.Geomancy.Indi = {}
sets.Geomancy.Indi.Entrust = {}

-- A pet's own moves. The game reads a move's potency gear while the pet readies it, and
-- pet_midcast wears these sets from the readying to the move's finish. Each merges over the
-- last. First sets.Pet_Midcast, for every move. Then the move's family: BloodPact for every
-- blood pact, Ready for every Ready move, Wyvern for every move of the wyvern. Then its
-- category, by what drives the move: Physical, Magical, Hybrid, Multi (a multi-hit Ready
-- move), Debuff, Buff, Healing, or Breath (a breath whose damage follows its user's HP). Then
-- the category's child for the current offense mode, such as sets.Pet_Midcast.Physical.ACC.
-- Then TPBonus, for a move whose damage or potency follows the pet's TP. Then a set named for
-- the move, then the job file's pet_midcast_custom layer, and under the weapon lock your
-- weapon set and the locked weapons last. Pet_Moves in section 5 gives each move's family,
-- category and TP mark. A family, category or TP bonus set a job file leaves undeclared is
-- skipped. On a Beastmaster every move of the pet takes the Ready family, listed or not, and
-- a category only where the table lists it as a Ready move. Otherwise a move the table does
-- not list, or whose type disagrees with its family, such as an automaton's spell named like
-- a blood pact, takes sets.Pet_Midcast and its own set alone. A spirit's own spell and the
-- automaton's weaponskill dress nothing, and a move readied while your own cast is in flight
-- goes without its set.
sets.Pet_Midcast = {}
sets.Pet_Midcast.BloodPact = {}
sets.Pet_Midcast.Ready = {}
sets.Pet_Midcast.Wyvern = {}
sets.Pet_Midcast.Physical = {}
sets.Pet_Midcast.Magical = {}
sets.Pet_Midcast.Hybrid = {}
sets.Pet_Midcast.Multi = {}
sets.Pet_Midcast.Debuff = {}
sets.Pet_Midcast.Buff = {}
sets.Pet_Midcast.Healing = {}
sets.Pet_Midcast.Breath = {}
sets.Pet_Midcast.TPBonus = {}

-- The master's pet commands, worn from the command to its completion over the idle or engaged
-- set, with none of the spell sets. The game reads delay gear at the command, so it goes here:
-- sets.Pet_Command for every pet command, then the command's family, BloodPact for a blood
-- pact, Ready for a Ready move's command or Sic, Maneuver for a maneuver, then a set named for
-- the command, such as sets.Pet_Command['Spur'] or a pact's own. A family set a job file leaves
-- undeclared is skipped. Gear for the move itself comes off before the pet readies it, so it
-- goes in the pet sets above. A child named for a buff merges while that buff is up, such as
-- sets.Pet_Command.Ready.Unleash. A key that is also a pet command's name is that command's
-- own set instead, so sets.Pet_Command['Fire Maneuver'] is the maneuver's set, never a child
-- for the Fire Maneuver buff. The engine dresses nothing at the command of a blood pact under
-- Astral Conduit.
sets.Pet_Command = {}
sets.Pet_Command.BloodPact = {}
sets.Pet_Command.Ready = {}
sets.Pet_Command.Maneuver = {}

-- The automaton's weaponskill gear. The automaton decides its weaponskill before its readying
-- reaches GearSwap, so this set goes on from its TP instead: over the idle or engaged build
-- while its TP reads PetWSThreshold or more, as the Puppetmaster's Pet WS mode, the first job
-- mode, allows. Idle wears it while you idle, Always idle or engaged, and any other value
-- never. A child named for the frame goes over it, such as sets.Pet_WS['Valoredge Frame'], then
-- the child named for the offense mode.
sets.Pet_WS = {}


-- Bard instruments, chosen by song family ----------------------------------------------------------
-- A bard file names an instrument per purpose here. During a song's midcast, and under
-- Nightingale at its precast too, the engine equips Count for a dummy song, AOE_Sleep for a
-- Horde song, Enfeebling for a song on the Enfeebling_Song list and Potency for any other. A
-- song with a midcast set named for it takes none of these, except a dummy song, which always
-- takes Count. Under Nightingale, one with a precast set named for it takes none at its
-- precast. Pianissimo goes on at midcast for
-- a song aimed at another player or a Trust, a dummy song aside, and takes per-family
-- children, so such a song can carry a different instrument from the party version of the
-- same song. Honor March and Aria of Passion take their required instrument instead. The
-- engine does not read the other keys, which are for the job file's own weapon sets.
Instrument = {}
Instrument.Count = {}
Instrument.Potency = {}
Instrument.Pianissimo = {}
Instrument.Enfeebling = {}
Instrument.AOE_Sleep = {}
Instrument.Idle = {}
Instrument.TP = {}
Instrument.Mordant = {}
Instrument.QuickMagic = {}
Instrument.FastCast = {}
Instrument.MAB = {}

state = state or {}

----------------------------------------------------------------------------------------------------
-- SECTION 3 - MODE DEFINITIONS
----------------------------------------------------------------------------------------------------
-- The named switches the engine reads when choosing gear. Each is an M{} object from
-- GearSwap's Modes library, which gives it an option list to cycle and a current value. The
-- defaults here are what a job file inherits when it declares nothing. A job file's own
-- :options(...) call replaces an option list whole.

-- The stance, shown on the status box as STN. Most set families read a child named for its
-- value, such as sets.Idle.DT or sets.WS.ACC.
state.OffenseMode = M { ['description'] = 'Melee Mode' }
state.OffenseMode:options('TP', 'ACC', 'DT')
state.OffenseMode:set('TP')

-- The buff level, which only the weaponskill build reads, whatever the OffenseMode. Each
-- value names a child of the weaponskill sets, as sets.WS['Savage Blade'].HighBuff, worn
-- while the level stands at that value. MidBuff, the default, reads only a weaponskill's own
-- MidBuff child, never sets.WS.MidBuff, as TP reads no stance child of sets.WS's. A job file
-- may start it high with state.BuffLevel:set('HighBuff'), or add a level with its own
-- :options(...) call.
state.BuffLevel = M { ['description'] = 'Buff Level' }
state.BuffLevel:options('MidBuff', 'HighBuff')
state.BuffLevel:set('MidBuff')

-- Multibox spell-received gear. ON wears the received set as soon as another character on
-- this machine starts casting on this one, before the spell lands, which is what makes it
-- work through Quick Magic. The slots stay held until the spell resolves, or until the
-- failsafe delay releases them when no completion arrives. ON also has this character
-- announce its own tracked spells and Waltzes, so the others can do the same.
state.SpellReceived = M { ['description'] = "Spell-Received" }
state.SpellReceived:options('OFF', 'ON')
state.SpellReceived:set('ON')

-- The Hoxne Ampulla hold. ON-Locked keeps range and ammo outright, so nothing else may enter
-- either. ON-Allow Critical holds them the same way, but stands aside for what needs those
-- slots and takes them back afterward: bard songs, Geomancy, Tomahawk and Angon, and Sleep
-- gear whose set names range or ammo. Bards and Geomancers need ON-Allow Critical, because
-- ON-Locked blocks their instrument and handbell.
state.Hoxne = M { ['description'] = 'Hoxne' }
state.Hoxne:options('OFF', 'ON-Allow Critical', 'ON-Locked')
state.Hoxne:set('OFF')

-- Treasure Hunter handling. Tag wears sets.TreasureHunter against a monster not yet tagged:
-- while you are engaged with it as your target, and for an action aimed at it. Full Time
-- also keeps the set on whenever you are engaged, and SATA while you are engaged with Sneak
-- Attack, Trick Attack or Feint up. Only Thief gets the SATA option, and only Thief defaults
-- to Full Time. Every other job defaults to None.
state.TreasureMode = M { ['description'] = 'Treasure Mode' }
if player.main_job == "THF" then
    state.TreasureMode:options('None', 'Tag', 'Full Time', 'SATA')
    state.TreasureMode:set('Full Time')
else
    state.TreasureMode:options('None', 'Tag', 'Full Time')
    state.TreasureMode:set('None')
end

-- Which weapon set to wear. The option list is the job file's own, and each name needs a
-- matching sets.Weapons entry. Two names are special. 'Locked' and 'Unlocked' name no set of
-- their own and are bridged to the weapon lock below: entering either sets the lock to
-- match, and leaving either returns the lock to Unlocked.
state.WeaponMode = {}
state.WeaponMode = M { ['description'] = 'Weapon Specific Mode' }
state.WeaponMode:options('OFF', 'ON')
state.WeaponMode:set('OFF')

-- The weapon lock, separate from the weapon mode. The mode says what the weapons are, and
-- the lock says whether the other sets may change main and sub.
--   Unlocked   holds nothing.
--   Locked     holds main and sub in every phase, on the weapon mode's weapons, or on what
--              is worn where the mode names none.
--   Songs      (Bard) Locked, except for a song aimed at the bard, another player or a Trust.
--   Locked+R   (Corsair) Locked, and holds range as well unless a Hoxne mode holds it.
--   Geomancy   (Geomancer) Locked, except for a Geomancy spell, whose set may change main
--              and sub.
-- The holds that outrank the lock still win main or sub where they cover them: an item use,
-- the disable and strip holds, Sleep gear, a weapon a spell needs, such as Daybreak for
-- Dispelga, and received gear. The lock shuts main, never sub, and writes sub back at the end
-- of every build, so a job file's hook merged after a build can still move sub for that one
-- action.
--
-- The engine fixes this list per job, and a job file never redeclares it, because its own
-- :options() call would replace the list. A job file that wants to start locked calls
-- state.WeaponLock:set('Locked') and nothing else. A value its job's list does not offer
-- raises at load. The equip component resolves the value into flags at startup and on every
-- change, and every build path reads those flags rather than this mode.
state.WeaponLock = M { ['description'] = 'Weapon Lock' }
if player.main_job == "BRD" then
    state.WeaponLock:options('Unlocked', 'Locked', 'Songs')
elseif player.main_job == "COR" then
    state.WeaponLock:options('Unlocked', 'Locked', 'Locked+R')
elseif player.main_job == "GEO" then
    state.WeaponLock:options('Unlocked', 'Locked', 'Geomancy')
else
    state.WeaponLock:options('Unlocked', 'Locked')
end
state.WeaponLock:set('Unlocked')

-- Two mode slots for the job file. The status box shows each slot the job file names with
-- UI_Name or UI_Name2 in section 6, and an unnamed one stays hidden. The engine reads
-- JobMode where Job_Mode_Check dresses sets.Weapons by it, where a jug-pet call reads
-- sets.Jugs by it, where a value of
-- 'Ranged' merges the idle set's OffenseMode child into the engaged build, and on a
-- Puppetmaster as the Pet WS mode, Idle, Always or Off, which decides when sets.Pet_WS is
-- worn. On a pet job JobMode2 is the pet mode. Its value names a child of sets.Idle.Pet and
-- of sets.Idle.Pet.Engaged, and, while a pet is out, of the offense mode's engaged set. Under
-- Auto the job file's Pet_Modes gives the value. Anything else a value means is up to the job
-- file's own hooks.
state.JobMode = {}
state.JobMode = M { ['description'] = 'Job Specific Mode' }
state.JobMode:options('OFF', 'ON')
state.JobMode:set('OFF')

state.JobMode2 = {}
state.JobMode2 = M { ['description'] = 'Job Specific Mode' }
state.JobMode2:options('OFF', 'ON')
state.JobMode2:set('OFF')

-- The ranged ammunition type. The engine reads it only to find the standard round a
-- weaponskill may finish on once its own has run out. A job file carrying more than one
-- ranged type reads it to fill the offense-mode keys of Ammo below.
state.RAMode = {}
state.RAMode = M { ['description'] = 'Ranged Attack Mode' }
state.RAMode:options('Bullet', 'Arrow', 'Bolt')
state.RAMode:set('Bullet')

-- Raised once the low-ammunition warning has fired, so a dwindling stack is reported once
-- rather than on every shot. Cleared once the count is back above Ammo_Warning_Limit.
state.warned = M(false)


-- Ammunition --------------------------------------------------------------------------------------
-- Ammunition names, read in two shapes, and a job file fills each shape itself. The set
-- builders read Ammo[<the current OffenseMode value>] and put that round in the ammo slot of
-- the idle and engaged build, a ranged weaponskill's precast, and a shot's precast and
-- midcast, so those sets need not name one. The out-of-ammunition fallback reads
-- Ammo[<the current RAMode value>], then .RA or .TP: the standard round a weaponskill may
-- still fire on once its own round has run out. Filling only the per-type tables below
-- leaves the first shape empty, and those sets must then name their own rounds. A job file
-- with more than one ranged type assigns the offense-mode keys from state.RAMode, so the
-- round follows the type.
Ammo = {}
Ammo.Bullet = {}
Ammo.Arrow = {}
Ammo.Bolt = {}

-- At or below this many rounds of the ammunition an action is about to spend, Quick Draw
-- aside, precast prints the low-ammunition warning once and echoes it to the other
-- characters. A job file may set its own.
Ammo_Warning_Limit = 99


----------------------------------------------------------------------------------------------------
-- SECTION 4 - JOB FILE OPTIONS
----------------------------------------------------------------------------------------------------
-- The busy flag, the plain options a job file may set, and the Job_Mode_Check helper.

-- The busy window, not a job-file option. While it stands, precast refuses a new action, and
-- the movement check, the deferred rebuild, the Hoxne tick and the job file's Cycle_Timer
-- wait. Precast raises it for every action but an item used on an NPC, which GearSwap never
-- ends. The action's end leaves a short tail, and the polling engine or the next precast
-- clears it once the window runs out. Precast's cancel path, the buff change hook and the
-- zone handler clear it at once for an action GearSwap ended with no aftercast. It is a bare
-- global rather than a field on E, so a job file can see it and raise it. Moved out of the
-- global scope, it would break a job file that reads it with no error anywhere.
is_Busy = false

-- Plain toggles a job file may set near its top, declared here so the engine reads a
-- default when the job file sets none. AutoItem uses a Remedy or a Holy Water for the
-- status ailments that call for one. Random_Lockstyle picks the lockstyle from
-- Lockstyle_List each time jobsetup runs. PetMoveHold holds the pet's set on while a move you
-- commanded is in flight. The hold starts when your pact, Ready command, Sic or breath
-- command completes, and lasts until the move ends, or two seconds if the pet readies
-- nothing. A move whose end never arrives holds your actions for three seconds at most after
-- its readying. While it holds, your actions are refused with a notice naming the move, and
-- a status change, a buff change, movement or a Treasure Hunter target change re-dresses
-- only when the move ends. A move the pet makes on its own holds nothing. Set false, your
-- actions go through and dress over the pet's set. PetWSThreshold is the automaton's TP from
-- which sets.Pet_WS is worn, until its weaponskill spends the TP.
AutoItem = false
PetMoveHold = true
PetWSThreshold = 600
Random_Lockstyle = false
Lockstyle_List = {}

-- Layer the weapon set named by the current JobMode value onto a set the caller is building,
-- and return the result. A helper for job files: the engine never calls it, and some of the
-- sample job files do.
--
-- It works for any mode name the job file offers, because it is a table lookup rather than a
-- list of known modes. Declaring sets.Weapons.<mode> is all a mode needs to dress weapons,
-- and a mode with no such set dresses nothing. A job file that wants different behavior
-- defines its own Job_Mode_Check after its include line, and that one replaces this.
function Job_Mode_Check(equipSet)
    local weapons = sets.Weapons and sets.Weapons[state.JobMode.value]
    -- set_combine, never an in-place merge. The table belongs to the caller, and merging into
    -- it would write the weapons into whatever set was passed, for good.
    if weapons then equipSet = set_combine(equipSet, weapons) end
    return equipSet
end


----------------------------------------------------------------------------------------------------
-- SECTION 5 - ACTION CLASSIFICATION LISTS
----------------------------------------------------------------------------------------------------
-- The lists that route an action to its set. The builders look an action up in these and
-- merge the set its list names, so adding a name to a list is how a job file re-routes a
-- spell. The lists group spells by what improves them rather than by school or element,
-- because two spells from one school often want different gear. Pet_Moves sorts a pet's
-- moves the same way.

-- Weaponskills that deal magic damage, so they take the day, weather and distance pieces the
-- elemental bonus selection chooses.
Elemental_WS = S {
    'Gust Slash', 'Cyclone', 'Energy Steal', 'Energy Drain', 'Aeolian Edge',
    'Burning Blade', 'Red Lotus Blade', 'Shining Blade', 'Seraph Blade', 'Sanguine Blade', 'Uriel Blade',
    'Frostbite', 'Freezebite', 'Herculean Slash',
    'Gale Axe',
    'Cloudsplitter', 'Primal Rend',
    'Dark Harvest', 'Shadow of Death', 'Infernal Scythe',
    'Thunder Thrust', 'Raiden Thrust',
    'Blade: Teki', 'Blade: To', 'Blade: Chi', 'Blade: Ei', 'Blade: Yu',
    'Tachi: Goten', 'Tachi: Kagero', 'Tachi: Jinpu', 'Tachi: Koki',
    'Shining Strike', 'Seraph Strike', 'Flash Nova',
    'Rock Crusher', 'Earth Crusher', 'Starburst', 'Sunburst', 'Cataclysm', 'Vidohunir', 'Garland of Bliss', 'Omniscience',
    'Flaming Arrow',
    'Hot Shot', 'Wildfire', 'Trueflight', 'Leaden Salute',
}

-- Pieces the elemental bonus selection leaves in place. When the set being built names one of
-- these in its waist, back or elemental ring slot, that slot is not swapped for an obi, sash,
-- cape or ring. Only that slot is kept, and the other two are still chosen. Oneiros Rope is
-- here because specific spells' sets wear it in the waist to gain TP from the cast rather
-- than damage. Add a piece as ['Name'] = true, spelled as the game spells it. The lookup is
-- exact, so a set naming the piece in another case is not kept. This is a plain table, read
-- by name on every elemental cast, and not S{}: an S{} answers a lookup of one of its own
-- method names, such as 'empty', which is the name a bare slot resolves to.
Bonus_Keep = { ['Oneiros Rope'] = true }

-- The ring slot Zodiac Ring is worn in when the spell's element matches the day: 'right_ring'
-- or 'left_ring'. This is the default. A job file declares Elemental_Bonus_Ring_Slot itself
-- to choose per job, and any other value is read as 'right_ring'.
Elemental_Bonus_Ring_Slot = 'right_ring'

-- The Geomancer's bubble and Indicolure spells. A Geomancy spell with no set named for it
-- takes sets.Geomancy.Geo or sets.Geomancy.Indi by these, and an Indicolure cast on another
-- player adds sets.Geomancy.Indi.Entrust.
Geomancy_List = M('Geo-Acumen', 'Geo-Attunement', 'Geo-Barrier', 'Geo-STR', 'Geo-DEX', 'Geo-VIT', 'Geo-AGI', 'Geo-INT',
    'Geo-MND', 'Geo-CHR', 'Geo-Fade',
    'Geo-Fend', 'Geo-Focus', 'Geo-Frailty', 'Geo-Fury', 'Geo-Gravity', 'Geo-Haste', 'Geo-Languor', 'Geo-Malaise',
    'Geo-Paralysis',
    'Geo-Poison', 'Geo-Precision', 'Geo-Refresh', 'Geo-Regen', 'Geo-Slip', 'Geo-Slow', 'Geo-Torpor',
    'Geo-Vex',
    'Geo-Voidance', 'Geo-Wilt')

Indicolure_List = M('Indi-Acumen', 'Indi-Attunement', 'Indi-Barrier', 'Indi-STR', 'Indi-DEX', 'Indi-VIT', 'Indi-AGI',
    'Indi-INT', 'Indi-MND', 'Indi-CHR', 'Indi-Fade',
    'Indi-Fend', 'Indi-Focus', 'Indi-Frailty', 'Indi-Fury', 'Indi-Gravity', 'Indi-Haste', 'Indi-Languor', 'Indi-Malaise',
    'Indi-Paralysis',
    'Indi-Poison', 'Indi-Precision', 'Indi-Refresh', 'Indi-Regen', 'Indi-Slip', 'Indi-Slow', 'Indi-Torpor', 'Indi-Vex',
    'Indi-Voidance', 'Indi-Wilt')

-- Enfeebling songs, which take sets.Midcast.Enfeebling and Instrument.Enfeebling.
Enfeebling_Song = S { 'Foe Requiem', 'Foe Requiem II', 'Foe Requiem III', 'Foe Requiem IV', 'Foe Requiem V', 'Foe Requiem VI', 'Foe Requiem VII', 'Battlefield Elegy', 'Carnage Elegy',
    'Fire Threnody', 'Ice Threnody', 'Wind Threnody', 'Earth Threnody', 'Ltng. Threnody', 'Water Threnody', 'Light Threnody', 'Dark Threnody', 'Fire Threnody II',
    'Ice Threnody II', 'Wind Threnody II', 'Earth Threnody II', 'Ltng. Threnody II', 'Water Threnody II', 'Light Threnody II', 'Dark Threnody II', 'Magic Finale', 'Pining Nocturne' }

-- The enfeebling tiers, first match winning: sets.Midcast.Enfeebling.MACC, .Potency and
-- .Duration. Aspir, Drain and Stun are dark magic, which never reads the accuracy list, and
-- Aspir and Drain take their own sets first, so their entries here change nothing.
Enfeeble_Acc = S { 'Dispel', 'Aspir', 'Aspir II', 'Aspir III', 'Drain', 'Drain II', 'Drain III', 'Frazzle', 'Frazzle II', 'Stun', 'Poison', 'Poison II', 'Poisonga' }
Enfeeble_Potency = S { 'Paralyze', 'Paralyze II', 'Slow', 'Slow II', 'Addle', 'Addle II', 'Distract', 'Distract II', 'Distract III', 'Frazzle III', 'Blind', 'Blind II', 'Gravity', 'Gravity II' }
Enfeeble_Duration = S { 'Sleep', 'Sleep II', 'Sleepga', 'Sleepga II', 'Diaga', 'Dia', 'Dia II', 'Dia III', 'Bio', 'Bio II', 'Bio III', 'Silence', 'Inundation', 'Break', 'Breakga', 'Bind', 'Bindga' }

-- Dark magic: sets.Midcast.Dark.MACC, .Absorb and .Enhancing. A dark spell in none of these
-- takes the potency or duration tier above. Aspir and Drain take sets.Midcast.Aspir and
-- sets.Midcast.Drain before these lists are read, so their entries in Dark_Absorb change
-- nothing.
Dark_Acc = S { 'Death', 'Kaustra', 'Stun' }
Dark_Absorb = S { 'Absorb-ACC', 'Absorb-AGI', 'Absorb-Attri', 'Absorb-CHR', 'Absorb-DEX', 'Absorb-INT', 'Absorb-MND', 'Absorb-STR', 'Absorb-TP', 'Absorb-VIT', 'Aspir', 'Aspir II', 'Aspir III', 'Drain', 'Drain II', 'Drain III' }
Dark_Enhancing = S { 'Dread Spikes', 'Endark', 'Endark II', 'Klimaform', 'Tractor' }

-- Enhancing spells that scale with skill take sets.Midcast.Enhancing.Skill, and the divine
-- spells take sets.Midcast.Divine.
Enhancing_Skill = S { 'Temper', 'Temper II', 'Enaero', 'Enstone', 'Enthunder', 'Enwater', 'Enfire', 'Enblizzard', 'Boost-STR', 'Boost-DEX', 'Boost-VIT', 'Boost-AGI', 'Boost-INT', 'Boost-MND', 'Boost-CHR' }
Divine_Skill = S { 'Enlight', 'Enlight II', 'Flash', 'Repose', 'Holy', 'Holy II', 'Banish', 'Banish II', 'Banish III', 'Banishga', 'Banishga II', }

-- The blue magic buckets. Each takes the sets.Midcast.BlueMagic child of the same name, and
-- Tank takes .Enmity. Two blue spells that look alike can scale from different stats, so
-- each bucket below states what improves it. A spell with a set named for it under
-- sets.Midcast skips the buckets.
--
-- Physical: weapon accuracy, the spell's stat modifier, and attack. Magic attack does
-- nothing for these.
BluePhysical = S { 'Amorphic Spikes', 'Asuran Claws', 'Barbed Crescent', 'Battle Dance',
    'Benthic Typhoon', 'Bilgestorm', 'Bloodrake', 'Bludgeon', 'Body Slam', 'Cannonball',
    'Claw Cyclone', 'Death Scissors', 'Delta Thrust', 'Dimensional Death', 'Disseverment',
    'Empty Thrash', 'Feather Storm', 'Final Sting', 'Foot Kick', 'Frenetic Rip', 'Frypan',
    'Glutinous Dart', 'Goblin Rush', 'Grand Slam', 'Head Butt', 'Heavy Strike', 'Helldive',
    'Hydro Shot', 'Hysteric Barrage', 'Jet Stream', 'Mandibular Bite', 'Paralyzing Triad',
    'Pinecone Bomb', 'Power Attack', 'Quad. Continuum', 'Quadrastrike', 'Queasyshroom',
    'Ram Charge', 'Saurian Slide', 'Screwdriver', 'Seedspray', 'Sickle Slash', 'Sinker Drill',
    'Smite of Rage', 'Spinal Cleave', 'Spiral Spin', 'Sprout Smack', 'Sub-zero Smash',
    'Sudden Lunge', 'Sweeping Gouge', 'Tail Slap', 'Terror Touch', 'Thrashing Assault',
    'Tourbillion', 'Uppercut', 'Vanity Dive', 'Vertical Cleave', 'Whirl of Rage', 'Wild Oats' }
-- Breath: max HP and level, and nothing else. INT, magic attack bonus and Blue Magic Skill
-- do nothing here, so these cannot share the nuke set.
BlueBreath = S { 'Bad Breath', 'Flying Hip Press', 'Frost Breath', 'Heat Breath',
    'Hecatomb Wave', 'Magnetite Cloud', 'Poison Breath', 'Radiant Breath', 'Self-Destruct',
    'Thunder Breath', 'Vapor Spray', 'Wind Breath' }
-- Nuke: magic attack bonus and the spell's own stat modifier, the way a black mage's nuke
-- scales. These also take the elemental bonus pieces.
BlueNuke = S { 'Acrid Stream', 'Anvil Lightning', 'Blastbomb', 'Blazing Bound',
    'Blinding Fulgor', 'Blitzstrahl', 'Bomb Toss', 'Cesspool', 'Charged Whisker',
    'Crashing Thunder', 'Cursed Sphere', 'Dark Orb', 'Death Ray', 'Diffusion Ray',
    'Droning Whirlwind', 'Embalming Earth', 'Entomb', 'Evryone. Grudge', 'Eyes On Me',
    'Firespit', 'Foul Waters', 'Gates of Hades', 'Ice Break', 'Leafstorm', 'Maelstrom',
    'Magic Hammer', 'Mind Blast', 'Molting Plumage', 'Mysterious Light', 'Nectarous Deluge',
    'Palling Salvo', 'Polar Roar', 'Rail Cannon', 'Regurgitation', 'Rending Deluge',
    'Retinal Glare', 'Scouring Spate', 'Searing Tempest', 'Silent Storm', 'Spectral Floe',
    'Subduction', 'Tearing Gust', 'Tem. Upheaval', 'Temporal Shift', 'Tenebral Crush',
    'Thermal Pulse', 'Thunderbolt', 'Uproot', 'Water Bomb' }
-- Skill: potency scales with Blue Magic Skill alone, so skill gear is the only thing that
-- moves these.
BlueSkill = S { 'Atra. Libations', 'Barrier Tusk', 'Diamondhide', 'Magic Barrier',
    'Metallic Body', 'Occultation', 'Plasma Charge', 'Pyric Bulwark', 'Reactor Cool' }
-- Buff: fixed potency. No gear changes the effect, so duration is the only thing worth
-- gearing for.
BlueBuff = S { 'Amplification', 'Animating Wail', 'Battery Charge', 'Carcharian Verve',
    'Cocoon', 'Erratic Flutter', 'Exuviation', 'Fantod', 'Feather Barrier', 'Harden Shell',
    'Memento Mori', 'Mighty Guard', 'Nat. Meditation', 'O. Counterstance', 'Refueling',
    'Regeneration', 'Saline Coat', 'Triumphant Roar', 'Warm-Up', 'Winds of Promy.',
    'Zephyr Mantle' }
-- Healing: cure potency, MND and Blue Magic Skill. White Wind is not in this list. It heals
-- from max HP and ignores skill and MND, so it takes a set named for it instead.
BlueHealing = S { 'Healing Breeze', 'Magic Fruit', 'Plenilune Embrace', 'Pollen', 'Restoral',
    'Wild Carrot' }
-- Tank: the enmity-generating enfeebles, geared for enmity rather than for the debuff.
BlueTank = S { 'Actinic Burst', 'Blank Gaze', 'Demoralizing Roar', 'Frightful Roar',
    'Geist Wall', 'Jettatura', 'Sheep Song', 'Soporific', 'Stinking Gas' }
-- Accuracy: the enfeebles and debuffs whose only question is whether they land, so they
-- want magic accuracy.
BlueACC = S { '1000 Needles', 'Absolute Terror', 'Auroral Drape', 'Awful Eye',
    'Blistering Roar', 'Blood Drain', 'Blood Saber', 'Chaotic Eye', 'Cimicine Discharge',
    'Cold Wave', 'Corrosive Ooze', 'Cruel Joke', 'Digest', 'Dream Flower', 'Enervation',
    'Feather Tickle', 'Filamented Hold', 'Infrasonics', 'Light of Penance', 'Lowing',
    'MP Drainkiss', 'Mortal Ray', 'Osmosis', 'Reaving Wind', 'Sandspin', 'Sandspray',
    'Sound Blast', 'Venom Shell', 'Voracious Trunk', 'Yawn' }


-- Elemental and healing magic ---------------------------------------------------------------------
-- The elemental debuffs, which take sets.Midcast.Enfeebling and its accuracy child.
Elemental_Enfeeble = S { 'Burn', 'Frost', 'Choke', 'Rasp', 'Shock', 'Drown' }

-- Healing spells other than the cures, which take sets.Precast.Healing.
Healing_Magic = S { 'Arise', 'Blindna', 'Esuna', 'Paralyna', 'Poisona', 'Raise', 'Raise II', 'Raise III', 'Reraise', 'Reraise II', 'Reraise III', 'Reraise IV', 'Sacrifice', 'Silena', 'Stona', 'Viruna', 'Cursna' }


-- Pet moves ---------------------------------------------------------------------------------------
-- Every pet move pet_midcast sorts, by the name GearSwap hands it: its family and its
-- category, and tp for a move whose damage or potency follows the pet's TP, which takes
-- sets.Pet_Midcast.TPBonus. tp is the percent a +650 TP bonus adds to the move at 0 TP where
-- a table gives it, and true where a source says so without a figure. The gear each category
-- rewards:
--   Physical  the pet's attack and accuracy, and for a pact Blood Pact damage
--   Magical   the pet's magic attack bonus and magic accuracy, and for a pact Blood Pact
--             damage
--   Hybrid    a pact of physical hits and a magical one, so both of the above
--   Multi     a multi-hit Ready move: pet double attack, since only its first hit takes
--             Ready's accuracy bonus
--   Breath    the wyvern's elemental breaths: its current HP, and breath bonus gear
--   Debuff    the pet's magic accuracy, and for a ward Summoning Magic skill as well
--   Buff      for a ward, Summoning Magic skill, which lengthens most and strengthens some
--   Healing   for a ward or a healing breath, the pet's maximum HP
-- A move with no category takes its family's set, TPBonus where it carries a TP mark, and its
-- own set.
Pet_Moves = {
    -- Blood pacts, Physical
    ['Axe Kick']           = { 'BloodPact', 'Physical', tp = true },
    ['Barracuda Dive']     = { 'BloodPact', 'Physical' },
    ['Blindside']          = { 'BloodPact', 'Physical', tp = true },
    ['Camisado']           = { 'BloodPact', 'Physical' },
    ['Chaotic Strike']     = { 'BloodPact', 'Physical' },
    ['Claw']               = { 'BloodPact', 'Physical' },
    ['Crag Throw']         = { 'BloodPact', 'Physical' },
    ['Crescent Fang']      = { 'BloodPact', 'Physical', tp = true },
    ['Double Punch']       = { 'BloodPact', 'Physical', tp = true },
    ['Double Slap']        = { 'BloodPact', 'Physical' },
    ['Eclipse Bite']       = { 'BloodPact', 'Physical', tp = true },
    ['Hysteric Assault']   = { 'BloodPact', 'Physical' },
    ['Megalith Throw']     = { 'BloodPact', 'Physical' },
    ['Moonlit Charge']     = { 'BloodPact', 'Physical' },
    ['Mountain Buster']    = { 'BloodPact', 'Physical', tp = 12 },
    ['Poison Nails']       = { 'BloodPact', 'Physical' },
    ['Predator Claws']     = { 'BloodPact', 'Physical' },
    ['Punch']              = { 'BloodPact', 'Physical' },
    ['Regal Gash']         = { 'BloodPact', 'Physical' },
    ['Regal Scratch']      = { 'BloodPact', 'Physical' },
    ['Rock Buster']        = { 'BloodPact', 'Physical', tp = true },
    ['Rock Throw']         = { 'BloodPact', 'Physical' },
    ['Roundhouse']         = { 'BloodPact', 'Physical' },
    ['Rush']               = { 'BloodPact', 'Physical' },
    ['Shock Strike']       = { 'BloodPact', 'Physical' },
    ['Spinning Dive']      = { 'BloodPact', 'Physical' },
    ['Tail Whip']          = { 'BloodPact', 'Physical', tp = true },
    ['Volt Strike']        = { 'BloodPact', 'Physical' },
    ['Welt']               = { 'BloodPact', 'Physical' },
    -- Blood pacts, Magical
    ['Aerial Blast']       = { 'BloodPact', 'Magical' },
    ['Aero II']            = { 'BloodPact', 'Magical', tp = 36 },
    ['Aero IV']            = { 'BloodPact', 'Magical', tp = 20 },
    ['Blizzard II']        = { 'BloodPact', 'Magical', tp = 36 },
    ['Blizzard IV']        = { 'BloodPact', 'Magical', tp = 20 },
    ['Clarsach Call']      = { 'BloodPact', 'Magical' },
    ['Conflag Strike']     = { 'BloodPact', 'Magical', tp = 17 },
    ['Diamond Dust']       = { 'BloodPact', 'Magical' },
    ['Earthen Fury']       = { 'BloodPact', 'Magical' },
    ['Fire II']            = { 'BloodPact', 'Magical', tp = 36 },
    ['Fire IV']            = { 'BloodPact', 'Magical', tp = 20 },
    ['Geocrush']           = { 'BloodPact', 'Magical', tp = 22 },
    ['Grand Fall']         = { 'BloodPact', 'Magical', tp = 22 },
    ['Heavenly Strike']    = { 'BloodPact', 'Magical', tp = 22 },
    ['Holy Mist']          = { 'BloodPact', 'Magical' },
    ['Howling Moon']       = { 'BloodPact', 'Magical' },
    ['Impact']             = { 'BloodPact', 'Magical', tp = 17 },
    ['Inferno']            = { 'BloodPact', 'Magical' },
    ['Judgment Bolt']      = { 'BloodPact', 'Magical' },
    ['Level ? Holy']       = { 'BloodPact', 'Magical' },
    ['Lunar Bay']          = { 'BloodPact', 'Magical' },
    ['Meteor Strike']      = { 'BloodPact', 'Magical', tp = 22 },
    ['Meteorite']          = { 'BloodPact', 'Magical' },
    ['Nether Blast']       = { 'BloodPact', 'Magical' },
    ['Night Terror']       = { 'BloodPact', 'Magical' },
    ['Ruinous Omen']       = { 'BloodPact', 'Magical' },
    ['Searing Light']      = { 'BloodPact', 'Magical' },
    ['Sonic Buffet']       = { 'BloodPact', 'Magical', tp = 22 },
    ['Stone II']           = { 'BloodPact', 'Magical', tp = 36 },
    ['Stone IV']           = { 'BloodPact', 'Magical', tp = 20 },
    ['Thunder II']         = { 'BloodPact', 'Magical', tp = 36 },
    ['Thunder IV']         = { 'BloodPact', 'Magical', tp = 20 },
    ['Thunderspark']       = { 'BloodPact', 'Magical' },
    ['Thunderstorm']       = { 'BloodPact', 'Magical', tp = 22 },
    ['Tidal Wave']         = { 'BloodPact', 'Magical' },
    ['Tornado II']         = { 'BloodPact', 'Magical', tp = 12 },
    ['Water II']           = { 'BloodPact', 'Magical', tp = 36 },
    ['Water IV']           = { 'BloodPact', 'Magical', tp = 20 },
    ['Wind Blade']         = { 'BloodPact', 'Magical', tp = 22 },
    ['Zantetsuken']        = { 'BloodPact', 'Magical' },
    -- Blood pacts, Hybrid
    ['Burning Strike']     = { 'BloodPact', 'Hybrid' },
    ['Flaming Crush']      = { 'BloodPact', 'Hybrid' },
    -- Blood pacts, Debuff
    ['Bitter Elegy']       = { 'BloodPact', 'Debuff' },
    ['Diamond Storm']      = { 'BloodPact', 'Debuff' },
    ['Eerie Eye']          = { 'BloodPact', 'Debuff' },
    ['Lunar Cry']          = { 'BloodPact', 'Debuff' },
    ['Lunar Roar']         = { 'BloodPact', 'Debuff' },
    ['Lunatic Voice']      = { 'BloodPact', 'Debuff' },
    ['Mewing Lullaby']     = { 'BloodPact', 'Debuff' },
    ['Nightmare']          = { 'BloodPact', 'Debuff' },
    ['Pavor Nocturnus']    = { 'BloodPact', 'Debuff' },
    ['Shock Squall']       = { 'BloodPact', 'Debuff' },
    ['Sleepga']            = { 'BloodPact', 'Debuff' },
    ['Slowga']             = { 'BloodPact', 'Debuff' },
    ['Somnolence']         = { 'BloodPact', 'Debuff' },
    ['Tidal Roar']         = { 'BloodPact', 'Debuff' },
    ['Ultimate Terror']    = { 'BloodPact', 'Debuff' },
    -- Blood pacts, Buff
    ['Aerial Armor']       = { 'BloodPact', 'Buff' },
    ['Chinook']            = { 'BloodPact', 'Buff' },
    ['Crimson Howl']       = { 'BloodPact', 'Buff' },
    ['Crystal Blessing']   = { 'BloodPact', 'Buff' },
    ['Dream Shroud']       = { 'BloodPact', 'Buff' },
    ['Earthen Armor']      = { 'BloodPact', 'Buff' },
    ['Earthen Ward']       = { 'BloodPact', 'Buff' },
    ['Ecliptic Growl']     = { 'BloodPact', 'Buff' },
    ['Ecliptic Howl']      = { 'BloodPact', 'Buff' },
    ['Fleet Wind']         = { 'BloodPact', 'Buff' },
    ['Frost Armor']        = { 'BloodPact', 'Buff' },
    ['Glittering Ruby']    = { 'BloodPact', 'Buff' },
    ['Hastega']            = { 'BloodPact', 'Buff' },
    ['Hastega II']         = { 'BloodPact', 'Buff' },
    ['Heavenward Howl']    = { 'BloodPact', 'Buff' },
    ['Inferno Howl']       = { 'BloodPact', 'Buff' },
    ['Katabatic Blades']   = { 'BloodPact', 'Buff' },
    ['Lightning Armor']    = { 'BloodPact', 'Buff' },
    ['Noctoshield']        = { 'BloodPact', 'Buff' },
    ['Perfect Defense']    = { 'BloodPact', 'Buff' },
    ['Rolling Thunder']    = { 'BloodPact', 'Buff' },
    ['Shining Ruby']       = { 'BloodPact', 'Buff' },
    ['Soothing Current']   = { 'BloodPact', 'Buff' },
    ['Soothing Ruby']      = { 'BloodPact', 'Buff' },
    ['Wind\'s Blessing']   = { 'BloodPact', 'Buff' },
    -- Blood pacts, Healing
    ['Healing Ruby']       = { 'BloodPact', 'Healing' },
    ['Healing Ruby II']    = { 'BloodPact', 'Healing', tp = true },
    ['Spring Water']       = { 'BloodPact', 'Healing' },
    ['Whispering Wind']    = { 'BloodPact', 'Healing' },
    -- Blood pacts, no category
    ['Altana\'s Favor']    = { 'BloodPact' },
    ['Cacodemonia']        = { 'BloodPact' },
    ['Chronoshift']        = { 'BloodPact' },
    ['Deconstruction']     = { 'BloodPact' },
    ['Pacifying Ruby']     = { 'BloodPact' },
    ['Raise II']           = { 'BloodPact' },
    ['Reraise II']         = { 'BloodPact' },
    -- The wyvern's moves, Breath
    ['Flame Breath']       = { 'Wyvern', 'Breath' },
    ['Frost Breath']       = { 'Wyvern', 'Breath' },
    ['Gust Breath']        = { 'Wyvern', 'Breath' },
    ['Hydro Breath']       = { 'Wyvern', 'Breath' },
    ['Lightning Breath']   = { 'Wyvern', 'Breath' },
    ['Sand Breath']        = { 'Wyvern', 'Breath' },
    -- The wyvern's moves, Healing
    ['Healing Breath']     = { 'Wyvern', 'Healing' },
    ['Healing Breath II']  = { 'Wyvern', 'Healing' },
    ['Healing Breath III'] = { 'Wyvern', 'Healing' },
    ['Healing Breath IV']  = { 'Wyvern', 'Healing' },
    -- The wyvern's moves, no category
    ['Remove Blindness']   = { 'Wyvern' },
    ['Remove Curse']       = { 'Wyvern' },
    ['Remove Disease']     = { 'Wyvern' },
    ['Remove Paralysis']   = { 'Wyvern' },
    ['Remove Poison']      = { 'Wyvern' },
    ['Super Climb']        = { 'Wyvern' },
    -- Ready moves, Physical
    ['??? Needles']        = { 'Ready', 'Physical' },
    ['Back Heel']          = { 'Ready', 'Physical', tp = 65 },
    ['Beak Lunge']         = { 'Ready', 'Physical', tp = 65 },
    ['Big Scissors']       = { 'Ready', 'Physical' },
    ['Blockhead']          = { 'Ready', 'Physical', tp = 35 },
    ['Brain Crush']        = { 'Ready', 'Physical', tp = 35 },
    ['Choke Breath']       = { 'Ready', 'Physical' },
    ['Claw Cyclone']       = { 'Ready', 'Physical', tp = 34 },
    ['Crossthrash']        = { 'Ready', 'Physical' },
    ['Cyclotail']          = { 'Ready', 'Physical', tp = 34 },
    ['Disembowel']         = { 'Ready', 'Physical', tp = 62 },
    ['Double Claw']        = { 'Ready', 'Physical', tp = 62 },
    ['Extirpating Salvo']  = { 'Ready', 'Physical', tp = 65 },
    ['Fluid Spread']       = { 'Ready', 'Physical', tp = 22 },
    ['Fluid Toss']         = { 'Ready', 'Physical', tp = 25 },
    ['Foot Kick']          = { 'Ready', 'Physical' },
    ['Frogkick']           = { 'Ready', 'Physical' },
    ['Grapple']            = { 'Ready', 'Physical', tp = 60 },
    ['Head Butt']          = { 'Ready', 'Physical', tp = 65 },
    ['Hoof Volley']        = { 'Ready', 'Physical' },
    ['Lamb Chop']          = { 'Ready', 'Physical', tp = 35 },
    ['Leaf Dagger']        = { 'Ready', 'Physical', tp = 65 },
    ['Mandibular Bite']    = { 'Ready', 'Physical', tp = 35 },
    ['Mega Scissors']      = { 'Ready', 'Physical' },
    ['Needleshot']         = { 'Ready', 'Physical', tp = 35 },
    ['Nimble Snap']        = { 'Ready', 'Physical', tp = 35 },
    ['Numbshroom']         = { 'Ready', 'Physical' },
    ['Power Attack']       = { 'Ready', 'Physical' },
    ['Queasyshroom']       = { 'Ready', 'Physical' },
    ['Razor Fang']         = { 'Ready', 'Physical', tp = 35 },
    ['Recoil Dive']        = { 'Ready', 'Physical', tp = 35 },
    ['Rhino Attack']       = { 'Ready', 'Physical', tp = 35 },
    ['Rhinowrecker']       = { 'Ready', 'Physical', tp = 33 },
    ['Ripper Fang']        = { 'Ready', 'Physical', tp = 35 },
    ['Scythe Tail']        = { 'Ready', 'Physical', tp = 35 },
    ['Sensilla Blades']    = { 'Ready', 'Physical', tp = 35 },
    ['Shakeshroom']        = { 'Ready', 'Physical' },
    ['Sheep Charge']       = { 'Ready', 'Physical', tp = 35 },
    ['Sickle Slash']       = { 'Ready', 'Physical' },
    ['Somersault']         = { 'Ready', 'Physical', tp = 33 },
    ['Spinning Top']       = { 'Ready', 'Physical', tp = 60 },
    ['Spiral Spin']        = { 'Ready', 'Physical' },
    ['Suction']            = { 'Ready', 'Physical', tp = 35 },
    ['Sudden Lunge']       = { 'Ready', 'Physical', tp = 65 },
    ['Swooping Frenzy']    = { 'Ready', 'Physical' },
    ['Tail Blow']          = { 'Ready', 'Physical', tp = 35 },
    ['Tegmina Buffet']     = { 'Ready', 'Physical', tp = 34 },
    ['Tortoise Stomp']     = { 'Ready', 'Physical', tp = 65 },
    ['Whirl Claws']        = { 'Ready', 'Physical' },
    ['Wild Oats']          = { 'Ready', 'Physical', tp = 65 },
    -- Ready moves, Magical
    ['Acid Mist']          = { 'Ready', 'Magical', tp = 31 },
    ['Acid Spray']         = { 'Ready', 'Magical', tp = 25 },
    ['Bubble Shower']      = { 'Ready', 'Magical' },
    ['Charged Whisker']    = { 'Ready', 'Magical', tp = 28 },
    ['Corrosive Ooze']     = { 'Ready', 'Magical', tp = 28 },
    ['Cursed Sphere']      = { 'Ready', 'Magical', tp = 29 },
    ['Dark Spore']         = { 'Ready', 'Magical' },
    ['Drainkiss']          = { 'Ready', 'Magical', tp = 29 },
    ['Dust Cloud']         = { 'Ready', 'Magical', tp = 29 },
    ['Fireball']           = { 'Ready', 'Magical', tp = 29 },
    ['Foul Waters']        = { 'Ready', 'Magical', tp = 44 },
    ['Gloom Spray']        = { 'Ready', 'Magical', tp = 43 },
    ['Infected Leech']     = { 'Ready', 'Magical' },
    ['Molting Plumage']    = { 'Ready', 'Magical' },
    ['Nectarous Deluge']   = { 'Ready', 'Magical' },
    ['Nepenthic Plunge']   = { 'Ready', 'Magical' },
    ['Pestilent Plume']    = { 'Ready', 'Magical', tp = 44 },
    ['Purulent Ooze']      = { 'Ready', 'Magical', tp = 26 },
    ['Silence Gas']        = { 'Ready', 'Magical' },
    ['Snow Cloud']         = { 'Ready', 'Magical', tp = 29 },
    ['Stink Bomb']         = { 'Ready', 'Magical' },
    ['TP Drainkiss']       = { 'Ready', 'Magical', tp = 21 },
    ['Venom']              = { 'Ready', 'Magical' },
    ['Venom Shower']       = { 'Ready', 'Magical' },
    -- Ready moves, Multi
    ['Chomp Rush']         = { 'Ready', 'Multi' },
    ['Pecking Flurry']     = { 'Ready', 'Multi', tp = 52 },
    ['Pentapeck']          = { 'Ready', 'Multi' },
    ['Sweeping Gouge']     = { 'Ready', 'Multi', tp = 60 },
    ['Tickling Tendrils']  = { 'Ready', 'Multi', tp = 28 },
    ['Wing Slap']          = { 'Ready', 'Multi', tp = 49 },
    -- Ready moves, Breath
    ['Aqua Breath']        = { 'Ready', 'Breath' },
    -- Ready moves, Debuff
    ['Blaster']            = { 'Ready', 'Debuff' },
    ['Chaotic Eye']        = { 'Ready', 'Debuff' },
    ['Dream Flower']       = { 'Ready', 'Debuff' },
    ['Filamented Hold']    = { 'Ready', 'Debuff' },
    ['Geist Wall']         = { 'Ready', 'Debuff' },
    ['Gloeosuccus']        = { 'Ready', 'Debuff' },
    ['Hi-Freq Field']      = { 'Ready', 'Debuff' },
    ['Infrasonics']        = { 'Ready', 'Debuff' },
    ['Intimidate']         = { 'Ready', 'Debuff' },
    ['Jettatura']          = { 'Ready', 'Debuff' },
    ['Nihility Song']      = { 'Ready', 'Debuff' },
    ['Noisome Powder']     = { 'Ready', 'Debuff' },
    ['Numbing Noise']      = { 'Ready', 'Debuff' },
    ['Palsy Pollen']       = { 'Ready', 'Debuff' },
    ['Predatory Glare']    = { 'Ready', 'Debuff' },
    ['Roar']               = { 'Ready', 'Debuff' },
    ['Sandblast']          = { 'Ready', 'Debuff' },
    ['Sandpit']            = { 'Ready', 'Debuff' },
    ['Scream']             = { 'Ready', 'Debuff' },
    ['Sheep Song']         = { 'Ready', 'Debuff' },
    ['Soporific']          = { 'Ready', 'Debuff' },
    ['Spider Web']         = { 'Ready', 'Debuff' },
    ['Spoil']              = { 'Ready', 'Debuff' },
    ['Spore']              = { 'Ready', 'Debuff' },
    ['Toxic Spit']         = { 'Ready', 'Debuff' },
    ['Venom Spray']        = { 'Ready', 'Debuff' },
    -- Ready moves, Buff
    ['Bubble Curtain']     = { 'Ready', 'Buff' },
    ['Fantod']             = { 'Ready', 'Buff' },
    ['Frenzied Rage']      = { 'Ready', 'Buff' },
    ['Harden Shell']       = { 'Ready', 'Buff' },
    ['Metallic Body']      = { 'Ready', 'Buff' },
    ['Rage']               = { 'Ready', 'Buff' },
    ['Rhino Guard']        = { 'Ready', 'Buff' },
    ['Scissor Guard']      = { 'Ready', 'Buff' },
    ['Secretion']          = { 'Ready', 'Buff' },
    ['Water Wall']         = { 'Ready', 'Buff' },
    ['Zealous Snort']      = { 'Ready', 'Buff' },
    -- Ready moves, Healing
    ['Wild Carrot']        = { 'Ready', 'Healing', tp = 28 },
    -- Ready moves, no category
    ['Digest']             = { 'Ready', tp = 34 },
}

-- The automaton's weaponskills, by the name GearSwap hands pet_midcast. The automaton decides
-- each one before its readying reaches GearSwap, so gear put on at the readying never counts,
-- and pet_midcast dresses nothing for them. Their gear goes in sets.Pet_WS, and a
-- Puppetmaster file is told at load about a set named for one under sets.Pet_Midcast.
Automaton_Weaponskills = S { 'Slapstick', 'Knockout', 'Magic Mortar', 'Chimera Ripper', 'String Clipper',
    'Cannibal Blade', 'Bone Crusher', 'String Shredder', 'Arcuballista', 'Daze', 'Armor Piercer',
    'Armor Shatterer' }

-- Every avatar and spirit, by the name GearSwap gives the pet, so pet.name can be tested
-- against it. A spirit's name is one word. Not read by the engine.
AvatarList = S { 'Shiva', 'Ramuh', 'Garuda', 'Leviathan', 'Diabolos', 'Titan', 'Fenrir', 'Ifrit', 'Carbuncle',
    'Cait Sith', 'Siren', 'FireSpirit', 'AirSpirit', 'IceSpirit', 'ThunderSpirit', 'LightSpirit', 'DarkSpirit',
    'EarthSpirit', 'WaterSpirit', 'Alexander', 'Odin', 'Atomos' }


-- Bard songs --------------------------------------------------------------------------------------
-- Dummy songs, sung only to be overwritten by the next song. They take
-- sets.Midcast.DummySongs and Instrument.Count, and never the Pianissimo instrument.
SongCount = S { "Knight's Minne", "Knight's Minne II", "Army's Paeon", "Army's Paeon II", "Army's Paeon III", "Army's Paeon IV", "Fowl Aubade", "Herb Pastoral",
    "Shining Fantasia", "Scop's Operetta", "Puppet's Operetta", "Gold Capriccio", "Warding Round", "Goblin Gavotte" }


-- Ninjutsu ----------------------------------------------------------------------------------------
-- Enfeebling ninjutsu, which takes sets.Midcast.Enfeebling.
Enfeebling_Ninjitsu = S { 'Jubaku: Ichi', 'Kurayami: Ni', 'Hojo: Ichi', 'Hojo: Ni', 'Kurayami: Ichi', 'Dokumori: Ichi', 'Aisha: Ichi', 'Yurin: Ichi' }


-- Bar spells --------------------------------------------------------------------------------------
-- The bar spells, by what they resist. The elemental ones take
-- sets.Midcast.Enhancing.Elemental, and the status ones take sets.Midcast.Enhancing.Status.
Elemental_Bar = S { 'Barfire', 'Barblizzard', 'Baraero', 'Barstone', 'Barthunder', 'Barwater', 'Barfira', 'Barblizzara', 'Baraera', 'Barstonra', 'Barthundra', 'Barwatera' }
Status_Bar = S { 'Barsleepra', 'Barpoisonra', 'Barparalyzra', 'Barblindra', 'Barvira', 'Barpetra', 'Baramnesra', 'Barsilencera', 'Barsleep', 'Barpoison', 'Barparalyze', 'Barblind', 'Barvirus', 'Barpetrify', 'Baramnesia', 'Barsilence' }


-- Pet lists kept from 2.1 -------------------------------------------------------------------------
-- The blood pact and Ready move lists that job files written before 2.2 read in their own
-- hooks. The engine sorts pet moves by Pet_Moves above and never reads these. A job file
-- whose functions read one is told at load that it is out of date.
Buff_BPs_Duration = S { 'Shining Ruby', 'Aerial Armor', 'Frost Armor', 'Rolling Thunder', 'Crimson Howl', 'Lightning Armor', 'Ecliptic Growl', 'Glittering Ruby', 'Earthen Ward', 'Hastega',
    'Noctoshield', 'Ecliptic Howl', 'Dream Shroud', 'Earthen Armor', 'Fleet Wind', 'Inferno Howl', 'Heavenward Howl', 'Hastega II', 'Soothing Current', 'Crystal Blessing' }
Buff_BPs_Healing = S { 'Healing Ruby', 'Healing Ruby II', 'Whispering Wind', 'Spring Water' }
Debuff_BPs = S { 'Mewing Lullaby', 'Eerie Eye', 'Lunar Cry', 'Lunar Roar', 'Nightmare', 'Pavor Nocturnus', 'Ultimate Terror', 'Somnolence', 'Slowga', 'Tidal Roar', 'Diamond Storm', 'Sleepga', 'Shock Squall' }
Debuff_Rage_BPs = S { 'Moonlit Charge', 'Tail Whip' }
Magic_BPs_NoTP = S { 'Holy Mist', 'Nether Blast', 'Aerial Blast', 'Searing Light', 'Diamond Dust', 'Earthen Fury', 'Zantetsuken', 'Tidal Wave', 'Judgment Bolt', 'Inferno', 'Howling Moon', 'Ruinous Omen', 'Night Terror', 'Thunderspark' }
Magic_BPs_TP = S { 'Impact', 'Conflag Strike', 'Level ? Holy', 'Lunar Bay' }
Merit_BPs = S { 'Meteor Strike', 'Geocrush', 'Grand Fall', 'Wind Blade', 'Heavenly Strike', 'Thunderstorm' }
Physical_BPs_TP = S { 'Rock Buster', 'Mountain Buster', 'Crescent Fang', 'Spinning Dive' }

Ready_Standard = S { 'Sic', 'Whirl Claws', 'Dust Cloud', 'Foot Kick', 'Sheep Song', 'Sheep Charge', 'Lamb Chop',
    'Rage', 'Head Butt', 'Scream', 'Dream Flower', 'Wild Oats', 'Leaf Dagger', 'Claw Cyclone', 'Razor Fang',
    'Roar', 'Gloeosuccus', 'Palsy Pollen', 'Soporific', 'Cursed Sphere', 'Venom', 'Geist Wall', 'Toxic Spit',
    'Numbing Noise', 'Nimble Snap', 'Cyclotail', 'Spoil', 'Rhino Guard', 'Rhino Attack', 'Power Attack',
    'Hi-Freq Field', 'Sandpit', 'Sandblast', 'Venom Spray', 'Mandibular Bite', 'Metallic Body', 'Bubble Shower',
    'Bubble Curtain', 'Scissor Guard', 'Big Scissors', 'Grapple', 'Spinning Top', 'Double Claw', 'Filamented Hold',
    'Frog Kick', 'Queasyshroom', 'Silence Gas', 'Numbshroom', 'Spore', 'Dark Spore', 'Shakeshroom', 'Blockhead',
    'Secretion', 'Fireball', 'Tail Blow', 'Plague Breath', 'Brain Crush', 'Infrasonics', '??? Needles',
    'Needleshot', 'Chaotic Eye', 'Blaster', 'Scythe Tail', 'Ripper Fang', 'Chomp Rush', 'Intimidate', 'Recoil Dive',
    'Water Wall', 'Snow Cloud', 'Wild Carrot', 'Sudden Lunge', 'Spiral Spin', 'Noisome Powder', 'Wing Slap',
    'Beak Lunge', 'Suction', 'Drainkiss', 'Acid Mist', 'TP Drainkiss', 'Back Heel', 'Jettatura', 'Choke Breath',
    'Fantod', 'Charged Whisker', 'Purulent Ooze', 'Corrosive Ooze', 'Tortoise Stomp', 'Harden Shell', 'Aqua Breath',
    'Sensilla Blades', 'Tegmina Buffet', 'Molting Plumage', 'Swooping Frenzy', 'Pentapeck', 'Sweeping Gouge',
    'Zealous Snort', 'Somersault ', 'Tickling Tendrils', 'Stink Bomb', 'Nectarous Deluge', 'Nepenthic Plunge',
    'Pecking Flurry', 'Pestilent Plume', 'Foul Waters', 'Spider Web', 'Sickle Slash', 'Crossthrash', 'Predatory Glare',
    'Hoof Volley', 'Nihility Song', 'Frenzied Rage', 'Venom Shower', 'Mega Scissors', 'Fluid Toss', 'Fluid Spread',
    'Digest', 'Rhinowrecker' }

Ready_Magic = S { 'Dust Cloud', 'Sheep Song', 'Scream', 'Dream Flower', 'Roar', 'Gloeosuccus', 'Palsy Pollen',
    'Soporific', 'Cursed Sphere', 'Venom', 'Geist Wall', 'Toxic Spit', 'Numbing Noise', 'Spoil', 'Hi-Freq Field',
    'Sandpit', 'Sandblast', 'Venom Spray', 'Bubble Shower', 'Filamented Hold', 'Queasyshroom', 'Silence Gas',
    'Numbshroom', 'Spore', 'Dark Spore', 'Shakeshroom', 'Fireball', 'Plague Breath', 'Infrasonics', 'Chaotic Eye',
    'Blaster', 'Intimidate', 'Snow Cloud', 'Noisome Powder', 'TP Drainkiss', 'Jettatura', 'Charged Whisker',
    'Purulent Ooze', 'Corrosive Ooze', 'Aqua Breath', 'Molting Plumage', 'Stink Bomb', 'Nectarous Deluge',
    'Nepenthic Plunge', 'Pestilent Plume', 'Foul Waters', 'Spider Web' }

Ready_TP = S { 'Sic', 'Somersault', 'Dust Cloud', 'Foot Kick', 'Sheep Song', 'Sheep Charge', 'Lamb Chop',
    'Rage', 'Head Butt', 'Scream', 'Dream Flower', 'Wild Oats', 'Leaf Dagger', 'Claw Cyclone', 'Razor Fang', 'Roar',
    'Gloeosuccus', 'Palsy Pollen', 'Soporific', 'Cursed Sphere', 'Geist Wall', 'Numbing Noise', 'Frogkick',
    'Nimble Snap', 'Cyclotail', 'Spoil', 'Rhino Guard', 'Rhino Attack', 'Hi-Freq Field', 'Sandpit', 'Sandblast',
    'Mandibular Bite', 'Metallic Body', 'Bubble Shower', 'Bubble Curtain', 'Scissor Guard', 'Grapple', 'Spinning Top',
    'Double Claw', 'Filamented Hold', 'Spore', 'Blockhead', 'Secretion', 'Fireball', 'Tail Blow', 'Plague Breath',
    'Brain Crush', 'Infrasonics', 'Needleshot', 'Chaotic Eye', 'Blaster', 'Ripper Fang', 'Intimidate', 'Recoil Dive',
    'Water Wall', 'Snow Cloud', 'Wild Carrot', 'Sudden Lunge', 'Noisome Powder', 'Beak Lunge', 'Suction',
    'Drainkiss', 'Acid Mist', 'TP Drainkiss', 'Back Heel', 'Jettatura', 'Choke Breath', 'Fantod', 'Charged Whisker',
    'Purulent Ooze', 'Corrosive Ooze', 'Tortoise Stomp', 'Harden Shell', 'Aqua Breath', 'Sensilla Blades',
    'Tegmina Buffet', 'Zealous Snort', 'Pestilent Plume', 'Foul Waters', 'Spider Web' }

Ready_Debuff = S { 'Dust Cloud', 'Sheep Song', 'Scream', 'Dream Flower', 'Roar', 'Gloeosuccus', 'Palsy Pollen',
    'Soporific', 'Geist Wall', 'Numbing Noise', 'Spoil', 'Hi-Freq Field', 'Sandpit', 'Sandblast', 'Filamented Hold',
    'Spore', 'Fireball', 'Infrasonics', 'Chaotic Eye', 'Blaster', 'Intimidate', 'Noisome Powder', 'TP Drainkiss',
    'Jettatura', 'Purulent Ooze', 'Corrosive Ooze', 'Pestilent Plume', 'Spider Web', 'Nihility Song' }

Ready_Multi = S { 'Sweeping Gouge', 'Tickling Tendrils', 'Chomp Rush', 'Pentapeck', 'Wing Slap', 'Pecking Flurry' }

----------------------------------------------------------------------------------------------------
-- SECTION 6 - DISPLAY LABELS
----------------------------------------------------------------------------------------------------
-- The names shown in chat and on the status box for the two job-defined mode slots. An empty
-- name hides that mode: it is left off the status box, and its keybind is not announced at
-- startup.
UI_Name = ''
UI_Name2 = ''

-- Optional short labels for the status box. Left empty, the display component derives one
-- from the name above. A known name is looked up in its alias table. Any other name takes
-- the first three letters of a single word, or two letters of the first word and the
-- initial of the last. An explicit label is used as given and may run past three
-- characters, which widens the whole label column.
UI_Short = ''
UI_Short2 = ''


