
-- Morwen

-- Load and initialize the include file.
include('GearSets-Include')
include('Mirdain-Include')

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "20"
MacroBook = "20"
MacroSet = "1"

-- Use "gs c food" to use the specified food item 
Food = "Tropical Crepe"

--Uses Items Automatically
AutoItem = false

--Upon Job change will use a random lockstyleset
Random_Lockstyle = false

--Lockstyle sets to randomly equip
Lockstyle_List = {1,2,6,12}

-- 'TP','ACC','DT' are standard Default modes.  You may add more and assigne equipsets for them ( Idle.X and OffenseMode.X )
state.OffenseMode:options('TP','ACC','DT','PDL','SB','MEVA') -- ACC effects WS and TP modes

--Set default mode (TP,ACC,DT)
state.OffenseMode:set('DT')

--Weapons options
state.WeaponMode:options('Idris','Black Halo','Unlocked')
state.WeaponMode:set('Unlocked')

--Command to Lock Style and Set the correct macros
jobsetup (LockStylePallet,MacroBook,MacroSet)

-- Goal 2200 HP/1400 MP
function get_sets()

	-- Weapon setup
	sets.Weapons = {}

	sets.Weapons['Idris'] = {
		main=gear.idris,
		sub=gear.genmeiShield,
	}

	sets.Weapons['Black Halo'] = {
		main=gear.maxentius,
		sub=gear.genmeiShield,
	}

	sets.Weapons['Unlocked'] = {
		main=gear.daybreak,
		sub=gear.genmeiShield,
	}

	sets.Weapons.Sleep = {
		main=gear.lorgMor,
	}

	--Shield used when not dual wield.
	sets.Weapons.Shield = {
		sub=gear.genmeiShield,
	}

	-- Standard Idle set with -DT,Refresh,Regen and movement gear
	sets.Idle = {
		range = gear.dunnaFC,
		head=gear.azimuthHeadPlusThree, -- 11/11
		body=gear.azimuthBodyPlusThree,
		hands=gear.azimuthHandsPlusThree, -- 12/12
		legs = gear.agwuLegs, -- 10/10
		feet=gear.azimuthFeetPlusThree, -- 10/10
		neck = gear.loricatePlusOne, -- 6/6
		waist=gear.carriers,
		left_ear=gear.sanareEarring,
		right_ear=gear.lugalbanda,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
		back = gear.geoPetRegen,
    } -- 50 PDT / 52 MDT (including shield)

	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})

	-- Sets for Idle when player has a pet
	sets.Idle.Pet = set_combine( sets.Idle, { --2278/1482
		head=gear.azimuthHeadPlusThree, -- 11/11
		neck = gear.baguaCharm,
		body=gear.adamantiteArmor,
		feet = gear.baguaArmorFeetPlusFour,
		left_ring=gear.defending,
		hands=gear.geomancyHandsPlusFour,
    }) -- 54 PDT / 45 MDT (with shield)

	--Used to swap into movement gear when the player is moving and not engaged
	sets.Movement = {
		left_ring=gear.defending,
		feet=gear.geomancyFeetPlusFour,
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

	sets.TreasureHunter = {
		ammo=gear.perfectEgg,
		waist=gear.chaac,
		hands = gear.merlinicDastanasNukeB,
	}

	sets.OffenseMode = {
		head=gear.azimuthHeadPlusThree,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet=gear.azimuthFeetPlusThree,
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
		left_ear=gear.crepuscularEar,
		right_ear=gear.telos,
		left_ring=gear.chirichRingPlusOne,
		right_ring=gear.chirichRingPlusOne,
		back = gear.geoPetRegen,
	}

	sets.OffenseMode.TP = set_combine(sets.OffenseMode,{})
	sets.OffenseMode.DT = set_combine(sets.OffenseMode,{})
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode,{})
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, {})

	--Swap in when dual wielding
	sets.DualWield = {
		left_ear=gear.eabani,
	}

	-- Precast Sets
	sets.Precast = {}

	-- Used for Magic Spells
	sets.Precast.FastCast = {
		range = gear.dunnaFC, -- 3
		head = gear.merlinicHoodFC, -- 15
		body=gear.zendikRobe, -- 13
		hands = gear.agwuHands, -- 6
		legs=gear.geomancyLegsPlusFour, -- 15
		feet = gear.merlinicCrackowsFC, -- 12
		neck=gear.voltsurge, -- 4
		waist=gear.witful, -- 3 and 3 Quick Magic
		left_ear=gear.etiolation, -- 1
		right_ear=gear.malignanceEar, -- 4
		left_ring=gear.lebecheRing, -- 2 Quick Magic
		right_ring=gear.kishar, -- 4
		-- Have to use Fast Cast due to Head Locked out with Pet above 67%
		back = gear.geoFCB,
		--back="Perimede Cape", -- 4 Quick Magic
	} -- 80% Fast Cast with 9% Quick Magic

	sets.Precast.Cure = {}
	sets.Precast.Enhancing = {}
	sets.Precast.Elemental = {}
	sets.Precast.Utsusemi = {}
	sets.Precast.BlueMagic = {}
	sets.Precast.Songs = {}


	--Base set for midcast - if not defined will notify and use your idle set for surviability
	sets.Midcast = set_combine(sets.Idle, {
	
	})

	--This set is used as base as is overwrote by specific gear changes (Spell Interruption Rate Down)
	sets.Midcast.SIRD = {}

	-- Cure Set
	sets.Midcast.Cure = {
		main=gear.daybreak, -- 30
		sub=gear.genmeiShield,
		range = gear.dunnaFC,
		head = gear.vanyaHeadPathB, -- 10
		body = gear.vanyaBodyPathB,
		hands=gear.azimuthHandsPlusThree,
		legs = gear.vanyaLegsPathB,
		feet=gear.azimuthFeetPlusThree,
		neck = gear.loricatePlusOne,
		waist=gear.luminarySash,
		left_ear = gear.odnowaPlusOne,
		right_ear=gear.etiolation,
		left_ring = gear.stikiniRingPlusOne2,
		right_ring = gear.stikiniRingPlusOne3,
		back = gear.geoCure, -- 10
    }

	-- CuragaSet
	sets.Midcast.Curaga = set_combine( sets.Midcast.Cure, {})

	-- Enhancing Skill
	sets.Midcast.Enhancing = {
		sub=gear.ammurapi,
		range = gear.dunnaFC,
		head = gear.telchineCapBEnhDur,
		body = gear.telchineChasubleBEnhDur,
		hands = gear.telchineGlovesCEnhDur,
		legs = gear.telchineBraconiBEnhDur,
		feet = gear.telchinePigachesC,
		neck=gear.loricatePlusOne,
		waist=gear.embla,
		left_ear = gear.odnowaPlusOne,
		right_ear=gear.etiolation,
		left_ring=gear.defending,
		right_ring = gear.gelatinousPlusOne,
		back = gear.geoPetRegen,
	}

	--'Barfire','Barblizzard','Baraero','Barstone','Barthunder','Barwater','Barfira','Barblizzara','Baraera','Barstonra','Barthundra','Barwatera'
	sets.Midcast.Enhancing.Elemental = {}

	--'Barsleepra','Barpoisonra','Barparalyzra','Barblindra','Barvira','Barpetra','Baramnesra','Barsilencera','Barsleep','Barpoison','Barparalyze','Barblind','Barvirus','Barpetrify','Baramnesia','Barsilence'
	sets.Midcast.Enhancing.Status = {}

	--'Temper','Temper II','Enaero','Enstone','Enthunder','Enwater','Enfire','Enblizzard','Boost-STR','Boost-DEX','Boost-VIT','Boost-AGI','Boost-INT','Boost-MND','Boost-CHR'
	sets.Midcast.Enhancing.Skill = {}

	sets.Midcast.Enhancing.Others = {}

	-- High MACC for landing spells
	sets.Midcast.Enfeebling = {
		main = gear.idris,
		sub=gear.ammurapi,
		range = gear.dunnaFC,
		head=gear.geomancyHeadPlusFour,
		body=gear.geomancyBodyPlusFour,
		hands=gear.azimuthHandsPlusThree,
		legs=gear.geomancyLegsPlusFour,
		feet=gear.geomancyFeetPlusFour,
		neck = gear.baguaCharm,
		waist=gear.luminarySash,
		left_ear=gear.regalEarring,
		right_ear=gear.malignanceEar,
		left_ring = gear.stikiniRingPlusOne2,
		right_ring = gear.stikiniRingPlusOne3,
		back = gear.geoNukePdt,
	}

	-- Free Nuke
	sets.Midcast.Nuke = {
		main = gear.idris,
		sub=gear.ammurapi,
		ammo = gear.ghastlyTathlumPlusOne,
		head=gear.eaHatPlusOne,
		body=gear.eaHouppelandePlusOne,
		hands=gear.azimuthHandsPlusThree,
		legs=gear.azimuthLegsPlusThree,
		feet=gear.azimuthFeetPlusThree,
		neck=gear.mizukageNoKubikazari,
		waist = gear.acuityBeltPlusOne,
		left_ear=gear.regalEarring,
		right_ear=gear.malignanceEar,
		left_ring=gear.freke,
		right_ring = gear.metamorphPlusOne,
		back = gear.geoNukePdt,
	}

	-- Used for Burst Mode
	sets.Midcast.Burst = set_combine( sets.Midcast.Nuke, {})

	-- Cursna Set
	sets.Midcast.Cursna = set_combine( sets.Midcast.Cure, {
	    left_ring=gear.menelausRing,
		right_ring=gear.haomaRing,
	})

	-- Specific gear for spells
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne3,
		waist=gear.siegel,
	})

	-- Aquaveil Set
	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, {
		head = gear.amalricHeadPlusOnePathA,
		hands=gear.regalCuffs,
	})

	-- Stun Set
	sets.Midcast["Stun"] = set_combine( sets.Midcast.Nuke,{})

	sets.Midcast["Diaga"] = set_combine (sets.Midcast.Enfeebling, sets.TreasureHunter)

	sets.Midcast["Dispelga"] = set_combine (sets.Midcast.Enfeebling.MACC, sets.TreasureHunter,{
		main=gear.daybreak
	})

	sets.Midcast.Refresh = {}
	sets.Midcast.Aspir = {}
	sets.Midcast.Drain = {}
	sets.Midcast.Regen = {}
	sets.Midcast.Dark = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Dark.MACC = set_combine(sets.Midcast.Enfeebling.MACC, {})
	sets.Midcast.Dark.Absorb = set_combine(sets.Midcast.Enfeebling, {})

	sets.Geomancy = {}

	-- Indi Duration
	sets.Geomancy.Indi = {
		main = gear.idris,
		sub=gear.genmeiShield,
		range = gear.dunnaFC,
		head = gear.baguaArmorHeadPlusFour,
		body=gear.azimuthBodyPlusThree,
		hands=gear.geomancyHandsPlusFour,
		legs = gear.baguaArmorLegsPlusFour, -- 21
		feet=gear.azimuthFeetPlusThree, -- 30
		neck = gear.baguaCharm,
		waist=gear.luminarySash,
		left_ear = gear.odnowaPlusOne,
		right_ear=gear.etiolation,
		left_ring=gear.defending,
		right_ring = gear.gelatinousPlusOne,
		back = gear.lifestreamCape,
	}

	sets.Geomancy.Indi.Entrust = set_combine(sets.Geomancy.Indi, {
		main = gear.gadaNuke,
	})

	-- Geo Potency
	sets.Geomancy.Geo = set_combine( sets.Geomancy.Indi, {
		legs = gear.nyameLegs, -- 8/8
		feet=gear.azimuthFeetPlusThree, -- 11/11
	})

	sets.Pet_Midcast = {}

	-- Will be used to keep max HP of Luopan when casting spells but switches when below 70% to the Idle.Pet set.
	sets.Luopan = {
		head = gear.baguaArmorHeadPlusFour,
	}

	-- Job Abilities
	sets.JA = {}
	sets.JA["Collimated Fervor"] = {}
	sets.JA["Convert"] = {}
	sets.JA["Bolster"] = {
	    body = gear.baguaArmorBodyPlusFour, 
	}
	sets.JA["Full Circle"] = {
		head=gear.azimuthHeadPlusThree, -- 3
		hands = gear.baguaArmorHandsPlusFour,
	}
	sets.JA["Lasting Emanation"] = {}
	sets.JA["Ecliptic Attrition"] = {} 
	sets.JA["Life Cycle"] = {
		body=gear.geomancyBodyPlusFour,
		back = gear.geoPetRegen,
	}
	sets.JA["Blaze of Glory"] = {}
	sets.JA["Dematerialzie"] = {}
	sets.JA["Theurgic Focus"] = {}
	sets.JA["Concentric Pulse"] = {}
	sets.JA["Mending Halation"] = {
	    legs = gear.baguaArmorLegsPlusFour,
	}
	sets.JA["Radial Arcana"] = {
	    feet = gear.baguaArmorFeetPlusFour,
	}
	sets.JA["Widened Compass"] = {}
	sets.JA["Entrust"] = {}

	-- Base WS set
	sets.WS = {
	    range = gear.dunnaFC,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.telos,
		left_ring=gear.epimanondas,
		right_ring=gear.corneliaRing,
		back = gear.geoPetRegen,
	}

	--This set is used when OffenseMode is ACC and a WS is used (Augments the WS base set)
	sets.WS.ACC = {}

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
	equipSet = set_combine(equipSet, Luopan())
	return equipSet
