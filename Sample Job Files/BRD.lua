-- Load and initialize the include file.
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')

-- The in-game lockstyle set, macro book and macro set this file applies on load.
LockStylePallet = "9"
MacroBook = "9"
MacroSet = "1"

-- The food "gs c food" uses.
Food = "Tropical Crepe"

-- Weapon modes. Each name needs a matching sets.Weapons entry.
state.WeaponMode:options('Mordant Rime', 'Aeolian Edge', 'Shining Strike', 'Shining Blade', 'Savage Blade',
	'Evisceration', 'Rudra\'s Storm', 'Staff')
state.WeaponMode:set('Mordant Rime')

-- Offense modes. TP, ACC and DT are the engine's defaults, and more can be added. Each mode picks its own engaged, idle and weaponskill sets, so each one offered needs a sets.OffenseMode.<Mode> and a sets.Idle.<Mode> below.
state.OffenseMode:options('TP', 'ACC', 'DT', 'PDL', 'SB', 'MEVA', 'CRIT')

-- The offense mode the file starts in.
state.OffenseMode:set('TP')

-- Apply the macro book, macro set and lockstyle, bind the mode keys, and print the key list.
jobsetup(LockStylePallet, MacroBook, MacroSet)

function get_sets()
	-- Weapon sets, one per weapon mode.
	sets.Weapons = {}

	sets.Weapons['Mordant Rime'] = {
		main = gear.carnwenhan,
		sub = gear.crepuscularKnife,
	}

	sets.Weapons['Aeolian Edge'] = {
		main = gear.carnwenhan,
		sub = gear.gleti,
	}

	sets.Weapons['Shining Strike'] = {
		main = gear.daybreak,
		sub = gear.gleti,
	}

	sets.Weapons['Shining Blade'] = {
		main = gear.naegling,
		sub = gear.daybreak,
	}

	sets.Weapons['Savage Blade'] = {
		main = gear.naegling,
		sub = gear.fusettoPlusTwo,
	}

	sets.Weapons['Staff'] = {
		main = gear.xoanon,
		sub = gear.alberStrap,
	}

	sets.Weapons['Evisceration'] = {
		main = 'Tauret',
		sub = gear.gleti,
	}

	sets.Weapons['Rudra\'s Storm'] = {
		main = gear.carnwenhan,
		sub = gear.gleti,
	}

	-- Weapons worn for every song, with the Precast or Midcast child merged over them in that phase.
	-- A weapon lock that does not exempt the song keeps the locked main and sub.
	sets.Weapons.Songs = {
		main = gear.carnwenhan,
		sub = gear.kaliPathD,
	}

	sets.Weapons.Songs.Precast = {}

	sets.Weapons.Songs.Midcast = {}

	-- Worn in the offhand whenever the main is one-handed and no dual-wield trait is active.
	sets.Weapons.Shield = { sub = gear.genmeiShield, }

	-- Worn over the idle set when you are put to sleep. Its slots stay held until you wake, and the engine re-dresses nothing else while you sleep.
	-- Put gear here that wakes you, such as a piece that drains HP.
	sets.Weapons.Sleep = { range = gear.loughnashade, }

	-- Instruments the engine equips for songs: Count for dummy songs, Potency for other songs, Enfeebling for enfeebling songs,
	-- Pianissimo for a song sung on one other player, and AOE_Sleep for Horde Lullaby.
	Instrument = {}
	Instrument.Count = { name = "Daurdabla" }
	Instrument.Potency = { name = "Gjallarhorn" }
	Instrument.Enfeebling = { name = "Gjallarhorn" }
	Instrument.Pianissimo = { name = "Gjallarhorn" }

	-- A family entry under Pianissimo, such as Ballad, replaces the general one when a song of that family is sung on one other player.
	-- Honor March and Aria of Passion always take their required instrument instead.
	Instrument.Pianissimo.Ballad = { name = "Miracle Cheer" }
	Instrument.AOE_Sleep = { name = "Daurdabla" }

	-- Linos variants this file names in its own sets below. The engine does not read these.
	Instrument.Idle = { name = "Linos", augments = { 'Mag. Evasion+15', '"Waltz" potency +4%', 'HP+20', } }
	Instrument.TP = { name = "Linos", augments = { 'Accuracy+20', '"Store TP"+4', 'Quadruple Attack +3', } }
	Instrument.Mordant = { name = "Linos", augments = { 'Accuracy+15 Attack+15', 'Weapon skill damage +3%', 'CHR+8', } }
	Instrument.QuickMagic = { name = "Linos", augments = { 'Mag. Evasion+15', 'Occ. quickens spellcasting +4%', 'HP+20', } }
	Instrument.FastCast = { name = "Linos", augments = { 'Mag. Evasion+15', '"Fast Cast"+6', 'HP+20', } }
	Instrument.WS = { name = "Linos", augments = { 'Accuracy+15 Attack+15', 'Weapon skill damage +3%', 'STR+8', } }
	Instrument.MAB = { name = "Linos", augments = { 'Mag.Atk.Bns."+15', 'Weapon skill damage +3%', 'INT+8', } }

	-- Worn whenever you are not engaged. It is also the floor under every action, so a slot an action's sets leave unnamed keeps its idle piece.
	sets.Idle = {
		range = Instrument.Idle, -- 4/0
		head = gear.filiHeadPlusThree, -- 11/11
		body = gear.adamantiteArmor, -- 20/20
		hands = gear.bunziHands, -- 8/8
		legs = gear.filiLegsPlusThree, -- 13/13
		feet = gear.filiFeetPlusThree, -- 18% Movement
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
		left_ear = gear.odnowaPlusOne, -- 3/3
		right_ear = gear.sanareEarring,
		left_ring = gear.wardenRing,
		right_ring = gear.shadowRing,
		back = gear.brdWaltz,
	}

	-- Merged over the idle sets while you rest.
	sets.Idle.Resting = set_combine(sets.Idle, {})

	-- Idle sets for each offense mode, merged over the idle set.
	sets.Idle.TP = set_combine(sets.Idle, {})
	sets.Idle.ACC = set_combine(sets.Idle, {})
	sets.Idle.DT = set_combine(sets.Idle, {})
	sets.Idle.SB = set_combine(sets.Idle, {})
	sets.Idle.PDL = set_combine(sets.Idle, {})
	sets.Idle.MEVA = set_combine(sets.Idle, {})
	sets.Idle.CRIT = set_combine(sets.Idle, {})

	-- Worn over the idle set while a Phantom Roll on you stands at 11.
	-- It is meant for Roller's Ring, which every job can wear and which grants Refresh +1 and Regain +10 at an 11, e.g. left_ring="Roller's Ring".
	-- This set applies in every offense mode. The TP set below applies only in TP mode and merges after it.
	-- It is worn only while idle, so any action swaps it out, and it comes back when the action ends.
	-- While you move, a ring named here replaces a movement ring in the same slot. This file's sets.Movement names no ring, so either slot is free.
	sets.Idle.XIRoll = {}
	-- The TP mode version, merged after the one above.
	sets.Idle.TP.XIRoll = {}

	-- Merged over the idle set while you are moving and not engaged.
	sets.Movement = { feet = gear.filiFeetPlusThree }

	-- Worn when another character on this machine, running this engine, starts casting one of these spells on you, while Spell Received mode is ON. sets.Cursna_Received is also the Doom set, worn and held while you are doomed with that mode OFF.
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

	-- The ring slot Zodiac Ring goes in when an elemental spell matches the day's element: "right_ring" or "left_ring".
	Elemental_Bonus_Ring_Slot = "right_ring"

	-- Worn when you use a Holy Water or Hallowed Water.
	sets.Holy_Water = {
		neck = gear.nicander,
	}

	-- Merged over the engaged set while a dual-wield trait is active.
	-- Only 9 is needed with Haste Samba and /DNC. /NIN needs 11 without Haste Samba and none with it.
	sets.DualWield = {
		waist = gear.reiki,
		--left_ear="Eabani Earring",
	}

	-- Engaged sets. sets.OffenseMode is worn in every offense mode, and the current mode's set merges over it.
	sets.OffenseMode = {}

	-- TP mode, and the base most other modes build on.
	sets.OffenseMode.TP = {
		range = Instrument.TP,
		head = gear.bunziHead,
		body = gear.asheraHarness,
		hands = gear.bunziHands,
		legs = gear.volteTights,
		feet = gear.nyameFeet,
		neck = gear.bardCharmPlusTwo,
		waist = gear.windbuffetPlusOne, -- swapped out with Dual Wield
		left_ear = gear.telos,
		right_ear = gear.balderEarringPlusOne,
		left_ring = gear.lehkoHabhokaRing,
		right_ring = gear.chirichPlusOne2,
		back = gear.nullShawl,
	}

	sets.OffenseMode.DT = set_combine(sets.OffenseMode.TP, {
		legs = gear.filiLegsPlusThree,
		right_ring = gear.moonlightRing2,
	})

	sets.OffenseMode.ACC = set_combine(sets.OffenseMode.TP, {})

	sets.OffenseMode.PDL = set_combine(sets.OffenseMode.TP, {
		left_ring = gear.sroda,
	})

	sets.OffenseMode.MEVA = set_combine(sets.OffenseMode.DT, {
		waist = gear.carriers,
	})

	sets.OffenseMode.SB = set_combine(sets.OffenseMode.TP, {
		left_ring = gear.chirichPlusOne1,
		right_ring = gear.chirichPlusOne2,
	})

	sets.OffenseMode.CRIT = set_combine(sets.OffenseMode.TP, {
		body = gear.adamantiteArmor,
		right_ring = gear.moonlightRing,
	})

	sets.Precast = {}

	-- Fast cast, worn at the start of every spell.
	sets.Precast.FastCast = {
		range = Instrument.QuickMagic, -- 4 Quick Magic
		head = gear.bunziHead,   -- 10
		body = gear.inyangaBodyPlusTwo, -- 14
		hands = gear.leylineGlovesFCB, -- 8
		legs = gear.volteLegs,   -- 9
		feet = gear.filiFeetPlusThree, -- 13
		neck = gear.voltsurge,   -- 4
		waist = gear.witful,     -- 3 3 Quick Magic
		left_ear = gear.etiolation, -- 1
		right_ear = gear.tuisto,
		left_ring = gear.kishar, -- 4
		right_ring = gear.weatherspoon, -- 5 3 Quick Magic
		back = gear.brdFCPdt,    -- 10
	}                            -- 81 FC and 10 Quick Magic

	-- Merged over the fast-cast set for songs. Fast cast is easy to cap, so this can stay empty.
	sets.Precast.Songs = {}
	-- Merged over the fast-cast set for cures.
	sets.Precast.Cure = {}
	-- Merged over the fast-cast set for enhancing magic.
	sets.Precast.Enhancing = {}
	-- Merged over the fast-cast set for Utsusemi.
	sets.Precast.Utsusemi = {}
	-- Merged over the fast-cast set for blue magic.
	sets.Precast.BlueMagic = {}

	-- The base for every cast, songs included, and dressed here for song duration and potency. sets.Idle is merged underneath it, so a slot this set does not name keeps its idle piece.
	sets.Midcast = set_combine(sets.Idle, {
		head = gear.filiHeadPlusThree, -- 11
		body = gear.filiBodyPlusThree,
		hands = gear.filiHandsPlusThree, -- 11
		legs = gear.inyangaLegsPlusTwo,
		feet = gear.briosoFeetPlusFour,
		neck = gear.moonbowWhistlePlusOne,
		waist = gear.carriers,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.alabaster,
		left_ring = gear.murky,
		right_ring = gear.defending,
		back = gear.brdFCPdt,
	})

	-- Worn for dummy songs, the ones the engine's SongCount list names. Gear here replaces the song gear above to keep a dummy's duration low. Ballad is the lowest duration song.
	sets.Midcast.DummySongs = set_combine(sets.Idle, {})

	-- Cure spells. Curaga shares this table below.
	sets.Midcast.Cure = {
		range = gear.linosFC,
		head = gear.kaykausHeadPlusOnePathB,
		body = gear.kaykausBodyPlusOnePathD,
		hands = gear.kaykausHandsPlusOnePathB,
		legs = gear.kaykausLegsPlusOnePathB,
		feet = gear.kaykausFeetPlusOnePathB,
		neck = gear.loricatePlusOne,
		waist = gear.platinumMoogleBelt,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.alabaster,
		left_ring = gear.murky,
		right_ring = gear.defending,
		back = gear.brdFCPdt,
	} -- 50% Cure Potency / 15% Cure Potency II

	sets.Midcast.Regen = {}
	sets.Midcast.Refresh = {}

	-- Enhancing magic, dressed for duration. Raise, Reraise and the -na spells take it too.
	sets.Midcast.Enhancing = {
		sub = gear.ammurapi,
		range = gear.linosFC,
		head = gear.telchineCapBEnhDur,
		body = gear.telchineChasubleBEnhDur,
		hands = gear.telchineGlovesCEnhDur,
		legs = gear.telchineBraconiBEnhDur,
		feet = gear.telchinePigachesBEnhDur,
		neck = gear.incanterTorque,
		waist = gear.embla,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.alabaster,
		left_ring = gear.murky,
		right_ring = gear.moonlightRing,
		back = gear.brdFCPdt,
	}

	-- Merged over the enhancing set: Elemental for elemental bar spells, Status for status bar spells, Skill for skill-based buffs, Gain for Gain spells.
	sets.Midcast.Enhancing.Elemental = {}
	sets.Midcast.Enhancing.Status = {}
	sets.Midcast.Enhancing.Skill = {}
	sets.Midcast.Enhancing.Gain = {}

	-- Curaga follows different rules than Cure but shares its table here. Give it a table of its own to dress it differently.
	sets.Midcast.Curaga = sets.Midcast.Cure

	-- Cursna, merged over the enhancing set.
	sets.Midcast.Cursna = set_combine(sets.Midcast.Cure, {
		range = gear.linosFC,
		head = gear.kaykausHeadPlusOnePathB,
		body = gear.adamantiteArmor,
		hands = gear.inyangaHandsPlusTwo,
		legs = gear.kaykausLegsPlusOnePathB,
		feet = gear.gendewithaGaloshesPlusOne,
		neck = gear.loricatePlusOne,
		waist = gear.witful,
		left_ear = gear.odnowaPlusOne,
		right_ear = gear.alabaster,
		left_ring = gear.menelausRing,
		right_ring = gear.haomaRing,
		back = gear.brdFCPdt,
	})

	sets.Midcast.Divine = {}
	sets.Midcast.Phalanx = {}

	-- Enfeebling magic, dressed for magic accuracy. Enfeebling songs take it too, with their family set merged over it.
	sets.Midcast.Enfeebling = {
		sub = gear.ammurapi,
		range = Instrument.Potency,
		head = gear.briosoHeadPlusFour,
		body = gear.briosoBodyPlusFour,
		hands = gear.briosoHandsPlusFour,
		legs = gear.filiLegsPlusThree,
		feet = gear.briosoFeetPlusFour,
		neck = gear.moonbowWhistlePlusOne,
		waist = gear.nullWaist,
		left_ear = gear.crepuscularEar,
		right_ear = gear.regalEarring,
		left_ring = gear.stikiniRingPlusOne,
		right_ring = gear.stikiniRingPlusOne,
		back = gear.brdFCPdt,
	}

	-- Merged over the enfeebling set for the spells the engine's lists name: MACC for accuracy-based spells, Potency for potency-based ones, Duration for duration-based ones.
	sets.Midcast.Enfeebling.MACC = {}
	sets.Midcast.Enfeebling.Potency = {}
	sets.Midcast.Enfeebling.Duration = {}

	-- Song family sets, merged over a song's other midcast sets. Every song belongs to one family, and dummy songs skip these.

	-- Lullaby, dressed for duration.
	sets.Midcast.Lullaby = set_combine(sets.Midcast.Enfeebling, {
		body = gear.filiBodyPlusThree,
		legs = gear.inyangaLegsPlusTwo,
	})

	sets.Midcast.Finale = {}
	sets.Midcast.Requiem = {}
	sets.Midcast.Elegy = {}
	sets.Midcast.Prelude = {}
	sets.Midcast.Madrigal = { head = gear.filiHeadPlusThree }
	sets.Midcast.Minuet = { body = gear.filiBodyPlusThree }
	sets.Midcast.March = { hands = gear.filiHandsPlusThree }
	sets.Midcast.Ballad = { legs = gear.filiLegsPlusThree }
	sets.Midcast.Scherzo = { feet = gear.filiFeetPlusThree }
	sets.Midcast.Mazurka = {}
	sets.Midcast.Paeon = { head = gear.briosoHeadPlusFour }
	sets.Midcast.Threnody = { body = gear.mousaiBodyPlusOne }
	sets.Midcast.Minne = { legs = gear.mousaiLegsPlusOne }
	sets.Midcast.Mambo = {}
	sets.Midcast.Carol = { hands = gear.mousaiHandsPlusOne }
	sets.Midcast.Etude = { head = gear.mousaiHeadPlusOne }
	sets.Midcast.Dirge = {}
	sets.Midcast.Sirvente = {}
	sets.Midcast.Aria = {}

	-- Sets named for one spell. Each replaces the family set for that spell.
	sets.Midcast["Stoneskin"] = {
		waist = gear.siegel,
	}

	-- Job abilities. sets.JA is worn for every job ability, and the set named for the ability merges over it.
	sets.JA = {}
	sets.JA["Nightingale"] = { feet = gear.bihuFeetPlusFour }
	sets.JA["Troubadour"] = { body = gear.bihuBodyPlusFour, }
	sets.JA["Soul Voice"] = { legs = gear.bihuLegsPlusFour }
	sets.JA["Tenuto"] = {}
	sets.JA["Marcato"] = {}
	sets.JA["Clarion Call"] = {}
	sets.JA["Pianissimo"] = {}

	-- Dancer abilities from the subjob. Each family set is worn for its abilities, and a child named for the ability merges over it.

	sets.Flourish = set_combine(sets.Idle.DT, {})
	sets.Jig = set_combine(sets.Idle.DT, {})
	sets.Step = set_combine(sets.Idle.DT, {})
	sets.Samba = set_combine(sets.Idle.DT, {})
	sets.Waltz = set_combine(sets.Idle.DT, {
		range = Instrument.Idle, -- 4
		legs = gear.dashingSubligar, -- 10
		back = gear.brdWaltz, --10
	})                       -- 24% Potency

	-- Weaponskill base, worn for every weaponskill. The set named for the weaponskill merges over it.
	sets.WS = {
		range = Instrument.WS,
		head = gear.nyameHead,
		body = gear.bihuBodyPlusFour,
		hands = gear.nyameHands,
		legs = gear.nyameLegs,
		feet = gear.nyameFeet,
		neck = gear.republicanPlatinumMedal,
		waist = gear.sailfi,
		left_ear = gear.moonshade,
		right_ear = gear.regalEarring,
		left_ring = gear.sroda,
		right_ring = gear.epimanondas,
		back = gear.brdWSDDt,
	}

	-- Merged over the weaponskill sets in PDL mode, for physical damage limit when attack is capped.
	sets.WS.PDL = {
		body = gear.bunziBody,
		left_ring = gear.sroda,
	}

	-- WSD and MAB are not offense modes. They are worn only through the weaponskill sets below that are built from them.
	sets.WS.WSD = set_combine(sets.WS, {

	})

	sets.WS.MAB = set_combine(sets.WS, {
		range = Instrument.MAB,
		neck = gear.sibylScarf,
		waist = gear.orpheusWaist,
		body = gear.nyameBody,
		left_ring = gear.metamorphPlusOne,
		back = gear.brdWSDInt,
	})

	-- Merged in ACC mode after the set named for the weaponskill, so its slots win. Name only the slots ACC mode should change. A weaponskill with an ACC set of its own skips it.
	sets.WS.ACC = {}

	-- MEVA, CRIT and SB merge over the weaponskill sets in those modes, the same way.
	sets.WS.MEVA = {
		neck = gear.warderCharmPlusOne,
		waist = gear.carriers,
	}

	sets.WS.CRIT = {
		neck = gear.fotiaNeck,
		waist = gear.fotiaWaist,
		left_ring = gear.hetairoi,
		right_ring = gear.ilabrat,
		back = gear.brdWSDDt,
	}

	sets.WS.SB = {
		left_ring = gear.chirichPlusOne1,
		right_ring = gear.chirichPlusOne2,
	}

	sets.WS["Savage Blade"] = set_combine(sets.WS.WSD, {})

	sets.WS["Mordant Rime"] = set_combine(sets.WS, {
		range = Instrument.Mordant,
		neck = gear.bardCharmPlusTwo,
		waist = gear.grunfeldRope,
		left_ear = gear.ishvara,
		left_ring = gear.metamorphPlusOne,
		back = gear.brdWSDChr,
	})

	sets.WS["Evisceration"] = sets.WS.CRIT

	sets.WS["Aeolian Edge"] = set_combine(sets.WS.MAB, {
	})

	sets.WS["Burning Blade"] = sets.WS.MAB
	sets.WS["Shining Blade"] = set_combine(sets.WS.MAB, {
		right_ring = gear.weatherspoon,
	})
	sets.WS["Shining Strike"] = set_combine(sets.WS.MAB, {
		right_ring = gear.weatherspoon,
	})

	sets.WS["Shell Crusher"] = set_combine(sets.WS.WSD, {
	})

	-- Treasure Hunter gear, worn on an action or melee swing against a monster not yet tagged, and throughout a fight in Full Time mode. It is never worn in None mode, where every job but Thief starts.
	sets.TreasureHunter = {
		body = gear.volteJupon,
		legs = gear.volteHose,
		waist = gear.chaac,
	}
