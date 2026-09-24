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
-- it needs, so this file speaks to players who edit job files as well as to maintainers.
--
-- This is the one component with no constructor. Every other engine file returns a
-- function(E) that the root builds. This one runs at the top level, exports nothing onto E,
-- and loads first, before any other engine file. The rest of the engine can therefore
-- assume these globals exist, and nothing in this file may read an engine internal, because
-- none exists yet.
--
-- Job_Mode_Check, in section 4, is the only function here. Nothing in the engine calls it.
-- It is a helper for job files.

----------------------------------------------------------------------------------------------------
-- SECTION 1 - VERSION AND SHARED GLOBALS
----------------------------------------------------------------------------------------------------
-- The version, the Modes library and the received-gear registry, which the rest of the
-- engine expects to exist before it loads.

-- The version every component stamps itself against. The root compares each component's
-- returned stamp with this one, so a file left over from another version announces itself at
-- load rather than running mismatched.
Rahvin_GS = '2.1'

-- GearSwap's Modes library, which supplies the M{} class every state variable in section 3
-- is built from. It is included here because those declarations run in this file, before
-- any component exists.
include('Modes')

-- The registry of slots received gear is holding, keyed by the slot name the received set
-- uses. It is a global so the lifecycle teardown can empty it without reaching into the
-- spell-received component. That component replaces the table whole on every release, so
-- every reader looks the global up at each use rather than keeping a reference.
active_external_locks = {}

----------------------------------------------------------------------------------------------------
-- SECTION 2 - GEAR SET PLACEHOLDERS
----------------------------------------------------------------------------------------------------
-- The fixed set paths the engine reads, created empty. A job file declares only the sets it
-- uses, and a set it leaves out merges as nothing rather than failing to exist. A job file
-- replaces these tables inside get_sets(), and the first set build after a load re-creates
-- any placeholder path the job file dropped. The engine records each placeholder before the
-- job file declares its sets, so its warnings can tell a set the job file never declared
-- from one it declared and left empty.

-- Weapons. The job file adds one child per WeaponMode option. Sleep is held on while the
-- character is asleep, Shield is the offhand merged under a one-handed main without Dual
-- Wield, and Songs holds the bard's song weapons.
sets.Weapons = {}
sets.Weapons.Sleep = {}
sets.Weapons.Shield = {}
sets.Weapons.Songs = {}
sets.Weapons.Songs.Precast = {}
sets.Weapons.Songs.Midcast = {}

-- Idle. The base is also the floor under every precast and midcast build. A child named for
-- the current OffenseMode layers over it, and Resting, Pet and Sublimation layer on in those
-- states.
sets.Idle = {}
sets.Idle.Pet = {}
sets.Idle.Sublimation = {}
sets.Idle.Resting = {}
sets.Idle.TP = {}
sets.Idle.ACC = {}
sets.Idle.DT = {}

-- Layered over idle while the character moves and is not engaged.
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

-- The engaged build. sets.OffenseMode is the base and always applies. The child named for
-- the current OffenseMode layers over it, and a mode with no child skips the rest of the
-- engaged build, so every mode a job file offers needs one. The AM tiers layer on top while
-- the matching Aftermath is up, and each can take a child keyed by weapon mode.
sets.OffenseMode = {}
sets.OffenseMode.AM = {}
sets.OffenseMode.AM1 = {}
sets.OffenseMode.AM2 = {}
sets.OffenseMode.AM3 = {}

-- Layered over the engaged build while the Dual Wield trait is up.
sets.DualWield = {}

-- Precast for spells and ranged attacks: fast cast with its per-school children, and
-- snapshot under sets.Precast.RA with a child for each Flurry. The midcast build replaces
-- this gear once the cast starts.
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

