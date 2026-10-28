-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: Paladin. A sample to copy into your character's folder and fill in.
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

-- The item that "gs c food" uses.
Food = "Miso Ramen"

-- The offense modes this job cycles through, instead of the engine's default TP, ACC and DT. Each
-- mode needs a sets.OffenseMode.<Mode> and a sets.Idle.<Mode> below, and can also have a
-- sets.WS.<Mode>.
state.OffenseMode:options('TP','ACC','DT','PDT','MEVA','AoE')

-- Names for the two job-specific modes, JobMode and JobMode2. A named mode is shown in the status
-- box, and an empty name hides it.
UI_Name = ''
UI_Name2 = ''


-- Weapon modes. Each one needs a sets.Weapons['<Mode>'] of the same name below.
state.WeaponMode:options('Burtgang','Naegling','Club','Shining One')
state.WeaponMode:set('Burtgang')

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

-- Called once at load, below, to pick the macro set for the subjob. With any subjob but RUN it also
-- selects DT mode, and with BLU it loads the tanking spell set through the AzureSets addon.
function Macro_Sub_Job()
	local macro = 1
	if player.sub_job == "BLU" then
		state.OffenseMode:set('DT')
		macro = 1
		send_command('wait 2;aset set tanking')
	elseif player.sub_job == "RUN" then
		macro = 1
	else
		state.OffenseMode:set('DT')
		macro = 1
	end
	return macro
end

-- The tanking spell set that Macro_Sub_Job loads with "aset set tanking", in the form the AzureSets
-- addon stores it.

--[[
	<tanking>
		<slot01>healing breeze</slot01>
		<slot02>sheep song</slot02>
		<slot03>wild carrot</slot03>
		<slot04>pollen</slot04>
		<slot05>terror touch</slot05>
		<slot06>grand slam</slot06>
		<slot07>cocoon</slot07>
		<slot08>jettatura</slot08>
		<slot09>blank gaze</slot09>
		<slot10>screwdriver</slot10>
		<slot11>geist wall</slot11>
		<slot12>sandspin</slot12>
	</tanking>
]]--

-- The lockstyle set, macro book and macro set that jobsetup applies at load.
LockStylePallet = "13"
MacroBook = "5"
MacroSet = Macro_Sub_Job()

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

--
-- HP balancing: 2800 HP
-- MP balancing: 900 MP
--

