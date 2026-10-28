-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: Corsair. A sample to copy into your character's folder and fill in.
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
LockStylePallet = "7"
MacroBook = "18" -- sub_job_change_custom below can switch to a different book for each subjob
MacroSet = "1"

-- The food "gs c food" uses.
Food = "Sublime Sushi"

-- Use a Remedy for paralysis or silence, and a Holy Water for doom, automatically.
AutoItem = false

-- Pick a random lockstyle from Lockstyle_List each time the file loads, instead of LockStylePallet.
Random_Lockstyle = false

-- The lockstyle sets the random pick chooses from.
Lockstyle_List = { 1, 2, 6, 12 }

-- Warn at precast when your ammunition falls below this count.
Ammo_Warning_Limit = 99

-- Offense modes, and the one the file starts in. CRIT is added to the engine's defaults for
-- Aftermath Lv.3 critical-hit builds.
-- Each mode offered needs its own sets.OffenseMode.<Mode> and sets.Idle.<Mode> below.
state.OffenseMode:options('TP', 'ACC', 'DT', 'CRIT', 'MEVA', 'SB')
state.OffenseMode:set('TP')

-- Weapon modes. Each name needs a matching sets.Weapons entry.
state.WeaponMode:options('Fomalhaut', 'Death Penalty', 'Savage Blade', 'Aeolian Edge', 'Evisceration')
state.WeaponMode:set('Death Penalty')

-- The weapon lock, and the one to start in. Unlocked lets any set change your weapons. Locked keeps
-- the pair your weapon mode names, and the TP on it, through every action, except where the engine
-- itself must put on a weapon: one a spell needs, sets.Weapons.Sleep while you are asleep, and a
-- Spell Received set. Locked+R is Locked and keeps your ranged weapon as well, unless a Hoxne mode
-- holds that slot.
state.WeaponLock:options('Unlocked','Locked','Locked+R')
state.WeaponLock:set('Unlocked')

-- The buff level, and the one to start in. Only weaponskills read it: at HighBuff they wear their
-- HighBuff children, and at MidBuff only a weaponskill's own MidBuff child.
state.BuffLevel:options('MidBuff','HighBuff')
state.BuffLevel:set('MidBuff')

-- Naming JobMode shows it in chat and on the status box.
UI_Name = 'TP Mode'

-- Job mode, and the one to start in. The hooks below add the sets.Weapons entry named for the
-- current value, through Job_Mode_Check: Melee, Ranged and Subtle Blow each name an offhand there,
-- and Standard names none. Ranged also merges the idle set for the current offense mode into the
-- engaged set, since a character shooting stands still.
state.JobMode:options('Standard', 'Melee', 'Ranged', 'Subtle Blow')
state.JobMode:set('Standard')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup(LockStylePallet, MacroBook, MacroSet)