-- Midcast for ranged attacks, with children for the shot buffs, and the three enfeebling
-- buckets. An enfeeble is routed by what improves it, accuracy, potency or duration, rather
-- than by its school.
sets.Midcast = {}
sets.Midcast.RA = {}
sets.Midcast.RA['True Shot'] = {}
sets.Midcast.RA.TripleShot = {}
sets.Midcast.RA.DoubleShot = {}
sets.Midcast.RA.Barrage = {}

sets.Midcast.Enfeebling = {}
sets.Midcast.Enfeebling.MACC = {}
sets.Midcast.Enfeebling.Potency = {}
sets.Midcast.Enfeebling.Duration = {}

-- Midcast for the magic schools: nukes and bursts, the cure family, enhancing and its
-- children, dark magic, and the generic skill and accuracy sets. SIRD is merged under every
-- midcast except a ranged attack's.
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

sets.Midcast.Aspir = {}
sets.Midcast.Drain = {}
sets.Midcast.Dark = {}
sets.Midcast.Dark.MACC = {}
sets.Midcast.Dark.Absorb = {}
sets.Midcast.Dark.Enhancing = {}
sets.Midcast.Skill = {}
sets.Midcast.ACC = {}
sets.Midcast.BP = {}
sets.Midcast.SummoningMagic = {}
sets.Midcast.Summon = {}

sets.Midcast.Utsusemi = {}
sets.Midcast.Phalanx = {}
sets.Midcast.Divine = {}
sets.Helix = {}
sets.Helix.Dark = {}
sets.Helix.Light = {}

-- Midcast for blue magic, split by mechanic rather than by element or school. The blue magic
-- lists in section 5 decide which of these a spell reaches, and say what improves each one.
sets.Midcast.BlueMagic = {}
sets.Midcast.BlueMagic.Physical = {}
sets.Midcast.BlueMagic.Breath = {}
sets.Midcast.BlueMagic.Nuke = {}
sets.Midcast.BlueMagic.Skill = {}
sets.Midcast.BlueMagic.Buff = {}
sets.Midcast.BlueMagic.Enmity = {}
sets.Midcast.BlueMagic.Healing = {}
sets.Midcast.BlueMagic.ACC = {}

-- Midcast for bard songs, one set per song family. Every castable song belongs to exactly
-- one family, so a song always has a set to reach for. DummySongs serves the dummy songs
-- listed in section 5.
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

-- Weaponskills. sets.WS is the base, and a set named for the weaponskill layers over it. A
-- mode child comes next: the named set's own child for the current OffenseMode where it has
-- one, otherwise sets.WS's child for that mode. TP takes no generic mode child. The AM tiers
-- layer over those while the matching Aftermath is up. A ranged weaponskill merges sets.WS.RA
-- over sets.WS and reads its generic mode children there, so those keys read RA first:
-- sets.WS.RA.ACC, never sets.WS.ACC.RA, which the engine does not read.
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
sets.WS.AM = {}
sets.WS.RA.AM = {}
sets.WS.AM1 = {}
sets.WS.RA.AM1 = {}
sets.WS.AM2 = {}
sets.WS.RA.AM2 = {}
sets.WS.AM3 = {}
sets.WS.RA.AM3 = {}

-- Job abilities, the job-specific families, pet actions and the situational sets. sets.JA is
-- the base of every job ability's precast, and a child named for the ability layers over it.
-- The families below it serve their own action types. sets.Enmity is not read by the
-- engine. It is a building block job files combine into their enmity abilities' sets.
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

sets.Storms = {}
sets.Enmity = {}
sets.Diffusion = {}
sets.Geomancy = {}
sets.Geomancy.Geo = {}
sets.Geomancy.Indi = {}
sets.Geomancy.Indi.Entrust = {}
sets.Pet_Midcast = {}


-- Beastmaster Ready moves. The engine merges sets.Ready for every Ready move and reads none
-- of its children, which are there for the job file's own hooks.
sets.Ready = {}
sets.Ready.Magic = {}
sets.Ready.TP = {}
sets.Ready.Debuff = {}
sets.Ready.Standard = {}


