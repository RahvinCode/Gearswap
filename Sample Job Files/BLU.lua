-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: Blue Mage. A sample to copy into your character's folder and fill in.
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
LockStylePallet = "11"
MacroBook = "8"
MacroSet = "2"

-- The food "gs c food" uses.
Food = "Sublime Sushi"

-- Use a Remedy for paralysis or silence, and a Holy Water for doom, automatically.
AutoItem = false

-- Pick a random lockstyle from Lockstyle_List each time the file loads, instead of LockStylePallet.
Random_Lockstyle = false

-- The lockstyle sets the random pick chooses from.
Lockstyle_List = {1,2,6,12}

-- Offense modes. TP, ACC and DT are the engine's defaults, and more can be added. Each mode picks
-- its own engaged, idle and weaponskill sets, so each one offered needs a sets.OffenseMode.<Mode>
-- and a sets.Idle.<Mode> below. MB is for bursting with blue magic: in it every spell that takes
-- the blue magic nuke set also wears sets.Midcast.BlueMagic.Nuke.MB.
state.OffenseMode:options('TP','ACC','DT','SB','MEVA','MB')

-- The offense mode the file starts in.
state.OffenseMode:set('DT')

-- Weapon modes. Each name needs a matching sets.Weapons entry.
state.WeaponMode:options('Almace','Naegling','Black Halo','Cleave')
state.WeaponMode:set('Almace')

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

-- Naming JobMode shows it in chat and on the status box.
UI_Name = 'Mode'

