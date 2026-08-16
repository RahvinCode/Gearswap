
--Luthien

-- Load and initialize the include file.
include('GearSets-Include')
include('Mirdain-Include')

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "11"
MacroBook = "8"
MacroSet = "2"

-- Use "gs c food" to use the specified food item 
Food = "Sublime Sushi"

--Uses Items Automatically
AutoItem = false

--Upon Job change will use a random lockstyleset
Random_Lockstyle = false

-- 'TP','ACC','DT' are standard Default modes.  You may add more and assigne equipsets for them ( Idle.X and OffenseMode.X )
state.OffenseMode:options('TP','ACC','DT','PDL','SB','MEVA') -- ACC effects WS and TP modes

--Lockstyle sets to randomly equip
Lockstyle_List = {1,2,6,12}

--Set default mode (TP,ACC,DT)
state.OffenseMode:set('DT')

--Command to Lock Style and Set the correct macros
jobsetup (LockStylePallet,MacroBook,MacroSet)

-- Blue Magic classification.  Buckets follow the spell's mechanic, because the
-- mechanics do not share gear.  See the header in Mirdain-Include.lua.
BluePhysical = S { 'Amorphic Spikes', 'Asuran Claws', 'Barbed Crescent', 'Battle Dance',
    'Benthic Typhoon', 'Bilgestorm', 'Bloodrake', 'Bludgeon', 'Body Slam', 'Cannonball',
    'Claw Cyclone', 'Death Scissors', 'Delta Thrust', 'Dimensional Death', 'Disseverment',
    'Empty Thrash', 'Feather Storm', 'Final Sting', 'Foot Kick', 'Frenetic Rip', 'Frypan',
    'Glutinous Dart', 'Goblin Rush', 'Grand Slam', 'Head Butt', 'Heavy Strike', 'Helldive',
    'Hydro Shot', 'Hysteric Barrage', 'Jet Stream', 'Mandibular Bite', 'Paralyzing Triad',
    'Pinecone Bomb', 'Power Attack', 'Quad. Continuum', 'Quadrastrike', 'Queasyshroom',
    'Ram Charge', 'Saurian Slide', 'Screwdriver', 'Seedspray', 'Sickle Slash', 'Sinker Drill',
    'Smite of Rage', 'Spinal Cleave', 'Spiral Spin', 'Sprout Smack', 'Sub-zero Smash',
    'Sudden Lunge', 'Sweeping Gouge', 'Tail Slap', 'Terror Touch', 'Thrashing Assault',
    'Tourbillion', 'Uppercut', 'Vanity Dive', 'Vertical Cleave', 'Whirl of Rage', 'Wild Oats' }
BlueBreath = S { 'Bad Breath', 'Flying Hip Press', 'Frost Breath', 'Heat Breath',
    'Hecatomb Wave', 'Magnetite Cloud', 'Poison Breath', 'Radiant Breath', 'Self-Destruct',
    'Thunder Breath', 'Vapor Spray', 'Wind Breath' }
BlueNuke = S { 'Acrid Stream', 'Anvil Lightning', 'Blastbomb', 'Blazing Bound',
    'Blinding Fulgor', 'Blitzstrahl', 'Bomb Toss', 'Cesspool', 'Charged Whisker',
    'Crashing Thunder', 'Cursed Sphere', 'Dark Orb', 'Death Ray', 'Diffusion Ray',
    'Droning Whirlwind', 'Embalming Earth', 'Entomb', 'Evryone. Grudge', 'Eyes On Me',
    'Firespit', 'Foul Waters', 'Gates of Hades', 'Ice Break', 'Leafstorm', 'Maelstrom',
    'Magic Hammer', 'Mind Blast', 'Molting Plumage', 'Mysterious Light', 'Nectarous Deluge',
    'Palling Salvo', 'Polar Roar', 'Rail Cannon', 'Regurgitation', 'Rending Deluge',
    'Retinal Glare', 'Scouring Spate', 'Searing Tempest', 'Silent Storm', 'Spectral Floe',
    'Subduction', 'Tearing Gust', 'Tem. Upheaval', 'Temporal Shift', 'Tenebral Crush',
    'Thermal Pulse', 'Thunderbolt', 'Uproot', 'Water Bomb' }
BlueSkill = S { 'Atra. Libations', 'Barrier Tusk', 'Diamondhide', 'Magic Barrier',
    'Metallic Body', 'Occultation', 'Plasma Charge', 'Pyric Bulwark', 'Reactor Cool' }