-- Bard instruments, chosen by song family ----------------------------------------------------------
-- A bard file names an instrument per purpose here. The engine equips Count, AOE_Sleep,
-- Enfeebling or Potency during a song's midcast, and at precast under Nightingale. It adds
-- Pianissimo at midcast for a song aimed at one other player or a Trust, and Pianissimo takes
-- per-family children, so such a song can carry a different instrument from the party
-- version of the same song. The engine does not read the other keys, which are for the job
-- file's own weapon sets.
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
state.OffenseMode = M { ['description'] = 'Melee Mode' }
state.OffenseMode:options('TP', 'ACC', 'DT')
state.OffenseMode:set('TP')

-- Multibox spell-received gear. ON wears the received set as soon as another character on
-- this machine starts casting on this one, before the spell lands, which is what makes it
-- work through Quick Magic. The slots stay held until the spell resolves, or until the
-- failsafe delay releases them when no completion arrives.
state.SpellReceived = M { ['description'] = "Spell-Received" }
state.SpellReceived:options('OFF', 'ON')
state.SpellReceived:set('ON')

-- The Hoxne Ampulla hold. ON-Locked keeps range and ammo outright, so nothing else may enter
-- either. ON-Allow Critical holds them the same way, but stands aside for the four actions
-- that need those slots and takes them back afterward: bard songs, Geomancy, Tomahawk and
-- Angon. Bards and Geomancers need ON-Allow Critical, because ON-Locked blocks their
-- instrument and handbell.
state.Hoxne = M { ['description'] = 'Hoxne' }
state.Hoxne:options('OFF', 'ON-Allow Critical', 'ON-Locked')
state.Hoxne:set('OFF')

-- Treasure Hunter handling. Only Thief gets the SATA option, and only Thief defaults to Full
-- Time. Every other job defaults to None.
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
-- the lock says whether anything but the mode may change main and sub.
--   Unlocked   holds nothing.
--   Locked     makes the weapon mode the only writer of main and sub in every phase.
--   Songs      (Bard) Locked, except for a song aimed at the bard, another player or a Trust.
--   Locked+R   (Corsair) Locked, and holds range as well unless a Hoxne mode holds it.
--   Geomancy   (Geomancer) Locked, except for a Geomancy spell, whose set may change main
--              and sub.
-- The engine fixes this list per job, and a job file never redeclares it, because its own
-- :options() call would wipe the list. A job file that wants to start locked calls
-- state.WeaponLock:set('Locked') and nothing else. A value its job's list does not offer
-- raises at load. The equip component resolves the value into four flags at startup and on
-- every change, and every build path reads those flags rather than this mode.
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

-- Two free-form mode slots for anything a job needs. The engine shows each value and reads
-- JobMode in three places. Job_Mode_Check dresses sets.Weapons by it, the two jug-pet calls
-- read sets.Jugs by it, and a value of 'Ranged' merges the idle set's OffenseMode child into
-- the engaged build. Anything else a value means is up to the job file's own hooks. Name the
-- slots with UI_Name and UI_Name2 in section 6, or they stay hidden.
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
-- ranged type reads it to fill the flat Ammo keys below.
state.RAMode = {}
state.RAMode = M { ['description'] = 'Ranged Attack Mode' }
state.RAMode:options('Bullet', 'Arrow', 'Bolt')
state.RAMode:set('Bullet')

-- Raised once the low-ammunition warning has fired, so a dwindling stack is reported once
-- rather than on every shot. Cleared once the count is back above Ammo_Warning_Limit.
state.warned = M(false)


-- Ammunition --------------------------------------------------------------------------------------
-- Ammunition names, read in two shapes, and a job file fills each shape itself. The set
-- builders read one level, Ammo[<the current OffenseMode value>], and merge it into the ammo
-- slot of the idle and engaged build, the ranged weaponskill precast, and the ranged attack's
-- precast and midcast, so those sets need not name a round. The out-of-ammunition fallback
-- for a weaponskill reads two levels, Ammo[<the current RAMode value>] then .RA or .TP: the
-- standard round a weaponskill may finish on once its own has run out. Filling only the
-- per-type tables below leaves the one-level merges with nothing, and those sets must then
-- name their own rounds. Assigning the flat keys from state.RAMode is what makes the merged
-- round follow the ranged type.
Ammo = {}
Ammo.Bullet = {}
Ammo.Arrow = {}
Ammo.Bolt = {}

