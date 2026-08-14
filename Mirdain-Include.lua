--------------------------------------------------------------------------
-===          Mirdain Gearswap Enhanced by Rahvin                     ===-
--------------------------------------------------------------------------
-- Revisions of Mirdain-Include and sample job files from 1.6.0 forward were conceived and programmed by Rahvin.
-- README.md covers installation, features, commands and troubleshooting

-- Enhanced features compared to Mirdain 1.5.X:
-- Hoxne Ampulla Mode with automatic equipping and item use. 
--     Specialized modes: (ON-Allow Critical) allow critical spells to equip ranged and ammo
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

-----------------------------------------------------------------------------

-- Global Variables
Mirdain_GS = '1.6.6'

-- Modes is the include file for a mode-tracking variable class.  Used for state vars, below.
include('Modes')

--Herald Lock State Tracking
active_external_locks = {}

-- Weapons
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

--Spell Received Sets
sets.Cure_Received = {}
sets.Cursna_Received = {}
sets.Phalanx_Received = {}
sets.Protect_Shell_Received = {}
sets.Regen_Received = {}
sets.Refresh_Received = {}
sets.Waltz_Received = {}
sets.Holy_Water = {}

-- State sets
sets.OffenseMode = {}
sets.OffenseMode.AM = {}
sets.OffenseMode.AM1 = {}
sets.OffenseMode.AM2 = {}
sets.OffenseMode.AM3 = {}

sets.DualWield = {}

-- Precast
sets.Precast = {}
sets.Precast.FastCast = {}
sets.Precast.Blue_Magic = {}
sets.Precast.Enhancing = {}
sets.Precast.Cure = {}
sets.Precast.Utsusemi = {}
sets.Precast.Songs = {}

sets.Precast.RA = {}
sets.Precast.RA.Flurry = {}
sets.Precast.RA.Flurry_II = {}

-- Midcast
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

-- Midcast
sets.Midcast.SIRD = {}
sets.Midcast.Nuke = {}
sets.Midcast.Burst = {}
sets.Midcast.Cure = {}
sets.Midcast.Curaga = {}
sets.Midcast.Cura = {}
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

-- Bard Midcast
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

-- Midcast for Ranged Attacks and Aftermath
sets.Midcast.AM = {}
sets.Midcast.RA.AM = {}
sets.Midcast.AM1 = {}
sets.Midcast.RA.AM1 = {}
sets.Midcast.AM2 = {}
sets.Midcast.RA.AM2 = {}
sets.Midcast.AM3 = {}
sets.Midcast.RA.AM3 = {}

--Weaponskills
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

-- Other Sets
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

--Modes for Melee
state.OffenseMode = M { ['description'] = 'Melee Mode' }
state.OffenseMode:options('TP', 'ACC', 'DT')
state.OffenseMode:set('TP')

--Modes for Spell-Received Tracking via IPC. ON equips the received gear and keeps
--those slots locked until the caster's spell completes, unlocking at completion
--or after the configured delay as a failsafe.
state.SpellReceived = M { ['description'] = "Spell-Received" }
state.SpellReceived:options('OFF', 'ON')
state.SpellReceived:set('ON')

--Modes for Hoxne Ampulla locking
state.Hoxne = M { ['description'] = 'Hoxne' }
state.Hoxne:options('OFF', 'ON-Allow Critical', 'ON-Locked')
state.Hoxne:set('OFF')

--Modes for Auto Buff
state.AutoBuff = M { ['description'] = 'Auto Buff Mode' }
state.AutoBuff:options('OFF', 'ON')
state.AutoBuff:set('OFF')

--TH mode handling
state.TreasureMode = M { ['description'] = 'Treasure Mode' }
if player.main_job == "THF" then
    state.TreasureMode:options('None', 'Tag', 'Full Time', 'SATA')
    state.TreasureMode:set('Full Time')
else
    state.TreasureMode:options('None', 'Tag', 'Full Time')
    state.TreasureMode:set('None')
end

--Weapon specific modes
state.WeaponMode = {}
state.WeaponMode = M { ['description'] = 'Weapon Specific Mode' }
state.WeaponMode:options('OFF', 'ON')
state.WeaponMode:set('OFF')

--Job specific modes
state.JobMode = {}
state.JobMode = M { ['description'] = 'Job Specific Mode' }
state.JobMode:options('OFF', 'ON')
state.JobMode:set('OFF')

--Job specific modes
state.JobMode2 = {}
state.JobMode2 = M { ['description'] = 'Job Specific Mode' }
state.JobMode2:options('OFF', 'ON')
state.JobMode2:set('OFF')

--Ranged Attack mode
state.RAMode = {}
state.RAMode = M { ['description'] = 'Ranged Attack Mode' }
state.RAMode:options('Bullet', 'Arrow', 'Bolt')
state.RAMode:set('Bullet')

--State for Ammunition check
state.warned = M(false)

--Ammunition
Ammo = {}
Ammo.Bullet = {}
Ammo.Arrow = {}
Ammo.Bolt = {}

Ammo_Warning_Limit = 99

-- User Defined

is_Busy = false
AutoItem = false
Random_Lockstyle = false
Lockstyle_List = {}

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

-- BluePhysical - weapon accuracy + stat mod + physical Attack.  MAB does nothing.
-- White Wind is deliberately absent: floor(MaxHP/7)*2 scaled by Cure Potency and
-- unaffected by Blue Magic Skill or MND, so it uses sets.Midcast['White Wind'].
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
-- BlueBreath   - HP and level only (Hecatomb Wave = CurrentHP/4 + Level/1.5).
-- INT, MAB and Blue Magic Skill do nothing.
BlueBreath = S { 'Bad Breath', 'Flying Hip Press', 'Frost Breath', 'Heat Breath',
    'Hecatomb Wave', 'Magnetite Cloud', 'Poison Breath', 'Radiant Breath', 'Self-Destruct',
    'Thunder Breath', 'Vapor Spray', 'Wind Breath' }
-- BlueNuke     - magical damage (MAB, INT/MND/CHR/VIT/DEX/AGI per spell).
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
-- BlueSkill - potency scales with Blue Magic Skill (Occultation shadows =
-- floor(skill/50); Atra. Libations drain = skill*.11*9).
BlueSkill = S { 'Atra. Libations', 'Barrier Tusk', 'Diamondhide', 'Magic Barrier',
    'Metallic Body', 'Occultation', 'Plasma Charge', 'Pyric Bulwark', 'Reactor Cool' }
--   BlueBuff - fixed potency; only duration responds to gear.
BlueBuff = S { 'Amplification', 'Animating Wail', 'Battery Charge', 'Carcharian Verve',
    'Cocoon', 'Erratic Flutter', 'Exuviation', 'Fantod', 'Feather Barrier', 'Harden Shell',
    'Memento Mori', 'Mighty Guard', 'Nat. Meditation', 'O. Counterstance', 'Refueling',
    'Regeneration', 'Saline Coat', 'Triumphant Roar', 'Warm-Up', 'Winds of Promy.',
    'Zephyr Mantle' }
-- BlueHealing - Cure Potency, MND, Blue Magic Skill
-- White Wind is deliberately absent: it heals floor(MaxHP/7)*2 scaled by Cure
-- Potency and is unaffected by Blue Magic Skill or MND, so it uses its own named
-- set (sets.Midcast["White Wind"]) rather than the healing bucket.
BlueHealing = S { 'Healing Breeze', 'Magic Fruit', 'Plenilune Embrace', 'Pollen', 'Restoral',
    'Wild Carrot' }
-- BlueTank - enmity-generating enfeebles.
BlueTank = S { 'Actinic Burst', 'Blank Gaze', 'Demoralizing Roar', 'Frightful Roar',
    'Geist Wall', 'Jettatura', 'Sheep Song', 'Soporific', 'Stinking Gas' }
-- BlueACC - enfeebles/debuffs wanting magic accuracy.
BlueACC = S { '1000 Needles', 'Absolute Terror', 'Auroral Drape', 'Awful Eye',
    'Blistering Roar', 'Blood Drain', 'Blood Saber', 'Chaotic Eye', 'Cimicine Discharge',
    'Cold Wave', 'Corrosive Ooze', 'Cruel Joke', 'Digest', 'Dream Flower', 'Enervation',
    'Feather Tickle', 'Filamented Hold', 'Infrasonics', 'Light of Penance', 'Lowing',
    'MP Drainkiss', 'Mortal Ray', 'Osmosis', 'Reaving Wind', 'Sandspin', 'Sandspray',
    'Sound Blast', 'Venom Shell', 'Voracious Trunk', 'Yawn' }

Elemental_Enfeeble = S { 'Burn', 'Frost', 'Choke', 'Rasp', 'Shock', 'Drown' }

Healing_Magic = S { 'Arise', 'Blinda', 'Esuna', 'Paralyna', 'Poisona', 'Raise', 'Raise II', 'Raise III', 'Reraise', 'Reraise II', 'Reraise III', 'Reraise IV', 'Sacrifice', 'Silena', 'Stona', 'Viruna', 'Cursna' }

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

SongCount = S { "Knight's Minne", "Knight's Minne II", "Army's Paeon", "Army's Paeon II", "Army's Paeon III", "Army's Paeon IV", "Fowl Aubade", "Herb Pastoral",
    "Shining Fantasia", "Scop's Operetta", "Puppet's Operetta", "Gold Capriccio", "Warding Round", "Goblin Gavotte" }

Enfeebling_Ninjitsu = S { 'Jubaku: Ichi', 'Kurayami: Ni', 'Hojo: Ichi', 'Hojo: Ni', 'Kurayami: Ichi', 'Dokumori: Ichi', 'Aisha: Ichi', 'Yurin: Ichi' }

Elemental_Bar = S { 'Barfire', 'Barblizzard', 'Baraero', 'Barstone', 'Barthunder', 'Barwater', 'Barfira', 'Barblizzara', 'Baraera', 'Barstonra', 'Barthundra', 'Barwatera' }
Status_Bar = S { 'Barsleepra', 'Barpoisonra', 'Barparalyzra', 'Barblindra', 'Barvira', 'Barpetra', 'Baramnesra', 'Barsilencera', 'Barsleep', 'Barpoison', 'Barparalyze', 'Barblind', 'Barvirus', 'Barpetrify', 'Baramnesia', 'Barsilence' }

-- Standard Ready Moves
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

-- List of Magic-based Ready moves
Ready_Magic = S { 'Dust Cloud', 'Sheep Song', 'Scream', 'Dream Flower', 'Roar', 'Gloeosuccus', 'Palsy Pollen',
    'Soporific', 'Cursed Sphere', 'Venom', 'Geist Wall', 'Toxic Spit', 'Numbing Noise', 'Spoil', 'Hi-Freq Field',
    'Sandpit', 'Sandblast', 'Venom Spray', 'Bubble Shower', 'Filamented Hold', 'Queasyshroom', 'Silence Gas',
    'Numbshroom', 'Spore', 'Dark Spore', 'Shakeshroom', 'Fireball', 'Plague Breath', 'Infrasonics', 'Chaotic Eye',
    'Blaster', 'Intimidate', 'Snow Cloud', 'Noisome Powder', 'TP Drainkiss', 'Jettatura', 'Charged Whisker',
    'Purulent Ooze', 'Corrosive Ooze', 'Aqua Breath', 'Molting Plumage', 'Stink Bomb', 'Nectarous Deluge',
    'Nepenthic Plunge', 'Pestilent Plume', 'Foul Waters', 'Spider Web' }

-- List of TP based Ready moves
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

-- Magic ACC Based Ready moves
Ready_Debuff = S { 'Dust Cloud', 'Sheep Song', 'Scream', 'Dream Flower', 'Roar', 'Gloeosuccus', 'Palsy Pollen',
    'Soporific', 'Geist Wall', 'Numbing Noise', 'Spoil', 'Hi-Freq Field', 'Sandpit', 'Sandblast', 'Filamented Hold',
    'Spore', 'Fireball', 'Infrasonics', 'Chaotic Eye', 'Blaster', 'Intimidate', 'Noisome Powder', 'TP Drainkiss',
    'Jettatura', 'Purulent Ooze', 'Corrosive Ooze', 'Pestilent Plume', 'Spider Web', 'Nihility Song' }

-- Physical Ready moves that have Multi-Hit
Ready_Multi = S { 'Sweeping Gouge', 'Tickling Tendrils', 'Chomp Rush', 'Pentapeck', 'Wing Slap', 'Pecking Flurry' }

-- Long names, used in chat messages. Empty hides the mode entirely.
UI_Name = ''
UI_Name2 = ''

-- Optional short labels for the status box. Leave empty and the include derives
-- one from UI_Name, so existing job files need no changes.
UI_Short = ''
UI_Short2 = ''