-- Job mode, and the one to start in. Changing it loads a blue magic spell set through the
-- AzureSets addon and switches the macro set, by self_command_custom below: AoE loads the magic
-- spell set and macro set 2, and Melee the tp spell set and macro set 1.
state.JobMode:options('AoE','Melee')
state.JobMode:set('Melee')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	-- Weapon sets, one per weapon mode.
	sets.Weapons = {}

	sets.Weapons['Almace'] = {
		main = gear.almace,
		sub = gear.sakpataSword,
	}

	sets.Weapons['Naegling'] = {
		main = gear.naegling,
		sub = gear.zantetsuken,
		--sub={ name="Machaera +2", augments={'TP Bonus +1000',}},
	}

	sets.Weapons['Black Halo'] = {
		main = gear.maxentius,
		sub = gear.bunzi,
	}

	sets.Weapons['Cleave'] = {
		main = gear.nibiruCudgelPathB,
		sub = gear.nibiruCudgelPathB,
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons.Shield = {
		sub = gear.genmeiShield,
	}

	-- Merged over the idle set when you are put to sleep. The slots it names stay locked until you
	-- wake up. Put gear here that wakes you, such as a piece that drains HP.
	sets.Weapons.Sleep = {}

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
		ammo = gear.staunchPlusOne,
		head = gear.malignanceHead,
		body = gear.hashishinBodyPlusThree,
		hands = gear.hashishinHandsPlusThree,
		legs = gear.hashishinLegsPlusThree,
		feet = gear.hashishinFeetPlusThree,
		neck = gear.loricatePlusOne,
		waist = gear.carriers,
		left_ear = gear.etiolation,
		right_ear = gear.odnowaPlusOne,
		left_ring = gear.stikiniRingPlusOne1, -- +1 Refresh
		right_ring = gear.stikiniRingPlusOne2, -- +1 Refresh
		back = gear.bluDA,
	}
	-- Idle sets for each offense mode, merged over the idle set, and Resting, merged over them
	-- while you rest.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.Resting = {}
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
	})
	-- MB mode starts from a copy of the DT idle set, so you sit in DT gear between casts.
	sets.Idle.MB = set_combine(sets.Idle.DT, {})

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
		ammo = gear.coiste,
		head = gear.malignanceHead,
		body = gear.malignanceBody,
		hands = gear.malignanceHands,
		legs = gear.malignanceLegs,
		feet = gear.malignanceFeet,
		neck = gear.mirageStolePlusTwo,
		waist = gear.reiki,
		left_ear = gear.eabani,
		right_ear = gear.hashishinEarringPlusOneDA,
		left_ring = gear.eponas,
		right_ring = gear.lehkoHabhokaRing,
		back = gear.bluDA,
	}

	sets.OffenseMode.TP = {
		ammo = gear.coiste,
		head = gear.gletiHead,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
		waist = gear.windbuffetPlusOne,
		left_ear = gear.crepuscularEar,
		right_ear = gear.telos,
		left_ring = gear.eponas,
		right_ring = gear.lehkoHabhokaRing,
		back = gear.bluDA,
	}

	sets.OffenseMode.DT = set_combine ( sets.OffenseMode.TP, {
		head = gear.malignanceHead,
		body = gear.malignanceBody,
		hands = gear.malignanceHands,
		legs = gear.malignanceLegs,
		feet = gear.malignanceFeet,
		left_ring = gear.defending,
		right_ear = gear.odnowaPlusOne,
	})

	sets.OffenseMode.ACC = set_combine ( sets.OffenseMode.DT,{

	})

	sets.OffenseMode.MEVA = set_combine ( sets.OffenseMode.DT,{
		ammo = gear.coiste,
		head = gear.gletiHead,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
		neck = gear.warderCharmPlusOne,
		waist = gear.reiki,
		left_ear = gear.eabani,
		right_ear = gear.telos,
		left_ring = gear.chirichRingPlusOne,
		right_ring = gear.lehkoHabhokaRing,
		back = gear.bluDA,
	})

	sets.OffenseMode.SB = set_combine ( sets.OffenseMode,{
		left_ring = gear.chirichPlusOne1,
		right_ring = gear.chirichPlusOne2,
	})

	-- MB mode starts from a copy of the DT engaged set.
	sets.OffenseMode.MB = set_combine(sets.OffenseMode.DT, {})

	-- Merged over the engaged set while you have the Dual Wield trait and your main weapon is
	-- one-handed.
	sets.DualWield = {
		left_ear = gear.eabani,
		waist = gear.reiki,
	}

	-- Aftermath sets, merged over the engaged set while that level of Aftermath is up. A child
	-- named for a weapon mode adds gear for that weapon alone, so Almace's Aftermath gear goes in
	-- the Almace children, which are not worn once you change to another weapon mode.
	sets.OffenseMode.AM1 = {}
	sets.OffenseMode.AM2 = {}
	sets.OffenseMode.AM3 = {}
	sets.OffenseMode.AM1['Almace'] = {}
	sets.OffenseMode.AM2['Almace'] = {}
	sets.OffenseMode.AM3['Almace'] = {}

	-- Treasure Hunter gear, worn on an action or melee swing against a monster not yet tagged, and
	-- throughout a fight in Full Time mode. It is never worn in None mode, where every job but
	-- Thief starts.
	sets.TreasureHunter = {
		waist = gear.chaac,
		body = gear.volteJupon,
		ammo = gear.perfectEgg,
	}

	-- Enmity gear that the blue magic enmity set and the divine set below are built from. The
	-- engine does not automatically merge this set into any others.
	sets.Enmity = {}

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Every precast starts from sets.Idle, except a pet command's. For a spell, sets.Precast is
	-- merged over it, then the fast cast set. Any slot left empty keeps your idle gear.
	sets.Precast = {}

	-- Fast cast, worn at the start of every spell.
	-- 10% FC from sword
	sets.Precast.FastCast = {
		ammo = gear.impatiens, -- Quick Magic 2
		head = gear.carmineHeadPlusOnePathD, --14
		body = gear.taeonTabardFCB, -- 9
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.ayanmoLegsPlusTwo, --6
		feet = gear.carmineFeetPlusOnePathD, --8
		neck = gear.voltsurge, -- 4
		waist = gear.witful, -- Quick Magic 3
		left_ear = gear.etiolation, --1
		right_ear = gear.loquacious, --2
		left_ring = gear.lebecheRing, -- Quick Magic 2
		right_ring = gear.weatherspoon, --5 Quick Magic 3
		back = gear.bluFCSird, --10
	} -- 79 and 10% Quick Magic

	-- Merged over the fast-cast set for blue magic.
	sets.Precast.BlueMagic = set_combine (sets.Precast.FastCast, {
		body = gear.hashishinBodyPlusThree, -- 16
	})

	-- Merged over the fast cast set when you cast enhancing magic.
	sets.Precast.Enhancing = {}

	-- Merged over the fast cast set when you cast Cure, Curaga or Cura.
	sets.Precast.Cure = {}

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
	sets.Midcast.SIRD = { --Total = 15 merits + 84 gear = 99 - Cap is 105
		ammo = gear.staunchPlusOne, -- 11
		hands = gear.amalricHandsPlusOnePathD, --11
		legs = gear.carmineLegsPlusOnePathA, -- 20
		feet = gear.amalricFeetPlusOnePathA, --16
		waist = gear.ruminationSash, --10
	}

	-- Cure spells. The blue magic healing set below copies it.
	sets.Midcast.Cure = {
		ammo = gear.staunchPlusOne,
		head = gear.nyameHead,
		body = gear.hashishinBodyPlusThree,
		hands = gear.telchineGlovesCEnhDur,
		legs = gear.hashishinLegsPlusThree,
		feet = gear.mediumSabotsCure,
		neck = gear.incanterTorque,
		waist = gear.gishdubar,
		left_ear = gear.mendicantEarring,
		right_ear = gear.hashishinEarringPlusOne,
		left_ring = gear.lebecheRing,
		right_ring = gear.menelausRing,
		back = gear.bluFCSird,
	} --35 %
	-- Merged over the cure set in DT or MEVA mode.
	-- sets.Midcast.Cure.DT = {}
	-- sets.Midcast.Cure.MEVA = {}

	-- Merged over the cure set when you cast a cure on yourself.
	sets.Midcast.Cure.Self = {}

	-- Merged over the cure set when you cast a cure on anyone else, or on yourself under Accession.
	sets.Midcast.Cure.Others = {}

	-- Enhancing magic. Raise, Reraise and the -na spells take it too, and the blue magic skill set
	-- below copies it.
	sets.Midcast.Enhancing = {
		ammo = gear.staunchPlusOne,
		head = gear.telchineCapBEnhDur,
		body = gear.telchineChasubleBEnhDur,
		hands = gear.telchineGlovesCEnhDur,
		legs = gear.telchineBraconiBEnhDur,
		feet = gear.telchinePigachesBEnhDur,
		neck = gear.incanterTorque,
		waist = gear.olympus,
		left_ear = gear.mimir,
		right_ear = gear.odnowaPlusOne,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
		back = gear.bluFCSird,
	}
	-- Merged over the enhancing set in DT or MEVA mode.
	-- sets.Midcast.Enhancing.DT = {}
	-- sets.Midcast.Enhancing.MEVA = {}

	-- Merged over the enhancing set, from your red mage or rune fencer subjob: Phalanx when you
	-- cast Phalanx, Skill for the en-spells, Elemental and Status for the bar spells, and Regen
	-- for a Regen spell.
	sets.Midcast.Phalanx = {}
	sets.Midcast.Enhancing.Skill = {}
	sets.Midcast.Enhancing.Elemental = {}
	sets.Midcast.Enhancing.Status = {}
	sets.Midcast.Regen = {}

	-- Enfeebling magic, dressed for magic accuracy.
	sets.Midcast.Enfeebling = {}
	-- Merged over the enfeebling set in DT or MEVA mode.
	-- sets.Midcast.Enfeebling.DT = {}
	-- sets.Midcast.Enfeebling.MEVA = {}

	-- Divine magic: Flash, from your rune fencer subjob, built on the enmity set.
	sets.Midcast.Divine = set_combine(sets.Enmity, {})
	-- Merged over the divine set in DT or MEVA mode.
	-- sets.Midcast.Divine.DT = {}
	-- sets.Midcast.Divine.MEVA = {}

	-- Elemental nukes. The blue magic nuke set below copies it.
	sets.Midcast.Nuke = {
		ammo = gear.pemphredoTathlum,
		head = gear.hashishinHeadPlusThree,
		body = gear.hashishinBodyPlusThree,
		hands = gear.hashishinHandsPlusThree,
		legs = gear.hashishinLegsPlusThree,
		feet = gear.hashishinFeetPlusThree,
		neck = gear.sanctity,
		waist = gear.orpheusWaist,
		left_ear = gear.friomisi,
		right_ear = gear.regalEarring,
		left_ring = gear.shivaRingPlusOne,
		right_ring = gear.metamorphPlusOne,
		back = gear.bluFCSird,
	}
	-- Merged over the nuke set in DT or MEVA mode.
	-- sets.Midcast.Nuke.DT = {}
	-- sets.Midcast.Nuke.MEVA = {}

	-- Blue magic. The engine sorts each blue spell into one of the sets below by its own lists,
	-- unless the spell has a set of its own. It never uses sets.Midcast.BlueMagic by itself.
	sets.Midcast.BlueMagic = {}

	-- Worn when you cast a physical blue magic spell.
	sets.Midcast.BlueMagic.Physical = {}

	-- Worn when you cast a breath blue magic spell, for HP gear.
	sets.Midcast.BlueMagic.Breath = {}

	-- Worn when you cast a buff on the BlueBuff list, for duration gear. The skill-based buffs,
	-- such as Occultation and Metallic Body, use sets.Midcast.BlueMagic.Skill below instead.
	sets.Midcast.BlueMagic.Buff = {}

	sets.Midcast.BlueMagic.Skill = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Nuke = set_combine(sets.Midcast.Nuke, {})

	-- Merged over the blue nuke set when you cast a magical blue spell under Burst Affinity or
	-- Azure Lore into a burst window of its element.
	sets.Midcast.BlueMagic.Nuke.Burst = {}

	-- Merged over the blue nuke set in MB mode, for wearing burst gear on every spell that takes
	-- it. A spell the engine expects to burst (which needs Burst Affinity or Azure Lore) also gets
	-- the burst set above, merged after this one.
	sets.Midcast.BlueMagic.Nuke.MB = {}

	sets.Midcast.BlueMagic.Healing = set_combine(sets.Midcast.Cure, {})
	sets.Midcast.BlueMagic.Enmity = set_combine(sets.Enmity, {})
	sets.Midcast.BlueMagic.ACC = set_combine(sets.Idle, {
		ammo = gear.pemphredoTathlum,
		head = gear.hashishinHeadPlusThree,
		body = gear.hashishinBodyPlusThree,
		hands = gear.hashishinHandsPlusThree,
		legs = gear.hashishinLegsPlusThree,
		feet = gear.hashishinFeetPlusThree,
		neck = gear.nullLoop,
		waist = gear.nullWaist,
		left_ear = gear.hashishinEarringPlusOne,
		right_ear = gear.telos,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
		back = gear.nullShawl,
	})

	-- A blue magic set can take a child named for an offense mode, merged over it while you cast
	-- in that mode. The ACC children are for accuracy on the damaging spells in ACC mode. The
	-- commented DT and MEVA lines are for damage taken or magic evasion pieces, at some cost to
	-- what the set is for: fill one and uncomment it.
	sets.Midcast.BlueMagic.Physical.ACC = {}
	sets.Midcast.BlueMagic.Breath.ACC = {}
	sets.Midcast.BlueMagic.Nuke.ACC = {}
	-- sets.Midcast.BlueMagic.Physical.DT = {}
	-- sets.Midcast.BlueMagic.Physical.MEVA = {}
	-- sets.Midcast.BlueMagic.Breath.DT = {}
	-- sets.Midcast.BlueMagic.Breath.MEVA = {}
	-- sets.Midcast.BlueMagic.Nuke.DT = {}
	-- sets.Midcast.BlueMagic.Nuke.MEVA = {}
	-- sets.Midcast.BlueMagic.Buff.DT = {}
	-- sets.Midcast.BlueMagic.Buff.MEVA = {}
	-- sets.Midcast.BlueMagic.Skill.DT = {}
	-- sets.Midcast.BlueMagic.Skill.MEVA = {}
	-- sets.Midcast.BlueMagic.Healing.DT = {}
	-- sets.Midcast.BlueMagic.Healing.MEVA = {}
	-- sets.Midcast.BlueMagic.Enmity.DT = {}
	-- sets.Midcast.BlueMagic.Enmity.MEVA = {}
	-- sets.Midcast.BlueMagic.ACC.DT = {}
	-- sets.Midcast.BlueMagic.ACC.MEVA = {}

	-- The buff sets below sit under sets.Midcast, where each is merged on every spell while its
	-- buff is up. sets.Midcast.BlueMagic itself is never worn, so a child set there does nothing.
	-- A blue magic set you declare can hold one instead, such as
	-- sets.Midcast.BlueMagic.Nuke['Burst Affinity'], so it only applies to that set's spells.

	-- Worn on every spell while Chain Affinity is up, and the next physical blue spell uses the
	-- buff up. Gear that enhances it, such as Hashishin Kavuk +3 (head), raises that spell's base
	-- damage.
	-- sets.Midcast['Chain Affinity'] = {}

	-- Worn on every spell while Burst Affinity is up, and the next magical blue spell uses the buff
	-- up. Gear that enhances it, such as Hashishin Basmak +3 (feet), raises that spell's WSC.
	-- sets.Midcast['Burst Affinity'] = {}

	-- Worn on every spell while Efflux is up, and the next physical blue spell uses the buff up.
	-- Gear that enhances it, such as Hashishin Tayt +3 (legs), adds to Efflux's TP bonus.
	-- sets.Midcast.Efflux = {}

	-- Worn on every spell while Convergence is up. Gear that enhances it, such as the relic head
	-- with its Convergence augment, goes here, worn on the spell that uses the buff up.
	-- sets.Midcast.Convergence = {}

	-- Sets named for one spell. A spell with its own set uses it instead of the family set, except
	-- Refresh, whose set is merged over the enhancing set.
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
		waist = gear.siegel,
		neck = gear.nodens,
	})

	sets.Midcast["Refresh"] = {
		waist = gear.gishdubar
	}

	-- White Wind heals floor(MaxHP/7)*2. Cure potency raises it, but blue magic skill and MND do
	-- not, so favor max HP first and cure potency second.
	sets.Midcast["White Wind"] = {}

	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, {
	})

	-- Foil, from your rune fencer subjob, wears the enhancing set. A set of its own is worn in
	-- the enhancing set's place, so uncomment this line to wear the enmity set for Foil instead.
	-- sets.Midcast["Foil"] = set_combine(sets.Enmity, {})

	sets.Midcast["Feather Tickle"] = set_combine(sets.Midcast.BlueMagic.ACC, {
		ammo = gear.pemphredoTathlum,
		head = gear.carmineHeadPlusOnePathD,
		body = gear.hashishinBodyPlusThree,
		hands = gear.hashishinHandsPlusThree,
		legs = gear.hashishinLegsPlusThree,
		feet = gear.hashishinFeetPlusThree,
		neck = gear.nullLoop,
		waist = gear.nullWaist,
		left_ear = gear.crepuscularEar,
		right_ear = gear.hashishinEarringPlusOne,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.weatherspoon,
		back = gear.bluFCSird,
	})

	sets.Midcast["Reaving Wind"] = set_combine(sets.Midcast.BlueMagic.ACC, {
		ammo = gear.pemphredoTathlum,
		head = gear.carmineHeadPlusOnePathD,
		body = gear.hashishinBodyPlusThree,
		hands = gear.hashishinHandsPlusThree,
		legs = gear.hashishinLegsPlusThree,
		feet = gear.hashishinFeetPlusThree,
		neck = gear.nullLoop,
		waist = gear.nullWaist,
		left_ear = gear.crepuscularEar,
		right_ear = gear.hashishinEarringPlusOne,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.weatherspoon,
		back = gear.bluFCSird,
	})

	sets.Midcast["Cruel Joke"] = set_combine(sets.Midcast.BlueMagic.ACC, {
		ammo = gear.pemphredoTathlum,
		head = gear.carmineHeadPlusOnePathD,
		body = gear.hashishinBodyPlusThree,
		hands = gear.hashishinHandsPlusThree,
		legs = gear.hashishinLegsPlusThree,
		feet = gear.hashishinFeetPlusThree,
		neck = gear.nullLoop,
		waist = gear.nullWaist,
		left_ear = gear.crepuscularEar,
		right_ear = gear.hashishinEarringPlusOne,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.weatherspoon,
		back = gear.bluFCSird,
	})

	sets.Midcast['Entomb'] = set_combine(sets.Midcast.BlueMagic.Nuke, {
		neck = gear.quanpur,
	})

	-- Merged over the blue magic set while Diffusion is up. A spell with a set of its own above
	-- does not take it.
	sets.Diffusion = {
		feet = gear.luhlazaFeetPlusOne,
	}

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is merged over sets.Idle for every job ability, then the set named for
	-- the ability is merged over it. Any slot left empty keeps your idle gear.
	sets.JA = {}
	sets.JA["Azure Lore"] = {}
	sets.JA["Chain Affinity"] = {}
	sets.JA["Burst Affinity"] = {}
	sets.JA["Diffusion"] = {}
	sets.JA["Efflux"] = {}
	sets.JA["Unbridled Learning"] = {}
	sets.JA["Unbridled Wisdom"] = {}

	-- Steps and Waltzes from your dancer subjob. Each of these sets is merged over sets.Idle for
	-- its kind of ability (they do not use sets.JA), and a set named for one ability is merged over
	-- it. Built on sets.OffenseMode.DT, they keep you in that defensive gear while the ability goes
	-- off.
	sets.Step = set_combine(sets.OffenseMode.DT, {})
	sets.Waltz = set_combine(sets.OffenseMode.DT, {
		ammo = gear.yamarang, -- 5
		body = gear.gletiBody, -- 10
		hands = gear.slitherGlovesPlusOne, -- 5
		legs = gear.dashingSubligar, -- 10
	}) -- 30% Potency

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- Weaponskill base, merged over sets.Idle for every weaponskill. The set named for the
	-- weaponskill is merged over it. Any slot left empty keeps your idle gear.
	sets.WS = {
		ammo = gear.coiste,
		head = gear.hashishinHeadPlusThree,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.mirageStolePlusTwo,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear = gear.ishvara,
		left_ring = gear.eponas,
		right_ring = gear.epimanondas,
		back = gear.bluWSDDt,
	}

	-- Merged in ACC mode after the set named for the weaponskill, so its gear wins. Only fill in
	-- the slots ACC mode should change. A weaponskill with its own ACC set uses that instead.
	sets.WS.ACC = {}

	-- Merged over the weaponskill sets in SB mode, the same way.
	sets.WS.SB = sets.Subtle_Blow

	-- Merged over the weaponskill sets in MEVA mode, the same way, so the magic evasion neck stays
	-- on.
	sets.WS.MEVA = {
		neck = gear.warderCharmPlusOne,
	}

	-- Merged in DT mode after the set named for the weaponskill, so its gear wins, for damage taken
	-- gear. A weaponskill with its own DT set uses that instead. Every slot here costs some of the
	-- weaponskill's damage, so uncomment it only once you fill it in.
	-- sets.WS.DT = {}

	-- Merged over every weaponskill while Buff Level (Alt+F12) is set to HighBuff, for physical
	-- damage limit gear. At MidBuff, the default, no set is used here. In any offense mode except
	-- TP, the set for that mode and level is merged after it, such as sets.WS.ACC.HighBuff in ACC
	-- mode. A weaponskill's own child sets replace these for that weaponskill, as shown at the end
	-- of this section.
	sets.WS.HighBuff = {}
	sets.WS.ACC.HighBuff = {}

	sets.WS['Black Halo'] = {
		ammo = gear.coiste,
		head = gear.hashishinHeadPlusThree,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.mirageStolePlusTwo,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear = gear.ishvara,
		left_ring = gear.eponas,
		right_ring = gear.epimanondas,
		back = gear.bluWSDDt,
	}

	sets.WS['Expiacion'] = {
		ammo = gear.coiste,
		head = gear.hashishinHeadPlusThree,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.mirageStolePlusTwo,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear = gear.ishvara,
		left_ring = gear.eponas,
		right_ring = gear.epimanondas,
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
		waist = gear.fotiaWaist,
		left_ear = gear.odr,
		right_ear = gear.hashishinEarringPlusOne,
		left_ring = gear.eponas,
		right_ring = gear.lehkoHabhokaRing,
		back = gear.bluDA,
	}

	-- Savage Blade, for the Naegling weapon mode.
	sets.WS['Savage Blade'] = {}

	-- Child sets for a single weaponskill, used instead of the general sets.WS ones: one for a
	-- mode, one for HighBuff, and one for the two together. Once declared, each one replaces the
	-- general set for that weaponskill even if it is empty, so only uncomment a line after you fill
	-- it in. The mode and HighBuff line also needs the mode line above it.
	-- sets.WS['Black Halo'].ACC = {}
	-- sets.WS['Black Halo'].HighBuff = {}
	-- sets.WS['Black Halo'].ACC.HighBuff = {}

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
-- change your gear. Here, changing the job mode (by key, by gs c jobmode or by gs c jobmode AoE)
-- loads the matching AzureSets spell set, magic for AoE and tp for Melee, and switches the macro
-- set to match. Checking only the first word keeps jobmode2 and other commands that just contain
-- jobmode from triggering it.
function self_command_custom(command)
	if command:match('^(%S+)') == 'jobmode' then
		if state.JobMode.value == 'AoE' then
			send_command('input //aset spellset magic;input /macro book 8;wait .1; input /macro set 2')
		else
			send_command('input //aset spellset tp;input /macro book 8;wait .1; input /macro set 1')
		end
	end
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
