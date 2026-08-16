
-- Luthien

-- Load and initialize the include file.
include('GearSets-Include')
include('Mirdain-Include')

-- Use "gs c food" to use the specified food item 
Food = "Miso Ramen"

-- 'TP','ACC','DT' are standard Default modes.  You may add more and assigne equipsets for them ( Idle.X and OffenseMode.X )
state.OffenseMode:options('TP','ACC','DT','PDT','MEVA','AoE') -- ACC effects WS and TP modes

--Enable JobMode for UI - Once locked-on and auto buff enabled it will do enmity actions
UI_Name = 'Auto Tank'
UI_Name2 = 'Runes'

Buff_Delay = 2 -- Used this to slow down auto buffing
Tank_Delay = 1 -- delays between tanking actions (only used when auto-buffing enabled and target locked on)

--Modes for specific to Paladin.  These are defined below in "Weapons".
state.WeaponMode:options('Burtgang','Naegling','Club','Shining One')
state.WeaponMode:set('Burtgang')

-- Function used to change pallets based off sub job and modes
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

-- Blue spells used for tanking (Azureset)

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

BlueNuke = S{'Spectral Floe','Entomb', 'Magic Hammer', 'Tenebral Crush'}
BlueHealing = S{'Magic Fruit', 'Healing Breeze','Pollen', 'Wild Carrot'}
BlueSkill = S{'Occultation','Erratic Flutter','Nature\'s Meditation','Cocoon','Barrier Tusk','Matellic Body','Mighty Guard'}
BlueTank = S{'Jettatura','Blank Gaze','Sheep Song','Geist Wall'}

-- Used when /RUN

--Modes for specific to /RUN
state.JobMode2:options('None','Fire','Ice','Wind','Earth','Lightning','Water','Light','Dark') -- Modes used to use Rune Enhancement
state.JobMode2:set('None')

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

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "13"
MacroBook = "5"
MacroSet = Macro_Sub_Job()

--Command to Lock Style and Set the correct macros
jobsetup (LockStylePallet,MacroBook,MacroSet)

--
-- HP balancing: 2800 HP
-- MP balancing: 900 MP
--

function get_sets()

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

	--Default Shield
	sets.Weapons.Shield = {}

	-- Standard Idle set
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

	sets.Idle.TP = set_combine( sets.Idle, {
		sub=gear.duban,
	})

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

	sets.Movement = {
		ammo=gear.staunchPlusOne,
		legs = gear.carmineLegsPlusOnePathA,
		right_ear=gear.chevalierEarringPlusOne,
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

	--Base TP set to build off
	sets.OffenseMode.TP = set_combine( sets.OffenseMode, {

	})

	--This set is used when OffenseMode is ACC and Enaged (Augments the TP base set)
	sets.OffenseMode.ACC = set_combine( sets.OffenseMode, {

	})

	--This set is used when OffenseMode is DT and Enaged (Augments the TP base set)
	sets.OffenseMode.DT = set_combine( sets.OffenseMode, {
		body = gear.sakpataBody,
		neck = gear.unmovingPlusOne,
		right_ear = gear.odnowaPlusOne,
	})

	--This set is used when OffenseMode is PDT and Enaged (Augments the TP base set)
	sets.OffenseMode.PDT = set_combine( sets.Idle.PDT, {
		waist=gear.flumeBeltPlusOne,
		left_ear=gear.etherealEarring,
	})

	--This set is used when OffenseMode is MEVA and Enaged (Augments the TP base set)
	sets.OffenseMode.MEVA = set_combine( sets.Idle.MEVA, {
		left_ear=gear.telos,
		right_ear=gear.chevalierEarringPlusOne,
		left_ring=gear.lehkoHabhokaRing,
		back=gear.nullShawl,
	})

	--This set is used when OffenseMode is AoE and Enaged (Augments the TP base set)
	sets.OffenseMode.AoE = set_combine( sets.Idle.AoE, {

	})

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

	-- Used for Magic Spells
	sets.Precast.FastCast = { -- 61 FC with 3029/890
		ammo=gear.sapience, -- 2
		head = gear.carmineHeadPlusOnePathD, -- 14
		body=gear.reverenceBodyPlusThree, -- 10
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.odysseanCuissesFCB, -- 6
		feet = gear.odysseanGreavesFC, -- 11
		neck=gear.voltsurge, -- 4
		waist = gear.platinumMoogleBelt,
		left_ear = gear.tuisto,
		right_ear=gear.etiolation, -- 1
		left_ring=gear.weatherspoon, -- 5
		right_ring=gear.kishar, -- 4
		back = gear.pldFCB, -- 10
	}

	-- Augments the base Fast Cast set when a cure spell is used
	sets.Precast.Cure = {
		left_ring=gear.rahabRing,
	}
	-- Augments the base Fast Cast set when a cure or raise is used.
	sets.Precast.QuickMagic = {}

	--Base set for midcast - if not defined will notify and use your idle set for surviability
	sets.Midcast = set_combine( sets.Idle, {
	
	})

	--This set is used in conjuction with set_combine
	sets.Midcast.SIRD = {
		ammo=gear.staunchPlusOne, -- 11
		head = gear.souveranHeadPlusOnePathC, -- 20
		legs = gear.founderHoseMacc, -- 30
		neck=gear.moonlightNeck, -- 15
		waist=gear.audumbla, -- 10
		back = gear.pldCure, -- 10
	} -- 96 +10 merits = 106

	-- Cure Set (special SIRD set)
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

	-- Enhancing Skill
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

	sets.Midcast.Divine = set_combine( sets.Idle, sets.Enmity, sets.Midcast.SIRD, {
	
	})

	-- High MACC for landing spells
	sets.Midcast.Enfeebling = {}

	-- Specific gear for spells
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
		left_ear=gear.tuisto,
		right_ear = gear.odnowaPlusOne,
		left_ring=gear.moonlightRing,
		right_ring=gear.moonlightRing,
		back = gear.pldCure,
	}

	sets.Midcast["Flash"] = set_combine( sets.Idle, sets.Enmity, sets.Midcast.SIRD, {
	
	})

	sets.Cover = { 
		body = gear.caballariusBodyPlusThree
	}

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
	sets.JA["Iron Will"] = set_combine( sets.Enmity, { head = gear.caballariusHeadPlusThree })
	sets.JA["Fealty"] = set_combine( sets.Enmity, { body = gear.caballariusBodyPlusThree })
	sets.JA["Chivalry"] = set_combine( sets.Enmity, { hands = gear.caballariusHandsPlusThree })
	sets.JA["Majesty"] = set_combine( sets.Enmity, { })
	sets.JA["Berserk"] = set_combine( sets.Enmity, { })
	sets.JA["Defender"] = set_combine( sets.Enmity, { })
	sets.JA["Aggressor"] = set_combine( sets.Enmity, { })

	--Default WS set base
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
	--This set is used when OffenseMode is ACC and a WS is used (Augments the WS base set)
	sets.WS.ACC = {}
	sets.WS.WSD = {}
	sets.WS.CRIT = {}

	--Sword WS
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

	--Custom sets for each jobsetup
	sets.Custom = {}

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
		if buffactive['Rampart'] and (spell.type == 'WhiteMagic' or spell.type == 'BlueMagic') then
			equipSet = sets.Midcast.Rampart
		end
		if state.OffenseMode.value == 'MEVA' and not spell.name:contains('Cure') then
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

	if buffactive['Cover'] and gain then
		equipSet = sets.Cover
	end

	if name == "Rampart" and not gain then
		send_command('input /ap Rampart [OFF]')
	elseif name == "Sentinel" and not gain then
		send_command('input /p Sentinel [OFF]')
	elseif name == "Invincible" and not gain then
		send_command('input /p Invincible [OFF]')
	end

	return equipSet
