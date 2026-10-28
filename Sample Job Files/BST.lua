-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: Beastmaster. A sample to copy into your character's folder and fill in.
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

-- The in-game lockstyle set, macro book and macro set this file applies on load.
LockStylePallet = "19"
MacroBook = "19"
MacroSet = "1"

-- Use a Remedy for paralysis or silence, and a Holy Water for doom, automatically.
AutoItem = false

-- The food "gs c food" uses.
Food = "Sublime Sushi"

-- Pick a random lockstyle from Lockstyle_List each time the file loads, instead of LockStylePallet.
Random_Lockstyle = false

-- The lockstyle sets the random pick chooses from.
Lockstyle_List = {1,2,6,12}

-- Offense modes. TP, ACC and DT are the engine's defaults, and more can be added. Each mode picks
-- its own engaged, idle and weaponskill sets, so each one offered needs a sets.OffenseMode.<Mode>
-- and a sets.Idle.<Mode> below.
state.OffenseMode:options('TP','ACC','DT','SB','MEVA')

-- The offense mode the file starts in.
state.OffenseMode:set('DT')

-- Weapon modes. Each name needs a matching sets.Weapons entry.
state.WeaponMode:options('Decimation','Pangu')
state.WeaponMode:set('Decimation')

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

-- Naming JobMode shows it in chat and on the status box.
UI_Name = 'Pet'

-- Job mode picks the jug pet. Call Beast and Bestial Loyalty equip the sets.Jugs entry the current
-- job mode names. None's entry is empty, so neither equips a jug, and Call Beast needs one in your
-- ammo slot: pick None only when you do not call jug pets.
state.JobMode:options('None','FatsoFargann','ScissorlegXerin','GenerousArthur','BlackbeardRandy','FluffyBredo')
state.JobMode:set('FatsoFargann')

