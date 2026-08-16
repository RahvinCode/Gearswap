--Hurin

-- Load and initialize the include file.
include('GearSets-Include')
include('Mirdain-Include')

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "14"
MacroBook = "20"
MacroSet = "1"

--Uses Items Automatically
AutoItem = false

--Upon Job change will use a random lockstyleset
Random_Lockstyle = false

--Lockstyle sets to randomly equip
Lockstyle_List = {1,2,6,12}

-- Use "gs c food" to use the specified food item 
Food = "Tropical Crepe"

--Set default mode (TP,ACC,DT)
state.OffenseMode:options('TP','ACC','DT','PDT','MEVA')
state.OffenseMode:set('DT')

--Weapon Modes
state.WeaponMode:options('Nuke','Unlocked')
state.WeaponMode:set('Nuke')

--Command to Lock Style and Set the correct macros
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	sets.Weapons = {}

	sets.Weapons['Nuke'] ={
		main = gear.mpacaStaff,
		sub=gear.enki,
	}

	sets.Weapons.Shield ={}

	sets.Weapons['Unlocked'] ={
		main = gear.mpacaStaff,
		sub=gear.enki,
	}

	--Standard Idle set with -DT,Refresh,Regen and movement gear
	sets.Idle = {
		ammo=gear.staunchPlusOne,
		head=gear.wicceHeadPlusThree, --11
		body=gear.wicceBodyPlusThree,
		hands=gear.wicceHandsPlusThree, --13
		legs=gear.wicceLegsPlusThree,
		feet=gear.wicceFeetPlusThree, --11 (removed while moving)
		neck = gear.loricatePlusOne, --6
		waist=gear.carriers,
		left_ear=gear.lugalbanda,
		right_ear=gear.etiolation,
		left_ring=gear.defending, --10
		right_ring=gear.stikiniPlusOne,
		back = gear.blmNuke,
    }

	-- 'TP','ACC','DT','PDT','MEVA'
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDT = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
	})
	-- Set is only applied when sublimation is charging
	sets.Idle.Sublimation = set_combine(sets.Idle, {
	    waist=gear.embla, -- +3 Submlimation when active
	})
	sets.Idle.Resting = set_combine(sets.Idle, {})

	--Used to swap into movement gear when the player is detected movement when not engaged
	sets.Movement = {
		feet=gear.heraldGaiters,
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

	sets.OffenseMode = {}
	sets.OffenseMode.TP = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.DT = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.PDT = set_combine(sets.OffenseMode, { })
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, { })

	sets.Precast = {}

	-- Used for Magic Spells
	sets.Precast.FastCast = {
		ammo = gear.ghastlyTathlumPlusOne,
		head = gear.merlinicHoodFCB, -- 14
		body = gear.merlinicJubbahFC, -- 13
		hands = gear.merlinicDastanasBFC, -- 7
		legs=gear.agwuLegs, -- 7
		feet = gear.merlinicCrackowsBFC, -- 12
		neck = gear.unmovingPlusOne, 
		waist=gear.embla, -- 5
		left_ear=gear.malignanceEar, -- 4
		right_ear=gear.etiolation, -- 1
		left_ring=gear.kishar, -- 4
		right_ring=gear.weatherspoon, -- 5
		back = gear.blmFC, -- 10
	} -- 80% FC

	-- Used for Enhancing Magic
	sets.Precast.Enhancing = set_combine(sets.Precast.FastCast, {})

	sets.Precast["Impact"] = set_combine(sets.Precast.FastCast,{
	    ammo=gear.sapience,
		neck=gear.voltsurge,
		body=gear.twilightCloak,
	})

	-- Job Abilities
	sets.JA = {}
	sets.JA["Collimated Fervor"] = {}
	sets.JA["Convert"] = {}
	sets.JA["Bolster"] = {}
	sets.JA["Full Circle"] = {}
	sets.JA["Lasting Emanation"] = {}
	sets.JA["Ecliptic Attrition"] = {}
	sets.JA["Life Cycle"] = {}
	sets.JA["Blaze of Glory"] = {}
	sets.JA["Dematerialzie"] = {}
	sets.JA["Theurgic Focus"] = {}
	sets.JA["Concentric Pulse"] = {}
	sets.JA["Mending Halation"] = {}
	sets.JA["Radial Arcana"] = {}
	sets.JA["Widened Compass"] = {}
	sets.JA["Entrust"] = {}

	--Base set for midcast - if not defined will notify and use your idle set for surviability
	sets.Midcast = set_combine(sets.Idle, {
	
	})

	--This set is used as base as is overwrote by specific gear changes (Spell Interruption Rate Down)
	sets.Midcast.SIRD = {

	}

	-- Cure Set
	sets.Midcast.Cure = {

    }

	-- Enhancing Skill
	sets.Midcast.Enhancing = {
		main=gear.daybreak,
		sub=gear.ammurapi,
		ammo = gear.ghastlyTathlumPlusOne,
		head = gear.telchineCapBEnhDur,
		body = gear.telchineChasubleBEnhDur,
		hands = gear.telchineGlovesBRegen,
		legs = gear.telchineBraconiBEnhDur,
		feet = gear.telchinePigachesBEnhDur,
		neck=gear.incanterTorque,
		waist=gear.embla,
		left_ear=gear.mimir,
		right_ear=gear.etiolation,
		left_ring = gear.gelatinousPlusOne,
		right_ring=gear.stikiniPlusOne,
		back=gear.perimedeCape,
	}
	sets.Midcast.Enhancing.Others = set_combine(sets.Midcast.Enhancing, {});
	sets.Midcast.Enhancing.Status = set_combine(sets.Midcast.Enhancing, {});
	sets.Midcast.Enhancing.Skill = set_combine(sets.Midcast.Enhancing, {});

	-- High MACC for landing spells
	sets.Midcast.Enfeebling = {
	    main=gear.daybreak,
		sub=gear.ammurapi,
		ammo = gear.ghastlyTathlumPlusOne,
		head=gear.wicceHeadPlusThree,
		body=gear.wicceBodyPlusThree,
		hands=gear.wicceHandsPlusThree,
		legs=gear.wicceLegsPlusThree,
		feet=gear.wicceFeetPlusThree,
		neck=gear.incanterTorque,
		waist=gear.luminarySash,
		left_ear=gear.malignanceEar,
		right_ear=gear.wicceEarringPlusOne,
		left_ring=gear.weatherspoon,
		right_ring=gear.stikiniPlusOne,
		back = gear.blmNuke,
	}

	sets.Midcast.Enfeebling.MACC = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Enfeebling.Potency = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Enfeebling.Duration = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Enfeebling.Drain = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Enfeebling.Aspir = set_combine(sets.Midcast.Enfeebling, {})

	sets.Midcast.Dark = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Dark.MACC = set_combine(sets.Midcast.Enfeebling.MACC, {})
	sets.Midcast.Dark.Absorb = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Dark.Enhancing = set_combine(sets.Midcast.Enhancing, {})

	sets.Midcast.Nuke = {
		ammo = gear.ghastlyTathlumPlusOne,
		head=gear.eaHatPlusOne,
		body=gear.wicceBodyPlusThree,
		hands = gear.agwuHands,
		legs=gear.wicceLegsPlusThree,
		feet = gear.agwuFeet,
		neck = gear.sorcererStolePlusTwo,
		waist = gear.acuityBeltPlusOne,
		left_ear=gear.malignanceEar,
		right_ear=gear.regalEarring,
		left_ring = gear.metamorphPlusOne,
		right_ring=gear.freke,
		back = gear.blmNuke,
	}

	sets.Midcast.Burst = set_combine(sets.Midcast.Nuke, { })

	sets.Midcast.Nuke.Earth = {
	    neck=gear.quanpur,
	}

	sets.Midcast['Impact'] = set_combine(sets.Midcast.Nuke, {
		hands=gear.wicceHandsPlusThree,
		legs=gear.wicceLegsPlusThree,
		feet=gear.wicceFeetPlusThree,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
	})

	-- Misc Sets
	sets.Midcast.CuragaSet = sets.Midcast.Cure

	sets.Midcast.Cursna = {}

	sets.MP_Recover = {
	    body=gear.spaekonaBodyPlusThree,
	}

	--Used for elemental Bar Magic Spells
	sets.Midcast.Enhancing.Elemental = {}

	-- Specific gear for spells
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		right_ring=gear.stikiniPlusOne,
		waist=gear.siegel,
		neck=gear.nodens,
	})

	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, {
		head=gear.amalricCoifPlusOne
	})

	sets.Midcast.Refresh = set_combine(sets.Midcast.Enhancing, {
		head = gear.amalricCoifPlusOne
	})

	-- Aspir Set
	sets.Midcast.Aspir = {}

	sets.WS = {}

	--This set is used when OffenseMode is ACC and a WS is used (Augments the WS base set)
	sets.WS.ACC = {}

	sets.WS["Myrkr"] = {
		ammo = gear.ghastlyTathlumPlusOne,
		head = gear.amalricHeadPlusOnePathA,
		body = gear.amalricBodyPlusOnePathA,
		hands = gear.vanyaHandsPathA,
		legs = gear.amalricLegsPlusOnePathA,
		feet = gear.vanyaFeetPathA,
		neck=gear.sanctity,
		waist=gear.luminarySash,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.etiolation,
		left_ring=gear.etanaRing,
		right_ring = gear.metamorphPlusOne,
		back = gear.blmNuke,
	}

	sets.TreasureHunter = { }

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

	return equipSet
end
-- Augment basic equipment sets
function midcast_custom(spell)
	local equipSet = {}
	if spell.skill == 'Elemental Magic' and not Elemental_Enfeeble:contains(spell.name) and player.MPP < 30 then
		windower.add_to_chat(8,'Player Less than 30% MP - Recover MP!')
		equipSet = sets.MP_Recover
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

--Function is called when a self command is issued
function self_command_custom(command)

end

-- Function is called when the job lua is unloaded
function user_file_unload()

end

--Function used to automate Job Ability use - Checked first
function check_buff_JA()
	local buff = 'None'
	--local ja_recasts = windower.ffxi.get_ability_recasts()
	return buff
end

--Function used to automate Spell use
function check_buff_SP()
	local buff = 'None'
	--local sp_recasts = windower.ffxi.get_spell_recasts()
	return buff
end
