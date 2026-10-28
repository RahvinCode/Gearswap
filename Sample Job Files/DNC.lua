-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: Dancer. A sample to copy into your character's folder and fill in.
--
-- How this file is laid out. The lines above get_sets() are your options: the offense, weapon and
-- job modes you cycle through in game, and the lockstyle and macro book the file sets when it
-- loads. get_sets() holds your gear sets, one section for each kind: weapons, idle, engaged
-- (sets.OffenseMode), precast, midcast, job abilities and weaponskills. The comment above each set
-- says when it is worn and what it is merged over. A set named for a mode, a spell, an ability or a
-- buff is merged over the set it sits under, and any slot it leaves empty keeps the gear from
-- underneath. Gear comes from the gear library as gear.<name>, or by its item name in quotes.
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
LockStylePallet = "16"
MacroBook = "6"
MacroSet = "1"

-- Use a Remedy for paralysis or silence, and a Holy Water for doom, automatically.
AutoItem = false

-- Pick a random lockstyle from Lockstyle_List each time the file loads, instead of LockStylePallet.
Random_Lockstyle = true

-- The lockstyle sets the random pick chooses from.
Lockstyle_List = {16,17,18}

-- The food "gs c food" uses.
Food = "Sublime Sushi"

-- Offense modes, and the one the file starts in. Each mode offered needs its own
-- sets.OffenseMode.<Mode> and sets.Idle.<Mode> below.
state.OffenseMode:options('DT','TP','SB','Farm')
state.OffenseMode:set('DT')

-- Weapon modes. Each name needs a matching sets.Weapons entry.
state.WeaponMode:options('Aeneas','Karambit')
state.WeaponMode:set('Aeneas')

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

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup (LockStylePallet,MacroBook,MacroSet)