-- At or below this many rounds of the ranged ammunition, precast prints the low-ammunition
-- warning, once. A job file may set its own.
Ammo_Warning_Limit = 99


----------------------------------------------------------------------------------------------------
-- SECTION 4 - JOB FILE OPTIONS
----------------------------------------------------------------------------------------------------
-- The busy window, not a job-file option. It is a bare global rather than a field on E so a
-- job file can see it and raise it, as the summoner template does. The precast hook raises
-- it for each action, and the polling engine or the next precast clears it once the window
-- runs out. The polling engine, the Hoxne tick and the debug box read it. Moved out of the
-- global scope, it would break those job files with no error anywhere.
is_Busy = false

-- Plain toggles a job file may set near its top, declared here so the engine reads a
-- default when the job file sets none. AutoItem uses a Remedy or a Holy Water for the
-- status ailments that call for one. Random_Lockstyle picks the lockstyle from
-- Lockstyle_List each time jobsetup runs.
AutoItem = false
Random_Lockstyle = false
Lockstyle_List = {}

-- Layer the weapon set named by the current JobMode value onto a set the caller is building,
-- and return the result. A helper for job files: nothing in the engine calls it, and some
-- shipped templates do.
--
-- It works for any mode name the job file offers, 'Standard' included, because it is a table
-- lookup rather than a list of known modes. Declaring sets.Weapons.<mode> is all a mode
-- needs to dress weapons, and a mode with no such set dresses nothing. A job file that wants
-- different behavior defines its own Job_Mode_Check after its include line, and that one
-- replaces this.
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
-- because two spells from one school often want different gear. The blood pact and Ready
-- move lists are the exception: the engine does not read them, and they are for the
-- summoner and beastmaster job files' own hooks.

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
-- .Duration.
Enfeeble_Acc = S { 'Dispel', 'Aspir', 'Aspir II', 'Aspir III', 'Drain', 'Drain II', 'Drain III', 'Frazzle', 'Frazzle II', 'Stun', 'Poison', 'Poison II', 'Poisonga' }
Enfeeble_Potency = S { 'Paralyze', 'Paralyze II', 'Slow', 'Slow II', 'Addle', 'Addle II', 'Distract', 'Distract II', 'Distract III', 'Frazzle III', 'Blind', 'Blind II', 'Gravity', 'Gravity II' }
Enfeeble_Duration = S { 'Sleep', 'Sleep II', 'Sleepga', 'Sleepga II', 'Diaga', 'Dia', 'Dia II', 'Dia III', 'Bio', 'Bio II', 'Bio III', 'Silence', 'Inundation', 'Break', 'Breakga', 'Bind', 'Bindga' }

-- Dark magic: sets.Midcast.Dark.MACC, .Absorb and .Enhancing. A dark spell in none of these
-- takes the potency or duration tier above.
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


-- Summoner blood pacts ----------------------------------------------------------------------------
-- Not read by the engine. The summoner job file sorts its blood pacts with these.
Buff_BPs_Duration = S { 'Shining Ruby', 'Aerial Armor', 'Frost Armor', 'Rolling Thunder', 'Crimson Howl', 'Lightning Armor', 'Ecliptic Growl', 'Glittering Ruby', 'Earthen Ward', 'Hastega',
    'Noctoshield', 'Ecliptic Howl', 'Dream Shroud', 'Earthen Armor', 'Fleet Wind', 'Inferno Howl', 'Heavenward Howl', 'Hastega II', 'Soothing Current', 'Crystal Blessing' }
