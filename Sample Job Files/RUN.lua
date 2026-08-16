
--Turin

-- Load and initialize the include file.
include('GearSets-Include')
include('Mirdain-Include')

-- Use "gs c food" to use the specified food item 
Food = "Miso Ramen"

BlueNuke = S{'Spectral Floe','Entomb', 'Magic Hammer', 'Tenebral Crush'}
BlueHealing = S{'Magic Fruit'}
BlueSkill = S{'Occultation','Erratic Flutter','Nature\'s Meditation','Cocoon','Barrier Tusk','Metallic Body','Mighty Guard'}
BlueTank = S{'Jettatura','Geist Wall','Blank Gaze','Sheep Song','Sandspin','Healing Breeze'}

-- 'TP','ACC','DT' are standard Default modes.  You may add more and assigne equipsets for them
state.OffenseMode:options('TP','ACC','DT','PDT','MEVA') -- ACC effects WS and TP modes

-- Function used to change pallets based off sub job and modes
function Macro_Sub_Job()
	local macro = 1
	if player.sub_job == "BLU" then
		state.OffenseMode:set('DT')
		--Set you macro pallet for when you are /BLU
		macro = 1
		send_command('wait 2;aset set tanking')
	else
		state.OffenseMode:set('TP')
		--Set you macro pallet for when you are NOT /BLU
		macro = 1
	end
	return macro
end

Buff_Delay = 5 -- Used this to slow down auto buffing
Tank_Delay = 5 -- delays between tanking actions (only used when auto-buffing enabled and target locked on)

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "12"
MacroBook = "12"
MacroSet = Macro_Sub_Job()

--Modes for specific to Paladin.  These are defined below in "Weapons".
state.WeaponMode:options('Epeolatry','Naegling','Club','Great Axe','Axe')
state.WeaponMode:set('Epeolatry')

--Enable JobMode for UI.
UI_Name = 'Runes'
UI_Name2 = 'Auto Tank'

--Modes for specific to RUN
state.JobMode:options('None','Fire','Ice','Wind','Earth','Lightning','Water','Light','Dark') -- Modes used to use Rune Enhancement
state.JobMode:set('None')

Runes = {
	Fire = {Name = "Ignis", Description = "[ICE RESISTANCE] and deals [FIRE DAMAGE]"},
	Ice = {Name = "Gelus", Description = "[WIND RESISTANCE] and deals [ICE DAMAGE]"},
	Wind = {Name = "Flabra", Description = "[EARTH RESISTANCE] and deals [WIND DAMAGE]"},
	Earth = {Name = "Tellus", Description = "[LIGHTNING RESISTANCE] and deals [EARTH DAMAGE]"},
	Lightning = {Name = "Sulpor", Description = "[WATER RESISTANCE] and deals [LIGHTNING DAMAGE]"},
	Water = {Name = "Unda", Description = "[FIRE RESISTANCE] and deals [WATER DAMAGE]"},
	Light = {Name = "Lux", Description = "[DARK RESISTANCE] and deals [LIGHT DAMAGE]"},
	Dark = {Name = "Tenebrae", Description = "[LIGHT RESISTANCE] and deals [DARKNESS DAMAGE]"},
	None = {Name = 'None', Description = "None"}
}

jobsetup (LockStylePallet,MacroBook,MacroSet)

-- HP balancing: 3000 HP
-- MP balancing: 950 MP

