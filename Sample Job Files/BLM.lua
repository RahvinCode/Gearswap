-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- Rahvin GS job file: Black Mage. A sample to copy into your character's folder and fill in.
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
LockStylePallet = "14"
MacroBook = "20"
MacroSet = "1"

-- Use a Remedy for paralysis or silence, and a Holy Water for doom, automatically.
AutoItem = false

-- Pick a random lockstyle from Lockstyle_List each time the file loads, instead of LockStylePallet.
Random_Lockstyle = false

-- The lockstyle sets the random pick chooses from.
Lockstyle_List = {1,2,6,12}

-- The food "gs c food" uses.
Food = "Tropical Crepe"

-- Offense modes, and the one the file starts in. Each mode offered needs its own
-- sets.OffenseMode.<Mode> and sets.Idle.<Mode> below. Occult and MB are nuking modes, read by the
-- nuke sets' children of the same name: Occult for Occult Acumen gear, MB for burst gear on every
-- nuke.
state.OffenseMode:options('TP','ACC','DT','PDT','MEVA','Occult','MB')
state.OffenseMode:set('DT')

-- Weapon modes. Each name needs a matching sets.Weapons entry.
state.WeaponMode:options('Nuke','Mpaca')
state.WeaponMode:set('Nuke')

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

	sets.Weapons = {}

	sets.Weapons['Nuke'] ={
		main = gear.mpacaStaff,
		sub = gear.enki,
	}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons.Shield ={}

	sets.Weapons['Mpaca'] ={
		main = gear.mpacaStaff,
		sub = gear.enki,
	}

	-- Merged whole over a Cure, Curaga or Cura cast on Lightsday or in Light weather. Its main and
	-- sub are worn unless the weapon lock holds them.
	-- When this set is empty, the engine puts Chatoyant Staff in main alone, if you carry one.
	-- Without a Chatoyant Staff, remove main and sub from this set. The game refuses its grip
	-- beside a one-handed main.
	sets.Weapons['Light Bonus'] = {}

	-- ===================================================================================================================
	--		sets.Idle
	-- ===================================================================================================================

	-- Worn whenever you are not engaged. Every action also starts from this set, so any slot an
	-- action's sets leave empty keeps your idle gear.
	sets.Idle = {
		ammo = gear.staunchPlusOne,
		head = gear.wicceHeadPlusThree, --11
		body = gear.wicceBodyPlusThree,
		hands = gear.wicceHandsPlusThree, --13
		legs = gear.wicceLegsPlusThree,
		feet = gear.wicceFeetPlusThree, --11 (removed while moving)
		neck = gear.loricatePlusOne, --6
		waist = gear.carriers,
		left_ear = gear.lugalbanda,
		right_ear = gear.etiolation,
		left_ring = gear.defending, --10
		right_ring = gear.stikiniRingPlusOne,
		back = gear.blmNuke,
	}

	-- Idle sets for each offense mode, merged over the idle set.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.PDT = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
	})
	-- Occult and MB modes start from copies of the DT idle set, so you sit in DT gear between
	-- casts in those modes.
	sets.Idle.Occult = set_combine(sets.Idle.DT, {})
	sets.Idle.MB = set_combine(sets.Idle.DT, {})
	-- Merged over the idle set while Sublimation is charging.
	sets.Idle.Sublimation = {
		waist = gear.embla, -- +3 Sublimation when active
	}
	-- Merged over the idle set while you rest.
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

	-- Worn over the idle set while Mana Wall is up. Gear that enhances Mana Wall, such as Wicce
	-- Sabots +3 (feet) or Taranus's Cape (back), cuts the damage further before Mana Wall takes it
	-- from your MP.
	-- Feet named here replace the movement set's feet while you move.
	-- sets.Idle['Mana Wall'] = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = {
		feet = gear.heraldGaiters,
	}

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
	sets.OffenseMode.TP = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.DT = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.ACC = set_combine(sets.OffenseMode,{ })
	sets.OffenseMode.PDT = set_combine(sets.OffenseMode, { })
	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode, { })
	-- Occult and MB modes start from copies of the DT engaged set.
	sets.OffenseMode.Occult = set_combine(sets.OffenseMode.DT, { })
	sets.OffenseMode.MB = set_combine(sets.OffenseMode.DT, { })

	-- Worn over the engaged set in every offense mode while Mana Wall is up, for the same Mana Wall
	-- gear as the idle one above.
	-- sets.OffenseMode['Mana Wall'] = {}

	-- Aftermath sets, merged over the engaged set while the matching Aftermath is up. The engine
	-- uses the strongest active tier that has gear for the current weapon. A tier set applies with
	-- any weapon, and a child named for a weapon mode adds gear for that weapon only, such as
	-- sets.OffenseMode.AM3['Laevateinn'] once a 'Laevateinn' weapon mode is offered above.
	sets.OffenseMode.AM1 = {}
	sets.OffenseMode.AM2 = {}
	sets.OffenseMode.AM3 = {}

	-- Treasure Hunter gear, worn on an action or melee swing against a monster not yet tagged, and
	-- throughout a fight in Full Time mode. It is never worn in None mode, where every job but
	-- Thief starts.
	sets.TreasureHunter = { }

	-- ===================================================================================================================
	--		sets.Precast
	-- ===================================================================================================================

	-- Every precast starts from sets.Idle, except a pet command's. For a spell, sets.Precast is
	-- merged over it, then the fast cast set. Any slot left empty keeps your idle gear.
	sets.Precast = {}

	-- Fast cast, worn at the start of every spell.
	sets.Precast.FastCast = {
		ammo = gear.ghastlyTathlumPlusOne,
		head = gear.merlinicHoodFCB, -- 14
		body = gear.merlinicJubbahFC, -- 13
		hands = gear.merlinicDastanasBFC, -- 7
		legs = gear.agwuLegs, -- 7
		feet = gear.merlinicCrackowsBFC, -- 12
		neck = gear.unmovingPlusOne,
		waist = gear.embla, -- 5
		left_ear = gear.malignanceEar, -- 4
		right_ear = gear.etiolation, -- 1
		left_ring = gear.weatherspoon, -- 5
		right_ring = gear.kishar, -- 4
		back = gear.blmFC, -- 10
	} -- 80% FC

	-- Merged over the fast-cast set for enhancing magic.
	sets.Precast.Enhancing = set_combine(sets.Precast.FastCast, {})

	-- Merged over the fast cast set when you cast Cure, Curaga or Cura.
	sets.Precast.Cure = {}

	-- Merged over the fast cast set when you cast a healing spell other than a cure, such as Raise
	-- or a -na spell.
	sets.Precast.Healing = {}

	-- Merged over the fast cast set when you cast Impact. The engine then puts on the Impact cloak
	-- you carry and removes your head piece.
	sets.Precast["Impact"] = set_combine(sets.Precast.FastCast,{
		ammo = gear.sapience,
		neck = gear.voltsurge,
		body = gear.twilightCloak,
	})

	-- Merged over the fast cast set when you cast Death, for maximum MP gear.
	sets.Precast['Death'] = {}

	-- ===================================================================================================================
	--		sets.Midcast
	-- ===================================================================================================================

	-- The base for every cast, merged over sets.Idle on every midcast, so any slot it leaves empty
	-- keeps your idle gear.
	sets.Midcast = set_combine(sets.Idle, {

	})

	-- Spell interruption rate down. Used under every midcast except ranged attacks, so any more
	-- specific set overrides it.
	sets.Midcast.SIRD = {

	}

	-- Merged over sets.Midcast and sets.Midcast.SIRD when you cast any spell in ACC mode. The
	-- spell's own family set is merged after it, so that set wins any slot both fill.
	sets.Midcast.ACC = {}

	-- Each casting set below can take a child set named for an offense mode, such as
	-- sets.Midcast.Nuke.ACC. It is merged right over its set in that mode, so the sets merged after
	-- it still win any slot both fill. The DT and MEVA children are for damage taken and magic
	-- evasion gear. They ship commented out: uncomment one once you fill it in.

	-- Merged over every spell's midcast while Mana Wall is up, so its gear is back on for the cast.
	-- No precast set can carry it, so the fast-cast set's pieces are worn at the start of each
	-- spell.
	-- sets.Midcast['Mana Wall'] = {}

	-- Worn when you cast a cure. Curaga below is this same set, so the child sets below apply to
	-- Curaga too.
	sets.Midcast.Cure = {

	}

	-- Merged over the cure set when you cast a cure on yourself.
	sets.Midcast.Cure.Self = {}

	-- Merged over the cure set when you cast a cure on anyone else, or on yourself under Accession.
	sets.Midcast.Cure.Others = {}

	-- Merged over the cure set in DT or MEVA mode.
	-- sets.Midcast.Cure.DT = {}
	-- sets.Midcast.Cure.MEVA = {}

	-- Enhancing magic. Raise, Reraise, the -na spells and Cursna take it too, and the Stoneskin,
	-- Aquaveil and dark magic enhancing sets below start from a copy of it.
	sets.Midcast.Enhancing = {
		main = gear.daybreak,
		sub = gear.ammurapi,
		ammo = gear.ghastlyTathlumPlusOne,
		head = gear.telchineCapBEnhDur,
		body = gear.telchineChasubleBEnhDur,
		hands = gear.telchineGlovesBRegen,
		legs = gear.telchineBraconiBEnhDur,
		feet = gear.telchinePigachesBEnhDur,
		neck = gear.incanterTorque,
		waist = gear.embla,
		left_ear = gear.mimir,
		right_ear = gear.etiolation,
		left_ring = gear.gelatinousPlusOne,
		right_ring = gear.stikiniRingPlusOne,
		back = gear.perimedeCape,
	}
	-- Merged over the enhancing set: Others when you cast on someone else, or on yourself under
	-- Accession, Status for status bar spells, Skill for skill-based buffs.
	sets.Midcast.Enhancing.Others = {}
	sets.Midcast.Enhancing.Status = {}
	sets.Midcast.Enhancing.Skill = {}

	-- Merged over the enhancing set in DT or MEVA mode.
	-- sets.Midcast.Enhancing.DT = {}
	-- sets.Midcast.Enhancing.MEVA = {}

	-- Enfeebling magic, dressed for magic accuracy.
	sets.Midcast.Enfeebling = {
		main = gear.daybreak,
		sub = gear.ammurapi,
		ammo = gear.ghastlyTathlumPlusOne,
		head = gear.wicceHeadPlusThree,
		body = gear.wicceBodyPlusThree,
		hands = gear.wicceHandsPlusThree,
		legs = gear.wicceLegsPlusThree,
		feet = gear.wicceFeetPlusThree,
		neck = gear.incanterTorque,
		waist = gear.luminarySash,
		left_ear = gear.malignanceEar,
		right_ear = gear.wicceEarringPlusOne,
		left_ring = gear.weatherspoon,
		right_ring = gear.stikiniRingPlusOne,
		back = gear.blmNuke,
	}

	-- Merged over the enfeebling set for the spells the engine's lists name: MACC for
	-- accuracy-based spells, Potency for potency-based ones, Duration for duration-based ones. The
	-- elemental debuffs, such as Burn, take MACC too, and Bio takes Duration over the dark magic set.
	sets.Midcast.Enfeebling.MACC = {}
	sets.Midcast.Enfeebling.Potency = {}
	sets.Midcast.Enfeebling.Duration = {}

	-- Merged over the enfeebling set in ACC, DT or MEVA mode, before the MACC, Potency or Duration
	-- set. ACC is for magic accuracy gear.
	sets.Midcast.Enfeebling.ACC = {}
	-- sets.Midcast.Enfeebling.DT = {}
	-- sets.Midcast.Enfeebling.MEVA = {}

	-- Drain and Aspir take their own sets, sets.Midcast.Drain and sets.Midcast.Aspir, ahead of any
	-- enfeebling or dark magic set.
	sets.Midcast.Drain = set_combine(sets.Midcast.Enfeebling, {})

	-- Merged over the Drain set when you cast Drain into a burst window of its element.
	sets.Midcast.Drain.Burst = {}

	-- Merged over the Drain set in ACC, DT or MEVA mode.
	sets.Midcast.Drain.ACC = {}
	-- sets.Midcast.Drain.DT = {}
	-- sets.Midcast.Drain.MEVA = {}

	-- Dark magic. MACC, Absorb and Enhancing merge over it for the spells the engine's dark magic
	-- lists name: MACC for Stun and Death, Absorb for the Absorb spells, such as Absorb-TP, and
	-- Enhancing for Tractor. MACC starts from the enfeebling MACC set's own pieces, and Enhancing
	-- from a copy of the enhancing set.
	sets.Midcast.Dark = set_combine(sets.Midcast.Enfeebling, {})
	sets.Midcast.Dark.MACC = set_combine(sets.Midcast.Enfeebling.MACC, {})
	sets.Midcast.Dark.Absorb = {}
	sets.Midcast.Dark.Enhancing = set_combine(sets.Midcast.Enhancing, {})

	-- Merged over the dark magic set in ACC, DT or MEVA mode, before the MACC, Absorb or Enhancing
	-- set.
	sets.Midcast.Dark.ACC = {}
	-- sets.Midcast.Dark.DT = {}
	-- sets.Midcast.Dark.MEVA = {}

	-- Elemental nukes. After this set, the engine may put an obi, sash, cape or Zodiac Ring in the
	-- waist, back and ring slots when the day, weather or distance favors one.
	sets.Midcast.Nuke = {
		ammo = gear.ghastlyTathlumPlusOne,
		head = gear.eaHeadPlusOne,
		body = gear.wicceBodyPlusThree,
		hands = gear.agwuHands,
		legs = gear.wicceLegsPlusThree,
		feet = gear.agwuFeet,
		neck = gear.sorcererStolePlusTwo,
		waist = gear.acuityBeltPlusOne,
		left_ear = gear.malignanceEar,
		right_ear = gear.regalEarring,
		left_ring = gear.metamorphPlusOne,
		right_ring = gear.freke,
		back = gear.blmNuke,
	}

	-- Used instead of the nuke set when the engine expects your nuke to land on the skillchain's
	-- target while the burst window is open, with an element that skillchain carries. A skillchain
	-- of its element that lands on your target while you cast puts this set on too.
	sets.Midcast.Burst = set_combine(sets.Midcast.Nuke, { })

	-- Merged over the burst set when you cast Thundaga III into a burst window of its element. A
	-- child named for any spell works the same way.
	sets.Midcast.Burst['Thundaga III'] = {}

	-- Merged over the nuke set in Occult mode, for Occult Acumen gear. A nuke the engine expects to
	-- burst uses the burst set instead, so in Occult mode it takes sets.Midcast.Burst.Occult.
	sets.Midcast.Nuke.Occult = {}
	sets.Midcast.Burst.Occult = {}

	-- Merged over the nuke set in MB mode, for wearing burst gear on every nuke. It goes on when the
	-- engine does not expect the nuke to burst. A nuke it does expect to burst uses the burst set as
	-- usual.
	sets.Midcast.Nuke.MB = {}

	-- Merged over the nuke set, or over the burst set, in ACC mode for magic accuracy gear, and in
	-- DT or MEVA mode once uncommented.
	sets.Midcast.Nuke.ACC = {}
	sets.Midcast.Burst.ACC = {}
	-- sets.Midcast.Nuke.DT = {}
	-- sets.Midcast.Nuke.MEVA = {}
	-- sets.Midcast.Burst.DT = {}
	-- sets.Midcast.Burst.MEVA = {}

	-- Merged over the nuke or burst set for earth spells.
	sets.Midcast.Nuke.Earth = {
		neck = gear.quanpur,
	}

	-- Merged over the nuke set when you cast Comet, for dark-element magic damage gear. A Comet
	-- cast into a burst window of its element uses sets.Midcast.Burst['Comet'] instead, since a
	-- burst uses the burst set instead of the nuke set.
	sets.Midcast.Nuke['Comet'] = {}

	-- Used instead of the nuke set and the burst set when you cast Impact. The engine puts on the
	-- Impact cloak and removes your head piece.
	sets.Midcast['Impact'] = set_combine(sets.Midcast.Nuke, {
		hands = gear.wicceHandsPlusThree,
		legs = gear.wicceLegsPlusThree,
		feet = gear.wicceFeetPlusThree,
		left_ring = gear.stikiniRingPlusOne1,
		right_ring = gear.stikiniRingPlusOne2,
	})

	-- Merged over the Impact set when you cast Impact into a burst window of its element.
	sets.Midcast['Impact'].Burst = {}

	-- Used instead of the dark magic set when you cast Death, for maximum MP and magic damage gear.
	-- Uncomment the two lines below once you fill them in: once declared, the first replaces the
	-- dark magic set for Death even if it is empty, and its burst child set is merged over it when
	-- you cast Death into a burst window of its element.
	-- sets.Midcast['Death'] = {}
	-- sets.Midcast['Death'].Burst = {}

	-- Curaga uses the same set as Cure.
	sets.Midcast.Curaga = sets.Midcast.Cure

	-- Merged over the enhancing set when you cast Cursna.
	sets.Midcast.Cursna = {}

	-- Worn when you cast divine magic, such as Banish.
	sets.Midcast.Divine = {}

	-- Merged over the divine set in ACC, DT or MEVA mode.
	sets.Midcast.Divine.ACC = {}
	-- sets.Midcast.Divine.DT = {}
	-- sets.Midcast.Divine.MEVA = {}

	-- Not read by the engine. midcast_custom below wears it on an elemental nuke cast below 30% MP.
	sets.MP_Recover = {
		body = gear.spaekonaBodyPlusThree,
	}

	-- Merged over the enhancing set for elemental bar spells.
	sets.Midcast.Enhancing.Elemental = {}

	-- Sets named for one spell. Each replaces the enhancing set for that spell, so these two start
	-- from a copy of it.
	sets.Midcast["Stoneskin"] = set_combine(sets.Midcast.Enhancing, {
		right_ring = gear.stikiniRingPlusOne,
		waist = gear.siegel,
		neck = gear.nodens,
	})

	sets.Midcast["Aquaveil"] = set_combine(sets.Midcast.Enhancing, {
		head = gear.amalricCoifPlusOne
	})

	-- Merged over the enhancing set when you cast Refresh.
	sets.Midcast.Refresh = {
		head = gear.amalricCoifPlusOne
	}

	-- Used instead of the dark magic set when you cast Aspir, Aspir II or Aspir III.
	sets.Midcast.Aspir = {}

	-- Merged over the Aspir set when you cast Aspir into a burst window of its element.
	sets.Midcast.Aspir.Burst = {}

	-- Merged over the Aspir set in ACC, DT or MEVA mode.
	sets.Midcast.Aspir.ACC = {}
	-- sets.Midcast.Aspir.DT = {}
	-- sets.Midcast.Aspir.MEVA = {}

	-- ===================================================================================================================
	--		sets.JA
	-- ===================================================================================================================

	-- Job abilities. sets.JA is merged over sets.Idle for every job ability, then the set named for
	-- the ability is merged over it. Any slot left empty keeps your idle gear.
	sets.JA = {}
	sets.JA["Manafont"] = {}
	sets.JA["Elemental Seal"] = {}
	sets.JA["Mana Wall"] = {}
	sets.JA["Cascade"] = {}
	sets.JA["Enmity Douse"] = {}
	sets.JA["Manawell"] = {}
	sets.JA["Subtle Sorcery"] = {}

	-- ===================================================================================================================
	--		sets.WS
	-- ===================================================================================================================

	-- Weaponskill base, merged over sets.Idle for every weaponskill. The set named for the
	-- weaponskill is merged over it. Any slot left empty keeps your idle gear.
	sets.WS = {}

	-- Merged in ACC mode after the set named for the weaponskill, so its gear wins. Only fill in
	-- the slots ACC mode should change. A weaponskill with its own ACC set uses that instead.
	sets.WS.ACC = {}

	-- Merged in DT mode after the set named for the weaponskill, so its gear wins, for damage taken
	-- gear. sets.WS.MEVA works the same way in MEVA mode, for magic evasion gear. A weaponskill
	-- with its own DT or MEVA set uses that instead. Every slot here costs some of the
	-- weaponskill's damage, so uncomment a line only once you fill it in.
	-- sets.WS.DT = {}
	-- sets.WS.MEVA = {}

	-- Merged over every weaponskill while Buff Level (Alt+F12) is set to HighBuff, for physical
	-- damage limit gear. At MidBuff, the default, no set is used here. A weaponskill's own HighBuff
	-- set replaces this one for that weaponskill, even if it is empty. In any offense mode except
	-- TP, the set for that mode and level is merged after it, such as sets.WS.ACC.HighBuff in ACC
	-- mode.
	sets.WS.HighBuff = {}
	sets.WS.ACC.HighBuff = {}

	-- Merged over sets.WS when you use Myrkr.
	sets.WS["Myrkr"] = {
		ammo = gear.ghastlyTathlumPlusOne,
		head = gear.amalricHeadPlusOnePathA,
		body = gear.amalricBodyPlusOnePathA,
		hands = gear.vanyaHandsPathA,
		legs = gear.amalricLegsPlusOnePathA,
		feet = gear.vanyaFeetPathA,
		neck = gear.sanctity,
		waist = gear.luminarySash,
		left_ear = gear.moonshadeEarringAcc,
		right_ear = gear.etiolation,
		left_ring = gear.metamorphPlusOne,
		right_ring = gear.etanaRing,
		back = gear.blmNuke,
	}

	-- Merged over sets.WS when you use Cataclysm or Earth Crusher. Both deal magic damage, so the
	-- engine adds the day, weather and distance pieces after them.
	sets.WS['Cataclysm'] = {}
	sets.WS['Earth Crusher'] = {}

	-- Aftermath sets for weaponskills, merged after the weaponskill's own sets while the matching
	-- Aftermath is up. They work as the engaged Aftermath sets do.
	sets.WS.AM1 = {}
	sets.WS.AM2 = {}
	sets.WS.AM3 = {}

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
	if spell.skill == 'Elemental Magic' and not Elemental_Enfeeble:contains(spell.name) and player.MPP < 30 then
		windower.add_to_chat(8,'Player Less than 30% MP - Recover MP!')
		equipSet = sets.MP_Recover
	end
	return equipSet
end

-- Called when each action ends. The table it returns is merged over the idle or engaged set the
-- engine rebuilds.
function aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called when a buff is gained or lost. The table it returns is merged over the rebuilt idle or
-- engaged set. If one of your own actions is still in progress, it is still called right away, but
-- the table it returns is not used, and the gear change happens when that action ends.
function buff_change_custom(name,gain)
	local equipSet = {}

	return equipSet
end

-- Called whenever the engine rebuilds the idle or engaged set, which it does after each action, on
-- a buff or status change, and when movement starts or stops. The table it returns is merged over
-- that set.
function choose_set_custom()
	local equipSet = {}

	return equipSet
end

-- Called when the player's status changes, such as engaging, disengaging or resting. The table it
-- returns is merged over the rebuilt idle or engaged set. If one of your own actions is still in
-- progress, the table is not used, and the gear change happens when that action ends.
function status_change_custom(new,old)
	local equipSet = {}

	return equipSet
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
