

-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The lockstyle set, macro book and macro set that jobsetup applies at load.
LockStylePallet = "10"
MacroBook = "1"
MacroSet = "1"

-- The item that "gs c food" uses.
Food = "Sublime Sushi"

-- When true, the engine uses a Remedy on paralysis or silence and a Holy Water on Doom.
AutoItem = false

-- When true, each load picks a lockstyle set from Lockstyle_List in place of LockStylePallet.
Random_Lockstyle = false

-- The lockstyle sets Random_Lockstyle picks from.
Lockstyle_List = {1,2,6,12}

-- The offense modes this job cycles through, in place of the engine's default TP, ACC and DT.
-- Each mode needs a sets.OffenseMode.<Mode> and a sets.Idle.<Mode> below, and can also have
-- a sets.WS.<Mode>. state.OffenseMode:set picks the mode selected at load.
state.OffenseMode:options('TP','ACC','DT','PDL','SB','MEVA')
state.OffenseMode:set('DT')

-- Weapon modes. Each one needs a sets.Weapons['<Mode>'] of the same name below.
state.WeaponMode:options('Kannagi','Savage Blade','Karambit','Aeolian Edge','Abyssea','Ninjitsu')
state.WeaponMode:set('Kannagi')

-- Not read by the engine. Its own Elemental_WS list already holds these weaponskills.
elemental_ws = S{'Aeolian Edge', 'Blade: Teki', 'Blade: To','Blade: Chi','Blade: Ei','Blade: Yu'}

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- Weapon sets, one per weapon mode above.
	sets.Weapons = {}

	sets.Weapons['Kannagi'] = {
		main = gear.kannagi,
		sub=gear.gokotai,
	}

	sets.Weapons['Ninjitsu'] = {
		main=gear.tauret,
		sub=gear.gokotai,
	}

	sets.Weapons['Savage Blade'] = {
		main=gear.naegling,
		sub=gear.blurredKnife,
	}

	sets.Weapons['Karambit'] = {
		main=gear.karambit,
		sub="empty",
	}

	sets.Weapons['Aeolian Edge'] = {
		main=gear.tauret,
		sub=gear.naegling,
	}

	sets.Weapons['Abyssea'] = {
		main="",
		sub="",
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active,
	-- engaged or idle.
	sets.Weapons.Shield = {}
	-- Worn with the idle set when this character is put to sleep. Its slots are held until the
	-- sleep ends, and nothing else changes gear while asleep.
	sets.Weapons.Sleep = {}

	-- Worn while idle. Every action's precast and midcast also start from this set, so a slot
	-- their sets leave out keeps its idle piece.
	sets.Idle = {
		ammo=gear.staunchPlusOne,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.loricatePlusOne,
		waist=gear.carriers,
		left_ear=gear.etiolation,
		right_ear = gear.odnowaPlusOne,
		left_ring=gear.eihwazRing,
		right_ring = gear.gelatinousPlusOne,
		back = gear.ninDA,
    }

	-- Worn over sets.Idle while idle in the matching offense mode.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
	})

	-- Worn over the idle set while a Phantom Roll on you stands at 11. It is for the Roller's
	-- Ring, which any job can wear and which gives Refresh +1 and Regain +10 at an 11, for example
	-- left_ring="Roller's Ring". It applies in every offense mode. It is worn only while idle, so
	-- any action swaps it out and it comes back when the action ends. While moving, a ring here
	-- replaces the movement set's ring in the same slot. This file's movement sets name no ring,
	-- so either slot is free.
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

	-- Worn while moving at any hour. The period set for the hour goes over it.
	sets.Movement_Base = {}

	sets.Movement_Day = {
		feet=gear.danzoSuneAte,
	}
	sets.Movement_Night = {
		feet=gear.hachiyaFeetPlusOne,
	}
	sets.Movement_Dusk = {
		feet=gear.hachiyaFeetPlusOne,
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

	-- Engaged sets. sets.OffenseMode is merged first in every offense mode, and the mode's own set
	-- goes over it.
	sets.OffenseMode = {}

	-- The TP set. The DT, ACC and PDL sets below build on it.
	sets.OffenseMode.TP = {
		ammo=gear.happoShurikenPlusOne,
		head = gear.adhemarHeadPlusOnePathA,
		body=gear.kendatsubaBodyPlusOne,
		hands = gear.adhemarHandsPlusOnePathA,
		legs = gear.samnuhaTightsDA,
		feet=gear.kendatsubaFeetPlusOne,
		neck = gear.ninjaNodowaPlusTwo,
		waist = gear.sailfi,
		left_ear=gear.telos,
		right_ear=gear.hattoriEarringPlusOne,
		left_ring=gear.gereRing,
		right_ring=gear.eponas,
		back = gear.ninDA,
	}
	-- DT mode, built on the TP set.
	sets.OffenseMode.DT = set_combine (sets.OffenseMode.TP, {
	    head=gear.malignanceHead,
		body=gear.malignanceBody,
		hands=gear.malignanceHands,
		legs=gear.malignanceLegs,
		feet=gear.malignanceFeet,
	})
	-- ACC mode, built on the TP set.
	sets.OffenseMode.ACC = set_combine (sets.OffenseMode.TP, {
	    head=gear.kendatsubaHeadPlusOne,
		body=gear.kendatsubaBodyPlusOne,
		hands=gear.kendatsubaHandsPlusOne,
		legs=gear.kendatsubaLegsPlusOne,
		feet=gear.kendatsubaFeetPlusOne,
	})
	sets.OffenseMode.PDL = set_combine (sets.OffenseMode.TP, {
	    head=gear.malignanceHead,
		body=gear.malignanceBody,
		hands=gear.malignanceHands,
		legs=gear.malignanceLegs,
		feet=gear.malignanceFeet,
	})

	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode.DT,{
		neck = gear.warderCharmPlusOne,
	})

	sets.OffenseMode.SB = set_combine(sets.OffenseMode.DT,{ })

	-- Worn over the engaged set in every offense mode while Migawari is up, for the same bonus.
	-- sets.OffenseMode.Migawari = {}

	-- Worn while engaged with the Dual Wield trait active, over the mode's set.
	sets.DualWield = {}

	sets.Precast = {}
	-- Fast cast gear, worn at the start of every spell.
	sets.Precast.FastCast = {
		ammo=gear.sapience, -- 2
		head = gear.herculeanHelmFC, --13
		body = gear.taeonTabardBFC, -- 9
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.herculeanTrousersFC, -- 6
		feet = gear.herculeanBootsFC, -- 6
		neck=gear.voltsurge, -- 4
		waist=gear.platinumMoogleBelt,
		left_ear=gear.etiolation, -- 1
		right_ear=gear.loquacious, -- 2
		left_ring=gear.kishar, -- 4
		right_ring=gear.rahabRing, -- 2
		back = gear.ninFC, -- 10
	} -- 67

	-- Merged over the fast cast set for Utsusemi.
	sets.Precast.Utsusemi = {
		neck=gear.magoragaBeadNecklace, -- 10 FC (+6)
	}

	-- An enmity set for Provoke below. The engine does not read it.
	sets.Enmity = { -- Head and Back upgrade slots
		ammo=gear.sapience, --2
		body=gear.emetHarnessPlusOne, --10
		hands=gear.kurysGloves, --9
		--="Zoar Subligar +1", --6
		feet=gear.ahosiLeggings, --7
		neck=gear.moonlightNeck, --15
		waist=gear.kasiriBelt, --3
		left_ear=gear.crypticEarring, --4
		right_ear=gear.friomisi, --2
		left_ring=gear.eihwazRing, --5
		right_ring=gear.petrov, --4
	}

	-- The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this
	-- set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {

	})
	-- Utsusemi. Other ninjutsu takes a set named for the spell if there is one, then
	-- sets.Midcast.Enhancing for a self-cast, sets.Midcast.Enfeebling for an enfeeble, and
	-- sets.Midcast.Nuke for the rest.
	sets.Midcast.Utsusemi = {
		back = gear.ninFC,
		feet=gear.hattoriFeetPlusOne,
	}
	-- Spell interruption rate down. Merged under every midcast except a ranged attack, so any
	-- specific set overwrites it.
	sets.Midcast.SIRD = {}
	sets.Midcast.Cure = {}
	-- Self-cast ninjutsu, such as Tonko and Monomi, and enhancing magic.
	sets.Midcast.Enhancing = {
		hands = gear.mochizukiTekkoPlusThree,
	}
	-- Enfeebling ninjutsu, such as Kurayami and Hojo, and enfeebling magic, built for magic
	-- accuracy.
	sets.Midcast.Enfeebling = {
		ammo=gear.hydrocera,
		head=gear.hachiyaHeadPlusThree,
		body=gear.malignanceBody,
		hands = gear.mochizukiTekkoPlusThree,
		legs=gear.malignanceLegs,
		feet=gear.malignanceFeet,
		neck=gear.moonlightNeck,
		waist=gear.eschan,
		left_ear=gear.hermetic,
		right_ear=gear.crepuscularEar,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
		back = gear.ninFC,
	}
	-- Elemental ninjutsu and elemental magic, built for magic attack.
	sets.Midcast.Nuke = {
    ammo = gear.ghastlyTathlumPlusOne,
    head = gear.mochizukiHeadPlusThree,
    body = gear.nyameBody,
    hands = gear.nyameHands,
    legs = gear.nyameLegs,
    feet = gear.mpacaFeet,
    neck=gear.sanctity,
    waist=gear.orpheusWaist,
    left_ear=gear.hermetic,
    right_ear=gear.friomisi,
	left_ring = gear.stikiniRingPlusOne1,
	right_ring = gear.stikiniRingPlusOne2,
    back = gear.ninFC,
	}

	-- Worn on elemental ninjutsu while Futae is up, since those spells take sets.Midcast.Nuke. A
	-- spell with a set of its own skips it. Futae gear, such as the Hattori Tekko, raises Futae's
	-- damage bonus and must be worn during the cast.
	-- sets.Midcast.Nuke.Futae = {}

	-- Sets named for one spell. Such a set takes the place of the spell's family set.
	sets.Midcast["Stoneskin"] = {waist=gear.siegel,}

	-- Job abilities. sets.JA is worn for every ability, and a set named for the ability goes over it.
	sets.JA = {}
	sets.JA["Futae"] = {} --hands="Hattori Tekko"
	sets.JA["Berserk"] = {}
	sets.JA["Warcry"] = {}
	sets.JA["Defender"] = {}
	sets.JA["Aggressor"] = {}
	sets.JA["Provoke"] = sets.Enmity
	sets.JA["Mijin Gakure"] = {}
	sets.JA["Yonin"] = {head = gear.mochizukiHeadPlusThree}
	sets.JA["Innin"] = {head = gear.mochizukiHeadPlusThree}
	sets.JA["Issekigan"] = {}
	sets.JA["Mikage"] = {}

	-- Worn on every weaponskill. The set named for the weaponskill goes over it, then the offense
	-- mode's set.
	sets.WS = {
		ammo=gear.yetshilaPlusOne,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.ninjaNodowaPlusTwo,
		waist = gear.sailfi,
		left_ear=gear.odr,
		right_ear=gear.ishvara,
		left_ring=gear.gereRing,
		right_ring=gear.eponas,
		back = gear.ninWSD,
	}

	-- sets.WS.WSD, .CRIT and .MAB are shared sets for the weaponskills below to point to. They are
	-- not offense modes here, so the engine reads one only through a weaponskill that uses it. No
	-- weaponskill uses WSD yet. To use it, point one at it, for example
	-- sets.WS["Blade: Ku"] = sets.WS.WSD, and that weaponskill wears sets.WS with these rings over it.
	sets.WS.WSD = set_combine({
		left_ring=gear.epimanondas,
		right_ring=gear.karieyhRingPlusOne,
	})

	-- Worn on weaponskills in ACC mode, over the set named for the weaponskill. List only the
	-- pieces the mode changes, since every slot named here overrides the weaponskill's own set. A
	-- weaponskill with an ACC set of its own, sets.WS['<name>'].ACC, takes that instead. The other
	-- mode sets work the same way, except that sets.WS.TP is never merged.
	sets.WS.ACC = set_combine({
		head=gear.kendatsubaHeadPlusOne,
		body=gear.kendatsubaBodyPlusOne,
		hands=gear.kendatsubaHandsPlusOne,
		legs=gear.kendatsubaLegsPlusOne,
		feet=gear.kendatsubaFeetPlusOne,
	})

	sets.WS.CRIT = {
		ammo=gear.yetshilaPlusOne,
		head = gear.adhemarHeadPlusOnePathA,
		body=gear.kendatsubaBodyPlusOne,
		hands = gear.adhemarHandsPlusOnePathA,
		legs = gear.samnuhaTightsDA,
		feet = gear.herculeanBootsCrit,
		neck = gear.ninjaNodowaPlusTwo,
		waist=gear.windbuffetPlusOne,
		left_ear=gear.odr,
		right_ear=gear.ishvara,
		left_ring=gear.gereRing,
		right_ring=gear.eponas,
		back = gear.ninDA,
	}
	sets.WS.MAB = set_combine({
		ammo = gear.seethingBombletPlusOne,
		neck=gear.sanctity,
		waist=gear.eschan,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.friomisi,
		left_ring=gear.epimanondas,
		right_ring=gear.dingir,
		back = gear.ninFC,
	})

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
	    ammo=gear.yetshilaPlusOne,
		head=gear.kendatsubaHeadPlusOne,
		body=gear.kendatsubaBodyPlusOne,
		hands=gear.kendatsubaHandsPlusOne,
		legs=gear.kendatsubaLegsPlusOne,
		feet=gear.kendatsubaFeetPlusOne,
		neck=gear.fotiaNeck,
		waist=gear.fotiaWaist,
		left_ear=gear.odr,
		right_ear=gear.ishvara,
		left_ring=gear.gereRing,
		right_ring=gear.hetairoi,
		back = gear.ninWSD,
	}

	sets.WS["Savage Blade"] = {
	    ammo=gear.oshashaTreatise,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.ninjaNodowaPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.ishvara,
		left_ring=gear.epimanondas,
		right_ring=gear.corneliaRing,
		back = gear.ninWSD,
	}

	-- Treasure Hunter gear. While TH Mode is Tag or Full Time, it is worn for an action aimed at an
	-- untagged monster and while engaged on one. Full Time also keeps it on whenever engaged. TH
	-- Mode starts at None, which never wears it, on every job but Thief.
	sets.TreasureHunter = {
	    head=gear.volteHead,
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

-- Not read by the engine.
Cycle_Time = 1

-- The engine calls Cycle_Timer about every 2 seconds. It skips the call during an action and
-- while you are dead, charmed or asleep. This one rebuilds sets.Movement for the game hour: Night
-- from 18:00 to 6:00, Dusk from 17:00 to 18:00 and from 6:00 to 7:00, and Day otherwise.
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