end
-- Augment basic equipment sets
function midcast_custom(spell)
	local equipSet = {}
	equipSet = set_combine(equipSet, Luopan())
	return equipSet
end
-- Augment basic equipment sets
function aftercast_custom(spell)
	local equipSet = {}
	-- Maintain the High HP of the Luopan
	if Geomancy_List:contains(spell.english) then
		equipSet = set_combine(equipSet, sets.Luopan)
	else
		equipSet = set_combine(equipSet, Luopan())
	end
	return equipSet
end
--Function is called when the player gains or loses a buff
function buff_change_custom(name,gain)
	local equipSet = {}
	-- Maintain the High HP of the Luopan when you use Blaze of Glory
	if name == "Blaze of Glory" and not gain then
		equipSet = set_combine(equipSet, sets.Luopan)
	end
	equipSet = set_combine(equipSet, Luopan())
	return equipSet
end
--This function is called when a update request the correct equipment set
function choose_set_custom()
	local equipSet = {}
	equipSet = set_combine(equipSet, Luopan())
	return equipSet
end
--Function is called when the player changes states
function status_change_custom(new,old)
	local equipSet = {}
	equipSet = set_combine(equipSet, Luopan())
	return equipSet
end

function pet_change_custom(pet,gain)
	local equipSet = {}
	equipSet = set_combine(equipSet, Luopan())
	return equipSet
