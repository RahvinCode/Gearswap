--------------------------------------------------------------------------
--===          Mirdain Gearswap Enhanced by Rahvin                   ===--
--------------------------------------------------------------------------
-- Revisions of Mirdain-Include and sample job files from 1.6.0 forward were conceived and programmed by Rahvin.
-- README.md covers installation, features, commands and troubleshooting

-- Enhanced features compared to Mirdain 1.5.X:
-- Hoxne Ampulla Mode with automatic equipping and item use.
--     Specialized modes: (ON-Allow Critical) allow critical spells to equip ranged and ammo (Bard songs, geo spells, angon and tomahawk only)
--                        (ON-Locked) disallow any ranged or ammo changes.
-- Multibox Spell-Received Gear Tracking with AoE prediction for -aga, -ra, Accession, Divine Veil and Majesty.
--     Automatically equips sets.XXXX_Received the instant a local multiboxed character starts casting on you.
--     Locks spell received gear in place until the exact moment the spell lands.  Reverts to normal gear immediately.
--     Set up your gear in job specific lua (BRD.lua, WAR.lua, etc).
-- Automated Holy Water gear equipping when used from macro or through automation tools.
-- Twilight Cape support. Now equips Twilight Cape automatically for Cura and Curaga during matching day/weather.
-- One-Line or Full display toggling with automated position saving. Display redesigned for aesthetics and compactness.
-- Added commands for better gear control and fixed equipment slot enabling/unlock routines to respect modes and zones
--     Supports all usable items for gs c use xxxx . Type the name of the item out in all lower case, including spaces and +1 when applicable.
--     Item equip delays and recast times are tracked now, with warnings when requested items are on cooldown.
--     No longer silently fails to use warp rings due to unlock or equip overwrites from movement, incoming action packets, combat commands, etc.
-- Extensive optimization to core code.
--     CPU performance improved by ~10%. 2-3% less total cpu usage for a 6 box on high end systems.
--     Many functions and table calls optimized to use hash-mapped checks over iterative lookups.
--     Event registers switched to raw register events for some routines to reduce background table allocations
--     Guard clauses and fixes to conditional statements everywhere to prevent unnecessary computation

-- See https://www.github.com/rahvincode for full details and latest version.
-- README.md includes installation instructions and full feature explanations.
-- Credit to Mirdain for the original concept and scaffolding.

-- TODO next version:
-- Fix info texts/warn texts to display when a called set is empty.

-----------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------
-- SECTION 1 - VERSION AND SHARED GLOBALS
----------------------------------------------------------------------------------------------------
-- The version string, the Modes library, and globals the job file may read.
Mirdain_GS = '1.7.1'

-- Modes supplies the M{} mode-tracking class used by every state variable below.
include('Modes')

-- Slots locked by the multibox spell-received system, so they can be released on unload.
active_external_locks = {}

-- Weapons and idle.

----------------------------------------------------------------------------------------------------
-- SECTION 2 - GEAR SET PLACEHOLDERS
----------------------------------------------------------------------------------------------------
-- Every set the engine merges is created empty here so a job file that omits one still
-- loads. The job file replaces these inside get_sets(); anything left empty merges as a
-- no-op.
sets.Weapons = {}
sets.Weapons.Sleep = {}
sets.Weapons.Shield = {}
sets.Weapons.Songs = {}
sets.Weapons.Songs.Midcast = {}

sets.Idle = {}
sets.Idle.Pet = {}
sets.Idle.Sublimation = {}
sets.Idle.Resting = {}
sets.Idle.TP = {}
sets.Idle.ACC = {}
sets.Idle.DT = {}

sets.Movement = {}

-- Sets worn while another local character casts on this one.
sets.Cure_Received = {}
sets.Cursna_Received = {}
sets.Phalanx_Received = {}
sets.Protect_Shell_Received = {}
sets.Regen_Received = {}
sets.Refresh_Received = {}
sets.Waltz_Received = {}
sets.Holy_Water = {}

-- Melee stance, keyed by state.OffenseMode. AM1-AM3 apply under Aftermath.
sets.OffenseMode = {}
sets.OffenseMode.AM = {}
sets.OffenseMode.AM1 = {}
sets.OffenseMode.AM2 = {}
sets.OffenseMode.AM3 = {}

sets.DualWield = {}

-- Precast: fast cast and ability openers.
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

-- Midcast: ranged attacks and enfeebles.
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

-- Midcast: magic by school.
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

-- Midcast: bard songs, keyed by song family.
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

-- Midcast under Aftermath.
sets.Midcast.AM = {}
sets.Midcast.RA.AM = {}
sets.Midcast.AM1 = {}
sets.Midcast.RA.AM1 = {}
sets.Midcast.AM2 = {}
sets.Midcast.RA.AM2 = {}
sets.Midcast.AM3 = {}
sets.Midcast.RA.AM3 = {}

-- Weaponskills. RA variants apply to ranged weaponskills.
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

-- Job abilities, pet actions and situational sets.
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


-- Bard instruments, selected by song family -------------------------------------------------------
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

-- Melee stance.

----------------------------------------------------------------------------------------------------
-- SECTION 3 - MODE DEFINITIONS
----------------------------------------------------------------------------------------------------
-- State variables cycled by keybind or by "gs c <mode>". Each is an M{} object from the
-- Modes library.
state.OffenseMode = M { ['description'] = 'Melee Mode' }
state.OffenseMode:options('TP', 'ACC', 'DT')
state.OffenseMode:set('TP')

-- Multibox spell-received gear. ON wears the received set the moment another local
-- character starts casting and holds those slots until the spell lands.
--those slots locked until the caster's spell completes, unlocking at completion
--or after the configured delay as a failsafe.
state.SpellReceived = M { ['description'] = "Spell-Received" }
state.SpellReceived:options('OFF', 'ON')
state.SpellReceived:set('ON')

-- Hoxne Ampulla. ON-Allow Critical lets songs, Geomancy, Tomahawk and Angon borrow
-- range or ammo; ON-Locked holds both slots outright.
state.Hoxne = M { ['description'] = 'Hoxne' }
state.Hoxne:options('OFF', 'ON-Allow Critical', 'ON-Locked')
state.Hoxne:set('OFF')

-- Automatic buff upkeep, driven by the job file check_buff hook.
state.AutoBuff = M { ['description'] = 'Auto Buff Mode' }
state.AutoBuff:options('OFF', 'ON')
state.AutoBuff:set('OFF')

-- Treasure Hunter. Thief gains the SATA option and defaults to full time.
state.TreasureMode = M { ['description'] = 'Treasure Mode' }
if player.main_job == "THF" then
    state.TreasureMode:options('None', 'Tag', 'Full Time', 'SATA')
    state.TreasureMode:set('Full Time')
else
    state.TreasureMode:options('None', 'Tag', 'Full Time')
    state.TreasureMode:set('None')
end

-- Weapon set selection.
state.WeaponMode = {}
state.WeaponMode = M { ['description'] = 'Weapon Specific Mode' }
state.WeaponMode:options('OFF', 'ON')
state.WeaponMode:set('OFF')

-- Two job-defined mode slots. Name them with UI_Name and UI_Name2 below.
state.JobMode = {}
state.JobMode = M { ['description'] = 'Job Specific Mode' }
state.JobMode:options('OFF', 'ON')
state.JobMode:set('OFF')

state.JobMode2 = {}
state.JobMode2 = M { ['description'] = 'Job Specific Mode' }
state.JobMode2:options('OFF', 'ON')
state.JobMode2:set('OFF')

-- Ammunition type for ranged attacks.
state.RAMode = {}
state.RAMode = M { ['description'] = 'Ranged Attack Mode' }
state.RAMode:options('Bullet', 'Arrow', 'Bolt')
state.RAMode:set('Bullet')

-- Set once the low-ammo warning has fired, so it warns only once per stack.
state.warned = M(false)


-- Ammunition --------------------------------------------------------------------------------------
-- Ammunition by type, keyed by state.OffenseMode.
Ammo = {}
Ammo.Bullet = {}
Ammo.Arrow = {}
Ammo.Bolt = {}

Ammo_Warning_Limit = 99

-- Job file options. Override these in the job file, not here.


----------------------------------------------------------------------------------------------------
-- SECTION 4 - JOB FILE OPTIONS
----------------------------------------------------------------------------------------------------
-- Simple toggles a job file may set.
is_Busy = false
AutoItem = false
Random_Lockstyle = false
Lockstyle_List = {}


----------------------------------------------------------------------------------------------------
-- SECTION 5 - ACTION CLASSIFICATION LISTS
----------------------------------------------------------------------------------------------------
-- Name lists that route an action to the right set. Membership decides which bucket a
-- spell, weaponskill or ready move falls into.
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
    'Geo-Poison', 'Geo-Precision', 'Geosettings.Dis-Refresh', 'Geo-Regen', 'Geo-Slip', 'Geo-Slow', 'Geo-Torpor',
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
Enfeeble_Duration = S { 'Sleep', 'Sleep II', 'Sleepga', 'Sleepga II', 'Diaga', 'Dia', 'Dia II', 'Dia III', 'Bio', 'Bio II', 'Bio III', 'Silence', 'Inundation', 'Break', 'Breakaga', 'Bind', 'Bind II' }

Dark_Acc = S { 'Death', 'Kaustra', 'Stun' }
Dark_Absorb = S { 'Absorb-ACC', 'Absorb-AGI', 'Absorb-Attri', 'Absorb-CHR', 'Absorb-DEX', 'Absorb-INT', 'Absorb-MND', 'Absorb-STR', 'Absorb-TP', 'Absorb-VIT', 'Aspir', 'Aspir II', 'Aspir III', 'Drain', 'Drain II', 'Drain III' }
Dark_Enhancing = S { 'Dread Spikes', 'Endark', 'Endark II', 'Klimaform', 'Tractor' }

Enhancing_Skill = S { 'Temper', 'Temper II', 'Enaero', 'Enstone', 'Enthunder', 'Enwater', 'Enfire', 'Enblizzard', 'Boost-STR', 'Boost-DEX', 'Boost-VIT', 'Boost-AGI', 'Boost-INT', 'Boost-MND', 'Boost-CHR' }
Divine_Skill = S { 'Enlight', 'Enlight II', 'Flash', 'Repose', 'Holy', 'Holy II', 'Banish', 'Banish II', 'Banish III', 'Banishga', 'Banishga II', }

-- Blue magic buckets. Each spell scales from different stats, so they are grouped by
-- what actually improves them rather than by element or school.
-- Physical: weapon accuracy, the stat modifier and attack. Magic attack does nothing.
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
-- Breath: HP and level only. INT, magic attack and Blue Magic Skill do nothing.
BlueBreath = S { 'Bad Breath', 'Flying Hip Press', 'Frost Breath', 'Heat Breath',
    'Hecatomb Wave', 'Magnetite Cloud', 'Poison Breath', 'Radiant Breath', 'Self-Destruct',
    'Thunder Breath', 'Vapor Spray', 'Wind Breath' }
-- Nuke: magic attack bonus and the per-spell stat modifier.
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
-- Skill: potency scales with Blue Magic Skill.
BlueSkill = S { 'Atra. Libations', 'Barrier Tusk', 'Diamondhide', 'Magic Barrier',
    'Metallic Body', 'Occultation', 'Plasma Charge', 'Pyric Bulwark', 'Reactor Cool' }
-- Buff: fixed potency, so only duration responds to gear.
BlueBuff = S { 'Amplification', 'Animating Wail', 'Battery Charge', 'Carcharian Verve',
    'Cocoon', 'Erratic Flutter', 'Exuviation', 'Fantod', 'Feather Barrier', 'Harden Shell',
    'Memento Mori', 'Mighty Guard', 'Nat. Meditation', 'O. Counterstance', 'Refueling',
    'Regeneration', 'Saline Coat', 'Triumphant Roar', 'Warm-Up', 'Winds of Promy.',
    'Zephyr Mantle' }
-- Healing: cure potency, MND and Blue Magic Skill. White Wind is deliberately absent -
-- it heals from max HP and ignores both skill and MND, so it uses its own named set.
BlueHealing = S { 'Healing Breeze', 'Magic Fruit', 'Plenilune Embrace', 'Pollen', 'Restoral',
    'Wild Carrot' }
-- Tank: enmity-generating enfeebles.
BlueTank = S { 'Actinic Burst', 'Blank Gaze', 'Demoralizing Roar', 'Frightful Roar',
    'Geist Wall', 'Jettatura', 'Sheep Song', 'Soporific', 'Stinking Gas' }
-- Accuracy: enfeebles and debuffs that want magic accuracy.
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

-- Long mode names used in chat messages. Leave empty to hide the mode entirely.

----------------------------------------------------------------------------------------------------
-- SECTION 6 - DISPLAY LABELS
----------------------------------------------------------------------------------------------------
-- Names shown in chat and on the status box for the two job-defined modes.
UI_Name = ''
UI_Name2 = ''

-- Optional three-letter labels for the status box. Leave empty and the include derives
-- one from UI_Name, so existing job files need no changes.
-- one from UI_Name, so existing job files need no changes.
UI_Short = ''
UI_Short2 = ''


