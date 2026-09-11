# Rahvin GearSwap
## Including the GearSets-Include gear library

**Version 2.0** · A GearSwap engine for Final Fantasy XI (Windower 4)

Rahvin GearSwap is a complete equipment engine for FFXI. You fill in gear sets for the jobs you play; it decides what to wear, and when, for every action you take — casting, weaponskills, job abilities, ranged attacks, pet actions, songs, item uses, moving, resting, sleeping and dying. It ships with a 4,903-entry gear library, sample files for all 22 jobs, and a set of automations built for players running several characters at once.

It began as a fork of Mirdain-Include, and Mirdain is credited for the original concept and scaffolding. Everything from 1.6.0 forward — engine and job files alike — is Rahvin's work, and the suite carries its own name and its own folder layout. The version numbering continues rather than restarting, so the first public release under the new name is **2.0**, following 1.7.3. Check the running version in game with `//gs c version`.

---

## Table of Contents

- [Key Features](#key-features)
- [Installation](#installation)
  - [Clean install](#clean-install)
  - [Coming from another GearSwap suite](#coming-from-another-gearswap-suite)
  - [Upgrading from Mirdain-Include](#upgrading-from-mirdain-include)
    - [What to change in your own job file](#what-to-change-in-your-own-job-file)
- [Quick Start](#quick-start)
- [The Manual](#the-manual)
  1. [How it works](#1-how-it-works)
  2. [The on-screen display](#2-the-on-screen-display)
  3. [Keybinds](#3-keybinds)
  4. [Modes](#4-modes)
  5. [Commands](#5-commands)
  6. [Holds and locks](#6-holds-and-locks)
  7. [Job file settings](#7-job-file-settings) — [Startup](#startup) · [Behavior](#behavior) · [Ammunition](#ammunition) · [Instruments](#instruments)
  8. [Gear sets reference](#8-gear-sets-reference)
  9. [The gear library](#9-the-gear-library)
  10. [Automatic engine checks](#10-automatic-engine-checks)
  11. [Action and spell tracking](#11-action-and-spell-tracking)
  12. [Customization hooks](#12-customization-hooks)
  13. [Troubleshooting](#13-troubleshooting)
- [Performance](#performance)
- [Credits](#credits)
- [License](#license)

---

# Key Features

A map of what the suite does; each line links to the section that explains it.

### Gear

- **A full swap pipeline for every action.** Precast, midcast and aftercast are built for spells, weaponskills, job abilities, ranged attacks, pet actions, songs, rolls and shots, steps, stratagems and item uses, and your own hook runs at each step. → [How it works](#1-how-it-works), [Customization hooks](#12-customization-hooks)
- **Layers instead of copies.** Idle, movement, resting, pet and Sublimation layers, a per-mode melee set, Aftermath tiers with an optional refinement per weapon mode, and a dual-wield layer all stack, so you declare what differs, not the whole set again. → [Gear sets reference](#8-gear-sets-reference)
- **Named switches you drive from a macro or a key.** Melee mode, weapon set, weapon lock, Treasure Hunter behavior, spell-received gear, the Hoxne Ampulla hold, ranged ammunition type, and two free-form slots any job defines. → [Modes](#4-modes), [Keybinds](#3-keybinds)
- **Situational gear is equipped for you** — the day, weather and distance pieces, the required equipment for a handful of named spells, two-handed detection, and a response to sleep, Doom, Silence and Paralysis. → [Automatic gear rules](#automatic-gear-rules), [Status ailment responses](#status-ailment-responses)
- **Actions that would fail are canceled before they cost you anything** — asleep, KO'd, charmed, not enough TP, still on cooldown, Amnesia — and ranged ammunition is counted across inventory and all eight wardrobes before a shot. → [Action validation](#action-validation), [Resource warnings](#resource-warnings)

### The gear library

- **4,903 pre-built item entries, referenced by key.** The full Artifact, Relic and Empyrean catalog for every job at every reforge tier, every Nolan augment path for the Escha and Geas Fete sets, the Trial of the Magians weapons, and the endgame gear the sample files use. → [The gear library](#9-the-gear-library)
- **Your max HP survives the swap chain.** Every entry carries a priority equal to its total HP, so high-HP pieces land first and your maximum never dips mid-swap; weapons share one rank instead, which leaves the offhand free when you change weapon sets. Three builders mint your own entries the same way. → [Why priorities matter](#why-priorities-matter), [Adding your own entries](#adding-your-own-entries)

### The on-screen display

- **Four styles and two views.** `gs c displaystyle` picks CLASSIC, HARNESS, LATTICE or HALO and the box opens in LATTICE; `gs c displaymode` switches between the stacked box and a one-line form, and each choice is saved under the character playing. → [Display styles](#display-styles), [The status box](#the-status-box)
- **LATTICE adds the rig** — a four-by-four grid of your sixteen gear slots beside the mode rows, each cell colored by whichever layer is holding that slot. → [Display styles](#display-styles)
- **A debug box** with the internal state that explains an unexpected swap, plus a legend rail and a sixteen-slot hold map. → [The debug box](#the-debug-box)

### Holds and locks

- **Holds that bare a slot, or freeze it.** `gs c naked`, `gs c weaponsonly` and `gs c abysseaproc` bare their slots and hold them; `gs c disable <slot>... | all` holds slots wearing exactly what they wear. One arbiter hands out every slot, so a refusal names the layer holding it. → [Strip holds](#strip-holds), [The disable hold](#the-disable-hold), [How the layers stack](#how-the-layers-stack)
- **Locks that keep something on.** The weapon lock on <kbd>F10</kbd> makes your weapon set the only writer of main and sub; the Hoxne Ampulla hold has two on states, one standing aside for songs, Geomancy, Tomahawk and Angon; `gs c capacity`, `gs c dynamisrp` and `gs c jubilee` wear the best copy you carry. → [The weapon lock](#the-weapon-lock), [The Hoxne Ampulla hold](#the-hoxne-ampulla-hold), [Carried-item locks](#carried-item-locks)
- **`gs c use <item>` drives any enchanted item**, drawn from the game's own item data rather than a hand-kept list: it picks the slot, waits out the equip delay, uses the item and gives the slot back, with the cooldown read live from the item itself. → [Enchanted items](#enchanted-items)

### Multibox and tracking

- **Spell-received gear, equipped before the spell lands.** When one of your characters casts a supported spell, the target equips its "received" set at pretarget — ahead of the cast completing, and ahead of Quick Magic — with area coverage predicted and a failsafe that releases borrowed gear. → [Spell-received tracking](#spell-received-tracking)
- **Treasure Hunter that knows what it has tagged.** Four modes and a register of the monsters you have already tagged, so `Tag` mode returns to full damage the moment the tag lands. → [TreasureHunter](#treasurehunter), [Treasure Hunter tracking](#treasure-hunter-tracking)
- **Every skillchain on your target is watched**, including ones other players make: when one closes, an eight-second window opens and a matching nuke wears `sets.Midcast.Burst`. → [Skillchain and magic burst tracking](#skillchain-and-magic-burst-tracking)
- **Reporting that tells you what you actually wore.** One line per action names the set — `[Cure IV] [sets.Midcast.Cure][Used]` — an empty set is named with the reason, each set warns at most once a minute, and `gs c checksets` audits a whole job file in two lines. → [Diagnostics](#diagnostics)

### Your job file

- **Twenty-two sample job files and the settings that drive them.** One file per job, ready to load and fill in with your own gear, plus the lockstyle and macro book, `AutoItem`, `Food`, `Ammo_Warning_Limit`, the ammunition tables a ranged job assigns, and the instrument keys covering all 25 Bard song families. → [Installation](#installation), [Job file settings](#7-job-file-settings), [Instruments](#instruments)
- **Built for six characters at once.** Six simultaneous clients in an 18-man alliance is the design target, and the engine is measured against it; the gear trace ships off and `info` and `warn` are one command each, so chat volume stays under your control. → [Performance](#performance)

---

# Installation

New to GearSwap? The clean install below is all you need — the two sections after it are for players arriving from another suite.

## Clean install

1. Install Windower 4 and enable the **GearSwap** addon.
2. Copy the whole `RahvinGS` folder into:
   ```
   Windower4/addons/GearSwap/data/
   ```
3. Copy the job files you want from `Sample Job Files/` into that same `data/` folder.
4. Rename each job file to match your character, or leave it as the job name to share across characters:
   - `WAR.lua` — used by any character on Warrior
   - `Yourname_WAR.lua` — used only by that character on Warrior
5. Log in and change to that job. GearSwap loads the file automatically, prints the keybind list, and equips you.
6. Type `//gs c version`. The engine answers `Include Version is [2.0]`.

## Coming from another GearSwap suite

If you have been running the Kinematics/Mote libraries, Selindrile's suite, or any other GearSwap package, clear it out before you copy anything in:

1. **Remove that suite's folders and files from `Windower4/addons/GearSwap/data/`** — its include files, its library folders, and its job files. GearSwap loads a job file by name, so a leftover `WAR.lua` from another suite is the file it loads for Warrior.
2. **Delete `Windower4/addons/GearSwap/data/settings.xml`**, with GearSwap unloaded (`//lua unload gearswap`). Rahvin GearSwap owns that file and rewrites it whole whenever it saves, so a file deleted while the addon is running comes back within seconds.
3. Follow the [clean install](#clean-install) above.

**Job files written for another suite are not compatible.** The set names, the mode objects and the hook names are this engine's own. Start from the file in `Sample Job Files/` for your job and move your gear into it; the sample is also a worked example of every convention in this document.

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
4. Reload GearSwap with `//lua r gearswap`, then type `//gs c version` and check the answer.

> **Running several characters? Upgrade them all in one sitting.** The messages your characters send each other for spell-received gear carry an internal tag tied to the suite name, and versions on either side of the rename ignore each other's messages — no error, just silence. Until every character is upgraded, spell-received gear stops arriving between mixed versions.

### What happens to `settings.xml`

Your existing `Windower4/addons/GearSwap/data/settings.xml` loads. Nothing has to be deleted.

The first time each character loads 2.0, the display settings return to their defaults — the style and the view, whether the status box is shown, and each box's font, size, colors and background — along with the HALO style's colors; the box positions you dragged are kept. One line per group says so:

```
Display settings reset to defaults (version 2); box positions kept
Halo settings reset to defaults (version 1)
```

That reset is what hands you the display defaults: the status box opens in LATTICE, in the stacked view. `//gs c displaystyle classic` selects the plain text box instead, and `//gs c displaymode` switches to one line — each choice saves under the character playing.

Your channel toggles (`debug`, `info`, `warn`, `gear_reporting`) and the multibox announce delay carry through untouched.

If you would rather start from a blank file, delete `settings.xml` — but **unload GearSwap first** (`//lua unload gearswap`). The engine rewrites the whole file whenever it saves, so a file deleted while GearSwap is running comes back within seconds.

### What to change in your own job file

The engine reports the first two of these in chat as your job file loads, so you do not have to hunt for them.

| What it says | What to do |
|---|---|
| `Auto Buff was removed: this job file still defines check_buff_JA or check_buff_SP and nothing calls them. They can be deleted.` | Delete both functions and any `Buff_Delay` or `Tank_Delay` variable that fed them. Self-buffing is a job for the automation tools most players already run. |
| `Auto Tank and Runes were removed: this job file still names one, so the mode is still shown but now drives nothing.` | `UI_Name` and `UI_Name2` are generic job-mode slots. Either clear the name, or point the slot at something your own file acts on — see [JobMode and JobMode2](#jobmode-and-jobmode2). |

**Weapons and the lock.** Locking your weapons is a mode of its own, `state.WeaponLock`, and <kbd>F10</kbd> cycles it.

- Remove `'Unlocked'` and `'Locked'` from `state.WeaponMode:options(...)`, and delete an empty `sets.Weapons.Unlocked` with them. A file that keeps either value still works — the value bridges onto the lock and the engine says so — but `gs c weaponlock` is where to set it.
- **Do not declare `state.WeaponLock:options(...)`.** The engine fixes that list per job: `Unlocked` and `Locked` everywhere, `Songs` on Bard, `Locked+R` on Corsair. A file that wants to boot locked calls `state.WeaponLock:set('Locked')` and nothing else.

**Commands and keys.**

- **`gs c cp` is spelled `gs c trizek`.** It equips and uses the Trizek Ring exactly as before. Update any macro or keybind carrying the old word.
- **<kbd>F10</kbd> cycles the weapon lock.** The capacity point cape lock stays reachable as `gs c capacity`, `gs c aptitude` or `gs c mecisto`. The full key list is under [Keybinds](#3-keybinds); every key has an equivalent command, so bind your own if you prefer.
- **`SpellReceived` takes `OFF` or `ON`.** A macro passing `ON-Locked` or `ON-Unlocked` is rejected with a suggestion — update it to `ON`.
- **A `//gs c jobmode <value>` macro works only for values your own file declares.** The engine's default options for both job-mode slots are `OFF` and `ON`; a job file widens them with `state.JobMode:options(...)`. The shipped PLD and RUN templates leave both slots unnamed.

**Gear library keys.** Eleven Dynamis Divergence +2 necks are keyed `gear.<name>PlusTwo` — `gear.warriorsBeadPlusTwo` is War. Beads +2 — and the tier-less key names the base piece. If your own file references one of the eleven, point it at the tier you mean. `PATCH NOTES.md` lists them all.

**Set paths worth a search.** Gear declared at a path the engine does not read sits there doing nothing.

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

Ranged weaponskill and ranged midcast keys read `RA` first. Under `sets.Midcast.Enfeebling` the engine reads `.MACC`, `.Potency` and `.Duration` and nothing else. Under `sets.Precast.RA` it reads the two Flurry children and nothing else. And a pet command — Fight, Heel, Spur, Deploy and the rest — has no set of its own: your pet's own actions are dressed by the `sets.Pet_Midcast` family.

**Two gaps that are easy to miss.**

- **Every mode you offer needs a set.** A mode named in `state.OffenseMode:options(...)` with no matching `sets.OffenseMode.<mode>` costs you the rest of the engaged build; `sets.OffenseMode.PDL = set_combine(sets.OffenseMode, {})` is enough to close it — see [Core sets](#core-sets).
- **Every ranged action's built set must name an `ammo`.** A set that leaves the slot undeclared, blank or cleared cancels the shot rather than firing it on whatever round happens to be loaded — see [Troubleshooting: no round named](#a-ranged-attack-is-canceled-with-no-round-named).

**The sample files.** All 22 ship refreshed. Copying the one for your job brings its gear and behavior corrections into your own file; keeping your own copy is equally fine, because a definition in your job file loads after the include and replaces the engine's. Per-release detail is in [PATCH NOTES.md](PATCH%20NOTES.md).

After the upgrade, run **`//gs c checksets`**. It names every set you declared and left empty, which is the fastest way to find something the move disturbed.

---

# Quick Start

You have installed the suite and copied `WAR.lua` into `data/`. Here is the first ten minutes.

**1. Open your job file and fill in three sets.** Everything else can wait.

```lua
function get_sets()
    sets.Idle       = { head = gear.nyameHead, body = gear.sakpataBody }
    sets.OffenseMode = { head = gear.nyameHead, body = gear.sakpataBody }
    sets.WS         = { head = gear.nyameHead, body = gear.sakpataBody }
end
```

`sets.Idle` is what you stand in, `sets.OffenseMode` what you fight in, `sets.WS` what you weaponskill in. Use `gear.<key>` from [the gear library](#9-the-gear-library) or plain item names in quotes — both work.

**2. Change job in game.** The engine prints its keybinds, applies your lockstyle and macro book, and dresses you.

**3. Read the box in the corner.** It opens in the LATTICE style, stacked: a bordered panel with a header strip, and the rig — a four-by-four grid of your sixteen gear slots — at the right of the mode rows. The top row is your job and three indicators — spell-received gear, Treasure Hunter, Hoxne — each a colored square. Below it is one row per mode: `STN` your melee mode, `DPS` your weapon set, `LCK` the weapon lock. → [The status box](#the-status-box)

**4. Three keys and three commands for day one.**

| | |
|---|---|
| <kbd>F12</kbd> | Cycle your melee mode — `TP`, `ACC`, `DT` |
| <kbd>F9</kbd> | Cycle your weapon set |
| <kbd>F11</kbd> | Cycle Treasure Hunter |
| `//gs c checksets` | Count the sets carrying gear and the ones you left undeclared, and name every declared set that is empty |
| `//gs c info` | Turn the running commentary on or off — one line per action naming the set it wore |
| `//gs c update auto` | Force a rebuild when a set looks wrong |

**5. Where to read next.** [Gear sets reference](#8-gear-sets-reference) is the list of every set name the engine reads. [Modes](#4-modes) is how the switches work. [Troubleshooting](#13-troubleshooting) is what a warning in chat means.

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

Two details are worth knowing early. `sets.Idle` is merged underneath every midcast as a floor, so a cast that matches no branch still comes out dressed rather than in whatever precast left on. And a few action types are final at precast — their precast gear is what the action lands in, and no midcast runs.

Separately, a background loop runs about ten times a second to handle what is not tied to an action — movement gear, weapon checks, housekeeping. See [Automatic engine checks](#10-automatic-engine-checks).

---

## 2. The on-screen display

The suite draws two boxes: a **status box**, always available, and a **debug box**, hidden unless `gs c debug` is on.

### Display styles

Four renderers draw the status box, and it opens in LATTICE. `//gs c displaystyle` with no argument cycles them; a name selects one. The choice is saved under the character playing, so each of your characters can use a different one.

| Style | What it draws |
|---|---|
| `classic` | The plain text box: a crown row of three colored squares, one label and `◄ value ►` row per mode, and the hold row |
| `harness` | Every mode in a cell of its own, sized from that mode's own option list, packed two cells to a row, with no chevrons |
| `lattice` | CLASSIC's composition drawn on a panel with a header strip and a fitted border — plus the rig |
| `halo` | No background at all: four text planes at one position — crown, labels, values and holds — each with its own weight, stroke and hue, and a cap on how wide one value may run |

Each style in both views, stacked first and then one line:

**`lattice`** — the default

![The LATTICE style, stacked, with the rig](Rahvin%20GS%202.0%20Images/Lattice%20Stacked.png)

![The LATTICE style in one line](Rahvin%20GS%202.0%20Images/Lattice%20Oneline.png)

**`classic`**

![The CLASSIC style, stacked](Rahvin%20GS%202.0%20Images/Classic%20Stacked.png)

![The CLASSIC style in one line](Rahvin%20GS%202.0%20Images/Classic%20Oneline.png)

**`harness`**

![The HARNESS style, stacked](Rahvin%20GS%202.0%20Images/Harness%20Stacked.png)

![The HARNESS style in one line](Rahvin%20GS%202.0%20Images/Harness%20Oneline.png)

**`halo`**

![The HALO style, stacked](Rahvin%20GS%202.0%20Images/Halo%20Stacked.png)

![The HALO style in one line](Rahvin%20GS%202.0%20Images/Halo%20Oneline.png)

```
//gs c displaystyle              -- cycle
//gs c displaystyle lattice      -- pick one
```

A name that is not on offer is refused with the list:

```
Display Style: "neon" is not a style.
Usage: //gs c displaystyle [classic|harness|lattice|halo]
```

**The rig** is LATTICE's addition, in the stacked view: a four-by-four grid of your sixteen gear slots, laid out in the game's own equipment-window order, in text columns reserved at the right of every mode row. Each cell is colored by whichever layer is holding that slot — a strip hold in orange, the disable hold in cyan, a lock mode or the weapon lock in violet, the Hoxne hold in green, an item use in pale yellow — and a slot nothing holds draws as a dim socket. Turn it off with `settings.Lattice.rig.enabled = false`.

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

**The crown** is three indicators whose *color* carries the state, so the row never reflows: `SR` (SpellReceived), `TH` (TreasureHunter) and `HOX` (Hoxne). The crown opens with your job in every view but CLASSIC's stacked one.

| Indicator | Meaning |
|---|---|
| Green square | Mode is fully on — `ON`, `Full Time`, `ON-Locked` |
| Amber square | Partially on — TH `Tag`, or Hoxne `ON-Allow Critical` |
| Cyan square | THF-only TH `SATA` |
| Gray square | Mode is off (`None` / `OFF`) |

**The mode rows** show full text, so the weapon or job function currently selected is always readable: `STN` OffenseMode, `DPS` WeaponMode, `LCK` WeaponLock, then JobMode and JobMode2 when your file names them. The `LCK` value turns violet while the lock is actually holding main and sub.

**The hold row** appears only while something is holding a slot: an `HLD` anchor, then a three-letter token per hold, in precedence order.

| Token | Hold |
|---|---|
| `DIS` | The disable hold — one token however many slots it holds |
| `NKD` `WPO` `PRC` | A strip hold: `gs c naked`, `gs c weaponsonly`, `gs c abysseaproc` |
| `CAP` `DYN` `JUB` | The capacity point cape, Dynamis neck and Jubilee Ring locks |

**Sizing.** Column widths come from each mode's complete list of options rather than its current value, so cycling a mode never resizes the stacked box — it stays a fixed width for as long as a job is loaded. The one-line view deliberately flexes with the current values to stay as short as possible. Set `Display_MinValueCells` in `settings.xml` to put a floor of your own under the value column.

### The debug box

`//gs c debug` shows it, and opens the verbose log channel with it.

![The debug box: six engine flags, the legend rail and the hold map](Rahvin%20GS%202.0%20Images/Debug%20Box.png)

| Field | Meaning |
|---|---|
| `is_Busy` | Engine is mid-action and will not overwrite gear |
| `is_Moving` | You are moving |
| `DualWield` | Dual Wield trait detected |
| `TwoHand` | Your current main weapon is two-handed |
| `Casting` | An outgoing tracked cast is in progress |
| `Failsafe` | Spell-received gear is waiting on a timeout |

Below those are two lines the other boxes do not carry: a **legend rail** of the nine layers, lit where that layer is holding something, and a **hold map** of the sixteen slots in equipment-window order, each cell carrying its holder's letter.

| Letter | Layer |
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

Drag either box with the left mouse button while it is visible. Releasing the drag writes the new position to disk, silently — there is no chat confirmation.

You can also save manually with `//gs c save`, put a lost box back in the top-left corner with `//gs c zero`, hide the status box with `//gs c display`, and switch between one-line and stacked with `//gs c displaymode`.

Settings live in `Windower4/addons/GearSwap/data/settings.xml`, under a node named for your character.

> Saving is skipped while you are zoning, because the file cannot be written when no character is resolvable. `//gs c save` says so outright — `Cannot save while zoning - try again in a moment.` — and a drag released mid-zone is lost. Drop the box again once you have finished loading.

---

## 3. Keybinds

Bound automatically when your job file loads, and released when it unloads.

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

The engine lists these in chat as your job file loads:

```
Stance - [F12]
TH Mode - [F11]
Weapon Lock - [F10]
Weapon Mode - [F9]
Hoxne Ampulla Mode - [Ctrl + F10]
Spell Received Gear Mode (Multibox Only) - [Ctrl + F9]
```

The two job-mode keys are announced only when your file names the slot with `UI_Name` or `UI_Name2`.

Every keybind is a self command, so each key has a typeable equivalent and you can bind your own keys or build macros instead.

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
- **Command:** `//gs c OffenseMode PDL` · **Key:** <kbd>F12</kbd>

Every option you list needs a matching `sets.OffenseMode.<Name>`, or the engine warns you and skips the rest of the engaged build — see [Core sets](#core-sets).

### WeaponMode

Which weapon set to equip, without touching your gear sets.

- **Options are entirely yours:**
  ```lua
  state.WeaponMode:options('Chango','Shining One','Naegling','Mpaca')
  state.WeaponMode:set('Chango')
  ```
- **Command:** `//gs c WeaponMode "Shining One"` · **Key:** <kbd>F9</kbd>
- Each option needs a matching `sets.Weapons.<Name>`.
- Changing the mode also re-runs the two-handed check, and calls your `self_command_custom` before the rebuild.
- The values `Locked` and `Unlocked` name no set of their own. A file that still offers either has it bridged onto the weapon lock, and the engine says so: `Weapon Lock: [Locked] (from weapon mode Locked)`.

### WeaponLock

Whether anything but the weapon mode may write main and sub. The mode says what the weapons *are*; the lock says whether they stay.

| Value | Behavior |
|---|---|
| `Unlocked` | Every phase behaves as it would otherwise |
| `Locked` | `sets.Weapons[<mode>]` is the sole writer of main and sub in every phase |
| `Songs` | Bard only — `Locked`, except for a song aimed at yourself, another player or a Trust |
| `Locked+R` | Corsair only — holds range with main and sub |

- **Command:** `//gs c weaponlock Locked` · **Key:** <kbd>F10</kbd>
- **The engine fixes this list per job and a job file never redeclares it** — a job file's own `:options()` call wipes it. To boot locked, call `state.WeaponLock:set('Locked')` and nothing else.
- `Locked+R` is refused while a Hoxne mode is on, because the Ampulla owns range above the lock: `Weapon Lock: [Locked+R] refused; Hoxne Ampulla holds range.` Passed as an argument, the lock stays where it was; on a cycle the value is passed over.

### TreasureHunter

The engine remembers which monsters you have already tagged, so it only wears TH gear when it will do something.

| Mode | Behavior |
|---|---|
| `None` | Never equip TH gear |
| `Tag` | Equip TH gear for the action that tags the monster, then return to full damage |
| `Full Time` | Keep TH gear on while engaged, tagged or not |
| `SATA` | THF only — like `Full Time`, but only while Sneak Attack, Trick Attack or Feint is up |

In every mode but `None`, an **untagged** monster gets the set: that is the swing that applies the tag. The modes differ in what happens afterwards.

Defaults to `Full Time` on THF and `None` on every other job. Tagged monsters are forgotten after three minutes of inactivity, and cleared entirely when you zone.

- **Command:** `//gs c TreasureHunter "Full Time"` · **Key:** <kbd>F11</kbd>

### SpellReceived

For players running more than one character. When another of your characters casts a supported spell on you, this character equips its "received" gear *before the spell lands* — even through Quick Magic.

| Mode | Behavior |
|---|---|
| `ON` | Equip received gear and hold those slots until the spell resolves |
| `OFF` | Disabled |

Defaults to `ON`. Every switch, in either direction, releases everything the feature is holding.

- **Command:** `//gs c SpellReceived ON` · **Key:** <kbd>Ctrl</kbd>+<kbd>F9</kbd>

Requires the corresponding `*_Received` sets. See [Spell-received tracking](#spell-received-tracking).

### Hoxne

Keeps Hoxne Ampulla in your ammo slot and uses it for you.

- **Options:** `OFF` `ON-Allow Critical` `ON-Locked`
- **Command:** `//gs c hoxne`, or `//gs c hoxne ON-Locked` · **Key:** <kbd>Ctrl</kbd>+<kbd>F10</kbd>

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
- **Keys:** <kbd>Ctrl</kbd>+<kbd>F12</kbd> and <kbd>Ctrl</kbd>+<kbd>F11</kbd>
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

All commands are typed as `//gs c <command>` and are **case-insensitive**.

A command resolves by its whole name, or by its first word where that word takes an argument — never by a substring, which is what lets `gs c use hoxne ampulla` reach the item rather than the Hoxne mode.

### Argument validation

**With no argument, every mode command cycles forward one step** — `//gs c TreasureHunter` steps `None` to `Tag` to `Full Time` and wraps. A stray trailing space still counts as no argument.

**With an argument**, the value must be one of that mode's options, matched without regard to case. Anything else changes nothing and reports why:

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
| `gs c WeaponLock [Unlocked\|Locked\|Songs\|Locked+R]` | Cycle, or set the weapon lock |
| `gs c TreasureHunter [mode]` | Cycle, or jump to a TH mode |
| `gs c SpellReceived [ON\|OFF]` | Cycle, or set spell-received tracking |
| `gs c Hoxne [OFF\|ON-Allow Critical\|ON-Locked]` | Cycle, or set the Hoxne Ampulla hold |
| `gs c JobMode [mode]` | Cycle, or jump to a job-specific mode |
| `gs c JobMode2 [mode]` | Cycle, or jump to a second job-specific mode |

### Display commands

| Command | Description |
|---|---|
| `gs c display` | Show or hide the status box — `The UI is now shown` / `hidden` |
| `gs c displaymode` | Toggle one-line versus stacked — `One line display is: [ON]` |
| `gs c displaystyle [classic\|harness\|lattice\|halo]` | Cycle, or pick a renderer; saves |
| `gs c zero` | Put both boxes back in the top-left corner and save |
| `gs c save` | Write settings to disk now — `Settings saved` |

### Gear commands

| Command | Description |
|---|---|
| `gs c update auto` | Re-evaluate and equip the correct set for your current state |
| `gs c two_hand_check` | Re-read whether your main weapon is two-handed |

The engine keeps your gear current on its own — every action ends with the right set re-equipped, and it re-checks whenever your state changes. `gs c update auto` is for the times a set looks wrong and you want to force a rebuild. If nothing at all produced gear it says so, at most once every 30 seconds:

```
Chosen set is [Empty] - nothing to equip. gs c checksets lists your sets.
```

### Holds and slot commands

| Command | Description |
|---|---|
| `gs c naked [on\|off]` | Bare all sixteen slots and hold them |
| `gs c weaponsonly [on\|off]` | Bare and hold the twelve armor slots, keeping weapons dressed |
| `gs c abysseaproc [on\|off]` | Bare and hold head, hands, legs and feet |
| `gs c nakedunlocked` | Bare every slot for an instant, with no hold |
| `gs c disable <slot>... \| all` | Hold the named slots wearing exactly what they wear |
| `gs c enable <slot>... \| all` | Release the named slots |
| `gs c enableall` | Release every slot, unconditionally |
| `gs c enablebymode` | Release only what no layer is still claiming |

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

**The slot is held for the whole use.** A combat rebuild, a buff wearing off or a weapon-mode change leaves the item where it is until the use finishes. Zoning cancels the use and gives the slot straight back.

**Changing your mind.** `gs c cancel` stops a use that is under way, hands the slot back and re-equips your normal gear. You rarely need it, because any new `gs c use` or shortcut takes over from the one already running:

```
//gs c warp
//gs c trizek
```

The Warp Ring is dropped and the Trizek Ring takes its place. Two things are worth knowing:

- **Re-typing the same command changes nothing** — the running use keeps its place and the engine answers `Warp Ring is already in progress.`
- **Once the item has been used it cannot be called back** — `Warp Ring: already sent and cannot be recalled; move to interrupt it.` Canceling afterwards still frees your slot and restores your gear; to stop the effect, move to interrupt it, as you would a spell.

### Job abilities

| Command | Description |
|---|---|
| `gs c tomahawk` | Equip Thr. Tomahawk, then use Tomahawk on your target (WAR) |
| `gs c angon` | Equip Angon, then use Angon on your target (DRG) |

A typed `/ja "Tomahawk"` or `/ja "Angon"` works on its own while Hoxne is `OFF` or `ON-Allow Critical` — the engine equips the throwing item for it, with `<t>` or a numeric target id, and the ability fires. The commands above are the macro-friendly form: every reason the ability could fail is answered *before* any gear moves, so a command on cooldown costs you nothing.

```
Tomahawk is not available (wrong job or level).
Tomahawk is on cooldown [0:43].
```

Under Hoxne `ON-Locked` the ability is refused with its reason on every press, whichever form you use:

```
Hoxne ON-Locked holds ammo. Use ON-Allow Critical or OFF for Tomahawk.
```

The item search covers every equippable bag and every stack in it, and prefers a copy you are already wearing.

### Utility

| Command | Description |
|---|---|
| `gs c version` | Print the running engine version — `Include Version is [2.0]` |
| `gs c profile <path>` | Run a Windower script named for your job, subjob and character |
| `gs c shutdown` | Terminate the game client |

`gs c profile` splits what you type into runs of letters and digits and joins everything after the first word with underscores, then executes `<that>/<main>_<sub>_<character>`. So `//gs c profile raid` runs `raid/WAR_SAM_Yourname`, and a separator does not survive the split — `//gs c profile scripts/raid` runs `scripts_raid/WAR_SAM_Yourname`, so name a single directory.

### Diagnostics

These answer questions about what the engine is doing. All are safe to run at any time and none of them change your gear.

| Command | Description |
|---|---|
| `gs c checksets` | Audit your job file: how many sets carry gear, how many you never declared, and which declared sets are empty. Also clears warning silences |
| `gs c gearreporting` | Toggle a running trace of precast, midcast and aftercast, and what each fell back through |
| `gs c enchinfo <item>` | Print an enchanted item's live charges, equip delay and cooldown |
| `gs c capinfo` | List every capacity point cape you carry, what each is worth, which the mode picks, and what is worn |
| `gs c hoxneinfo` | Print what the Hoxne subsystem sees: mode, slots, buff, cooldown, retries |
| `gs c warn` | Toggle warnings about sets that hold no gear |
| `gs c info` | Toggle informational messages, including the set each action wears |
| `gs c debug` | Toggle the debug box and verbose engine logging |

**Every action names the set it used.** On the info channel you get one line per action, whatever the action is — spells, job abilities, weaponskills, stratagems, Corsair rolls and shots, Dancer steps, Waltzes, item uses, bard songs, pet actions and gear equipped for an incoming spell:

```
[Cure IV] [sets.Midcast.Cure][Used]
[Curaga II] [sets.Midcast.Curaga][Not Usable] -> [sets.Midcast][Used]
[Flame Breath] [sets.Pet_Midcast.Flame Breath][Used]
```

An Aftermath layer is named in its own clause, with the set your branch chose staying at the head of the line:

```
[Savage Blade] [sets.WS.Savage Blade][Used] + [sets.WS.AM3][Used]
```

**`gs c checksets`** is the one to run after writing a job file. It separates a set you never declared from one you declared and left empty — the second is almost always a set you meant to fill in:

```
//gs c checksets
Sets with gear: 63.  Engine placeholders left undeclared: 88.
Declared [Empty] sets: sets.Midcast.Enhancing, sets.Precast.Enhancing
```

With nothing to report it answers `Declared [Empty] sets: none.` Running it also clears any warning silences, so the next use of each set reports again.

**The channels answer different questions.** Leave `info` on for a running commentary, `warn` on to hear only about problems, and turn `gearreporting` on when you want to see why:

```
info   [Cure IV] [sets.Midcast.Cure][Used]
info   [Curaga II] [sets.Midcast.Curaga][Not Usable] -> [sets.Midcast][Used]
warn   [sets.Midcast.Curaga] is empty!  Silencing warnings for 60s.
```

Confirmations and diagnostics ride a channel of their own, which none of these silence. Mode and setting confirmations, the hold announcements, the startup keybind list, `gs c version` and every diagnostic reply print whatever `info`, `warn`, `gearreporting` and `debug` are set to — so a toggle can confirm itself, and a diagnostic you typed always answers. Gear and action reporting stays on `info`, which is the channel to turn down in a long fight; a mistyped mode argument is answered on `warn`.

None of the three channel toggles writes to disk, so a change lasts until the next reload unless `gs c save` follows it.

**`gs c gearreporting`** answers "why that set?" It traces all three phases of a swap, and the whole fallback path when a set it reached for was bare:

```
Precast: Using sets.Precast.Cure [Filled]
Attempted to use sets.Midcast.Regen [Empty] falling back -> Using sets.Midcast [Filled]
Aftercast: Using sets.OffenseMode.DT [Filled]
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

The second line is the one that matters: a **cooldown** means the item cannot be used yet and the command is refused, whereas an **equip delay** just means it needs to stay worn a few seconds longer, which the engine waits out on its own.

**`gs c capinfo`** lists every capacity point cape you carry, what each is worth, which one the mode picks and what is actually worn:

```
//gs c capinfo
capinfo: 2 carried; mode [ON] holding back.
  Aptitude Mantle +1  +30%        -   <- chosen
  Aptitude Mantle     +25%        -
  back holds Aptitude Mantle +1 -- matches.
```

The highest value wins, and a Mecisto whose augment reads higher than either native takes it. Where a Mecisto is chosen, the last line says that the *name* matches and that which copy is worn cannot be read — two copies of one cape name are indistinguishable in your equipment, which is the case this command exists for.

### Engine-internal

You never need to type these. Equipment changes have to happen inside a normal GearSwap event, so the parts of the engine that run outside one — its background ticks — send themselves a command instead. They are listed here only so you recognize them in a verbose log.

| Command | Issued by |
|---|---|
| `gs c enchrepair` | The enchanted item engine, when an item it is using is knocked out of its slot |
| `gs c hoxnerelock` | The Hoxne tick, re-asserting its hold on range and ammo |
| `gs c hoxnerelease` | The Hoxne tick, freeing a stranded Ampulla after a reload |

---

## 6. Holds and locks

Several features take a gear slot and keep it. They all go through one arbiter, so exactly one layer owns a slot at a time and a refusal always names the holder.

### How the layers stack

Highest first. A layer may take a slot from anything below it; asking for one held from above is refused, and the refusal says who has it.

| | Layer | Named in chat as |
|---|---|---|
| 1 | An enchanted item use | `an item use` |
| 2 | The disable hold | `gs c disable` |
| 3 | A strip hold — `gs c naked`, `gs c weaponsonly`, `gs c abysseaproc` | `a strip hold` |
| 4 | The Hoxne Ampulla hold | `the Hoxne hold` |
| 5 | Sleep gear | `Sleep gear` |
| 6 | The cast in progress | `the cast in progress` |
| 7 | Received gear | `received gear` |
| 8 | The weapon lock | `the weapon lock` |
| 9 | The carried-item locks | — they never refuse; they wait |

A refusal reads one line per holder, slots ranked down the body:

```
Aptitude Mantle +1: back is held by an item use right now.
Received gear: head, body are held by a strip hold right now.
```

A refusal that answers a command you just typed prints on the unsilenceable channel. One raised while the engine was building gear on its own rides `gs c info`.

### Strip holds

Three commands bare a set of slots and *hold* them bare. Nothing below an item use dresses a held slot while one stands.

| Command | Slots |
|---|---|
| `gs c naked` | All sixteen |
| `gs c weaponsonly` | The twelve armor slots — main, sub, range and ammo stay dressed |
| `gs c abysseaproc` | Head, hands, legs and feet |

Each takes the same grammar. Bare flips the hold; `on` takes it, or re-takes it as the manual repair when something grabbed a slot behind the engine's back; `off` releases it, or answers `Naked: already [OFF]`. Anything else is refused:

```
Naked: "yes" is not on or off.
Usage: //gs c naked [on|off]
```

**One hold stands at a time.** Typing a second word while the first stands switches shape — going from `naked` to `weaponsonly` hands the four weapon slots back and keeps the twelve.

`gs c nakedunlocked` is the momentary form: it bares every slot it can and holds nothing, so the next action or poll dresses you again. Every layer that was already holding a slot keeps it.

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

Accepted slot words are the canonical sixteen plus the spellings people actually type: `main sub range ranged ammo head body hands legs feet neck waist back ear1 ear2 lear rear learring rearring left_ear right_ear ring1 ring2 lring rring left_ring right_ring`, plus `all`.

GearSwap's own `//gs disable` and `//gs enable` are not tracked by this engine. Using one with a slot name gets a single line pointing at the tracked form:

```
Disable: //gs disable leaves the slot untracked -- use //gs c disable <slot>... instead.
```

(A bare `//gs disable`, which switches your whole job file off, is left alone.)

### The weapon lock

`gs c weaponlock` is a [mode](#weaponlock) rather than a momentary hold, and <kbd>F10</kbd> cycles it. Under `Locked`, `sets.Weapons[<your weapon mode>]` is the only thing that writes main and sub, in every phase — precast, midcast and aftercast alike. The pair starts as whatever you are wearing, so a slot the mode names nothing for is held as found.

Bard's `Songs` value stands aside for a song aimed at yourself, another player or a Trust; a song aimed at a monster stays locked, and so does everything else. Corsair's `Locked+R` holds range as well, and stands down to `Locked` if a Hoxne mode takes range:

```
Weapon Lock: [Locked] (Hoxne Ampulla holds range)
```

`gs c enableall` does **not** turn the lock off — the lock is a mode, and `gs c weaponlock` is what ends it. Its sub slot, which it registers but never shuts, is freed with the rest.

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

The slot is released as the action starts and reclaimed afterwards — within a second for the two job abilities, and five seconds after the last cast for songs and Geomancy, so a full song rotation or a Geo/Indi pair is treated as one continuous window rather than fighting you between casts. An interrupted song holds its instrument for those same five seconds, so a re-sing inside them shows no flicker.

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

These **wear** an item and keep it there. Nothing your job file equips takes that slot back while the mode is on. Each is `[on|off]`: bare flips, `on` sets it on, `off` sets it off, and each transition is announced.

```
//gs c capacity          -- flip it
//gs c jubilee on        -- set it on
//gs c dynamisrp off     -- set it off
```

| Mode | What it wears |
|---|---|
| `gs c capacity` · `gs c aptitude` · `gs c mecisto` | The best capacity point cape you carry: Aptitude Mantle +1 (+30%), Aptitude Mantle (+25%), or a Mecisto. Mantle whose own augment is read per copy. Three words, one mode |
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

Because their item is chosen rather than fixed, setting one on while it is already on **chooses afresh** — a cape whose augment reads higher, or a neck rank you have acquired since. `gs c jubilee on` while on re-asserts the same ring instead, which makes the bare command double as the repair when something took the slot behind the engine's back.

**They sit at the bottom of the pecking order.** They never take a slot from another layer: a slot something above is holding is refused and named, and the mode waits. They also let go on their own when they must — if the item leaves your bags, or a level sync drops it below what you can wear, the mode switches itself off instead of holding an empty slot shut. And because `/equipset`, a server-forced unequip and `//gs enable` fire no event the engine can hear, the held slot is compared against what you are actually wearing as gear is chosen, so a slot taken from behind the engine's back is reclaimed.

Entering a Dynamis Divergence zone prints a reminder:

```
Entering Dynamis Divergence - Use "gs c dynamisrp" to equip and lock your JSE neck.
```

Zoning releases every lock mode — `Lock modes released (zoned).` — and so does unloading your job file.

### Releasing a slot

| Command | What it does |
|---|---|
| `gs c enableall` | The manual override. Clears the disable hold, then the strip hold, then the lock modes, and frees every slot the weapon lock is not holding |
| `gs c enablebymode` | The routine release. Offers all sixteen slots and frees only the ones no layer is still claiming |

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

Apply them by calling `jobsetup(LockStylePallet, MacroBook, MacroSet)` once, outside `get_sets()`. That call also binds the mode keys and prints the key list.

### Behavior

| Variable | Type | Default | Description |
|---|---|---|---|
| `AutoItem` | boolean | `false` | Use a Remedy and a Holy Water automatically for status ailments |
| `Food` | string | — | Item used by `//gs c food` — `"Sublime Sushi"` |
| `Ammo_Warning_Limit` | number | `99` | Warn on precast when ranged ammunition falls below this count |
| `UI_Name` | string | `''` | Name used for JobMode in chat and on the box; empty hides the mode |
| `UI_Name2` | string | `''` | Name used for JobMode2; empty hides the mode |
| `UI_Short` | string | `''` | Optional status box label for JobMode; derived from `UI_Name` when empty |
| `UI_Short2` | string | `''` | Optional status box label for JobMode2 |

### Ammunition

The engine reads `Ammo[<the current OffenseMode value>]` when it builds an engaged, ranged or weaponskill set, so your gear sets never have to name a bullet or an arrow.

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

`Ammo.Bullet`, `Ammo.Arrow` and `Ammo.Bolt` are created for you. A weaponskill fired with no ammunition of its own falls back on the standard round for the ranged type in use — the `.RA` or `.TP` key of `Ammo[state.RAMode.value]` — on Ranger as well as Corsair.

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

Two things help while building a file. **A set you declare and leave empty is reported in chat, whereas one you never declare is not** — so if you decide you do not want a set, delete the declaration rather than emptying it. And **`//gs c checksets`** reports both — see [Diagnostics](#diagnostics).

All sets go inside `function get_sets()` in your job file.

### Core sets

| Set | When used |
|---|---|
| `sets.Idle` | Standing still, not engaged — and merged as a floor under every midcast |
| `sets.Idle.<Mode>` | Idle variant matched to the current OffenseMode |
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

An OffenseMode you offer with no matching child set costs you the rest of the engaged build: the weapons, the shield or dual-wield offhand, Aftermath and Treasure Hunter are all skipped. The base `sets.OffenseMode` still equips, which is what makes the gap easy to miss. An empty declaration is enough to close it.

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
| `sets.Weapons['Light Bonus']` | Merged with Chatoyant Staff on a Cure or Cura when the day or the weather is Light |

Each phase reads its own weapon child set and the shield merges last, so a declared offhand wins where dual wield allows one and stands aside where it does not.

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
| `sets.JA` | Job abilities — the catch-all every ability falls back to |
| `sets.JA['<Ability Name>']` | One job ability |

`sets.JA` and its named children are read for actions the game types as **JobAbility**. A pet command — Fight, Heel, Spur, Deploy and the rest — is not one of those, and has no set of its own: your pet's own actions are dressed by [the pet midcast sets](#midcast).

### Midcast

Offensive magic:

| Set | When used |
|---|---|
| `sets.Midcast` | The base for every cast, over `sets.Idle` |
| `sets.Midcast.SIRD` | Spell Interruption Rate Down — merged under every midcast except a ranged attack |
| `sets.Midcast.Nuke` | Elemental nukes |
| `sets.Midcast.Nuke.Earth` | An extra layer for Earth nukes |
| `sets.Midcast.Burst` | Nukes during an open skillchain window |
| `sets.Midcast.Enfeebling.MACC` | Accuracy-based enfeebles (Dispel, Aspir, Drain, Frazzle, Stun, Poison) |
| `sets.Midcast.Enfeebling.Potency` | Potency-based enfeebles (Paralyze, Slow, Addle, Distract, Blind, Gravity) |
| `sets.Midcast.Enfeebling.Duration` | Duration-based enfeebles (Sleep, Dia, Bio, Silence, Bind, Break, Inundation) |
| `sets.Midcast.Dark.MACC` | Death, Kaustra, Stun |
| `sets.Midcast.Dark.Absorb` | Absorb-*, Aspir, Drain |
| `sets.Midcast.Dark.Enhancing` | Dread Spikes, Endark, Klimaform, Tractor |
| `sets.Midcast.Aspir` / `.Drain` | Aspir and Drain specifically |
| `sets.Helix` | Helix spells, with `.Dark` and `.Light` layered on top by element |
| `sets.Midcast.BlueMagic` | Blue magic base, with `.Physical`, `.Breath`, `.Nuke`, `.Skill`, `.Buff`, `.Enmity`, `.Healing` and `.ACC` layered by spell class |

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
| `sets.Midcast.RA.<Mode>` | Per OffenseMode |
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
| `sets.WS.<Mode>` | Per OffenseMode — `ACC`, `PDL`, `SB`, `CRIT`, `MEVA` |
| `sets.WS['<Weaponskill Name>']` | A specific weaponskill — `sets.WS['Savage Blade']` |
| `sets.WS['<Name>'].<Mode>` | A specific weaponskill in a specific mode |
| `sets.WS.AM` / `.AM1` / `.AM2` / `.AM3` | Aftermath tiers, each with an optional `['<Weapon Mode>']` child |
| `sets.WS.RA` | Ranged weaponskills, the base |
| `sets.WS.RA.<Mode>` | Ranged weaponskills per OffenseMode |
| `sets.WS.RA.AM` / `.AM1` / `.AM2` / `.AM3` | Ranged Aftermath tiers, each with an optional `['<Weapon Mode>']` child |

Named weaponskill sets layer on top of the generic ones, so you only specify what differs.

**Ranged weaponskill keys read `RA` first**: `sets.WS.RA.ACC`, not `sets.WS.ACC.RA`. A declaration written the other way round sits in a table the engine does not read.

### Job-specific sets

| Set | Job |
|---|---|
| `sets.Waltz`, `sets.Jig`, `sets.Samba`, `sets.Step`, `sets.Flourish` | DNC — each with an optional child named for the ability |
| `sets.PhantomRoll`, `sets.QuickDraw` | COR — each with an optional child named for the roll or shot |
| `sets.Jugs` | BST — keyed by your JobMode value |
| `sets.Ready` | BST — the one set worn for a Ready move |
| `sets.Geomancy`, `.Geo`, `.Indi`, `.Indi.Entrust` | GEO |
| `sets.Storms` | SCH |
| `sets.Diffusion` | BLU |
| `sets.TreasureHunter` | THF, and anyone using a TH mode |

`sets.Ready.Magic`, `.TP`, `.Debuff` and `.Standard` are declared and reserved; the engine merges the parent `sets.Ready` only.

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

---

## 9. The gear library

`GearSets-Include.lua` is a companion library of pre-built item entries — 4,903 of them. Instead of typing item names into your sets, you reference entries by key:

```lua
sets.Idle = {
    head = gear.nyameHead,
    body = gear.sakpataBody,
    left_ring = gear.moonlightRing,
    right_ring = gear.gelatinousPlusOne,
}
```

Every entry carries the item's name, any augments, an optional wardrobe pin, and a **priority** — and the priority is the point of the whole system.

It loads with one line at the top of your job file, which the samples already have:

```lua
include('RahvinGS/GearSets-Include')
include('RahvinGS/Rahvin-Engine')
```

Then use `gear.<key>` anywhere you would write an item name. Plain item-name strings still work everywhere — they just swap without a priority.

### Why priorities matter

When GearSwap performs a rapid chain of swaps — precast, midcast, aftercast, back to idle — your maximum HP and MP are gated to the **lowest combined total that occurs at any moment during the chain**. Equip low-HP gear before high-HP gear and your max HP dips mid-swap; the game clamps you to that dip, and the loss endures after the swap completes.

GearSwap equips the pieces of a set in priority order, highest first. The library sets each item's priority to its total HP, including augments, so higher-HP gear always lands first and the dip never happens: max HP rises before it falls, and you keep the highest enduring HP and MP through every swap chain.

**This strategy has been through extensive in-game testing by Rahvin.** Side-by-side comparison against unprioritized swapping shows prioritized swaps reliably preserving higher enduring HP and MP. A third strategy — computing the HP delta between the incoming set and the gear currently worn, and prioritizing by that delta — was also built and tested, and it performed markedly worse in practice: lower HP at aftercast, plus heavy calculation cost at load and cast time. Raw total-HP priorities win on both reliability and cost, which is why the library uses them.

Items with MP and no HP get a small priority, compressed to 1–10, so they sort below anything carrying real HP. Items whose own HP is negative — the two HP-to-MP converter rings, the Apogee set — sort below everything.

Melee weapons use an **ordering token** instead of HP: every main- and offhand weapon in the library carries the same rank, **100**, and shields, grips and straps rank strictly below it. Since GearSwap breaks a priority tie by slot number, equal-ranked weapons dress the main hand before the offhand, which forces the offhand slot to empty and be available when you switch between one-handed, two-handed and dual-wield sets. Guns, bows and crossbows carry an ordinary HP priority instead: nothing competes with them for the range slot, so there is no ordering to protect.

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

The library covers the full Artifact, Relic and Empyrean catalog for every job across the original era and every reforge tier, every Nolan augment path for the Escha and Geas Fete sets at maximum rank, every stage of every Trial of the Magians weapon, and the endgame gear the sample files reference. Each entry carries an inline comment with the item's highlight stats, and armor set categories note their set bonus.

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
- **Spell timeout** — clears the busy flag if an action never reported completion, so the engine cannot get stuck.
- **Gear refresh** — re-equips the correct set whenever something has changed that warrants it.
- **Every 2 seconds** — calls your `Cycle_Timer()` if you defined one, skipped while the engine is busy.
- **Every 30 seconds** — re-checks the Dual Wield trait and expires Treasure Hunter entries older than three minutes.

### Action validation

The engine refuses actions that would fail, before GearSwap composes the packet, and tells you why.

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

A macro aimed at an open subtarget cursor — `/ma "Cure IV" <stpt>`, `/ws "Aeolian Edge" <stnpc>` — completes without a Lua error.

### Resource warnings

- **Ranged ammunition** — counted across your inventory and all eight wardrobes at precast. A shot or weaponskill has to leave more rounds than it would spend, so the last ones are held back rather than fired; below `Ammo_Warning_Limit` you get one banner, echoed to your other characters, and it is said once rather than on every shot.
  ```
  No ammo (Chrono Bullet) available for that action.
  Not enough ammo.  Canceling.
  No Quick Draw ammo left.  Using what's currently equipped (Hauksbok Bullet).
  ```
- **Ninja tools** — warns when your Shihei or Shikanofuda runs low, and echoes the warning to your other characters. It never cancels: casting the last shadows is exactly what a player out of tools wants to do.

### Automatic gear rules

- **Weather and day bonus** — on elemental magic, equips Hachirin-no-Obi, Orpheus's Sash, Chatoyant Staff or Twilight Cape when day, weather or target distance makes them worthwhile, and only if you own the item. Twilight Cape is held for Cura and Curaga, so single-target cures keep whatever back piece your set specifies.
- **Required equipment** — Dispelga equips Daybreak, Honor March equips Marsyas, Aria of Passion equips Loughnashade, Impact equips a Crepuscular or Twilight Cloak, and a White Mage main job carrying Yagrush casts Cursna with it. These are merged over everything else the build chose. When a higher layer holds one of those slots, the piece stands down and the line names the holder.
- **Two-handed detection** — inspects your WeaponMode weapon and sets the two-hand flag, which suppresses sub-slot swaps. The answer is remembered per weapon name, so a weapon-mode change does not re-scan the item database.
- **Long casts hold their gear** — blue magic, avatar and spirit summons and Trust summons each get a busy window sized from their own cast time, so a buff landing mid-cast does not rebuild you into idle or engaged gear.

### Status ailment responses

| Ailment | Response |
|---|---|
| **Sleep** | Equips idle plus `sets.Weapons.Sleep` and holds those slots; cancels Stoneskin so you can be woken |
| **Doom** | Equips and holds `sets.Cursna_Received`; uses a Holy Water if `AutoItem` is on, and says so if you have none |
| **Silence** (mage main or subjob) | Uses a Remedy if `AutoItem` is on |
| **Paralysis** | Uses a Remedy if `AutoItem` is on |
| **Petrification / Stun** | Re-evaluates and re-equips your correct set |

Sleep and Doom holds are released automatically when the status wears off. With `SpellReceived` on, the Doom set is dressed by the multibox path instead, so one owner holds the slots rather than two. Spectral Jig cancels an active Sneak before the ability fires, so the jig's own Sneak lands.

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

For players running several characters at once. When one of your characters begins casting a supported spell, it broadcasts over Windower's IPC channel. Any of your other characters targeted by that spell equips its "received" gear immediately — at pretarget, before the spell lands and ahead of Quick Magic.

**Supported spells:** Cure I–VI · Curaga I–V · Cura I–III · Cursna · Phalanx I–II · Protect I–V · Protectra I–V · Shell I–V · Shellra I–V · Regen I–V · Refresh I–III

**Supported abilities:** Curing Waltz I–V · Divine Waltz I–II

The engine also predicts area-of-effect coverage, so `-ga` and `-ra` spells, Accession, Divine Veil and Majesty reach every affected character rather than only the direct target — and reach your party members only, so an alliance member in another party is not armed for a buff that cannot land on them.

Received gear sits below an item use, the two holds, the Hoxne hold, Sleep gear and the cast in progress, and it says which slot a higher hold kept from it:

```
Received gear: back is held by gs c disable right now.
```

A canceled cast releases the gear and slots it borrowed on your other characters at once. A failsafe timer releases any held gear if a completion message never arrives, so you cannot get stuck wearing cure-potency gear in a fight. The window is `delay` in `settings.xml`, three seconds by default.

---

## 12. Customization hooks

The engine builds a gear set, then calls your function and merges whatever you return. Define only the hooks you need — the engine names the missing ones in chat while `warn` is on. A hook returning something that is not a gear set is ignored, and says so.

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

A function of the same name defined in your job file loads after the include and replaces the engine's, so a file carrying its own copy keeps working exactly as it did. The same is true of every engine global: your job file loads last and wins.

### The startup call

Call this once, outside `get_sets()`, to apply your lockstyle, macro book and keybinds:

```lua
jobsetup(LockStylePallet, MacroBook, MacroSet)
```

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

**Each set warns at most once a minute**, and says so, so a long fight stays readable. When the same set speaks again it reports what it held back — `(4 silenced since the last)`. The trace hint appears on the first warning after a load, not on every one. `gs c checksets` clears the silences if you want everything reported again immediately.

**To stop a warning for a set you deliberately leave bare, delete the declaration rather than emptying it.** The engine never asks for a set you have not declared, so `sets.JA["Light Arts"] = {}` is noisier than no line at all: deleting it moves the report up to `sets.JA`, which collapses many per-ability warnings into one. Put gear in `sets.JA` and it goes quiet entirely, while the info line still confirms what you wore. This works for ability and named-spell sets, which are yours to declare; the engine's own category sets — `sets.Midcast.Cure` and the like — always exist, so for those the answer is gear or `gs c warn`.

A third message, `Chosen set is [Empty] - nothing to equip.`, means no set at all produced gear for your current state. It repeats at most once every 30 seconds.

`//gs c warn` turns these off entirely.

### Gear is not swapping

1. `//gs c debug` and watch the debug box.
2. If `is_Busy` is stuck on, an action never reported completion — it clears itself within a couple of seconds.
3. If `is_Moving` is stuck on, you may be on a mount or in an area where position updates are unreliable.
4. Read the hold map on the debug box, or the rig under the LATTICE style: if the slot carries a letter, a layer is holding it.
5. `//gs c enableall` releases every slot.
6. `//gs c update auto` forces a re-evaluation.

### A slot is stuck

Something is holding it, and the [layer table](#how-the-layers-stack) says what. `//gs c enablebymode` releases what no layer is still claiming; `//gs c enableall` releases everything.

`//gs c enableall` is a manual override, so it releases range and ammo even while a Hoxne mode is on and the mode takes them back — see [Releasing a slot](#releasing-a-slot). The weapon lock is a mode too, and `gs c weaponlock Unlocked` is what ends it.

If the Hoxne Ampulla is sitting in your ammo slot after a reload, wait a few seconds — the engine detects a stranded Ampulla shortly after loading and puts your normal gear back on its own. `//gs c hoxneinfo` shows what it is doing.

### The status box shows a hold I did not ask for

The `HLD` row names every hold standing. `DIS` is `gs c disable`, `NKD` / `WPO` / `PRC` are the three strip holds, and `CAP` / `DYN` / `JUB` are the carried-item locks. Each ends with its own command's `off`, or with `gs c enableall`.

### An item is not equipping

The engine can only equip items you own. Check the spelling exactly as the item appears in game, and confirm it is in inventory or a wardrobe — not in storage, a satchel or a sack.

If the item's name contains a command word — `gs c use hoxne ampulla` — the command still reaches the right handler; the whole name after `use` is treated as the item.

### An enchanted item is not being used

`gs c use` names the reason it stopped, so read the chat line first — it will tell you whether the item is missing, unusable by your job, or on cooldown. If it printed `Equipping and using [...]` and then nothing happened, run `gs c enchinfo <item>` and check the `-> engine sees:` line described under [Diagnostics](#diagnostics).

A few things are worth knowing:

- **The first use after equipping always takes a few seconds.** Enchanted gear has to be worn for its equip delay before the game will accept a use, and the server wants a little more than the delay the wiki lists.
- **Timings restart every time the item is re-equipped**, so anything that swaps that slot mid-wait starts the clock again.
- **A song or Geomancy cast clears your ammo slot.** If you are running Hoxne `ON-Allow Critical`, that is why the Ampulla disappears during a song and returns afterwards.

### A ranged attack is canceled with "No round named"

The built set for that action names no ammunition. The line says which shape the key took:

```
No round named for Last Stand: ammo is undeclared in the built set. Canceling.
```

`undeclared` means nothing set the slot, `blank` means it was set to an empty string, and `empty` means it was set to be cleared. Check that the `Ammo` key for your current OffenseMode is filled in — see [Ammunition](#ammunition) — and that no set in the chain clears the slot.

### A bard song or Geomancy spell fails with a command error

Check whether Hoxne is set to `ON-Locked`, and switch to `ON-Allow Critical`, which stands aside for exactly these cases — see [The Hoxne Ampulla hold](#the-hoxne-ampulla-hold). Bards should also check that the weapon lock is not on `Locked`, which holds main and sub through a song aimed at a monster; `Songs` is the value written for them.

### The display box is gone

`//gs c zero` moves it back to the top-left corner. If it is hidden rather than lost, `//gs c display`.

### Settings are not saving

Saving is skipped while zoning. Wait until you are fully loaded, then `//gs c save`. Settings live in `Windower4/addons/GearSwap/data/settings.xml`, under a node named for your character.

Dragging a box saves silently, so no chat message on release is normal — confirm by checking the `pos` values in `settings.xml`, or reload GearSwap and see whether the box returns to where you dropped it. The three channel toggles — `info`, `warn`, `gearreporting` — do not write to disk on their own, so follow one with `gs c save` to keep it.

### The status box shows blank squares or the columns are ragged

The box uses square and triangle characters that exist in Consolas, Lucida Console and Courier New. If you have changed `font` in `settings.xml` to a font lacking them, Windows substitutes a glyph from another font at a different width, which knocks the columns out of alignment. Switch back to a monospaced font that covers them.

### A startup message mentions a retired feature

Two notices can appear as your job file loads:

```
Auto Buff was removed: this job file still defines check_buff_JA or check_buff_SP and nothing calls them. They can be deleted.
Auto Tank and Runes were removed: this job file still names one, so the mode is still shown but now drives nothing.
```

Both are advisory and neither stops anything working. See [Upgrading](#what-to-change-in-your-own-job-file) for what to do about each.

### Nothing loads at all

Confirm the `RahvinGS` folder and your job file are both in `GearSwap/data/`. Then `//gs reload` and watch for errors in the Windower console.

---

# Performance

Rahvin GearSwap is measured, not asserted. A simulated Dynamis Divergence fight — six clients played the way a six-box party plays, inside an 18-player alliance against a full mob wave — runs three engines over identical timelines from a fixed seed, at each engine's own shipped defaults:

| Engine | What it is |
|---|---|
| **Mirdain-Include 1.5.12** | The original include as its author shipped it |
| **Selindrile** | Another author's suite, at a pinned upstream commit |
| **Rahvin GearSwap 2.0** | This engine |

The comparison covers CPU cost per client and across the party, the most expensive single frame against a 60 fps budget, allocation rate and resident memory, per-cast and per-event costs, the received-spell race, and chat volume in each of the diagnostic states you can select.

The 2.0 report is published after release.

[perfSim comparison report: link to follow]

---

# Credits

Original concept and engine by **Mirdain**. This enhanced revision conceived and programmed by **Rahvin**.

Contributions and issue reports welcome via the Silmaril or Vinland discords.  IYKYK.

# License

Released under the MIT License — see [LICENSE.md](LICENSE.md). Copyright © 2026 Rahvin; derived from Mirdain-Include, copyright © 2020 Mirdain, used with the author's permission.
