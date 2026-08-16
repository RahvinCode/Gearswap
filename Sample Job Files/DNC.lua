-- Salidar

-- Load and initialize the include file.
include('GearSets-Include')
include('Mirdain-Include')

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "16"
MacroBook = "6"
MacroSet = "1"

--Uses Items Automatically
AutoItem = false

--Upon Job change will use a random lockstyleset
Random_Lockstyle = true

--Lockstyle sets to randomly equip
Lockstyle_List = {16,17,18}

-- Use "gs c food" to use the specified food item 
Food = "Sublime Sushi"

-- 'TP','ACC','DT' are standard Default modes.  You may add more and assigne equipsets for them
state.OffenseMode:options('DT','TP','SB','Farm') -- ACC effects WS and TP modes
state.OffenseMode:set('DT')

state.WeaponMode:options('Aeneas','Karambit')
state.WeaponMode:set('Aeneas')

-- Initialize Player
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	sets.Weapons = {}
	sets.Weapons['Terpsichore'] = {}
	sets.Weapons['Twashtar'] = {}
	sets.Weapons['Aeneas'] = {main=gear.aeneas, sub=gear.gleti,}
	sets.Weapons['Karambit'] = {main=gear.karambit,}

	-- Standard Idle set with -DT, Refresh, Regen and movement gear
	sets.Idle = {}

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

	sets.Movement = {right_ring=gear.shneddickRing,}

	--Spell Received Sets
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
	sets.Holy_Water = {
	    neck=gear.nicander,
	}

	--This set is used when OffenseMode is DT and Enaged (Augments the TP base set)
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
	--Base TP set to build off
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

	--This set is used when OffenseMode is ACC and Enaged (Augments the TP base set)
	sets.OffenseMode.ACC = {}
	--Dual Wield
	sets.OffenseMode.DW = {}

	sets.Precast = {}
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
	sets.Enmity = {}
	sets.Midcast = {}
	sets.Midcast.SIRD = {}
	sets.Midcast.Cure = {}
	sets.Midcast.Enhancing = {}
	sets.Midcast.Enfeebling = {}
	sets.Midcast["Stoneskin"] = {}
	-------------------------------------------------------------------------------
	---------------------------------  JA Sets  -----------------------------------
	-- When you combine with idle during JA's you'll get ~2 sec of high defense --- 
	-------------------- if not overwritten by specified gear ---------------------
	-------------------------------------------------------------------------------
	sets.JA = {}

	sets.JA["Trance"] = {}
	sets.JA["Contradance"] = {}
	sets.JA["Saber Dance"] = {}
	sets.JA["Fan Dance"] = {}
	sets.JA["No Foot Rise"] = {}
	sets.JA["Presto"] = {}
	sets.JA["Grand Pas"] = {}
	-------------------------------------------------------------------------------
	-- Flourishes provide buffs to the Dancer and debuffs to the target monster. --
	-------------------------------------------------------------------------------
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
	-------------------------------------------------------------------------------
	-- Waltz Potency gear caps at 50%, while Waltz received potency caps at 30%. -- 
	-------------------------------------------------------------------------------
	sets.Waltz = {    
		ammo=gear.yamarang,
    	head = gear.horosHeadPlusOne,
    	body=gear.maxixiBody,
    	hands = gear.horosHandsPlusOne,
    	legs=gear.dashingSubligar,
    	feet=gear.maxixiFeet,
    	neck = gear.unmovingPlusOne,
    	waist=gear.chaac,
    	left_ear=gear.enchanterEarringPlusOne,
    	right_ear=gear.crypticEarring,
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
	-------------------------------------------------------------------------------
	---------- Samba duration can be increased using various equipment. -----------
	-------------------------------------------------------------------------------
	sets.Samba = set_combine(sets.Idle.DT, {head=gear.maxixiHead,}) --  Missing Ambu Cape for +15
	
	sets.Samba["Haste Samba"] = {}
	sets.Samba["Aspir Samba"] = {}
	sets.Samba["Aspir Samba II"] = {}
	sets.Samba["Drain Samba"] = {}
	sets.Samba["Drain Samba II"] = {}
	sets.Samba["Drain Samba III"] = {}
	-------------------------------------------------------------------------------
	----------- Jigs duration can be increased using various equipment. ----------- 
	-------------------------------------------------------------------------------
	sets.Jig = set_combine(sets.Idle.DT, {feet=gear.maxixiFeet,}) -- Horos Tights +3 and Maxixi Toe Shoes +3

	sets.Jig["Spectral Jig"] = sets.Jig
	sets.Jig["Chocobo Jig"] = sets.Jig
	sets.Jig["Chocobo Jig II"] = sets.Jig
	-------------------------------------------------------------------------------
	----- Step Accuracy depends on your melee hit rate (including your normal -----
	---- Accuracy equipment). All Steps tested have shown an innate 10 Accuracy --- 
	-- bonus, which can be further enhanced through various pieces of equipment, -- 
	----------------------------- merits, and Presto. -----------------------------
	-------------------------------------------------------------------------------
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
	
	sets.JA["Quickstep"] = sets.Step
	sets.JA["Box Step"] = sets.Step
	sets.JA["Stutter Step"] = sets.Step
	sets.JA["Feather Step"] = set_combine(sets.Idle.DT, {})

	--Default WS set base
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

	--This set is used when OffenseMode is ACC and a WS is used (Augments the WS base set)
	sets.WS.ACC = {}
	--WS Sets
	-- Dagger WS
	sets.WS["Wasp Sting"] = {}
	sets.WS["Viper Bite"] = {}
	sets.WS["Shadowstich"] = {}
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
   		left_ear = gear.moonshadeEarringBAtt,
    	right_ear=gear.friomisi,
    	left_ring=gear.regalRing,
    	right_ring=gear.ilabrat,
    	back=gear.sacroMantle,}
	sets.WS["Rudra's Storm"] = {}

	-- Hand to Hand WS
	sets.WS["Combo"] = {}
	sets.WS["Shoulder Tackle"] = {}
	sets.WS["Backhand Blow"] = {}
	sets.WS["Asuran Fists"] = {} 	-- Only if Karambit Weapon Equipt
	sets.WS["Dragon Kick"] = {} 	-- Only if Hepatizon Baghnakhs NQ/+1 Weapon Equipt
	sets.WS["One Inch Punch"] = {} 	-- Must Sub MNK
	sets.WS["Raging Fists"] = {} 	-- Must Sub MNK
	sets.WS["Tornado Kick"] = {} 	-- Must Sub MNK

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
	-- Typically used for Macro pallet changing
