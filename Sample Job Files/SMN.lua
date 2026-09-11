
-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

--Set to ingame lockstyle and Macro Book/Set
LockStylePallet = "1"
MacroBook = "2"
MacroSet = "1"

-- Use "gs c food" to use the specified food item
Food = "Grape Daifuku"

--Uses Items Automatically
AutoItem = false

--Upon Job change will use a random lockstyleset
Random_Lockstyle = false

--Lockstyle sets to randomly equip
Lockstyle_List = {1,2,6,12}

--Set default mode (TP,ACC,DT)
state.OffenseMode:set('DT')

-- Not read by this engine.
Organizer = true

--Weapons options
state.WeaponMode:options('Nirvana','Mpaca')
state.WeaponMode:set('Nirvana')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- Weapon setup
	sets.Weapons = {}

	sets.Weapons['Nirvana'] = {
		main=gear.nirvana,
		sub=gear.elanStrapPlusOne,
	}

	sets.Weapons['Mpaca'] = {
		main=gear.mpacaStaff,
		sub=gear.enki,
	}

	sets.Weapons.Physical = {
		main=gear.nirvana,
		sub=gear.elanStrapPlusOne,
	}

	sets.Weapons.Magic = {
		main = gear.grioavolrMaccBloodPact,
		sub=gear.elanStrapPlusOne,
	}

	--Worn in the offhand whenever the main is one-handed and no dual-wield trait is active, engaged or idle.
	sets.Weapons.Shield = {
		sub=gear.genmeiShield,
	}

	-- Standard Idle set with -DT, Refresh, Regen
	sets.Idle = {
		sub=gear.elanStrapPlusOne,
		ammo=gear.sancusSachetPlusOne,
		head=gear.beckonerHeadPlusOne,
		body=gear.bunziBody,
		hands = gear.bunziHands,
		legs=gear.bunziLegs,
		feet=gear.bunziFeet,
		neck = gear.summonerCollarPlusTwo,
		waist=gear.regalBelt,
		left_ear=gear.cathPalugEarring,
		right_ear=gear.beckonerEarringPlusOne,
		left_ring=gear.defending,
		right_ring=gear.cathPalugRing,
		back = gear.smnPetRegen,
    }

	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.PDT = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})

	-- Perpetuation and Refresh Set
	sets.Idle.Pet = set_combine(sets.Idle, {
		waist=gear.luciditySash,
		feet = gear.apogeeFeetPlusOnePathB,
	})

	sets.Movement = {
		feet=gear.heraldGaiters,
	}

	--Worn when another character on this machine, running this engine, casts on you; Spell Received Mode must be ON. sets.Cursna_Received is also the Doom set, worn when that mode is OFF.
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
	sets.OffenseMode.TP = {}
	sets.OffenseMode.ACC = {}
	sets.OffenseMode.DT = {}
	sets.OffenseMode.MEVA = {}

	sets.Precast = {}

	-- Used for Magic Spells
	sets.Precast.FastCast = {
		ammo=gear.sancusSachetPlusOne,
		head = gear.merlinicHoodFC,
		body=gear.inyangaBodyPlusTwo,
		hands = gear.merlinicDastanasFC,
		legs = gear.merlinicShalwarFC,
		feet = gear.merlinicCrackowsFC,
		neck=gear.voltsurge,
		waist=gear.embla,
		left_ear=gear.malignanceEar,
		right_ear=gear.etiolation,
		left_ring=gear.kishar,
		right_ring = gear.gelatinousPlusOne,
		back = gear.smnFCB,
	}

	sets.Precast.Cure = set_combine(sets.Precast.FastCast, {})

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	--The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {
	
	})

	--Spell interruption rate down. Merged under every midcast except a ranged attack, so any specific set overwrites it.
	sets.Midcast.SIRD = {

	}

	-- Cure Set
	sets.Midcast.Cure = {
		head = gear.vanyaHeadPathB,
		body = gear.bunziBody,
		hands = gear.vanyaHandsPathB,
		legs = gear.vanyaLegsPathB,
		feet = gear.vanyaFeetPathB,
		neck = gear.loricatePlusOne,
		waist=gear.platinumMoogleBelt,
		left_ear=gear.roundelEarring,
		right_ear=gear.etiolation,
		left_ring=gear.najiLoop,
		right_ring=gear.lehkoHabhokaRing,
		back = gear.smnFCB,
    }
	-- Enhancing Skill
	sets.Midcast.Enhancing = {
		ring1=gear.stikiniRingPlusOne,
		ring2=gear.stikiniRingPlusOne,
	}
	-- High MACC for landing spells
	sets.Midcast.Enfeebling = {
	    main = gear.grioavolrNukeB,
		ammo=gear.sancusSachetPlusOne,
		head = gear.amalricHeadPlusOnePathA,
		body=gear.inyangaBodyPlusTwo,
		hands = gear.amalricHandsPlusOnePathD,
		legs=gear.inyangaLegsPlusTwo,
		feet = gear.mediumSabotsCureB,
		neck=gear.sanctity,
		waist=gear.luminarySash,
		left_ear=gear.dignitary,
		right_ear=gear.hermetic,
		left_ring = gear.stikiniRingPlusOne2,
		right_ring = gear.stikiniRingPlusOne1,
		back = gear.smnFC,
	}

	sets.Midcast.Nuke = {
	    main = gear.grioavolrNukeB,
		ammo=gear.sancusSachetPlusOne,
		head = gear.amalricHeadPlusOnePathA,
		body=gear.inyangaBodyPlusTwo,
		hands = gear.amalricHandsPlusOnePathD,
		legs=gear.inyangaLegsPlusTwo,
		feet = gear.mediumSabotsCureB,
		neck=gear.sanctity,
		waist=gear.luminarySash,
		left_ear=gear.dignitary,
		right_ear=gear.hermetic,
		left_ring = gear.stikiniRingPlusOne2,
		right_ring = gear.stikiniRingPlusOne1,
		back = gear.smnFC,
	}

	-- BP Timer Gear
    sets.Midcast.BP = {
		main=gear.malignancePole,
		sub=gear.enki,
		ammo=gear.sancusSachetPlusOne,
		head=gear.beckonerHeadPlusOne,
		body=gear.convokerBodyPlusThree,
		hands = gear.merlinicDastanasNukeBloodPact,
		legs=gear.assiduityPants,
		feet = gear.apogeeFeetPlusOnePathC,
		neck = gear.summonerCollarPlusTwo,
		waist=gear.luciditySash,
		left_ear=gear.cathPalugEarring,
		right_ear=gear.andoaaEarring,
		left_ring = gear.stikiniRingPlusOne2,
		right_ring = gear.stikiniRingPlusOne1,
		back=gear.solemnityCape,
	}
	sets.Midcast.Summon = set_combine(sets.Idle, {
		body=gear.baayamiBodyPlusOne
	})

	sets.Midcast.MAB = {
		sub=gear.elanStrapPlusOne,
		ammo=gear.sancusSachetPlusOne,
		head = gear.amalricHeadPlusOnePathA,
		body=gear.inyangaBodyPlusTwo,
		hands = gear.amalricHandsPlusOnePathD,
		legs = gear.amalricLegsPlusOnePathA,
		feet = gear.amalricFeetPlusOnePathA,
		neck=gear.sanctity,
		waist=gear.eschan,
		left_ear = gear.moonshadeEarringAcc,
		right_ear=gear.friomisi,
		left_ring = gear.stikiniRingPlusOne2,
		right_ring = gear.stikiniRingPlusOne1,
		back = gear.smnFC,
	}

	-- Specific gear for spells
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		waist=gear.siegel,
		neck=gear.nodens,
	})

	sets.Midcast.Refresh = set_combine(sets.Midcast.Enhancing, {
		head=gear.amalricCoifPlusOne,
		waist=gear.gishdubar
	})

	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, {
		head=gear.amalricCoifPlusOne
	})

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================
	--Custom sets for each jobsetup. The engine never reads this set; the hooks below are where a job file uses one.
	sets.Custom = {}

	sets.WS = {}
	--Merged after the set named for the weaponskill, so its slots win. Skipped where sets.WS['<name>'].ACC exists. Never merged in TP mode.
	sets.WS.ACC = {}


	sets.WS["Garland of Bliss"] = sets.Midcast.MAB
	sets.WS["Shattersoul"] = sets.Midcast.MAB
	sets.WS["Cataclysm"] = sets.Midcast.MAB

	sets.Pet_Midcast = {}

	-- Main physical pact set (Volt Strike, Pred Claws, etc.)
	sets.Pet_Midcast.Physical_BP = {
		main=gear.nirvana,
		sub=gear.elanStrapPlusOne,
		ammo=gear.sancusSachetPlusOne,
		head = gear.apogeeHeadPlusOnePathB,
		body=gear.convokerBodyPlusThree,
		hands = gear.merlinicDastanasNukeBloodPact,
		legs = gear.apogeeLegsPlusOnePathD,
		feet = gear.apogeeFeetPlusOnePathC,
		neck = gear.summonerCollarPlusTwo,
		waist=gear.incarnationSash,
		left_ear=gear.lugalbanda,
		right_ear=gear.kyreneEarring,
		left_ring=gear.vararRingPlusOne,
		right_ring=gear.cathPalugRing,
		back = gear.smnPetRegen,
	}
	-- Physical pacts which benefit more from TP than Pet:DA (like single-hit BP)
	sets.Pet_Midcast.Physical_BP_TP = set_combine(sets.Pet_Midcast.Physical_BP, {
		legs=gear.enticerPants,
	})
	-- Base magic pact set
	sets.Pet_Midcast.Magic_BP = {
		main = gear.grioavolrNukeBloodPact,
		sub=gear.elanStrapPlusOne,
		ammo=gear.sancusSachetPlusOne,
		head=gear.cathPalugCrown,
		body=gear.convokerBodyPlusThree,
		hands = gear.merlinicDastanasNukeBloodPact,
		legs = gear.enticerPantsMaccPetMacc,
		feet = gear.apogeeFeetPlusOnePathB,
		neck = gear.summonerCollarPlusTwo,
		waist=gear.regalBelt,
		left_ear=gear.lugalbanda,
		right_ear=gear.beckonerEarringPlusOne,
		left_ring = gear.vararRingPlusOne2,
		right_ring = gear.vararRingPlusOne1,
		back = gear.smnPetRegenB,
	}
	-- Some magic pacts benefit more from TP than others.
	sets.Pet_Midcast.Magic_BP_TP = set_combine(sets.Pet_Midcast.Magic_BP, {
		legs=gear.enticerPants
	})
	-- Similar to the Magic Set except Nirvana used
	sets.Pet_Midcast.FlamingCrush = {
		main = gear.grioavolrNukeBloodPact,
		sub=gear.elanStrapPlusOne,
		ammo=gear.sancusSachetPlusOne,
		head = gear.apogeeHeadPlusOnePathB,
		body=gear.convokerBodyPlusThree,
		hands = gear.merlinicDastanasNukeBloodPact,
		legs = gear.apogeeLegsPlusOnePathD,
		feet = gear.apogeeFeetPlusOnePathC,
		neck = gear.summonerCollarPlusTwo,
		waist=gear.regalBelt,
		left_ear=gear.lugalbanda,
		right_ear=gear.kyreneEarring,
		left_ring=gear.vararRingPlusOne,
		right_ring=gear.cathPalugRing,
		back = gear.smnFCB,
	}
	-- Pure summoning magic set, mainly used for buffs like Hastega II.
	sets.Pet_Midcast.SummoningMagic = {
		ammo=gear.sancusSachetPlusOne,
		head=gear.baayamiHeadPlusOne,
		body=gear.baayamiBodyPlusOne,
		hands=gear.baayamiHandsPlusOne,
		legs=gear.baayamiLegs,
		feet=gear.baayamiFeetPlusOne,
		neck = gear.summonerCollarPlusTwo,
		waist=gear.luciditySash,
		left_ear=gear.lugalbanda,
		right_ear=gear.cathPalugEarring,
		left_ring=gear.stikiniRingPlusOne,
		right_ring=gear.stikiniRingPlusOne,
		back = gear.smnFC,
	}

	-- Job Abilities
	sets.JA = {}
	sets.JA["Convert"] = {}
	sets.JA["Astral Flow"] = {}
	sets.JA["Elemental Siphon"] = {}
	sets.JA["Mana Cede"] = {}
	sets.JA["Astral Conduit"] = {}
	sets.JA["Apogee"] = {}

	-- Worn on the action that tags a monster. The engine merges it only while TH Mode is not None, and every job but Thief starts at None.
	sets.TreasureHunter = {
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
	if pet.isvalid and not buffactive["Avatar\'s Favor"] and spell.name ~= "Avatar\'s Favor" then
		add_to_chat(8,'Avatar\'s Favor is Down')
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

function pet_change_custom(pet,gain)
	local equipSet = {}
	-- Select initial macro set and set lockstyle
	-- Change or delete this block if your macro books are laid out differently.
	if pet and gain then
		log('Macro Change ['..pet.name..']')
		if pet.name=='Fenrir' then
			send_command('input /macro book '..MacroBook..';wait .1;input /macro set 2')
		elseif pet.name=='Ifrit' then
			send_command('input /macro book '..MacroBook..';wait .1;input /macro set 3')
		elseif pet.name=='Titan' then
			send_command('input /macro book '..MacroBook..';wait .1;input /macro set 4')
		elseif pet.name=='Leviathan' then
			send_command('input /macro book '..MacroBook..';wait .1;input /macro set 5')
		elseif pet.name=='Garuda' then
			send_command('input /macro book '..MacroBook..';wait .1;input /macro set 6')
		elseif pet.name=='Shiva' then
			send_command('input /macro book '..MacroBook..';wait .1;input /macro set 7')
		elseif pet.name=='Ramuh' then
			send_command('input /macro book '..MacroBook..';wait .1;input /macro set 8')
		elseif pet.name=='Diabolos' then
			send_command('input /macro book '..MacroBook..';wait .1;input /macro set 9')
		elseif pet.name=='Cait Sith' then
			send_command('input /macro book '..MacroBook..';wait .1;input /macro set 10')
		end
	else
		log('Macro Change (No Avatar)')
		send_command('input /macro book '..MacroBook..';wait .1;input /macro set 1')
	end
	-- End macro set
	return equipSet
end

function pet_midcast_custom(spell)
	local equipSet = {}
		-- This section is for SMN Blood Pact abilities
		if player.main_job == "SMN" then
			is_Busy = true
			if spell.name == "Perfect Defense" then
				equipSet = sets.Pet_Midcast.SummoningMagic
				equipSet = set_combine(equipSet, sets.Weapons.Physical)
			elseif Debuff_BPs:contains(spell.name) then
				equipSet = sets.Pet_Midcast.SummoningMagic
				equipSet = set_combine(equipSet, sets.Weapons.Physical)
			elseif Buff_BPs_Healing:contains(spell.name) then
				equipSet = sets.Pet_Midcast.SummoningMagic
				equipSet = set_combine(equipSet, sets.Weapons.Physical)
			elseif Buff_BPs_Duration:contains(spell.name) then
				equipSet = sets.Pet_Midcast.SummoningMagic
				equipSet = set_combine(equipSet, sets.Weapons.Physical)
			elseif spell.name == "Flaming Crush" then
				equipSet = sets.Pet_Midcast.FlamingCrush
				equipSet = set_combine(equipSet, sets.Weapons.Magic)
			elseif ImpactDebuff and (spell.name=="Impact" or spell.name=="Conflag Strike") then
				equipSet = sets.Pet_Midcast.SummoningMagic
				equipSet = set_combine(equipSet, sets.Weapons.Magic)
			elseif Magic_BPs_TP:contains(spell.name) then
				equipSet = sets.Pet_Midcast.Magic_BP_TP
				equipSet = set_combine(equipSet, sets.Weapons.Magic)
			elseif Magic_BPs_NoTP:contains(spell.name) then
				equipSet = sets.Pet_Midcast.Magic_BP
				equipSet = set_combine(equipSet, sets.Weapons.Magic)
			elseif Merit_BPs:contains(spell.name) then
				equipSet = sets.Pet_Midcast.Magic_BP_TP
				equipSet = set_combine(equipSet, sets.Weapons.Magic)
			elseif Debuff_Rage_BPs:contains(spell.name) then
				equipSet = sets.Pet_Midcast.SummoningMagic
				equipSet = set_combine(equipSet, sets.Weapons.Magic)
			else
				equipSet = sets.Pet_Midcast.Physical_BP
				equipSet = set_combine(equipSet, sets.Weapons.Physical)
			end
		end
	return equipSet
end

function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

--Called for a "gs c" command the engine did not handle itself, and for the Weapon Mode, Job Mode and Job Mode 2 commands, which call it before the gear rebuild.
function self_command_custom(command)

end
-- This function is called when the job file is unloaded
function user_file_unload()

end
