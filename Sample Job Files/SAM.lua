-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: Samurai. A sample to copy into your character's folder and fill in.
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
LockStylePallet = "4"
MacroBook = "10"
MacroSet = "1"

-- Pick a random lockstyle from Lockstyle_List each time this file loads.
Random_Lockstyle = false

-- The equip sets the random lockstyle picks from.
Lockstyle_List = {1,2,6,12}

-- The food item "gs c food" uses.
Food = "Sublime Sushi"

-- Use a Remedy on paralysis or silence, and a Holy Water on doom, automatically.
AutoItem = false

-- The offense modes this file offers. The engine's defaults are TP, ACC and DT.
-- Every mode offered here needs both a sets.OffenseMode.<Mode> entry and a sets.Idle.<Mode> entry.
-- The engine warns in chat each time it looks for a missing one.
state.OffenseMode:options('TP','ACC','DT','SB') -- ACC mode changes both the engaged and the weaponskill sets

-- The offense mode to start in.
state.OffenseMode:set('DT')

-- The weapon modes, each naming a sets.Weapons entry below, and the one to start in.
state.WeaponMode:options('Masamune', 'Dojikiri', 'Shining One', 'Yoichinoyumi', 'Soboro')
state.WeaponMode:set('Masamune')

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

function get_sets()

	-- One weapon set per weapon mode, keyed by the mode's name.

	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	sets.Weapons['Dojikiri'] = {
		main = gear.dojikiriYasutsuna,
		sub = gear.utu,
	}

	sets.Weapons['Masamune'] = {
		main = gear.masamune,
		sub = gear.utu,
	}

	sets.Weapons['Yoichinoyumi'] = {
		main = gear.dojikiriYasutsuna,
		sub = gear.utu,
		range = gear.yoichinoyumi,
		ammo = gear.yoichiArrow,
	}

	sets.Weapons['Soboro'] = {
		main = gear.soboroSukehiro,
		sub = gear.utu,
	}

	sets.Weapons['Shining One'] = {
		main = gear.shiningOne,
		sub = gear.utu,
	}

	-- Worn in the offhand, idle or engaged, whenever the main is one-handed and no dual-wield trait
	-- is active.
	sets.Weapons.Shield = {}

	-- The arrow the ranged sets below name.
	Ammo.RA = "Yoichi's Arrow"

	-- ===================================================================================================================
	--		sets.Idle
	-- ===================================================================================================================

	-- Worn while idle. Every precast and midcast also starts from this set, so any slot an action's
	-- set leaves empty keeps your idle gear.
	sets.Idle = {
		ammo = gear.staunchPlusOne,
		head = gear.nyameHead,
		body = gear.adamantiteArmor,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.warderCharmPlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.sanareEarring,
		right_ear = gear.odnowaPlusOne,
		left_ring = gear.lehkoHabhokaRing,
		right_ring = gear.shadowRing,
		back = gear.nullShawl,
	}

	-- Idle sets per offense mode, merged over sets.Idle in the matching mode. sets.Idle.Resting is
	-- merged while you rest.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.Resting = {}

	-- Idle sets for PDT and MEVA, which this file does not offer. The engine reads one only once
	-- its mode is added to state.OffenseMode:options above with a sets.OffenseMode set of the same
	-- name. Then uncomment its lines.
	-- sets.Idle.PDT = set_combine(sets.Idle, {})
	-- sets.Idle.MEVA = set_combine(sets.Idle, {
	-- 	neck = gear.warderCharmPlusOne,
	-- 	waist = gear.carriers,
	-- })

	-- Worn over the idle set while a Phantom Roll on you stands at 11.
	-- It is meant for the Roller's Ring, which every job can wear and which gives Refresh +1 and
	-- Regain +10 at an 11, e.g. right_ring="Roller's Ring".
	-- This set applies in every offense mode. sets.Idle.TP.XIRoll applies in TP mode only and is
	-- merged after it.
	-- It is worn only while idle, so any action swaps it out and it comes back when the action
	-- ends.
	-- While you move, a ring named here replaces the movement set's ring in the same slot. This
	-- file's sets.Movement names left_ring, so right_ring is the free slot.
	sets.Idle.XIRoll = {}
	-- The TP mode form of sets.Idle.XIRoll, merged after it.
	sets.Idle.TP.XIRoll = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = {
		left_ring = gear.gelatinousPlusOne,
		feet = gear.danzoSuneAte
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

	-- Subtle Blow gear. The engine does not automatically merge this set into any others. It is
	-- built into the SB engaged set and worn as the SB weaponskill set below. 10 + 19 for Auspice
	sets.Subtle_Blow = {
		body = gear.dagonBreastplate, -- SB II 10
		legs = gear.mpacaLegs, -- SB II 5
		left_ring = gear.niqmaddu, -- SB II 5
		head = gear.kendatsubaHeadPlusOne,  -- 8
		hands = gear.kendatsubaHandsPlusOne, -- 8
		feet = gear.kendatsubaFeetPlusOne, -- 8
		right_ear = gear.schere, -- 3
		right_ring = gear.chirichRingPlusOne, -- 10
		waist = gear.sarissaphoroi, -- 5
		--neck="Bathy Choker +1", -- 11 Not needed if using Pukatrice Eggs
	}

	-- ===================================================================================================================
	--		sets.OffenseMode
	-- ===================================================================================================================

	-- The engaged base, worn in every offense mode. The set named for the current mode is merged
	-- over it, and the mode sets below start from a copy of it.
	sets.OffenseMode = {
		ammo = gear.coiste,
		head = gear.kasugaHeadPlusTwo,
		body = gear.kasugaBodyPlusThree,
		hands = gear.mpacaHands,
		legs = gear.kasugaLegsPlusTwo,
		feet = gear.mpacaFeet,
		neck = gear.samuraiNodowaPlusTwo,
		waist = gear.ioskehaBeltPlusOne,
		left_ear = gear.kasugaEarringPlusOneWSD,
		right_ear = gear.schere,
		left_ring = gear.niqmaddu,
		right_ring = gear.chirichRingPlusOne,
		back = gear.nullShawl,
	}

	-- TP mode: the base with these slots changed.
	sets.OffenseMode.TP = set_combine(sets.OffenseMode, {

	})

	-- DT mode: the base with these slots changed.
	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {
		head = gear.kasugaHeadPlusTwo,
		hands = gear.mpacaHands,
	})

	-- ACC mode: the base with these slots changed.
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {

	})

	-- SB mode: the base with the Subtle Blow set over it. Both wear Schere Earring in the right
	-- ear, as SB weaponskills do, so no earring changes ear.
	-- Subtle Blow caps at 75 in total, and at 50 for each of SB and SB II.
	sets.OffenseMode.SB = set_combine(sets.OffenseMode, sets.Subtle_Blow, {

	})

	-- Worn over the engaged set in every offense mode while Seigan is up, and its slots win over
	-- the mode set.
	-- Kasuga Kabuto adds Counter under Seigan while Third Eye is down. Treasure Hunter gear still
	-- takes its slots whenever your TH mode wears it.
	sets.OffenseMode.Seigan = {
		head = gear.kasugaHeadPlusTwo,
		body = gear.kasugaBodyPlusThree,
	}
	-- Worn while engaged with both Seigan and Third Eye up, merged after the Seigan set. Sakonji
	-- Haidate add Counter under Third Eye. Uncomment it to use it.
	-- sets.OffenseMode.Seigan['Third Eye'] = {
		--legs={ name="Sakonji Haidate +3", augments={'Enhances "Shikikoyo" effect',}},
	-- }

	-- Aftermath sets, merged over the engaged set while the matching Aftermath is up. The engine
	-- uses the strongest active tier that has gear for the current weapon, and a tier set applies
	-- with any weapon. A child named for a weapon mode adds gear for that weapon only, over the
	-- tier set, and is read only when its name is one of the state.WeaponMode options above.
	-- Masamune's Aftermath acts on melee attacks, not weaponskills, so its sets are here.
	-- Dojikiri Yasutsuna's are with the weaponskill sets, and Yoichinoyumi's with the ranged sets.
	sets.OffenseMode.AM1 = {}
	sets.OffenseMode.AM2 = {}
	sets.OffenseMode.AM3 = {}
	sets.OffenseMode.AM1['Masamune'] = {}
	sets.OffenseMode.AM2['Masamune'] = {}
	sets.OffenseMode.AM3['Masamune'] = {}

	-- Treasure Hunter gear. In every TH mode but None, it is worn on the action that tags a monster
	-- and while engaged on an untagged one. Full Time also wears it whenever you are engaged. Every
	-- job but Thief starts in None.
	sets.TreasureHunter = {
		ammo = gear.perfectEgg,
		body = gear.volteJupon,
		waist = gear.chaac,
	}

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Every precast starts from sets.Idle, except a pet command's. For a spell or a ranged attack,
	-- sets.Precast is merged over it, then the fast cast set for a spell or sets.Precast.RA for a
	-- ranged attack. Any slot left empty keeps your idle gear.
	sets.Precast = {}

	-- Snapshot caps at 70. Rapid Shot works like Quick Magic, and Snapshot works like fast cast.

	-- The True Shot sweet spot, where ranged attacks and weaponskills deal more damage. Monster
	-- size changes these distances.
		-- Gun ~6.5 yalms
		-- Short Bow ~8.6 yalms
		-- Crossbow ~10.7 yalms
		-- Long Bow ~ 11.8 yalms

	-- Flurry is 15% Snapshot
	-- Flurry II 30% Snapshot

	-- Ranged attack precast, where snapshot gear goes.
	sets.Precast.RA = set_combine(sets.Precast, {
		ammo = Ammo.RA,
		head = gear.acroHelmRapidShot,
		body = gear.acroSurcoatRapidShot,
		hands = gear.acroGauntletsRapidShot,
		legs = gear.acroBreechesRapidShot,
		feet = gear.acroLeggingsRapidShot,
		neck = gear.unmovingPlusOne,
		waist = gear.yemaya,
		left_ear = gear.tuisto,
		right_ear = gear.odnowaPlusOne,
		left_ring = gear.gelatinousPlusOne,
		right_ring = gear.crepuscularRing,
		back = gear.samSnapshot,
	})

	-- sets.Precast.RA has no child sets for offense modes. Flurry and Flurry_II are the only child
	-- sets it uses.

	-- Merged over the ranged precast while Flurry is up. It needs 55 Snapshot.
	sets.Precast.RA.Flurry = set_combine(sets.Precast.RA, {

	})

	-- Merged over the ranged precast while Flurry II or Embrava is up. It needs 40 Snapshot.
	sets.Precast.RA.Flurry_II = set_combine( sets.Precast.RA.Flurry, {

	})

	-- Worn at the start of every spell. Fast cast gear goes here.
	sets.Precast.FastCast = set_combine (sets.Idle.DT, {
		ammo = gear.sapience,
		hands = gear.leylineGlovesFCB,
		neck = gear.voltsurge,
		waist = gear.tempusFugit,
		left_ear = gear.etiolation,
		right_ear = gear.loquacious,
		left_ring = gear.prolix,
	})

	-- Merged over the fast cast set when you cast Utsusemi.
	sets.Precast.Utsusemi = {}

	-- Enmity gear for Provoke. sets.JA["Provoke"] below points to this same set. The engine does
	-- not automatically merge this set into any others.
	sets.Enmity = set_combine (sets.Idle.DT, {
		ammo = gear.sapience, -- 2
		neck = gear.warderCharmPlusOne, -- 1-8
		left_ear = gear.friomisi, --2
		right_ear = gear.crypticEarring, -- 4
		waist = gear.kasiriBelt, -- 3
		left_ring = gear.petrov, -- 4
		right_ring = gear.eihwazRing, -- 5
	})

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- The base for every cast, merged over sets.Idle on every midcast, so any slot it leaves empty
	-- keeps your idle gear.
	sets.Midcast = set_combine (sets.Idle.DT, { })

	-- Spell interruption rate down. Used under every midcast except ranged attacks, so any more
	-- specific set overrides it.
	sets.Midcast.SIRD = {}

	-- Merged over the spell interruption set when you cast Utsusemi from your ninja subjob.
	sets.Midcast.Utsusemi = {}
	-- Merged over the Utsusemi set in DT or MEVA mode.
	-- sets.Midcast.Utsusemi.DT = {}
	-- sets.Midcast.Utsusemi.MEVA = {}

	-- Ranged attack midcast. In every offense mode but TP, the set named for the mode is merged
	-- over it.
	sets.Midcast.RA = set_combine(sets.Midcast, {
		ammo = Ammo.RA,
		head = gear.sakonjiHeadPlusThree,
		body = gear.kasugaBodyPlusThree,
		hands = gear.volteMittens,
		legs = gear.wakidoLegsPlusThree,
		feet = gear.volteSpats,
		neck = gear.samuraiNodowaPlusTwo,
		waist = gear.yemaya,
		left_ear = gear.telos,
		right_ear = gear.crepuscularEar,
		right_ring = gear.crepuscularRing,
		left_ring = gear.ilabrat,
		back = gear.samSTP,
	})

	-- ACC mode, for high accuracy.
	sets.Midcast.RA.ACC = set_combine(sets.Midcast.RA, {

	})

	-- CRIT mode, for a critical hit build. CRIT is not offered above, so the engine never reads
	-- this set. To use it, add 'CRIT' to the offense modes above with its engaged and idle sets,
	-- then uncomment it.
	-- sets.Midcast.RA.CRIT = set_combine(sets.Midcast.RA, {})

	-- Ranged Aftermath sets, merged over the ranged midcast while the matching Aftermath is up. A
	-- child named for a weapon mode adds gear for that weapon only, over the tier set.
	-- Yoichinoyumi's Aftermath works on your shots, so the Yoichinoyumi mode's sets are here.
	sets.Midcast.RA.AM1 = {}
	sets.Midcast.RA.AM2 = {}
	sets.Midcast.RA.AM3 = {}
	sets.Midcast.RA.AM1['Yoichinoyumi'] = {}
	sets.Midcast.RA.AM2['Yoichinoyumi'] = {}
	sets.Midcast.RA.AM3['Yoichinoyumi'] = {}

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is merged over sets.Idle for every job ability, then the set named for
	-- the ability is merged over it. Any slot left empty keeps your idle gear.
	sets.JA = {}
	sets.JA["Meikyo Shisui"] = {}
	sets.JA["Provoke"] = sets.Enmity

	-- Merged over sets.Idle when you use a Waltz. Waltzes do not use sets.JA.
	sets.Waltz = {}

	sets.JA["Third Eye"] = {}
	sets.JA["Meditate"] = {
		head = gear.wakidoHeadPlusThree,
		hands = gear.sakonjiHandsPlusThree,
		back = gear.samSTPDt,
	}
	sets.JA["Warding Circle"] = {
		head = gear.wakidoHeadPlusThree,
	}
	sets.JA["Shikikoyo"] = {}
	sets.JA["Hasso"] = {}
	sets.JA["Seigan"] = {}
	sets.JA["Sengikori"] = {}
	sets.JA["Hamanoha"] = {}
	sets.JA["Hagakure"] = {}
	sets.JA["Konzen-ittai"] = {}
	sets.JA["Yaegasumi"] = {}

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- The base for every weaponskill, merged over sets.Idle. A set named for the weaponskill is
	-- merged over it. Any slot left empty keeps your idle gear.
	sets.WS = {
		ammo = gear.knobkierrie,
		head = gear.mpacaHead,
		body = gear.nyameBody,
		hands = gear.kasugaHandsPlusTwo,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.samuraiNodowaPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear = gear.thrud,
		left_ring = gear.niqmaddu,
		right_ring = gear.epimanondas,
		back = gear.samWSD,
	}

	-- Merged over sets.WS on every ranged weaponskill, in every offense mode, so the weaponskill
	-- fires the arrow.
	-- Without it the ammo slot keeps sets.WS's ammo, and the engine cancels a ranged weaponskill
	-- unless you carry at least two of what that slot holds.
	sets.WS.RA = { ammo = Ammo.RA }

	-- Weaponskill sets for each offense mode, merged after the set named for the weaponskill so
	-- their gear wins. Never merged in TP mode. Each only fills in the slots its mode changes, so a
	-- weaponskill's own set keeps every other slot. A weaponskill's own mode set, such as
	-- sets.WS['Tachi: Fudo'].ACC, is used instead of these where it exists.
	sets.WS.ACC = {}

	sets.WS.SB = sets.Subtle_Blow

	-- A building block for magical weaponskills. MAB is not an offense mode, so this set is worn
	-- only through the sets built from it.
	sets.WS.MAB = set_combine(sets.WS, {
		waist = gear.orpheusWaist,
		left_ear = gear.friomisi,
		neck = gear.fotiaNeck,
		waist = gear.orpheusWaist,
		left_ear = gear.friomisi,
		-- back={ name="Smertrios's Mantle", augments={'STR+20','Mag. Acc+20 Mag. Dmg.+20','Mag. Acc.+10','"Mag.Atk.Bns."+10','Damage taken-5%',}},
	})

	-- CRIT mode. CRIT is not offered above, so the engine never reads this set. To use it, add
	-- 'CRIT' to the offense modes above with its engaged and idle sets, then uncomment its lines.
	-- sets.WS.CRIT = {
	-- 	right_ear = gear.schere,
	-- 	ammo = gear.coiste,
	-- }

	-- Merged in DT mode after the set named for the weaponskill, so its gear wins, for damage taken
	-- gear. A weaponskill with its own DT set uses that instead. Every slot here costs some of the
	-- weaponskill's damage, so uncomment it only once you fill it in.
	-- sets.WS.DT = {}

	-- Merged over every weaponskill while Buff Level (Alt+F12) is set to HighBuff, for physical
	-- damage limit gear. At MidBuff, the default, no set is used here. In any offense mode except
	-- TP, the set for that mode and level is merged after it, such as sets.WS.ACC.HighBuff in ACC
	-- mode. A ranged weaponskill uses sets.WS.RA.HighBuff instead of sets.WS.HighBuff. A
	-- weaponskill's own child sets replace these for that weaponskill, as shown at the end of this
	-- section.
	sets.WS.HighBuff = {}
	sets.WS.ACC.HighBuff = {}
	sets.WS.RA.HighBuff = {}

	-- Aftermath sets for weaponskills, merged after the weaponskill's own sets while the matching
	-- Aftermath is up. They work as the engaged Aftermath sets do. Dojikiri Yasutsuna's Aftermath
	-- raises the damage of the skillchains your weaponskills make, so the Dojikiri mode's sets are
	-- here.
	sets.WS.AM1 = {}
	sets.WS.AM2 = {}
	sets.WS.AM3 = {}
	sets.WS.AM1['Dojikiri'] = {}
	sets.WS.AM2['Dojikiri'] = {}
	sets.WS.AM3['Dojikiri'] = {}

	-- Sets named for one weaponskill, merged over sets.WS.
	sets.WS["Tachi: Enpi"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Hobaku"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Jinpu"] = set_combine (sets.WS.MAB, {})
	sets.WS["Tachi: Goten"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Kagero"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Koki"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Yukikaze"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Gekko"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Kasha"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Rana"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Ageha"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Fudo"] = set_combine (sets.WS, {})
	sets.WS["Tachi: Shoha"] = set_combine (sets.WS,
	{
		right_ring = gear.sroda,
		legs = gear.mpacaLegs,
		feet = gear.kasugaFeetPlusTwo,
	})

	-- The Shining One mode's weaponskill.
	sets.WS["Impulse Drive"] = {}

	-- The Yoichinoyumi mode's weaponskill. It is merged over sets.WS.RA, so any slot it leaves
	-- empty, the arrow included, keeps that set's piece.
	sets.WS["Namas Arrow"] = {}

	-- Child sets for a single weaponskill, used instead of the general sets.WS ones: one for a
	-- mode, one for HighBuff, and one for the two together. Once declared, each one replaces the
	-- general set for that weaponskill even if it is empty, so only uncomment a line after you fill
	-- it in. The mode and HighBuff line also needs the mode line above it.
	-- sets.WS["Tachi: Fudo"].ACC = {}
	-- sets.WS["Tachi: Fudo"].HighBuff = {}
	-- sets.WS["Tachi: Fudo"].ACC.HighBuff = {}

	-- Buff sets for weaponskills. Uncomment one to use it. Each is worn on every weaponskill while
	-- its buff is up, and its slots win over the set named for the weaponskill.
	-- Worn on every weaponskill while Meikyo Shisui is up. Sakonji Sune-Ate strengthen Meikyo
	-- Shisui and must be worn for the weaponskill itself.
	-- sets.WS['Meikyo Shisui'] = {}
	-- Worn on the next weaponskill while Sekkanoki is up. With Kasuga Kote, that weaponskill also
	-- scales with the TP Sekkanoki leaves you.
	-- sets.WS.Sekkanoki = {}
	-- Worn on the next weaponskill while Sengikori is up. Kasuga Sune-Ate raise the bonus Sengikori
	-- gives the skillchain or magic burst that follows.
	-- sets.WS.Sengikori = {}
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
