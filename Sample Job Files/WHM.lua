
--Yavanna

-- Load and initialize the include file.
include('GearSets-Include')
include('Mirdain-Include')

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "2"
MacroBook = "11"
MacroSet = "1"

-- Use "gs c food" to use the specified food item 
Food = "Miso Ramen"

--Uses Items Automatically
AutoItem = false

--Upon Job change will use a random lockstyleset
Random_Lockstyle = false

--Lockstyle sets to randomly equip
Lockstyle_List = {1,2,6,12}

-- 'TP','ACC','DT' are standard Default modes.  You may add more and assigne equipsets for them ( Idle.X and OffenseMode.X )
state.OffenseMode:options('TP','ACC','DT','PDT','MEVA')
state.OffenseMode:set('DT')

-- Set to true to run organizer on job changes
Organizer = false

--Weapons options
state.WeaponMode:options('Seraph Strike','Black Halo','Asclepius','Unlocked')
state.WeaponMode:set('Unlocked')

--Command to Lock Style and Set the correct macros
jobsetup (LockStylePallet,MacroBook,MacroSet)

-- Balance 2100 HP / 1500 MP
function get_sets()

	-- Weapon setup
	sets.Weapons = {}

	sets.Weapons['Seraph Strike'] = {
		main=gear.daybreak,
	}

	sets.Weapons['Black Halo'] = {
		main=gear.maxentius,
		sub=gear.cathPalugHammer,
	}

	sets.Weapons['Asclepius'] = {
		main=gear.asclepius,
	}

	sets.Weapons['Shield'] = {
		sub=gear.genmeiShield,
	}

	sets.Weapons['Sleep'] ={
		main=gear.lorgMor,
	}

	sets.Weapons['Light Bonus'] = {
		main=gear.chatoyantStaff,
		sub=gear.enki,
		left_ring=gear.murky,
		right_ring = gear.gelatinousPlusOne,
		right_ear = gear.tuisto,
		waist=gear.hachirinNoObi,
	}

	sets.Weapons['Unlocked'] = {}

	-- Standard Idle set with -DT,Refresh,Regen and movement gear
	sets.Idle = {
		main=gear.daybreak,
		sub=gear.genmeiShield,
		ammo=gear.staunchPlusOne,
		head = gear.bunziHead,
		body=gear.ebersBodyPlusThree,
		hands = gear.bunziHands,
		legs=gear.ebersLegsPlusThree,
		feet = gear.chironicSlippersRefresh, -- +2 Refresh
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
		left_ear = gear.alabaster,
		right_ear = gear.etiolation, -- 1
		left_ring = gear.stikiniRingPlusOne1, -- +1 Refresh
		right_ring = gear.stikiniRingPlusOne2, -- +1 Refresh
		back = gear.whmFC,
    }

	-- 'TP','PDL','ACC','DT','PDT','MEVA'
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {
		main = gear.asclepius,
		body = gear.adamantiteArmor,
		waist = gear.platinumMoogleBelt,
		right_ear=gear.heartyEarring,
	})
	sets.Idle.PDT = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle.DT, {
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
	})
	-- Set is only applied when sublimation is charging
	sets.Idle.Sublimation = set_combine(sets.Idle, {
	    waist=gear.embla, -- +3 Submlimation when active
	})
	-- Set to swap out when MP is low
	sets.Idle.Refresh = set_combine(sets.Idle, {
		body=gear.ebersBodyPlusThree,
	    feet = gear.chironicSlippersRefresh,
		left_ring = gear.stikiniRingPlusOne1, -- +1 Refresh
		right_ring = gear.stikiniRingPlusOne2, -- +1 Refresh
	})
	sets.Idle.Resting = set_combine(sets.Idle, {})

	-- Movement Gear
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

	sets.OffenseMode = {
		ammo=gear.hastyPinionPlusOne,
		head=gear.bunziHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.unmovingPlusOne,
		waist=gear.grunfeldRope,
		left_ear=gear.crepuscularEar,
		right_ear=gear.telos,
		left_ring=gear.lehkoHabhokaRing,
		right_ring = gear.chirichPlusOne2,
		back = gear.whmDA,
	}

	sets.OffenseMode.TP = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.DT = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.PDT = set_combine(sets.OffenseMode, { })
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, { })

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	sets.Precast = {}

	-- Used for Magic Spells (Cap 80%)
	sets.Precast.FastCast = {
		main=gear.asclepius,
		ammo=gear.impatiens, -- Quick Cast 2%
		head=gear.ebersHeadPlusThree, -- FC 13%
		body=gear.pingaTunicPlusOne, -- FC 15%
		hands = gear.gendewithaGagesPlusOneBCureFC, -- FC 7%
		legs=gear.pingaPantsPlusOne, -- FC 13%
		feet=gear.volteGaiters, -- FC 6%
		neck = gear.clericTorquePlusTwo,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.alabaster,
		right_ear = gear.etiolation,  -- FC 1%
		left_ring=gear.lehkoHabhokaRing,
		right_ring=gear.weatherspoon, -- FC 5%
		back = gear.whmFC, -- FC 10%
	} -- 80% FC 25% Haste 3k+ HP

	-- Used for Cure cast
	-- 3k HP, 80% Cast Speed, 25% gear haste
	sets.Precast.Cure = set_combine(sets.Precast.FastCast, { })

	-- Used for Enhancing cast
	sets.Precast.Enhancing = set_combine(sets.Precast.FastCast, { })

	sets.Precast.Healing = set_combine(sets.Precast.FastCast, { })

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	--Base set for midcast - if not defined will notify and use your idle set for surviability
	sets.Midcast = set_combine(sets.Idle, sets.Idle.DT, { })

	--This set is used as base as is overwrote by specific gear changes (Spell Interruption Rate Down)
	sets.Midcast.SIRD = {}

	-- Cure Set
	sets.Midcast.Cure = {
		main = gear.asclepius,
		sub=gear.ammurapi,
		ammo=gear.staunchPlusOne,
		head=gear.ebersHeadPlusThree,
		body=gear.ebersBodyPlusThree,
		hands=gear.theophanyHandsPlusFour,
		legs=gear.ebersLegsPlusThree,
		feet=gear.pietyFeetPlusFour,
		neck = gear.clericTorquePlusTwo,
		waist = gear.platinumMoogleBelt,
		left_ear=gear.alabaster,
		right_ear = gear.ebersEarringPlusOneMacc,
		left_ring=gear.lebecheRing,
		right_ring=gear.najiLoop,
		back = gear.whmFC,
    }

	-- For AoE cure
	sets.Midcast.Curaga = set_combine(sets.Midcast.Cure, { body=gear.theophanyBodyPlusFour,})

	-- For Cura
	sets.Midcast.Cura = set_combine(sets.Midcast.Cure, {
		main = gear.asclepius, body=gear.theophanyBodyPlusFour,
	})

	-- Enhancing Skill

	-- Used for base duration
	sets.Midcast.Enhancing = {
		main = gear.asclepius,
		sub=gear.ammurapi,
		ammo=gear.staunchPlusOne,
		head = gear.telchineCapRegen,
		body = gear.telchineChasubleRegen,
		hands = gear.telchineGlovesRegen,
		legs = gear.telchineBraconiRegen,
		feet=gear.theophanyFeetPlusFour,
		neck=gear.unmovingPlusOne,
		waist=gear.embla,
		left_ear=gear.alabaster,
		right_ear=gear.odnowaPlusOne,
		left_ring=gear.murky,
		right_ring=gear.defending,
		back = gear.whmFC,
	}
	sets.Midcast.Enhancing.Others = set_combine(sets.Midcast.Enhancing, {});

	-- Caps at 500 for bar spells
	--'Barsleepra','Barpoisonra','Barparalyzra','Barblindra','Barvira','Barpetra','Baramnesra','Barsilencera','Barsleep','Barpoison','Barparalyze','Barblind','Barvirus','Barpetrify','Baramnesia','Barsilence'
	sets.Midcast.Enhancing.Status = set_combine(sets.Midcast.Enhancing, {
		ammo=gear.staunchPlusOne,
		head=gear.ebersHeadPlusThree,
		body=gear.ebersBodyPlusThree,
		hands=gear.ebersHandsPlusThree,
		legs = gear.pietyLegsPlusFour,
		feet=gear.ebersFeetPlusThree,
		left_ear=gear.alabaster,
		right_ear=gear.ebersEarringPlusOne,
		left_ring=gear.murky,
	})

	--'Barfire','Barblizzard','Baraero','Barstone','Barthunder','Barwater','Barfira','Barblizzara','Baraera','Barstonra','Barthundra','Barwatera'
	sets.Midcast.Enhancing.Elemental = set_combine(sets.Midcast.Enhancing.Status, {
		main=gear.beneficus,
	})

	-- This caps at 500 for Gain spells
	--'Temper','Temper II','Enaero','Enstone','Enthunder','Enwater','Enfire','Enblizzard','Boost-STR','Boost-DEX','Boost-VIT','Boost-AGI','Boost-INT','Boost-MND','Boost-CHR'
	sets.Midcast.Enhancing.Skill = set_combine(sets.Midcast.Enhancing, { })

	-- High MACC for landing spells
	sets.Midcast.Enfeebling = {
		main = gear.asclepius,
		sub=gear.ammurapi,
		ammo=gear.pemphredoTathlum,
		head=gear.theophanyHeadPlusFour,
		body=gear.theophanyBodyPlusFour,
		hands=gear.theophanyHandsPlusFour,
		legs = gear.chironicHoseNukeB,
		feet=gear.theophanyFeetPlusFour,
		neck=gear.nullLoop,
		waist=gear.obstinateSash,
		left_ear=gear.alabaster,
		right_ear = gear.ebersEarringPlusOneMacc,
		left_ring=gear.stikiniPlusOne,
		right_ring=gear.stikiniPlusOne,
		back=gear.nullShawl,
	}

	-- Skill Based ('Dispel','Aspir','Aspir II','Aspir III','Drain','Drain II','Drain III','Frazzle','Frazzle II','Stun','Poison','Poison II','Poisonga')
	sets.Midcast.Enfeebling.MACC = set_combine(sets.Midcast.Enfeebling, {})

	 -- Potency Basted ('Paralyze','Paralyze II','Slow','Slow II','Addle','Addle II','Distract','Distract II','Distract III','Frazzle III','Blind','Blind II')
	sets.Midcast.Enfeebling.Potency = set_combine(sets.Midcast.Enfeebling, { })

	-- Duration Based ('Sleep','Sleep II','Sleepga','Sleepga II','Diaga','Dia','Dia II','Dia III','Bio','Bio II','Bio III','Silence','Gravity','Gravity II','Inundation','Break','Breakaga', 'Bind', 'Bind II')
	sets.Midcast.Enfeebling.Duration = set_combine(sets.Midcast.Enfeebling, { 
		left_ring=gear.kishar,
		hands=gear.regalCuffs,
	})

	sets.Midcast.Phalanx = set_combine(sets.Midcast.Enhancing.Skill, { })
	sets.Midcast.Dark = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Dark.MACC = set_combine(sets.Midcast.Enfeebling.MACC, {})
	sets.Midcast.Dark.Absorb = set_combine(sets.Midcast.Enfeebling, {})

	sets.Midcast["Cursna"] = {
		main=gear.yagrush,
		sub=gear.ammurapi,
		ammo=gear.staunchPlusOne,
		head = gear.vanyaHeadPathD,
		body=gear.ebersBodyPlusThree,
		hands = gear.fanaticGlovesFC,
		legs=gear.theophanyLegsPlusThree,
		feet = gear.gendewithaGaloshesPlusOneBCureFC,
		neck=gear.debilis,
		waist=gear.platinumMoogleBelt,
		left_ear=gear.alabaster,
		right_ear = gear.ebersEarringPlusOneMacc,
		left_ring=gear.haomaRing,
		right_ring=gear.menelausRing,
		back = gear.whmFC,
	}

	sets.Midcast["Erase"] = set_combine(sets.Midcast, {
		main=gear.yagrush,
		neck = gear.clericTorquePlusTwo,
	})

	sets.Midcast["Esuna"] = set_combine(sets.Midcast, {
		main=gear.asclepius,
	})

	sets.Midcast["Silena"] = set_combine(sets.Midcast, {
		hands=gear.ebersHandsPlusThree,
		main=gear.yagrush
	})

	sets.Midcast["Poisona"] = set_combine(sets.Midcast, {
		hands=gear.ebersHandsPlusThree,
		main=gear.yagrush
	})

	sets.Midcast["Paralyna"] = set_combine(sets.Midcast, {
		hands=gear.ebersHandsPlusThree,
		main=gear.yagrush
	})

	sets.Midcast["Stona"] = set_combine(sets.Midcast, {
		hands=gear.ebersHandsPlusThree,
		main=gear.yagrush
	})

	sets.Midcast["Blindna"] = set_combine(sets.Midcast, {
		hands=gear.ebersHandsPlusThree,
		main=gear.yagrush
	})

	sets.Midcast["Viruna"] = set_combine(sets.Midcast, {
		hands=gear.ebersHandsPlusThree,
		main=gear.yagrush
	})

	sets.Midcast["Auspice"] = set_combine(sets.Midcast.Enhancing, {
		feet=gear.ebersFeetPlusThree,
	})

	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, {
		main=gear.vadoseRod,
		sub=gear.ammurapi,
		ammo=gear.impatiens,
		head = gear.chironicHatFC,
		body=gear.adamantiteArmor,
		hands=gear.regalCuffs,
		legs=gear.shedirSeraweels,
		feet=gear.theophanyFeetPlusFour,
		neck=gear.loricatePlusOne,
		waist=gear.platinumMoogleBelt,
		left_ear=gear.alabaster,
		right_ear = gear.ebersEarringPlusOneMacc,
		left_ring=gear.murky,
		right_ring=gear.defending,
		back = gear.whmFC,
	})

	-- Regen Set
	sets.Midcast.Regen = {
		main=gear.bolelabunga,
		sub=gear.ammurapi,
		ammo=gear.staunchPlusOne,
		head=gear.inyangaHeadPlusTwo,
		body=gear.pietyBodyPlusFour,
		hands=gear.ebersHandsPlusThree,
		legs=gear.theophanyLegsPlusThree,
		feet=gear.bunziFeet,
		neck=gear.unmovingPlusOne,
		waist=gear.embla,
		left_ear=gear.alabaster,
		right_ear=gear.etiolation,
		left_ring=gear.murky,
		right_ring=gear.defending,
		back = gear.whmFC,
	}

	-- Specific gear for spells
	sets.Midcast["Stoneskin"] = {
		main = gear.asclepius,
		sub=gear.genmeiShield,
		ammo=gear.staunchPlusOne,
		head=gear.nullMasque,
		body=gear.adamantiteArmor,
		hands=gear.ebersHandsPlusThree,
		legs=gear.shedirSeraweels,
		feet=gear.ebersFeetPlusThree,
		neck=gear.nodens,
		waist=gear.siegel,
		left_ear=gear.alabaster,
		right_ear=gear.earthcryEarring,
		left_ring=gear.stikiniPlusOne,
		right_ring=gear.stikiniPlusOne,
		back = gear.whmFC,
	}

	sets.Midcast.Refresh = {}

	-- Job Abilities
	sets.JA = {}
	sets.JA["Benediction"] = {
		body = gear.pietyBodyPlusFour,
	}
	sets.JA["Divine Seal"] = {}
	sets.JA["Convert"] = {}
	sets.JA["Devotion"] = {
		head = gear.pietyHeadPlusFour,
	}
	sets.JA["Afflatus Solace"] = {}
	sets.JA["Afflatus Misery"] = {}
	sets.JA["Sacrosanctity"] = {}
	sets.JA["Asylum"] = {}

	-- ===================================================================================================================
	--		sets.aftercast
	-- ===================================================================================================================

	sets.WS = {
	    ammo=gear.oshashaTreatise,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck=gear.fotiaNeck,
		waist=gear.fotiaWaist,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.ishvara,
		left_ring=gear.ilabrat,
		right_ring=gear.epimanondas,
		back = gear.whmDA,
	}

	--This set is used when OffenseMode is ACC and a WS is used (Augments the WS base set)
	sets.WS.ACC = {}

	-- Note that the Mote library will unlock these gear spots when used.
	sets.TreasureHunter = {}

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

	return equipSet
end
-- Augment basic equipment sets
function aftercast_custom(spell)
	local equipSet = {}
	if not buffactive['Afflatus Solace'] and not buffactive['Afflatus Misery'] then
		add_to_chat(8,'You are not in a stance')
	end
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
-- Function is called when the job lua is unloaded
function user_file_unload()

end

--Function used to automate Job Ability use - Checked first
function check_buff_JA()
	local buff = 'None'
	return buff
end

--Function used to automate Spell use
function check_buff_SP()
	local buff = 'None'
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
