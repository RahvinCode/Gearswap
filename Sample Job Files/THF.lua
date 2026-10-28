-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: Thief. A sample to copy into your character's folder and fill in.
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
LockStylePallet = "5"
MacroBook = "6"
MacroSet = "1"

-- The food item "gs c food" uses.
Food = "Sublime Sushi"

-- Use a Remedy on paralysis or silence, and a Holy Water on doom, automatically.
AutoItem = false

-- Pick a random lockstyle from Lockstyle_List each time this file loads.
Random_Lockstyle = false

-- The equip sets the random lockstyle picks from.
Lockstyle_List = {1,2,6,12}

-- The offense mode to start in. This file offers the engine's default modes, TP, ACC and DT.
state.OffenseMode:set('DT')

-- The weapon modes, each naming a sets.Weapons entry below, and the one to start in.
state.WeaponMode:options('Aeneas','Naegling','Evisceration')
state.WeaponMode:set('Aeneas')

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

	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	-- One weapon set per weapon mode, keyed by the mode's name.
	sets.Weapons = {}

	sets.Weapons['Aeneas'] = {
		main = gear.aeneas,
		sub = gear.gleti,
	}

	sets.Weapons['Naegling'] = {
		main = gear.naegling,
		sub = gear.crepuscularKnife,
	}

	sets.Weapons['Evisceration'] = {
		main = gear.tauret,
		sub = gear.aeneas,
	}

	-- Worn in the offhand, idle or engaged, whenever the main is one-handed and no dual-wield trait
	-- is active.
	sets.Weapons.Shield = {}
	-- Worn over the idle set when you are put to sleep, and held until the sleep ends. A piece that
	-- drains HP wakes you on its first tick.
	sets.Weapons.Sleep = {
		sub = gear.mpuGandring,
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

	-- Worn while idle. Every precast and midcast also starts from this set, so any slot an action's
	-- set leaves empty keeps your idle gear.
	sets.Idle = {
		ammo = gear.staunchPlusOne,
		head = gear.nullMasque,
		body = gear.adamantiteArmor,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
		neck = gear.warderCharmPlusOne,
		waist = gear.nullWaist,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.sanareEarring,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.nullShawl,
	}
	-- Idle sets per offense mode, merged over sets.Idle in the matching mode. sets.Idle.Resting is
	-- merged while you rest.
	sets.Idle.Resting = {}
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})

	-- Idle sets for SB and MEVA, which this file does not offer. The engine reads one only once
	-- its mode is offered: add a state.OffenseMode:options line above that lists it with TP, ACC
	-- and DT, and a sets.OffenseMode set of the same name, then uncomment its lines.
	-- sets.Idle.SB = set_combine(sets.Idle, {})
	-- sets.Idle.MEVA = set_combine(sets.Idle, {
	-- 	neck = gear.warderCharmPlusOne,
	-- 	waist = gear.carriers,
	-- })

	-- Merged over the idle set while you have a Phantom Roll of 11. It is meant for Roller's Ring,
	-- which every job can wear and which gives Refresh +1 and Regain +10 on an 11, e.g.
	-- left_ring="Roller's Ring". This set applies in every offense mode. sets.Idle.TP.XIRoll
	-- applies in TP mode only and is merged after it. It is only worn while idle, so any action
	-- swaps it out and it comes back when the action ends. While you move, a ring here replaces the
	-- movement set's ring in the same slot. This file's sets.Movement has no ring, so either slot
	-- works.
	sets.Idle.XIRoll = {}
	-- The TP mode form of sets.Idle.XIRoll, merged after it.
	sets.Idle.TP.XIRoll = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = {
		feet = gear.fajinBoots,
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

	-- ===================================================================================================================
	--		sets.OffenseMode
	-- ===================================================================================================================

	-- Engaged sets. sets.OffenseMode is the base, and the set named for the current offense mode is
	-- merged over it.
	sets.OffenseMode = {}

	-- Worn while engaged in TP mode. The other modes below start from a copy of it.
	sets.OffenseMode.TP = {
		ammo = gear.coiste,
		head = gear.adhemarHeadPlusOnePathA,
		body = gear.adhemarBodyPlusOnePathA,
		hands = gear.adhemarHandsPlusOnePathA,
		legs = gear.samnuhaTightsDA,
		feet = gear.gletiFeet,
		neck = gear.assassinGorgetPlusTwo,
		waist = gear.windbuffetPlusOne,
		right_ear = gear.skulkerEarringPlusOne,
		left_ear = gear.sherida,
		left_ring = gear.gereRing,
		right_ring = gear.lehkoHabhokaRing,
		back = gear.nullShawl,
	}

	-- Worn while engaged in DT mode: the TP set with these slots changed.
	sets.OffenseMode.DT = set_combine(sets.OffenseMode.TP, {
		head = gear.malignanceHead,
		body = gear.adamantiteArmor,
		hands = gear.malignanceHands,
		legs = gear.gletiLegs,
		feet = gear.malignanceFeet,
		left_ear = gear.odnowaPlusOne,
		left_ring = gear.moonlightRing,
		waist = gear.platinumMoogleBelt,
	})

	-- Worn while engaged in ACC mode: the TP set with these slots changed.
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode.TP, {})

	-- Buff sets for the engaged set. Uncomment one to use it. Each is worn over the engaged set in
	-- every offense mode while its buff is up, and its slots win over the mode set.
	-- Treasure Hunter gear still takes its slots whenever your TH mode wears it.
	-- Worn while engaged with Trick Attack up. Pillager's Armlets and Plunderer's Vest strengthen
	-- Trick Attack while they are worn.
	-- sets.OffenseMode['Trick Attack'] = {}
	-- Worn while engaged with Sneak Attack up. Its hit is a critical hit, so DEX and critical hit
	-- damage gear helps it.
	-- sets.OffenseMode['Sneak Attack'] = {}
	-- With both up, both are merged, Trick Attack's last. The nested form sets.OffenseMode['Sneak
	-- Attack']['Trick Attack'] holds gear for both at once and merges after them.

	-- Merged over the engaged set while the Dual Wield trait is active and the main weapon is
	-- one-handed. A two-handed or hand-to-hand main skips it. You need only 6 Dual Wield here if
	-- you are not getting Haste Samba.
	sets.DualWield = {
		--left_ear="Eabani Earring",
		--waist="Reiki Yotai",
	}

	-- Treasure Hunter gear. In every TH mode but None, it is worn on the action that tags a monster
	-- and while engaged on an untagged one. Full Time also wears it whenever you are engaged, and
	-- SATA while Sneak Attack, Trick Attack or Feint is up. Thief starts in Full Time.
	sets.TreasureHunter = {
		feet = gear.skulkerFeetPlusThree,
	}

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Every precast starts from sets.Idle, except a pet command's. For a spell, sets.Precast is
	-- merged over it, then the fast cast set. Any slot left empty keeps your idle gear.
	sets.Precast = {}

	-- Worn at the start of every spell. Fast cast gear goes here.
	sets.Precast.FastCast = {
		ammo = gear.sapience, -- 2
		head = gear.herculeanHelmFC, -- 13
		body = gear.taeonTabardBFC, -- 8
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.herculeanTrousersFC, -- 6
		feet = gear.herculeanBootsFC, -- 6
		neck = gear.voltsurge, --4
		waist = gear.platinumMoogleBelt,
		left_ear = gear.etiolation, -- 1
		right_ear = gear.tuisto,
		left_ring = gear.prolix, -- 3
		right_ring = gear.gelatinousPlusOne,
	} -- 51 -- Need cape for another 10%

	-- Merged over the fast cast set when you cast Cure, Curaga or Cura.
	sets.Precast.Cure = {}

	-- Merged over the fast cast set when you cast a healing spell other than a cure, such as Raise
	-- or a -na spell.
	sets.Precast.Healing = {}

	-- Merged over the fast cast set when you cast Utsusemi.
	sets.Precast.Utsusemi = {}

	-- Enmity gear. The engine does not automatically merge this set into any others, so combine it
	-- into a job ability's set to use it.
	sets.Enmity = {
		ammo = gear.sapience, -- 2
		left_ear = gear.friomisi, --2
		right_ear = gear.crypticEarring, -- 4
		left_ring = gear.petrov, -- 4
	}

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- The base for every cast, merged over sets.Idle on every midcast, so any slot it leaves empty
	-- keeps your idle gear.
	sets.Midcast = set_combine(sets.Idle, {

	})
	-- Spell interruption rate down. Used under every midcast except ranged attacks, so any more
	-- specific set overrides it.
	sets.Midcast.SIRD = {}

	-- Merged over the spell interruption set when you cast Utsusemi from your ninja subjob.
	sets.Midcast.Utsusemi = {}
	-- Merged over the Utsusemi set in DT or MEVA mode.
	-- sets.Midcast.Utsusemi.DT = {}
	-- sets.Midcast.Utsusemi.MEVA = {}

	-- Worn when you cast a single-target cure. Curaga takes its own set below.
	sets.Midcast.Cure = {}
	-- Merged over the cure set in DT or MEVA mode.
	-- sets.Midcast.Cure.DT = {}
	-- sets.Midcast.Cure.MEVA = {}

	-- Merged over the cure set when you cast a cure on yourself.
	sets.Midcast.Cure.Self = {}

	-- Merged over the cure set when you cast a cure on anyone else, or on yourself under Accession.
	sets.Midcast.Cure.Others = {}

	-- Worn when you cast Curaga from your white mage subjob. It does not use the cure set above.
	sets.Midcast.Curaga = {}
	-- Merged over the Curaga set in DT or MEVA mode.
	-- sets.Midcast.Curaga.DT = {}
	-- sets.Midcast.Curaga.MEVA = {}

	-- Enhancing magic. Healing spells other than cures, such as Raise and the -na spells, use it
	-- too.
	sets.Midcast.Enhancing = {}
	-- Merged over the enhancing set in DT or MEVA mode.
	-- sets.Midcast.Enhancing.DT = {}
	-- sets.Midcast.Enhancing.MEVA = {}
	-- Enfeebling magic, where magic accuracy decides whether the spell lands.
	sets.Midcast.Enfeebling = {}
	-- Merged over the enfeebling set in DT or MEVA mode.
	-- sets.Midcast.Enfeebling.DT = {}
	-- sets.Midcast.Enfeebling.MEVA = {}
	-- A set named for one spell replaces its family set for that spell, so Stoneskin skips the
	-- enhancing set. Cures are the exception and always take the Cure, Curaga or Cura set.
	sets.Midcast["Stoneskin"] = {
		waist = gear.siegel,
	}

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is merged over sets.Idle for every job ability, then the set named for
	-- the ability is merged over it. Any slot left empty keeps your idle gear.
	sets.JA = {}
	sets.JA["Perfect Dodge"] = {hands = gear.plundererHandsPlusThree,}
	sets.JA["Steal"] = {}
	sets.JA["Flee"] = {}
	sets.JA["Hide"] = {}
	sets.JA["Sneak Attack"] = {}
	sets.JA["Mug"] = {}
	sets.JA["Trick Attack"] = {}
	sets.JA["Accomplice"] = {}
	sets.JA["Feint"] = {}
	sets.JA["Despoil"] = {}
	sets.JA["Collaborator"] = {}
	sets.JA["Conspirator"] = {}
	sets.JA["Bully"] = {}
	sets.JA["Larceny"] = {}

	-- Dancer abilities from your dancer subjob. Each of these sets is merged over sets.Idle for its
	-- kind of ability (they do not use sets.JA), and a set named for one ability is merged over it.
	-- Built from sets.OffenseMode.DT, each keeps you in that defensive gear while the ability goes
	-- off.
	sets.Step = set_combine(sets.OffenseMode.DT, {})

	-- Waltz potency gear caps at 50%, and Waltz potency received caps at 30%.
	sets.Waltz = set_combine(sets.OffenseMode.DT, {
		ammo = gear.yamarang, -- 5%
		head = gear.malignanceHead,
		body = gear.gletiBody, -- 10%
		hands = gear.slitherGlovesPlusOne, -- 5%
		legs = gear.dashingSubligar, -- 10%
		feet = gear.malignanceFeet,
		neck = gear.loricatePlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.tuisto,
		right_ring = gear.defending,
		left_ring = gear.moonlightRing,
		back = gear.thfDA,
	}) -- 30% Potency

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- The base for every weaponskill, merged over sets.Idle. A set named for the weaponskill is
	-- merged over it. Any slot left empty keeps your idle gear.
	sets.WS = {
		ammo = gear.yetshilaPlusOne,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.fotiaNeck,
		waist = gear.fotiaWaist,
		left_ear = gear.sherida,
		right_ear = gear.moonshadeEarringAcc,
		left_ring = gear.gereRing,
		right_ring = gear.regalRing,
		back = gear.thfWSD,
	}
	-- Worn on weaponskills in ACC mode, merged after the set named for the weaponskill so its slots
	-- win. It is skipped where sets.WS['<name>'].ACC exists.
	sets.WS.ACC = {}

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

	-- Aftermath sets for weaponskills, merged after the weaponskill's own sets while the matching
	-- Aftermath is up. The engine uses the strongest active tier that has gear for the current
	-- weapon, and a tier set applies with any weapon. A child named for a weapon mode adds gear for
	-- that weapon only, over the tier set, and is read only when its name is one of the
	-- state.WeaponMode options above. Aeneas's Aftermath raises the damage of the skillchains your
	-- weaponskills make, so its sets are here.
	sets.WS.AM1 = {}
	sets.WS.AM2 = {}
	sets.WS.AM3 = {}
	sets.WS.AM1['Aeneas'] = {}
	sets.WS.AM2['Aeneas'] = {}
	sets.WS.AM3['Aeneas'] = {}

	-- A building block for magical weaponskills. MAB is not an offense mode, so this set is worn
	-- only through the sets built from it.
	sets.WS.MAB = set_combine( sets.WS, {
		ammo = gear.ghastlyTathlumPlusOne,
		neck = gear.sanctity,
		waist = gear.orpheusWaist,
		left_ear = gear.friomisi,
		right_ear = gear.moonshadeEarringAcc,
		left_ring = gear.karieyhRingPlusOne,
		right_ring = gear.epimanondas,
		back = gear.thfWSD,
	})
	-- Sets named for one weaponskill, merged over sets.WS.
	sets.WS["Wasp Sting"] = {}
	sets.WS["Viper Bite"] = {}
	sets.WS["Shadowstitch"] = {}
	sets.WS["Gust Slash"] = {}
	sets.WS["Cyclone"] = {}
	sets.WS["Energy Steal"] = {}
	sets.WS["Energy Drain"] = {}
	sets.WS["Dancing Edge"] = {}
	sets.WS["Shark Bite"] = {}
	sets.WS["Evisceration"] = {}
	sets.WS["Aeolian Edge"] = set_combine( sets.WS.MAB, {
		feet = gear.skulkerFeetPlusThree,
	})
	sets.WS["Exenterator"] = {}

	-- Sword weaponskills, for the Naegling mode.
	sets.WS["Savage Blade"] = {}

	-- Child sets for a single weaponskill, used instead of the general sets.WS ones: one for a
	-- mode, one for HighBuff, and one for the two together. Once declared, each one replaces the
	-- general set for that weaponskill even if it is empty, so only uncomment a line after you fill
	-- it in. The mode and HighBuff line also needs the mode line above it.
	-- sets.WS["Evisceration"].ACC = {}
	-- sets.WS["Evisceration"].HighBuff = {}
	-- sets.WS["Evisceration"].ACC.HighBuff = {}

	-- Buff sets for weaponskills. Uncomment one to use it. Each is worn on every weaponskill while
	-- its buff is up, and its slots win over the set named for the weaponskill.
	-- Treasure Hunter gear still takes its slots on an untagged monster.
	-- Worn on every weaponskill while Trick Attack is up. Pillager's Armlets and Plunderer's Vest
	-- strengthen Trick Attack while they are worn.
	-- sets.WS['Trick Attack'] = {}
	-- Worn on every weaponskill while Sneak Attack is up. Sneak Attack makes the first hit a
	-- critical hit, so DEX and critical hit damage gear helps it.
	-- sets.WS['Sneak Attack'] = {}
	-- With both up, both are merged, Trick Attack's last. The nested form sets.WS['Sneak
	-- Attack']['Trick Attack'] holds gear for both at once and merges after them. Declare it below
	-- the Sneak Attack set.

	-- Sets for your own hooks. The engine never uses sets.Custom on its own, so use it from the
	-- hooks below.
	sets.Custom = {}
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