end

function pet_aftercast_custom(spell)
	local equipSet = {}
	equipSet = set_combine(equipSet, Luopan())
	return equipSet
end

function pet_midcast_custom(spell)
	local equipSet = {}
	equipSet = set_combine(equipSet, Luopan())
	return equipSet
end

--Function is called when a self command is issued
function self_command_custom(command)

end
-- Function is called when the job lua is unloaded
function user_file_unload()

end

function check_buff_JA()
	local buff = 'None'
	--local ja_recasts = windower.ffxi.get_ability_recasts()
	return buff
end

function check_buff_SP()
	local buff = 'None'
	--local sp_recasts = windower.ffxi.get_spell_recasts()
	return buff
end

-- Maintains the extra 600hp during midcast of spells when the Luopan is deployed.
-- Called from every gear hook, so it returns as early as it can and builds no
-- table: returning nothing is the same as returning an empty set to set_combine.
-- The log arguments are passed separately so the text is only joined when debug
-- is on.
function Luopan()
	if not pet.isvalid then return end
	local head_item = player.equipment.head
	if not (head_item and head_item:contains("Bagua")) then return end
	log('Regen [', pet.hpp, ']% HP')
	-- Swap the right head
	if pet.hpp > 68 then return sets.Luopan end
end

-- Whether the Luopan was last seen above the threshold, so the timer below only
-- asks for a rebuild when that actually changes.
Luopan_Was_High = false

function Cycle_Timer()
	if player.status ~= "Idle" then return end
	-- Nothing else rebuilds gear while idle, so watch for the Luopan crossing
	-- the threshold and ask for the swap when it does. Calling Luopan() here
	-- would only compute a set with nowhere to go.
	local high = (pet.isvalid and pet.hpp > 68) and true or false
	if high ~= Luopan_Was_High then
		Luopan_Was_High = high
		equip_set_command()
	end
end
