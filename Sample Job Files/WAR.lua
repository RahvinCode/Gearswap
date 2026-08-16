--Turin

-- Load and initialize the include file.
include('GearSets-Include')
include('Mirdain-Include')

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "8"
MacroBook = "4"
MacroSet = "1"

-- Use "gs c food" to use the specified food item 
Food = "Sublime Sushi"

--Uses Items Automatically
AutoItem = false

--Upon Job change will use a random lockstyleset
Random_Lockstyle = false

--Lockstyle sets to randomly equip
Lockstyle_List = {1,2,6,12}

-- 'TP','ACC','DT' are standard Default modes.  You may add more and assigne equipsets for them ( Idle.X and OffenseMode.X )
state.OffenseMode:options('TP','PDL','ACC','DT','PDT','MEVA','CRIT','SB')

--Set default mode (TP,ACC,DT,PDL)
state.OffenseMode:set('DT')

--Weapons options
state.WeaponMode:options('Chango','Shining One','Savage Blade','Decimation','Axe','Aeolian Edge', 'Ukonvasara','Labraunda','Unlocked')
state.WeaponMode:set('Chango')

-- Initialize Player
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- Weapon setup
	sets.Weapons = {}

	sets.Weapons['Chango'] = {
		main=gear.chango,
		sub=gear.utu,
	}
	sets.Weapons['Labraunda'] = {
		main = gear.labraunda,
		sub=gear.utu,
	}
	sets.Weapons['Shining One'] = {
		main=gear.shiningOne,
		sub=gear.utu,
	}
	sets.Weapons['Savage Blade'] = {
		main=gear.naegling,
		sub=gear.zantetsuken,
	}
	sets.Weapons['Decimation'] = {
		main=gear.dolichenus,
		sub=gear.zantetsuken,
	}
	sets.Weapons['Axe'] = {
		main=gear.ikengaAxe,
		sub=gear.zantetsuken,
	}
	sets.Weapons['Aeolian Edge'] = {
		main=gear.ternionDaggerPlusOne,
		sub=gear.naegling,
	}
	sets.Weapons['Ukonvasara'] = {
		main=gear.chango,
		sub=gear.utu,
	}
	-- This stops GS from chaning weapons (Abyssea Proc etc)
	sets.Weapons['Unlocked'] ={}

	-- This is used when you do not have dual wield and is not a two handed weapon
	sets.Weapons.Shield = {
		sub=gear.blurredShield,
	}
	sets.Weapons.Sleep = {}

	-- Base set for when the player is not engaged or casting.  Other sets build off this set
	sets.Idle = {
		ammo=gear.staunchPlusOne,
		head=gear.sakpataHead,
		body=gear.sakpataBody,
		hands=gear.sakpataHands,
		legs=gear.sakpataLegs,
		feet=gear.sakpataFeet,
		neck = gear.loricatePlusOne,
		waist=gear.carriers,
		left_ear=gear.eabani,
		right_ear = gear.odnowaPlusOne,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.warDAAcc,
    }
	-- 'TP','PDL','ACC','DT','PDT','MEVA','CRIT','SB'

	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.PDT = set_combine(sets.Idle, {})
	sets.Idle.CRIT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
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

	-- 10 + 19 for Auspice
	sets.Subtle_Blow = {
		body=gear.dagonBreastplate, -- 10 SB II
		feet = gear.sakpataFeet, -- 15 SB I
		hands = gear.sakpataHands, -- 8 SB I
		left_ring=gear.niqmaddu, -- 5 SB II
	}

	--WAR Double attack
	--28% Job Trait
	--5% Merits

	-- Sets the base equipset for OffenseMode
	sets.OffenseMode = {
		ammo = gear.coiste, -- 3 DA
		head=gear.flammaHeadPlusTwo,
		body=gear.dagonBreastplate,
		hands = gear.sakpataHands,
		legs=gear.pummelerLegsPlusThree,
		feet=gear.pummelerFeetPlusThree,
		neck = gear.warriorsBead, -- 7 DA
		waist = gear.sailfi, -- 5 DA
		left_ear = gear.schere, -- 3 DA
		right_ear=gear.boiiEarringPlusOne, -- 8 DA
		left_ring=gear.niqmaddu,
		right_ring=gear.lehkoHabhokaRing,
		back=gear.nullShawl,
	}

	sets.OffenseMode.TP = set_combine( sets.OffenseMode, {})
	--This set is used when OffenseMode is ACC and Enaged
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {})
	--This set is used when OffenseMode is CRIT and Engaged
	sets.OffenseMode.CRIT = set_combine(sets.OffenseMode, {})

	sets.OffenseMode.DT = set_combine( sets.OffenseMode, {
		head=gear.hjarrandiHead,
		body=gear.sakpataBody,
		hands=gear.sakpataHands, -- 6 DA
		legs=gear.sakpataLegs, -- 7 DA
		feet=gear.sakpataFeet, -- 4 DA
	}) -- 100% DA

	sets.OffenseMode.PDL = set_combine( sets.OffenseMode, {
		ammo=gear.crepuscularPebble,
		right_ring=gear.sroda,
	})

	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, {
		ammo = gear.coiste,
		head = gear.sakpataHead,
		neck = gear.warderCharmPlusOne,
		waist=gear.carriers,
		left_ring=gear.moonlightRing,
		right_ring=gear.lehkoHabhokaRing,
	})

	-- Max SB set (SB 50 and SBII 15) Need auspice (29) to cap
	sets.OffenseMode.SB = set_combine(sets.OffenseMode, { 
		head=gear.hjarrandiHead,
		body=gear.sakpataBody,
		legs=gear.sakpataLegs,
		feet=gear.sakpataFeet,
	})

	--These base set are used when an aftermath is active and player is enaged and correct weapon type set (Augments the current OffenseMode)
	--If you don't specify a weapon mode it will use it regardless of Mythic,Empy,Relic,Aeonic

	sets.OffenseMode.AM = {}  -- This is for Relic AM only
	sets.OffenseMode.AM1 = {} -- All AM1 Types
	sets.OffenseMode.AM2 = {} -- All AM2 Types
	sets.OffenseMode.AM3 = {} -- All AM3 Types

	-- This is how you specify a Weapon Mode AM set by Weapon Mode (examples)
	sets.OffenseMode.AM['Bravura'] = {}
	sets.OffenseMode.AM1['Ukonvasara'] = {}
	sets.OffenseMode.AM2['Ukonvasara'] = {}
	sets.OffenseMode.AM3['Ukonvasara'] = {}
	sets.OffenseMode.AM3['Farsha'] = {}
	sets.OffenseMode.AM1['Conqueror'] = {}
	sets.OffenseMode.AM2['Laphria'] = {}

	sets.DualWield = {
		waist=gear.reiki,
		right_ear=gear.eabani,
	}

	sets.Precast = set_combine(sets.Idle, {})

	-- For Cure Cast Time reduction
	sets.Precast.Cure = {}

	-- For Enhancing Cast Time reduction
	sets.Precast.Enhancing = {}

	-- Used for Magic Spells
	sets.Precast.FastCast = {
		ammo=gear.sapience, --2
		head=gear.sakpataHead, --8
		body=gear.sacroBody, --10
		hands = gear.leylineGlovesFCB, --8
		neck=gear.voltsurge, -- 4
		left_ear=gear.etiolation, --1
		right_ear=gear.loquacious, -- 3
		left_ring=gear.prolix, -- 2
		right_ring = gear.gelatinousPlusOne,
	} --44%

	-- For instant casts (Like Raises/Reraise)
	sets.Precast.QuickMagic = {}

	sets.Precast.Enmity = {
		ammo=gear.sapience, -- 2
		head = gear.souveranHeadPlusOnePathC, --9
		body = gear.souveranBodyPlusOnePathC, --20
		hands = gear.souveranHandsPlusOnePathC, --9
		legs = gear.souveranLegsPlusOnePathC, --9
		feet = gear.souveranFeetPlusOnePathC, --9
		neck=gear.moonlightNeck, --15
		left_ear=gear.crypticEarring, --4
		right_ear=gear.truxEarring, --5
		left_ring=gear.petrov, --4
		right_ring=gear.eihwazRing, --5
	} --91

	sets.Precast['Utsusemi: Ichi'] = {}
	sets.Precast['Utsusemi: Ni'] = {}

	-- Ranged Attack
	sets.Precast.RA = {}
    sets.Precast.RA.ACC = {}
	sets.Precast.RA.Flurry = {}
	sets.Precast.RA.Flurry_II = {}

	--Base set for midcast - if not defined will notify and use your idle set for surviability
	sets.Midcast = set_combine(sets.Idle, {})

	--This set is used as base as is overwrote by specific gear changes (Spell Interruption Rate Down)
	sets.Midcast.SIRD = {
	    ammo=gear.staunchPlusOne, --11
		--feet={ name="Odyssean Greaves", augments={'Attack+1','"Fast Cast"+6',}}, --20
		neck=gear.moonlightNeck, --15
		left_ear=gear.magneticEarring, --8
		waist=gear.audumbla, --10
	}

	-- Enhancing
	sets.Midcast.Enhancing = {}
	sets.Midcast.Enhancing.Others = {}
	
	-- Enfeebling
	sets.Midcast.Enfeebling = {}
	-- Skill Based ('Dispel','Aspir','Aspir II','Aspir III','Drain','Drain II','Drain III','Frazzle','Frazzle II','Stun','Poison','Poison II','Poisonga')
	sets.Midcast.Enfeebling.MACC = {}
	-- Potency Basted ('Paralyze','Paralyze II','Slow','Slow II','Addle','Addle II','Distract','Distract II','Distract III','Frazzle III','Blind','Blind II')
	sets.Midcast.Enfeebling.Potency = {}
	-- Duration Based ('Sleep','Sleep II','Sleepga','Sleepga II','Diaga','Dia','Dia II','Dia III','Bio','Bio II','Bio III','Silence','Gravity','Gravity II','Inundation','Break','Breakaga', 'Bind', 'Bind II')
	sets.Midcast.Enfeebling.Duration = {}

	-- Ranged Attack Gear (Normal Midshot)
    sets.Midcast.RA = {}
    sets.Midcast.RA.ACC = {}
    sets.Midcast.RA.PDL = {}
	sets.Midcast.RA.CRIT = {}
	sets.Midcast.RA.AM3 = {}

	-- Healing
	sets.Midcast.Cure = {}
	sets.Midcast.Curaga = set_combine(sets.Midcast.Cure, {})
	sets.Midcast.Regen = {}

	-- Dancer JA
	sets.Flourish = set_combine(sets.Idle.DT, {})
	sets.Jig = set_combine(sets.Idle.DT, {})
	sets.Step = set_combine(sets.OffenseMode.DT, {})
	sets.Waltz = set_combine(sets.OffenseMode.DT, {})

	-- Specific gear for spells
	sets.Midcast["Stoneskin"] = {
		waist=gear.siegel,
	}
	sets.Midcast['Utsusemi: Ichi'] = {}
	sets.Midcast['Utsusemi: Ni'] = {}

	-- Job Abilities
	sets.JA = {}
	sets.JA["Mighty Strikes"] = {}
	sets.JA["Berserk"] = {body=gear.pummelerBodyPlusThree}
	sets.JA["Warcry"] = {head = gear.agogeHeadPlusThree}
	sets.JA["Defender"] = {}
	sets.JA["Aggressor"] = {}
	sets.JA["Provoke"] = sets.Precast.Enmity
	sets.JA["Tomahawk"] = {ammo=gear.throwingTomahawk,} -- Need to add feet
	sets.JA["Retaliation"] = {}
	sets.JA["Restraint"] = {}
	sets.JA["Blood Rage"] = {}
	sets.JA["Brazen Rush"] = {}

	--Default WS set base
	sets.WS = {
		ammo=gear.knobkierrie,
		head = gear.agogeHeadPlusThree,
		body=gear.pummelerBodyPlusThree,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.warriorsBead,
		waist = gear.sailfi,
		left_ear=gear.thrud,
		right_ear=gear.boiiEarringPlusOne,
		left_ring=gear.karieyhRingPlusOne,
		right_ring=gear.regalRing,
		back = gear.warWSDSTR
	}
	sets.WS.RA = {}

	sets.WS.WSD = {}
	sets.WS.WSD.RA = {}

	sets.WS.MEVA = set_combine(sets.WS, {
		head = gear.sakpataHead,
		body = gear.sakpataBody,
	    neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
	})

	-- Modes
	sets.WS.CRIT = {
		ammo=gear.yetshilaPlusOne,
		head = gear.sakpataHead,
		body=gear.hjarrandiBody,
		hands = gear.sakpataHands,
		legs = gear.sakpataLegs,
		feet = gear.sakpataFeet,
		neck = gear.warriorsBead,
		waist = gear.sailfi,
		left_ear = gear.schere,
		right_ear=gear.boiiEarringPlusOne,
		left_ring=gear.niqmaddu,
		right_ring=gear.lehkoHabhokaRing,
		back = gear.warWSDSTR,
	}
	sets.WS.CRIT.RA = {}

	sets.WS.ACC = {}
	sets.WS.ACC.RA = {}

	sets.WS.SB = sets.Subtle_Blow

	sets.WS.SB.RA = {}

	sets.WS.PDL = {}
	sets.WS.PDL.RA = {}

	--These set are used when a weaponskill is used with that level of aftermath with the correct weapon
	--They Augment any built weaponskill set - Same formatting as the OffenseModes
	sets.WS.AM = {}
	sets.WS.AM1 = {}
	sets.WS.AM2 = {}
	sets.WS.AM3 = {}

	sets.WS.AM1['Ukonvasara'] = {}
	sets.WS.AM2['Ukonvasara'] = {}
	sets.WS.AM3['Ukonvasara'] = {}

	sets.WS.AM.RA = {}
	sets.WS.AM1.RA = {}
	sets.WS.AM2.RA = {}
	sets.WS.AM3.RA = {}

	sets.WS.AM1.RA['Some Relic Gun'] = {}
	sets.WS.AM2.RA['Some Relic Gun'] = {}
	sets.WS.AM3.RA['Some Relic Gun'] = {}

	-- Great Axe WS
	sets.WS["Ukko's Fury"] = {
	    ammo=gear.yetshilaPlusOne,
		head = gear.sakpataHead,
		body = gear.sakpataBody,
		hands = gear.sakpataHands,
		legs = gear.sakpataLegs,
		feet = gear.sakpataFeet,
		neck = gear.warriorsBead,
		waist = gear.sailfi,
		left_ear = gear.schere,
		right_ear = gear.boiiEarringPlusOneCrit,
		left_ring=gear.niqmaddu,
		right_ring=gear.lehkoHabhokaRing,
		back = gear.warWSDSTR,
	}
	sets.WS["Upheaval"] = {
	    ammo=gear.knobkierrie,
		head = gear.agogeHeadPlusThree,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.warriorsBead,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.thrud,
		left_ring=gear.niqmaddu,
		right_ring=gear.regalRing,
		back = gear.warWSDSTR,
	}
	sets.WS["Full Break"] = {
		ammo=gear.knobkierrie,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.warriorsBead,
		waist = gear.sailfi,
		left_ear=gear.thrud,
		right_ear = gear.boiiEarringPlusOneCrit,
		left_ring=gear.karieyhRingPlusOne,
		right_ring=gear.regalRing,
		back = gear.warWSDSTR,
	}

	--Axe WS
	sets.WS["Ragin Axe"] = {}
	sets.WS["Smash Axe"] = {}
	sets.WS["Gale Axe"] = {}
	sets.WS["Avalanche Axe"] = {}
	sets.WS["Spinning Axe"] = {}
	sets.WS["Rampage"] = {}
	sets.WS["Calamity"] = {}
	sets.WS["Mistral Axe"] = {}
	sets.WS["Decimation"] = sets.WS.CRIT
	sets.WS["Bora Axe"] = {}
	sets.WS["Cloudsplitter"] = {}

	--Sword WS
	sets.WS["Fast Blade"] = {}
	sets.WS["Burning Blade"] = {}
	sets.WS["Red Lotus Blade"] = {}
	sets.WS["Flat Blade"] = {}
	sets.WS["Shining Blade"] = {}
	sets.WS["Seraph Blade"] = {}
	sets.WS["Circle Blade"] = {}
	sets.WS["Spirits Within"] = {}
	sets.WS["Vorpal Blade"] = {}
	sets.WS["Savage Blade"] = sets.WS.WSD
	sets.WS["Savage Blade"]['PDL'] = set_combine(sets.WS.WSD, {
		head = gear.sakpataHead,
	})

	sets.WS["Sanguine Blade"] = {}
	sets.WS["Requiescat"] = {}

	--Polearm
	sets.WS["Impulse Drive"] = sets.WS.CRIT
	sets.WS["Leg Sweep"] = {
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.warriorsBead,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear = gear.boiiEarringPlusOneCrit,
		left_ring=gear.karieyhRingPlusOne,
		right_ring=gear.regalRing,
		back = gear.warWSDSTR,
	}

	sets.TreasureHunter = {
		ammo=gear.perfectEgg,
		waist=gear.chaac,
		body=gear.volteJupon,
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

function user_file_unload()
	
end

function check_buff_JA()
	local buff = 'None'
	local ja_recasts = windower.ffxi.get_ability_recasts()
	if not buffactive['Berserk'] and ja_recasts[1] == 0 then
		buff = "Berserk"
	elseif not buffactive['Aggressor'] and ja_recasts[4] == 0 then
		buff = "Aggressor"
	elseif not buffactive['Warcry'] and ja_recasts[2] == 0 then
		buff = "Warcry"
	end
	if player.sub_job == 'SAM' then
		if not buffactive['Hasso'] and not buffactive['Seigan'] and ja_recasts[138] == 0 then
			buff = "Hasso"
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
