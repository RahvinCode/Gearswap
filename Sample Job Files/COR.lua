-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The in-game lockstyle set, macro book and macro set this file applies on load.
LockStylePallet = "7"
MacroBook = "18" -- sub_job_change_custom below can switch to a different book for each subjob
MacroSet = "1"

-- The food "gs c food" uses.
Food = "Sublime Sushi"

-- Use a Remedy for paralysis or silence, and a Holy Water for doom, automatically.
AutoItem = false

-- Pick a random lockstyle from Lockstyle_List on each load, in place of LockStylePallet.
Random_Lockstyle = false

-- The lockstyle sets the random pick chooses from.
Lockstyle_List = { 1, 2, 6, 12 }

-- Offense modes, and the one the file starts in. CRIT is added to the engine's defaults for Aftermath Lv.3 critical-hit builds.
-- Each mode offered needs its own sets.OffenseMode.<Mode> and sets.Idle.<Mode> below.
state.OffenseMode:options('TP', 'ACC', 'DT', 'PDL', 'CRIT', 'MEVA', 'SB')
state.OffenseMode:set('TP')

-- Weapon modes. Each name needs a matching sets.Weapons entry.
state.WeaponMode:options('Fomalhaut', 'Death Penalty', 'Savage Blade', 'Aeolian Edge', 'Evisceration')
state.WeaponMode:set('Death Penalty')

-- Naming JobMode shows it in chat and on the status box.
UI_Name = 'TP Mode'

-- Job mode. The hooks below add the sets.Weapons entry named for it, when one exists.
-- Ranged also wears the idle set for the current offense mode while engaged, since a character shooting stands still.
state.JobMode:options('Standard', 'Melee', 'Ranged', 'Subtle Blow')
state.JobMode:set('Standard')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup(LockStylePallet, MacroBook, MacroSet)

-- Warn at precast when your ammunition falls below this count.
Ammo_Warning_Limit = 99