Buff_BPs_Healing = S { 'Healing Ruby', 'Healing Ruby II', 'Whispering Wind', 'Spring Water' }
Debuff_BPs = S { 'Mewing Lullaby', 'Eerie Eye', 'Lunar Cry', 'Lunar Roar', 'Nightmare', 'Pavor Nocturnus', 'Ultimate Terror', 'Somnolence', 'Slowga', 'Tidal Roar', 'Diamond Storm', 'Sleepga', 'Shock Squall' }
Debuff_Rage_BPs = S { 'Moonlit Charge', 'Tail Whip' }
Magic_BPs_NoTP = S { 'Holy Mist', 'Nether Blast', 'Aerial Blast', 'Searing Light', 'Diamond Dust', 'Earthen Fury', 'Zantetsuken', 'Tidal Wave', 'Judgment Bolt', 'Inferno', 'Howling Moon', 'Ruinous Omen', 'Night Terror', 'Thunderspark' }
Magic_BPs_TP = S { 'Impact', 'Conflag Strike', 'Level ? Holy', 'Lunar Bay' }
Merit_BPs = S { 'Meteor Strike', 'Geocrush', 'Grand Fall', 'Wind Blade', 'Heavenly Strike', 'Thunderstorm' }
Physical_BPs_TP = S { 'Rock Buster', 'Mountain Buster', 'Crescent Fang', 'Spinning Dive' }
AvatarList = S { 'Shiva', 'Ramuh', 'Garuda', 'Leviathan', 'Diabolos', 'Titan', 'Fenrir', 'Ifrit', 'Carbuncle', 'Fire Spirit', 'Air Spirit', 'Ice Spirit', 'Thunder Spirit',
    'Light Spirit', 'Dark Spirit', 'Earth Spirit', 'Water Spirit', 'Cait Sith', 'Alexander', 'Odin', 'Atomos' }


-- Bard songs --------------------------------------------------------------------------------------
-- Dummy songs, sung only to be overwritten by the next song. They take
-- sets.Midcast.DummySongs and Instrument.Count, and never the Pianissimo instrument.
SongCount = S { "Knight's Minne", "Knight's Minne II", "Army's Paeon", "Army's Paeon II", "Army's Paeon III", "Army's Paeon IV", "Fowl Aubade", "Herb Pastoral",
    "Shining Fantasia", "Scop's Operetta", "Puppet's Operetta", "Gold Capriccio", "Warding Round", "Goblin Gavotte" }


-- Ninjutsu ----------------------------------------------------------------------------------------
-- Enfeebling ninjutsu, which takes sets.Midcast.Enfeebling.
Enfeebling_Ninjitsu = S { 'Jubaku: Ichi', 'Kurayami: Ni', 'Hojo: Ichi', 'Hojo: Ni', 'Kurayami: Ichi', 'Dokumori: Ichi', 'Aisha: Ichi', 'Yurin: Ichi' }

-- The bar spells, by what they resist. The elemental ones take
-- sets.Midcast.Enhancing.Elemental, and the status ones take sets.Midcast.Enhancing.Status.
Elemental_Bar = S { 'Barfire', 'Barblizzard', 'Baraero', 'Barstone', 'Barthunder', 'Barwater', 'Barfira', 'Barblizzara', 'Baraera', 'Barstonra', 'Barthundra', 'Barwatera' }
Status_Bar = S { 'Barsleepra', 'Barpoisonra', 'Barparalyzra', 'Barblindra', 'Barvira', 'Barpetra', 'Baramnesra', 'Barsilencera', 'Barsleep', 'Barpoison', 'Barparalyze', 'Barblind', 'Barvirus', 'Barpetrify', 'Baramnesia', 'Barsilence' }

-- Beastmaster ready moves -------------------------------------------------------------------------
-- Grouped by what their potency scales from. Not read by the engine, which merges sets.Ready
-- for every Ready move. The beastmaster job file sorts its moves with these.
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


