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
--   Section 2 - Gear set placeholders: every set the engine will ever merge, created empty
--   Section 3 - Mode definitions: the M{} state variables and the ammunition tables
--   Section 4 - Job file options, and the Job_Mode_Check helper
--   Section 5 - Action classification lists: which bucket each spell or move falls into
--   Section 6 - Display labels for the two job-defined modes
--
-- THIS IS THE ENGINE'S PUBLIC SURFACE, and the only part a job file is meant to reach.
-- Everything here is global by design. A job file reads these, writes them, and overrides
-- what it needs; nothing here is private and nothing here should become private.
--
-- It is also the ONE COMPONENT WITH NO CONSTRUCTOR. Every other engine file returns a
-- function(E) and is built by the root; this one executes at the top level, exports nothing
-- onto E, and loads FIRST -- before any engine internal exists. That order is what lets the
-- rest of the engine assume these globals are already present, and it is why nothing in this
-- file may read an engine internal: at this point there are none.
--
-- ONE FUNCTION LIVES HERE: Job_Mode_Check, in section 4. Nothing in the engine calls it --
-- it is a helper the engine offers TO job files, and the shipped templates call it several
-- times each. A search for callers inside RahvinGS finds none, which is expected.
--
-- THE SIX SECTION BANNERS BELOW ARE ANCHORS, not decoration. Each one starts at the
-- beginning of its line, each appears exactly once, and they run in ascending order.
-- Sections 2 and 3 bound the gear-set placeholders between them, and sections 5 and 6 bound
-- the classification lists. The wording and the position are both fixed: reword a banner and
-- the block it bounds loses its boundary.

----------------------------------------------------------------------------------------------------
-- SECTION 1 - VERSION AND SHARED GLOBALS
----------------------------------------------------------------------------------------------------
-- Three things the whole engine depends on being present before anything else loads.

-- The version every component stamps itself against. The root compares each component's
-- returned stamp to this one, so a file left over from an older install announces itself at
-- load rather than running half-matched.
Rahvin_GS = '2.0'

-- GearSwap's own Modes library, which supplies the M{} class every state variable in
-- section 3 is built from. Included here rather than by a component because those
-- declarations run in this file, before any component exists.
include('Modes')

-- The registry of slots the multibox spell-received system is holding. It lives out here,
-- visible to job files, because teardown has to be able to empty it from the lifecycle
-- component without reaching into the subsystem that filled it.
active_external_locks = {}

----------------------------------------------------------------------------------------------------
-- SECTION 2 - GEAR SET PLACEHOLDERS
----------------------------------------------------------------------------------------------------
-- Every set the engine can ever merge, created empty. This is what lets a job file declare
-- only the sets it cares about and still load: a set nobody filled in merges as nothing
-- rather than failing to exist. A job file replaces these inside get_sets().
--
-- The distinction a player sees follows from this list. A set that is HERE and left empty
-- is one they declared and did not fill, which is reported; a set they never declared at
-- all is not, because the engine simply falls back to a more general one.
sets.Weapons = {}
sets.Weapons.Sleep = {}
sets.Weapons.Shield = {}
sets.Weapons.Songs = {}
sets.Weapons.Songs.Precast = {}
sets.Weapons.Songs.Midcast = {}

sets.Idle = {}
sets.Idle.Pet = {}
sets.Idle.Sublimation = {}
sets.Idle.Resting = {}
sets.Idle.TP = {}
sets.Idle.ACC = {}
sets.Idle.DT = {}

sets.Movement = {}

-- The multibox received sets, worn while another character on this machine casts on this
-- one. Only needed when SpellReceived is on; each maps to one family of incoming spell.
sets.Cure_Received = {}
sets.Cursna_Received = {}
sets.Phalanx_Received = {}
sets.Protect_Shell_Received = {}
sets.Regen_Received = {}
sets.Refresh_Received = {}
sets.Waltz_Received = {}