function get_sets()

	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	-- Weapon sets, one per weapon mode above.
	sets.Weapons = {}

	sets.Weapons['Burtgang'] = {
		main = gear.burtgang,
	}

	sets.Weapons['Naegling'] = {
		main = gear.naegling,
	}

	sets.Weapons['Club'] = {
		main = gear.berylliumMacePlusOne,
	}

	sets.Weapons['Shining One'] = {
		main = gear.shiningOne,
		sub = gear.alberStrap,
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active,
	-- engaged or idle.
	sets.Weapons.Shield = {}

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
		ammo = gear.homiliary,
		head = gear.sakpataHead, -- 7
		body = gear.sakpataBody, -- 10
		hands = gear.sakpataHands, -- 8
		legs = gear.sakpataLegs, -- 9
		feet = gear.sakpataFeet, -- 6
		neck = gear.unmovingPlusOne,
		waist = gear.carriers,
		left_ear = gear.odnowaPlusOne, -- 3
		right_ear = gear.sanareEarring,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.pldEnmityMeva,
	}

	-- Worn over sets.Idle while idle in the matching offense mode.
	sets.Idle.TP = set_combine( sets.Idle, {
		sub = gear.duban,
	})

	sets.Idle.ACC = set_combine( sets.Idle, {})

	sets.Idle.DT = set_combine( sets.Idle, {
		sub = gear.aegis,
		ammo = gear.staunchPlusOne,
	})

	sets.Idle.PDT = set_combine( sets.Idle, {
		sub = gear.ochain,
		waist = gear.flumeBeltPlusOne,
		right_ear = gear.etherealEarring,
	})

	sets.Idle.MEVA = set_combine( sets.Idle, {
		sub = gear.aegis,
		ammo = gear.staunchPlusOne,
		neck = gear.warderCharmPlusOne,
		right_ear = gear.sanareEarring,
		waist = gear.platinumMoogleBelt,
	})

	sets.Idle.AoE = set_combine( sets.Idle, {
		waist = gear.flumeBeltPlusOne,
	})

	-- Merged over the idle set while Sublimation is charging.
	sets.Idle.Sublimation = {}

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
		ammo = gear.staunchPlusOne,
		legs = gear.carmineLegsPlusOnePathA,
		right_ear = gear.chevalierEarringPlusOne,
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

	-- The ring slot Zodiac Ring goes in when an elemental spell matches the day's element:
	-- "right_ring" or "left_ring".
	Elemental_Bonus_Ring_Slot = "right_ring"

	-- Worn while using a Holy Water or Hallowed Water.
	sets.Holy_Water = {
		neck = gear.nicander,
	}

	-- ===================================================================================================================
	--		sets.OffenseMode
	-- ===================================================================================================================

	-- The engaged base, merged first in every offense mode. The mode's own set is merged over it.
	sets.OffenseMode = set_combine( sets.Idle, {
		ammo = gear.coiste,
		head = gear.hjarrandiHead,
		body = gear.dagonBreastplate,
		hands = gear.sakpataHands,
		legs = gear.sakpataLegs,
		feet = gear.sakpataFeet,
		neck = gear.vimPlusOne,
		waist = gear.sailfi,
		left_ear = gear.telos,
		right_ear = gear.crepuscularEar,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.pldDA,
	})

	sets.OffenseMode.TP = set_combine( sets.OffenseMode, {

	})

	sets.OffenseMode.ACC = set_combine( sets.OffenseMode, {

	})

	sets.OffenseMode.DT = set_combine( sets.OffenseMode, {
		body = gear.sakpataBody,
		neck = gear.unmovingPlusOne,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.telos,
	})

	-- PDT mode, built on sets.Idle.PDT.
	sets.OffenseMode.PDT = set_combine( sets.Idle.PDT, {
		waist = gear.flumeBeltPlusOne,
	})

	-- MEVA mode, built on sets.Idle.MEVA.
	sets.OffenseMode.MEVA = set_combine( sets.Idle.MEVA, {
		left_ear = gear.telos,
		right_ear = gear.chevalierEarringPlusOne,
		left_ring = gear.lehkoHabhokaRing,
		back = gear.nullShawl,
	})

	-- AoE mode, built on sets.Idle.AoE.
	sets.OffenseMode.AoE = set_combine( sets.Idle.AoE, {

	})

	-- Aftermath sets, merged over the engaged set while that level of Aftermath is up. A child
	-- named for a weapon mode adds gear for that weapon alone, so Burtgang's Aftermath gear goes
	-- in the Burtgang children, which are not worn once you change to another weapon mode.
	sets.OffenseMode.AM1 = {}
	sets.OffenseMode.AM2 = {}
	sets.OffenseMode.AM3 = {}
	sets.OffenseMode.AM1['Burtgang'] = {}
	sets.OffenseMode.AM2['Burtgang'] = {}
	sets.OffenseMode.AM3['Burtgang'] = {}

	-- Treasure Hunter gear. While TH Mode is Tag or Full Time, it is worn for an action aimed at an
	-- untagged monster and while engaged on one. Full Time also keeps it on whenever engaged. TH
	-- Mode starts at None, which never wears it, on every job but Thief.
	sets.TreasureHunter = {
		ammo = gear.perfectEgg,
		body = gear.volteJupon,
		waist = gear.chaac,
	}

	-- Enmity gear that the spells, job abilities and Atonement below are built from. The engine
	-- does not automatically merge this set into any others.
	sets.Enmity = { -- Goal is 200 total -Crusade is 30 and Burtang is 23
		ammo = gear.sapience, -- 2
		head = gear.loessBarbutaPlusOne, -- 24
		body = gear.souveranBodyPlusOnePathC, -- 20
		hands = gear.souveranHandsPlusOnePathC, -- 9
		legs = gear.souveranLegsPlusOnePathC, -- 9
		feet = gear.souveranFeetPlusOnePathC, -- 9
		neck = gear.moonlightNeck, -- 15
		waist = gear.creedBaudrier, -- 5
		left_ear = gear.truxEarring, -- 5
		right_ear = gear.crypticEarring, -- 5
		left_ring = gear.apeileRingPlusOne, -- 9
		right_ring = gear.eihwazRing, -- 5
		back = gear.pldEnmityMeva, -- 10
	} -- 127 in gear with Burtang (163 with Crusade)

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Every precast starts from sets.Idle, except a pet command's. For a spell, sets.Precast is
	-- merged over it, then the fast cast set. Any slot left empty keeps your idle gear.
	sets.Precast = {}

	-- Fast cast gear, worn at the start of every spell.
	sets.Precast.FastCast = { -- 61 FC with 3029/890
		ammo = gear.sapience, -- 2
		head = gear.carmineHeadPlusOnePathD, -- 14
		body = gear.reverenceBodyPlusThree, -- 10
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.odysseanCuissesFCB, -- 6
		feet = gear.odysseanGreavesFC, -- 11
		neck = gear.voltsurge, -- 4
		waist = gear.platinumMoogleBelt,
		left_ear = gear.etiolation, -- 1
		right_ear = gear.tuisto,
		left_ring = gear.weatherspoon, -- 5
		right_ring = gear.kishar, -- 4
		back = gear.pldFCB, -- 10
	}

	-- Merged over the fast cast set for Cure, Curaga and Cura spells.
	sets.Precast.Cure = {
		left_ring = gear.rahabRing,
	}

	-- Merged over the fast cast set when you cast a healing spell other than a cure, such as Raise
	-- or a -na spell.
	sets.Precast.Healing = {}

	-- Merged over the fast cast set when you cast enhancing magic.
	sets.Precast.Enhancing = {}

	-- Merged over the fast cast set when you cast Utsusemi.
	sets.Precast.Utsusemi = {}

	-- Merged over the fast cast set when you cast blue magic.
	sets.Precast.BlueMagic = {}

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- The base for every cast, merged over sets.Idle on every midcast, so any slot it leaves empty
	-- keeps your idle gear.
	sets.Midcast = set_combine( sets.Idle, {

	})

	-- Spell interruption rate down. Used under every midcast except ranged attacks, so any more
	-- specific set overrides it.
	sets.Midcast.SIRD = {
		ammo = gear.staunchPlusOne, -- 11
		head = gear.souveranHeadPlusOnePathC, -- 20
		legs = gear.founderHoseMacc, -- 30
		neck = gear.moonlightNeck, -- 15
		waist = gear.audumbla, -- 10
		back = gear.pldCure, -- 10
	} -- 96 +10 merits = 106

	-- Magic evasion gear for every spell you cast in MEVA mode. It goes on top of the spell
	-- interruption set, and the spell's own set goes on top of it.
	sets.Midcast.MEVA = set_combine( sets.Idle.MEVA, {
		sub = gear.aegis,
		ammo = gear.staunchPlusOne,
		neck = gear.warderCharmPlusOne,
		right_ear = gear.sanareEarring,
		waist = gear.platinumMoogleBelt,
	})

	-- The commented DT and MEVA children below go over their casting set in those offense modes.
	-- Put damage taken or magic evasion pieces in one, at some cost to what the set is for, and
	-- uncomment it. In MEVA mode sets.Midcast.MEVA already goes under every casting set, so a MEVA
	-- child needs only the slots its casting set names. The ones filled in below hold
	-- sets.Midcast.MEVA's pieces for those slots, so magic evasion wins there. The cure set's MEVA
	-- child is commented, so a cure keeps its own gear in every slot the cure set names.

	-- Cure spells, built with spell interruption rate down.
	sets.Midcast.Cure = {
		ammo = gear.staunchPlusOne, -- 11 SIRD / 3 DT
		head = gear.sakpataHead, -- 7 DT / 5 Cure
		body = gear.sakpataBody,
		hands = gear.sakpataHands, -- 8 DT
		legs = gear.founderHoseMacc, -- 30 SIRD
		feet = gear.odysseanGreavesCure, -- 20 SIRD / 13 Cure
		neck = gear.moonlightNeck, -- 15 SIRD
		waist = gear.platinumMoogleBelt, -- 3 DT
		left_ear = gear.nourishingEarringPlusOne, -- 5 SIRD / 6 Cure
		right_ear = gear.chevalierEarringPlusOne, -- 3 DT / 11 Cure
		left_ring = gear.moonlightRing1, -- 5 DT
		right_ring = gear.defending, -- 10 DT
		back = gear.pldCure, -- 10 SIRD / 10 Cure
	} -- 91 + 10 Merits = 101 SIRD / 49 DT / 56 Cure

	-- Merged over the cure set when you cast a cure on yourself.
	sets.Midcast.Cure.Self = {}

	-- Merged over the cure set when you cast a cure on anyone else, or on yourself under Accession.
	sets.Midcast.Cure.Others = {}

	-- Merged over the cure set in DT or MEVA mode.
	-- sets.Midcast.Cure.DT = {}
	-- sets.Midcast.Cure.MEVA = {}

	-- Enhancing magic. Raise and the other healing spells that are not cures use it too.
	sets.Midcast.Enhancing = {
		ammo = gear.staunchPlusOne,
		head = gear.souveranHeadPlusOnePathC,
		body = gear.sakpataBody,
		hands = gear.sakpataHands,
		legs = gear.founderHoseMacc,
		feet = gear.sakpataFeet,
		neck = gear.moonlightNeck,
		waist = gear.audumbla,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.chevalierEarringPlusOne,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.pldCure,
	}

	-- Merged over the enhancing set when you cast an enhancing spell on someone else, or on
	-- yourself under Accession.
	sets.Midcast.Enhancing.Others = {}

	-- Merged over the enhancing set in DT or MEVA mode.
	-- sets.Midcast.Enhancing.DT = {}
	sets.Midcast.Enhancing.MEVA = {
		ammo = gear.staunchPlusOne,
		head = gear.sakpataHead,
		body = gear.sakpataBody,
		hands = gear.sakpataHands,
		legs = gear.sakpataLegs,
		feet = gear.sakpataFeet,
		neck = gear.warderCharmPlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.sanareEarring,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.pldEnmityMeva,
	}

	-- Merged over the enhancing set when you cast Refresh.
	sets.Midcast.Refresh = {}

	-- Merged over the enhancing set when you cast a Regen spell.
	sets.Midcast.Regen = {}

	-- Merged over the enhancing set for elemental bar spells.
	sets.Midcast.Enhancing.Elemental = {}

	-- Merged over the enhancing set for status bar spells.
	sets.Midcast.Enhancing.Status = {}

	-- Merged over the enhancing set for the storm spells.
	sets.Storms = {}

	-- Merged over the Refresh, Regen, bar spell and storm sets in MEVA mode.
	-- sets.Midcast.Refresh.MEVA = {}
	-- sets.Midcast.Regen.MEVA = {}
	-- sets.Midcast.Enhancing.Elemental.MEVA = {}
	-- sets.Midcast.Enhancing.Status.MEVA = {}
	-- sets.Storms.MEVA = {}

	-- Divine magic, such as Holy, Banish and Enlight. Flash has a set of its own below.
	sets.Midcast.Divine = set_combine( sets.Idle, sets.Enmity, sets.Midcast.SIRD, {

	})

	-- Merged over the divine set when you cast Enlight or Enlight II, for divine magic skill gear.
	sets.Midcast.Divine['Enlight'] = {}
	sets.Midcast.Divine['Enlight II'] = sets.Midcast.Divine['Enlight']

	-- Merged over the divine set in DT or MEVA mode.
	-- sets.Midcast.Divine.DT = {}
	sets.Midcast.Divine.MEVA = {
		ammo = gear.staunchPlusOne,
		head = gear.sakpataHead,
		body = gear.sakpataBody,
		hands = gear.sakpataHands,
		legs = gear.sakpataLegs,
		feet = gear.sakpataFeet,
		neck = gear.warderCharmPlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.sanareEarring,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.pldEnmityMeva,
	}

	-- Enfeebling magic, built for magic accuracy.
	sets.Midcast.Enfeebling = {}
	-- Merged over the enfeebling set in DT or MEVA mode.
	-- sets.Midcast.Enfeebling.DT = {}
	-- sets.Midcast.Enfeebling.MEVA = {}

	-- Merged over the enfeebling set when you cast a spell on the engine's accuracy list, such as
	-- Dispel or, from your dark knight subjob, Poisonga.
	sets.Midcast.Enfeebling.MACC = {}

	-- Dark magic from your dark knight subjob. Stun takes the MACC set merged over it.
	sets.Midcast.Dark = {}
	-- Merged over the dark magic set in DT or MEVA mode.
	-- sets.Midcast.Dark.DT = {}
	-- sets.Midcast.Dark.MEVA = {}
	sets.Midcast.Dark.MACC = {}

	-- Blue magic from your blue mage subjob. The engine never wears sets.Midcast.BlueMagic itself.
	-- It sorts each blue spell into one of the sets below by its own lists: Enmity for spells
	-- such as Jettatura, Sheep Song and Geist Wall, Healing for Healing Breeze and Wild Carrot,
	-- Buff for Cocoon, Nuke for Bomb Toss and Cursed Sphere, which pull a group from range, and
	-- ACC for Cold Wave.
	sets.Midcast.BlueMagic = {}
	sets.Midcast.BlueMagic.Enmity = {}
	sets.Midcast.BlueMagic.Healing = {}
	-- Merged over the blue magic healing set in DT or MEVA mode.
	-- sets.Midcast.BlueMagic.Healing.DT = {}
	-- sets.Midcast.BlueMagic.Healing.MEVA = {}
	sets.Midcast.BlueMagic.Buff = {}
	-- Merged over the blue magic buff set in DT or MEVA mode.
	-- sets.Midcast.BlueMagic.Buff.DT = {}
	-- sets.Midcast.BlueMagic.Buff.MEVA = {}
	sets.Midcast.BlueMagic.Nuke = {}
	-- Merged over the blue magic nuke set in DT or MEVA mode.
	-- sets.Midcast.BlueMagic.Nuke.DT = {}
	-- sets.Midcast.BlueMagic.Nuke.MEVA = {}
	sets.Midcast.BlueMagic.ACC = {}
	-- Merged over the blue magic accuracy set in DT or MEVA mode.
	-- sets.Midcast.BlueMagic.ACC.DT = {}
	-- sets.Midcast.BlueMagic.ACC.MEVA = {}

	-- Merged over the blue magic enmity set in DT or MEVA mode.
	-- sets.Midcast.BlueMagic.Enmity.DT = {}
	-- sets.Midcast.BlueMagic.Enmity.MEVA = {}

	-- Sets named for one spell. A spell with its own set uses it instead of the family set, except
	-- Phalanx, whose set is merged over the enhancing set.
	sets.Midcast["Stoneskin"] = {
		waist = gear.siegel,
	}

	sets.Midcast["Phalanx"] = set_combine( sets.Idle, sets.Midcast.SIRD, {
		hands = gear.regalGauntlets,
		legs = gear.sakpataLegs,
		feet = gear.souveranFeetPlusOnePathC, -- 9
	})


	sets.Midcast["Reprisal"] = { -- Block rate is based off HP
		ammo = gear.staunchPlusOne,
		head = gear.souveranHeadPlusOnePathC,
		body = gear.souveranBodyPlusOnePathC,
		hands = gear.regalGauntlets,
		legs = gear.carmineLegsPlusOnePathA,
		feet = gear.souveranFeetPlusOnePathC,
		neck = gear.unmovingPlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.tuisto,
		left_ring = gear.moonlightRing,
		right_ring = gear.moonlightRing,
		back = gear.pldCure,
	}

	sets.Midcast["Flash"] = set_combine( sets.Idle, sets.Enmity, sets.Midcast.SIRD, {

	})

	-- Merged over the Flash set in DT or MEVA mode.
	-- sets.Midcast["Flash"].DT = {}
	sets.Midcast["Flash"].MEVA = {
		ammo = gear.staunchPlusOne,
		head = gear.sakpataHead,
		body = gear.sakpataBody,
		hands = gear.sakpataHands,
		legs = gear.sakpataLegs,
		feet = gear.sakpataFeet,
		neck = gear.warderCharmPlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.sanareEarring,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.pldEnmityMeva,
	}

	-- Merged over the Stoneskin, Phalanx and Reprisal sets in MEVA mode. Each holds
	-- sets.Midcast.MEVA's pieces for the slots its set names.
	sets.Midcast["Stoneskin"].MEVA = {
		waist = gear.platinumMoogleBelt,
	}
	sets.Midcast["Phalanx"].MEVA = {
		ammo = gear.staunchPlusOne,
		head = gear.sakpataHead,
		body = gear.sakpataBody,
		hands = gear.sakpataHands,
		legs = gear.sakpataLegs,
		feet = gear.sakpataFeet,
		neck = gear.warderCharmPlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.sanareEarring,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.pldEnmityMeva,
	}
	sets.Midcast["Reprisal"].MEVA = {
		ammo = gear.staunchPlusOne,
		head = gear.sakpataHead,
		body = gear.sakpataBody,
		hands = gear.sakpataHands,
		legs = gear.sakpataLegs,
		feet = gear.sakpataFeet,
		neck = gear.warderCharmPlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.sanareEarring,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.pldEnmityMeva,
	}

	-- Foil, from your rune fencer subjob, wears the enhancing set. A set of its own is worn in
	-- the enhancing set's place, so uncomment this line to wear the enmity set for Foil instead.
	-- sets.Midcast["Foil"] = set_combine(sets.Enmity, {})

	-- Worn over the idle and engaged sets while Cover is up, as one table under both keys. The
	-- Caballarius Surcoat turns part of the physical damage taken while covering into MP.
	sets.Idle.Cover = {
		body = gear.caballariusBodyPlusThree
	}
	sets.OffenseMode.Cover = sets.Idle.Cover

	-- Merged over every spell's midcast while Rampart is up. Rampart is a job ability, so this is
	-- not the set worn to use it. That one is sets.JA["Rampart"] below.
	-- sets.Midcast.Rampart = {}

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is merged over sets.Idle for every job ability, then the set named for
	-- the ability is merged over it. Any slot left empty keeps your idle gear.
	sets.JA = {}
	sets.JA["Invincible"] = set_combine( sets.Enmity, { legs = gear.caballariusLegsPlusThree })
	sets.JA["Shield Bash"] = set_combine( sets.Enmity, { hands = gear.caballariusHandsPlusThree })
	sets.JA["Holy Circle"] = set_combine( sets.Enmity, { })
	sets.JA["Sentinel"] = set_combine( sets.Enmity, { feet = gear.caballariusFeetPlusThree })
	sets.JA["Cover"] = set_combine( sets.Enmity, { }) -- Need AF head
	sets.JA["Provoke"] = set_combine( sets.Enmity, { })
	sets.JA["Rampart"] = set_combine( sets.Enmity, { head = gear.caballariusHeadPlusThree })
	sets.JA["Divine Emblem"] = set_combine( sets.Enmity, { })
	sets.JA["Sepulcher"] = set_combine( sets.Enmity, { })
	sets.JA["Palisade"] = set_combine( sets.Enmity, { })
	sets.JA["Intervene"] = set_combine( sets.Enmity, { })
	sets.JA["Fealty"] = set_combine( sets.Enmity, { body = gear.caballariusBodyPlusThree })
	sets.JA["Chivalry"] = set_combine( sets.Enmity, { hands = gear.caballariusHandsPlusThree })
	sets.JA["Majesty"] = set_combine( sets.Enmity, { })
	sets.JA["Berserk"] = set_combine( sets.Enmity, { })
	sets.JA["Defender"] = set_combine( sets.Enmity, { })
	sets.JA["Aggressor"] = set_combine( sets.Enmity, { })

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
		ammo = gear.oshashaTreatise,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.fotiaNeck,
		waist = gear.sailfi,
		left_ear = gear.ishvara,
		right_ear = gear.moonshadeEarringAcc,
		left_ring = gear.epimanondas,
		right_ring = gear.corneliaRing,
		back = gear.pldWSD,
	}
	-- Worn on weaponskills in ACC mode, over the set named for the weaponskill. List only the
	-- pieces the mode changes, since every slot named here overrides the weaponskill's own set. A
	-- weaponskill with an ACC set of its own, sets.WS['<name>'].ACC, takes that instead. The other
	-- mode sets work the same way, except that sets.WS.TP is never merged.
	sets.WS.ACC = {}

	-- A building block for weaponskill damage. WSD is not an offense mode, so this set is worn
	-- only through the sets built from it, such as Savage Blade below.
	sets.WS.WSD = {}

	-- Read only in a CRIT offense mode. To use it, add 'CRIT' to state.OffenseMode:options above,
	-- declare sets.OffenseMode.CRIT and sets.Idle.CRIT, and uncomment this line. It is then merged
	-- over each weaponskill in that mode.
	-- sets.WS.CRIT = {}

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
	sets.WS.AM1['Burtgang'] = {}
	sets.WS.AM2['Burtgang'] = {}
	sets.WS.AM3['Burtgang'] = {}

	-- Sword weaponskills.
	sets.WS["Fast Blade"] = {}
	sets.WS["Burning Blade"] = {}
	sets.WS["Red Lotus Blade"] = {}
	sets.WS["Flat Blade"] = {}
	sets.WS["Shining Blade"] = {}
	sets.WS["Seraph Blade"] = {}
	sets.WS["Circle Blade"] = {}
	sets.WS["Spirits Within"] = {}
	sets.WS["Swift Blade"] = {}
	sets.WS["Vorpal Blade"] = {}
	sets.WS["Savage Blade"] = sets.WS.WSD
	sets.WS["Atonement"] = sets.Enmity
	sets.WS["Chant du Cygne"] = {}
	sets.WS["Requiescat"] = {}

	-- Child sets for a single weaponskill, used instead of the general sets.WS ones: one for a
	-- mode, one for HighBuff, and one for the two together. Once declared, each one replaces the
	-- general set for that weaponskill even if it is empty, so only uncomment a line after you fill
	-- it in. The mode and HighBuff line also needs the mode line above it.
	-- sets.WS['Chant du Cygne'].ACC = {}
	-- sets.WS['Chant du Cygne'].HighBuff = {}
	-- sets.WS['Chant du Cygne'].ACC.HighBuff = {}

	-- A place for sets of your own. The engine never uses sets.Custom on its own, so use it from
	-- the hooks below.
	sets.Custom = {}

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

	-- Tell the party when Rampart, Sentinel or Invincible wears off.
	if name == "Rampart" and not gain then
		send_command('input /p Rampart [OFF]')
	elseif name == "Sentinel" and not gain then
		send_command('input /p Sentinel [OFF]')
	elseif name == "Invincible" and not gain then
		send_command('input /p Invincible [OFF]')
	end

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
