# Patch Notes

Release-by-release detail for Rahvin GearSwap, and for the Mirdain-era releases it grew from.

The [README](README.md) describes what the engine does **now**. This file records
**what changed and when**, newest first, and keeps every release. Check your running
version in game with `//gs c version`.

Each release is broken into the same four headings, so you can scan for what matters:

- **Notices** — changes that need something from you before they take effect.
- **New and Changed Features** — what the release adds or does differently.
- **Optimizations** — the same behavior, cheaper.
- **Bug Fixes** — things that now work as intended.

A heading is omitted when a release has nothing under it.

**Credits.** Mirdain-Include was created by **Mirdain**; version 1.5.12 is the original
and the base this suite was forked from. Everything from **1.6.0** forward — engine
revisions and sample job files alike — was conceived and programmed by **Rahvin**. From
**2.0** the suite is released as **Rahvin GearSwap**, continuing the same sequence.

| Version | Summary |
|---|---|
| [2.1](#21) | Buff sets worn while a buff is up, day and weather gear chosen by what it adds, weapons kept in hand through every weaponskill, your own mode keys, one settings file per character |
| [2.0](#20) | Rahvin GearSwap: new name, new folder; four display styles and the slot rig; the weapon lock on F10; the disable and strip holds; the capacity cape and Dynamis neck locks; a much larger gear library |

The releases below shipped under the suite's former name, **Mirdain Gearswap Enhanced by
Rahvin**; 2.0 above follows 1.7.3 directly.

| Version | Summary |
|---|---|
| [1.7.3](#173) | Sets that were equipping nothing now equip; two commands to hold an item in a slot; Aftermath gear layers correctly; every sample job file refreshed |
| [1.7.2](#172) | Crash fixes for subtarget macros; reporting reaches pet actions and songs; weapon-mode and auto-buff costs cut |
| [1.7.1](#171) | Per-action gear reporting and warning throttle; status box redesign; the HP-priority gear library |
| [1.7.0](#170) | Thrown-item job abilities; cancel and override for item use; reload recovery; `gs c enchinfo` and `gs c hoxneinfo` |
| [1.6.6](#166) | Enchanted item engine rebuilt around live cooldowns; Hoxne split into two on states |
| [1.6.5](#165) | Status box rebuild; mode arguments validated; SpellReceived reduced to OFF/ON |
| [1.6.4](#164) | 196 blue magic spells classified; item-search bag list corrected |
| [1.6.0 – 1.6.3](#160--163) | The initial enhancement work over Mirdain 1.5.x |
| [1.5.12](#1512) | Mirdain's original |

---

## 2.1

2.1 puts on gear for a buff with no code in your job file, chooses day, weather and distance
gear by what each piece adds, and keeps your weapons in hand through every weaponskill. You
can choose your own mode keys, and each character keeps its own settings file. Most job files
written for 2.0 need no edits. The Notices below cover the ones that do.

### Notices

- **Each character has its own settings file.** The settings file holds your box positions,
  display style, chat toggles and keys. It lives in
  `Windower4/addons/GearSwap/data/<CharacterName>/settings.xml`, the same folder GearSwap
  checks for that character's own job files. The first time each character loads 2.1, the
  engine copies that character's settings from `data/settings.xml` into the new file, and
  Windower confirms it once with `New file: data/<CharacterName>/settings.xml`. The engine
  never writes to `data/settings.xml`. Edit the character's own file from now on, and only
  with GearSwap unloaded (`//lua unload gearswap`), because every save rewrites the whole
  file. To start a character over from defaults, delete its file. While `data/settings.xml`
  is still there, the next load copies it again, so delete that one too once every character
  has a file of its own.
- **A weaponskill keeps your weapons in hand.** Swapping main or sub resets your TP, and so
  does swapping a ranged weapon, so a weaponskill that swapped one would fail. Main, sub and
  range stay exactly as they are for the whole weaponskill, whatever your weaponskill sets or
  `sets.Idle` name. A Bard's instrument and a Geomancer's handbell still swap. With
  `gs c warn` on, a set that names one of those slots is pointed out once a minute:

  ```
  [Savage Blade] sets.Idle names main, sub; a weaponskill keeps the weapons in hand.  Silencing warnings for 60s.
  ```

  Take the slot out of the set it names, since weapons belong in `sets.Weapons`. Under the
  weapon lock the slots stay put without the line.
- **A weaponskill mode set names only what the mode changes.** In any offense mode but `TP`,
  a weaponskill wears `sets.WS`, then the set named for the weaponskill, then the mode's set,
  such as `sets.WS.ACC`. The mode's set goes on last, so one built from the whole base set,
  `sets.WS.ACC = set_combine(sets.WS, { ... })`, puts every base piece back over your named
  weaponskill's gear. To check your own file, look for a mode set written as
  `set_combine(sets.WS, ...)` or `set_combine(sets.WS.RA, ...)`. To fix it, keep only the
  pieces the mode changes: `sets.WS.ACC = { ... }`. A weaponskill's own mode set, such as
  `sets.WS['Savage Blade'].ACC`, takes the place of `sets.WS.ACC` for that weaponskill.
- **A table named after a buff is a buff set.** Inside `sets.OffenseMode`, `sets.Idle`,
  `sets.WS`, `sets.Midcast`, `sets.Helix`, `sets.Storms`, a Geomancy spell's own set,
  `sets.Geomancy.Indi`, `sets.Geomancy.Geo`, `sets.Diffusion`, `sets.Ready` and the sets the
  engine wears from them, a table whose name is a buff's name is worn automatically while that
  buff is on you. New and Changed Features lists exactly where. If your own
  file keeps a table such as `sets.Idle.Refresh` for some other purpose, rename it, or it goes
  on every time Refresh does. Spell sets inside `sets.Midcast`, such as
  `sets.Midcast.Refresh`, stay spell sets. With `gs c warn` on, a name inside a mode set such
  as `sets.OffenseMode.TP` that is neither a gear slot nor a buff is pointed out as your file
  loads:

  ```
  sets.OffenseMode.TP.Footwrk is not a buff name
  ```

- **`sets.Weapons['Light Bonus']` is worn exactly as you wrote it.** On a Cure, Cura or
  Curaga cast on Lightsday or in Light weather, a Light Bonus set with gear in it goes on
  whole, whether or not you carry Chatoyant Staff. Its own main and sub go on too, unless the
  weapon lock holds them. If you leave the set empty, the engine puts Chatoyant Staff in main
  when you carry one. If you declared this set, check what it names.
- **Five commands save as they change.** `gs c display`, `gs c debug`, `gs c warn`,
  `gs c info` and `gs c gearreporting` write your choice to the settings file, as
  `gs c displaymode` and `gs c displaystyle` do. A channel you turn off for one fight stays
  off after a reload until you turn it back on.
- **The engine handles four new commands and more arguments.** `gs c help`, `gs c keybind`,
  `gs c displaypos` and `gs c displaycells` are engine commands, and `display`,
  `displaymode`, `debug`, `warn`, `info` and `gearreporting` take `on` or `off`. If your job
  file has its own `gs c` command by one of these names, rename yours. A mistyped argument to
  any of these, or to `naked`, `weaponsonly`, `abysseaproc`, `capacity`, `aptitude`,
  `mecisto`, `dynamisrp`, `jubilee`, `disable` or `enable`, is answered by the engine and
  never reaches your job file. `gs c help` replies with the list of groups, and
  `gs c keybind` with the modes or the keys it accepts. The rest reply with their usage line
  while `gs c warn` is on.
- **The engine supplies no `round` function.** A job file that calls `round` stops with a
  Lua error naming it, `attempt to call global 'round' (a nil value)`, until it carries a
  copy of its own.

**If you copy a 2.1 sample file:**

- **Three samples offer one more offense mode.** DRK and RDM add `MEVA`, and PUP adds `PDT`.
  If you copy one of these samples, the offense mode key (F12 unless you changed it) and
  `gs c offensemode` have one more stop in their cycle. Take the mode out of
  `state.OffenseMode:options(...)` if you do not want it.
- **Six sample files wear their buff gear through buff sets.** A job file you keep works
  unchanged. If you copy one of these samples, its buff gear sits at the new names below and
  needs no code of its own:

  | Sample | In the 2.0 sample | In the 2.1 sample |
  |---|---|---|
  | MNK | `sets.Impetus` | `sets.OffenseMode.Impetus`, also worn on weaponskills as `sets.WS.Impetus` |
  | MNK | `sets.Foot_Work` | `sets.OffenseMode.Footwork` |
  | MNK | `sets.Boost` | `sets.OffenseMode.Boost`, also `sets.Idle.Boost` and `sets.WS.Boost` |
  | PLD | `sets.Cover` | `sets.Idle.Cover` and `sets.OffenseMode.Cover` |
  | PLD | `sets.Rampart` | `sets.Midcast.Rampart`, worn on every spell while Rampart is up, commented out and ready to fill |
  | RDM | `sets.Saboteur` | `sets.Midcast.Enfeebling.Saboteur` |
  | RUN | `sets.Embolden` | `sets.Midcast.Enhancing.Embolden` |
  | SAM | `sets.Seigan` and `sets.ThirdEye` | `sets.OffenseMode.Seigan`, with `sets.OffenseMode.Seigan['Third Eye']` inside it, commented out and ready to fill |
  | SCH | stratagem sets such as `sets.Immanence` and `sets.Rapture` | buff sets inside its midcast sets, with Klimaform left in the file's own code |

  A Monk file that still declares `sets.Impetus`, `sets.Foot_Work` or `sets.Boost` also keeps
  working, and the code it carries for them can go. The new RUN and SCH samples print no
  `Embolden Set` or stratagem `... Set` line. The action line names each buff set a cast
  wears instead.
- **Every sample file ships empty `XIRoll` sets.** `sets.Idle.XIRoll` and
  `sets.Idle.TP.XIRoll` (RDM has only the first) are ready for gear such as Roller's Ring
  (see New and Changed Features). They start empty, so `gs c checksets` lists them among your
  empty sets until you fill them or delete the lines.

### New and Changed Features

**Buff sets**

- **Gear for a buff, with no code.** A buff set is a table named after a buff, placed inside
  a set the engine already wears. While that buff is on you, the buff set goes on over the set
  it sits in, and it comes off when the buff ends. Spell the buff's name as the game does, in
  any capitalization:

  ```lua
  sets.OffenseMode.Impetus = { body = gear.bhikkuBodyPlusThree }             -- engaged, any offense mode
  sets.OffenseMode.TP.Footwork = { feet = gear.anchoriteFeetPlusFour }       -- engaged, TP mode only
  sets.WS['Victory Smite'].Footwork = { feet = gear.anchoriteFeetPlusFour }  -- one weaponskill
  sets.Midcast.Enfeebling.Saboteur = { hands = gear.lethargyHandsPlusThree } -- enfeebling magic
  ```

- **Where buff sets work.** A buff set is worn only inside a set the engine wears for what
  you are doing:

  | When | Buff sets work inside |
  |---|---|
  | Engaged | `sets.OffenseMode`, and the set for your offense mode, such as `sets.OffenseMode.TP` |
  | Idle | `sets.Idle`, the set for your offense mode, such as `sets.Idle.TP`, and `sets.Idle.Resting` |
  | Weaponskills | `sets.WS` and `sets.WS.RA`, the set named for the weaponskill and its mode sets, and the mode sets other than `TP`, such as `sets.WS.ACC` and `sets.WS.RA.ACC` |
  | Spells | `sets.Midcast`, and the set a spell wears under it, such as `sets.Midcast.Cure`, `sets.Midcast.Enfeebling` or `sets.Midcast.BlueMagic.Nuke` |
  | Shots | `sets.Midcast.RA`, its mode sets other than `TP`, and `sets.Midcast.RA.TripleShot`, `.DoubleShot` and `.Barrage` |
  | Job sets | `sets.Helix` with its `Dark` and `Light` sets, `sets.Storms`, a Geomancy spell's own set, `sets.Geomancy.Indi` with its `Entrust` set, `sets.Geomancy.Geo`, `sets.Diffusion` and `sets.Ready` |

  A buff set anywhere else is never worn, and nothing says so. That includes `sets.Precast`,
  `sets.JA`, `sets.Idle.Pet`, `sets.Idle.Sublimation`, `sets.Movement`, `sets.WS.TP`,
  `sets.WS.RA.TP` and `sets.Midcast.RA.TP`, and `sets.Midcast.BlueMagic` and `sets.Geomancy`
  themselves. `sets.Midcast.SIRD` takes none either, and with `gs c warn` on it says so as
  your file loads. Treasure Hunter gear, your `Ammo` round and the weapon lock keep their
  slots over a buff set.
- **Buff sets nest.** `sets.OffenseMode.Impetus.Footwork` is worn while Impetus and Footwork
  are both up. Nesting goes three buffs deep, and the deeper set wins a slot the two share.
- **`XIRoll` sets.** A Corsair roll lands with a number from 1 to 11. A table named `XIRoll`,
  placed anywhere a buff set can go, is worn while any Corsair roll on you stands at 11, for
  gear such as Roller's Ring. After a reload or a job change it waits for the next roll or
  Double-Up, or for another of your characters on the same computer, in your party, running
  2.1 and holding that roll, to share the total.
- **Every action line names the buff sets it wore**, with `gs c info` on, for example
  `[Victory Smite] [sets.WS.Victory Smite][Used] + [sets.WS.Impetus][Used]`.
  `gs c gearreporting` lists them too.
- **`gs c checksets` names an empty set under every name you gave it.**

**Day, weather and distance gear**

- **Each piece is chosen by what it adds.** Some gear adds power to a spell whose element
  matches the day or the weather, or to one cast at a close target. On a nuke, an elemental
  ninjutsu, a blue magic nuke, a magical weaponskill, a helix, one of the six elemental Quick
  Draw shots, or a Cure, Cura or Curaga, the engine weighs each such piece you carry and can
  wear, then wears the best one for each slot. The pieces are Hachirin-no-Obi, the spell's own
  elemental obi (Karin, Hyorin, Furin, Dorin, Rairin, Suirin, Korin or Anrin), Orpheus's Sash
  within 10 yalms of the target, Twilight Cape and Zodiac Ring. A helix takes the sash, the
  cape and the ring but never an obi. Zodiac Ring serves elemental magic on the day that
  matches the spell's element, and never on Lightsday or Darksday. Cures take no sash, and a
  single-target Cure keeps your own back piece.
- **One line names what it wore and what each piece adds**, with `gs c info` on:

  ```
  [Fire VI] waist: Hachirin-no-Obi (+6.7%, day), back: Twilight Cape (+5.0%, day), right_ring: Zodiac Ring (+3.0%, day)
  ```

- **Zodiac Ring goes in your right ring.** Add `Elemental_Bonus_Ring_Slot = "left_ring"` to
  your job file to use the left. Every sample file declares the line.
- **A piece you list in `Bonus_Keep` stays put.** Oneiros Rope is listed already, so a spell
  set that names it in its waist keeps it. Add your own with
  `Bonus_Keep['Item Name'] = true`, spelled exactly as the game spells it.
- **Gale Axe and Uriel Blade** take the day, weather and distance gear as magical
  weaponskills.
- **Nine new gear library entries**: `gear.karinObi`, `gear.hyorinObi`, `gear.furinObi`,
  `gear.dorinObi`, `gear.rairinObi`, `gear.suirinObi`, `gear.korinObi`, `gear.anrinObi` and
  `gear.twilightCape`.

**Weapons**

- **Geomancers get a third weapon lock value, `Geomancy`.** The weapon lock keeps the weapons
  your weapon mode names in hand. `Geomancy` works like `Locked`, except that a Geomancy spell
  wears the main and sub its own set names for the cast, and your weapon set comes back
  afterward. Choose it with `gs c weaponlock Geomancy`, or cycle to it with F10.

**Keys and help**

- **Choose your own mode keys.** `gs c keybind <mode> <key>` moves one mode to another key.
  A key is F1 to F12, alone or with one of Ctrl, Alt or Shift, typed as `^f5`, `ctrl+f5` or
  `Ctrl F5`. `gs c keybind <mode> none` takes a mode off its key,
  `gs c keybind <mode> default` puts it back on its usual key, and `gs c keybind default`
  resets all eight. The modes are `offensemode`, `weaponmode`, `weaponlock`,
  `treasurehunter`, `jobmode`, `jobmode2`, `hoxne` and `spellreceived`.
- **Your keys are checked and saved.** A key another mode already uses is refused, and the
  answer names that mode. Binding a key replaces any other Windower bind on it. Your keys are
  saved for each character, and the engine leaves a key set to `none` alone, so a Windower
  bind of your own on it survives job changes.
- **The key list at load is two lines**, and `gs c keybind` shows it again:

  ```
  Keys: [F12] Stance  [F9] Weapon Mode  [F10] Weapon Lock  [F11] TH Mode
  Keys: [Ctrl+F10] Hoxne Ampulla  [Ctrl+F9] Spell Received (Multibox)
  ```

  When your file names its job modes, their keys lead the second line. If that line would pass
  100 characters, as long job-mode names can make it, the job-mode keys take a line of their
  own, making three.
- **`gs c help`** lists every command by group, with each mode's current key.
  `gs c help <group>` explains the commands in one group: `modes`, `display`, `holds`,
  `locks`, `items`, `utility` or `diagnostics`.

**Display and multiboxing**

- **Commands you can send to every character at once.** Sent through Windower's Send addon,
  each of these leaves every character in the same state, whatever state it was in.
  `gs c displaypos <x> <y>` places the status box and `gs c displaypos debug <x> <y>` the
  debug box. With no numbers, `gs c displaypos` reports where both boxes are.
  `gs c displaycells <n>` sets a minimum width, in character cells, for the value column of
  the status box. `display`, `displaymode`, `debug`, `warn`, `info` and `gearreporting` take
  `on` or `off`. Each of these saves.
- **The rig shows three more holders in colors of their own.** The rig is the LATTICE
  style's grid of your sixteen gear slots, each cell colored by whatever is holding that
  slot. Sleep gear, the item a spell requires, and gear worn for a spell another of your
  characters is casting on you each have their own color.
- **At the character select screen,** a display, chat-channel or key-binding command changes
  nothing, and with `gs c warn` on it says so in the chat log.

**Sample files**

- **Every sample file** declares `Elemental_Bonus_Ring_Slot` and its `XIRoll` sets.
- **The SMN sample's `sets.Idle`** names no weapon, and its Garland of Bliss, Shattersoul and
  Cataclysm use a new `sets.WS.MAB` that names none.
- **The BRD, BST, COR, DRG, DRK, MNK, PUP, RDM, RNG, SAM and WAR samples** name only what each
  weaponskill mode changes, so a named weaponskill keeps its own gear in every mode. WAR's
  `sets.WS.CRIT` holds only its nine critical-hit pieces.
- **The MNK sample** also wears Boost on weaponskills, for chaining a Boost into a
  weaponskill between auto-attacks. Its SB and CRIT modes are built on its TP set, so their
  gear changes.
- **The RDM and SAM samples' `sets.WS.RA` names the arrow**, so a ranged weaponskill fires it
  in every offense mode.
- **The RUN sample's Embolden set** also covers Phalanx, Stoneskin, Aquaveil, Foil, Regen and
  Refresh, and **the RDM sample's Saboteur set** also covers Diaga and Dispelga.
- **The BLM sample's `sets.JA`** lists Black Mage's own abilities, plus the few a Geomancer or
  Red Mage subjob reaches.
- **Buff sets ready to fill.** These samples carry buff sets written out and commented out.
  Remove the comment marks and add your gear:

  | Sample | Buff sets |
  |---|---|
  | BLM | Mana Wall |
  | BLU | Chain Affinity, Burst Affinity, Efflux |
  | BST | Killer Instinct |
  | DNC | Climactic Flourish, Striking Flourish, Saber Dance |
  | DRK | Souleater, Dark Seal, Nether Void |
  | NIN | Migawari, Futae |
  | RDM | Composure |
  | RUN | Pflug |
  | SAM | Meikyo Shisui, Sekkanoki, Sengikori |
  | SCH | Penury |
  | SMN | Avatar's Favor |
  | THF | Trick Attack, Sneak Attack |
  | WAR | Restraint, Retaliation |
  | WHM | Afflatus Solace, and Divine Caress under each status-removal spell's own set |

- **The WHM and GEO samples** explain the Light Bonus set and the Geomancy lock beside the
  sets they affect.

### Optimizations

- **A buff gained or lost skips the gear swap when everything it calls for is already on.**
- **In Treasure Hunter's `Tag` and `SATA` modes, gear is rebuilt once, when a monster is
  first tagged.** Later swings against it trigger no rebuild.
- **Loading a job file leaves an up-to-date settings file untouched**, and a dragged box is
  saved once, a second after it comes to rest.
- **The message another of your characters sends when its spell finishes costs less to
  read.**

### Bug Fixes

- **Both boxes leave the screen when you log out**, panel and all, and come back as you left
  them at the next login.
- **A box dropped while zoning keeps its place**, and so does one dropped just before a job
  change.
- **One character's save never overwrites another's.** A settings file that cannot be read
  is left untouched. The character runs on the default settings, chat names the file and the
  reason, and nothing is saved until you fix or delete the file and reload GearSwap.
- **`on` and `off` work in any capitalization** for `gs c naked`, `weaponsonly`,
  `abysseaproc`, `capacity`, `aptitude`, `mecisto`, `dynamisrp` and `jubilee`.
- **A buff that lands in the seconds after your own spell puts its gear on right away.**
- **Under the weapon lock, the locked weapons stay in hand.** A pet, Sublimation or movement
  set that names main or sub leaves them in place.
- **After your pet acts, the set you go back to keeps the gear your job file adds to it.**
- **A pet action dressed by your job file's `pet_midcast_custom` says so.** When
  `sets.Pet_Midcast` is empty and your pet code supplies the gear, as the SMN sample's blood
  pacts do, the action line reads
  `[Rock Buster] [sets.Pet_Midcast][Empty] + [pet_midcast_custom][Used]`, and the gear report
  names the same hook.
- **A spell whose precast set names an ammo gets its handbell or instrument back for the
  midcast.**
- **Meteor and other spells with no element take no day or weather gear.**
- **An elemental ninjutsu takes the day, weather and distance gear whether or not it has a set
  of its own**, such as `sets.Midcast['Katon: San']`.
- **The rig and the status box's hold row keep up with every hold.** An item use, Sleep
  gear, a spell's required item, gear worn for another character's spell and the weapon lock
  recolor their slots at once, and a lock such as `gs c capacity` that switches itself off
  clears its mark from the hold row.
- **Reloading GearSwap while asleep frees the slots your Sleep gear was holding.**
- **Every sample keeps each earring and ring on one side** through idle, engaged,
  weaponskills, spells and abilities, so each set's earrings and rings go on as written. Three
  cases still move a piece to the other side: MNK's Lehko's Ring and PLD's Telos Earring when
  you switch mode while engaged, and BLU's Hashishin Earring +1 in SB mode when you own only
  one.
- **The GEO sample's Dispelga and dark magic accuracy sets wear its enfeebling set**, through
  `sets.Midcast.Enfeebling.MACC`, which is ready for accuracy gear.
- **The COR sample's Triple Shot volleys keep the offense mode's rings, earring, cape, belt
  and bullet**, and its CRIT, PDL and SB shots fire the bullets named for those modes.
- **The RDM and SAM samples keep your melee and idle ammo in ACC mode**, and wear the arrow
  for bow shots, RDM's through the whole shot.
- **The SAM sample's `sets.Subtle_Blow` wears both rings**, and its engaged modes and
  weaponskills keep each earring and ring on the same side.
- **The DRK sample's Great Sword weapon mode wears Caladbolg.**
- **The SMN sample's Rock Buster, Mountain Buster, Crescent Fang and Spinning Dive wear its TP
  pact set**, with Enticer's Pants.
- **The PLD sample counts Metallic Body and Nat. Meditation as blue-skill spells**, and its
  Rampart line posts to the party.
- **The BLU sample's `gs c jobmode` with a value**, such as `gs c jobmode AoE`, switches the
  spell set and macros, as cycling does.

---

## 2.0

The suite becomes **Rahvin GearSwap 2.0**, continuing the numbering after 1.7.3, and the
engine moves into a `RahvinGS` folder split into its parts. Your gear sets, your modes and
your macros carry over — the shape on disk is what changes, and a handful of job-file edits
go with it. The Notices below are what to do first; the refreshed sample files carry every
one of them already.

### Notices

- **New files, and two include lines to update.** `Mirdain-Include.lua` and
  `GearSets-Include.lua` are replaced by the `RahvinGS` folder. Delete the two old files
  from `Windower4/addons/GearSwap/data/`, copy the whole folder in beside your job
  files, and change the two include lines at the top of each job file to:

  ```lua
  include('RahvinGS/GearSets-Include')
  include('RahvinGS/Rahvin-Engine')
  ```

  The refreshed samples carry the new lines already.
- **Your `settings.xml` loads, and nothing has to be deleted.** The first time each character
  loads 2.0, the display settings return to their defaults — the style and the view, whether
  the status box is shown, each box's font, size, colors and background, the LATTICE panel and
  rig settings, and the value-column floor — along with the HALO style's colors; the box
  positions you dragged are kept. One line per group says so:

  ```
  Display settings reset to defaults (version 2); box positions kept
  Halo settings reset to defaults (version 1)
  ```

  Your channel toggles — `debug`, `info`, `warn` and `gear_reporting` — and the multibox
  announce delay carry through untouched. If you would rather start from a blank file,
  delete `settings.xml`, but **unload GearSwap first** (`//lua unload gearswap`): the engine
  rewrites the whole file whenever it saves, so a file deleted while GearSwap is running
  comes back within seconds.
- **Auto Buff, Auto Tank and the Runes mode are retired.** Self-buffing belongs to the
  automation tools most players already run alongside GearSwap, and the engine hands it
  back. The engine names each leftover in chat as your job file loads, so there is
  nothing to hunt for:

  ```
  Auto Buff was removed: this job file still defines check_buff_JA or check_buff_SP and nothing calls them. They can be deleted.
  Auto Tank and Runes were removed: this job file still names one, so the mode is still shown but now drives nothing.
  ```

  Delete `check_buff_JA` and `check_buff_SP` along with any `Buff_Delay` or `Tank_Delay`
  they used, and either clear a `UI_Name` reading `Auto Tank` or `Runes` or point that
  slot at something your own file acts on.
- **<kbd>F10</kbd> cycles the weapon lock.** `gs c weaponlock` decides whether anything but
  your weapon set may write main and sub, and the key steps through its values. The capacity
  point cape lock is reached by command — `gs c capacity`, `gs c aptitude` or
  `gs c mecisto` — so bind one of those yourself if you want it on a key. The engine lists
  every keybind in chat as your job file loads.
- **`Unlocked` and `Locked` leave your weapon-mode list.** Take both values out of
  `state.WeaponMode:options(...)` and delete an empty `sets.Weapons.Unlocked` with them; the
  nine shipped templates that offered either value carry neither now. A file that keeps a
  value still works — it bridges onto the weapon lock, and the engine says so — but
  `gs c weaponlock` is where to set it. **Do not declare `state.WeaponLock:options(...)`**:
  the engine fixes that list per job — `Unlocked` and `Locked` everywhere, `Songs` on Bard,
  `Locked+R` on Corsair — and a job file's own `:options()` call wipes it. A file that wants
  to boot locked calls `state.WeaponLock:set('Locked')` and nothing else.
- **A `//gs c jobmode` macro carrying a value works only where your own file declares
  that value.** Both job-mode slots offer `OFF` and `ON` until a job file widens them
  with `state.JobMode:options(...)`, and the shipped PLD and RUN templates leave both
  slots unnamed. Declare the options you want in your file, or the value is answered
  with the valid list instead of being acted on.
- **Every ranged action's built set has to name an `ammo`.** A ranged attack, shot or ranged
  weaponskill whose set leaves the slot undeclared, blank or cleared is canceled rather than
  fired on whatever round happens to be loaded:

  ```
  No round named for Last Stand: ammo is undeclared in the built set. Canceling.
  ```

  Check the `Ammo` key for every OffenseMode a ranged job offers, and that no set in the
  chain clears the slot.
- **`//gs disable` and `//gs enable` are not tracked by this engine; `//gs c disable` and
  `//gs c enable` are.** A native word carrying a slot name answers with one line pointing at
  the tracked form, so update a macro that carries it:

  ```
  Disable: //gs disable leaves the slot untracked -- use //gs c disable <slot>... instead.
  ```

  A bare `//gs disable`, which switches your whole job file off, is left alone.
- **Set paths worth a search in your own file.** Gear declared at a name the engine does not
  read equips nothing, silently.

  | Put it here | Not here |
  |---|---|
  | `sets.WS.RA.ACC`, `.PDL`, `.SB`, `.CRIT`, `.MEVA` | `sets.WS.ACC.RA` and friends |
  | `sets.WS.RA.AM`, `.AM1`, `.AM2`, `.AM3` | `sets.WS.AM3.RA` and friends |
  | `sets.Midcast.RA.AM`, `.AM1`, `.AM2`, `.AM3` | `sets.Midcast.AM3` and friends |
  | `sets.Precast.BlueMagic` | `sets.Precast.Blue_Magic` |
  | `sets.Midcast.Drain`, `sets.Midcast.Aspir` | `sets.Midcast.Enfeebling.Drain` and `.Aspir` |
  | `sets.DualWield` | `sets.OffenseMode.DW` |
  | `sets.Precast.RA.Flurry`, `.Flurry_II` | `sets.Precast.RA.ACC` and other mode children |
  | `sets.Pet_Midcast['<Action Name>']` | `sets.JA['Spur']` and other pet-command names |

  Under `sets.Midcast.Enfeebling` the engine reads `.MACC`, `.Potency` and `.Duration` and
  nothing else. Under `sets.Precast.RA` it reads the two Flurry children and nothing else.
  And a pet command — Fight, Heel, Spur, Deploy and the rest — has no set of its own: your
  pet's own actions are dressed by the `sets.Pet_Midcast` family.
- **Eleven Dynamis Divergence necks are keyed by tier.** Each of these job necks reads
  base, `PlusOne` and `PlusTwo` in the gear library, like every other tiered piece. The
  `+2` is `gear.<name>PlusTwo`, and the tier-less key names the base neck — so a job file
  naming one of the keys on the right dresses the base piece until you point it at the tier
  you mean.

  | Job | The `+2` | The tier-less key, and what it wears |
  |---|---|---|
  | WAR | `gear.warriorsBeadPlusTwo` | `gear.warriorsBead` — Warrior's Beads |
  | MNK | `gear.monkNodowaPlusTwo` | `gear.monkNodowa` — Monk's Nodowa |
  | RDM | `gear.duelistTorquePlusTwo` | `gear.duelistTorque` — Duelist's Torque |
  | PLD | `gear.knightsBeadPlusTwo` | `gear.knightsBead` — Knight's Beads |
  | BRD | `gear.bardCharmPlusTwo` | `gear.bardCharm` — Bard's Charm |
  | RNG | `gear.scoutGorgetPlusTwo` | `gear.scoutGorget` — Scout's Gorget |
  | DRG | `gear.dragoonCollarPlusTwo` | `gear.dragoonCollar` — Dragoon's Collar |
  | BLU | `gear.mirageStolePlusTwo` | `gear.mirageStole` — Mirage Stole |
  | COR | `gear.commodoreCharmPlusTwo` | `gear.commodoreCharm` — Commodore Charm |
  | SCH | `gear.arguteStolePlusTwo` | `gear.arguteStole` — Argute Stole |
  | GEO | `gear.baguaCharmPlusTwo` | `gear.baguaCharm` — Bagua Charm |

- **What changed inside the sample files.** All 22 ship refreshed. Copying the one for your
  job brings these with it; keeping your own copy is equally fine, because a definition in
  your job file loads after the include and replaces the engine's.

  - BLM and DRK declare Drain and Aspir at `sets.Midcast.Drain` and `sets.Midcast.Aspir`,
    the names the engine reads.
  - Sets the engine never reads are gone: RDM's `sets.Enspell`, the `sets.Precast.RA.ACC`
    in SAM and WAR, and DNC's dual-wield set, which moves to `sets.DualWield`.
  - The pet-command blocks in BST and PUP are gone, because a pet command has no set of
    its own.
  - Three set names read the way the game spells the action: `sets.WS['Raging Axe']` in BST
    and WAR, `sets.WS['Shadowstitch']` in DNC and THF, and `sets.JA['Clarion Call']` in BRD.
    Four ship empty and warn on first use — put gear in them or delete the line; BST's
    Raging Axe set copies that file's base weaponskill set.
  - BLM, GEO, SCH, SMN and WHM carry an `Mpaca` weapon set.
- **Upgrade every character you multibox in the same sitting.** The messages your
  characters send each other for spell-received gear carry a new internal tag under the
  new name, and 2.0 and 1.7.3 ignore each other's messages — no error on either side, just
  silence — so spell-received gear stops arriving between mixed versions.
- **Check what you are running with `//gs c version`.** The numbering continues under the
  new name rather than restarting, so a higher version is always a later one.

### New and Changed Features

**The on-screen display** — `gs c displaystyle`

- **Four renderers draw the status box**: `classic`, `harness`, `lattice` and `halo`. The
  bare command cycles them, a name selects one, and the choice is saved under the character
  playing, so each of your characters can use a different one. A name that is not on offer
  is refused with the list.
- **LATTICE in the stacked view is what the box opens in**, so the panel, the border and the
  rig are there from the first job change with nothing to switch on. If you would rather have
  the plain text box, `//gs c displaystyle classic`; for the compact view, `//gs c displaymode`.
  Both save immediately, under the character playing.
- **LATTICE draws the box on a panel** with a header strip and a fitted border, and adds
  **the rig**: a four-by-four grid of your sixteen gear slots beside the mode rows, laid out
  in the game's own equipment-window order. Each cell is colored by whichever layer is
  holding that slot — a strip hold in orange, the disable hold in cyan, a lock mode or the
  weapon lock in violet, the Hoxne hold in green, an item use in pale yellow — and a slot
  nothing holds draws as a dim socket. `settings.Lattice.rig.enabled = false` turns it off.
- **HALO draws no background at all**: four text planes at one position — crown, labels,
  values and holds — each with its own weight, stroke and hue, and a cap on how wide one
  value may run.
- **HARNESS gives every mode a cell of its own**, sized from that mode's own option list and
  packed two cells to a row, with no chevrons.
- **A hold row names every hold standing**, behind an `HLD` anchor: `DIS` for the disable
  hold, `NKD`, `WPO` and `PRC` for the three strip holds, and `CAP`, `DYN` and `JUB` for the
  carried-item locks. The row appears only while something is holding a slot.
- **The weapon lock has a row of its own, `LCK`**, and its value turns violet while the lock
  is actually holding main and sub.
- **The debug box carries a legend rail and a sixteen-slot hold map**, so you can read which
  layer is holding each slot.

**Holds and locks**

- **The weapon lock: `gs c weaponlock`, on <kbd>F10</kbd>.** `Locked` makes
  `sets.Weapons[<your weapon mode>]` the only writer of main and sub in every phase —
  precast, midcast and aftercast alike — and the pair starts as whatever you are wearing, so
  a slot the mode names nothing for is held as found. Bard's `Songs` stands aside for a song
  aimed at yourself, another player or a Trust; Corsair's `Locked+R` holds range as well, and
  stands down to `Locked` if a Hoxne mode takes range.
- **Hold slots exactly as they are: `gs c disable <slot>... | all`.** Nothing is equipped and
  nothing is unequipped — the gear staying where it is is the whole point — and
  `gs c enable <slot>...` hands the slots back. A bare `gs c disable` prints the usage and
  what stands, and one unrecognized slot word refuses the whole command before any slot is
  touched.
- **`gs c naked`, `gs c weaponsonly` and `gs c abysseaproc` bare their slots and hold them
  bare**, each with the same grammar: bare flips the hold, `on` takes it or re-takes it as
  the manual repair when something grabbed a slot behind the engine's back, and `off`
  releases it. One hold stands at a time, and typing a second word while the first stands
  switches shape.
- **`gs c nakedunlocked` is the momentary form** — it bares every slot it can and holds
  nothing, so the next action or poll dresses you again.
- **`gs c capacity` wears the best capacity point cape you carry** and holds the back slot:
  Aptitude Mantle +1, Aptitude Mantle, or a Mecisto whose own augment reads higher than
  either. It names what it settled on with its value — `Aptitude Mantle +1 (+30%): [ON] held
  in back.` — and setting it on while it is already on chooses afresh. `gs c aptitude` and
  `gs c mecisto` are the same mode under other names.
- **`gs c capinfo` lists every capacity point cape you carry**, what each is worth, which one
  the mode picks and what is actually worn.
- **`gs c dynamisrp` wears the best Dynamis Divergence neck your main job carries** — +2 over
  +1 over the base piece — and holds the neck slot. Entering a Divergence zone prints a
  reminder.
- **Every layer knows its place.** One arbiter hands out slots, so exactly one layer owns a
  slot at a time and a refusal names the holder and the slots, ranked down the body:
  `Received gear: head, body are held by a strip hold right now.` Sleep gear is a named holder
  like the rest, and prints a line on every sleep and wake.

**Gear and reporting**

- **A typed `/ja "Tomahawk"` or `/ja "Angon"` works on its own** while Hoxne is `OFF` or
  `ON-Allow Critical`, with `<t>` or a numeric target id: the engine equips the throwing
  item and the ability fires. `gs c tomahawk` and `gs c angon` remain the macro-friendly
  form — the ability's recast is checked before any gear moves, and a missing item is
  answered rather than silent. Under `ON-Locked` the ability is refused with its reason,
  whichever form you use.
- **A set you gave two names is reported under the one the action reached for.** Writing
  `sets.WS['Savage Blade'] = sets.WS.WSD` in your job file leaves both names live; a Savage
  Blade reports as `sets.WS.Savage Blade` on every load, and `gs c checksets` lists it under
  that same name.
- **An Aftermath layer is named in a clause of its own** on a weaponskill or shot line, with
  the set your branch chose at the head of the line: `[Savage Blade]
  [sets.WS.Savage Blade][Used] + [sets.WS.AM3][Used]`.
- **A White Mage main job carrying Yagrush casts Cursna with it**, and the line names the
  holder when a higher hold owns that slot.
- **The gear library grows by 322 entries.** Story mission rewards from every
  storyline, Seekers of Adoulin, Rhapsodies of Vana'diel and The Voracious Resurgence
  included; the three add-on scenarios' coffer pieces; Twilight and other Abyssea pieces;
  the Sortie earrings at every tier; Sinister Reign; Vagary; the Prime and Aeonic weapons;
  the Ambuscade weapon ladders; the Dynamis Divergence necks at every tier; Omen, Sroda and
  Unity accessories; and the Dancer's Ambuscade cape.
- **Debug output is prefixed `[Rahvin Debug]`.**

### Optimizations

- **Movement gear and Treasure Hunter tracking cost less to keep current.** Your position
  is read straight off the game's own movement messages, and movement gear swaps in and out
  exactly as it is documented.
- **The status box costs less to keep on screen.**

### Bug Fixes

- **The offhand stays withheld after a reload until both weapon traits are read**, so no
  shield appears in the sub slot for the first seconds.
- **The Hoxne Ampulla waits out a mount.** The game refuses item use while you are
  mounted, so the automatic use holds instead of retrying every few seconds for the
  whole ride, and fires promptly once you dismount.
- **A cast that is canceled or interrupted gives the Hoxne Ampulla back**, including the
  last song of a wave.
- **An interrupted song holds its instrument for five seconds**, so a re-sing inside them
  shows no Ampulla flicker; Tomahawk and Angon give the slot back within a second.
- **An ability your character cannot use is refused before any gear moves**, naming the
  real cause: `Tomahawk is not available (wrong job or level).`
- **A job ability still on cooldown reports the time remaining, as minutes and seconds.**
- **A Scholar carrying job points is refused a stratagem it does not have**, and told
  how long until the next charge.
- **Zoning releases the Hoxne hold and the lock modes, then dresses you for where you have
  arrived.**
- **Unloading a job file hands back the slot an item use was holding**, and clears the lock
  modes last, reporting any that were on.
- **A Bard file that omits an `Instrument` key falls back to the family set in silence**; a
  key declared and left `{}` is named in chat like any other empty set.
- **The shipped BLU file's `Shield` weapon mode equips its shield.**
- **The shipped BRD files open in the combat mode the file names.**
- **The shipped RUN file's One for All equips the idle set.**

---

## 1.7.3

A correctness release. A lot of gear that was quietly equipping nothing now equips:
sets whose names were misspelled, sets declared where the engine does not look, and
modes offered with no set behind them. Every sample job file carries the fixes. One
command is renamed, and a few things in your own job file are worth a look — the
Notices below are the short list.

### Notices

- **`gs c cp` is now `gs c trizek`.** Same Trizek Ring, same behaviour. Update any macro
  or keybind carrying the old word.
- **Take the sample job file for your job if you can.** All 22 changed. What each one
  gets you, in play:

  | Sample | What you get |
  |---|---|
  | WAR | Ranged weaponskills wear the gear you wrote for them — the sets were sitting under a name the engine does not read. Also a set for the PDT mode the file offers, and a Savage Blade set of its own rather than one shared with the weaponskill-damage set. |
  | PLD | Shield Bash and Chivalry fire on their recasts, and Enlight applies. Plus a Rampart set to put gear in. |
  | COR | Your Aeolian Edge set carries the bullet you named for it. |
  | BRD | The Subtle Blow and Critical Hit modes dress you — both now build on your full TP set. Evisceration wears the set you wrote for it. |
  | RNG | Your TP ammunition, your Bounty Shot ammunition, and the ammunition chosen on a weapon-mode change all resolve to real ammunition. |
  | BLM | Curaga wears your cure set, and Dematerialize wears the set you wrote for it. |
  | GEO | The Physical Damage Limit and Subtle Blow modes dress you, and Dematerialize wears the set you wrote for it. |
  | RDM | A Subtle Blow set, and a set behind the Physical Damage Limit mode. |
  | RUN | A Divine magic set, which Vivacious Pulse wears. |
  | SAM | Accuracy ammunition, and a set behind the Physical Damage Limit mode. |
  | PUP | A set behind the Physical Damage Limit mode. |
  | BST | A Puppetmaster ability branch taken out, where a Beastmaster never reaches it. |
  | DRG, DRK | Provoke wears your enmity set. |
  | BLM, BRD, SCH, SMN, WHM | Ring entries that name a key the gear library actually defines, so those ring slots dress. |
  | BST, COR, DNC, DRG, DRK, MNK, NIN, PUP, RNG, RUN, SAM, WAR | Warrior self-buffing that asks for Berserk, Aggressor and Warcry at the levels Warrior learns them. Seven of these ask on any Warrior subjob at all, however low. |
  | COR, RNG | Job-mode weapon swapping that covers every job mode the file offers, `Standard` included. |

- **Every mode you offer needs a set behind it.** A mode named in your
  `state.OffenseMode:options(...)` line with no matching `sets.OffenseMode.<mode>` costs
  you the rest of the engaged build — your weapons, your shield or dual-wield offhand,
  Aftermath and Treasure Hunter all go with it. Your base `sets.OffenseMode` still
  equips, which is what makes this easy to miss: you look dressed. An empty declaration
  is enough to close it:

  ```lua
  sets.OffenseMode.PDL = set_combine(sets.OffenseMode, {})
  ```

- **Three set paths are worth checking in your own file.** Gear declared at a name the
  engine does not read equips nothing, silently.

  | Put it here | Not here |
  |---|---|
  | `sets.WS.RA.ACC`, `.PDL`, `.SB`, `.CRIT`, `.MEVA` | `sets.WS.ACC.RA` and friends |
  | `sets.WS.RA.AM`, `.AM1`, `.AM2`, `.AM3` | `sets.WS.AM3.RA` and friends |
  | `sets.Midcast.RA.AM`, `.AM1`, `.AM2`, `.AM3` | `sets.Midcast.AM3` and friends |

  The two `sets.WS` rows are the shape the engine has always read — it is the WAR sample
  that carried them the other way round, so check your file if you built it from that
  one. `sets.Midcast.AM` and its siblings are gone from the engine's own declarations.

- **Aftermath tier sets dress you on their own now.** `sets.WS.AM3` is a base layer, and
  `sets.WS.AM3['<Weapon Mode>']` goes on over it for one weapon mode. Gear you put in the
  tier itself equips whichever weapon you are holding, and a weapon-mode set you declared
  and left empty holds nothing back. The same applies under `sets.WS.RA`,
  `sets.OffenseMode` and `sets.Midcast.RA`.

- **Five families of set are available and ship empty**: `sets.Midcast.Utsusemi`,
  `sets.Midcast.Phalanx`, `sets.Midcast.Divine`, `sets.Midcast.BlueMagic` with its eight
  children (`.ACC`, `.Breath`, `.Buff`, `.Enmity`, `.Healing`, `.Nuke`, `.Physical`,
  `.Skill`), and `sets.Helix` with `.Dark` and `.Light`. Filling them is optional — left
  alone they fall back like any other family set, and they warn on the same once-a-minute
  throttle as everything else.

- **Bards: `sets.Weapons.Songs.Precast` is read.** Declare it to hold a particular
  instrument or weapon pair through a song's precast; leave it out and precast keeps
  whatever you are holding.

- **Two pieces of job-file boilerplate moved into the engine** — the job-mode weapon
  swap and the Warrior sub-job self-buff chain — so the sample files are shorter. Your
  own copies keep working exactly as they did. The README's *Customization Hooks* section
  shows the shorter form if you want it.

- **The subjob-change hook receives the new and previous subjob.** If you wrote a branch
  against those, it runs with real values in it now.

### New and Changed Features

- **Hold an item in a slot: `gs c aptitude` and `gs c jubilee`.** They wear the Aptitude
  Mantle and the Jubilee Ring and keep them there against your normal gear. Type either
  bare to flip it, or with `on` or `off` to set it. They stand aside for an enchanted
  item use, the Hoxne Ampulla lock and incoming spell-received gear, and say so when they
  do. If the item leaves your bags or a level sync drops it, the mode switches itself off
  rather than holding an empty slot shut — and gear taken back by `/equipset` or a
  server-forced unequip is noticed and reclaimed.
- **Confirmations and diagnostics always answer.** Mode and setting confirmations, the
  lock-mode announcements, the startup keybind list, the version and every diagnostic
  reply print whatever your chat channels are set to — so a toggle can confirm itself and
  a diagnostic you typed never answers with silence. Gear and action reporting stays on
  `gs c info`, which is still the channel to turn down in a long fight.
- **Weaponskill and shot reports name the Aftermath gear they wore**, in a clause of
  their own. The set your weaponskill chose stays at the head of the line: Aftermath goes
  on over it rather than replacing it.
- **Bards: instrument overrides cover every song.** An `Instrument.Pianissimo` entry is
  honoured for all 25 song families, Hymnus included. Enfeebling songs wear
  `Instrument.Enfeebling`, and under Nightingale they wear it at precast too.
- **Bards: your offhand is respected through a song.** A declared offhand wins where dual
  wield allows one, and stands aside where it does not.
- **`gs c tomahawk` and `gs c angon` find the item anywhere you can equip it from** — any
  bag, any stack, and a copy you are already wearing is preferred. Under the Hoxne
  Ampulla lock the ability is refused with its reason on every press.
- **An enchanted item keeps its slot for the whole use.** A combat rebuild, a buff
  wearing off or a weapon-mode change leaves it in place until the use finishes. Zoning
  cancels the use and gives the slot straight back.
- **Long casts keep their midcast gear.** Blue magic, avatar and spirit summons, and
  Trust summons hold the gear they cast in for the whole cast, so a buff landing partway
  through does not dress you back into idle or engaged gear. Trust summons report their
  gear like any other cast.

### Optimizations

- **Dying costs nothing.** While you are dead the Hoxne Ampulla mode stops searching your
  bags and re-equipping, and picks up again when you are raised.
- **Reports cost nothing when their channel is off.** With `gs c info` off, the line for a
  shot or a weaponskill is never built in the first place.
- **Fewer bag searches on a cast.** The day, weather and distance gear checks look for an
  item only when the branch they are on can actually use it.
- **Less idle work.** The display boxes redraw only while they are visible, and Treasure
  Hunter's mob tracking does its housekeeping in one pass.

### Bug Fixes

- Weapon-mode changes dress the main hand first, so the offhand slot is free when you
  move between one-handed, two-handed and dual-wield sets.
- Chango, Compensator and Mumeito equip when a set names them.
- A mob killed by a weapon skill, spell, job ability or additional effect is dropped from
  Treasure Hunter's tag list, so a mob that respawns on the same spot within three minutes
  is tagged again and wears your Treasure Hunter set.
- Spectral Jig cancels an active Sneak before the ability fires, so the jig's own Sneak
  lands.
- Cancelling a cast releases the gear and slots it borrowed on your other characters at
  once, and the next cast you make is announced correctly.
- An AoE spell announced to your other characters reaches your party members only — an
  alliance member in another party is not dressed for a buff that cannot land on them.
- Utsusemi, Phalanx, Divine magic, blue magic and Helix spells report their sets and warn
  about them the same way every other family does.
- A reload or a job change leaves no empty box painted on the screen.
- `gs c zero` and `gs c displaymode` report a settings write only when the write happened.
- The back slot is released along with the other fifteen at startup.
- A weaponskill fired with no ammunition falls back on the ammunition type your ranged
  weapon actually uses, on Ranger as well as Corsair.
- A job file that offers an empty lockstyle list loads instead of failing.
- `gs c debug` prints one confirmation when you switch it on.
- The mode-cycling commands all wrap through their options the same way, including in job
  files that add their own commands.
- A job ability refused during the Hoxne Ampulla lock says why on every press.

---

## 1.7.2

A hardening release: crash fixes reported from the field, gear reporting extended to
the last actions outside it, and the two remaining per-action stalls removed.

### Notices

- **Five song family sets are new and ship empty**: `sets.Midcast.Fugue`, `.Hum`,
  `.Hymnus`, `.Virelai` and `.Nocturne`. Cactuar Fugue, Chocobo Hum, Goddess's Hymnus,
  Maiden's Virelai and Pining Nocturne route to them, so every castable song now has a
  family set. Declare gear in them if you want it; left alone, those songs fall back to
  `sets.Midcast` like any other song whose family set is bare.
- **NIN sample: the time-of-day movement sets are siblings of `sets.Movement`, not
  children.** Declare `sets.Movement_Day`, `sets.Movement_Night` and
  `sets.Movement_Dusk` beside a `sets.Movement_Base`, and rebuild from the base in
  `Cycle_Timer` as the sample shows. Rebuilding `sets.Movement` from sets nested inside
  it deletes those sets on the first tick and freezes the feet on whichever period was
  active at load — if your NIN file follows the old sample's pattern, copy the new one.
- **GEO sample: the idle Luopan check performs the swap now.** When the Luopan crosses
  its HP threshold while you stand idle, the head swap happens within about two
  seconds. If your GEO file carries its own copy of `Luopan()` and `Cycle_Timer`, take
  the sample's new pair to get the same behaviour.

### New and Changed Features

- **Pet actions report their gear.** A wyvern breath, blood pact or jug-pet move names
  the set it wore — `[sets.Pet_Midcast.Flame Breath][Used]` — with the same fallback
  line, empty-set warning and trace as a spell.
- **Songs report their family set the same way.** A song names the family set it used;
  one that is declared and empty shows both ends of the fallback —
  `[sets.Midcast.Paeon][Not Usable] -> [sets.Midcast][Used]` — and `gs c gearreporting`
  carries the full path.
- **Bindga** routes to `sets.Midcast.Enfeebling.Duration`, beside Bind.

### Optimizations

- **Weapon-mode changes answer from memory.** Whether a weapon is two-handed is
  resolved once per weapon name and remembered, instead of scanning the full item
  database on every press — about two milliseconds off every weapon-mode macro, paid in
  the same frame as the swap.
- **Auto-buff checks are paced to once a second**, resuming immediately after each
  action so a buff chain keeps its pace. With AutoBuff on, the recast queries this
  saves are about ninety percent of what the hooks were paying.
- **Less work per event in a large fight.** Expanding an AoE broadcast to nearby party
  members reads the party data already in hand; a weaponskill from elsewhere in the
  alliance closing a skillchain compares ids without fetching the mob; the movement
  poll skips its position read while mounted or mid-action; auto-buff ability and spell
  names are resolved once per name; multibox messages parse in a single pass.

### Bug Fixes

- A macro aimed at an open subtarget cursor — `/ma "Cure IV" <stpt>`,
  `/ws "Aeolian Edge" <stnpc>` — completes without a Lua error. This covers every
  tracked spell and every elemental weaponskill.
- Geo-Refresh wears `sets.Geomancy.Geo`.
- Breakga wears the enfeebling duration set.
- Casting a song leaves your song sets exactly as you declared them: a set you left
  empty keeps warning as empty, and `gs c checksets` stays accurate however many songs
  you cast.
- After an Accession or Divine Seal charge is spent, the next single-target cast is
  announced to your other characters as single-target.
- Multibox target matching is exact, so a character whose name contains another
  character's name cannot take gear swaps meant for them.
- Turning SpellReceived `OFF` during an incoming cast releases the borrowed slots at
  once.
- A tracked cast at a target outside render range equips gear and announces to your
  other characters normally.
- The earth-element, day-bonus and weather-bonus gear notices honour `gs c info`.
- Tzee Xicu's Blade carries the two-handed ordering token in the gear library, so
  entering a weapon mode built on it orders the swap correctly.

---

## 1.7.1

Knowing what your gear sets are doing. Every action names the set it wore, in one
consistent format, and the warnings that tell you a set is empty stay readable through a
long fight.

### Notices

- **Blue magic precast reads `sets.Precast.BlueMagic`.** If your job file declares
  `sets.Precast.Blue_Magic`, rename it; the underscored spelling is inert.
- **Warnings name any set that exists and holds no gear**, which includes ability sets
  declared as empty placeholders. A warning means the set exists and is empty, not that
  it is missing — the engine never asks for a set you have not declared. To quiet one
  for an ability you do not want special gear for, delete the `sets.JA["Name"] = {}`
  line rather than leaving it blank, or put gear in `sets.JA` to cover everything
  without a specific set. `gs c warn` turns the channel off entirely.
- **`sets.Midcast.Cursna` is available** if you want Cursna to wear something other than
  your enhancing gear. Declaring it is optional.

### New and Changed Features

**Gear reporting** — `gs c info`, `gs c gearreporting`, `gs c checksets`

- Every action names the set it used on the info channel: `[sets.Midcast.Cure][Used]`.
  When the set it reached for holds nothing, the same line shows both ends of the
  fallback: `[sets.Midcast.Cure][Not Usable] -> [sets.Midcast][Used]`.
- Job abilities, weaponskills, stratagems, Corsair rolls and shots, Dancer steps,
  Waltzes, Runes and item uses report as well, each at the point its gear is chosen.
  One line per action, whatever the action is.
- A set that holds no gear is named with the reason: `[sets.Midcast.Cure] not found!`
  if it was never declared, `[sets.Midcast.Regen] is empty!` if it was declared and
  left bare.
- `gs c checksets` audits a job file: how many sets carry gear, how many engine sets
  were never declared, and — named individually — any set declared but left empty.
- `gs c gearreporting` traces precast, midcast and aftercast, one labelled line each,
  including the whole fallback path when a set was bare. Off by default.
- Gear equipped for an incoming spell reports in the same format.
- Weaponskill chat carries the Aftermath tier and ammunition count on its own line,
  beside the set line rather than folded into it.

**Warning volume** — `gs c warn`

- Each set warns at most once per 60 seconds, and says so when the silence starts:
  `Silencing warnings for 60s`.
- When a set speaks again it reports what it held back — `(4 silenced since the last)` —
  so a quiet channel never reads as a fixed problem.
- The `gs c gearreporting` hint appears on the first warning after a load rather than on
  every one.
- `gs c checksets` clears the silences, so it doubles as "tell me everything again".

**Healing magic**

- Raise, Arise, Reraise, the -na spells, Esuna and Sacrifice use
  `sets.Midcast.Enhancing`.
- Cursna wears `sets.Midcast.Cursna` layered over `sets.Midcast.Enhancing`, so either
  set alone is enough.

**The gear library**

- `GearSets-Include.lua` ships as a shared library of roughly 3,700 named gear entries,
  referenced from job files as `gear.<name>`. All 38 job files reference it by key.
- Each entry carries a priority derived from the item's total HP, so higher-HP pieces
  equip first and a rapid swap chain does not dip your maximum HP or MP.
- Weapons carry ordering tokens that keep a main hand ahead of its off-hand in every
  pairing, so swapping from a two-handed set never refuses the off-hand.
- `hp_gear`, `mp_gear` and `rank_gear` are exported for your own entries.

**The status box**

- The indicators run SR, TH, HOX. In the stacked layout the header spans the full box
  with equal gaps, and each mode value sits between its chevrons with a single space on
  either side, so the chevrons travel with the value.
- Mode status shows as a solid square glyph, and the text carries a dark outline so it
  reads against any background.

**Chat**

- Chat output routes through Windower's own chat call, and the notice colours are
  retuned so warnings, the gear trace and debug output are distinguishable at a glance.
  Each writer has its own channel and its own toggle.

### Optimizations

Measured against the original Mirdain-Include 1.5.12 under a simulated Dynamis Divergence
alliance fight — six local clients inside an 18-player alliance, driven for 300 simulated
seconds per configuration:

- Roughly 70% of 1.5.12's CPU cost and 72% of its allocation rate, with every subsystem
  active. With every chat channel on, it costs what 1.5.12 costs running silent.
- The worst single frame in twenty minutes of simulated combat is about half of 1.5.12's,
  itself around 1% of a 60 fps budget.
- The reporting itself costs under 9 microseconds per action in any configuration, so
  chat volume rather than processing is what a busy fight should be tuned for.

The full write-up, with charts, is the Divergence Three-Suite Report, distributed separately.

### Bug Fixes

- Reporting reaches every set the engine can choose, including the ones a job file
  leaves undeclared, and names the set that actually dressed you.
- Blindna is recognised by the precast healing-magic set.

---

## 1.7.0

The first public release since 1.6.5, carrying the 1.6.6 work with it. Nothing in it
requires a change to your job files.

### Notices

- **Use `gs c tomahawk` and `gs c angon` in your macros** in place of a raw `/ja` line
  for those two abilities. The game refuses a typed `/ja` while the throwing item is
  unworn, so the command equips first and fires the ability once the equip is confirmed.

### New and Changed Features

- `gs c tomahawk` and `gs c angon` equip the throwing item, then use the ability on your
  target. The ability's recast is checked before any gear moves.
- `gs c cancel` stops a use in progress, and any new use command — `gs c use`,
  `gs c warp` and friends — takes over from the one already running. Re-issuing the item
  already running leaves it alone, and a command that is about to be refused never
  disturbs a use in progress.
- `gs c enchinfo <item>` prints an item's live charges, equip delay and cooldown beside
  what the engine derives from them, for when the timing looks wrong.
- `gs c hoxneinfo` prints everything the mode acts on — mode, both views of your
  equipment, buff, cooldown and retries — as a one-command health check.
- Switching a Hoxne mode on while the Ampulla is cooling down reports the wait once.
- Zoning turns the Hoxne mode `OFF`.
- Sample job files for all 22 jobs are included.

### Optimizations

- Command routing is a direct lookup rather than a chain of tests, so the order commands
  are declared in carries no meaning and cannot be got wrong.

### Bug Fixes

- Item names that contain command words — `gs c use hoxne ampulla` — reach the right
  command rather than the command whose name appears inside the argument.
- A use that the server honours is reported as a success.
- An item's equip delay is held apart from its true cooldown, so an item still waiting
  out its delay is waited on quietly rather than reported as unavailable.
- An Ampulla left stranded in the ammo slot after a reload is detected and released
  within a few seconds, with normal gear restored.
- Slots left locked by a previous load are released at startup.
- Treasure Hunter gear is merged at precast for weapon skills, ranged attacks and job
  abilities against untagged mobs. Spell precasts keep fast-cast gear; the Treasure
  Hunter set arrives at midcast, which is when the tag lands.

---

## 1.6.6

Developed but not released on its own; this work reached players inside 1.7.0.

### Notices

- **The Hoxne mode has three values**: `OFF`, `ON-Allow Critical` and `ON-Locked`,
  replacing the former `OFF` and `ON`. Anything that selects the mode by name — a macro,
  a keybind, a saved setting — needs the new value.

### New and Changed Features

- `gs c use <item>` reaches any of the 533 usable self-target items by name, matched
  case-insensitively — including the 126 whose log name carries mixed case. Type it in
  lower case, spaces and any `+1` included: `//gs c use prishe's boots +1`.
- Cooldowns are read live from the item, so `gs c use <item>` reports the remaining wait
  rather than equipping the item and quietly failing.
- One use runs at a time, driven by a single state machine that survives a reload. It
  re-equips up to three times if something takes the slot back, waits out movement and
  other actions, and has a hard deadline so a lost completion cannot strand a locked
  slot.
- `ON-Locked` re-asserts its hold every second and re-equips the Ampulla if the game
  clears ammo or an in-game equipset bypasses the lock. It also uses the Ampulla
  automatically when the enchantment is down and the recast is up.
- `ON-Allow Critical` opens a window for the four actions that genuinely need those
  slots — bard songs and Geomancy for range, Angon and Thrown Tomahawk for ammo —
  releasing only the slot the action needs. Job abilities close their window at
  aftercast; songs and Geomancy get a five-second debounce that each new cast refreshes,
  so a wave of songs is one continuous window.
- The status box glyph order is TH, SR, HOX, and the HOX colour distinguishes the two on
  states.

### Optimizations

- Cooldown warnings are throttled by the item's own ready time, which keeps the Hoxne
  tick quiet through the Ampulla's 60 second recast.
- The Ampulla's bag scan is gated so it runs at most every ten seconds.

### Bug Fixes

- Twilight Cape equips only for Cura and Curaga, so single-target cures keep the back
  piece the set specifies.
- Slot choice prefers the slot the item already occupies, which decides the matter for
  rings, where either hand would otherwise serve.
- Slot unlocking filters out Hoxne-held slots, so zoning, Doom or Sleep wearing off, and
  item completions leave the Ampulla in place instead of flushing parked job ammo in on
  top of it.
- Gear selection returns an empty set under Sleep rather than nothing at all.

---

## 1.6.5

### Notices

- **SpellReceived has two values, `OFF` and `ON`**, replacing the former on states.
  Anything that selects it by name needs the new value.

### New and Changed Features

- The display box is rebuilt: a coloured glyph header for TH, SR and HOX, aligned label
  and value columns with chevrons, and short labels derived from the mode names with
  per-mode overrides.
- `gs c <mode> <argument>` validates its argument, answering with a suggestion and usage
  text instead of silently accepting a partial match.
- Dragging is tied to box visibility.

### Optimizations

- The box layout is computed once and cached, so a redraw is concatenation rather than
  measurement.

### Bug Fixes

- Box settings — stroke and padding — are applied explicitly when the box is created.
- Toggling debug resets the debug box, and `gs c zero` repositions it along with the
  main box.

---

## 1.6.4

### Notices

- **Four blue magic sets are available to fill in**: `sets.Midcast.BlueMagic.Physical`,
  `.Breath`, `.Buff`, and `sets.Midcast["White Wind"]`. They ship empty; spells in those
  categories wear your general blue magic gear until you declare them.

### New and Changed Features

- All 196 blue magic spells are classified by mechanic, so a spell reaches gear chosen
  for what it does. Three categories are added because their mechanics share no gear
  with the existing ones: **Physical** (59 spells, scaling off weapon accuracy and
  attack), **Breath** (12, scaling off your HP and level only) and **Buff** (21, fixed
  potency where only duration responds to gear).
- White Wind gets a named set of its own, since it scales off maximum HP rather than
  MND.
- Every spell reaches a set chosen for its mechanic rather than falling through to the
  generic midcast base, which gears for not being interrupted rather than for effect.

### Optimizations

- Set building uses an in-place merge, saving roughly 60 table allocations and 250 hash
  operations per action. This is memory pressure in a Lua state shared with every other
  addon rather than frame time.

### Bug Fixes

- The item-search bag list is corrected. Wardrobe 8 went unsearched and Safe 2 was
  searched, so an Ampulla in Wardrobe 8 made `gs c hoxne` refuse to enable, while one in
  Safe 2 made it report success, equip nothing, and lock range and ammo on whatever was
  already worn.
- A dead target-assist block is removed from the pretarget checks.

---

## 1.6.0 – 1.6.3

The initial enhancement work over Mirdain 1.5.x. These versions predate this
repository's history and are recorded here as one span, at the granularity the record
supports.

### New and Changed Features

- **Hoxne Ampulla mode**, holding the slots and using the item.
- **Multibox spell-received gear tracking**, with AoE prediction for -aga and -ra
  spells, Accession, Divine Veil and Majesty. Sets equip the instant a local multiboxed
  character starts casting on you, lock until the spell lands, then revert.
- **Holy Water gear** equipped automatically when used from a macro or automation.
- **Twilight Cape support**, equipped for matching day and weather.
- **One-line or full display toggling**, with automatic position saving.
- **Commands for finer gear control**, and equipment slot lock and unlock routines that
  respect modes and zones.

### Optimizations

- Around 10% better CPU performance: hash-mapped lookups in place of iterative ones, raw
  event registration where it reduces background allocation, and guard clauses
  throughout to avoid unnecessary work.

---

## 1.5.12

Mirdain's original Mirdain-Include, and the base this suite was forked from. Credit to
Mirdain for the original concept and scaffolding. It is the baseline the bundled
performance report measures against.