function get_sets()

	-- Bullets by purpose. The engine does not choose between these by offense mode, so a set uses
	-- one by naming it, as sets.Idle does with Ammo.Bullet.RA. Ammo.Bullet.RA is also the standard
	-- bullet a weaponskill can fire once its own bullets run out. These sit above sets.Weapons
	-- because the Aeolian Edge weapon set uses Ammo.Bullet.MAG_WS.
	Ammo.Bullet.RA = "Chrono Bullet"  -- TP Ammo
	Ammo.Bullet.WS = "Chrono Bullet"  -- Physical Weaponskills
	Ammo.Bullet.CRIT = "Chrono Bullet" -- Critical Hit Mode
	Ammo.Bullet.SB = "Chrono Bullet"  -- Subtle Blow Mode
	Ammo.Bullet.MAB = "Living Bullet" -- Magical Weaponskills
	-- Magic accuracy bullets. No set uses this yet. To use it, add ammo = Ammo.Bullet.MACC to the
	-- set that should.
	Ammo.Bullet.MACC = "Chrono Bullet"
	Ammo.Bullet.QD = "Hauksbok Bullet" -- Quick Draw
	Ammo.Bullet.MAG_WS = "Living Bullet" -- Magic Weapon Skills

	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	-- Weapon sets, one per weapon mode.
	sets.Weapons = {}

	sets.Weapons['Savage Blade'] = {
		main = gear.naegling,
		sub = gear.gleti,
		range = gear.anarchyPlusTwo,
	}

	sets.Weapons['Evisceration'] = {
		main = gear.tauret,
		sub = gear.gleti,
		range = gear.fomalhaut,
	}

	sets.Weapons['Fomalhaut'] = {
		main = gear.rostam4,
		sub = gear.rostam2,
		range = gear.fomalhaut,
	}

	sets.Weapons['Death Penalty'] = {
		main = gear.rostam4,
		sub = gear.tauret,
		range = gear.deathPenalty,
	}

	sets.Weapons['Aeolian Edge'] = {
		ammo = Ammo.Bullet.MAG_WS,
		main = gear.rostam4,
		sub = gear.tauret,
		range = gear.anarchyPlusTwo,
	}

	-- Offhand weapons for the Melee, Subtle Blow and Ranged job modes, added by Job_Mode_Check in
	-- the hooks below.
	sets.Weapons.Melee = {
		sub = gear.gleti,
	}

	sets.Weapons['Subtle Blow'] = {
		sub = gear.gleti, -- Used for SB II
	}

	sets.Weapons.Ranged = {
		sub = gear.kustawiPlusOne,
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons.Shield = {
		sub = gear.nusku,
	}

	-- Merged over the idle set when you are put to sleep. The slots it names stay locked until you
	-- wake up. Put gear here that wakes you, such as a piece that drains HP.
	sets.Weapons.Sleep = {
		range = gear.earp,
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

	-- Worn whenever you are not engaged. Every action also starts from this set, so any slot an
	-- action's sets leave empty keeps your idle gear.
	sets.Idle = {
		ammo = Ammo.Bullet.RA,
		head = gear.nyameHead,
		body = gear.adamantiteArmor,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.loricatePlusOne,
		waist = gear.carriers,
		left_ear = gear.sanareEarring,
		right_ear = gear.odnowaPlusOne,
		left_ring = gear.gelatinousPlusOne,
		right_ring = gear.shadowRing,
		back = gear.corDAPdt,
	}
	-- Idle sets for each offense mode, merged over the idle set, and Resting, merged over them
	-- while you rest.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.CRIT = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {})
	sets.Idle.Resting = {}

	-- Worn over the idle set while a Phantom Roll on you stands at 11.
	-- It is meant for Roller's Ring, which every job can wear and which grants Refresh +1 and
	-- Regain +10 at an 11, e.g. left_ring="Roller's Ring".
	-- This set applies in every offense mode. The TP set below applies only in TP mode and merges
	-- after it.
	-- It is worn only while idle, so any action swaps it out, and it comes back when the action
	-- ends.
	-- While you move, a ring named here replaces a movement ring in the same slot. This file's
	-- sets.Movement names right_ring, so left_ring is the free slot.
	sets.Idle.XIRoll = {}
	-- The TP mode version, merged after the one above.
	sets.Idle.TP.XIRoll = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = {
		legs = gear.carmineLegsPlusOnePathA,
		right_ring = gear.defending,
	}

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

	-- Not read by the engine. The SB weaponskill set below is this same table.
	sets.Subtle_Blow = {
		neck = gear.bathyPlusOne,
		right_ring = gear.chirichPlusOne2,
	}

	-- ===================================================================================================================
	--		sets.OffenseMode
	-- ===================================================================================================================

	-- Engaged sets. sets.OffenseMode is worn in every offense mode, and the current mode's set
	-- merges over it.
	sets.OffenseMode = {
		ammo = Ammo.Bullet.RA,
		head = gear.malignanceHead,
		body = gear.malignanceBody,
		hands = gear.malignanceHands,
		legs = gear.samnuhaTightsDA,
		feet = gear.malignanceFeet,
		neck = gear.iskur,
		waist = gear.sailfi,
		left_ear = gear.telos,
		right_ear = gear.crepuscularEar,
		left_ring = gear.lehkoHabhokaRing,
		right_ring = gear.eponas,
		back = gear.nullShawl,
	}

	sets.OffenseMode.TP = set_combine(sets.OffenseMode, {})

	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {
		legs = gear.chasseurLegsPlusThree,
		right_ear = gear.odnowaPlusOne,
	})

	sets.OffenseMode.CRIT = set_combine(sets.OffenseMode, {
		head = gear.nullMasque,
		body = gear.ikengaBody,
		hands = gear.chasseurHandsPlusThree,
		legs = gear.malignanceLegs,
		feet = gear.oshosiFeetPlusOne,
		neck = gear.nullLoop,
		waist = gear.reiki,
		left_ear = gear.telos,
		right_ear = gear.chasseurEarringPlusOne,
		left_ring = gear.lehkoHabhokaRing,
		right_ring = gear.eponas,
		back = gear.corCrit,
	})

	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {})

	sets.OffenseMode.SB = set_combine(sets.OffenseMode, {
		body = gear.adamantiteArmor,
		legs = gear.chasseurLegsPlusThree,
		neck = gear.nullLoop,
		right_ear = gear.odnowaPlusOne,
		left_ring = gear.chirichPlusOne1,
		right_ring = gear.chirichPlusOne2,
	})

	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode.DT, {
		head = gear.malignanceHead,
		body = gear.malignanceBody,
		hands = gear.malignanceHands,
		legs = gear.chasseurLegsPlusThree,
		feet = gear.malignanceFeet,
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
		left_ear = gear.telos,
		right_ear = gear.odnowaPlusOne,
		left_ring = gear.lehkoHabhokaRing,
		right_ring = gear.defending,
		back = gear.corDAPdt,
	})

	-- Merged over the engaged set while you have the Dual Wield trait and your main weapon is
	-- one-handed.
	sets.DualWield = {
		waist = gear.reiki,
		right_ear = gear.eabani,
	}

	-- Treasure Hunter gear, worn on an action or melee swing against a monster not yet tagged, and
	-- throughout a fight in Full Time mode. It is never worn in None mode, where every job but
	-- Thief starts.
	sets.TreasureHunter = {
		waist = gear.chaac,
	}

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Every precast starts from sets.Idle, except a pet command's. For a spell or a ranged attack,
	-- sets.Precast is merged over it, then the fast cast set for a spell or sets.Precast.RA for a
	-- ranged attack. Any slot left empty keeps your idle gear.
	sets.Precast = {}
	-- Ranged attack precast. Snapshot shortens a shot the way fast cast shortens a spell, and Rapid
	-- Shot works like quick magic.
	-- Snapshot caps at 70, and job gifts give 10, so gear needs 60. Flurry adds 15% snapshot and
	-- Flurry II adds 30%.

	-- Without Flurry, 60 snapshot is needed.
	sets.Precast.RA = {
		ammo = Ammo.Bullet.RA,
		head = gear.chasseurHeadPlusThree, -- 0/14
		body = gear.oshosiBodyPlusOne,   -- 14/0
		hands = gear.carmineHandsPlusOnePathD, -- 8/11
		legs = gear.adhemarLegsPlusOnePathD, -- 10/13
		feet = gear.meghanadaFeetPlusTwo, -- 10/0
		left_ear = gear.tuisto,
		right_ear = gear.etiolation,
		left_ring = gear.dingir,
		right_ring = gear.crepuscularRing, -- 3/0
		neck = gear.commodoreCharmPlusTwo, -- 4/0
		waist = gear.yemaya,       -- 0/5
		back = gear.corSnapshot,   -- 10/0
	}                              -- Totals 59/43

	-- Merged over the ranged precast set while Flurry is up, when 45 snapshot is needed.
	sets.Precast.RA.Flurry = set_combine(sets.Precast.RA, {
		body = gear.laksamanaBodyPlusFour, -- 0/20
	})                             -- Totals 45/63

	-- Merged over the ranged precast set instead while Flurry II or Embrava is up, when 30 snapshot
	-- is needed.
	sets.Precast.RA.Flurry_II = set_combine(sets.Precast.RA.Flurry, {
		feet = gear.pursuerFeetPathD -- 0/10
	})                         -- Totals 35/73

	-- Fast cast, worn at the start of every spell.
	sets.Precast.FastCast = {
		head = gear.carmineHeadPlusOnePathD, -- 14
		body = gear.taeonTabardFC,        -- 9
		hands = gear.leylineGlovesFC,     -- 7  Need to update
		legs = gear.herculeanTrousersBFC, -- 6
		feet = gear.carmineFeetPlusOnePathD, -- 8
		neck = gear.voltsurge,            -- 4
		waist = gear.platinumMoogleBelt,
		left_ear = gear.loquacious,       -- 2
		right_ear = gear.etiolation,      -- 1
		left_ring = gear.kishar,          -- 4
		right_ring = gear.lebecheRing,
		back = gear.corFC,                -- 10
	}                                     -- 65 FC

	-- Merged over the fast cast set when you cast Cure, Curaga or Cura.
	sets.Precast.Cure = {}

	-- Merged over the fast cast set when you cast a healing spell other than a cure, such as Raise
	-- or a -na spell.
	sets.Precast.Healing = {}

	-- Merged over the fast cast set when you cast enhancing magic.
	sets.Precast.Enhancing = {}

	-- Merged over the fast cast set when you cast Utsusemi.
	sets.Precast.Utsusemi = {}

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- The base for every cast, merged over sets.Idle on every midcast, so any slot it leaves empty
	-- keeps your idle gear.
	sets.Midcast = set_combine(sets.Idle, {})

	-- Spell interruption rate down. Used under every midcast except ranged attacks, so any more
	-- specific set overrides it.
	sets.Midcast.SIRD = {}

	-- Worn for every shot. The offense mode's set below merges over it, except in TP mode.
	sets.Midcast.RA = set_combine(sets.Midcast, {
		ammo = Ammo.Bullet.RA,
		head = gear.ikengaHead,
		body = gear.ikengaBody,
		hands = gear.ikengaHands,
		legs = gear.chasseurLegsPlusThree,
		feet = gear.ikengaFeet,
		neck = gear.iskur,
		waist = gear.yemaya,
		left_ear = gear.telos,
		right_ear = gear.crepuscularEar,
		left_ring = gear.ilabrat,
		right_ring = gear.crepuscularRing,
		back = gear.corSTP,
	})

	sets.Midcast.RA.ACC = set_combine(sets.Midcast.RA, {})

	sets.Midcast.RA.SB = set_combine(sets.Midcast.RA, {
		ammo = Ammo.Bullet.SB,
		-- 10 II from gleti's Knife
		head = gear.ikengaHead,      -- 5 II
		hands = gear.ikengaHands,    -- 15
		left_ring = gear.chirichPlusOne1, -- 10
		right_ring = gear.chirichPlusOne2, -- 10
	})

	sets.Midcast.RA.CRIT = set_combine(sets.Midcast.RA, {
		ammo = Ammo.Bullet.CRIT,
		head = gear.ikengaHead,
		feet = gear.oshosiFeetPlusOne,
		legs = gear.ikengaLegs,
		waist = gear.kwahuKachinaBeltPlusOne,
		left_ring = gear.chirichRingPlusOne,
		right_ring = gear.chirichRingPlusOne,
		right_ear = gear.chasseurEarringPlusOne,
		back = gear.corCrit,
	})

	-- Aftermath sets for shots, merged over the shooting set and its mode set while that level of
	-- Aftermath is up. A child named for a weapon mode adds gear for that weapon alone, so Death
	-- Penalty's Aftermath gear goes in the Death Penalty children.
	sets.Midcast.RA.AM1 = {}
	sets.Midcast.RA.AM2 = {}
	sets.Midcast.RA.AM3 = {}
	sets.Midcast.RA.AM1['Death Penalty'] = {}
	sets.Midcast.RA.AM2['Death Penalty'] = {}
	sets.Midcast.RA.AM3['Death Penalty'] = {}

	-- Worn for every shot while Triple Shot is up, in any offense mode. It goes on after the mode's
	-- shooting set, so every slot it names wins, including any slot you add to it. The slots it
	-- leaves out keep the mode's pieces.
	-- Only these go on after it: a set keyed by an active buff's name under sets.Midcast or the
	-- shooting sets, the round the Ammo table names for the mode, the weapon mode's set and weapon
	-- pair while the weapon lock is on, Treasure Hunter gear against an untagged monster, and what
	-- midcast_custom below returns. A hold or lock on a slot keeps that slot as it is.
	sets.Midcast.RA.TripleShot = {
		head = gear.oshosiHeadPlusOne,   -- Missing
		body = gear.chasseurBodyPlusThree, --14
		hands = gear.lanunHandsPlusFour, -- Tripple shot becomes Quad shot
		legs = gear.oshosiLegsPlusOne, -- Missing
		feet = gear.oshosiFeetPlusOne, --3
	}                                   --28

	-- Worn when you cast Utsusemi.
	sets.Midcast.Utsusemi = {}
	-- Merged over the Utsusemi set in DT or MEVA mode.
	-- sets.Midcast.Utsusemi.DT = {}
	-- sets.Midcast.Utsusemi.MEVA = {}

	-- The commented DT and MEVA children below go over their casting set in those offense modes.
	-- Put damage taken or magic evasion pieces in one, at some cost to what the set is for, and
	-- uncomment it.

	-- Worn when you cast a cure.
	sets.Midcast.Cure = {}

	-- Merged over the cure set when you cast a cure on yourself.
	sets.Midcast.Cure.Self = {}

	-- Merged over the cure set when you cast a cure on anyone else, or on yourself under Accession.
	sets.Midcast.Cure.Others = {}

	-- Merged over the cure set in DT or MEVA mode.
	-- sets.Midcast.Cure.DT = {}
	-- sets.Midcast.Cure.MEVA = {}

	-- Worn when you cast a Curaga spell, or Cura, from your white mage subjob. Neither wears the
	-- cure set.
	sets.Midcast.Curaga = {}
	-- Merged over the Curaga set in DT or MEVA mode.
	-- sets.Midcast.Curaga.DT = {}
	-- sets.Midcast.Curaga.MEVA = {}
	sets.Midcast.Cura = {}
	-- Merged over the Cura set in DT or MEVA mode.
	-- sets.Midcast.Cura.DT = {}
	-- sets.Midcast.Cura.MEVA = {}

	-- Worn when you cast enhancing magic, for duration gear.
	sets.Midcast.Enhancing = {}

	-- Merged over the enhancing set when you cast an enhancing spell on someone else, or on
	-- yourself under Accession.
	sets.Midcast.Enhancing.Others = {}

	-- Merged over the enhancing set in DT or MEVA mode.
	-- sets.Midcast.Enhancing.DT = {}
	-- sets.Midcast.Enhancing.MEVA = {}

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Quick Draw. sets.QuickDraw is merged over sets.Idle (Quick Draw does not use sets.JA), then
	-- the set named for the shot. ACC, DMG and STP are building blocks that the shot sets below
	-- copy.
	sets.QuickDraw = {}

	sets.QuickDraw.ACC = {
		ammo = Ammo.Bullet.QD,
		head = gear.malignanceHead,
		body = gear.malignanceBody,
		hands = gear.malignanceHands,
		legs = gear.malignanceLegs,
		feet = gear.malignanceFeet,
		neck = gear.commodoreCharmPlusTwo,
		waist = gear.eschan,
		left_ear = gear.hermetic,
		right_ear = gear.crepuscularEar,
		left_ring = gear.kishar,
		right_ring = gear.crepuscularRing,
		back = gear.corSTP,
	}

	sets.QuickDraw.DMG = {
		ammo = Ammo.Bullet.QD,
		head = gear.nyameHead,
		body = gear.lanunBodyPlusThree,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.chasseurFeetPlusThree,
		neck = gear.commodoreCharmPlusTwo,
		waist = gear.orpheusWaist,
		left_ear = gear.friomisi,
		right_ear = gear.moonshadeEarringAcc,
		left_ring = gear.ilabrat,
		right_ring = gear.dingir,
		back = gear.corWSDAgi,
	}

	sets.QuickDraw.STP = {
		ammo = Ammo.Bullet.QD,
		head = gear.malignanceHead,
		body = gear.malignanceBody,
		hands = gear.malignanceHands,
		legs = gear.chasseurLegsPlusThree,
		feet = gear.malignanceFeet,
		neck = gear.iskur,
		waist = gear.yemaya,
		left_ear = gear.telos,
		right_ear = gear.crepuscularEar,
		left_ring = gear.ilabrat,
		right_ring = gear.crepuscularRing,
		back = gear.corSTP,
	}

	-- One set per shot. Fire through Water Shot may also take an obi, sash or cape the engine picks
	-- for the day, weather and distance. Light Shot and Dark Shot do not.
	sets.QuickDraw["Fire Shot"] = set_combine(sets.QuickDraw.DMG, {})
	sets.QuickDraw["Ice Shot"] = set_combine(sets.QuickDraw.DMG, {})
	sets.QuickDraw["Wind Shot"] = set_combine(sets.QuickDraw.DMG, {})
	sets.QuickDraw["Earth Shot"] = set_combine(sets.QuickDraw.DMG, {})
	sets.QuickDraw["Thunder Shot"] = set_combine(sets.QuickDraw.DMG, {})
	sets.QuickDraw["Water Shot"] = set_combine(sets.QuickDraw.DMG, {})
	sets.QuickDraw["Light Shot"] = set_combine(sets.QuickDraw.DMG, {})
	sets.QuickDraw["Dark Shot"] = set_combine(sets.QuickDraw.DMG, {
		left_ring = gear.dingir,
		right_ring = gear.archonRing,
		head = gear.pixieHead,
	})

	-- Job abilities. sets.JA is merged over sets.Idle for every job ability, then the set named for
	-- the ability is merged over it. Any slot left empty keeps your idle gear.
	sets.JA = {}
	sets.JA["Wild Card"] = {
		feet = gear.lanunFeetPlusFour,
	}
	sets.JA["Random Deal"] = {
		body = gear.lanunBodyPlusThree,
	}
	sets.JA["Snake Eye"] = {
		legs = gear.lanunLegsPlusThree,
	}
	sets.JA["Fold"] = {}     -- Use gloves for bust
	sets.JA["Triple Shot"] = {} -- Worn when Triple Shot is used. The shots themselves wear sets.Midcast.RA.TripleShot.
	sets.JA["Cutting Cards"] = {}
	sets.JA["Crooked Cards"] = {}
	-- Merged over sets.JA when you use Double-Up, instead of sets.PhantomRoll. Your Phantom Roll
	-- bonus gear keeps working through every Double-Up, so this set only needs the range ring.
	sets.JA["Double-Up"] = {
		right_ring = gear.luzaf, -- 16 yalm range
	}

	-- Waltzes from your dancer subjob, merged over sets.Idle (Waltzes do not use sets.JA). A set
	-- named for the waltz is merged over it.
	sets.Waltz = set_combine(sets.OffenseMode.DT, {
		ammo = gear.yamarang,      -- 5
		hands = gear.slitherGlovesPlusOne, -- 5
		legs = gear.dashingSubligar, -- 10
	})                             -- 20% Potency

	-- Not read by the engine. The precast and midcast hooks below add it on Fold while two busts
	-- stand.
	sets.Fold = { hands = gear.lanunHandsPlusFour }

	-- Merged over sets.Idle for every Phantom Roll (rolls do not use sets.JA), with the set named
	-- for the roll merged over it. Double-Up uses sets.JA and then this set, unless you declare
	-- sets.JA["Double-Up"], which it uses instead.
	sets.PhantomRoll = {
		main = gear.rostam2,         -- +8 Effect and 60 sec Duration
		sub = gear.nusku,
		range = gear.compensator,    -- 20 sec Duration
		head = gear.lanunHeadPlusFour, -- 50% Job ability Bonus
		hands = gear.chasseurHandsPlusThree, --60 sec Duration
		neck = gear.regalNeck,       -- 20 sec Duration
		right_ring = gear.luzaf,     -- 16 yalm range
		back = gear.corSnapshot,     -- 30 sec Duration
	}

	-- Sets named for each roll. Most are the base set itself, and the rest add the piece that
	-- enhances that roll.
	sets.PhantomRoll["Fighter's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Monk's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Healer's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Wizard's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Warlock's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Rogue's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Gallant's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Chaos Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Beast Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Choral Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Hunter's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Samurai Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Ninja Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Drachen Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Evoker's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Magus's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Corsair's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Puppet Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Dancer's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Scholar's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Bolter's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Caster's Roll"] = set_combine(sets.PhantomRoll, { legs = gear.chasseurLegsPlusThree, })
	sets.PhantomRoll["Tactician's Roll"] = set_combine(sets.PhantomRoll, { body = gear.chasseurBodyPlusThree })
	sets.PhantomRoll["Allies' Roll"] = set_combine(sets.PhantomRoll, { hands = gear.chasseurHandsPlusThree })
	sets.PhantomRoll["Miser's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Companion's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Avenger's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Naturalist's Roll"] = sets.PhantomRoll
	sets.PhantomRoll["Courser's Roll"] = set_combine(sets.PhantomRoll, { feet = gear.chasseurFeetPlusThree })
	sets.PhantomRoll["Blitzer's Roll"] = set_combine(sets.PhantomRoll, { head = gear.chasseurHeadPlusThree })

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- Weaponskill base, merged over sets.Idle for every weaponskill, ranged ones included. The set
	-- named for the weaponskill is merged over it. Any slot left empty keeps your idle gear.
	sets.WS = {
		ammo = Ammo.Bullet.WS,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.chasseurHandsPlusThree,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.commodoreCharmPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.ishvara,
		right_ear = gear.moonshadeEarringAcc,
		left_ring = gear.regalRing,
		right_ring = gear.epimanondas,
		back = gear.corWSDStr,
	}

	-- Merged over the melee weaponskill sets in CRIT mode. SB and MEVA below work the same way in
	-- their modes.
	sets.WS.CRIT = {}

	-- Merged in ACC mode after the set named for the weaponskill, so its gear wins. Only fill in
	-- the slots ACC mode should change. A weaponskill with its own ACC set uses that instead.
	sets.WS.ACC = {}

	sets.WS.SB = sets.Subtle_Blow

	-- MAB is not an offense mode. It is worn only through the magic weaponskill sets below that are
	-- built from it.
	sets.WS.MAB = set_combine(sets.WS, {
		ammo = Ammo.Bullet.MAB,
		feet = gear.lanunFeetPlusFour,
		waist = gear.eschan,
		left_ear = gear.friomisi,
		right_ear = gear.crematioEarring,
		back = gear.corWSDAgi,
	})

	sets.WS.MEVA = {
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
	}

	-- Ranged weaponskill base, merged over sets.WS for Marksmanship weaponskills. The offense
	-- mode's set, keyed RA first as in sets.WS.RA.ACC, merges over it except in TP mode.
	sets.WS.RA = {
		head = gear.lanunHeadPlusFour,
		body = gear.ikengaBody,
		hands = gear.chasseurHandsPlusThree,
		legs = gear.ikengaLegs,
		feet = gear.ikengaFeet,
		neck = gear.fotiaNeck,
		waist = gear.fotiaWaist,
		left_ear = gear.ishvara,
		right_ear = gear.moonshadeEarringAcc,
		left_ring = gear.regalRing,
		right_ring = gear.dingir,
		back = gear.corWSDDt,
	}

	-- Ranged mode sets, merged after the set named for the weaponskill the same way. Each only
	-- fills in what its mode changes.
	sets.WS.RA.ACC = {}

	sets.WS.RA.CRIT = {}

	-- Aftermath sets, merged over the weaponskill sets while that Aftermath level is up. A child
	-- keyed by a weapon mode refines a level for that weapon, so the ['Death Penalty'] children
	-- apply only in the Death Penalty weapon mode.
	sets.WS.AM = {}
	sets.WS.AM1 = {}
	sets.WS.AM2 = {}
	sets.WS.AM3 = {}

	sets.WS.RA.AM = {}
	sets.WS.RA.AM1 = {}
	sets.WS.RA.AM2 = {}
	sets.WS.RA.AM3 = {}
	sets.WS.RA.AM1['Death Penalty'] = {}
	sets.WS.RA.AM2['Death Penalty'] = {}
	sets.WS.RA.AM3['Death Penalty'] = {}

	-- Merged in DT mode after the set named for the weaponskill, so its gear wins, for damage taken
	-- gear. A weaponskill with its own DT set uses that instead. Every slot here costs some of the
	-- weaponskill's damage, so uncomment it only once you fill it in.
	-- sets.WS.DT = {}

	-- Merged over every weaponskill while Buff Level (Alt+F12) is set to HighBuff, for physical
	-- damage limit gear. At MidBuff, the default, no set is used here. In any offense mode except
	-- TP, the set for that mode and level is merged after it, such as sets.WS.ACC.HighBuff in ACC
	-- mode. A ranged weaponskill uses the same sets under sets.WS.RA instead, such as
	-- sets.WS.RA.HighBuff. A weaponskill's own child sets replace these for that weaponskill, as
	-- shown at the end of this section.
	sets.WS.HighBuff = {
		left_ring = gear.sroda,
	}
	sets.WS.ACC.HighBuff = {}
	sets.WS.RA.HighBuff = {
		head = gear.ikengaHead,
		left_ring = gear.sroda,
	}
	sets.WS.RA.ACC.HighBuff = {}

	sets.WS['Aeolian Edge'] = set_combine(sets.WS.MAB, {
		right_ear = gear.moonshadeEarringAcc,
	})

	-- Evisceration, for the Evisceration weapon mode.
	sets.WS["Evisceration"] = {}

	sets.WS["Savage Blade"] = set_combine(sets.WS, {
		left_ring = gear.sroda,
	})

	sets.WS["Fast Blade"] = set_combine(sets.WS, {})
	sets.WS["Burning Blade"] = set_combine(sets.WS, {})
	sets.WS["Flat Blade"] = set_combine(sets.WS, {})
	sets.WS["Shining Blade"] = set_combine(sets.WS, {})
	sets.WS["Circle Blade"] = set_combine(sets.WS, {})
	sets.WS["Spirits Within"] = set_combine(sets.WS, {})
	sets.WS["Requiescat"] = set_combine(sets.WS, {})

	-- Marksmanship weaponskills.
	sets.WS["Hot Shot"] = set_combine(sets.WS, sets.WS.RA, {})
	sets.WS["Split Shot"] = set_combine(sets.WS, sets.WS.RA, {})
	sets.WS["Sniper Shot"] = set_combine(sets.WS, sets.WS.RA, { -- MAX ACC for skillchaining
		head = gear.chasseurHeadPlusThree,
		body = gear.chasseurBodyPlusThree,
		hands = gear.chasseurHandsPlusThree,
		legs = gear.chasseurLegsPlusThree,
		feet = gear.ikengaFeet,
		neck = gear.iskur,
		waist = gear.tellenBelt,
		left_ear = gear.telos,
		right_ear = gear.crepuscularEar,
		left_ring = gear.crepuscularRing,
		right_ring = gear.karieyh,
		back = gear.corWSDDt,
	})
	sets.WS["Numbing Shot"] = set_combine(sets.WS, sets.WS.RA, {})
	sets.WS["Slug Shot"] = set_combine(sets.WS, sets.WS.RA, {

	})

	sets.WS["Last Stand"] = set_combine(sets.WS, sets.WS.RA, {

	})

	sets.WS["Wildfire"] = set_combine(sets.WS.MAB, {

	})

	sets.WS["Leaden Salute"] = set_combine(sets.WS.MAB, {
		head = gear.pixieHead,
		right_ring = gear.archonRing,
		right_ear = gear.moonshadeEarringAcc,
		waist = gear.svelt, -- Changes based off elemental function
	})

	-- Child sets for a single weaponskill, used instead of the general sets.WS or sets.WS.RA ones:
	-- one for a mode, one for HighBuff, and one for the two together. Once declared, each one
	-- replaces the general set for that weaponskill even if it is empty, so only uncomment a line
	-- after you fill it in. The mode and HighBuff line also needs the mode line above it.
	-- sets.WS["Savage Blade"].ACC = {}
	-- sets.WS["Savage Blade"].HighBuff = {}
	-- sets.WS["Savage Blade"].ACC.HighBuff = {}
	-- sets.WS["Last Stand"].HighBuff = {}
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

