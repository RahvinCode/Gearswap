

-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The food "gs c food" uses.
Food = "Miso Ramen"

-- Blue magic lists for the BLU subjob. Each replaces the engine's list of the same name and decides which sets.Midcast.BlueMagic set a spell takes.
BlueNuke = S{'Spectral Floe','Entomb', 'Magic Hammer', 'Tenebral Crush'}
BlueHealing = S{'Magic Fruit'}
BlueSkill = S{'Occultation','Erratic Flutter','Nature\'s Meditation','Cocoon','Barrier Tusk','Metallic Body','Mighty Guard'}
BlueTank = S{'Jettatura','Geist Wall','Blank Gaze','Sheep Song','Sandspin','Healing Breeze'}

-- Offense modes. TP, ACC and DT are the engine's defaults, and more can be added. Each mode picks its own engaged, idle and weaponskill sets, so each one offered needs a sets.OffenseMode.<Mode> and a sets.Idle.<Mode> below.
state.OffenseMode:options('TP','ACC','DT','PDT','MEVA')

-- Picks the macro set for the current subjob and the starting offense mode, DT on /BLU and TP otherwise. On /BLU it also loads the AzureSets tanking set.
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


-- The in-game lockstyle set, macro book and macro set this file applies on load. The macro set comes from Macro_Sub_Job above.
LockStylePallet = "12"
MacroBook = "12"
MacroSet = Macro_Sub_Job()

-- Weapon modes. Each name needs a matching sets.Weapons entry below.
state.WeaponMode:options('Epeolatry','Naegling','Club','Great Axe','Axe')
state.WeaponMode:set('Epeolatry')

-- Job-specific mode slots. Name one with UI_Name or UI_Name2 to show it in chat and on the status box.
UI_Name = ''
UI_Name2 = ''

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

-- HP balancing: 3000 HP
-- MP balancing: 950 MP