function get_sets()

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

	sets.Weapons.Shield = {}
	sets.Weapons.Sleep = {}

	-- Standard Idle set
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

	-- Set is used for midcast during MEVA OffenseMode
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

	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})

	-- This gear will be equiped when the player is moving and not engaged
	sets.Movement = {
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		legs = gear.carmineLegsPlusOnePathA,
    } -- 73 PDT / 33 MDT		3028 HP / 963 MP

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

	sets.Embolden = { back = gear.evasionistCapeDA,}

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

	--DPS set for tanking
	sets.OffenseMode.TP = {
		head=gear.erilazHeadPlusThree,
		head = gear.adhemarHeadPlusOnePathA,
		hands = gear.adhemarHandsPlusOnePathA,
		legs = gear.samnuhaTightsDA,
	} -- No fucks given

	-- Gear to swap in for ACC when TP
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, { })

	--Physical Damage Taken set for tanking
	sets.OffenseMode.PDT = set_combine(sets.OffenseMode, {
		head = gear.nyameHead,
		body=gear.adamantiteArmor,
		hands=gear.turmsMittensPlusOne,
		neck = gear.unmovingPlusOne,
		waist = gear.sailfi,
		back=gear.nullShawl,
	}) -- Maintains Capped PDT with some DPS mixed in

	--Magic Evasion set for tanking
	sets.OffenseMode.MEVA = set_combine(sets.Idle.MEVA, {

	}) -- Focus on Magic Evasion with some DPS mixed in

	-- Standard Tanking TP set
	sets.OffenseMode.DT = set_combine(sets.Idle.DT, {	
		body=gear.asheraHarness,
		waist = gear.sailfi,
		left_ear=gear.sherida,
		right_ear=gear.telos,
		back = gear.runSTP,
	})

	-- Set used for hate generation on Job abilities
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

	--This set is used as base as is overwrote by specific gear changes (Spell Interruption Rate Down)
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
	-- Used for Magic Spells

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
		left_ring=gear.kishar, -- 4
		right_ring = gear.gelatinousPlusOne,
		back = gear.runFC, -- 10
	} --65 FC

	sets.Precast.Enhancing = set_combine(sets.Precast.FastCast, {
		legs = gear.futharkLegsPlusThree, -- 7  (15 - 8) 
		waist=gear.siegel, -- 8
	}) -- 80+ FC

	sets.Precast.BlueMagic = set_combine (sets.Precast.FastCast, {})

	--Base set for midcast - if not defined will notify and use your idle set for surviability
	sets.Midcast = set_combine(sets.Idle, sets.Enmity, sets.SIRD, {})

	-- Enhancing Skill
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

	-- Elemental
	sets.Midcast.Enhancing.Elemental = set_combine(sets.Midcast.Enhancing, {})

	-- Enhancing Duration on OTHERS
	sets.Midcast.Enhancing.Others = set_combine(sets.Midcast.Enhancing, {})

	-- Status
	sets.Midcast.Enhancing.Status = set_combine(sets.Midcast.Enhancing, {})

	-- Skill
	sets.Midcast.Enhancing.Skill = set_combine(sets.Midcast.Enhancing, {})

	-- Regen Sets
	sets.Midcast.Regen = set_combine(sets.Midcast.Enhancing, {})

	sets.Midcast.Refresh = set_combine(sets.Midcast.Enhancing, {})

	sets.Midcast.Cure = {}

	-- Blue Magic
	sets.Midcast.BlueMagic = {}
	sets.Midcast.BlueMagic.Skill = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Nuke = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Healing = set_combine(sets.Midcast.Cure, {})
	sets.Midcast.BlueMagic.ACC = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Enmity = set_combine(sets.Enmity, {})

	-- High MACC for landing spells
	sets.Midcast.Enfeebling = {}

	-- Specific gear for spells
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

	-- JOB ABILITIES --
	sets.JA = {}
    sets.JA["Elemental Sforzo"] = set_combine(sets.Enmity, { body=gear.futharkBodyPlusThree })
    sets.JA["Gambit"] = set_combine(sets.Enmity, { hands=gear.runeistHandsPlusThree,})
    sets.JA["Rayke"] = set_combine(sets.Enmity, { feet=gear.futharkFeetPlusThree })
    sets.JA["Liement"] = set_combine(sets.Enmity, { body=gear.futharkBodyPlusThree })
    sets.JA["One For All"] = sets.Idle
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
    sets.JA["Vivacious Pulse"] = set_combine(sets.Precast.Divine, { head=gear.erilazHeadPlusThree })
    sets.JA["Embolden"] = set_combine(sets.Enmity, sets.Embolden)
    sets.JA["Swordplay"] = set_combine(sets.Enmity, { hands=gear.futharkHandsPlusThree })
	sets.JA["Provoke"] = sets.Enmity


	--Default WS set base
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
	--This set is used when OffenseMode is ACC and a WS is used (Augments the WS base set)
	sets.WS.ACC = {}
	sets.WS.WSD = {}
	sets.WS.CRIT = {}

	--Great Sword WS
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

	sets.TreasureHunter = {
		ammo=gear.perfectEgg,
		body=gear.volteJupon,
		waist=gear.chaac,
	}

end

-------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE UNLESS YOU NEED TO MAKE JOB SPECIFIC RULES
-------------------------------------------------------------------------------------------------------------------


buff_time = os.clock()
tank_time = os.clock()

JA_Delay = os.clock()


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

	return equipSet
end
-- Augment basic equipment sets
function midcast_custom(spell)
	local equipSet = {}
	equipSet = set_combine(equipSet, Embolden_Check(spell))

	if state.OffenseMode.value == 'MEVA' then
		equipSet = set_combine(equipSet, sets.MEVA)
	end

	return equipSet
