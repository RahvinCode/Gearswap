-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: Puppetmaster. A sample to copy into your character's folder and fill in.
--
-- How this file is laid out. The lines above get_sets() are your options: the offense, weapon and
-- job modes you cycle through in game, and the lockstyle and macro book the file sets when it
-- loads. get_sets() holds your gear sets, one section for each kind: weapons, idle, engaged
-- (sets.OffenseMode), precast, midcast, pet gear, job abilities and weaponskills. The comment above
-- each set says when it is worn and what it is merged over. A set named for a mode, a spell, an
-- ability or a buff is merged over the set it sits under, and any slot it leaves empty keeps the
-- gear from underneath. Gear comes from the gear library as gear.<name>, or by its item name in
-- quotes.
--
-- How to change it. Fill in the sets you use and leave the rest empty. An empty set is just a
-- placeholder. The engine tells you in chat when the set it picks for a spell's or a ranged
-- attack's midcast, or for an ability, weaponskill, item or pet move, is empty. It does not name
-- an empty precast set for a spell, or an empty idle or engaged set. gs c checksets shows how
-- many sets have gear and lists the empty ones, and gs c gearreporting shows which sets each
-- action used. Below the DO NOT EDIT line are the hooks for job-specific rules. The comment above
-- each hook says when it runs, and any table a hook returns is merged over the engine's gear.
--
-- A job file written for Mirdain-Include still loads once its include line is replaced by the two
-- lines at the top of this file (see Upgrading from Mirdain-Include in the README). Its job logic
-- lives in these same hooks, and whatever a hook returns is merged over the engine's sets, so any
-- slot it fills overrides the engine's buff, burst and mode sets. Only the gear the engine keeps for
-- the action goes on after it: Daybreak for Dispelga, the Impact cloak, a song's instrument, Yagrush
-- for a White Mage's Cursna, the item a Tomahawk or Angon throws, and the weapons a weaponskill keeps
-- in hand. It is best to convert an old file to this layout and move that logic into sets, so the
-- engine can layer each set where it belongs.

-- The lockstyle set, macro book and macro set that jobsetup applies at load.
LockStylePallet = "19"
MacroBook = "19"
MacroSet = "1"

-- When true, the engine uses a Remedy on paralysis or silence and a Holy Water on Doom.
AutoItem = false

-- The item that "gs c food" uses.
Food = "Sublime Sushi"

-- When true, each load picks a lockstyle set from Lockstyle_List instead of LockStylePallet.
Random_Lockstyle = false

-- The lockstyle sets Random_Lockstyle picks from.
Lockstyle_List = {1,2,6,12}

-- The offense modes this job cycles through, instead of the engine's default TP, ACC and DT. Each
-- mode needs a sets.OffenseMode.<Mode> and a sets.Idle.<Mode> below, and can also have a
-- sets.WS.<Mode>.
state.OffenseMode:options('TP','ACC','DT','PDT','SB','MEVA')

-- The offense mode selected at load.
state.OffenseMode:set('DT')

-- Weapon modes. Each one needs a sets.Weapons['<Mode>'] of the same name below.
state.WeaponMode:options('God Hands','Pole','Club')
state.WeaponMode:set('God Hands')

-- The weapon lock, and the one to start in. Unlocked lets any set change your weapons. Locked keeps
-- the pair your weapon mode names, and the TP on it, through every action, except where the engine
-- itself must put on a weapon: one a spell needs, sets.Weapons.Sleep while you are asleep, and a
-- Spell Received set.
state.WeaponLock:options('Unlocked','Locked')
state.WeaponLock:set('Unlocked')

-- The buff level, and the one to start in. Only weaponskills read it: at HighBuff they wear their
-- HighBuff children, and at MidBuff only a weaponskill's own MidBuff child.
state.BuffLevel:options('MidBuff','HighBuff')
state.BuffLevel:set('MidBuff')

-- The Pet WS mode, the first job mode (Ctrl+F12): when sets.Pet_WS, the automaton's weaponskill
-- set, goes on from its TP. Idle wears it only while you idle, Always while you idle or fight, and
-- Off never, as during Overdrive. Worn while you fight, a weapon in the set takes your own TP each
-- time it swaps.
UI_Name = 'Pet WS'
UI_Short = 'PWS'
state.JobMode:options('Idle','Always','Off')
state.JobMode:set('Idle')