function get_sets()

	-- Bullets by purpose. The engine does not pick among these by offense mode, so a set uses one by naming it, as sets.Idle names Ammo.Bullet.RA.
	-- Ammo.Bullet.RA is also the standard round a weaponskill may fire once its own bullets run out.
	-- These sit above sets.Weapons because the Aeolian Edge weapon set reads Ammo.Bullet.MAG_WS.
	Ammo.Bullet.RA = "Chrono Bullet"  -- TP Ammo
	Ammo.Bullet.WS = "Chrono Bullet"  -- Physical Weaponskills
	Ammo.Bullet.CRIT = "Chrono Bullet" -- Critical Hit Mode
	Ammo.Bullet.PDL = "Chrono Bullet" -- Physical Damage Mode
	Ammo.Bullet.SB = "Chrono Bullet"  -- Subtle Blow Mode
	Ammo.Bullet.MAB = "Living Bullet" -- Magical Weaponskills
	Ammo.Bullet.MACC = "Chrono Bullet" -- Magic Accuracy. No set names it yet. To fire it, add ammo = Ammo.Bullet.MACC to the set that should use it.
	Ammo.Bullet.QD = "Hauksbok Bullet" -- Quick Draw
	Ammo.Bullet.MAG_WS = "Living Bullet" -- Magic Weapon Skills

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

	-- Offhand weapons for the Melee, Subtle Blow and Ranged job modes, added by Job_Mode_Check in the hooks below.
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

	-- Worn over the idle set when you are put to sleep. Its slots stay held until you wake, and the engine re-dresses nothing else while you sleep.
	-- Put gear here that wakes you, such as a piece that drains HP.
	sets.Weapons.Sleep = {
		range = gear.earp,
	}

	-- Worn whenever you are not engaged. It is also the floor under every action, so a slot an action's sets leave unnamed keeps its idle piece.
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
	-- Idle sets for each offense mode, merged over the idle set, and Resting, merged over them while you rest.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.CRIT = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})

	-- Worn over the idle set while a Phantom Roll on you stands at 11.
	-- It is meant for Roller's Ring, which every job can wear and which grants Refresh +1 and Regain +10 at an 11, e.g. left_ring="Roller's Ring".
	-- This set applies in every offense mode. The TP set below applies only in TP mode and merges after it.
	-- It is worn only while idle, so any action swaps it out, and it comes back when the action ends.
	-- While you move, a ring named here replaces a movement ring in the same slot. This file's sets.Movement names right_ring, so left_ring is the free slot.
	sets.Idle.XIRoll = {}
	-- The TP mode version, merged after the one above.
	sets.Idle.TP.XIRoll = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = {
		legs = gear.carmineLegsPlusOnePathA,
		right_ring = gear.defending,
	}

	-- Worn when another character on this machine, running this engine, starts casting one of these spells on you, while Spell Received mode is ON. sets.Cursna_Received is also the Doom set, worn and held while you are doomed with that mode OFF.
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

	-- The ring slot Zodiac Ring goes in when an elemental spell matches the day's element: "right_ring" or "left_ring".
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

	-- Merged over the engaged set while a dual-wield trait is active.
	sets.DualWield = {
		waist = gear.reiki,
		right_ear = gear.eabani,
	}

	-- Engaged sets. sets.OffenseMode is worn in every offense mode, and the current mode's set merges over it.
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

	sets.OffenseMode.PDL = set_combine(sets.OffenseMode, {
		legs = gear.malignanceLegs,
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

	sets.Precast = {}
	-- Ranged attack precast. Snapshot shortens a shot the way fast cast shortens a spell, and Rapid Shot works like quick magic.
	-- Snapshot caps at 70, and job gifts give 10, so gear needs 60. Flurry adds 15% snapshot and Flurry II adds 30%.

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

	-- Merged over the ranged precast set instead while Flurry II or Embrava is up, when 30 snapshot is needed.
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

	--The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {})

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

	sets.Midcast.RA.PDL = set_combine(sets.Midcast.RA, {
		ammo = Ammo.Bullet.PDL,
		left_ring = gear.sroda,
	})

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

	-- Worn for every shot while Triple Shot is up, in any offense mode. It goes on after the mode's shooting set, so every slot it names wins,
	-- including any slot you add to it. The slots it leaves out keep the mode's pieces.
	-- Only these go on after it: a set keyed by an active buff's name under sets.Midcast or the shooting sets, the round the Ammo table names
	-- for the mode, the weapon mode's set and weapon pair while the weapon lock is on, Treasure Hunter gear against an untagged monster,
	-- and what midcast_custom below returns. A hold or lock on a slot keeps that slot as it is.
	sets.Midcast.RA.TripleShot = {
		head = gear.oshosiHeadPlusOne,   -- Missing
		body = gear.chasseurBodyPlusThree, --14
		hands = gear.lanunHandsPlusFour, -- Tripple shot becomes Quad shot
		legs = gear.oshosiLegsPlusOne, -- Missing
		feet = gear.oshosiFeetPlusOne, --3
	}                                   --28

	sets.Midcast.Utsusemi = set_combine(sets.Idle, {})

	-- Quick Draw. The engine wears sets.QuickDraw and then the set named for the shot. ACC, DMG and STP are building blocks the shot sets below copy.
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

	-- One set per shot. Fire through Water Shot may also take an obi, sash or cape the engine picks for the day, weather and distance. Light Shot and Dark Shot do not.
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

	-- Job abilities. sets.JA is worn for every job ability, and the set named for the ability merges over it.
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
	sets.JA["Double-Up"] = {
		right_ring = gear.luzaf, -- 16 yalm range
	}

	-- Waltzes from the dancer subjob. A set named for the waltz merges over it.
	sets.Waltz = set_combine(sets.OffenseMode.DT, {
		ammo = gear.yamarang,      -- 5
		hands = gear.slitherGlovesPlusOne, -- 5
		legs = gear.dashingSubligar, -- 10
	})                             -- 20% Potency

	-- Not read by the engine. The precast and midcast hooks below add it on Fold while two busts stand.
	sets.Fold = { hands = gear.lanunHandsPlusFour }

	-- Worn for every Phantom Roll, with the set named for the roll merged over it. Double-Up wears this base set alone.
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

	-- Sets named for each roll. Most are the base set itself, and the rest add the piece that enhances that roll.
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

	-- Weaponskill base, worn for every weaponskill, ranged ones included. The set named for the weaponskill merges over it.
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

	-- Merged over the melee weaponskill sets in CRIT mode. PDL, SB and MEVA below work the same way in their modes.
	sets.WS.CRIT = {}

	-- Merged in ACC mode after the set named for the weaponskill, so its slots win. Name only the slots ACC mode should change. A weaponskill with an ACC set of its own skips it.
	sets.WS.ACC = {}

	-- For physical damage limit when attack is capped.
	sets.WS.PDL = {
		left_ring = gear.sroda,
	}

	sets.WS.SB = sets.Subtle_Blow

	-- MAB is not an offense mode. It is worn only through the magic weaponskill sets below that are built from it.
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

	-- Ranged weaponskill base, merged over sets.WS for Marksmanship weaponskills. The offense mode's set, keyed RA first as in
	-- sets.WS.RA.ACC, merges over it except in TP mode.
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

	-- Ranged mode sets, merged after the set named for the weaponskill the same way. Each names only what its mode changes.
	sets.WS.RA.ACC = {}

	sets.WS.RA.PDL = {
		left_ring = gear.sroda,
		head = gear.ikengaHead,
		legs = gear.ikengaLegs,
		feet = gear.ikengaFeet,
	}

	sets.WS.RA.CRIT = {}

	-- Aftermath sets, merged over the weaponskill sets while that Aftermath level is up. A child keyed by the current weapon mode
	-- refines a level, so the ['Armageddon'] children apply only while a weapon mode of that name is selected.
	sets.WS.AM = {}
	sets.WS.AM1 = {}
	sets.WS.AM2 = {}
	sets.WS.AM3 = {}

	sets.WS.RA.AM = {}
	sets.WS.RA.AM1 = {}
	sets.WS.RA.AM2 = {}
	sets.WS.RA.AM3 = {}
	sets.WS.RA.AM1['Armageddon'] = {}
	sets.WS.RA.AM2['Armageddon'] = {}
	sets.WS.RA.AM3['Armageddon'] = {}

	sets.WS['Aeolian Edge'] = set_combine(sets.WS.MAB, {
		right_ear = gear.moonshadeEarringAcc,
	})

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

	-- Treasure Hunter gear, worn on an action or melee swing against a monster not yet tagged, and throughout a fight in Full Time mode. It is never worn in None mode, where every job but Thief starts.
	sets.TreasureHunter = {
		waist = gear.chaac,
	}
end

-------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE UNLESS YOU NEED TO MAKE JOB SPECIFIC RULES
-------------------------------------------------------------------------------------------------------------------

-- Called when the player's subjob changes.
function sub_job_change_custom(new, old)
	-- A common use is switching the macro book or set.
end

-- Called before each action, after the engine's own checks. Cancel the action here with cancel_spell(). Nothing it returns is used.
function pretarget_custom(spell, action)
end

-- Gear returned here merges over the engine's precast set for the action. This file adds sets.Fold on Fold while two busts stand,
-- and every hook from here to status_change_custom adds the job mode's weapons through Job_Mode_Check.
function precast_custom(spell)
	local equipSet = {}
	if spell.english == 'Fold' and buffactive['Bust'] == 2 then
		equipSet = set_combine(equipSet, sets.Fold)
	end
	equipSet = Job_Mode_Check(equipSet)
	return equipSet
end

-- Gear returned here merges over the engine's midcast set for the action.
function midcast_custom(spell)
	local equipSet = {}
	if spell.english == 'Fold' and buffactive['Bust'] == 2 then
		equipSet = set_combine(equipSet, sets.Fold)
	end
	equipSet = Job_Mode_Check(equipSet)
	return equipSet
end

-- Gear returned here merges over the idle or engaged set worn when an action ends.
function aftercast_custom(spell)
	local equipSet = Job_Mode_Check({})
	return equipSet
end

-- Called when a buff is gained or lost, except while an action is in flight. Gear returned here merges over the idle or engaged set.
function buff_change_custom(name, gain)
	local equipSet = Job_Mode_Check({})
	return equipSet
end

-- Gear returned here merges over every idle and engaged build: after each action, on a buff, status or mode change, and when you start or stop moving.
function choose_set_custom()
	local equipSet = Job_Mode_Check({})
	return equipSet
end

-- Called when your status changes, such as engaging, disengaging or resting. Gear returned here merges over the idle or engaged set that follows.
function status_change_custom(new, old)
	local equipSet = Job_Mode_Check({})
	return equipSet
end

-- Called for a "gs c" command the engine does not handle itself, and for the weapon mode, job mode and job mode 2 commands, which call it before the gear rebuild. The command arrives in lowercase.
function self_command_custom(command)
end

-- Called when the job file unloads, after the engine has released its keys and held slots.
function user_file_unload()
	--send_command('lua u autocor')
end

-- Called when a pet is summoned or lost. Gear returned here merges over the idle or engaged set.
function pet_change_custom(pet, gain)
	local equipSet = {}
	return equipSet
end

-- Called when a pet's action ends. Gear returned here merges over the idle or engaged set.
function pet_aftercast_custom(spell)
	local equipSet = {}
	return equipSet
end

-- Called while a pet's action is in flight. Gear returned here merges over sets.Pet_Midcast and the set named for the action.
function pet_midcast_custom(spell)
	local equipSet = {}
	return equipSet
end