-- Called as each action starts. The table it returns is merged over the engine's precast set. This
-- file adds sets.Fold when you use Fold with two busts up, and every hook from here down to
-- status_change_custom adds the job mode's weapons through Job_Mode_Check.
function precast_custom(spell)
	local equipSet = {}
	if spell.english == 'Fold' and buffactive['Bust'] == 2 then
		equipSet = set_combine(equipSet, sets.Fold)
	end
	equipSet = Job_Mode_Check(equipSet)
	return equipSet
end

-- Called while each action is in progress. The table it returns is merged over the engine's midcast
-- set, which is empty for abilities, weaponskills and items.
function midcast_custom(spell)
	local equipSet = {}
	if spell.english == 'Fold' and buffactive['Bust'] == 2 then
		equipSet = set_combine(equipSet, sets.Fold)
	end
	equipSet = Job_Mode_Check(equipSet)
	return equipSet
end

-- Called when each action ends. The table it returns is merged over the idle or engaged set the
-- engine rebuilds.
function aftercast_custom(spell)
	local equipSet = Job_Mode_Check({})
	return equipSet
end

-- Called when a buff is gained or lost. The table it returns is merged over the rebuilt idle or
-- engaged set. If one of your own actions is still in progress, it is still called right away, but
-- the table it returns is not used, and the gear change happens when that action ends.
function buff_change_custom(name, gain)
	local equipSet = Job_Mode_Check({})
	return equipSet
end

-- Called whenever the engine rebuilds the idle or engaged set, which it does after each action, on
-- a buff or status change, and when movement starts or stops. The table it returns is merged over
-- that set.
function choose_set_custom()
	local equipSet = Job_Mode_Check({})
	return equipSet
end

-- Called when the player's status changes, such as engaging, disengaging or resting. The table it
-- returns is merged over the rebuilt idle or engaged set. If one of your own actions is still in
-- progress, the table is not used, and the gear change happens when that action ends.
function status_change_custom(new, old)
	local equipSet = Job_Mode_Check({})
	return equipSet
end

-- Called with any "gs c" command the engine does not handle itself, in lowercase. Use it to add
-- your own commands. The Weapon Mode, Job Mode and Job Mode 2 commands also call it, before they
-- change your gear.
function self_command_custom(command)
end

-- Called when the job file unloads, after the engine releases its keybinds and slot holds.
function user_file_unload()
	--send_command('lua u autocor')
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