-- Worn while curing Doom with a Holy Water or Hallowed Water, where item potency gear
-- changes whether the cure lands.
sets.Holy_Water = {}

-- The engaged build. sets.OffenseMode is the base and always applies; a child named for the
-- current OffenseMode layers over it, which is why every mode a job file offers needs one.
-- The AM tiers layer again on top of that when the matching Aftermath is up, and each can
-- take a child keyed by weapon mode to refine it for one weapon.
sets.OffenseMode = {}
sets.OffenseMode.AM = {}
sets.OffenseMode.AM1 = {}
sets.OffenseMode.AM2 = {}
sets.OffenseMode.AM3 = {}

sets.DualWield = {}

-- Precast, the first half of a cast: fast cast, snapshot, and the opening gear for an
-- ability or weaponskill. Whatever is worn here is replaced at midcast.
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
-- buckets. An enfeeble is routed by what improves it rather than by its school -- accuracy,
-- potency or duration -- because those want different gear.
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
-- sub-buckets, dark magic, and the generic skill and accuracy fallbacks.
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

-- Midcast for blue magic, split by MECHANIC rather than by element or school -- the
-- classification lists in section 5 decide which of these a spell reaches, and the reason
-- for each split is written there.
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
-- one of these, so a song always has a set to reach for even if the job file leaves it bare.
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

-- Midcast Aftermath tiers, RANGED ONLY. There is deliberately no spell equivalent: no
-- builder merges an aftermath tier into a spell midcast, so declaring one would be inert.
sets.Midcast.RA.AM = {}
sets.Midcast.RA.AM1 = {}
sets.Midcast.RA.AM2 = {}
sets.Midcast.RA.AM3 = {}

-- Weaponskills. sets.WS is the base; a child named for the current OffenseMode refines it,
-- and a set named for the weaponskill itself refines it further. The RA branch is the same
-- shape for RANGED weaponskills, and its keys read RA FIRST -- sets.WS.RA.ACC, never
-- sets.WS.ACC.RA, which is a table the engine does not look in.
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
-- the catch-all every ability falls back to, so gear placed there covers everything a job
-- file has not given a named set of its own.
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


sets.Ready = {}
sets.Ready.Magic = {}
sets.Ready.TP = {}
sets.Ready.Debuff = {}
sets.Ready.Standard = {}


-- Bard instruments, chosen by song family ----------------------------------------------------------
-- A bard file names an instrument per purpose here, and the engine equips the matching one
-- during a song's midcast. Pianissimo takes per-family entries as well, so a single-target
-- song can carry a different instrument from the party version of the same song.
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
-- GearSwap's Modes library, which is what gives them a cycling option list and a current
-- value. The defaults set here are what a job file inherits if it declares nothing; a job
-- file widens or replaces an option list with its own :options(...) call.
state.OffenseMode = M { ['description'] = 'Melee Mode' }
state.OffenseMode:options('TP', 'ACC', 'DT')
state.OffenseMode:set('TP')

-- Multibox spell-received gear. ON wears the received set the moment another character on
-- this machine starts casting on this one -- before the spell lands, which is what makes it
-- work through Quick Magic -- and holds those slots until it resolves, or until the
-- failsafe delay releases them because no completion ever arrived.
state.SpellReceived = M { ['description'] = "Spell-Received" }
state.SpellReceived:options('OFF', 'ON')
state.SpellReceived:set('ON')

-- The Hoxne Ampulla hold. ON-Locked keeps range and ammo outright, so nothing else may
-- enter either. ON-Allow Critical holds them the same way but stands aside for the four
-- actions that genuinely need those slots -- bard songs, Geomancy, Tomahawk and Angon --
-- and takes them back afterwards. Bards and Geomancers want the second.
state.Hoxne = M { ['description'] = 'Hoxne' }
state.Hoxne:options('OFF', 'ON-Allow Critical', 'ON-Locked')
state.Hoxne:set('OFF')