function get_sets()

	-- ===================================================================================================================
	--		sets.Weapons
	-- ===================================================================================================================

	-- Weapon sets, one per weapon mode. A set here is worn only once its name is offered in the
	-- weapon modes above. The commented two are for modes this file does not offer: add the name
	-- to the weapon modes, then uncomment its line.
	sets.Weapons = {}
	-- sets.Weapons['Terpsichore'] = {}
	-- sets.Weapons['Twashtar'] = {}
	sets.Weapons['Aeneas'] = {main=gear.aeneas, sub=gear.gleti,}
	sets.Weapons['Karambit'] = {main=gear.karambit,}

	-- ===================================================================================================================
	--		sets.Idle
	-- ===================================================================================================================

	-- Worn whenever you are not engaged. It is empty here, so each offense mode's idle set below
	-- carries the gear.
	-- It is also the floor under every action, and an empty floor leaves unchanged any slot an
	-- action's sets do not name.
	sets.Idle = {}

	-- Idle sets for each offense mode, merged over the idle set. SB shares the DT table.
	sets.Idle.DT = {
		ammo = gear.staunchPlusOne,
		head = gear.malignanceHead,
		body = gear.malignanceBody,
		hands = gear.malignanceHands,
		legs = gear.malignanceLegs,
		feet = gear.malignanceFeet,
		neck = gear.loricatePlusOne,
		waist = gear.flumeBeltPlusOne,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.infusedEarring,
		left_ring = gear.chirichRingPlusOne,
		right_ring = gear.chirichRingPlusOne,
		back = gear.sacroMantle,}

	sets.Idle.TP = {
		ammo = gear.staunchPlusOne,
		head = gear.gletiHead,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
		neck = gear.loricatePlusOne,
		waist = gear.flumeBeltPlusOne,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.infusedEarring,
		left_ring = gear.chirichRingPlusOne,
		right_ring = gear.chirichRingPlusOne,
		back = gear.sacroMantle,}

	sets.Idle.SB = sets.Idle.DT

	sets.Idle.Farm = {
		ammo = gear.staunchPlusOne,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.unmovingPlusOne,
		waist = gear.silverMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.tuisto,
		left_ring = gear.gelatinousPlusOne,
		right_ring = gear.moonlightRing,
		back = gear.moonlightCape,}

	-- Merged over the idle set while you have a Phantom Roll of 11. It is meant for Roller's Ring,
	-- which every job can wear and which gives Refresh +1 and Regain +10 on an 11, e.g.
	-- left_ring="Roller's Ring". This set applies in every offense mode. The TP set below applies
	-- only in TP mode and is merged after it. It is only worn while idle. This file's idle base has
	-- no gear, so an action only swaps the ring out when that action's sets fill its slot, and it
	-- comes back when the action ends. While you move, a ring here replaces a movement ring in the
	-- same slot. This file's sets.Movement uses right_ring, so left_ring is the free slot.
	sets.Idle.XIRoll = {}
	-- The TP mode version, merged after the one above.
	sets.Idle.TP.XIRoll = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = {right_ring=gear.shneddickRing,}

	-- Worn when another character on this machine, running this engine, starts casting one of these
	-- spells on you, while Spell Received mode is ON. sets.Cursna_Received is also the Doom set,
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
	sets.OffenseMode = {}

	sets.OffenseMode.DT = {
		ammo = gear.yamarang,
		head = gear.malignanceHead,
		body = gear.malignanceBody,
		hands = gear.malignanceHands,
		legs = gear.malignanceLegs,
		feet = gear.malignanceFeet,
		neck = gear.anu,
		waist = gear.reiki,
		left_ear = gear.sherida,
		right_ear = gear.telos,
		left_ring = gear.moonlightRing,
		right_ring = gear.moonlightRing,
		back = gear.sacroMantle,
	}
	sets.OffenseMode.TP = {
		ammo = gear.coiste,
		head = gear.adhemarHeadPlusOnePathA,
		body = gear.adhemarBodyPlusOnePathA,
		hands = gear.adhemarHandsPlusOnePathA,
		legs = gear.samnuhaTightsDAB,
		feet = gear.malignanceFeet,
		neck = gear.anu,
		waist = gear.sailfi,
		left_ear = gear.sherida,
		right_ear = gear.telos,
		left_ring = gear.gereRing,
		right_ring = gear.eponas,
		back = gear.sacroMantle,
	}
	-- Subtle Blow Cap at 50 and II at 25 for a Total of 75.
	-- DNC Subtle Blow = 20/50 w/ Traits. Need +30 in Gear for SBI Cap.
	-- Subtle Blow I: 50/50 | Subtle Blow II:05/25 | DT:50/50 | ACC: High
	sets.OffenseMode.SB = {
		ammo = gear.yamarang,
		head = gear.malignanceHead,
		body = gear.malignanceBody,
		hands = gear.malignanceHands,
		legs = gear.malignanceLegs,
		feet = gear.malignanceFeet,
		neck = gear.anu,
		waist = gear.reiki,
		left_ear = gear.sherida, -- SBII+5
		right_ear = gear.telos,
		left_ring = gear.chirichRingPlusOne, -- SB+10
		right_ring = gear.chirichRingPlusOne, -- SB+10
		back = gear.sacroMantle, -- Ambu Cape has SB+10
	}
	sets.OffenseMode.Farm = {
		ammo = gear.staunchPlusOne,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.unmovingPlusOne,
		waist = gear.silverMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.tuisto,
		left_ring = gear.gelatinousPlusOne,
		right_ring = gear.moonlightRing,
		back = gear.moonlightCape,
	}

	-- Merged over the engaged set in ACC mode. ACC is not offered above, so the engine never reads
	-- it. To use it, add 'ACC' to the options list above, then uncomment this line.
	-- sets.OffenseMode.ACC = {}

	-- Worn over the engaged set in every offense mode while Climactic Flourish is up. Gear that
	-- enhances it, such as Maculele Tiara +3 (head), adds damage to the critical hits it forces.
	-- sets.OffenseMode['Climactic Flourish'] = {}

	-- Worn over the engaged set in every offense mode while Saber Dance is up. Gear that enhances
	-- it, such as Horos Tights +3 (legs), raises its minimum double attack rate.
	-- sets.OffenseMode['Saber Dance'] = {}

	-- Merged over the engaged set while the Dual Wield trait is active and the main weapon is
	-- one-handed. A two-handed or hand-to-hand main, such as the Karambit mode's, skips it.
	sets.DualWield = {}

	-- Treasure Hunter gear, worn on an action or melee swing against a monster not yet tagged, and
	-- throughout a fight in Full Time mode. It is never worn in None mode, where every job but
	-- Thief starts.
	sets.TreasureHunter = {
		head = gear.herculeanHelmNuke,
		legs = gear.herculeanTrousersAccEnmityDown,
		waist = gear.chaac,}

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Every precast starts from sets.Idle, except a pet command's. For a spell, sets.Precast is
	-- merged over it, then the fast cast set. Any slot left empty keeps your idle gear.
	sets.Precast = {}

	-- Fast cast, worn at the start of every spell.
	sets.Precast.FastCast = {
		ammo = gear.sapience,
		head = gear.herculeanHelmNuke,
		hands = gear.leylineGlovesFCB,
		neck = gear.baetylPendant,
		waist = gear.hachirinNoObi,
		left_ear = gear.etiolation,
		right_ear = gear.enchanterEarringPlusOne,
		right_ring = gear.rahabRing,
	}

	-- Merged over the fast cast set when you cast Utsusemi.
	sets.Precast.Utsusemi = {}

	-- Enmity gear for Animated Flourish, whose set below is built from it. The engine does not
	-- automatically merge this set into any others.
	sets.Enmity = {}

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- Midcast sets for spells from a subjob. sets.Midcast is the base for every cast, merged over
	-- sets.Idle, so any slot it leaves empty keeps your idle gear.
	sets.Midcast = {}
	-- Spell interruption rate down. Used under every midcast except ranged attacks, so any more
	-- specific set overrides it.
	sets.Midcast.SIRD = {}
	-- Merged over the spell interruption set when you cast Utsusemi from your ninja subjob.
	sets.Midcast.Utsusemi = {}
	-- Merged over the Utsusemi set in DT or MEVA mode.
	-- sets.Midcast.Utsusemi.DT = {}
	-- sets.Midcast.Utsusemi.MEVA = {}
	-- Self-cast ninjutsu from your ninja subjob, such as Tonko and Monomi.
	sets.Midcast.Enhancing = {}
	-- Merged over the enhancing set in DT or MEVA mode.
	-- sets.Midcast.Enhancing.DT = {}
	-- sets.Midcast.Enhancing.MEVA = {}
	-- Enfeebling ninjutsu from your ninja subjob, such as Kurayami and Hojo.
	sets.Midcast.Enfeebling = {}
	-- Merged over the enfeebling set in DT or MEVA mode.
	-- sets.Midcast.Enfeebling.DT = {}
	-- sets.Midcast.Enfeebling.MEVA = {}

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is merged over sets.Idle for every job ability, then the set named for
	-- the ability is merged over it. Any slot left empty keeps your idle gear. An ability set built
	-- from sets.Idle.DT, as several below are, keeps you in defensive gear for the second or two
	-- the ability takes, except where its own gear replaces it.
	sets.JA = {}

	sets.JA["Trance"] = {}
	sets.JA["Contradance"] = {}
	sets.JA["Saber Dance"] = {}
	sets.JA["Fan Dance"] = {}
	sets.JA["No Foot Rise"] = {}
	sets.JA["Presto"] = {}
	sets.JA["Grand Pas"] = {}

	-- Flourishes, which buff you or debuff the monster. sets.Flourish is merged over sets.Idle
	-- (flourishes do not use sets.JA), then the set named for the flourish.
	sets.Flourish = set_combine(sets.Idle.DT, {head=gear.nyameHead,})
																					-- Flourishes I
																					-- : Monster
																					-- Control
	sets.Flourish["Animated Flourish"] = set_combine(sets.Flourish, sets.Enmity) 	-- Volatile Enmity spike like Provoke
	sets.Flourish["Desperate Flourish"] = {} 										-- Gravity effect
	sets.Flourish["Violent Flourish"] = {} 											-- Stun effect
																					-- Flourishes II
																					-- : Skillchain
																					-- Enhancers
	sets.Flourish["Reverse Flourish"] = {} 											-- Returns TP in exchange for Finishing Moves
	sets.Flourish["Building Flourish"] = {head=gear.nyameHead,}						-- Increases the strength of the next Weapon Skill
	sets.Flourish["Wild Flourish"] = {}												-- Readies target for Skillchain
																					-- Flourishes
																					-- III : Weapon
																					-- Skill Buffs
	sets.Flourish["Climactic Flourish"] = {}										-- Forces Critical Hit(s) on the next attack(s)
	sets.Flourish["Striking Flourish"] = {head=gear.nyameHead,}						-- Forces a Double Attack on the next swing
	sets.Flourish["Ternary Flourish"] = {}											-- Forces a Triple Attack on the next swing

	-- Waltzes. Waltz potency gear caps at 50%, and the potency you receive caps at 30%. sets.Waltz
	-- is merged over sets.Idle (Waltzes do not use sets.JA), then the set named for the waltz.
	sets.Waltz = {
		ammo = gear.yamarang,
		head = gear.horosHeadPlusOne,
		body = gear.maxixiBody,
		hands = gear.horosHandsPlusOne,
		legs = gear.dashingSubligar,
		feet = gear.maxixiFeet,
		neck = gear.unmovingPlusOne,
		waist = gear.chaac,
		left_ear = gear.crypticEarring,
		right_ear = gear.enchanterEarringPlusOne,
		left_ring = gear.metamorphRing,
		right_ring = gear.carbuncleRingPlusOne,
		back = gear.moonlightCape,
	}
	sets.Waltz["Curing Waltz"] = sets.Waltz
	sets.Waltz["Curing Waltz II"] = sets.Waltz
	sets.Waltz["Curing Waltz III"] = sets.Waltz
	sets.Waltz["Curing Waltz IV"] = sets.Waltz
	sets.Waltz["Curing Waltz V"] = sets.Waltz
	sets.Waltz["Divine Waltz"] = sets.Waltz
	sets.Waltz["Divine Waltz II"] = sets.Waltz
	sets.Waltz["Healing Waltz"] = sets.Waltz

	-- Sambas, merged over sets.Idle (they do not use sets.JA). Gear can extend samba duration.
	sets.Samba = set_combine(sets.Idle.DT, {head=gear.maxixiHead,}) --  Missing Ambu Cape for +15

	sets.Samba["Haste Samba"] = {}
	sets.Samba["Aspir Samba"] = {}
	sets.Samba["Aspir Samba II"] = {}
	sets.Samba["Drain Samba"] = {}
	sets.Samba["Drain Samba II"] = {}
	sets.Samba["Drain Samba III"] = {}

	-- Jigs, merged over sets.Idle (they do not use sets.JA). Gear can extend jig duration.
	sets.Jig = set_combine(sets.Idle.DT, {feet=gear.maxixiFeet,}) -- Horos Tights +3 and Maxixi Toe Shoes +3

	sets.Jig["Spectral Jig"] = sets.Jig
	sets.Jig["Chocobo Jig"] = sets.Jig
	sets.Jig["Chocobo Jig II"] = sets.Jig

	-- Steps. sets.Step is merged over sets.Idle (steps do not use sets.JA), then the set named for
	-- the step, such as sets.Step['Box Step']. Step accuracy depends on your melee hit rate, normal
	-- accuracy gear included. Every step tested shows an innate 10 accuracy bonus, which gear,
	-- merits and Presto raise further.
	sets.Step = {
		ammo = gear.yamarang,
		head = gear.malignanceHead,
		body = gear.malignanceBody,
		hands = gear.malignanceHands,
		legs = gear.malignanceLegs,
		feet = gear.malignanceFeet,
		neck = gear.etoileGorgetPlusOne,
		waist = gear.reiki,
		left_ear = gear.odr,
		right_ear = gear.telos,
		left_ring = gear.chirichRingPlusOne,
		right_ring = gear.chirichRingPlusOne,
		back = gear.sacroMantle,
	}

	-- Merged over the step set when you use Feather Step. Maculele Toe Shoes add to Feather Step's
	-- effect.
	sets.Step["Feather Step"] = {}

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- Weaponskill base, merged over sets.Idle for every weaponskill. The set named for the
	-- weaponskill is merged over it. Any slot left empty keeps your idle gear.
	sets.WS = {
		ammo = gear.coiste,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.anu,
		waist = gear.sailfi,
		left_ear = gear.sherida,
		right_ear = gear.moonshadeEarringBAtt,
		left_ring = gear.gereRing,
		right_ring = gear.eponas,
		back = gear.sacroMantle,
	}

	-- Merged in ACC mode after the set named for the weaponskill, so its gear wins. ACC is not
	-- offered above, so the engine never reads it. To use it, add ACC to the modes above, then
	-- uncomment this line and fill in only the slots ACC mode should change. A weaponskill with its
	-- own ACC set uses that instead.
	-- sets.WS.ACC = {}

	-- Worn on every weaponskill while Climactic Flourish is up. Gear that enhances it, such as
	-- Maculele Tiara +3 (head), adds damage to the critical hits it forces.
	-- sets.WS['Climactic Flourish'] = {}

	-- Worn on every weaponskill while Striking Flourish is up. Gear that enhances it, such as
	-- Maculele Casaque +3 (body), raises the critical hit rate of the double attack it forces.
	-- sets.WS['Striking Flourish'] = {}

	-- Merged in DT mode after the set named for the weaponskill, so its gear wins, for damage taken
	-- gear. A weaponskill with its own DT set uses that instead. Every slot here costs some of the
	-- weaponskill's damage, so uncomment it only once you fill it in.
	-- sets.WS.DT = {}

	-- Merged over every weaponskill while Buff Level (Alt+F12) is set to HighBuff, for physical
	-- damage limit gear. At MidBuff, the default, no set is used here. In any offense mode except
	-- TP, the set for that mode and level is merged after it, such as sets.WS.DT.HighBuff in DT
	-- mode once sets.WS.DT exists. A weaponskill's own child sets replace these for that
	-- weaponskill, as shown at the end of this section.
	sets.WS.HighBuff = {}

	-- Aftermath sets for weaponskills, merged after the weaponskill's own sets while the matching
	-- Aftermath is up. The engine uses the strongest active tier that has gear for the current
	-- weapon, and a tier set applies with any weapon. A child named for a weapon mode adds gear for
	-- that weapon only, over the tier set, and is read only when its name is one of the
	-- state.WeaponMode options above. Aeneas's Aftermath raises the damage of the skillchains your
	-- weaponskills make, so its sets are here.
	sets.WS.AM1 = {}
	sets.WS.AM2 = {}
	sets.WS.AM3 = {}
	sets.WS.AM1['Aeneas'] = {}
	sets.WS.AM2['Aeneas'] = {}
	sets.WS.AM3['Aeneas'] = {}

	-- Sets named for one weaponskill, merged over sets.WS.
	-- Dagger weaponskills
	sets.WS["Wasp Sting"] = {}
	sets.WS["Viper Bite"] = {}
	sets.WS["Shadowstitch"] = {}
	sets.WS["Gust Slash"] = {}
	sets.WS["Cyclone"] = {}
	sets.WS["Energy Steal"] = {}
	sets.WS["Energy Drain"] = {}
	sets.WS["Dancing Edge"] = {}
	sets.WS["Shark Bite"] = {}
	sets.WS["Evisceration"] = {
		ammo = gear.ginsen,
		head = gear.blisteringSalletPlusOne,
		body = gear.gletiBody,
		hands = gear.gletiHands,
		legs = gear.gletiLegs,
		feet = gear.gletiFeet,
		neck = gear.fotiaNeck,
		waist = gear.fotiaWaist,
		left_ear = gear.sherida,
		right_ear = gear.odr,
		left_ring = gear.regalRing,
		right_ring = gear.eponas,}
	sets.WS["Aeolian Edge"] = {
		ammo = gear.yamarang,
		head = gear.nyameHead,
		body = gear.nyameBody,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.baetylPendant,
		waist = gear.fotiaWaist,
		left_ear = gear.friomisi,
		right_ear = gear.moonshadeEarringBAtt,
		left_ring = gear.regalRing,
		right_ring = gear.ilabrat,
		back = gear.sacroMantle,}
	sets.WS["Rudra's Storm"] = {}
	sets.WS["Exenterator"] = {}

	-- Hand-to-hand weaponskills
	sets.WS["Combo"] = {}
	sets.WS["Shoulder Tackle"] = {}
	sets.WS["Backhand Blow"] = {}
	sets.WS["Asuran Fists"] = {} 	-- Only with Karambit equipped
	sets.WS["Dragon Kick"] = {} 	-- Only with Hepatizon Baghnakhs NQ/+1 equipped
	sets.WS["One Inch Punch"] = {}
	sets.WS["Raging Fists"] = {}
	sets.WS["Tornado Kick"] = {}

	-- Child sets for a single weaponskill, used instead of the general sets.WS ones: one for a
	-- mode, one for HighBuff, and one for the two together. Once declared, each one replaces the
	-- general set for that weaponskill even if it is empty, so only uncomment a line after you fill
	-- it in. The mode and HighBuff line also needs the mode line above it.
	-- sets.WS["Rudra's Storm"].DT = {}
	-- sets.WS["Rudra's Storm"].HighBuff = {}
	-- sets.WS["Rudra's Storm"].DT.HighBuff = {}
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

