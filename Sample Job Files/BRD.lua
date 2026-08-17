--Luthien

-- Load and initialize the include file.
include('GearSets-Include')
include('Mirdain-Include')

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "9"
MacroBook = "9"
MacroSet = "1"

-- Use "gs c food" to use the specified food item 
Food = "Tropical Crepe"

--Modes for specific to bard
state.WeaponMode:options('Mordant Rime','Aeolian Edge','Shining Strike','Shining Blade','Savage Blade','Evisceration','Rudra\'s Storm','Staff')
state.WeaponMode:set('Mordant Rime')

--Default to DT Mode
state.OffenseMode:set('TP')

-- 'TP','ACC','DT' are standard Default modes.  You may add more and assigne equipsets for them ( Idle.X and OffenseMode.X )
state.OffenseMode:options('TP','ACC','DT','PDL','SB','MEVA','CRIT') -- ACC effects WS and TP modes

--Command to Lock Style and Set the correct macros
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	--Set the weapon options.  This is set below in job customization section
	sets.Weapons = {}

	sets.Weapons['Mordant Rime'] = {
		main = gear.carnwenhan,
		sub=gear.crepuscularKnife,
	}

	sets.Weapons['Aeolian Edge'] = {
		main = gear.carnwenhan,
		sub = gear.gleti,
	}

	sets.Weapons['Shining Strike'] = {
		main=gear.daybreak,
		sub = gear.gleti,
	}

	sets.Weapons['Shining Blade'] = {
		main=gear.naegling,
		sub=gear.daybreak,
	}

	sets.Weapons['Savage Blade'] = {
		main=gear.naegling,
		sub = gear.fusettoPlusTwoB,
	}

	sets.Weapons['Staff'] = {
		main=gear.xoanon,
		sub=gear.alberStrap,
	}

	sets.Weapons['Evisceration'] = {
		main='Tauret',
		sub = gear.gleti,
	}

	sets.Weapons['Rudra\'s Storm'] = {
		main = gear.carnwenhan,
		sub = gear.gleti,
	}

	sets.Weapons.Songs = {
		main = gear.carnwenhan,
		sub = gear.kaliMacc,
	}

	sets.Weapons.Shield = { sub=gear.genmeiShield,}

	sets.Weapons.Sleep = { range=gear.loughnashade,}

	sets.Weapons.Songs.Precast = {}
	sets.Weapons.Songs.Midcast = {}

	-- Instruments to use
	Instrument = {}
	Instrument.Count = { name="Daurdabla" }
	Instrument.Potency = { name="Gjallarhorn" }
	Instrument.Enfeebling = { name="Gjallarhorn" }
	Instrument.Pianissimo = { name="Gjallarhorn" }

	-- Note all song types that can be Pianissimo'd can be defined
	Instrument.Pianissimo.Ballad = { name="Miracle Cheer" } -- Possible swap to Miracle Cheer
	Instrument.AOE_Sleep = { name="Daurdabla" }

	Instrument.Idle = { name="Linos", augments={'Mag. Evasion+15','"Waltz" potency +4%','HP+20',} }
	Instrument.TP = { name="Linos", augments={'Accuracy+20','"Store TP"+4','Quadruple Attack +3',} }
	Instrument.Mordant = { name="Linos", augments={'Accuracy+15 Attack+15','Weapon skill damage +3%','CHR+8',} }
	Instrument.QuickMagic = { name="Linos", augments={'Mag. Evasion+15','Occ. quickens spellcasting +4%','HP+20',} }
	Instrument.FastCast = { name="Linos", augments={'Mag. Evasion+15','"Fast Cast"+6','HP+20',} }
	Instrument.WS = {  name="Linos", augments={'Accuracy+15 Attack+15','Weapon skill damage +3%','STR+8',} }
	Instrument.MAB = {  name="Linos", augments={'Mag.Atk.Bns."+15','Weapon skill damage +3%','INT+8',} }

	-- Standard Idle set
	sets.Idle = {
		range=Instrument.Idle,  -- 4/0
		head=gear.filiHeadPlusThree, -- 11/11
		body=gear.adamantiteArmor, -- 20/20
		hands=gear.bunziHands, -- 8/8 
		legs=gear.filiLegsPlusThree, -- 13/13
		feet=gear.filiFeetPlusThree, -- 18% Movement
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
		left_ear = gear.odnowaPlusOne, -- 3/3
		right_ear=gear.sanareEarring,
		left_ring=gear.wardenRing,
		right_ring=gear.shadowRing,
		back = gear.brdWaltz,
    }

	sets.Idle.Resting = set_combine(sets.Idle, {})

	-- These are used based off your OffenseMode
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {})
	sets.Idle.CRIT = set_combine(sets.Idle, {})

	--Used to swap into movement gear when the player is detected movement when not engaged
	sets.Movement = { feet=gear.filiFeetPlusThree}

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

	--The following sets augment the base TP set 
	--Only 9 is needed with haste samba and /DNC.  /NIN needs 11 without samba and none with samba
	sets.DualWield = {
		waist=gear.reiki,
		--left_ear="Eabani Earring",
	}

	sets.OffenseMode = {}

	--Base TP set to build off
	sets.OffenseMode.TP = {
		range=Instrument.TP,
		head = gear.bunziHead,
		body=gear.asheraHarness,
		hands = gear.bunziHands,
		legs=gear.volteTights,
		feet=gear.nyameFeet,
		neck = gear.bardCharm,
		waist=gear.windbuffetPlusOne, -- swapped out with Dual Wield
		left_ear=gear.telos,
		right_ear=gear.balderEarringPlusOne,
		left_ring=gear.lehkoHabhokaRing,
		right_ring = gear.chirichPlusOne2,
		back=gear.nullShawl,
	}

	--This set is used when OffenseMode is DT and Enaged (Augments the TP base set)
	sets.OffenseMode.DT = set_combine(sets.OffenseMode.TP, {
		legs=gear.filiLegsPlusThree,
		right_ring = gear.moonlightRing2,
	})

	--This set is used when OffenseMode is ACC and Enaged (Augments the TP base set)
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode.TP, {})

	--This set is used when OffenseMode is PDL and Enaged
	sets.OffenseMode.PDL = set_combine(sets.OffenseMode.TP, {
		left_ring=gear.sroda,
	})

	--This set is used when OffenseMode is PDL and Enaged
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode.DT, {
		waist=gear.carriers,
	})

	--This set is used when OffenseMode is SB and Enaged (Augments the TP base set)
	sets.OffenseMode.SB = set_combine(sets.OffenseMode, {
		left_ring = gear.chirichPlusOne1,
		right_ring = gear.chirichPlusOne2,
	})

	sets.OffenseMode.CRIT = set_combine(sets.OffenseMode, {
		body=gear.adamantiteArmor,
		right_ring=gear.moonlightRing,
	})

	sets.Precast = {}

	-- Used for Magic Spells
	sets.Precast.FastCast = {
		range=Instrument.QuickMagic, -- 4 Quick Magic
		head = gear.bunziHead, -- 10
		body=gear.inyangaBodyPlusTwo, -- 14
		hands = gear.leylineGlovesFCB, -- 8
		legs=gear.volteLegs, -- 9
		feet=gear.filiFeetPlusThree, -- 13
		neck=gear.voltsurge, -- 4
		waist=gear.witful, -- 3 3 Quick Magic
		left_ear=gear.etiolation, -- 1
		right_ear = gear.tuisto,
		left_ring=gear.kishar, -- 4
		right_ring=gear.weatherspoon, -- 5 3 Quick Magic
		back = gear.brdFCPdt, -- 10
	} -- 81 FC and 10 Quick Magic

	-- Used for Songs (now easy to max Fast Cast so not needed)
	sets.Precast.Songs = {}
	-- Used for "-Cure casting time"
	sets.Precast.Cure = {}
	-- Used for "-Enhancing casting time"
	sets.Precast.Enhancing = {}
	-- Used for "Utsusemi casting time"
	sets.Precast.Utsusemi = {}
	-- Used for "Blue Magic casting time"
	sets.Precast.BlueMagic = {}

	-- Default song duration / strength
	sets.Midcast = set_combine(sets.Idle, {
		head=gear.filiHeadPlusThree, -- 11
		body=gear.filiBodyPlusThree,
		hands=gear.filiHandsPlusThree, -- 11
		legs=gear.inyangaLegsPlusTwo,
		feet=gear.briosoFeetPlusFour,
		neck=gear.moonbowWhistlePlusOne,
		waist=gear.carriers,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.alabaster,
		left_ring=gear.murky,
		right_ring=gear.defending,
		back = gear.brdFCPdt,
	})

	-- Reduce Durations for Dummy songs (Ballad is lowest duration)
	sets.Midcast.DummySongs = set_combine(sets.Idle, {})

	-- Cure Set
	sets.Midcast.Cure = {
		range = gear.linosFC,
		head = gear.kaykausHeadPlusOnePathB,
		body = gear.kaykausBodyPlusOnePathD,
		hands = gear.kaykausHandsPlusOnePathB,
		legs = gear.kaykausLegsPlusOnePathB,
		feet = gear.kaykausFeetPlusOnePathB,
		neck=gear.loricatePlusOne,
		waist=gear.platinumMoogleBelt,
		left_ear=gear.odnowaPlusOne,
		right_ear=gear.alabaster,
		left_ring=gear.murky,
		right_ring=gear.defending,
		back = gear.brdFCPdt,
    } -- 50% Cure Potency / 15% Cure Potency II

	sets.Midcast.Regen = {}
	sets.Midcast.Refresh = {}

	-- Base set for duration
	sets.Midcast.Enhancing = {
		sub=gear.ammurapi,
		range = gear.linosFC,
		head = gear.telchineCapBEnhDur,
		body = gear.telchineChasubleBEnhDur,
		hands = gear.telchineGlovesCEnhDur,
		legs = gear.telchineBraconiBEnhDur,
		feet = gear.telchinePigachesBEnhDur,
		neck=gear.incanterTorque,
		waist=gear.embla,
		left_ear=gear.odnowaPlusOne,
		right_ear=gear.alabaster,
		left_ring=gear.murky,
		right_ring=gear.moonlightRing,
		back = gear.brdFCPdt,
	}

	--Used for elemental Bar Magic Spells
	sets.Midcast.Enhancing.Elemental = {}
	sets.Midcast.Enhancing.Status = {}
	sets.Midcast.Enhancing.Skill = {}
	sets.Midcast.Enhancing.Gain = {}

	-- Curaga Set (different rules than cure)
	sets.Midcast.Curaga = sets.Midcast.Cure

	-- Cursna Set
	sets.Midcast.Cursna = set_combine (sets.Midcast.Cure, {
		range = gear.linosFC,
		head = gear.kaykausHeadPlusOnePathB,
		body=gear.adamantiteArmor,
		hands=gear.inyangaHandsPlusTwo,
		legs = gear.kaykausLegsPlusOnePathB,
		feet=gear.gendewithaGaloshesPlusOne,
		neck=gear.loricatePlusOne,
		waist=gear.witful,
		left_ear=gear.odnowaPlusOne,
		right_ear=gear.alabaster,
		left_ring=gear.menelausRing,
		right_ring=gear.haomaRing,
		back = gear.brdFCPdt,
	})

	sets.Midcast.Divine = {}
	sets.Midcast.Phalanx = {}

	-- High MACC for landing spells
	sets.Midcast.Enfeebling = {
		sub=gear.ammurapi,
		range=Instrument.Potency,
		head=gear.briosoHeadPlusFour,
		body=gear.briosoBodyPlusFour,
		hands=gear.briosoHandsPlusFour,
		legs=gear.filiLegsPlusThree,
		feet=gear.briosoFeetPlusFour,
		neck=gear.moonbowWhistlePlusOne,
		waist=gear.nullWaist,
		left_ear=gear.regalEarring,
		right_ear=gear.crepuscularEar,
		left_ring=gear.stikiniPlusOne,
		right_ring=gear.stikiniPlusOne,
		back = gear.brdFCPdt,
	}

	sets.Midcast.Enfeebling.MACC = {}
	sets.Midcast.Enfeebling.Potency = {}
	sets.Midcast.Enfeebling.Duration = {}

	-- Bard Specific Sets

	-- Max duration
	sets.Midcast.Lullaby = set_combine(sets.Midcast.Enfeebling, {
		body=gear.filiBodyPlusThree,
		legs=gear.inyangaLegsPlusTwo,
	})

	sets.Midcast.Finale = {}
	sets.Midcast.Requiem = {}
	sets.Midcast.Elegy = {}
	sets.Midcast.Prelude = {}
	sets.Midcast.Madrigal = {head=gear.filiHeadPlusThree}
    sets.Midcast.Minuet = {body=gear.filiBodyPlusThree}
    sets.Midcast.March = {hands=gear.filiHandsPlusThree}
    sets.Midcast.Ballad = {legs=gear.filiLegsPlusThree}
    sets.Midcast.Scherzo = {feet=gear.filiFeetPlusThree}
    sets.Midcast.Mazurka = {}
    sets.Midcast.Paeon = {head=gear.briosoHeadPlusFour}
    sets.Midcast.Threnody = {body=gear.mousaiManteelPlusOne}
    sets.Midcast.Minne = {legs=gear.mousaiLegsPlusOne}
    sets.Midcast.Mambo = {}
    sets.Midcast.Carol = {hands=gear.mousaiGagesPlusOne}
    sets.Midcast.Etude = {head=gear.mousaiTurbanPlusOne}
	sets.Midcast.Dirge = {}
	sets.Midcast.Sirvente = {}
	sets.Midcast.Aria = {}

	-- Specific gear for spells
	sets.Midcast["Stoneskin"] = {
		waist=gear.siegel,
	}

	-- Job Abilities
	sets.JA = {}
	sets.JA["Nightingale"] = {feet = gear.bihuFeetPlusFour}
	sets.JA["Troubadour"] = {body = gear.bihuBodyPlusFour,}
	sets.JA["Soul Voice"] = {legs = gear.bihuLegsPlusFour}
	sets.JA["Tenuto"] = {}
	sets.JA["Marcato"] = {}
	sets.JA["Clarion"] = {}
	sets.JA["Pianissimo"] = {}

	-- Dancer JA Section

	sets.Flourish = set_combine(sets.Idle.DT, {})
	sets.Jig = set_combine(sets.Idle.DT, { })
	sets.Step = set_combine(sets.Idle.DT, {})
	sets.Samba = set_combine(sets.Idle.DT, {})
	sets.Waltz = set_combine(sets.Idle.DT, {
		range=Instrument.Idle, -- 4
		legs=gear.dashingSubligar, -- 10
		back = gear.brdWaltz, --10
	}) -- 24% Potency

	--Default WS set base
	sets.WS = {
		range=Instrument.WS,
		head=gear.nyameHead,
		body=gear.bihuBodyPlusFour,
		hands=gear.nyameHands,
		legs=gear.nyameLegs,
		feet=gear.nyameFeet,
		neck=gear.republicanPlatinumMedal,
		waist=gear.sailfi,
		left_ear=gear.moonshade,
		right_ear=gear.regalEarring,
		left_ring=gear.sroda,
		right_ring=gear.epimanondas,
		back = gear.brdWSDDt,
	}

	-- Equipment to augment the Melee WS for Physical Damage Limit (Capped Attack)
	sets.WS.PDL = set_combine(sets.WS, {
		body=gear.bunziBody,
		right_ring=gear.sroda,
	})

	--The following sets augment the WS base set
	sets.WS.WSD = set_combine(sets.WS, {
		
	})

	sets.WS.MAB = set_combine(sets.WS, {
		range=Instrument.MAB,
		neck=gear.sibylScarf,
		waist=gear.orpheusWaist,
		body=gear.nyameBody,
		left_ring=gear.metamorphPlusOne,
		back = gear.brdWSDInt,
	})

	sets.WS.ACC = set_combine(sets.WS, {})

	sets.WS.MEVA = set_combine(sets.WS, {
	    neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
	})

	sets.WS.CRIT = set_combine(sets.WS, {
		neck=gear.fotiaNeck,
		waist=gear.fotiaWaist,
		right_ear = gear.moonshadeEarringAcc,
		left_ring=gear.hetairoi,
		right_ring=gear.ilabrat,
		back = gear.brdWSDDt,
	})

	sets.WS.SB = {
		left_ring = gear.chirichPlusOne1,
		right_ring = gear.chirichPlusOne2,
	}

	sets.WS["Savage Blade"] =  set_combine(sets.WS.WSD, { })

	sets.WS["Mordant Rime"] = set_combine(sets.WS, {
		range=Instrument.Mordant,
		neck = gear.bardCharm,
		waist=gear.grunfeldRope,
		left_ear=gear.ishvara,
		left_ring=gear.metamorphPlusOne,
		back = gear.brdWSDChr,
	})

	sets.WS["Eviceration"] = sets.WS.CRIT

	sets.WS["Aeolian Edge"] = set_combine(sets.WS.MAB, {
	})

	sets.WS["Burning Blade"] = sets.WS.MAB
	sets.WS["Shining Blade"] = set_combine( sets.WS.MAB, {
		right_ring=gear.weatherspoon,
	})
	sets.WS["Shining Strike"] = set_combine( sets.WS.MAB, {
		right_ring=gear.weatherspoon,
	})

	sets.WS["Shell Crusher"] = set_combine( sets.WS.WSD, {
		right_ring=gear.sroda,
	})

	sets.TreasureHunter = {
		body=gear.volteJupon,
		legs=gear.volteHose,
		waist=gear.chaac,
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

function check_buff_SP()
	local buff = 'None'
	--local sp_recasts = windower.ffxi.get_spell_recasts()
	return buff
end

function check_buff_JA()
	local buff = 'None'
	--local ja_recasts = windower.ffxi.get_ability_recasts()
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
