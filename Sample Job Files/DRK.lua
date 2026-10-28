-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: Dark Knight. A sample to copy into your character's folder and fill in.
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

-- The lockstyle set, macro book and macro set that jobsetup applies at load.
LockStylePallet = "15"
MacroBook = "2"
MacroSet = "1"

-- The item that "gs c food" uses.
Food = "Sublime Sushi"

-- When true, the engine uses a Remedy on paralysis or silence and a Holy Water on Doom.
AutoItem = false

-- When true, each load picks a lockstyle set from Lockstyle_List instead of LockStylePallet.
Random_Lockstyle = false

-- The lockstyle sets Random_Lockstyle picks from.
Lockstyle_List = {1,2,6,12}

-- The offense modes this job cycles through, instead of the engine's default TP, ACC and DT. Each
-- mode needs a sets.OffenseMode.<Mode> and a sets.Idle.<Mode> below, and can also have a
-- sets.WS.<Mode>. state.OffenseMode:set picks the mode you start in.
state.OffenseMode:options('DT','TP','ACC','SB','MEVA')
state.OffenseMode:set('DT')

-- Weapon modes. Each one needs a sets.Weapons['<Mode>'] of the same name below.
state.WeaponMode:options('Scythe','Great Sword','Sword','Club','Axe')
state.WeaponMode:set('Scythe')

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

	-- Weapon sets, one per weapon mode above.
	sets.Weapons = {}

	sets.Weapons['Scythe'] = {
		main = gear.anguta,
		sub = gear.utu,
	}

	sets.Weapons['Great Sword'] = {
		main = gear.caladbolg,
		sub = gear.utu,
	}

	sets.Weapons['Sword'] = {
		main = gear.naegling,
		sub = gear.ternionDaggerPlusOne,
	}

	sets.Weapons['Club'] = {
		main = gear.loxoticPlusOne,
		sub = gear.blurredShield,
	}

	sets.Weapons['Axe'] = {
		main = gear.dolichenus,
		sub = gear.ternionDaggerPlusOne,
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active,
	-- engaged or idle.
	sets.Weapons.Shield =
	{
		sub = gear.blurredShield,
	}

	-- ===================================================================================================================
	--		sets.Idle
	-- ===================================================================================================================

	-- Worn while idle. Every action's precast and midcast also start from this set, so any slot
	-- their sets leave empty keeps your idle gear.
	sets.Idle = {
		ammo = gear.staunchPlusOne,
		head = gear.sakpataHead,
		body = gear.sakpataBody,
		hands = gear.sakpataHands,
		legs = gear.sakpataLegs,
		feet = gear.sakpataFeet,
		neck = gear.loricatePlusOne,
		waist = gear.carriers,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.etiolation,
		left_ring = gear.moonlightRing,
		right_ring = gear.gelatinousPlusOne,
		back = gear.drkDA,
	}

	-- Merged over sets.Idle while idle in the matching offense mode. sets.Idle.Resting is merged
	-- over them while resting.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.Resting = {}
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
	})

	-- Worn over the idle set while a Phantom Roll on you stands at 11. It is for the Roller's
	-- Ring, which any job can wear and which gives Refresh +1 and Regain +10 at an 11, for example
	-- left_ring="Roller's Ring". It applies in every offense mode. It is worn only while idle, so
	-- any action swaps it out and it comes back when the action ends. While moving, a ring here
	-- replaces the movement set's ring in the same slot. This file's sets.Movement has no ring, so
	-- either slot works.
	sets.Idle.XIRoll = {}

	-- The TP-mode form, merged after sets.Idle.XIRoll while idle in TP mode.
	sets.Idle.TP.XIRoll = {}

	-- Worn over the idle set while moving and not engaged.
	sets.Movement = {
		legs = gear.carmineLegsPlusOnePathA,
	}

	-- Worn when another character on this machine, running this engine, casts on you. Spell
	-- Received mode must be ON. sets.Cursna_Received is also the Doom set, worn when that mode is
	-- OFF.
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

	-- The ring slot Zodiac Ring goes in when a spell's element matches the day: "right_ring" or
	-- "left_ring".
	Elemental_Bonus_Ring_Slot = "right_ring"

	-- Worn while using a Holy Water or Hallowed Water.
	sets.Holy_Water = {
		neck = gear.nicander,
	}

	-- Subtle blow gear. sets.WS.SB below is this same table, so weaponskills in SB mode wear it.
	-- This caps with Auspice from WHM.
	sets.Subtle_Blow = {
		body = gear.dagonBreastplate,
		feet = gear.sakpataFeet,
		hands = gear.sakpataHands,
		right_ring = gear.niqmaddu,
	}

	-- Maximum HP gear, the base of sets.Midcast['Dread Spikes'] below.
	sets.Max_HP = {
		ammo = gear.staunchPlusOne,
		head = gear.ratriHeadPlusOne,
		body = gear.ratriBodyPlusOne,
		hands = gear.ratriHandsPlusOne,
		legs = gear.ratriLegsPlusOne,
		feet = gear.ratriFeetPlusOne,
		neck = gear.unmovingPlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.tuisto,
		left_ring = gear.moonlightRing,
		right_ring = gear.gelatinousPlusOne,
		back = gear.drkFC,
	}

	-- ===================================================================================================================
	--		sets.OffenseMode
	-- ===================================================================================================================

	-- The engaged base, merged first in every offense mode. The mode's own set is merged over it.
	sets.OffenseMode = {
		ammo = gear.coiste,
		head = gear.flammaHeadPlusTwo,
		body = gear.sakpataBody,
		hands = gear.sakpataHands,
		legs = gear.sakpataLegs,
		feet = gear.flammaFeetPlusTwo,
		neck = gear.vimPlusOne,
		waist = gear.sailfi,
		left_ear = gear.telos,
		right_ear = gear.schere,
		left_ring = gear.moonlightRing,
		right_ring = gear.niqmaddu,
		back = gear.nullShawl,
	}

	sets.OffenseMode.TP = set_combine(sets.OffenseMode, {

	})

	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {
		head = gear.hjarrandiHead,
		body = gear.hjarrandiBody,
		feet = gear.sakpataFeet,
		neck = gear.nullLoop,
		left_ring = gear.lehkoHabhokaRing,
	})

	sets.OffenseMode.ACC = set_combine(sets.OffenseMode,{ })
	-- PDT mode's engaged set. PDT is not offered above, so the engine never reads it. To offer it,
	-- add 'PDT' to state.OffenseMode:options, uncomment this line, and add a sets.Idle.PDT with the
	-- other idle modes.
	-- sets.OffenseMode.PDT = set_combine(sets.OffenseMode, { })
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, { })
	sets.OffenseMode.SB =  set_combine(sets.OffenseMode, {
		head = gear.hjarrandiHead,
		body = gear.hjarrandiBody,
		feet = gear.sakpataFeet,
		neck = gear.nullLoop,
		right_ear = gear.tuisto,
		left_ring = gear.lehkoHabhokaRing,
	})

	-- Worn over the engaged set in every offense mode while Souleater is up. Souleater gear, such
	-- as the Ignominy Burgeonet, raises the share of HP each hit spends on extra damage.
	-- sets.OffenseMode.Souleater = {}

	-- Aftermath sets, merged over the engaged set while the matching Aftermath is up. The engine
	-- uses the strongest active tier that has gear for the current weapon, and a tier set applies
	-- with any weapon. A child named for a weapon mode adds gear for that weapon only, over the
	-- tier set, and is read only when its name is one of the state.WeaponMode options above.
	-- Caladbolg's Aftermath acts on melee attacks, not weaponskills, so the Great Sword mode's
	-- sets are here. Anguta's, for the Scythe mode, are with the weaponskill sets.
	sets.OffenseMode.AM1 = {}
	sets.OffenseMode.AM2 = {}
	sets.OffenseMode.AM3 = {}
	sets.OffenseMode.AM1['Great Sword'] = {}
	sets.OffenseMode.AM2['Great Sword'] = {}
	sets.OffenseMode.AM3['Great Sword'] = {}

	-- Merged over the engaged set while the Dual Wield trait is active and the main weapon is
	-- one-handed. A two-handed or hand-to-hand main skips it.
	sets.DualWield = {}

	-- Treasure Hunter gear. While TH Mode is Tag or Full Time, it is worn for an action aimed at an
	-- untagged monster and while engaged on one. Full Time also keeps it on whenever engaged. TH
	-- Mode starts at None, which never wears it, on every job but Thief.
	sets.TreasureHunter = {
		ammo = gear.perfectEgg,
		legs = gear.volteHose,
		feet = gear.volteBoots,
		waist = gear.chaac,
	}

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Every precast starts from sets.Idle, except a pet command's. For a spell, sets.Precast is
	-- merged over it, then the fast cast set. Any slot left empty keeps your idle gear.
	sets.Precast = {}

	-- Fast cast gear, worn at the start of every spell.
	sets.Precast.FastCast = {
		ammo = gear.sapience, -- 2
		head = gear.carmineHeadPlusOnePathD, -- 14
		body = gear.sacroBody, -- 10
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.odysseanCuissesFC, -- 6
		feet = gear.odysseanGreavesBFC, -- 13
		neck = gear.voltsurge, -- 4
		waist = gear.platinumMoogleBelt,
		left_ear = gear.malignanceEar, -- 4
		right_ear = gear.etiolation, -- 1
		left_ring = gear.weatherspoon, -- 5
		right_ring = gear.kishar, -- 4
		back = gear.drkFC, -- 10
	}

	-- Merged over the fast cast set when you cast Impact. The engine then puts on the Impact cloak
	-- you carry and removes your head piece.
	sets.Precast['Impact'] = {}

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
	sets.Midcast.SIRD = set_combine(sets.Midcast, {})

	-- A building block for sets.Midcast.Dark.Enhancing below. No spell a Dark Knight casts takes
	-- the enhancing set itself, so it is worn only through the set built from it.
	sets.Midcast.Enhancing = {}

	-- Enfeebling magic. The engine merges .MACC or .Duration over it for the spells on its own
	-- lists, such as Poison and Sleep.
	sets.Midcast.Enfeebling = {}
	sets.Midcast.Enfeebling.MACC = {}
	sets.Midcast.Enfeebling.Duration = {}
	-- Merged over the enfeebling set in ACC mode, before the MACC or Duration set, for magic
	-- accuracy gear.
	sets.Midcast.Enfeebling.ACC = {}
	-- Merged over the enfeebling set in DT or MEVA mode. Uncomment one to wear damage taken or
	-- magic evasion gear while you cast, at the cost of the spell's accuracy.
	-- sets.Midcast.Enfeebling.DT = {}
	-- sets.Midcast.Enfeebling.MEVA = {}

	-- Drain and Aspir spells use these two sets instead of the dark magic sets below.
	sets.Midcast.Drain = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Aspir = set_combine(sets.Midcast.Enfeebling, {})

	-- Merged over the Drain or Aspir set when you cast that spell into a burst window of its
	-- element.
	sets.Midcast.Drain.Burst = {}
	sets.Midcast.Aspir.Burst = {}

	-- Merged over the Drain or Aspir set in ACC mode, for magic accuracy gear.
	sets.Midcast.Drain.ACC = {}
	sets.Midcast.Aspir.ACC = {}
	-- Merged over the Drain or Aspir set in DT or MEVA mode. Uncomment one to wear damage taken or
	-- magic evasion gear while you cast, at the cost of what the spell absorbs.
	-- sets.Midcast.Drain.DT = {}
	-- sets.Midcast.Drain.MEVA = {}
	-- sets.Midcast.Aspir.DT = {}
	-- sets.Midcast.Aspir.MEVA = {}

	-- Other dark magic, such as Stun, Bio and the Absorb spells. Absorb spells add .Absorb, Stun
	-- adds .MACC, and Endark and Tractor add .Enhancing. Bio adds the enfeebling Duration set
	-- instead.
	sets.Midcast.Dark = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Dark.MACC = set_combine(sets.Midcast.Enfeebling.MACC, {})
	sets.Midcast.Dark.Absorb = {}
	sets.Midcast.Dark.Enhancing = set_combine(sets.Midcast.Enhancing, {})
	-- Merged over the dark magic set in ACC mode, for magic accuracy gear. The MACC, Absorb or
	-- Enhancing set is merged after it and wins any slot both fill.
	sets.Midcast.Dark.ACC = {}
	-- Merged over the dark magic set in DT or MEVA mode. Uncomment one to wear damage taken or
	-- magic evasion gear while you cast, at the cost of the spell's accuracy.
	-- sets.Midcast.Dark.DT = {}
	-- sets.Midcast.Dark.MEVA = {}

	-- Used instead of the dark magic sets when you cast Dread Spikes: the maximum HP set plus the
	-- Crepuscular Scythe. With the weapon lock at Locked, your weapon mode's pair and the TP on it
	-- stay in hand, so the scythe goes on only while Unlocked.
	sets.Midcast['Dread Spikes'] = set_combine(sets.Max_HP, { main = gear.crepuscularScythe })

	-- Worn on Absorb spells while Dark Seal is up. Dark Seal gear, such as the Fallen's Burgeonet,
	-- lengthens the spell's effect and must be worn during the cast.
	-- sets.Midcast.Dark.Absorb['Dark Seal'] = {}
	-- Worn on Drain spells while Dark Seal is up, for the same bonus.
	-- sets.Midcast.Drain['Dark Seal'] = {}
	-- Worn on Absorb spells while Nether Void is up. Nether Void gear, such as the Heathen's
	-- Flanchard, raises how much the next Absorb or Drain spell absorbs.
	-- sets.Midcast.Dark.Absorb['Nether Void'] = {}
	-- Worn on Drain spells while Nether Void is up, for the same bonus.
	-- sets.Midcast.Drain['Nether Void'] = {}

	-- Worn when you cast an elemental nuke. With no burst set declared, a nuke cast into a burst
	-- window of its element uses this set plus its Burst child set below.
	sets.Midcast.Nuke = {}
	-- Merged over the nuke set in DT or MEVA mode.
	-- sets.Midcast.Nuke.DT = {}
	-- sets.Midcast.Nuke.MEVA = {}

	-- Merged over the nuke set when you cast a nuke into a burst window of its element.
	sets.Midcast.Nuke.Burst = {}

	-- Used instead of the nuke set when you cast Impact. The engine puts on the Crepuscular or
	-- Twilight Cloak you carry and removes your head piece. Uncomment the two lines below once you
	-- fill them in: once declared, the first replaces the nuke set for Impact even if it is empty,
	-- and its burst child set is merged over it when you cast Impact into a burst window of its
	-- element.
	-- sets.Midcast['Impact'] = set_combine(sets.Midcast.Nuke, {})
	-- sets.Midcast['Impact'].Burst = {}

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is merged over sets.Idle for every job ability, then the set named for
	-- the ability is merged over it. Any slot left empty keeps your idle gear.
	sets.JA = {}
	sets.JA["Provoke"] = sets.Enmity
	sets.JA["Blood Weapon"] = {}
	sets.JA["Souleater"] = {}
	sets.JA["Arcane Circle"] = {}
	sets.JA["Weapon Bash"] = {}
	sets.JA["Nether Void"] = {}
	sets.JA["Arcane Crest"] = {}
	sets.JA["Scarlet Delirium"] = {}
	sets.JA["Soul Enslavement"] = {}
	sets.JA["Consume Mana"] = {}

	-- Worn when you use Last Resort, for "Last Resort" gear such as Ankou's Mantle.
	sets.JA["Last Resort"] = {}

	-- Merged over sets.Idle when you use a Waltz. Waltzes do not use sets.JA.
	sets.Waltz = {}

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- Merged over sets.Idle for every weaponskill. The set named for the weaponskill is merged over
	-- it, then the offense mode's set. Any slot left empty keeps your idle gear.
	sets.WS = {
		ammo = gear.knobkierrie,
		head = gear.nyameHead, -- Need Heathen
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.fotiaNeck,
		waist = gear.fotiaWaist,
		left_ear = gear.moonshadeEarringAcc,
		right_ear = gear.schere,
		left_ring = gear.epimanondas,
		right_ring = gear.niqmaddu,
		back = gear.drkWSD,
	}

	-- Worn on weaponskills in ACC mode, over the set named for the weaponskill. List only the
	-- pieces the mode changes, since every slot named here overrides the weaponskill's own set. A
	-- weaponskill with an ACC set of its own, sets.WS['<name>'].ACC, takes that instead. The other
	-- mode sets work the same way, except that sets.WS.TP is never merged.
	sets.WS.ACC = {}

	-- Weaponskill sets for WSD, CRIT and Multi_Hit modes, which this file does not offer, so the
	-- engine never reads them. To use one as a mode, add its name to state.OffenseMode:options
	-- with its engaged and idle sets, uncomment its line here, and list only the pieces the mode
	-- changes.
	-- sets.WS.WSD = {}
	-- sets.WS.CRIT = {}
	-- sets.WS.Multi_Hit = {}

	sets.WS.SB = sets.Subtle_Blow

	-- Worn on every weaponskill while Souleater is up, for the same bonus.
	-- sets.WS.Souleater = {}

	-- Merged in DT mode after the set named for the weaponskill, so its gear wins, for damage taken
	-- gear. sets.WS.MEVA works the same way in MEVA mode, for magic evasion gear. A weaponskill
	-- with its own DT or MEVA set uses that instead. Every slot here costs some of the
	-- weaponskill's damage, so uncomment a line only once you fill it in.
	-- sets.WS.DT = {}
	-- sets.WS.MEVA = {}

	-- Merged over every weaponskill while Buff Level (Alt+F12) is set to HighBuff, for physical
	-- damage limit gear. At MidBuff, the default, no set is used here. In any offense mode except
	-- TP, the set for that mode and level is merged after it, such as sets.WS.ACC.HighBuff in ACC
	-- mode. A weaponskill's own child sets replace these for that weaponskill, as shown at the end
	-- of this section.
	sets.WS.HighBuff = {}
	sets.WS.ACC.HighBuff = {}

	-- Aftermath sets for weaponskills, merged after the weaponskill's own sets while the matching
	-- Aftermath is up. They work as the engaged Aftermath sets do. Anguta's Aftermath raises the
	-- damage of the skillchains your weaponskills make, so the Scythe mode's sets are here.
	sets.WS.AM1 = {}
	sets.WS.AM2 = {}
	sets.WS.AM3 = {}
	sets.WS.AM1['Scythe'] = {}
	sets.WS.AM2['Scythe'] = {}
	sets.WS.AM3['Scythe'] = {}

	-- Sets named for each weaponskill.
	sets.WS['Catastrophe'] = set_combine(sets.WS, {
		left_ear = gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
	})

	sets.WS['Origin'] = set_combine(sets.WS, {
		right_ear = gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
	})

	sets.WS['Entropy'] = set_combine(sets.WS, {
		ammo = gear.coiste,
		left_ring = gear.metamorphPlusOne,
	})

	sets.WS['Quietus'] = set_combine(sets.WS, {
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
	})

	sets.WS['Cross Reaper'] = set_combine(sets.WS, {
		right_ear = gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
		left_ring = gear.regalRing,
	})

	sets.WS['Insurgency'] = set_combine(sets.WS, {
		right_ear = gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
		left_ring = gear.regalRing,
	})

	sets.WS['Torcleaver'] = set_combine(sets.WS, {
		right_ear = gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
	})

	sets.WS['Fimbulvetr'] = set_combine(sets.WS, {
		right_ear = gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
		left_ring = gear.regalRing,
	})

	sets.WS['Scourge'] = set_combine(sets.WS, {
		left_ear = gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
		left_ring = gear.regalRing,
	})

	sets.WS['Resolution'] = set_combine(sets.WS, {
		neck = gear.abyssalBeadNecklacePlusTwo,
		left_ring = gear.sroda,
	})

	sets.WS['Judgment'] = set_combine(sets.WS, {
		right_ear = gear.thrud,
		neck = gear.abyssalBeadNecklacePlusTwo,
		waist = gear.sailfi,
	})

	-- The Sword mode's and the Axe mode's weaponskills.
	sets.WS['Savage Blade'] = {}
	sets.WS['Decimation'] = {}

	-- Child sets for a single weaponskill, used instead of the general sets.WS ones: one for a
	-- mode, one for HighBuff, and one for the two together. Once declared, each one replaces the
	-- general set for that weaponskill even if it is empty, so only uncomment a line after you fill
	-- it in. The mode and HighBuff line also needs the mode line above it.
	-- sets.WS['Torcleaver'].ACC = {}
	-- sets.WS['Torcleaver'].HighBuff = {}
	-- sets.WS['Torcleaver'].ACC.HighBuff = {}

end

-------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE UNLESS YOU NEED TO MAKE JOB SPECIFIC RULES
-------------------------------------------------------------------------------------------------------------------

-- Called when the subjob changes.
function sub_job_change_custom(new, old)
	-- Typically used to change the macro book or set.
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