end
--Adjust custom precast actions
function pretarget_custom(spell,action)
	
end
-- Augment basic equipment sets
function precast_custom(spell)
	local equipSet = {}

	return Weapon_Check(equipSet)
end
-- Augment basic equipment sets
function midcast_custom(spell)
	local equipSet = {}

	return Weapon_Check(equipSet)
end
-- Augment basic equipment sets
function aftercast_custom(spell)
	local equipSet = {}

	return Weapon_Check(equipSet)
end
--Function is called when the player gains or loses a buff
function buff_change_custom(name,gain)
	local equipSet = {}

	return Weapon_Check(equipSet)
end
--This function is called when a update request the correct equipment set
function choose_set_custom()
	local equipSet = {}

	return Weapon_Check(equipSet)
end
--Function is called when the player changes states
function status_change_custom(new,old)
	local equipSet = {}

	return Weapon_Check(equipSet)
end
--Function is called when a self command is issued
function self_command_custom(command)

end
--Function is called when a lua is unloaded
function user_file_unload()

end

--Function used to automate Job Ability use
function check_buff_JA()
	local buff = 'None'
	local ja_recasts = windower.ffxi.get_ability_recasts()

	if player.sub_job == 'SAM' and player.sub_job_level > 8 then
		if not buffactive['Hasso'] and not buffactive['Seigan'] and ja_recasts[138] == 0 then
			buff = "Hasso"
		elseif not buffactive['Meditate'] and ja_recasts[134] == 0 then
			buff = "Meditate"
		end
	end

	if player.sub_job == 'WAR' and player.sub_job_level > 8 then
		if not buffactive['Berserk'] and ja_recasts[1] == 0 then
			buff = "Berserk"
		elseif not buffactive['Aggressor'] and ja_recasts[4] == 0 then
			buff = "Aggressor"
		elseif not buffactive['Warcry'] and ja_recasts[2] == 0 then
			buff = "Warcry"
		end
	end

	return buff
end

function check_buff_SP()
	local buff = 'None'
	--local sp_recasts = windower.ffxi.get_spell_recasts()
	return buff
end

function pet_change_custom(pet,gain)
	local equipSet = {}
	
	return equipSet
end

function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

function pet_midcast_custom(spell)
	local equipSet = {}

	return equipSet
end

function Weapon_Check(equipSet)
	equipSet = set_combine(equipSet,sets.Weapons[state.JobMode.value])

	return equipSet
end

function pet_change_custom(pet,gain)
	local equipSet = {}
	
	return equipSet
end

function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

function pet_midcast_custom(spell)
	local equipSet = {}

	return equipSet
end