-- Everything below is engine internals held in a single scope so job files cannot
-- reach it. Locals must be declared before first use; globals resolve at call time.
do
    ------------------------------------------------------------------------------------------------
    -- SECTION 7 - LIBRARIES AND USER SETTINGS
    ------------------------------------------------------------------------------------------------
    -- Windower libraries, the saved settings file, and the two on-screen text boxes.

    -- Windower libraries. config persists the settings file, res exposes the game's
    -- resource tables, socket supplies a millisecond clock shared across characters,
    -- and extdata decodes the per-item blob carrying enchantment charges and timers.
    local config = require('config')
    local res = require('resources')
    local socket = require('socket')
    local extdata = require('extdata')

    -- Defaults written to the settings file on first load, then merged with whatever
    -- the user has saved.
    local default = {
        visible = true,
        oneline = true,
        debug = false,
        info = true,
        warn = true,
        gear_reporting = false,
        Display_Box = { text = { size = 11, font = 'Consolas', red = 255, green = 255, blue = 255, alpha = 255, stroke = { width = 2, alpha = 255, red = 15, green = 15, blue = 15 } }, pos = { x = 0, y = 0 }, bg = { visible = true, red = 0, green = 0, blue = 0, alpha = 190 }, flags = { bold = true }, padding = 3 },
        Debug_Box = { text = { size = 11, font = 'Consolas', red = 255, green = 255, blue = 255, alpha = 255, stroke = { width = 2, alpha = 255, red = 15, green = 15, blue = 15 } }, pos = { x = 0, y = 50 }, bg = { visible = true, red = 0, green = 0, blue = 0, alpha = 190 }, flags = { bold = true }, padding = 3 },
        delay = 3,
    }

    -- The live settings table. Every toggle in this file reads and writes through it.
    local settings = config.load(default)

    -- Bind a text box to its saved position so dragging it persists. Called once per
    -- box immediately after creation.
    local function apply_box_settings(box, cfg)
        box:pos(cfg.pos.x, cfg.pos.y)
        box:font(cfg.text.font, unpack(cfg.text.fonts))
        box:size(cfg.text.size)
        box:color(cfg.text.red, cfg.text.green, cfg.text.blue)
        box:alpha(cfg.text.alpha)
        box:stroke_width(cfg.text.stroke.width)
        box:stroke_color(cfg.text.stroke.red, cfg.text.stroke.green, cfg.text.stroke.blue)
        box:stroke_alpha(cfg.text.stroke.alpha)
        box:bg_color(cfg.bg.red, cfg.bg.green, cfg.bg.blue)
        box:bg_alpha(cfg.bg.alpha)
        box:bg_visible(cfg.bg.visible)
        box:bold(cfg.flags.bold)
        box:italic(cfg.flags.italic)
        box:right_justified(cfg.flags.right)
        box:bottom_justified(cfg.flags.bottom)
        box:pad(cfg.padding)
    end

    -- The two on-screen boxes: the mode display and the debug readout.
    local gs_status = texts.new("", settings.Display_Box, settings)
    local gs_debug = texts.new("", settings.Debug_Box, settings)

    -- Restore each box's saved position, allow dragging only while shown, then honour
    -- its saved visibility.
    apply_box_settings(gs_status, settings.Display_Box)
    apply_box_settings(gs_debug, settings.Debug_Box)
    gs_status:draggable(settings.visible and true or false)
    gs_debug:draggable(settings.debug and true or false)
    if settings.visible then gs_status:show() end
    if settings.debug then gs_debug:show() end

    ------------------------------------------------------------------------------------------------
    -- SECTION 8 - SHARED CONSTANTS AND LOOKUP TABLES
    ------------------------------------------------------------------------------------------------
    -- Values used across more than one subsystem. Constants private to a single
    -- subsystem live with that subsystem instead.

    -- Action classification -----------------------------------------------------------------------

    -- Spell types carrying a recast timer. pretargetcheck() consults this before
    -- spending a get_spell_recasts() call.
    local HasRecastTimer = {
        ['WhiteMagic']   = true,
        ['BlackMagic']   = true,
        ['BlueMagic']    = true,
        ['Ninjutsu']     = true,
        ['BardSong']     = true,
        ['Geomancy']     = true,
        ['SummonerPact'] = true,
        ['Trust']        = true,
    }

    -- Spell types that additionally arm the post-cast busy window in precast() and
    -- aftercast().
    local RecastTimers = {
        ['WhiteMagic'] = true,
        ['BlackMagic'] = true,
        ['Ninjutsu']   = true,
        ['BardSong']   = true,
        ['Geomancy']   = true,
    }

    -- Interned buff ids and action-type strings. Reused rather than rebuilt so the hot
    -- comparison paths allocate nothing.
    local BUFF_SLEEP, BUFF_STUN, BUFF_KO = 'Sleep', 'Stun', 'KO'
    local BUFF_PETRI, BUFF_CHARM, BUFF_TERROR = 'Petrification', 'Charm', 'Terror'
    local TYPE_JA, TYPE_WS, TYPE_MS, TYPE_SCH = 'JobAbility', 'WeaponSkill', 'Magic', 'Scholar'

    -- Action categories that count as tagging a mob for Treasure Hunter.
    local TaggingCategories = S { 1, 2, 3, 4, 6, 11, 14 }

    -- Job, zone and element reference -------------------------------------------------------------

    -- Single-target storm spells, used to select the matching obi.
    local Storms = S { "Aurorastorm", "Voidstorm", "Firestorm", "Sandstorm", "Rainstorm", "Windstorm", "Hailstorm", "Thunderstorm",
        "Aurorastorm II", "Voidstorm II", "Firestorm II", "Sandstorm II", "Rainstorm II", "Windstorm II", "Hailstorm II", "Thunderstorm II" }

    -- Utsusemi variants, used by the shadow-count guard in do_Utsu_checks().
    local UtsusemiSpell = S { 'Utsusemi: Ichi', 'Utsusemi: Ni', 'Utsusemi: San' }

    -- Dynamis Divergence zones, where the neck slot stays locked.
    local Divergence_Zones = S { "Dynamis - San d'Oria [D]", "Dynamis - Bastok [D]", "Dynamis - Windurst [D]", "Dynamis - Jeuno [D]" }

    -- Jobs treated as mages when deciding to auto-use a Remedy.
    local Mage_Job = S { 'BLM', 'RDM', 'WHM', 'BRD', 'BLU', 'GEO', 'SCH', 'NIN', 'PLD', 'RUN', 'DRK', 'SMN' }

    -- City zones, where town gear and idle behaviour apply.
    local Cities = S { "Ru'Lude Gardens", "Upper Jeuno", "Lower Jeuno", "Port Jeuno", "Port Windurst", "Windurst Waters", "Windurst Woods", "Windurst Walls", "Heavens Tower", "Port San d'Oria", "Northern San d'Oria",
        "Southern San d'Oria", "Chateau d'Oraguille", "Port Bastok", "Bastok Markets", "Bastok Mines", "Metalworks", "Aht Urhgan Whitegate", "The Colosseum", "Tavnazian Safehold", "Nashmau", "Selbina",
        "Mhaura", "Rabao", "Norg", "Kazham", "Eastern Adoulin", "Western Adoulin", "Celennia Memorial Library", "Mog Garden", "Leafallia" }

    -- Buff names the cancel commands accept, keyed by the client's language.
    local Language = windower.ffxi.get_info().language:lower()

    -- Skillchain properties keyed by chain name, giving the element(s) run_burst()
    -- reports for magic burst timing.
    local skillchains = {
        [288] = { id = 288, english = 'Light', elements = { 'Light', 'Lightning', 'Wind', 'Fire' } },
        [289] = { id = 289, english = 'Darkness', elements = { 'Dark', 'Ice', 'Water', 'Earth' } },
        [290] = { id = 290, english = 'Gravitation', elements = { 'Dark', 'Earth' } },
        [291] = { id = 291, english = 'Fragmentation', elements = { 'Lightning', 'Wind' } },
        [292] = { id = 292, english = 'Distortion', elements = { 'Ice', 'Water' } },
        [293] = { id = 293, english = 'Fusion', elements = { 'Light', 'Fire' } },
        [294] = { id = 294, english = 'Compression', elements = { 'Dark' } },
        [295] = { id = 295, english = 'Liquefaction', elements = { 'Fire' } },
        [296] = { id = 296, english = 'Induration', elements = { 'Ice' } },
        [297] = { id = 297, english = 'Reverberation', elements = { 'Water' } },
        [298] = { id = 298, english = 'Transfixion', elements = { 'Light' } },
        [299] = { id = 299, english = 'Scission', elements = { 'Earth' } },
        [300] = { id = 300, english = 'Detonation', elements = { 'Wind' } },
        [301] = { id = 301, english = 'Impaction', elements = { 'Lightning' } },
        [385] = { id = 385, english = 'Light', elements = { 'Light', 'Lightning', 'Wind', 'Fire' } },
        [386] = { id = 386, english = 'Darkness', elements = { 'Dark', 'Ice', 'Water', 'Earth' } },
        [387] = { id = 387, english = 'Gravitation', elements = { 'Dark', 'Earth' } },
        [388] = { id = 388, english = 'Fragmentation', elements = { 'Lightning', 'Wind' } },
        [389] = { id = 389, english = 'Distortion', elements = { 'Ice', 'Water' } },
        [390] = { id = 390, english = 'Fusion', elements = { 'Light', 'Fire' } },
        [391] = { id = 391, english = 'Compression', elements = { 'Dark' } },
        [392] = { id = 392, english = 'Liquefaction', elements = { 'Fire' } },
        [393] = { id = 393, english = 'Induration', elements = { 'Ice' } },
        [394] = { id = 394, english = 'Reverberation', elements = { 'Water' } },
        [395] = { id = 395, english = 'Transfixion', elements = { 'Light' } },
        [396] = { id = 396, english = 'Scission', elements = { 'Earth' } },
        [397] = { id = 397, english = 'Detonation', elements = { 'Wind' } },
        [398] = { id = 398, english = 'Impaction', elements = { 'Lightning' } },
        [767] = { id = 767, english = 'Radiance', elements = { 'Light', 'Lightning', 'Wind', 'Fire' } },
        [768] = { id = 768, english = 'Umbra', elements = { 'Dark', 'Ice', 'Water', 'Earth' } },
        [769] = { id = 769, english = 'Radiance', elements = { 'Light', 'Lightning', 'Wind', 'Fire' } },
        [770] = { id = 770, english = 'Umbra', elements = { 'Dark', 'Ice', 'Water', 'Earth' } },
    }

    -- Action types with no midcast build: precast chooses their final gear, and
    -- midcastequip returns immediately for them.
    local PRECAST_FINAL = {
        WeaponSkill = true,
        JobAbility  = true,
        Item        = true,
        Scholar     = true,
        Ward        = true,
        Rune        = true,
        Effusion    = true,
        CorsairRoll = true,
        CorsairShot = true,
        Waltz       = true,
        Jig         = true,
        Samba       = true,
        Step        = true,
        Flourish1   = true,
        Flourish2   = true,
        Flourish3   = true,
    }

    -- Equipment slots -----------------------------------------------------------------------------

    -- Canonical slot names. Covers exactly the 27 keys GearSwap itself accepts
    -- (statics.lua:150-176), so merge_into() can never drop a key GearSwap would
    -- have taken.
    local CANON_SLOT = {
        main = 'main',
        sub = 'sub',
        range = 'range',
        ranged = 'range',
        ammo = 'ammo',
        head = 'head',
        body = 'body',
        hands = 'hands',
        legs = 'legs',
        feet = 'feet',
        neck = 'neck',
        waist = 'waist',
        back = 'back',
        ear1 = 'left_ear',
        ear2 = 'right_ear',
        lear = 'left_ear',
        rear = 'right_ear',
        learring = 'left_ear',
        rearring = 'right_ear',
        left_ear = 'left_ear',
        right_ear = 'right_ear',
        ring1 = 'left_ring',
        ring2 = 'right_ring',
        lring = 'left_ring',
        rring = 'right_ring',
        left_ring = 'left_ring',
        right_ring = 'right_ring',
    }

    ------------------------------------------------------------------------------------------------
    -- SECTION 9 - SPELL AND ABILITY DATA
    ------------------------------------------------------------------------------------------------
    -- Metadata driving the multibox spell-received gear system: which set an incoming
    -- action calls for, and whether it can land on more than one party member.

    -- Tracked spells. category selects the handler, equip names the set to wear, aoe
    -- marks inherently multi-target spells, and accession marks spells that become
    -- multi-target under Accession.
    local spell_info = {
        -- Cursna
        [20] = { name = "Cursna", category = 'track_cursna', equip = "cursna_set", aoe = false, majesty = false, accession = true, divine = true },                       --Cursna
        -- Phalanx
        [106] = { name = "Phalanx", category = 'track_phalanx', equip = "phalanx_set", aoe = false, majesty = false, accession = true, divine = false },                  --Phalanx
        [107] = { name = "Phalanx II", category = 'track_phalanx', equip = "phalanx_set", aoe = false, majesty = false, accession = false, divine = false },              --Phalanx II
        -- Regen
        [108] = { name = "Regen", category = 'track_regen', equip = "regen_set", aoe = false, majesty = false, accession = true, divine = false },                        --Regen
        [110] = { name = "Regen II", category = 'track_regen', equip = "regen_set", aoe = false, majesty = false, accession = true, divine = false },                     --Regen II
        [111] = { name = "Regen III", category = 'track_regen', equip = "regen_set", aoe = false, majesty = false, accession = true, divine = false },                    --Regen III
        [477] = { name = "Regen IV", category = 'track_regen', equip = "regen_set", aoe = false, majesty = false, accession = true, divine = false },                     --Regen IV
        [504] = { name = "Regen V", category = 'track_regen', equip = "regen_set", aoe = false, majesty = false, accession = true, divine = false },                      --Regen V
        -- Protect
        [43] = { name = "Protect", category = 'track_protect_shell', equip = "protect_shell_set", aoe = false, majesty = true, accession = true, divine = false },        --Protect
        [44] = { name = "Protect II", category = 'track_protect_shell', equip = "protect_shell_set", aoe = false, majesty = true, accession = true, divine = false },     --Protect II
        [45] = { name = "Protect III", category = 'track_protect_shell', equip = "protect_shell_set", aoe = false, majesty = true, accession = true, divine = false },    --Protect III
        [46] = { name = "Protect IV", category = 'track_protect_shell', equip = "protect_shell_set", aoe = false, majesty = true, accession = true, divine = false },     --Protect IV
        [47] = { name = "Protect V", category = 'track_protect_shell', equip = "protect_shell_set", aoe = false, majesty = true, accession = true, divine = false },      --Protect V
        [125] = { name = "Protectra", category = 'track_protect_shell', equip = "protect_shell_set", aoe = true, majesty = true, accession = false, divine = false },     --Protectra
        [126] = { name = "Protectra II", category = 'track_protect_shell', equip = "protect_shell_set", aoe = true, majesty = true, accession = false, divine = false },  --Protectra II
        [127] = { name = "Protectra III", category = 'track_protect_shell', equip = "protect_shell_set", aoe = true, majesty = true, accession = false, divine = false }, --Protectra III
        [128] = { name = "Protectra IV", category = 'track_protect_shell', equip = "protect_shell_set", aoe = true, majesty = true, accession = false, divine = false },  --Protectra IV
        [129] = { name = "Protectra V", category = 'track_protect_shell', equip = "protect_shell_set", aoe = true, majesty = true, accession = false, divine = false },   --Protectra V
        -- Shell
        [48] = { name = "Shell", category = 'track_protect_shell', equip = "protect_shell_set", aoe = false, majesty = false, accession = true, divine = false },         --Shell
        [49] = { name = "Shell II", category = 'track_protect_shell', equip = "protect_shell_set", aoe = false, majesty = false, accession = true, divine = false },      --Shell II
        [50] = { name = "Shell III", category = 'track_protect_shell', equip = "protect_shell_set", aoe = false, majesty = false, accession = true, divine = false },     --Shell III
        [51] = { name = "Shell IV", category = 'track_protect_shell', equip = "protect_shell_set", aoe = false, majesty = false, accession = true, divine = false },      --Shell IV
        [52] = { name = "Shell V", category = 'track_protect_shell', equip = "protect_shell_set", aoe = false, majesty = false, accession = true, divine = false },       --Shell V
        [130] = { name = "Shellra", category = 'track_protect_shell', equip = "protect_shell_set", aoe = true, majesty = false, accession = false, divine = false },      --Shellra
        [131] = { name = "Shellra II", category = 'track_protect_shell', equip = "protect_shell_set", aoe = true, majesty = false, accession = false, divine = false },   --Shellra II
        [132] = { name = "Shellra III", category = 'track_protect_shell', equip = "protect_shell_set", aoe = true, majesty = false, accession = false, divine = false },  --Shellra III
        [133] = { name = "Shellra IV", category = 'track_protect_shell', equip = "protect_shell_set", aoe = true, majesty = false, accession = false, divine = false },   --Shellra IV
        [134] = { name = "Shellra V", category = 'track_protect_shell', equip = "protect_shell_set", aoe = true, majesty = false, accession = false, divine = false },    --Shellra V
        -- Cure
        [1] = { name = "Cure", category = 'track_cure', equip = "cure_set", aoe = false, majesty = true, accession = true, divine = false },                              --Cure
        [2] = { name = "Cure II", category = 'track_cure', equip = "cure_set", aoe = false, majesty = true, accession = true, divine = false },                           --Cure II
        [3] = { name = "Cure III", category = 'track_cure', equip = "cure_set", aoe = false, majesty = true, accession = true, divine = false },                          --Cure III
        [4] = { name = "Cure IV", category = 'track_cure', equip = "cure_set", aoe = false, majesty = true, accession = true, divine = false },                           --Cure IV
        [5] = { name = "Cure V", category = 'track_cure', equip = "cure_set", aoe = false, majesty = true, accession = false, divine = false },                           --Cure V
        [6] = { name = "Cure VI", category = 'track_cure', equip = "cure_set", aoe = false, majesty = true, accession = false, divine = false },                          --Cure VI
        -- Curaga / Cura
        [7] = { name = "Curaga", category = 'track_cure', equip = "cure_set", aoe = true, majesty = false, accession = false, divine = false },                           --Curaga
        [8] = { name = "Curaga II", category = 'track_cure', equip = "cure_set", aoe = true, majesty = false, accession = false, divine = false },                        --Curaga II
        [9] = { name = "Curaga III", category = 'track_cure', equip = "cure_set", aoe = true, majesty = false, accession = false, divine = false },                       --Curaga III
        [10] = { name = "Curaga IV", category = 'track_cure', equip = "cure_set", aoe = true, majesty = false, accession = false, divine = false },                       --Curaga IV
        [11] = { name = "Curaga V", category = 'track_cure', equip = "cure_set", aoe = true, majesty = false, accession = false, divine = false },                        --Curaga V
        [93] = { name = "Cura", category = 'track_cure', equip = "cure_set", aoe = true, majesty = false, accession = false, divine = false },                            --Cura
        [474] = { name = "Cura II", category = 'track_cure', equip = "cure_set", aoe = true, majesty = false, accession = false, divine = false },                        --Cura II
        [475] = { name = "Cura III", category = 'track_cure', equip = "cure_set", aoe = true, majesty = false, accession = false, divine = false },                       --Cura III
        --Refresh
        [109] = { name = "Refresh", category = 'track_refresh', equip = "refresh_set", aoe = false, majesty = false, accession = true, divine = false },                  --Refresh
        [473] = { name = "Refresh II", category = 'track_refresh', equip = "refresh_set", aoe = false, majesty = false, accession = false, divine = false },              --Refresh II
        [894] = { name = "Refresh III", category = 'track_refresh', equip = "refresh_set", aoe = false, majesty = false, accession = false, divine = false },             --Refresh III
    }

    -- Tracked job abilities, same shape as spell_info above.
    local ability_info = {
        [190] = { name = "Curing Waltz", category = 'track_waltz', equip = "waltz_set", aoe = false, accession = false },     --Curing Waltz
        [191] = { name = "Curing Waltz II", category = 'track_waltz', equip = "waltz_set", aoe = false, accession = false },  --Curing Waltz II
        [192] = { name = "Curing Waltz III", category = 'track_waltz', equip = "waltz_set", aoe = false, accession = false }, --Curing Waltz III
        [193] = { name = "Curing Waltz IV", category = 'track_waltz', equip = "waltz_set", aoe = false, accession = false },  --Curing Waltz IV
        [311] = { name = "Curing Waltz V", category = 'track_waltz', equip = "waltz_set", aoe = false, accession = false },   --Curing Waltz V
        [195] = { name = "Divine Waltz", category = 'track_waltz', equip = "waltz_set", aoe = true, accession = false },      --Divine Waltz
        [262] = { name = "Divine Waltz II", category = 'track_waltz', equip = "waltz_set", aoe = true, accession = false },   --Divine Waltz II
    }

    ------------------------------------------------------------------------------------------------
    -- SECTION 10 - RUNTIME STATE
    ------------------------------------------------------------------------------------------------
    -- Mutable state shared between hooks and the polling engines. Subsystem-private
    -- state is declared with its subsystem.

    -- Combat, movement and timing -----------------------------------------------------------------

    -- Weapon traits refreshed on job or subjob change.
    local DualWield = false
    local TwoHand = false

    -- The post-cast busy window. precast() arms it, main_engine() expires it, and
    -- is_Busy gates the automation that must not fire mid-action.
    local SpellCastTime = 0
    local Spellstart = os.clock()

    -- Set by main_engine() from position deltas. Only ever true while disengaged.
    local is_moving = false

    -- Last skillchain observed, used by run_burst() to report burst windows.
    local last_skillchain_id = 0
    local last_skillchain_time = 0
    local last_skillchain_elements = {}

    -- main_engine() scheduling clocks: the 30 second housekeeping pass, the 2 second
    -- job-file Cycle_Timer, and the 0.1 second floor on the engine itself.
    local UpdateTime1 = os.clock()
    local UpdateTime2 = os.clock()
    local main_engine_time = os.clock()

    -- Last sampled position, compared each tick to detect movement.
    local Location = { x = 0, y = 0, z = 0 }

    -- Set when something changes that warrants a gear refresh; consumed by main_engine().
    local Require_Update = false

    -- Ammo remaining, recounted by do_bullet_checks().
    local available_bullets = 0

    -- Multibox spell-received tracking ------------------------------------------------------------

    -- State for the IPC gear system: whether we are the caster, which predictions are
    -- live, who is currently casting on us, and the failsafe that releases the
    -- borrowed gear if a completion message never arrives.
    local outgoing_cast_active = false
    local accession_predicted = false
    local divine_seal_predicted = false
    local active_incoming_casters = {}
    local cast_start_time = 0
    local failsafe_active = false
    local failsafe_trigger_time = 0

    -- Cached API handles --------------------------------------------------------------------------

    -- Windower API functions hoisted out of function scope. These are called from
    -- per-tick paths where the table lookups are worth avoiding.
    local ffxi = windower.ffxi
    local get_ability_recasts = ffxi.get_ability_recasts
    local get_spell_recasts = ffxi.get_spell_recasts
    local get_mob_by_id = ffxi.get_mob_by_id
    local get_mob_by_name = ffxi.get_mob_by_name
    local get_party = ffxi.get_party
    local send_ipc = windower.send_ipc_message

    -- Reused buffer for AoE party scans, so resolve_aoe_target_name() allocates nothing.
    local NEARBY_MEMBERS_BUFFER = {}

    -- Treasure Hunter -----------------------------------------------------------------------------

    -- Mobs tagged with TH, keyed by mob id and stamped with os.clock(). Entries are
    -- cleared on death, on zoning, and after three minutes of no activity.
    local th_info = {}
    th_info.tagged_mobs = T {}
    th_info.last_player_target_index = 0

    ------------------------------------------------------------------------------------------------
    -- SECTION 11 - CORE UTILITIES
    ------------------------------------------------------------------------------------------------
    -- Small helpers with no subsystem of their own.

    -- Chat output ---------------------------------------------------------------------------------

    -- Concatenate varargs into a single message, tolerating nil and non-string values.
    local function join(...)
        if select('#', ...) < 2 then return (...) end
        local parts = {}
        for i = 1, select('#', ...) do parts[i] = tostring((select(i, ...))) end
        return table.concat(parts)
    end

    -- The three user-facing channels, each gated by its own settings toggle: log for
    -- developer tracing, info for normal feedback, warn for problems.
    function log(...)
        if settings.debug then print(80, join(...)) end
    end

    function info(...)
        if settings.info then print(8, join(...)) end
    end

    function warn(...)
        if settings.warn then print(123, join(...)) end
    end

    -- The midcast gear-selection trace, in light blue. Off by default;
    -- 'gs c gearreporting'.
    function gear_report(...)
        if settings.gear_reporting then print(207, join(...)) end
    end

    -- Shared writer for the three channels above. Wraps long messages on word
    -- boundaries so the chat log never truncates mid-word.
    function print(mode, msg)
        if msg == nil then
            windower.add_to_chat(mode, 'Value is Nil')
        elseif type(msg) == "table" then
            for index, value in pairs(msg) do
                if type(value) == "table" then
                    for index2, value2 in pairs(value) do
                        if type(value2) == "table" then
                            for index3, value3 in pairs(value2) do
                                if type(value3) == "table" then
                                    for index4, value4 in pairs(value3) do
                                        windower.add_to_chat(mode,
                                            '---- [' ..
                                            tostring(index) ..
                                            '] [' ..
                                            tostring(index2) ..
                                            '] [' ..
                                            tostring(index3) .. '] [' ..
                                            tostring(index4) .. '] ' .. tostring(value4) .. ' ----')
                                    end
                                else
                                    windower.add_to_chat(mode,
                                        '---- [' ..
                                        tostring(index) ..
                                        '] [' ..
                                        tostring(index2) .. '] [' .. tostring(index3) .. '] ' ..
                                        tostring(value3) .. ' ----')
                                end
                            end
                        else
                            windower.add_to_chat(mode,
                                '---- [' .. tostring(index) .. '] [' .. tostring(index2) ..
                                '] ' .. tostring(value2) .. ' ----')
                        end
                    end
                else
                    windower.add_to_chat(mode, '---- [' .. tostring(index) .. '] ' .. tostring(value) .. ' ----')
                end
            end
        elseif type(msg) == "number" then
            windower.add_to_chat(mode, tostring(msg))
        elseif type(msg) == "string" then
            windower.add_to_chat(mode, msg)
        elseif type(msg) == "boolean" then
            windower.add_to_chat(mode, tostring(msg))
        else
            windower.add_to_chat(mode, 'Unknown Message')
        end
    end

    -- Timestamped debug output, shown only while debug mode is on.
    local function debug(message)
        if not settings.debug then return end
        windower.add_to_chat(121, "[Mirdain Debug] " .. message)
    end

    -- General helpers -----------------------------------------------------------------------------

    -- Millisecond wall clock. socket is required rather than os.clock() so that
    -- timestamps are comparable across separate game clients.
    local function get_time()
        return math.floor(socket.gettime() * 1000)
    end

    -- Count the entries in the top level of a table.
    local function count_keys(tbl)
        local count = 0
        for _ in pairs(tbl) do
            count = count + 1
        end
        return count
    end

    -- Round to a given number of decimal places.
    function round(num, numDecimalPlaces)
        if num ~= nil then
            local mult = 10 ^ (numDecimalPlaces or 0)
            return math.floor(num * mult + 0.5) / mult
        end
    end

    -- Return the item name a set assigns to a slot, or nil when the set does not
    -- touch it. Accepts both plain names and augmented item tables.
    local function get_slot_item_name(gear_set, slot)
        if not gear_set or not gear_set[slot] then
            return nil
        end

        local slot_data = gear_set[slot]

        if type(slot_data) == 'table' then
            return slot_data.name
        elseif type(slot_data) == 'string' then
            return slot_data
        end

        return nil
    end

    -- Party and target helpers --------------------------------------------------------------------

    -- Return true when the named character is currently in the player's party.
    local function is_target_in_party(target_name, party_info)
        if not target_name then return false end

        if not party_info then return false end

        for i = 0, 5 do
            local member = party_info['p' .. i]
            if member and member.name == target_name then
                return true
            end
        end

        return false
    end

    -- Expand an outgoing IPC target name into a comma-separated list of party members
    -- within AoE range, or return it unchanged when the spell cannot spread.
    local function resolve_aoe_target_name(target_mob, target_name)
        local party = get_party()
        if not (party and is_target_in_party(target_name, party)) then
            return target_name
        end

        local count = 0
        for k in pairs(NEARBY_MEMBERS_BUFFER) do NEARBY_MEMBERS_BUFFER[k] = nil end

        for slot, member in pairs(party) do
            if type(member) == 'table' and member.name then
                local m_mob = get_mob_by_name(member.name)
                if m_mob then
                    local dx = m_mob.x - target_mob.x
                    local dy = m_mob.y - target_mob.y
                    local dz = m_mob.z - target_mob.z
                    if ((dx * dx) + (dy * dy) + (dz * dz)) <= 100 then
                        if settings.debug then debug(member.name .. " is WITHIN 10 yalms of " .. target_mob.name) end
                        count = count + 1
                        NEARBY_MEMBERS_BUFFER[count] = member.name
                    else
                        if settings.debug then debug(member.name .. " is OUT of aoe range from " .. target_mob.name) end
                    end
                else
                    if settings.debug then debug(member.name .. " data unavailable (Too far away).") end
                end
            end
        end

        if count > 0 then
            return table.concat(NEARBY_MEMBERS_BUFFER, ",")
        end
        return target_name
    end

    -- Recast helpers ------------------------------------------------------------------------------

    -- Return how many Scholar stratagem charges are currently available.
    local function get_current_stratagem_count()
        local charge_cooldown = windower.ffxi.get_ability_recasts()[231] or 0

        local max_charges = 1
        local charge_regen_time = 240

        local sch_level = 0
        if player.main_job == 'SCH' then
            sch_level = player.main_job_level
        elseif player.sub_job == 'SCH' then
            sch_level = player.sub_job_level
        end

        if sch_level >= 90 then
            max_charges = 5
            charge_regen_time = 48
        elseif sch_level >= 70 then
            max_charges = 4
            charge_regen_time = 60
        elseif sch_level >= 50 then
            max_charges = 3
            charge_regen_time = 80
        elseif sch_level >= 30 then
            max_charges = 3
            charge_regen_time = 120
        elseif sch_level >= 10 then
            max_charges = 2
            charge_regen_time = 240
        end

        if charge_cooldown == 0 then return max_charges end

        local full_recharge_window = max_charges * charge_regen_time
        local current_charges = math.floor((full_recharge_window - charge_cooldown) / charge_regen_time)

        return math.max(0, current_charges)
    end

    ------------------------------------------------------------------------------------------------
    -- SECTION 12 - EQUIPMENT APPLICATION AND SLOT CONTROL
    ------------------------------------------------------------------------------------------------
    -- Everything that decides whether a gear request reaches the game: set merging,
    -- the Hoxne slot hold, and the lock and unlock helpers.

    -- Set merging ---------------------------------------------------------------------------------

    -- In-place equivalent of built_set = set_combine(built_set, layer). Avoids the
    -- table allocation set_combine performs on every call, which matters because the
    -- set builders below merge dozens of layers per action.
    local function merge_into(base, layer)
        if type(layer) ~= 'table' then return base end
        for slot, item in pairs(layer) do
            local canon = CANON_SLOT[slot] or (type(slot) == 'string' and CANON_SLOT[slot:lower()])
            if canon then base[canon] = item end
        end
        return base
    end

    -- Set diagnostics -----------------------------------------------------------------------------

    -- The section 2 placeholders, keyed by table identity, recorded before the job
    -- file declares anything. A gearless set still keyed here was never declared; a
    -- gearless set not keyed here was declared and left empty. PLACEHOLDER_LIST
    -- keeps the same names in parent-first order.
    local PLACEHOLDER_NAME = {}
    local PLACEHOLDER_LIST = {}
    do
        local function record(tbl, name)
            PLACEHOLDER_NAME[tbl] = name
            PLACEHOLDER_LIST[#PLACEHOLDER_LIST + 1] = name
            for k, v in pairs(tbl) do
                if type(v) == 'table' then record(v, name .. '.' .. tostring(k)) end
            end
        end
        record(sets, 'sets')
        record(Instrument, 'Instrument')
    end

    -- Job files replace whole parents (sets.Midcast = { ... }), which removes every
    -- engine placeholder beneath them. Re-create any placeholder path the job file
    -- dropped, so the merge guards see the tree section 2 promised. Runs once, on
    -- the first set build after a load.
    local placeholders_ensured = false
    local function ensure_placeholders()
        if placeholders_ensured then return end
        placeholders_ensured = true
        local created = false
        for i = 1, #PLACEHOLDER_LIST do
            local name = PLACEHOLDER_LIST[i]
            local segs = {}
            for seg in name:gmatch('[^%.]+') do segs[#segs + 1] = seg end
            if #segs >= 2 then
                local node = segs[1] == 'sets' and sets or segs[1] == 'Instrument' and Instrument
                for j = 2, #segs - 1 do
                    node = type(node) == 'table' and node[segs[j]] or nil
                end
                if type(node) == 'table' and node[segs[#segs]] == nil then
                    local fresh = {}
                    node[segs[#segs]] = fresh
                    PLACEHOLDER_NAME[fresh] = name
                    created = true
                end
            end
        end
        if created then invalidate_set_index() end
    end

    -- True when a set table carries at least one wearable slot key.
    local function set_has_gear(t)
        for slot in pairs(t) do
            if CANON_SLOT[slot] or (type(slot) == 'string' and CANON_SLOT[slot:lower()]) then
                return true
            end
        end
        return false
    end

    -- Walk every set reachable from the gear-set roots and classify it: carrying
    -- gear, declared but [Empty], or an untouched engine placeholder. Returns the
    -- three name lists, sorted. Slot values are gear, not sets, and are not entered;
    -- a declared gearless table that only holds child sets is structure, not a set,
    -- and is not reported.
    function set_diagnostics()
        ensure_placeholders()
        local gear, empty, undeclared = {}, {}, {}
        local seen = {}
        local function visit(t, name)
            if seen[t] then return end
            seen[t] = true
            if set_has_gear(t) then
                gear[#gear + 1] = name
            elseif PLACEHOLDER_NAME[t] then
                undeclared[#undeclared + 1] = name
            elseif next(t) == nil then
                empty[#empty + 1] = name
            end
            for k, v in pairs(t) do
                if type(v) == 'table'
                    and not (CANON_SLOT[k] or (type(k) == 'string' and CANON_SLOT[k:lower()])) then
                    visit(v, name .. '.' .. tostring(k))
                end
            end
        end
        for k, v in pairs(sets) do
            if type(v) == 'table' then visit(v, 'sets.' .. tostring(k)) end
        end
        for k, v in pairs(Instrument) do
            if type(v) == 'table' then visit(v, 'Instrument.' .. tostring(k)) end
        end
        table.sort(gear)
        table.sort(empty)
        table.sort(undeclared)
        return gear, empty, undeclared
    end

    -- Empty-set warnings, throttled per set ---------------------------------------------------------

    -- Each set warns at most once per window and reports what it held back.
    -- Must stay above warn_if_empty, which routes through it.
    local SET_WARN_WINDOW = 60
    local set_warn_until, set_warn_held = {}, {}
    local set_warn_hinted = false

    -- Forget the throttle, so the next use of every set reports again.
    local function reset_set_warnings()
        set_warn_until, set_warn_held = {}, {}
        set_warn_hinted = false
    end

    -- Warn that a chosen set wore nothing, naming whether it was never declared
    -- or declared and left empty. Silent while that set's window is open.
    local function warn_empty_set(name, undeclared)
        local now = os.clock()
        if (set_warn_until[name] or 0) > now then
            set_warn_held[name] = (set_warn_held[name] or 0) + 1
            return
        end
        set_warn_until[name] = now + SET_WARN_WINDOW

        local msg = '[' .. name .. (undeclared and '] not found!' or '] is empty!')
        -- The trace hint is worth saying once a load, not on every warning.
        if not set_warn_hinted then
            set_warn_hinted = true
            msg = msg .. '  Use gs c gearreporting to trace fallback pattern.'
        end
        local held = set_warn_held[name]
        set_warn_held[name] = nil
        if held then
            msg = msg .. ('  Silencing warnings for %ds (%d silenced since the last).')
                :format(SET_WARN_WINDOW, held)
        else
            msg = msg .. ('  Silencing warnings for %ds.'):format(SET_WARN_WINDOW)
        end
        warn(msg)
    end

    -- Warn when a set about to be worn carries no gear, naming it and whether it was
    -- never declared or declared empty. Returns true when the set was empty, whether
    -- or not the throttle let anything print.
    local function warn_if_empty(t, name)
        if type(t) ~= 'table' or set_has_gear(t) then return false end
        warn_empty_set(name, PLACEHOLDER_NAME[t] ~= nil)
        return true
    end

    -- Identity to dotted name for every set in the live tree, built on first use
    -- and discarded when a job file loads. A table not in the index is an inline
    -- literal a builder merged, and misses in constant time.
    local SET_NAME

    local function build_set_index()
        SET_NAME = {}
        local seen = {}
        local function visit(t, name)
            if seen[t] then return end
            seen[t] = true
            SET_NAME[t] = name
            for k, v in pairs(t) do
                if type(v) == 'table'
                    and not (CANON_SLOT[k] or (type(k) == 'string' and CANON_SLOT[k:lower()])) then
                    visit(v, name .. '.' .. tostring(k))
                end
            end
        end
        visit(sets, 'sets')
        visit(Instrument, 'Instrument')
    end

    -- Discard the cached index, forcing a rebuild on the next lookup. Called when
    -- a job file loads, and by gs c checksets as a manual refresh.
    function invalidate_set_index() SET_NAME = nil end

    -- Recover a set's dotted name. Warn and trace paths only.
    local function set_name_of(t)
        if not SET_NAME then build_set_index() end
        return SET_NAME[t]
    end

    -- merge_into plus fallback-path tracking. Each build records every merged set in
    -- order, bracketed by two marks that separate the base layers, the chosen-set
    -- branch, and the trailing merges. The flush reads the branch's path.
    local mr_history, mr_count, mr_mark, mr_branch_end = {}, 0, 0, nil

    -- Reset the tracking. Builders call this once at entry.
    local function merge_report_begin()
        mr_count, mr_mark, mr_branch_end = 0, 0, nil
    end

    -- End of the base layers; the spell-type branch merges from here on.
    local function merge_report_mark()
        mr_mark = mr_count
    end

    -- End of the spell-type branch; weapon holds and instruments follow.
    local function merge_report_branch_end()
        mr_branch_end = mr_count
    end

    local function merge_report(base, layer)
        if type(layer) == 'table' then
            mr_count = mr_count + 1
            mr_history[mr_count] = layer
        end
        return merge_into(base, layer)
    end

    -- Name a merged layer. Engine placeholders are named from the include-time
    -- record; everything else is recovered from the live tree.
    local function mr_name(t)
        return PLACEHOLDER_NAME[t] or set_name_of(t)
    end

    -- Report the finished build; the precast, midcast and aftercast hooks each
    -- call this after theirs. warn() and info() speak only for the phase that
    -- chose the action's final gear, gear_report() for every phase.
    local function merge_report_flush(phase, spell)
        local mark, last = mr_mark, mr_branch_end or mr_count
        mr_count, mr_mark, mr_branch_end = 0, 0, nil

        -- Warnings and the info summary belong to the phase that chose the
        -- action's final gear: midcast for spells, precast for abilities, items
        -- and weaponskills. The trace covers every phase.
        local final_phase = phase == nil or phase == 'midcast'
            or (phase == 'precast' and spell ~= nil and PRECAST_FINAL[spell.type] ~= nil)
        local can_warn = final_phase and settings.warn
        local can_info = final_phase and settings.info
        -- Nothing can be printed: skip the naming work entirely.
        if not can_warn and not can_info and not settings.gear_reporting then return end
        local label = phase == 'precast' and 'Precast: '
            or phase == 'aftercast' and 'Aftercast: ' or ''

        -- The set the branch chose: the most specific nameable layer it merged.
        -- Inline literals are unnameable and are stepped over.
        local i, head, name = last, nil, nil
        while i > mark do
            name = mr_name(mr_history[i])
            if name then
                head = mr_history[i]
                break
            end
            i = i - 1
        end
        if not head then return end

        -- The build wore the set it reached for: name it as the one it used.
        if set_has_gear(head) then
            if can_info then info('[' .. name .. '][Used]') end
            if settings.gear_reporting then
                gear_report(label .. 'Using ' .. name .. ' [Filled]')
            end
            return
        end

        -- The chosen set wore nothing. Name it, distinguishing a set that does
        -- not exist from one the job file declared and left empty.
        if can_warn then warn_empty_set(name, PLACEHOLDER_NAME[head] ~= nil) end

        -- Both remaining outputs need the walk; stop when neither can print.
        if not settings.gear_reporting and not can_info then return end

        -- Gearless: one step per layer the branch fell through, ending on the gear
        -- that covered. Base layers can only be that ending.
        local steps = { 'Attempted to use ' .. name .. ' [Empty]' }
        local covered, cover_name = false, nil
        i = i - 1
        while i > 0 do
            local t = mr_history[i]
            local n = mr_name(t)
            if set_has_gear(t) then
                if n then steps[#steps + 1] = 'Using ' .. n .. ' [Filled]' end
                covered, cover_name = true, n
                break
            end
            if i > mark and n then
                steps[#steps + 1] = 'Attempted to use ' .. n .. ' [Empty]'
            end
            i = i - 1
        end
        if not covered then steps[#steps + 1] = 'nothing to equip.' end

        -- The compressed fallback: intended set and final cover only.
        if can_info then
            if covered then
                info('[' .. name .. '][Not Usable] -> [' .. (cover_name or 'unnamed set') .. '][Used]')
            else
                info('[' .. name .. '][Not Usable] -> nothing to equip.')
            end
        end
        if settings.gear_reporting then
            gear_report(label .. table.concat(steps, ' falling back -> '))
        end
    end

    -- Hoxne Ampulla slot hold ---------------------------------------------------------------------

    -- The item this mode holds, and the buff id that proves its enchantment is active.
    local HOXNE_AMPULLA = 'Hoxne Ampulla'
    local BUFF_ENCHANTMENT = 162 -- res.buffs[162] = "enchantment"

    -- Mode state. window marks an open critical window, slot names the slot it
    -- borrowed, expires is its deadline, next_check and recheck_at pace the tick,
    -- and use_not_before blocks a use attempt during the equip delay.
    local hoxne = {
        window         = false, -- a critical action currently owns one slot
        slot           = nil,   -- which slot it borrowed ('range' or 'ammo')
        expires        = 0,     -- os.clock() deadline for that window
        resume         = nil,   -- 'aftercast' | 'delay'
        next_check     = 0,     -- os.clock() gate for hoxne_tick (always 1s)
        recheck_at     = 0,     -- os.clock() before which the bags are not re-scanned
        use_not_before = 0,     -- os.clock() before which no /item may be attempted
        release_tries  = 0,     -- remaining attempts to free a stranded Ampulla
        release_next   = 0,     -- os.clock() gate between those attempts
    }

    -- Ampulla equip delay (5s) plus the server activation latency and a margin. Also
    -- covers the moment after our own equip when extdata still reports the previous
    -- activation_time.
    local HOXNE_EQUIP_LOCKOUT = 9

    -- True in either ON mode.
    local function hoxne_on() return state.Hoxne.value ~= 'OFF' end

    -- ON-Allow Critical holds range and ammo by stripping them from equip requests, not
    -- by disable(), which would make the gear-gated songs uncastable. ON-Locked uses a
    -- real disable().
    --
    -- gs_equip is GearSwap's original equip, for paths that must bypass the filter. It
    -- must stay immediately above the override below.
    local gs_equip = equip
    function equip(...)
        if state.Hoxne.value ~= 'ON-Allow Critical' or hoxne.window then
            return gs_equip(...)
        end
        local n = select('#', ...)
        local args = { ... }
        for i = 1, n do
            local set = args[i]
            if type(set) == 'table' then
                local cleaned
                for k in pairs(set) do
                    local canon = type(k) == 'string' and CANON_SLOT[k:lower()]
                    if canon == 'range' or canon == 'ammo' then
                        if not cleaned then
                            cleaned = {}
                            for k2, v2 in pairs(set) do cleaned[k2] = v2 end
                        end
                        cleaned[k] = nil
                    end
                end
                if cleaned then args[i] = cleaned end
            end
        end
        return gs_equip(unpack(args, 1, n))
    end

    -- Only ON-Locked places slots in disable_table, so only ON-Locked needs protection
    -- from a blanket enable.
    function hoxne_owns_slot(slot)
        if state.Hoxne.value ~= 'ON-Locked' then return false end
        local s = (slot == 'ranged') and 'range' or slot
        return s == 'range' or s == 'ammo'
    end

    -- Slot locking --------------------------------------------------------------------------------

    -- Release every slot. Reached only from 'gs c enableall', the manual recovery
    -- command, so it deliberately ignores the Hoxne hold; hoxne_tick() re-asserts it
    -- within a second.
    function Unlock()
        log('Unlock Called')
        enable('main', 'sub', 'range', 'ammo', 'head', 'neck', 'ear1', 'ear2', 'body', 'hands', 'ring1', 'ring2', 'waist',
            'legs', 'feet', 'back')
        equip_set_command()
    end

    -- Enable a list of slots, skipping any the Hoxne mode is currently holding.
    local function enable_except_held(slots)
        local list = {}
        for _, s in ipairs(slots) do
            if not hoxne_owns_slot(s) then list[#list + 1] = s end
        end
        if #list > 0 then enable(unpack(list)) end
    end

    -- Release the slots the current mode and zone allow. Fires on zone change, on Doom
    -- or Sleep wearing off, and on every item completion, so it must respect the
    -- Hoxne hold.
    function UnlockByMode()
        log('Unlock By Mode Called')
        local slots = { 'main', 'sub', 'range', 'ammo', 'head', 'ear1', 'ear2', 'body',
            'hands', 'ring1', 'ring2', 'waist', 'legs', 'feet', 'back' }
        if not Divergence_Zones:contains(world.area) then
            -- Only unlock neck if not in divergence zone.
            slots[#slots + 1] = 'neck'
        end
        enable_except_held(slots)
    end

    -- Lock every slot.
    function Lock()
        log('Lock Called')
        disable('main', 'sub', 'range', 'ammo', 'head', 'neck', 'ear1', 'ear2', 'body', 'hands', 'ring1', 'ring2',
            'waist',
            'legs', 'feet', 'back')
    end

    ------------------------------------------------------------------------------------------------
    -- SECTION 13 - ENCHANTED ITEM ENGINE
    ------------------------------------------------------------------------------------------------
    -- Equipping and using enchanted gear from 'gs c use', 'gs c warp' and friends.
    -- One state machine advanced by a single prerender driver: no coroutines, so two
    -- uses cannot overlap and nothing survives a //gs reload.

    -- Constants -----------------------------------------------------------------------------------

    -- Resource slot id to GearSwap slot name. Matches GearSwap's default_slot_map
    -- (statics.lua:97-99), which is how player.equipment is keyed.
    local ENCH_SLOT_NAMES = {
        [0] = 'main',
        [1] = 'sub',
        [2] = 'range',
        [3] = 'ammo',
        [4] = 'head',
        [5] = 'body',
        [6] = 'hands',
        [7] = 'legs',
        [8] = 'feet',
        [9] = 'neck',
        [10] = 'waist',
        [11] = 'left_ear',
        [12] = 'right_ear',
        [13] = 'left_ring',
        [14] = 'right_ring',
        [15] = 'back',
    }

    -- Bags that can hold equippable gear: inventory, then wardrobes 1 through 8.
    local ENCH_BAGS = { 0, 8, 10, 11, 12, 13, 14, 15, 16 }

    -- extdata decodes enchantment timestamps against 2001-12-31 10:00 UTC
    -- (extdata.lua:1181), but the server's epoch is midnight 2002-01-01 JST. Every
    -- decoded timestamp therefore lands 18000 seconds early, which hides any cooldown
    -- shorter than five hours. This correction restores them.
    local EXTDATA_TS_CORRECTION = 18000

    -- The server refuses a use for roughly three seconds past the listed equip delay
    -- or recast boundary. Empirical; the wikis document only the listed delay.
    local ENCH_ACTIVATION_BUFFER = 3

    -- Item lookup ---------------------------------------------------------------------------------

    -- Lowercased name to resource row, built once on first use. Self commands arrive
    -- lowercased, but many items carry a mixed-case log name, so both fields are
    -- indexed. 'en' is indexed first so a real item name is never shadowed by another
    -- item's log name.
    local ench_index
    local function build_ench_index()
        ench_index = {}
        local function usable(row)
            return row.cast_delay and row.targets and row.targets:contains('Self')
        end
        for _, row in pairs(res.items) do
            if usable(row) then
                local k = row.en:lower()
                ench_index[k] = ench_index[k] or row
            end
        end
        for _, row in pairs(res.items) do
            if usable(row) and row.enl then
                local k = row.enl:lower()
                ench_index[k] = ench_index[k] or row
            end
        end
    end

    -- Locate an item and read its enchantment data. Returns the resource row, decoded
    -- extdata, whether it is carried, and whether that copy is currently worn.
    local function find_enchantment(name)
        if not ench_index then build_ench_index() end
        local row = ench_index[tostring(name):lower():trim()]
        if not row then return nil, nil, false end
        for _, bag_id in ipairs(ENCH_BAGS) do
            local bag = windower.ffxi.get_items(bag_id)
            if bag then
                for _, it in ipairs(bag) do
                    if type(it) == 'table' and it.id == row.id then
                        local ok, ext = pcall(extdata.decode, it)
                        -- status == 5 marks the bag copy of a currently worn
                        -- item - the same field GearSwap's own equip pipeline
                        -- trusts (equip_processing.lua:139).
                        return row, (ok and ext) or nil, true, (it.status == 5)
                    end
                end
            end
        end
        return row, nil, false
    end

    -- Timing and warnings -------------------------------------------------------------------------

    -- Return the two waits that gate a use, in seconds. They are separate because they
    -- call for opposite responses: a recast cannot be waited out while worn and is
    -- worth refusing a command for, whereas an equip delay only needs a few more
    -- seconds and should pass silently.
    local function enchantment_waits(ext)
        if not ext then return nil, nil end
        local now_t = os.time() - EXTDATA_TS_CORRECTION
        local recast, activation = 0, 0
        if ext.next_use_time then
            recast = (ext.next_use_time - now_t) + ENCH_ACTIVATION_BUFFER
        end
        if ext.activation_time then
            activation = (ext.activation_time - now_t) + ENCH_ACTIVATION_BUFFER
        end
        if recast < 0 then recast = 0 end
        if activation < 0 then activation = 0 end
        -- Clocks say ready but the item disagrees: trust the flag, and treat the
        -- unknown as an equip delay rather than a cooldown.
        if recast == 0 and activation == 0 and ext.usable == false then
            activation = 5
        end
        return recast, activation
    end

    -- Cooldown warnings are throttled per item until it is actually back, which keeps
    -- the Hoxne tick from repeating itself once a second. Pass always for a typed
    -- command: those answer every time and leave the throttle untouched, so neither
    -- path can silence the other.
    local ench_warned = {}
    local function warn_unavailable(row, wait, always)
        if not always then
            local ready_at = os.time() + math.ceil(wait)
            if (ench_warned[row.id] or 0) >= ready_at then return end
            ench_warned[row.id] = ready_at
        end
        if wait >= 3600 then
            info(('%s is on cooldown [%dh %dm].'):format(
                row.en, math.floor(wait / 3600), math.floor(wait % 3600 / 60)))
        else
            info(('%s is on cooldown [%d:%02d].'):format(
                row.en, math.floor(wait / 60), math.floor(wait % 60)))
        end
    end

    -- Use state machine ---------------------------------------------------------------------------

    -- The item currently being used, or nil. Only use_enchantment() sets this.
    local ench_active = nil
    local ench_next_check = 0

    -- Release the slot and restore normal gear. Skips the enable when Hoxne is holding
    -- that slot.
    local function finish_enchantment()
        local st = ench_active
        ench_active = nil
        if not st then return end
        if not hoxne_owns_slot(st.slot) then enable(st.slot) end
        equip_set_command()
    end

    -- Abort the running use and hand the slot back. Returns the item name and whether
    -- its /item had already been sent, or nil when the engine was idle.
    local function cancel_enchantment()
        local st = ench_active
        if not st then return nil end
        local name, sent = st.name, (st.phase == 'sent')
        finish_enchantment()
        return name, sent
    end

    -- Called from the action event. The item-finished packet is generic and fires for
    -- food and medicines too, so it only counts once our own use has been sent.
    function enchantment_completed()
        if ench_active and ench_active.phase == 'sent' then finish_enchantment() end
    end

    -- Advance the state machine. Driven from prerender, so it never calls equip()
    -- directly: equip() from a raw handler is discarded when the next wrapped event
    -- clears equip_list (flow.lua:60). Repairs route through 'gs c enchrepair'.
    local function enchantment_tick(now)
        local st = ench_active
        if not st or now < st.next_step then return end

        if now > st.deadline then
            if st.phase == 'sent' then
                warn(st.name .. ': use was not accepted - most likely still on cooldown. Releasing.')
            else
                warn(st.name .. ': timed out, releasing lock.')
            end
            finish_enchantment()
            return
        end

        if st.phase == 'sent' then
            st.next_step = now + 1
            return
        end

        if is_moving or midaction() or pet_midaction() then
            st.next_step = now + 1
            return
        end

        local held = now - st.equipped_at
        if held < st.cast_delay then
            st.next_step = now + (st.cast_delay - held) + 0.5
            return
        end

        -- One bag walk answers presence, equipped state and the enchantment timers
        -- together.  player.equipment must not be used for the equipped check here:
        -- it refreshes only when a wrapped GearSwap event begins (flow.lua:59), so
        -- in this raw handler it lags the engine's own equip.
        local row, ext, carried, equipped = find_enchantment(st.name)

        -- Something genuinely took the slot (in-game /equipset, or the game
        -- clearing ammo).  The re-equip routes through self_command because
        -- equip() from raw context is discarded (flow.lua:60).
        if not equipped then
            st.attempts = st.attempts + 1
            if st.attempts > 3 then
                warn(st.name .. ': could not keep it equipped in ' .. st.slot .. '.')
                finish_enchantment()
                return
            end
            windower.send_command('gs c enchrepair')
            st.equipped_at = now
            st.next_step = now + st.cast_delay + ENCH_ACTIVATION_BUFFER + 1
            return
        end

        local recast, activation = enchantment_waits(ext)
        recast, activation = recast or 0, activation or 0
        if recast > 0 then
            -- A genuine cooldown discovered after we already equipped.  Short
            -- ones are worth waiting out; long ones are not.
            if recast < 15 then
                st.next_step = now + recast + 0.5
            else
                -- Still the user's gs c use command (ench_active is only ever
                -- set by use_enchantment), so answer unconditionally here too.
                warn_unavailable(row, recast, true)
                finish_enchantment()
            end
            return
        end
        if activation > 0 then
            -- Equip delay only: wait silently, however long it takes.
            st.next_step = now + activation + 0.5
            return
        end

        log('/item "', st.name, '" <me>')
        windower.chat.input('/item "' .. st.name .. '" <me>')
        st.phase = 'sent'
        st.next_step = now + 1
        -- enchantment_completed() closes this out when the server accepts. A silent
        -- rejection never arrives, so release after cast_time plus a margin.
        st.deadline = now + st.cast_time + 4
    end

    -- Equip an enchanted item and use it. Guards run in order of cost: name, carried,
    -- equippable, engine idle, then cooldown.
    function use_enchantment(item)
        local row, ext, carried = find_enchantment(item)
        if not row then
            info('Unknown enchanted item: [' .. tostring(item) .. ']')
            return
        end
        local i_name = row.en
        if not carried then
            info(i_name .. ': not found in inventory or wardrobes.')
            return
        end

        -- Reject unequippable items up front with a specific reason, instead of
        -- letting the state machine time out. Mirrors GearSwap own equip checks.
        local job_level = (player.jobs and player.jobs[player.main_job]) or player.main_job_level
        if row.jobs and not row.jobs[player.main_job_id] then
            info(i_name .. ' cannot be worn by this job.')
            return
        elseif row.level and job_level and row.level > job_level then
            info(('%s requires level %d; your %s is %d.'):format(
                i_name, row.level, tostring(player.main_job), job_level))
            return
        elseif row.races and not row.races[player.race_id] then
            info(i_name .. ' cannot be worn by your race.')
            return
        elseif not row.slots then
            info(i_name .. ' cannot be worn.')
            return
        end

        -- Re-issuing the item already running is not an override: a restart would reset
        -- its equip delay, so repeating the command would only push the use further out.
        if ench_active and ench_active.id == row.id then
            info(i_name .. ' is already in progress.')
            return
        end

        -- Only a genuine cooldown refuses the command.  An equip delay is not
        -- a failure - equipping and waiting it out is precisely what this
        -- function exists to do, so it is ignored here and handled by the tick.
        local recast = enchantment_waits(ext)
        if recast and recast > 0 then
            warn_unavailable(row, recast, true) -- user asked; always answer
            return
        end

        -- Prefer the slot the item already occupies. Rings list both slots and
        -- pairs() order is undefined, so the choice must be made deliberately.
        local slot, first
        for id = 0, 15 do
            if row.slots:contains(id) then
                local name = ENCH_SLOT_NAMES[id]
                first = first or name
                if player.equipment[name] == i_name then
                    slot = name
                    break
                end
            end
        end
        slot = slot or first
        -- The guard above rejects a nil slots field; this catches the rarer
        -- case of a slots set that exists but is empty.
        if not slot then
            info('No equippable slot for [' .. i_name .. '].')
            return
        end

        -- A different item supersedes whatever is running. Sits below every guard above,
        -- so a command that is about to be refused never disturbs a use already running.
        local prev, prev_sent = cancel_enchantment()
        if prev then
            if prev_sent then
                warn(prev .. ': already sent and cannot be recalled; move to interrupt it.')
            else
                info('Cancelled [' .. prev .. '].')
            end
        end

        info('Equipping and using [' .. i_name .. ']')

        local cd, ct = row.cast_delay or 5, row.cast_time or 1
        local now = os.clock()
        ench_active = {
            name        = i_name,
            id          = row.id,
            slot        = slot,
            cast_delay  = cd,
            cast_time   = ct,
            equipped_at = now,
            attempts    = 0,
            phase       = 'waiting',
            -- The +1 past the buffer is empirical.
            next_step   = now + cd + ENCH_ACTIVATION_BUFFER + 1,
            deadline    = now + cd + ct + 12,
        }

        -- gs_equip: the engine manages its own slot, so the Hoxne data-filter
        -- must not strip an ammo or range enchantment the user asked for.
        enable(slot)
        gs_equip({ [slot] = i_name })
        disable(slot)
        log('use_enchantment: ', i_name, ' -> ', slot)
    end

    ------------------------------------------------------------------------------------------------
    -- SECTION 14 - HOXNE AMPULLA AUTOMATION
    ------------------------------------------------------------------------------------------------
    -- Keeping the Ampulla worn and used while a Hoxne mode is on, and opening a
    -- critical window when an action genuinely needs range or ammo.

    -- Actions allowed to borrow a slot in ON-Allow Critical. Job abilities are keyed by
    -- ability id, everything else by spell type. Angon (18259) and Thr. Tomahawk
    -- (18258) occupy ammo; instruments and handbells occupy range. Songs and Geomancy
    -- resume after a refreshing delay because they are normally cast in waves.
    local CRITICAL_JA = {
        [150] = { slot = 'ammo', force = 'Thr. Tomahawk', item_id = 18258, resume = 'aftercast' },
        [170] = { slot = 'ammo', force = 'Angon', item_id = 18259, resume = 'aftercast' },
    }
    local CRITICAL_TYPE = {
        ['BardSong'] = { slot = 'range', resume = 'delay', delay = 5 },
        ['Geomancy'] = { slot = 'range', resume = 'delay', delay = 5 },
    }

    -- Return the critical-action entry for a spell or ability, or nil.
    function critical_action_for(spell)
        if not spell then return nil end
        if spell.type == TYPE_JA then return CRITICAL_JA[spell.id] end
        return CRITICAL_TYPE[spell.type]
    end

    -- A gated /ja waiting for its throwing item's equip to be confirmed, or nil.
    local gated_ja = nil

    -- Fire the pending ability the moment the item's bag copy reports worn. The bag
    -- status is live server state - exactly what the client checks a typed /ja
    -- against - so this fires one round trip after the equip, not on a fixed timer.
    local function gated_ja_tick(now)
        local st = gated_ja
        if now > st.deadline then
            gated_ja = nil
            warn(st.item_name .. ' never equipped. ' .. st.ja_name .. ' not used.')
            return
        end
        local bag = windower.ffxi.get_items(st.bag_id)
        if bag then
            for _, it in ipairs(bag) do
                if type(it) == 'table' and it.id == st.item_id and it.status == 5 then
                    gated_ja = nil
                    log('/ja "', st.ja_name, '" <t>')
                    windower.chat.input('/ja "' .. st.ja_name .. '" <t>')
                    return
                end
            end
        end
    end

    -- Equip a job ability's throwing item and issue the ability once the equip is
    -- confirmed. The client refuses a typed /ja for Tomahawk and Angon while the item
    -- is not worn, and it checks before an equip sent in the same frame can arrive,
    -- so the ability follows the equip confirmation. Call from a wrapped event.
    local function use_gated_ja(ja_id)
        local crit = CRITICAL_JA[ja_id]
        local ja_name = res.job_abilities[ja_id].en
        if state.Hoxne.value == 'ON-Locked' then
            info('Hoxne ON-Locked holds ammo. Use ON-Allow Critical or OFF for ' .. ja_name .. '.')
            return
        end
        -- The ability's own recast, checked before any gear moves: equipping for an
        -- ability that cannot fire would park suboptimal ammo for the whole watchdog.
        local recasts = windower.ffxi.get_ability_recasts()
        local wait = (recasts and recasts[res.job_abilities[ja_id].recast_id]) or 0
        if wait > 0 then
            info(('%s is on cooldown [%d:%02d].'):format(ja_name, math.floor(wait / 60), math.floor(wait % 60)))
            return
        end
        local found_bag, worn
        for _, bag_id in ipairs(ENCH_BAGS) do
            local bag = windower.ffxi.get_items(bag_id)
            if bag then
                for _, it in ipairs(bag) do
                    if type(it) == 'table' and it.id == crit.item_id then
                        found_bag = bag_id
                        worn = (it.status == 5)
                        break
                    end
                end
            end
            if found_bag then break end
        end
        if not found_bag then
            info(crit.force .. ': not found in inventory or wardrobes.')
            return
        end
        if state.Hoxne.value == 'ON-Allow Critical' then
            hoxne.window  = true
            hoxne.slot    = crit.slot
            hoxne.resume  = crit.resume
            hoxne.expires = os.clock() + 20 -- watchdog; aftercast sets the real countdown
        end
        if worn then
            -- Already confirmed worn: the client accepts the /ja right now.
            windower.chat.input('/ja "' .. ja_name .. '" <t>')
            return
        end
        equip({ [crit.slot] = crit.force })
        info('Equipping [' .. crit.force .. '] and using [' .. ja_name .. ']')
        gated_ja = {
            item_id    = crit.item_id,
            item_name  = crit.force,
            ja_name    = ja_name,
            bag_id     = found_bag,
            deadline   = os.clock() + 3,
            next_check = 0,
        }
    end

    -- Put the Ampulla back and re-assert the hold. ON-Locked must enable, equip and
    -- disable in that order within one event, or parked gear wins the flush instead.
    -- Call only from a wrapped event.
    local function hoxne_equip_ampulla()
        if state.Hoxne.value == 'ON-Locked' then
            enable('range', 'ammo')
            gs_equip({ range = empty, ammo = HOXNE_AMPULLA })
            disable('range', 'ammo')
        else
            gs_equip({ range = empty, ammo = HOXNE_AMPULLA })
        end
    end

    -- Free a stranded Ampulla, one step per call. Step one re-asserts the truly worn
    -- gear to resync GearSwap's equipment model; step two releases through it. Worn
    -- state comes from the bag copy's status. Call from a wrapped event.
    local function hoxne_release_step()
        local _, _, carried, equipped = find_enchantment(HOXNE_AMPULLA)
        if carried and not equipped then return 'done' end
        -- Bags read as empty for a few seconds after zoning, so a missing item is
        -- inconclusive rather than done; the bounded retries decide.
        if not carried then return 'wait' end
        if player.equipment.ammo ~= HOXNE_AMPULLA then
            -- A worn Ampulla rules out a range implement, and the ON modes held range
            -- empty, so both halves of the true state are known here.
            gs_equip({ range = empty, ammo = HOXNE_AMPULLA })
            return 'resync'
        end
        gs_equip({ ammo = empty })
        equip_set_command()
        return 'release'
    end

    -- Close the critical window and restore the Ampulla, routed through a self command
    -- because the tick runs on a raw handler.
    local function hoxne_relock()
        hoxne.window = false
        hoxne.slot   = nil
        hoxne.resume = nil
        -- Routed through self_command because equip() from a raw handler is
        -- discarded.
        windower.send_command('gs c hoxnerelock')
        log('Hoxne: critical window closed, re-locking Ampulla.')
    end

    -- The 1 Hz driver. Closes an expired critical window, repairs the Ampulla when the
    -- game clears it, and uses it once the buff has dropped and the item is ready.
    local function hoxne_tick(now)
        if not hoxne_on() then
            -- Mode OFF, but a reload cannot unequip: the Ampulla can be left worn with
            -- no set able to displace it. This only paces; the wrapped handler does
            -- the work and zeroes the count once the slot is confirmed free.
            if hoxne.release_tries > 0 and now >= hoxne.release_next then
                hoxne.release_next  = now + 2
                hoxne.release_tries = hoxne.release_tries - 1
                windower.send_command('gs c hoxnerelease')
            end
            return
        end

        -- While a critical window is open this is a passive observer: it only
        -- compares the clock.  It never reads or writes equipment, so a borrowed
        -- instrument or Angon cannot be overwritten before the window closes.
        if hoxne.window then
            if now >= hoxne.expires then hoxne_relock() end
            return
        end

        if ench_active then return end

        -- ON-Locked re-asserts its hold every tick; cheap, and self-healing after
        -- 'gs c enableall'. ON-Allow Critical must never disable().
        if state.Hoxne.value == 'ON-Locked' then
            disable('range', 'ammo')
        end

        -- Neither hold stops the game itself: equipping an instrument clears
        -- ammo, and in-game /equipset bypasses GearSwap entirely - so repair
        -- the slot here, routed through self_command because equip() from this
        -- raw handler would be discarded (flow.lua:60).
        if player.equipment.ammo ~= HOXNE_AMPULLA then
            local _, _, carried = find_enchantment(HOXNE_AMPULLA)
            if not carried then return end
            windower.send_command('gs c hoxnerelock')
            hoxne.next_check = now + 2
            return
        end

        if buffactive[BUFF_ENCHANTMENT] then return end
        if is_Busy or is_moving or midaction() or pet_midaction() then return end
        if player.status == 'Dead' or player.status == 'Engaged dead' then return end

        -- Never attempt a use inside the equip-delay window after our own
        -- re-equip (see HOXNE_EQUIP_LOCKOUT).
        if now < hoxne.use_not_before then return end

        -- Bag-scan gate: rescans are expensive, so throttle them during a recast gap.
        -- Covers the scan only; the tick itself still runs once per second.
        if now < hoxne.recheck_at then return end

        local row, ext = find_enchantment(HOXNE_AMPULLA)
        if not row then return end
        local recast, activation = enchantment_waits(ext)
        recast, activation = recast or 0, activation or 0
        if recast > 0 then
            warn_unavailable(row, recast)
            hoxne.recheck_at = now + math.min(recast, 5)
            return
        end
        if activation > 0 then
            -- Equip delay after our own re-equip: silent, no warning.
            hoxne.recheck_at = now + math.min(activation, 5)
            return
        end
        -- Assume the use lands.  If it did, buff 162 short-circuits this function
        -- long before the gate matters; if it did not, we retry within 10 seconds.
        hoxne.recheck_at = now + math.min(row.recast_delay or 60, 5)

        log('/item "', HOXNE_AMPULLA, '" <me>')
        windower.chat.input('/item "' .. HOXNE_AMPULLA .. '" <me>')
    end

    ------------------------------------------------------------------------------------------------
    -- SECTION 15 - GEAR SET BUILDERS
    ------------------------------------------------------------------------------------------------
    -- Assemble the equipment set for a given moment. Each returns a table for its
    -- caller to equip; none equips anything itself.

    -- Build the set for the player's current state. This is the idle and engaged
    -- builder, called on movement, buff changes, status changes and 'gs c update',
    -- so it must stay cheap and must never write to chat.
    function choose_set()
        merge_report_begin()
        if buffactive['Sleep'] then return {} end
        local built_set = {}
        -- Combat Checks
        if player.status == "Engaged" then
            if sets.OffenseMode then
                merge_report(built_set, sets.OffenseMode)
                merge_report_mark()
                if sets.OffenseMode[state.OffenseMode.value] then
                    merge_report(built_set, sets.OffenseMode[state.OffenseMode.value])
                    merge_report_branch_end()
                    -- Check the weapons
                    if state.WeaponMode.value ~= "Locked" then
                        if sets.Weapons then
                            if sets.Weapons[state.WeaponMode.value] then
                                merge_report(built_set, sets.Weapons[state.WeaponMode.value])
                            else
                                warn('sets.Weapons.' .. state.WeaponMode.value .. ' not found!')
                            end
                        else
                            warn('sets.Weapons not found!')
                        end
                        -- Equip sub weapon based off mode
                        if not DualWield and not TwoHand then
                            if sets.Weapons.Shield then
                                merge_report(built_set, sets.Weapons.Shield)
                            else
                                warn('sets.Weapons.Shield not found!')
                            end
                        elseif DualWield then
                            if sets.DualWield then
                                merge_report(built_set, sets.DualWield)
                            else
                                warn('sets.DualWield not found!')
                            end
                        end
                    end
                    -- Ranged Mode
                    if state.JobMode.value == "Ranged" then
                        log('Ranged Mode')
                        if sets.Idle and sets.Idle[state.OffenseMode.value] then
                            merge_report(built_set, sets.Idle[state.OffenseMode.value])
                        else
                            warn('sets.Idle.' .. state.OffenseMode.value .. ' not found!')
                        end
                    end
                    -- Check if AM3 is active
                    if buffactive['Aftermath: Lv.3'] and sets.OffenseMode.AM3 and sets.OffenseMode.AM3[state.WeaponMode.value] then
                        merge_report(built_set, sets.OffenseMode.AM3[state.WeaponMode.value])
                    elseif buffactive['Aftermath: Lv.2'] and sets.OffenseMode.AM2 and sets.OffenseMode.AM2[state.WeaponMode.value] then
                        merge_report(built_set, sets.OffenseMode.AM2[state.WeaponMode.value])
                    elseif buffactive['Aftermath: Lv.1'] and sets.OffenseMode.AM1 and sets.OffenseMode.AM1[state.WeaponMode.value] then
                        merge_report(built_set, sets.OffenseMode.AM1[state.WeaponMode.value])
                    elseif buffactive['Aftermath'] and sets.OffenseMode.AM and sets.OffenseMode.AM[state.WeaponMode.value] then
                        merge_report(built_set, sets.OffenseMode.AM[state.WeaponMode.value])
                    end
                    -- Check if TreasureMode is activew
                    if state.TreasureMode.value ~= 'None' then
                        if sets.TreasureHunter then
                            -- Equip TH gear if mob is not marked as tagged
                            if not th_info.tagged_mobs[player.target.id] then
                                merge_report(built_set, sets.TreasureHunter)

                                -- Equip TH gear if TreasureMode is Full Time
                            elseif state.TreasureMode.value == 'Full Time' then
                                merge_report(built_set, sets.TreasureHunter)

                                -- Equip TH gear if TreasureMode is SATA and either SA, TA or Feint is active
                            elseif state.TreasureMode.value == 'SATA' and (buffactive['Sneak Attack'] or buffactive['Trick Attack'] or buffactive['Feint']) then
                                merge_report(built_set, sets.TreasureHunter)
                            end
                        else
                            warn('sets.TreasureHunter not found!')
                        end
                    end
                else
                    warn('sets.OffenseMode.' .. state.OffenseMode.value .. ' not found!')
                end
            else
                warn('sets.OffenseMode not found!')
            end
            -- Idle sets
        else
            if sets.Idle then
                merge_report(built_set, sets.Idle)
                merge_report_mark()

                -- Idle state
                if sets.Idle[state.OffenseMode.value] then
                    merge_report(built_set, sets.Idle[state.OffenseMode.value])
                else
                    warn('sets.Idle.' .. state.OffenseMode.value .. ' not found!')
                end

                -- Resting condition
                if player.status == "Resting" then
                    if sets.Idle.Resting then
                        merge_report(built_set, sets.Idle.Resting)
                    else
                        warn('sets.Idle.Resting not found!')
                    end
                end
                merge_report_branch_end()

                -- Check the weapons
                if state.WeaponMode.value == "Locked" then
                    merge_report(built_set,
                        { main = player.equipment.main, sub = player.equipment.sub, range = player.equipment.range })
                    log(built_set)
                else
                    if sets.Weapons then
                        if sets.Weapons[state.WeaponMode.value] then
                            merge_report(built_set, sets.Weapons[state.WeaponMode.value])
                        else
                            warn('sets.Weapons.' .. state.WeaponMode.value .. ' not found!')
                        end
                    else
                        warn('sets.Weapons not found!')
                    end

                    -- Check for sub weapon
                    if not TwoHand and not DualWield then
                        if sets.Weapons.Shield then
                            merge_report(built_set, sets.Weapons.Shield)
                        else
                            warn('sets.Weapons.Shield not found!')
                        end
                    end
                end

                --Pet specific checks
                if pet.isvalid then
                    if sets.Idle.Pet then
                        merge_report(built_set, sets.Idle.Pet)
                    else
                        warn('sets.Idle.Pet not found!')
                    end
                end
                -- Equip Sublimation gear
                if buffactive[187] then
                    if sets.Idle.Sublimation then
                        merge_report(built_set, sets.Idle.Sublimation)
                    else
                        warn('sets.Idle.Sublimation not found!')
                    end
                end
                -- Equip movement gear
                if is_moving then
                    if sets.Movement then
                        merge_report(built_set, sets.Movement)
                    else
                        warn('sets.Movement not found!')
                    end
                end
            else
                warn('sets.Idle not found!')
            end
        end

        -- Variable Ammo
        if Ammo and Ammo[state.OffenseMode.value] then
            merge_report(built_set,
                { ammo = Ammo[state.OffenseMode.value] })
        end

        return built_set
    end

    -- Build the set for the opening phase of an action: fast cast, ability and
    -- weaponskill gear.
    function precastequip(spell)
        log('precastequip Called')
        ensure_placeholders()
        merge_report_begin()
        if settings.debug then
            debug("spell.type = " ..
                spell.type ..
                " , spell.action_type = " ..
                spell.action_type .. " , spell.english = " .. spell.english .. " , spell.name = " .. spell.name)
        end
        --Cancel for SMN if Avatar is mid action
        if pet.isvalid and pet_midaction() then return end
        --Default gearset
        local built_set = {}
        -- Merge the Idle incase a midcast is not set
        if sets.Idle then merge_report(built_set, sets.Idle) end
        merge_report_mark()
        -- WeaponSkill
        if spell.type == 'WeaponSkill' then
            if sets.WS then
                merge_report(built_set, sets.WS)
                local message = ''
                if spell.skill == "Marksmanship" or spell.skill == "Archery" then
                    -- Try to equip a generic ranged WS set
                    if sets.WS.RA then
                        merge_report(built_set, sets.WS.RA)
                    else
                        warn('sets.WS.RA not found!')
                    end

                    -- Set is defined
                    if sets.WS[spell.english] then
                        merge_report(built_set, sets.WS[spell.english])
                        -- Example would be WS[Savage Blade]['PDL']
                        if sets.WS[spell.english][state.OffenseMode.value] then
                            merge_report(built_set, sets.WS[spell.english][state.OffenseMode.value])
                            -- Example would be WS.RA.ACC
                        elseif state.OffenseMode.value ~= 'TP' and sets.WS.RA and sets.WS.RA[state.OffenseMode.value] then
                            merge_report(built_set, sets.WS.RA[state.OffenseMode.value])
                        end

                        -- Generic
                    else
                        if state.OffenseMode.value ~= 'TP' and sets.WS.RA and sets.WS.RA[state.OffenseMode.value] then
                            merge_report(built_set, sets.WS.RA[state.OffenseMode.value])
                        end
                    end

                    -- Check if Aftermath is active
                    if sets.WS.RA then
                        if buffactive['Aftermath: Lv.3'] and sets.WS.RA.AM3 and sets.WS.RA.AM3[state.WeaponMode.value] then
                            merge_report(built_set, sets.WS.RA.AM3[state.WeaponMode.value])
                            message = 'Level 3 Aftermath [' .. state.WeaponMode.value .. ']'
                        elseif buffactive['Aftermath: Lv.2'] and sets.WS.RA.AM2 and sets.WS.RA.AM2[state.WeaponMode.value] then
                            merge_report(built_set, sets.WS.RA.AM2[state.WeaponMode.value])
                            message = 'Level 2 Aftermath [' .. state.WeaponMode.value .. ']'
                        elseif buffactive['Aftermath: Lv.1'] and sets.WS.RA.AM1 and sets.WS.RA.AM1[state.WeaponMode.value] then
                            merge_report(built_set, sets.WS.RA.AM1[state.WeaponMode.value])
                            message = 'Level 1 Aftermath [' .. state.WeaponMode.value .. ']'
                        elseif buffactive['Aftermath'] and sets.WS.RA.AM and sets.WS.RA.AM[state.WeaponMode.value] then
                            merge_report(built_set, sets.WS.RA.AM[state.WeaponMode.value])
                            message = 'Aftermath [' .. state.WeaponMode.value .. ']'
                        end
                    end

                    -- Bullet Check
                    do_bullet_checks(spell, built_set)

                    -- Variable Ammo
                    if Ammo and Ammo[state.OffenseMode.value] then
                        merge_report(built_set,
                            { ammo = Ammo[state.OffenseMode.value] })
                    end

                    message = (message ~= '' and message .. ' ' or '')
                        .. '[' .. available_bullets .. 'x]'
                else
                    -- Set is defined
                    if sets.WS[spell.english] then
                        merge_report(built_set, sets.WS[spell.english])
                        -- Example would be WS[Savage Blade]['PDL']
                        if sets.WS[spell.english][state.OffenseMode.value] then
                            merge_report(built_set, sets.WS[spell.english][state.OffenseMode.value])
                            -- Example would be WS.ACC
                        elseif state.OffenseMode.value ~= 'TP' and sets.WS[state.OffenseMode.value] then
                            merge_report(built_set, sets.WS[state.OffenseMode.value])
                        end

                        -- Generic
                    else
                        if state.OffenseMode.value ~= 'TP' and sets.WS[state.OffenseMode.value] then
                            merge_report(built_set, sets.WS[state.OffenseMode.value])
                        end
                    end

                    -- Check if Aftermath is active
                    if buffactive['Aftermath: Lv.3'] and sets.WS.AM3 and sets.WS.AM3[state.WeaponMode.value] then
                        merge_report(built_set, sets.WS.AM3[state.WeaponMode.value])
                        message = 'Level 3 Aftermath'
                    elseif buffactive['Aftermath: Lv.2'] and sets.WS.AM2 and sets.WS.AM2[state.WeaponMode.value] then
                        merge_report(built_set, sets.WS.AM2[state.WeaponMode.value])
                        message = 'Level 2 Aftermath'
                    elseif buffactive['Aftermath: Lv.1'] and sets.WS.AM1 and sets.WS.AM1[state.WeaponMode.value] then
                        merge_report(built_set, sets.WS.AM1[state.WeaponMode.value])
                        message = 'Level 1 Aftermath'
                    elseif buffactive['Aftermath'] and sets.WS.AM and sets.WS.AM[state.WeaponMode.value] then
                        merge_report(built_set, sets.WS.AM[state.WeaponMode.value])
                        message = 'Aftermath'
                    end
                end

                -- Check if an Obi or Orpheus is to be Equiped
                if Elemental_WS:contains(spell.name) then built_set = elemental_check(spell, built_set) end

                -- Aftermath and ammo only; the set itself is named by the build report.
                if message ~= '' then info(message) end
            else
                warn('sets.WS not found!')
            end
            -- Ranged attack
        elseif spell.action_type == 'Ranged Attack' then
            if sets.Precast then
                merge_report(built_set, sets.Precast)
                if sets.Precast.RA then
                    merge_report(built_set, sets.Precast.RA)
                    if buffactive[265] then -- Flurry
                        if sets.Precast.RA.Flurry then
                            merge_report(built_set, sets.Precast.RA.Flurry)
                        else
                            warn('sets.Precast.RA.Flurry not found!')
                        end
                    elseif buffactive[581] then -- Flurry II
                        if sets.Precast.RA.Flurry_II then
                            merge_report(built_set, sets.Precast.RA.Flurry_II)
                        else
                            warn('sets.Precast.RA.Flurry_II not found!')
                        end
                    elseif buffactive[228] then -- Embrava
                        if sets.Precast.RA.Flurry_II then
                            merge_report(built_set, sets.Precast.RA.Flurry_II)
                        else
                            warn('sets.Precast.RA.Flurry_II not found!')
                        end
                    end

                    -- Variable Ammo
                    if Ammo and Ammo[state.OffenseMode.value] then
                        merge_report(built_set,
                            { ammo = Ammo[state.OffenseMode.value] })
                    end
                else
                    warn('sets.Precast.RA not found!')
                end
            else
                warn('sets.Precast not found!')
            end

            -- Check for bullets if shooting a round
            if built_set.ammo ~= "" and built_set.ranged ~= "" then do_bullet_checks(spell, built_set) end
            -- JobAbility
        elseif spell.type == 'JobAbility' then
            if sets.JA then
                merge_report(built_set, sets.JA)
                if spell.name == 'Double-Up' then -- Double Up for distance
                    if sets.PhantomRoll then
                        merge_report(built_set, sets.PhantomRoll)
                    else
                        warn('sets.PhantomRoll not found!')
                    end
                elseif sets.JA[spell.english] then
                    merge_report(built_set, sets.JA[spell.english])
                    --Summon the correct jug pet
                    if spell.name == 'Bestial Loyalty' or spell.name == 'Call Beast' then
                        if sets.Jugs[state.JobMode.value] then
                            merge_report(built_set, sets.Jugs[state.JobMode.value])
                        else
                            warn('sets.Jugs.' .. state.JobMode.value .. ' not found!')
                        end
                    end
                end
                -- Check for bounty shot ammo
                if spell.name == 'Bounty Shot' then
                    do_bullet_checks(spell, built_set)
                end
            else
                warn('sets.JA not found!')
            end
            if spell.name == "Divine Seal" and not divine_seal_predicted then
                divine_seal_predicted = true
                if settings.debug then debug("Divine Seal detected while tracking. Divine_Seal_Predicted = True") end
            end
            -- Items
        elseif spell.action_type == 'Item' or spell.prefix == '/item' then
            log('Item Use - Precast')
            if spell.english == "Holy Water" or spell.english == "Hallowed Water" then
                if sets.Holy_Water then
                    if sets.Idle then
                        merge_report(built_set, sets.Holy_Water)
                    else
                        warn('sets.Idle not found!')
                    end
                else
                    warn('sets.Holy_Water not found!')
                end
            else
                if sets.Idle then
                    merge_report(built_set, sets.Idle)
                else
                    warn('sets.Idle not found!')
                end
            end
            -- Scholar
        elseif spell.type == 'Scholar' then
            if spell.name == "Accession" and not accession_predicted then
                accession_predicted = true
                if settings.debug then debug("Accession detected while tracking. Accession_Predicted = True") end
            end
            if sets.JA then
                merge_report(built_set, sets.JA)
                if sets.JA[spell.english] then
                    merge_report(built_set, sets.JA[spell.english])
                end
            else
                warn('sets.JA not found!')
            end
            -- Ward
        elseif spell.type == 'Ward' then
            if sets.JA then
                merge_report(built_set, sets.JA)
                if sets.JA[spell.english] then
                    merge_report(built_set, sets.JA[spell.english])
                end
            else
                warn('sets.JA not found!')
            end
            -- Rune
        elseif spell.type == 'Rune' then
            if sets.JA then
                merge_report(built_set, sets.JA)
                if sets.JA[spell.english] then
                    merge_report(built_set, sets.JA[spell.english])
                end
            else
                warn('sets.JA not found!')
            end
            -- Effusion
        elseif spell.type == 'Effusion' then
            if sets.JA then
                merge_report(built_set, sets.JA)
                if sets.JA[spell.english] then
                    merge_report(built_set, sets.JA[spell.english])
                end
            else
                warn('sets.JA not found!')
            end
            -- CorsairRoll
        elseif spell.type == 'CorsairRoll' then
            log('CorsairRoll')
            if sets.PhantomRoll then
                merge_report(built_set, sets.PhantomRoll)
                if sets.PhantomRoll[spell.english] then
                    merge_report(built_set, sets.PhantomRoll[spell.english])
                end
            else
                warn('sets.PhantomRoll not found!')
            end
            -- CorsairShot
        elseif spell.type == 'CorsairShot' then
            if sets.QuickDraw then
                merge_report(built_set, sets.QuickDraw)
                if sets.QuickDraw[spell.english] then
                    merge_report(built_set, sets.QuickDraw[spell.english])
                end
            else
                warn('sets.QuickDraw not found!')
            end
            -- Waltz
        elseif spell.type == 'Waltz' then
            if sets.Waltz then
                merge_report(built_set, sets.Waltz)
                if sets.Waltz[spell.english] then
                    merge_report(built_set, sets.Waltz[spell.english])
                end
            else
                warn('sets.Waltz not found!')
            end

            --Check for ability casts that are tracked for spell-received gear swapping
            --Notify eligible targets via IPC that a tracked spell is incoming
            if state.SpellReceived.value ~= "OFF" then
                local a_info = ability_info[spell.id]
                if a_info and not outgoing_cast_active then
                    local target_mob = get_mob_by_id(spell.target.id)
                    if not player or not target_mob then return end

                    local target_name = spell.target.name
                    outgoing_cast_active = true
                    if settings.debug then
                        debug(player.name .. ' is using tracked ability measured at precast: ' ..
                            spell.name .. ' on ' .. target_name .. ' at ' .. get_time())
                    end

                    --AoE Checks
                    if a_info.aoe then
                        if settings.debug then debug("AoE Ability Cast Detected.  Calculating targets.") end
                        target_name = resolve_aoe_target_name(target_mob, target_name)
                    end
                    if settings.debug then
                        debug(string.format("IPC message sent: MIRDAIN|ABILITY|%s|%s|%s|%.0f", player.name, target_name,
                            spell.id, get_time()))
                    end
                    send_ipc(string.format("MIRDAIN|ABILITY|%s|%s|%s|%.0f", player.name, target_name, spell.id,
                        get_time()))
                end
            end
            -- Jig
        elseif spell.type == 'Jig' then
            if sets.Jig then
                merge_report(built_set, sets.Jig)
                if sets.Jig[spell.english] then
                    merge_report(built_set, sets.Jig[spell.english])
                end
            else
                warn('sets.Jig not found!')
            end
            -- Samba
        elseif spell.type == 'Samba' then
            if sets.Samba then
                merge_report(built_set, sets.Samba)
                if sets.Samba[spell.english] then
                    merge_report(built_set, sets.Samba[spell.english])
                end
            else
                warn('sets.Samba not found!')
            end
            -- Step
        elseif spell.type == 'Step' then
            if sets.Step then
                merge_report(built_set, sets.Step)
                if sets.Step[spell.english] then
                    merge_report(built_set, sets.Step[spell.english])
                end
            else
                warn('sets.Step not found!')
            end
            -- Flourishes
        elseif spell.type == 'Flourish1' or spell.type == 'Flourish2' or spell.type == 'Flourish3' then
            if sets.Flourish then
                merge_report(built_set, sets.Flourish)
                if sets.Flourish[spell.english] then
                    merge_report(built_set, sets.Flourish[spell.english])
                end
            else
                warn('sets.Flourish not found!')
            end
            -- Magic based actions
        else
            -- Precast
            if sets.Precast then
                merge_report(built_set, sets.Precast)
                -- FastCast
                if sets.Precast.FastCast then
                    merge_report(built_set, sets.Precast.FastCast)
                    -- Augment with Enhancing set
                    if spell.skill == 'Enhancing Magic' then
                        if sets.Precast.Enhancing then
                            merge_report(built_set, sets.Precast.Enhancing)
                        else
                            warn('sets.Precast.Enhancing not found!')
                        end
                    end
                    -- Specified Sets
                    if sets.Precast[spell.english] then
                        merge_report(built_set, sets.Precast[spell.english])
                        -- Augment with Cure Casting set
                    elseif spell.name:contains('Cure') or spell.name:contains('Cura') then
                        if sets.Precast.Cure then
                            merge_report(built_set, sets.Precast.Cure)
                        else
                            warn('sets.Precast.Cure not found!')
                        end
                        -- Augment with Healing Magic set
                    elseif Healing_Magic:contains(spell.name) then
                        if sets.Precast.Healing then
                            merge_report(built_set, sets.Precast.Healing)
                        else
                            warn('sets.Precast.Healing not found!')
                        end
                        -- Ninjutsu
                    elseif spell.type == 'Ninjutsu' and UtsusemiSpell:contains(spell.name) then
                        do_Utsu_checks(spell)
                        if sets.Precast.Utsusemi then
                            merge_report(built_set, sets.Precast.Utsusemi)
                        else
                            warn('sets.Precast.Utsusemi not found!')
                        end
                        -- Blue Magic
                    elseif spell.type == 'BlueMagic' then
                        if sets.Precast.BlueMagic then
                            merge_report(built_set, sets.Precast.BlueMagic)
                        else
                            warn('sets.Precast.BlueMagic not found!')
                        end
                        -- BardSong
                    elseif spell.type == 'BardSong' then
                        if buffactive['Nightingale'] then
                            -- Default BRD song gear is in Midcast
                            if sets.Midcast then
                                merge_report(built_set, sets.Midcast)
                            else
                                warn('sets.Midcast not found!')
                            end
                            -- Song Count for Dummy Songs
                            if SongCount:contains(spell.name) then
                                if sets.Midcast.DummySongs then
                                    merge_report(built_set, sets.Midcast.DummySongs)
                                else
                                    warn('sets.Midcast.DummySongs not found!')
                                end
                                merge_report(built_set, { range = Instrument.Count })
                                -- Potency / Instruments
                            else
                                -- Defined Gear Set
                                if sets.Midcast[spell.english] then
                                    merge_report(built_set, sets.Midcast[spell.english])
                                    -- Equip Harp
                                elseif spell.name:contains('Horde') then
                                    if sets.Midcast.Enfeebling then
                                        merge_report(built_set, sets.Midcast.Enfeebling)
                                    else
                                        warn('sets.Midcast.Enfeebling not found!')
                                    end
                                    merge_report(built_set, { range = Instrument.AOE_Sleep })
                                    -- Normal Enfeebles
                                elseif Enfeebling_Song:contains(spell.english) then
                                    if sets.Midcast.Enfeebling then
                                        merge_report(built_set, sets.Midcast.Enfeebling)
                                    else
                                        warn('sets.Midcast.Enfeebling not found!')
                                    end
                                    merge_report(built_set, { range = Instrument.Potency })
                                    -- Augment the buff songs
                                else
                                    merge_report(built_set, { range = Instrument.Potency })
                                end
                                -- Augment the specific Song if set
                                merge_report(built_set, equip_song_gear(spell, built_set['range']))
                            end
                        else
                            if sets.Precast.Songs then
                                merge_report(built_set, sets.Precast.Songs)
                            else
                                warn('sets.Precast.Songs not found!')
                            end
                        end
                    end
                else
                    warn('sets.Precast.FastCast not found!')
                end
            else
                warn('sets.Precast not found!')
            end
            --Check for spell casts that are tracked for spell-received gear swapping
            --Notify eligible targets via IPC that a tracked spell is incoming
            local s_info = spell_info[spell.id]
            if s_info and state.SpellReceived.value ~= "OFF" and not outgoing_cast_active then
                local target_mob = get_mob_by_id(spell.target.id)
                if not target_mob then return end

                local target_name = spell.target.name
                outgoing_cast_active = true

                if settings.debug then
                    debug(player.name ..
                        ' is using tracked spell measured at precast: ' ..
                        spell.name .. ' on ' .. target_name .. ' at ' .. get_time())
                end
                local active_buffs = buffactive
                local accession_active = active_buffs[366] or active_buffs['Accession']
                local majesty_active = active_buffs[621] or active_buffs['Majesty']
                local divine_veil_active = active_buffs[78] or active_buffs['Divine Seal']

                --AoE Checks
                local has_yagrush = (s_info.divine and get_slot_item_name(sets.Midcast["Cursna"], 'main') == "Yagrush")
                if (s_info.aoe or ((accession_predicted or accession_active) and s_info.accession) or (majesty_active and s_info.majesty) or ((divine_seal_predicted or divine_veil_active or has_yagrush) and s_info.divine)) then
                    if settings.debug then debug("AoE Spell Cast Detected. Calculating targets.") end
                    target_name = resolve_aoe_target_name(target_mob, target_name)
                end
                if settings.debug then
                    debug(string.format("IPC message sent: MIRDAIN|SPELL|%s|%s|%s|%.0f", player.name,
                        target_name, spell.id, get_time()))
                end
                send_ipc(string.format("MIRDAIN|SPELL|%s|%s|%s|%.0f", player.name, target_name, spell.id, get_time()))
            end
        end

        merge_report_branch_end()

        -- Weapon Checks for precast
        -- If it set to unlocked it will not swap the weapons even if defined in the built_set job lua
        if state.WeaponMode.value ~= "Unlocked" and spell.type ~= 'CorsairRoll' and spell.name ~= 'Double-Up' then
            log('Update Weapons - Precast')
            if state.WeaponMode.value == "Locked" then
                merge_report(built_set,
                    { main = player.equipment.main, sub = player.equipment.sub, range = player.equipment.range })
            else
                if sets.Weapons then
                    if sets.Weapons[state.WeaponMode.value] then
                        merge_report(built_set, sets.Weapons[state.WeaponMode.value])
                        if not TwoHand and not DualWield then
                            if sets.Weapons.Shield then
                                merge_report(built_set, sets.Weapons.Shield)
                            else
                                warn('sets.Weapons.Shield not found!')
                            end
                        end
                    else
                        warn('sets.Weapons.' .. state.WeaponMode.value .. ' not found!')
                    end
                else
                    warn('sets.Weapons not found!')
                end
            end
        end

        --Swap in bard song weapons no matter the mode
        if spell.type == 'BardSong' then --and spell.target.type ~= 'MONSTER' then
            if sets.Weapons then
                if sets.Weapons.Songs then
                    merge_report(built_set, sets.Weapons.Songs)
                    if sets.Weapons.Songs.Midcast then
                        if not DualWield and not TwoHand then
                            if sets.Weapons.Shield then
                                merge_report(built_set, sets.Weapons.Shield)
                            else
                                warn('sets.Weapons.Shield not found!')
                            end
                        end
                        merge_report(built_set, sets.Weapons.Songs.Midcast)
                    else
                        warn('sets.Weapons.Songs.Midcast not found!')
                    end
                else
                    warn('sets.Weapons.Songs not found!')
                end
            else
                warn('sets.Weapons not found!')
            end
        end

        -- If TH mode is on - check if new mob and not casting a spell and then equip TH gear
        if state.TreasureMode.value ~= 'None' and spell.target.type == 'MONSTER' and not th_info.tagged_mobs[spell.target.id]
            and not (spell.type:endswith('Magic') or spell.type == 'Trust' or spell.type == 'BardSong' or spell.skill == 'Ninjutsu') then
            if sets.TreasureHunter then
                merge_report(built_set, sets.TreasureHunter)
                info('[' .. spell.english .. '] Set with Treasure Hunter')
            else
                warn('sets.TreasureHunter not found!')
            end
        end

        -- Final built_set built to return.  This is not the final set as custom Job can Augment
        return built_set
    end

    -- Build the set applied while an action is in flight, which is what determines its
    -- potency.
    function midcastequip(spell)
        ensure_placeholders()
        merge_report_begin()
        -- Abilities and items have no midcast build; precast chose their gear.
        if PRECAST_FINAL[spell.type] then
            log('abort midcast')
            return
        end
        if pet.isvalid and pet_midaction() then return end

        --Default gearset
        local built_set = {}
        -- Merge the Idle incase a midcast is not set
        if sets.Idle then merge_report(built_set, sets.Idle) end
        -- Merget the Midcast Set
        if sets.Midcast then
            merge_report(built_set, sets.Midcast)
            -- Spell interruption Down for the rest of the actions
            if sets.Midcast.SIRD and spell.action_type ~= 'Ranged Attack' then
                merge_report(built_set,
                    sets.Midcast.SIRD)
            end
            merge_report_mark()

            -- Ranged Attack
            if spell.action_type == 'Ranged Attack' then
                if sets.Midcast.RA then
                    local message = ''
                    merge_report(built_set, sets.Midcast.RA)

                    -- Augment based off Mode
                    if state.OffenseMode.value ~= 'TP' and sets.Midcast.RA[state.OffenseMode.value] then
                        merge_report(built_set, sets.Midcast.RA[state.OffenseMode.value])
                        if state.OffenseMode.value == 'ACC' then
                            message = 'Ranged Attack with Accuracy'
                        elseif state.OffenseMode.value == 'PDL' then
                            message = 'Ranged Attack with Physical Damage Limit'
                        elseif state.OffenseMode.value == 'SB' then
                            message = 'Ranged Attack with Subtle Blow'
                        elseif state.OffenseMode.value == 'MEVA' then
                            message = 'Ranged Attack with Magic Evasion'
                        elseif state.OffenseMode.value == 'DT' then
                            message = 'Ranged Attack with Damage Taken'
                        elseif state.OffenseMode.value == 'PDT' then
                            message = 'Ranged Attack with Physical Damage Taken'
                        elseif state.OffenseMode.value == 'CRIT' then
                            message = 'Ranged Attack with Critical Hit'
                        elseif state.OffenseMode.value == 'True Shot' then
                            message = 'Ranged Attack with True Shot'
                        end
                    else
                        message = 'Ranged Attack Set'
                    end

                    -- Check if Aftermath is active
                    if buffactive['Aftermath: Lv.3'] and sets.Midcast.RA.AM3 and sets.Midcast.RA.AM3[state.WeaponMode.value] then
                        merge_report(built_set, sets.Midcast.RA.AM3[state.WeaponMode.value])
                        message = message .. ' and with Aftermath 3 [' .. state.WeaponMode.value .. ']'
                    elseif buffactive['Aftermath: Lv.2'] and sets.Midcast.RA.AM2 and sets.Midcast.RA.AM2[state.WeaponMode.value] then
                        merge_report(built_set, sets.Midcast.RA.AM2[state.WeaponMode.value])
                        message = message .. ' and with Aftermath 2 [' .. state.WeaponMode.value .. ']'
                    elseif buffactive['Aftermath: Lv.1'] and sets.Midcast.RA.AM1 and sets.Midcast.RA.AM1[state.WeaponMode.value] then
                        merge_report(built_set, sets.Midcast.RA.AM1[state.WeaponMode.value])
                        message = message .. ' and with Aftermath 1 [' .. state.WeaponMode.value .. ']'
                    elseif buffactive['Aftermath'] and sets.Midcast.RA.AM and sets.Midcast.RA.AM[state.WeaponMode.value] then
                        merge_report(built_set, sets.Midcast.RA.AM[state.WeaponMode.value])
                        message = message .. ' and with Aftermath [' .. state.WeaponMode.value .. ']'
                    end

                    -- Buffs
                    if buffactive['Triple Shot'] and sets.Midcast.RA.TripleShot then
                        merge_report(built_set, sets.Midcast.RA.TripleShot)
                        message = 'Using Triple Shot Set'
                    elseif buffactive['Double Shot'] and sets.Midcast.RA.DoubleShot then
                        merge_report(built_set, sets.Midcast.RA.DoubleShot)
                        message = 'Using Double Shot Set'
                    elseif buffactive['Barrage'] and sets.Midcast.RA.Barrage then
                        merge_report(built_set, sets.Midcast.RA.Barrage)
                        message = 'Using Barrage Set'
                    end

                    -- Variable Ammo
                    if Ammo[state.OffenseMode.value] then
                        merge_report(built_set,
                            { ammo = Ammo[state.OffenseMode.value] })
                    end

                    message = message .. ' [' .. available_bullets .. 'x]'
                    info(message)
                else
                    warn('sets.Midcast.RA not found!')
                end
                -- Ninjutsu
            elseif spell.type == 'Ninjutsu' then
                -- Defined Gear Set
                if sets.Midcast[spell.english] then
                    merge_report(built_set, sets.Midcast[spell.english])
                    -- Utsusemi Spells
                elseif UtsusemiSpell:contains(spell.name) then
                    if sets.Midcast.Utsusemi then
                        merge_report(built_set, sets.Midcast.Utsusemi)
                    else
                        warn('sets.Midcast.Utsusemi not found!')
                    end
                    -- Enhancing Magic
                elseif spell.target.type == 'SELF' then
                    if sets.Midcast.Enhancing then
                        merge_report(built_set, sets.Midcast.Enhancing)
                    else
                        warn('sets.Midcast.Enhancing not found!')
                    end
                    -- Enfeebling
                elseif Enfeebling_Ninjitsu:contains(spell.english) then
                    if sets.Midcast.Enfeebling then
                        merge_report(built_set, sets.Midcast.Enfeebling)
                    else
                        warn('sets.Midcast.Enfeebling not found!')
                    end
                    -- Defaults to Nukes if not the above
                else
                    if sets.Midcast.Nuke then
                        merge_report(built_set, sets.Midcast.Nuke)
                    else
                        warn('sets.Midcast.Nuke not found!')
                    end
                    -- Check for an elemental set
                    built_set = elemental_check(spell, built_set)
                end
                -- WhiteMagic
            elseif spell.type == 'WhiteMagic' then
                -- Cure
                if spell.name:contains('Cure') then
                    if sets.Midcast.Cure then
                        merge_report(built_set, sets.Midcast.Cure)
                    else
                        warn('sets.Midcast.Cure not found!')
                    end
                    -- Check if an Obi or Orpheus is to be Equiped
                    built_set = elemental_check(spell, built_set)
                    -- Curaga
                elseif spell.name:contains('Curaga') then
                    if sets.Midcast.Curaga then
                        merge_report(built_set, sets.Midcast.Curaga)
                    else
                        warn('sets.Midcast.Curaga not found!')
                    end
                    -- Check if an Obi or Orpheus is to be Equiped
                    built_set = elemental_check(spell, built_set)
                    -- Cura
                elseif spell.name:contains('Cura') then
                    if sets.Midcast.Cura then
                        merge_report(built_set, sets.Midcast.Cura)
                    else
                        warn('sets.Midcast.Cura not found!')
                    end
                    -- Check if an Obi or Orpheus is to be Equiped
                    built_set = elemental_check(spell, built_set)
                    -- Cursna: its own set layered over the Enhancing base
                elseif spell.name == 'Cursna' then
                    if sets.Midcast.Enhancing then
                        merge_report(built_set, sets.Midcast.Enhancing)
                    else
                        warn('sets.Midcast.Enhancing not found!')
                    end
                    if sets.Midcast.Cursna then
                        merge_report(built_set, sets.Midcast.Cursna)
                    else
                        warn('sets.Midcast.Cursna not found!')
                    end
                    -- Defined Gear Set
                elseif sets.Midcast[spell.english] then
                    merge_report(built_set, sets.Midcast[spell.english])
                    -- All other Healing Magic - Raise, Reraise, status cures - uses the
                    -- plain Enhancing set, no subcategories
                elseif spell.skill == 'Healing Magic' then
                    if sets.Midcast.Enhancing then
                        merge_report(built_set, sets.Midcast.Enhancing)
                    else
                        warn('sets.Midcast.Enhancing not found!')
                    end
                    -- Enhancing
                elseif spell.skill == 'Enhancing Magic' then
                    if sets.Midcast.Enhancing then
                        merge_report(built_set, sets.Midcast.Enhancing)
                        -- Augment the set for Others if defined
                        if spell.target.type ~= 'SELF' or (spell.target.type == 'SELF' and buffactive['Accession']) then
                            if sets.Midcast.Enhancing.Others then
                                merge_report(built_set, sets.Midcast.Enhancing.Others)
                            else
                                warn('sets.Midcast.Enhancing.Others not found!')
                            end
                        end
                        -- Refresh
                        if spell.name:contains('Refresh') then
                            if sets.Midcast.Refresh then
                                merge_report(built_set, sets.Midcast.Refresh)
                            else
                                warn('sets.Midcast.Refresh not found!')
                            end
                            -- Regen
                        elseif spell.name:contains('Regen') then
                            if sets.Midcast.Regen then
                                merge_report(built_set, sets.Midcast.Regen)
                            else
                                warn('sets.Midcast.Regen not found!')
                            end
                        elseif Storms:contains(spell.name) then
                            if sets.Storms then
                                merge_report(built_set, sets.Storms)
                            else
                                warn('sets.Storms not found!')
                            end
                            -- Gain Spells
                        elseif spell.name:contains('Gain') then
                            if sets.Midcast.Enhancing.Gain then
                                merge_report(built_set, sets.Midcast.Enhancing.Gain)
                            else
                                warn('sets.Midcast.Enhancing.Gain not found!')
                            end
                            -- Phalanx
                        elseif spell.name:contains('Phalanx') then
                            if sets.Midcast.Phalanx then
                                merge_report(built_set, sets.Midcast.Phalanx)
                            else
                                warn('sets.Midcast.Phalanx not found!')
                            end
                            -- Bar Spells
                        elseif Elemental_Bar:contains(spell.name) then
                            if sets.Midcast.Enhancing.Elemental then
                                merge_report(built_set, sets.Midcast.Enhancing.Elemental)
                            else
                                warn('sets.Midcast.Enhancing.Elemental not found!')
                            end
                            -- Bar Status
                        elseif Status_Bar:contains(spell.name) then
                            if sets.Midcast.Enhancing.Status then
                                merge_report(built_set, sets.Midcast.Enhancing.Status)
                            else
                                warn('sets.Midcast.Enhancing.Status not found!')
                            end
                            -- Enhancing SKill
                        elseif Enhancing_Skill:contains(spell.name) then
                            if sets.Midcast.Enhancing.Skill then
                                merge_report(built_set, sets.Midcast.Enhancing.Skill)
                            else
                                warn('sets.Midcast.Enhancing.Skill not found!')
                            end
                        end
                    else
                        warn('sets.Midcast.Enhancing not found!')
                    end
                    -- Divine Spells
                elseif Divine_Skill:contains(spell.name) then
                    if sets.Midcast.Divine then
                        merge_report(built_set, sets.Midcast.Divine)
                    else
                        warn('sets.Midcast.Divine not found!')
                    end
                    -- Enfeebling Magic
                elseif spell.skill == 'Enfeebling Magic' then
                    if sets.Midcast.Enfeebling then
                        merge_report(built_set, sets.Midcast.Enfeebling)
                        -- Accuracy
                        if Enfeeble_Acc:contains(spell.name) then
                            if sets.Midcast.Enfeebling.MACC then
                                merge_report(built_set, sets.Midcast.Enfeebling.MACC)
                            else
                                warn('sets.Midcast.Enfeebling.MACC not found!')
                            end
                            -- Potency
                        elseif Enfeeble_Potency:contains(spell.name) then
                            if sets.Midcast.Enfeebling.Potency then
                                merge_report(built_set, sets.Midcast.Enfeebling.Potency)
                            else
                                warn('sets.Midcast.Enfeebling.Potency not found!')
                            end
                            -- Duration
                        elseif Enfeeble_Duration:contains(spell.name) then
                            if sets.Midcast.Enfeebling.Duration then
                                merge_report(built_set, sets.Midcast.Enfeebling.Duration)
                            else
                                warn('sets.Midcast.Enfeebling.Duration not found!')
                            end
                        end
                    else
                        info('No sets.Midcast.Enfeebling defined!')
                    end
                end
                -- Black Magic
            elseif spell.type == 'BlackMagic' then
                -- Defined Gear Set
                if sets.Midcast[spell.english] then
                    merge_report(built_set, sets.Midcast[spell.english])
                    -- Check for an elemental set
                    if spell.skill == 'Elemental Magic' and not spell.name:contains('helix') then
                        built_set =
                            elemental_check(spell, built_set)
                    end
                    -- Aspir Gear
                elseif spell.name:contains('Aspir') then
                    if sets.Midcast.Aspir then
                        merge_report(built_set, sets.Midcast.Aspir)
                    else
                        warn('sets.Midcast.Aspir not found!')
                    end
                    -- Drain Gear
                elseif spell.name:contains('Drain') then
                    if sets.Midcast.Drain then
                        merge_report(built_set, sets.Midcast.Drain)
                    else
                        warn('sets.Midcast.Drain not found!')
                    end
                    -- Enfeebling Magic
                elseif spell.skill == 'Enfeebling Magic' then
                    if sets.Midcast.Enfeebling then
                        merge_report(built_set, sets.Midcast.Enfeebling)
                        -- Accuracy
                        if Enfeeble_Acc:contains(spell.name) then
                            if sets.Midcast.Enfeebling.MACC then
                                merge_report(built_set, sets.Midcast.Enfeebling.MACC)
                            else
                                warn('sets.Midcast.Enfeebling.MACC not found!')
                            end
                            -- Potency
                        elseif Enfeeble_Potency:contains(spell.name) then
                            if sets.Midcast.Enfeebling.Potency then
                                merge_report(built_set, sets.Midcast.Enfeebling.Potency)
                            else
                                warn('sets.Midcast.Enfeebling.Potency not found!')
                            end
                            -- Duration
                        elseif Enfeeble_Duration:contains(spell.name) then
                            if sets.Midcast.Enfeebling.Duration then
                                merge_report(built_set, sets.Midcast.Enfeebling.Duration)
                            else
                                warn('sets.Midcast.Enfeebling.Duration not found!')
                            end
                        end
                    else
                        info('No sets.Midcast.Enfeebling not found!')
                    end
                    -- Dark Magic
                elseif spell.skill == 'Dark Magic' then
                    if sets.Midcast.Dark then
                        merge_report(built_set, sets.Midcast.Dark)
                        -- Accuracy
                        if Dark_Acc:contains(spell.name) then
                            if sets.Midcast.Dark.MACC then
                                merge_report(built_set, sets.Midcast.Dark.MACC)
                            else
                                warn('sets.Midcast.Dark.MACC not found!')
                            end
                            -- Absorb
                        elseif Dark_Absorb:contains(spell.name) then
                            if sets.Midcast.Dark.Absorb then
                                merge_report(built_set, sets.Midcast.Dark.Absorb)
                            else
                                warn('sets.Midcast.Dark.Absorb not found!')
                            end
                            -- Enhancing
                        elseif Dark_Enhancing:contains(spell.name) then
                            if sets.Midcast.Dark.Enhancing then
                                merge_report(built_set, sets.Midcast.Dark.Enhancing)
                            else
                                warn('sets.Midcast.Dark.Enhancing not found!')
                            end
                            -- Potency
                        elseif Enfeeble_Potency:contains(spell.name) then
                            if sets.Midcast.Enfeebling.Potency then
                                merge_report(built_set, sets.Midcast.Enfeebling.Potency)
                            else
                                warn('sets.Midcast.Enfeebling.Potency not found!')
                            end
                            -- Duration
                        elseif Enfeeble_Duration:contains(spell.name) then
                            if sets.Midcast.Enfeebling.Duration then
                                merge_report(built_set, sets.Midcast.Enfeebling.Duration)
                            else
                                warn('sets.Midcast.Enfeebling.Duration not found!')
                            end
                        end
                    else
                        info('No sets.Midcast.Dark not found!')
                    end
                    -- Enhancing Magic
                elseif spell.skill == 'Enhancing Magic' then
                    if sets.Midcast.Enhancing then
                        merge_report(built_set, sets.Midcast.Enhancing)
                    else
                        warn('sets.Midcast.Enhancing not found!')
                    end
                    -- Enfeebling Elemental Magic
                elseif Elemental_Enfeeble:contains(spell.name) then
                    if sets.Midcast.Enfeebling then
                        merge_report(built_set, sets.Midcast.Enfeebling)
                        if sets.Midcast.Enfeebling.MACC then
                            merge_report(built_set, sets.Midcast.Enfeebling.MACC)
                        else
                            warn('sets.Midcast.Enfeebling.MACC not found!')
                        end
                    else
                        warn('sets.Midcast.Enfeebling not found!')
                    end
                    -- Standard Offensive Spells
                elseif spell.skill == 'Elemental Magic' then
                    local element = res.spells[spell.id].element
                    local element_name = res.elements[element].en
                    if spell.target.id == last_skillchain_id and os.clock() - last_skillchain_time < 8 and last_skillchain_elements[element_name] then
                        info("Burst Detected!")
                        if sets.Midcast.Burst then
                            merge_report(built_set, sets.Midcast.Burst)
                        else
                            warn('sets.Midcast.Burst not found!')
                        end
                    else
                        if sets.Midcast.Nuke then
                            merge_report(built_set, sets.Midcast.Nuke)
                        else
                            warn('sets.Midcast.Nuke not found!')
                        end
                    end
                    -- Check for Helix
                    if spell.name:contains('helix') then
                        if sets.Helix then
                            merge_report(built_set, sets.Helix)
                            if spell.element == 'Dark' then
                                if sets.Helix.Dark then
                                    merge_report(built_set, sets.Helix.Dark)
                                else
                                    warn('sets.Helix.Dark not found!')
                                end
                            elseif spell.element == 'Light' then
                                if sets.Helix.Light then
                                    merge_report(built_set, sets.Helix.Light)
                                else
                                    warn('sets.Helix.Light not found!')
                                end
                            end
                        else
                            warn('sets.Helix not found!')
                        end
                    else
                        if spell.element == "Earth" and sets.Midcast.Nuke.Earth then
                            merge_report(built_set, sets.Midcast.Nuke.Earth)
                            windower.add_to_chat(8, 'Earth Element Detected!')
                        end
                        -- Check for an elemental set
                        built_set = elemental_check(spell, built_set)
                    end
                end
                -- Bard Song
            elseif spell.type == 'BardSong' then
                -- Song Count for Dummy Songs
                if SongCount:contains(spell.name) then
                    if sets.Midcast.DummySongs then
                        merge_report(built_set, sets.Midcast.DummySongs)
                    else
                        warn('sets.Midcast.DummySongs not found!')
                    end
                    merge_report(built_set, { range = Instrument.Count })
                    -- Potency / Instruments
                else
                    -- Defined Gear Set
                    if sets.Midcast[spell.english] then
                        merge_report(built_set, sets.Midcast[spell.english])
                        -- Equip Harp
                    elseif spell.name:contains('Horde') then
                        if sets.Midcast.Enfeebling then
                            merge_report(built_set, sets.Midcast.Enfeebling)
                        else
                            warn('sets.Midcast.Enfeebling not found!')
                        end
                        merge_report(built_set, { range = Instrument.AOE_Sleep })
                        -- Normal Enfeebles
                    elseif Enfeebling_Song:contains(spell.english) then
                        if sets.Midcast.Enfeebling then
                            merge_report(built_set, sets.Midcast.Enfeebling)
                        else
                            warn('sets.Midcast.Enfeebling not found!')
                        end
                        merge_report(built_set, { range = Instrument.Enfeebling })
                        -- Augment the buff songs
                    else
                        merge_report(built_set, { range = Instrument.Potency })
                    end
                    -- Augment the specific Song if set
                    merge_report(built_set, equip_song_gear(spell, built_set['range']))
                end
                -- BlueMagic
            elseif spell.type == 'BlueMagic' then
                -- Defined Set
                if sets.Midcast[spell.english] then
                    merge_report(built_set, sets.Midcast[spell.english])
                    -- Check for an elemental set
                    if BlueNuke:contains(spell.english) then built_set = elemental_check(spell, built_set) end
                else
                    if sets.Midcast.BlueMagic then
                        -- Physical blue magic: damage comes from mainhand weapon
                        -- accuracy, DEX/Accuracy and physical Attack.  Deliberately skips
                        -- elemental_check -- obi and Orpheus scale magic damage only.
                        if BluePhysical:contains(spell.english) then
                            if sets.Midcast.BlueMagic.Physical then
                                merge_report(built_set, sets.Midcast.BlueMagic.Physical)
                            else
                                warn('sets.Midcast.BlueMagic.Physical not found!')
                            end
                            -- Breath damage scales off the caster's HP and level only.
                            -- MAB, INT and Blue Magic Skill contribute nothing, so this
                            -- also skips elemental_check.
                        elseif BlueBreath:contains(spell.english) then
                            if sets.Midcast.BlueMagic.Breath then
                                merge_report(built_set, sets.Midcast.BlueMagic.Breath)
                            else
                                warn('sets.Midcast.BlueMagic.Breath not found!')
                            end
                            -- Defined Blue Nukes
                        elseif BlueNuke:contains(spell.english) then
                            if sets.Midcast.BlueMagic.Nuke then
                                merge_report(built_set, sets.Midcast.BlueMagic.Nuke)
                            else
                                warn('sets.Midcast.BlueMagic.Nuke not found!')
                            end
                            built_set = elemental_check(spell, built_set)
                            -- Spells that benifit from Blue Magic Skill
                        elseif BlueSkill:contains(spell.english) then
                            if sets.Midcast.BlueMagic.Skill then
                                merge_report(built_set, sets.Midcast.BlueMagic.Skill)
                            else
                                warn('sets.Midcast.BlueMagic.Skill not found!')
                            end
                            -- Fixed-potency buffs: only duration is influenced by gear,
                            -- so these must not borrow the skill set.
                        elseif BlueBuff:contains(spell.english) then
                            if sets.Midcast.BlueMagic.Buff then
                                merge_report(built_set, sets.Midcast.BlueMagic.Buff)
                            else
                                warn('sets.Midcast.BlueMagic.Buff not found!')
                            end
                        elseif BlueTank:contains(spell.english) then
                            if sets.Midcast.BlueMagic.Enmity then
                                merge_report(built_set, sets.Midcast.BlueMagic.Enmity)
                            else
                                warn('sets.Midcast.BlueMagic.Enmity not found!')
                            end
                        elseif BlueHealing:contains(spell.english) then
                            if sets.Midcast.BlueMagic.Healing then
                                merge_report(built_set, sets.Midcast.BlueMagic.Healing)
                            else
                                warn('sets.Midcast.BlueMagic.Healing not found!')
                            end
                        elseif BlueACC:contains(spell.english) then
                            if sets.Midcast.BlueMagic.ACC then
                                merge_report(built_set, sets.Midcast.BlueMagic.ACC)
                            else
                                warn('sets.Midcast.BlueMagic.ACC not found!')
                            end
                        end
                        if buffactive["Diffusion"] then
                            if sets.Diffusion then
                                merge_report(built_set, sets.Diffusion)
                                info('Diffusion Augment')
                            else
                                warn('sets.Diffusion not found!')
                            end
                        end
                    else
                        warn('sets.Midcast.BlueMagic not found!')
                    end
                end
                -- Geomancy
            elseif spell.type == 'Geomancy' then
                if sets.Geomancy then
                    -- Defined Set
                    if sets.Geomancy[spell.english] then
                        merge_report(built_set, sets.Geomancy[spell.english])
                        -- Indi Equipment
                    elseif Indicolure_List:contains(spell.english) then
                        if sets.Geomancy.Indi then
                            merge_report(built_set, sets.Geomancy.Indi)
                            if spell.target.type ~= "SELF" then
                                if sets.Geomancy.Indi.Entrust then
                                    merge_report(built_set, sets.Geomancy.Indi.Entrust)
                                    info('Indicolure set - Entrust')
                                else
                                    warn('sets.Geomancy.Indi.Entrust not found!')
                                end
                            end
                        else
                            warn('sets.Geomancy.Indi not found!')
                        end
                        -- Bubble Equipment
                    elseif Geomancy_List:contains(spell.english) then
                        if sets.Geomancy.Geo then
                            merge_report(built_set, sets.Geomancy.Geo)
                        else
                            warn('sets.Geomancy.Geo not found!')
                        end
                    end
                else
                    warn('sets.Geomancy not found!')
                end
                -- Trust
            elseif spell.type == 'Trust' then
                log('Nothing Defined')
                -- BloodPactRage and BloodPactWard
            elseif spell.type == "BloodPactWard" or spell.type == "BloodPactRage" then
                -- BP Timer gear needs to swap here if not under Astral Conduit
                if not buffactive["Astral Conduit"] then
                    if sets.Midcast[spell.english] then
                        merge_report(built_set, sets.Midcast[spell.english])
                    elseif sets.Midcast.BP then
                        merge_report(built_set, sets.Midcast.BP)
                    else
                        warn('sets.Midcast.BP not found!')
                    end
                else
                    -- Astral Conduit active so don't swap gear
                    built_set = {}
                end
                -- Monster
            elseif spell.type == 'Monster' then
                if sets.Ready then
                    merge_report(built_set, sets.Ready)
                else
                    warn('sets.Ready not found!')
                end
                -- Elemental Siphon
            elseif spell.name == "Elemental Siphon" then
                if sets.Midcast[spell.english] then
                    merge_report(built_set, sets.Midcast[spell.english])
                else
                    if sets.Midcast.SummoningMagic then
                        merge_report(built_set, sets.Midcast.SummoningMagic)
                    else
                        warn('sets.Midcast.SummoningMagic not found!')
                    end
                end
                -- Summon Avatar
            elseif spell.type == "SummonerPact" then
                if sets.Midcast[spell.english] then
                    merge_report(built_set, sets.Midcast[spell.english])
                else
                    if sets.Midcast.Summon then
                        merge_report(built_set, sets.Midcast.Summon)
                    else
                        warn('sets.Midcast.Summon not found!')
                    end
                end
            end
        else
            warn('sets.Midcast not found!')
        end
        merge_report_branch_end()
        -- Auto-cancel existing buffs
        if spell.name == "Stoneskin" and buffactive["Stoneskin"] then
            send_command('cancel 37;')
        elseif spell.name == "Sneak" and buffactive["Sneak"] and spell.target.type == "SELF" then
            send_command('cancel 71;')
        elseif spell.name == "Spectral Jig" and buffactive["Sneak"] then
            send_command('cancel 71;')
        elseif spell.name == "Utsusemi: Ichi" and buffactive["Copy Image"] then
            send_command('wait .5;cancel 66;')
        end
        -- Weapon Checks for midcast
        -- If it set to unlocked it will not swap the weapons even if defined in the built_set job lua
        if state.WeaponMode.value ~= "Unlocked" then
            if spell.type == 'Geomancy' then
                log('Swap Weapon due to Geomancy')
            elseif state.WeaponMode.value == "Locked" then
                merge_report(built_set,
                    { main = player.equipment.main, sub = player.equipment.sub, range = player.equipment.range })
                log(built_set)
            else
                if sets.Weapons then
                    if sets.Weapons[state.WeaponMode.value] then
                        merge_report(built_set, sets.Weapons[state.WeaponMode.value])
                    else
                        warn('sets.Weapons.' .. state.WeaponMode.value .. ' not found!')
                    end
                    if not TwoHand and not DualWield then
                        if sets.Weapons.Shield then
                            merge_report(built_set, sets.Weapons.Shield)
                        else
                            warn('sets.Weapons.Shield not found!')
                        end
                    end
                else
                    warn('sets.Weapons not found!')
                end
            end
        end

        --Swap in bard song weapons no matter the mode
        if spell.type == 'BardSong' then --and spell.target.type ~= 'MONSTER' then
            -- Weapons
            if sets.Weapons.Songs then
                merge_report(built_set, sets.Weapons.Songs)
                if sets.Weapons.Songs.Midcast then
                    merge_report(built_set, sets.Weapons.Songs.Midcast)
                    if not DualWield and not TwoHand then
                        if sets.Weapons.Shield then
                            merge_report(built_set, sets.Weapons.Shield)
                        else
                            warn('sets.Weapons.Shield not found!')
                        end
                    end
                else
                    warn('sets.Weapons.Songs.Midcast not found!')
                end
            else
                warn('sets.Weapons.Songs not found!')
            end

            -- Instruments for pianissimo buffs
            if spell.target.id ~= player.id and not SongCount:contains(spell.name) and (spell.target.type == 'PLAYER' or spell.target.type == 'NPC') then
                log('Pianissimo Check')
                if Instrument then
                    --Check for pianissimo Weapons
                    if Instrument.Pianissimo then
                        merge_report(built_set, { range = equip_pianissimo_gear(spell) })
                    else
                        warn('Instrument.Pianissimo not found!')
                    end
                else
                    warn('Instrument not found!')
                end
            end
        end
        -- If TH mode is on - check if new mob and then equip TH gear
        if state.TreasureMode.value ~= 'None' and spell.target.type == 'MONSTER' and not th_info.tagged_mobs[spell.target.id] and sets.TreasureHunter then
            merge_report(built_set, sets.TreasureHunter)
            info('[' .. spell.english .. '] Set with Treasure Hunter')
        end
        -- Built built_set to return
        return built_set
    end

    -- Build the set restored once an action completes.
    function aftercastequip(spell)
        -- Dont change gear as the pet is still performing an action
        if pet_midaction() then
            merge_report_begin()
            return
        else
            local built_set = choose_set()
            if choose_set_custom then
                built_set = set_combine(built_set, choose_set_custom())
            else
                info('choose_set_custom() not found!')
            end
            return built_set
        end
    end

    -- Apply day and weather bonus gear, and the elemental obi or staff when the
    -- element matches.
    function elemental_check(spell, built_set)
        -- Rule for Cures
        if spell.name:contains('Cure') or spell.name:contains('Cura') then
            if world.weather_element == spell.element or spell.element == world.day_element then
                -- Verify player has the gear
                local Obi = player.inventory["Hachirin-no-Obi"] or player.wardrobe["Hachirin-no-Obi"] or
                    player.wardrobe2["Hachirin-no-Obi"]
                    or player.wardrobe3["Hachirin-no-Obi"] or player.wardrobe4["Hachirin-no-Obi"] or
                    player.wardrobe5["Hachirin-no-Obi"]
                    or player.wardrobe6["Hachirin-no-Obi"] or player.wardrobe7["Hachirin-no-Obi"] or
                    player.wardrobe8["Hachirin-no-Obi"]

                local Staff = player.inventory["Chatoyant Staff"] or player.wardrobe["Chatoyant Staff"] or
                    player.wardrobe2["Chatoyant Staff"]
                    or player.wardrobe3["Chatoyant Staff"] or player.wardrobe4["Chatoyant Staff"] or
                    player.wardrobe5["Chatoyant Staff"]
                    or player.wardrobe6["Chatoyant Staff"] or player.wardrobe7["Chatoyant Staff"] or
                    player.wardrobe8["Chatoyant Staff"]

                --Twilight Cape will only be used for Cura and Curaga.  Prefer Alaunus' cape for single target cures.
                local Cape = player.inventory["Twilight Cape"] or player.wardrobe["Twilight Cape"] or
                    player.wardrobe2["Twilight Cape"]
                    or player.wardrobe3["Twilight Cape"] or player.wardrobe4["Twilight Cape"] or
                    player.wardrobe5["Twilight Cape"]
                    or player.wardrobe6["Twilight Cape"] or player.wardrobe7["Twilight Cape"] or
                    player.wardrobe8["Twilight Cape"]

                -- Check for bonus
                if spell.element == world.day_element then
                    if Obi then merge_into(built_set, { waist = "Hachirin-no-Obi" }) end
                    if Staff then
                        merge_into(built_set, sets.Weapons['Light Bonus'])
                        merge_into(built_set, { main = "Chatoyant Staff" })
                    end
                    if Cape and spell.name:contains('Cura') then merge_into(built_set, { back = "Twilight Cape" }) end
                    windower.add_to_chat(8, '[' .. world.day_element .. '] day - using Bonus Gear')
                elseif world.weather_element == spell.element then
                    if Obi then merge_into(built_set, { waist = "Hachirin-no-Obi" }) end
                    if Staff then
                        merge_into(built_set, sets.Weapons['Light Bonus'])
                        merge_into(built_set, { main = "Chatoyant Staff" })
                    end
                    if Cape and spell.name:contains('Cura') then merge_into(built_set, { back = "Twilight Cape" }) end
                    windower.add_to_chat(8, 'Weather is [' .. world.weather_element .. '] - using Bonus Gear')
                end
            end
            -- This function swaps in the Orpheus or Hachirin as needed
        else
            -- Check for player gear
            local Osash = player.inventory["Orpheus's Sash"] or player.wardrobe["Orpheus's Sash"] or
                player.wardrobe2["Orpheus's Sash"]
                or player.wardrobe3["Orpheus's Sash"] or player.wardrobe4["Orpheus's Sash"] or
                player.wardrobe5["Orpheus's Sash"]
                or player.wardrobe6["Orpheus's Sash"] or player.wardrobe7["Orpheus's Sash"] or
                player.wardrobe8["Orpheus's Sash"]
            local Obi = player.inventory["Hachirin-no-Obi"] or player.wardrobe["Hachirin-no-Obi"] or
                player.wardrobe2["Hachirin-no-Obi"]
                or player.wardrobe3["Hachirin-no-Obi"] or player.wardrobe4["Hachirin-no-Obi"] or
                player.wardrobe5["Hachirin-no-Obi"]
                or player.wardrobe6["Hachirin-no-Obi"] or player.wardrobe7["Hachirin-no-Obi"] or
                player.wardrobe8["Hachirin-no-Obi"]

            -- Matching double weather (w/o day conflict).
            if spell.element == world.weather_element and world.weather_intensity == 2 and Obi then
                merge_into(built_set, { waist = "Hachirin-no-Obi" })
                info('Weather is Double [' .. world.weather_element .. '] - using Hachirin-no-Obi')
                -- Matching day and weather.
            elseif spell.element == world.day_element and spell.element == world.weather_element and Obi then
                merge_into(built_set, { waist = "Hachirin-no-Obi" })
                info('[' ..
                    world.day_element .. '] day and weather is [' .. world.weather_element .. '] - using Hachirin-no-Obi')
                -- Target distance less than 6 yalms
            elseif spell.target.distance < (6 + spell.target.model_size) and Osash then
                merge_into(built_set, { waist = "Orpheus's Sash" })
                info('Distance is [' .. round(spell.target.distance, 2) .. '] using Orpheus Sash')
                -- Match day or weather.
            elseif (spell.element == world.day_element or spell.element == world.weather_element) and Obi then
                merge_into(built_set, { waist = "Hachirin-no-Obi" })
                info('[' ..
                    world.day_element .. '] day and weather is [' .. world.weather_element .. '] - using Hachirin-no-Obi')
            end
        end
        return built_set
    end

    -- Select the instrument and song set for a bard song.
    function equip_song_gear(spell, instrument)
        local song_set = {}
        if string.find(spell.english, 'Finale') and sets.Midcast.Finale then
            song_set = sets.Midcast.Finale
        elseif string.find(spell.english, 'Lullaby') and sets.Midcast.Lullaby then
            song_set = sets.Midcast.Lullaby
        elseif string.find(spell.english, 'Threnody') and sets.Midcast.Threnody then
            song_set = sets.Midcast.Threnody
        elseif string.find(spell.english, 'Elegy') and sets.Midcast.Elegy then
            song_set = sets.Midcast.Elegy
        elseif string.find(spell.english, 'Requiem') and sets.Midcast.Requiem then
            song_set = sets.Midcast.Requiem
        elseif string.find(spell.english, 'March') and sets.Midcast.March then
            song_set = sets.Midcast.March
        elseif string.find(spell.english, 'Minuet') and sets.Midcast.Minuet then
            song_set = sets.Midcast.Minuet
        elseif string.find(spell.english, 'Madrigal') and sets.Midcast.Madrigal then
            song_set = sets.Midcast.Madrigal
        elseif string.find(spell.english, 'Ballad') and sets.Midcast.Ballad then
            song_set = sets.Midcast.Ballad
        elseif string.find(spell.english, 'Scherzo') and sets.Midcast.Scherzo then
            song_set = sets.Midcast.Scherzo
        elseif string.find(spell.english, 'Mazurka') and sets.Midcast.Mazurka then
            song_set = sets.Midcast.Mazurka
        elseif string.find(spell.english, 'Paeon') and sets.Midcast.Paeon then
            song_set = sets.Midcast.Paeon
        elseif string.find(spell.english, 'Carol') and sets.Midcast.Carol then
            song_set = sets.Midcast.Carol
        elseif string.find(spell.english, 'Minne') and sets.Midcast.Minne then
            song_set = sets.Midcast.Minne
        elseif string.find(spell.english, 'Mambo') and sets.Midcast.Mambo then
            song_set = sets.Midcast.Mambo
        elseif string.find(spell.english, 'Etude') and sets.Midcast.Etude then
            song_set = sets.Midcast.Etude
        elseif string.find(spell.english, 'Prelude') and sets.Midcast.Prelude then
            song_set = sets.Midcast.Prelude
        elseif string.find(spell.english, 'Dirge') and sets.Midcast.Dirge then
            song_set = sets.Midcast.Dirge
        elseif string.find(spell.english, 'Sirvente') and sets.Midcast.Sirvente then
            song_set = sets.Midcast.Sirvente
        elseif string.find(spell.english, 'Aria') and sets.Midcast.Aria then
            song_set = sets.Midcast.Aria
        else
            warn('[' .. spell.english .. '] set not found!')
        end
        song_set['range'] = instrument
        return song_set
    end

    -- Select the instrument for a Pianissimo song.
    function equip_pianissimo_gear(spell)
        if spell.english == "Honor March" or spell.english == "Aria of Passion" then return end
        if Instrument then
            if Instrument.Pianissimo then
                log('Check Pianissimo Instrument')
                if string.find(spell.english, 'March') and Instrument.Pianissimo.March then
                    return Instrument.Pianissimo.March
                elseif string.find(spell.english, 'Minuet') and Instrument.Pianissimo.Minuet then
                    return Instrument.Pianissimo.Minuet
                elseif string.find(spell.english, 'Madrigal') and Instrument.Pianissimo.Madrigal then
                    return Instrument.Pianissimo.Madrigal
                elseif string.find(spell.english, 'Ballad') and Instrument.Pianissimo.Ballad then
                    return Instrument.Pianissimo.Ballad
                elseif string.find(spell.english, 'Scherzo') and Instrument.Pianissimo.Scherzo then
                    return Instrument.Pianissimo.Scherzo
                elseif string.find(spell.english, 'Mazurka') and Instrument.Pianissimo.Mazurka then
                    return Instrument.Pianissimo.Mazurka
                elseif string.find(spell.english, 'Paeon') and Instrument.Pianissimo.Paeon then
                    return Instrument.Pianissimo.Paeon
                elseif string.find(spell.english, 'Carol') and Instrument.Pianissimo.Carol then
                    return Instrument.Pianissimo.Carol
                elseif string.find(spell.english, 'Minne') and Instrument.Pianissimo.Minne then
                    return Instrument.Pianissimo.Minne
                elseif string.find(spell.english, 'Mambo') and Instrument.Pianissimo.Mambo then
                    return Instrument.Pianissimo.Mambo
                elseif string.find(spell.english, 'Etude') and Instrument.Pianissimo.Etude then
                    return Instrument.Pianissimo.Etude
                elseif string.find(spell.english, 'Prelude') and Instrument.Pianissimo.Prelude then
                    return Instrument.Pianissimo.Prelude
                elseif string.find(spell.english, 'Dirge') and Instrument.Pianissimo.Dirge then
                    return Instrument.Pianissimo.Dirge
                elseif string.find(spell.english, 'Sirvente') and Instrument.Pianissimo.Sirvente then
                    return Instrument.Pianissimo.Sirvente
                else
                    return Instrument.Pianissimo
                end
            else
                warn('sets.Instrument.Pianissimo not found!')
            end
        else
            warn('sets.Instrument not found!')
        end
    end

    -- Return gear an action cannot be performed without, such as Marsyas for Honor
    -- March or a cloak for Impact.
    function check_equipment_spells(spell)
        local built_set
        --Equip weapon for Dispelga
        if spell.name == "Dispelga" then
            built_set = { main = "Daybreak" }
            -- Equip Marsyas
        elseif spell.name == "Honor March" then
            built_set = { range = "Marsyas" }
            -- Equip Loughnashade
        elseif spell.name == "Aria of Passion" then
            built_set = { range = "Loughnashade" }
            --Equip body for Impact
        elseif spell.name == "Impact" then
            local Crepuscular = player.inventory["Crepuscular Cloak"] or player.wardrobe["Crepuscular Cloak"] or
                player.wardrobe2["Crepuscular Cloak"]
                or player.wardrobe3["Crepuscular Cloak"] or player.wardrobe4["Crepuscular Cloak"] or
                player.wardrobe5["Crepuscular Cloak"]
                or player.wardrobe6["Crepuscular Cloak"] or player.wardrobe7["Crepuscular Cloak"] or
                player.wardrobe8["Crepuscular Cloak"]
            local Twilight = player.inventory["Twilight Cloak"] or player.wardrobe["Twilight Cloak"] or
                player.wardrobe2["Twilight Cloak"]
                or player.wardrobe3["Twilight Cloak"] or player.wardrobe4["Twilight Cloak"] or
                player.wardrobe5["Twilight Cloak"]
                or player.wardrobe6["Twilight Cloak"] or player.wardrobe7["Twilight Cloak"] or
                player.wardrobe8["Twilight Cloak"]
            -- Crepuscular Cloak Found
            if Crepuscular then
                log("Crepuscular Found")
                built_set = { head = empty, body = "Crepuscular Cloak", }
                -- Twilight Cloak Found
            elseif Twilight then
                log("Twilight Found")
                built_set = { head = empty, body = "Twilight Cloak", }
            end
        end
        return built_set
    end

    -- Verify enough ammo remains for the action, accounting for Barrage and the shot
    -- abilities, and warn before the last round is spent.
    function do_bullet_checks(spell, built_set)
        if spell and built_set then
            local bullet_name = built_set.ammo
            if bullet_name == 'empty' or not bullet_name then return end
            log('Ammo name is: ', bullet_name)

            local bullet_min_count = 1
            if spell.action_type == 'Ranged Attack' then
                if buffactive['Triple Shot'] then
                    bullet_min_count = 3
                elseif buffactive['Double Shot'] then
                    bullet_min_count = 2
                elseif buffactive['Barrage'] then
                    bullet_min_count = 8
                end
            end

            available_bullets = 0

            if player.inventory[bullet_name] then
                available_bullets = available_bullets +
                    player.inventory[bullet_name].count
            end
            if player.wardrobe[bullet_name] then
                available_bullets = available_bullets +
                    player.wardrobe[bullet_name].count
            end
            if player.wardrobe2[bullet_name] then
                available_bullets = available_bullets +
                    player.wardrobe2[bullet_name].count
            end
            if player.wardrobe3[bullet_name] then
                available_bullets = available_bullets +
                    player.wardrobe3[bullet_name].count
            end
            if player.wardrobe4[bullet_name] then
                available_bullets = available_bullets +
                    player.wardrobe4[bullet_name].count
            end
            if player.wardrobe5[bullet_name] then
                available_bullets = available_bullets +
                    player.wardrobe5[bullet_name].count
            end
            if player.wardrobe6[bullet_name] then
                available_bullets = available_bullets +
                    player.wardrobe6[bullet_name].count
            end
            if player.wardrobe7[bullet_name] then
                available_bullets = available_bullets +
                    player.wardrobe7[bullet_name].count
            end
            if player.wardrobe8[bullet_name] then
                available_bullets = available_bullets +
                    player.wardrobe8[bullet_name].count
            end

            log('Bullet Count [', available_bullets, ']')

            if available_bullets == 0 then
                -- If no ammo is available, give appropriate warning and end.
                if spell.type == 'CorsairShot' and player.equipment.ammo ~= 'empty' then
                    windower.add_to_chat(104,
                        'No Quick Draw ammo left.  Using what\'s currently equipped (' .. player.equipment.ammo .. ').')
                    return
                elseif spell.type == 'WeaponSkill' and player.equipment.ammo == Ammo.Bullet.RA then
                    windower.add_to_chat(104,
                        'No weaponskill ammo left.  Using what\'s currently equipped (standard ranged bullets: ' ..
                        player.equipment.ammo .. ').')
                    return
                else
                    windower.add_to_chat(104, 'No ammo (' .. tostring(bullet_name) .. ') available for that action.')
                    cancel_spell()
                    return
                end
            end

            -- Don't allow shooting or weaponskilling with ammo reserved for quick draw.
            if spell.type ~= 'CorsairShot' and available_bullets <= bullet_min_count then
                windower.add_to_chat(104, 'Not enough ammo.  Cancelling.')
                cancel_spell()
                return
            end

            -- Low ammo warning.
            if spell.type ~= 'CorsairShot' and state.warned.value == false and available_bullets > 1 and available_bullets <= Ammo_Warning_Limit then
                local msg = '*****  LOW AMMO WARNING: ' .. tostring(available_bullets) .. 'x ' .. bullet_name .. ' *****'
                local border = ""
                for i = 2, #msg do border = border .. "*" end
                windower.send_command('send @others input /echo ' .. msg .. '')
                windower.add_to_chat(167, border)
                windower.add_to_chat(167, msg)
                windower.add_to_chat(167, border)
                state.warned:set()
            elseif available_bullets > Ammo_Warning_Limit and state.warned then
                state.warned:reset()
            end
        end
    end

    -- Verify enough Shihei remains to recast Utsusemi.
    function do_Utsu_checks(spell)
        if spell.name == 'Utsusemi: Ichi' or spell.name == 'Utsusemi: Ni' or spell.name == 'Utsusemi: San' then
            local display_message = false
            local warning_level = 10
            local count = 0
            local available_shihei = player.inventory['Shihei']
            local available_shiki = player.inventory['Shikanofuda']
            -- Check for levels
            if available_shihei then
                if available_shihei.count < warning_level then
                    display_message = true
                    count = available_shihei.count
                end
            elseif available_shiki then
                if available_shiki.count < warning_level then
                    display_message = true
                    count = available_shiki.count
                end
            else
                display_message = true
            end
            -- Notify player is low
            if display_message then
                local msg = '*****  LOW TOOL WARNING: ' .. tostring(count) .. 'x *****'
                local border = ""
                for i = 1, #msg do border = border .. "*" end
                windower.send_command('send @others input /echo ' .. msg .. '')
                windower.add_to_chat(167, border)
                windower.add_to_chat(167, msg)
                windower.add_to_chat(167, border)
            end
        end
    end

    ------------------------------------------------------------------------------------------------
    -- SECTION 16 - GEARSWAP ACTION HOOKS
    ------------------------------------------------------------------------------------------------
    -- The functions GearSwap calls directly. Each combines the engine's set with the
    -- matching job-file hook, then equips the result.

    -- Validate an action before GearSwap composes its packet. Every rejection here
    -- calls cancel_spell(), which sets a flag rather than returning, so execution
    -- continues to the end of the function.
    function pretargetcheck(spell, action)
        if pet.isvalid and pet_midaction() then
            cancel_spell()
            return
        end

        local active_buffs = buffactive
        if active_buffs[BUFF_SLEEP] then
            cancel_spell()
            if sets.Idle then equip(sets.Idle) else warn('sets.Idle not found!') end
            if sets.Weapons then
                if sets.Weapons.Sleep then equip(sets.Weapons.Sleep) else warn('sets.Weapons.Sleep not found!') end
            else
                warn('sets.Weapons not found!')
            end
            return
        elseif active_buffs[BUFF_STUN] or active_buffs[BUFF_PETRI] or active_buffs[BUFF_TERROR] then
            cancel_spell()
            if sets.Idle then equip(sets.Idle) else warn('sets.Idle not found!') end
            return
        elseif active_buffs[BUFF_KO] or active_buffs[BUFF_CHARM] then
            cancel_spell()
            return
        end

        if AutoItem and not active_buffs['Muddle'] then
            local inv = player.inventory
            if (active_buffs['Paralysis'] and spell.type == TYPE_JA) or (spell.action_type == TYPE_MS and active_buffs['Silence']) then
                if inv['Remedy'] then
                    cancel_spell()
                    windower.chat.input('/item "Remedy" <me>')
                    return
                end
            end
        end

        -- Weapon Skill Checks
        local s_type = spell.type
        if s_type == TYPE_WS then
            if player.tp < 1000 then
                cancel_spell()
                return
            elseif active_buffs['Amnesia'] then
                cancel_spell()
                info("Can't Weapon Skill due to amnesia.")
                return
            end

            -- Abilities Handling
        elseif s_type == TYPE_JA or s_type == 'Waltz' or s_type == 'BloodPactWard' or s_type == 'BloodPactRage' or s_type == 'PetCommand' then
            local recast_time = get_ability_recasts()[spell.recast_id]
            if recast_time and recast_time > 0 then
                local total_sec = recast_time / 60
                info(spell.name ..
                    ' [' .. math.floor(total_sec / 60) .. ':' .. string.format("%02d", total_sec % 60) .. ']')
                cancel_spell()
                return
            end
            if spell.type == 'Waltz' then
                local ja_resource = res.job_abilities[spell.id]
                if ja_resource and ja_resource.tp_cost then
                    if player.tp < ja_resource.tp_cost then
                        cancel_spell()
                        info('Insufficient TP for ' ..
                            spell.name .. ' [' .. player.tp .. '/' .. ja_resource.tp_cost .. ']')
                        return
                    end
                end
            end

            --Check for ability casts that are tracked for spell-received gear swapping
            --Notify eligible targets via IPC that a tracked spell is incoming
            if state.SpellReceived.value ~= "OFF" then
                if spell.name == "Divine Seal" then
                    divine_seal_predicted = true
                    if settings.debug then debug("Divine Seal detected while tracking. Divine_Seal_Predicted = True") end
                end
                local a_info = ability_info[spell.id]
                if a_info then
                    local target_mob = get_mob_by_id(spell.target.id)
                    if not player or not target_mob then return end

                    local target_name = spell.target.name
                    outgoing_cast_active = true
                    if settings.debug then
                        debug(player.name .. ' is using tracked ability measured at pretarget: ' ..
                            spell.name .. ' on ' .. target_name .. ' at ' .. get_time())
                    end

                    --AoE Checks
                    if a_info.aoe then
                        if settings.debug then debug("AoE Ability Cast Detected.  Calculating targets.") end
                        target_name = resolve_aoe_target_name(target_mob, target_name)
                    end
                    if settings.debug then
                        debug(string.format("IPC message sent: MIRDAIN|ABILITY|%s|%s|%s|%.0f", player.name, target_name,
                            spell.id, get_time()))
                    end
                    send_ipc(string.format("MIRDAIN|ABILITY|%s|%s|%s|%.0f", player.name, target_name, spell.id,
                        get_time()))
                end
            end
        elseif HasRecastTimer[s_type] then
            local recast_time = get_spell_recasts()[spell.recast_id]
            if recast_time and recast_time > 0 then
                local total_sec = recast_time / 60
                info(spell.name ..
                    ' [' .. math.floor(total_sec / 60) .. ':' .. string.format("%02d", total_sec % 60) .. ']')
                cancel_spell()
                return
            end

            --Check for spell casts that are tracked for spell-received gear swapping
            --Notify eligible targets via IPC that a tracked spell is incoming
            local s_info = spell_info[spell.id]
            if s_info and state.SpellReceived.value ~= "OFF" then
                local target_mob = get_mob_by_id(spell.target.id)
                if not target_mob then return end

                local target_name = spell.target.name
                outgoing_cast_active = true

                if settings.debug then
                    debug(player.name ..
                        ' is using tracked spell measured at pretarget: ' ..
                        spell.name .. ' on ' .. target_name .. ' at ' .. get_time())
                end

                local accession_active = active_buffs[366] or active_buffs['Accession']
                local majesty_active = active_buffs[621] or active_buffs['Majesty']
                local divine_veil_active = active_buffs[78] or active_buffs['Divine Seal']

                --AoE checks
                local has_yagrush = (s_info.divine and get_slot_item_name(sets.Midcast["Cursna"], 'main') == "Yagrush")
                if (s_info.aoe or ((accession_predicted or accession_active) and s_info.accession) or (majesty_active and s_info.majesty) or ((divine_seal_predicted or divine_veil_active or has_yagrush) and s_info.divine)) then
                    if settings.debug then debug("AoE Spell Cast Detected. Calculating targets.") end
                    target_name = resolve_aoe_target_name(target_mob, target_name)
                end
                if settings.debug then
                    debug(string.format("IPC message sent: MIRDAIN|SPELL|%s|%s|%s|%.0f", player.name, target_name,
                        spell.id,
                        get_time()))
                end
                send_ipc(string.format("MIRDAIN|SPELL|%s|%s|%s|%.0f", player.name, target_name, spell.id, get_time()))
            end
        elseif s_type == TYPE_SCH then
            local available_charges = get_current_stratagem_count()
            if available_charges == 0 then
                cancel_spell()
                info("Unable to use strategems. Available charges = 0")
            elseif spell.name == "Accession" then
                accession_predicted = true
                if settings.debug then debug("Accession detected while tracking. Accession_Predicted = True") end
            end
        end
    end

    -- Runs before GearSwap builds the action packet. The Hoxne critical window opens
    -- here, between the engine's guards and the job file's, so that instrument logic
    -- in either one flows through it.
    function pretarget(spell, action)
        --Calls the function in the include file for basic checks
        pretargetcheck(spell, action)

        -- Open the Hoxne critical window here: after the include's guards, before
        -- pretarget_custom, so a job file's instrument equips flow through the
        -- Allow-Critical filter rather than being stripped.
        local hoxne_opened = false
        if state.Hoxne.value == 'ON-Allow Critical' then
            local crit = critical_action_for(spell)
            if crit then
                if _global.cancel_spell then
                    log('Hoxne: window not opened; pretargetcheck cancelled [', spell.english, ']')
                else
                    hoxne_opened  = true
                    hoxne.window  = true
                    hoxne.slot    = crit.slot
                    hoxne.resume  = crit.resume
                    hoxne.expires = os.clock() + 20 -- watchdog only; aftercast sets the real countdown
                    -- Gear-gated songs need their implement now; Tomahawk and Angon
                    -- need their forced ammo. Ordinary songs and Geomancy need
                    -- nothing: their instruments arrive with the normal sets.
                    local gated   = check_equipment_spells(spell)
                    if gated then
                        equip(gated)
                    elseif crit.force then
                        equip({ [crit.slot] = crit.force })
                    end
                    log('Hoxne: critical window open for ', spell.english, ' (', crit.slot, ')')
                end
            end
        end

        --Calls the job specific function
        if pretarget_custom then pretarget_custom(spell, action) end

        -- If the job file cancelled after the window opened, collapse it soon.
        -- The 2 second grace covers the common cancel-equip-reissue pattern: a
        -- re-issued command re-opens the window before the tick re-locks.
        if hoxne_opened and _global.cancel_spell then
            hoxne.expires = os.clock() + 2
            log('Hoxne: pretarget_custom cancelled [', spell.english, ']; window closing in 2s')
        end
    end

    -- Runs after the packet is composed but before it is sent, so gear set here still
    -- reaches the action. Also arms the busy window.
    function precast(spell)
        -- Spell timed out
        if is_Busy and os.clock() - Spellstart > SpellCastTime then
            is_Busy = false
            SpellCastTime = 0
        end
        if not is_Busy then
            if RecastTimers[spell.type] then
                local cast_spell = res.spells[spell.id]
                -- assume 80% FC
                SpellCastTime = cast_spell.cast_time * .2 + 2.5
                -- Spell not delay set to default 2 sec
                if buffactive["Chainspell"] or buffactive["Nightingale"] then
                    SpellCastTime = 1
                end
            elseif spell.action_type == 'Ranged Attack' then
                SpellCastTime = 1.1
            else
                -- Set duration of JA/WS
                SpellCastTime = 1
            end
            -- Spell timer counter
            Spellstart = os.clock()
            is_Busy = true
        else
            log('Player is Busy [', spell.english, ']')
            cancel_spell()
            return
        end
        -- Fallback for actions that skip pretarget, such as menu casts. Without it
        -- the equip wrapper would strip instruments from every menu cast.
        if state.Hoxne.value == 'ON-Allow Critical' then
            local crit = critical_action_for(spell)
            if crit then
                if not hoxne.window then
                    hoxne.window  = true
                    hoxne.slot    = crit.slot
                    hoxne.resume  = crit.resume
                    hoxne.expires = os.clock() + 20
                    if crit.force then equip({ [crit.slot] = crit.force }) end
                    log('Hoxne: critical window open at precast for ', spell.english, ' (', crit.slot, ')')
                else
                    -- A new critical action inside an open window pushes the
                    -- deadline back out; without this it inherits the previous
                    -- action's countdown.
                    hoxne.slot    = crit.slot
                    hoxne.resume  = crit.resume
                    hoxne.expires = os.clock() + 20
                    log('Hoxne: critical window refreshed at precast for ', spell.english)
                end
            end
        end

        --Generate the correct set from the include file and custom function
        local built_set = precastequip(spell)
        merge_report_flush('precast', spell)
        -- Process a custom set if enabled
        if precast_custom then
            built_set = set_combine(built_set, precast_custom(spell))
        else
            warn('precast_custom() not found!')
        end
        -- Check the gear
        local equipment_spell_set = check_equipment_spells(spell)
        if equipment_spell_set then built_set = set_combine(built_set, equipment_spell_set) end
        -- Here is where gear is actually equipped
        equip(built_set)
    end

    -- Runs while the action is in flight.
    function midcast(spell)
        --Generate the correct set from the include file and custom function
        local built_set = midcastequip(spell)
        merge_report_flush('midcast')
        -- Process a custom set if enabled
        if midcast_custom then
            built_set = set_combine(built_set, midcast_custom(spell))
        else
            warn('midcast_custom() not found!')
        end
        -- Check the gear
        local equipment_spell_set = check_equipment_spells(spell)
        if equipment_spell_set then built_set = set_combine(built_set, equipment_spell_set) end
        -- Here is where gear is actually equipped
        equip(built_set)
    end

    -- Runs when the action completes or is interrupted, and starts the critical
    -- window's resume countdown.
    function aftercast(spell)
        --Reset state for spell-received gear tracking
        if state.SpellReceived.value ~= 'OFF' and outgoing_cast_active then
            outgoing_cast_active = false
            if settings.debug then
                debug(string.format("IPC message sent: MIRDAIN|COMPLETE|%s|%.0f", player.name,
                    get_time()))
            end
            send_ipc(string.format("MIRDAIN|COMPLETE|%s|%.0f", player.name, get_time()))
            if accession_predicted and not spell.interrupted and spell.type == "WhiteMagic" then
                accession_predicted = false
                if settings.debug then
                    debug(
                        "Accessioned spell probably used while tracking. Accession_Predicted = False")
                end
            end
            if divine_seal_predicted and not spell.interrupted and spell.type == "WhiteMagic" and spell.skill == "Healing Magic" then
                divine_seal_predicted = false
                if settings.debug then
                    debug(
                        "Divine Sealed spell probably used while tracking. Divine_Seal_Predicted = False")
                end
            end
        end
        --Generate the correct set from the include file and custom function
        local built_set = aftercastequip(spell)
        merge_report_flush('aftercast')
        if aftercast_custom then
            built_set = set_combine(built_set, aftercast_custom(spell))
        else
            warn('aftercast_custom() not found!')
        end
        -- here is where gear is actually equipped
        equip(built_set)
        -- Begin Reset Process - Spells have a hard delay where the JA's have a small delay
        if RecastTimers[spell.type] then
            SpellCastTime = 2.5
        elseif spell.action_type == 'Ranged Attack' then
            SpellCastTime = 1.1
        else
            SpellCastTime = 0
        end
        Spellstart = os.clock()

        -- Close the Hoxne critical window. Job abilities resume immediately; songs
        -- and Geomancy get a refreshing 5 second debounce so a wave stays one
        -- continuous window.
        local crit = hoxne.window and critical_action_for(spell) or nil
        if crit then
            hoxne.expires = os.clock() +
                ((crit.resume == 'delay') and (crit.delay or 5) or 0.5)
        end
    end

    -- Runs on any buff gain or loss.
    function buff_change(name, gain)
        if not is_Busy then
            --calls the include file and custom on a buff change
            local built_set = choose_set()
            if choose_set_custom then
                built_set = set_combine(built_set, choose_set_custom())
            else
                warn('choose_set_custom() not found!')
            end
            if buff_change_custom then
                built_set = set_combine(built_set, buff_change_custom(name, gain))
            else
                warn('buff_change_custom(name,gain) not found!')
            end
            -- Here is where gear is actually equipped
            equip(built_set)
        end
    end

    -- Runs on any player status change.
    function status_change(new, old)
        --calls the include file and custom on a state change
        local built_set = choose_set()
        if choose_set_custom then
            built_set = set_combine(built_set, choose_set_custom())
        else
            warn('choose_set_custom() not found!')
        end
        if status_change_custom then
            built_set = set_combine(built_set, status_change_custom(new, old))
        else
            warn('status_change_custom(name,gain) not found!')
        end
        -- Here is where gear is actually equipped
        equip(built_set)
    end

    -- Runs when a pet appears or disappears.
    function pet_change(pet, gain)
        -- A new pet is found
        local built_set = choose_set()
        if choose_set_custom then
            built_set = set_combine(built_set, choose_set_custom())
        else
            warn('choose_set_custom() not found!')
        end
        if pet_change_custom then
            built_set = set_combine(built_set, pet_change_custom(pet, gain))
        else
            warn('pet_change_custom() not found!')
        end
        -- Here is where gear is actually equipped
        equip(built_set)
    end

    -- Runs while a pet action is in flight.
    function pet_midcast(spell)
        if sets.Pet_Midcast then
            local built_set = sets.Pet_Midcast
            -- Specific sets are defined
            if sets.Pet_Midcast[spell.english] then
                built_set = set_combine(built_set, sets.Pet_Midcast[spell.english])
                info('[' .. spell.english .. '] Set')
            end
            -- User level commands
            if pet_midcast_custom then
                built_set = set_combine(built_set, pet_midcast_custom(spell))
            end
            -- Weapon Checks for precast
            -- If it set to unlocked it will not swap the weapons even if defined in the built_set job lua
            if state.WeaponMode.value ~= "Unlocked" then
                if state.WeaponMode.value == "Locked" then
                    built_set = set_combine(built_set,
                        { main = player.equipment.main, sub = player.equipment.sub, range = player.equipment.range })
                else
                    if sets.Weapons[state.WeaponMode.value] then
                        built_set = set_combine(built_set, sets.Weapons[state.WeaponMode.value])
                        if not TwoHand and not DualWield then
                            if sets.Weapons.Shield then
                                built_set = set_combine(built_set, sets.Weapons.Shield)
                            end
                        end
                    end
                end
                log('Midcast set equiping Offense Mode Gear')
            end
            equip(built_set)
        else
            warn('sets.Pet_Midcast not found!')
        end
    end

    -- Runs when a pet action completes.
    function pet_aftercast(spell)
        local built_set = choose_set()
        if pet_aftercast_custom then
            built_set = set_combine(built_set, pet_aftercast_custom(spell))
        end
        equip(built_set)
    end

    ------------------------------------------------------------------------------------------------
    -- SECTION 17 - MULTIBOX SPELL-RECEIVED TRACKING
    ------------------------------------------------------------------------------------------------
    -- Wears the matching received-gear set the instant another local character starts
    -- casting on this one, and releases it the moment the spell lands. Driven by the
    -- IPC messages registered in the final section.

    -- The set each spell_info/ability_info equip key selects, for the empty-set warning.
    local SR_SET_NAME = {
        cure_set          = 'sets.Cure_Received',
        cursna_set        = 'sets.Cursna_Received',
        phalanx_set       = 'sets.Phalanx_Received',
        protect_shell_set = 'sets.Protect_Shell_Received',
        regen_set         = 'sets.Regen_Received',
        refresh_set       = 'sets.Refresh_Received',
        waltz_set         = 'sets.Waltz_Received',
    }

    -- Equip the set for an incoming spell or ability and lock the slots it uses until
    -- the cast completes.
    local function equip_spell_received_gear(spell_id, spell_type)
        if settings.debug then debug("Equip gear function triggered: " .. spell_id .. ", " .. spell_type) end
        local s_info
        if spell_type == "spell" then
            s_info = spell_info[spell_id]
        elseif spell_type == "ability" then
            s_info = ability_info[spell_id]
        end
        if not s_info then
            warn("Unknown Spell for Spell Received Gear")
            return
        end

        --Calculate delta since cast start time in milliseconds
        --local elapsed_ms = get_time() - cast_start_time

        local spell_received_set = {}
        if s_info.equip == "cure_set" then
            if sets.Cure_Received then
                spell_received_set = sets.Cure_Received
            else
                warn("sets.Cure_Received not found!")
            end
        elseif s_info.equip == "cursna_set" then
            if sets.Cursna_Received then
                spell_received_set = sets.Cursna_Received
            else
                warn("sets.Cursna_Received not found!")
            end
        elseif s_info.equip == "phalanx_set" then
            if sets.Phalanx_Received then
                spell_received_set = sets.Phalanx_Received
            else
                warn("sets.Phalanx_Received not found!")
            end
        elseif s_info.equip == "protect_shell_set" then
            if sets.Protect_Shell_Received then
                spell_received_set = sets.Protect_Shell_Received
            else
                warn("sets.Protect_Shell_Received not found!")
            end
        elseif s_info.equip == "regen_set" then
            if sets.Regen_Received then
                spell_received_set = sets.Regen_Received
            else
                warn("sets.Regen_Received not found!")
            end
        elseif s_info.equip == "refresh_set" then
            if sets.Refresh_Received then
                spell_received_set = sets.Refresh_Received
            else
                warn("sets.Refresh_Received not found!")
            end
        elseif s_info.equip == "waltz_set" then
            if sets.Waltz_Received then
                spell_received_set = sets.Waltz_Received
            else
                warn("sets.Waltz_Received not found!")
            end
        else
            warn("Unknown Equip Set for Spell Received Gear")
        end

        if type(spell_received_set) == 'table' then
            -- Report the chosen set the way a cast does. There is no fallback
            -- chain here: the set either dresses the slots or nothing does.
            local set_name = SR_SET_NAME[s_info.equip]
            if set_name then
                if warn_if_empty(spell_received_set, set_name) then
                    info('[' .. set_name .. '][Not Usable] -> nothing to equip.')
                else
                    info('[' .. set_name .. '][Used]')
                end
            end
            equip(spell_received_set)
            if state.SpellReceived.value == "ON" then
                --Lock the slots of items from the spell received set to prevent other
                --actions from overwriting until cast completion
                for slot, item in pairs(spell_received_set) do
                    disable(slot)

                    if settings.debug then debug("Locking " .. tostring(slot)) end
                    active_external_locks[slot] = true
                end
            end
        end
    end

    ------------------------------------------------------------------------------------------------
    -- SECTION 18 - TREASURE HUNTER TRACKING
    ------------------------------------------------------------------------------------------------
    -- Remembers which mobs have already been tagged so TH gear is worn only when it
    -- can still apply.

    -- On changing targets while engaged, rebuild gear so TH is worn for a new mob.
    function on_target_change_for_th(new_index, old_index)
        -- Only care about changing targets while we're engaged, either manually or via current target death.
        if player.status == 'Engaged' and state.TreasureMode.value ~= 'None' then
            -- If  the current player.target is the same as the new mob then we're actually engaged with it.
            -- If it's different than the last known mob, then we've actually changed targets.
            if player.target.index == new_index and new_index ~= th_info.last_player_target_index then
                th_info.last_player_target_index = player.target.index
                local built_set = choose_set()
                if choose_set_custom then
                    built_set = set_combine(built_set, choose_set_custom())
                else
                    warn('choose_set_custom() not found!')
                end
                equip(built_set)
            end
        end
    end

    -- Drop a mob from the tagged table when it dies.
    function on_incoming_chunk_for_th(id, data, modified, injected, blocked)
        -- Action Packet
        if id == 0x29 and state.TreasureMode.value ~= 'None' then
            local target_id = data:unpack('I', 0x09)
            local message_id = data:unpack('H', 0x19) % 32768
            -- Remove mobs that die from our tagged mobs list.
            if th_info.tagged_mobs[target_id] then
                -- 6 == actor defeats target
                -- 20 == target falls to the ground
                if message_id == 6 or message_id == 20 then
                    if settings.debug then
                        windower.add_to_chat(123, 'Mob ' ..
                            target_id .. ' died. Removing from tagged mobs table.')
                    end
                    th_info.tagged_mobs[target_id] = nil
                end
            end
        end
    end

    -- Clear the tagged table on zoning.
    function on_zone_change_for_th(new_zone, old_zone)
        -- Hoxne does not survive a zone. Reset before UnlockByMode so the hold is
        -- gone and range/ammo unlock with everything else. The Ampulla itself comes
        -- out via the release tick, routed through a wrapped command, because equips
        -- from this raw handler are discarded.
        if state.Hoxne.value ~= 'OFF' then
            state.Hoxne:set('OFF')
            hoxne.window        = false
            hoxne.slot          = nil
            hoxne.resume        = nil
            hoxne.release_tries = 10
            hoxne.release_next  = os.clock() + 3
            info('Hoxne Ampulla Mode: [OFF] (zoned)')
            display_box_update()
        end
        UnlockByMode()
        if settings.debug then windower.add_to_chat(123, 'Zoning. Clearing tagged mobs table.') end
        th_info.tagged_mobs:clear()
        -- Turn off for zones
        state.AutoBuff:set('OFF')
    end

    -- Drop mobs with no activity for three minutes, covering deaggro and player death.
    function cleanup_tagged_mobs()
        -- If it's been more than 3 minutes since an action on or by a tagged mob,
        -- remove them from the tagged mobs list.
        local current_time = os.clock()
        local remove_mobs = S {}

        --log('The TH table contains ['..tostring(#th_info.tagged_mobs)..'] entries.')

        -- Search list and flag old entries.
        for target_id, action_time in pairs(th_info.tagged_mobs) do
            local time_since_last_action = current_time - action_time
            if time_since_last_action > 180 then
                remove_mobs:add(target_id)
                if settings.debug then
                    windower.add_to_chat(123,
                        'Over 3 minutes since last action on mob ' .. target_id .. '. Removing from tagged mobs list.')
                end
            end
        end

        -- Clean out mobs flagged for removal.
        for mob_id, _ in pairs(remove_mobs) do
            th_info.tagged_mobs[mob_id] = nil
        end
    end

    ------------------------------------------------------------------------------------------------
    -- SECTION 19 - AUTOMATION AND COMBAT MONITORING
    ------------------------------------------------------------------------------------------------
    -- Periodic and reactive behaviour: buff upkeep, burst reporting, trait checks and
    -- the main polling engine.

    -- Ask the job file for a buff to apply, then issue it as an ability or a spell.
    function check_buff()
        -- Auto Buff is on and not in a town
        if not is_Busy and state.AutoBuff.value ~= 'OFF' and not Cities:contains(world.area) and not buffactive['Stun'] and not buffactive['Terror'] then
            -- Set defaults
            local command_JA = 'None'
            local command_SP = 'None'

            -- Spells
            if not is_moving and check_buff_SP then command_SP = check_buff_SP() end

            -- Job Abilities
            if check_buff_JA then command_JA = check_buff_JA() end

            if command_JA ~= 'None' and not buffactive['Amnesia'] then
                command_JA_execute(command_JA)
            elseif command_SP ~= 'None' then
                command_SP_execute(command_SP)
            end
        end
    end

    -- Execute a job ability by name.
    function command_JA_execute(command_JA)
        local cast_ability = res.job_abilities:with('en', command_JA)
        local target = ''
        if tostring(cast_ability.targets) == "{Self}" then
            target = '<me>'
        elseif tostring(cast_ability.targets) == "{Enemy}" then
            target = '<bt>'
        else
            target = '<me>'
        end
        --log('input /ja "'..command_JA..'" '..target..'')
        windower.chat.input('/ja "' .. command_JA .. '" ' .. target .. '')
    end

    -- Execute a spell by name.
    function command_SP_execute(command_SP)
        local cast_spell = res.spells:with('en', command_SP)
        local spell_cast_time = cast_spell.cast_time
        local target = ''
        if tostring(cast_spell.targets) == '{Self}' then
            target = '<me>'
        elseif tostring(cast_spell.targets) == '{Enemy}' then
            target = '<bt>'
        else
            target = '<me>'
        end
        --log('input /ma "'..command_SP..'" '..target..'')
        windower.chat.input('/ma "' .. command_SP .. '" ' .. target .. '')
    end

    -- Use Escha temporary items.
    function escha_temps()
        info('Escha Temps')
        windower.send_command(
            "input /item \"Monarch's Drink\" <me>;wait 2.5;input /item \"Braver's Drink\" <me>;wait 2.5;input /item \"Fighter's Drink\" <me>;wait 2.5;input /item \"Champion's Drink\" <me>;wait 2.5;input /item \"Soldier's Drink\" <me>;wait 2.5;input /item \"Barbarian's Drink\" <me>")
    end

    -- Report the element and window of a skillchain so a burst can be timed.
    function run_burst(data)
        local target = data.targets[1]
        local action = target and target.actions[1]
        if not action then return end
        if (action.add_effect_message > 287 and action.add_effect_message < 302)     -- Normal SC DMG
            or (action.add_effect_message > 384 and action.add_effect_message < 399) -- SC Heals
            or (action.add_effect_message > 766 and action.add_effect_message < 771) -- Umbra/Radiance
        then
            log('There was a skillchain')
            local t = windower.ffxi.get_mob_by_id(data.targets[1].id)
            -- valid party target and within range
            if t and t.spawn_type == 16 and t.distance:sqrt() < 21 then
                -- Update the enemy to track
                last_skillchain_id = t.id
                last_skillchain_time = os.clock()
                last_skillchain_elements = {}
                log('Skillchain detected')
                -- get the type of skillchain
                local skillchain = skillchains[action.add_effect_message]
                -- Find the elements
                for index, element in pairs(skillchain.elements) do
                    last_skillchain_elements[element] = element
                end
                log(last_skillchain_elements)
            end
            -- This is used to stop bursting if a ws happened to close the window
        elseif data.category == 3 and data.param ~= 0 then
            local t = windower.ffxi.get_mob_by_id(data.targets[1].id)
            if t and t.id == last_skillchain_id then
                log('Skillchain is closed for [', last_skillchain_id, ']')
                last_skillchain_elements = {}
                last_skillchain_id = 0
                last_skillchain_time = 0
            end
        end
    end

    -- Cancel a buff by name or id, using the cancel addon's packet where available.
    function cancel(...)
        local command = table.concat({ ... }, ' ')
        if not command then return end
        local status_id_tab = command:split(',')
        status_id_tab.n = nil
        local ids = {}
        local buffs = {}
        for _, v in pairs(player.buffs) do
            for _, r in pairs(status_id_tab) do
                if windower.wc_match(res.buffs[v][Language], r) or windower.wc_match(tostring(v), r) then
                    cancel_buff(v)
                    break
                end
            end
        end
    end

    -- Send the cancel packet for a buff id directly.
    function cancel_buff(id)
        windower.packets.inject_outgoing(0xF1, string.char(0xF1, 0x04, 0, 0, id % 256, math.floor(id / 256), 0, 0)) -- Inject the cancel packet
    end

    -- Refresh the dual wield trait after a job or subjob change.
    function dual_wield_check()
        local current_abilities = windower.ffxi.get_abilities()
        if table.contains(current_abilities.job_traits, 18) then -- Dual Wield trait
            DualWield = true
        else
            DualWield = false
        end
    end

    -- Refresh the two-handed weapon flag from the current weapon set.
    function two_hand_check()
        if sets.Weapons[state.WeaponMode.value] and sets.Weapons[state.WeaponMode.value]['main'] then
            local weapon_name = sets.Weapons[state.WeaponMode.value]['main']
            if type(weapon_name) == "table" then weapon_name = sets.Weapons[state.WeaponMode.value]['main'].name end
            local Main_Weapon = res.items:with('en', weapon_name)
            if Main_Weapon then
                --log('Weapon:['..Main_Weapon.en..']')
                local Skill_type = Main_Weapon.skill
                if Skill_type == 4 or Skill_type == 6 or Skill_type == 7 or Skill_type == 8 or Skill_type == 10 or Skill_type == 12 then
                    TwoHand = true
                else
                    TwoHand = false
                end
            else
                TwoHand = false
            end
        end
    end

    -- The main polling engine. Bound to outgoing chunk, so it does not tick reliably
    -- while the character is idle; anything that must run while standing still
    -- belongs on prerender instead. Gated to 0.1 seconds.
    function main_engine()
        local now = os.clock()
        -- Spell timed out
        if is_Busy and now - Spellstart > SpellCastTime then
            is_Busy = false
            SpellCastTime = 0
        end
        -- Make sure not update faster than .1 seconds
        if now - main_engine_time < .1 then return end
        -- Update the debug UI if visible
        if settings.debug then debug_box_update() end
        -- Hoist the buff table and status out of the repeated lookups below
        local active_buffs = buffactive
        local player_status = player and player.status
        -- Go no farther as you are dead
        if not player or player_status == "Dead" or player_status == "Engaged dead" or active_buffs['Charm'] or active_buffs['Sleep'] then return end
        -- Status Ailment Check
        if not active_buffs['Paralysis'] and not active_buffs['Silence'] and not active_buffs['Muddle'] then
            check_buff()
        end
        local position = get_mob_by_id(player.id)
        if position and not active_buffs['Mounted'] and not is_Busy then
            -- Compare squared distance: saves a sqrt and three pow calls per poll.
            local dx = position.x - Location.x
            local dy = position.y - Location.y
            local dz = position.z - Location.z
            local movement = (dx * dx + dy * dy + dz * dz) > 0.25 -- 0.5 yalms, squared
            if movement and not is_moving then
                if player_status ~= "Engaged" then
                    is_moving = true
                    Require_Update = true
                    --windower.chat.input('/echo Moving! Status: '..player.status..'')
                end
            elseif not movement and is_moving then
                is_moving = false
                Require_Update = true
                --windower.chat.input('/echo Stopped Moving! Status: '..player.status..'')
            end
            Location.x = position.x
            Location.y = position.y
            Location.z = position.z
        end

        if Require_Update and not is_Busy then
            equip_set_command()
            Require_Update = false
        end

        -- 30 second cycle timer
        if now - UpdateTime1 > 30 then
            dual_wield_check()
            cleanup_tagged_mobs()
            UpdateTime1 = now
        end

        -- function used for periodic updates - feature
        if Cycle_Timer and now - UpdateTime2 > 2 and not is_Busy then
            Cycle_Timer()
            UpdateTime2 = now
        end

        main_engine_time = now
    end

    ------------------------------------------------------------------------------------------------
    -- SECTION 20 - ON-SCREEN DISPLAY
    ------------------------------------------------------------------------------------------------
    -- The mode box and the debug box. Layout is cached and rebuilt only when a mode
    -- list changes, so a redraw is a string concatenation rather than a measurement.

    -- Appearance ----------------------------------------------------------------------------------

    -- Glyphs and colours for the mode indicators.
    local GLYPH = {
        on    = string.char(0xE2, 0x96, 0xA0), -- U+25A0 Black Square
        off   = string.char(0xE2, 0x96, 0xA0), -- U+25A0 Black Square
        prev  = string.char(0xE2, 0x97, 0x84), -- U+25C4 Black left-pointing arrow
        next  = string.char(0xE2, 0x96, 0xBA), -- U+25BA Black right-pointing arrow
        trunc = string.char(0xE2, 0x80, 0xA6), -- U+2026 Elipsis
    }
    local COLOR = {
        label = '150,150,150',
        value = '235,235,235',
        chev = '110,110,110',
        idle = '120,120,120', -- Hollow "off" circle
        good = '80,220,110',  -- Fully on - green
        warn = '255,170,60',  -- Partially on - amber for TH tag
        cyan = '90,200,255',  -- TH SATA mode
    }

    -- Wrap a string in a Windower colour tag.
    local function cs(color, s) return '\\cs(' .. color .. ')' .. s .. '\\cr' end

    -- Column separator.
    local SEP = '  '

    -- Modes rendered as a coloured circle rather than a labelled cell, with the value
    -- that counts as off and the colour for each active value.
    local GLYPH_FIELDS = {
        {
            label = 'SR',
            mode = 'SpellReceived',
            off = 'OFF',
            colors = { ['ON'] = COLOR.good }
        },
        {
            label = 'TH',
            mode = 'TreasureMode',
            off = 'None',
            colors = { ['Tag'] = COLOR.warn, ['Full Time'] = COLOR.good, ['SATA'] = COLOR.cyan }
        },
        {
            label = 'HOX',
            mode = 'Hoxne',
            off = 'OFF',
            colors = { ['ON-Allow Critical'] = COLOR.warn, ['ON-Locked'] = COLOR.good }
        },
    }

    -- Three-letter labels for known mode names.
    local UI_SHORT_ALIASES = {
        ['mode'] = 'MDE',
        ['pet'] = 'PET',
        ['tp mode'] = 'TPM',
        ['auto tank'] = 'TNK',
        ['tank'] = 'TNK',
        ['runes'] = 'RUN',
        ['rune'] = 'RUN',
    }

    -- Derive a three-letter label from a mode name: alias first, otherwise the first
    -- three letters of a single word, or two letters of the first word plus the
    -- initial of the last.
    local function derive_short(name)
        local alias = UI_SHORT_ALIASES[name:lower()]
        if alias then return alias end

        local words = {}
        for w in name:gmatch('%a+') do words[#words + 1] = w end

        local short
        if #words == 0 then
            short = name:upper()
        elseif #words == 1 then
            short = words[1]:upper()
        else
            short = (words[1]:sub(1, 2) .. words[#words]:sub(1, 1)):upper()
        end
        return (short .. '   '):sub(1, 3)
    end

    -- Layout --------------------------------------------------------------------------------------

    -- Label for a mode. An explicit UI_Short always wins and widens the column.
    local function status_label(explicit, name)
        if explicit and explicit ~= '' then return explicit end
        return derive_short(name)
    end

    -- Measure in display columns rather than bytes: glyphs are three bytes each and
    -- colour tags are zero width, so a composed string cannot be measured directly.
    local function cells(s)
        local n = 0
        for i = 1, #s do
            local b = s:byte(i)
            if b < 0x80 or b >= 0xC0 then n = n + 1 end
        end
        return n
    end

    -- Cached layout, rebuilt only when invalidated.
    local layout -- nil = rebuild on next draw

    -- Build the cells for one mode's option list.
    local function option_cells(m)
        local w = 0
        if type(m) == 'table' and m._track and m._track._type == 'list' then
            for _, v in ipairs(m) do
                local n = #tostring(v)
                if n > w then w = n end
            end
        end
        return w
    end

    -- Compute column widths and cache the result.
    local function build_layout()
        -- Modes are referenced by name, not by object, so a job file replacing a
        -- state table wholesale cannot force holding a stale reference.
        local fields = {
            { label = 'STN', mode = 'OffenseMode' },
            { label = 'DPS', mode = 'WeaponMode' },
        }
        if UI_Name ~= '' then
            fields[#fields + 1] = { label = status_label(UI_Short, UI_Name), mode = 'JobMode' }
        end
        if UI_Name2 ~= '' then
            fields[#fields + 1] = { label = status_label(UI_Short2, UI_Name2), mode = 'JobMode2' }
        end

        local label_w, value_w = 3, 0
        for _, f in ipairs(fields) do
            if #f.label > label_w then label_w = #f.label end
            value_w = math.max(value_w, option_cells(state[f.mode]))
        end

        local header_w = 0
        for i, g in ipairs(GLYPH_FIELDS) do
            header_w = header_w + #g.label + 2 -- label + space + circle
            if i > 1 then header_w = header_w + #SEP end
        end

        -- Stretch the value field so rows are at least as wide as the header.
        -- Row = label_w + 1 + chevron + space + value_w + space + chevron.
        value_w = math.max(value_w, header_w - label_w - 5,
            settings.Display_MinValueCells or 0)
        local row_w = label_w + value_w + 5

        -- Justify the header across the row: first entry left, second centred,
        -- third right, gaps filled with spaces.
        local w1 = #GLYPH_FIELDS[1].label + 2
        local w2 = #GLYPH_FIELDS[2].label + 2
        local w3 = #GLYPH_FIELDS[3].label + 2
        -- Equal gaps flanking the centre entry, widening the row by one cell
        -- when the free space is odd so the gaps never differ.
        local free = row_w - w1 - w2 - w3
        if free % 2 ~= 0 then
            value_w = value_w + 1
            row_w = row_w + 1
            free = free + 1
        end
        local gap1 = math.max(free / 2, 1)
        local gap2 = gap1

        layout = {
            fields = fields,
            label_w = label_w,
            value_w = value_w,
            head_pad1 = string.rep(' ', gap1),
            head_pad2 = string.rep(' ', gap2),
        }
    end

    -- Discard the cached layout, forcing a rebuild on the next redraw.
    function invalidate_layout() layout = nil end

    -- Render one glyph field.
    local function glyph_entry(g)
        local m = state[g.mode]
        local v = m and tostring(m.value) or ''
        if v == g.off then
            return cs(COLOR.label, g.label) .. ' ' .. cs(COLOR.idle, GLYPH.off)
        end
        return cs(COLOR.label, g.label) .. ' ' .. cs(g.colors[v] or COLOR.good, GLYPH.on)
    end

    -- Centre a chevron-flanked value within the value column. The chevrons keep a
    -- single space on each side of the value and travel with it.
    local function chevroned(v, w)
        local n = cells(v)
        if n > w then
            v, n = v:sub(1, w - 1) .. GLYPH.trunc, w -- values are ASCII; safe to sub
        end
        local pad = w - n
        local left = math.floor(pad / 2)
        return string.rep(' ', left)
            .. cs(COLOR.chev, GLYPH.prev) .. ' '
            .. cs(COLOR.value, v) .. ' '
            .. cs(COLOR.chev, GLYPH.next)
            .. string.rep(' ', pad - left)
    end

    -- Rendering -----------------------------------------------------------------------------------

    -- Redraw the mode box from current state.
    function display_box_update()
        if not layout then build_layout() end

        local head = T {}
        for _, g in ipairs(GLYPH_FIELDS) do head:insert(glyph_entry(g)) end

        if settings.oneline then
            -- Chevrons flank the value with a single space each side.
            for _, f in ipairs(layout.fields) do
                head:insert(cs(COLOR.label, f.label) .. ' '
                    .. cs(COLOR.chev, GLYPH.prev) .. ' '
                    .. cs(COLOR.value, tostring(state[f.mode].value)) .. ' '
                    .. cs(COLOR.chev, GLYPH.next))
            end
            gs_status:text(head:concat(SEP))
        else
            local lines = T { head[1] .. layout.head_pad1 .. head[2] .. layout.head_pad2 .. head[3] }
            for _, f in ipairs(layout.fields) do
                lines:insert(cs(COLOR.label, f.label .. string.rep(' ', layout.label_w - #f.label))
                    .. ' ' .. chevroned(tostring(state[f.mode].value), layout.value_w))
            end
            gs_status:text(lines:concat('\n'))
        end
    end

    -- Reset both boxes to the top-left corner.
    function display_zero_command()
        gs_status:pos_x(0)
        gs_status:pos_y(0)
        gs_debug:pos_x(0)
        gs_debug:pos_y(100)
        config.save(settings)
        windower.add_to_chat(80, "Displays reset and settings saved")
    end

    -- Last rendered debug values, compared to skip redundant redraws.
    local debug_box_state = {}

    -- Clear the cached debug values.
    function debug_box_reset() debug_box_state = {} end

    -- Redraw the debug box, skipping the update when nothing has changed.
    function debug_box_update()
        if debug_box_state.busy == is_Busy
            and debug_box_state.moving == is_moving
            and debug_box_state.dual_wield == DualWield
            and debug_box_state.two_hand == TwoHand
            and debug_box_state.casting == outgoing_cast_active
            and debug_box_state.failsafe == failsafe_active then
            return
        end
        debug_box_state.busy = is_Busy
        debug_box_state.moving = is_moving
        debug_box_state.dual_wield = DualWield
        debug_box_state.two_hand = TwoHand
        debug_box_state.casting = outgoing_cast_active
        debug_box_state.failsafe = failsafe_active
        local lines = T {}
        lines:insert('is_Busy' .. string.format('[%s]', tostring(is_Busy)):lpad(' ', 12))
        lines:insert('is_Moving' .. string.format('[%s]', tostring(is_moving)):lpad(' ', 10))
        lines:insert('DualWield' .. string.format('[%s]', tostring(DualWield)):lpad(' ', 10))
        lines:insert('TwoHand' .. string.format('[%s]', tostring(TwoHand)):lpad(' ', 12))
        lines:insert('Casting' .. string.format('[%s]', tostring(outgoing_cast_active)):lpad(' ', 12))
        lines:insert('Failsafe' .. string.format('[%s]', tostring(failsafe_active)):lpad(' ', 11))
        local maxWidth = math.max(1, table.reduce(lines, function(a, b) return math.max(a, #b) end, '1'))
        for i, line in ipairs(lines) do lines[i] = lines[i]:rpad(' ', maxWidth) end
        gs_debug:text(lines:concat('\n'))
    end

    ------------------------------------------------------------------------------------------------
    -- SECTION 21 - SELF COMMANDS
    ------------------------------------------------------------------------------------------------
    -- Everything reachable through 'gs c ...', including the internal commands the
    -- raw-handler engines use to perform equips inside a wrapped event.

    -- Return the argument portion of a command, or nil when none was given.
    local function command_arg(cmd)
        local arg = cmd:match('^%s*%S+%s+(.-)%s*$')
        if not arg or arg == '' then return nil end
        return arg
    end

    -- List a mode's options.
    local function mode_options(m)
        local opts = T {}
        if type(m) == 'table' and m._track and m._track._type == 'list' then
            for _, v in ipairs(m) do opts:insert(tostring(v)) end
        end
        return opts
    end

    -- Match a typed argument to a mode option. Returns the canonical option on an
    -- exact match, otherwise nil plus the closest option as a suggestion. Partial
    -- values are never silently accepted.
    local function match_mode_value(m, arg)
        local opts = mode_options(m)
        if not arg then return nil, nil, opts end
        local want = arg:lower()
        for _, v in ipairs(opts) do
            if v:lower() == want then return v, nil, opts end
        end
        for _, v in ipairs(opts) do
            local lv = v:lower()
            if lv:startswith(want) or want:startswith(lv) then return nil, v, opts end
        end
        for _, v in ipairs(opts) do
            local lv = v:lower()
            if lv:contains(want) or want:contains(lv) then return nil, v, opts end
        end
        return nil, nil, opts
    end

    -- Validate and apply a mode argument. Returns true when the mode was set.
    local function set_mode_arg(m, label, usage, arg)
        local value, suggestion, opts = match_mode_value(m, arg)
        if value then
            m:set(value)
            return true
        end
        if arg then
            warn(('%s: "%s" is not a valid mode.%s'):format(
                label, tostring(arg), suggestion and (' Did you mean [' .. suggestion .. ']?') or ''))
        else
            warn(('%s: no mode given.'):format(label))
        end
        warn(('Usage: //gs c %s [%s]'):format(usage, opts:concat('|')))
        return false
    end

    -- Commands that accept an argument, matched on their first word. Every other
    -- command matches only as a complete string.
    local command_takes_arg = {
        ["autobuff"] = true,
        ["enchinfo"] = true,
        ["hoxne"] = true,
        ["jobmode"] = true,
        ["jobmode2"] = true,
        ["offensemode"] = true,
        ["profile"] = true,
        ["spellreceived"] = true,
        ["treasurehunter"] = true,
        ["use"] = true,
        ["weaponmode"] = true,
    }

    -- Handlers receive the raw command and its lowercased, trimmed form. Returning
    -- true means handled: it suppresses the trailing self_command_custom hook, which
    -- some job files rely on.
    local command_handlers = {}

    -- Throttle for the [Empty] chosen-set warning below.
    local empty_set_gate = 0

    command_handlers["update auto"] = function(cmd, command)
        local built_set = choose_set()
        if choose_set_custom then
            built_set = set_combine(built_set, choose_set_custom())
        else
            warn('choose_set_custom() not found!')
        end
        -- An empty result means no chosen set carries any gear. Sleep is the one
        -- deliberate empty set, and the warning repeats at most every 30 seconds.
        if next(built_set) == nil and not buffactive['Sleep'] and os.clock() >= empty_set_gate then
            empty_set_gate = os.clock() + 30
            warn('Chosen set is [Empty] - nothing to equip. gs c checksets lists your sets.')
        end
        -- Order the gear and then equip
        equip(built_set)
        return true
    end

    command_handlers["zero"] = function(cmd, command)
        display_zero_command()
    end

    command_handlers["displaymode"] = function(cmd, command)
        settings.oneline = not settings.oneline
        info('One line display is: [' .. (settings.oneline and "ON" or "OFF") .. ']')
        display_box_update()
        config.save(settings)
        windower.add_to_chat(80, "Settings saved")
    end

    -- Toggles the TH state
    command_handlers["treasurehunter"] = function(cmd, command)
        if command == "treasurehunter" then
            state.TreasureMode:cycle()
            info('Treasure Hunter Mode: [' .. state.TreasureMode.value .. ']')
            display_box_update()
        elseif set_mode_arg(state.TreasureMode, 'Treasure Hunter', 'TreasureHunter', command_arg(cmd)) then
            info('Treasure Hunter Mode: [' .. state.TreasureMode.value .. ']')
            display_box_update()
        else
            return true
        end
        equip_set_command()
        return true
    end

    command_handlers["spellreceived"] = function(cmd, command)
        if command == "spellreceived" then
            state.SpellReceived:cycle()
            info('Spell Received Mode: [' .. state.SpellReceived.value .. ']')
            display_box_update()
        elseif set_mode_arg(state.SpellReceived, 'Spell Received', 'SpellReceived', command_arg(cmd)) then
            info('Spell Received Mode: [' .. state.SpellReceived.value .. ']')
            display_box_update()
        else
            return true
        end
        equip_set_command()
        return true
    end

    command_handlers["hoxnerelock"] = function(cmd, command)
        -- Wrapped landing point for the raw prerender driver (hoxne_relock /
        -- hoxne_tick).  Skips if a window opened while the command was in
        -- flight, so an async re-lock can never stomp a borrowed instrument.
        if state.Hoxne.value ~= 'OFF' and not hoxne.window then
            hoxne_equip_ampulla()
            -- The equip delay restarts on every re-equip, but the recast
            -- may be longer still: whichever is larger governs, with the
            -- equip lockout as the floor against stale extdata.
            local _, hx_ext = find_enchantment(HOXNE_AMPULLA)
            local hx_recast = enchantment_waits(hx_ext) or 0
            hoxne.use_not_before = os.clock() + math.max(HOXNE_EQUIP_LOCKOUT, hx_recast)
            equip_set_command()
        end
        return true
    end

    command_handlers["hoxnerelease"] = function(cmd, command)
        -- Wrapped landing point for hoxne_tick's stranded-Ampulla release. A reload
        -- resets the mode to OFF but cannot unequip, so the Ampulla is left worn.
        if state.Hoxne.value == 'OFF' then
            if hoxne_release_step() == 'done' then hoxne.release_tries = 0 end
        end
        return true
    end

    command_handlers["enchrepair"] = function(cmd, command)
        -- Wrapped landing point for enchantment_tick's re-equip.
        local st = ench_active
        if st then
            enable(st.slot)
            gs_equip({ [st.slot] = st.name })
            disable(st.slot)
        end
        return true
    end

    command_handlers["enchinfo"] = function(cmd, command)
        -- Diagnostic: dumps the live extdata for an enchanted item so the
        -- cooldown and activation the engine sees can be compared against
        -- reality.  Usage: gs c enchinfo warp ring
        local name = command_arg(cmd)
        local row, ext, carried, equipped = find_enchantment(name or '')
        if not row then
            info('enchinfo: unknown item [' .. tostring(name) .. ']')
        elseif not carried then
            info(row.en .. ': not in inventory or wardrobes.')
        elseif not ext then
            info(row.en .. ': carried, but extdata did not decode.')
        else
            local now_t = os.time() - EXTDATA_TS_CORRECTION
            local recast, activation = enchantment_waits(ext)
            info(('%s: equipped=%s usable=%s charges=%s activation %+ds next_use %+ds (epoch-corrected)'):format(
                row.en, tostring(equipped), tostring(ext.usable), tostring(ext.charges_remaining),
                (ext.activation_time or now_t) - now_t, (ext.next_use_time or now_t) - now_t))
            info(('  -> engine sees: cooldown %ds (warns/refuses), equip delay %ds (waits quietly)'):format(
                recast or 0, activation or 0))
        end
        return true
    end

    command_handlers["hoxneinfo"] = function(cmd, command)
        -- Diagnostic: everything the Hoxne subsystem gates on, read-only.  Usage:
        -- gs c hoxneinfo
        local row, ext, carried, equipped = find_enchantment(HOXNE_AMPULLA)
        local recast, activation = enchantment_waits(ext)
        -- The two sources are printed separately and labelled because they disagree:
        -- player.equipment has been seen inverted after a reload while the bag status
        -- stayed correct. If these two lines contradict each other, believe the second.
        info(('Hoxne [%s]  buff=%s  window=%s  release attempts left=%d'):format(
            state.Hoxne.value, tostring(buffactive[BUFF_ENCHANTMENT] and true or false),
            tostring(hoxne.window), hoxne.release_tries))
        info(('  player.equipment: ammo=[%s] range=[%s]'):format(
            tostring(player.equipment.ammo), tostring(player.equipment.range)))
        info(('  live bag status:  ampulla carried=%s equipped=%s cooldown=%ds equip delay=%ds'):format(
            tostring(carried), tostring(equipped), recast or 0, activation or 0))
        return true
    end

    -- Diagnostic: classify every gear set, read-only. Usage: gs c checksets
    command_handlers["checksets"] = function(cmd, command)
        invalidate_set_index()
        reset_set_warnings()
        local gear, empty, undeclared = set_diagnostics()
        info(('Sets with gear: %d.  Engine placeholders left undeclared: %d.'):format(#gear, #undeclared))
        if #empty == 0 then
            info('Declared [Empty] sets: none.')
        else
            info('Declared [Empty] sets: ' .. table.concat(empty, ', '))
        end
        return true
    end

    command_handlers["hoxne"] = function(cmd, command)
        if command == "hoxne" then
            state.Hoxne:cycle()
            info('Hoxne Ampulla Mode: [' .. state.Hoxne.value .. ']')
            display_box_update()
        elseif set_mode_arg(state.Hoxne, 'Hoxne Ampulla', 'Hoxne', command_arg(cmd)) then
            info('Hoxne Ampulla Mode: [' .. state.Hoxne.value .. ']')
            display_box_update()
        else
            return true
        end
        if state.Hoxne.value ~= 'OFF' then
            local _, _, carried = find_enchantment('Hoxne Ampulla')
            if carried then
                hoxne.window     = false
                hoxne.slot       = nil
                hoxne.resume     = nil
                hoxne.recheck_at = 0
                if state.Hoxne.value == 'ON-Allow Critical' then
                    -- Allow-Critical holds without disable(); this also clears a hold
                    -- left behind when toggling over from ON-Locked.
                    enable('range', 'ammo')
                end
                hoxne_equip_ampulla()
                local _, hx_ext = find_enchantment(HOXNE_AMPULLA)
                local hx_recast = enchantment_waits(hx_ext) or 0
                hoxne.use_not_before = os.clock() + math.max(HOXNE_EQUIP_LOCKOUT, hx_recast)
                -- Answer once here; the tick's own warnings are throttled.
                if hx_recast > 0 then
                    info(('Hoxne Ampulla is on cooldown for %ds; it will be used as soon as it is ready.')
                        :format(math.ceil(hx_recast)))
                end
                if state.Hoxne.value == 'ON-Allow Critical' then
                    info('Hoxne locked. Songs, Geomancy, Tomahawk and Angon may borrow range/ammo.')
                else
                    info('Hoxne locked. Range and ammo are held; instruments and Angon/Tomahawk will not equip.')
                end
            else
                warn("Hoxne Ampulla not found.  Not locking range/ammo")
                state.Hoxne:set('OFF')
                info('Hoxne Ampulla Mode: [' .. state.Hoxne.value .. ']')
                display_box_update()
            end
        else
            hoxne.window     = false
            hoxne.slot       = nil
            hoxne.resume     = nil
            hoxne.recheck_at = 0
            enable('range', 'ammo')
            -- Start the release and let the tick verify it: one call is not enough
            -- when GearSwap's equipment model is desynced.
            if hoxne_release_step() ~= 'done' then
                hoxne.release_tries = 5
                hoxne.release_next  = os.clock() + 2
            end
            info('Hoxne mode disabled.  Range and ammo unlocked.')
        end
        equip_set_command()
        return true
    end

    -- Toggles the Auto Buff function off/on
    command_handlers["autobuff"] = function(cmd, command)
        if command == 'autobuff' then
            state.AutoBuff:cycle()
            info('Auto Buff is [' .. state.AutoBuff.value .. ']')
        elseif set_mode_arg(state.AutoBuff, 'Auto Buff', 'AutoBuff', command_arg(cmd)) then
            info('Auto Buff is [' .. state.AutoBuff.value .. ']')
        else
            return true
        end
        display_box_update()
        equip_set_command()
        return true
    end

    -- Shuts down instnace
    command_handlers["shutdown"] = function(cmd, command)
        send_command('terminate')
    end

    -- Saves the location of HUD
    command_handlers["save"] = function(cmd, command)
        if windower.ffxi.get_info().logged_in then
            config.save(settings)
            windower.add_to_chat(80, 'Settings saved')
        else
            windower.add_to_chat(80, 'Cannot save while zoning - try again in a moment.')
        end
    end

    -- Toggles dispay of the HUD
    command_handlers["display"] = function(cmd, command)
        if settings.visible == true then
            settings.visible = false
            gs_status:hide()
            gs_status:draggable(false)
            windower.add_to_chat(80, 'The UI is now hidden')
        else
            settings.visible = true
            gs_status:draggable(true)
            gs_status:show()
            display_box_update()
            windower.add_to_chat(80, 'The UI is now shown')
        end
    end

    command_handlers["debug"] = function(cmd, command)
        if settings.debug == true then
            settings.debug = false
            gs_debug:hide()
            gs_debug:draggable(false)
            windower.add_to_chat(121, '[Mirdain Debug] Debugging is now [OFF]')
        else
            settings.debug = true
            gs_debug:draggable(true)
            gs_debug:show()
            debug_box_reset()
            debug_box_update()
            log('Debugging is now [ON]')
            debug('Debugging is now [ON]')
        end
    end

    command_handlers["warn"] = function(cmd, command)
        if settings.warn == true then
            settings.warn = false
            windower.add_to_chat(123, 'The set warning is now [OFF]')
        else
            settings.warn = true
            warn('The set warning is now [ON]')
        end
    end

    -- Traces which gear set each midcast chose, and what it fell back through.
    command_handlers["gearreporting"] = function(cmd, command)
        if settings.gear_reporting == true then
            settings.gear_reporting = false
            windower.add_to_chat(207, 'Gear reporting is now [OFF]')
        else
            settings.gear_reporting = true
            gear_report('Gear reporting is now [ON]')
        end
    end

    command_handlers["info"] = function(cmd, command)
        if settings.info == true then
            settings.info = false
            windower.add_to_chat(8, 'Information is now [OFF]')
        else
            settings.info = true
            info('Information is now [ON]')
        end
    end

    command_handlers["two_hand_check"] = function(cmd, command)
        two_hand_check()
    end

    -- Esha Temps
    command_handlers["temps"] = function(cmd, command)
        escha_temps()
    end

    -- Stop an enchanted item use that is under way. Deliberately does not return true,
    -- matching the shortcuts below, so self_command_custom still runs.
    command_handlers["cancel"] = function(cmd, command)
        local name, sent = cancel_enchantment()
        if not name then
            info('Nothing to cancel.')
        elseif sent then
            warn(name .. ': already sent and cannot be recalled; move to interrupt it.')
        else
            info('Cancelled [' .. name .. '].')
        end
    end

    -- Typed /ja for these is refused by the client while the throwing item is not
    -- worn, so the command equips first and issues the ability once the equip lands.
    command_handlers["tomahawk"] = function(cmd, command)
        use_gated_ja(150)
    end

    command_handlers["angon"] = function(cmd, command)
        use_gated_ja(170)
    end

    -- Warp Ring
    command_handlers["warp"] = function(cmd, command)
        use_enchantment("Warp Ring")
    end

    -- Warp Club
    command_handlers["warp club"] = function(cmd, command)
        use_enchantment("Warp Cudgel")
    end

    -- Holla Teleport
    command_handlers["holla"] = function(cmd, command)
        use_enchantment("Dim. Ring (Holla)")
    end

    -- Dem Teleport
    command_handlers["dem"] = function(cmd, command)
        use_enchantment("Dim. Ring (Dem)")
    end

    -- Mea Teleport
    command_handlers["mea"] = function(cmd, command)
        use_enchantment("Dim. Ring (Mea)")
    end

    -- CP Ring
    command_handlers["cp"] = function(cmd, command)
        use_enchantment("Trizek Ring")
    end

    -- Toggles the current player stances
    command_handlers["offensemode"] = function(cmd, command)
        if command == 'offensemode' then
            for i, v in ipairs(state.OffenseMode) do
                if state.OffenseMode.value == v then
                    if state.OffenseMode.value ~= state.OffenseMode[#state.OffenseMode] then
                        state.OffenseMode:set(state.OffenseMode[i + 1])
                    else
                        state.OffenseMode:set(state.OffenseMode[1])
                    end
                    info('Offense Mode: [' .. state.OffenseMode.value .. ']')
                    display_box_update()
                    equip_set_command()
                    return true
                end
            end
        elseif set_mode_arg(state.OffenseMode, 'Offense Mode', 'OffenseMode', command_arg(cmd)) then
            info('Offense Mode: [' .. state.OffenseMode.value .. ']')
            display_box_update()
            equip_set_command()
            return true
        else
            return true
        end
    end

    command_handlers["weaponmode"] = function(cmd, command)
        if command == 'weaponmode' then
            for i, v in ipairs(state.WeaponMode) do
                if state.WeaponMode.value == v then
                    if state.WeaponMode.value ~= state.WeaponMode[#state.WeaponMode] then
                        state.WeaponMode:set(state.WeaponMode[i + 1])
                    else
                        state.WeaponMode:set(state.WeaponMode[1])
                    end
                    info('Weapon Mode: [' .. state.WeaponMode.value .. ']')
                    display_box_update()
                    if self_command_custom then self_command_custom(command) end
                    two_hand_check()
                    equip_set_command()
                    return true
                end
            end
        elseif set_mode_arg(state.WeaponMode, 'Weapon Mode', 'WeaponMode', command_arg(cmd)) then
            info('Weapon Mode: [' .. state.WeaponMode.value .. ']')
            display_box_update()
            if self_command_custom then self_command_custom(command) end
            two_hand_check()
            equip_set_command()
            return true
        else
            return true
        end
    end

    command_handlers["jobmode2"] = function(cmd, command)
        if command == 'jobmode2' then
            for i, v in ipairs(state.JobMode2) do
                if state.JobMode2.value == v then
                    if state.JobMode2.value ~= state.JobMode2[#state.JobMode2] then
                        state.JobMode2:set(state.JobMode2[i + 1])
                    else
                        state.JobMode2:set(state.JobMode2[1])
                    end
                    info(UI_Name2 .. ': [' .. state.JobMode2.value .. ']')
                    display_box_update()
                    if self_command_custom then self_command_custom(command) end
                    equip_set_command()
                    return true
                end
            end
        elseif set_mode_arg(state.JobMode2, UI_Name2 ~= '' and UI_Name2 or 'Job Mode 2', 'JobMode2', command_arg(cmd)) then
            info(UI_Name2 .. ': [' .. state.JobMode2.value .. ']')
            display_box_update()
            if self_command_custom then self_command_custom(command) end
            equip_set_command()
            return true
        else
            return true
        end
    end

    command_handlers["jobmode"] = function(cmd, command)
        if command == 'jobmode' then
            for i, v in ipairs(state.JobMode) do
                if state.JobMode.value == v then
                    if state.JobMode.value ~= state.JobMode[#state.JobMode] then
                        state.JobMode:set(state.JobMode[i + 1])
                    else
                        state.JobMode:set(state.JobMode[1])
                    end
                    info(UI_Name .. ': [' .. state.JobMode.value .. ']')
                    display_box_update()
                    -- Issue a command to the lua for the job specific command
                    if self_command_custom then self_command_custom(command) end
                    equip_set_command()
                    return true
                end
            end
        elseif set_mode_arg(state.JobMode, UI_Name ~= '' and UI_Name or 'Job Mode', 'JobMode', command_arg(cmd)) then
            info(UI_Name .. ': [' .. state.JobMode.value .. ']')
            display_box_update()
            -- Issue a command to the lua for the job specific command
            if self_command_custom then self_command_custom(command) end
            equip_set_command()
            return true
        else
            return true
        end
    end

    -- This profile mode is used to load a Silmaril profile and execute a script
    command_handlers["profile"] = function(cmd, command)
        local modes = {}
        for mode in string.gmatch(cmd, "(%w+)") do
            table.insert(modes, mode)
        end
        local smModePath = table.concat(modes, '_', 2, #modes)
        info('Profile: [' .. modes[#modes] .. ']')
        windower.send_command('exec ' .. smModePath .. '/' .. player.main_job ..
            '_' .. player.sub_job .. '_' .. player.name)
    end

    command_handlers["food"] = function(cmd, command)
        windower.chat.input('/item "' .. Food .. '" <me>')
    end

    -- Command to use any enchanted item, can use either en or enl names from resources, autodetects slot, equip timeout and cast time
    command_handlers["use"] = function(cmd, command)
        use_enchantment(command:slice(5))
    end

    command_handlers["version"] = function(cmd, command)
        info('Include Version is [' .. Mirdain_GS .. ']')
    end

    -------Custom Commands for Proccing and 1Dmg Weapons-------
    command_handlers["naked"] = function(cmd, command)
        equip({
            main = empty,
            sub = empty,
            range = empty,
            ammo = empty,
            head = empty,
            neck = empty,
            ear1 = empty,
            ear2 = empty,
            body = empty,
            hands = empty,
            ring1 = empty,
            ring2 = empty,
            back = empty,
            waist = empty,
            legs = empty,
            feet = empty
        })
        Lock()
    end

    --Perform instant unequip that will be immediately undone through equip_set_command on the next action or timing
    --Use for cure cheating, sortie objective, etc
    command_handlers["nakedunlocked"] = function(cmd, command)
        equip({
            main = empty,
            sub = empty,
            range = empty,
            ammo = empty,
            head = empty,
            neck = empty,
            ear1 = empty,
            ear2 = empty,
            body = empty,
            hands = empty,
            ring1 = empty,
            ring2 = empty,
            back = empty,
            waist = empty,
            legs = empty,
            feet = empty
        })
    end

    --Disable all slots but weapons, range and ammo
    command_handlers["weaponsonly"] = function(cmd, command)
        equip({
            head = empty,
            neck = empty,
            ear1 = empty,
            ear2 = empty,
            body = empty,
            hands = empty,
            ring1 = empty,
            ring2 = empty,
            back = empty,
            waist = empty,
            legs = empty,
            feet = empty
        })
        disable('head', 'neck', 'ear1', 'ear2', 'body', 'hands', 'ring1', 'ring2', 'back', 'waist', 'legs', 'feet')
    end

    --Mode to disable main equipment slots for abyssea red proccing
    command_handlers["abysseaproc"] = function(cmd, command)
        equip({
            head = empty,
            --body = empty,
            hands = empty,
            legs = empty,
            feet = empty,
        })
        --disable('head', 'neck', 'ear1', 'ear2', 'body', 'hands', 'ring1', 'ring2', 'back', 'waist', 'legs', 'feet')
        disable('head', 'hands', 'legs', 'feet')
    end

    --Enable All Slots
    command_handlers["enableall"] = function(cmd, command)
        Unlock()
    end

    --Enable slots that aren't locked by the current mode or zone
    command_handlers["enablebymode"] = function(cmd, command)
        UnlockByMode()
    end

    -- Command dispatcher. Whole string first, then first word for the commands that
    -- take an argument. Unrecognised commands fall through to self_command_custom,
    -- which is how job files add their own.
    function self_command(cmd)
        local command = cmd:lower():trim()

        local handler = command_handlers[command]
        if not handler then
            local verb = command:match('^(%S+)')
            if verb and command_takes_arg[verb] then
                handler = command_handlers[verb]
            end
        end
        if handler and handler(cmd, command) then return end

        --use below for custom Job commands
        if self_command_custom then self_command_custom(command) end
    end

    ------------------------------------------------------------------------------------------------
    -- SECTION 22 - JOB LIFECYCLE
    ------------------------------------------------------------------------------------------------
    -- Load, unload and subjob changes.

    -- Set the macro book, lockstyle and keybinds for the job.
    function jobsetup(LockStylePallet, MacroBook, MacroSet)
        if Random_Lockstyle then
            LockStylePallet = Lockstyle_List[math.random(#Lockstyle_List)]
        end

        windower.send_command('wait 1;input /macro book ' ..
            MacroBook ..
            ';wait 1;input /macro set ' ..
            MacroSet ..
            ';gs validate;wait 3;input /lockstyleset ' ..
            LockStylePallet .. ';input /echo Change Complete;gs c update auto;')

        send_command('bind f12 gs c OffenseMode')
        send_command('bind f11 gs c TreasureHunter')
        send_command('bind f10 gs c AutoBuff')
        send_command('bind f9 gs c WeaponMode')
        send_command('bind ^f12 gs c JobMode')
        send_command('bind ^f11 gs c JobMode2')
        send_command('bind ^f10 gs c Hoxne')
        send_command('bind ^f9 gs c SpellReceived')

        local maxWidth = 40
        windower.add_to_chat(8, 'Stance - ' .. string.format('[%s]', 'F12'))
        windower.add_to_chat(8, 'TH Mode - ' .. string.format('[%s]', 'F11'))
        windower.add_to_chat(8, 'Auto Buff - ' .. string.format('[%s]', 'F10'))
        windower.add_to_chat(8, 'Weapon Mode - ' .. string.format('[%s]', 'F9'))
        if UI_Name ~= '' then
            windower.add_to_chat(8, UI_Name .. ' - ' .. string.format('[%s]', 'Ctrl + F12'))
        end
        if UI_Name2 ~= '' then
            windower.add_to_chat(8, UI_Name2 .. ' - ' .. string.format('[%s]', 'Ctrl + F11'))
        end
        windower.add_to_chat(8, 'Hoxne Ampulla Mode - ' .. string.format('[%s]', 'Ctrl + F10'))
        windower.add_to_chat(8,
            'Spell Received Gear Mode (Multibox Only) - ' .. string.format('[%s]', 'Ctrl + F9'))
    end

    -- Release locks, destroy the display boxes and unbind keys when the file unloads.
    function file_unload(file_name)
        if gs_status then
            gs_status:destroy()
        end
        if gs_debug then
            gs_debug:destroy()
        end

        send_command('unbind ^f9')
        send_command('unbind ^f10')
        send_command('unbind ^f11')
        send_command('unbind ^f12')
        send_command('unbind f9')
        send_command('unbind f10')
        send_command('unbind f11')
        send_command('unbind f12')

        ench_active      = nil
        hoxne.window     = false
        hoxne.slot       = nil
        hoxne.recheck_at = 0
        enable('range', 'ammo')

        if active_external_locks and next(active_external_locks) ~= nil then
            for slot, _ in pairs(active_external_locks) do
                enable(slot)
            end
            active_external_locks = {}
        end

        if user_file_unload then
            user_file_unload()
        else
            info('user_file_unload() not found!')
        end
    end

    -- Refresh weapon traits and gear after a subjob change.
    function sub_job_change(new, old)
        invalidate_layout()
        invalidate_set_index()
        reset_set_warnings()
        coroutine.schedule(dual_wield_check, 2)
        coroutine.schedule(two_hand_check, 2.1)
        coroutine.schedule(equip_set_command, 2.2)
        if sub_job_change_custom then
            sub_job_change_custom()
        end
    end

    ------------------------------------------------------------------------------------------------
    -- SECTION 23 - EVENT REGISTRATION AND STARTUP
    ------------------------------------------------------------------------------------------------
    -- Windower event bindings and the deferred startup pass. Registration happens last
    -- so every handler and every local it captures already exists.

    -- Release any slots left locked by a previous load.
    enable('main', 'sub', 'range', 'ammo', 'head', 'neck', 'lear', 'rear', 'body', 'hands', 'lring', 'rring', 'waist',
        'legs', 'feet')

    -- Action, packet and zone events.
    windower.register_event('target change', on_target_change_for_th)
    windower.raw_register_event('incoming chunk', on_incoming_chunk_for_th)
    windower.raw_register_event('outgoing chunk', main_engine)
    windower.raw_register_event('zone change', on_zone_change_for_th)

    -- Multibox IPC: another local character announcing a cast on this one.
    windower.register_event('ipc message', function(msg)
        if state.SpellReceived.value == 'OFF' then return end

        if msg:startswith('MIRDAIN|SPELL|') then
            local split_msg = msg:split("|")
            local target_name = split_msg[4] or "Missing Target Name"
            if string.find(target_name, player.name, 1, true) then
                local caster_name = split_msg[3] or "Missing Caster Name"
                local spell_id = split_msg[5] or "Missing Spell ID"
                local time_sent = tonumber(split_msg[6]) or 9999999999999
                local time_received = get_time()
                if settings.debug then
                    debug("Targeted IPC Message Received: " ..
                        msg .. " after " .. (time_received - time_sent) .. " ms")
                end

                if next(active_incoming_casters) == nil then
                    cast_start_time = time_sent
                    equip_spell_received_gear(tonumber(spell_id), "spell")
                end

                -- Add caster to active pool and refresh failsafe timer
                active_incoming_casters[caster_name] = true
                if settings.debug then
                    debug(caster_name ..
                        " added to Active Incoming Casters (" .. count_keys(active_incoming_casters) .. ")")
                end
                failsafe_active = true
                failsafe_trigger_time = os.clock() + settings.delay
                if settings.debug then
                    debug(player.name ..
                        " is targeted by " .. caster_name .. ". Gear equipped and timer refreshed.")
                end
            end
        elseif msg:startswith('MIRDAIN|ABILITY|') then
            local split_msg = msg:split("|")
            local target_name = split_msg[4] or "Missing Target Name"
            if string.find(target_name, player.name, 1, true) then
                local caster_name = split_msg[3] or "Missing Caster Name"
                local spell_id = split_msg[5] or "Missing Spell ID"
                local time_sent = tonumber(split_msg[6]) or 9999999999999
                local time_received = get_time()
                if settings.debug then
                    debug("Targeted IPC Message Received: " ..
                        msg .. " after " .. (time_received - time_sent) .. " ms")
                end

                if next(active_incoming_casters) == nil then
                    cast_start_time = time_sent
                    equip_spell_received_gear(tonumber(spell_id), "ability")
                end

                -- Add caster to active pool and refresh failsafe timer
                active_incoming_casters[caster_name] = true
                if settings.debug then
                    debug(caster_name ..
                        " added to Active Incoming Casters (" .. count_keys(active_incoming_casters) .. ")")
                end
                failsafe_active = true
                failsafe_trigger_time = os.clock() + settings.delay
                if settings.debug then
                    debug(player.name ..
                        " is targeted by " .. caster_name .. ". Gear equipped and timer refreshed.")
                end
            end
        elseif msg:startswith('MIRDAIN|COMPLETE|') then
            if next(active_incoming_casters) ~= nil then
                if settings.debug then debug("Targeted IPC Message Received: " .. msg) end
                local split_msg = msg:split("|")
                local caster_name = split_msg[3]
                local time_sent = tonumber(split_msg[4])
                if active_incoming_casters[caster_name] then
                    active_incoming_casters[caster_name] = nil
                    if settings.debug then
                        debug(caster_name ..
                            " finished casting after " ..
                            (time_sent - cast_start_time) ..
                            " ms and is removed from Active Incoming Casters (" ..
                            count_keys(active_incoming_casters) .. ")")
                    end
                    if next(active_incoming_casters) == nil then
                        if settings.debug then debug("No active incoming casts remain. Resetting gear.") end
                        if state.SpellReceived.value == 'ON' then
                            for slot, _ in pairs(active_external_locks) do
                                enable(slot)
                                if settings.debug then debug("Unlocking " .. tostring(slot)) end
                            end
                            active_external_locks = {}
                        end
                        equip_set_command()
                        failsafe_active = false
                    end
                end
            end
        end
    end)

    -- Enchantment and Hoxne drivers. prerender fires every frame regardless of network
    -- traffic, which is why these live here rather than in main_engine: they keep
    -- working while the character stands still. Both are gated on a clock read.
    windower.raw_register_event('prerender', function()
        local now = os.clock()
        if now >= ench_next_check then
            ench_next_check = now + 0.25
            enchantment_tick(now)
        end
        if now >= hoxne.next_check then
            hoxne.next_check = now + 1.0
            hoxne_tick(now)
        end
        -- Only ever non-nil for the few hundred milliseconds an equip is in flight,
        -- so the steady-state cost is one nil test.
        if gated_ja and now >= gated_ja.next_check then
            gated_ja.next_check = now + 0.1
            gated_ja_tick(now)
        end
    end)

    -- Spell-received failsafe: releases borrowed gear if a completion never arrives.
    windower.raw_register_event('prerender', function()
        if not failsafe_active or state.SpellReceived.value == "OFF" then return end

        if os.clock() >= failsafe_trigger_time then
            failsafe_active = false
            failsafe_trigger_time = 0
            active_incoming_casters = {}
            if settings.debug then debug("Failsafe triggered! Sending equipment reset command.") end
            for slot, _ in pairs(active_external_locks) do
                enable(slot)
            end
            active_external_locks = {}
            equip_set_command()
        end
    end)

    -- Buff gained: sleep and doom gear, and automatic status-removal items.
    windower.register_event('gain buff', function(id)
        if id == 6 and (Mage_Job:contains(player.main_job) or Mage_Job:contains(player.sub_job)) then
            if player.inventory['Remedy'] ~= nil then
                if AutoItem == true then
                    windower.chat.input('/item "Remedy" <me>')
                end
            else
                info('No Remedies in inventory.')
            end
        elseif id == 4 then
            if player.inventory['Remedy'] ~= nil then
                if AutoItem == true then
                    windower.chat.input('/item "Remedy" <me>')
                end
            else
                info('No Remedies in inventory.')
            end
        elseif id == 2 then
            local built_set = {}
            if sets.Idle then
                built_set = sets.Idle
            else
                warn('sets.Idle not found!')
            end
            if sets.Weapons then
                if sets.Weapons.Sleep then
                    info('Locking Sleep Gear')
                    built_set = set_combine(built_set, sets.Weapons.Sleep)
                else
                    warn('sets.Weapons.Sleep not found!')
                end
            else
                warn('sets.Weapons not found!')
            end
            equip(built_set)
            disable('main', 'range')
            -- Used to wake up during sleep
            -- Cancel stoneskin
            if buffactive['Stoneskin'] then
                info('Cancel Stoneskin')
                cancel('Stoneskin')
            end
        elseif id == 7 then
            log("Petrification - Checking Gear")
            if choose_set_custom then
                equip(set_combine(choose_set(), choose_set_custom()))
            else
                equip(set_combine(choose_set()))
            end
        elseif id == 10 then
            log("Stunned - Checking Gear")
            if choose_set_custom then
                equip(set_combine(choose_set(), choose_set_custom()))
            else
                equip(set_combine(choose_set()))
            end
        elseif id == 15 then
            info('DOOOOOOM!!!')
            --Lock eligible slots for cursna received gear if not tracking party spellcasting through IPC
            if state.SpellReceived.value == "OFF" then
                if sets.Cursna_Received then
                    warn_if_empty(sets.Cursna_Received, 'sets.Cursna_Received')
                    equip(sets.Cursna_Received)
                    for slot, item in pairs(sets.Cursna_Received) do
                        disable(slot)
                    end
                    info('Locking Cursna Received Gear')
                else
                    warn('sets.Cursna_Received not found!')
                end
            end
            if AutoItem then
                if player.inventory['Holy Water'] ~= nil then -- Only here to notify player about Doom status and potential lack of Holy Waters
                    windower.chat.input('/item "Holy Water" <me>')
                else
                    info('No Holy Waters in inventory. Unable to cure DOOM status!')
                end
            end
        end
    end)

    -- Buff lost: release the gear locked for that buff.
    windower.register_event('lose buff', function(id)
        local buff = res.buffs[id]
        local name = buff and buff.en or tostring(id)
        local gain = false
        --Unlock cursna received gear if not tracking party spellcasting through IPC
        if id == 15 and state.SpellReceived.value == "OFF" then -- Doom
            UnlockByMode()
            if choose_set_custom then
                if buff_change_custom then
                    equip(set_combine(choose_set(), choose_set_custom(), buff_change_custom(name, gain)))
                else
                    equip(set_combine(choose_set(), choose_set_custom()))
                end
            else
                equip(set_combine(choose_set()))
            end
            info('Unlocking Cursna Received Gear')
        elseif id == 2 then -- sleep
            UnlockByMode()
            if choose_set_custom then
                if buff_change_custom then
                    equip(set_combine(choose_set(), choose_set_custom(), buff_change_custom(name, gain)))
                else
                    equip(set_combine(choose_set(), choose_set_custom()))
                end
            else
                equip(set_combine(choose_set()))
            end
            info('Unlocking Sleep Gear')
        end
    end)

    -- Disabled example showing how to hook party chat and tells. Kept as a template;
    -- uncomment to use.
    --[[
    windower.register_event('chat message', function(message, sender, mode, gm)
        --Future Hooks for PT chat or tells
        -- Mode 3 is tell
        -- Mode 4 is party
        --Ignore it if it's not party chat or a tell
        if mode ~= 3 and mode ~= 4 then
            return
        end
        message = message:lower()
        -- Example Use
        if message:contains('hqzerg') then
            windower.send_command('sm on')
        end
    end)
    ]] --

    -- Player actions. Gated on actor id, because this fires for every entity in range.
    windower.raw_register_event('action', function(data)
        if data ~= nil then
            --info('cat=' .. data.category .. ',param=' .. data.param)
            if data.actor_id == player.id then
                -- Ranged attack finish
                if data.category == 2 then
                    if data.param == 26739 then
                        log('Player finished Shooting')
                    end
                    --Casting finish
                elseif data.category == 4 then
                    log('Casting Finished')
                    -- Item Use
                elseif data.category == 9 then
                    if data.param == 24931 then
                        log('Item use')
                    elseif data.param == 28787 then
                        log('Item Use Interupted')
                        enchantment_completed()
                        UnlockByMode()
                        equip_set_command()
                    end
                    -- Item use Finished
                elseif data.category == 5 then
                    -- Not gated on param: on completion it carries the item id, so any
                    -- single value matches only one item.
                    log('Item Use Finished')
                    enchantment_completed()
                    UnlockByMode()
                    equip_set_command()
                    -- Casting Start
                elseif data.category == 8 then
                    if data.param == 28787 then
                        log('Spell Interupt')
                        -- An interrupted song never reaches aftercast; collapse
                        -- the watchdog so the Ampulla comes back promptly.
                        if hoxne.window then hoxne.expires = os.clock() + 0.5 end
                        equip_set_command()
                    elseif data.param == 24931 then
                        log('Casting Spell')
                    end
                    -- Ranged attack start
                elseif data.category == 12 then
                    if data.param == 24931 then
                        log(player.name, ' is Shooting')
                    elseif data.param == 28787 then
                        log('Shooting is interrupted')
                    end
                end
                -- If player takes action, adjust TH tagging information
                if state.TreasureMode.value ~= 'None' and TaggingCategories:contains(data.category) then
                    local target = data.targets[1]
                    local target_mob = target and windower.ffxi.get_mob_by_id(target.id)
                    if target_mob and target_mob.is_npc then
                        th_info.tagged_mobs[target.id] = os.clock()
                        if state.TreasureMode.value ~= 'Full Time' then
                            equip_set_command()
                        end
                    elseif th_info.tagged_mobs[data.actor_id] then
                        th_info.tagged_mobs[data.actor_id] = os.clock()
                    elseif target and th_info.tagged_mobs[target.id] then
                        th_info.tagged_mobs[target.id] = os.clock()
                    end
                end
            end
            --[[ Casting Spell
            if data.category == 8 then
                if data.param == 24931 then
                    if data.targets[1].actions[1].param ~= 0 then
                        -- Get the ability
                        -- local ability = res.spells[targets[1].actions[1].param]
                    end
                    -- Spell inturpted
                elseif data.param == 28787 then
                end
                -- Weaponskill Finished
            else]]
            if data.category == 3 and data.param ~= 0 then
                run_burst(data)
                -- Casting finish
            elseif data.category == 4 then
                run_burst(data)
            end
        end
    end)

    -- Ask the engine to rebuild and equip the current set.
    function equip_set_command()
        windower.send_command("gs c update auto")
    end

    -- Deferred startup, staggered so the first pass runs after the job file has loaded
    -- and the client has settled. Unlock releases every slot and re-equips: a slot hold
    -- can survive a reload and strand gear.
    coroutine.schedule(display_box_update, 2.0)
    coroutine.schedule(dual_wield_check, 2.1)
    coroutine.schedule(two_hand_check, 2.2)
    coroutine.schedule(Unlock, 2.3)
    coroutine.schedule(main_engine, 2.4)

    -- Arm the stranded-Ampulla release; hoxne_tick performs it. Held until the startup
    -- equips above have landed.
    hoxne.release_tries = 10
    hoxne.release_next  = os.clock() + 3
end