-- Called as each action starts. The table it returns is merged over the engine's precast set. Every
-- hook from here down to status_change_custom adds the job mode's weapons through the engine's
-- Job_Mode_Check, which merges the sets.Weapons entry named for the current job mode, if there is
-- one. This file sets no job mode options, so it adds nothing until you add job modes with matching
-- sets.Weapons entries.
function precast_custom(spell)
	local equipSet = {}

	return Job_Mode_Check(equipSet)
end

-- Called while each action is in progress. The table it returns is merged over the engine's midcast
-- set, which is empty for abilities, weaponskills and items.
function midcast_custom(spell)
	local equipSet = {}

	return Job_Mode_Check(equipSet)
end

-- Called when each action ends. The table it returns is merged over the idle or engaged set the
-- engine rebuilds.
function aftercast_custom(spell)
	local equipSet = {}

	return Job_Mode_Check(equipSet)
end

-- Called when a buff is gained or lost. The table it returns is merged over the rebuilt idle or
-- engaged set. If one of your own actions is still in progress, it is still called right away, but
-- the table it returns is not used, and the gear change happens when that action ends.
function buff_change_custom(name,gain)
	local equipSet = {}

	return Job_Mode_Check(equipSet)
end

-- Called whenever the engine rebuilds the idle or engaged set, which it does after each action, on
-- a buff or status change, and when movement starts or stops. The table it returns is merged over
-- that set.
function choose_set_custom()
	local equipSet = {}

	return Job_Mode_Check(equipSet)
end

-- Called when the player's status changes, such as engaging, disengaging or resting. The table it
-- returns is merged over the rebuilt idle or engaged set. If one of your own actions is still in
-- progress, the table is not used, and the gear change happens when that action ends.
function status_change_custom(new,old)
	local equipSet = {}

	return Job_Mode_Check(equipSet)
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