-- Keep local variables to the include
do
    -- Used to save the user specific settings
    local config = require('config')
    local res = require('resources')
    local socket = require('socket')
    local packets = require('packets')
    local extdata = require('extdata')

    local default = {
        visible = true,
        oneline = true,
        debug = false,
        info = true,
        warn = true,
        Display_Box = { text = { size = 11, font = 'Consolas', red = 255, green = 255, blue = 255, alpha = 255, stroke = { width = 2, alpha = 200, red = 0, green = 0, blue = 0 } }, pos = { x = 0, y = 0 }, bg = { visible = true, red = 0, green = 0, blue = 0, alpha = 190 }, flags = { bold = true }, padding = 3 },
        Debug_Box = { text = { size = 11, font = 'Consolas', red = 255, green = 255, blue = 255, alpha = 255, stroke = { width = 2, alpha = 200, red = 0, green = 0, blue = 0 } }, pos = { x = 0, y = 50 }, bg = { visible = true, red = 0, green = 0, blue = 0, alpha = 190 }, flags = { bold = true }, padding = 3 },
        delay = 3,
    }

    local buttons = { 'State', 'TH Mode', 'Auto Buff', 'Weapon', 'Job Mode' }

    local Storms = S { "Aurorastorm", "Voidstorm", "Firestorm", "Sandstorm", "Rainstorm", "Windstorm", "Hailstorm", "Thunderstorm",
        "Aurorastorm II", "Voidstorm II", "Firestorm II", "Sandstorm II", "Rainstorm II", "Windstorm II", "Hailstorm II", "Thunderstorm II" }

    local UtsusemiSpell = S { 'Utsusemi: Ichi', 'Utsusemi: Ni', 'Utsusemi: San' }

    -- Used only for the get_spell_recasts() pre-check in pretargetcheck().
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

    -- Types that additionally arm the post-cast busy window in precast()/aftercast().
    local RecastTimers = {
        ['WhiteMagic'] = true,
        ['BlackMagic'] = true,
        ['Ninjutsu']   = true,
        ['BardSong']   = true,
        ['Geomancy']   = true,
    }
    local SleepSongs = S { 'Foe Lullaby', 'Foe Lullaby II', 'Horde Lullaby', 'Horde Lullaby II', }

    local Divergence_Zones = S { "Dynamis - San d'Oria [D]", "Dynamis - Bastok [D]", "Dynamis - Windurst [D]", "Dynamis - Jeuno [D]" }

    local settings = config.load(default)

    --Function to apply display box settings.  Used after display creation to ensure settings are tied to the newly created box for auto-saving.
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

    local gs_status = texts.new("", settings.Display_Box, settings)
    local gs_debug = texts.new("", settings.Debug_Box, settings)

    apply_box_settings(gs_status, settings.Display_Box)
    apply_box_settings(gs_debug, settings.Debug_Box)

    --Sets status and debug displays to draggable only when displayed
    gs_status:draggable(settings.visible and true or false)
    gs_debug:draggable(settings.debug and true or false)

    if settings.visible then gs_status:show() end
    if settings.debug then gs_debug:show() end

    local DualWield = false
    local TwoHand = false

    local SpellCastTime = 0
    local Spellstart = os.clock()

    local is_moving = false
    local is_first_time_load = true

    local last_skillchain_id = 0
    local last_skillchain_time = 0
    local last_skillchain_elements = {}

    local UpdateTime1 = os.clock()
    local UpdateTime2 = os.clock()
    local Location = { x = 0, y = 0, z = 0 }
    local main_engine_time = os.clock()

    local Require_Update = false
    local available_bullets = 0

    -- Spell-Received Gear Tracking. Cache heavy API endpoints and immutable configurations outside the function scope.
    local outgoing_cast_active = false
    local accession_predicted = false
    local divine_seal_predicted = false
    local active_incoming_casters = {}
    local cast_start_time = 0
    local failsafe_active = false
    local failsafe_trigger_time = 0
    local ffxi = windower.ffxi
    local get_ability_recasts = ffxi.get_ability_recasts
    local get_spell_recasts = ffxi.get_spell_recasts
    local get_mob_by_id = ffxi.get_mob_by_id
    local get_mob_by_name = ffxi.get_mob_by_name
    local get_party = ffxi.get_party
    local send_ipc = windower.send_ipc_message
    local NEARBY_MEMBERS_BUFFER = {}

    -- Static string buffers to be reused to eliminate runtime GC string allocations
    local BUFF_SLEEP, BUFF_STUN, BUFF_KO = 'Sleep', 'Stun', 'KO'
    local BUFF_PETRI, BUFF_CHARM, BUFF_TERROR = 'Petrification', 'Charm', 'Terror'
    local TYPE_JA, TYPE_WS, TYPE_MS, TYPE_SCH = 'JobAbility', 'WeaponSkill', 'Magic', 'Scholar'

    -- Tracking vars for TH
    local th_info = {}
    th_info.tagged_mobs = T {}
    th_info.last_player_target_index = 0

    -- For TH handling, which event IDs to register for tagging
    local TaggingCategories = S { 1, 2, 3, 4, 6, 11, 14 }

    local Mage_Job = S { 'BLM', 'RDM', 'WHM', 'BRD', 'BLU', 'GEO', 'SCH', 'NIN', 'PLD', 'RUN', 'DRK', 'SMN' }

    -- City areas for town gear and behavior.
    local Cities = S { "Ru'Lude Gardens", "Upper Jeuno", "Lower Jeuno", "Port Jeuno", "Port Windurst", "Windurst Waters", "Windurst Woods", "Windurst Walls", "Heavens Tower", "Port San d'Oria", "Northern San d'Oria",
        "Southern San d'Oria", "Chateau d'Oraguille", "Port Bastok", "Bastok Markets", "Bastok Mines", "Metalworks", "Aht Urhgan Whitegate", "The Colosseum", "Tavnazian Safehold", "Nashmau", "Selbina",
        "Mhaura", "Rabao", "Norg", "Kazham", "Eastern Adoulin", "Western Adoulin", "Celennia Memorial Library", "Mog Garden", "Leafallia" }

    local Language = windower.ffxi.get_info().language:lower()

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

    -- Spell definitions with metadata to dictate equipment categories and AoE rules
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

    -- Consolidated abilities mapping
    local ability_info = {
        [190] = { name = "Curing Waltz", category = 'track_waltz', equip = "waltz_set", aoe = false, accession = false },     --Curing Waltz
        [191] = { name = "Curing Waltz II", category = 'track_waltz', equip = "waltz_set", aoe = false, accession = false },  --Curing Waltz II
        [192] = { name = "Curing Waltz III", category = 'track_waltz', equip = "waltz_set", aoe = false, accession = false }, --Curing Waltz III
        [193] = { name = "Curing Waltz IV", category = 'track_waltz', equip = "waltz_set", aoe = false, accession = false },  --Curing Waltz IV
        [311] = { name = "Curing Waltz V", category = 'track_waltz', equip = "waltz_set", aoe = false, accession = false },   --Curing Waltz V
        [195] = { name = "Divine Waltz", category = 'track_waltz', equip = "waltz_set", aoe = true, accession = false },      --Divine Waltz
        [262] = { name = "Divine Waltz II", category = 'track_waltz', equip = "waltz_set", aoe = true, accession = false },   --Divine Waltz II
    }

    --Unlock any previously locked gear
    enable('main', 'sub', 'range', 'ammo', 'head', 'neck', 'lear', 'rear', 'body', 'hands', 'lring', 'rring', 'waist',
        'legs', 'feet')

    --Get the time in milliseconds from socket to provide synchronous time for all clients.
    --Must use socket instead of os.clock() for this purpose
    local function get_time()
        return math.floor(socket.gettime() * 1000)
    end

    --Used to display timestamped debug messages when debug mode is on
    local function debug(message)
        if not settings.debug then return end
        windower.add_to_chat(121, "[Mirdain Debug] " .. message)
    end

    --Check if a set has a slot/gear combo defined
    --Return the item name for a given slot within a set or nil if it isn't defined
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

    --Check if a name is currently in the character's party.
    --Return true if target is in party
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

    -- Canonical slot names, mirroring GearSwap's default_slot_map (statics.lua:148).
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

    -- In-place equivalent of: built_set = set_combine(built_set, layer)
    -- Reduces table creation and GC from set_combine
    local function merge_into(base, layer)
        if type(layer) ~= 'table' then return base end
        for slot, item in pairs(layer) do
            local canon = CANON_SLOT[slot] or (type(slot) == 'string' and CANON_SLOT[slot:lower()])
            if canon then base[canon] = item end
        end
        return base
    end

    --Given the mob being targeted and the name currently addressed on the outgoing IPC message,
    --expand target_name to a comma-separated list of party members within AoE range (10 yalms),
    --or return it unchanged if the target isn't a valid AoE candidate.
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

    --Calculate and return how many strategems are off cooldown.
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

    --Helper function to count and return the number of entries in the top level of a table.
    local function count_keys(tbl)
        local count = 0
        for _ in pairs(tbl) do
            count = count + 1
        end
        return count
    end

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
                info("Cure Received set")
            else
                warn("sets.Cure_Received not found!")
            end
        elseif s_info.equip == "cursna_set" then
            if sets.Cursna_Received then
                spell_received_set = sets.Cursna_Received
                info("Cursna Received set")
            else
                warn("sets.Cursna_Received not found!")
            end
        elseif s_info.equip == "phalanx_set" then
            if sets.Phalanx_Received then
                spell_received_set = sets.Phalanx_Received
                info("Phalanx Received set")
            else
                warn("sets.Phalanx_Received not found!")
            end
        elseif s_info.equip == "protect_shell_set" then
            if sets.Protect_Shell_Received then
                spell_received_set = sets.Protect_Shell_Received
                info("Protect and Shell Received set")
            else
                warn("sets.Protect_Shell_Received not found!")
            end
        elseif s_info.equip == "regen_set" then
            if sets.Regen_Received then
                spell_received_set = sets.Regen_Received
                info("Regen Received set")
            else
                warn("sets.Regen_Received not found!")
            end
        elseif s_info.equip == "refresh_set" then
            if sets.Refresh_Received then
                spell_received_set = sets.Refresh_Received
                info("Refresh Received set")
            else
                warn("sets.Refresh_Received not found!")
            end
        elseif s_info.equip == "waltz_set" then
            if sets.Waltz_Received then
                spell_received_set = sets.Waltz_Received
                info("Waltz Received set")
            else
                warn("sets.Waltz_Received not found!")
            end
        else
            warn("Unknown Equip Set for Spell Received Gear")
        end

        if type(spell_received_set) == 'table' then
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
    -------------------------------------------------------------------------------------------------------------------
    -- ENCHANTED ITEM ENGINE + HOXNE AMPULLA AUTOMATION
    -------------------------------------------------------------------------------------------------------------------

    -- res slot id -> GearSwap slot name.  Matches GearSwap's default_slot_map
    -- (statics.lua:97), which is what player.equipment is keyed by and what
    -- equip()/disable() accept.
    local ENCH_SLOT_NAMES = {
        [0] = 'main',  [1] = 'sub',       [2] = 'range',     [3] = 'ammo',
        [4] = 'head',  [5] = 'body',      [6] = 'hands',     [7] = 'legs',
        [8] = 'feet',  [9] = 'neck',      [10] = 'waist',
        [11] = 'left_ear',  [12] = 'right_ear',
        [13] = 'left_ring', [14] = 'right_ring', [15] = 'back',
    }

    -- 0 = Inventory, 8 = Wardrobe, 10-16 = Wardrobes 2-8.
    local ENCH_BAGS = { 0, 8, 10, 11, 12, 13, 14, 15, 16 }

    -- Lowercased name -> resource row, built once on first use.
    -- self_command() lowercases every command, but 126 of the 533 usable enchanted
    -- items have a mixed-case 'enl' ("Prishe's boots +1", "Hoxne ampulla", "Warp
    -- cudgel") and every item's 'en' is capitalised - so the old
    -- res.items:with('enl',x) or res.items:with('en',x) could never match those.
    -- 'en' is indexed first so a real item name is never shadowed by another
    -- item's log name (Albatross Ring, Pandit's Staff, etc).
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

    -- Returns: resource row (nil if the name is unknown), decoded extdata (or nil),
    -- and whether you are actually carrying it.
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
                        return row, (ok and ext) or nil, true
                    end
                end
            end
        end
        return row, nil, false
    end

    -- Seconds until the enchantment can be used.  0 = ready, nil = unknown.
    -- extdata.next_use_time is a Unix timestamp (extdata.lua adds
    -- server_timestamp_offset = 1009792800), so it compares to os.time().
    local function enchantment_wait(ext)
        if not ext then return nil end
        if ext.next_use_time then
            local remain = ext.next_use_time - os.time()
            if remain > 0 then return remain end
        end
        return 0
    end

    -- Cooldown warnings are throttled by the item's own ready-time: once warned,
    -- stay silent until it is actually back.  This is what stops the 1 Hz Hoxne
    -- tick from spamming chat through the Ampulla's 60 second recast.
    local ench_warned = {}
    local function warn_unavailable(row, wait)
        local ready_at = os.time() + math.ceil(wait)
        if (ench_warned[row.id] or 0) >= ready_at then return end
        ench_warned[row.id] = ready_at
        if wait >= 3600 then
            warn(('%s is on cooldown [%dh %dm].'):format(
                row.en, math.floor(wait / 3600), math.floor(wait % 3600 / 60)))
        else
            warn(('%s is on cooldown [%d:%02d].'):format(
                row.en, math.floor(wait / 60), math.floor(wait % 60)))
        end
    end

    -------------------------------------------------------------------------------
    -- Hoxne state
    -------------------------------------------------------------------------------
    local HOXNE_AMPULLA = 'Hoxne Ampulla'
    local BUFF_ENCHANTMENT = 162   -- res.buffs[162] = "enchantment"

    local hoxne = {
        window     = false,  -- a critical action currently owns one slot
        slot       = nil,    -- which slot it borrowed ('range' or 'ammo')
        expires    = 0,      -- os.clock() deadline for that window
        resume     = nil,    -- 'aftercast' | 'delay'
        next_check = 0,      -- os.clock() gate for hoxne_tick (always 1s)
        recheck_at = 0,      -- os.clock() before which the bags are not re-scanned
    }

    local function hoxne_on() return state.Hoxne.value ~= 'OFF' end

    -- Global so UnlockByMode() can consult it.  During an open critical window
    -- ONLY the borrowed slot is considered released - the other stays held, so an
    -- unrelated UnlockByMode() (any item finishing, Doom/Sleep wearing off, a zone
    -- change) cannot flush parked job ammo in and displace the instrument.
    function hoxne_owns_slot(slot)
        if not hoxne_on() then return false end
        local s = (slot == 'ranged') and 'range' or slot
        if s ~= 'range' and s ~= 'ammo' then return false end
        if hoxne.window then return s ~= hoxne.slot end
        return true
    end

    -------------------------------------------------------------------------------
    -- Enchantment state machine.  No coroutines: a single driver (registered on
    -- prerender, further down) advances this, so two chains can never exist and
    -- nothing survives a //gs reload.
    -------------------------------------------------------------------------------
    local ench_active = nil
    local ench_next_check = 0

    local function finish_enchantment()
        local st = ench_active
        ench_active = nil
        if not st then return end
        if not hoxne_owns_slot(st.slot) then enable(st.slot) end
        equip_set_command()
    end

    -- Called from the 'action' event.  The "item finished" packet is generic - it
    -- fires for food, Remedies, Holy Water, anything - so only accept it as ours
    -- once we have actually sent our own /item.
    function enchantment_completed()
        if ench_active and ench_active.phase == 'sent' then finish_enchantment() end
    end

    local function enchantment_tick(now)
        local st = ench_active
        if not st or now < st.next_step then return end

        if now > st.deadline then
            warn(st.name .. ': timed out, releasing lock.')
            finish_enchantment()
            return
        end

        if st.phase == 'sent' then
            st.next_step = now + 1
            return
        end

        -- Something took the slot (in-game /equipset, or the game clearing ammo).
        if player.equipment[st.slot] ~= st.name then
            st.attempts = st.attempts + 1
            if st.attempts > 3 then
                warn(st.name .. ': could not keep it equipped in ' .. st.slot .. '.')
                finish_enchantment()
                return
            end
            enable(st.slot)
            equip({ [st.slot] = st.name })
            disable(st.slot)
            st.equipped_at = now
            st.next_step = now + st.cast_delay + 1
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

        local row, ext = find_enchantment(st.name)
        local wait = enchantment_wait(ext)
        if wait and wait > 0 then
            if wait < 15 then
                st.next_step = now + wait + 0.5
            else
                warn_unavailable(row or { id = st.id, en = st.name }, wait)
                finish_enchantment()
            end
            return
        end

        log('/item "', st.name, '" <me>')
        windower.chat.input('/item "' .. st.name .. '" <me>')
        st.phase = 'sent'
        st.next_step = now + 1
        st.deadline = math.min(st.deadline, now + st.cast_time + 8)
    end

    function use_enchantment(item)
        local row, ext, carried = find_enchantment(item)
        if not row then
            info('Unknown enchanted item: [' .. tostring(item) .. ']')
            return
        end
        if not carried then
            info(row.en .. ': not found in inventory or wardrobes.')
            return
        end
        if ench_active then
            info('Already using [' .. ench_active.name .. ']. Ignoring [' .. row.en .. '].')
            return
        end

        local wait = enchantment_wait(ext)
        if wait and wait > 0 then
            warn_unavailable(row, wait)
            return
        end

        -- Prefer the slot the item already occupies: rings list both slots and
        -- pairs() order is undefined, which is why the old loop picked at random.
        local slot, first
        for id = 0, 15 do
            if row.slots:contains(id) then
                local name = ENCH_SLOT_NAMES[id]
                first = first or name
                if player.equipment[name] == row.en then
                    slot = name
                    break
                end
            end
        end
        slot = slot or first
        if not slot then
            info('No equippable slot for [' .. row.en .. '].')
            return
        end

        local cd, ct = row.cast_delay or 5, row.cast_time or 1
        local now = os.clock()
        ench_active = {
            name = row.en, id = row.id, slot = slot,
            cast_delay = cd, cast_time = ct,
            equipped_at = now, attempts = 0, phase = 'waiting',
            next_step = now + cd + 1,
            deadline  = now + cd + ct + 12,
        }

        enable(slot)
        equip({ [slot] = row.en })
        disable(slot)
        log('use_enchantment: ', row.en, ' -> ', slot)
    end

    -------------------------------------------------------------------------------
    -- Hoxne enforcement
    -------------------------------------------------------------------------------
    -- enable() is bound to user_enable() (GearSwap refresh.lua:117), which
    -- immediately re-equips whatever choose_set() parked in not_sent_out_equip
    -- while the slot was locked.  The enable/equip/disable trio must therefore
    -- happen in ONE event and in THIS order, so the Ampulla wins the same
    -- equip_list flush as the parked job ammo.
    local function hoxne_equip_ampulla()
        enable('range', 'ammo')
        equip({ range = empty, ammo = HOXNE_AMPULLA })
        disable('range', 'ammo')
    end

    local function hoxne_relock()
        hoxne.window = false
        hoxne.slot   = nil
        hoxne.resume = nil
        hoxne_equip_ampulla()
        equip_set_command()
        log('Hoxne: critical window closed, Ampulla re-locked.')
    end

    local function hoxne_tick(now)
        if not hoxne_on() then return end

        -- While a critical window is open this is a passive observer: it only
        -- compares the clock.  It never reads or writes equipment, so a borrowed
        -- instrument or Angon cannot be overwritten before the window closes.
        if hoxne.window then
            if now >= hoxne.expires then hoxne_relock() end
            return
        end

        if ench_active then return end

        -- Re-assert the lock every tick.  disable() is a pure table write into
        -- GearSwap's disable_table (user_functions.lua:131) - no packet, no equip -
        -- so this is effectively free, and it makes the mode self-healing after
        -- 'gs c enableall' or any other blanket enable().  That is why Unlock()
        -- does not need to know about Hoxne: the owner re-establishes its own
        -- invariant instead of every unlocker having to know about it.
        disable('range', 'ammo')

        -- disable() only stops GearSwap from swapping.  The game still clears
        -- ammo when an instrument enters range, and in-game /equipset bypasses
        -- disable_table entirely - so repair the slot here.
        if player.equipment.ammo ~= HOXNE_AMPULLA then
            local _, _, carried = find_enchantment(HOXNE_AMPULLA)
            if not carried then return end
            hoxne_equip_ampulla()
            return
        end

        if buffactive[BUFF_ENCHANTMENT] then return end
        if is_Busy or is_moving or midaction() or pet_midaction() then return end
        if player.status == 'Dead' or player.status == 'Engaged dead' then return end

        -- Bag-scan gate.  windower.ffxi.get_items() marshals a full table per bag
        -- and find_enchantment() walks up to nine of them, so during a recast gap
        -- re-scan at most every 10 seconds, or the moment the cooldown completes,
        -- whichever comes first.  This gate covers ONLY the scan: the tick itself
        -- keeps running once per second, so the repair path and the disable()
        -- re-assert above stay at one-second latency in every state.
        if now < hoxne.recheck_at then return end

        local row, ext = find_enchantment(HOXNE_AMPULLA)
        if not row then return end
        local wait = enchantment_wait(ext)
        if wait and wait > 0 then
            warn_unavailable(row, wait)
            hoxne.recheck_at = now + math.min(wait, 10)
            return
        end
        -- Assume the use lands.  If it did, buff 162 short-circuits this function
        -- long before the gate matters; if it did not, we retry within 10 seconds.
        hoxne.recheck_at = now + math.min(row.recast_delay or 60, 10)

        log('/item "', HOXNE_AMPULLA, '" <me>')
        windower.chat.input('/item "' .. HOXNE_AMPULLA .. '" <me>')
    end

    -------------------------------------------------------------------------------
    -- Critical actions allowed to borrow range/ammo in 'ON-Allow Critical'.
    -- Verified against Windower resources:
    --   Angon          id 18259, slots=8 -> ammo   (DRG)
    --   Thr. Tomahawk  id 18258, slots=8 -> ammo   (WAR; the ammo item is
    --                                       "Thr. Tomahawk", NOT "Tomahawk",
    --                                       which is a level 25 main/sub axe)
    --   Marsyas        id 21398, slots=4 -> range  (BRD)
    --   Dunna          id 21372, slots=4 -> range  (GEO)
    -- Job abilities: Tomahawk = 150, Angon = 170.
    -- Spell types:   'BardSong'; Geo- and Indi- are both 'Geomancy'.
    -------------------------------------------------------------------------------
    local CRITICAL_JA = {
        [150] = { slot = 'ammo', force = 'Thr. Tomahawk', resume = 'aftercast' },
        [170] = { slot = 'ammo', force = 'Angon',         resume = 'aftercast' },
    }
    local CRITICAL_TYPE = {
        ['BardSong'] = { slot = 'range', resume = 'delay', delay = 5 },
        ['Geomancy'] = { slot = 'range', resume = 'delay', delay = 5 },
    }

    function critical_action_for(spell)
        if not spell then return nil end
        if spell.type == TYPE_JA then return CRITICAL_JA[spell.id] end
        return CRITICAL_TYPE[spell.type]
    end

    -------------------------------------------------------------------------------------------------------------------
    -- This function is called from the default GearSwap Function "pretarget" to validate the user action
    -------------------------------------------------------------------------------------------------------------------

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

    -------------------------------------------------------------------------------------------------------------------
    -- This function is called from the default GearSwap Function "precast" to build an built_set
    -------------------------------------------------------------------------------------------------------------------

    function precastequip(spell)
        log('precastequip Called')
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
        if sets.Idle then merge_into(built_set, sets.Idle) end
        -- WeaponSkill
        if spell.type == 'WeaponSkill' then
            if sets.WS then
                merge_into(built_set, sets.WS)
                local message = ''
                if spell.skill == "Marksmanship" or spell.skill == "Archery" then
                    -- Try to equip a generic ranged WS set
                    if sets.WS.RA then
                        merge_into(built_set, sets.WS.RA)
                    else
                        warn('sets.WS.RA not found!')
                    end

                    -- Set is defined
                    if sets.WS[spell.english] then
                        merge_into(built_set, sets.WS[spell.english])
                        -- Example would be WS[Savage Blade]['PDL']
                        if sets.WS[spell.english][state.OffenseMode.value] then
                            merge_into(built_set, sets.WS[spell.english][state.OffenseMode.value])
                            message = '[' .. spell.english .. '] Set (Augmented)'
                            -- Example would be WS.RA.ACC
                        elseif state.OffenseMode.value ~= 'TP' and sets.WS.RA and sets.WS.RA[state.OffenseMode.value] then
                            merge_into(built_set, sets.WS.RA[state.OffenseMode.value])
                            -- Augment the specified WS
                            if state.OffenseMode.value == 'ACC' then
                                message = '[' .. spell.english .. '] Set with Accuracy'
                            elseif state.OffenseMode.value == 'PDL' then
                                message = '[' .. spell.english .. '] Set with Physical Damage Limit'
                            elseif state.OffenseMode.value == 'SB' then
                                message = '[' .. spell.english .. '] Set with Subtle Blow'
                            elseif state.OffenseMode.value == 'MEVA' then
                                message = '[' .. spell.english .. '] Set with Magic Evasion'
                            elseif state.OffenseMode.value == 'CRIT' then
                                message = '[' .. spell.english .. '] Set with Critical Hit'
                            end
                        else
                            message = '[' .. spell.english .. '] Set'
                        end

                        -- Generic
                    else
                        if state.OffenseMode.value ~= 'TP' and sets.WS.RA and sets.WS.RA[state.OffenseMode.value] then
                            merge_into(built_set, sets.WS.RA[state.OffenseMode.value])
                            if state.OffenseMode.value == 'ACC' then
                                message = 'Using Default WS Set with Accuracy'
                            elseif state.OffenseMode.value == 'PDL' then
                                message = 'Using Default WS Set with Physical Damage Limit'
                            elseif state.OffenseMode.value == 'SB' then
                                message = 'Using Default WS Set with Subtle Blow'
                            elseif state.OffenseMode.value == 'MEVA' then
                                message = 'Using Default WS Set with Magic Evasion'
                            elseif state.OffenseMode.value == 'CRIT' then
                                message = 'Using Default WS Set with Critical Hit'
                            end
                        else
                            message = 'Using Default WS Set'
                        end
                    end

                    -- Check if Aftermath is active
                    if sets.WS.RA then
                        if buffactive['Aftermath: Lv.3'] and sets.WS.RA.AM3 and sets.WS.RA.AM3[state.WeaponMode.value] then
                            merge_into(built_set, sets.WS.RA.AM3[state.WeaponMode.value])
                            message = message .. ' and Level 3 Aftermath [' .. state.WeaponMode.value .. ']'
                        elseif buffactive['Aftermath: Lv.2'] and sets.WS.RA.AM2 and sets.WS.RA.AM2[state.WeaponMode.value] then
                            merge_into(built_set, sets.WS.RA.AM2[state.WeaponMode.value])
                            message = message .. ' and Level 2 Aftermath [' .. state.WeaponMode.value .. ']'
                        elseif buffactive['Aftermath: Lv.1'] and sets.WS.RA.AM1 and sets.WS.RA.AM1[state.WeaponMode.value] then
                            merge_into(built_set, sets.WS.RA.AM1[state.WeaponMode.value])
                            message = message .. ' and Level 1 Aftermath [' .. state.WeaponMode.value .. ']'
                        elseif buffactive['Aftermath'] and sets.WS.RA.AM and sets.WS.RA.AM[state.WeaponMode.value] then
                            merge_into(built_set, sets.WS.RA.AM[state.WeaponMode.value])
                            message = message .. ' and Aftermath [' .. state.WeaponMode.value .. ']'
                        end
                    end

                    -- Bullet Check
                    do_bullet_checks(spell, built_set)

                    -- Variable Ammo
                    if Ammo and Ammo[state.OffenseMode.value] then
                        merge_into(built_set,
                            { ammo = Ammo[state.OffenseMode.value] })
                    end

                    message = message .. ' [' .. available_bullets .. 'x]'
                else
                    -- Set is defined
                    if sets.WS[spell.english] then
                        merge_into(built_set, sets.WS[spell.english])
                        -- Example would be WS[Savage Blade]['PDL']
                        if sets.WS[spell.english][state.OffenseMode.value] then
                            merge_into(built_set, sets.WS[spell.english][state.OffenseMode.value])
                            message = '[' .. spell.english .. '] Set (Augmented)'
                            -- Example would be WS.ACC
                        elseif state.OffenseMode.value ~= 'TP' and sets.WS[state.OffenseMode.value] then
                            merge_into(built_set, sets.WS[state.OffenseMode.value])
                            -- Augment the specified WS
                            if state.OffenseMode.value == 'ACC' then
                                message = '[' .. spell.english .. '] Set with Accuracy'
                            elseif state.OffenseMode.value == 'PDL' then
                                message = '[' .. spell.english .. '] Set with Physical Damage Limit'
                            elseif state.OffenseMode.value == 'SB' then
                                message = '[' .. spell.english .. '] Set with Subtle Blow'
                            elseif state.OffenseMode.value == 'MEVA' then
                                message = '[' .. spell.english .. '] Set with Magic Evasion'
                            elseif state.OffenseMode.value == 'CRIT' then
                                message = '[' .. spell.english .. '] Set with Critical Hit'
                            end
                        else
                            message = '[' .. spell.english .. '] Set'
                        end

                        -- Generic
                    else
                        if state.OffenseMode.value ~= 'TP' and sets.WS[state.OffenseMode.value] then
                            merge_into(built_set, sets.WS[state.OffenseMode.value])
                            -- Augment the specified WS
                            if state.OffenseMode.value == 'ACC' then
                                message = 'Using Default WS Set with Accuracy'
                            elseif state.OffenseMode.value == 'PDL' then
                                message = 'Using Default WS Set with Physical Damage Limit'
                            elseif state.OffenseMode.value == 'SB' then
                                message = 'Using Default WS Set with Subtle Blow'
                            elseif state.OffenseMode.value == 'MEVA' then
                                message = 'Using Default WS Set with Magic Evasion'
                            elseif state.OffenseMode.value == 'CRIT' then
                                message = 'Using Default WS Set with Critical Hit'
                            end
                        else
                            message = 'Using Default WS Set'
                        end
                    end

                    -- Check if Aftermath is active
                    if buffactive['Aftermath: Lv.3'] and sets.WS.AM3 and sets.WS.AM3[state.WeaponMode.value] then
                        merge_into(built_set, sets.WS.AM3[state.WeaponMode.value])
                        message = message .. ' and Level 3 Aftermath'
                    elseif buffactive['Aftermath: Lv.2'] and sets.WS.AM2 and sets.WS.AM2[state.WeaponMode.value] then
                        merge_into(built_set, sets.WS.AM2[state.WeaponMode.value])
                        message = message .. ' and Level 2 Aftermath'
                    elseif buffactive['Aftermath: Lv.1'] and sets.WS.AM1 and sets.WS.AM1[state.WeaponMode.value] then
                        merge_into(built_set, sets.WS.AM1[state.WeaponMode.value])
                        message = message .. ' and Level 1 Aftermath'
                    elseif buffactive['Aftermath'] and sets.WS.AM and sets.WS.AM[state.WeaponMode.value] then
                        merge_into(built_set, sets.WS.AM[state.WeaponMode.value])
                        message = message .. ' and Aftermath'
                    end
                end

                -- Check if an Obi or Orpheus is to be Equiped
                if Elemental_WS:contains(spell.name) then built_set = elemental_check(spell, built_set) end

                info(message)
            else
                warn('sets.WS not found!')
            end
            -- Ranged attack
        elseif spell.action_type == 'Ranged Attack' then
            if sets.Precast then
                merge_into(built_set, sets.Precast)
                if sets.Precast.RA then
                    merge_into(built_set, sets.Precast.RA)
                    if buffactive[265] then -- Flurry
                        if sets.Precast.RA.Flurry then
                            merge_into(built_set, sets.Precast.RA.Flurry)
                        else
                            warn('sets.Precast.RA.Flurry not found!')
                        end
                    elseif buffactive[581] then -- Flurry II
                        if sets.Precast.RA.Flurry_II then
                            merge_into(built_set, sets.Precast.RA.Flurry_II)
                        else
                            warn('sets.Precast.RA.Flurry_II not found!')
                        end
                    elseif buffactive[228] then -- Embrava
                        if sets.Precast.RA.Flurry_II then
                            merge_into(built_set, sets.Precast.RA.Flurry_II)
                        else
                            warn('sets.Precast.RA.Flurry_II not found!')
                        end
                    end

                    -- Variable Ammo
                    if Ammo and Ammo[state.OffenseMode.value] then
                        merge_into(built_set,
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
                merge_into(built_set, sets.JA)
                if spell.name == 'Double-Up' then -- Double Up for distance
                    if sets.PhantomRoll then
                        merge_into(built_set, sets.PhantomRoll)
                        info('[' .. spell.english .. '] Set')
                    else
                        warn('sets.PhantomRoll not found!')
                    end
                elseif sets.JA[spell.english] then
                    merge_into(built_set, sets.JA[spell.english])
                    --Summon the correct jug pet
                    if spell.name == 'Bestial Loyalty' or spell.name == 'Call Beast' then
                        if sets.Jugs[state.JobMode.value] then
                            merge_into(built_set, sets.Jugs[state.JobMode.value])
                        else
                            warn('sets.Jugs.' .. state.JobMode.value .. ' not found!')
                        end
                    end
                    info('[' .. spell.english .. '] Set')
                else
                    info('JA not set for [' .. spell.english .. ']')
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
                info("Holy Water set")
                if sets.Holy_Water then
                    if sets.Idle then
                        merge_into(built_set, sets.Holy_Water)
                    else
                        warn('sets.Idle not found!')
                    end
                else
                    warn('sets.Holy_Water not found!')
                end
            else
                if sets.Idle then
                    merge_into(built_set, sets.Idle)
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
                merge_into(built_set, sets.JA)
                if sets.JA[spell.english] then
                    merge_into(built_set, sets.JA[spell.english])
                    info('[' .. spell.english .. '] Set')
                else
                    info('Using Default Scholar Set')
                end
            else
                warn('sets.JA not found!')
            end
            -- Ward
        elseif spell.type == 'Ward' then
            if sets.JA then
                merge_into(built_set, sets.JA)
                if sets.JA[spell.english] then
                    merge_into(built_set, sets.JA[spell.english])
                    info('[' .. spell.english .. '] Set')
                else
                    info('Using Default Ward Set')
                end
            else
                warn('sets.JA not found!')
            end
            -- Rune
        elseif spell.type == 'Rune' then
            if sets.JA then
                merge_into(built_set, sets.JA)
                if sets.JA[spell.english] then
                    merge_into(built_set, sets.JA[spell.english])
                    info('[' .. spell.english .. '] Set')
                else
                    info('Using Default Rune Set')
                end
            else
                warn('sets.JA not found!')
            end
            -- Effusion
        elseif spell.type == 'Effusion' then
            if sets.JA then
                merge_into(built_set, sets.JA)
                if sets.JA[spell.english] then
                    merge_into(built_set, sets.JA[spell.english])
                    info('[' .. spell.english .. '] Set')
                else
                    info('Using Default Effusion Set')
                end
            else
                warn('sets.JA not found!')
            end
            -- CorsairRoll
        elseif spell.type == 'CorsairRoll' then
            log('CorsairRoll')
            if sets.PhantomRoll then
                merge_into(built_set, sets.PhantomRoll)
                if sets.PhantomRoll[spell.english] then
                    merge_into(built_set, sets.PhantomRoll[spell.english])
                    info('[' .. spell.english .. '] Set ')
                else
                    info('Roll not set')
                end
            else
                warn('sets.PhantomRoll not found!')
            end
            -- CorsairShot
        elseif spell.type == 'CorsairShot' then
            if sets.QuickDraw then
                merge_into(built_set, sets.QuickDraw)
                if sets.QuickDraw[spell.english] then
                    merge_into(built_set, sets.QuickDraw[spell.english])
                    info('[' .. spell.english .. '] Set')
                else
                    info('Using Default Quick Draw Set')
                end
            else
                warn('sets.QuickDraw not found!')
            end
            -- Waltz
        elseif spell.type == 'Waltz' then
            if sets.Waltz then
                merge_into(built_set, sets.Waltz)
                if sets.Waltz[spell.english] then
                    merge_into(built_set, sets.Waltz[spell.english])
                    info('[' .. spell.english .. '] Set')
                else
                    info('Using Default Waltz Set')
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
                merge_into(built_set, sets.Jig)
                if sets.Jig[spell.english] then
                    merge_into(built_set, sets.Jig[spell.english])
                    info('[' .. spell.english .. '] Set')
                else
                    info('Using Default Jig Set')
                end
            else
                warn('sets.Jig not found!')
            end
            -- Samba
        elseif spell.type == 'Samba' then
            if sets.Samba then
                merge_into(built_set, sets.Samba)
                if sets.Samba[spell.english] then
                    merge_into(built_set, sets.Samba[spell.english])
                    info('[' .. spell.english .. '] Set')
                else
                    info('Using Default Samba Set')
                end
            else
                warn('sets.Samba not found!')
            end
            -- Step
        elseif spell.type == 'Step' then
            if sets.Step then
                merge_into(built_set, sets.Step)
                if sets.Step[spell.english] then
                    merge_into(built_set, sets.Step[spell.english])
                    info('[' .. spell.english .. '] Set')
                else
                    info('Using Default Step Set')
                end
            else
                warn('sets.Step not found!')
            end
            -- Flourishes
        elseif spell.type == 'Flourish1' or spell.type == 'Flourish2' or spell.type == 'Flourish3' then
            if sets.Flourish then
                merge_into(built_set, sets.Flourish)
                if sets.Flourish[spell.english] then
                    merge_into(built_set, sets.Flourish[spell.english])
                    info('[' .. spell.english .. '] Set')
                else
                    info('Using Default Flourish Set')
                end
            else
                warn('sets.Flourish not found!')
            end
            -- Magic based actions
        else
            -- Precast
            if sets.Precast then
                merge_into(built_set, sets.Precast)
                -- FastCast
                if sets.Precast.FastCast then
                    merge_into(built_set, sets.Precast.FastCast)
                    -- Augment with Enhancing set
                    if spell.skill == 'Enhancing Magic' then
                        if sets.Precast.Enhancing then
                            merge_into(built_set, sets.Precast.Enhancing)
                        else
                            warn('sets.Precast.Enhancing not found!')
                        end
                    end
                    -- Specified Sets
                    if sets.Precast[spell.english] then
                        merge_into(built_set, sets.Precast[spell.english])
                        -- Augment with Cure Casting set
                    elseif spell.name:contains('Cure') or spell.name:contains('Cura') then
                        if sets.Precast.Cure then
                            merge_into(built_set, sets.Precast.Cure)
                        else
                            warn('sets.Precast.Cure not found!')
                        end
                        -- Augment with Healing Magic set
                    elseif Healing_Magic:contains(spell.name) then
                        if sets.Precast.Healing then
                            merge_into(built_set, sets.Precast.Healing)
                        else
                            warn('sets.Precast.Healing not found!')
                        end
                        -- Ninjutsu
                    elseif spell.type == 'Ninjutsu' and UtsusemiSpell:contains(spell.name) then
                        do_Utsu_checks(spell)
                        if sets.Precast.Utsusemi then
                            merge_into(built_set, sets.Precast.Utsusemi)
                        else
                            warn('sets.Precast.Utsusemi not found!')
                        end
                        -- Blue Magic
                    elseif spell.type == 'BlueMagic' then
                        if sets.Precast.BlueMagic then
                            merge_into(built_set, sets.Precast.BlueMagic)
                        else
                            warn('sets.Precast.BlueMagic not found!')
                        end
                        -- BardSong
                    elseif spell.type == 'BardSong' then
                        if buffactive['Nightingale'] then
                            -- Default BRD song gear is in Midcast
                            if sets.Midcast then
                                merge_into(built_set, sets.Midcast)
                            else
                                warn('sets.Midcast not found!')
                            end
                            -- Song Count for Dummy Songs
                            if SongCount:contains(spell.name) then
                                if sets.Midcast.DummySongs then
                                    merge_into(built_set, sets.Midcast.DummySongs)
                                else
                                    warn('sets.Midcast.DummySongs not found!')
                                end
                                merge_into(built_set, { range = Instrument.Count })
                                -- Potency / Instruments
                            else
                                -- Defined Gear Set
                                if sets.Midcast[spell.english] then
                                    merge_into(built_set, sets.Midcast[spell.english])
                                    -- Equip Harp
                                elseif spell.name:contains('Horde') then
                                    if sets.Midcast.Enfeebling then
                                        merge_into(built_set, sets.Midcast.Enfeebling)
                                    else
                                        warn('sets.Midcast.Enfeebling not found!')
                                    end
                                    merge_into(built_set, { range = Instrument.AOE_Sleep })
                                    -- Normal Enfeebles
                                elseif Enfeebling_Song:contains(spell.english) then
                                    if sets.Midcast.Enfeebling then
                                        merge_into(built_set, sets.Midcast.Enfeebling)
                                    else
                                        warn('sets.Midcast.Enfeebling not found!')
                                    end
                                    merge_into(built_set, { range = Instrument.Potency })
                                    -- Augment the buff songs
                                else
                                    merge_into(built_set, { range = Instrument.Potency })
                                end
                                -- Augment the specific Song if set
                                merge_into(built_set, equip_song_gear(spell, built_set['range']))
                            end
                        else
                            if sets.Precast.Songs then
                                merge_into(built_set, sets.Precast.Songs)
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

        -- Weapon Checks for precast
        -- If it set to unlocked it will not swap the weapons even if defined in the built_set job lua
        if state.WeaponMode.value ~= "Unlocked" and spell.type ~= 'CorsairRoll' and spell.name ~= 'Double-Up' then
            log('Update Weapons - Precast')
            if state.WeaponMode.value == "Locked" then
                merge_into(built_set,
                    { main = player.equipment.main, sub = player.equipment.sub, range = player.equipment.range })
            else
                if sets.Weapons then
                    if sets.Weapons[state.WeaponMode.value] then
                        merge_into(built_set, sets.Weapons[state.WeaponMode.value])
                        if not TwoHand and not DualWield then
                            if sets.Weapons.Shield then
                                merge_into(built_set, sets.Weapons.Shield)
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
                    merge_into(built_set, sets.Weapons.Songs)
                    if sets.Weapons.Songs.Midcast then
                        if not DualWield and not TwoHand then
                            if sets.Weapons.Shield then
                                merge_into(built_set, sets.Weapons.Shield)
                            else
                                warn('sets.Weapons.Shield not found!')
                            end
                        end
                        merge_into(built_set, sets.Weapons.Songs.Midcast)
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

        --[[ If TH mode is on - check if new mob and then equip TH gear
        if state.TreasureMode.value ~= 'None' and spell.target.type == 'MONSTER' and not th_info.tagged_mobs[spell.target.id] then
            if sets.TreasureHunter then
                merge_into(built_set, sets.TreasureHunter)
                info('[' .. spell.english .. '] Set with Treasure Hunter')
            else
                warn('sets.TreasureHunter not found!')
            end
        end
        --]]
        -- Final built_set built to return.  This is not the final set as custom Job can Augment
        return built_set
    end

    -------------------------------------------------------------------------------------------------------------------
    -- This function is called from the default GearSwap Function "midcast" to build an built_set
    -------------------------------------------------------------------------------------------------------------------

    function midcastequip(spell)
        if spell.type == 'WeaponSkill' then
            log('abort midcast')
            return
        end
        if spell.type == 'JobAbility' then
            log('abort midcast')
            return
        end
        if spell.type == 'Item' then
            log('abort midcast')
            return
        end
        if spell.type == 'Scholar' then
            log('abort midcast')
            return
        end
        if spell.type == 'Ward' then
            log('abort midcast')
            return
        end
        if spell.type == 'Rune' then
            log('abort midcast')
            return
        end
        if spell.type == 'Effusion' then
            log('abort midcast')
            return
        end
        if spell.type == 'CorsairRoll' then
            log('abort midcast')
            return
        end
        if spell.type == 'CorsairShot' then
            log('abort midcast')
            return
        end
        if spell.type == 'Waltz' then
            log('abort midcast')
            return
        end
        if spell.type == 'Jig' then
            log('abort midcast')
            return
        end
        if spell.type == 'Samba' then
            log('abort midcast')
            return
        end
        if spell.type == 'Step' then
            log('abort midcast')
            return
        end
        if spell.type == 'Flourish1' or spell.type == 'Flourish2' or spell.type == 'Flourish3' then
            log('abort midcast')
            return
        end
        if pet.isvalid and pet_midaction() then return end

        --Default gearset
        local built_set = {}
        -- Merge the Idle incase a midcast is not set
        if sets.Idle then merge_into(built_set, sets.Idle) end
        -- Merget the Midcast Set
        if sets.Midcast then
            merge_into(built_set, sets.Midcast)
            -- Spell interruption Down for the rest of the actions
            if sets.Midcast.SIRD and spell.action_type ~= 'Ranged Attack' then
                merge_into(built_set,
                    sets.Midcast.SIRD)
            end

            -- Ranged Attack
            if spell.action_type == 'Ranged Attack' then
                if sets.Midcast.RA then
                    local message = ''
                    merge_into(built_set, sets.Midcast.RA)

                    -- Augment based off Mode
                    if state.OffenseMode.value ~= 'TP' and sets.Midcast.RA[state.OffenseMode.value] then
                        merge_into(built_set, sets.Midcast.RA[state.OffenseMode.value])
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
                        merge_into(built_set, sets.Midcast.RA.AM3[state.WeaponMode.value])
                        message = message .. ' and with Aftermath 3 [' .. state.WeaponMode.value .. ']'
                    elseif buffactive['Aftermath: Lv.2'] and sets.Midcast.RA.AM2 and sets.Midcast.RA.AM2[state.WeaponMode.value] then
                        merge_into(built_set, sets.Midcast.RA.AM2[state.WeaponMode.value])
                        message = message .. ' and with Aftermath 2 [' .. state.WeaponMode.value .. ']'
                    elseif buffactive['Aftermath: Lv.1'] and sets.Midcast.RA.AM1 and sets.Midcast.RA.AM1[state.WeaponMode.value] then
                        merge_into(built_set, sets.Midcast.RA.AM1[state.WeaponMode.value])
                        message = message .. ' and with Aftermath 1 [' .. state.WeaponMode.value .. ']'
                    elseif buffactive['Aftermath'] and sets.Midcast.RA.AM and sets.Midcast.RA.AM[state.WeaponMode.value] then
                        merge_into(built_set, sets.Midcast.RA.AM[state.WeaponMode.value])
                        message = message .. ' and with Aftermath [' .. state.WeaponMode.value .. ']'
                    end

                    -- Buffs
                    if buffactive['Triple Shot'] and sets.Midcast.RA.TripleShot then
                        merge_into(built_set, sets.Midcast.RA.TripleShot)
                        message = 'Using Triple Shot Set'
                    elseif buffactive['Double Shot'] and sets.Midcast.RA.DoubleShot then
                        merge_into(built_set, sets.Midcast.RA.DoubleShot)
                        message = 'Using Double Shot Set'
                    elseif buffactive['Barrage'] and sets.Midcast.RA.Barrage then
                        merge_into(built_set, sets.Midcast.RA.Barrage)
                        message = 'Using Barrage Set'
                    end

                    -- Variable Ammo
                    if Ammo[state.OffenseMode.value] then
                        merge_into(built_set,
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
                    merge_into(built_set, sets.Midcast[spell.english])
                    info('[' .. spell.english .. '] Set')
                    -- Utsusemi Spells
                elseif UtsusemiSpell:contains(spell.name) then
                    if sets.Midcast.Utsusemi then
                        merge_into(built_set, sets.Midcast.Utsusemi)
                        info('[' .. spell.english .. '] Utsusemi Set')
                    else
                        warn('sets.Midcast.Utsusemi not found!')
                    end
                    -- Enhancing Magic
                elseif spell.target.type == 'SELF' then
                    if sets.Midcast.Enhancing then
                        merge_into(built_set, sets.Midcast.Enhancing)
                        info('Enhancing set')
                    else
                        warn('sets.Midcast.Enhancing not found!')
                    end
                    -- Enfeebling
                elseif Enfeebling_Ninjitsu:contains(spell.english) then
                    if sets.Midcast.Enfeebling then
                        merge_into(built_set, sets.Midcast.Enfeebling)
                        info('Enfeebling set')
                    else
                        warn('sets.Midcast.Enfeebling not found!')
                    end
                    -- Defaults to Nukes if not the above
                else
                    if sets.Midcast.Nuke then
                        merge_into(built_set, sets.Midcast.Nuke)
                        info('Nuke set')
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
                        merge_into(built_set, sets.Midcast.Cure)
                        info('Cure Set')
                    else
                        warn('sets.Midcast.Cure not found!')
                    end
                    -- Check if an Obi or Orpheus is to be Equiped
                    built_set = elemental_check(spell, built_set)
                    -- Curaga
                elseif spell.name:contains('Curaga') then
                    if sets.Midcast.Curaga then
                        merge_into(built_set, sets.Midcast.Curaga)
                        info('Curaga Set')
                    else
                        warn('sets.Midcast.Curaga not found!')
                    end
                    -- Check if an Obi or Orpheus is to be Equiped
                    built_set = elemental_check(spell, built_set)
                    -- Cura
                elseif spell.name:contains('Cura') then
                    if sets.Midcast.Cura then
                        merge_into(built_set, sets.Midcast.Cura)
                        info('Cura Set')
                    else
                        warn('sets.Midcast.Cura not found!')
                    end
                    -- Check if an Obi or Orpheus is to be Equiped
                    built_set = elemental_check(spell, built_set)
                    -- Defined Gear Set
                elseif sets.Midcast[spell.english] then
                    merge_into(built_set, sets.Midcast[spell.english])
                    info('[' .. spell.english .. '] Set')
                    -- Healing Magic
                elseif spell.name:contains('Raise') or spell.name == "Arise" or spell.name:contains('Reraise') then
                    log('No Swap Defined (Raise)')
                    -- Enhancing
                elseif spell.skill == 'Enhancing Magic' then
                    if sets.Midcast.Enhancing then
                        merge_into(built_set, sets.Midcast.Enhancing)
                        -- Augment the set for Others if defined
                        if spell.target.type ~= 'SELF' or (spell.target.type == 'SELF' and buffactive['Accession']) then
                            if sets.Midcast.Enhancing.Others then
                                merge_into(built_set, sets.Midcast.Enhancing.Others)
                            else
                                warn('sets.Midcast.Enhancing.Others not found!')
                            end
                        end
                        -- Refresh
                        if spell.name:contains('Refresh') then
                            if sets.Midcast.Refresh then
                                merge_into(built_set, sets.Midcast.Refresh)
                                info('Refresh Set')
                            else
                                warn('sets.Midcast.Refresh not found!')
                            end
                            -- Regen
                        elseif spell.name:contains('Regen') then
                            if sets.Midcast.Regen then
                                merge_into(built_set, sets.Midcast.Regen)
                                info('Regen Set')
                            else
                                warn('sets.Midcast.Regen not found!')
                            end
                        elseif Storms:contains(spell.name) then
                            if sets.Storms then
                                merge_into(built_set, sets.Storms)
                                info('Storms Set')
                            else
                                warn('sets.Storms not found!')
                            end
                            -- Gain Spells
                        elseif spell.name:contains('Gain') then
                            if sets.Midcast.Enhancing.Gain then
                                merge_into(built_set, sets.Midcast.Enhancing.Gain)
                                info('Gain Set')
                            else
                                warn('sets.Midcast.Enhancing.Gain not found!')
                            end
                            -- Phalanx
                        elseif spell.name:contains('Phalanx') then
                            if sets.Midcast.Phalanx then
                                merge_into(built_set, sets.Midcast.Phalanx)
                                info('Phalanx Set')
                            else
                                warn('sets.Midcast.Phalanx not found!')
                            end
                            -- Bar Spells
                        elseif Elemental_Bar:contains(spell.name) then
                            if sets.Midcast.Enhancing.Elemental then
                                merge_into(built_set, sets.Midcast.Enhancing.Elemental)
                                info('Elemental Bar Element Set')
                            else
                                warn('sets.Midcast.Enhancing.Elemental not found!')
                            end
                            -- Bar Status
                        elseif Status_Bar:contains(spell.name) then
                            if sets.Midcast.Enhancing.Status then
                                merge_into(built_set, sets.Midcast.Enhancing.Status)
                                info('Status Bar Status Set')
                            else
                                warn('sets.Midcast.Enhancing.Status not found!')
                            end
                            -- Enhancing SKill
                        elseif Enhancing_Skill:contains(spell.name) then
                            if sets.Midcast.Enhancing.Skill then
                                merge_into(built_set, sets.Midcast.Enhancing.Skill)
                                info('Enhancing Skill Set')
                            else
                                warn('sets.Midcast.Enhancing.Skill not found!')
                            end
                            -- Enhancing
                        else
                            info('Enhancing Magic Set')
                        end
                    else
                        warn('sets.Midcast.Enhancing not found!')
                    end
                    -- Divine Spells
                elseif Divine_Skill:contains(spell.name) then
                    if sets.Midcast.Divine then
                        merge_into(built_set, sets.Midcast.Divine)
                        info('Divine Skill Set')
                    else
                        warn('sets.Midcast.Divine not found!')
                    end
                    -- Enfeebling Magic
                elseif spell.skill == 'Enfeebling Magic' then
                    if sets.Midcast.Enfeebling then
                        merge_into(built_set, sets.Midcast.Enfeebling)
                        -- Accuracy
                        if Enfeeble_Acc:contains(spell.name) then
                            if sets.Midcast.Enfeebling.MACC then
                                merge_into(built_set, sets.Midcast.Enfeebling.MACC)
                                info('Enfeebling Magic Set - Magic Accuracy')
                            else
                                warn('sets.Midcast.Enfeebling.MACC not found!')
                            end
                            -- Potency
                        elseif Enfeeble_Potency:contains(spell.name) then
                            if sets.Midcast.Enfeebling.Potency then
                                merge_into(built_set, sets.Midcast.Enfeebling.Potency)
                                info('Enfeebling Magic Set - Potency')
                            else
                                warn('sets.Midcast.Enfeebling.Potency not found!')
                            end
                            -- Duration
                        elseif Enfeeble_Duration:contains(spell.name) then
                            if sets.Midcast.Enfeebling.Duration then
                                merge_into(built_set, sets.Midcast.Enfeebling.Duration)
                                info('Enfeebling Magic Set - Duration')
                            else
                                warn('sets.Midcast.Enfeebling.Duration not found!')
                            end
                            -- Default
                        else
                            info('Enfeebling Magic Set')
                        end
                    else
                        info('No sets.Midcast.Enfeebling defined!')
                    end
                end
                -- Black Magic
            elseif spell.type == 'BlackMagic' then
                -- Defined Gear Set
                if sets.Midcast[spell.english] then
                    merge_into(built_set, sets.Midcast[spell.english])
                    -- Check for an elemental set
                    if spell.skill == 'Elemental Magic' and not spell.name:contains('helix') then
                        built_set =
                            elemental_check(spell, built_set)
                    end
                    info('[' .. spell.english .. '] Set')
                    -- Aspir Gear
                elseif spell.name:contains('Aspir') then
                    if sets.Midcast.Aspir then
                        merge_into(built_set, sets.Midcast.Aspir)
                        info('Aspir Set')
                    else
                        warn('sets.Midcast.Aspir not found!')
                    end
                    -- Drain Gear
                elseif spell.name:contains('Drain') then
                    if sets.Midcast.Drain then
                        merge_into(built_set, sets.Midcast.Drain)
                        info('Drain Set')
                    else
                        warn('sets.Midcast.Drain not found!')
                    end
                    -- Enfeebling Magic
                elseif spell.skill == 'Enfeebling Magic' then
                    if sets.Midcast.Enfeebling then
                        merge_into(built_set, sets.Midcast.Enfeebling)
                        -- Accuracy
                        if Enfeeble_Acc:contains(spell.name) then
                            if sets.Midcast.Enfeebling.MACC then
                                merge_into(built_set, sets.Midcast.Enfeebling.MACC)
                                info('Enfeebling Magic Set - Magic Accuracy')
                            else
                                warn('sets.Midcast.Enfeebling.MACC not found!')
                            end
                            -- Potency
                        elseif Enfeeble_Potency:contains(spell.name) then
                            if sets.Midcast.Enfeebling.Potency then
                                merge_into(built_set, sets.Midcast.Enfeebling.Potency)
                                info('Enfeebling Magic Set - Potency')
                            else
                                warn('sets.Midcast.Enfeebling.Potency not found!')
                            end
                            -- Duration
                        elseif Enfeeble_Duration:contains(spell.name) then
                            if sets.Midcast.Enfeebling.Duration then
                                merge_into(built_set, sets.Midcast.Enfeebling.Duration)
                                info('Enfeebling Magic Set - Duration')
                            else
                                warn('sets.Midcast.Enfeebling.Duration not found!')
                            end
                            -- Default
                        else
                            info('Enfeebling Magic Set')
                        end
                    else
                        info('No sets.Midcast.Enfeebling not found!')
                    end
                    -- Dark Magic
                elseif spell.skill == 'Dark Magic' then
                    if sets.Midcast.Dark then
                        merge_into(built_set, sets.Midcast.Dark)
                        -- Accuracy
                        if Dark_Acc:contains(spell.name) then
                            if sets.Midcast.Dark.MACC then
                                merge_into(built_set, sets.Midcast.Dark.MACC)
                                info('Dark Magic Set - Magic Accuracy')
                            else
                                warn('sets.Midcast.Dark.MACC not found!')
                            end
                            -- Absorb
                        elseif Dark_Absorb:contains(spell.name) then
                            if sets.Midcast.Dark.Absorb then
                                merge_into(built_set, sets.Midcast.Dark.Absorb)
                                info('Absorb Magic Set - Potency')
                            else
                                warn('sets.Midcast.Dark.Absorb not found!')
                            end
                            -- Enhancing
                        elseif Dark_Enhancing:contains(spell.name) then
                            if sets.Midcast.Dark.Enhancing then
                                merge_into(built_set, sets.Midcast.Dark.Enhancing)
                                info('Dark Enhancing Magic Set - Duration')
                            else
                                warn('sets.Midcast.Dark.Enhancing not found!')
                            end
                            -- Potency
                        elseif Enfeeble_Potency:contains(spell.name) then
                            if sets.Midcast.Enfeebling.Potency then
                                merge_into(built_set, sets.Midcast.Enfeebling.Potency)
                                info('Enfeebling Magic Set - Potency')
                            else
                                warn('sets.Midcast.Enfeebling.Potency not found!')
                            end
                            -- Duration
                        elseif Enfeeble_Duration:contains(spell.name) then
                            if sets.Midcast.Enfeebling.Duration then
                                merge_into(built_set, sets.Midcast.Enfeebling.Duration)
                                info('Enfeebling Magic Set - Duration')
                            else
                                warn('sets.Midcast.Enfeebling.Duration not found!')
                            end
                            -- Default
                        else
                            info('Dark Magic Set')
                        end
                    else
                        info('No sets.Midcast.Dark not found!')
                    end
                    -- Enhancing Magic
                elseif spell.skill == 'Enhancing Magic' then
                    if sets.Midcast.Enhancing then
                        merge_into(built_set, sets.Midcast.Enhancing)
                        info('Enhancing Magic Set')
                    else
                        warn('sets.Midcast.Enhancing not found!')
                    end
                    -- Enfeebling Elemental Magic
                elseif Elemental_Enfeeble:contains(spell.name) then
                    if sets.Midcast.Enfeebling then
                        merge_into(built_set, sets.Midcast.Enfeebling)
                        if sets.Midcast.Enfeebling.MACC then
                            merge_into(built_set, sets.Midcast.Enfeebling.MACC)
                            info('Enfeebling Magic Set - Magic Accuracy')
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
                            merge_into(built_set, sets.Midcast.Burst)
                        else
                            warn('sets.Midcast.Burst not found!')
                        end
                    else
                        if sets.Midcast.Nuke then
                            merge_into(built_set, sets.Midcast.Nuke)
                            info('Nuke Set')
                        else
                            warn('sets.Midcast.Nuke not found!')
                        end
                    end
                    -- Check for Helix
                    if spell.name:contains('helix') then
                        if sets.Helix then
                            merge_into(built_set, sets.Helix)
                            if spell.element == 'Dark' then
                                if sets.Helix.Dark then
                                    merge_into(built_set, sets.Helix.Dark)
                                else
                                    warn('sets.Helix.Dark not found!')
                                end
                            elseif spell.element == 'Light' then
                                if sets.Helix.Light then
                                    merge_into(built_set, sets.Helix.Light)
                                else
                                    warn('sets.Helix.Light not found!')
                                end
                            end
                        else
                            warn('sets.Helix not found!')
                        end
                    else
                        if spell.element == "Earth" and sets.Midcast.Nuke.Earth then
                            merge_into(built_set, sets.Midcast.Nuke.Earth)
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
                        merge_into(built_set, sets.Midcast.DummySongs)
                        info('[' .. spell.english .. '] Set (Song Count)')
                    else
                        warn('sets.Midcast.DummySongs not found!')
                    end
                    merge_into(built_set, { range = Instrument.Count })
                    -- Potency / Instruments
                else
                    -- Defined Gear Set
                    if sets.Midcast[spell.english] then
                        merge_into(built_set, sets.Midcast[spell.english])
                        info('[' .. spell.english .. '] Set')
                        -- Equip Harp
                    elseif spell.name:contains('Horde') then
                        if sets.Midcast.Enfeebling then
                            merge_into(built_set, sets.Midcast.Enfeebling)
                        else
                            warn('sets.Midcast.Enfeebling not found!')
                        end
                        merge_into(built_set, { range = Instrument.AOE_Sleep })
                        info('[' .. spell.english .. '] Set (AOE Sleep)')
                        -- Normal Enfeebles
                    elseif Enfeebling_Song:contains(spell.english) then
                        if sets.Midcast.Enfeebling then
                            merge_into(built_set, sets.Midcast.Enfeebling)
                        else
                            warn('sets.Midcast.Enfeebling not found!')
                        end
                        merge_into(built_set, { range = Instrument.Enfeebling })
                        info('[' .. spell.english .. '] Set (Enfeebling)')
                        -- Augment the buff songs
                    else
                        info('[' .. spell.english .. '] Set (Potency)')
                        merge_into(built_set, { range = Instrument.Potency })
                    end
                    -- Augment the specific Song if set
                    merge_into(built_set, equip_song_gear(spell, built_set['range']))
                end
                -- BlueMagic
            elseif spell.type == 'BlueMagic' then
                -- Defined Set
                if sets.Midcast[spell.english] then
                    merge_into(built_set, sets.Midcast[spell.english])
                    -- Check for an elemental set
                    if BlueNuke:contains(spell.english) then built_set = elemental_check(spell, built_set) end
                    info('[' .. spell.english .. '] Set')
                else
                    if sets.Midcast.BlueMagic then
                        -- Physical blue magic: damage comes from mainhand weapon
                        -- accuracy, DEX/Accuracy and physical Attack.  Deliberately skips
                        -- elemental_check -- obi and Orpheus scale magic damage only.
                        if BluePhysical:contains(spell.english) then
                            if sets.Midcast.BlueMagic.Physical then
                                merge_into(built_set, sets.Midcast.BlueMagic.Physical)
                                info('Blue Physical set')
                            else
                                warn('sets.Midcast.BlueMagic.Physical not found!')
                            end
                            -- Breath damage scales off the caster's HP and level only.
                            -- MAB, INT and Blue Magic Skill contribute nothing, so this
                            -- also skips elemental_check.
                        elseif BlueBreath:contains(spell.english) then
                            if sets.Midcast.BlueMagic.Breath then
                                merge_into(built_set, sets.Midcast.BlueMagic.Breath)
                                info('Blue Breath set')
                            else
                                warn('sets.Midcast.BlueMagic.Breath not found!')
                            end
                            -- Defined Blue Nukes
                        elseif BlueNuke:contains(spell.english) then
                            if sets.Midcast.BlueMagic.Nuke then
                                merge_into(built_set, sets.Midcast.BlueMagic.Nuke)
                                info('Blue Nuke set')
                            else
                                warn('sets.Midcast.BlueMagic.Nuke not found!')
                            end
                            built_set = elemental_check(spell, built_set)
                            -- Spells that benifit from Blue Magic Skill
                        elseif BlueSkill:contains(spell.english) then
                            if sets.Midcast.BlueMagic.Skill then
                                merge_into(built_set, sets.Midcast.BlueMagic.Skill)
                                info('Blue Skill set')
                            else
                                warn('sets.Midcast.BlueMagic.Skill not found!')
                            end
                            -- Fixed-potency buffs: only duration is influenced by gear,
                            -- so these must not borrow the skill set.
                        elseif BlueBuff:contains(spell.english) then
                            if sets.Midcast.BlueMagic.Buff then
                                merge_into(built_set, sets.Midcast.BlueMagic.Buff)
                                info('Blue Buff set')
                            else
                                warn('sets.Midcast.BlueMagic.Buff not found!')
                            end
                        elseif BlueTank:contains(spell.english) then
                            if sets.Midcast.BlueMagic.Enmity then
                                merge_into(built_set, sets.Midcast.BlueMagic.Enmity)
                                info('Blue Enmity set')
                            else
                                warn('sets.Midcast.BlueMagic.Enmity not found!')
                            end
                        elseif BlueHealing:contains(spell.english) then
                            if sets.Midcast.BlueMagic.Healing then
                                merge_into(built_set, sets.Midcast.BlueMagic.Healing)
                                info('Blue Cure set')
                            else
                                warn('sets.Midcast.BlueMagic.Healing not found!')
                            end
                        elseif BlueACC:contains(spell.english) then
                            if sets.Midcast.BlueMagic.ACC then
                                merge_into(built_set, sets.Midcast.BlueMagic.ACC)
                                info('Blue Magic Accuracy set')
                            else
                                warn('sets.Midcast.BlueMagic.ACC not found!')
                            end
                            -- Default Spell set
                        else
                            info('Midcast not set')
                        end
                        if buffactive["Diffusion"] then
                            if sets.Diffusion then
                                merge_into(built_set, sets.Diffusion)
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
                        merge_into(built_set, sets.Geomancy[spell.english])
                        info('[' .. spell.english .. '] Set')
                        -- Indi Equipment
                    elseif Indicolure_List:contains(spell.english) then
                        if sets.Geomancy.Indi then
                            merge_into(built_set, sets.Geomancy.Indi)
                            if spell.target.type ~= "SELF" then
                                if sets.Geomancy.Indi.Entrust then
                                    merge_into(built_set, sets.Geomancy.Indi.Entrust)
                                    info('Indicolure set - Entrust')
                                else
                                    warn('sets.Geomancy.Indi.Entrust not found!')
                                end
                            else
                                info('Indicolure set')
                            end
                        else
                            warn('sets.Geomancy.Indi not found!')
                        end
                        -- Bubble Equipment
                    elseif Geomancy_List:contains(spell.english) then
                        if sets.Geomancy.Geo then
                            merge_into(built_set, sets.Geomancy.Geo)
                            info('Geomancy set')
                        else
                            warn('sets.Geomancy.Geo not found!')
                        end
                        -- Default set
                    else
                        info('Midcast not set')
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
                        merge_into(built_set, sets.Midcast[spell.english])
                        info('[' .. spell.english .. '] Set')
                    elseif sets.Midcast.BP then
                        merge_into(built_set, sets.Midcast.BP)
                        info('Blood Pact Set')
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
                    merge_into(built_set, sets.Ready)
                    info('[Ready] Set')
                else
                    warn('sets.Ready not found!')
                end
                -- Elemental Siphon
            elseif spell.name == "Elemental Siphon" then
                if sets.Midcast[spell.english] then
                    merge_into(built_set, sets.Midcast[spell.english])
                    info('[' .. spell.english .. '] Set')
                else
                    if sets.Midcast.SummoningMagic then
                        merge_into(built_set, sets.Midcast.SummoningMagic)
                        info('Summoning Magic Set')
                    else
                        warn('sets.Midcast.SummoningMagic not found!')
                    end
                end
                -- Summon Avatar
            elseif spell.type == "SummonerPact" then
                if sets.Midcast[spell.english] then
                    merge_into(built_set, sets.Midcast[spell.english])
                    info('[' .. spell.english .. '] Set')
                else
                    if sets.Midcast.Summon then
                        merge_into(built_set, sets.Midcast.Summon)
                        info('Summon Magic Set')
                    else
                        warn('sets.Midcast.Summon not found!')
                    end
                end
            end
        else
            warn('sets.Midcast not found!')
        end
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
                merge_into(built_set,
                    { main = player.equipment.main, sub = player.equipment.sub, range = player.equipment.range })
                log(built_set)
            else
                if sets.Weapons then
                    if sets.Weapons[state.WeaponMode.value] then
                        merge_into(built_set, sets.Weapons[state.WeaponMode.value])
                    else
                        warn('sets.Weapons.' .. state.WeaponMode.value .. ' not found!')
                    end
                    if not TwoHand and not DualWield then
                        if sets.Weapons.Shield then
                            merge_into(built_set, sets.Weapons.Shield)
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
                merge_into(built_set, sets.Weapons.Songs)
                if sets.Weapons.Songs.Midcast then
                    merge_into(built_set, sets.Weapons.Songs.Midcast)
                    if not DualWield and not TwoHand then
                        if sets.Weapons.Shield then
                            merge_into(built_set, sets.Weapons.Shield)
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
                        merge_into(built_set, { range = equip_pianissimo_gear(spell) })
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
            merge_into(built_set, sets.TreasureHunter)
            info('[' .. spell.english .. '] Set with Treasure Hunter')
        end
        -- Built built_set to return
        return built_set
    end

    -------------------------------------------------------------------------------------------------------------------
    -- This function is called from the default GearSwap Function "aftercast" to build an built_set
    -------------------------------------------------------------------------------------------------------------------

    function aftercastequip(spell)
        -- Dont change gear as the pet is still performing an action
        if pet_midaction() then
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

    -------------------------------------------------------------------------------------------------------------------
    -- This function is called by gearswap for pretarget checks
    -------------------------------------------------------------------------------------------------------------------

    function pretarget(spell, action)
        --Calls the function in the include file for basic checks
        pretargetcheck(spell, action)
        --Calls the job specific function
        if pretarget_custom then pretarget_custom(spell, action) end
    end

    -------------------------------------------------------------------------------------------------------------------
    -- This function is called by gearswap for precast checks
    -------------------------------------------------------------------------------------------------------------------

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
        -- Hoxne critical window.  Derived here rather than handed over from
        -- pretarget: precast only runs for actions that survived every
        -- cancel_spell() guard in pretargetcheck AND pretarget_custom, so a
        -- cancelled action can never leave a slot unlocked, and two actions in
        -- flight cannot clobber each other's intent.  Only the ONE slot the
        -- action needs is released.  The forced item is applied before
        -- precastequip(), so a job file's own sets.JA['Angon'] still wins.
        if state.Hoxne.value == 'ON-Allow Critical' then
            local crit = critical_action_for(spell)
            if crit then
                hoxne.window  = true
                hoxne.slot    = crit.slot
                hoxne.resume  = crit.resume
                hoxne.expires = os.clock() + 20 -- watchdog only; aftercast sets the real countdown
                enable(crit.slot)
                if crit.force then equip({ [crit.slot] = crit.force }) end
                log('Hoxne: critical window open for ', spell.english, ' (', crit.slot, ')')
            end
        end

        --Generate the correct set from the include file and custom function
        local built_set = precastequip(spell)
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

    -------------------------------------------------------------------------------------------------------------------
    -- This function is called by gearswap for midcast checks
    -------------------------------------------------------------------------------------------------------------------

    function midcast(spell)
        --Generate the correct set from the include file and custom function
        local built_set = midcastequip(spell)
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

    -------------------------------------------------------------------------------------------------------------------
    -- This function is called by gearswap for aftercast checks
    -------------------------------------------------------------------------------------------------------------------

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

        -- Close the Hoxne critical window.  Job abilities resume immediately
        -- whether they landed or failed; songs and Geomancy get a 5 second
        -- debounce that each new cast refreshes, so a wave of songs or an
        -- Indi/Geo pair is one continuous window.  Only the critical action
        -- itself moves the countdown - an unrelated JA landing inside the
        -- window must not extend it indefinitely.
        local crit = hoxne.window and critical_action_for(spell) or nil
        if crit then
            hoxne.expires = os.clock() +
                ((crit.resume == 'delay') and (crit.delay or 5) or 0.5)
        end
    end

    -------------------------------------------------------------------------------------------------------------------
    -- This function is called by gearswap for any buff changes
    -------------------------------------------------------------------------------------------------------------------

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

    -------------------------------------------------------------------------------------------------------------------
    -- This function is called by gearswap for any player status changes
    -------------------------------------------------------------------------------------------------------------------

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

    -------------------------------------------------------------------------------------------------------------------
    -- This function is called by gearswap for any pet changes
    -------------------------------------------------------------------------------------------------------------------

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

    -------------------------------------------------------------------------------------------------------------------
    -- This function is called by gearswap for pet mid actions
    -------------------------------------------------------------------------------------------------------------------

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

    -------------------------------------------------------------------------------------------------------------------
    -- This function is called by gearswap for pet after actions
    -------------------------------------------------------------------------------------------------------------------

    function pet_aftercast(spell)
        local built_set = choose_set()
        if pet_aftercast_custom then
            built_set = set_combine(built_set, pet_aftercast_custom(spell))
        end
        equip(built_set)
    end

    -------------------------------------------------------------------------------------------------------------------
    -- This function is called to determine if there are current buffs to be used
    -------------------------------------------------------------------------------------------------------------------

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

    -------------------------------------------------------------------------------------------------------------------
    -- Determine whether we have sufficient ammo for the action being attempted.
    -------------------------------------------------------------------------------------------------------------------

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
                    add_to_chat(104,
                        'No Quick Draw ammo left.  Using what\'s currently equipped (' .. player.equipment.ammo .. ').')
                    return
                elseif spell.type == 'WeaponSkill' and player.equipment.ammo == Ammo.Bullet.RA then
                    add_to_chat(104,
                        'No weaponskill ammo left.  Using what\'s currently equipped (standard ranged bullets: ' ..
                        player.equipment.ammo .. ').')
                    return
                else
                    add_to_chat(104, 'No ammo (' .. tostring(bullet_name) .. ') available for that action.')
                    cancel_spell()
                    return
                end
            end

            -- Don't allow shooting or weaponskilling with ammo reserved for quick draw.
            if spell.type ~= 'CorsairShot' and available_bullets <= bullet_min_count then
                add_to_chat(104, 'Not enough ammo.  Cancelling.')
                cancel_spell()
                return
            end

            -- Low ammo warning.
            if spell.type ~= 'CorsairShot' and state.warned.value == false and available_bullets > 1 and available_bullets <= Ammo_Warning_Limit then
                local msg = '*****  LOW AMMO WARNING: ' .. tostring(available_bullets) .. 'x ' .. bullet_name .. ' *****'
                local border = ""
                for i = 2, #msg do border = border .. "*" end
                windower.send_command('send @others input /echo ' .. msg .. '')
                add_to_chat(167, border)
                add_to_chat(167, msg)
                add_to_chat(167, border)
                state.warned:set()
            elseif available_bullets > Ammo_Warning_Limit and state.warned then
                state.warned:reset()
            end
        end
    end

    -------------------------------------------------------------------------------------------------------------------
    -- Determine whether we have sufficient Shihei for the action being attempted.
    -------------------------------------------------------------------------------------------------------------------

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
                add_to_chat(167, border)
                add_to_chat(167, msg)
                add_to_chat(167, border)
            end
        end
    end

    -------------------------------------------------------------------------------------------------------------------
    -- This function returns the correct equipement to perform an action
    -------------------------------------------------------------------------------------------------------------------

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

    --Helper function for checking if player has an item available to equip.
    --Bag ids per res/bags.lua:
    --0 = Inventory, 8 = Wardrobe, 10-15 = Wardrobes 2-7, 16 = Wardrobe 8.
    local ITEM_SEARCH_BAGS = { 0, 8, 10, 11, 12, 13, 14, 15, 16 }
    local function has_item(item_id)
        for _, bag_id in ipairs(ITEM_SEARCH_BAGS) do
            local bag = windower.ffxi.get_items(bag_id)
            if bag then
                for _, item in ipairs(bag) do
                    if type(item) == 'table' and item.id == item_id then
                        return true
                    end
                end
            end
        end
        return false
    end

    --Command helper functions to validate user-typed arguments are acceptable options for each 'gs c xxxx arg'
    local function command_arg(cmd)
        local arg = cmd:match('^%s*%S+%s+(.-)%s*$')
        if not arg or arg == '' then return nil end
        return arg
    end

    local function mode_options(m)
        local opts = T {}
        if type(m) == 'table' and m._track and m._track._type == 'list' then
            for _, v in ipairs(m) do opts:insert(tostring(v)) end
        end
        return opts
    end

    -- Returns the canonical option on an exact match, otherwise nil plus the
    -- closest option as a suggestion only. Partial and legacy values are never
    -- silently accepted.
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
    -------------------------------------------------------------------------------------------------------------------
    -- This function is called by the user via the self command - "gs c XXXX"
    -------------------------------------------------------------------------------------------------------------------

    function self_command(cmd)
        local command = cmd:lower():trim()
        if command == 'update auto' then
            local built_set = choose_set()
            if choose_set_custom then
                built_set = set_combine(built_set, choose_set_custom())
            else
                warn('choose_set_custom() not found!')
            end
            -- Order the gear and then equip
            equip(built_set)
            return
        elseif command == 'zero' then
            display_zero_command()
        elseif command == 'displaymode' then
            settings.oneline = not settings.oneline
            info('One line display is: [' .. (settings.oneline and "ON" or "OFF") .. ']')
            display_box_update()
            config.save(settings)
            add_to_chat(80, "Settings saved")
            -- Toggles the TH state
        elseif command:contains('treasurehunter') then
            if command == "treasurehunter" then
                state.TreasureMode:cycle()
                info('Treasure Hunter Mode: [' .. state.TreasureMode.value .. ']')
                display_box_update()
            elseif set_mode_arg(state.TreasureMode, 'Treasure Hunter', 'TreasureHunter', command_arg(cmd)) then
                info('Treasure Hunter Mode: [' .. state.TreasureMode.value .. ']')
                display_box_update()
            else
                return
            end
            equip_set_command()
            return
        elseif command:contains('spellreceived') then
            if command == "spellreceived" then
                state.SpellReceived:cycle()
                info('Spell Received Mode: [' .. state.SpellReceived.value .. ']')
                display_box_update()
            elseif set_mode_arg(state.SpellReceived, 'Spell Received', 'SpellReceived', command_arg(cmd)) then
                info('Spell Received Mode: [' .. state.SpellReceived.value .. ']')
                display_box_update()
            else
                return
            end
            equip_set_command()
            return
        elseif command:contains('hoxne') then
            if command == "hoxne" then
                state.Hoxne:cycle()
                info('Hoxne Ampulla Mode: [' .. state.Hoxne.value .. ']')
                display_box_update()
            elseif set_mode_arg(state.Hoxne, 'Hoxne Ampulla', 'Hoxne', command_arg(cmd)) then
                info('Hoxne Ampulla Mode: [' .. state.Hoxne.value .. ']')
                display_box_update()
            else
                return
            end
            if state.Hoxne.value ~= 'OFF' then
                local _, _, carried = find_enchantment('Hoxne Ampulla')
                if carried then
                    hoxne.window   = false
                    hoxne.slot     = nil
                    hoxne.resume   = nil
                    hoxne.recheck_at = 0
                    hoxne_equip_ampulla()
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
                hoxne.window   = false
                hoxne.slot     = nil
                hoxne.resume   = nil
                hoxne.recheck_at = 0
                enable('range', 'ammo')
                info('Hoxne mode disabled.  Range and ammo unlocked.')
            end
            equip_set_command()
            return
            -- Toggles the Auto Buff function off/on
        elseif command:contains('autobuff') then
            if command == 'autobuff' then
                state.AutoBuff:cycle()
                info('Auto Buff is [' .. state.AutoBuff.value .. ']')
            elseif set_mode_arg(state.AutoBuff, 'Auto Buff', 'AutoBuff', command_arg(cmd)) then
                info('Auto Buff is [' .. state.AutoBuff.value .. ']')
            else
                return
            end
            display_box_update()
            equip_set_command()
            return
            -- Shuts down instnace
        elseif command == 'shutdown' then
            send_command('terminate')
            -- Saves the location of HUD
        elseif command == 'save' then
            if windower.ffxi.get_info().logged_in then
                config.save(settings)
                add_to_chat(80, 'Settings saved')
            else
                add_to_chat(80, 'Cannot save while zoning - try again in a moment.')
            end
            -- Toggles dispay of the HUD
        elseif command == 'display' then
            if settings.visible == true then
                settings.visible = false
                gs_status:hide()
                gs_status:draggable(false)
                add_to_chat(80, 'The UI is now hidden')
            else
                settings.visible = true
                gs_status:draggable(true)
                gs_status:show()
                display_box_update()
                add_to_chat(80, 'The UI is now shown')
            end
        elseif command == 'debug' then
            if settings.debug == true then
                settings.debug = false
                gs_debug:hide()
                gs_debug:draggable(false)
                windower.add_to_chat(80, 'The debugging is now [OFF]')
            else
                settings.debug = true
                gs_debug:draggable(true)
                gs_debug:show()
                debug_box_reset()
                debug_box_update()
                log('The debugging is now [ON]')
            end
        elseif command == 'warn' then
            if settings.warn == true then
                settings.warn = false
                windower.add_to_chat(8, 'The set warning is now [OFF]')
            else
                settings.warn = true
                warn('The set warning is now [ON]')
            end
        elseif command == 'info' then
            if settings.info == true then
                settings.info = false
                windower.add_to_chat(8, 'Information is now [OFF]')
            else
                settings.info = true
                info('Information is now [ON]')
            end
        elseif command == 'two_hand_check' then
            two_hand_check()
            -- Esha Temps
        elseif command == 'temps' then
            escha_temps()
            -- Warp Ring
        elseif command == 'warp' then
            use_enchantment("Warp Ring")
            -- Warp Club
        elseif command == 'warp club' then
            use_enchantment("Warp Cudgel")
            -- Holla Teleport
        elseif command == 'holla' then
            use_enchantment("Dim. Ring (Holla)")
            -- Dem Teleport
        elseif command == 'dem' then
            use_enchantment("Dim. Ring (Dem)")
            -- Mea Teleport
        elseif command == 'mea' then
            use_enchantment("Dim. Ring (Mea)")
            -- CP Ring
        elseif command == 'cp' then
            use_enchantment("Trizek Ring")
            -- Toggles the current player stances
        elseif command:contains('offensemode') then
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
                        return
                    end
                end
            elseif set_mode_arg(state.OffenseMode, 'Offense Mode', 'OffenseMode', command_arg(cmd)) then
                info('Offense Mode: [' .. state.OffenseMode.value .. ']')
                display_box_update()
                equip_set_command()
                return
            else
                return
            end
        elseif command:contains('weaponmode') then
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
                        return
                    end
                end
            elseif set_mode_arg(state.WeaponMode, 'Weapon Mode', 'WeaponMode', command_arg(cmd)) then
                info('Weapon Mode: [' .. state.WeaponMode.value .. ']')
                display_box_update()
                if self_command_custom then self_command_custom(command) end
                two_hand_check()
                equip_set_command()
                return
            else
                return
            end
        elseif command:contains('jobmode2') then
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
                        return
                    end
                end
            elseif set_mode_arg(state.JobMode2, UI_Name2 ~= '' and UI_Name2 or 'Job Mode 2', 'JobMode2', command_arg(cmd)) then
                info(UI_Name2 .. ': [' .. state.JobMode2.value .. ']')
                display_box_update()
                if self_command_custom then self_command_custom(command) end
                equip_set_command()
                return
            else
                return
            end
        elseif command:contains('jobmode') then
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
                        return
                    end
                end
            elseif set_mode_arg(state.JobMode, UI_Name ~= '' and UI_Name or 'Job Mode', 'JobMode', command_arg(cmd)) then
                info(UI_Name .. ': [' .. state.JobMode.value .. ']')
                display_box_update()
                -- Issue a command to the lua for the job specific command
                if self_command_custom then self_command_custom(command) end
                equip_set_command()
                return
            else
                return
            end
            -- This profile mode is used to load a Silmaril profile and execute a script
        elseif command:contains('profile') then
            local modes = {}
            for mode in string.gmatch(cmd, "(%w+)") do
                table.insert(modes, mode)
            end
            local smModePath = table.concat(modes, '_', 2, #modes)
            info('Profile: [' .. modes[#modes] .. ']')
            windower.send_command('exec ' .. smModePath .. '/' .. player.main_job ..
                '_' .. player.sub_job .. '_' .. player.name)
        elseif command == 'food' then
            windower.chat.input('/item "' .. Food .. '" <me>')
            -- Command to use any enchanted item, can use either en or enl names from resources, autodetects slot, equip timeout and cast time
        elseif command:startswith('use') then
            use_enchantment(command:slice(5))
        elseif command == 'version' then
            info('Include Version is [' .. Mirdain_GS .. ']')

            -------Custom Commands for Proccing and 1Dmg Weapons-------
        elseif command == 'naked' then
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
            --Perform instant unequip that will be immediately undone through equip_set_command on the next action or timing
            --Use for cure cheating, sortie objective, etc
        elseif command == 'nakedunlocked' then
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
            --Disable all slots but weapons, range and ammo
        elseif command == 'weaponsonly' then
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
            --Mode to disable main equipment slots for abyssea red proccing
        elseif command == 'abysseaproc' then
            equip({
                head = empty,
                --body = empty,
                hands = empty,
                legs = empty,
                feet = empty,
            })
            --disable('head', 'neck', 'ear1', 'ear2', 'body', 'hands', 'ring1', 'ring2', 'back', 'waist', 'legs', 'feet')
            disable('head', 'hands', 'legs', 'feet')
            --Enable All Slots
        elseif command == 'enableall' then
            Unlock()
            --Enable slots that aren't locked by the current mode or zone
        elseif command == 'enablebymode' then
            UnlockByMode()
        end

        --use below for custom Job commands
        if self_command_custom then self_command_custom(command) end
    end

    -- Functin used to exectue Job Abilities
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

    -- Functin used to exectue Spells
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

    -- Used for Escha Temp and Zerg
    function escha_temps()
        info('Escha Temps')
        windower.send_command(
            "input /item \"Monarch's Drink\" <me>;wait 2.5;input /item \"Braver's Drink\" <me>;wait 2.5;input /item \"Fighter's Drink\" <me>;wait 2.5;input /item \"Champion's Drink\" <me>;wait 2.5;input /item \"Soldier's Drink\" <me>;wait 2.5;input /item \"Barbarian's Drink\" <me>")
    end

    -- Determines correct gear for the songs
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

    -- Determines correct instrument for Pianissimo
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

    -- Unbind Keys when the file is unloaded
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

        ench_active    = nil
        hoxne.window   = false
        hoxne.slot     = nil
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

    -- Command to Lock Style and Set the correct macros
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

    -- Called when the player's subjob changes.
    function sub_job_change(new, old)
        invalidate_layout()
        coroutine.schedule(dual_wield_check, 2)
        coroutine.schedule(two_hand_check, 2.1)
        coroutine.schedule(equip_set_command, 2.2)
        if sub_job_change_custom then
            sub_job_change_custom()
        end
    end

    -- Check if you have the dual wield trait
    function dual_wield_check()
        local current_abilities = windower.ffxi.get_abilities()
        if table.contains(current_abilities.job_traits, 18) then -- Dual Wield trait
            DualWield = true
        else
            DualWield = false
        end
    end

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

    -- On changing targets, attempt to add TH gear.
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

    -- This function removes mobs from our tracking table when they die.
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
                        add_to_chat(123, 'Mob ' ..
                            target_id .. ' died. Removing from tagged mobs table.')
                    end
                    th_info.tagged_mobs[target_id] = nil
                end
            end
        end
    end

    -- Clear out the entire tagged mobs table when zoning.
    function on_zone_change_for_th(new_zone, old_zone)
        UnlockByMode()
        if settings.debug then windower.add_to_chat(123, 'Zoning. Clearing tagged mobs table.') end
        th_info.tagged_mobs:clear()
        -- Turn off for zones
        state.AutoBuff:set('OFF')
    end

    -- Remove mobs that we've marked as tagged with TH if we haven't seen any activity from or on them
    -- for over 3 minutes.  This is to handle deagros, player deaths, or other random stuff where the
    -- mob is lost, but doesn't die.
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

    -------------------------------------------------------------------------------------------------------------------
    -- BELOW IS FROM THE CANCEL ADDON
    -- ADDING DUE TO FACT SOME PEOPLE MAY NOT HAVE IT INSTALLED
    -- ALLOWS CANCELING OF BUFFS EASIER
    -------------------------------------------------------------------------------------------------------------------

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

    function cancel_buff(id)
        windower.packets.inject_outgoing(0xF1, string.char(0xF1, 0x04, 0, 0, id % 256, math.floor(id / 256), 0, 0)) -- Inject the cancel packet
    end

    function Unlock()
        log('Unlock Called')
        enable('main', 'sub', 'range', 'ammo', 'head', 'neck', 'ear1', 'ear2', 'body', 'hands', 'ring1', 'ring2', 'waist',
            'legs', 'feet', 'back')
    end

    -- UnlockByMode() fires on zone change, Doom/Sleep wearing off, and every item
    -- completion, so it must not release a slot Hoxne is holding.  Unlock() above
    -- is deliberately left alone: its only caller is 'gs c enableall', the manual
    -- recovery escape hatch, and hoxne_tick re-asserts the lock within a second.
    local function enable_except_held(slots)
        local list = {}
        for _, s in ipairs(slots) do
            if not hoxne_owns_slot(s) then list[#list + 1] = s end
        end
        if #list > 0 then enable(unpack(list)) end
    end

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

    function Lock()
        log('Lock Called')
        disable('main', 'sub', 'range', 'ammo', 'head', 'neck', 'ear1', 'ear2', 'body', 'hands', 'ring1', 'ring2',
            'waist',
            'legs', 'feet', 'back')
    end

    -- UI for displaying the current states
    local GLYPH = {
        on    = string.char(0xE2, 0x97, 0x8F), -- U+25CF Black Circle
        off   = string.char(0xE2, 0x97, 0x8F), -- U+25CB White Circle
        prev  = string.char(0xE2, 0x97, 0x84), -- U+25C4 Black left-pointing arrow
        next  = string.char(0xE2, 0x96, 0xBA), -- U+25BA Black right-pointing arrow
        trunc = string.char(0xE2, 0x80, 0xA6), -- U+2026 Elipsis
    }

    local COLOR = {
        label = '150,150,150',
        value = '235,235,235',
        chev = '110,110,110',
        idle = '120,120,120',  -- Hollow "off" circle
        good = '80,220,110',   -- Fully on - green
        warn = '255,170,60',   -- Partially on - amber for TH tag
        cyan = '90,200,255',   -- TH SATA mode
    }

    local function cs(color, s) return '\\cs(' .. color .. ')' .. s .. '\\cr' end

    local SEP = '  '

    -- Define glyph variables for displaying mode status as a colored circle
    local GLYPH_FIELDS = {
        {
            label = 'TH',
            mode = 'TreasureMode',
            off = 'None',
            colors = { ['Tag'] = COLOR.warn, ['Full Time'] = COLOR.good, ['SATA'] = COLOR.cyan }
        },
        {
            label = 'SR',
            mode = 'SpellReceived',
            off = 'OFF',
            colors = { ['ON'] = COLOR.good }
        },
        {
            label = 'HOX',
            mode = 'Hoxne',
            off = 'OFF',
            colors = { ['ON-Allow Critical'] = COLOR.warn, ['ON-Locked'] = COLOR.good }
        },
    }

    --3 letter aliases for known ui names. Backward-compatible.
    local UI_SHORT_ALIASES = {
        ['mode'] = 'MDE',
        ['pet'] = 'PET',
        ['tp mode'] = 'TPM',
        ['auto tank'] = 'TNK',
        ['tank'] = 'TNK',
        ['runes'] = 'RUN',
        ['rune'] = 'RUN',
    }

    -- Derive a three-cell label from a long mode name. Alias first, then a
    -- generic rule: one word takes its first three letters, several words take
    -- two letters of the first plus the initial of the last ("TP Mode" -> TPM).
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

    -- An explicit UI_Short always wins and is used verbatim. The label column
    -- widens to fit it.
    local function status_label(explicit, name)
        if explicit and explicit ~= '' then return explicit end
        return derive_short(name)
    end

    -- Display columns, not bytes: mode values are ASCII, but glyphs are 3 bytes
    -- each and colour tags are zero-width, so never measure a composed string.
    local function cells(s)
        local n = 0
        for i = 1, #s do
            local b = s:byte(i)
            if b < 0x80 or b >= 0xC0 then n = n + 1 end
        end
        return n
    end

    local layout -- nil = rebuild on next draw

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

        layout = {
            fields = fields,
            label_w = label_w,
            header_w = header_w,
            -- Stretch the value field so the closing chevrons land on the
            -- header's right edge. Row = label_w + 1 + 1 + value_w + 1.
            value_w = math.max(value_w, header_w - label_w - 3,
                settings.Display_MinValueCells or 0),
        }
    end

    function invalidate_layout() layout = nil end

    local function glyph_entry(g)
        local m = state[g.mode]
        local v = m and tostring(m.value) or ''
        if v == g.off then
            return cs(COLOR.label, g.label) .. ' ' .. cs(COLOR.idle, GLYPH.off)
        end
        return cs(COLOR.label, g.label) .. ' ' .. cs(g.colors[v] or COLOR.good, GLYPH.on)
    end

    local function centered(v, w)
        local n = cells(v)
        if n > w then
            v, n = v:sub(1, w - 1) .. GLYPH.trunc, w -- values are ASCII; safe to sub
        end
        local pad = w - n
        local left = math.floor(pad / 2)
        return string.rep(' ', left) .. v .. string.rep(' ', pad - left)
    end

    -- UI for displaying the current states
    function display_box_update()
        if not layout then build_layout() end

        local head = T {}
        for _, g in ipairs(GLYPH_FIELDS) do head:insert(glyph_entry(g)) end

        if settings.oneline then
            -- Chevrons sit tight against the value; entries are space separated.
            for _, f in ipairs(layout.fields) do
                head:insert(cs(COLOR.label, f.label) .. ' '
                    .. cs(COLOR.chev, GLYPH.prev)
                    .. cs(COLOR.value, tostring(state[f.mode].value))
                    .. cs(COLOR.chev, GLYPH.next))
            end
            gs_status:text(head:concat(SEP))
        else
            local lines = T { head:concat(SEP) }
            for _, f in ipairs(layout.fields) do
                lines:insert(cs(COLOR.label, f.label .. string.rep(' ', layout.label_w - #f.label))
                    .. ' ' .. cs(COLOR.chev, GLYPH.prev)
                    .. cs(COLOR.value, centered(tostring(state[f.mode].value), layout.value_w))
                    .. cs(COLOR.chev, GLYPH.next))
            end
            gs_status:text(lines:concat('\n'))
        end
    end

    -- Zero the display and debug windows
    function display_zero_command()
        gs_status:pos_x(0)
        gs_status:pos_y(0)
        gs_debug:pos_x(0)
        gs_debug:pos_y(100)
        config.save(settings)
        add_to_chat("Displays reset and positions saved")
    end

    local debug_box_state = {}
    function debug_box_reset() debug_box_state = {} end

    -- Used to help debug issues
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

    local function join(...)
        if select('#', ...) < 2 then return (...) end
        local parts = {}
        for i = 1, select('#', ...) do parts[i] = tostring((select(i, ...))) end
        return table.concat(parts)
    end

    function log(...)
        if settings.debug then print(80, join(...)) end
    end

    function info(...)
        if settings.info then print(8, join(...)) end
    end

    function warn(...)
        if settings.warn then print(12, join(...)) end
    end

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

    function round(num, numDecimalPlaces)
        if num ~= nil then
            local mult = 10 ^ (numDecimalPlaces or 0)
            return math.floor(num * mult + 0.5) / mult
        end
    end

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

    -- Register event section
    windower.register_event('target change', on_target_change_for_th)
    windower.raw_register_event('incoming chunk', on_incoming_chunk_for_th)
    windower.raw_register_event('outgoing chunk', main_engine)
    windower.raw_register_event('zone change', on_zone_change_for_th)

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

    -- prerender fires every frame, independent of network traffic.  main_engine is
    -- bound to 'outgoing chunk', so it only runs when the client is actually
    -- sending packets - which is why the Ampulla re-equip and auto-use live here
    -- instead: they keep working while you stand still doing nothing.  The two
    -- clock gates make the per-frame cost one os.clock() call and a compare.
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
    end)

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

    -- Section used to determine if player is performing an action.
    -- raw_register_event skips user_equip_sets, which otherwise runs refresh_globals()
    -- plus a full equip_sets() pass for every action by every entity in range.  This
    -- handler only reads state and issues send_commands (UnlockByMode, equip_set_command,
    -- run_burst), so it needs neither.  See GearSwap user_functions.lua:265 vs :284.
    windower.raw_register_event('action', function(data)
        if data ~= nil then
            --log('cat='..data.category..',param='..data.param)
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
                    if data.param == 4154 then
                        log('Item Use Finished')
                        enchantment_completed()
                        UnlockByMode()
                        equip_set_command()
                    end
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

    -------------------------------------------------------------------------------------------------------------------
    -- This function is called to determine correct sets and not a built in gearswap call
    -------------------------------------------------------------------------------------------------------------------

    function choose_set()
        if buffactive['Sleep'] then return end
        local built_set = {}
        -- Combat Checks
        if player.status == "Engaged" then
            if sets.OffenseMode then
                merge_into(built_set, sets.OffenseMode)
                if sets.OffenseMode[state.OffenseMode.value] then
                    merge_into(built_set, sets.OffenseMode[state.OffenseMode.value])
                    -- Check the weapons
                    if state.WeaponMode.value ~= "Locked" then
                        if sets.Weapons then
                            if sets.Weapons[state.WeaponMode.value] then
                                merge_into(built_set, sets.Weapons[state.WeaponMode.value])
                            else
                                warn('sets.Weapons.' .. state.WeaponMode.value .. ' not found!')
                            end
                        else
                            warn('sets.Weapons not found!')
                        end
                        -- Equip sub weapon based off mode
                        if not DualWield and not TwoHand then
                            if sets.Weapons.Shield then
                                merge_into(built_set, sets.Weapons.Shield)
                            else
                                warn('sets.Weapons.Shield not found!')
                            end
                        elseif DualWield then
                            if sets.DualWield then
                                merge_into(built_set, sets.DualWield)
                            else
                                warn('sets.DualWield not found!')
                            end
                        end
                    end
                    -- Ranged Mode
                    if state.JobMode.value == "Ranged" then
                        log('Ranged Mode')
                        if sets.Idle and sets.Idle[state.OffenseMode.value] then
                            merge_into(built_set, sets.Idle[state.OffenseMode.value])
                        else
                            warn('sets.Idle.' .. state.OffenseMode.value .. ' not found!')
                        end
                    end
                    -- Check if AM3 is active
                    if buffactive['Aftermath: Lv.3'] and sets.OffenseMode.AM3 and sets.OffenseMode.AM3[state.WeaponMode.value] then
                        merge_into(built_set, sets.OffenseMode.AM3[state.WeaponMode.value])
                    elseif buffactive['Aftermath: Lv.2'] and sets.OffenseMode.AM2 and sets.OffenseMode.AM2[state.WeaponMode.value] then
                        merge_into(built_set, sets.OffenseMode.AM2[state.WeaponMode.value])
                    elseif buffactive['Aftermath: Lv.1'] and sets.OffenseMode.AM1 and sets.OffenseMode.AM1[state.WeaponMode.value] then
                        merge_into(built_set, sets.OffenseMode.AM1[state.WeaponMode.value])
                    elseif buffactive['Aftermath'] and sets.OffenseMode.AM and sets.OffenseMode.AM[state.WeaponMode.value] then
                        merge_into(built_set, sets.OffenseMode.AM[state.WeaponMode.value])
                    end
                    -- Check if TreasureMode is activew
                    if state.TreasureMode.value ~= 'None' then
                        if sets.TreasureHunter then
                            -- Equip TH gear if mob is not marked as tagged
                            if not th_info.tagged_mobs[player.target.id] then
                                merge_into(built_set, sets.TreasureHunter)

                                -- Equip TH gear if TreasureMode is Full Time
                            elseif state.TreasureMode.value == 'Full Time' then
                                merge_into(built_set, sets.TreasureHunter)

                                -- Equip TH gear if TreasureMode is SATA and either SA, TA or Feint is active
                            elseif state.TreasureMode.value == 'SATA' and (buffactive['Sneak Attack'] or buffactive['Trick Attack'] or buffactive['Feint']) then
                                merge_into(built_set, sets.TreasureHunter)
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
                merge_into(built_set, sets.Idle)

                -- Idle state
                if sets.Idle[state.OffenseMode.value] then
                    merge_into(built_set, sets.Idle[state.OffenseMode.value])
                else
                    warn('sets.Idle.' .. state.OffenseMode.value .. ' not found!')
                end

                -- Resting condition
                if player.status == "Resting" then
                    if sets.Idle.Resting then
                        merge_into(built_set, sets.Idle.Resting)
                    else
                        warn('sets.Idle.Resting not found!')
                    end
                end

                -- Check the weapons
                if state.WeaponMode.value == "Locked" then
                    merge_into(built_set,
                        { main = player.equipment.main, sub = player.equipment.sub, range = player.equipment.range })
                    log(built_set)
                else
                    if sets.Weapons then
                        if sets.Weapons[state.WeaponMode.value] then
                            merge_into(built_set, sets.Weapons[state.WeaponMode.value])
                        else
                            warn('sets.Weapons.' .. state.WeaponMode.value .. ' not found!')
                        end
                    else
                        warn('sets.Weapons not found!')
                    end

                    -- Check for sub weapon
                    if not TwoHand and not DualWield then
                        if sets.Weapons.Shield then
                            merge_into(built_set, sets.Weapons.Shield)
                        else
                            warn('sets.Weapons.Shield not found!')
                        end
                    end
                end

                --Pet specific checks
                if pet.isvalid then
                    if sets.Idle.Pet then
                        merge_into(built_set, sets.Idle.Pet)
                    else
                        warn('sets.Idle.Pet not found!')
                    end
                end
                -- Equip Sublimation gear
                if buffactive[187] then
                    if sets.Idle.Sublimation then
                        merge_into(built_set, sets.Idle.Sublimation)
                    else
                        warn('sets.Idle.Sublimation not found!')
                    end
                end
                -- Equip movement gear
                if is_moving then
                    if sets.Movement then
                        merge_into(built_set, sets.Movement)
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
            merge_into(built_set,
                { ammo = Ammo[state.OffenseMode.value] })
        end

        return built_set
    end

    function equip_set_command()
        windower.send_command("gs c update auto")
    end

    -- Start the engine with a 5 sec delay
    coroutine.schedule(display_box_update, 2)
    coroutine.schedule(dual_wield_check, 2.1)
    coroutine.schedule(two_hand_check, 2.2)
    coroutine.schedule(equip_set_command, 2.3)
    coroutine.schedule(main_engine, 2.4)
end