-- Treasure Hunter handling. Thief alone gets the SATA option, and alone defaults to full
-- time -- every other job defaults to None, because TH gear costs them damage for nothing.
state.TreasureMode = M { ['description'] = 'Treasure Mode' }
if player.main_job == "THF" then
    state.TreasureMode:options('None', 'Tag', 'Full Time', 'SATA')
    state.TreasureMode:set('Full Time')
else
    state.TreasureMode:options('None', 'Tag', 'Full Time')
    state.TreasureMode:set('None')
end

-- Which weapon set to wear. The option list is entirely the job file's to define; each name
-- needs a matching sets.Weapons entry. Two names are special: 'Locked' and 'Unlocked' name
-- no set of their own and are bridged to the weapon lock below instead -- entering either
-- sets the lock to match, and leaving either returns the lock to Unlocked.
state.WeaponMode = {}
state.WeaponMode = M { ['description'] = 'Weapon Specific Mode' }
state.WeaponMode:options('OFF', 'ON')
state.WeaponMode:set('OFF')

-- The weapon lock, separate from the weapon mode: the mode says what the weapons are, the
-- lock says whether anything but the mode may change main and sub. Unlocked leaves every
-- phase as it is today. Locked makes the weapon mode the only writer of main and sub in
-- every phase. Bards get Songs, Locked for everything except a song aimed at a friendly
-- target; Corsairs get Locked+R, which holds range as well. Fixed by the engine and never
-- redeclared by a job file -- a job file's own :options() call would wipe the list -- so a
-- job file that wants to boot locked calls state.WeaponLock:set('Locked') and nothing else;
-- a value its job's list does not offer raises at load. The value is resolved into three
-- flags the moment it changes -- whether main and sub are held, whether range goes with
-- them, whether a friendly song is exempt -- and every build path reads those flags rather
-- than this mode.
state.WeaponLock = M { ['description'] = 'Weapon Lock' }
if player.main_job == "BRD" then
    state.WeaponLock:options('Unlocked', 'Locked', 'Songs')
elseif player.main_job == "COR" then
    state.WeaponLock:options('Unlocked', 'Locked', 'Locked+R')
else
    state.WeaponLock:options('Unlocked', 'Locked')
end
state.WeaponLock:set('Unlocked')

-- Two free-form mode slots for anything a job needs. The engine only tracks the value and
-- shows it; what it MEANS is entirely up to the job file, which reads it in its own hooks.
-- Name them with UI_Name and UI_Name2 in section 6, or they stay hidden.
state.JobMode = {}
state.JobMode = M { ['description'] = 'Job Specific Mode' }
state.JobMode:options('OFF', 'ON')
state.JobMode:set('OFF')

state.JobMode2 = {}
state.JobMode2 = M { ['description'] = 'Job Specific Mode' }
state.JobMode2:options('OFF', 'ON')
state.JobMode2:set('OFF')

-- Which ammunition table the engine reads. Selects between the three below, so a job file
-- that carries more than one ranged weapon does not need separate gear sets for each.
state.RAMode = {}
state.RAMode = M { ['description'] = 'Ranged Attack Mode' }
state.RAMode:options('Bullet', 'Arrow', 'Bolt')
state.RAMode:set('Bullet')

-- Raised once the low-ammunition warning has fired, so a dwindling stack is reported once
-- rather than on every shot. Cleared when the stack is replaced.
state.warned = M(false)


-- Ammunition --------------------------------------------------------------------------------------
-- Ammunition names, read in two shapes, and a job file fills each shape itself. The set
-- builders read one level, Ammo[<the current OffenseMode value>], and merge it into the ammo
-- slot of the idle and engaged dress, the ranged weaponskill precast, and the ranged attack's
-- precast and midcast, so those sets need not name a bullet or an arrow. The out-of-ammunition
-- weaponskill fallback reads two levels, Ammo[<the current RAMode value>] then .RA or .TP: the
-- standard round a weaponskill may be finished on once its own has run out. Filling only the
-- per-type tables below leaves the one-level merges with nothing, so those sets must name their
-- own rounds; assigning the flat keys from state.RAMode is what makes the merged round follow
-- the ranged type.
Ammo = {}
Ammo.Bullet = {}
Ammo.Arrow = {}
Ammo.Bolt = {}