end
-- Augment basic equipment sets
function aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end
--Function is called when the player gains or loses a buff
function buff_change_custom(name,gain)
	local equipSet = {}

	return equipSet
end
--This function is called when a update request the correct equipment set
function choose_set_custom()
	local equipSet = {}

	return equipSet
end
--Function is called when the player changes states
function status_change_custom(new,old)
	local equipSet = {}

	return equipSet
end
--Function is called when a self command is issued
function self_command_custom(command)

end

--Function used to automate Job Ability use - Checked first
function check_buff_JA()
	local buff = 'None'
	if os.clock() - buff_time > Buff_Delay then
		local ja_recasts = windower.ffxi.get_ability_recasts()
		local delay = os.clock() - JA_Delay

		if player.sub_job == 'SAM' then
			if not buffactive['Hasso'] and not buffactive['Seigan'] and ja_recasts[138] == 0 then
				buff = "Hasso"
			end
		end

		if player.sub_job == 'WAR' then
			if not buffactive['Berserk'] and ja_recasts[1] == 0 then
				buff = "Berserk"
			elseif not buffactive['Aggressor'] and ja_recasts[4] == 0 then
				buff = "Aggressor"
			elseif not buffactive['Warcry'] and ja_recasts[2] == 0 then
				buff = "Warcry"
			end
		end

		if buffactive[Runes[state.JobMode.value].Name] == 3 and windower.ffxi.get_player().target_locked then
			if not buffactive['Valiance'] and not buffactive['Vallation'] and not buffactive['Liement'] and ja_recasts[23] == 0 and delay > 3 then
				buff = "Vallation" -- Next Single Target DT and FC
			end
			if not buffactive['Valiance'] and not buffactive['Vallation'] and not buffactive['Liement'] and ja_recasts[113] == 0 then
				buff = "Valiance" -- AoE DT and FC
				JA_Delay = os.clock() -- Need to give Valiance a chance to register before Vallation is used
			end
		end

		--Rune sets
		if Runes[state.JobMode.value].Name ~= "None" then
			if ja_recasts[92] == 0 and buffactive[Runes[state.JobMode.value].Name] ~= 3 then
				buff = Runes[state.JobMode.value].Name
				info(Runes[state.JobMode.value].Description)
			end

		end

		if buff ~= 'None' then
			buff_time = os.clock()
		end
	end
	return buff
end

--Function used to automate Spell use
function check_buff_SP()
	local buff = 'None'
	if os.clock() - buff_time > Buff_Delay then
		local sp_recasts = windower.ffxi.get_spell_recasts()

		if not buffactive['Enmity Boost'] and sp_recasts[476] == 0 and player.mp > 100 then
			buff = "Crusade"
		elseif not buffactive['Phalanx'] and sp_recasts[106] == 0 and player.mp > 100 then
			buff = "Phalanx"
		elseif not buffactive['Aquaveil'] and sp_recasts[55] == 0 and player.mp > 100 then
			buff = "Aquaveil"
		elseif not buffactive['Multi Strikes'] and sp_recasts[493] == 0 and player.mp > 36 then
			buff = "Temper"
		elseif not buffactive['Ice Spikes'] and sp_recasts[250] == 0 and player.mp > 16 then
			buff = "Ice Spikes"
		end

		if player.sub_job == "BLU" and player.sub_job_level > 8 then 
			if not buffactive['Defense Boost'] and sp_recasts[547] == 0 and player.mp > 10 then
				buff = "Cocoon"
			end
		end

		if buff ~= 'None' then
			buff_time = os.clock()
		else
			buff = check_tank()
		end
	end
	return buff
end


function check_tank()
	local buff = 'None'
	if os.clock() - tank_time > Tank_Delay then
				log('tank check')
		if (player.status == "Engaged" or windower.ffxi.get_player().target_locked) and state.JobMode2.value == "ON" then
			local sp_recasts = windower.ffxi.get_spell_recasts()
			if sp_recasts[112] == 0 and player.mp > 25 then
				buff = "Flash"
			end
			if sp_recasts[840] == 0 and player.mp > 48 then
				buff = "Foil"
			end
		end
	end

	if buff ~= 'None' then
		tank_time = os.clock()
	end
	return buff
end

-- This function is called when the job file is unloaded
function user_file_unload()

end

-- Swaps back when embolden buff is active to extend duration
function Embolden_Check(spell)
	local equipSet = {}
	if spell.target.id == player.id then
		if buffactive['Embolden'] then
			equipSet = sets.Embolden
			info('Embolden Set')
		end
	end
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