end
--This function is called when a update request the correct equipment set
function choose_set_custom()
	local equipSet = {}
	 if buffactive['Cover'] then
		equipSet = sets.Cover
	 end
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

--Function used to automate Job Ability use
function check_buff_JA()
	local buff = 'None'
	if os.clock() - buff_time > Buff_Delay then
		local ja_recasts = windower.ffxi.get_ability_recasts()

		if player.sub_job == 'SAM' and player.sub_job_level > 24 then
			if not buffactive['Hasso'] and not buffactive['Seigan'] and ja_recasts[138] == 0 and player.sub_job_level > 24 then
				buff = "Hasso"
			end
		end

		if player.sub_job == 'WAR' then
			if not buffactive['Berserk'] and ja_recasts[1] == 0 and player.sub_job_level > 14 then
				buff = "Berserk"
			end
			if not buffactive['Aggressor'] and ja_recasts[4] == 0 and player.sub_job_level > 44 then
				buff = "Aggressor"
			end
			if not buffactive['Warcry'] and ja_recasts[2] == 0 and player.sub_job_level > 34 then
				buff = "Warcry"
			end
		end

		if player.sub_job == 'RUN' then
			--Rune sets
			if Runes[state.JobMode2.value].Name ~= "None" and player.sub_job_level > 4 then
				if ja_recasts[92] == 0 and buffactive[Runes[state.JobMode2.value].Name] ~= 2 then
					buff = Runes[state.JobMode2.value].Name
					info(Runes[state.JobMode2.value].Description)
				end
			end
		end

		if not buffactive['Majesty'] and ja_recasts[150] == 0 and player.main_job_level > 69 then
			buff = "Majesty"
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
		if not buffactive['Enmity Boost'] and sp_recasts[476] == 0 and player.mp > 18 and player.main_job_level > 87 then
			buff = "Crusade"
		elseif not buffactive['Phalanx'] and sp_recasts[106] == 0 and player.mp > 21 and player.main_job_level > 76 then
			buff = "Phalanx"
		elseif not buffactive['Reprisal'] and sp_recasts[97] == 0 and player.mp > 25 and player.main_job_level > 60 then
			buff = "Reprisal"
		elseif not buffactive['Enlight'] and sp_recasts[274] == 0 and player.mp > 25 and player.main_job_level > 84 then
			buff = "Enlight II"
		end
		if player.sub_job == "BLU" then
			if not buffactive['Defense Boost'] and sp_recasts[547] == 0 and player.mp > 10 and player.sub_job_level > 8 then
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
		if (player.status == "Engaged" or windower.ffxi.get_player().target_locked) and state.JobMode.value == "ON" then
			local sp_recasts = windower.ffxi.get_spell_recasts()
			local ja_recasts = windower.ffxi.get_ability_recasts()
			if sp_recasts[112] == 0 and player.mp > 25 and player.main_job_level > 36 then
				buff = "Flash"
			elseif ja_recasts[46] == 0 and state.JobMode.value == "ON" and player.main_job_level > 14 then
				buff = "Shield Bash"
			elseif ja_recasts[159] == 0 and player.mp < 150 and player.tp > 2000 and state.JobMode.value == "ON" and player.main_job_level > 14 then
				buff = "Chivalry"
			elseif sp_recasts[840] == 0 and player.mp > 48 and player.sub_job == "RUN" and player.sub_job_level > 57 then
				buff = "Foil"
			end
		end
	end

	if buff ~= 'None' then
		tank_time = os.clock()
	end
	return buff
end

-- Function is called when the job lua is unloaded
function user_file_unload()

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
