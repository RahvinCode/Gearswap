
-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The in-game lockstyle set, macro book and macro set this file applies on load.
LockStylePallet = "16"
MacroBook = "6"
MacroSet = "1"

-- Use a Remedy for paralysis or silence, and a Holy Water for doom, automatically.
AutoItem = false

-- Pick a random lockstyle from Lockstyle_List on each load, in place of LockStylePallet.
Random_Lockstyle = true

-- The lockstyle sets the random pick chooses from.
Lockstyle_List = {16,17,18}

-- The food "gs c food" uses.
Food = "Sublime Sushi"

-- Offense modes, and the one the file starts in. Each mode offered needs its own sets.OffenseMode.<Mode> and sets.Idle.<Mode> below.
state.OffenseMode:options('DT','TP','SB','Farm')
state.OffenseMode:set('DT')

-- Weapon modes. Each name needs a matching sets.Weapons entry.
state.WeaponMode:options('Aeneas','Karambit')
state.WeaponMode:set('Aeneas')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- Weapon sets, one per weapon mode. A set here is worn only once its name is offered in the weapon modes above.
	sets.Weapons = {}
	sets.Weapons['Terpsichore'] = {}
	sets.Weapons['Twashtar'] = {}
	sets.Weapons['Aeneas'] = {main=gear.aeneas, sub=gear.gleti,}
	sets.Weapons['Karambit'] = {main=gear.karambit,}

	-- Worn whenever you are not engaged. It is empty here, so each offense mode's idle set below carries the gear.
	-- It is also the floor under every action, and an empty floor leaves unchanged any slot an action's sets do not name.
	sets.Idle = {}

	-- Idle sets for each offense mode, merged over the idle set. SB shares the DT table.
	sets.Idle.DT = {
		ammo=gear.staunchPlusOne,
    	head=gear.malignanceHead,
		body=gear.malignanceBody,
		hands=gear.malignanceHands,
		legs=gear.malignanceLegs,
		feet=gear.malignanceFeet,
    	neck = gear.loricatePlusOne,
    	waist=gear.flumeBeltPlusOne,
    	left_ear = gear.odnowaPlusOne,
    	right_ear=gear.infusedEarring,
    	left_ring=gear.chirichRingPlusOne,
    	right_ring=gear.chirichRingPlusOne,
    	back=gear.sacroMantle,}

	sets.Idle.TP = {
		ammo=gear.staunchPlusOne,
    	head=gear.gletiHead,
    	body=gear.gletiBody,
    	hands=gear.gletiHands,
    	legs=gear.gletiLegs,
    	feet=gear.gletiFeet,
    	neck = gear.loricatePlusOne,
    	waist=gear.flumeBeltPlusOne,
    	left_ear = gear.odnowaPlusOne,
    	right_ear=gear.infusedEarring,
    	left_ring=gear.chirichRingPlusOne,
    	right_ring=gear.chirichRingPlusOne,
    	back=gear.sacroMantle,}
	
	sets.Idle.SB = sets.Idle.DT

	sets.Idle.Farm = {
		ammo=gear.staunchPlusOne,
    	head=gear.nyameHead,
    	body = gear.nyameBody,
    	hands=gear.nyameHands,
    	legs=gear.nyameLegs,
    	feet=gear.nyameFeet,
    	neck = gear.unmovingPlusOne,
    	waist=gear.silverMoogleBelt,
    	left_ear = gear.odnowaPlusOne,
    	right_ear=gear.tuisto,
    	left_ring = gear.gelatinousPlusOne,
    	right_ring=gear.moonlightRing,
    	back=gear.moonlightCape,}

	-- Worn over the idle set while a Phantom Roll on you stands at 11.
	-- It is meant for Roller's Ring, which every job can wear and which grants Refresh +1 and Regain +10 at an 11, e.g. left_ring="Roller's Ring".
	-- This set applies in every offense mode. The TP set below applies only in TP mode and merges after it.
	-- It is worn only while idle. This file's idle base names no gear, so an action swaps the ring out only when that action's sets name its slot, and it comes back when the action ends.
	-- While you move, a ring named here replaces a movement ring in the same slot. This file's sets.Movement names right_ring, so left_ring is the free slot.
	sets.Idle.XIRoll = {}
	-- The TP mode version, merged after the one above.
	sets.Idle.TP.XIRoll = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = {right_ring=gear.shneddickRing,}

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
	sets.OffenseMode = {}

	sets.OffenseMode.DT = {
		ammo=gear.yamarang,
		head=gear.malignanceHead,
		body=gear.malignanceBody,
		hands=gear.malignanceHands,
		legs=gear.malignanceLegs,
		feet=gear.malignanceFeet,
		neck=gear.anu,
		waist=gear.reiki,
		left_ear=gear.sherida,
		right_ear=gear.telos,
		left_ring=gear.moonlightRing,
		right_ring=gear.moonlightRing,
		back=gear.sacroMantle,
	}
	sets.OffenseMode.TP = {
		ammo = gear.coiste,
    	head = gear.adhemarHeadPlusOnePathA,
    	body = gear.adhemarBodyPlusOnePathA,
    	hands = gear.adhemarHandsPlusOnePathA,
    	legs = gear.samnuhaTightsDAB,
    	feet=gear.malignanceFeet,
    	neck=gear.anu,
    	waist = gear.sailfi,
    	left_ear=gear.sherida,
    	right_ear=gear.telos,
    	left_ring=gear.gereRing,
    	right_ring=gear.eponas,
    	back=gear.sacroMantle,
	}
	-- Subtle Blow Cap at 50 and II at 25 for a Total of 75.
	-- DNC Subtle Blow = 20/50 w/ Traits. Need +30 in Gear for SBI Cap.
	-- Subtle Blow I: 50/50 | Subtle Blow II:05/25 | DT:50/50 | ACC: High
	sets.OffenseMode.SB = {
		ammo=gear.yamarang,
    	head=gear.malignanceHead,
    	body=gear.malignanceBody,
    	hands=gear.malignanceHands,
    	legs=gear.malignanceLegs,
    	feet=gear.malignanceFeet,
    	neck=gear.anu,
    	waist=gear.reiki,
    	left_ear=gear.sherida, -- SBII+5
    	right_ear=gear.telos,
    	left_ring=gear.chirichRingPlusOne, -- SB+10
    	right_ring=gear.chirichRingPlusOne, -- SB+10
    	back=gear.sacroMantle, -- Ambu Cape has SB+10
	}
	sets.OffenseMode.Farm = {
		ammo=gear.staunchPlusOne,
    	head=gear.nyameHead,
    	body = gear.nyameBody,
    	hands=gear.nyameHands,
    	legs=gear.nyameLegs,
    	feet=gear.nyameFeet,
    	neck = gear.unmovingPlusOne,
    	waist=gear.silverMoogleBelt,
    	left_ear = gear.odnowaPlusOne,
    	right_ear=gear.tuisto,
    	left_ring = gear.gelatinousPlusOne,
    	right_ring=gear.moonlightRing,
    	back=gear.moonlightCape,
	}

	--Merged over the engaged set while OffenseMode is ACC, once ACC is added to the options list above.
	sets.OffenseMode.ACC = {}

	-- Worn over the engaged set in every offense mode while Climactic Flourish is up. Gear that enhances it, such as Maculele Tiara +3 (head), adds damage to the critical hits it forces.
	-- sets.OffenseMode['Climactic Flourish'] = {}

	-- Worn over the engaged set in every offense mode while Saber Dance is up. Gear that enhances it, such as Horos Tights +3 (legs), raises its minimum double attack rate.
	-- sets.OffenseMode['Saber Dance'] = {}

	--Merged over the engaged set while a dual-wield trait is active.
	sets.DualWield = {}

	sets.Precast = {}
	-- Fast cast, worn at the start of every spell.
	sets.Precast.FastCast = {
		ammo=gear.sapience,
		head = gear.herculeanHelmNuke,
    	hands = gear.leylineGlovesFCB,
    	neck=gear.baetylPendant,
    	waist=gear.hachirinNoObi,
    	left_ear=gear.etiolation,
    	right_ear=gear.enchanterEarringPlusOne,
    	right_ring=gear.rahabRing,
	}
	-- Not read by the engine. The Animated Flourish set below builds on it.
	sets.Enmity = {}
	-- Midcast sets for spells from a subjob. sets.Midcast is the base for every cast.
	sets.Midcast = {}
	sets.Midcast.SIRD = {}
	sets.Midcast.Cure = {}
	sets.Midcast.Enhancing = {}
	sets.Midcast.Enfeebling = {}
	sets.Midcast["Stoneskin"] = {}

	-- Job abilities. sets.JA is worn for every job ability, and the set named for the ability merges over it.
	-- An ability set built on sets.Idle.DT, as several below are, keeps you in defensive gear for the second or two the ability takes, wherever its own gear does not replace it.
	sets.JA = {}

	sets.JA["Trance"] = {}
	sets.JA["Contradance"] = {}
	sets.JA["Saber Dance"] = {}
	sets.JA["Fan Dance"] = {}
	sets.JA["No Foot Rise"] = {}
	sets.JA["Presto"] = {}
	sets.JA["Grand Pas"] = {}

	-- Flourishes, which buff you or debuff the monster. The engine wears sets.Flourish and then the set named for the flourish.
	sets.Flourish = set_combine(sets.Idle.DT, {head=gear.nyameHead,})
																					-- Flourishes I : Monster Control
	sets.Flourish["Animated Flourish"] = set_combine(sets.Flourish, sets.Enmity) 	-- Volatile Enmity spike like Provoke
	sets.Flourish["Desperate Flourish"] = {} 										-- Gravity effect 
	sets.Flourish["Violent Flourish"] = {} 											-- Stun effect 
																					-- Flourishes II : Skillchain Enhancers
	sets.Flourish["Reverse Flourish"] = {} 											-- Returns TP in exchange for Finishing Moves
	sets.Flourish["Building Flourish"] = {head=gear.nyameHead,}						-- Increases the strength of the next Weapon Skill
	sets.Flourish["Wild Flourish"] = {}												-- Readies target for Skillchain
																					-- Flourishes III : Weapon Skill Buffs
	sets.Flourish["Climactic Flourish"] = {}										-- Forces Critical Hit(s) on the next attack(s) 
	sets.Flourish["Striking Flourish"] = {head=gear.nyameHead,}						-- Forces a Double Attack on the next swing 
	sets.Flourish["Ternary Flourish"] = {}											-- Forces a Triple Attack on the next swing

	-- Waltzes. Waltz potency gear caps at 50%, and the potency you receive caps at 30%. The engine wears sets.Waltz and then the set named for the waltz.
	sets.Waltz = {
		ammo=gear.yamarang,
    	head = gear.horosHeadPlusOne,
    	body=gear.maxixiBody,
    	hands = gear.horosHandsPlusOne,
    	legs=gear.dashingSubligar,
    	feet=gear.maxixiFeet,
    	neck = gear.unmovingPlusOne,
    	waist=gear.chaac,
    	left_ear=gear.crypticEarring,
    	right_ear=gear.enchanterEarringPlusOne,
    	left_ring=gear.metamorphRing,
    	right_ring=gear.carbuncleRingPlusOne,
    	back=gear.moonlightCape,
	}
	sets.Waltz["Curing Waltz"] = sets.Waltz
	sets.Waltz["Curing Waltz II"] = sets.Waltz
	sets.Waltz["Curing Waltz III"] = sets.Waltz
	sets.Waltz["Curing Waltz IV"] = sets.Waltz
	sets.Waltz["Curing Waltz V"] = sets.Waltz
	sets.Waltz["Divine Waltz"] = sets.Waltz
	sets.Waltz["Divine Waltz II"] = sets.Waltz
	sets.Waltz["Healing Waltz"] = sets.Waltz

	-- Sambas. Gear can extend samba duration.
	sets.Samba = set_combine(sets.Idle.DT, {head=gear.maxixiHead,}) --  Missing Ambu Cape for +15
	
	sets.Samba["Haste Samba"] = {}
	sets.Samba["Aspir Samba"] = {}
	sets.Samba["Aspir Samba II"] = {}
	sets.Samba["Drain Samba"] = {}
	sets.Samba["Drain Samba II"] = {}
	sets.Samba["Drain Samba III"] = {}

	-- Jigs. Gear can extend jig duration.
	sets.Jig = set_combine(sets.Idle.DT, {feet=gear.maxixiFeet,}) -- Horos Tights +3 and Maxixi Toe Shoes +3

	sets.Jig["Spectral Jig"] = sets.Jig
	sets.Jig["Chocobo Jig"] = sets.Jig
	sets.Jig["Chocobo Jig II"] = sets.Jig

	-- Steps. The engine wears sets.Step and then the set named for the step, such as sets.Step['Box Step'].
	-- Step accuracy depends on your melee hit rate, normal accuracy gear included. Every step tested shows an innate 10 accuracy bonus, which gear, merits and Presto raise further.
	sets.Step = {
		ammo=gear.yamarang,
    	head=gear.malignanceHead,
    	body=gear.malignanceBody,
    	hands=gear.malignanceHands,
    	legs=gear.malignanceLegs,
    	feet=gear.malignanceFeet,
    	neck=gear.etoileGorgetPlusOne,
    	waist=gear.reiki,
    	left_ear=gear.odr,
    	right_ear=gear.telos,
    	left_ring=gear.chirichRingPlusOne,
    	right_ring=gear.chirichRingPlusOne,
    	back=gear.sacroMantle,
	}

	-- Weaponskill base, worn for every weaponskill. The set named for the weaponskill merges over it.
	sets.WS = {
		ammo = gear.coiste,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
    	neck=gear.anu,
    	waist = gear.sailfi,
    	left_ear=gear.sherida,
    	right_ear = gear.moonshadeEarringBAtt,
    	left_ring=gear.gereRing,
    	right_ring=gear.eponas,
    	back=gear.sacroMantle,
	}

	-- Merged in ACC mode, once ACC is offered above, after the set named for the weaponskill, so its slots win. Name only the slots ACC mode should change. A weaponskill with an ACC set of its own skips it.
	sets.WS.ACC = {}

	-- Worn on every weaponskill while Climactic Flourish is up. Gear that enhances it, such as Maculele Tiara +3 (head), adds damage to the critical hits it forces.
	-- sets.WS['Climactic Flourish'] = {}

	-- Worn on every weaponskill while Striking Flourish is up. Gear that enhances it, such as Maculele Casaque +3 (body), raises the critical hit rate of the double attack it forces.
	-- sets.WS['Striking Flourish'] = {}

	-- Sets named for one weaponskill, merged over sets.WS.
	-- Dagger weaponskills
	sets.WS["Wasp Sting"] = {}
	sets.WS["Viper Bite"] = {}
	sets.WS["Shadowstitch"] = {}
	sets.WS["Gust Slash"] = {}
	sets.WS["Cyclone"] = {}
	sets.WS["Energy Steal"] = {}
	sets.WS["Energy Drain"] = {}
	sets.WS["Dancing Edge"] = {}
	sets.WS["Shark Bite"] = {}
	sets.WS["Evisceration"] = {
		ammo=gear.ginsen,
		head = gear.blisteringSalletPlusOne,
    	body=gear.gletiBody,
    	hands=gear.gletiHands,
    	legs=gear.gletiLegs,
    	feet=gear.gletiFeet,
		neck=gear.fotiaNeck,
		waist=gear.fotiaWaist,
		left_ear=gear.sherida,
		right_ear=gear.odr,
		left_ring=gear.regalRing,
		right_ring=gear.eponas,}
	sets.WS["Aeolian Edge"] = {
		ammo=gear.yamarang,
    	head=gear.nyameHead,
    	body = gear.nyameBody,
    	hands=gear.nyameHands,
    	legs=gear.nyameLegs,
    	feet=gear.nyameFeet,
    	neck=gear.baetylPendant,
    	waist=gear.fotiaWaist,
   		left_ear = gear.friomisi,
    	right_ear=gear.moonshadeEarringBAtt,
    	left_ring=gear.regalRing,
    	right_ring=gear.ilabrat,
    	back=gear.sacroMantle,}
	sets.WS["Rudra's Storm"] = {}

	-- Hand-to-hand weaponskills
	sets.WS["Combo"] = {}
	sets.WS["Shoulder Tackle"] = {}
	sets.WS["Backhand Blow"] = {}
	sets.WS["Asuran Fists"] = {} 	-- Only with Karambit equipped
	sets.WS["Dragon Kick"] = {} 	-- Only with Hepatizon Baghnakhs NQ/+1 equipped
	sets.WS["One Inch Punch"] = {} 	-- Requires the MNK subjob
	sets.WS["Raging Fists"] = {} 	-- Requires the MNK subjob
	sets.WS["Tornado Kick"] = {} 	-- Requires the MNK subjob

	-- Treasure Hunter gear, worn on an action or melee swing against a monster not yet tagged, and throughout a fight in Full Time mode. It is never worn in None mode, where every job but Thief starts.
	sets.TreasureHunter = {
		head = gear.herculeanHelmNuke, 
		legs = gear.herculeanTrousersAccEnmityDown,
		waist=gear.chaac,}
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
-- Gear returned here merges over the engine's precast set for the action. Every hook from here to status_change_custom adds the job mode's weapons through Weapon_Check below.
function precast_custom(spell)
	local equipSet = {}

	return Weapon_Check(equipSet)