BlueBuff = S { 'Amplification', 'Animating Wail', 'Battery Charge', 'Carcharian Verve',
    'Cocoon', 'Erratic Flutter', 'Exuviation', 'Fantod', 'Feather Barrier', 'Harden Shell',
    'Memento Mori', 'Mighty Guard', 'Nat. Meditation', 'O. Counterstance', 'Refueling',
    'Regeneration', 'Saline Coat', 'Triumphant Roar', 'Warm-Up', 'Winds of Promy.',
    'Zephyr Mantle' }
BlueHealing = S { 'Healing Breeze', 'Magic Fruit', 'Plenilune Embrace', 'Pollen', 'Restoral',
    'Wild Carrot' }
BlueTank = S { 'Actinic Burst', 'Blank Gaze', 'Demoralizing Roar', 'Frightful Roar',
    'Geist Wall', 'Jettatura', 'Sheep Song', 'Soporific', 'Stinking Gas' }
BlueACC = S { '1000 Needles', 'Absolute Terror', 'Auroral Drape', 'Awful Eye',
    'Blistering Roar', 'Blood Drain', 'Blood Saber', 'Chaotic Eye', 'Cimicine Discharge',
    'Cold Wave', 'Corrosive Ooze', 'Cruel Joke', 'Digest', 'Dream Flower', 'Enervation',
    'Feather Tickle', 'Filamented Hold', 'Infrasonics', 'Light of Penance', 'Lowing',
    'MP Drainkiss', 'Mortal Ray', 'Osmosis', 'Reaving Wind', 'Sandspin', 'Sandspray',
    'Sound Blast', 'Venom Shell', 'Voracious Trunk', 'Yawn' }

--Weapons specific to Blue Mage
state.WeaponMode:options('Almace','Naegling','Black Halo','Cleave')
state.WeaponMode:set('Almace')

--Enable JobMode for UI
UI_Name = 'Mode'

--Modes for specific to Blue Mage
state.JobMode:options('AoE','Melee')
state.JobMode:set('Melee')