Ammo_Warning_Limit = 99


----------------------------------------------------------------------------------------------------
-- SECTION 4 - JOB FILE OPTIONS
----------------------------------------------------------------------------------------------------
-- The post-action busy window, not a job-file option. It is a bare global rather than a
-- field on the shared engine table because a job file has to be able to see it and raise
-- it, and the summoner template does. The action hooks and the polling engine both write it
-- every action; the Hoxne tick and the debug box read it. Move it out of the global scope
-- and those job files break with no error anywhere.
is_Busy = false

-- Plain toggles a job file may set near the top of itself. Declared here so a file that
-- sets none of them still finds them defined rather than nil.
AutoItem = false
Random_Lockstyle = false
Lockstyle_List = {}

-- Layer the weapon set named by the current JobMode value onto a set the caller is building.
-- A HELPER FOR JOB FILES: nothing in the engine calls it, and the shipped templates call it
-- several times each.
--
-- It works for ANY mode name the job file offers, including 'Standard' -- it is a table
-- lookup, not a list of known modes -- so declaring sets.Weapons.<mode> is all that is
-- needed to have a mode dress weapons, and leaving that set out makes the mode dress
-- nothing. A job file wanting different behavior defines its own Job_Mode_Check after the
-- include line, which loads later and replaces this one.
function Job_Mode_Check(equipSet)
    local weapons = sets.Weapons and sets.Weapons[state.JobMode.value]
    -- set_combine, never an in-place merge: the table belongs to the caller, and merging
    -- into it would write the weapons permanently into whatever set was passed.
    if weapons then equipSet = set_combine(equipSet, weapons) end
    return equipSet
end


