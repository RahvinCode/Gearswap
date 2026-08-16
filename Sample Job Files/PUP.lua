
--Morwen

-- Load and initialize the include file.
include('GearSets-Include')
include('Mirdain-Include')

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "19"
MacroBook = "19"
MacroSet = "1"

--Uses Items Automatically
AutoItem = false

-- Use "gs c food" to use the specified food item 
Food = "Sublime Sushi"

-- 'TP','ACC','DT' are standard Default modes.  You may add more and assigne equipsets for them ( Idle.X and OffenseMode.X )
state.OffenseMode:options('TP','ACC','DT','PDL','SB','MEVA') -- ACC effects WS and TP modes

--Upon Job change will use a random lockstyleset
Random_Lockstyle = false

-- Set to true to run organizer on job changes
Organizer = false

--Lockstyle sets to randomly equip
Lockstyle_List = {1,2,6,12}

--Set Mode to Damage Taken as Default
state.OffenseMode:set('DT')

--Modes for specific to Ninja
state.WeaponMode:options('God Hands','Pole','Club')
state.WeaponMode:set('God Hands')

-- Initialize Player
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- Weapon setup
	sets.Weapons = {}

	sets.Weapons['God Hands'] = {
		main=gear.godhands,
		range = gear.neoAnimator,
		ammo=gear.canOfAutomatonOilPlusThree,
	}

	sets.Weapons['Club'] = {}

	sets.Weapons['Pole'] = {}

	sets.Weapons.Shield = {}

	-- Standard Idle set with -DT, Refresh, Regen and movement gear
	sets.Idle = {
		head=gear.nyameHead,
		body=gear.nyameBody,
		hands=gear.nyameHands,
		legs=gear.nyameLegs,
		feet=gear.nyameFeet,
		neck = gear.loricatePlusOne,
		waist=gear.carriers,
		left_ear=gear.etiolation,
		right_ear = gear.odnowaPlusOne,
		left_ring=gear.regalRing,
		right_ring = gear.gelatinousPlusOne,
		back = gear.pupDA,
    }

	sets.Idle.Pet = {}
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDT = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
	})

	--Used to swap into movement gear when the player is detected movement when not engaged
	sets.Movement = {
		feet=gear.hermesSandals,
	}

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

	sets.OffenseMode = {
		head=gear.mpacaHead,
		body = gear.mpacaBody,
		hands=gear.mpacaHands,
		legs=gear.mpacaLegs,
		feet=gear.mpacaFeet,
		neck=gear.combatantTorque,
		waist=gear.moonbowBeltPlusOne,
		left_ear=gear.macheEarringPlusOne,
		right_ear = gear.karagozEarringPlusOneSTP,
		left_ring=gear.niqmaddu,
		right_ring=gear.gereRing,
		back = gear.pupDA,
	}

	sets.OffenseMode.TP = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.DT = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.PDT = set_combine(sets.OffenseMode, { })
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode.TP,{
		neck=gear.warderCharmPlusOne,
	})

	--This set is used when OffenseMode is ACC and Enaged (Augments the TP base set)
	-- Cap is 75% - 50% in either I or II
	sets.OffenseMode.SB = 
	{
		-- Belt SB II 15%
		-- Mpaca Legs SB II 5%
		-- Ring SB II 5%
		-- Earring SB I 6%
		head=gear.volteTiara, -- 6%
		body=gear.malignanceBody,
		hands=gear.volteMittens, -- 6%
		legs=gear.mpacaLegs, -- 5%
		feet=gear.volteSpats, -- 6%
		waist=gear.moonbowBeltPlusOne, -- 15%
		left_ear=gear.macheEarringPlusOne,
		right_ear=gear.karagozEarringPlusOne, -- 6%
		left_ring=gear.niqmaddu, -- 5%
		right_ring=gear.chirichRingPlusOne, -- 10%
		back = gear.pupDA,
	}

	sets.Precast = {}

	-- Used for Magic Spells
	sets.Precast.FastCast = {}

	sets.Precast.Enmity = {}

	--Base set for midcast - if not defined will notify and use your idle set for surviability
	sets.Midcast = set_combine(sets.Idle, {})

	sets.Pet_Midcast = {}
	sets.Pet_Midcast['Bone Crusher'] = {}

	-- Job Abilities
	sets.JA = {}
	sets.JA['Overdrive'] = set_combine(sets.Idle, {})
	sets.JA['Activate'] = set_combine(sets.Idle, {})
	sets.JA['Repair'] = set_combine(sets.Idle, {})
	sets.JA['Role Reversal'] = set_combine(sets.Idle, {})
	sets.JA['Ventriloquy'] = set_combine(sets.Idle, {})
	sets.JA['Tactical Switch'] = set_combine(sets.Idle, {})
	sets.JA['Cooldown'] = set_combine(sets.Idle, {})
	sets.JA['Deus Ex Automata'] = set_combine(sets.Idle, {})
	sets.JA['Maintenance'] = set_combine(sets.Idle, {})
	sets.JA['Heady Artifice'] = set_combine(sets.Idle, {})

	-- Pet commands
	sets.JA['Deploy'] = set_combine(sets.Idle, {})
	sets.JA['Deactivate'] = set_combine(sets.Idle, {})
	sets.JA['Retrieve'] = set_combine(sets.Idle, {})
	sets.JA.Maneuver = set_combine(sets.Idle, {})

	sets.JA["Berserk"] = {}
	sets.JA["Warcry"] = {}
	sets.JA["Defender"] = {}
	sets.JA["Aggressor"] = {}
	sets.JA["Provoke"] = sets.Precast.Enmity

	--Default WS set base
	sets.WS = {
		head=gear.mpacaHead,
		body=gear.mpacaBody,
		hands=gear.mpacaHands,
		legs=gear.mpacaLegs,
		feet=gear.mpacaFeet,
		neck=gear.fotiaNeck,
		waist=gear.moonbowBeltPlusOne,
		left_ear = gear.schere,
		right_ear=gear.macheEarringPlusOne,
		left_ring=gear.regalRing,
		right_ring=gear.niqmaddu,
		back = gear.pupDA,
	}

	sets.WS.SB = set_combine( sets.WS, { -- This maximize SB

	})

	--This set is used when OffenseMode is ACC and a WS is used (Augments the WS base set)
	sets.WS.ACC = set_combine(sets.WS,{})

	sets.WS.PDL = set_combine(sets.WS,{})

	--WS Sets
	sets.WS["Combo"] = set_combine(sets.WS,{})
	sets.WS["Shoulder Tackle"] = set_combine(sets.WS,{})
	sets.WS["One Inch Punch"] = set_combine(sets.WS,{})
	sets.WS["Backhand Blow"] = set_combine(sets.WS,{})
	sets.WS["Raging Fists"] = set_combine(sets.WS,{})
	sets.WS["Spinning Attack"] = set_combine(sets.WS,{})
	sets.WS["Howling Fist"] = set_combine(sets.WS,{})
	sets.WS["Dragon Kick"] = set_combine(sets.WS,{})
	sets.WS["Asuran Fists"] = set_combine(sets.WS,{})
	sets.WS["Tornado Kick"] = set_combine(sets.WS,{})
	sets.WS["Victory Smite"] = set_combine(sets.WS,{})
	sets.WS["Shijin Spiral"] = set_combine(sets.WS,{})

	sets.TreasureHunter = {

	}

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
	if spell.name:contains('Maneuver') then
		equipSet = sets.JA.Maneuver
	elseif spell.type == 'WeaponSkill' then
		if state.OffenseMode.value == "MEVA" then
			equipSet = { neck=gear.warderCharmPlusOne, }
		end
	end
	return equipSet
end
-- Augment basic equipment sets
function midcast_custom(spell)
	local equipSet = {}

	return equipSet
end
-- Augment basic equipment sets
function aftercast_custom(spell)
	local equipSet = {}

	return choose_gear()
end

-- Called when the pet dies or is summoned
function pet_change_custom(pet,gain)
	local equipSet = {}

	return equipSet
end

-- Called during a pet midcast
function pet_midcast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called after the performs an action
function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

--Function is called when the player gains or loses a buff
function buff_change_custom(name,gain)
	local equipSet = {}

	return choose_gear()
end
--This function is called when a update request the correct equipment set
function choose_set_custom()
	local equipSet = {}

	return choose_gear()
end
--Function is called when the player changes states
function status_change_custom(new,old)
	local equipSet = {}

	return choose_gear()
end
--Function is called when a self command is issued
function self_command_custom(command)

end
--Custom Function
function choose_gear()
	local equipSet = {}

	return equipSet
end

function check_buff_JA()
	local buff = 'None'
	local ja_recasts = windower.ffxi.get_ability_recasts()

	-- Sub job has least priority
	if player.sub_job == 'WAR' then
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

-- This function is called when the job file is unloaded
function user_file_unload()

end