end

-------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE UNLESS YOU NEED TO MAKE JOB SPECIFIC RULES
-------------------------------------------------------------------------------------------------------------------

-- Called when the player's subjob changes.
function sub_job_change_custom(new, old)
	-- A common use is switching the macro book or set.
end

-- Called before each action, after the engine's own checks. Cancel the action here with cancel_spell(). Nothing it returns is used.
function pretarget_custom(spell, action)

end

-- Gear returned here merges over the engine's precast set for the action.
function precast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Gear returned here merges over the engine's midcast set for the action.
function midcast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Gear returned here merges over the idle or engaged set worn when an action ends.
function aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called when a buff is gained or lost, except while an action is in flight. Gear returned here merges over the idle or engaged set.
function buff_change_custom(name, gain)
	local equipSet = {}

	return equipSet
end

-- Gear returned here merges over every idle and engaged build: after each action, on a buff, status or mode change, and when you start or stop moving.
function choose_set_custom()
	local equipSet = {}

	return equipSet
end

-- Called when your status changes, such as engaging, disengaging or resting. Gear returned here merges over the idle or engaged set that follows.
function status_change_custom(new, old)
	local equipSet = {}

	return equipSet
end

-- Called for a "gs c" command the engine does not handle itself, and for the weapon mode, job mode and job mode 2 commands, which call it before the gear rebuild. The command arrives in lowercase.
function self_command_custom(command)

end

-- Called when the job file unloads, after the engine has released its keys and held slots.
function user_file_unload()

end

-- Called when a pet is summoned or lost. Gear returned here merges over the idle or engaged set.
function pet_change_custom(pet, gain)
	local equipSet = {}

	return equipSet
end

-- Called when a pet's action ends. Gear returned here merges over the idle or engaged set.
function pet_aftercast_custom(spell)
	local equipSet = {}

	return equipSet
end

-- Called while a pet's action is in flight. Gear returned here merges over sets.Pet_Midcast and the set named for the action.
function pet_midcast_custom(spell)
	local equipSet = {}

	return equipSet
end