----------------------------------------------------------------------------------------------------
-- SECTION 5 - ACTION CLASSIFICATION LISTS
----------------------------------------------------------------------------------------------------
-- The lists that decide which set an action reaches for. Membership here is the whole
-- routing mechanism: a spell, weaponskill or ready move is looked up in these, and the
-- bucket it lands in names the set.
--
-- Adding a name to a list is therefore how a spell is re-routed, and the lists are grouped
-- by WHAT IMPROVES an action rather than by its school or element -- two spells from the
-- same school often want completely different gear.
Elemental_WS = S {
    'Earth Shot', 'Ice Shot', 'Water Shot', 'Fire Shot', 'Wind Shot', 'Thunder Shot',
    'Gust Slash', 'Cyclone', 'Energy Steal', 'Energy Drain', 'Aeolian Edge',
    'Burning Blade', 'Red Lotus Blade', 'Shining Blade', 'Seraph Blade', 'Sanguine Blade',
    'Frostbite', 'Freezebite', 'Herculean Slash',
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

Enfeebling_Song = S { 'Foe Requiem', 'Foe Requiem II', 'Foe Requiem III', 'Foe Requiem IV', 'Foe Requiem V', 'Foe Requiem VI', 'Foe Requiem VII', 'Battlefield Elegy', 'Carnage Elegy',
    'Fire Threnody', 'Ice Threnody', 'Wind Threnody', 'Earth Threnody', 'Ltng. Threnody', 'Water Threnody', 'Light Threnody', 'Dark Threnody', 'Fire Threnody II',
    'Ice Threnody II', 'Wind Threnody II', 'Earth Threnody II', 'Ltng. Threnody II', 'Water Threnody II', 'Light Threnody II', 'Dark Threnody II', 'Magic Finale', 'Pining Nocturne' }

Enfeeble_Acc = S { 'Dispel', 'Aspir', 'Aspir II', 'Aspir III', 'Drain', 'Drain II', 'Drain III', 'Frazzle', 'Frazzle II', 'Stun', 'Poison', 'Poison II', 'Poisonga' }
Enfeeble_Potency = S { 'Paralyze', 'Paralyze II', 'Slow', 'Slow II', 'Addle', 'Addle II', 'Distract', 'Distract II', 'Distract III', 'Frazzle III', 'Blind', 'Blind II', 'Gravity', 'Gravity II' }
Enfeeble_Duration = S { 'Sleep', 'Sleep II', 'Sleepga', 'Sleepga II', 'Diaga', 'Dia', 'Dia II', 'Dia III', 'Bio', 'Bio II', 'Bio III', 'Silence', 'Inundation', 'Break', 'Breakga', 'Bind', 'Bindga' }

Dark_Acc = S { 'Death', 'Kaustra', 'Stun' }
Dark_Absorb = S { 'Absorb-ACC', 'Absorb-AGI', 'Absorb-Attri', 'Absorb-CHR', 'Absorb-DEX', 'Absorb-INT', 'Absorb-MND', 'Absorb-STR', 'Absorb-TP', 'Absorb-VIT', 'Aspir', 'Aspir II', 'Aspir III', 'Drain', 'Drain II', 'Drain III' }
Dark_Enhancing = S { 'Dread Spikes', 'Endark', 'Endark II', 'Klimaform', 'Tractor' }

Enhancing_Skill = S { 'Temper', 'Temper II', 'Enaero', 'Enstone', 'Enthunder', 'Enwater', 'Enfire', 'Enblizzard', 'Boost-STR', 'Boost-DEX', 'Boost-VIT', 'Boost-AGI', 'Boost-INT', 'Boost-MND', 'Boost-CHR' }
Divine_Skill = S { 'Enlight', 'Enlight II', 'Flash', 'Repose', 'Holy', 'Holy II', 'Banish', 'Banish II', 'Banish III', 'Banishga', 'Banishga II', }

-- The blue magic buckets. Blue magic is the clearest case for grouping by mechanic: two
-- spells that look alike can scale from entirely different stats, so gearing them the same
-- way wastes one of them. Each bucket below states what actually improves it.
--
-- Physical: weapon accuracy, the spell's stat modifier, and attack. Magic attack does
-- nothing at all for these.
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
-- Breath: scales from max HP and level, and nothing else. INT, magic attack bonus and Blue
-- Magic Skill are all inert here, which is why these cannot share the nuke set.
BlueBreath = S { 'Bad Breath', 'Flying Hip Press', 'Frost Breath', 'Heat Breath',
    'Hecatomb Wave', 'Magnetite Cloud', 'Poison Breath', 'Radiant Breath', 'Self-Destruct',
    'Thunder Breath', 'Vapor Spray', 'Wind Breath' }
-- Nuke: magic attack bonus and the spell's own stat modifier. The bucket that behaves the
-- way a black mage's nuke does.
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
-- Buff: fixed potency. Nothing gear can carry changes the effect, so DURATION is the only
-- thing worth gearing for here.
BlueBuff = S { 'Amplification', 'Animating Wail', 'Battery Charge', 'Carcharian Verve',
    'Cocoon', 'Erratic Flutter', 'Exuviation', 'Fantod', 'Feather Barrier', 'Harden Shell',
    'Memento Mori', 'Mighty Guard', 'Nat. Meditation', 'O. Counterstance', 'Refueling',
    'Regeneration', 'Saline Coat', 'Triumphant Roar', 'Warm-Up', 'Winds of Promy.',
    'Zephyr Mantle' }
-- Healing: cure potency, MND and Blue Magic Skill. White Wind is DELIBERATELY ABSENT from
-- this list -- it heals from max HP and ignores both skill and MND, so it would be geared
-- wrongly here and takes a named set of its own instead.
BlueHealing = S { 'Healing Breeze', 'Magic Fruit', 'Plenilune Embrace', 'Pollen', 'Restoral',
    'Wild Carrot' }
-- Tank: the enmity-generating enfeebles, geared for enmity rather than for the debuff.
BlueTank = S { 'Actinic Burst', 'Blank Gaze', 'Demoralizing Roar', 'Frightful Roar',
    'Geist Wall', 'Jettatura', 'Sheep Song', 'Soporific', 'Stinking Gas' }
-- Accuracy: the enfeebles and debuffs whose only question is whether they land, so magic
-- accuracy is what they want.
BlueACC = S { '1000 Needles', 'Absolute Terror', 'Auroral Drape', 'Awful Eye',
    'Blistering Roar', 'Blood Drain', 'Blood Saber', 'Chaotic Eye', 'Cimicine Discharge',
    'Cold Wave', 'Corrosive Ooze', 'Cruel Joke', 'Digest', 'Dream Flower', 'Enervation',
    'Feather Tickle', 'Filamented Hold', 'Infrasonics', 'Light of Penance', 'Lowing',
    'MP Drainkiss', 'Mortal Ray', 'Osmosis', 'Reaving Wind', 'Sandspin', 'Sandspray',
    'Sound Blast', 'Venom Shell', 'Voracious Trunk', 'Yawn' }


-- Elemental and healing magic ---------------------------------------------------------------------
Elemental_Enfeeble = S { 'Burn', 'Frost', 'Choke', 'Rasp', 'Shock', 'Drown' }

Healing_Magic = S { 'Arise', 'Blindna', 'Esuna', 'Paralyna', 'Poisona', 'Raise', 'Raise II', 'Raise III', 'Reraise', 'Reraise II', 'Reraise III', 'Reraise IV', 'Sacrifice', 'Silena', 'Stona', 'Viruna', 'Cursna' }


-- Summoner blood pacts ----------------------------------------------------------------------------
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
SongCount = S { "Knight's Minne", "Knight's Minne II", "Army's Paeon", "Army's Paeon II", "Army's Paeon III", "Army's Paeon IV", "Fowl Aubade", "Herb Pastoral",
    "Shining Fantasia", "Scop's Operetta", "Puppet's Operetta", "Gold Capriccio", "Warding Round", "Goblin Gavotte" }


-- Ninjutsu ----------------------------------------------------------------------------------------
Enfeebling_Ninjitsu = S { 'Jubaku: Ichi', 'Kurayami: Ni', 'Hojo: Ichi', 'Hojo: Ni', 'Kurayami: Ichi', 'Dokumori: Ichi', 'Aisha: Ichi', 'Yurin: Ichi' }

Elemental_Bar = S { 'Barfire', 'Barblizzard', 'Baraero', 'Barstone', 'Barthunder', 'Barwater', 'Barfira', 'Barblizzara', 'Baraera', 'Barstonra', 'Barthundra', 'Barwatera' }
Status_Bar = S { 'Barsleepra', 'Barpoisonra', 'Barparalyzra', 'Barblindra', 'Barvira', 'Barpetra', 'Baramnesra', 'Barsilencera', 'Barsleep', 'Barpoison', 'Barparalyze', 'Barblind', 'Barvirus', 'Barpetrify', 'Baramnesia', 'Barsilence' }

-- Pet ready moves, grouped by what their potency scales from.

-- Beastmaster ready moves -------------------------------------------------------------------------
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
-- The names shown in chat and on the status box for the two job-defined mode slots.
-- Leaving one empty HIDES that mode entirely -- it is dropped from the status box and its
-- keybind is not announced at startup -- which is how a job file that uses neither slot
-- gets a status box with nothing spurious in it.
UI_Name = ''
UI_Name2 = ''

-- Optional short labels for the status box. Left empty, the display component derives one
-- from the name above: a known name is looked up in its alias table, and anything else
-- takes the first three letters of a single word, or two letters of the first word plus the
-- initial of the last. An explicit value here is used verbatim instead, and unlike a derived
-- label it may run longer than three characters and widen the whole label column.
UI_Short = ''
UI_Short2 = ''


