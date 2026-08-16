
--Yavanna

-- Load and initialize the include file.
include('GearSets-Include')
include('Mirdain-Include')

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "6"
MacroBook = "3"
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
state.OffenseMode:options('TP','ACC','DT','PDL','SB','CRIT','Enspell')
state.OffenseMode:set('DT')

--Command to Lock Style and Set the correct macros
jobsetup (LockStylePallet,MacroBook,MacroSet)

--Modes for TP
state.WeaponMode:options('Seraph Blade', 'Sanguine Blade', 'Chant du Cygne','Savage Blade', 'Evisceration', 'Aeolian Edge', 'Black Halo', 'Ullr', 'Unlocked')
state.WeaponMode:set('Sanguine Blade')

-- Goal 2100 hp and 1300 MP
function get_sets()

	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	--Set the weapon options.  This is set below in job customization section
	sets.Weapons = {}

	sets.Weapons['Seraph Blade'] ={
		main = gear.croceaMors,
		sub=gear.daybreak
	}

	sets.Weapons['Sanguine Blade'] ={
		main = gear.croceaMors,
		sub = gear.demersalDegenPlusOne,
	}

	sets.Weapons['Chant du Cygne'] ={
		main = gear.croceaMors,
		sub = gear.demersalDegenPlusOne,
	}

	sets.Weapons['Savage Blade'] ={
		main=gear.naegling,
		sub = gear.demersalDegenPlusOne,
	}

	sets.Weapons['Evisceration'] ={
		main=gear.tauret,
		sub=gear.gleti,
	}

	sets.Weapons['Aeolian Edge'] ={
		main=gear.tauret,
		sub = gear.demersalDegenPlusOne,
	}

	sets.Weapons['Black Halo'] ={
		main=gear.maxentius,
		sub = gear.machaeraPlusTwo,
	}

	sets.Weapons['Ullr'] = {
		range=gear.ullr,
		ammo=gear.berylliumArrow,
	}

	sets.Weapons['Unlocked'] ={
		main = gear.croceaMors,
		sub = gear.demersalDegenPlusOne,
	}

	--Shield used when melee and not dual wield.
	sets.Weapons.Shield = {
		sub=gear.sacroBulwark,
	}

	sets.Weapons.Sleep = {
		sub=gear.caliburnus,
	}

	--Default arrow to use
	Ammo.RA = "Beryllium Arrow"
	Ammo.ACC = "Beryllium Arrow"

	-- ===================================================================================================================
	--		sets.Idle
	-- ===================================================================================================================

	-- Standard Idle set with -DT,Refresh,Regen and movement gear
	sets.Idle = {
		ammo=gear.staunchPlusOne, -- 3/3
		head = gear.vitiationChapeauPlusFour, -- +3 Refresh
		body=gear.lethargyBodyPlusThree, -- 14/14  +4 Refresh
		hands=gear.lethargyHandsPlusThree, -- 11/11
		legs=gear.bunziLegs, -- 9/9
		feet = gear.bunziFeet, -- 6/6
		neck=gear.loricatePlusOne, -- 6/6
		waist=gear.carriers,
		left_ear = gear.etiolation, -- Used to Keep HP/MP pool
		right_ear = gear.odnowaPlusOne, --3/5
		left_ring = gear.stikiniRingPlusOne1, -- +1 Refresh
		right_ring = gear.stikiniRingPlusOne2, -- +1 Refresh
		back = gear.rdmFCPdt, -- 10/0
    }
	sets.Idle.TP = sets.Idle
	sets.Idle.ACC = sets.Idle
	sets.Idle.DT = sets.Idle
	sets.Idle.PDL = sets.Idle
	sets.Idle.SB = sets.Idle
	sets.Idle.MEVA = sets.Idle
	sets.Idle.CRIT = sets.Idle
	sets.Idle.Enspell = sets.Idle
	sets.Idle.Resting = sets.Idle

	-- Set is only applied when sublimation is charging
	sets.Idle.Sublimation = set_combine(sets.Idle, {
	    waist=gear.embla, -- +3 Submlimation when active
	})

	-- Gear to swap out for Movement
	sets.Movement = {
		legs = gear.carmineLegsPlusOnePathA,
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

	-- ===================================================================================================================
	--		sets.OffenseMode
	-- ===================================================================================================================

	-- 'TP','ACC','DT','PDL','SB','Enspell'
	sets.OffenseMode = {
		ammo = gear.coiste,
		head=gear.malignanceHead,
		body=gear.malignanceBody,
		hands=gear.malignanceHands,
		legs=gear.malignanceLegs,
		feet=gear.malignanceFeet,
		neck=gear.anu,
		waist = gear.sailfi,
		left_ear=gear.sherida,
		right_ear = gear.lethargyEarringPlusOne,
		left_ring = gear.chirichPlusOne1,
		right_ring = gear.chirichPlusOne2,
		back=gear.nullShawl,
	}

	sets.OffenseMode.TP = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.DT = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.PDT = set_combine(sets.OffenseMode, { })
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, { })

	sets.OffenseMode.SB = set_combine(sets.OffenseMode, { 
		hands=gear.volteMittens,
		legs=gear.volteTights,
		neck=gear.bathyPlusOne,
		waist=gear.sarissaphoroi,
	})

	sets.OffenseMode.CRIT = set_combine(sets.OffenseMode, { 
	    ammo=gear.yetshilaPlusOne,
		head = gear.blisteringSalletPlusOne,
		body=gear.adamantiteArmor,
		hands=gear.lethargyHandsPlusThree,
		legs=gear.bunziLegs,
		feet=gear.thereoidGreaves,
		neck=gear.nullLoop,
		waist=gear.reiki,
		left_ear=gear.sherida,
		right_ear = gear.lethargyEarringPlusOneDA,
		left_ring=gear.lehkoHabhokaRing,
		right_ring = gear.gelatinousPlusOne,
		back = gear.rdmCrit,
	})

	sets.OffenseMode.Enspell = set_combine(sets.OffenseMode, { 
	    sub=gear.ammurapi,
		range=gear.ullr,
		head=gear.umuthiHat,
		body=gear.lethargyBodyPlusThree,
		hands=gear.ayanmoHandsPlusTwo,
		legs = gear.vitiationTightsPlusThree,
		feet=gear.lethargyFeetPlusThree,
		neck=gear.quanpur,
		waist=gear.orpheusWaist,
		left_ear=gear.malignanceEar,
		right_ear=gear.lethargyEarringPlusOne,
		left_ring=gear.freke,
		right_ring = gear.metamorphPlusOne,
		back=gear.nullShawl,
	})

	sets.DualWield = {
		waist=gear.reiki,
		left_ear=gear.eabani,
	}

	sets.Enspell = {}

	sets.Saboteur = {hands=gear.lethargyHandsPlusThree,}

	sets.TreasureHunter = {
		ammo=gear.perfectEgg,
		head=gear.volteHead,
	    legs=gear.volteHose,
		waist=gear.chaac,
	}

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Used for Magic Spells
	sets.Precast = {}

	-- 42% Fast Cast is needed on RDM (Fast Cast IX - 38%)
	-- 10% is Quick Magic limit
	sets.Precast.FastCast = {
		ammo=gear.impatiens, -- 2 Quick Magic
		head=gear.bunziHead, -- 10
		body = gear.vitiationBodyPlusThree, -- 15
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.kaykausLegsPlusOnePathB, -- 7
		feet = gear.bunziFeet,
		neck = gear.unmovingPlusOne,
		waist=gear.witful, -- 3 Quick Magic
		left_ear = gear.etiolation, -- Used to Keep HP/MP pool
		right_ear = gear.lethargyEarringPlusOne, -- 8
		left_ring=gear.lebecheRing, -- 2 Quick Magic
		right_ring = gear.etanaRing,
		back=gear.perimedeCape, -- 4 Quick Magic
	} -- 50%+ total Fast Cast and 11% Quick Magic

	-- Used for Enhancing Magic
	sets.Precast.Enhancing = set_combine(sets.Precast.FastCast, {})

	-- Used for Healing Magic
	sets.Precast.Cure = set_combine(sets.Precast.FastCast, {})

	sets.Precast.RA = set_combine(sets.Precast, {
		ammo=Ammo.RA,
		waist=gear.yemaya, -- 0 / 5
		right_ring=gear.crepuscularRing, -- 3
    })	

	-- Flurry
	sets.Precast.RA.Flurry = set_combine(sets.Precast.RA, {}) 

	-- Flurry II
	sets.Precast.RA.Flurry_II = set_combine( sets.Precast.RA.Flurry, {})

	sets.Precast.BlueMagic = set_combine (sets.Precast.FastCast, {})

	-- ===================================================================================================================
	--		sets.midcast
	-- ===================================================================================================================

	--Base set for midcast - if not defined will notify and use your idle set for surviability
	sets.Midcast = set_combine(sets.Idle, {})

	sets.Midcast.Utsusemi = set_combine(sets.Midcast, {})

	-- Ranged Attack Gear (Normal Midshot)
    sets.Midcast.RA = set_combine(sets.Midcast, {})

	-- Ranged Attack Gear (High Accuracy Midshot)
    sets.Midcast.RA.ACC = set_combine(sets.Midcast.RA, {
		ammo=Ammo.ACC,
    })

	-- Ranged Attack Gear (Physical Damage Limit)
    sets.Midcast.RA.PDL = set_combine(sets.Midcast.RA, {})

	-- Ranged Attack Gear (Critical Build)
    sets.Midcast.RA.CRIT = set_combine(sets.Midcast.RA, {})

	--This set is used as base as is overwrote by specific gear changes (Spell Interruption Rate Down)
	sets.Midcast.SIRD = {}

	-- Cure Set
	sets.Midcast.Cure = {
		ammo=gear.staunchPlusOne,
		head = gear.kaykausHeadPlusOnePathB, -- 11
		body = gear.kaykausBodyPlusOnePathD, -- 6
		hands = gear.kaykausHandsPlusOnePathB, -- 11
		legs = gear.kaykausLegsPlusOnePathB, -- 11
		feet = gear.kaykausFeetPlusOnePathB, -- 11
		neck = gear.loricatePlusOne,
		waist=gear.sacroCord,
		left_ear = gear.etiolation, -- Used to Keep HP/MP pool
		right_ear = gear.odnowaPlusOne,
		right_ring = gear.gelatinousPlusOne,
		left_ring=gear.defending,
		back = gear.rdmFCPdt,
    } -- 50% Cure I, 16% Cure II

	sets.Midcast.Curaga = set_combine(sets.Midcast.Cure, {})

	-- Regen
	sets.Midcast.Regen = {
		feet = gear.bunziFeet,
	}

	-- Enhancing Duration on SELF
	sets.Midcast.Enhancing = {
		sub=gear.ammurapi,
		ammo=gear.staunchPlusOne,
		head = gear.telchineCapRegen,
		body = gear.vitiationBodyPlusThree, --15
		hands=gear.atrophyHandsPlusThree, -- 20
		legs = gear.telchineBraconiRegen,
		feet=gear.lethargyFeetPlusThree, -- 35
		neck = gear.duelistTorque, --25
		waist=gear.embla, --10
		left_ear = gear.etiolation, -- Used to Keep HP/MP pool
		right_ear=gear.lethargyEarringPlusOne, -- 8
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
		back = gear.rdmFCPdt, -- 20
	} -- 150% Duration

	-- Enhancing Duration on OTHERS
	sets.Midcast.Enhancing.Others = set_combine(sets.Midcast.Enhancing, {
		head=gear.lethargyHeadPlusThree,
		body=gear.lethargyBodyPlusThree,
		legs=gear.lethargyLegsPlusThree,
	})

	-- Spells that require SKILL - RDM only needs 500 or more except Temper II
	sets.Midcast.Enhancing.Skill = set_combine(sets.Midcast.Enhancing, {
		sub=gear.ammurapi,
		head=gear.befouledCrown,
		body = gear.vitiationBodyPlusThree,
		hands = gear.vitiationGlovesPlusThree,
		legs=gear.atrophyLegsPlusThree,
		feet=gear.lethargyFeetPlusThree,
		neck=gear.incanterTorque,
		waist=gear.olympus,
		left_ear=gear.andoaaEarring,
		right_ear=gear.mimir,
	})

	-- used to boost Gain Spells
	sets.Midcast.Enhancing.Gain = set_combine(sets.Midcast.Enhancing, {
		hands = gear.vitiationGlovesPlusThree,
	})

	-- Elemental
	sets.Midcast.Enhancing.Elemental = set_combine(sets.Midcast.Enhancing, {})

	-- Status
	sets.Midcast.Enhancing.Status = set_combine(sets.Midcast.Enhancing, {})

	-- Blue Magic
	sets.Midcast.BlueMagic = {}
	sets.Midcast.BlueMagic.Skill = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Nuke = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Healing = set_combine(sets.Midcast.Cure, {})
	sets.Midcast.BlueMagic.ACC = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Enmity = set_combine(sets.Enmity, {})

	-- Enfeebling
	sets.Midcast.Enfeebling = {
		ammo=gear.regalGem,
		head = gear.vitiationChapeauPlusFour,
		body=gear.atrophyBodyPlusFour,
		hands=gear.lethargyHandsPlusThree,
		legs = gear.chironicHoseNuke,
		feet = gear.vitiationBootsPlusThree,
		neck = gear.duelistTorque,
		waist = gear.obstinateSash,
		left_ear=gear.regalEarring,
		right_ear=gear.snotra,
		left_ring = gear.stikiniRingPlusOne2,
		right_ring = gear.stikiniRingPlusOne1,
		back = gear.rdmFCPdt,
	}

	-- Skill Based ('Dispel','Aspir','Aspir II','Aspir III','Drain','Drain II','Drain III','Frazzle','Frazzle II','Stun','Poison','Poison II','Poisonga')
	sets.Midcast.Enfeebling.MACC = set_combine(sets.Midcast.Enfeebling, {})

	 -- Potency Basted ('Paralyze','Paralyze II','Slow','Slow II','Addle','Addle II','Distract','Distract II','Distract III','Frazzle III','Blind','Blind II')
	sets.Midcast.Enfeebling.Potency = set_combine(sets.Midcast.Enfeebling, {
		ammo=gear.regalGem, -- 10%
		body=gear.lethargyBodyPlusThree, -- 14%
		back = gear.rdmFCPdt, -- 10%
		feet = gear.vitiationBootsPlusThree, -- 10%
		neck = gear.duelistTorque, -- 10%
	})

	-- Duration Based ('Sleep','Sleep II','Sleepga','Sleepga II','Diaga','Dia','Dia II','Dia III','Bio','Bio II','Bio III','Silence','Gravity','Gravity II','Inundation','Break','Breakaga', 'Bind', 'Bind II')
	sets.Midcast.Enfeebling.Duration = set_combine(sets.Midcast.Enfeebling, {
		head = gear.vitiationChapeauPlusFour, -- 15s (3 seconds x 5 merits)
		hands=gear.regalCuffs, --20% swaps out with Saboteur active
		right_ear=gear.snotra, -- 10%
		left_ring=gear.kishar, -- 10%
		waist = gear.obstinateSash, -- 5%
		neck = gear.duelistTorque, -- 25%
	})

	-- Specific gear for spells
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		neck=gear.nodens,
		waist=gear.siegel,
		left_ear=gear.earthcryEarring,
	})

	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, {
		hands=gear.regalCuffs,
		head=gear.amalricCoifPlusOne
	})

	-- Spells that require SKILL - RDM only needs +500 skill except Temper II
	sets.Midcast["Temper II"] = set_combine(sets.Midcast.Enhancing, {
		ammo=gear.psilomene,
		head=gear.befouledCrown,
		hands = gear.vitiationGlovesPlusThree,
		legs=gear.atrophyLegsPlusThree,
		neck=gear.incanterTorque,
		left_ear=gear.mimir,
		right_ear=gear.andoaaEarring,
		waist=gear.olympus,
		back=gear.perimedeCape,
	}) -- Max Enhancing 672

	sets.Midcast["Diaga"] = set_combine (sets.Midcast.Enfeebling, sets.TreasureHunter)
	sets.Midcast["Dispelga"] = set_combine (sets.Midcast.Enfeebling, sets.TreasureHunter)

	sets.Midcast.Refresh = set_combine(sets.Midcast.Enhancing, {
		head=gear.amalricCoifPlusOne,
		body=gear.atrophyBodyPlusFour,
		legs=gear.lethargyLegsPlusThree,
	})

	sets.Midcast.Phalanx = set_combine(sets.Midcast.Enhancing.Skill, { })

	sets.Midcast.Dark = set_combine(sets.Midcast.Enfeebling, {})

	sets.Midcast.Dark.MACC = set_combine(sets.Midcast.Enfeebling.MACC, {})

	sets.Midcast.Dark.Absorb = set_combine(sets.Midcast.Enfeebling, {})

	sets.Midcast.Nuke = {
		sub=gear.ammurapi,
		ammo = gear.ghastlyTathlumPlusOne,
		head=gear.lethargyHeadPlusThree,
		body=gear.lethargyBodyPlusThree,
		hands=gear.lethargyHandsPlusThree,
		legs=gear.lethargyLegsPlusThree,
		feet=gear.lethargyFeetPlusThree,
		neck=gear.mizukageNoKubikazari,
		waist = gear.acuityBeltPlusOne,
		left_ear=gear.regalEarring,
		right_ear=gear.malignanceEar,
		left_ring = gear.metamorphPlusOne,
		right_ring=gear.freke,
		back = gear.rdmFCPdt,
	}

	sets.Midcast.Burst = set_combine(sets.Midcast.Nuke, {
		left_ring=gear.mujinBand,
		neck=gear.mizukageNoKubikazari,
	})

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job Abilities
	sets.JA = {}
	sets.JA["Chainspell"] = {body = gear.vitiationBodyPlusThree}
	sets.JA["Saboteur"] = {}
	sets.JA["Spontaneity"] = {}
	sets.JA["Stymie"] = {}
	sets.JA["Convert"] = {}
	sets.JA["Composure"] = {}

	-- Dancer JA Section
	sets.Flourish = set_combine(sets.Idle.DT, {})

	sets.Jig = set_combine(sets.Idle.DT, { })

	sets.Step = set_combine(sets.OffenseMode.DT, {})

	sets.Samba = set_combine(sets.Idle.DT, {})

	-------------------------------------------------------------------------------
	-- Waltz Potency gear caps at 50%, while Waltz received potency caps at 30%. -- 
	-------------------------------------------------------------------------------
	sets.Waltz = set_combine(sets.OffenseMode.DT, {
		legs=gear.dashingSubligar, -- 10
		--ammo="Yamarang", -- 5
		--body={ name="Gleti's Cuirass", augments={'Path: A',}}, -- 10
		--hands="Slither Gloves +1", -- 5
	}) -- 10% Potency

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	sets.WS = {
		ammo = gear.coiste,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet=gear.lethargyFeetPlusThree,
		neck = gear.duelistTorque,
		waist = gear.sailfi,
		left_ear=gear.sherida,
		right_ear = gear.lethargyEarringPlusOne,
		left_ring=gear.sroda,
		right_ring=gear.epimanondas,
		back = gear.rdmWSDDt,
	}

	sets.WS.ACC = set_combine(sets.WS, {})

	sets.WS.PDL = set_combine(sets.WS, 
	{
		ammo=gear.crepuscularPebble,
		right_ring=gear.sroda,
	})

	sets.WS.WSD = set_combine(sets.WS, 
	{
		ammo=gear.oshashaTreatise,
		left_ear=gear.ishvara,
	})

	sets.WS.MAB = set_combine(sets.WS, 
	{
		ammo=gear.oshashaTreatise,
		neck=gear.sanctity,
		waist=gear.orpheusWaist,
		left_ear=gear.malignanceEar,
	    right_ear=gear.regalEarring,
	})

	sets.WS.CRIT = set_combine(sets.WS,{
		ammo=gear.yetshilaPlusOne,
		head = gear.blisteringSalletPlusOne,
		neck=gear.fotiaNeck,
		waist=gear.fotiaWaist,
		right_ring=gear.hetairoi,
		back = gear.rdmCrit,
	})

	sets.WS.RA = set_combine(sets.WS,{})

	sets.WS.SB = sets.Subtle_Blow

	sets.WS["Seraph Blade"] =  set_combine(sets.WS.MAB, {
		right_ring=gear.weatherspoon,
		right_ear = gear.moonshadeEarringAcc,
	})

	sets.WS["Sanguine Blade"] = set_combine(sets.WS.MAB, {
		head=gear.pixieHead,
		right_ring=gear.archonRing,
	})

	sets.WS["Aeolian Edge"] = set_combine(sets.WS.MAB, {
		right_ear = gear.moonshadeEarringAcc,
	})

	sets.WS["Red Lotus Blade"] = sets.WS.MAB

	sets.WS["Chant du Cygne"] = sets.WS.CRIT

	sets.WS["Savage Blade"] = sets.WS.WSD

	sets.WS["Black Halo"] = sets.WS.WSD

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
	if buffactive['Saboteur'] and spell.skill == 'Enfeebling Magic' then
		equipSet = sets.Saboteur
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

-- This function is called when the job file is unloaded
function user_file_unload()

end

--Function used to automate Job Ability use
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
