-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: Ninja. A sample to copy into your character's folder and fill in.
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
LockStylePallet = "10"
MacroBook = "1"
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
-- sets.WS.<Mode>. state.OffenseMode:set picks the mode you start in. MB wears burst gear on every
-- elemental ninjutsu, through sets.Midcast.Nuke.MB below.
state.OffenseMode:options('TP','ACC','DT','SB','MEVA','MB')
state.OffenseMode:set('DT')

-- Weapon modes. Each one needs a sets.Weapons['<Mode>'] of the same name below.
state.WeaponMode:options('Kannagi','Savage Blade','Karambit','Aeolian Edge','Abyssea','Ninjitsu')
state.WeaponMode:set('Kannagi')

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

	-- Weapon sets, one per weapon mode above.
	sets.Weapons = {}

	sets.Weapons['Kannagi'] = {
		main = gear.kannagi,
		sub = gear.gokotai,
	}

	sets.Weapons['Ninjitsu'] = {
		main = gear.tauret,
		sub = gear.gokotai,
	}

	sets.Weapons['Savage Blade'] = {
		main = gear.naegling,
		sub = gear.blurredKnife,
	}

	sets.Weapons['Karambit'] = {
		main = gear.karambit,
		sub = "empty",
	}

	sets.Weapons['Aeolian Edge'] = {
		main = gear.tauret,
		sub = gear.naegling,
	}

	sets.Weapons['Abyssea'] = {
		main = "",
		sub = "",
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active,
	-- engaged or idle.
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

	-- Worn while idle. Every action's precast and midcast also start from this set, so any slot
	-- their sets leave empty keeps your idle gear.
	sets.Idle = {
		ammo = gear.staunchPlusOne,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.loricatePlusOne,
		waist = gear.carriers,
		left_ear = gear.etiolation,
		right_ear = gear.odnowaPlusOne,
		left_ring = gear.eihwazRing,
		right_ring = gear.gelatinousPlusOne,
		back = gear.ninDA,
	}

	-- Worn over sets.Idle while idle in the matching offense mode.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
	})

	-- Worn over the idle set while a Phantom Roll on you stands at 11. It is for the Roller's
	-- Ring, which any job can wear and which gives Refresh +1 and Regain +10 at an 11, for example
	-- left_ring="Roller's Ring". It applies in every offense mode. It is worn only while idle, so
	-- any action swaps it out and it comes back when the action ends. While moving, a ring here
	-- replaces the movement set's ring in the same slot. This file's movement sets have no ring, so
	-- either slot works.
	sets.Idle.XIRoll = {}

	-- The TP-mode form, merged after sets.Idle.XIRoll while idle in TP mode.
	sets.Idle.TP.XIRoll = {}

	-- Worn over the idle set while Migawari is up. Migawari gear, such as the Hattori Ningi, lowers
	-- the damage threshold at which Migawari takes a hit, and must be worn when that hit lands.
	-- sets.Idle.Migawari = {}

	-- Worn over the idle set while moving and not engaged. Cycle_Timer at the bottom of this file
	-- rebuilds it for the time of day. The three period sets are siblings of sets.Movement, not
	-- children of it, because a rebuilt set keeps only equipment slots and children would not
	-- survive.
	sets.Movement = {}

	-- Worn while moving at any hour. The set for the current time of day is merged over it.
	sets.Movement_Base = {}

	sets.Movement_Day = {
		feet = gear.danzoSuneAte,
	}
	sets.Movement_Night = {
		feet = gear.hachiyaFeetPlusOne,
	}
	sets.Movement_Dusk = {
		feet = gear.hachiyaFeetPlusOne,
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

	-- ===================================================================================================================
	--		sets.OffenseMode
	-- ===================================================================================================================

	-- Engaged sets. sets.OffenseMode is merged first in every offense mode, and the mode's own set
	-- is merged over it.
	sets.OffenseMode = {}

	-- The TP set. The DT and ACC sets below build on it.
	sets.OffenseMode.TP = {
		ammo = gear.happoShurikenPlusOne,
		head = gear.adhemarHeadPlusOnePathA,
		body = gear.kendatsubaBodyPlusOne,
		hands = gear.adhemarHandsPlusOnePathA,
		legs = gear.samnuhaTightsDA,
		feet = gear.kendatsubaFeetPlusOne,
		neck = gear.ninjaNodowaPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.telos,
		right_ear = gear.hattoriEarringPlusOne,
		left_ring = gear.gereRing,
		right_ring = gear.eponas,
		back = gear.ninDA,
	}
	-- DT mode, built on the TP set.
	sets.OffenseMode.DT = set_combine (sets.OffenseMode.TP, {
		head = gear.malignanceHead,
		body = gear.malignanceBody,
		hands = gear.malignanceHands,
		legs = gear.malignanceLegs,
		feet = gear.malignanceFeet,
	})
	-- ACC mode, built on the TP set.
	sets.OffenseMode.ACC = set_combine (sets.OffenseMode.TP, {
		head = gear.kendatsubaHeadPlusOne,
		body = gear.kendatsubaBodyPlusOne,
		hands = gear.kendatsubaHandsPlusOne,
		legs = gear.kendatsubaLegsPlusOne,
		feet = gear.kendatsubaFeetPlusOne,
	})

	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode.DT,{
		neck = gear.warderCharmPlusOne,
	})

	sets.OffenseMode.SB = set_combine(sets.OffenseMode.DT,{ })

	-- Worn over the engaged set in every offense mode while Migawari is up, for the same bonus.
	-- sets.OffenseMode.Migawari = {}
	-- Worn over the engaged set in every offense mode while Innin is up. Uncomment it to use it.
	-- Hattori Zukin adds Double Attack under Innin.
	-- sets.OffenseMode.Innin = {}
	-- Worn over the engaged set in every offense mode while Yonin is up. Uncomment it to use it.
	-- Hattori Hakama adds Counter under Yonin.
	-- sets.OffenseMode.Yonin = {}

	-- Aftermath sets, merged over the engaged set while the matching Aftermath is up. The engine
	-- uses the strongest active tier that has gear for the current weapon, and a tier set applies
	-- with any weapon. A child named for a weapon mode adds gear for that weapon only, over the
	-- tier set, and is read only when its name is one of the state.WeaponMode options above.
	-- Kannagi's Aftermath acts on melee attacks, not weaponskills, so its sets are here.
	sets.OffenseMode.AM1 = {}
	sets.OffenseMode.AM2 = {}
	sets.OffenseMode.AM3 = {}
	sets.OffenseMode.AM1['Kannagi'] = {}
	sets.OffenseMode.AM2['Kannagi'] = {}
	sets.OffenseMode.AM3['Kannagi'] = {}

	-- Merged over the engaged set while the Dual Wield trait is active and the main weapon is
	-- one-handed. A two-handed or hand-to-hand main, such as the Karambit mode's, skips it.
	sets.DualWield = {}

	-- Treasure Hunter gear. While TH Mode is Tag or Full Time, it is worn for an action aimed at an
	-- untagged monster and while engaged on one. Full Time also keeps it on whenever engaged. TH
	-- Mode starts at None, which never wears it, on every job but Thief.
	sets.TreasureHunter = {
		head = gear.volteHead,
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
	-- Fast cast gear, worn at the start of every spell.
	sets.Precast.FastCast = {
		ammo = gear.sapience, -- 2
		head = gear.herculeanHelmFC, --13
		body = gear.taeonTabardBFC, -- 9
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.herculeanTrousersFC, -- 6
		feet = gear.herculeanBootsFC, -- 6
		neck = gear.voltsurge, -- 4
		waist = gear.platinumMoogleBelt,
		left_ear = gear.etiolation, -- 1
		right_ear = gear.loquacious, -- 2
		left_ring = gear.kishar, -- 4
		right_ring = gear.rahabRing, -- 2
		back = gear.ninFC, -- 10
	} -- 67

	-- Merged over the fast cast set for Utsusemi.
	sets.Precast.Utsusemi = {
		neck = gear.magoragaBeadNecklace, -- 10 FC (+6)
	}

	-- Worn when you start a ranged attack, for snapshot and rapid shot gear. Name the shuriken you
	-- throw here and in sets.Midcast.RA below. Without one the ammo slot keeps your idle ammo, and
	-- the engine cancels the throw unless you carry at least two of what that slot holds.
	sets.Precast.RA = {}

	-- Enmity gear for Provoke. sets.JA["Provoke"] below points to this same set. The engine does
	-- not automatically merge this set into any others.
	sets.Enmity = { -- Head and Back upgrade slots
		ammo = gear.sapience, --2
		body = gear.emetHarnessPlusOne, --10
		hands = gear.kurysGloves, --9
		--="Zoar Subligar +1", --6
		feet = gear.ahosiLeggings, --7
		neck = gear.moonlightNeck, --15
		waist = gear.kasiriBelt, --3
		left_ear = gear.crypticEarring, --4
		right_ear = gear.friomisi, --2
		left_ring = gear.eihwazRing, --5
		right_ring = gear.petrov, --4
	}

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- The base for every cast, merged over sets.Idle on every midcast, so any slot it leaves empty
	-- keeps your idle gear.
	sets.Midcast = set_combine(sets.Idle, {

	})
	-- Utsusemi. Other ninjutsu takes a set named for the spell if there is one, then
	-- sets.Midcast.Enhancing for a self-cast, sets.Midcast.Enfeebling for an enfeeble, and
	-- sets.Midcast.Nuke for the rest.
	sets.Midcast.Utsusemi = {
		back = gear.ninFC,
		feet = gear.hattoriFeetPlusOne,
	}
	-- Merged over the Utsusemi set in DT or MEVA mode. Uncomment one to wear damage taken or magic
	-- evasion gear while you cast, at the cost of the Utsusemi pieces in those slots.
	-- sets.Midcast.Utsusemi.DT = {}
	-- sets.Midcast.Utsusemi.MEVA = {}

	-- Worn while your ranged attack is in flight, for ranged accuracy and attack gear. Name the
	-- same shuriken here as in sets.Precast.RA, so the ammo slot keeps it through the throw.
	sets.Midcast.RA = {}
	-- Spell interruption rate down. Used under every midcast except ranged attacks, so any more
	-- specific set overrides it.
	sets.Midcast.SIRD = {}
	-- Worn when you cast a cure from your red mage subjob.
	sets.Midcast.Cure = {}
	-- Merged over the cure set in DT or MEVA mode.
	-- sets.Midcast.Cure.DT = {}
	-- sets.Midcast.Cure.MEVA = {}
	-- Self-cast ninjutsu, such as Tonko and Monomi, and enhancing magic.
	sets.Midcast.Enhancing = {
		hands = gear.mochizukiTekkoPlusThree,
	}
	-- Merged over the enhancing set in DT or MEVA mode. Uncomment one to wear damage taken or magic
	-- evasion gear while you cast, at the cost of the spell's own pieces in those slots.
	-- sets.Midcast.Enhancing.DT = {}
	-- sets.Midcast.Enhancing.MEVA = {}
	-- Enfeebling ninjutsu, such as Kurayami and Hojo, and enfeebling magic, built for magic
	-- accuracy.
	sets.Midcast.Enfeebling = {
		ammo = gear.hydrocera,
		head = gear.hachiyaHeadPlusThree,
		body = gear.malignanceBody,
		hands = gear.mochizukiTekkoPlusThree,
		legs = gear.malignanceLegs,
		feet = gear.malignanceFeet,
		neck = gear.moonlightNeck,
		waist = gear.eschan,
		left_ear = gear.hermetic,
		right_ear = gear.crepuscularEar,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
		back = gear.ninFC,
	}

	-- Merged over the enfeebling set when you cast a spell on one of the engine's lists: MACC for
	-- the accuracy list, Duration for the duration list, such as Bind and Silence.
	sets.Midcast.Enfeebling.MACC = {}
	sets.Midcast.Enfeebling.Duration = {}
	-- Merged over the enfeebling set in ACC mode, before the MACC or Duration set, for magic
	-- accuracy gear.
	sets.Midcast.Enfeebling.ACC = {}
	-- Merged over the enfeebling set in DT or MEVA mode. Uncomment one to wear damage taken or
	-- magic evasion gear while you cast, at the cost of the spell's accuracy.
	-- sets.Midcast.Enfeebling.DT = {}
	-- sets.Midcast.Enfeebling.MEVA = {}

	-- Elemental ninjutsu and elemental magic, built for magic attack.
	sets.Midcast.Nuke = {
		ammo = gear.ghastlyTathlumPlusOne,
		head = gear.mochizukiHeadPlusThree,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.mpacaFeet,
		neck = gear.sanctity,
		waist = gear.orpheusWaist,
		left_ear = gear.hermetic,
		right_ear = gear.friomisi,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
		back = gear.ninFC,
	}

	-- Merged over the nuke set when you cast elemental ninjutsu into a burst window of its element.
	-- Ninjutsu never uses sets.Midcast.Burst, so a burst uses the nuke set plus this child set.
	sets.Midcast.Nuke.Burst = {}

	-- Worn on elemental ninjutsu while Futae is up, since those spells take sets.Midcast.Nuke. A
	-- spell with a set of its own skips it. Futae gear, such as the Hattori Tekko, raises Futae's
	-- damage bonus and must be worn during the cast.
	-- sets.Midcast.Nuke.Futae = {}

	-- Merged over the nuke set in ACC mode, for magic accuracy gear.
	sets.Midcast.Nuke.ACC = {}
	-- Merged over the nuke set in DT or MEVA mode. Uncomment one to wear damage taken or magic
	-- evasion gear while you cast, at the cost of the nuke's damage.
	-- sets.Midcast.Nuke.DT = {}
	-- sets.Midcast.Nuke.MEVA = {}

	-- MB mode, a manual magic burst mode for wearing burst gear on every elemental ninjutsu. In MB
	-- mode, each nuke gets sets.Midcast.Nuke.MB merged over the nuke set, and one the engine
	-- expects to burst also gets the burst child set above. The other two lines start the mode's
	-- idle and engaged sets from copies of DT mode's, so you sit in DT gear between casts.
	sets.Midcast.Nuke.MB = {}
	sets.Idle.MB = set_combine(sets.Idle.DT, {})
	sets.OffenseMode.MB = set_combine(sets.OffenseMode.DT, {})

	-- Sets named for one spell. A spell with its own set uses it instead of the family set.
	sets.Midcast["Stoneskin"] = {waist=gear.siegel,}

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is merged over sets.Idle for every job ability, then the set named for
	-- the ability is merged over it. Any slot left empty keeps your idle gear.
	sets.JA = {}
	sets.JA["Futae"] = {} --hands="Hattori Tekko"
	sets.JA["Provoke"] = sets.Enmity
	sets.JA["Mijin Gakure"] = {}
	sets.JA["Yonin"] = {head = gear.mochizukiHeadPlusThree}
	sets.JA["Innin"] = {head = gear.mochizukiHeadPlusThree}
	sets.JA["Issekigan"] = {}
	sets.JA["Mikage"] = {}

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

	-- Merged over sets.Idle for every weaponskill. The set named for the weaponskill is merged over
	-- it, then the offense mode's set. Any slot left empty keeps your idle gear.
	sets.WS = {
		ammo = gear.yetshilaPlusOne,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.ninjaNodowaPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.odr,
		right_ear = gear.ishvara,
		left_ring = gear.gereRing,
		right_ring = gear.eponas,
		back = gear.ninWSD,
	}

	-- sets.WS.WSD, .CRIT and .MAB are shared sets for the weaponskills below to point to. They are
	-- not offense modes here, so the engine only uses one through a weaponskill that points to it.
	-- No weaponskill uses WSD yet. To use it, point a weaponskill's line below at it, such as
	-- sets.WS["Blade: Ku"] = sets.WS.WSD, and that weaponskill wears sets.WS with these rings
	-- merged over it.
	sets.WS.WSD = set_combine({
		left_ring = gear.epimanondas,
		right_ring = gear.karieyhRingPlusOne,
	})

	-- Worn on weaponskills in ACC mode, over the set named for the weaponskill. List only the
	-- pieces the mode changes, since every slot named here overrides the weaponskill's own set. A
	-- weaponskill with an ACC set of its own, sets.WS['<name>'].ACC, takes that instead. The other
	-- mode sets work the same way, except that sets.WS.TP is never merged.
	sets.WS.ACC = set_combine({
		head = gear.kendatsubaHeadPlusOne,
		body = gear.kendatsubaBodyPlusOne,
		hands = gear.kendatsubaHandsPlusOne,
		legs = gear.kendatsubaLegsPlusOne,
		feet = gear.kendatsubaFeetPlusOne,
	})

	sets.WS.CRIT = {
		ammo = gear.yetshilaPlusOne,
		head = gear.adhemarHeadPlusOnePathA,
		body = gear.kendatsubaBodyPlusOne,
		hands = gear.adhemarHandsPlusOnePathA,
		legs = gear.samnuhaTightsDA,
		feet = gear.herculeanBootsCrit,
		neck = gear.ninjaNodowaPlusTwo,
		waist = gear.windbuffetPlusOne,
		left_ear = gear.odr,
		right_ear = gear.ishvara,
		left_ring = gear.gereRing,
		right_ring = gear.eponas,
		back = gear.ninDA,
	}
	sets.WS.MAB = set_combine({
		ammo = gear.seethingBombletPlusOne,
		neck = gear.sanctity,
		waist = gear.eschan,
		left_ear = gear.moonshadeEarringAcc,
		right_ear = gear.friomisi,
		left_ring = gear.epimanondas,
		right_ring = gear.dingir,
		back = gear.ninFC,
	})

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

	-- Sets named for each weaponskill.
	sets.WS["Blade: Rin"] = sets.WS.CRIT
	sets.WS["Blade: Retsu"] = {}
	sets.WS["Blade: Teki"] = sets.WS.MAB
	sets.WS["Blade: To"] = sets.WS.MAB
	sets.WS["Blade: Chi"] = sets.WS.MAB
	sets.WS["Blade: Ei"] = set_combine(sets.WS.MAB, {head=gear.pixieHead, left_ring=gear.archonRing})
	sets.WS["Blade: Jin"] = sets.WS.CRIT
	sets.WS["Blade: Ten"] = {}
	sets.WS["Blade: Ku"] = {}
	sets.WS["Blade: Kamu"] = {}
	sets.WS["Blade: Yu"] = sets.WS.MAB
	sets.WS["Blade: Hi"] = sets.WS.CRIT
	sets.WS["Blade: Shun"] = {}

	sets.WS["Asuran Fists"] = {
		ammo = gear.yetshilaPlusOne,
		head = gear.kendatsubaHeadPlusOne,
		body = gear.kendatsubaBodyPlusOne,
		hands = gear.kendatsubaHandsPlusOne,
		legs = gear.kendatsubaLegsPlusOne,
		feet = gear.kendatsubaFeetPlusOne,
		neck = gear.fotiaNeck,
		waist = gear.fotiaWaist,
		left_ear = gear.odr,
		right_ear = gear.ishvara,
		left_ring = gear.gereRing,
		right_ring = gear.hetairoi,
		back = gear.ninWSD,
	}

	sets.WS["Savage Blade"] = {
		ammo = gear.oshashaTreatise,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.ninjaNodowaPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear = gear.ishvara,
		left_ring = gear.epimanondas,
		right_ring = gear.corneliaRing,
		back = gear.ninWSD,
	}

	-- Dagger weaponskills, for the Aeolian Edge and Ninjitsu modes. Aeolian Edge is on the engine's
	-- list of magical weaponskills, so the day, weather and distance pieces the engine picks go on
	-- over its set. To wear sets.WS.MAB for it, point its line at that set, as the magical Blade
	-- weaponskills above do.
	sets.WS["Aeolian Edge"] = {}
	sets.WS["Evisceration"] = {}

	-- Child sets for a single weaponskill, used instead of the general sets.WS ones: one for a
	-- mode, one for HighBuff, and one for the two together. Once declared, each one replaces the
	-- general set for that weaponskill even if it is empty, so only uncomment a line after you fill
	-- it in. The mode and HighBuff line also needs the mode line above it.
	-- sets.WS['Blade: Ten'].ACC = {}
	-- sets.WS['Blade: Ten'].HighBuff = {}
	-- sets.WS['Blade: Ten'].ACC.HighBuff = {}

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

-- The engine calls Cycle_Timer about every 2 seconds. It skips the call during an action and while
-- you are dead, charmed or asleep. This one rebuilds sets.Movement for the game hour: Night from
-- 18:00 to 6:00, Dusk from 17:00 to 18:00 and from 6:00 to 7:00, and Day otherwise.
function Cycle_Timer()
	if world.time >= 17*60 or world.time <= 7*60 then
		if world.time >= (18*60) or world.time <= (6*60) then
			sets.Movement = set_combine(sets.Movement_Base, sets.Movement_Night)
			log('Night Feet')
		else
			sets.Movement = set_combine(sets.Movement_Base, sets.Movement_Dusk)
			log('Dusk Feet')
		end
	else
		sets.Movement = set_combine(sets.Movement_Base, sets.Movement_Day)
		log('Day Feet')
	end
end
