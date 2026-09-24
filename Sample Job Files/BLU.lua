

-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The in-game lockstyle set, macro book and macro set this file applies on load.
LockStylePallet = "11"
MacroBook = "8"
MacroSet = "2"

-- The food "gs c food" uses.
Food = "Sublime Sushi"

-- Use a Remedy for paralysis or silence, and a Holy Water for doom, automatically.
AutoItem = false

-- Pick a random lockstyle from Lockstyle_List on each load, in place of LockStylePallet.
Random_Lockstyle = false

-- Offense modes. TP, ACC and DT are the engine's defaults, and more can be added. Each mode picks its own engaged, idle and weaponskill sets, so each one offered needs a sets.OffenseMode.<Mode> and a sets.Idle.<Mode> below.
state.OffenseMode:options('TP','ACC','DT','PDL','SB','MEVA')

-- The lockstyle sets the random pick chooses from.
Lockstyle_List = {1,2,6,12}

-- The offense mode the file starts in.
state.OffenseMode:set('DT')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

-- Blue magic lists. Each blue spell takes the midcast set of the list that names it. The lists follow what a spell's damage or
-- effect scales with, since those do not share gear. The engine declares the same lists, and these copies replace them, so edit a list here to move a spell.
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
BlueBreath = S { 'Bad Breath', 'Flying Hip Press', 'Frost Breath', 'Heat Breath',
    'Hecatomb Wave', 'Magnetite Cloud', 'Poison Breath', 'Radiant Breath', 'Self-Destruct',
    'Thunder Breath', 'Vapor Spray', 'Wind Breath' }
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
BlueSkill = S { 'Atra. Libations', 'Barrier Tusk', 'Diamondhide', 'Magic Barrier',
    'Metallic Body', 'Occultation', 'Plasma Charge', 'Pyric Bulwark', 'Reactor Cool' }
BlueBuff = S { 'Amplification', 'Animating Wail', 'Battery Charge', 'Carcharian Verve',
    'Cocoon', 'Erratic Flutter', 'Exuviation', 'Fantod', 'Feather Barrier', 'Harden Shell',
    'Memento Mori', 'Mighty Guard', 'Nat. Meditation', 'O. Counterstance', 'Refueling',
    'Regeneration', 'Saline Coat', 'Triumphant Roar', 'Warm-Up', 'Winds of Promy.',
    'Zephyr Mantle' }
BlueHealing = S { 'Healing Breeze', 'Magic Fruit', 'Plenilune Embrace', 'Pollen', 'Restoral',
    'Wild Carrot' }
BlueTank = S { 'Actinic Burst', 'Blank Gaze', 'Demoralizing Roar', 'Frightful Roar',
    'Geist Wall', 'Jettatura', 'Sheep Song', 'Soporific', 'Stinking Gas' }
BlueACC = S { '1000 Needles', 'Absolute Terror', 'Auroral Drape', 'Awful Eye',
    'Blistering Roar', 'Blood Drain', 'Blood Saber', 'Chaotic Eye', 'Cimicine Discharge',
    'Cold Wave', 'Corrosive Ooze', 'Cruel Joke', 'Digest', 'Dream Flower', 'Enervation',
    'Feather Tickle', 'Filamented Hold', 'Infrasonics', 'Light of Penance', 'Lowing',
    'MP Drainkiss', 'Mortal Ray', 'Osmosis', 'Reaving Wind', 'Sandspin', 'Sandspray',
    'Sound Blast', 'Venom Shell', 'Voracious Trunk', 'Yawn' }

-- Weapon modes. Each name needs a matching sets.Weapons entry.
state.WeaponMode:options('Almace','Naegling','Black Halo','Cleave')
state.WeaponMode:set('Almace')

-- Naming JobMode shows it in chat and on the status box.
UI_Name = 'Mode'

-- Job mode. self_command_custom below loads the matching blue magic spell set and macro set when you cycle it.
state.JobMode:options('AoE','Melee')
state.JobMode:set('Melee')

