

-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The item that "gs c food" uses.
Food = "Miso Ramen"

-- The offense modes this job cycles through, in place of the engine's default TP, ACC and DT.
-- Each mode needs a sets.OffenseMode.<Mode> and a sets.Idle.<Mode> below, and can also have
-- a sets.WS.<Mode>.
state.OffenseMode:options('TP','ACC','DT','PDT','MEVA','AoE')

-- Names for the two job-specific modes, JobMode and JobMode2. A named mode is shown in the
-- status box, and an empty name hides it.
UI_Name = ''
UI_Name2 = ''


-- Weapon modes. Each one needs a sets.Weapons['<Mode>'] of the same name below.
state.WeaponMode:options('Burtgang','Naegling','Club','Shining One')
state.WeaponMode:set('Burtgang')

-- Called once at load, below, to pick the macro set for the subjob. With any subjob but RUN it
-- also selects DT mode, and with BLU it loads the tanking spell set through the AzureSets addon.
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

-- The tanking spell set that Macro_Sub_Job loads with "aset set tanking", in the form the
-- AzureSets addon stores it.

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

-- Blue magic lists for a BLU subjob. They replace the engine's lists of the same names, which
-- decide the sets.Midcast.BlueMagic family set each blue spell takes.
BlueNuke = S{'Spectral Floe','Entomb', 'Magic Hammer', 'Tenebral Crush'}
BlueHealing = S{'Magic Fruit', 'Healing Breeze','Pollen', 'Wild Carrot'}
BlueSkill = S{'Occultation','Erratic Flutter','Nat. Meditation','Cocoon','Barrier Tusk','Metallic Body','Mighty Guard'}
BlueTank = S{'Jettatura','Blank Gaze','Sheep Song','Geist Wall'}

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

	-- Weapon sets, one per weapon mode above.
	sets.Weapons = {}

	sets.Weapons['Burtgang'] = {
		main = gear.burtgang,
	}

	sets.Weapons['Naegling'] = {
		main=gear.naegling,
	}

	sets.Weapons['Club'] = {
		main=gear.berylliumMacePlusOne,
	}

	sets.Weapons['Shining One'] = {
		main=gear.shiningOne,
		sub=gear.alberStrap,
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active,
	-- engaged or idle.
	sets.Weapons.Shield = {}

	-- Worn while idle. Every action's precast and midcast also start from this set, so a slot
	-- their sets leave out keeps its idle piece.
	sets.Idle = {
		ammo=gear.homiliary,
		head=gear.sakpataHead, -- 7
		body = gear.sakpataBody, -- 10
		hands = gear.sakpataHands, -- 8
		legs=gear.sakpataLegs, -- 9
		feet=gear.sakpataFeet, -- 6
		neck = gear.unmovingPlusOne,
		waist=gear.carriers,
		left_ear = gear.odnowaPlusOne, -- 3
		right_ear=gear.sanareEarring,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.pldEnmityMeva,
	}

	-- Worn over sets.Idle while idle in the matching offense mode.
	sets.Idle.TP = set_combine( sets.Idle, {
		sub=gear.duban,
	})

	sets.Idle.ACC = set_combine( sets.Idle, {})

	sets.Idle.DT = set_combine( sets.Idle, {
		sub=gear.aegis,
		ammo=gear.staunchPlusOne,
	})

	sets.Idle.PDT = set_combine( sets.Idle, {
		sub=gear.ochain,
	    waist=gear.flumeBeltPlusOne,
		right_ear=gear.etherealEarring,
	})

	sets.Idle.MEVA = set_combine( sets.Idle, {
		sub=gear.aegis,
		ammo=gear.staunchPlusOne,
		neck=gear.warderCharmPlusOne,
		right_ear=gear.sanareEarring,
		waist=gear.platinumMoogleBelt,
	})

	-- In MEVA mode, midcast_custom below merges this over every action's midcast except Cure
	-- spells.
	sets.MEVA = set_combine( sets.Idle.MEVA, {
		sub=gear.aegis,
		ammo=gear.staunchPlusOne,
		neck=gear.warderCharmPlusOne,
		right_ear=gear.sanareEarring,
		waist=gear.platinumMoogleBelt,
	})

	sets.Idle.AoE = set_combine( sets.Idle, {
		waist=gear.flumeBeltPlusOne,
	})

	-- Worn over the idle set while a Phantom Roll on you stands at 11. It is for the Roller's
	-- Ring, which any job can wear and which gives Refresh +1 and Regain +10 at an 11, for example
	-- left_ring="Roller's Ring". It applies in every offense mode. It is worn only while idle, so
	-- any action swaps it out and it comes back when the action ends. While moving, a ring here
	-- replaces the movement set's ring in the same slot. This file's sets.Movement names no ring,
	-- so either slot is free.
	sets.Idle.XIRoll = {}

	-- The TP-mode form, merged after sets.Idle.XIRoll while idle in TP mode.
	sets.Idle.TP.XIRoll = {}

	-- Worn over the idle set while moving and not engaged.
	sets.Movement = {
		ammo=gear.staunchPlusOne,
		legs = gear.carmineLegsPlusOnePathA,
		right_ear=gear.chevalierEarringPlusOne,
    }

	-- Worn when another character on this machine, running this engine, casts on you. Spell
	-- Received mode must be ON. sets.Cursna_Received is also the Doom set, worn when that mode is OFF.
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

	-- The ring slot Zodiac Ring goes in when a spell's element matches the day: "right_ring" or
	-- "left_ring".
	Elemental_Bonus_Ring_Slot = "right_ring"

	-- Worn while using a Holy Water or Hallowed Water.
	sets.Holy_Water = {
	    neck=gear.nicander,
	}

	-- The engaged base, merged first in every offense mode. The mode's own set goes over it.
	sets.OffenseMode = set_combine( sets.Idle, {
		ammo = gear.coiste,
		head=gear.hjarrandiHead,
		body=gear.dagonBreastplate,
		hands = gear.sakpataHands,
		legs=gear.sakpataLegs,
		feet=gear.sakpataFeet,
		neck = gear.vimPlusOne,
		waist = gear.sailfi,
		left_ear=gear.telos,
		right_ear=gear.crepuscularEar,
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
		waist=gear.flumeBeltPlusOne,
	})

	-- MEVA mode, built on sets.Idle.MEVA.
	sets.OffenseMode.MEVA = set_combine( sets.Idle.MEVA, {
		left_ear=gear.telos,
		right_ear=gear.chevalierEarringPlusOne,
		left_ring=gear.lehkoHabhokaRing,
		back=gear.nullShawl,
	})

	-- AoE mode, built on sets.Idle.AoE.
	sets.OffenseMode.AoE = set_combine( sets.Idle.AoE, {

	})

	-- The enmity base for the spells, job abilities and Atonement below. The engine does not
	-- read it.
	sets.Enmity = { -- Goal is 200 total -Crusade is 30 and Burtang is 23
		ammo=gear.sapience, -- 2
		head = gear.loessBarbutaPlusOne, -- 24
		body = gear.souveranBodyPlusOnePathC, -- 20
		hands = gear.souveranHandsPlusOnePathC, -- 9
		legs = gear.souveranLegsPlusOnePathC, -- 9
		feet = gear.souveranFeetPlusOnePathC, -- 9
		neck=gear.moonlightNeck, -- 15
		waist=gear.creedBaudrier, -- 5
		left_ear=gear.truxEarring, -- 5
		right_ear=gear.crypticEarring, -- 5
		left_ring=gear.apeileRingPlusOne, -- 9
		right_ring=gear.eihwazRing, -- 5
		back = gear.pldEnmityMeva, -- 10
	} -- 127 in gear with Burtang (163 with Crusade)

	sets.Precast = {}

	-- Fast cast gear, worn at the start of every spell.
	sets.Precast.FastCast = { -- 61 FC with 3029/890
		ammo=gear.sapience, -- 2
		head = gear.carmineHeadPlusOnePathD, -- 14
		body=gear.reverenceBodyPlusThree, -- 10
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.odysseanCuissesFCB, -- 6
		feet = gear.odysseanGreavesFC, -- 11
		neck=gear.voltsurge, -- 4
		waist = gear.platinumMoogleBelt,
		left_ear=gear.etiolation, -- 1
		right_ear = gear.tuisto,
		left_ring=gear.weatherspoon, -- 5
		right_ring=gear.kishar, -- 4
		back = gear.pldFCB, -- 10
	}

	-- Merged over the fast cast set for Cure, Curaga and Cura spells.
	sets.Precast.Cure = {
		left_ring=gear.rahabRing,
	}

	-- The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this
	-- set does not name keeps its idle piece.
	sets.Midcast = set_combine( sets.Idle, {

	})

	-- Spell interruption rate down. Merged under every midcast except a ranged attack, so any
	-- specific set overwrites it.
	sets.Midcast.SIRD = {
		ammo=gear.staunchPlusOne, -- 11
		head = gear.souveranHeadPlusOnePathC, -- 20
		legs = gear.founderHoseMacc, -- 30
		neck=gear.moonlightNeck, -- 15
		waist=gear.audumbla, -- 10
		back = gear.pldCure, -- 10
	} -- 96 +10 merits = 106

	-- Cure spells, built with spell interruption rate down.
	sets.Midcast.Cure = {
		ammo=gear.staunchPlusOne, -- 11 SIRD / 3 DT
		head = gear.sakpataHead, -- 7 DT / 5 Cure
		body = gear.sakpataBody,
		hands = gear.sakpataHands, -- 8 DT
		legs = gear.founderHoseMacc, -- 30 SIRD
		feet = gear.odysseanGreavesCure, -- 20 SIRD / 13 Cure
		neck=gear.moonlightNeck, -- 15 SIRD
		waist = gear.platinumMoogleBelt, -- 3 DT
		left_ear = gear.nourishingEarringPlusOne, -- 5 SIRD / 6 Cure
		right_ear=gear.chevalierEarringPlusOne, -- 3 DT / 11 Cure
		left_ring = gear.moonlightRing1, -- 5 DT
		right_ring=gear.defending, -- 10 DT
		back = gear.pldCure, -- 10 SIRD / 10 Cure
	} -- 91 + 10 Merits = 101 SIRD / 49 DT / 56 Cure

	-- Enhancing magic. Raise and the other healing spells that are not cures use it too.
	sets.Midcast.Enhancing = {
		ammo=gear.staunchPlusOne,
		head = gear.souveranHeadPlusOnePathC,
		body = gear.sakpataBody,
		hands = gear.sakpataHands,
		legs = gear.founderHoseMacc,
		feet=gear.sakpataFeet,
		neck=gear.moonlightNeck,
		waist=gear.audumbla,
		left_ear = gear.odnowaPlusOne,
		right_ear=gear.chevalierEarringPlusOne,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.pldCure,
	}

	-- Divine magic, such as Holy, Banish and Enlight. Flash has a set of its own below.
	sets.Midcast.Divine = set_combine( sets.Idle, sets.Enmity, sets.Midcast.SIRD, {

	})

	-- Enfeebling magic, built for magic accuracy.
	sets.Midcast.Enfeebling = {}

	-- Sets named for one spell. Such a set takes the place of the spell's family set.
	sets.Midcast["Stoneskin"] = {
		waist=gear.siegel,
	}

	sets.Midcast["Phalanx"] = set_combine( sets.Idle, sets.Midcast.SIRD, {
		hands=gear.regalGauntlets,
		legs=gear.sakpataLegs,
		feet = gear.souveranFeetPlusOnePathC, -- 9
	})


	sets.Midcast["Reprisal"] = { -- Block rate is based off HP
		ammo=gear.staunchPlusOne,
		head = gear.souveranHeadPlusOnePathC,
		body = gear.souveranBodyPlusOnePathC,
		hands=gear.regalGauntlets,
		legs = gear.carmineLegsPlusOnePathA,
		feet = gear.souveranFeetPlusOnePathC,
		neck = gear.unmovingPlusOne,
		waist=gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		right_ear=gear.tuisto,
		left_ring=gear.moonlightRing,
		right_ring=gear.moonlightRing,
		back = gear.pldCure,
	}

	sets.Midcast["Flash"] = set_combine( sets.Idle, sets.Enmity, sets.Midcast.SIRD, {
	
	})

	-- Worn over the idle and engaged sets while Cover is up, as one table under both keys. The
	-- Caballarius Surcoat turns part of the physical damage taken while covering into MP.
	sets.Idle.Cover = {
		body = gear.caballariusBodyPlusThree
	}
	sets.OffenseMode.Cover = sets.Idle.Cover

	-- Merged over every spell's midcast while Rampart is up. Rampart is a job ability, so this is
	-- not the set worn to use it. That one is sets.JA["Rampart"] below.
	-- sets.Midcast.Rampart = {}

	-- Job abilities. sets.JA is worn for every ability, and a set named for the ability goes over it.
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

	-- Worn on every weaponskill. The set named for the weaponskill goes over it, then the offense
	-- mode's set.
	sets.WS = {
		ammo=gear.oshashaTreatise,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck=gear.fotiaNeck,
		waist = gear.sailfi,
		left_ear=gear.ishvara,
		right_ear = gear.moonshadeEarringAcc,
		left_ring=gear.epimanondas,
		right_ring=gear.corneliaRing,
		back = gear.pldWSD,
	}
	-- Worn on weaponskills in ACC mode, over the set named for the weaponskill. List only the
	-- pieces the mode changes, since every slot named here overrides the weaponskill's own set. A
	-- weaponskill with an ACC set of its own, sets.WS['<name>'].ACC, takes that instead. The other
	-- mode sets work the same way, except that sets.WS.TP is never merged.
	sets.WS.ACC = {}
	-- WSD and CRIT are not offense modes here. WSD is a shared set, and Savage Blade below uses it.
	-- CRIT is a placeholder. To use it as a mode, add 'CRIT' to state.OffenseMode:options and add
	-- sets.OffenseMode.CRIT and sets.Idle.CRIT. This set then goes over each weaponskill in that mode.
	sets.WS.WSD = {}
	sets.WS.CRIT = {}

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

	-- A place for sets of your own. The engine never reads sets.Custom, so use it from the hooks
	-- below.
	sets.Custom = {}

	-- Treasure Hunter gear. While TH Mode is Tag or Full Time, it is worn for an action aimed at an
	-- untagged monster and while engaged on one. Full Time also keeps it on whenever engaged. TH
	-- Mode starts at None, which never wears it, on every job but Thief.
	sets.TreasureHunter = {
		ammo=gear.perfectEgg,
		body=gear.volteJupon,
		waist=gear.chaac,
	}

end

-------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE UNLESS YOU NEED TO MAKE JOB SPECIFIC RULES
-------------------------------------------------------------------------------------------------------------------


-- Called when the subjob changes.
function sub_job_change_custom(new, old)
	-- Typically used to change the macro book or set.
end

-- Called before each action, after the engine's own checks. Call cancel_spell() here to stop
-- the action.
function pretarget_custom(spell,action)

end
-- Called as each action starts. The table it returns is merged over the engine's precast set.
function precast_custom(spell)
	local equipSet = {}

	return equipSet
end
-- Called while each action is in flight. The table it returns is merged over the engine's
-- midcast set, which is empty for abilities, weaponskills and items.
function midcast_custom(spell)
	local equipSet = {}
		if state.OffenseMode.value == 'MEVA' and not spell.name:contains('Cure') then
			equipSet = set_combine(equipSet, sets.MEVA)
		end
	return equipSet
end
-- Called when each action ends. The table it returns is merged over the idle or engaged set the
-- engine rebuilds.
function aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end
-- Called when a buff is gained or lost. The table it returns is merged over the rebuilt idle or
-- engaged set. A change during one of your own actions is dressed when the action ends instead.
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
-- Called whenever the engine rebuilds the idle or engaged set, which it does after each action,
-- on a buff or status change, and when movement starts or stops. The table it returns is merged
-- over that set.
function choose_set_custom()
	local equipSet = {}

	return equipSet
end
-- Called when the player's status changes, such as engaging, disengaging or resting. The table
-- it returns is merged over the rebuilt idle or engaged set.
function status_change_custom(new,old)
	local equipSet = {}

	return equipSet
end
-- Called with each "gs c" command, in lowercase, that the engine's own commands leave unclaimed.
-- Use it to add commands of your own. The Weapon Mode, Job Mode and Job Mode 2 commands also call
-- it, before their gear rebuild.
function self_command_custom(command)

end

-- Called when the job file unloads, after the engine releases its keybinds and slot holds.
function user_file_unload()

end

-- Called when a pet is summoned or lost. The table it returns is merged over the rebuilt idle or
-- engaged set.
function pet_change_custom(pet,gain)
	local equipSet = {}

	return equipSet
end

-- Called when a pet's action ends. The table it returns is merged over the idle or engaged set
-- the engine rebuilds.
function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called while a pet's action is in flight. The table it returns is merged over sets.Pet_Midcast
-- and the set named for the action.
function pet_midcast_custom(spell)
	local equipSet = {}

	return equipSet
end