-- The pet mode, the second job mode (Ctrl+F11): your pet's role, Tank or DD, picked by hand for the
-- fight, since the same jug or charmed pet can do either. It holds on every pet until you change
-- it, and names a child of sets.Idle.Pet and of sets.Idle.Pet.Engaged, and, while a pet is out, of
-- your offense mode's set.
UI_Name2 = 'Pet Mode'
state.JobMode2:options('Tank','DD')
state.JobMode2:set('Tank')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	-- Weapon sets, one per weapon mode.
	sets.Weapons = {}

	sets.Weapons['Decimation'] = {
		main = gear.dolichenus,
		sub = gear.ikengaAxe,
	}

	sets.Weapons['Pangu'] = {
		main = gear.pangu,
		sub = gear.ikengaAxe,
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons['Shield'] = {}
	-- Merged over the idle set when you are put to sleep. The slots it names stay locked until you
	-- wake up. Put gear here that wakes you, such as a piece that drains HP.
	sets.Weapons['Sleep'] = {}

	-- ===================================================================================================================
	--		sets.Idle
	-- ===================================================================================================================

	-- Worn whenever you are not engaged. Every action except a pet command also starts from this
	-- set, so any slot an action's sets leave empty keeps your idle gear. A pet command, such as
	-- Fight or a Ready move, starts from the idle or engaged set you have on.
	sets.Idle = {
		ammo = gear.staunchPlusOne,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
		left_ear = gear.etiolation,
		right_ear = gear.odnowaPlusOne,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.bstSTP,
	}

	-- Idle sets for each offense mode, merged over the idle set, and Resting, merged over them
	-- while you rest.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {})
	sets.Idle.Resting = {}

	-- Merged over the idle set while you have a Phantom Roll of 11. It is meant for Roller's Ring,
	-- which every job can wear and which gives Refresh +1 and Regain +10 on an 11, e.g.
	-- left_ring="Roller's Ring". This set applies in every offense mode. The TP set below applies
	-- only in TP mode and is merged after it. It is only worn while idle, so any action swaps it
	-- out, and it comes back when the action ends. While you move, a ring here replaces a movement
	-- ring in the same slot. This file's sets.Movement has no ring, so either slot works.
	sets.Idle.XIRoll = {}
	-- The TP mode version, merged after the one above.
	sets.Idle.TP.XIRoll = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = {
		--feet="Hermes' Sandals",
	}

	-- Worn when another character on this machine, running this engine, starts one of these spells,
	-- or a waltz, on you, while Spell Received mode is ON. sets.Cursna_Received is also the Doom set,
	-- worn and held while you are doomed with that mode OFF.
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

	-- The ring slot Zodiac Ring goes in when an elemental spell matches the day's element:
	-- "right_ring" or "left_ring".
	Elemental_Bonus_Ring_Slot = "right_ring"

	-- Worn when you use a Holy Water or Hallowed Water.
	sets.Holy_Water = {
		neck = gear.nicander,
	}

	-- ===================================================================================================================
	--		sets.OffenseMode
	-- ===================================================================================================================

	-- Engaged sets. sets.OffenseMode is worn in every offense mode, and the current mode's set
	-- merges over it.
	sets.OffenseMode = {
		ammo = gear.coiste,
		head = gear.malignanceHead,
		body = gear.gletiBody,
		hands = gear.malignanceHands,
		legs = gear.gletiLegs,
		feet = gear.malignanceFeet,
		neck = gear.anu,
		waist = gear.sailfi,
		left_ear = gear.crepuscularEar,
		right_ear = gear.sherida,
		left_ring = gear.gereRing,
		right_ring = gear.eponas,
		back = gear.nullShawl,
	}

	sets.OffenseMode.TP = set_combine (sets.OffenseMode, {})

	-- Merged over the TP set while you are engaged with a pet out: the child named for your pet
	-- mode. Add the same under each offense mode you use. Tank wears Gleti's Gauntlets for your
	-- pet's tanking, and DD an Incarnation Sash for its damage.
	sets.OffenseMode.TP.Tank = {
		hands = gear.gletiHands,
	}
	sets.OffenseMode.TP.DD = {
		waist = gear.incarnationSash,
	}

	sets.OffenseMode.DT = set_combine(sets.OffenseMode, {
		body = gear.malignanceBody,
		legs = gear.malignanceLegs,
		left_ring = gear.moonlightRing1,
		right_ring = gear.moonlightRing2,
		back = gear.bstSTP,
	})

	sets.OffenseMode.ACC = set_combine(sets.OffenseMode, {})

	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, {
		neck = gear.warderCharmPlusOne,
	})

	-- Cap is 75% - 50% limit in I or II
	sets.OffenseMode.SB = {}

	-- Aftermath sets, merged over the engaged set while the matching Aftermath is up. The engine
	-- uses the strongest active tier that has gear for the current weapon. A tier set applies with
	-- any weapon, and a child named for a weapon mode adds gear for that weapon only, such as
	-- sets.OffenseMode.AM3['Aymur'] once an 'Aymur' weapon mode is offered above.
	sets.OffenseMode.AM1 = {}
	sets.OffenseMode.AM2 = {}
	sets.OffenseMode.AM3 = {}
	-- sets.OffenseMode.AM3['Aymur'] = {}

	-- Merged over the engaged set while the Dual Wield trait is active and the main weapon is
	-- one-handed. A two-handed or hand-to-hand main skips it.
	sets.DualWield = {
		left_ear = gear.eabani,
		waist = gear.reiki,
	}

	-- Treasure Hunter gear, worn on an action or melee swing against a monster not yet tagged, and
	-- throughout a fight in Full Time mode. It is never worn in None mode, where every job but
	-- Thief starts.
	sets.TreasureHunter = {

	}

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Every precast starts from sets.Idle, except a pet command's. For a spell, sets.Precast is
	-- merged over it, then the fast cast set. Any slot left empty keeps your idle gear.
	sets.Precast = {}

	-- Fast cast, worn at the start of every spell.
	sets.Precast.FastCast = {}

	-- Merged over the fast cast set when you cast Utsusemi.
	sets.Precast.Utsusemi = {}

	-- Enmity gear, for Provoke under /WAR and for Vallation, Valiance, Pflug, Flash and Foil under
	-- /RUN. sets.JA["Provoke"] and the three ward sets below point to this same set, and the Flash
	-- and Foil sets below start from it. The engine does not automatically merge this set into any
	-- others.
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

	-- Flash and Foil under /RUN. Without a set of its own, Flash takes sets.Midcast.Divine and Foil
	-- takes sets.Midcast.Enhancing. Once declared, a spell's own set replaces that family set even
	-- if it is empty, so uncomment these after you fill in sets.Enmity.
	-- sets.Midcast["Flash"] = set_combine(sets.Enmity, {})
	-- sets.Midcast["Foil"] = set_combine(sets.Enmity, {})

	-- ===================================================================================================================
	--		Pet gear, by when the game reads it
	-- ===================================================================================================================

	-- Gear read at your command. Worn from your pet command until it completes, merged over your
	-- idle or engaged set. The game checks delay and recast gear at the command, and the rest comes
	-- off before your pet acts, so gear for the move itself goes in the sets worn during your pet's
	-- move. Ready and Sic share one set, as they share one recast. A child set named for a buff is
	-- merged while that buff is up, except a buff named like a pet command, such as Spur.
	sets.Pet_Command.Ready = {
		legs = gear.gletiLegs,
	}

	-- Fight, Heel, Leave, Stay, Snarl, Spur and Run Wild use your idle or engaged set, with a set
	-- named for the command merged over it if you declare one.

	-- Merged over your idle or engaged set when you use Spur, for "Spur" gear, until the command
	-- completes.
	sets.Pet_Command['Spur'] = {}

	-- Gear read during your pet's move.
	-- Worn from the moment your pet readies a move until it finishes, merged over the idle or
	-- engaged set you have on. This is when the game checks the move's damage, accuracy and
	-- potency gear. A move your pet uses under Sic is picked at random, and it gets its gear when
	-- your pet readies it, the same as a Ready move. Each set below is merged over the one above
	-- it:
	--   sets.Pet_Midcast              every pet move
	--   sets.Pet_Midcast.Ready        every move of a jug or charmed pet
	--   the move's category           Physical, Magical, Multi, Debuff, Buff, Healing or Breath,
	--                                 from the engine's Pet_Moves table
	--   the category's mode set       such as sets.Pet_Midcast.Physical.ACC, in ACC mode
	--   sets.Pet_Midcast.TPBonus      for a move whose damage depends on your pet's TP
	--   a set named for the move      such as sets.Pet_Midcast['TP Drainkiss']
	-- Only fill in the slots a set changes, so a later set never undoes what an earlier one
	-- changed.
	sets.Pet_Midcast = {
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.gletiFeet,
		neck = gear.beastmasterCollarPlusTwo,
		waist = gear.incarnationSash,
		left_ear = gear.ferineEarring,
		right_ear = gear.nukumiEarringPlusOne,
		right_ring = gear.cathPalugRing,
		back = gear.bstSTP,
	}

	-- Worn when your pet readies a physical move, such as Razor Fang, for pet attack and accuracy
	-- gear.
	sets.Pet_Midcast.Physical = {}

	-- Merged over the physical set when your pet readies a physical move in ACC mode.
	sets.Pet_Midcast.Physical.ACC = {}

	-- Magical moves, such as Fireball: pet magic attack bonus.
	sets.Pet_Midcast.Magical = {}

	-- Merged over the magical set when your pet readies a magical move in ACC mode.
	sets.Pet_Midcast.Magical.ACC = {}

	-- Debuff moves, such as Sheep Song and Infrasonics: pet magic accuracy lands them.
	sets.Pet_Midcast.Debuff = {
		ammo = gear.hesperiidae,
		left_ear = gear.crepuscularEar,
		back = gear.bstPetRegen,
	}

	-- Multi-hit moves, such as Pentapeck and Sweeping Gouge: pet double attack, since only the
	-- first hit takes Ready's accuracy bonus.
	sets.Pet_Midcast.Multi = {

	}

	-- The pet TP bonus piece, for moves whose damage depends on your pet's TP. The game adds its
	-- bonus when your pet readies the move, on top of Ready's minimum of 1000 TP, so it helps at
	-- any TP until the pet would pass 3000.
	sets.Pet_Midcast.TPBonus = {
		hands = gear.nukumiHandsPlusOne,
	}

	-- A set named for one move merges after its category and the TP bonus set, so on a slot they
	-- share, it wins.
	sets.Pet_Midcast['TP Drainkiss'] = set_combine(sets.Pet_Midcast.Debuff, { })

	-- Gear read while your pet is out. While you are idle with a pet out, sets.Idle.Pet is merged
	-- over your idle set and its offense mode set, then its own child set for your offense mode. It
	-- only needs the slots it changes, and the rest of your offense mode's idle gear stays on
	-- underneath. Its child set for your pet's role is merged last.
	sets.Idle.Pet = {
		hands = gear.gletiHands,
		feet = gear.gletiFeet,
		right_ear = gear.nukumiEarringPlusOne,
		right_ring = gear.cathPalugRing,
		back = gear.bstPetRegen,
	}

	-- Pet tanking: pet damage taken, regen and level.
	sets.Idle.Pet.Tank = {}

	-- Gear read while your pet fights. While your pet fights and you are idle,
	-- sets.Idle.Pet.Engaged is merged over sets.Idle.Pet, then its child set for your offense mode.
	-- When you fight too, your offense mode's sets hold the pet gear, so add an offense mode for
	-- fighting alongside your pet. Never name a mode Pet, since sets.Idle.Pet would then be used as
	-- that mode's idle set. Each set's child set for your pet's role is merged last, and while you
	-- fight with a pet out, so is your offense mode's, such as sets.OffenseMode.TP.DD.
	sets.Idle.Pet.Engaged = {}

	-- Pet tanking while it fights, and pet damage: pet haste, accuracy, attack and double attack.
	sets.Idle.Pet.Engaged.Tank = {}
	sets.Idle.Pet.Engaged.DD = {}

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is merged over sets.Idle for every job ability, then the set named for
	-- the ability is merged over it. Any slot left empty keeps your idle gear.
	sets.JA = {}
	sets.JA['Familiar'] = {
		legs = gear.ankusaLegsPlusThree,
	}
	sets.JA['Charm'] = {
		legs = gear.ankusaLegsPlusThree,
	}
	sets.JA['Gauge'] = {}
	sets.JA['Tame'] = {
		head = gear.totemicHeadPlusThree,
	}
	sets.JA['Reward'] = {
		head = gear.bisonWarbonnet,
		body = gear.totemicBodyPlusThree,
		legs = gear.ankusaLegsPlusThree,
		feet = gear.ankusaFeetPlusThree,
		left_ear = gear.ferineEarring,
		ammo = gear.petFoodThetaBiscuit,
	}
	sets.JA['Call Beast'] = {
		hands = gear.ankusaHandsPlusThree,
	}
	sets.JA['Feral Howl'] = {
		body = gear.ankusaBodyPlusThree,
	}
	sets.JA['Unleash'] = {}
	sets.JA['Bestial Loyalty'] = {
		hands = gear.ankusaHandsPlusThree,
	}
	sets.JA['Killer Instinct'] = {
		head = gear.ankusaHeadPlusThree,
	}

	-- Provoke under /WAR, and Vallation, Valiance and Pflug under /RUN, each worn from sets.Enmity
	-- above.
	sets.JA["Provoke"] = sets.Enmity
	sets.JA["Vallation"] = sets.Enmity
	sets.JA["Valiance"] = sets.Enmity
	sets.JA["Pflug"] = sets.Enmity

	-- The jug for each pet in the job mode list, one set per job mode. Bestial Loyalty and Call
	-- Beast merge the jug for your current job mode over their own sets.
	sets.Jugs = {}
	sets.Jugs['None'] = {}
	sets.Jugs['FatsoFargann'] = {ammo=gear.jugOfCurdledPlasmaBroth }
	sets.Jugs['FluffyBredo'] = {ammo=gear.jugOfVenomousBroth}
	sets.Jugs['GenerousArthur'] = {ammo=gear.jugOfDireBroth}
	sets.Jugs['BlackbeardRandy'] = {ammo=gear.jugOfMeatyBroth}
	sets.Jugs['ScissorlegXerin'] = {ammo=gear.jugOfSpicyBroth}

	-- Merged over sets.Idle when you use a Waltz. Waltzes do not use sets.JA.
	sets.Waltz = {}

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- Weaponskill base, merged over sets.Idle for every weaponskill. The set named for the
	-- weaponskill is merged over it. Any slot left empty keeps your idle gear.
	sets.WS = {
		ammo = gear.coiste,
		head = gear.gletiHead,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
		neck = gear.beastmasterCollarPlusTwo,
		waist = gear.sailfi,
		left_ear = gear.nukumiEarringPlusOne,
		right_ear = gear.sherida,
		left_ring = gear.gereRing,
		right_ring = gear.eponas,
		back = gear.bstDA,
	}

	-- Worn on every weaponskill while Killer Instinct is up. Killer Instinct shares your pet's
	-- killer effect, and a body that augments killer effects, such as Nukumi Gausape +3, adds half
	-- your total killer effect to the damage you deal.
	-- sets.WS['Killer Instinct'] = {}

	-- Merged over the weaponskill sets in SB mode. Subtle Blow gear goes here.
	sets.WS.SB = {}

	-- Merged in ACC mode after the set named for the weaponskill, so its gear wins. Only fill in
	-- the slots ACC mode should change. A weaponskill with its own ACC set uses that instead.
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
	-- sets.WS.AM3['Aymur'] = {}

	-- Sets named for one weaponskill, merged over sets.WS.
	sets.WS["Raging Axe"] = set_combine(sets.WS,{})
	sets.WS["Smash Axe"] = set_combine(sets.WS,{})
	sets.WS["Gale Axe"] = set_combine(sets.WS,{})
	sets.WS["Avalanche Axe"] = set_combine(sets.WS,{})
	sets.WS["Spinning Axe"] = set_combine(sets.WS,{})
	sets.WS["Rampage"] = set_combine(sets.WS,{})
	sets.WS["Calamity"] = set_combine(sets.WS,{})
	sets.WS["Mistral Axe"] = set_combine(sets.WS,{})
	sets.WS["Decimation"] = set_combine(sets.WS,{})
	sets.WS["Bora Axe"] = set_combine(sets.WS,{})

	-- Child sets for a single weaponskill, used instead of the general sets.WS ones: one for a
	-- mode, one for HighBuff, and one for the two together. Once declared, each one replaces the
	-- general set for that weaponskill even if it is empty, so only uncomment a line after you fill
	-- it in. The mode and HighBuff line also needs the mode line above it.
	-- sets.WS["Decimation"].ACC = {}
	-- sets.WS["Decimation"].HighBuff = {}
	-- sets.WS["Decimation"].ACC.HighBuff = {}

end

-------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE UNLESS YOU NEED TO MAKE JOB SPECIFIC RULES
-------------------------------------------------------------------------------------------------------------------

-- Called when the subjob changes.
function sub_job_change_custom(new, old)
	-- A common use is switching the macro book or set.
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

-- Called when a pet is summoned, dismissed or dies. The table it returns is merged over the rebuilt
-- idle or engaged set. If one of your own actions is still in progress, it is still called, but the
-- table it returns is not used, and the gear change happens when that action ends.
function pet_change_custom(pet,gain)
	local equipSet = {}

	return equipSet
end

-- Called when your pet's move finishes or is interrupted. The table it returns is merged over the
-- idle or engaged set the engine rebuilds. If one of your own actions is still in progress, it is
-- still called, but the table it returns is not used, and the gear change happens when that action
-- ends.
function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called when your pet readies a move. The table it returns is merged over the pet sets, which the
-- engine has already chosen for the move.
function pet_midcast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- A helper this file's aftercast, buff change, status change and choose_set_custom hooks all
-- return, so gear logic written here reaches every idle and engaged build.
function choose_gear()
	local equipSet = {}

	return equipSet
end