function get_sets()

	-- Weapon sets, one per weapon mode.
	sets.Weapons = {}

	sets.Weapons['Almace'] = {
		main=gear.almace,
		sub = gear.sakpataSword,
	}

	sets.Weapons['Naegling'] = {
		main=gear.naegling,
		sub=gear.zantetsuken,
		--sub={ name="Machaera +2", augments={'TP Bonus +1000',}},
	}

	sets.Weapons['Black Halo'] = {
	    main=gear.maxentius,
		sub=gear.bunzi,
	}

	sets.Weapons['Cleave'] = {
		main = gear.nibiruCudgelPathB,
		sub = gear.nibiruCudgelPathB,
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons.Shield = {
		sub=gear.genmeiShield,
	}

	-- Worn over the idle set when you are put to sleep. Its slots stay held until you wake, and the engine re-dresses nothing else while you sleep.
	-- Put gear here that wakes you, such as a piece that drains HP.
	sets.Weapons.Sleep = {}

	-- Worn whenever you are not engaged. It is also the floor under every action, so a slot an action's sets leave unnamed keeps its idle piece.
	sets.Idle = {
		ammo=gear.staunchPlusOne,
		head=gear.malignanceHead,
		body=gear.hashishinBodyPlusThree,
		hands=gear.hashishinHandsPlusThree,
		legs=gear.hashishinLegsPlusThree,
		feet=gear.hashishinFeetPlusThree,
		neck = gear.loricatePlusOne,
		waist=gear.carriers,
		left_ear=gear.etiolation,
		right_ear = gear.odnowaPlusOne,
		left_ring = gear.stikiniRingPlusOne1, -- +1 Refresh
		right_ring = gear.stikiniRingPlusOne2, -- +1 Refresh
		back = gear.bluDA,
    }
	-- Idle sets for each offense mode, merged over the idle set, and Resting, merged over them while you rest.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
	})

	-- Worn over the idle set while a Phantom Roll on you stands at 11.
	-- It is meant for Roller's Ring, which every job can wear and which grants Refresh +1 and Regain +10 at an 11, e.g. left_ring="Roller's Ring".
	-- This set applies in every offense mode. The TP set below applies only in TP mode and merges after it.
	-- It is worn only while idle, so any action swaps it out, and it comes back when the action ends.
	-- While you move, a ring named here replaces a movement ring in the same slot. This file's sets.Movement names no ring, so either slot is free.
	sets.Idle.XIRoll = {}
	-- The TP mode version, merged after the one above.
	sets.Idle.TP.XIRoll = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = {
		legs = gear.carmineLegsPlusOnePathA,
    }

	-- Worn when another character on this machine, running this engine, starts casting one of these spells on you, while Spell Received mode is ON. sets.Cursna_Received is also the Doom set, worn and held while you are doomed with that mode OFF.
	sets.Cure_Received = {}
	sets.Cursna_Received = {
	    neck=gear.nicander,
	    left_ring = gear.eshmun1,
		right_ring = gear.eshmun2,
		waist=gear.gishdubar,
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
	    neck=gear.nicander,
	}

	-- Not read by the engine. The SB weaponskill set below is this same table.
	sets.Subtle_Blow = {
		neck=gear.bathyPlusOne,
		right_ring = gear.chirichPlusOne2,
	}

	-- Engaged sets. sets.OffenseMode is worn in every offense mode, and the current mode's set merges over it.
	sets.OffenseMode = {
	    ammo = gear.coiste,
		head=gear.malignanceHead,
		body=gear.malignanceBody,
		hands=gear.malignanceHands,
		legs=gear.malignanceLegs,
		feet=gear.malignanceFeet,
		neck = gear.mirageStolePlusTwo,
		waist=gear.reiki,
		left_ear=gear.eabani,
		right_ear = gear.hashishinEarringPlusOneDA,
		left_ring=gear.eponas,
		right_ring=gear.lehkoHabhokaRing,
		back = gear.bluDA,
	}

	sets.OffenseMode.TP = {
		ammo = gear.coiste,
		head = gear.gletiHead,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
		waist=gear.windbuffetPlusOne,
		left_ear=gear.crepuscularEar,
		right_ear=gear.telos,
		left_ring=gear.eponas,
		right_ring=gear.lehkoHabhokaRing,
		back = gear.bluDA,
	}

	sets.OffenseMode.DT = set_combine ( sets.OffenseMode.TP, {
		head=gear.malignanceHead,
		body=gear.malignanceBody,
		hands=gear.malignanceHands,
		legs=gear.malignanceLegs,
		feet=gear.malignanceFeet,
		left_ring=gear.defending,
		right_ear = gear.odnowaPlusOne,
	})

	sets.OffenseMode.ACC = set_combine ( sets.OffenseMode.DT,{
	
	})

	sets.OffenseMode.PDL = set_combine ( sets.OffenseMode.DT,{
	
	})

	sets.OffenseMode.MEVA = set_combine ( sets.OffenseMode.DT,{
		ammo = gear.coiste,
		head = gear.gletiHead,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
		neck=gear.warderCharmPlusOne,
		waist=gear.reiki,
		left_ear=gear.eabani,
		right_ear=gear.telos,
		left_ring=gear.chirichRingPlusOne,
		right_ring=gear.lehkoHabhokaRing,
		back = gear.bluDA,
	})

	sets.OffenseMode.SB = set_combine ( sets.OffenseMode,{
		left_ring = gear.chirichPlusOne1,
		right_ring = gear.chirichPlusOne2,
	})

	-- Merged over the engaged set while a dual-wield trait is active.
	sets.DualWield = {
		left_ear=gear.eabani,
		waist=gear.reiki,
	}

	sets.Precast = {}

	-- Fast cast, worn at the start of every spell.
	-- 10% FC from sword
	sets.Precast.FastCast = {
		ammo=gear.impatiens, -- Quick Magic 2
		head = gear.carmineHeadPlusOnePathD, --14
		body = gear.taeonTabardFCB, -- 9
		hands = gear.leylineGlovesFCB, -- 8
		legs=gear.ayanmoLegsPlusTwo, --6
		feet = gear.carmineFeetPlusOnePathD, --8
		neck=gear.voltsurge, -- 4
		waist=gear.witful, -- Quick Magic 3
		left_ear=gear.etiolation, --1
		right_ear=gear.loquacious, --2
		left_ring=gear.lebecheRing, -- Quick Magic 2
		right_ring=gear.weatherspoon, --5 Quick Magic 3
		back = gear.bluFCSird, --10
	} -- 79 and 10% Quick Magic

	-- Merged over the fast-cast set for blue magic.
	sets.Precast.BlueMagic = set_combine (sets.Precast.FastCast, {
		body=gear.hashishinBodyPlusThree, -- 16
	})

	-- Job abilities. sets.JA is worn for every job ability, and the set named for the ability merges over it.
	sets.JA = {}
	sets.JA["Azure Lore"] = {}
	sets.JA["Chain Affinity"] = {}
	sets.JA["Burst Affinity"] = {}
	sets.JA["Diffusion"] = {}
	sets.JA["Efflux"] = {}
	sets.JA["Unbridled Learning"] = {}
	sets.JA["Unbridled Wisdom"] = {}

	-- Dancer abilities from the subjob. Each family set is worn for its abilities, and a child named for the ability merges over it.

	sets.Flourish = set_combine(sets.Idle.DT, {})
	sets.Jig = set_combine(sets.Idle.DT, { })
	sets.Step = set_combine(sets.OffenseMode.DT, {})
	sets.Samba = set_combine(sets.Idle.DT, {})
	sets.Waltz = set_combine(sets.OffenseMode.DT, {
		ammo=gear.yamarang, -- 5
		body = gear.gletiBody, -- 10
		hands=gear.slitherGlovesPlusOne, -- 5
		legs=gear.dashingSubligar, -- 10
	}) -- 30% Potency


	--The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {})

	--Spell interruption rate down. Merged under every midcast except a ranged attack, so any specific set overwrites it.
	sets.Midcast.SIRD = { --Total = 15 merits + 84 gear = 99 - Cap is 105
		ammo=gear.staunchPlusOne, -- 11
		hands = gear.amalricHandsPlusOnePathD, --11
		legs = gear.carmineLegsPlusOnePathA, -- 20
		feet = gear.amalricFeetPlusOnePathA, --16
		waist=gear.ruminationSash, --10
	}

	-- Cure spells. The blue magic healing set below copies it.
	sets.Midcast.Cure = {
		ammo=gear.staunchPlusOne,
		head = gear.nyameHead,
		body=gear.hashishinBodyPlusThree,
		hands = gear.telchineGlovesCEnhDur,
		legs=gear.hashishinLegsPlusThree,
		feet = gear.mediumSabotsCure,
		neck=gear.incanterTorque,
		waist=gear.gishdubar,
		left_ear=gear.mendicantEarring,
		right_ear=gear.hashishinEarringPlusOne,
		left_ring=gear.lebecheRing,
		right_ring=gear.menelausRing,
		back = gear.bluFCSird,
    } --35 %

	-- Enhancing magic. Raise, Reraise and the -na spells take it too, and the blue magic skill set below copies it.
	sets.Midcast.Enhancing = {
	    ammo=gear.staunchPlusOne,
		head = gear.telchineCapBEnhDur,
		body = gear.telchineChasubleBEnhDur,
		hands = gear.telchineGlovesCEnhDur,
		legs = gear.telchineBraconiBEnhDur,
		feet = gear.telchinePigachesBEnhDur,
		neck=gear.incanterTorque,
		waist=gear.olympus,
		left_ear=gear.mimir,
		right_ear = gear.odnowaPlusOne,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
		back = gear.bluFCSird,
	}

	-- Enfeebling magic, dressed for magic accuracy.
	sets.Midcast.Enfeebling = {}

	-- Elemental nukes. The blue magic nuke set below copies it.
	sets.Midcast.Nuke = {
		ammo=gear.pemphredoTathlum,
		head=gear.hashishinHeadPlusThree,
		body=gear.hashishinBodyPlusThree,
		hands=gear.hashishinHandsPlusThree,
		legs=gear.hashishinLegsPlusThree,
		feet=gear.hashishinFeetPlusThree,
		neck=gear.sanctity,
		waist=gear.orpheusWaist,
		left_ear=gear.friomisi,
		right_ear=gear.regalEarring,
		left_ring=gear.shivaRingPlusOne,
		right_ring = gear.metamorphPlusOne,
		back = gear.bluFCSird,
	}

	-- Blue magic. Each spell takes the one subfamily set its list above names, unless it has a set of its own. The engine never wears sets.Midcast.BlueMagic itself.
	-- Physical, Breath and Buff are not declared here. Until you declare one, a spell in that list wears only sets.Midcast, and the engine reports the missing set.
	sets.Midcast.BlueMagic = {}
	sets.Midcast.BlueMagic.Skill = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Nuke = set_combine(sets.Midcast.Nuke, {})
	sets.Midcast.BlueMagic.Healing = set_combine(sets.Midcast.Cure, {})
	sets.Midcast.BlueMagic.Enmity = set_combine(sets.Enmity, {})
	sets.Midcast.BlueMagic.ACC = set_combine(sets.Idle, {
		ammo=gear.pemphredoTathlum,
		head=gear.hashishinHeadPlusThree,
		body=gear.hashishinBodyPlusThree,
		hands=gear.hashishinHandsPlusThree,
		legs=gear.hashishinLegsPlusThree,
		feet=gear.hashishinFeetPlusThree,
		neck=gear.nullLoop,
		waist=gear.nullWaist,
		left_ear=gear.hashishinEarringPlusOne,
		right_ear=gear.telos,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
		back=gear.nullShawl,
	})

	-- The three buff sets below sit on sets.Midcast, where each merges on every spell while its buff is up. sets.Midcast.BlueMagic itself is never worn,
	-- so a child there does nothing. A declared subfamily can carry one instead, such as sets.Midcast.BlueMagic.Nuke['Burst Affinity'], to dress only that subfamily.

	-- Worn on every spell while Chain Affinity is up, and the next physical blue spell uses the buff up. Gear that enhances it, such as Hashishin Kavuk +3 (head), raises that spell's base damage.
	-- sets.Midcast['Chain Affinity'] = {}

	-- Worn on every spell while Burst Affinity is up, and the next magical blue spell uses the buff up. Gear that enhances it, such as Hashishin Basmak +3 (feet), raises that spell's WSC.
	-- sets.Midcast['Burst Affinity'] = {}

	-- Worn on every spell while Efflux is up, and the next physical blue spell uses the buff up. Gear that enhances it, such as Hashishin Tayt +3 (legs), adds to Efflux's TP bonus.
	-- sets.Midcast.Efflux = {}

	-- Sets named for one spell. Each replaces the family set for that spell.
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
		waist=gear.siegel,
		neck=gear.nodens,
	})

    sets.Midcast["Refresh"] = set_combine(sets.Midcast.Enhancing, {
		waist=gear.gishdubar
	})
	
    -- White Wind heals floor(MaxHP/7)*2. Cure potency raises it, but blue magic skill and MND do not,
    -- so favor max HP first and cure potency second.
    sets.Midcast["White Wind"] = {}

    sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, {
	})

	sets.Midcast["Feather Tickle"] = set_combine(sets.Midcast.BlueMagic.ACC, {
		ammo=gear.pemphredoTathlum,
		head = gear.carmineHeadPlusOnePathD,
		body=gear.hashishinBodyPlusThree,
		hands=gear.hashishinHandsPlusThree,
		legs=gear.hashishinLegsPlusThree,
		feet=gear.hashishinFeetPlusThree,
		neck=gear.nullLoop,
		waist=gear.nullWaist,
		left_ear=gear.crepuscularEar,
		right_ear=gear.hashishinEarringPlusOne,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring=gear.weatherspoon,
		back = gear.bluFCSird,
	})

	sets.Midcast["Reaving Wind"] = set_combine(sets.Midcast.BlueMagic.ACC, {
		ammo=gear.pemphredoTathlum,
		head = gear.carmineHeadPlusOnePathD,
		body=gear.hashishinBodyPlusThree,
		hands=gear.hashishinHandsPlusThree,
		legs=gear.hashishinLegsPlusThree,
		feet=gear.hashishinFeetPlusThree,
		neck=gear.nullLoop,
		waist=gear.nullWaist,
		left_ear=gear.crepuscularEar,
		right_ear=gear.hashishinEarringPlusOne,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring=gear.weatherspoon,
		back = gear.bluFCSird,
	})

	sets.Midcast["Cruel Joke"] = set_combine(sets.Midcast.BlueMagic.ACC, {
		ammo=gear.pemphredoTathlum,
		head = gear.carmineHeadPlusOnePathD,
		body=gear.hashishinBodyPlusThree,
		hands=gear.hashishinHandsPlusThree,
		legs=gear.hashishinLegsPlusThree,
		feet=gear.hashishinFeetPlusThree,
		neck=gear.nullLoop,
		waist=gear.nullWaist,
		left_ear=gear.crepuscularEar,
		right_ear=gear.hashishinEarringPlusOne,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring=gear.weatherspoon,
		back = gear.bluFCSird,
	})

	sets.Midcast['Entomb'] = set_combine(sets.Midcast.BlueMagic.Nuke, {
		neck=gear.quanpur,
	})

	-- Weaponskill base, worn for every weaponskill. The set named for the weaponskill merges over it.
	sets.WS = {
		ammo = gear.coiste,
		head=gear.hashishinHeadPlusThree,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.mirageStolePlusTwo,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.ishvara,
		left_ring=gear.eponas,
		right_ring=gear.epimanondas,
		back = gear.bluWSDDt,
	}

	-- Merged in ACC mode after the set named for the weaponskill, so its slots win. Name only the slots ACC mode should change. A weaponskill with an ACC set of its own skips it.
	sets.WS.ACC = {}

	-- Merged over the weaponskill sets in SB mode, the same way.
	sets.WS.SB = sets.Subtle_Blow

	sets.WS['Black Halo'] = {
		ammo = gear.coiste,
		head=gear.hashishinHeadPlusThree,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.mirageStolePlusTwo,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.ishvara,
		left_ring=gear.eponas,
		right_ring=gear.epimanondas,
		back = gear.bluWSDDt,
	}

	sets.WS['Expiacion'] = {
		ammo = gear.coiste,
		head=gear.hashishinHeadPlusThree,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.mirageStolePlusTwo,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.ishvara,
		left_ring=gear.eponas,
		right_ring=gear.epimanondas,
		back = gear.bluWSDDt,
	}

	sets.WS['Chant du Cygne'] = {
		ammo = gear.coiste,
		head = gear.adhemarHeadPlusOnePathA,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
		neck = gear.mirageStolePlusTwo,
		waist=gear.fotiaWaist,
		left_ear=gear.odr,
		right_ear=gear.hashishinEarringPlusOne,
		left_ring=gear.eponas,
		right_ring=gear.lehkoHabhokaRing,
		back = gear.bluDA,
	}

	-- Treasure Hunter gear, worn on an action or melee swing against a monster not yet tagged, and throughout a fight in Full Time mode. It is never worn in None mode, where every job but Thief starts.
	sets.TreasureHunter = {
		waist=gear.chaac,
		body=gear.volteJupon,
		ammo=gear.perfectEgg,
	}

	-- Merged over the blue magic set while Diffusion is up. A spell with a set of its own above does not take it.
	sets.Diffusion = {
	    feet = gear.luhlazaFeetPlusOne,
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
function pretarget_custom(spell,action)

end
-- Gear returned here merges over the engine's precast set for the action. In MEVA mode a weaponskill keeps the magic evasion neck.
function precast_custom(spell)
	local equipSet = {}
	if spell.type == 'WeaponSkill' then
		if state.OffenseMode.value == "MEVA" then
			equipSet = set_combine(equipSet, { neck=gear.warderCharmPlusOne, })
		end
	end
	return equipSet
end
-- Gear returned here merges over the engine's midcast set for the action.
function midcast_custom(spell)
	local equipSet = {}

	return equipSet
end
-- Gear returned here merges over the idle or engaged set worn when an action ends.
function aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end
-- Called when a buff is gained or lost, except while an action is in flight. Gear returned here merges over the idle or engaged set.
function buff_change_custom(name,gain)
	local equipSet = {}

	return equipSet
end
-- Gear returned here merges over every idle and engaged build: after each action, on a buff, status or mode change, and when you start or stop moving.
function choose_set_custom()
	local equipSet = {}

	return equipSet
end
-- Called when your status changes, such as engaging, disengaging or resting. Gear returned here merges over the idle or engaged set that follows.
function status_change_custom(new,old)
	local equipSet = {}

	return equipSet
end
-- Called for a "gs c" command the engine does not handle itself, and for the weapon mode, job mode and job mode 2 commands, which call it before the gear rebuild. The command arrives in lowercase.
-- Here, a job mode change, by key, by gs c jobmode or by gs c jobmode AoE, loads the matching AzureSets spell set, magic for AoE and tp for Melee, and switches the macro set to match.
-- Testing the first word keeps jobmode2 and other commands that merely contain jobmode from triggering it.
function self_command_custom(command)
	if command:match('^(%S+)') == 'jobmode' then
		if state.JobMode.value == 'AoE' then
			send_command('input //aset spellset magic;input /macro book 8;wait .1; input /macro set 2')
		else
			send_command('input //aset spellset tp;input /macro book 8;wait .1; input /macro set 1')
		end
	end
end

-- Called when the job file unloads, after the engine has released its keys and held slots.
function user_file_unload()

end

-- Called when a pet is summoned or lost. Gear returned here merges over the idle or engaged set.
function pet_change_custom(pet,gain)
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