-- The automaton's TP from which sets.Pet_WS is worn, until its weaponskill spends the TP. 600
-- leaves time for the swap even for an automaton that gains TP quickly. Raise it if the set stays
-- on longer than you want.
PetWSThreshold = 600

-- The pet mode, the second job mode (Ctrl+F11). Under Auto, Pet_Modes below gives the role of the
-- automaton you activate, and a role you pick by hand holds on every automaton until you cycle back
-- to Auto. The role names a child of sets.Idle.Pet and of sets.Idle.Pet.Engaged, and, while the
-- automaton is out, of your offense mode's set.
UI_Name2 = 'Pet Mode'
state.JobMode2:options('Auto','Tank','Melee','Ranged','Heal','Nuke','Magic')
state.JobMode2:set('Auto')

-- The role Auto gives each automaton. An attachment listed under Attachments decides first, so
-- Strobe, Strobe II or Flashbulb fitted makes a tank whatever the frame and head. Then the frame,
-- then the head, for the builds players use. Any other build has no role and wears the pet sets
-- alone.
Pet_Modes = {
	Attachments = { ['Strobe'] = 'Tank', ['Strobe II'] = 'Tank', ['Flashbulb'] = 'Tank' },
	['Valoredge Frame'] = {
		['Valoredge Head'] = 'Melee', ['Soulsoother Head'] = 'Tank', ['Harlequin Head'] = 'Melee',
		['Sharpshot Head'] = 'Melee',
	},
	['Sharpshot Frame'] = { ['Valoredge Head'] = 'Melee', ['Sharpshot Head'] = 'Ranged' },
	['Stormwaker Frame'] = {
		['Soulsoother Head'] = 'Heal', ['Spiritreaver Head'] = 'Nuke', ['Stormwaker Head'] = 'Magic',
	},
	['Harlequin Frame'] = { ['Soulsoother Head'] = 'Tank', ['Valoredge Head'] = 'Tank' },
}

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	-- Weapon sets, one per weapon mode above.
	sets.Weapons = {}

	sets.Weapons['God Hands'] = {
		main = gear.godhands,
		range = gear.neoAnimator,
		ammo = gear.automatonOilPlusThree,
	}

	sets.Weapons['Club'] = {}

	sets.Weapons['Pole'] = {}

	-- Worn in the offhand whenever the main is a one-handed weapon other than hand-to-hand, such as a
	-- club, and no dual-wield trait is active, engaged or idle.
	sets.Weapons.Shield = {}

	-- ===================================================================================================================
	--		sets.Idle
	-- ===================================================================================================================

	-- Worn while idle. Every action's precast and midcast also start from this set, except a pet
	-- command's, so any slot their sets leave empty keeps your idle gear. A pet command, such as
	-- Deploy, starts from the idle or engaged set you have on.
	sets.Idle = {
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.loricatePlusOne,
		waist = gear.carriers,
		left_ear = gear.etiolation,
		right_ear = gear.odnowaPlusOne,
		left_ring = gear.regalRing,
		right_ring = gear.gelatinousPlusOne,
		back = gear.pupDA,
	}

	-- Merged over sets.Idle while idle in the matching offense mode. sets.Idle.Resting is merged
	-- over them while resting.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.Resting = {}
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
	})

	-- Worn over the idle set while a Phantom Roll on you stands at 11. It is for the Roller's
	-- Ring, which any job can wear and which gives Refresh +1 and Regain +10 at an 11, for example
	-- left_ring="Roller's Ring". It applies in every offense mode. It is worn only while idle, so
	-- any action swaps it out and it comes back when the action ends. While moving, a ring here
	-- replaces the movement set's ring in the same slot. This file's sets.Movement has no ring, so
	-- either slot works.
	sets.Idle.XIRoll = {}

	-- The TP-mode form, merged after sets.Idle.XIRoll while idle in TP mode.
	sets.Idle.TP.XIRoll = {}

	-- Worn over the idle set while moving and not engaged.
	sets.Movement = {
		feet = gear.hermesSandals,
	}

	-- Worn when another character on this machine, running this engine, casts on you. Spell
	-- Received mode must be ON. sets.Cursna_Received is also the Doom set, worn when that mode is
	-- OFF.
	sets.Cure_Received = {}
	sets.Cursna_Received = {
		neck = gear.nicander,
		left_ring = gear.eshmun1,
		right_ring = gear.eshmun2,
		waist = gear.gishdubar,
	}
	sets.Phalanx_Received = {}
	sets.Protect_Shell_Received = {}
	sets.Regen_Received = {}
	sets.Refresh_Received = {}
	sets.Waltz_Received = {}

	-- The ring slot Zodiac Ring goes in when a spell's element matches the day: "right_ring" or
	-- "left_ring".
	Elemental_Bonus_Ring_Slot = "right_ring"

	-- Worn while using a Holy Water or Hallowed Water.
	sets.Holy_Water = {
		neck = gear.nicander,
	}

	-- ===================================================================================================================
	--		sets.OffenseMode
	-- ===================================================================================================================

	-- The engaged base, merged first in every offense mode. The mode's own set is merged over it.
	sets.OffenseMode = {
		head = gear.mpacaHead,
		body = gear.mpacaBody,
		hands = gear.mpacaHands,
		legs = gear.mpacaLegs,
		feet = gear.mpacaFeet,
		neck = gear.combatantTorque,
		waist = gear.moonbowBeltPlusOne,
		left_ear = gear.macheEarringPlusOne,
		right_ear = gear.karagozEarringPlusOneSTP,
		left_ring = gear.gereRing,
		right_ring = gear.niqmaddu,
		back = gear.pupDA,
	}

	sets.OffenseMode.TP = set_combine(sets.OffenseMode,{ })

	-- Merged over the TP set while you are engaged with your automaton out and its role is Melee:
	-- the child named for your pet mode. Add one for each role and offense mode you use. Shulmanu
	-- Collar adds accuracy, attack and double attack for you and your automaton.
	sets.OffenseMode.TP.Melee = {
		neck = gear.shulmanuCollar,
	}
	sets.OffenseMode.DT = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.PDT = set_combine(sets.OffenseMode, { })
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode.TP,{
		neck = gear.warderCharmPlusOne,
	})

	-- SB mode. It lists its own pieces rather than building on another mode's set.
	-- Cap is 75% - 50% in either I or II
	sets.OffenseMode.SB =
	{
		-- Belt SB II 15%
		-- Mpaca Legs SB II 5%
		-- Ring SB II 5%
		-- Earring SB I 6%
		head = gear.volteTiara, -- 6%
		body = gear.malignanceBody,
		hands = gear.volteMittens, -- 6%
		legs = gear.mpacaLegs, -- 5%
		feet = gear.volteSpats, -- 6%
		waist = gear.moonbowBeltPlusOne, -- 15%
		left_ear = gear.macheEarringPlusOne,
		right_ear = gear.karagozEarringPlusOne, -- 6%
		left_ring = gear.chirichRingPlusOne, -- 10%
		right_ring = gear.niqmaddu, -- 5%
		back = gear.pupDA,
	}

	-- Aftermath sets, merged over the engaged set while the matching Aftermath is up. The engine
	-- uses the strongest active tier that has gear for the current weapon. A tier set applies with
	-- any weapon, and a child named for a weapon mode adds gear for that weapon only, such as the
	-- God Hands one below.
	sets.OffenseMode.AM1 = {}
	sets.OffenseMode.AM2 = {}
	sets.OffenseMode.AM3 = {}
	sets.OffenseMode.AM3['God Hands'] = {}

	-- Treasure Hunter gear. While TH Mode is Tag or Full Time, it is worn for an action aimed at an
	-- untagged monster and while engaged on one. Full Time also keeps it on whenever engaged. TH
	-- Mode starts at None, which never wears it, on every job but Thief.
	sets.TreasureHunter = {

	}

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Every precast starts from sets.Idle, except a pet command's. For a spell, sets.Precast is
	-- merged over it, then the fast cast set. Any slot left empty keeps your idle gear.
	sets.Precast = {}

	-- Fast cast gear, worn at the start of every spell.
	sets.Precast.FastCast = {}

	-- Merged over the fast cast set when you cast Utsusemi.
	sets.Precast.Utsusemi = {}

	-- Enmity gear for Provoke. sets.JA["Provoke"] below points to this same set. The engine does
	-- not automatically merge this set into any others.
	sets.Enmity = {}

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- The base for every cast, merged over sets.Idle on every midcast, so any slot it leaves empty
	-- keeps your idle gear.
	sets.Midcast = set_combine(sets.Idle, {})

	-- Spell interruption rate down. Used under every midcast except ranged attacks, so any more
	-- specific set overrides it.
	sets.Midcast.SIRD = {}

	-- ===================================================================================================================
	--		Pet gear, by when the game reads it
	-- ===================================================================================================================

	-- Gear read at your command. Worn from your pet command until it completes, merged over your
	-- idle or engaged set. The game checks delay and recast gear at the command, and the rest comes
	-- off before your pet acts, so gear for the move itself goes in the sets worn during your pet's
	-- move. None of your commands makes the automaton act, and the game checks your attribute and
	-- maneuver gear at a maneuver. Every maneuver uses sets.Pet_Command.Maneuver, and a set named
	-- for one maneuver, such as sets.Pet_Command['Fire Maneuver'], is merged over it. Deploy,
	-- Deactivate and Retrieve check no gear.
	sets.Pet_Command.Maneuver = {}

	-- Gear read during your pet's move. Worn from the moment your pet readies a move until it
	-- finishes, merged over the idle or engaged set you have on. This is when the game checks the
	-- move's damage, accuracy and potency gear. The automaton picks its weaponskill before GearSwap
	-- can see it, so weaponskill gear goes in sets.Pet_WS, which is worn based on the automaton's
	-- TP. A nuke lands too soon for gear put on when it starts casting, so nuke gear goes in the
	-- sets worn while it fights. Its other spells, such as its cures, get their gear here when they
	-- start casting: sets.Pet_Midcast for each of them, with a set named for the spell merged over
	-- it.
	sets.Pet_Midcast = {}

	-- Worn as the Pet WS mode allows while the automaton's TP is at or over PetWSThreshold, until
	-- its weaponskill spends the TP. A child named for the frame, such as sets.Pet_WS['Valoredge
	-- Frame'], merges over it, then its child named for your offense mode.
	sets.Pet_WS = {}
	sets.Pet_WS['Valoredge Frame'] = {}

	-- Merged over sets.Pet_WS while the Sharpshot, Harlequin or Stormwaker frame is attached, the
	-- same way the Valoredge set works with that frame.
	sets.Pet_WS['Sharpshot Frame'] = {}
	sets.Pet_WS['Harlequin Frame'] = {}
	sets.Pet_WS['Stormwaker Frame'] = {}

	-- Merged over sets.Pet_WS and its frame's set in ACC mode, for automaton accuracy gear.
	sets.Pet_WS.ACC = {}

	-- Gear read while your pet is out. While you are idle with a pet out, sets.Idle.Pet is merged
	-- over your idle set and its offense mode set, then its own child set for your offense mode. It
	-- only needs the slots it changes, and the rest of your offense mode's idle gear stays on
	-- underneath. Its child set for the automaton's role is merged last. The automaton's level and
	-- attributes follow the gear you wear at every moment, so its level gear belongs in every set.
	sets.Idle.Pet = {}

	-- Gear read while your pet fights. While your pet fights and you are idle,
	-- sets.Idle.Pet.Engaged is merged over sets.Idle.Pet, then its child set for your offense mode.
	-- When you fight too, your offense mode's sets hold the pet gear, so add an offense mode for
	-- fighting alongside your pet. Never name a mode Pet, since sets.Idle.Pet would then be used as
	-- that mode's idle set. Each set's child set for the automaton's role is merged last, and while
	-- you fight with it out, so is your offense mode's, such as sets.OffenseMode.TP.Melee. Gear for
	-- the automaton's nukes goes here, worn the whole time.
	sets.Idle.Pet.Engaged = {}

	-- Merged over sets.Idle.Pet.Engaged while you are idle and your automaton is fighting, using
	-- the set named for its role in the pet mode: Tank, Melee, Ranged, Heal, Nuke or Magic. In
	-- Auto, Pet_Modes above works out the role from the automaton's attachments, frame and head.
	sets.Idle.Pet.Engaged.Tank = {}
	sets.Idle.Pet.Engaged.Melee = {}
	sets.Idle.Pet.Engaged.Ranged = {}
	sets.Idle.Pet.Engaged.Heal = {}
	sets.Idle.Pet.Engaged.Nuke = {}
	sets.Idle.Pet.Engaged.Magic = {}

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is merged over sets.Idle for every job ability, then the set named for
	-- the ability is merged over it. Any slot left empty keeps your idle gear.
	sets.JA = {}
	sets.JA['Overdrive'] = {}
	sets.JA['Activate'] = {}
	sets.JA['Repair'] = {}
	sets.JA['Role Reversal'] = {}
	sets.JA['Ventriloquy'] = {}
	sets.JA['Tactical Switch'] = {}
	sets.JA['Cooldown'] = {}
	sets.JA['Deus Ex Automata'] = {}
	sets.JA['Maintenance'] = {}
	sets.JA['Heady Artifice'] = {}

	sets.JA["Provoke"] = sets.Enmity

	-- Merged over sets.Idle when you use a Waltz. Waltzes do not use sets.JA.
	sets.Waltz = {}

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- Merged over sets.Idle for every weaponskill. The set named for the weaponskill is merged over
	-- it, then the offense mode's set. Any slot left empty keeps your idle gear.
	sets.WS = {
		head = gear.mpacaHead,
		body = gear.mpacaBody,
		hands = gear.mpacaHands,
		legs = gear.mpacaLegs,
		feet = gear.mpacaFeet,
		neck = gear.fotiaNeck,
		waist = gear.moonbowBeltPlusOne,
		left_ear = gear.macheEarringPlusOne,
		right_ear = gear.schere,
		left_ring = gear.regalRing,
		right_ring = gear.niqmaddu,
		back = gear.pupDA,
	}

	-- Subtle blow pieces for weaponskills in SB mode.
	sets.WS.SB = {}

	-- Worn on weaponskills in ACC mode, over the set named for the weaponskill. List only the
	-- pieces the mode changes, since every slot named here overrides the weaponskill's own set. A
	-- weaponskill with an ACC set of its own, sets.WS['<name>'].ACC, takes that instead. The other
	-- mode sets work the same way, except that sets.WS.TP is never merged.
	sets.WS.ACC = {}

	-- Merged over the weaponskill sets in MEVA mode, the same way, so the magic evasion neck stays
	-- on.
	sets.WS.MEVA = {
		neck = gear.warderCharmPlusOne,
	}

	-- Merged in DT mode after the set named for the weaponskill, so its gear wins, for damage taken
	-- gear. A weaponskill with its own DT set uses that instead. Every slot here costs some of the
	-- weaponskill's damage, so uncomment it only once you fill it in.
	-- sets.WS.DT = {}

	-- Merged over every weaponskill while Buff Level (Alt+F12) is set to HighBuff, for physical
	-- damage limit gear. At MidBuff, the default, no set is used here. In any offense mode except
	-- TP, the set for that mode and level is merged after it, such as sets.WS.ACC.HighBuff in ACC
	-- mode. A weaponskill's own child sets replace these for that weaponskill, as shown at the end
	-- of this section.
	sets.WS.HighBuff = {}
	sets.WS.ACC.HighBuff = {}

	-- Aftermath sets for weaponskills, merged after the weaponskill's own sets while the matching
	-- Aftermath is up. They work as the engaged Aftermath sets do.
	sets.WS.AM1 = {}
	sets.WS.AM2 = {}
	sets.WS.AM3 = {}
	sets.WS.AM3['God Hands'] = {}

	-- Sets named for each weaponskill.
	sets.WS["Combo"] = set_combine(sets.WS,{})
	sets.WS["Shoulder Tackle"] = set_combine(sets.WS,{})
	sets.WS["One Inch Punch"] = set_combine(sets.WS,{})
	sets.WS["Backhand Blow"] = set_combine(sets.WS,{})
	sets.WS["Raging Fists"] = set_combine(sets.WS,{})
	sets.WS["Spinning Attack"] = set_combine(sets.WS,{})
	sets.WS["Howling Fist"] = set_combine(sets.WS,{})
	sets.WS["Dragon Kick"] = set_combine(sets.WS,{})
	sets.WS["Asuran Fists"] = set_combine(sets.WS,{})
	sets.WS["Tornado Kick"] = set_combine(sets.WS,{})
	sets.WS["Victory Smite"] = set_combine(sets.WS,{})
	sets.WS["Shijin Spiral"] = set_combine(sets.WS,{})

	-- Child sets for a single weaponskill, used instead of the general sets.WS ones: one for a
	-- mode, one for HighBuff, and one for the two together. Once declared, each one replaces the
	-- general set for that weaponskill even if it is empty, so only uncomment a line after you fill
	-- it in. The mode and HighBuff line also needs the mode line above it.
	-- sets.WS["Victory Smite"].ACC = {}
	-- sets.WS["Victory Smite"].HighBuff = {}
	-- sets.WS["Victory Smite"].ACC.HighBuff = {}

end

-------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE UNLESS YOU NEED TO MAKE JOB SPECIFIC RULES
-------------------------------------------------------------------------------------------------------------------

-- Called when the subjob changes.
function sub_job_change_custom(new, old)
	-- Typically used to change the macro book or set.
end

-- Called before each action, after the engine's own checks. Call cancel_spell() here to stop the
-- action.
function pretarget_custom(spell,action)

end

-- Called as each action starts. The table it returns is merged over the engine's precast set.
function precast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called while each action is in progress. The table it returns is merged over the engine's midcast
-- set, which is empty for abilities, weaponskills and items.
function midcast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called when each action ends. The table it returns is merged over the idle or engaged set the
-- engine rebuilds.
function aftercast_custom(spell)
	local equipSet = {}

	return choose_gear()
end

-- Called when a buff is gained or lost. The table it returns is merged over the rebuilt idle or
-- engaged set. If one of your own actions is still in progress, it is still called right away, but
-- the table it returns is not used, and the gear change happens when that action ends.
function buff_change_custom(name,gain)
	local equipSet = {}

	return choose_gear()
end

-- Called whenever the engine rebuilds the idle or engaged set, which it does after each action, on
-- a buff or status change, and when movement starts or stops. The table it returns is merged over
-- that set.
function choose_set_custom()
	local equipSet = {}

	return choose_gear()
end

-- Called when the player's status changes, such as engaging, disengaging or resting. The table it
-- returns is merged over the rebuilt idle or engaged set. If one of your own actions is still in
-- progress, the table is not used, and the gear change happens when that action ends.
function status_change_custom(new,old)
	local equipSet = {}

	return choose_gear()
end

-- Called with any "gs c" command the engine does not handle itself, in lowercase. Use it to add
-- your own commands. The Weapon Mode, Job Mode and Job Mode 2 commands also call it, before they
-- change your gear.
function self_command_custom(command)

end

-- Called when the job file unloads, after the engine releases its keybinds and slot holds.
function user_file_unload()

end

-- Called when a pet is summoned or lost. The table it returns is merged over the rebuilt idle or
-- engaged set. If one of your own actions is still in progress, it is still called, but the table
-- it returns is not used, and the gear change happens when that action ends.
function pet_change_custom(pet,gain)
	local equipSet = {}

	return equipSet
end

-- Called when a pet's action ends. The table it returns is merged over the idle or engaged set the
-- engine rebuilds. If one of your own actions is still in progress, it is still called, but the
-- table it returns is not used, and the gear change happens when that action ends.
function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called while your pet's action is in progress. The table it returns is merged over the pet's
-- midcast sets.
function pet_midcast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Shared by the aftercast, buff change, rebuild and status change hooks above, so a rule placed
-- here applies to all four.
function choose_gear()
	local equipSet = {}

	return equipSet
end