function get_sets()

	-- Weapon sets, one per weapon mode.
	sets.Weapons = {}

	sets.Weapons['Epeolatry'] = {
		main=gear.epeolatry,
		sub=gear.utu,
	}

	sets.Weapons['Naegling'] = {
		main=gear.naegling,
		sub=gear.dolichenus,
	}

	sets.Weapons['Axe'] = {
		main=gear.dolichenus,
		sub=gear.naegling,
	}

	sets.Weapons['Great Axe'] = {
		main=gear.lycurgos,
		sub=gear.utu,
	}

	sets.Weapons['Club'] = {
		main = gear.loxoticPlusOne,
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons.Shield = {}
	-- Worn over the idle set when you are put to sleep. Its slots stay held until you wake, and the engine re-dresses nothing else while you sleep.
	-- Put gear here that wakes you, such as a piece that drains HP.
	sets.Weapons.Sleep = {}

	-- Worn whenever you are not engaged. It is also the floor under every action, so a slot an action's sets leave unnamed keeps its idle piece.
	sets.Idle = {
		ammo=gear.homiliary, -- 1 Refresh
		head = gear.nyameHead, -- 7/7
		body=gear.erilazBodyPlusThree,
		hands=gear.erilazHandsPlusThree, -- 11/11
		legs=gear.erilazLegsPlusThree, -- 13/13
		feet=gear.erilazFeetPlusThree, -- 11/11
		neck = gear.futharkTorquePlusTwo, -- 7/7
		waist=gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne, -- 3/5
		right_ear=gear.sanareEarring, -- Upgrade to +1/+2 Earring
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.runEnmity, -- 5/5
    } -- 75 PDT / 58 MDT		3571 HP/ 1149 MP

	-- Idle sets for each offense mode, merged over the idle set.
	sets.Idle.PDT = set_combine( sets.Idle, {
		neck = gear.loricatePlusOne,
		waist=gear.flumeBeltPlusOne, -- 4/0
		left_ear=gear.tuisto,
		left_ring = gear.gelatinousPlusOne, -- 7/-1
	})

	sets.Idle.MEVA = set_combine( sets.Idle, {
		ammo=gear.staunchPlusOne,
		neck = gear.warderCharmPlusOne,
		head=gear.erilazHeadPlusThree,
		body=gear.runeistBodyPlusThree,
		waist=gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne, -- 3/5
		right_ear=gear.sanareEarring,
	})

	sets.Idle.DT = set_combine( sets.Idle, {
		ammo=gear.yamarang,
		head=gear.erilazHeadPlusThree,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.tuisto,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	})

	-- Not read by the engine. midcast_custom below merges it over the midcast set in MEVA mode.
	sets.MEVA = {
		ammo=gear.staunchPlusOne,
		neck = gear.warderCharmPlusOne,
		body=gear.runeistBodyPlusThree,
		hands=gear.erilazHandsPlusThree, -- 11/11
		legs=gear.erilazLegsPlusThree, -- 13/13
		feet=gear.erilazFeetPlusThree, -- 11/11
		waist=gear.platinumMoogleBelt,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		left_ear = gear.odnowaPlusOne, -- 3/5
	}

	-- The remaining idle mode sets, and Resting, merged over them while you rest.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})

	-- Worn over the idle set while a Phantom Roll on you stands at 11.
	-- It is meant for Roller's Ring, which every job can wear and which grants Refresh +1 and Regain +10 at an 11, e.g. left_ring="Roller's Ring".
	-- This set applies in every offense mode. The TP set below applies only in TP mode and merges after it.
	-- It is worn only while idle, so any action swaps it out, and it comes back when the action ends.
	-- While you move, a ring named here replaces a movement ring in the same slot. This file's sets.Movement names both rings, so no slot is free and a ring here replaces one of them while you move.
	sets.Idle.XIRoll = {}
	-- The TP mode version, merged after the one above.
	sets.Idle.TP.XIRoll = {}

	-- Worn over the idle set while Pflug is up. Runeist Bottes raise Pflug's resistance bonus, but only when worn as the enemy's spell or ability finishes,
	-- so this keeps them on while Pflug lasts.
	-- sets.Idle.Pflug = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = {
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		legs = gear.carmineLegsPlusOnePathA,
    } -- 73 PDT / 33 MDT		3028 HP / 963 MP

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

	-- Engaged sets. sets.OffenseMode is worn in every offense mode, and the current mode's set merges over it.
	sets.OffenseMode = {
		ammo = gear.coiste,
		head=gear.erilazHeadPlusThree,
		body=gear.asheraHarness,
		hands=gear.erilazHandsPlusThree,
		legs=gear.erilazLegsPlusThree,
		feet=gear.erilazFeetPlusThree,
		neck = gear.futharkTorquePlusTwo,
		waist=gear.windbuffetPlusOne,
		left_ear=gear.sherida,
		right_ear=gear.telos,
		left_ring=gear.niqmaddu,
		right_ring=gear.eponas,
		back = gear.runSTP,
	}

	-- TP mode, for damage while tanking. It names only the slots it changes over the base above.
	sets.OffenseMode.TP = {
		head = gear.adhemarHeadPlusOnePathA,
		hands = gear.adhemarHandsPlusOnePathA,
		legs = gear.samnuhaTightsDA,
	}

	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, { })

	-- PDT mode, a physical damage taken set for tanking.
	sets.OffenseMode.PDT = set_combine(sets.OffenseMode, {
		head = gear.nyameHead,
		body=gear.adamantiteArmor,
		hands=gear.turmsHandsPlusOne,
		neck = gear.unmovingPlusOne,
		waist = gear.sailfi,
		back=gear.nullShawl,
	}) -- Maintains Capped PDT with some DPS mixed in

	-- MEVA mode, a magic evasion set for tanking.
	sets.OffenseMode.MEVA = set_combine(sets.Idle.MEVA, {

	}) -- Focus on Magic Evasion with some DPS mixed in

	-- DT mode, the standard tanking set.
	sets.OffenseMode.DT = set_combine(sets.Idle.DT, {
		body=gear.asheraHarness,
		waist = gear.sailfi,
		left_ear=gear.sherida,
		right_ear=gear.telos,
		back = gear.runSTP,
	})

	-- Worn over the engaged set in every offense mode while Pflug is up, to keep the Runeist Bottes on as enemy spells and abilities finish, as the idle one above does.
	-- sets.OffenseMode.Pflug = {}

	-- Enmity gear. The engine does not read this set. The job ability sets, Flash, Foil and sets.Midcast below build on it.
	sets.Enmity = { -- 23 Epo
		ammo=gear.sapience, -- 2
		head=gear.erilazHeadPlusThree,
		body=gear.erilazBodyPlusThree,
		hands=gear.erilazHandsPlusThree,
		legs=gear.erilazLegsPlusThree, -- 11
		feet=gear.erilazFeetPlusThree, -- 8 
		neck = gear.unmovingPlusOne, -- 10
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.crypticEarring, -- 4
		left_ring = gear.eihwazRing, -- 5
		right_ring = gear.moonlightRing4,
		back = gear.runEnmity, -- 10
	} -- 99 Enmity 2884 HP / 840 MP

	-- Spell interruption rate down. The engine does not read this set. sets.Midcast and the Aquaveil set below fold it in with set_combine, so any more specific set overwrites it.
	sets.SIRD = set_combine(sets.Idle.DT, {
		ammo=gear.staunchPlusOne, -- 11
		head=gear.erilazHeadPlusThree, -- 20
		hands=gear.regalGauntlets, -- 10
		legs = gear.carmineLegsPlusOnePathA, -- 20
		neck=gear.moonlightNeck, -- 15
		waist=gear.audumbla, -- 10
		back = gear.runFC, -- 10
	})	-- 104 With Merits

	sets.Precast = {}
	-- Fast cast, worn at the start of every spell.

	sets.Precast.FastCast = {
		ammo=gear.sapience, -- 2
		head=gear.runeistHeadPlusThree, -- 14
		body=gear.erilazBodyPlusThree, -- 13
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.futharkLegsPlusThree,
		feet = gear.carmineFeetPlusOnePathD, -- 8
		neck=gear.voltsurge,
		waist = gear.platinumMoogleBelt,
		right_ear = gear.etiolation,
		left_ear = gear.tuisto,
		left_ring = gear.gelatinousPlusOne,
		right_ring=gear.kishar, -- 4
		back = gear.runFC, -- 10
	} --65 FC

	-- Merged over the fast-cast set for enhancing magic.
	sets.Precast.Enhancing = set_combine(sets.Precast.FastCast, {
		legs = gear.futharkLegsPlusThree, -- 7  (15 - 8) 
		waist=gear.siegel, -- 8
	}) -- 80+ FC

	-- Merged over the fast-cast set for blue magic.
	sets.Precast.BlueMagic = set_combine (sets.Precast.FastCast, {})

	--The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, sets.Enmity, sets.SIRD, {})

	-- Enhancing magic, and the base the enhancing sets below copy.
	sets.Midcast.Enhancing = {
		ammo=gear.staunchPlusOne,
	    head=gear.erilazHeadPlusThree,
		body=gear.runeistBodyPlusThree,
		hands = gear.regalGauntlets,
		legs = gear.futharkLegsPlusThree,
		feet=gear.erilazFeetPlusThree,
		neck = gear.warderCharmPlusOne,
		waist=gear.carriers,
		left_ear=gear.tuisto,
		right_ear=gear.mimir,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.runEnmity, -- 5/5
	}

	-- Merged over the enhancing set while Embolden is up. An Evasionist's Cape with an Embolden augment adds 5 to 15 percent duration to a spell you receive
	-- under Embolden, and it must be worn as the spell lands. Regen, Refresh, Stoneskin, Aquaveil, Phalanx and Foil wear sets of their own in place of the
	-- enhancing set, so this same table is also placed under each of those sets, below the last of them.
	sets.Midcast.Enhancing.Embolden = { back = gear.evasionistCapeDA, }

	-- Merged over the enhancing set for elemental bar spells.
	sets.Midcast.Enhancing.Elemental = set_combine(sets.Midcast.Enhancing, {})

	-- Merged over the enhancing set when the spell targets someone else, for duration.
	sets.Midcast.Enhancing.Others = set_combine(sets.Midcast.Enhancing, {})

	-- Merged over the enhancing set for status bar spells.
	sets.Midcast.Enhancing.Status = set_combine(sets.Midcast.Enhancing, {})

	-- Merged over the enhancing set for skill-based buffs such as Temper.
	sets.Midcast.Enhancing.Skill = set_combine(sets.Midcast.Enhancing, {})

	-- Regen and Refresh. The spells named Regen and Refresh match these keys exactly, so they wear these sets in place of the enhancing set.
	-- Regen II and up wear the enhancing set with the Regen set merged over it.
	sets.Midcast.Regen = set_combine(sets.Midcast.Enhancing, {})

	sets.Midcast.Refresh = set_combine(sets.Midcast.Enhancing, {})

	sets.Midcast.Cure = {}

	-- Blue magic for the BLU subjob. Each spell takes the one subfamily set its list above names. The engine never wears sets.Midcast.BlueMagic itself.
	sets.Midcast.BlueMagic = {}
	sets.Midcast.BlueMagic.Skill = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Nuke = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Healing = set_combine(sets.Midcast.Cure, {})
	sets.Midcast.BlueMagic.ACC = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Enmity = set_combine(sets.Enmity, {})

	-- Enfeebling magic, dressed for magic accuracy.
	sets.Midcast.Enfeebling = {}

	-- Divine magic. The Vivacious Pulse set below is built on it, since that ability's cure scales with divine magic skill.
	sets.Midcast.Divine = {}

	-- Sets named for one spell. Each replaces the family set for that spell.
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		waist=gear.siegel,
	})

	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, sets.SIRD, {
		body=gear.runeistBodyPlusThree,
	})

	sets.Midcast["Phalanx"] = set_combine(sets.Midcast.Enhancing, {
		head = gear.futharkHeadPlusThree, --7
		neck = gear.warderCharmPlusOne,
		waist=gear.carriers,
		left_ear=gear.tuisto,
		right_ear = gear.etiolation,
		body=gear.runeistBodyPlusThree,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	})

	sets.Midcast["Flash"] = set_combine(sets.Enmity, {
		neck = gear.warderCharmPlusOne,
		waist=gear.carriers,
		left_ear=gear.tuisto,
		hands=gear.erilazHandsPlusThree,
		body=gear.runeistBodyPlusThree,
		right_ear = gear.etiolation,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	})

	sets.Midcast["Foil"] = set_combine(sets.Enmity, {
		neck = gear.warderCharmPlusOne,
		waist=gear.carriers,
		left_ear=gear.tuisto,
		hands=gear.erilazHandsPlusThree,
		body=gear.runeistBodyPlusThree,
		right_ear = gear.etiolation,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
	})

	-- The Embolden table again, under each spell set that replaces the enhancing set, so those spells take it too.
	sets.Midcast.Regen.Embolden = sets.Midcast.Enhancing.Embolden
	sets.Midcast.Refresh.Embolden = sets.Midcast.Enhancing.Embolden
	sets.Midcast["Stoneskin"].Embolden = sets.Midcast.Enhancing.Embolden
	sets.Midcast["Aquaveil"].Embolden = sets.Midcast.Enhancing.Embolden
	sets.Midcast["Phalanx"].Embolden = sets.Midcast.Enhancing.Embolden
	sets.Midcast["Foil"].Embolden = sets.Midcast.Enhancing.Embolden

	-- Job abilities. sets.JA is worn for every job ability, rune, ward and effusion, and the set named for the ability merges over it.
	sets.JA = {}
    sets.JA["Elemental Sforzo"] = set_combine(sets.Enmity, { body=gear.futharkBodyPlusThree })
    sets.JA["Gambit"] = set_combine(sets.Enmity, { hands=gear.runeistHandsPlusThree,})
    sets.JA["Rayke"] = set_combine(sets.Enmity, { feet=gear.futharkFeetPlusThree })
    sets.JA["Liement"] = set_combine(sets.Enmity, { body=gear.futharkBodyPlusThree })
    sets.JA["One for All"] = sets.Idle
    sets.JA["Valiance"] = set_combine(sets.Enmity, {
        body=gear.runeistBodyPlusThree,
		back = gear.runEnmity, -- 5/5
        legs=gear.futharkLegsPlusThree
    })
    sets.JA["Vallation"] = set_combine(sets.Enmity, {
        body=gear.runeistBodyPlusThree,
		back = gear.runEnmity, -- 5/5
        legs=gear.futharkLegsPlusThree
    })
    sets.JA["Pflug"] = set_combine(sets.Enmity, { feet=gear.runeistFeetPlusThree })
    sets.JA["Battuta"] = set_combine(sets.Enmity, { head=gear.futharkHeadPlusThree })
    sets.JA["Vivacious Pulse"] = set_combine(sets.Midcast.Divine, { head=gear.erilazHeadPlusThree })
    sets.JA["Embolden"] = set_combine(sets.Enmity, sets.Midcast.Enhancing.Embolden)
    sets.JA["Swordplay"] = set_combine(sets.Enmity, { hands=gear.futharkHandsPlusThree })
	sets.JA["Provoke"] = sets.Enmity


	-- Weaponskill base, worn for every weaponskill. The set named for the weaponskill merges over it.
	sets.WS = {
		ammo=gear.knobkierrie,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck=gear.fotiaNeck,
		waist=gear.fotiaWaist,
		left_ear=gear.sherida,
		right_ear=gear.odr,
		left_ring=gear.niqmaddu,
		right_ring=gear.epimanondas,
		back = gear.runWSD,
	}
	-- Merged in ACC mode after the set named for the weaponskill, so its slots win. Name only the slots ACC mode should change. A weaponskill with an ACC set of its own skips it.
	sets.WS.ACC = {}
	-- WSD and CRIT are not offense modes in this file, so they are worn only through sets built from them.
	sets.WS.WSD = {}
	sets.WS.CRIT = {}

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

	-- Treasure Hunter gear, worn on an action or melee swing against a monster not yet tagged, and throughout a fight in Full Time mode. It is never worn in None mode, where every job but Thief starts.
	sets.TreasureHunter = {
		ammo=gear.perfectEgg,
		body=gear.volteJupon,
		waist=gear.chaac,
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
-- Gear returned here merges over the engine's precast set for the action.
function precast_custom(spell)
	local equipSet = {}

	return equipSet
end
-- Gear returned here merges over the engine's midcast set for the action. In MEVA mode this adds sets.MEVA.
function midcast_custom(spell)
	local equipSet = {}

	if state.OffenseMode.value == 'MEVA' then
		equipSet = set_combine(equipSet, sets.MEVA)
	end

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
function self_command_custom(command)

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
