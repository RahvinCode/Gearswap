-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: Rune Fencer. A sample to copy into your character's folder and fill in.
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

-- The food "gs c food" uses.
Food = "Miso Ramen"

-- Offense modes. TP, ACC and DT are the engine's defaults, and more can be added. Each mode picks
-- its own engaged, idle and weaponskill sets, so each one offered needs a sets.OffenseMode.<Mode>
-- and a sets.Idle.<Mode> below.
state.OffenseMode:options('TP','ACC','DT','PDT','MEVA')

-- Picks the macro set for the current subjob and the starting offense mode, DT on /BLU and TP
-- otherwise. On /BLU it also loads the AzureSets tanking set.
-- It runs once, when the file loads.
function Macro_Sub_Job()
	local macro = 1
	if player.sub_job == "BLU" then
		state.OffenseMode:set('DT')
		-- Macro set used on /BLU.
		macro = 1
		send_command('wait 2;aset set tanking')
	else
		state.OffenseMode:set('TP')
		-- Macro set used on any other subjob.
		macro = 1
	end
	return macro
end


-- The in-game lockstyle set, macro book and macro set this file applies on load. The macro set
-- comes from Macro_Sub_Job above.
LockStylePallet = "12"
MacroBook = "12"
MacroSet = Macro_Sub_Job()

-- Weapon modes. Each name needs a matching sets.Weapons entry below.
state.WeaponMode:options('Epeolatry','Naegling','Club','Great Axe','Axe')
state.WeaponMode:set('Epeolatry')

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

-- Job-specific mode slots. Name one with UI_Name or UI_Name2 to show it in chat and on the status
-- box.
UI_Name = ''
UI_Name2 = ''

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

-- HP balancing: 3000 HP
-- MP balancing: 950 MP

