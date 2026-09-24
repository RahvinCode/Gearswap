
-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The in-game equip set used for lockstyle, and the macro book and set to switch to on load.
LockStylePallet = "1"
MacroBook = "2"
MacroSet = "1"

-- The food item "gs c food" uses.
Food = "Grape Daifuku"

-- Use a Remedy on paralysis or silence, and a Holy Water on doom, automatically.
AutoItem = false

-- Pick a random lockstyle from Lockstyle_List each time this file loads.
Random_Lockstyle = false

-- The equip sets the random lockstyle picks from.
Lockstyle_List = {1,2,6,12}

-- The offense mode to start in. This file offers the engine's default modes, TP, ACC and DT.
state.OffenseMode:set('DT')

-- Not read by this engine.
Organizer = true

-- The weapon modes, each naming a sets.Weapons entry below, and the one to start in.
state.WeaponMode:options('Nirvana','Mpaca')
state.WeaponMode:set('Nirvana')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- One weapon set per weapon mode, keyed by the mode's name.
	sets.Weapons = {}

	sets.Weapons['Nirvana'] = {
		main=gear.nirvana,
		sub=gear.elanStrapPlusOne,
	}

	sets.Weapons['Mpaca'] = {
		main=gear.mpacaStaff,
		sub=gear.enki,
	}

	-- The blood pact hook at the end of this file wears one of these two weapon sets over each pact's set.
	sets.Weapons.Physical = {
		main=gear.nirvana,
		sub=gear.elanStrapPlusOne,
	}

	sets.Weapons.Magic = {
		main = gear.grioavolrMaccBloodPact,
		sub=gear.elanStrapPlusOne,
	}

	-- Worn in the offhand, idle or engaged, whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons.Shield = {
		sub=gear.genmeiShield,
	}

	-- Worn while idle. It is also the floor under every precast and midcast, so a slot an action's set leaves out keeps its idle piece.
	-- It names no weapon, since the weapon mode dresses the staff and the grip.
	sets.Idle = {
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

	-- Idle sets per offense mode, merged over sets.Idle in the matching mode. sets.Idle.Resting is merged while you rest.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.PDT = set_combine(sets.Idle, {})
	sets.Idle.Resting = set_combine(sets.Idle, {})

	-- Merged over the idle set while your avatar or spirit is out. Perpetuation and refresh gear goes here.
	sets.Idle.Pet = set_combine(sets.Idle, {
		waist=gear.luciditySash,
		feet = gear.apogeeFeetPlusOnePathB,
	})

	-- Worn over the idle set while a Phantom Roll on you stands at 11.
	-- It is meant for the Roller's Ring, which every job can wear and which gives Refresh +1 and Regain +10 at an 11, e.g. left_ring="Roller's Ring".
	-- This set applies in every offense mode. sets.Idle.TP.XIRoll applies in TP mode only and is merged after it.
	-- It is worn only while idle, so any action swaps it out and it comes back when the action ends.
	-- While you move, a ring named here replaces the movement set's ring in the same slot. This file's sets.Movement names no ring, so either slot is free.
	sets.Idle.XIRoll = {}
	-- The TP mode form of sets.Idle.XIRoll, merged after it.
	sets.Idle.TP.XIRoll = {}

	-- Worn over the idle set while Avatar's Favor is up, merged after sets.Idle.Pet so its slots win. Uncomment it to use it.
	-- Favor's potency depends on your summoning magic skill and the Avatar's Favor gear in your idle set, such as Beckoner's Horn.
	-- sets.Idle["Avatar's Favor"] = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = {
		feet=gear.heraldGaiters,
	}

	-- Each is worn when another character on this machine, also running this engine, starts that spell or waltz on you. Spell Received mode must be ON.
	-- sets.Cursna_Received is also the doom set. With Spell Received OFF, it is worn and held while you are doomed.
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

	-- The ring slot Zodiac Ring takes on elemental magic that matches the day's element: "right_ring" or "left_ring".
	Elemental_Bonus_Ring_Slot = "right_ring"

	-- Worn when you use a Holy Water or Hallowed Water.
	sets.Holy_Water = {
	    neck=gear.nicander,
	}

	-- Engaged sets. sets.OffenseMode is the base, and the set named for the current offense mode is merged over it.
	sets.OffenseMode = {}
	sets.OffenseMode.TP = {}
	sets.OffenseMode.ACC = {}
	sets.OffenseMode.DT = {}
	sets.OffenseMode.MEVA = {}

	sets.Precast = {}

	-- Worn at the start of every spell. Fast cast gear goes here.
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

	-- Merged over the fast cast set for cures.
	sets.Precast.Cure = set_combine(sets.Precast.FastCast, {})

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- The base for every cast. sets.Idle is merged underneath it on every midcast, so a slot this set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {
	
	})

	-- Spell interruption rate down. Merged under every midcast except a ranged attack, so any specific set overwrites it.
	sets.Midcast.SIRD = {

	}

	-- Single-target cures, Cure through Cure VI.
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
	-- Enhancing magic. Healing spells other than cures, such as Raise and the -na spells, use it too.
	sets.Midcast.Enhancing = {
		ring1=gear.stikiniRingPlusOne,
		ring2=gear.stikiniRingPlusOne,
	}
	-- Enfeebling magic, where magic accuracy decides whether the spell lands.
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

	-- Elemental magic nukes.
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

	-- Worn at the midcast of your blood pact command. Blood pact recast gear goes here. Under Astral Conduit the engine wears no set for it.
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
	-- Worn while summoning an avatar or spirit.
	sets.Midcast.Summon = set_combine(sets.Idle, {
		body=gear.baayamiBodyPlusOne
	})

	-- A set named for one spell replaces its family set for that spell, so Stoneskin skips the enhancing set. Cures are the exception and always take the Cure, Curaga or Cura set.
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		waist=gear.siegel,
		neck=gear.nodens,
	})

	-- Merged over the enhancing set for Refresh spells.
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
	-- Sets for your own hooks. The engine never reads sets.Custom, so use it from the hooks below.
	sets.Custom = {}

	-- The base for every weaponskill. A set named for the weaponskill is merged over it.
	sets.WS = {}
	-- Worn on weaponskills in ACC mode, merged after the set named for the weaponskill so its slots win. It is skipped where sets.WS['<name>'].ACC exists.
	sets.WS.ACC = {}


	-- A building block for magical weaponskills, used as the three weaponskill sets below.
	-- It names no weapon, since the engine keeps the weapons in hand through a weaponskill.
	sets.WS.MAB = {
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
	sets.WS["Garland of Bliss"] = sets.WS.MAB
	sets.WS["Shattersoul"] = sets.WS.MAB
	sets.WS["Cataclysm"] = sets.WS.MAB

	-- Pet action sets. The engine merges sets.Pet_Midcast and a set named for the pet's action.
	-- The sets below it are chosen by the blood pact hook at the end of this file.
	sets.Pet_Midcast = {}

	-- The main physical pact set, for Volt Strike, Predator Claws and the like.
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
	-- For physical pacts that gain more from TP than from pet Double Attack, such as single-hit pacts. The blood pact hook below wears it for the pacts in the engine's Physical_BPs_TP list.
	sets.Pet_Midcast.Physical_BP_TP = set_combine(sets.Pet_Midcast.Physical_BP, {
		legs=gear.enticerPants,
	})
	-- The base magic pact set.
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
	-- For the magic pacts that gain from TP, and for the merit pacts.
	sets.Pet_Midcast.Magic_BP_TP = set_combine(sets.Pet_Midcast.Magic_BP, {
		legs=gear.enticerPants
	})
	-- Flaming Crush, a hybrid pact, gets its own set. The hook pairs it with the Magic weapon set.
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
	-- Summoning magic skill gear, for Perfect Defense and the buff, healing and debuff pacts such as Hastega II.
	sets.Pet_Midcast.SummoningMagic = {
		ammo=gear.sancusSachetPlusOne,
		head=gear.baayamiHeadPlusOne,
		body=gear.baayamiBodyPlusOne,
		hands=gear.baayamiHandsPlusOne,
		legs=gear.baayamiLegs,
		feet=gear.baayamiFeetPlusOne,
		neck = gear.summonerCollarPlusTwo,
		waist=gear.luciditySash,
		left_ear=gear.cathPalugEarring,
		right_ear=gear.lugalbanda,
		left_ring=gear.stikiniRingPlusOne,
		right_ring=gear.stikiniRingPlusOne,
		back = gear.smnFC,
	}

	-- Job abilities. sets.JA is the base for every job ability, and a set named for the ability is merged over it.
	sets.JA = {}
	sets.JA["Convert"] = {}
	sets.JA["Astral Flow"] = {}
	sets.JA["Elemental Siphon"] = {}
	sets.JA["Mana Cede"] = {}
	sets.JA["Astral Conduit"] = {}
	sets.JA["Apogee"] = {}

	-- Treasure Hunter gear. In every TH mode but None, it is worn on the action that tags a monster and while engaged on an untagged one.
	-- Full Time also wears it whenever you are engaged. Every job but Thief starts in None.
	sets.TreasureHunter = {
		waist=gear.chaac,
	}
end

-------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE UNLESS YOU NEED TO MAKE JOB SPECIFIC RULES
-------------------------------------------------------------------------------------------------------------------

-- Called when the player's subjob changes.
function sub_job_change_custom(new, old)
	-- A common use is switching the macro book or set.
end

-- Called before an action's precast, after the engine's own checks. Call cancel_spell() here to stop the action.
function pretarget_custom(spell,action)

end
-- Called at precast. Gear in the returned table is worn over the engine's precast set.
function precast_custom(spell)
	local equipSet = {}

	return equipSet
end
-- Called at midcast. Gear in the returned table is worn over the engine's midcast set.
function midcast_custom(spell)
	local equipSet = {}

	return equipSet
end
-- Called when an action ends. Gear in the returned table is worn over the idle or engaged set.
function aftercast_custom(spell)
	local equipSet = {}
	-- A chat reminder after every action while an avatar is out and Avatar's Favor is down.
	if pet.isvalid and not buffactive["Avatar\'s Favor"] and spell.name ~= "Avatar\'s Favor" then
		add_to_chat(8,'Avatar\'s Favor is Down')
	end
	return equipSet
end
-- Called when you gain or lose a buff, except while your own cast is in progress. Gear in the returned table is worn over the idle or engaged set.
function buff_change_custom(name,gain)
	local equipSet = {}

	return equipSet
end
-- Called whenever the engine builds your idle or engaged set. Gear in the returned table is worn over it.
function choose_set_custom()
	local equipSet = {}

	return equipSet
end
-- Called when your status changes, such as engaging, disengaging or resting. Gear in the returned table is worn over the idle or engaged set.
function status_change_custom(new,old)
	local equipSet = {}
	return equipSet
end

-- Called when a pet is summoned or released. Gear in the returned table is worn over the idle or engaged set.
function pet_change_custom(pet,gain)
	local equipSet = {}
	-- Switches to the macro set for the avatar summoned, and back to set 1 when the avatar leaves.
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
	return equipSet
end

-- Called while a pet's action is in flight. Gear in the returned table is worn over the pet midcast sets.
-- Here it is the blood pact hook: it picks the pact's set from the lists the pact belongs to, with the Physical or Magic weapon set over it.
function pet_midcast_custom(spell)
	local equipSet = {}
		-- Blood pacts, on a summoner main job only.
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
			-- ImpactDebuff is yours to set near the top of this file. With it true, Impact and Conflag Strike are cast in the summoning magic set for their debuff.
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
			elseif Physical_BPs_TP:contains(spell.name) then
				equipSet = sets.Pet_Midcast.Physical_BP_TP
				equipSet = set_combine(equipSet, sets.Weapons.Physical)
			else
				equipSet = sets.Pet_Midcast.Physical_BP
				equipSet = set_combine(equipSet, sets.Weapons.Physical)
			end
		end
	return equipSet
end

-- Called when a pet's action ends. Gear in the returned table is worn over the idle or engaged set.
function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called for a "gs c" command the engine did not handle, and by the Weapon Mode, Job Mode and Job Mode 2 commands before their gear rebuild. The command arrives in lowercase.
function self_command_custom(command)

end
-- Called when the job file is unloaded.
function user_file_unload()

end