end
-- Gear returned here merges over the engine's midcast set for the action.
function midcast_custom(spell)
	local equipSet = {}

	return Weapon_Check(equipSet)
end
-- Gear returned here merges over the idle or engaged set worn when an action ends.
function aftercast_custom(spell)
	local equipSet = {}

	return Weapon_Check(equipSet)
end
-- Called when a buff is gained or lost, except while an action is in flight. Gear returned here merges over the idle or engaged set.
function buff_change_custom(name,gain)
	local equipSet = {}

	return Weapon_Check(equipSet)
end
-- Gear returned here merges over every idle and engaged build: after each action, on a buff, status or mode change, and when you start or stop moving.
function choose_set_custom()
	local equipSet = {}

	return Weapon_Check(equipSet)
end
-- Called when your status changes, such as engaging, disengaging or resting. Gear returned here merges over the idle or engaged set that follows.
function status_change_custom(new,old)
	local equipSet = {}

	return Weapon_Check(equipSet)
end
-- Called for a "gs c" command the engine does not handle itself, and for the weapon mode, job mode and job mode 2 commands, which call it before the gear rebuild. The command arrives in lowercase.
function self_command_custom(command)

end
-- Called when the job file unloads, after the engine has released its keys and held slots.
function user_file_unload()

end

-- Adds the weapon set named by the current job mode, when one exists. This file sets no job mode options, so it adds nothing
-- until you offer job modes with matching sets.Weapons entries.
function Weapon_Check(equipSet)
	equipSet = set_combine(equipSet,sets.Weapons[state.JobMode.value])

	return equipSet
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