function get_sets()

	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	-- Weapon sets, one per weapon mode.
	sets.Weapons = {}

	sets.Weapons['Epeolatry'] = {
		main = gear.epeolatry,
		sub = gear.utu,
	}

	sets.Weapons['Naegling'] = {
		main = gear.naegling,
		sub = gear.dolichenus,
	}

	sets.Weapons['Axe'] = {
		main = gear.dolichenus,
		sub = gear.naegling,
	}

	sets.Weapons['Great Axe'] = {
		main = gear.lycurgos,
		sub = gear.utu,
	}

	sets.Weapons['Club'] = {
		main = gear.loxoticPlusOne,
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons.Shield = {}
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
		ammo = gear.homiliary, -- 1 Refresh
		head = gear.nyameHead, -- 7/7
		body = gear.erilazBodyPlusThree,
		hands = gear.erilazHandsPlusThree, -- 11/11
		legs = gear.erilazLegsPlusThree, -- 13/13
		feet = gear.erilazFeetPlusThree, -- 11/11
		neck = gear.futharkTorquePlusTwo, -- 7/7
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne, -- 3/5
		right_ear = gear.sanareEarring, -- Upgrade to +1/+2 Earring
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.runEnmity, -- 5/5
	} -- 75 PDT / 58 MDT		3571 HP/ 1149 MP

	-- Idle sets for each offense mode, merged over the idle set.
	sets.Idle.PDT = set_combine( sets.Idle, {
		neck = gear.loricatePlusOne,
		waist = gear.flumeBeltPlusOne, -- 4/0
		left_ear = gear.tuisto,
		left_ring = gear.gelatinousPlusOne, -- 7/-1
	})

	sets.Idle.MEVA = set_combine( sets.Idle, {
		ammo = gear.staunchPlusOne,
		neck = gear.warderCharmPlusOne,
		head = gear.erilazHeadPlusThree,
		body = gear.runeistBodyPlusThree,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne, -- 3/5
		right_ear = gear.sanareEarring,
	})

	sets.Idle.DT = set_combine( sets.Idle, {
		ammo = gear.yamarang,
		head = gear.erilazHeadPlusThree,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.tuisto,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	})

	-- The remaining idle mode sets, and Resting, merged over them while you rest.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.Resting = {}

	-- Read only in an SB offense mode, which this file does not offer. To use it, add 'SB' to
	-- state.OffenseMode:options above, declare sets.OffenseMode.SB, and uncomment this line.
	-- sets.Idle.SB = set_combine(sets.Idle, {})

	-- Merged over the idle set while Sublimation is charging.
	sets.Idle.Sublimation = {}

	-- Worn over the idle set while a Phantom Roll on you stands at 11.
	-- It is meant for Roller's Ring, which every job can wear and which grants Refresh +1 and
	-- Regain +10 at an 11, e.g. left_ring="Roller's Ring".
	-- This set applies in every offense mode. The TP set below applies only in TP mode and merges
	-- after it.
	-- It is worn only while idle, so any action swaps it out, and it comes back when the action
	-- ends.
	-- While you move, a ring named here replaces a movement ring in the same slot. This file's
	-- sets.Movement names both rings, so no slot is free and a ring here replaces one of them while
	-- you move.
	sets.Idle.XIRoll = {}
	-- The TP mode version, merged after the one above.
	sets.Idle.TP.XIRoll = {}

	-- Worn over the idle set while Pflug is up. Runeist Bottes raise Pflug's resistance bonus, but
	-- only when worn as the enemy's spell or ability finishes, so this keeps them on while Pflug
	-- lasts.
	-- sets.Idle.Pflug = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = {
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		legs = gear.carmineLegsPlusOnePathA,
	} -- 73 PDT / 33 MDT		3028 HP / 963 MP

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

	-- ===================================================================================================================
	--		sets.OffenseMode
	-- ===================================================================================================================

	-- Engaged sets. sets.OffenseMode is worn in every offense mode, and the current mode's set
	-- merges over it.
	sets.OffenseMode = {
		ammo = gear.coiste,
		head = gear.erilazHeadPlusThree,
		body = gear.asheraHarness,
		hands = gear.erilazHandsPlusThree,
		legs = gear.erilazLegsPlusThree,
		feet = gear.erilazFeetPlusThree,
		neck = gear.futharkTorquePlusTwo,
		waist = gear.windbuffetPlusOne,
		left_ear = gear.sherida,
		right_ear = gear.telos,
		left_ring = gear.niqmaddu,
		right_ring = gear.eponas,
		back = gear.runSTP,
	}

	-- TP mode, for damage while tanking. It only fills in the slots it changes over the base above.
	sets.OffenseMode.TP = {
		head = gear.adhemarHeadPlusOnePathA,
		hands = gear.adhemarHandsPlusOnePathA,
		legs = gear.samnuhaTightsDA,
	}

	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, { })

	-- PDT mode, a physical damage taken set for tanking.
	sets.OffenseMode.PDT = set_combine(sets.OffenseMode, {
		head = gear.nyameHead,
		body = gear.adamantiteArmor,
		hands = gear.turmsHandsPlusOne,
		neck = gear.unmovingPlusOne,
		waist = gear.sailfi,
		back = gear.nullShawl,
	}) -- Maintains Capped PDT with some DPS mixed in

	-- MEVA mode, a magic evasion set for tanking.
	sets.OffenseMode.MEVA = set_combine(sets.Idle.MEVA, {

	}) -- Focus on Magic Evasion with some DPS mixed in

	-- DT mode, the standard tanking set.
	sets.OffenseMode.DT = set_combine(sets.Idle.DT, {
		body = gear.asheraHarness,
		waist = gear.sailfi,
		left_ear = gear.sherida,
		right_ear = gear.telos,
		back = gear.runSTP,
	})

	-- Worn over the engaged set in every offense mode while Pflug is up, to keep the Runeist Bottes
	-- on as enemy spells and abilities finish, as the idle one above does.
	-- sets.OffenseMode.Pflug = {}

	-- Merged over the engaged set while you have the Dual Wield trait and your main weapon is
	-- one-handed, as in the Naegling and Axe weapon modes with a ninja or dancer subjob.
	sets.DualWield = {}

	-- Aftermath sets, merged over the engaged set while that level of Aftermath is up. A child
	-- named for a weapon mode adds gear for that weapon alone, so Epeolatry's Aftermath gear goes
	-- in the Epeolatry children, which are not worn once you change to another weapon mode.
	sets.OffenseMode.AM1 = {}
	sets.OffenseMode.AM2 = {}
	sets.OffenseMode.AM3 = {}
	sets.OffenseMode.AM1['Epeolatry'] = {}
	sets.OffenseMode.AM2['Epeolatry'] = {}
	sets.OffenseMode.AM3['Epeolatry'] = {}

	-- Treasure Hunter gear, worn on an action or melee swing against a monster not yet tagged, and
	-- throughout a fight in Full Time mode. It is never worn in None mode, where every job but
	-- Thief starts.
	sets.TreasureHunter = {
		ammo = gear.perfectEgg,
		body = gear.volteJupon,
		waist = gear.chaac,
	}

	-- Enmity gear that the job ability sets, sets.Midcast, Flash, Foil and the blue magic enmity
	-- set below are built from. The engine does not automatically merge this set into any others.
	sets.Enmity = { -- 23 Epo
		ammo = gear.sapience, -- 2
		head = gear.erilazHeadPlusThree,
		body = gear.erilazBodyPlusThree,
		hands = gear.erilazHandsPlusThree,
		legs = gear.erilazLegsPlusThree, -- 11
		feet = gear.erilazFeetPlusThree, -- 8
		neck = gear.unmovingPlusOne, -- 10
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.crypticEarring, -- 4
		left_ring = gear.eihwazRing, -- 5
		right_ring = gear.moonlightRing4,
		back = gear.runEnmity, -- 10
	} -- 99 Enmity 2884 HP / 840 MP

	-- Spell interruption rate down. The engine does not read this set. sets.Midcast and the
	-- Aquaveil set below fold it in with set_combine, so any more specific set overwrites it.
	sets.SIRD = set_combine(sets.Idle.DT, {
		ammo = gear.staunchPlusOne, -- 11
		head = gear.erilazHeadPlusThree, -- 20
		hands = gear.regalGauntlets, -- 10
		legs = gear.carmineLegsPlusOnePathA, -- 20
		neck = gear.moonlightNeck, -- 15
		waist = gear.audumbla, -- 10
		back = gear.runFC, -- 10
	})	-- 104 With Merits

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Every precast starts from sets.Idle, except a pet command's. For a spell, sets.Precast is
	-- merged over it, then the fast cast set. Any slot left empty keeps your idle gear.
	sets.Precast = {}

	-- Fast cast, worn at the start of every spell.
	sets.Precast.FastCast = {
		ammo = gear.sapience, -- 2
		head = gear.runeistHeadPlusThree, -- 14
		body = gear.erilazBodyPlusThree, -- 13
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.futharkLegsPlusThree,
		feet = gear.carmineFeetPlusOnePathD, -- 8
		neck = gear.voltsurge,
		waist = gear.platinumMoogleBelt,
		right_ear = gear.etiolation,
		left_ear = gear.tuisto,
		left_ring = gear.gelatinousPlusOne,
		right_ring = gear.kishar, -- 4
		back = gear.runFC, -- 10
	} --65 FC

	-- Merged over the fast-cast set for enhancing magic.
	sets.Precast.Enhancing = set_combine(sets.Precast.FastCast, {
		legs = gear.futharkLegsPlusThree, -- 7  (15 - 8)
		waist = gear.siegel, -- 8
	}) -- 80+ FC

	-- Merged over the fast-cast set for blue magic.
	sets.Precast.BlueMagic = set_combine (sets.Precast.FastCast, {})

	-- Merged over the fast cast set when you cast Cure, Curaga or Cura.
	sets.Precast.Cure = {}

	-- Merged over the fast cast set when you cast a healing spell other than a cure, such as Raise
	-- or a -na spell.
	sets.Precast.Healing = {}

	-- Merged over the fast cast set when you cast Utsusemi.
	sets.Precast.Utsusemi = {}

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- The base for every cast, merged over sets.Idle on every midcast, so any slot it leaves empty
	-- keeps your idle gear.
	sets.Midcast = set_combine(sets.Idle, sets.Enmity, sets.SIRD, {})

	-- Spell interruption rate down. Used under every midcast except ranged attacks, so any more
	-- specific set overrides it. The base set above already includes this file's sets.SIRD.
	sets.Midcast.SIRD = {}

	-- Magic evasion gear for every spell you cast in MEVA mode. It goes on top of the spell
	-- interruption set, and the spell's own set goes on top of it.
	sets.Midcast.MEVA = {
		ammo = gear.staunchPlusOne,
		neck = gear.warderCharmPlusOne,
		body = gear.runeistBodyPlusThree,
		hands = gear.erilazHandsPlusThree, -- 11/11
		legs = gear.erilazLegsPlusThree, -- 13/13
		feet = gear.erilazFeetPlusThree, -- 11/11
		waist = gear.platinumMoogleBelt,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		left_ear = gear.odnowaPlusOne, -- 3/5
	}

	-- The commented DT and MEVA children below go over their casting set in those offense modes.
	-- Put damage taken or magic evasion pieces in one, at some cost to what the set is for, and
	-- uncomment it. In MEVA mode sets.Midcast.MEVA already goes under every casting set, so a MEVA
	-- child needs only the slots its casting set names. The ones filled in below hold
	-- sets.Midcast.MEVA's pieces for those slots, so magic evasion wins there. Head, right ear and
	-- back keep the casting set's pieces.

	-- Enhancing magic. The sets below for each kind of enhancing spell are merged over it.
	-- Stoneskin's and Aquaveil's own sets are copies of it, because a spell with its own set uses
	-- that set instead of this one.
	sets.Midcast.Enhancing = {
		ammo = gear.staunchPlusOne,
		head = gear.erilazHeadPlusThree,
		body = gear.runeistBodyPlusThree,
		hands = gear.regalGauntlets,
		legs = gear.futharkLegsPlusThree,
		feet = gear.erilazFeetPlusThree,
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
		left_ear = gear.tuisto,
		right_ear = gear.mimir,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.runEnmity, -- 5/5
	}

	-- Merged over the enhancing set while Embolden is up. An Evasionist's Cape with an Embolden
	-- augment adds 5 to 15 percent duration to a spell you receive under Embolden, and it must be
	-- worn as the spell lands. Regen, Refresh and Phalanx are merged over the enhancing set, so
	-- they wear this too. Stoneskin, Aquaveil and Foil wear their own sets instead of the enhancing
	-- set, so each of those carries this same set, further below.
	sets.Midcast.Enhancing.Embolden = { back = gear.evasionistCapeDA, }

	-- Merged over the enhancing set for elemental bar spells.
	sets.Midcast.Enhancing.Elemental = {}

	-- Merged over the enhancing set when you cast an enhancing spell on yourself without Accession.
	sets.Midcast.Enhancing.Self = {}

	-- Merged over the enhancing set when you cast an enhancing spell on someone else, or on
	-- yourself under Accession.
	sets.Midcast.Enhancing.Others = {}

	-- Merged over the enhancing set in DT or MEVA mode.
	-- sets.Midcast.Enhancing.DT = {}
	sets.Midcast.Enhancing.MEVA = {
		ammo = gear.staunchPlusOne,
		body = gear.runeistBodyPlusThree,
		hands = gear.erilazHandsPlusThree,
		legs = gear.erilazLegsPlusThree,
		feet = gear.erilazFeetPlusThree,
		neck = gear.warderCharmPlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	}

	-- Merged over the enhancing set for status bar spells.
	sets.Midcast.Enhancing.Status = {}

	-- Merged over the enhancing set for skill-based buffs such as Temper.
	sets.Midcast.Enhancing.Skill = {}

	-- Merged over the enhancing set for every Regen and Refresh spell, the first tier included.
	sets.Midcast.Regen = {}

	sets.Midcast.Refresh = {}

	-- Merged over the enhancing set for the storm spells, such as Aurorastorm from your scholar
	-- subjob.
	sets.Storms = {}

	-- Merged over the Regen, Refresh, bar spell, skill and storm sets in MEVA mode.
	-- sets.Midcast.Regen.MEVA = {}
	-- sets.Midcast.Refresh.MEVA = {}
	-- sets.Midcast.Enhancing.Elemental.MEVA = {}
	-- sets.Midcast.Enhancing.Status.MEVA = {}
	-- sets.Midcast.Enhancing.Skill.MEVA = {}
	-- sets.Storms.MEVA = {}

	-- Worn when you cast a cure.
	sets.Midcast.Cure = {}

	-- Merged over the cure set when you cast a cure on yourself.
	sets.Midcast.Cure.Self = {}

	-- Merged over the cure set when you cast a cure on anyone else, or on yourself under Accession.
	sets.Midcast.Cure.Others = {}

	-- Merged over the cure set in DT or MEVA mode.
	-- sets.Midcast.Cure.DT = {}
	-- sets.Midcast.Cure.MEVA = {}

	-- Worn when you cast Utsusemi.
	sets.Midcast.Utsusemi = {}
	-- Merged over the Utsusemi set in DT or MEVA mode.
	-- sets.Midcast.Utsusemi.DT = {}
	-- sets.Midcast.Utsusemi.MEVA = {}

	-- Blue magic from your blue mage subjob. The engine never wears sets.Midcast.BlueMagic itself.
	-- It sorts each blue spell into one of the sets below by its own lists: Skill for spells such
	-- as Metallic Body, Nuke for Bomb Toss and Cursed Sphere, Healing for Healing Breeze and Wild
	-- Carrot, ACC for Sandspin and Cold Wave, Enmity for spells such as Jettatura, Blank Gaze and
	-- Geist Wall, and Buff for Cocoon.
	sets.Midcast.BlueMagic = {}
	sets.Midcast.BlueMagic.Skill = set_combine(sets.Midcast.Enhancing, {})
	-- Merged over the blue magic skill set in DT or MEVA mode.
	-- sets.Midcast.BlueMagic.Skill.DT = {}
	sets.Midcast.BlueMagic.Skill.MEVA = {
		ammo = gear.staunchPlusOne,
		body = gear.runeistBodyPlusThree,
		hands = gear.erilazHandsPlusThree,
		legs = gear.erilazLegsPlusThree,
		feet = gear.erilazFeetPlusThree,
		neck = gear.warderCharmPlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	}
	sets.Midcast.BlueMagic.Nuke = set_combine(sets.Midcast.Enhancing, {})
	-- Merged over the blue magic nuke set in DT or MEVA mode.
	-- sets.Midcast.BlueMagic.Nuke.DT = {}
	sets.Midcast.BlueMagic.Nuke.MEVA = {
		ammo = gear.staunchPlusOne,
		body = gear.runeistBodyPlusThree,
		hands = gear.erilazHandsPlusThree,
		legs = gear.erilazLegsPlusThree,
		feet = gear.erilazFeetPlusThree,
		neck = gear.warderCharmPlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	}
	sets.Midcast.BlueMagic.Healing = set_combine(sets.Midcast.Cure, {})
	-- Merged over the blue magic healing set in DT or MEVA mode.
	-- sets.Midcast.BlueMagic.Healing.DT = {}
	-- sets.Midcast.BlueMagic.Healing.MEVA = {}
	sets.Midcast.BlueMagic.ACC = set_combine(sets.Midcast.Enhancing, {})
	-- Merged over the blue magic accuracy set in DT or MEVA mode.
	-- sets.Midcast.BlueMagic.ACC.DT = {}
	sets.Midcast.BlueMagic.ACC.MEVA = {
		ammo = gear.staunchPlusOne,
		body = gear.runeistBodyPlusThree,
		hands = gear.erilazHandsPlusThree,
		legs = gear.erilazLegsPlusThree,
		feet = gear.erilazFeetPlusThree,
		neck = gear.warderCharmPlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	}
	sets.Midcast.BlueMagic.Enmity = set_combine(sets.Enmity, {})
	sets.Midcast.BlueMagic.Buff = {}
	-- Merged over the blue magic buff set in DT or MEVA mode.
	-- sets.Midcast.BlueMagic.Buff.DT = {}
	-- sets.Midcast.BlueMagic.Buff.MEVA = {}

	-- Merged over the blue magic enmity set in DT or MEVA mode.
	-- sets.Midcast.BlueMagic.Enmity.DT = {}
	sets.Midcast.BlueMagic.Enmity.MEVA = {
		ammo = gear.staunchPlusOne,
		body = gear.runeistBodyPlusThree,
		hands = gear.erilazHandsPlusThree,
		legs = gear.erilazLegsPlusThree,
		feet = gear.erilazFeetPlusThree,
		neck = gear.warderCharmPlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	}

	-- Enfeebling magic, dressed for magic accuracy.
	sets.Midcast.Enfeebling = {}
	-- Merged over the enfeebling set in DT or MEVA mode.
	-- sets.Midcast.Enfeebling.DT = {}
	-- sets.Midcast.Enfeebling.MEVA = {}

	-- Merged over the enfeebling set when you cast a spell on one of the engine's lists: MACC for
	-- the accuracy list, such as Dispel, Duration for the duration list, such as Sleep.
	sets.Midcast.Enfeebling.MACC = {}
	sets.Midcast.Enfeebling.Duration = {}

	-- Worn when you cast dark magic. Stun also takes the MACC set below.
	sets.Midcast.Dark = {}
	-- Merged over the dark magic set in DT or MEVA mode.
	-- sets.Midcast.Dark.DT = {}
	-- sets.Midcast.Dark.MEVA = {}
	sets.Midcast.Dark.MACC = {}

	-- Used instead of the dark magic sets: the first when you cast Drain, the second when you cast
	-- Aspir.
	sets.Midcast.Drain = {}
	-- Merged over the Drain set in DT or MEVA mode.
	-- sets.Midcast.Drain.DT = {}
	-- sets.Midcast.Drain.MEVA = {}
	sets.Midcast.Aspir = {}
	-- Merged over the Aspir set in DT or MEVA mode.
	-- sets.Midcast.Aspir.DT = {}
	-- sets.Midcast.Aspir.MEVA = {}

	-- Divine magic skill gear, a building block for the Vivacious Pulse set below, since that
	-- ability's cure scales with divine magic skill. No spell of yours wears it: Flash has a set of
	-- its own.
	sets.Midcast.Divine = {}
	-- Merged over the divine set in MEVA mode.
	-- sets.Midcast.Divine.MEVA = {}

	-- Sets named for one spell. A spell with its own set uses it instead of the family set, except
	-- Phalanx, whose set is merged over the enhancing set.
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		waist = gear.siegel,
	})

	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, sets.SIRD, {
		body = gear.runeistBodyPlusThree,
	})

	sets.Midcast["Phalanx"] = {
		head = gear.futharkHeadPlusThree, --7
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
		left_ear = gear.tuisto,
		right_ear = gear.etiolation,
		body = gear.runeistBodyPlusThree,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	}

	sets.Midcast["Flash"] = set_combine(sets.Enmity, {
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
		left_ear = gear.tuisto,
		hands = gear.erilazHandsPlusThree,
		body = gear.runeistBodyPlusThree,
		right_ear = gear.etiolation,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	})

	sets.Midcast["Foil"] = set_combine(sets.Enmity, {
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
		left_ear = gear.tuisto,
		hands = gear.erilazHandsPlusThree,
		body = gear.runeistBodyPlusThree,
		right_ear = gear.etiolation,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	})

	-- Merged over the Flash and Foil sets in DT or MEVA mode.
	-- sets.Midcast["Flash"].DT = {}
	sets.Midcast["Flash"].MEVA = {
		ammo = gear.staunchPlusOne,
		body = gear.runeistBodyPlusThree,
		hands = gear.erilazHandsPlusThree,
		legs = gear.erilazLegsPlusThree,
		feet = gear.erilazFeetPlusThree,
		neck = gear.warderCharmPlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	}
	-- sets.Midcast["Foil"].DT = {}
	sets.Midcast["Foil"].MEVA = {
		ammo = gear.staunchPlusOne,
		body = gear.runeistBodyPlusThree,
		hands = gear.erilazHandsPlusThree,
		legs = gear.erilazLegsPlusThree,
		feet = gear.erilazFeetPlusThree,
		neck = gear.warderCharmPlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	}

	-- Merged over the Stoneskin, Aquaveil and Phalanx sets in MEVA mode. Each holds
	-- sets.Midcast.MEVA's pieces for the slots its set names.
	sets.Midcast["Stoneskin"].MEVA = {
		ammo = gear.staunchPlusOne,
		body = gear.runeistBodyPlusThree,
		hands = gear.erilazHandsPlusThree,
		legs = gear.erilazLegsPlusThree,
		feet = gear.erilazFeetPlusThree,
		neck = gear.warderCharmPlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	}
	sets.Midcast["Aquaveil"].MEVA = {
		ammo = gear.staunchPlusOne,
		body = gear.runeistBodyPlusThree,
		hands = gear.erilazHandsPlusThree,
		legs = gear.erilazLegsPlusThree,
		feet = gear.erilazFeetPlusThree,
		neck = gear.warderCharmPlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	}
	sets.Midcast["Phalanx"].MEVA = {
		body = gear.runeistBodyPlusThree,
		neck = gear.warderCharmPlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	}

	-- The Embolden set again, under the sets below. Stoneskin, Aquaveil and Foil wear their own
	-- sets instead of the enhancing set, so they need it here. Regen, Refresh and Phalanx are
	-- merged over the enhancing set, so they wear its Embolden set already. Their lines keep the
	-- Embolden cape on if you give one of those three sets a back piece of its own.
	sets.Midcast.Regen.Embolden = sets.Midcast.Enhancing.Embolden
	sets.Midcast.Refresh.Embolden = sets.Midcast.Enhancing.Embolden
	sets.Midcast["Stoneskin"].Embolden = sets.Midcast.Enhancing.Embolden
	sets.Midcast["Aquaveil"].Embolden = sets.Midcast.Enhancing.Embolden
	sets.Midcast["Phalanx"].Embolden = sets.Midcast.Enhancing.Embolden
	sets.Midcast["Foil"].Embolden = sets.Midcast.Enhancing.Embolden

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is merged over sets.Idle for every job ability, rune, ward and
	-- effusion, then the set named for the ability is merged over it. Any slot left empty keeps
	-- your idle gear.
	sets.JA = {}
	sets.JA["Elemental Sforzo"] = set_combine(sets.Enmity, { body=gear.futharkBodyPlusThree })
	sets.JA["Gambit"] = set_combine(sets.Enmity, { hands=gear.runeistHandsPlusThree,})
	sets.JA["Rayke"] = set_combine(sets.Enmity, { feet=gear.futharkFeetPlusThree })
	sets.JA["Liement"] = set_combine(sets.Enmity, { body=gear.futharkBodyPlusThree })
	sets.JA["One for All"] = {}
	sets.JA["Valiance"] = set_combine(sets.Enmity, {
		body = gear.runeistBodyPlusThree,
		back = gear.runEnmity, -- 5/5
		legs = gear.futharkLegsPlusThree
	})
	sets.JA["Vallation"] = set_combine(sets.Enmity, {
		body = gear.runeistBodyPlusThree,
		back = gear.runEnmity, -- 5/5
		legs = gear.futharkLegsPlusThree
	})
	sets.JA["Pflug"] = set_combine(sets.Enmity, { feet=gear.runeistFeetPlusThree })
	sets.JA["Battuta"] = set_combine(sets.Enmity, { head=gear.futharkHeadPlusThree })
	sets.JA["Vivacious Pulse"] = set_combine(sets.Midcast.Divine, { head=gear.erilazHeadPlusThree })
	sets.JA["Embolden"] = set_combine(sets.Enmity, sets.Midcast.Enhancing.Embolden)
	sets.JA["Swordplay"] = set_combine(sets.Enmity, { hands=gear.futharkHandsPlusThree })
	sets.JA["Provoke"] = sets.Enmity

	-- Merged over sets.JA when you use Lunge, for "Lunge" and magic attack gear. Swipe wears the
	-- same set.
	sets.JA["Lunge"] = {}
	sets.JA["Swipe"] = sets.JA["Lunge"]

	-- Merged over sets.Idle when you use a Waltz. Waltzes do not use sets.JA.
	sets.Waltz = {}

	-- Merged over sets.Idle when you use a flourish, with a set named for one flourish merged over
	-- it. Flourishes do not use sets.JA.
	sets.Flourish = {}

	-- Uncomment this line to wear the enmity set over the flourish set when you use Animated
	-- Flourish.
	-- sets.Flourish['Animated Flourish'] = set_combine(sets.Flourish, sets.Enmity)

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- Weaponskill base, merged over sets.Idle for every weaponskill. The set named for the
	-- weaponskill is merged over it. Any slot left empty keeps your idle gear.
	sets.WS = {
		ammo = gear.knobkierrie,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.fotiaNeck,
		waist = gear.fotiaWaist,
		left_ear = gear.sherida,
		right_ear = gear.odr,
		left_ring = gear.niqmaddu,
		right_ring = gear.epimanondas,
		back = gear.runWSD,
	}
	-- Merged in ACC mode after the set named for the weaponskill, so its gear wins. Only fill in
	-- the slots ACC mode should change. A weaponskill with its own ACC set uses that instead.
	sets.WS.ACC = {}

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

	-- Aftermath sets for weaponskills, merged over the weaponskill's sets, its mode and Buff Level
	-- sets included, while that level of Aftermath is up. They work as the engaged Aftermath sets
	-- do.
	sets.WS.AM1 = {}
	sets.WS.AM2 = {}
	sets.WS.AM3 = {}
	sets.WS.AM1['Epeolatry'] = {}
	sets.WS.AM2['Epeolatry'] = {}
	sets.WS.AM3['Epeolatry'] = {}

	-- Great sword weaponskills, each merged over sets.WS.
	sets.WS["Hard Slash"] = {}
	sets.WS["Frostbite"] = {}
	sets.WS["Freezebite"] = {}
	sets.WS["Shockwave"] = {}
	sets.WS["Crescent Moon"] = {}
	sets.WS["Sickle Moon"] = {}
	sets.WS["Spinning Slash"] = {}
	sets.WS["Herculean Slash"] = {}
	sets.WS["Resolution"] = {}
	sets.WS["Dimidiation"] = {}

	-- Child sets for a single weaponskill, used instead of the general sets.WS ones: one for a
	-- mode, one for HighBuff, and one for the two together. Once declared, each one replaces the
	-- general set for that weaponskill even if it is empty, so only uncomment a line after you fill
	-- it in. The mode and HighBuff line also needs the mode line above it.
	-- sets.WS["Dimidiation"].ACC = {}
	-- sets.WS["Dimidiation"].HighBuff = {}
	-- sets.WS["Dimidiation"].ACC.HighBuff = {}

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
