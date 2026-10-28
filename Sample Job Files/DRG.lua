-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: Dragoon. A sample to copy into your character's folder and fill in.
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

-- The in-game lockstyle set, macro book and macro set this file applies on load.
LockStylePallet = "13"
MacroBook = "2"
MacroSet = "1"

-- The food "gs c food" uses.
Food = "Sublime Sushi"

-- Use a Remedy for paralysis or silence, and a Holy Water for doom, automatically.
AutoItem = false

-- Pick a random lockstyle from Lockstyle_List each time the file loads, instead of LockStylePallet.
Random_Lockstyle = false

-- The lockstyle sets the random pick chooses from.
Lockstyle_List = {1,2,6,12}

-- Offense modes, and the one the file starts in. TP, ACC and DT are the engine's defaults, and more
-- can be added. Each mode picks its own engaged, idle and weaponskill sets, so each one offered
-- needs a sets.OffenseMode.<Mode> and a sets.Idle.<Mode> below.
state.OffenseMode:options('DT','TP','MEVA','ACC','SB','CRIT')
state.OffenseMode:set('DT')

-- Weapon modes. Each name needs a matching sets.Weapons entry.
state.WeaponMode:options('Trishula','Savage Blade','Shining One')
state.WeaponMode:set('Trishula')

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
jobsetup(LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	-- Weapon sets, one per weapon mode.
	sets.Weapons = {}

	sets.Weapons['Trishula'] = {
		main = gear.trishula,
		sub = gear.utu,
	}

	sets.Weapons['Shining One'] = {
		main = gear.shiningOne,
		sub = gear.utu,
	}

	sets.Weapons['Savage Blade'] = {
		main = gear.naegling,
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons.Shield = {}

	-- ===================================================================================================================
	--		sets.Idle
	-- ===================================================================================================================

	-- Worn whenever you are not engaged. Every action except a pet command also starts from this
	-- set, so any slot an action's sets leave empty keeps your idle gear. A pet command, such as
	-- Smiting Breath, starts from the idle or engaged set you have on.
	sets.Idle = {
		ammo = gear.staunchPlusOne,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.loricatePlusOne,
		waist = gear.carriers,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.eabani,
		left_ring = gear.gelatinousPlusOne,
		right_ring = gear.defending,
		back = gear.drgDADt,
	}

	-- Idle sets for each offense mode, merged over the idle set, and Resting, merged over them
	-- while you rest.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.CRIT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
	})
	sets.Idle.Resting = {}

	-- Merged over the idle set while you have a Phantom Roll of 11. It is meant for Roller's Ring,
	-- which every job can wear and which gives Refresh +1 and Regain +10 on an 11, e.g.
	-- left_ring="Roller's Ring". This set applies in every offense mode. The TP set below applies
	-- only in TP mode and is merged after it. It is only worn while idle, so any action swaps it
	-- out, and it comes back when the action ends. While you move, a ring here replaces a movement
	-- ring in the same slot. This file's sets.Movement has no ring, so either slot works.
	sets.Idle.XIRoll = {}
	-- The TP mode version, merged after the one above.
	sets.Idle.TP.XIRoll = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = {
		legs = gear.carmineLegsPlusOnePathA,
	}

	-- Worn when another character on this machine, running this engine, starts one of these spells,
	-- or a waltz, on you, while Spell Received mode is ON. sets.Cursna_Received is also the Doom set,
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

	-- ===================================================================================================================
	--		sets.OffenseMode
	-- ===================================================================================================================

	-- Engaged sets. sets.OffenseMode is worn in every offense mode, and the current mode's set
	-- merges over it.
	sets.OffenseMode = {
		ammo = gear.coiste,
		head = gear.flammaHeadPlusTwo,
		body = gear.hjarrandiBody,
		hands = gear.flammaManopolasPlusTwo,
		legs = gear.nyameLegs,
		feet = gear.flammaFeetPlusTwo,
		neck = gear.vimPlusOne,
		waist = gear.sailfi,
		left_ear = gear.sherida,
		right_ear = gear.peltastEarringPlusOne,
		left_ring = gear.lehkoHabhokaRing,
		right_ring = gear.niqmaddu,
		back = gear.nullShawl,
	}

	sets.OffenseMode.TP = set_combine(sets.OffenseMode, {})

	-- Merged over the TP set while you are engaged with your wyvern out. While a pet is out, the
	-- engaged set also merges your offense mode's child set named after the pet mode. To use it,
	-- add state.JobMode2:options('Wyvern') next to the mode lines at the top of this file, then
	-- uncomment the line below and add one for each offense mode you use. The mode's own set is
	-- then your gear without the wyvern.
	-- sets.OffenseMode.TP.Wyvern = {}

	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {
		head = gear.hjarrandiHead,
		hands = gear.peltastHandsPlusThree,
		legs = gear.gletiLegs,
		feet = gear.peltastFeetPlusThree,
		neck = gear.dragoonCollarPlusTwo,
	})

	sets.OffenseMode.CRIT = set_combine(sets.OffenseMode, {
		head = gear.gletiHead,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
	})

	-- With 29 Auspice 70 Subtle Blow
	sets.OffenseMode.SB =  set_combine(sets.OffenseMode, {
		left_ear = gear.sherida, -- SB II 5
		body = gear.dagonBreastplate, -- SB II 10
		-- Niqmaddu Ring (SB 5) is worn in the right ring slot, from sets.OffenseMode.
		legs = gear.gletiLegs, -- SB 15
		right_ear = gear.peltastEarringPlusOne, -- SB 6
	})

	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {})

	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, {
		ammo = gear.coiste,
		head = gear.peltastHeadPlusThree,
		body = gear.gletiBody,
		hands = gear.peltastHandsPlusThree,
		legs = gear.peltastLegsPlusThree,
		feet = gear.peltastFeetPlusThree,
		neck = gear.dragoonCollarPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.sherida,
		right_ear = gear.peltastEarringPlusOne,
		left_ring = gear.moonlightRing,
		right_ring = gear.niqmaddu,
		back = gear.drgDADt,
	})

	-- Aftermath sets, merged over the engaged set while the matching Aftermath is up. The engine
	-- uses the strongest active tier that has gear for the current weapon. A tier set applies with
	-- any weapon, and a child named for a weapon mode adds gear for that weapon only, such as the
	-- Trishula one below.
	sets.OffenseMode.AM1 = {}
	sets.OffenseMode.AM2 = {}
	sets.OffenseMode.AM3 = {}
	sets.OffenseMode.AM3['Trishula'] = {}

	-- Merged over the engaged set while the Dual Wield trait is active and the main weapon is
	-- one-handed. A two-handed or hand-to-hand main skips it.
	sets.DualWield = {}

	-- Treasure Hunter gear, worn on an action or melee swing against a monster not yet tagged, and
	-- throughout a fight in Full Time mode. It is never worn in None mode, where every job but
	-- Thief starts.
	sets.TreasureHunter = {
		waist = gear.chaac,
	}

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Every precast starts from sets.Idle, except a pet command's. For a spell, sets.Precast is
	-- merged over it, then the fast cast set. Any slot left empty keeps your idle gear.
	sets.Precast = {}

	-- Fast cast, worn at the start of every spell.
	sets.Precast.FastCast = {
		ammo = gear.sapience, --2
		head = gear.carmineHeadPlusOnePathD, --14
		body = gear.taeonTabardFC, --9
		hands = gear.leylineGlovesFCB, --8
		legs = gear.carmineLegsPlusOnePathA,
		feet = gear.carmineFeetPlusOnePathD, --8
		neck = gear.voltsurge, --4
		left_ear = gear.etiolation, --1
		right_ear = gear.tuisto,
		left_ring = gear.gelatinousPlusOne,
		right_ring = gear.weatherspoon, --5
	}

	-- Merged over the fast cast set when you cast blue magic.
	sets.Precast.BlueMagic = {}

	-- Merged over the fast cast set when you cast Utsusemi.
	sets.Precast.Utsusemi = {}

	-- Enmity gear for Provoke. sets.JA["Provoke"] below points to this same set. The engine does
	-- not automatically merge this set into any others.
	sets.Enmity = {}

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- The base for every cast, merged over sets.Idle on every midcast, so any slot it leaves empty
	-- keeps your idle gear.
	sets.Midcast = set_combine(sets.Idle, {})

	-- Spell interruption rate down. Used under every midcast except ranged attacks, so any more
	-- specific set overrides it.
	sets.Midcast.SIRD = {}

	-- Each casting set below can take a child set named for an offense mode, such as
	-- sets.Midcast.Enfeebling.DT. It is merged right over its set in that mode, so the sets merged
	-- after it still win any slot both fill. The DT and MEVA children are for damage taken and
	-- magic evasion gear. They ship commented out: uncomment one once you fill it in.

	-- Under /NIN, ninjutsu you cast on yourself other than Utsusemi, such as Tonko, takes the
	-- enhancing set, and the enfeebling ninjutsu, such as Kurayami or Hojo, take the enfeebling set.
	sets.Midcast.Enhancing = {}
	sets.Midcast.Enfeebling = {}

	-- Merged over the enhancing or enfeebling set in DT or MEVA mode.
	-- sets.Midcast.Enhancing.DT = {}
	-- sets.Midcast.Enhancing.MEVA = {}
	-- sets.Midcast.Enfeebling.DT = {}
	-- sets.Midcast.Enfeebling.MEVA = {}

	-- Blue magic under /BLU. The engine never wears sets.Midcast.BlueMagic itself. Its healing set
	-- is worn when you cast a spell on the engine's blue healing list, such as Magic Fruit.
	sets.Midcast.BlueMagic = {}
	sets.Midcast.BlueMagic.Healing = {}

	-- Merged over the blue healing set in DT or MEVA mode.
	-- sets.Midcast.BlueMagic.Healing.DT = {}
	-- sets.Midcast.BlueMagic.Healing.MEVA = {}

	-- ===================================================================================================================
	--		Pet gear, by when the game reads it
	-- ===================================================================================================================

	-- Gear read at your command. Worn from your pet command until it completes, merged over your
	-- idle or engaged set. The game checks delay and recast gear at the command, and the rest comes
	-- off before your pet acts, so gear for the move itself goes in the sets worn during your pet's
	-- move. The game checks no gear at Smiting Breath or Restoring Breath, so a Dragoon needs no
	-- set here.

	-- Gear read during your pet's move. Worn from the moment your pet readies a move until it
	-- finishes, merged over the idle or engaged set you have on. This is when the game checks the
	-- move's damage, accuracy and potency gear. Your wyvern also uses breaths on its own after your
	-- weaponskills, and those get their gear when it readies them, the same as a breath you
	-- command. These sets go on in this order, each on top of the last: sets.Pet_Midcast for every
	-- pet move, then sets.Pet_Midcast.Wyvern for every wyvern move, then the move's category
	-- (Breath for the six elemental breaths, Healing for Healing Breath I to IV), then the
	-- category's set for your offense mode, such as sets.Pet_Midcast.Breath.ACC in ACC mode, then a
	-- set named for the move. Smiting Breath and Restoring Breath make your wyvern use an elemental
	-- breath and Healing Breath IV, so put their gear in Breath and Healing.
	sets.Pet_Midcast = {}

	-- Merged over sets.Pet_Midcast when your wyvern readies any move.
	sets.Pet_Midcast.Wyvern = {}

	-- The elemental breaths. Their damage depends on the wyvern's current HP and breath bonus gear.
	sets.Pet_Midcast.Breath = {
		--head={ name="Ptero. Armet +3", augments={'Enhances "Deep Breathing" effect',}},
		neck = gear.dragoonCollarPlusTwo,
	}

	-- Merged over the breath set when your wyvern readies an elemental breath in ACC mode, for
	-- breath accuracy gear.
	sets.Pet_Midcast.Breath.ACC = {}

	-- Healing Breath I to IV. The healing depends on the wyvern's maximum HP and breath bonus gear.
	sets.Pet_Midcast.Healing = {
		--head={ name="Ptero. Armet +3", augments={'Enhances "Deep Breathing" effect',}},
		--legs="Vishap Brais +3",
		--feet={ name="Ptero. Greaves +3", augments={'Enhances "Empathy" effect',}},
		neck = gear.dragoonCollarPlusTwo,
	}

	-- Gear read while your pet is out. While you are idle with a pet out, sets.Idle.Pet is merged
	-- over your idle set and its offense mode set, then its own child set for your offense mode. It
	-- only needs the slots it changes, and the rest of your offense mode's idle gear stays on
	-- underneath.
	sets.Idle.Pet = {
		head = gear.peltastHeadPlusThree,
		neck = gear.dragoonCollarPlusTwo,

	}

	-- Gear read while your pet fights. While your pet fights and you are idle,
	-- sets.Idle.Pet.Engaged is merged over sets.Idle.Pet, then its child set for your offense mode.
	-- When you fight too, your offense mode's sets hold the pet gear, so add an offense mode for
	-- fighting alongside your pet. Never name a mode Pet, since sets.Idle.Pet would then be used as
	-- that mode's idle set. Your wyvern engages and disengages with you, so a Dragoon needs no set
	-- here.

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is merged over sets.Idle for every job ability, then the set named for
	-- the ability is merged over it. Any slot left empty keeps your idle gear.
	sets.JA = {}
	sets.JA["Provoke"] = sets.Enmity
	sets.JA['Call Wyvern'] = {
		body = gear.pteroslaverBodyPlusThree,
	}
	sets.JA['Spirit Surge'] = {
		body = gear.pteroslaverBodyPlusThree,
		--legs="Vishap Brais +3",
		--feet={ name="Ptero. Greaves +3", augments={'Enhances "Empathy" effect',}},
		neck = gear.dragoonCollarPlusTwo,
	}
	sets.JA['Ancient Circle'] = {} --legs="Vishap Brais +3"
	sets.JA['Spirit Link'] = {
		--head="Vishap Armet +3",
		hands = gear.peltastHandsPlusThree,
		--feet={ name="Ptero. Greaves +3", augments={'Enhances "Empathy" effect',}},
		neck = gear.dragoonCollarPlusTwo,
	}

	-- Not read by the engine. The jump sets below build on it.
	sets.Jump = {
		ammo = gear.coiste,
		head = gear.hjarrandiHead,
		body = gear.hjarrandiBody,
		hands = gear.flammaManopolasPlusTwo,
		legs = gear.gletiLegs,
		feet = gear.flammaFeetPlusTwo,
		neck = gear.vimPlusOne,
		waist = gear.reiki,
		left_ear = gear.sherida,
		right_ear = gear.telos,
		left_ring = gear.moonlightRing,
		right_ring = gear.crepuscularRing,
		back = gear.drgDADt,
	}

	sets.JA['Jump'] = set_combine(sets.Jump, {})

	sets.JA['High Jump'] = set_combine(sets.Jump, {})

	sets.JA['Spirit Jump'] = set_combine(sets.Jump, {
		legs = gear.peltastLegsPlusThree,
		feet = gear.peltastFeetPlusThree,
	})

	sets.JA['Soul Jump'] = set_combine(sets.Jump, {
		legs = gear.peltastLegsPlusThree,
	})

	sets.JA['Super Jump'] = set_combine(sets.Jump, {
	})

	sets.JA['Angon'] = {
		ammo = gear.angon,
		hands = gear.pteroslaverHandsPlusThree,
	}

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- Weaponskill base, merged over sets.Idle for every weaponskill. The set named for the
	-- weaponskill is merged over it. Any slot left empty keeps your idle gear.
	sets.WS = {
		ammo = gear.knobkierrie,
		head = gear.peltastHeadPlusThree,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.dragoonCollarPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear = gear.peltastEarringPlusOne,
		left_ring = gear.sroda,
		right_ring = gear.niqmaddu,
		back = gear.drgWSDDt,
	}

	-- Merged in ACC mode after the set named for the weaponskill, so its gear wins. Only fill in
	-- the slots ACC mode should change. A weaponskill with its own ACC set uses that instead. CRIT
	-- below works the same way in its mode.
	sets.WS.ACC = {}

	-- WSD is not an offense mode. It is worn only through the weaponskill sets below that are built
	-- from it.
	sets.WS.WSD = set_combine(sets.WS, {
		right_ear = gear.thrud,
		hands = gear.pteroslaverHandsPlusThree,
	})

	-- CRIT only fills in what it changes over sets.WS, so a weaponskill set below that builds on it
	-- combines sets.WS and sets.WS.CRIT.
	sets.WS.CRIT = {
		ammo = gear.coiste,
		head = gear.gletiHead,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
		waist = gear.fotiaWaist,
		left_ring = gear.lehkoHabhokaRing,
	}

	-- Merged in DT mode after the set named for the weaponskill, so its gear wins, for damage taken
	-- gear. sets.WS.MEVA works the same way in MEVA mode, for magic evasion gear. A weaponskill
	-- with its own DT or MEVA set uses that instead. Every slot here costs some of the
	-- weaponskill's damage, so uncomment a line only once you fill it in.
	-- sets.WS.DT = {}
	-- sets.WS.MEVA = {}

	-- Merged over every weaponskill while Buff Level (Alt+F12) is set to HighBuff, for physical
	-- damage limit gear. At MidBuff, the default, no set is used here. In any offense mode except
	-- TP, the set for that mode and level is merged after it, such as sets.WS.ACC.HighBuff in ACC
	-- mode. A weaponskill's own HighBuff set replaces this one for that weaponskill, as in the sets
	-- named for one weaponskill below.
	sets.WS.HighBuff = {
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
	}
	sets.WS.ACC.HighBuff = {}

	-- Aftermath sets for weaponskills, merged after the weaponskill's own sets while the matching
	-- Aftermath is up. They work as the engaged Aftermath sets do.
	sets.WS.AM1 = {}
	sets.WS.AM2 = {}
	sets.WS.AM3 = {}
	sets.WS.AM3['Trishula'] = {}

	-- Sets named for one weaponskill, merged over sets.WS. At HighBuff, each one's HighBuff child
	-- is merged over it in place of sets.WS.HighBuff, even if it is empty, so it carries that
	-- weaponskill's high-buff pieces.
	sets.WS['Impulse Drive'] = set_combine(sets.WS, sets.WS.CRIT, {
		ammo = gear.knobkierrie,
		head = gear.peltastHeadPlusThree,
		right_ear = gear.thrud,
		left_ring = gear.sroda,
		hands = gear.pteroslaverHandsPlusThree,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		waist = gear.sailfi,
	})
	sets.WS['Impulse Drive'].HighBuff = {
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
	}

	sets.WS['Savage Blade'] = set_combine(sets.WS.WSD, {})
	sets.WS['Savage Blade'].HighBuff = {
		right_ear = gear.peltastEarringPlusOne,
		body = gear.peltastBodyPlusThree,
		right_ring = gear.epimanondas,
	}

	sets.WS['Geirskogul'] = set_combine(sets.WS, {
		neck = gear.fotiaNeck,
		left_ear = gear.sherida,
		left_ring = gear.regalRing,
	})
	sets.WS['Geirskogul'].HighBuff = {
		left_ring = gear.epimanondas,
		left_ear = gear.peltastEarringPlusOne,
		body = gear.gletiBody,
		waist = gear.fotiaWaist,
	}

	sets.WS['Drakesbane'] = set_combine(sets.WS, {
		ammo = gear.coiste,
		head = gear.gletiHead,
		body = gear.hjarrandiBody,
		hands = gear.gletiHands,
		legs = gear.peltastLegsPlusThree,
		feet = gear.gletiFeet,
		neck = gear.dragoonCollarPlusTwo,
		left_ring = gear.lehkoHabhokaRing,
	})
	sets.WS['Drakesbane'].HighBuff = {
		ammo = gear.crepuscularPebble,
		body = gear.gletiBody,
		left_ear = gear.thrud,
	}

	sets.WS["Camlann's Torment"] = set_combine(sets.WS, {
		waist = gear.fotiaWaist,
	})
	sets.WS["Camlann's Torment"].HighBuff = {
		left_ear = gear.thrud,
		body = gear.gletiBody,
		legs = gear.gletiLegs,
	}

	sets.WS['Stardiver'] = set_combine(sets.WS, {
		left_ring = gear.lehkoHabhokaRing,
		neck = gear.fotiaNeck,
		hands = gear.peltastHandsPlusThree,
		left_ear = gear.sherida,
		right_ear = gear.moonshadeEarringAcc,
		waist = gear.fotiaWaist,
	})
	sets.WS['Stardiver'].HighBuff = {
		ammo = gear.coiste,
		head = gear.gletiHead,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		neck = gear.dragoonCollarPlusTwo,
		left_ring = gear.sroda,
	}

	sets.WS['Sonic Thrust'] = sets.WS.CRIT
	sets.WS['Raiden Thrust'] = sets.WS.WSD
	sets.WS['Thunder Thrust'] = sets.WS.WSD
	sets.WS['Leg Sweep'] = sets.WS.WSD
	sets.WS['Diarmuid'] = sets.WS.WSD

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

-- Called when your wyvern is called or lost. The table it returns is merged over the rebuilt idle
-- or engaged set. If one of your own actions is still in progress, it is still called, but the
-- table it returns is not used, and the gear change happens when that action ends.
function pet_change_custom(pet,gain)
	local equipSet = {}

	return equipSet
end

-- Called when your wyvern's action ends. The table it returns is merged over the idle or engaged
-- set the engine rebuilds. If one of your own actions is still in progress, it is still called, but
-- the table it returns is not used, and the gear change happens when that action ends.
function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called when your wyvern readies a move. The table it returns is merged over the pet sets, which
-- the engine has already chosen for the move.
function pet_midcast_custom(spell)
	local equipSet = {}

	return equipSet
end