function get_sets()

	--Set the weapon options.  This is set below in job customization section

	-- Weapon setup
	sets.Weapons = {}

	sets.Weapons['Almace'] = {
		main=gear.almace,
		sub = gear.sakpataSword,
	}

	sets.Weapons['Naegling'] = {
		main=gear.naegling,
		sub=gear.zantetsuken,
		--sub={ name="Machaera +2", augments={'TP Bonus +1000',}},
	}

	sets.Weapons['Black Halo'] = {
	    main=gear.maxentius,
		sub=gear.bunzi,
	}

	sets.Weapons['Cleave'] = {
		main = gear.nibiruCudgelNuke,
		sub = gear.nibiruCudgelNuke,
	}

	sets.Weapons.Shield = {
		sub=gear.genmeiShield,
	}

	sets.Weapons.Shield = {}
	sets.Weapons.Sleep = {}

	-- Standard Idle set with -DT,Refresh,Regen and movement gear
	sets.Idle = {
		ammo=gear.staunchPlusOne,
		head=gear.malignanceHead,
		body=gear.hashishinBodyPlusThree,
		hands=gear.hashishinHandsPlusThree,
		legs=gear.hashishinLegsPlusThree,
		feet=gear.hashishinFeetPlusThree,
		neck = gear.loricatePlusOne,
		waist=gear.carriers,
		left_ear=gear.etiolation,
		right_ear = gear.odnowaPlusOne,
		left_ring = gear.stikiniRingPlusOne1, -- +1 Refresh
		right_ring = gear.stikiniRingPlusOne2, -- +1 Refresh
		back = gear.bluDA,
    }
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck=gear.warderCharmPlusOne,
		waist=gear.carriers,
	})

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

	sets.Subtle_Blow = {
		neck=gear.bathyPlusOne,
		left_ring = gear.chirichPlusOne2,
	}

	sets.OffenseMode = {
	    ammo = gear.coiste,
		head=gear.malignanceHead,
		body=gear.malignanceBody,
		hands=gear.malignanceHands,
		legs=gear.malignanceLegs,
		feet=gear.malignanceFeet,
		neck = gear.mirageStole,
		waist=gear.reiki,
		left_ear=gear.eabani,
		right_ear = gear.hashishinEarringPlusOneDA,
		left_ring=gear.eponas,
		right_ring=gear.lehkoHabhokaRing,
		back = gear.bluDA,
	}

	sets.OffenseMode.TP = {
		ammo = gear.coiste,
		head = gear.gletiHead,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
		waist=gear.windbuffetPlusOne,
		left_ear=gear.crepuscularEar,
		right_ear=gear.telos,
		left_ring=gear.eponas,
		right_ring=gear.lehkoHabhokaRing,
		back = gear.bluDA,
	}

	sets.OffenseMode.DT = set_combine ( sets.OffenseMode.TP, {
		head=gear.malignanceHead,
		body=gear.malignanceBody,
		hands=gear.malignanceHands,
		legs=gear.malignanceLegs,
		feet=gear.malignanceFeet,
		left_ring=gear.defending,
		right_ear = gear.odnowaPlusOne,
	})

	sets.OffenseMode.ACC = set_combine ( sets.OffenseMode.DT,{
	
	})

	sets.OffenseMode.PDL = set_combine ( sets.OffenseMode.DT,{
	
	})

	sets.OffenseMode.MEVA = set_combine ( sets.OffenseMode.DT,{
		ammo = gear.coiste,
		head = gear.gletiHead,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
		neck=gear.warderCharmPlusOne,
		waist=gear.reiki,
		left_ear=gear.telos,
		right_ear=gear.eabani,
		left_ring=gear.chirichRingPlusOne,
		right_ring=gear.lehkoHabhokaRing,
		back = gear.bluDA,
	})

	sets.OffenseMode.SB = set_combine ( sets.OffenseMode,{
		left_ring = gear.chirichPlusOne1,
		right_ring = gear.chirichPlusOne2,
	})

	sets.DualWield = {
		left_ear=gear.eabani,
		waist=gear.reiki,
	}

	sets.Precast = {}

	-- Used for Magic Spells
	-- 10% FC from sword
	sets.Precast.FastCast = {
		ammo=gear.impatiens, -- Quick Magic 2
		head = gear.carmineHeadPlusOnePathD, --14
		body = gear.taeonTabardFCB, -- 9
		hands = gear.leylineGlovesFCB, -- 8
		legs=gear.ayanmoLegsPlusTwo, --6
		feet = gear.carmineFeetPlusOnePathD, --8
		neck=gear.voltsurge, -- 4
		waist=gear.witful, -- Quick Magic 3
		left_ear=gear.etiolation, --1
		right_ear=gear.loquacious, --2
		left_ring=gear.lebecheRing, -- Quick Magic 2
		right_ring=gear.weatherspoon, --5 Quick Magic 3
		back = gear.bluFCSird, --10
	} -- 79 and 10% Quick Magic

	sets.Precast.BlueMagic = set_combine (sets.Precast.FastCast, {
		body=gear.hashishinBodyPlusThree, -- 16
	})

	-- Job Abilities
	sets.JA = {}
	sets.JA["Azure Lore"] = {}
	sets.JA["Chain Affinity"] = {}
	sets.JA["Burst Affinity"] = {}
	sets.JA["Diffusion"] = {}
	sets.JA["Efflux"] = {}
	sets.JA["Unbridled Learning"] = {}
	sets.JA["Unbridled Wisdom"] = {}

	-- Dancer JA Section

	sets.Flourish = set_combine(sets.Idle.DT, {})
	sets.Jig = set_combine(sets.Idle.DT, { })
	sets.Step = set_combine(sets.OffenseMode.DT, {})
	sets.Samba = set_combine(sets.Idle.DT, {})
	sets.Waltz = set_combine(sets.OffenseMode.DT, {
		ammo=gear.yamarang, -- 5
		body = gear.gletiBody, -- 10
		hands=gear.slitherGlovesPlusOne, -- 5
		legs=gear.dashingSubligar, -- 10
	}) -- 30% Potency


	--Base set for midcast - if not defined will notify and use your idle set for surviability
	sets.Midcast = set_combine(sets.Idle, {})

	--This set is used as base as is overwrote by specific gear changes (Spell Interruption Rate Down)
	sets.Midcast.SIRD = { --Total = 15 merits + 84 gear = 99 - Cap is 105
		ammo=gear.staunchPlusOne, -- 11
		hands = gear.amalricHandsPlusOnePathD, --11
		legs = gear.carmineLegsPlusOnePathA, -- 20
		feet = gear.amalricFeetPlusOnePathA, --16
		waist=gear.ruminationSash, --10
	}

	-- Cure Set
	sets.Midcast.Cure = {
		ammo=gear.staunchPlusOne,
		head = gear.nyameHead,
		body=gear.hashishinBodyPlusThree,
		hands = gear.telchineGlovesCEnhDur,
		legs=gear.hashishinLegsPlusThree,
		feet = gear.mediumSabotsCure,
		neck=gear.incanterTorque,
		waist=gear.gishdubar,
		left_ear=gear.mendicantEarring,
		right_ear=gear.hashishinEarringPlusOne,
		left_ring=gear.lebecheRing,
		right_ring=gear.menelausRing,
		back = gear.bluFCSird,
    } --35 %

	-- Enhancing Skill
	sets.Midcast.Enhancing = {
	    ammo=gear.staunchPlusOne,
		head = gear.telchineCapBEnhDur,
		body = gear.telchineChasubleBEnhDur,
		hands = gear.telchineGlovesCEnhDur,
		legs = gear.telchineBraconiBEnhDur,
		feet = gear.telchinePigachesBEnhDur,
		neck=gear.incanterTorque,
		waist=gear.olympus,
		left_ear=gear.mimir,
		right_ear = gear.odnowaPlusOne,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
		back = gear.bluFCSird,
	}

	-- High MACC for landing spells
	sets.Midcast.Enfeebling = {}

	sets.Midcast.Nuke = {
		ammo=gear.pemphredoTathlum,
		head=gear.hashishinHeadPlusThree,
		body=gear.hashishinBodyPlusThree,
		hands=gear.hashishinHandsPlusThree,
		legs=gear.hashishinLegsPlusThree,
		feet=gear.hashishinFeetPlusThree,
		neck=gear.sanctity,
		waist=gear.orpheusWaist,
		left_ear=gear.friomisi,
		right_ear=gear.regalEarring,
		left_ring=gear.shivaRingPlusOne,
		right_ring = gear.metamorphPlusOne,
		back = gear.bluFCSird,
	}

	-- Blue Magic
	sets.Midcast.BlueMagic = {}
	sets.Midcast.BlueMagic.Skill = set_combine(sets.Midcast.Enhancing, {})
	sets.Midcast.BlueMagic.Nuke = set_combine(sets.Midcast.Nuke, {})
	sets.Midcast.BlueMagic.Healing = set_combine(sets.Midcast.Cure, {})
	sets.Midcast.BlueMagic.Enmity = set_combine(sets.Enmity, {})
	sets.Midcast.BlueMagic.ACC = set_combine(sets.Idle, {
		ammo=gear.pemphredoTathlum,
		head=gear.hashishinHeadPlusThree,
		body=gear.hashishinBodyPlusThree,
		hands=gear.hashishinHandsPlusThree,
		legs=gear.hashishinLegsPlusThree,
		feet=gear.hashishinFeetPlusThree,
		neck=gear.nullLoop,
		waist=gear.nullWaist,
		left_ear=gear.telos,
		right_ear=gear.hashishinEarringPlusOne,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
		back=gear.nullShawl,
	})

	-- Specific gear for spells
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
		waist=gear.siegel,
		neck=gear.nodens,
	})

    sets.Midcast["Refresh"] = set_combine(sets.Midcast.Enhancing, {
		waist=gear.gishdubar
	})
	
    -- White Wind heals floor(MaxHP/7)*2 and is affected by Cure Potency, but NOT by
    -- Blue Magic Skill or MND.  Prioritize max HP, then Cure Potency.
    sets.Midcast["White Wind"] = {}

    sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, {
	})

	sets.Midcast["Feather Tickle"] = set_combine(sets.Midcast.BlueMagic.ACC, {
		ammo=gear.pemphredoTathlum,
		head = gear.carmineHeadPlusOnePathD,
		body=gear.hashishinBodyPlusThree,
		hands=gear.hashishinHandsPlusThree,
		legs=gear.hashishinLegsPlusThree,
		feet=gear.hashishinFeetPlusThree,
		neck=gear.nullLoop,
		waist=gear.nullWaist,
		left_ear=gear.crepuscularEar,
		right_ear=gear.hashishinEarringPlusOne,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring=gear.weatherspoon,
		back = gear.bluFCSird,
	})

	sets.Midcast["Reaving Wind"] = set_combine(sets.Midcast.BlueMagic.ACC, {
		ammo=gear.pemphredoTathlum,
		head = gear.carmineHeadPlusOnePathD,
		body=gear.hashishinBodyPlusThree,
		hands=gear.hashishinHandsPlusThree,
		legs=gear.hashishinLegsPlusThree,
		feet=gear.hashishinFeetPlusThree,
		neck=gear.nullLoop,
		waist=gear.nullWaist,
		left_ear=gear.crepuscularEar,
		right_ear=gear.hashishinEarringPlusOne,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring=gear.weatherspoon,
		back = gear.bluFCSird,
	})

	sets.Midcast["Cruel Joke"] = set_combine(sets.Midcast.BlueMagic.ACC, {
		ammo=gear.pemphredoTathlum,
		head = gear.carmineHeadPlusOnePathD,
		body=gear.hashishinBodyPlusThree,
		hands=gear.hashishinHandsPlusThree,
		legs=gear.hashishinLegsPlusThree,
		feet=gear.hashishinFeetPlusThree,
		neck=gear.nullLoop,
		waist=gear.nullWaist,
		left_ear=gear.crepuscularEar,
		right_ear=gear.hashishinEarringPlusOne,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring=gear.weatherspoon,
		back = gear.bluFCSird,
	})

	sets.Midcast['Entomb'] = set_combine(sets.Midcast.BlueMagic.Nuke, {
		neck=gear.quanpur,
	})

	sets.WS = {
		ammo = gear.coiste,
		head=gear.hashishinHeadPlusThree,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.mirageStole,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.ishvara,
		left_ring=gear.epimanondas,
		right_ring=gear.eponas,
		back = gear.bluWSDDt,
	}

	--This set is used when OffenseMode is ACC and a WS is used (Augments the WS base set)
	sets.WS.ACC = {}

	-- This will augement the WS sets when in the Subtle Blow statnce
	sets.WS.SB = sets.Subtle_Blow

	sets.WS['Black Halo'] = {
		ammo = gear.coiste,
		head=gear.hashishinHeadPlusThree,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.mirageStole,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.ishvara,
		left_ring=gear.epimanondas,
		right_ring=gear.eponas,
		back = gear.bluWSDDt,
	}

	sets.WS['Expiacion'] = {
		ammo = gear.coiste,
		head=gear.hashishinHeadPlusThree,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.mirageStole,
		waist = gear.sailfi,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.ishvara,
		left_ring=gear.epimanondas,
		right_ring=gear.eponas,
		back = gear.bluWSDDt,
	}

	sets.WS['Chant du Cygne'] = {
		ammo = gear.coiste,
		head = gear.adhemarHeadPlusOnePathA,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
		neck = gear.mirageStole,
		waist=gear.fotiaWaist,
		left_ear=gear.odr,
		right_ear=gear.hashishinEarringPlusOne,
		left_ring=gear.lehkoHabhokaRing,
		right_ring=gear.eponas,
		back = gear.bluDA,
	}

	-- Note that the Mote library will unlock these gear spots when used.
	sets.TreasureHunter = {
		waist=gear.chaac,
		body=gear.volteJupon,
		ammo=gear.perfectEgg,
	}

	sets.Diffusion = {
	    feet = gear.luhlazaFeetPlusOne,
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
	if spell.type == 'WeaponSkill' then
		if state.OffenseMode.value == "MEVA" then
			equipSet = set_combine(equipSet, { neck=gear.warderCharmPlusOne, })
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
	if command == 'jobmode' then
		if state.JobMode.value == 'AoE' then
			send_command('input //aset spellset magic;input /macro book 8;wait .1; input /macro set 2')
		else
			send_command('input //aset spellset tp;input /macro book 8;wait .1; input /macro set 1')
		end
	end
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
	local sp_recasts = windower.ffxi.get_spell_recasts()
	if not buffactive['Phalanx'] and sp_recasts[517] == 0 and player.mp >= 19 then
		buff = "Metallic Body"
	elseif not buffactive['Aquaveil'] and sp_recasts[55] == 0 and player.mp > 12 then
		buff = "Aquaveil"
	elseif not buffactive['Defense Boost'] and sp_recasts[547] == 0 and player.mp > 10 then
		buff = "Cocoon"
	end
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
