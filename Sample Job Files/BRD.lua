--Luthien

-- Load and initialize the include file.
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
		main={ name="Carnwenhan", augments={'Path: A',}},
		sub="Crepuscular Knife",
	}

	sets.Weapons['Aeolian Edge'] = {
		main={ name="Carnwenhan", augments={'Path: A',}},
		sub={ name="Gleti's Knife", augments={'Path: A',}},
	}

	sets.Weapons['Shining Strike'] = {
		main="Daybreak",
		sub={ name="Gleti's Knife", augments={'Path: A',}},
	}

	sets.Weapons['Shining Blade'] = {
		main="Naegling",
		sub="Daybreak",
	}

	sets.Weapons['Savage Blade'] = {
		main="Naegling",
		sub={ name="Fusetto +2", augments={'TP Bonus +1000',}},
	}

	sets.Weapons['Staff'] = {
		main="Xoanon",
		sub="Alber Strap",
	}

	sets.Weapons['Evisceration'] = {
		main='Tauret',
		sub={ name="Gleti's Knife", augments={'Path: A',}},
	}

	sets.Weapons['Rudra\'s Storm'] = {
		main={ name="Carnwenhan", augments={'Path: A',}},
		sub={ name="Gleti's Knife", augments={'Path: A',}},
	}

	sets.Weapons.Songs = {
		main={ name="Carnwenhan", augments={'Path: A',}},
		sub={ name="Kali", augments={'Mag. Acc.+15','String instrument skill +10','Wind instrument skill +10',}},
	}

	sets.Weapons.Shield = { sub="Genmei Shield",}

	sets.Weapons.Sleep = { range="Loughnashade",}

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
		head="Fili Calot +3", -- 11/11
		body="Adamantite Armor", -- 20/20
		hands="Bunzi's Gloves", -- 8/8 
		legs="Fili Rhingrave +3", -- 13/13
		feet="Fili Cothurnes +3", -- 18% Movement
		neck="Warder's Charm +1",
		waist="Carrier's Sash",
		left_ear={ name="Odnowa Earring +1", augments={'Path: A',}}, -- 3/3
		right_ear="Sanare Earring",
		left_ring="Warden's Ring",
		right_ring="Shadow Ring",
		back={ name="Intarabus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Mag. Evasion+15',}},
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
	sets.Movement = { feet="Fili Cothurnes +3"}

	--Spell Received Sets
	sets.Cure_Received = {}
	sets.Cursna_Received = {
	    neck="Nicander's Necklace",
	    left_ring={ name="Eshmun's Ring", bag="wardrobe", priority=2},
		right_ring={ name="Eshmun's Ring", bag="wardrobe2", priority=1},
		waist="Gishdubar Sash",
	}
	sets.Phalanx_Received = {}
	sets.Protect_Shell_Received = {}
	sets.Regen_Received = {}
	sets.Refresh_Received = {}
	sets.Waltz_Received = {}
	sets.Holy_Water = {
	    neck="Nicander's Necklace",
	}

	--The following sets augment the base TP set 
	--Only 9 is needed with haste samba and /DNC.  /NIN needs 11 without samba and none with samba
	sets.DualWield = {
		waist="Reiki Yotai",
		--left_ear="Eabani Earring",
	}

	sets.OffenseMode = {}

	--Base TP set to build off
	sets.OffenseMode.TP = {
		range=Instrument.TP,
		head={ name="Bunzi's Hat", augments={'Path: A',}},
		body="Ashera Harness",
		hands={ name="Bunzi's Gloves", augments={'Path: A',}},
		legs="Volte Tights",
		feet="Nyame Sollerets",
		neck={ name="Bard's Charm +2", augments={'Path: A',}},
		waist="Windbuffet Belt +1", -- swapped out with Dual Wield
		left_ear="Telos Earring",
		right_ear="Balder Earring +1",
		left_ring="Lehko's Ring",
		right_ring={ name="Chirich Ring +1", bag="wardrobe2", priority=1},
		back="Null Shawl",
	}

	--This set is used when OffenseMode is DT and Enaged (Augments the TP base set)
	sets.OffenseMode.DT = set_combine(sets.OffenseMode.TP, {
		legs="Fili Rhingrave +3",
		right_ring={ name="Moonlight Ring", bag="wardrobe2", priority=1},
	})

	--This set is used when OffenseMode is ACC and Enaged (Augments the TP base set)
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode.TP, {})

	--This set is used when OffenseMode is PDL and Enaged
	sets.OffenseMode.PDL = set_combine(sets.OffenseMode.TP, {
		left_ring="Sroda Ring",
	})

	--This set is used when OffenseMode is PDL and Enaged
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode.DT, {
		waist="Carrier's Sash",
	})

	--This set is used when OffenseMode is SB and Enaged (Augments the TP base set)
	sets.OffenseMode.SB = set_combine(sets.OffenseMode, {
		left_ring={ name="Chirich Ring +1", bag="wardrobe", priority=1},
		right_ring={ name="Chirich Ring +1", bag="wardrobe2", priority=2},
	})

	sets.OffenseMode.CRIT = set_combine(sets.OffenseMode, {
		body="Adamantite Armor",
		right_ring="Moonlight Ring",
	})

	sets.Precast = {}

	-- Used for Magic Spells
	sets.Precast.FastCast = {
		range=Instrument.QuickMagic, -- 4 Quick Magic
		head={ name="Bunzi's Hat", augments={'Path: A',}}, -- 10
		body="Inyanga Jubbah +2", -- 14
		hands={ name="Leyline Gloves", augments={'Accuracy+15','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Fast Cast"+3',}}, -- 8
		legs="Volte Brais", -- 9
		feet="Fili Cothurnes +3", -- 13
		neck="Voltsurge Torque", -- 4
		waist="Witful Belt", -- 3 3 Quick Magic
		left_ear="Etiolation Earring", -- 1
		right_ear={ name="Tuisto Earring", priority=1,},
		left_ring="Kishar Ring", -- 4
		right_ring="Weather. Ring", -- 5 3 Quick Magic
		back={ name="Intarabus's Cape", augments={'CHR+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Fast Cast"+10','Phys. dmg. taken-10%',}}, -- 10
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
	sets.Precast.Blue_Magic = {}

	-- Default song duration / strength
	sets.Midcast = set_combine(sets.Idle, {
		head="Fili Calot +3", -- 11
		body="Fili Hongreline +3",
		hands="Fili Manchettes +3", -- 11
		legs="Inyanga Shalwar +2",
		feet="Brioso Slippers +4",
		neck="Mnbw. Whistle +1",
		waist="Carrier's Sash",
		left_ear={ name="Odnowa Earring +1", augments={'Path: A',}, priority=3},
		right_ear={ name="Alabaster Earring", priority=1},
		left_ring="Murky Ring",
		right_ring="Defending Ring",
		back={ name="Intarabus's Cape", augments={'CHR+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Fast Cast"+10','Phys. dmg. taken-10%',}},
	})

	-- Reduce Durations for Dummy songs (Ballad is lowest duration)
	sets.Midcast.DummySongs = set_combine(sets.Idle, {})

	-- Cure Set
	sets.Midcast.Cure = {
		range={ name="Linos", augments={'Mag. Evasion+15','"Fast Cast"+6','HP+20',}},
		head={ name="Kaykaus Mitra +1", augments={'MP+80','"Cure" spellcasting time -7%','Enmity-6',}},
		body={ name="Kaykaus Bliaut +1", augments={'MP+80','"Cure" potency +6%','"Conserve MP"+7',}},
		hands={ name="Kaykaus Cuffs +1", augments={'MP+80','"Cure" spellcasting time -7%','Enmity-6',}},
		legs={ name="Kaykaus Tights +1", augments={'MP+80','"Cure" spellcasting time -7%','Enmity-6',}},
		feet={ name="Kaykaus Boots +1", augments={'MP+80','"Cure" spellcasting time -7%','Enmity-6',}},
		neck="Loricate Torque +1",
		waist="Plat. Mog. Belt",
		left_ear="Odnowa Earring +1",
		right_ear="Alabaster Earring",
		left_ring="Murky Ring",
		right_ring="Defending Ring",
		back={ name="Intarabus's Cape", augments={'CHR+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Fast Cast"+10','Phys. dmg. taken-10%',}},
    } -- 50% Cure Potency / 15% Cure Potency II

	sets.Midcast.Regen = {}
	sets.Midcast.Refresh = {}

	-- Base set for duration
	sets.Midcast.Enhancing = {
		sub="Ammurapi Shield",
		range={ name="Linos", augments={'Mag. Evasion+15','"Fast Cast"+6','HP+20',}},
		head={ name="Telchine Cap", augments={'Enh. Mag. eff. dur. +10',}},
		body={ name="Telchine Chas.", augments={'Enh. Mag. eff. dur. +10',}},
		hands={ name="Telchine Gloves", augments={'Enh. Mag. eff. dur. +10',}},
		legs={ name="Telchine Braconi", augments={'Enh. Mag. eff. dur. +10',}},
		feet={ name="Telchine Pigaches", augments={'Enh. Mag. eff. dur. +10',}},
		neck="Incanter's Torque",
		waist="Embla Sash",
		left_ear="Odnowa Earring +1",
		right_ear="Alabaster Earring",
		left_ring="Murky Ring",
		right_ring="Moonlight Ring",
		back={ name="Intarabus's Cape", augments={'CHR+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Fast Cast"+10','Phys. dmg. taken-10%',}},
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
		range={ name="Linos", augments={'Mag. Evasion+15','"Fast Cast"+6','HP+20',}},
		head={ name="Kaykaus Mitra +1", augments={'MP+80','"Cure" spellcasting time -7%','Enmity-6',}},
		body="Adamantite Armor",
		hands="Inyan. Dastanas +2",
		legs={ name="Kaykaus Tights +1", augments={'MP+80','"Cure" spellcasting time -7%','Enmity-6',}},
		feet="Gende. Galosh. +1",
		neck="Loricate Torque +1",
		waist="Witful Belt",
		left_ear="Odnowa Earring +1",
		right_ear="Alabaster Earring",
		left_ring="Menelaus's Ring",
		right_ring="Haoma's Ring",
		back={ name="Intarabus's Cape", augments={'CHR+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Fast Cast"+10','Phys. dmg. taken-10%',}},
	})

	sets.Midcast.Divine = {}
	sets.Midcast.Phalanx = {}

	-- High MACC for landing spells
	sets.Midcast.Enfeebling = {
		sub="Ammurapi Shield",
		range=Instrument.Potency,
		head="Brioso Roundlet +4",
		body="Brioso Just. +4",
		hands="Brioso Cuffs +4",
		legs="Fili Rhingrave +3",
		feet="Brioso Slippers +4",
		neck="Mnbw. Whistle +1",
		waist="Null Belt",
		left_ear="Regal Earring",
		right_ear="Crep. Earring",
		left_ring="Stikini Ring +1",
		right_ring="Stikini Ring +1",
		back={ name="Intarabus's Cape", augments={'CHR+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','"Fast Cast"+10','Phys. dmg. taken-10%',}},
	}

	sets.Midcast.Enfeebling.MACC = {}
	sets.Midcast.Enfeebling.Potency = {}
	sets.Midcast.Enfeebling.Duration = {}

	-- Bard Specific Sets

	-- Max duration
	sets.Midcast.Lullaby = set_combine(sets.Midcast.Enfeebling, {
		range=Instrument.Honor,
		body="Fili Hongreline +3",
		legs="Inyanga Shalwar +2",
	})

	sets.Midcast.Finale = {}
	sets.Midcast.Requiem = {}
	sets.Midcast.Elegy = {}
	sets.Midcast.Prelude = {}
	sets.Midcast.Madrigal = {head="Fili Calot +3"}
    sets.Midcast.Minuet = {body="Fili Hongreline +3"}
    sets.Midcast.March = {hands="Fili Manchettes +3"}
    sets.Midcast.Ballad = {legs="Fili Rhingrave +3"}
    sets.Midcast.Scherzo = {feet="Fili Cothurnes +3"}
    sets.Midcast.Mazurka = {}
    sets.Midcast.Paeon = {head="Brioso Roundlet +4"}
    sets.Midcast.Threnody = {body="Mou. Manteel +1"}
    sets.Midcast.Minne = {legs="Mou. Seraweels +1"}
    sets.Midcast.Mambo = {}
    sets.Midcast.Carol = {hands="Mousai Gages +1"}
    sets.Midcast.Etude = {head="Mousai Turban +1"}
	sets.Midcast.Dirge = {}
	sets.Midcast.Sirvente = {}
	sets.Midcast.Aria = {}

	-- Specific gear for spells
	sets.Midcast["Stoneskin"] = {
		waist="Siegel Sash",
	}

	-- Job Abilities
	sets.JA = {}
	sets.JA["Nightingale"] = {feet={ name="Bihu Slippers +4", augments={'Enhances "Nightingale" effect',}}}
	sets.JA["Troubadour"] = {body={ name="Bihu Just. +4", augments={'Enhances "Troubadour" effect',}},}
	sets.JA["Soul Voice"] = {legs={ name="Bihu Cannions +4", augments={'Enhances "Soul Voice" effect',}}}
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
		legs="Dashing Subligar", -- 10
		back={ name="Intarabus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Waltz" potency +10%','Mag. Evasion+15',}}, --10
	}) -- 24% Potency

	--Default WS set base
	sets.WS = {
		range=Instrument.WS,
		head="Nyame Helm",
		body="Bihu Just. +4",
		hands="Nyame Gauntlets",
		legs="Nyame Flanchard",
		feet="Nyame Sollerets",
		neck="Rep. Plat. Medal",
		waist="Sailfi Belt +1",
		left_ear="Moonshade Earring",
		right_ear="Regal Earring",
		left_ring="Sroda Ring",
		right_ring="Epaminondas's Ring",
		back={ name="Intarabus's Cape", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Damage taken-5%',}},
	}

	-- Equipment to augment the Melee WS for Physical Damage Limit (Capped Attack)
	sets.WS.PDL = set_combine(sets.WS, {
		body="Bunzi's Robe",
		right_ring="Sroda Ring",
	})

	--The following sets augment the WS base set
	sets.WS.WSD = set_combine(sets.WS, {
		
	})

	sets.WS.MAB = set_combine(sets.WS, {
		range=Instrument.MAB,
		neck="Sibyl Scarf",
		waist="Orpheus's Sash",
		body="Nyame Mail",
		left_ring="Metamor. Ring +1",
		back={ name="Intarabus's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','Weapon skill damage +10%','Damage taken-5%',}},
	})

	sets.WS.ACC = set_combine(sets.WS, {})

	sets.WS.MEVA = set_combine(sets.WS, {
	    neck="Warder's Charm +1",
		waist="Carrier's Sash",
	})

	sets.WS.CRIT = set_combine(sets.WS, {
		neck="Fotia Gorget",
		waist="Fotia Belt",
		right_ear={ name="Moonshade Earring", augments={'Accuracy+4','TP Bonus +250',}},
		left_ring="Hetairoi Ring",
		right_ring="Ilabrat Ring",
		back={ name="Intarabus's Cape", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Damage taken-5%',}},
	})

	sets.WS.SB = {
		left_ring={ name="Chirich Ring +1", bag="wardrobe", priority=1},
		right_ring={ name="Chirich Ring +1", bag="wardrobe2", priority=2},
	}

	sets.WS["Savage Blade"] =  set_combine(sets.WS.WSD, { })

	sets.WS["Mordant Rime"] = set_combine(sets.WS, {
		range=Instrument.Mordant,
		neck={ name="Bard's Charm +2", augments={'Path: A',}},
		waist="Grunfeld Rope",
		left_ear="Ishvara Earring",
		left_ring="Metamor. Ring +1",
		back={ name="Intarabus's Cape", augments={'CHR+20','Accuracy+20 Attack+20','CHR+10','Weapon skill damage +10%','Damage taken-5%',}},
	})

	sets.WS["Eviceration"] = sets.WS.CRIT

	sets.WS["Aeolian Edge"] = set_combine(sets.WS.MAB, {
	})

	sets.WS["Burning Blade"] = sets.WS.MAB
	sets.WS["Shining Blade"] = set_combine( sets.WS.MAB, {
		right_ring="Weather. Ring",
	})
	sets.WS["Shining Strike"] = set_combine( sets.WS.MAB, {
		right_ring="Weather. Ring",
	})

	sets.WS["Shell Crusher"] = set_combine( sets.WS.WSD, {
		right_ring="Sroda Ring",
	})

	sets.TreasureHunter = {
		body="Volte Jupon",
		legs="Volte Hose",
		waist="Chaac Belt",
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
	buff = 'None'
	--local sp_recasts = windower.ffxi.get_spell_recasts()
	return buff
end

function check_buff_JA()
	buff = 'None'
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
