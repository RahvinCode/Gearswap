# Rahvin GearSwap

*Including the GearSets-Include gear library*

**Version 2.1** · A GearSwap engine for Final Fantasy XI (Windower 4)

GearSwap is a Windower addon that changes your equipment automatically as you play. Rahvin GearSwap is a complete engine for it: you fill in gear sets for the jobs you play, and it decides what to wear, and when, for every action you take — casting, weaponskills, job abilities, ranged attacks, pet actions, songs, item uses, moving, resting, sleeping and dying. It ships with a 4,912-entry gear library, sample files for all 22 jobs, and a set of automations built for players running several characters at once.

It began as a fork of Mirdain-Include, and Mirdain is credited for the original concept and scaffolding. Everything from 1.6.0 forward — engine and job files alike — is Rahvin's work, and the suite carries its own name and its own folder layout. Check the running version in game with `//gs c version`.

---

## Table of Contents

**New here?** Follow [Clean install](#clean-install), then [Quick Start](#quick-start). **On 2.0?** See [Updating from 2.0](#updating-from-20). **Something wrong?** See [Troubleshooting](#13-troubleshooting).

- [Key Features](#key-features) — [Gear](#gear) · [The gear library](#the-gear-library) · [The on-screen display](#the-on-screen-display) · [Holds and locks](#holds-and-locks) · [Multibox and tracking](#multibox-and-tracking) · [Your job file](#your-job-file)
- [Installation](#installation) — [Coming from another GearSwap suite](#coming-from-another-gearswap-suite) · [Clean install](#clean-install)
- [Quick Start](#quick-start) — [Words used in this manual](#words-used-in-this-manual)
- [Updating from an earlier version](#updating-from-an-earlier-version) — [Updating from 2.0](#updating-from-20) · [Upgrading from Mirdain-Include](#upgrading-from-mirdain-include)
- [The Manual](#the-manual)
  1. [How it works](#1-how-it-works)
  2. [The on-screen display](#2-the-on-screen-display)
  3. [Keybinds](#3-keybinds)
  4. [Modes](#4-modes)
  5. [Commands](#5-commands)
  6. [Holds and locks](#6-holds-and-locks)
  7. [Job file settings](#7-job-file-settings)
  8. [Gear sets reference](#8-gear-sets-reference)
  9. [The gear library](#9-the-gear-library)
  10. [Automatic engine checks](#10-automatic-engine-checks)
  11. [Action and spell tracking](#11-action-and-spell-tracking)
  12. [Customization hooks](#12-customization-hooks)
  13. [Troubleshooting](#13-troubleshooting)
      - Messages in chat: [A set warning](#a-set-warning-in-chat) · [A weaponskill warning names main or sub](#a-weaponskill-warning-names-main-or-sub) · [A line about a buff set](#a-line-about-a-buff-set-as-your-file-loads) · [A retired feature](#a-startup-message-mentions-a-retired-feature) · [No round named](#a-ranged-attack-is-canceled-with-no-round-named) · [A song or Geomancy spell fails](#a-bard-song-or-geomancy-spell-fails-with-a-command-error)
      - Gear and holds: [Gear is not swapping](#gear-is-not-swapping) · [A slot is stuck](#a-slot-is-stuck) · [A hold I did not ask for](#the-status-box-shows-a-hold-i-did-not-ask-for) · [An item is not equipping](#an-item-is-not-equipping) · [An enchanted item is not being used](#an-enchanted-item-is-not-being-used)
      - Files, settings and display: [Nothing loads](#nothing-loads-at-all) · [The wrong job file loads](#the-wrong-job-file-loads) · [An edit changes nothing](#an-edit-to-the-job-file-changes-nothing) · [A Lua error names a line](#a-lua-error-names-the-job-file-and-a-line) · [Settings are not saving](#settings-are-not-saving) · [The display box is gone](#the-display-box-is-gone) · [Blank squares or ragged columns](#the-status-box-shows-blank-squares-or-the-columns-are-ragged)
- [Performance](#performance)
- [Credits](#credits)
- [License](#license)

---

# Key Features

A map of what the suite does; each line links to the section that explains it.

## Gear

- **Gear for every step of every action**, from spells and weaponskills to pet actions and item uses, and your own code can add to any step. → [How it works](#1-how-it-works), [Customization hooks](#12-customization-hooks)
- **Declare only what changes.** Idle, movement, resting, pet, Sublimation, melee-mode, Aftermath and dual-wield sets are laid over one another, so each set names only the pieces that differ. → [Gear sets reference](#8-gear-sets-reference)
- **Gear for a buff, with no code.** A set named after a buff, such as `sets.OffenseMode.Impetus`, is worn while that buff is on you, and an `XIRoll` set is worn while a Corsair roll on you stands at 11. → [Buff sets](#buff-sets), [The XIRoll set](#the-xiroll-set)
- **Switches on keys.** Melee mode, weapon set, weapon lock, Treasure Hunter and four more switches each sit on a key you can change, and `gs c help` lists every command. → [Modes](#4-modes), [Keybinds](#3-keybinds)
- **Situational gear is put on for you**: the best day, weather and distance piece you carry, the items a few spells require, gear for sleep and Doom, and a Remedy for Silence and Paralysis when `AutoItem` is on. → [Automatic gear rules](#automatic-gear-rules), [Status ailment responses](#status-ailment-responses)
- **Actions that would fail are canceled first** — asleep, KO'd, charmed, short of TP, on cooldown or out of ammunition — and chat names the reason for a cooldown, a waltz short of TP, missing stratagem charges and ammunition. → [Action validation](#action-validation), [Resource warnings](#resource-warnings)

## The gear library

- **4,912 ready-made item entries**, written as `gear.<key>`, from every job's Artifact, Relic and Empyrean gear to the endgame pieces the samples use. → [The gear library](#9-the-gear-library)
- **Your max HP survives every swap.** The library puts high-HP pieces on first, so your maximum HP never dips mid-swap, and you can add your own entries the same way. → [Why priorities matter](#why-priorities-matter), [Adding your own entries](#adding-your-own-entries)

## The on-screen display

- **A status box in four styles**, stacked or on one line, saved for each character. → [Display styles](#display-styles), [The status box](#the-status-box), [The settings file](#the-settings-file)
- **Place boxes by command.** `gs c displaypos` puts a box at exact coordinates, so one command sent to all your characters lines them all up. → [Moving and saving the boxes](#moving-and-saving-the-boxes)
- **The LATTICE style adds the rig**, a four-by-four grid of your sixteen gear slots, each colored by whatever is holding it. → [Display styles](#display-styles)
- **A debug box** shows the engine's state when a swap surprises you. → [The debug box](#the-debug-box)

## Holds and locks

- **Bare a slot, or freeze it.** `gs c naked`, `gs c weaponsonly` and `gs c abysseaproc` strip slots and keep them bare, and `gs c disable <slot>` keeps a slot wearing what it wears. → [Strip holds](#strip-holds), [The disable hold](#the-disable-hold), [How the holds stack](#how-the-holds-stack)
- **Keep something on.** The weapon lock (<kbd>F10</kbd>) keeps your weapons in hand, the Hoxne Ampulla hold keeps the Ampulla in your ammo slot, and `gs c capacity`, `gs c dynamisrp` and `gs c jubilee` keep on the best capacity cape, Dynamis neck or Jubilee Ring you carry. → [The weapon lock](#the-weapon-lock), [The Hoxne Ampulla hold](#the-hoxne-ampulla-hold), [Carried-item locks](#carried-item-locks)
- **`gs c use <item>` uses any enchanted item**: it equips the item, waits until the game allows the use, uses it and gives the slot back. → [Enchanted items](#enchanted-items)

## Multibox and tracking

- **Gear for a spell another of your characters is casting on you**, put on before the spell lands, even through Quick Magic. → [Spell-received tracking](#spell-received-tracking)
- **Treasure Hunter that remembers what it tagged**, so `Tag` mode goes back to full damage once the tag lands. → [TreasureHunter](#treasurehunter), [Treasure Hunter tracking](#treasure-hunter-tracking)
- **Magic bursts.** When a skillchain closes on your target, whoever made it, a matching nuke wears `sets.Midcast.Burst`. → [Skillchain and magic burst tracking](#skillchain-and-magic-burst-tracking)
- **Chat tells you what you wore.** One line per action names the set, as in `[Cure IV] [sets.Midcast.Cure][Used]`, and `gs c checksets` checks a whole job file. → [Diagnostics](#diagnostics)

## Your job file

- **Twenty-two sample job files**, one per job, ready to load and fill with your own gear, plus the settings that drive them. → [Installation](#installation), [Job file settings](#7-job-file-settings), [Instruments](#instruments)
- **Built for six characters at once.** Six clients in an 18-player alliance is the design target, and the engine is measured against it. The gear trace starts off, and one command switches info or warning messages, so chat volume stays under your control. → [Performance](#performance)

---

# Installation

New to GearSwap? Follow [Clean install](#clean-install), then [Quick Start](#quick-start). If another GearSwap suite is installed, clear it out first, as the next section describes. Updating an earlier version of this suite? See [Updating from an earlier version](#updating-from-an-earlier-version).

## Coming from another GearSwap suite

If you have been running the Kinematics/Mote libraries, Selindrile's suite, or any other GearSwap package, clear it out before you copy anything in:

1. **Remove that suite's folders and files from `Windower4/addons/GearSwap/data/`**, including any character folders inside it — its include files, its library folders, and its job files. GearSwap loads a job file by name and looks in the character's folder first, so a leftover `WAR.lua` or `John_WAR.lua` from another suite is the file it loads for Warrior.
2. **Delete `Windower4/addons/GearSwap/data/settings.xml`** if there is one, with GearSwap unloaded (`//lua unload gearswap`). The first time each character loads this engine, its own settings file starts as a copy of that file, so whatever another suite left there would be carried into every character's settings.
3. Follow the [clean install](#clean-install) below.

**Job files written for another suite are not compatible.** The set names, the mode objects and the hook names are this engine's own. Start from the file in `Sample Job Files/` for your job and move your gear into it; the sample is also a worked example of every convention in this document.

## Clean install

GearSwap keeps everything in one folder, `Windower4/addons/GearSwap/data/`. The engine goes directly inside it, and each character gets a folder of its own for its job files.

1. Install Windower 4 and enable the **GearSwap** addon, in the Windower launcher or by typing `//lua load gearswap` in game.
2. Copy the whole `RahvinGS` folder from the download into `Windower4/addons/GearSwap/data/`. Every character shares this one copy, and you never need to edit anything in it.
3. Inside `data/`, make a folder for each character you play, named exactly as the character is named in game — `data/John/` for a character called John.
4. Copy the job files you want from `Sample Job Files/` into that character's folder. Name each file either way:
   - `BLU.lua` — the job's short name
   - `John-BLU.lua` — the character's name, a hyphen, and the job's short name
5. Log in as that character and change to that job. GearSwap loads the file, prints the key list, and dresses you.
6. Type `//gs c version`. The engine answers `Include Version is [2.1]`.

Finished, it looks like this:

```
Windower4/addons/GearSwap/data/
├── RahvinGS/           the engine and the gear library, shared by every character
├── John/
│   ├── BLU.lua         John's Blue Mage file
│   ├── WAR.lua         John's Warrior file
│   └── settings.xml    John's settings, written by the engine
└── Jane/
    ├── Jane-WHM.lua    Jane's White Mage file
    └── settings.xml    Jane's settings
```

**Why a folder per character.** Each character's settings — box positions, display style, chat switches and mode keys — are saved in `settings.xml` inside that character's folder, and the engine creates the file the first time the character loads. With the job files beside it, everything that belongs to one character sits in one place, and two characters can each have their own `WAR.lua` with different gear. See [The settings file](#the-settings-file).

**Which file loads.** GearSwap looks in the character's own folder first, so a job file there always wins over one in `data/`, whatever the names. If GearSwap loads a different file from the one you expect, see [The wrong job file loads](#the-wrong-job-file-loads).

Next: [Quick Start](#quick-start).

---

# Quick Start

You have installed the suite and copied `WAR.lua` into your character's folder. Here is the first ten minutes.

**1. Open your job file and put your own gear in three sets.** Everything else can wait. The sample already names example gear in its main sets: replace the pieces you do not own, starting with these three.

```lua
function get_sets()
    sets.Idle       = { head = gear.nyameHead, body = gear.sakpataBody }
    sets.OffenseMode = { head = gear.nyameHead, body = gear.sakpataBody }
    sets.WS         = { head = gear.nyameHead, body = gear.sakpataBody }
end
```

`sets.Idle` is what you stand in, `sets.OffenseMode` what you fight in, `sets.WS` what you weaponskill in. Use `gear.<key>` from [the gear library](#9-the-gear-library) or plain item names in quotes — both work.

**2. Change job in game.** The engine prints its key list, applies your lockstyle and macro book, and dresses you. After each later edit, save the file and type `//gs reload` to load the change.

**3. Read the box in the corner.** It opens in the LATTICE style, stacked: a bordered panel with a header strip, and the rig — a four-by-four grid of your sixteen gear slots — at the right of the mode rows. The top row is your job and three indicators — spell-received gear, Treasure Hunter, Hoxne — each a colored square. Below it is one row per mode: `STN` your melee mode, `DPS` your weapon set, `LCK` the weapon lock. → [The status box](#the-status-box)

**4. Three keys and three commands for day one.** Type a command into the chat line. In an in-game macro, write it as `/console gs c checksets`.

| | |
|---|---|
| <kbd>F12</kbd> | Cycle your melee mode through the modes your file offers — the WAR sample offers eight and starts in `DT` |
| <kbd>F9</kbd> | Cycle your weapon set |
| <kbd>F11</kbd> | Cycle Treasure Hunter |
| `//gs c checksets` | Count the sets carrying gear and the ones you left undeclared, and name every declared set that is empty |
| `//gs c info` | Turn the running commentary on or off — one line per action naming the set it wore |
| `//gs c help` | List every command, with the key each mode is on |

These are the default keys, and `//gs c keybind` moves any of them — see [Keybinds](#3-keybinds).

**5. Where to read next.** [Gear sets reference](#8-gear-sets-reference) is the list of every set name the engine reads. [Modes](#4-modes) is how the switches work. [Troubleshooting](#13-troubleshooting) is what a warning in chat means. The words this manual uses are defined just below.

## Words used in this manual

- **Slot** — one of your sixteen equipment slots: main, sub, range, ammo, head, neck, two ears, body, hands, two rings, back, waist, legs and feet.
- **Set** — a list of gear by slot, such as `{ head = gear.nyameHead, body = gear.sakpataBody }`. A set names only the slots it cares about.
- **Table** — anything written between `{` and `}` in your job file. Every set is a table.
- **Child set** — a set written inside another, such as `sets.Idle.DT` inside `sets.Idle`.
- **Merge** — laying one set over another. Where both name a slot, the later set wins. A slot no set names keeps whatever you are wearing.
- **Layer** — a set laid over others as your gear is chosen, such as the movement set over your idle set.
- **`set_combine(a, b)`** — a new set: `a` with `b` laid over it. It copies gear slots only, never child sets.
- **Build** — the gear the engine puts together for one moment, such as an action or standing idle, built again whenever something changes.
- **Mode** — a named switch the engine reads when it picks gear, such as your melee mode or your weapon set. A key or a command changes it. See [Modes](#4-modes).
- **Mode names** — the key list and the status box use short names: OffenseMode (your melee mode) is *Stance* and `STN`, WeaponMode (your weapon set) *Weapon Mode* and `DPS`, WeaponLock *Weapon Lock* and `LCK`, and TreasureHunter *TH Mode* and `TH`.
- **Hold** — something keeping a slot as it is until it lets go: an item being used, a strip, a lock. Whatever keeps the slot is its **holder**. See [Holds and locks](#6-holds-and-locks).
- **Buff set** — a set named after a buff, worn while that buff is on you. See [Buff sets](#buff-sets).
- **Pretarget, precast, midcast and aftercast** — the four steps of an action. Pretarget checks it (enough TP? on cooldown? asleep?), precast puts on the gear that starts it, midcast the gear that makes it land, and aftercast puts your idle or melee gear back. See [How it works](#1-how-it-works).
- **Channel** — one kind of chat message, with its own on/off switch: `info`, `warn`, `debug` and `gearreporting`. See [Diagnostics](#diagnostics).
- **Mode abbreviations** are the game's own: ACC accuracy, CRIT critical hit, DT damage taken, MACC magic accuracy, MEVA magic evasion, PDL physical damage limit, PDT physical damage taken, SB subtle blow.

---

# Updating from an earlier version

## Updating from 2.0

1. Replace the `RahvinGS` folder in `data/` with the new one, then reload GearSwap with `//lua r gearswap`. Type `//gs c version` to check for `[2.1]`.
2. Move each character's job files into that character's own folder, as the [clean install](#clean-install) describes. A job file left in `data/` still loads, so this can wait.
3. Log in each character once. Each gets its own settings file, copied from its settings in the shared `data/settings.xml`, so box positions, style, view and chat switches carry over. See [The settings file](#the-settings-file).

Most job files written for 2.0 need no edits. Check yours for these:

- **Weapons in weaponskill sets.** A weaponskill never changes main or sub, or range except on Bard and Geomancer, so take those slots out of your weaponskill sets and `sets.Idle`. With `gs c warn` on and the weapon lock off, a line names the set. See [Weaponskills](#weaponskills).
- **Weaponskill mode sets.** A mode set built with `set_combine(sets.WS, ...)`, as a file from a 2.0 sample may have, puts the base pieces back over each named weaponskill's own gear. Name only what the mode changes: `sets.WS.ACC = { ... }`. See [Weaponskills](#weaponskills).
- **Tables named after a buff.** Under any set [where buff sets work](#buff-sets), a table named for a buff is worn while that buff is on you. Rename one you keep for another purpose, such as `sets.Idle.Refresh`.
- **`sets.Weapons['Light Bonus']`.** On a Light-day or Light-weather cure it goes on whole, main and sub included, whether or not you carry Chatoyant Staff. Check what it names.
- **Command words.** The engine handles `help`, `keybind`, `displaypos` and `displaycells`, and `on` or `off` after the display and chat words, so rename any `gs c` command of your own that uses one of these names. A mistyped argument to them, or to the hold and lock commands, never reaches your job file. See [Argument validation](#argument-validation).
- **Switches that save.** `gs c display`, `debug`, `warn`, `info` and `gearreporting` save their setting, so a channel you turn off stays off after a reload.
- **A job file that calls `round`.** The engine supplies no `round` function, so the call stops with a Lua error: `attempt to call global 'round' (a nil value)`. Copy this into your file, near the top:

  ```lua
  function round(num, numDecimalPlaces)
      if num ~= nil then
          local mult = 10 ^ (numDecimalPlaces or 0)
          return math.floor(num * mult + 0.5) / mult
      end
  end
  ```

The MNK, PLD, RDM, RUN, SAM and SCH samples wear their buff gear through buff sets. A job file you keep works as it is, and a Monk file's own code for `sets.Impetus`, `sets.Foot_Work` or `sets.Boost` can go — see [Buff sets in the sample files](#buff-sets-in-the-sample-files). Per-release detail is in [PATCH NOTES.md](PATCH%20NOTES.md).

## Upgrading from Mirdain-Include

This covers everyone arriving from **Mirdain-Include 1.5.x** and from **any 1.6.x or 1.7.x version of this suite**, up to and including 1.7.3. Your gear sets, your modes and your macros carry over; the shape on disk is what changes, and a handful of job-file edits go with it.

### The upgrade itself

1. Delete `Mirdain-Include.lua` and `GearSets-Include.lua` from `Windower4/addons/GearSwap/data/`.
2. Copy the whole `RahvinGS` folder into that same `data/` folder.
3. Point each of your job files at the new engine. The two include lines at the top become:

   ```lua
   include('RahvinGS/GearSets-Include')
   include('RahvinGS/Rahvin-Engine')
   ```

   The refreshed samples carry them already.
4. Move each character's job files into a folder of its own, as the [clean install](#clean-install) describes. A job file left in `data/` still loads, so this can wait.
5. Reload GearSwap with `//lua r gearswap`, then type `//gs c version` and check the answer.

> **Running several characters? Upgrade them all in one sitting.** The messages your characters send each other for spell-received gear carry an internal tag tied to the suite name, and versions on either side of the rename ignore each other's messages — no error, just silence. Until every character is upgraded, spell-received gear stops arriving between mixed versions.

### What happens to `settings.xml`

Nothing has to be deleted. The first time each character loads 2.1, the engine creates that character's own `data/<CharacterName>/settings.xml` as a copy of its settings in your existing `data/settings.xml`, and leaves the old file as it was. On that first load the display settings return to their defaults, so the status box opens in LATTICE, stacked, and the box positions you dragged are kept. One line per group says so:

```
Display settings reset to defaults (version 2); box positions kept
Halo settings reset to defaults (version 1)
```

Your chat switches and the spell-received failsafe window carry through untouched. To change the look, see [Display styles](#display-styles); to start from a blank file, see [The settings file](#the-settings-file).

### What to change in your own job file

The job-file edits each release asks for are listed in the Notices of [PATCH NOTES.md](PATCH%20NOTES.md): read those of every release after yours, through 2.0, then work through [Updating from 2.0](#updating-from-20). Three places in this manual cover what upgraded files most often miss:

- the two retired features a file may still carry, which the engine names as it loads — see [A startup message mentions a retired feature](#a-startup-message-mentions-a-retired-feature);
- set paths the engine does not read — see [Spellings the engine does not read](#spellings-the-engine-does-not-read);
- a mode with no set of its own, and a ranged action whose set names no round — see [Core sets](#core-sets) and [Ammunition](#ammunition).

All 22 sample files ship refreshed. Copying the one for your job brings its gear and behavior corrections into your own file; keeping your own file is equally fine.

After the upgrade, run **`//gs c checksets`**. It names every set you declared and left empty, which is the fastest way to find something the move disturbed.

---

# The Manual

## 1. How it works

GearSwap is a Windower addon that changes your equipment automatically as you play. Normally you would write all of that swapping logic yourself, for every job. This suite does it for you.

**The `RahvinGS` folder** is the engine — `Rahvin-Engine.lua`, the component files beside it, and the gear library `GearSets-Include.lua`. It holds all the rules: which gear to wear while idle, while fighting, while casting, while moving. It is the same folder for every job and you should not need to edit anything in it.

**Job files** (`WAR.lua`, `WHM.lua`, `BLM.lua`, …) are yours. They hold your gear, your modes and your preferences. You will spend all of your time in these.

Every job file begins by loading the gear library and the engine:

```lua
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')
```

From that point the engine drives everything, calling into your job file at specific moments. The flow for any action looks like this:

```
You press a macro
        │
        ▼
   pretarget ──► engine validates the action (enough TP? spell on cooldown? asleep?)
        │        cancels it and tells you why if not
        ▼
    precast  ──► engine equips Fast Cast / weaponskill / ability gear
        │
        ▼
    midcast  ──► engine equips potency / accuracy / recast gear
        │
        ▼
   aftercast ──► engine returns you to idle or melee gear
```

At each step the engine builds a gear set from its own rules, then calls **your** matching `_custom` function and merges whatever you return. See [Customization hooks](#12-customization-hooks).

Three details are worth knowing early. `sets.Idle` is laid underneath every precast and midcast as a floor, so an action that matches no set of its own still comes out dressed rather than in whatever the last step left on — and a slot `sets.Idle` names is part of every action's gear. Weaponskills, job abilities (Corsair rolls and shots, stratagems, runes, wards and effusions, and Dancer's waltzes, jigs, sambas, steps and flourishes among them) and item uses are final at precast: their precast gear is what the action lands in, and no midcast runs. Blood pacts, Ready moves and pet commands are not final at precast, and go on to a midcast. And a weaponskill never changes your weapons, because that would reset your TP — see [Weaponskills](#weaponskills).

Separately, a background loop runs about ten times a second to handle what is not tied to an action — movement gear, weapon checks, housekeeping. See [Automatic engine checks](#10-automatic-engine-checks).

The words this manual uses are defined under [Words used in this manual](#words-used-in-this-manual).

---

## 2. The on-screen display

The suite draws two boxes: a **status box**, always available, and a **debug box**, hidden unless `gs c debug` is on. Both leave the screen when you log out, and come back as you left them at the next login.

### Display styles

Four styles can draw the status box, and it opens in LATTICE. `//gs c displaystyle` with no argument cycles them; a name selects one. The choice is saved in the character's own settings file, so each of your characters can use a different one.

| Style | What it draws |
|---|---|
| `classic` | The plain text box: three colored indicators on top, one `label ◄ value ►` row per mode, and the hold row |
| `harness` | Each mode in a cell of its own, two cells to a row, without the arrows |
| `lattice` | CLASSIC's layout on a bordered panel with a header strip, plus the rig |
| `halo` | Text only, with no background: outlined letters in their own weights and colors, drawn straight over the game |

Each style in both views, stacked first and then one line:

**`lattice`** — the default

![The LATTICE style, stacked, with the rig](https://raw.githubusercontent.com/RahvinCode/Gearswap/master/Rahvin%20GS%202.0%20Images/Lattice%20Stacked.png)

![The LATTICE style in one line](https://raw.githubusercontent.com/RahvinCode/Gearswap/master/Rahvin%20GS%202.0%20Images/Lattice%20Oneline.png)

**`classic`**

![The CLASSIC style, stacked](https://raw.githubusercontent.com/RahvinCode/Gearswap/master/Rahvin%20GS%202.0%20Images/Classic%20Stacked.png)

![The CLASSIC style in one line](https://raw.githubusercontent.com/RahvinCode/Gearswap/master/Rahvin%20GS%202.0%20Images/Classic%20Oneline.png)

**`harness`**

![The HARNESS style, stacked](https://raw.githubusercontent.com/RahvinCode/Gearswap/master/Rahvin%20GS%202.0%20Images/Harness%20Stacked.png)

![The HARNESS style in one line](https://raw.githubusercontent.com/RahvinCode/Gearswap/master/Rahvin%20GS%202.0%20Images/Harness%20Oneline.png)

**`halo`**

![The HALO style, stacked](https://raw.githubusercontent.com/RahvinCode/Gearswap/master/Rahvin%20GS%202.0%20Images/Halo%20Stacked.png)

![The HALO style in one line](https://raw.githubusercontent.com/RahvinCode/Gearswap/master/Rahvin%20GS%202.0%20Images/Halo%20Oneline.png)

```
//gs c displaystyle              -- cycle
//gs c displaystyle lattice      -- pick one
```

A name that is not on offer is refused with the list:

```
Display Style: "neon" is not a style.
Usage: //gs c displaystyle [classic|harness|lattice|halo]
```

**The rig** is LATTICE's addition, in the stacked view: a four-by-four grid of your sixteen gear slots, laid out in the game's own equipment-window order, in text columns reserved at the right of every mode row. Each cell is colored by whatever is holding that slot, and a slot nothing holds draws as a dim socket:

| Color | Holding the slot |
|---|---|
| Orange | A strip hold |
| Cyan | The disable hold |
| Violet | A lock mode, or the weapon lock |
| Green | The Hoxne hold |
| Pale yellow | An item use |
| Blue | Sleep gear |
| Red | The item the cast in progress requires |
| Pink | Received gear |

A cell changes color the moment a hold takes or releases its slot. To turn the rig off, set `Lattice.rig.enabled` to `false` in your [settings file](#the-settings-file). The colors are under `Lattice.rig.hue` there.

### The status box

Two views, in every style. The box opens stacked; `//gs c displaymode` switches it to one line and back, and saves the choice.

Stacked, in CLASSIC:

```
SR .   TH .   HOX .
STN     < DT >
DPS < Black Halo >
LCK  < Unlocked >
MDE    < Melee >
HLD  DIS NKD
```

One-line:

```
WHM/SCH  SR .  TH .  HOX .  STN < DT >  DPS < Black Halo >  LCK < Unlocked >  MDE < Melee >  HLD DIS NKD
```

*(The box draws colored squares and solid triangles. They are transcribed above as `.`, `<` and `>`.)*

**The crown** is three indicators whose *color* carries the state, so the row never changes width: `SR` (SpellReceived), `TH` (TreasureHunter) and `HOX` (Hoxne). The crown opens with your job in every view but CLASSIC's stacked one.

| Indicator | Meaning |
|---|---|
| Green square | Mode is fully on — `ON`, `Full Time`, `ON-Locked` |
| Amber square | Partially on — TH `Tag`, or Hoxne `ON-Allow Critical` |
| Cyan square | THF-only TH `SATA` |
| Gray square | Mode is off (`None` / `OFF`) |

**The mode rows** show full text, so the weapon or job function currently selected is always readable: `STN` OffenseMode, `DPS` WeaponMode, `LCK` WeaponLock, then JobMode and JobMode2 when your file names them. The `LCK` value turns violet while the lock is actually holding main and sub.

**The hold row** appears only while something is holding a slot: the label `HLD`, then a three-letter code for each hold, strongest first.

| Code | Hold |
|---|---|
| `DIS` | The disable hold — one token however many slots it holds |
| `NKD` `WPO` `PRC` | A strip hold: `gs c naked`, `gs c weaponsonly`, `gs c abysseaproc` |
| `CAP` `DYN` `JUB` | The capacity point cape, Dynamis neck and Jubilee Ring locks |

**Sizing.** Column widths come from each mode's complete list of options rather than its current value, so cycling a mode never resizes the stacked box — it stays a fixed width for as long as a job is loaded. The one-line view deliberately flexes with the current values to stay as short as possible. To make the value column wider, give it a minimum width in characters with `//gs c displaycells <n>`. `//gs c displaycells 0` removes it, and the bare command reports it. The choice is saved.

### The debug box

`//gs c debug` shows it and opens the verbose log channel with it; typed again, it hides both. `//gs c debug on` and `//gs c debug off` set it outright. The choice is saved.

![The debug box: six engine flags, the legend rail and the hold map](https://raw.githubusercontent.com/RahvinCode/Gearswap/master/Rahvin%20GS%202.0%20Images/Debug%20Box.png)

| Field | Meaning |
|---|---|
| `is_Busy` | Engine is mid-action and will not overwrite gear |
| `is_Moving` | You are moving |
| `DualWield` | Dual Wield trait detected |
| `TwoHand` | Your current main weapon is two-handed |
| `Casting` | An outgoing tracked cast is in progress |
| `Failsafe` | Spell-received gear is waiting on a timeout |

Below those are two lines the other boxes do not carry: a **legend rail** of the nine holders, lit where that holder has a slot, and a **hold map** of the sixteen slots in equipment-window order, each cell carrying its holder's letter.

| Letter | Holder |
|---|---|
| `E` | An item use |
| `D` | The disable hold |
| `S` | A strip hold |
| `H` | The Hoxne hold |
| `Z` | Sleep gear |
| `I` | The cast in progress |
| `R` | Received gear |
| `L` | A lock mode |
| `W` | The weapon lock |

### Moving and saving the boxes

Drag either box with the left mouse button while it is visible. The new position is saved a second after you let go, silently — there is no chat confirmation.

You can also place a box by typing its position, in screen pixels from the top-left corner. This is the way to line up several characters: sent to all of them at once, for example through Windower's Send addon, the same command puts every box in the same place.

```
//gs c displaypos                    -- report where both boxes are
//gs c displaypos 1106 704           -- put the status box there
//gs c displaypos debug 1106 830     -- put the debug box there
```

Each placement is saved and answered — `Display position: status [1106, 704] saved`. A position off the screen is not refused, so `//gs c zero`, which puts both boxes back in the top-left corner, is the way to recover a box you cannot see.

Every other box command is listed under [Display commands](#display-commands), and each saves its change in the character's own [settings file](#the-settings-file). Their `on` and `off` forms are the ones to send to every character at once: they leave every character alike, whatever state each was in.

> A box dropped while you are zoning is saved once the zone finishes, and one dropped in the last second before you log out keeps its old position. Nothing is saved at the character select screen.

### The settings file

Each character's settings are saved in a file of its own:

```
Windower4/addons/GearSwap/data/<CharacterName>/settings.xml
```

It holds the box positions and their look, the display style and view, the chat switches (`info`, `warn`, `debug`, `gear_reporting`), your mode keys, and the spell-received failsafe window (`delay`, in seconds). The file is in the same place wherever your job files are.

- **It is created on the character's first load.** Windower prints one line naming it: `New file: data/John/settings.xml`. If the shared `data/settings.xml` from an earlier version is there, the new file starts as a copy of that character's settings in it. The shared file itself is never changed, and it is read again only by a character that has no file of its own.
- **It is saved as you go** — by a box drag, a display, chat or key command, and `//gs c save`. Nothing is saved while zoning or at the character select screen.
- **To edit it by hand, unload GearSwap first** (`//lua unload gearswap`). Every save rewrites the whole file, so an edit made while GearSwap is running is undone at the next save. A value in the section named for your character wins over the same value under `<global>`.
- **To start a character fresh**, unload GearSwap and delete its `settings.xml`. Delete `data/settings.xml` too if it is still there, or the next load copies it again.
- **A damaged file is left alone.** If the file cannot be read — or, on a first load, the shared `data/settings.xml` it would be copied from — the character runs on the default settings, and nothing is saved until you fix or delete that file and reload GearSwap. Chat says so once, naming the file and the reason:

  ```
  Settings: data/John/settings.xml could not be read (does not end with </settings>). Running on defaults; nothing will be saved until the file is fixed or deleted and GearSwap reloaded.
  ```

---

## 3. Keybinds

Eight keys are bound when your job file loads, and released when it unloads. These are the defaults:

| Key | Action |
|---|---|
| <kbd>F9</kbd> | Cycle **WeaponMode** |
| <kbd>F10</kbd> | Cycle **WeaponLock** |
| <kbd>F11</kbd> | Cycle **TreasureHunter** |
| <kbd>F12</kbd> | Cycle **OffenseMode** |
| <kbd>Ctrl</kbd>+<kbd>F9</kbd> | Cycle **SpellReceived** |
| <kbd>Ctrl</kbd>+<kbd>F10</kbd> | Cycle **Hoxne** — `OFF` → `ON-Allow Critical` → `ON-Locked` |
| <kbd>Ctrl</kbd>+<kbd>F11</kbd> | Cycle **JobMode2** |
| <kbd>Ctrl</kbd>+<kbd>F12</kbd> | Cycle **JobMode** |

The engine lists the keys in chat as your job file loads, and `//gs c keybind` lists them again:

```
Keys: [F12] Stance  [F9] Weapon Mode  [F10] Weapon Lock  [F11] TH Mode
Keys: [Ctrl+F10] Hoxne Ampulla  [Ctrl+F9] Spell Received (Multibox)
```

In that list OffenseMode is called *Stance*, the name the status box shortens to `STN`. When your file names its job modes with `UI_Name` or `UI_Name2`, their keys lead the second line, under the names you gave them.

Each key sends a command you can also type or put in a macro — <kbd>F12</kbd> sends `gs c OffenseMode`, for example. The commands are under [Mode commands](#mode-commands).

### Choosing your own keys

`gs c keybind` moves a mode to another key. A key is F1 to F12, alone or with one of Ctrl, Alt or Shift:

```
//gs c keybind treasurehunter ^f5      -- Ctrl+F5; ctrl+f5 and "Ctrl F5" work too
//gs c keybind weaponlock !f10         -- Alt+F10
//gs c keybind jobmode ~f12            -- Shift+F12
//gs c keybind hoxne none              -- no key; //gs c hoxne still cycles it
//gs c keybind hoxne default           -- back to its default key
//gs c keybind default                 -- all eight back to their defaults
```

The mode words are `offensemode`, `weaponmode`, `weaponlock`, `treasurehunter`, `jobmode`, `jobmode2`, `hoxne` and `spellreceived`. In the short spelling, `^` means Ctrl, `!` Alt and `~` Shift.

- **Each change is saved** in the character's own settings file, and confirmed: `TH Mode bound to [Ctrl+F5]; any other Windower bind on this key is replaced.`
- **A key another mode already uses is refused**, and the answer names that mode: `[F12] is bound to Stance; free it first (gs c keybind offensemode none) or choose another key.`
- **A key bound here does not do its usual job in game** while your job file is loaded. While <kbd>F9</kbd> is bound to a mode, for example, it does not target the nearest player.
- **A mode set to `none` leaves that key alone.** The engine binds nothing to it at load and releases nothing from it at unload, so a Windower bind of your own on that key survives job changes.
- **The keys live in the `<Keybinds>` section of the settings file**, under the mode words above, in the short spelling. A value there that is not a key is replaced by the default for that session, with a line saying so.

---

## 4. Modes

A "mode" is a named switch the engine reads when choosing gear. Cycle a mode with its keybind or with the bare command, or jump straight to a value by passing it.

### OffenseMode

The main damage-versus-survival switch. Drives `sets.OffenseMode`, `sets.WS`, `sets.Idle` and ammunition selection.

- **Default options:** `TP` `ACC` `DT`
- **Set your own in your job file:**
  ```lua
  state.OffenseMode:options('TP','PDL','ACC','DT','MEVA','CRIT','SB')
  state.OffenseMode:set('DT')
  ```
- **Command:** `//gs c OffenseMode PDL` · **Default key:** <kbd>F12</kbd>

Every option you list needs its own `sets.OffenseMode.<Name>` and `sets.Idle.<Name>` — see [Core sets](#core-sets) for what a missing one costs.

### WeaponMode

Which weapon set to equip, without touching your gear sets.

- **Options are entirely yours:**
  ```lua
  state.WeaponMode:options('Chango','Shining One','Naegling','Mpaca')
  state.WeaponMode:set('Chango')
  ```
- **Command:** `//gs c WeaponMode "Shining One"` · **Default key:** <kbd>F9</kbd>
- Each option needs a matching `sets.Weapons.<Name>`.
- Changing the mode also checks again whether your main weapon is two-handed, and calls your `self_command_custom` before your gear changes.
- The values `Locked` and `Unlocked` name no set of their own. A file that still offers either has it applied as the weapon lock setting, and the engine says so: `Weapon Lock: [Locked] (from weapon mode Locked)`.

### WeaponLock

Whether anything but the weapon mode may change main and sub. The mode says what the weapons *are*; the lock says whether they stay.

| Value | Behavior |
|---|---|
| `Unlocked` | Any set may change main and sub, except during a weaponskill |
| `Locked` | `sets.Weapons[<mode>]` is the only thing that changes main and sub, in every phase |
| `Songs` | Bard only — `Locked`, except for a song aimed at yourself, another player or a Trust |
| `Locked+R` | Corsair only — holds range with main and sub |
| `Geomancy` | Geomancer only — `Locked`, except for a Geomancy spell, whose set's main and sub swap in for the cast |

- **Command:** `//gs c weaponlock Locked` · **Default key:** <kbd>F10</kbd>
- **The engine fixes this list per job and a job file never redeclares it** — a job file's own `:options()` call wipes it. To boot locked, call `state.WeaponLock:set('Locked')` and nothing else.
- `Locked+R` is refused while a Hoxne mode is on, because the Hoxne hold outranks the weapon lock on range: `Weapon Lock: [Locked+R] refused; Hoxne Ampulla holds range.` Asked for by name, the lock stays where it was; while cycling, `Locked+R` is skipped.
- Whatever the value, a weaponskill never changes main or sub — see [Weaponskills](#weaponskills). The full behavior is under [The weapon lock](#the-weapon-lock).

### TreasureHunter

The engine remembers which monsters you have already tagged, so it only wears TH gear when it will do something.

| Mode | Behavior |
|---|---|
| `None` | Never equip TH gear |
| `Tag` | Equip TH gear for the action that tags the monster, then return to full damage |
| `Full Time` | Keep TH gear on while engaged, tagged or not |
| `SATA` | THF only — like `Full Time`, but only while Sneak Attack, Trick Attack or Feint is up |

In every mode but `None`, an **untagged** monster gets the set: that is the swing that applies the tag. The modes differ in what happens afterward.

Defaults to `Full Time` on THF and `None` on every other job. Tagged monsters are forgotten after three minutes of inactivity, and cleared entirely when you zone.

- **Command:** `//gs c TreasureHunter "Full Time"` · **Default key:** <kbd>F11</kbd>

### SpellReceived

For players running more than one character. When another of your characters casts a supported spell on you, this character equips its "received" gear *before the spell lands* — even through Quick Magic.

| Mode | Behavior |
|---|---|
| `ON` | Equip received gear and hold those slots until the spell resolves |
| `OFF` | Disabled |

Defaults to `ON`. Every switch, in either direction, releases everything the feature is holding.

- **Command:** `//gs c SpellReceived ON` · **Default key:** <kbd>Ctrl</kbd>+<kbd>F9</kbd>

Requires the corresponding `*_Received` sets. See [Spell-received tracking](#spell-received-tracking).

### Hoxne

Keeps Hoxne Ampulla in your ammo slot, and uses the item for you whenever its enchantment has worn off and the item is off cooldown.

- **Options:** `OFF` `ON-Allow Critical` `ON-Locked`
- **Command:** `//gs c hoxne`, or `//gs c hoxne ON-Locked` · **Default key:** <kbd>Ctrl</kbd>+<kbd>F10</kbd>

Full behavior, including what each on state does with the range slot, is under [The Hoxne Ampulla hold](#the-hoxne-ampulla-hold).

### JobMode and JobMode2

Two free-form modes for anything a job needs. The engine tracks the value and shows it; what it *means* is up to your job file. Left alone, both offer `OFF` and `ON`.

```lua
UI_Name  = 'TP Mode'       -- name used in chat messages and the status box
state.JobMode:options('Standard','Melee','Ranged','Subtle Blow')
state.JobMode:set('Standard')

UI_Name2 = 'Pet'
state.JobMode2:options('None','FatsoFargann','ScissorlegXerin','GenerousArthur')
```

- **Commands:** `//gs c JobMode Ranged` · `//gs c JobMode2 FatsoFargann`
- **Default keys:** <kbd>Ctrl</kbd>+<kbd>F12</kbd> and <kbd>Ctrl</kbd>+<kbd>F11</kbd>
- Both call your `self_command_custom` before the gear rebuild, which is where a job file usually acts on them.
- If `UI_Name` is left empty the mode is hidden from the status box and its key is not announced.

The shipped COR and RNG samples use the first slot for a TP mode, BST for its jug pet, and BLU for an AoE-versus-melee switch. `Job_Mode_Check` is the engine helper that turns any of these into a weapon set — see [Helpers the engine supplies](#helpers-the-engine-supplies).

**Status box labels.** The box needs a short label, and the engine derives one from `UI_Name` automatically. A table of known names is checked first:

| `UI_Name` | Label |
|---|---|
| `Mode` | `MDE` |
| `Pet` | `PET` |
| `TP Mode` | `TPM` |

Anything else takes a general rule: a single word gives its first three letters, several words give two letters of the first plus the initial of the last — `Skillchain` becomes `SKI`, `Blood Pact` becomes `BLP`. Set `UI_Short` (and `UI_Short2`) to override it. An explicit value is used verbatim, and the label column widens to fit if it runs past three characters.

```lua
UI_Name  = 'Blood Pact'
UI_Short = 'BP'            -- optional; overrides the derived BLP
```

### RAMode

Which ammunition table to read: `Bullet`, `Arrow` or `Bolt`. Defaults to `Bullet`. It has no `gs c` command of its own — a job file sets it, and the shipped RNG file reads it when it assembles its ammunition keys. See [Ammunition](#ammunition).

---

## 5. Commands

All commands are typed as `//gs c <command>` in the chat line, or as `/console gs c <command>` in an in-game macro, and are **case-insensitive**.

`//gs c help` lists them in game, grouped, with the key each mode is on:

```
Modes: offensemode [F12]  weaponmode [F9]  weaponlock [F10]  treasurehunter [F11]
Modes: jobmode [Ctrl+F12]  jobmode2 [Ctrl+F11]  hoxne [Ctrl+F10]  spellreceived [Ctrl+F9]
Display: display  displaymode  displaystyle  displaypos  displaycells  zero  save
Holds: naked  weaponsonly  abysseaproc  nakedunlocked  disable  enable  enableall
Locks: capacity  aptitude  mecisto  dynamisrp  jubilee
Items: use  cancel  food  temps  warp  warp club  holla  dem  mea  trizek
Utility: keybind  help  version  profile  shutdown
Diagnostics: checksets  gearreporting  enchinfo  capinfo  hoxneinfo  warn  info  debug
gs c help <group> for each command's form, e.g. gs c help modes
```

`//gs c help <group>` gives each command in that group with its form and purpose. The groups are `modes`, `display`, `holds`, `locks`, `items`, `utility` and `diagnostics`.

The engine matches a command by whole words, never by part of one, so `gs c use hoxne ampulla` uses the item rather than changing the Hoxne mode.

**Switches.** Every command that turns something on or off works the same way. Typed bare, it flips the setting; with `on` or `off`, it sets it outright. The outright form is the one to send to all your characters at once, since it leaves them all alike, whatever state each was in.

### Argument validation

**With no argument, every mode command cycles forward one step** — `//gs c TreasureHunter` steps `None` to `Tag` to `Full Time` and wraps. A stray trailing space still counts as no argument.

**With an argument**, the value must be one of that mode's options, matched without regard to case. Anything else changes nothing and, with `gs c warn` on, reports why. The mode, display, hold and lock commands all answer a mistyped argument on the `warn` channel:

```
//gs c SpellReceived on-locked
Spell Received: "on-locked" is not a valid mode. Did you mean [ON]?
Usage: //gs c SpellReceived [OFF|ON]
```

A partial value is offered as a suggestion but never accepted, so `//gs c TreasureHunter full` is rejected with `Full Time` offered as the correction. The usage line always lists the options *your job file* declared, not a fixed set.

### Mode commands

| Command | Description |
|---|---|
| `gs c OffenseMode [mode]` | Cycle, or jump to a melee mode |
| `gs c WeaponMode [mode]` | Cycle, or jump to a weapon set |
| `gs c WeaponLock [Unlocked\|Locked\|Songs\|Locked+R\|Geomancy]` | Cycle, or set the weapon lock |
| `gs c TreasureHunter [mode]` | Cycle, or jump to a TH mode |
| `gs c SpellReceived [ON\|OFF]` | Cycle, or set spell-received tracking |
| `gs c Hoxne [OFF\|ON-Allow Critical\|ON-Locked]` | Cycle, or set the Hoxne Ampulla hold |
| `gs c JobMode [mode]` | Cycle, or jump to a job-specific mode |
| `gs c JobMode2 [mode]` | Cycle, or jump to a second job-specific mode |

### Display commands

| Command | Description |
|---|---|
| `gs c display [on\|off]` | Show or hide the status box — `The UI is now shown; settings saved` |
| `gs c displaymode [on\|off]` | Turn the one-line view on or off — `One line display is: [ON]` |
| `gs c displaystyle [classic\|harness\|lattice\|halo]` | Cycle, or pick a style |
| `gs c displaypos [[status\|debug] <x> <y>]` | Put a box at a position, or report where both boxes are |
| `gs c displaycells [<n>]` | Set a minimum width for the status box's value column (`0` for none), or report it |
| `gs c zero` | Put both boxes back in the top-left corner |
| `gs c save` | Write settings to disk now — `Settings saved` |

Each of these saves its change. See [Moving and saving the boxes](#moving-and-saving-the-boxes).

At the character select screen these commands change nothing. With `gs c warn` on they say so — `Display mode: logged out; nothing changes until the next login.` — and `gs c save` always answers `Settings not saved: logged out; they are reloaded at the next login.`

### Holds and slot commands

| Command | Description |
|---|---|
| `gs c naked [on\|off]` | Bare all sixteen slots and hold them |
| `gs c weaponsonly [on\|off]` | Bare and hold the twelve armor slots, keeping weapons dressed |
| `gs c abysseaproc [on\|off]` | Bare and hold head, hands, legs and feet |
| `gs c nakedunlocked` | Bare every slot for an instant, with no hold |
| `gs c disable <slot>... \| all` | Hold the named slots wearing exactly what they wear |
| `gs c enable <slot>... \| all` | Release the named slots |
| `gs c enableall` | Release every slot the weapon lock is not holding, unconditionally, and dress you again |

Full behavior is under [Holds and locks](#6-holds-and-locks).

### Carried-item lock commands

| Command | Description |
|---|---|
| `gs c capacity [on\|off]` | Wear the best capacity point cape you carry and hold the back slot |
| `gs c aptitude [on\|off]` | The same mode under a second name |
| `gs c mecisto [on\|off]` | The same mode under a third name |
| `gs c dynamisrp [on\|off]` | Wear the best Dynamis Divergence neck your main job carries and hold the neck slot |
| `gs c jubilee [on\|off]` | Wear Jubilee Ring and hold its ring slot |

`mecisto` names the mode; it does not force a Mecisto. Full behavior is under [Carried-item locks](#carried-item-locks).

### Enchanted items

| Command | Description |
|---|---|
| `gs c use <item>` | Equip and use any enchanted item; handles slot, equip delay and cooldown |
| `gs c cancel` | Stop an item use that is under way and give the slot back |
| `gs c food` | Use the item named in your `Food` variable |
| `gs c temps` | Drink the six Escha temporary items in sequence |
| `gs c warp` | Use Warp Ring |
| `gs c warp club` | Use Warp Cudgel |
| `gs c holla` | Use Dim. Ring (Holla) |
| `gs c dem` | Use Dim. Ring (Dem) |
| `gs c mea` | Use Dim. Ring (Mea) |
| `gs c trizek` | Use Trizek Ring |

**`gs c use` handles the whole sequence for you**: it equips the item, waits out its equip delay, uses it, then gives your slot back. Type the item name in lower case, spaces and all, exactly as it appears in game — including any `+1`.

```
//gs c use warp ring
//gs c use prishe's boots +1
//gs c use volte harness
```

Every enchanted item the game's own item data marks usable on yourself is covered, so the shortcut commands above are convenience only, for the items people reach for most.

It tells you what it is doing rather than failing silently. Before equipping anything it checks that you own the item, that your job, level and race can wear it, and that it is not on cooldown, and it names whichever check failed:

```
Equipping and using [Warp Ring]
Warp Ring is on cooldown [8:32].
Volte Harness cannot be worn by this job.
Prishe's Boots +1 requires level 99; your WHM is 76.
Unknown enchanted item: [wrap ring]
```

Cooldown and equip delay are read live from the item itself, so the times are accurate and survive a `//gs reload` or a relog. If the timing ever looks wrong, `gs c enchinfo <item>` prints what the engine can see — see [Diagnostics](#diagnostics).

**The slot is held for the whole use.** A gear change during a fight, a buff wearing off or a weapon-mode change leaves the item where it is until the use finishes. Zoning cancels the use and gives the slot straight back.

**Changing your mind.** `gs c cancel` stops a use that is under way, hands the slot back and re-equips your normal gear. You rarely need it, because any new `gs c use` or shortcut takes over from the one already running:

```
//gs c warp
//gs c trizek
```

The Warp Ring is dropped and the Trizek Ring takes its place. Two things are worth knowing:

- **Re-typing the same command changes nothing** — the running use keeps its place and the engine answers `Warp Ring is already in progress.`
- **Once the item has been used it cannot be called back** — `Warp Ring: already sent and cannot be recalled; move to interrupt it.` Canceling afterward still frees your slot and restores your gear; to stop the effect, move to interrupt it, as you would a spell.

### Utility

| Command | Description |
|---|---|
| `gs c help [<group>]` | List every command by group, with each mode's key. With a group, list each command's form and purpose |
| `gs c keybind` | List the mode keys |
| `gs c keybind <mode> <key\|none\|default>` | Move one mode to another key, take its key away, or put it back — see [Choosing your own keys](#choosing-your-own-keys) |
| `gs c keybind default` | Put all eight mode keys back on their defaults |
| `gs c version` | Print the running engine version — `Include Version is [2.1]` |
| `gs c profile <path>` | Run a Windower script named for your job, subjob and character |
| `gs c shutdown` | Terminate the game client |

`//gs c profile raid` runs the Windower script `raid/WAR_SAM_Yourname`: the folder you name, then a script named for your main job, subjob and character. Name a folder of letters and digits: any other character splits the name, and the parts are joined with underscores, so `//gs c profile scripts/raid` runs `scripts_raid/WAR_SAM_Yourname`.

### Diagnostics

These answer questions about what the engine is doing. All are safe to run at any time and none of them change your gear.

| Command | Description |
|---|---|
| `gs c checksets` | Audit your job file: how many sets carry gear, how many you never declared, and which declared sets are empty. Also clears warning silences |
| `gs c gearreporting [on\|off]` | Switch the running trace of precast, midcast and aftercast, and what each fell back through |
| `gs c enchinfo <item>` | Print an enchanted item's live charges, equip delay and cooldown |
| `gs c capinfo` | List every capacity point cape you carry, what each is worth, which the mode picks, and what is worn |
| `gs c hoxneinfo` | Print what the Hoxne subsystem sees: mode, slots, buff, cooldown, retries |
| `gs c warn [on\|off]` | Switch warnings about your sets — an empty set, a weapon in a weaponskill's gear, a misspelled buff set |
| `gs c info [on\|off]` | Switch informational messages, including the set each action wears |
| `gs c debug [on\|off]` | Switch the debug box and verbose engine logging |

Each of the four switches is saved in the character's settings file, so a channel you turn off stays off after a reload until you turn it back on.

**Every action names the set it used.** With `info` on, every action gets one line, pet actions and gear worn for an incoming spell included:

```
[Cure IV] [sets.Midcast.Cure][Used]
[Curaga II] [sets.Midcast.Curaga][Not Usable] -> [sets.Midcast][Used]
[Flame Breath] [sets.Pet_Midcast.Flame Breath][Used]
```

An Aftermath tier gets a clause of its own after the set the action chose, and so does every [buff set](#buff-sets) the action wore — `[Empty]` for one that holds no gear:

```
[Savage Blade] [sets.WS.Savage Blade][Used] + [sets.WS.AM3][Used]
[Victory Smite] [sets.WS.Victory Smite][Used] + [sets.WS.Impetus][Used]
```

**`gs c checksets`** is the one to run after writing a job file. It separates a set you never declared from one you declared and left empty — the second is almost always a set you meant to fill in:

```
//gs c checksets
Sets with gear: 63.  Engine placeholders left undeclared: 88.
Declared [Empty] sets: sets.Midcast.Enhancing, sets.Precast.Enhancing
```

A set you placed under several names is listed under each of them. With nothing to report it answers `Declared [Empty] sets: none.`

**The channels answer different questions.** Leave `info` on for a running commentary, `warn` on to hear only about problems, and turn `gearreporting` on when you want to see why. Replies to commands you type, confirmations of a change, hold announcements and the startup key list always print, whatever the four switches are set to, except a refused argument, which is answered on `warn`. Gear and action reporting stays on `info`, the channel to turn down in a long fight.

**`gs c gearreporting`** answers "why that set?" It traces all three steps of a swap, and the whole fallback path when a set it reached for was empty. A clause at the end of a line names the buff sets that step added:

```
Precast: Using sets.Precast.Cure [Filled]
Attempted to use sets.Midcast.Regen [Empty] falling back -> Using sets.Midcast [Filled]
Aftercast: Using sets.OffenseMode.DT [Filled] + Buff children sets.OffenseMode.Impetus [Filled]
```

It is off by default, and worth turning off again once you have your answer — it prints three lines for every action.

**Warnings silence themselves per set** for 60 seconds so a long fight stays readable, and tell you when they do. A set that speaks again reports what it held back:

```
[sets.JA.Light Arts] is empty!  Silencing warnings for 60s (4 silenced since the last).
```

**`gs c enchinfo <item>`** shows why an item use is waiting:

```
//gs c enchinfo warp ring
Warp Ring: equipped=true usable=false charges=1 activation +6s next_use -515s (epoch-corrected)
  -> engine sees: cooldown 0s (warns/refuses), equip delay 9s (waits quietly)
```

In the second line, a **cooldown** means the item is not ready and the command is refused; an **equip delay** is a wait the engine sits out on its own.

**`gs c capinfo`** shows which capacity point cape the mode picks, and why:

```
//gs c capinfo
capinfo: 2 carried; mode [ON] holding back.
  Aptitude Mantle +1  +30%        -   <- chosen
  Aptitude Mantle     +25%        -
  back holds Aptitude Mantle +1 -- matches.
```

The highest value wins: a Mecisto. Mantle whose augment is worth more than either Aptitude Mantle is chosen. Two copies of one cape name look the same in your equipment, so when a Mecisto is chosen the last line confirms the *name* but cannot tell which copy is worn — the case this command exists for.

### Engine-internal

`gs c help` leaves these words out: they belong to the engine, and you never need to type them. Four of them — `update auto`, `enchrepair`, `hoxnerelock` and `hoxnerelease` — are commands the engine sends itself. Every word here still answers if typed, and all are listed so you recognize them in a verbose log.

| Command | What it does |
|---|---|
| `gs c update auto` | Rebuilds the set your current state calls for, and wears it. The engine sends it after every job change and whenever something calls for a rebuild. If no set produces any gear it says so — see [A set warning in chat](#a-set-warning-in-chat) |
| `gs c two_hand_check` | Re-reads whether your main weapon is two-handed. The engine does this itself at load and on every weapon-mode change |
| `gs c enablebymode` | Releases only the slots no hold is still claiming — the routine release the engine runs on a zone change, when Doom or Sleep wears off, and at the end of every item use |
| `gs c tomahawk` · `gs c angon` | Equips Thr. Tomahawk or Angon, then uses Tomahawk (WAR) or Angon (DRG) on your target once the item is on. Every reason it could fail is answered before any gear moves — `Tomahawk is not available (wrong job or level).`, `Tomahawk is on cooldown [0:43].` — and the item search covers every equippable bag, preferring a copy you are already wearing. A typed `/ja` does the same job — see [Automatic gear rules](#automatic-gear-rules) |
| `gs c enchrepair` | Sent by the enchanted item engine when an item it is using is knocked out of its slot |
| `gs c hoxnerelock` | Sent by the Hoxne Ampulla's background check, re-asserting its hold on range and ammo |
| `gs c hoxnerelease` | Sent by the Hoxne Ampulla's background check, freeing a stranded Ampulla after a reload |

---

## 6. Holds and locks

Several features take a gear slot and keep it. Only one thing holds a slot at a time, and a refusal always names what holds it.

### How the holds stack

Strongest first. A holder may take a slot from anything below it; asking for one held from above is refused, and the refusal says who has it.

| | Holder | Named in chat as |
|---|---|---|
| 1 | An enchanted item use | `an item use` |
| 2 | The disable hold | `gs c disable` |
| 3 | A strip hold — `gs c naked`, `gs c weaponsonly`, `gs c abysseaproc` | the word you typed: `gs c naked`, `gs c weaponsonly` or `gs c abysseaproc` |
| 4 | The Hoxne Ampulla hold | `the Hoxne hold` |
| 5 | Sleep gear | `Sleep gear` |
| 6 | The cast in progress | `the cast in progress` |
| 7 | Received gear | `received gear` |
| 8 | The carried-item locks | — they never refuse; they wait |
| 9 | The weapon lock | `the weapon lock` |

A refusal reads one line per holder, strongest first, with the slots in the order of the game's equipment window:

```
Aptitude Mantle +1: back is held by an item use right now.
Received gear: head, body are held by gs c naked right now.
```

A refusal that answers a command you just typed always prints. One raised while the engine was building gear on its own prints only while `gs c info` is on.

### Strip holds

Three commands bare a set of slots and *hold* them bare. While a strip hold stands, only an item use can put gear in its slots.

| Command | Slots |
|---|---|
| `gs c naked` | All sixteen |
| `gs c weaponsonly` | The twelve armor slots — main, sub, range and ammo stay dressed |
| `gs c abysseaproc` | Head, hands, legs and feet |

Each takes `on` or `off`, like every switch. `on` also re-applies the hold if something else took one of its slots, and `off` answers `Naked: already [OFF]` when the hold is not standing. Anything else is refused:

```
Naked: "yes" is not on or off.
Usage: //gs c naked [on|off]
```

**One hold stands at a time.** Typing a second word while the first stands switches to the new hold — going from `naked` to `weaponsonly` hands the four weapon slots back and keeps the twelve.

`gs c nakedunlocked` is the momentary form: it bares every slot it can and holds nothing, so the next action or the engine's next check dresses you again. Every hold that already had a slot keeps it.

### The disable hold

`gs c disable <slot> [<slot> ...]` holds the named slots wearing exactly what they already wear. Nothing is equipped and nothing is unequipped — the gear staying where it is is the whole point. `gs c enable <slot>...` releases them, and `all` on either word means the sixteen.

```
//gs c disable head ear1
//gs c disable all
//gs c enable head
```

A bare `gs c disable` prints the usage and what stands. **One unrecognized word refuses the whole command before any slot is touched:**

```
Disable: "helm" is not a slot.
Usage: //gs c disable <slot>... | all
```

Accepted slot words are the sixteen slot names plus the spellings people actually type: `main sub range ranged ammo head body hands legs feet neck waist back ear1 ear2 lear rear learring rearring left_ear right_ear ring1 ring2 lring rring left_ring right_ring`, plus `all`.

GearSwap's own `//gs disable` and `//gs enable` are not tracked by this engine. Using one with a slot name gets a single line pointing at the tracked form:

```
Disable: //gs disable leaves the slot untracked -- use //gs c disable <slot>... instead.
```

(A bare `//gs disable`, which switches your whole job file off, is left alone.)

### The weapon lock

`gs c weaponlock` is a [mode](#weaponlock) rather than a momentary hold, and <kbd>F10</kbd> cycles it by default. Under `Locked`, `sets.Weapons[<your weapon mode>]` is the only thing that changes main and sub, in every phase — precast, midcast and aftercast alike. No other set can put a different weapon beside the locked pair: not a pet, Sublimation or movement set, and not a buff set. The pair starts as whatever you are wearing, so a slot the mode names nothing for is held as found.

Three jobs get a value of their own:

- **Bard's `Songs`** stands aside for a song aimed at yourself, another player or a Trust. A song aimed at a monster stays locked, and so does everything else.
- **Geomancer's `Geomancy`** stands aside for every Geomancy spell, `Indi-` and `Geo-` alike, whatever the target. The main and sub named in that spell's own sets swap in for the cast, and your weapon set's pair comes back after it.
- **Corsair's `Locked+R`** holds range as well, and stands down to `Locked` if a Hoxne mode takes range:

  ```
  Weapon Lock: [Locked] (Hoxne Ampulla holds range)
  ```

Under every value, `Unlocked` included, a weaponskill leaves main and sub as they are — see [Weaponskills](#weaponskills).

`gs c enableall` does **not** turn the lock off — the lock is a mode, and `gs c weaponlock` is what ends it.

### The Hoxne Ampulla hold

Holds Hoxne Ampulla in your ammo slot, keeps it there when something knocks it out, and uses it automatically whenever the enchantment has worn off and the item is off cooldown.

**`ON-Locked`** holds range and ammo outright. Nothing else may enter either slot, so instruments, handbells, Angon and Thr. Tomahawk will not equip while it is on:

```
Hoxne locked. Range and ammo are held; instruments and Angon/Tomahawk will not equip.
```

**`ON-Allow Critical`** holds both slots the same way, but stands aside for the handful of actions that genuinely need them:

```
Hoxne locked. Songs, Geomancy, Tomahawk and Angon may borrow range/ammo.
```

| Action | Slot borrowed |
|---|---|
| Bard songs | `range` (instrument) |
| Geomancy — both `Geo-` and `Indi-` | `range` (handbell) |
| Tomahawk (WAR) | `ammo` (Thr. Tomahawk) |
| Angon (DRG) | `ammo` (Angon) |

The slot is released as the action starts and reclaimed afterward — within a second for the two job abilities, and five seconds after the last cast for songs and Geomancy, so a full song rotation or a Geo/Indi pair is treated as one continuous window rather than fighting you between casts. An interrupted song holds its instrument for those same five seconds, so a re-sing inside them shows no flicker.

> **Bards and Geomancers should use `ON-Allow Critical`.** Honor March and Aria of Passion can only be cast while Marsyas or Loughnashade is equipped, and `ON-Locked` blocks the instrument, so those two songs fail outright with a command error. Geomancy needs its handbell for the same reason.

Equipping an instrument or handbell makes the game clear your ammo slot, so the Ampulla is dropped for the duration and put back when the window closes. That is expected, not a fault.

**Turning it on.** The mode refuses to move at all while a disable hold or a strip hold owns range or ammo, and names what has them. It refuses to turn on when the item is not in your bags, and turns itself back off:

```
Hoxne Ampulla not found.  Not locking range/ammo
Hoxne Ampulla Mode: [OFF]
```

Automatic use waits out the item's equip delay and its recast, so the first use after switching the mode on takes a few seconds. If it is genuinely on cooldown you get one line with the time remaining, not a repeated one. The game refuses item use while you are mounted, so the automatic use holds for the ride and fires promptly once you dismount; while you are dead the mode stops scanning entirely and picks up again when you are raised.

**Zoning turns the mode `OFF`** and restores your normal gear — `Hoxne Ampulla Mode: [OFF] (zoned)`. Reloading GearSwap resets it to `OFF` too; the engine frees a stranded Ampulla and puts your gear back on its own within a few seconds of loading. `//gs c hoxneinfo` prints everything the mode is acting on — the slots, the buff and the item's timers.

### Carried-item locks

These **wear** an item and keep it there. Nothing your job file equips takes that slot back while the mode is on. Each takes `on` or `off`, like every switch, and announces each change.

```
//gs c capacity          -- flip it
//gs c jubilee on        -- set it on
//gs c dynamisrp off     -- set it off
```

| Mode | What it wears |
|---|---|
| `gs c capacity` · `gs c aptitude` · `gs c mecisto` | The best capacity point cape you carry: Aptitude Mantle +1 (+30%), Aptitude Mantle (+25%), or a Mecisto. Mantle, valued by its own augment. The three commands are one mode |
| `gs c dynamisrp` | The best rank of your main job's Dynamis Divergence neck that you carry — +2 over +1 over the base piece |
| `gs c jubilee` | Jubilee Ring |

The two chooser modes scan your inventory and wardrobes when you switch them on, and name what they settled on with its value:

```
Aptitude Mantle +1 (+30%): [ON] held in back.
Mecisto. Mantle (+50%): [ON] held in back.
War. Beads +2: [ON] held in neck.
Aptitude Mantle +1: [OFF]
No capacity point cape found in inventory or wardrobes.
No WAR Dynamis neck found in inventory or wardrobes.
```

Because their item is chosen rather than fixed, setting one on while it is already on **chooses afresh** — a cape whose augment reads higher, or a neck rank you have acquired since. `gs c jubilee on` while on puts the same ring back instead, which is how to repair the slot if something else took it.

**They never take a slot from another hold**, the weapon lock included: a slot something else is holding is refused and named, and the mode waits. They also let go on their own when they must — if the item leaves your bags, or a level sync drops it below what you can wear, the mode switches itself off instead of holding an empty slot shut. And if an `/equipset`, the server or `//gs enable` takes the slot, the mode puts the item back the next time your gear is chosen.

Entering a Dynamis Divergence zone prints a reminder:

```
Entering Dynamis Divergence - Use "gs c dynamisrp" to equip and lock your JSE neck.
```

Zoning releases every lock mode — `Lock modes released (zoned).` — and so does unloading your job file.

### Releasing a slot

`gs c enableall` is the manual override. It clears the disable hold, then the strip hold, then the lock modes, frees every slot the weapon lock is not holding, and dresses you again.

`gs c enableall` releases range and ammo even while a Hoxne mode is on. The mode notices within a second and takes them back, and says so:

```
Hoxne Ampulla Mode is [ON-Locked]; its hold returns shortly.
```

If you want them free, switch Hoxne to `OFF`.

---

## 7. Job file settings

Plain variables you set near the top of your job file.

### Startup

| Variable | Type | Description |
|---|---|---|
| `LockStylePallet` | string | In-game Equip Set number applied on load — `"8"` |
| `MacroBook` | string | Macro book to switch to — `"4"` |
| `MacroSet` | string | Macro page to switch to — `"1"` |
| `Random_Lockstyle` | boolean | Pick a random lockstyle from the list below on each job change |
| `Lockstyle_List` | table | Candidates for random selection — `{1, 2, 6, 12}` |

Apply them by calling `jobsetup(LockStylePallet, MacroBook, MacroSet)` once, outside `get_sets()`. That call also binds the mode keys — the defaults, or the keys you chose with `gs c keybind` — and prints the key list. Every sample already makes this call, above `get_sets()`.

### Behavior

| Variable | Type | Default | Description |
|---|---|---|---|
| `AutoItem` | boolean | `false` | Use a Remedy and a Holy Water automatically for status ailments |
| `Food` | string | — | Item used by `//gs c food` — `"Sublime Sushi"` |
| `Ammo_Warning_Limit` | number | `99` | Warn on precast when your ranged ammunition falls to this count or below |
| `UI_Name` | string | `''` | Name used for JobMode in chat and on the box; empty hides the mode |
| `UI_Name2` | string | `''` | Name used for JobMode2; empty hides the mode |
| `UI_Short` | string | `''` | Optional status box label for JobMode; derived from `UI_Name` when empty |
| `UI_Short2` | string | `''` | Optional status box label for JobMode2 |
| `Elemental_Bonus_Ring_Slot` | string | `"right_ring"` | The ring slot Zodiac Ring goes in when the day suits the spell — `"right_ring"` or `"left_ring"`. Every sample declares it inside `get_sets()` |
| `Bonus_Keep` | table | `{ ['Oneiros Rope'] = true }` | Pieces the engine never swaps out for a [day, weather or distance piece](#automatic-gear-rules) when your set names them in the waist, the back or the Zodiac Ring slot. Add one as `Bonus_Keep['Item Name'] = true`, spelled exactly as the game spells it |

### Ammunition

The engine reads `Ammo[<the current OffenseMode value>]` for every idle and engaged set, and for every ranged attack and ranged weaponskill, so your gear sets never have to name a bullet or an arrow.

**A round named there is worn idle and engaged in that mode, whatever weapon you hold.** A melee job that also shoots a bow should therefore name its arrows in its shooting sets — `sets.Precast.RA`, `sets.Midcast.RA` and `sets.WS.RA` — rather than in `Ammo[<mode>]`, or the arrows go on while you stand and fight too.

**A ranged weaponskill needs a round in its gear.** A job that fires ranged weaponskills names its round in `sets.WS.RA` — the RDM and SAM samples write `sets.WS.RA = { ammo = Ammo.RA }` — so the weaponskill fires in every mode, including one whose `Ammo` entry is empty. A ranged action with no round named is canceled, as [Troubleshooting](#a-ranged-attack-is-canceled-with-no-round-named) describes.

A ranged job that carries one weapon type can assign those keys directly:

```lua
Ammo.TP   = "Chrono Bullet"
Ammo.ACC  = "Eradicating Bullet"
Ammo.WS   = "Chrono Bullet"
```

A job that carries several keeps a table per type and assigns the flat keys from `state.RAMode`, which is what the shipped RNG file does:

```lua
Ammo.Bullet.TP = "Chrono Bullet"
Ammo.Arrow.TP  = "Chrono Arrow"
Ammo.Bolt.TP   = "Quelling Bolt"
-- ... and so on for ACC, CRIT, WS

Ammo.TP  = Ammo[state.RAMode.value].TP
Ammo.ACC = Ammo[state.RAMode.value].ACC
Ammo.WS  = Ammo[state.RAMode.value].WS
```

`Ammo.Bullet`, `Ammo.Arrow` and `Ammo.Bolt` are created for you.

**When a round runs out.** A weaponskill whose own round has run out still fires if the round already loaded is the standard one for your ranged type — the `.RA` key of `Ammo[state.RAMode.value]`, or its `.TP` key when there is no `.RA` — on Ranger as well as Corsair. A Quick Draw fires on whatever is loaded. Anything else whose round has run out is canceled, and so is any ranged action whose set names no round at all.

### Instruments

Bard files map song purposes to instruments, and the engine equips the matching one during a song's midcast.

| Key | When it is equipped |
|---|---|
| `Instrument.Count` | A dummy song |
| `Instrument.AOE_Sleep` | A Horde lullaby |
| `Instrument.Enfeebling` | An enfeebling song — also at precast under Nightingale |
| `Instrument.Potency` | Every other real song |
| `Instrument.Pianissimo` | A song aimed at one other player or a Trust |

```lua
Instrument.Count      = { name = "Daurdabla" }
Instrument.Potency    = { name = "Gjallarhorn" }
Instrument.Enfeebling = { name = "Gjallarhorn" }
Instrument.Pianissimo = { name = "Gjallarhorn" }
Instrument.AOE_Sleep  = { name = "Daurdabla" }
```

`Instrument.Pianissimo` also takes a per-family entry, so a single-target song can carry a different instrument from the party version of the same song:

```lua
Instrument.Pianissimo.Ballad = { name = "Miracle Cheer" }
```

All 25 song families are matched, Hymnus included. Honor March and Aria of Passion always take their required instrument instead. `Instrument.Idle`, `.TP`, `.Mordant`, `.QuickMagic`, `.FastCast` and `.MAB` are created for your own use — the shipped BRD file names them there and reaches for them from its own weapon sets.

---

## 8. Gear sets reference

Every set below is pre-created as an empty table by the engine, so you only fill in the ones you use. A set you never declare merges as nothing and the engine falls back to a more general one, which is normal and expected.

Two things help while building a file. **If you do not want a set for a spell, ability or weaponskill, delete its line rather than emptying it**: an empty set is reported in chat, and one you never declare is not — see [A set warning in chat](#a-set-warning-in-chat). And **`//gs c checksets`** lists both kinds — see [Diagnostics](#diagnostics).

All sets go inside `function get_sets()` in your job file. The idle, engaged, weaponskill and midcast sets below can also carry [buff sets](#buff-sets), worn while a buff is on you.

### Core sets

| Set | When used |
|---|---|
| `sets.Idle` | Standing still, not engaged — and merged as a floor under every precast and midcast |
| `sets.Idle.<Mode>` | Idle variant matched to the current OffenseMode — **declare one for every OffenseMode you offer** |
| `sets.Idle.Resting` | Resting |
| `sets.Idle.Pet` | Idle while you have a pet |
| `sets.Idle.Sublimation` | Idle while Sublimation is charging |
| `sets.Movement` | Layered on top of idle while moving and not engaged |
| `sets.OffenseMode` | Base melee set, always applied when engaged |
| `sets.OffenseMode.<Mode>` | Per-mode melee set — **declare one for every OffenseMode you offer** |
| `sets.OffenseMode.AM` / `.AM1` / `.AM2` / `.AM3` | Aftermath tiers, worn over the mode set |
| `sets.OffenseMode.AM3['<Weapon Mode>']` | An Aftermath tier refined for one weapon mode |
| `sets.DualWield` | Layered when the Dual Wield trait is detected |
| `sets.Enmity` | Not read by the engine — a building block the samples combine into `sets.JA['Provoke']` and the other enmity abilities |

An OffenseMode you offer with no matching child set costs you the rest of the engaged build: the weapons, the shield or dual-wield offhand, Aftermath and Treasure Hunter are all skipped. The base `sets.OffenseMode` still equips, which is what makes the gap easy to miss. Idle needs a child for every mode too: without `sets.Idle.<Mode>`, every idle rebuild prints `sets.Idle.PDL not found!` while `gs c warn` is on, though the rest of the idle set still goes on. An empty declaration is enough to close either gap.

An Aftermath tier set dresses you whichever weapon you hold; its weapon-mode child refines it on top. The child's key is the WeaponMode value, the same string `state.WeaponMode:options(...)` offers. Declaring the child alone is fine, and so is declaring only the tier.

### Weapons

| Set | When used |
|---|---|
| `sets.Weapons.<Mode>` | One per WeaponMode option |
| `sets.Weapons.Sleep` | Held on automatically while you are asleep |
| `sets.Weapons.Shield` | The offhand, merged last wherever the main is one-handed and no dual-wield trait is up |
| `sets.Weapons.Songs` | BRD instrument handling |
| `sets.Weapons.Songs.Precast` | Weapons held through a song's precast |
| `sets.Weapons.Songs.Midcast` | Weapons merged at a song's midcast |
| `sets.Weapons['Light Bonus']` | Worn whole on a Cure, Cura or Curaga cast on Lightsday or in Light weather, its own main and sub included unless the weapon lock holds them. Left empty, Chatoyant Staff goes in main instead when you carry one |

A song's precast wears `sets.Weapons.Songs` and then `sets.Weapons.Songs.Precast`; its midcast wears `sets.Weapons.Songs` and then `sets.Weapons.Songs.Midcast`. Idle and engaged gear, and a precast or midcast while the weapon lock holds your weapons, wear `sets.Weapons.<Mode>`. Either way, `sets.Weapons.Shield` goes on last, and only while your main is one-handed and you are not dual wielding.

### Precast

| Set | When used |
|---|---|
| `sets.Precast` | Base precast |
| `sets.Precast.FastCast` | Magic precast |
| `sets.Precast.Cure` | Cure precast |
| `sets.Precast.Healing` | Precast for Raise, Arise, Reraise, the -na spells, Esuna and Sacrifice |
| `sets.Precast.Enhancing` | Enhancing magic precast |
| `sets.Precast.Utsusemi` | Utsusemi precast |
| `sets.Precast.BlueMagic` | Blue magic precast |
| `sets.Precast.Songs` | Song precast |
| `sets.Precast.RA` | Ranged attack precast (Snapshot) |
| `sets.Precast.RA.Flurry` / `.Flurry_II` | With Flurry active — the only two children read here |
| `sets.Precast['<Spell Name>']` | A named precast for one spell, ahead of every branch above |
| `sets.JA` | Job abilities, stratagems, runes, wards and effusions — the catch-all each of them falls back to |
| `sets.JA['<Ability Name>']` | One job ability |

`sets.JA` and its named child sets are read for job abilities, and for stratagems, runes, wards and effusions; Corsair rolls and shots and Dancer's waltzes, jigs, sambas, steps and flourishes read their own sets instead (see [Job-specific sets](#job-specific-sets)). A pet command — Fight, Heel, Spur, Deploy and the rest — is not one of those, and has no set of its own: your pet's own actions are dressed by [the pet midcast sets](#midcast).

### Midcast

Offensive magic:

| Set | When used |
|---|---|
| `sets.Midcast` | The base for every cast, over `sets.Idle` |
| `sets.Midcast.SIRD` | Spell Interruption Rate Down — merged under every midcast except a ranged attack. Takes no buff sets |
| `sets.Midcast.Nuke` | Elemental nukes |
| `sets.Midcast.Nuke.Earth` | An extra layer for Earth nukes |
| `sets.Midcast.Burst` | Nukes during an open skillchain window |
| `sets.Midcast.Enfeebling.MACC` | Accuracy-based enfeebles (Dispel, Frazzle, Poison) |
| `sets.Midcast.Enfeebling.Potency` | Potency-based enfeebles (Paralyze, Slow, Addle, Distract, Blind, Gravity) |
| `sets.Midcast.Enfeebling.Duration` | Duration-based enfeebles (Sleep, Dia, Bio, Silence, Bind, Break, Inundation) |
| `sets.Midcast.Dark.MACC` | Death, Kaustra, Stun |
| `sets.Midcast.Dark.Absorb` | The Absorb- spells |
| `sets.Midcast.Dark.Enhancing` | Dread Spikes, Endark, Klimaform, Tractor |
| `sets.Midcast.Aspir` / `.Drain` | Every Aspir and Drain spell without a set of its own. These never reach the dark or enfeebling sets above |
| `sets.Helix` | Helix spells, with `.Dark` and `.Light` layered on top by element |
| `sets.Midcast.BlueMagic` | Blue magic, by family — see the note below |

`sets.Midcast.BlueMagic` holds the blue magic families — `.Physical`, `.Breath`, `.Nuke`, `.Skill`, `.Buff`, `.Enmity`, `.Healing` and `.ACC`. A blue spell with no set of its own wears the one family its class names, with `sets.Diffusion` over it while Diffusion is up. `sets.Midcast.BlueMagic` itself is never worn, so gear belongs in the families.

Healing and enhancing:

| Set | When used |
|---|---|
| `sets.Midcast.Cure` / `.Curaga` / `.Cura` | Cure family |
| `sets.Midcast.Cursna` | Cursna, layered over `sets.Midcast.Enhancing` |
| `sets.Midcast.Regen` / `.Refresh` | Regen and Refresh |
| `sets.Midcast.Enhancing` | Base enhancing magic. Also used by Raise, Arise, Reraise, the -na spells, Esuna and Sacrifice |
| `sets.Midcast.Enhancing.Others` | Cast on party members |
| `sets.Midcast.Enhancing.Skill` | Skill-scaling buffs (Temper, En-spells, Boost-*) |
| `sets.Midcast.Enhancing.Elemental` | Barfire, Barblizzard, … |
| `sets.Midcast.Enhancing.Status` | Barsleep, Barpoison, … |
| `sets.Midcast.Enhancing.Gain` | Gain-STR and friends |
| `sets.Midcast.Utsusemi` | Utsusemi midcast |
| `sets.Midcast.Phalanx` | Phalanx midcast |
| `sets.Midcast.Divine` | Divine magic — also the set RUN's Vivacious Pulse reads |
| `sets.Midcast.Skill` | Generic magic skill |
| `sets.Midcast.ACC` | Generic magic accuracy |
| `sets.Midcast['<Spell Name>']` | A named midcast for one spell |

Ranged and pets:

| Set | When used |
|---|---|
| `sets.Midcast.RA` | Ranged attack |
| `sets.Midcast.RA.<Mode>` | Per OffenseMode, in any mode but TP |
| `sets.Midcast.RA.TripleShot` / `.DoubleShot` / `.Barrage` | With the matching buff active |
| `sets.Midcast.RA['True Shot']` | True Shot |
| `sets.Midcast.RA.AM` / `.AM1` / `.AM2` / `.AM3` | Ranged Aftermath tiers, each with an optional `['<Weapon Mode>']` child |
| `sets.Midcast.BP` | Blood Pacts |
| `sets.Midcast.Summon` / `.SummoningMagic` | Summoning |
| `sets.Pet_Midcast` | Every pet action |
| `sets.Pet_Midcast['<Action Name>']` | One pet action — `sets.Pet_Midcast['Flame Breath']` |

Aftermath tiers under midcast are **ranged only**. Nothing merges an Aftermath tier into a spell midcast, so `sets.Midcast.AM3` and its siblings are inert.

Bard songs get one set per family under `sets.Midcast`: `.DummySongs`, `.Finale`, `.Lullaby`, `.Threnody`, `.Elegy`, `.Requiem`, `.March`, `.Minuet`, `.Madrigal`, `.Ballad`, `.Scherzo`, `.Mazurka`, `.Paeon`, `.Carol`, `.Minne`, `.Mambo`, `.Etude`, `.Prelude`, `.Dirge`, `.Sirvente`, `.Aria`, `.Fugue`, `.Hum`, `.Hymnus`, `.Virelai` and `.Nocturne`. Every castable song belongs to exactly one of them.

### Weaponskills

| Set | When used |
|---|---|
| `sets.WS` | Base, always applied |
| `sets.WS.<Mode>` | Per OffenseMode, in any mode but TP — `ACC`, `PDL`, `SB`, `CRIT`, `MEVA` |
| `sets.WS['<Weaponskill Name>']` | A specific weaponskill — `sets.WS['Savage Blade']` |
| `sets.WS['<Name>'].<Mode>` | A specific weaponskill in a specific mode |
| `sets.WS.AM` / `.AM1` / `.AM2` / `.AM3` | Aftermath tiers, each with an optional `['<Weapon Mode>']` child |
| `sets.WS.RA` | Ranged weaponskills, the base |
| `sets.WS.RA.<Mode>` | Ranged weaponskills per OffenseMode, in any mode but TP |
| `sets.WS.RA.AM` / `.AM1` / `.AM2` / `.AM3` | Ranged Aftermath tiers, each with an optional `['<Weapon Mode>']` child |

Named weaponskill sets layer on top of the generic ones, so you only specify what differs.

**A mode set names only what that mode changes.** In any mode but TP, a weaponskill wears `sets.WS`, then the set named for it, then the mode's set: in ACC mode, `sets.WS.ACC` goes on over `sets.WS['Savage Blade']`, unless that weaponskill has an ACC set of its own. A mode set copied from the whole of `sets.WS` would put the base pieces back over every named weaponskill's own gear. So give `sets.WS.ACC` only the slots ACC changes, and give a weaponskill that needs its own gear in a mode a set of its own, such as `sets.WS['Savage Blade'].ACC`. The same goes for `sets.WS.RA.<Mode>` over a named ranged weaponskill.

**Ranged weaponskill keys read `RA` first**: `sets.WS.RA.ACC`, not `sets.WS.ACC.RA`. A declaration written the other way round sits in a table the engine does not read.

**A weaponskill keeps the weapons in your hands.** Changing main or sub resets your TP, and so does changing a ranged weapon, so a weaponskill that swapped one would fail. Main and sub — and range, on every job but Bard and Geomancer — stay exactly as they are for the whole weaponskill, whatever your weaponskill sets, buff sets or `sets.Idle` name. With `gs c warn` on and the weapon lock off, a set that names one of those slots is pointed out, once a minute per set:

```
[Savage Blade] sets.Idle names main, sub; a weaponskill keeps the weapons in hand.  Silencing warnings for 60s.
```

Take the slot out of the set the line names. Weapons belong in `sets.Weapons`.

### Job-specific sets

| Set | Job |
|---|---|
| `sets.Waltz`, `sets.Jig`, `sets.Samba`, `sets.Step`, `sets.Flourish` | DNC — each with an optional child named for the ability |
| `sets.PhantomRoll`, `sets.QuickDraw` | COR — each with an optional child named for the roll or shot. The six elemental shots also take the [day, weather and distance pieces](#automatic-gear-rules) |
| `sets.Jugs` | BST — keyed by your JobMode value |
| `sets.Ready` | BST — the one set worn for a Ready move |
| `sets.Geomancy`, `.Geo`, `.Indi`, `.Indi.Entrust` | GEO |
| `sets.Storms` | SCH |
| `sets.Diffusion` | BLU |
| `sets.TreasureHunter` | THF, and anyone using a TH mode |

`sets.Ready.Magic`, `.TP`, `.Debuff` and `.Standard` exist for your own use; the engine wears only `sets.Ready` itself.

### Spell-received sets

Only needed if you use `SpellReceived`.

| Set | Received spell |
|---|---|
| `sets.Cure_Received` | Cure I–VI, Curaga I–V, Cura I–III |
| `sets.Cursna_Received` | Cursna — and the set worn and held when you are Doomed |
| `sets.Phalanx_Received` | Phalanx, Phalanx II |
| `sets.Protect_Shell_Received` | Protect I–V, Protectra I–V, Shell I–V, Shellra I–V |
| `sets.Regen_Received` | Regen I–V |
| `sets.Refresh_Received` | Refresh I–III |
| `sets.Waltz_Received` | Curing Waltz I–V, Divine Waltz I–II |
| `sets.Holy_Water` | Worn while curing Doom with a Holy Water |

### Buff sets

A **buff set** is a set named after a buff. While that buff is on you, it is worn over the set it sits under, and when the buff ends it comes off. No code is needed: declare the set, and the engine does the rest.

```lua
sets.OffenseMode.Impetus = { body = gear.bhikkuBodyPlusThree }              -- engaged, in every offense mode
sets.OffenseMode.TP.Footwork = { feet = gear.anchoriteFeetPlusFour }        -- engaged, in TP mode only
sets.WS['Victory Smite'].Footwork = { feet = gear.anchoriteFeetPlusFour }   -- that one weaponskill
sets.Midcast.Enfeebling.Saboteur = { hands = gear.lethargyHandsPlusThree }  -- enfeebling magic
sets.Midcast.Cure['Afflatus Solace'] = { body = gear.ebersBodyPlusThree }   -- Cure spells
```

**Spell the buff's name as the game does**, in any capitalization. A name with a space or a colon goes in brackets and quotes, as `['Afflatus Solace']` does above. Any key under the sets in the table below that is a buff's name is a buff set, whatever you meant it for.

**Where a buff set can go:**

| While you are | Put it under | It is worn |
|---|---|---|
| Idle | `sets.Idle` | Idle, in every offense mode |
| | `sets.Idle.<Mode>` or `sets.Idle.Resting` | Idle in that mode, or while resting |
| Engaged | `sets.OffenseMode` | Engaged, in every offense mode |
| | `sets.OffenseMode.<Mode>` | Engaged in that mode |
| Weaponskilling | `sets.WS` | On every weaponskill |
| | `sets.WS['<Weaponskill>']` and its mode sets | On that weaponskill |
| | `sets.WS.RA` | On ranged weaponskills |
| | `sets.WS.<Mode>` or `sets.WS.RA.<Mode>`, in any mode but TP | In that mode |
| Casting | `sets.Midcast` | On every spell's midcast, and every ranged attack |
| | A midcast family — `sets.Midcast.Cure`, `.Enfeebling`, `.Nuke`, `.Enhancing`, `sets.Midcast.BlueMagic.Nuke` and the rest | On the spells that set dresses |
| Shooting | `sets.Midcast.RA`, its mode sets in any mode but TP, and `sets.Midcast.RA.TripleShot`, `.DoubleShot` and `.Barrage` | On the shots that set dresses |
| Using a job's own sets | `sets.Helix` and its `.Dark` and `.Light` sets, `sets.Storms`, a Geomancy spell's own set, `sets.Geomancy.Indi` and its `.Entrust` set, `sets.Geomancy.Geo`, `sets.Diffusion` and `sets.Ready` | On the actions that set dresses |

Anywhere else, a buff set is never worn; the list is at the end of this section.

**Declaring them safely.** A buff set that seems to do nothing was most often written in the wrong order:

```lua
-- Right: the set it sits under first, then the buff set on a line of its own
sets.OffenseMode = { head = gear.nyameHead }
sets.OffenseMode.Impetus = { body = gear.bhikkuBodyPlusThree }

-- Wrong: the second line replaces the whole table, and the Impetus set with it
sets.OffenseMode.Impetus = { body = gear.bhikkuBodyPlusThree }
sets.OffenseMode = { head = gear.nyameHead }
```

- **Declare the set it sits under first, and give the buff set a line of its own.** A buff set written before its parent is lost when the parent's own line replaces the table, and one under a parent that does not exist at all stops the file from loading, with a Lua error in chat. One written inside a `set_combine(...)`, or under a parent your file later rebuilds with `set_combine`, is dropped, because `set_combine` keeps gear slots only. No loss is announced.
- **Under `sets.Midcast`, a buff that shares its name with a spell cannot be a buff set.** Haste, Refresh, Regen, Phalanx, Stoneskin, Klimaform, the storms and the en-spells are among them. Directly under `sets.Midcast` such a name is that spell's own set, and deeper under it the key is ignored. The same names work as buff sets under every set in the table above that is outside `sets.Midcast`.
- **`sets.Midcast.Diffusion` is a buff set** — worn on every spell while Diffusion is up. The engine's own `sets.Diffusion`, which dresses blue magic under Diffusion, is a different set.
- **A buff set is found as your file loads.** A file that declares none at load and adds one later from its own code wears it only after the next reload.

**How buff sets stack.** A buff set is laid over the rest of the gear being chosen for that moment, and a few things still beat it:

| A buff set wins its slots over | A buff set loses its slots to |
|---|---|
| The set it sits under, and the mode set | Treasure Hunter gear |
| Your weapon set, while the weapon lock is off | Your `Ammo` round |
| The Aftermath tiers | A song's instrument |
| The movement set, while you move | The weapon lock |
| | Anything your own [hooks](#12-customization-hooks) return |
| | Every [hold](#6-holds-and-locks) |

- **A buff set on a broad set reaches far.** `sets.WS.Impetus` goes on over every weaponskill's own set while Impetus is up, and a buff set directly under `sets.Midcast` over every spell's. Put it on a narrower set — `sets.WS['Victory Smite'].Footwork`, `sets.Midcast.Cure['Afflatus Solace']` — when it should dress only some actions. When a broad and a narrower buff set are both worn, the narrower one wins the slots they share.
- **A spell with a set of its own skips the family's buff sets.** Phalanx wears `sets.Midcast.Phalanx` and Dispelga `sets.Midcast['Dispelga']` in place of the enhancing or enfeebling set, so a buff set under that family is not reached. To dress such a spell too, put the same table under its own set as well, after both are declared: `sets.Midcast.Phalanx.Embolden = sets.Midcast.Enhancing.Embolden`.
- **A buff set under `sets.Idle` or `sets.OffenseMode` is not worn during an action.** A spell or weaponskill builds from `sets.Idle` itself and its own sets, so give the buff set to `sets.WS` or `sets.Midcast` as well when you want it there too.
- **Two buff sets under one set** both go on when both buffs are up. Where they name the same slot, the one whose name comes later in alphabetical order wins, so nest them when it matters which.

**Nesting.** A buff set can hold buff sets of its own, each worn only while every buff on the way to it is up: `sets.OffenseMode.Impetus.Footwork` goes on while Impetus and Footwork are both on you. Nesting goes three buffs deep, and the deepest set wins a slot it shares with the sets above it. A mode goes above the buff, never below it: `sets.OffenseMode.TP.Impetus` works, while `sets.OffenseMode.Impetus.TP` is never worn.

**Weapons and the day and weather pieces:**

| When a buff set names | What happens |
|---|---|
| Main, sub or range | It swaps your weapons when its buff arrives and again when it ends, and each swap resets your TP (range on every job but Bard) |
| Main or sub, under the weapon lock | Main and sub stay put |
| Range, at idle or while engaged | It is worn under every lock value but `Locked+R` |
| Range, on a spell or weaponskill under `Locked`, `Songs` or `Geomancy` | A range your weapon set names wins over the buff set's |
| Main, on a Light-day or Light-weather cure with the weapon lock off | It wins over Chatoyant Staff and `sets.Weapons['Light Bonus']` |
| Waist, back, or the ring slot Zodiac Ring uses, on a spell | It wins over the [day, weather and distance choice](#automatic-gear-rules), and the info line still names the piece that choice picked |
| Those three slots, on a magical weaponskill | The day, weather and distance choice wins them |

A weaponskill never changes the weapons at all — see [Weaponskills](#weaponskills).

**What chat tells you.** As your file loads, the `warn` channel names any key that is neither a gear slot nor a buff when it sits under a mode set, such as `sets.OffenseMode.TP` or `sets.Idle.DT`, or under a buff set:

```
sets.OffenseMode.TP.Footwrk is not a buff name
```

Directly under `sets.Idle`, `sets.OffenseMode`, `sets.WS`, `sets.Midcast` and the family sets, a misspelled name prints nothing and is never worn, so check the spelling there. The info line names each buff set a spell or weaponskill wore — `[Victory Smite] [sets.WS.Victory Smite][Used] + [sets.WS.Impetus][Used]` — and idle and engaged buff sets appear in the `gs c gearreporting` trace. The other load lines are under [A line about a buff set as your file loads](#a-line-about-a-buff-set-as-your-file-loads).

**What they cost.** Once your file declares any buff set, every gear change runs a small extra check, whether the buff is up or not. A file with none pays nothing. That is why the samples ship their extra buff sets for a job's own buffs commented out — remove the `--` in front of the ones you want — while the MNK, PLD, RDM, RUN, SAM and SCH samples below wear their buff gear through live buff sets.

**Where a buff set is never read:**

- precast sets other than the weaponskill sets, and `sets.JA`;
- `sets.Idle.Pet`, `sets.Idle.Sublimation` and `sets.Movement`, which go on after the idle set's own layers;
- the Aftermath tiers;
- `sets.WS.TP`, `sets.WS.RA.TP` and `sets.Midcast.RA.TP`, which TP mode never wears;
- `sets.Midcast.SIRD`;
- `sets.Midcast.BlueMagic` and `sets.Geomancy` themselves, which are never worn — use a family under them, such as `sets.Midcast.BlueMagic.Physical` or `sets.Geomancy.Indi`;
- `sets.Ready.Magic`, `.TP`, `.Debuff` and `.Standard`, which are never worn.

#### Buff sets in the sample files

- **MNK** wears Impetus, Footwork and Boost through `sets.OffenseMode.Impetus`, `.Footwork` and `.Boost`. Impetus and Boost are also placed under `sets.WS`, and Boost under `sets.Idle`, so they carry into weaponskills and idle. A Monk file that still declares `sets.Impetus`, `sets.Foot_Work` or `sets.Boost` keeps working: where the new name is not declared, the engine wears the old set in its place.
- **PLD** wears its Cover gear through `sets.Idle.Cover` and `sets.OffenseMode.Cover`, one table under both keys.
- **RDM** wears its Saboteur gear through `sets.Midcast.Enfeebling.Saboteur`, and puts the same table under the enfeebling spells that have sets of their own, such as Diaga and Dispelga.
- **RUN** wears its Embolden gear through `sets.Midcast.Enhancing.Embolden`, and puts the same table under the sets of Phalanx, Stoneskin, Aquaveil, Foil, Regen and Refresh: those four spells, and the first tier of Regen and Refresh, wear their own set instead of the enhancing set, while Regen II and higher wear the enhancing set with the Regen set over it.
- **SAM** wears its Seigan gear through `sets.OffenseMode.Seigan`, with a nested `['Third Eye']` set ready to uncomment.
- **SCH** wears its stratagem gear through buff sets under `sets.Midcast`, such as `sets.Midcast.Rapture`. Its Klimaform gear stays in the file's own code, because Klimaform is also a spell name.
- **WHM** carries a Divine Caress set, commented out, under each status-removal spell's own set, all sharing one table.
- **Every sample** ships an empty `sets.Idle.XIRoll` and `sets.Idle.TP.XIRoll`, ready for gear such as Roller's Ring (RDM has only the first), and most also carry buff sets for their job's own buffs, commented out.

### The XIRoll set

A Corsair roll lands with a number from 1 to 11. A set keyed `XIRoll` is worn while a Corsair's Phantom Roll on you stands at 11, for gear such as Roller's Ring. It goes anywhere a buff set can, nested ones included:

```lua
sets.Idle.XIRoll = { left_ring = "Roller's Ring" }
```

- **Any Corsair's roll counts**, yours or another player's. The engine reads each roll's total as it lands on you, and drops it when the roll busts or wears off, or when you zone. Nothing prints when a roll reaches 11.
- **An idle `XIRoll` set is worn at idle only.** `sets.Idle` is the floor under every precast and midcast, so if `sets.Idle` names that ring slot, your idle ring goes on for each action and the `XIRoll` ring comes back after it. To keep the ring on while engaged and through weaponskills and spells, give `sets.OffenseMode.XIRoll`, `sets.WS.XIRoll` and `sets.Midcast.XIRoll` the ring as well. The precast of a spell, an ability or an item still swaps it, since those precast sets take no buff sets.
- **After a reload or a job change,** the engine does not know the total until the next roll or Double-Up lands, or until another of your characters tells it. That character must be on the same computer, in your party, running 2.1 and holding that roll. If two of your characters hold the same roll at different totals, the reloading one keeps the first answer it hears until that roll's next Double-Up, re-roll or end.
- **A file whose only buff-style set is `XIRoll` pays nothing for it** until a roll on you stands at 11. A buff set placed under `XIRoll` counts like any other buff set.

### Spellings the engine does not read

Gear declared at a path the engine does not read sits there doing nothing. These are the spellings to search your file for:

| The engine reads | A spelling that reads as nothing |
|---|---|
| `sets.WS.RA.ACC`, `.PDL`, `.SB`, `.CRIT`, `.MEVA` | `sets.WS.ACC.RA` and friends |
| `sets.WS.RA.AM`, `.AM1`, `.AM2`, `.AM3` | `sets.WS.AM3.RA` and friends |
| `sets.Midcast.RA.AM`, `.AM1`, `.AM2`, `.AM3` | `sets.Midcast.AM3` and friends |
| `sets.Precast.BlueMagic` | `sets.Precast.Blue_Magic` |
| `sets.Midcast.Drain`, `sets.Midcast.Aspir` | `sets.Midcast.Enfeebling.Drain` and `.Aspir` |
| `sets.DualWield` | `sets.OffenseMode.DW` |
| `sets.Precast.RA.Flurry`, `.Flurry_II` | `sets.Precast.RA.ACC` and other mode children |
| `sets.Pet_Midcast['<Action Name>']` | `sets.JA['Spur']` and other pet-command names |

Under `sets.Midcast.Enfeebling` the engine reads `.MACC`, `.Potency` and `.Duration` and nothing else. A pet command has no set of its own — see [Precast](#precast).

---

## 9. The gear library

`GearSets-Include.lua` is a companion library of pre-built item entries — 4,912 of them. Instead of typing item names into your sets, you reference entries by key:

```lua
sets.Idle = {
    head = gear.nyameHead,
    body = gear.sakpataBody,
    left_ring = gear.moonlightRing,
    right_ring = gear.gelatinousPlusOne,
}
```

Every entry carries the item's name, any augments, an optional wardrobe pin, and a **priority** — and the priority is the point of the whole system.

It loads with the first of the two include lines at the top of every job file, which the samples already have (see [How it works](#1-how-it-works)). Then use `gear.<key>` anywhere you would write an item name. Plain item-name strings still work everywhere — they just swap without a priority.

### Why priorities matter

When GearSwap makes a quick chain of swaps — precast, midcast, aftercast, back to idle — your HP and MP can drop to the **lowest maximum reached at any moment during the swaps**, and stay there afterward. Equip low-HP gear before high-HP gear and your maximum HP dips mid-swap.

GearSwap equips the pieces of a set in priority order, highest first. The library sets each item's priority to its total HP, including augments, so higher-HP gear always lands first and the dip never happens: your maximum HP rises before it falls, and you keep the most HP and MP through every swap. Rahvin tested this in game against unprioritized swapping, and total-HP priorities kept the most HP and MP.

Items with MP and no HP get a small priority, compressed to 1–10, so they sort below anything carrying real HP. Items whose own HP is negative — the two HP-to-MP converter rings, the Apogee set — sort below everything.

Main- and offhand weapons all share one rank, **100**, instead of their HP, with shields, grips and straps below it. The main hand is then always dressed first, which empties the offhand slot in time when you switch between one-handed, two-handed and dual-wield sets. Give your own weapons the same rank — see [Adding your own entries](#adding-your-own-entries). Guns, bows and crossbows carry an ordinary HP priority.

### Finding the key you need

Keys follow consistent conventions:

| Kind of item | Convention | Examples |
|---|---|---|
| Ordinary gear | Item name in camelCase | `gear.moonlightRing`, `gear.sakpataBody` |
| Quality tiers | `PlusOne` … `PlusFour` spelled out | `gear.odnowaPlusOne`, `gear.reverenceBodyPlusFour` |
| AF / Relic / Empyrean | Family + slot + tier | `gear.ebersHeadPlusThree`, `gear.agogeBody` |
| Escha sets with Nolan paths | Name + slot + path letter | `gear.souveranHeadPlusOnePathC`, `gear.amalricHandsPathD` |
| JSE back capes | Job + purpose | `gear.rngSnapshot`, `gear.drkFC`, `gear.corWSD` |
| Wardrobe copies of one item | Number for the wardrobe | `gear.rostam1` (Wardrobe), `gear.rostam2` (Wardrobe 2) |

To find a key, open `RahvinGS/GearSets-Include.lua` in a text editor and search for the item's name. The key is the `gear.` name at the start of that line: `gear.nyameHead = hp_gear("Nyame Helm", 91)` is Nyame Helm.

The library covers the full Artifact, Relic and Empyrean catalog for every job across the original era and every reforge tier, every Nolan augment path for the Escha and Geas Fete sets at maximum rank, every stage of every Trial of the Magians weapon, and the endgame gear the sample files reference. It also carries the day and weather pieces: `gear.hachirinNoObi`, the eight single-element obis such as `gear.karinObi`, `gear.twilightCape` and `gear.zodiacRing`. Each entry carries an inline comment with the item's highlight stats, and armor set categories note their set bonus.

**A name must match the game exactly.** GearSwap compares against the item's name and its log name, without regard to case. A name matching neither equips nothing and reports nothing, which is why a misspelling is worse than an outright error.

Duplicate copies of one item — rings especially — are separate entries pinned to different wardrobes, which is the reliable way to equip both copies at once. Ask for `gear.chirich1` and `gear.chirich2` rather than the same name twice.

### Adding your own entries

Three builders are available after the include line, so you can define personal items in your job file the same way the library does:

```lua
gear.myCape  = hp_gear("Aptitude Mantle +1", 0)    -- priority = total HP
gear.myOrb   = mp_gear("Sapience Orb", 0)          -- MP-only item
gear.mySword = rank_gear("Excalibur", 100)         -- ordering token, not HP
```

Give a **main- or offhand** weapon the rank **100** the library uses for them — a different number puts it out of order with everything else and can leave an offhand slot occupied when it should be clear. A gun or bow wants `hp_gear` instead, like the rest of the library's ranged weapons.

The third argument is a table of extra attributes copied into the entry — an augment list, or a bag to pin the copy to:

```lua
gear.myCape = hp_gear("Rosmerta's Cape", 80, {
    augments = { 'HP+60', 'Eva.+20 /Mag. Eva.+20', 'HP+20', '"Fast Cast"+10', 'Damage taken-5%' },
})
gear.myRing2 = hp_gear("Chirich Ring", 0, { bag = "wardrobe2" })
```

Write the augments exactly as `//gs export` prints them, and the entry will match only that copy.

---

## 10. Automatic engine checks

These run without you asking. Most produce a chat message explaining what happened.

### The background loop

Runs about ten times a second:

- **Movement detection** — your position is read off the game's own movement messages and compared against the last one; more than half a yalm of movement while you are not engaged swaps in `sets.Movement`, and stopping swaps it back. The read is skipped while you are mounted, mid-action, asleep, charmed or dead.
- **Spell timeout** — clears the engine's busy state (`is_Busy` on the debug box) if an action never reported completion, so the engine cannot get stuck.
- **Gear refresh** — re-equips the correct set whenever something has changed that warrants it.
- **Every 2 seconds** — calls your `Cycle_Timer()` if you defined one, skipped while the engine is busy.
- **Every 30 seconds** — re-checks the Dual Wield trait and expires Treasure Hunter entries older than three minutes.

### Action validation

The engine refuses actions that would fail, before the action is sent to the game, and tells you why.

| Check | Result |
|---|---|
| Asleep | Canceled; idle plus `sets.Weapons.Sleep` equipped |
| Stunned, petrified or terrorized | Canceled; idle equipped |
| KO'd or charmed | Canceled |
| Pet is mid-action | Canceled |
| Weaponskill below 1000 TP | Canceled |
| Weaponskill with Amnesia | Canceled — `Can't Weapon Skill due to amnesia.` |
| Ability or spell still on cooldown | Canceled, remaining time shown as `m:ss` |
| Waltz without enough TP | Canceled — `Insufficient TP for Curing Waltz IV [780/800]` |
| Stratagem with no charge | Canceled — `Unable to use strategems. Next charge in [0:47].` |
| Paralyzed using an ability, or silenced casting | Uses a Remedy instead, if `AutoItem` is on and you carry one |

Macros aimed with a subtarget cursor, such as `/ma "Cure IV" <stpt>` or `/ws "Aeolian Edge" <stnpc>`, work as usual.

### Resource warnings

- **Ranged ammunition** — counted across your inventory and all eight wardrobes at precast. Your last rounds are never fired: a shot or ranged weaponskill is canceled unless you carry more rounds than it could spend — one for a weaponskill or a single shot, two under Double Shot, three under Triple Shot and eight under Barrage — while a Quick Draw may use its last round. At or below `Ammo_Warning_Limit` you get one banner, echoed to your other characters; it is said once rather than on every shot, until you restock above the limit.
  ```
  No ammo (Chrono Bullet) available for that action.
  Not enough ammo.  Canceling.
  ```
- **Ninja tools** — warns when your Shihei or Shikanofuda runs low, and echoes the warning to your other characters. It never cancels: casting the last shadows is exactly what a player out of tools wants to do.

### Automatic gear rules

- **Day, weather and distance pieces** — carry them, and no set has to name them. Some gear adds power to a spell whose element matches the day or the weather, or to one cast at a close target. On a nuke, an elemental ninjutsu, a blue magic nuke, a magical weaponskill, a helix, one of the six elemental Quick Draw shots, or a Cure, Cura or Curaga, the engine works out what each such piece you carry and can wear would add to this cast, and wears the best one for each slot. The pieces are Hachirin-no-Obi, the spell's own elemental obi (Karin, Hyorin, Furin, Dorin, Rairin, Suirin, Korin or Anrin), Orpheus's Sash within 10 yalms of the target, Twilight Cape, and Zodiac Ring.
  - A helix takes the sash, the cape and the ring, never an obi.
  - Zodiac Ring serves elemental magic on the day that matches the spell's element, never on Lightsday or Darksday. It goes in your right ring. For the left, set `Elemental_Bonus_Ring_Slot = "left_ring"` in your job file.
  - Cures take no sash, and a single-target Cure keeps your own back piece.
  - A spell with no element, such as Meteor, takes none of these.
  - A waist, back or Zodiac Ring slot your set fills with a piece listed in `Bonus_Keep` is left alone. Oneiros Rope is listed. Add your own as `Bonus_Keep['Item Name'] = true`.
  - One info line names what went on and what each piece adds:
    ```
    [Fire VI] waist: Hachirin-no-Obi (+6.7%, day), back: Twilight Cape (+5.0%, day), right_ring: Zodiac Ring (+3.0%, day)
    ```
- **Light cures** — a Cure, Cura or Curaga cast on Lightsday or in Light weather wears `sets.Weapons['Light Bonus']`, or Chatoyant Staff when that set is empty and you carry one — see [Weapons](#weapons).
- **Required equipment** — Dispelga equips Daybreak, Honor March equips Marsyas, Aria of Passion equips Loughnashade, Impact equips a Crepuscular or Twilight Cloak, and a White Mage main job carrying Yagrush casts Cursna with it. These are merged over everything else the build chose. When a stronger hold has one of those slots, the piece stands down and the line names the holder.
- **Tomahawk and Angon** — a typed `/ja "Tomahawk"` or `/ja "Angon"`, aimed with `<t>` or a numeric target id, equips Thr. Tomahawk or Angon for the ability while Hoxne is `OFF` or `ON-Allow Critical`, and the ability fires. Under Hoxne `ON-Locked` the ability is refused with its reason on every press:
  ```
  Hoxne ON-Locked holds ammo. Use ON-Allow Critical or OFF for Tomahawk.
  ```
- **Weapons stay in hand for a weaponskill**, because changing them would reset your TP — see [Weaponskills](#weaponskills).
- **A spell's ammo and your handbell or instrument** — when a spell's precast set names an ammo while a handbell or instrument is worn, the engine takes the handbell or instrument off for the precast, so the one your midcast names goes back on for the cast.
- **Two-handed detection** — checks whether your WeaponMode weapon is two-handed (`TwoHand` on the debug box); while it is, sub-slot swaps are suppressed.
- **Long casts hold their gear** — blue magic, avatar and spirit summons and Trust summons each get a busy window sized from their own cast time, so a buff landing mid-cast does not rebuild you into idle or engaged gear. A buff that lands in the seconds after your own cast finishes is dressed the moment it arrives.

### Status ailment responses

| Ailment | Response |
|---|---|
| **Sleep** | Equips idle plus `sets.Weapons.Sleep` and holds those slots; cancels Stoneskin so you can be woken |
| **Doom** | Equips and holds `sets.Cursna_Received`; uses a Holy Water if `AutoItem` is on, and says so if you have none |
| **Silence** (mage main or subjob) | Uses a Remedy if `AutoItem` is on |
| **Paralysis** | Uses a Remedy if `AutoItem` is on |
| **Petrification / Stun** | Re-evaluates and re-equips your correct set |

Sleep and Doom holds are released automatically when the status wears off. With `SpellReceived` on, the Doom set is dressed by the spell-received feature instead. Spectral Jig cancels an active Sneak before the ability fires, so the jig's own Sneak lands.

---

## 11. Action and spell tracking

### Treasure Hunter tracking

The engine keeps a register of the monsters you have already tagged. Entries are added when you act on a monster, removed when it dies, expired after three minutes without activity, and cleared entirely when you zone. A monster that respawns on the same spot is therefore tagged again and wears your Treasure Hunter set.

The phase the set is worn in follows what actually applies the tag. Weaponskills, ranged attacks and job abilities against an untagged monster pick it up at **precast**. Spells, Trusts, songs and ninjutsu do not tag, so their precast keeps your fast-cast gear and the set is merged at **midcast** instead, which is when the tag lands.

```
[Savage Blade] Set with Treasure Hunter
```

### Skillchain and magic burst tracking

The engine watches every skillchain that happens on your target — including ones made by other players. When one closes it records the elements and opens an eight-second window. A nuke cast into that window, at the same monster, whose element the chain opened, wears `sets.Midcast.Burst` instead of `sets.Midcast.Nuke`:

```
[Blizzard VI] Burst Detected!
```

Radiance and Umbra skillchains are recognized. A weaponskill that closes the window clears it.

### Spell-received tracking

For players running several characters at once. When one of your characters begins casting a supported spell, it tells your other characters on the same computer, through Windower. Any of them targeted by that spell equips its "received" gear immediately — as the cast starts, before the spell lands and ahead of Quick Magic.

**Supported spells:** Cure I–VI · Curaga I–V · Cura I–III · Cursna · Phalanx I–II · Protect I–V · Protectra I–V · Shell I–V · Shellra I–V · Regen I–V · Refresh I–III

**Supported abilities:** Curing Waltz I–V · Divine Waltz I–II

The engine also predicts which spells reach a whole party — the `-ga` and `-ra` spells, a spell spread by Accession or Majesty, and Cursna cast under Divine Seal — so every affected character dresses rather than only the direct target. Only characters in the caster's party dress for a spread, so an alliance member in another party is not dressed for a buff that cannot land on them.

Received gear sits below an item use, the two holds, the Hoxne hold, Sleep gear and the cast in progress, and it says which slot a higher hold kept from it:

```
Received gear: back is held by gs c disable right now.
```

A canceled cast releases the gear and slots it borrowed on your other characters at once. A failsafe timer releases any held gear if a completion message never arrives, so you cannot get stuck wearing cure-potency gear in a fight. The window is `delay` in the character's [settings file](#the-settings-file), three seconds by default.

---

## 12. Customization hooks

The engine builds a gear set, then calls your function and merges whatever you return. Define only the hooks you need — the engine names the missing ones in chat while `warn` is on.

Every gear hook returns a table: the gear to add, or `{}` when it has nothing to add. A value that is not a table is ignored, with a line saying so. A hook that stops on a Lua error ends that step's gear change, and GearSwap prints the error in chat.

### Required

```lua
function get_sets()
    -- all of your sets.* definitions go here
end
```

### Gear hooks

| Function | Called | Return |
|---|---|---|
| `choose_set_custom()` | Whenever gear is re-evaluated | Extra gear for your current state |
| `precast_custom(spell)` | Before an action | Extra precast gear |
| `midcast_custom(spell)` | During an action | Extra midcast gear |
| `aftercast_custom(spell)` | After an action | Extra aftercast gear |
| `pretarget_custom(spell, action)` | Before targeting | — (validation and retargeting) |
| `buff_change_custom(name, gain)` | A buff is gained or lost | Extra gear |
| `status_change_custom(new, old)` | Engaged, idle, resting, … | Extra gear |

Example:

```lua
function choose_set_custom()
    local built_set = {}
    if buffactive['Aftermath: Lv.3'] then
        built_set = set_combine(built_set, sets.OffenseMode.AM3)
    end
    return built_set
end
```

Gear that depends only on a buff, other than Aftermath, needs no hook at all: a [buff set](#buff-sets) is worn while its buff is up.

### Pet hooks

| Function | Called |
|---|---|
| `pet_change_custom(pet, gain)` | Pet summoned or dismissed |
| `pet_midcast_custom(spell)` | Pet action midcast |
| `pet_aftercast_custom(spell)` | Pet action complete |

### Other hooks

| Function | Called |
|---|---|
| `self_command_custom(command)` | Any `gs c` command the engine did not claim — add your own |
| `sub_job_change_custom(new, old)` | Subjob changed — `new` and `old` are the subjob names |
| `Cycle_Timer()` | Every 2 seconds, for periodic work |
| `user_file_unload()` | Job file unloading — clean up anything you created |

`self_command_custom` is also called by the WeaponMode, JobMode and JobMode2 commands *themselves*, before their gear rebuild rather than after, which is what lets a job file act on a mode change in the same swap.

`Cycle_Timer` is useful for time-of-day gear. Keep the period sets **beside** the set you rebuild, not nested inside it — `set_combine` keeps only equipment slots, so rebuilding a set from its own children deletes them on the first tick:

```lua
-- In get_sets():
sets.Movement_Base  = {}
sets.Movement_Day   = { feet = "Danzo Sune-Ate" }
sets.Movement_Night = { feet = "Hachi. Kyahan +1" }

function Cycle_Timer()
    if world.time >= 17*60 or world.time <= 7*60 then
        sets.Movement = set_combine(sets.Movement_Base, sets.Movement_Night)
    else
        sets.Movement = set_combine(sets.Movement_Base, sets.Movement_Day)
    end
end
```

### Helpers the engine supplies

`Job_Mode_Check(equipSet)` merges `sets.Weapons[<your current JobMode value>]` into the set it is given and returns it — for **any** mode name your file offers, `Standard` included. Declare a weapon set for each mode you want dressed, and leave the mode's set out to have it dress nothing.

A function of the same name defined in your job file loads after the include and replaces the engine's, so a file carrying its own copy keeps working exactly as it did. The same is true of every function or setting the engine defines: your job file loads last and wins.

### The startup call

`jobsetup(LockStylePallet, MacroBook, MacroSet)`, called once outside `get_sets()`, applies your lockstyle, macro book and keybinds — see [Startup](#startup).

---

## 13. Troubleshooting

### A set warning in chat

Two messages mean an action reached for gear and found none:

```
[sets.Midcast.Cure] not found!  Use gs c gearreporting to trace fallback pattern.  Silencing warnings for 60s.
[sets.Midcast.Regen] is empty!  Silencing warnings for 60s.
```

**"not found!"** means your job file never declared that set. If the action should have its own gear, add it in `get_sets()`. If it should not, nothing is wrong — a more general set dressed you instead, and the info line names which one.

**"is empty!"** means you declared the set but it holds no gear. This is the one that usually indicates a mistake, and the most common cause is building a set from a parent that is itself empty:

```lua
sets.Midcast.Enhancing = {}                                     -- nothing in here
sets.Midcast.Aquaveil = set_combine(sets.Midcast.Enhancing, {}) -- so nothing here either
```

Run **`gs c checksets`** to see every such set in one list — see [Diagnostics](#diagnostics).

**Each set warns at most once a minute**, and says so — see [Diagnostics](#diagnostics). The trace hint appears on the first warning after a load, not on every one, and `gs c checksets` clears the silences if you want everything reported again at once.

**To stop a warning for a set you deliberately leave bare, delete the declaration rather than emptying it.** The engine never asks for a set you have not declared, so `sets.JA["Light Arts"] = {}` is noisier than no line at all: deleting it moves the report up to `sets.JA`, which collapses many per-ability warnings into one. Put gear in `sets.JA` and it goes quiet entirely, while the info line still confirms what you wore. This works for ability and named-spell sets, which are yours to declare; the engine's own category sets — `sets.Midcast.Cure` and the like — always exist, so for those the answer is gear or `gs c warn off`.

A third message, `Chosen set is [Empty] - nothing to equip.`, means no set at all produced gear for your current state. It repeats at most once every 30 seconds.

`//gs c warn off` turns these off entirely.

### A weaponskill warning names main or sub

```
[Savage Blade] sets.Idle names main, sub; a weaponskill keeps the weapons in hand.  Silencing warnings for 60s.
```

A set in that weaponskill's gear names a weapon slot, and the weaponskill left your weapons as they were, because changing them would reset your TP. Nothing failed. Take main and sub, and range except on Bard and Geomancer, out of the set the line names. `sets.Idle` counts, because it sits under every weaponskill. See [Weaponskills](#weaponskills).

### A line about a buff set as your file loads

A second or two after your job file loads, the `warn` channel names any [buff set](#buff-sets) key it cannot use. Each is printed once per load.

| Line | What it means |
|---|---|
| `sets.OffenseMode.TP.Footwrk is not a buff name` | A key under a mode set or a buff set is neither a gear slot nor a buff. Fix the spelling to the buff's name as the game spells it, or remove the key |
| `sets.OffenseMode.Aftermath: Lv.3 is reserved to the Aftermath tiers -- AM3, AM2, AM1 and AM are read on the base set, never under a child` | Aftermath gear goes in the tier sets — `sets.OffenseMode.AM3` and the rest — not in a set named for the buff |
| `sets.Idle.xiroll: a second XIRoll key under one set` | Two spellings of `XIRoll` under one set. Only one is worn, so keep one |
| `sets.Midcast.SIRD.Impetus: SIRD carries no children` | `sets.Midcast.SIRD` takes no buff sets. Move it to `sets.Midcast` or a family under it |

A misspelled name in other places prints nothing — see [Buff sets](#buff-sets). If a buff set seems to do nothing, check its spelling, and watch the info line on your next spell or weaponskill: every buff set it wore is named there.

### Gear is not swapping

1. `//gs c debug` and watch the debug box.
2. If `is_Busy` is stuck on, an action never reported completion — it clears itself within a couple of seconds.
3. If `is_Moving` is stuck on, you may be on a mount or in an area where position updates are unreliable.
4. Read the hold map on the debug box, or the rig under the LATTICE style: if the slot carries a letter or a color, something is holding it.
5. `//gs c enableall` releases every slot the weapon lock is not holding and dresses you again.
6. Any action or mode change rebuilds your gear as well.

### A slot is stuck

Something is holding it, and [How the holds stack](#how-the-holds-stack) says what. Each hold ends with its own command's `off`, and `//gs c enableall` releases every hold but the weapon lock at once.

Under a Hoxne mode, `enableall` frees range and ammo only until the mode takes them back — see [Releasing a slot](#releasing-a-slot). The weapon lock is a mode, and `gs c weaponlock Unlocked` is what ends it.

If the Hoxne Ampulla is sitting in your ammo slot after a reload, wait a few seconds — the engine detects a stranded Ampulla shortly after loading and puts your normal gear back on its own. `//gs c hoxneinfo` shows what it is doing.

### The status box shows a hold I did not ask for

The `HLD` row names every hold standing. `DIS` is `gs c disable`, `NKD` / `WPO` / `PRC` are the three strip holds, and `CAP` / `DYN` / `JUB` are the carried-item locks. Each ends with its own command's `off`, or with `gs c enableall`.

### An item is not equipping

The engine can only equip items you own. Check the spelling exactly as the item appears in game, and confirm it is in inventory or a wardrobe — not in storage, a satchel or a sack.

If the item's name contains a command word — `gs c use hoxne ampulla` — the command still uses the item: the whole name after `use` is treated as the item's name.

### An enchanted item is not being used

`gs c use` names the reason it stopped, so read the chat line first — it will tell you whether the item is missing, unusable by your job, or on cooldown. If it printed `Equipping and using [...]` and then nothing happened, run `gs c enchinfo <item>` and check the `-> engine sees:` line described under [Diagnostics](#diagnostics).

A few things are worth knowing:

- **The first use after equipping always takes a few seconds.** Enchanted gear has to be worn for its equip delay before the game will accept a use, and the server wants a little more than the delay the wiki lists.
- **Timings restart every time the item is re-equipped**, so anything that swaps that slot mid-wait starts the clock again.
- **A song or Geomancy cast clears your ammo slot.** If you are running Hoxne `ON-Allow Critical`, that is why the Ampulla disappears during a song and returns afterward.

### A ranged attack is canceled with "No round named"

The built set for that action names no ammunition. The line says what was wrong with the ammo slot:

```
No round named for Last Stand: ammo is undeclared in the built set. Canceling.
```

`undeclared` means nothing set the slot, `blank` means it was set to an empty string, and `empty` means it was set to be cleared. Check that the `Ammo` key for your current OffenseMode is filled in, or that the action's own set names a round, as `sets.WS.RA` does for a ranged weaponskill — see [Ammunition](#ammunition) — and that no set in the chain clears the slot.

### A bard song or Geomancy spell fails with a command error

Check whether Hoxne is set to `ON-Locked`, and switch to `ON-Allow Critical`, which stands aside for exactly these cases — see [The Hoxne Ampulla hold](#the-hoxne-ampulla-hold). Bards should also check that the weapon lock is not on `Locked`, which holds main and sub through a song aimed at a monster; `Songs` is the value written for them.

### The display box is gone

`//gs c zero` moves it back to the top-left corner, and `//gs c displaypos` reports where both boxes are. If it is hidden rather than lost, `//gs c display on`.

### Settings are not saving

Settings live in each character's own file, `Windower4/addons/GearSwap/data/<CharacterName>/settings.xml` — see [The settings file](#the-settings-file). Read the line a save prints:

| Line | What it means |
|---|---|
| `Cannot save while zoning - try again in a moment.` | Wait until you are fully loaded, then `//gs c save` |
| `Settings not saved: logged out; they are reloaded at the next login.` | Nothing saves at the character select screen. Log in first |
| `Settings not saved: data/John/settings.xml failed to load; fix or delete it and reload.` | The file could not be read when the character loaded, so the character is running on defaults. With GearSwap unloaded, fix the file or delete it, then load GearSwap again |

Dragging a box saves silently, a second after you let go, so no chat message is normal. To confirm, check the `pos` values in the settings file, or reload GearSwap and see whether the box returns to where you dropped it.

If an edit you made by hand keeps disappearing, GearSwap was running when you made it: every save rewrites the whole file. Unload GearSwap first (`//lua unload gearswap`).

### The status box shows blank squares or the columns are ragged

The box uses square and triangle characters that exist in Consolas, Lucida Console and Courier New. If you have changed `font` in your settings file to a font lacking them, Windows substitutes a glyph from another font at a different width, which knocks the columns out of alignment. Switch back to a monospaced font that covers them.

### A startup message mentions a retired feature

Two notices can appear as your job file loads:

```
Auto Buff was removed: this job file still defines check_buff_JA or check_buff_SP and nothing calls them. They can be deleted.
Auto Tank and Runes were removed: this job file still names one, so the mode is still shown but now drives nothing.
```

Both are advisory, and neither stops anything working.

- **Auto Buff:** delete `check_buff_JA` and `check_buff_SP`, and any `Buff_Delay` or `Tank_Delay` variable that fed them. Self-buffing is a job for the automation tools most players already run.
- **Auto Tank and Runes:** `UI_Name` and `UI_Name2` are generic job-mode slots. Either clear the name, or point the slot at something your own file acts on — see [JobMode and JobMode2](#jobmode-and-jobmode2).

### Nothing loads at all

Confirm the `RahvinGS` folder is directly inside `GearSwap/data/`, and your job file is in your character's folder (`data/<CharacterName>/`) or in `data/`, named as [How GearSwap finds your job file](#how-gearswap-finds-your-job-file) lists. Then `//gs reload` and watch for errors in the Windower console. `Cannot find the include file` in an error means GearSwap did not find `RahvinGS` where the include lines expect it.

### The wrong job file loads

GearSwap loads the first file it finds, and it looks in the character's own folder before `data/`. Keep one file per job for each character. What decides it:

- **A file in the character's folder always wins** over a file in `data/`, whatever the names. A job file left over in the character's folder, even under another naming style such as `John_WAR.lua`, is the one that loads.
- **A `John.lua` in the character's folder loads for every job** that has no name-prefixed file there, such as `John-BLU.lua`, even when a plain `BLU.lua` sits beside it. **A `default.lua` there loads for every job with no other file there.** Either one means GearSwap never reaches `data/` for that character.
- **A job file in `data/` still works.** A file named for the job alone, such as `WAR.lua`, loads for any character whose own folder, and `data/common/` if you made one, hold no file GearSwap can use for that job.
- **Within one folder, the name order decides.** `data/John_WAR.lua` outranks `data/WAR.lua`.
- **The engine is found from anywhere.** The two include lines at the top of every job file find the shared `RahvinGS` folder from inside a character folder with no change. Keep a single copy of `RahvinGS` directly in `data/`: a copy placed inside a character's folder is the one that character would load instead.

#### How GearSwap finds your job file

When you log in or change job, GearSwap looks in these folders under `GearSwap/data/`, in this order, and stops at the first folder that holds any file it can use:

1. `data/<CharacterName>/` — the character's own folder
2. `data/common/` — for files every character shares, if you make one
3. `data/`

(Before these it checks GearSwap's own `libs-dev` and `libs` folders, and after them `%APPDATA%/Windower/GearSwap/` and Windower's `addons/libs/`. This suite uses none of those.)

Inside that folder it takes the first of these names that exists, shown here for a character named John on Blue Mage:

| Order | Name | Example |
|---|---|---|
| 1 | Name, underscore, short job | `John_BLU.lua` |
| 2 | Name, hyphen, short job | `John-BLU.lua` |
| 3 | Name, underscore, long job | `John_Blue Mage.lua` |
| 4 | Name, hyphen, long job | `John-Blue Mage.lua` |
| 5 | Name alone | `John.lua` |
| 6 | Short job | `BLU.lua` |
| 7 | Long job | `Blue Mage.lua` |
| 8 | Default | `default.lua` |

### An edit to the job file changes nothing

GearSwap reads your job file when it loads it, so an edit takes effect only once the file loads again. Save the file, then type `//gs reload`. If a Lua error appears instead, see the next entry.

### A Lua error names the job file and a line

A typo in the job file stops it loading, and GearSwap reports a Lua error naming the file and a line number; open the Windower console if nothing shows in chat. That line, or the one above it, usually holds the typo — most often a missing comma between two pieces of gear, or a missing closing brace `}`. Fix it, save, and type `//gs reload`.

---

# Performance

Rahvin GearSwap is measured, not asserted. A simulated Dynamis Divergence fight — six clients played the way a six-box party plays, inside an 18-player alliance against a full mob wave — runs three engines over identical timelines from a fixed seed, at each engine's own shipped defaults:

| Engine | What it is |
|---|---|
| **Mirdain-Include 1.5.12** | The original include as its author shipped it |
| **Selindrile** | Another author's suite, at a pinned upstream commit |
| **Rahvin GearSwap 2.0** | This engine |

The comparison covers CPU cost per client and across the party, the most expensive single frame against a 60 fps budget, allocation rate and resident memory, per-cast and per-event costs, the received-spell race, and chat volume in each of the diagnostic states you can select.

The current report measures 2.0 and is live at [Rahvin GS 2.0 Suite Comparison](https://rahvincode.github.io/Gearswap/). The 2.1 report is published after release.

---

# Credits

Original concept and engine by **Mirdain**. This enhanced revision conceived and programmed by **Rahvin**.

Contributions and issue reports welcome via the Silmaril or Vinland discords.  IYKYK.

# License

Released under the MIT License — see [LICENSE.md](LICENSE.md). Copyright © 2026 Rahvin; derived from Mirdain-Include, copyright © 2020 Mirdain, used with the author's permission.
