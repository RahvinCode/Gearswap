# Mirdain-Include Enhanced by Rahvin

**Version 1.7.0** · A GearSwap engine for Final Fantasy XI (Windower 4)

Enhanced version of Mirdain-Include, created by Rahvin. Check your running version in game with `//gs c version`.

---

## Table of Contents

1. [What This Is](#1-what-this-is)
2. [Installation](#2-installation)
3. [How It Works](#3-how-it-works)
4. [The On-Screen Display](#4-the-on-screen-display)
5. [Keybinds](#5-keybinds)
6. [Modes](#6-modes)
7. [Commands](#7-commands)
8. [Job File Settings](#8-job-file-settings)
9. [Gear Sets Reference](#9-gear-sets-reference)
10. [Automatic Engine Checks](#10-automatic-engine-checks)
11. [Action and Spell Tracking](#11-action-and-spell-tracking)
12. [Customization Hooks](#12-customization-hooks)
13. [Troubleshooting](#13-troubleshooting)

---

## 1. What This Is

GearSwap is a Windower addon that changes your equipment automatically as you play. Normally you would write all of that swapping logic yourself, for every job. This suite does it for you.

**Mirdain-Include.lua** is the engine. It contains all the rules: which gear to wear while idle, while fighting, while casting, while moving, and so on. It is the same file for every job and you should not need to edit it.

**Job files** (`WAR.lua`, `WHM.lua`, `BLM.lua`, …) are yours. They contain your gear, your modes, and your preferences. You will spend all of your time in these.

If you have never used GearSwap before: you only need to fill in gear sets in your job file. The engine handles the rest.

### New in 1.7.0

The first public release since 1.6.5, and it carries the 1.6.6 work with it. Nothing here requires a change to your job files — every existing job file, custom command and keybind keeps working as-is.

#### Enchanted items

- **`gs c use <item>`** equips and uses any enchanted item — over five hundred are supported — handling the slot, the equip delay and the cooldown for you. Type the name in lower case, spaces and any `+1` included: `//gs c use prishe's boots +1`.
- **Cooldowns are tracked** and read live from the item, so they survive a reload or a relog. A use on cooldown is refused with the time remaining; an equip delay is waited out quietly. Every refusal names its reason — item missing, wrong job, level too low, on cooldown.
- **`gs c cancel`** stops a use in progress, and issuing any new use command — `gs c use`, `gs c warp` and friends — takes over from the one already running. See [Changing your mind](#changing-your-mind).
- **`gs c enchinfo <item>`** prints an item's live charges, equip delay and cooldown when the timing looks wrong.

#### Hoxne Ampulla

- **Two on states**, cycled with `//gs c hoxne`. `ON-Locked` holds range and ammo outright. `ON-Allow Critical` stands aside for bard songs, Geomancy, Tomahawk and Angon, then takes the slot back — the one for Bards and Geomancers. See [Hoxne](#hoxne--hoxne-ampulla-lock).
- **Fully automatic use.** While a mode is on, the Ampulla is kept equipped, used whenever its enchantment is down and it is ready, and put back when anything knocks it out. Switching a mode on during a cooldown reports the wait once, then uses the item when it is ready. Zoning turns the mode `OFF`.
- **It recovers itself after a reload.** An Ampulla left stranded in your ammo slot is detected and released within a few seconds, with your normal gear restored.
- **`gs c hoxneinfo`** prints everything the mode is acting on — a one-command health check.

#### Job abilities that need a thrown item

- **`gs c tomahawk` and `gs c angon`** equip the throwing item, then use the ability on your target. Use these in macros in place of a raw `/ja` line, which the game refuses while the item is not worn. The ability's recast is checked before any gear moves.

#### Gear diagnostics

- **A cast that finds no gear says so**, naming the set and why: `[sets.Midcast.Cure] not found!` if you never declared it, `[sets.Midcast.Regen] is empty!` if you declared it and left it bare.
- **`gs c checksets`** audits a job file: how many sets carry gear, how many engine sets you never declared, and — named individually — any set you declared but left empty.
- **`gs c gearreporting`** traces which set each cast actually used, and the whole fallback path when the set it reached for was bare. Off by default.

#### The status box

- **Clearer layout.** The indicators run SR, TH, HOX; in the stacked layout the header spans the full box, evenly spaced, and each mode value sits between its chevrons with a single space on either side.
- **More legible.** Mode status shows as a solid coloured square, and the text carries a dark outline so it reads against any background.
- **Chat notices were re-coloured** so warnings, the gear trace and debug output are distinguishable at a glance.

#### Fixes

- Treasure Hunter gear is merged at precast for weapon skills, ranged attacks and job abilities against untagged mobs. Spell precasts keep your fast-cast gear; the Treasure Hunter set arrives at midcast instead, which is when the tag lands.
- Twilight Cape equips only for Cura and Curaga, so single-target cures keep the back piece your set specifies.
- Item names that contain command words — `gs c use hoxne ampulla` — reach the right command.
- A use that succeeds is not reported as "not accepted".
- Slots left locked by a previous load are released at startup.
- Sample job files for all 22 jobs are included.

#### Performance

Measured, not guessed: a simulated Dynamis Divergence alliance fight — a six-client multibox party inside an 18-player alliance with a full mob wave, every entity acting every one to three seconds — puts this engine and the original Mirdain-Include 1.5.12 side by side on identical timelines.

- **1.7.0 runs at roughly 70% of 1.5.12's CPU cost and 72% of its allocation rate**, with Hoxne, spell-received tracking, enchanted-item automation and the gear diagnostics all running. With every chat channel on, 1.7.0 costs what 1.5.12 costs running silent.
- **Frame rate is never at risk from the engine.** The worst single frame in twenty minutes of simulated combat is about 1% of a 60 fps frame budget on 1.5.12, and about half that on 1.7.0. Both engines together, across all six clients, use under 0.03% of one CPU core.
- **Chat volume is the one load that scales with settings rather than engine**: with every channel on, six clients emit about 1,400 lines a minute; with chat off, effectively none. For long fights, keep `debug` off — it is worth three orders of magnitude more rendered chat than any other choice.

The full write-up — per-cast costs, frame-budget analysis, allocation, chat volume, and methodology — is in the repository at [`Performance Impact Report.md`]
---

## 2. Installation

1. Install Windower 4 and enable the **GearSwap** addon.
2. Copy `Mirdain-Include.lua` into:
   ```
   Windower4/addons/GearSwap/data/
   ```
3. Copy the job files you want from `Sample Job Files/` into:
   ```
   Windower4/addons/GearSwap/data/
   ```
4. Rename each job file to match your character, or leave it as the job name to share across characters:
   - `WAR.lua` — used by any character on Warrior
   - `Yourname_WAR.lua` — used only by that character on Warrior
5. Log in and change to that job. GearSwap loads the file automatically.

Verify it worked by typing `//gs c version` — you should see the include version echoed back.

> **Upgrading?** Replace `Mirdain-Include.lua` only. Your job files are yours and are not overwritten. If you are upgrading from 1.5.X to any later version, delete the settings.xml file within Windower4/addons/GearSwap/data and reload GearSwap in game with `lua r gearswap`

---

## 3. How It Works

Every job file begins by loading the engine:

```lua
include('Mirdain-Include')
```

From that point the engine drives everything, calling into your job file at specific moments. The flow for any action looks like this:

```
You press a macro
        │
        ▼
   pretarget ──► engine validates the action (enough TP? spell on cooldown? asleep?)
        │        cancels it and tells you why if not
        ▼
    precast  ──► engine equips Fast Cast / weaponskill gear
        │
        ▼
    midcast  ──► engine equips potency / accuracy / recast gear
        │
        ▼
   aftercast ──► engine returns you to idle or melee gear
```

At each step the engine builds a gear set from its own rules, then calls **your** matching `_custom` function so you can add or override anything. See [Customization Hooks](#12-customization-hooks).

Separately, a background loop (the "engine") runs about ten times a second to handle things that are not tied to an action — movement gear, auto-buffing, weapon checks. See [Automatic Engine Checks](#10-automatic-engine-checks).

---

## 4. The On-Screen Display

The suite draws two boxes on screen.

**Status box** — always available, shows your current modes. Two layouts, toggled with `//gs c displaymode`.

Stacked:

```
SR .   TH .   HOX .
STN     < DT >
DPS < Black Halo >
MDE    < Melee >
```

One-line:

```
SR .  TH .  HOX .  STN < DT >  DPS < Black Halo >  MDE < Melee >
```

*(The box draws coloured squares and solid triangles. They are transcribed above as `.`, `<` and `>` so this file stays readable in a plain-text editor.)*

**Reading the indicators**

| Indicator | Meaning |
|---|---|
| Green square | Mode is fully on |
| Amber square | Partially on — TH `Tag`, or Hoxne `ON-Allow Critical` |
| Cyan square | THF-only TH `SATA` |
| Grey square | Mode is off (`None` / `OFF`) |
| Value between triangles | A cycling mode — press its key, or `//gs c <mode> <value>` |

SR (SpellReceived), TH and HOX (Hoxne) status is indicated by a colored square. In the stacked layout the indicator header spans the full width of the box — SR at the left edge, TH centred, HOX at the right. Every other mode shows **full text**, so the weapon or job function currently selected is always readable.

**Sizing.** Column widths come from each mode's complete list of options rather than its current value, so cycling a mode never resizes the stacked box — it stays a fixed width for as long as a job is loaded. The glyph header sets a 17-cell floor that most jobs never exceed, which also keeps the box near-identical across job changes, and the stacked box widens by one cell when needed so the header's gaps stay perfectly even. The one-line layout deliberately flexes with the current values to stay as short as possible.

**Debug box** — hidden by default, shows internal engine state. Useful when something is not swapping as expected:

| Field | Meaning |
|---|---|
| `is_Busy` | Engine is mid-action and will not overwrite gear |
| `is_Moving` | You are moving; movement gear is active |
| `DualWield` | Dual Wield trait detected |
| `TwoHand` | Your current main weapon is two-handed |
| `Casting` | An outgoing tracked cast is in progress |
| `Failsafe` | Spell-received gear is waiting on a timeout |

### Moving and saving the boxes

Drag either box with the left mouse button. The position is written to disk automatically when you release, and the save is **silent** — there is no chat confirmation. Display position saving is performed via Windower's text library and not by an explicit config.save.

You can also save manually with `//gs c save`, reset a lost box to the top-left corner with `//gs c zero`, hide the status box with `//gs c display`, and switch between one-line and stacked layouts with `//gs c displaymode`.

Positions are stored **per character** in `Windower4/addons/GearSwap/data/settings.xml`.

> Saving is skipped while you are zoning. A drag released mid-zone is not persisted — drop the box again once you have finished loading. `//gs c save` will tell you outright if it cannot save yet.

---

## 5. Keybinds

Bound automatically when your job file loads.

| Key | Action |
|---|---|
| <kbd>F9</kbd> | Cycle **WeaponMode** |
| <kbd>F10</kbd> | Cycle **AutoBuff** |
| <kbd>F11</kbd> | Cycle **TreasureHunter** |
| <kbd>F12</kbd> | Cycle **OffenseMode** |
| <kbd>Ctrl</kbd>+<kbd>F9</kbd> | Cycle **SpellReceived** |
| <kbd>Ctrl</kbd>+<kbd>F10</kbd> | Cycle **Hoxne** — `OFF` → `ON-Allow Critical` → `ON-Locked` |
| <kbd>Ctrl</kbd>+<kbd>F11</kbd> | Cycle **JobMode2** |
| <kbd>Ctrl</kbd>+<kbd>F12</kbd> | Cycle **JobMode** |

Every keybind has an equivalent command, so you can bind your own keys or build macros instead. Keybinds are released when the job file unloads.

---

## 6. Modes

A "mode" is a named switch the engine reads when choosing gear. Cycle a mode with its keybind, or jump straight to a value with a command.

### OffenseMode — your melee gear set

The main damage-vs-survival switch. Drives `sets.OffenseMode`, `sets.WS`, and ammo selection.

- **Default options:** `TP` `ACC` `DT`
- **Set your own in your job file:**
  ```lua
  state.OffenseMode:options('TP','PDL','ACC','DT','PDT','MEVA','CRIT','SB')
  state.OffenseMode:set('DT')
  ```
- **Command:** `//gs c OffenseMode PDL`

Every option you list needs a matching `sets.OffenseMode.<Name>`, or the engine warns you.

### WeaponMode — which weapon to equip

Lets you swap weapon sets without touching your gear sets.

- **Options are entirely yours:**
  ```lua
  state.WeaponMode:options('Chango','Shining One','Naegling','Unlocked')
  state.WeaponMode:set('Chango')
  ```
- **Command:** `//gs c WeaponMode "Shining One"`
- Each option needs a matching `sets.Weapons.<Name>`.
- The special value `Locked` stops the engine from changing weapons at all.

### TreasureHunter — Treasure Hunter gear handling

The engine remembers which monsters you have already tagged, so it only wears TH gear when it will actually do something.

| Mode | Behavior |
|---|---|
| `None` | Never equip TH gear |
| `Tag` | Equip TH gear only until the current target is tagged, then swap back to full damage |
| `Full Time` | Always wear TH gear while engaged |
| `SATA` | THF only — wear TH gear when Sneak Attack, Trick Attack or Feint is active |

Defaults to `Full Time` on THF and `None` on every other job. Tagged monsters are forgotten after 3 minutes of inactivity, and cleared entirely when you zone.

**Command:** `//gs c TreasureHunter "Full Time"`

### AutoBuff — self-buffing

When on, the engine checks roughly ten times a second whether you are missing a buff it can reapply, and uses it. Disabled in towns, and while asleep, stunned, terrorized, paralyzed, silenced or muddled.  This is leftover from development prior to the use of other automation tools.  Usable if manually playing.  Leave this setting turned off if using other automation software.

- **Options:** `OFF` `ON`
- **Command:** `//gs c AutoBuff ON`
- Automatically switched **off** when you zone.
- What gets buffed is defined by you — see [`check_buff_JA` / `check_buff_SP`](#12-customization-hooks).

### SpellReceived — multibox spell-received gear

For players running more than one character. When another of your characters casts a supported spell on you, this character equips its "received" gear *before the spell lands* — even through Quick Magic.

| Mode | Behavior |
|---|---|
| `ON` | Equip received gear and lock those slots until the spell resolves |
| `OFF` | Disabled |

**Command:** `//gs c SpellReceived ON`

> **Changed.** The former `ON-Locked` and `ON-Unlocked` values were collapsed into a single `ON`. `ON-Locked` is now just `ON` and behaves identically; `ON-Unlocked` has been removed as unnecessary. Any macro or script still passing an old value is rejected with a suggestion rather than silently doing the wrong thing — update it to `ON`.

Requires the corresponding `*_Received` sets. See [Spell-Received Tracking](#spell-received-tracking-multibox).

### Hoxne — Hoxne Ampulla lock

Holds Hoxne Ampulla in your ammo slot, keeps it there when something knocks it out, and uses it automatically whenever the enchantment has worn off and the item is off cooldown. Zoning turns the mode `OFF` and restores your normal gear.

- **Options:** `OFF` `ON-Allow Critical` `ON-Locked`
- **Command:** `//gs c hoxne`, or `//gs c hoxne ON-Locked` to set one directly
- Will refuse to turn on if the item is not in your inventory or wardrobes.

**`ON-Locked`** holds range and ammo outright. Nothing else may enter either slot, so instruments, handbells, Angon and Thr. Tomahawk will not equip while it is on. This is the strictest setting and the one to use when you only care about keeping the Ampulla up.

**`ON-Allow Critical`** holds both slots the same way, but stands aside for the handful of actions that genuinely need them:

| Action | Slot borrowed |
|---|---|
| Bard songs | `range` (instrument) |
| Geomancy — both `Geo-` and `Indi-` | `range` (handbell) |
| Tomahawk (WAR) | `ammo` (Thr. Tomahawk) |
| Angon (DRG) | `ammo` (Angon) |

The slot is released as the action starts and reclaimed afterwards — immediately for job abilities, and five seconds after the last cast for songs and Geomancy, so a full song rotation or a Geo/Indi pair is treated as one continuous window rather than fighting you between casts.

**Macro Tomahawk and Angon as `/console gs c tomahawk` and `/console gs c angon`**, not as a raw `/ja` line. The game refuses a typed `/ja` for these while the throwing item is not worn; the commands equip the item first, then use the ability on your target. Menu use needs no change.

Equipping an instrument or handbell makes the game clear your ammo slot, so the Ampulla is dropped for the duration and put back when the window closes. That is expected, not a fault.

> **Bards and Geomancers should use `ON-Allow Critical`.** Honor March and Aria of Passion can only be cast while Marsyas or Loughnashade is equipped, and `ON-Locked` blocks the instrument, so those two songs will fail outright with a command error. Geomancy needs its handbell for the same reason.

Automatic use waits out the item's equip delay and its recast, so the first use after locking the mode on takes a few seconds. If it is genuinely on cooldown you get one warning with the time remaining, not a repeated one.

Reloading GearSwap while a mode is on resets the mode to `OFF`; the engine frees the Ampulla and restores your normal gear on its own within a few seconds of loading. `//gs c hoxneinfo` prints everything the mode is acting on — the slots, the buff and the item's timers.

### JobMode and JobMode2 — your own switches

Two free-form modes for anything a job needs. The engine only tracks the value; what it means is up to your job file.

```lua
UI_Name  = 'Auto Tank'     -- name used in chat messages
state.JobMode:options('OFF','Auto Tank')

UI_Name2 = 'Runes'
state.JobMode2:options('Ignis','Gelus','Flabra')
```

**Commands:** `//gs c JobMode "Auto Tank"` · `//gs c JobMode2 Ignis`

If `UI_Name` is left empty the mode is hidden from the status box.

#### Status box labels

The status box needs a short label, and the include derives one from `UI_Name` automatically — **existing job files need no changes**. A table of known names is checked first, then a general rule: a single word takes its first three letters, several words take two letters of the first plus the initial of the last.

| `UI_Name` | Derived label |
|---|---|
| `Mode` | `MDE` |
| `Pet` | `PET` |
| `TP Mode` | `TPM` |
| `Auto Tank` | `TNK` |
| `Runes` | `RUN` |
| `Blood Pact` | `BLP` |
| `Skillchain` | `SKI` |

If you dislike what it picks, set `UI_Short` (and `UI_Short2`) in your job file to override it. An explicit value is used verbatim, and the label column widens to fit if it is longer than three characters:

```lua
UI_Name  = 'Auto Tank'
UI_Short = 'ATK'           -- optional; overrides the derived TNK
```

### RAMode — ranged ammunition type

Selects which ammo table the engine reads: `Bullet`, `Arrow` or `Bolt`. Defaults to `Bullet`. See [Ammunition](#ammunition).

---

## 7. Commands

All commands are typed as `//gs c <command>` and are **case-insensitive**.

They fall into three groups. **Everyday commands** are the ones worth binding to macros and keys. **Diagnostics** answer a question about what the engine is doing, and can be ignored until something looks wrong. **Engine-internal commands** are ones the engine sends to itself; they are listed at the end only so you recognise them if you see them.

---

### Modes

| Command | Description |
|---|---|
| `gs c OffenseMode [mode]` | Cycle, or jump to a specific mode |
| `gs c WeaponMode [mode]` | Cycle, or jump to a specific weapon set |
| `gs c TreasureHunter [mode]` | Cycle, or jump to a TH mode |
| `gs c AutoBuff [mode]` | Cycle, or set auto-buffing |
| `gs c SpellReceived [ON\|OFF]` | Cycle, or set spell-received tracking |
| `gs c Hoxne [OFF\|ON-Allow Critical\|ON-Locked]` | Cycle, or set the Hoxne Ampulla lock |
| `gs c JobMode [mode]` | Cycle, or jump to a job-specific mode |
| `gs c JobMode2 [mode]` | Cycle, or jump to a second job-specific mode |

#### Argument validation

**With no argument, every mode command cycles forward one step**, exactly as it always has — `//gs c TreasureHunter` steps `None` to `Tag` to `Full Time` and wraps. A stray trailing space still counts as no argument.

**With an argument**, the value must be one of that mode's options, matched case-insensitively. Anything else changes nothing and reports why:

```
//gs c SpellReceived on-locked
Spell Received: "on-locked" is not a valid mode. Did you mean [ON]?
Usage: //gs c SpellReceived [OFF|ON]
```

Partial values are offered as a suggestion but never accepted, so `//gs c TreasureHunter full` is rejected with `Full Time` offered as the correction.

---

### Display

| Command | Description |
|---|---|
| `gs c display` | Show/hide the status box |
| `gs c displaymode` | Toggle one-line vs. stacked layout |
| `gs c zero` | Move both boxes to the top-left corner and save |
| `gs c save` | Save current settings to disk |

---

### Gear

| Command | Description |
|---|---|
| `gs c update auto` | Re-evaluate and equip the correct set for your current state |
| `gs c naked` | Unequip everything and lock the slots |
| `gs c nakedunlocked` | Unequip everything, leave slots unlocked |
| `gs c weaponsonly` | Keep weapons only, empty every other slot |
| `gs c abysseaproc` | Empty head/hands/legs/feet and lock them, for Abyssea red procs |
| `gs c enableall` | Unlock every slot |
| `gs c enablebymode` | Unlock every slot the current mode and zone allow |
| `gs c two_hand_check` | Re-detect whether your main weapon is two-handed |

The engine issues `gs c update auto` itself after almost every action, so you rarely need to type it. It is here for the times a set looks wrong and you want to force a rebuild.

---

### Items

| Command | Description |
|---|---|
| `gs c use <item>` | Equip and use any enchanted item; handles slot, equip delay and cooldown |
| `gs c cancel` | Stop an enchanted item use that is under way and give the slot back |
| `gs c food` | Use the item named in your `Food` variable |
| `gs c temps` | Use the six Escha temporary drinks in sequence |
| `gs c warp` | Use Warp Ring |
| `gs c warp club` | Use Warp Cudgel |
| `gs c holla` | Use Dim. Ring (Holla) |
| `gs c dem` | Use Dim. Ring (Dem) |
| `gs c mea` | Use Dim. Ring (Mea) |
| `gs c cp` | Use Trizek Ring |

#### Using enchanted items

`gs c use` handles the whole sequence for you: it equips the item, waits out its equip delay, uses it, then gives your slot back. Type the item name in lower case, spaces and all, exactly as it appears in game — including any `+1`.

```
//gs c use warp ring
//gs c use prishe's boots +1
//gs c use volte harness
```

The shortcut commands above (`gs c warp`, `gs c cp` and friends) do the same thing for the items people use most often.

It tells you what it is doing rather than failing silently. Before equipping anything it checks that you own the item, that your job, level and race can wear it, and that it is not on cooldown, and it names whichever check failed:

```
Equipping and using [Warp Ring]
Warp Ring is on cooldown [8:32].
Volte Harness cannot be worn by this job.
Prishe's Boots +1 requires level 99; your WHM is 76.
```

Cooldown and equip delay are read live from the item itself, so the times are accurate and survive a `//gs reload` or a relog. There is nothing to configure and no timer to keep in sync. If the timing ever looks wrong, `gs c enchinfo <item>` prints what the engine can see — see [Diagnostics](#diagnostics).

#### Changing your mind

Typed the wrong item? `gs c cancel` stops a use that is under way, hands the slot back and re-equips your normal gear.

You rarely need it, though, because any new `gs c use` or shortcut simply takes over from the one already running:

```
//gs c warp
//gs c cp
```

The Warp Ring is dropped and the Trizek Ring takes its place. Two things are worth knowing:

- **Re-typing the same command changes nothing** — the running use keeps its place and the engine answers `Warp Ring is already in progress.`
- **Once the item has been used it cannot be called back.** Cancelling afterwards still frees your slot and restores your gear; to stop the effect itself, move to interrupt it, as you would a spell.

---

### Job abilities

| Command | Description |
|---|---|
| `gs c tomahawk` | Equip Thr. Tomahawk, then use Tomahawk on your target (WAR) |
| `gs c angon` | Equip Angon, then use Angon on your target (DRG) |

Use these in macros in place of a raw `/ja` line. The game refuses a typed `/ja "Tomahawk"` while the throwing item is not worn, so the engine equips the item first and fires the ability the moment the game confirms it — normally within a fraction of a second. The ability's own recast is checked before any gear moves, so a command on cooldown costs you nothing.

---

### Utility

| Command | Description |
|---|---|
| `gs c version` | Print the include version |
| `gs c profile <name>` | Load a Silmaril profile script for your job/subjob/character |
| `gs c shutdown` | Terminate the game client |

---

### Diagnostics

These answer questions about what the engine is doing. All are safe to run at any time and none of them change your gear.

| Command | Description |
|---|---|
| `gs c checksets` | Audit your job file: how many sets carry gear, how many you never declared, and which declared sets are empty |
| `gs c gearreporting` | Toggle a running trace of which set each cast used, and what it fell back through |
| `gs c enchinfo <item>` | Print an enchanted item's live charges, equip delay and cooldown |
| `gs c hoxneinfo` | Print what the Hoxne subsystem sees: mode, slots, buff, cooldown, retries |
| `gs c warn` | Toggle warnings about sets that hold no gear |
| `gs c info` | Toggle informational messages (skillchains, set changes) |
| `gs c debug` | Toggle the debug box and verbose engine logging |

**`gs c checksets`** is the one to run after writing a job file. It separates a set you never declared from one you declared and left empty — the second is almost always a set you meant to fill in:

```
//gs c checksets
Sets with gear: 63.  Engine placeholders left undeclared: 88.
Declared [Empty] sets: sets.Midcast.Enhancing, sets.Precast.Enhancing
```

**`gs c gearreporting`** answers "which set did that cast actually use?" A successful cast names the set it wore; a cast whose set held nothing traces the whole fallback path:

```
Using sets.Midcast.Curaga [Filled]
Attempted to use sets.Midcast.Regen [Empty] falling back -> Using sets.Midcast [Filled]
```

It is off by default, and worth turning off again once you have your answer — it prints a line for every cast.

**`gs c enchinfo <item>`** shows why an item use is waiting:

```
//gs c enchinfo warp ring
Warp Ring: equipped=true usable=false charges=1 activation +6s next_use -515s (epoch-corrected)
  -> engine sees: cooldown 0s (warns/refuses), equip delay 9s (waits quietly)
```

The second line is the one that matters: a **cooldown** means the item cannot be used yet and the command is refused, whereas an **equip delay** just means it needs to stay worn a few seconds longer, which the engine waits out on its own.

---

### Engine-internal

You never need to type these. Equipment changes have to happen inside a normal GearSwap event, so the parts of the engine that run outside one — its background ticks — send themselves a command instead. They are listed here only so you recognise them in a verbose log.

| Command | Issued by |
|---|---|
| `gs c enchrepair` | The enchanted item engine, when an item it is using is knocked out of its slot |
| `gs c hoxnerelock` | The Hoxne tick, re-asserting its hold on range and ammo |
| `gs c hoxnerelease` | The Hoxne tick, freeing a stranded Ampulla after a reload |

## 8. Job File Settings

Plain variables you set near the top of your job file.

### Startup

| Variable | Type | Description |
|---|---|---|
| `LockStylePallet` | string | In-game Equip Set number applied on load — `"8"` |
| `MacroBook` | string | Macro book to switch to — `"4"` |
| `MacroSet` | string | Macro page to switch to — `"1"` |
| `Random_Lockstyle` | boolean | Pick a random lockstyle from the list below on each job change |
| `Lockstyle_List` | table | Candidates for random selection — `{1, 2, 6, 12}` |

### Behavior

| Variable | Type | Default | Description |
|---|---|---|---|
| `AutoItem` | boolean | `false` | Automatically use Remedy and Holy Water for status ailments |
| `Food` | string | — | Item used by `//gs c food` — `"Sublime Sushi"` |
| `Ammo_Warning_Limit` | number | `99` | Warn on precast when ranged ammo falls below this count |
| `Buff_Delay` | number | — | Minimum seconds between AutoBuff attempts |
| `Tank_Delay` | number | — | Minimum seconds between auto-tank ability attempts |
| `UI_Name` | string | `''` | Name used for JobMode in chat; empty hides the mode entirely |
| `UI_Name2` | string | `''` | Name used for JobMode2 in chat; empty hides the mode entirely |
| `UI_Short` | string | `''` | Optional status box label for JobMode; derived from `UI_Name` when empty |
| `UI_Short2` | string | `''` | Optional status box label for JobMode2 |

> **Performance tip:** `Buff_Delay` matters. Without it, AutoBuff queries every ability and spell recast about ten times a second for the whole session. One check per second is plenty — job ability recasts are minutes long. The PLD and RUN sample files show the pattern.

### Ammunition

Ranged jobs define ammo per OffenseMode. The engine reads `Ammo[state.OffenseMode.value]` when building ranged and weaponskill sets, so your gear sets can stay generic.

```lua
Ammo.Bullet.TP   = "Chrono Bullet"
Ammo.Bullet.ACC  = "Eradicating Bullet"
Ammo.Bullet.CRIT = "Eradicating Bullet"
Ammo.Bullet.WS   = "Chrono Bullet"

Ammo.Arrow.TP    = "Chrono Arrow"
-- and so on for Ammo.Bolt
```

### Instruments (BRD)

Bard files map song categories to instruments, which the engine equips automatically during song midcast:

```lua
Instrument.Count      = "Blurred Harp +1"
Instrument.Potency    = "Gjallarhorn"
Instrument.Pianissimo = "Marsyas"
Instrument.Enfeebling = "Marsyas"
Instrument.AOE_Sleep  = "Blurred Harp +1"
Instrument.FastCast   = "Eminent Flute"
```

Also available: `Idle`, `TP`, `Mordant`, `QuickMagic`, `MAB`.

---

## 9. Gear Sets Reference

Every set below is pre-created as an empty table by the engine, so you only fill in the ones you use. A set you never declare merges as nothing and the engine falls back to a more general one, which is normal and expected.

Two things help while building a file. **A set you declare and leave empty is reported in chat, whereas one you never declare is not** — so if you decide you do not want a set, delete the declaration rather than emptying it. And **`//gs c checksets`** lists every set that carries gear, every one you left undeclared, and every declared set that is empty, which is the fastest way to find a set you meant to fill in.

All sets go inside `function get_sets()` in your job file.

### Core

| Set | When used |
|---|---|
| `sets.Idle` | Standing still, not engaged |
| `sets.Idle.Resting` | Resting (healing MP) |
| `sets.Idle.Pet` | Idle while you have a pet |
| `sets.Idle.Sublimation` | Idle with Sublimation active |
| `sets.Idle.TP` / `.ACC` / `.DT` | Idle variants matched to OffenseMode |
| `sets.Movement` | Layered on top of idle while moving |
| `sets.OffenseMode` | Base melee set, always applied when engaged |
| `sets.OffenseMode.<Mode>` | Per-mode melee set — one per OffenseMode option |
| `sets.OffenseMode.AM1` / `.AM2` / `.AM3` | Aftermath tiers |
| `sets.DualWield` | Layered when the Dual Wield trait is detected |
| `sets.Enmity` | Enmity-focused gear |

### Weapons

| Set | When used |
|---|---|
| `sets.Weapons.<Mode>` | One per WeaponMode option |
| `sets.Weapons.Sleep` | Locked on automatically when you fall asleep |
| `sets.Weapons.Shield` | Shield swap |
| `sets.Weapons.Songs` | BRD instrument handling |

### Precast

| Set | When used |
|---|---|
| `sets.Precast` | Base precast |
| `sets.Precast.FastCast` | Magic precast |
| `sets.Precast.Cure` | Cure precast |
| `sets.Precast.Enhancing` | Enhancing magic precast |
| `sets.Precast.Utsusemi` | Utsusemi precast |
| `sets.Precast.Blue_Magic` | Blue magic precast |
| `sets.Precast.Songs` | Song precast |
| `sets.Precast.RA` | Ranged attack precast (Snapshot) |
| `sets.Precast.RA.Flurry` / `.Flurry_II` | With Flurry active |
| `sets.JA` | Job abilities |

### Midcast — offensive magic

| Set | When used |
|---|---|
| `sets.Midcast.Nuke` | Elemental nukes |
| `sets.Midcast.Burst` | Nukes during an open skillchain window |
| `sets.Midcast.Enfeebling.MACC` | Accuracy-based enfeebles (Dispel, Aspir, Drain, Frazzle, Stun, Poison) |
| `sets.Midcast.Enfeebling.Potency` | Potency-based enfeebles (Paralyze, Slow, Addle, Distract, Blind, Gravity) |
| `sets.Midcast.Enfeebling.Duration` | Duration-based enfeebles (Sleep, Dia, Bio, Silence, Bind, Break) |
| `sets.Midcast.Dark.MACC` | Death, Kaustra, Stun |
| `sets.Midcast.Dark.Absorb` | Absorb, Aspir, Drain |
| `sets.Midcast.Dark.Enhancing` | Dread Spikes, Endark, Klimaform, Tractor |
| `sets.Midcast.Aspir` / `.Drain` | Aspir and Drain specifically |
| `sets.Midcast.Helix` | Helix spells |

### Midcast — healing and enhancing

| Set | When used |
|---|---|
| `sets.Midcast.Cure` / `.Curaga` / `.Cura` | Cure family |
| `sets.Midcast.Regen` / `.Refresh` | Regen and Refresh |
| `sets.Midcast.Enhancing` | Base enhancing magic |
| `sets.Midcast.Enhancing.Others` | Cast on party members |
| `sets.Midcast.Enhancing.Skill` | Skill-scaling buffs (Temper, En-spells, Boost-*) |
| `sets.Midcast.Enhancing.Elemental` | Barfire, Barblizzard, … |
| `sets.Midcast.Enhancing.Status` | Barsleep, Barpoison, … |
| `sets.Midcast.Enhancing.Gain` | Gain-STR and friends |
| `sets.Midcast.SIRD` | Spell Interruption Rate Down |
| `sets.Midcast.Skill` | Generic magic skill |
| `sets.Midcast.ACC` | Generic magic accuracy |

### Midcast — ranged and pets

| Set | When used |
|---|---|
| `sets.Midcast.RA` | Ranged attack |
| `sets.Midcast.RA.TripleShot` / `.DoubleShot` / `.Barrage` | With the matching buff active |
| `sets.Midcast.RA['True Shot']` | True Shot |
| `sets.Midcast.RA.AM1` / `.AM2` / `.AM3` | Ranged aftermath tiers |
| `sets.Midcast.BP` | Blood Pacts |
| `sets.Midcast.Summon` / `.SummoningMagic` | Summoning |
| `sets.Pet_Midcast` | Pet actions |

### Weaponskills

| Set | When used |
|---|---|
| `sets.WS` | Base, always applied |
| `sets.WS.<Mode>` | Per OffenseMode — `ACC`, `PDL`, `SB`, `CRIT`, `MEVA` |
| `sets.WS['<Weaponskill Name>']` | A specific weaponskill — e.g. `sets.WS['Savage Blade']` |
| `sets.WS['<Name>'].<Mode>` | A specific weaponskill in a specific mode |
| `sets.WS.RA` | Ranged weaponskills, plus `.ACC`, `.PDL`, `.AM1`–`.AM3` |

Named weaponskill sets layer on top of the generic ones, so you only specify what differs.

### Job-specific

| Set | Job |
|---|---|
| `sets.Waltz`, `sets.Jig`, `sets.Samba`, `sets.Step`, `sets.Flourish` | DNC |
| `sets.PhantomRoll`, `sets.QuickDraw` | COR |
| `sets.Jugs`, `sets.Ready`, `sets.Ready.Magic` / `.TP` / `.Debuff` / `.Standard` | BST |
| `sets.Geomancy`, `.Geo`, `.Indi`, `.Indi.Entrust` | GEO |
| `sets.Storms` | SCH |
| `sets.Diffusion` | BLU |
| `sets.Midcast.DummySongs`, `.Lullaby`, `.Madrigal`, `.March`, … | BRD (one per song family) |
| `sets.TreasureHunter` | THF and anyone using TH modes |

### Spell-received (multibox)

Only needed if you use `SpellReceived`.

| Set | Received spell |
|---|---|
| `sets.Cure_Received` | Cure I–VI, Curaga I–V, Cura I–III |
| `sets.Cursna_Received` | Cursna |
| `sets.Phalanx_Received` | Phalanx, Phalanx II |
| `sets.Protect_Shell_Received` | Protect I–V, Protectra I–V, Shell I–V, Shellra I–V |
| `sets.Regen_Received` | Regen I–V |
| `sets.Refresh_Received` | Refresh I–III |
| `sets.Waltz_Received` | Curing Waltz I–V, Divine Waltz I–II |
| `sets.Holy_Water` | Worn when using Holy Water |

---

## 10. Automatic Engine Checks

These run without you asking. Most produce a chat message explaining what happened.

### The background loop

Runs about ten times a second:

- **Movement detection** — compares your position frame to frame; more than half a yalm of movement swaps in `sets.Movement`, stopping swaps it back.
- **Auto-buff** — if AutoBuff is on and you are not in a town, asleep, stunned, terrorized, paralyzed, silenced or muddled, calls your buff-check functions.
- **Spell timeout** — clears the busy flag if an action never reported completion, so the engine cannot get stuck.
- **Every 2 seconds** — calls your `Cycle_Timer()` if you defined one.
- **Every 30 seconds** — re-checks the Dual Wield trait and expires stale Treasure Hunter entries.

### Action validation (pretarget)

The engine cancels actions that would fail, and tells you why:

| Check | Result |
|---|---|
| Asleep, KO'd or charmed | Action cancelled |
| Pet is mid-action | Action cancelled |
| Weaponskill below 1000 TP | Cancelled |
| Weaponskill with Amnesia | Cancelled, with message |
| Ability or spell still on cooldown | Cancelled, remaining time shown as `m:ss` |
| Waltz without enough TP | Cancelled, shows current vs. required TP |
| Paralyzed using an ability, or silenced casting | Uses a Remedy instead, if `AutoItem` is on |

### Resource warnings

- **Ranged ammo** — counts your ammo across inventory and all eight wardrobes on precast. Warns below `Ammo_Warning_Limit`, and cancels the action at zero with a message naming what is missing.
- **Ninja tools** — warns when Shihei or Shikanofuda drops below 10, and echoes the warning to your other characters.

### Automatic gear rules

- **Weather and day bonus** — on elemental magic, equips Hachirin-no-Obi, Orpheus's Sash, Chatoyant Staff or Twilight Cape when day, weather or target distance makes them worthwhile. Only if you actually own the item. Twilight Cape is restricted to Cura and Curaga, so single-target cures keep whatever back piece your set specifies.
- **Required equipment** — Dispelga equips Daybreak, Honor March equips Marsyas, Aria of Passion equips Loughnashade, Impact equips Crepuscular Cloak or Twilight Cloak.
- **Two-handed detection** — inspects your WeaponMode weapon and sets the two-hand flag, which suppresses sub-slot swaps.

### Status ailment responses

| Ailment | Response |
|---|---|
| **Sleep** | Equips idle + `sets.Weapons.Sleep`, locks main and ranged, cancels Stoneskin so you can be woken |
| **Doom** | Equips and locks `sets.Cursna_Received`; uses Holy Water if `AutoItem` is on, warns if you have none |
| **Silence** (mage jobs) | Uses a Remedy if `AutoItem` is on |
| **Paralysis** | Uses a Remedy if `AutoItem` is on |
| **Petrification / Stun** | Re-evaluates and re-equips your correct set |

Sleep and Doom locks are released automatically when the status wears off.

---

## 11. Action and Spell Tracking

### Treasure Hunter tracking

The engine keeps a list of monsters you have already tagged, so `Tag` mode can drop TH gear and return to full damage once the tag lands. Entries are added when you act on a monster, removed when it dies, expired after 3 minutes of no activity, and cleared entirely on zone.

### Skillchain and magic burst tracking

The engine watches every skillchain that happens on your target — including ones made by other players. When one closes it records the elements and opens an 8-second burst window. Nukes cast into that window with a matching element use `sets.Midcast.Burst` instead of `sets.Midcast.Nuke`.

Radiance and Umbra skillchains are recognized. A weaponskill that closes the window clears it.

### Spell-received tracking (multibox)

For players running several characters at once. When one of your characters begins casting a supported spell, it broadcasts over Windower's IPC channel. Any of your other characters targeted by that spell equips its "received" gear immediately — at pretarget and precast, before the spell lands.

**Supported spells:** Cure I–VI · Curaga I–V · Cura I–III · Cursna · Phalanx I–II · Protect I–V · Protectra I–V · Shell I–V · Shellra I–V · Regen I–V · Refresh I–III

**Supported abilities:** Curing Waltz I–V · Divine Waltz I–II

The engine also predicts area-of-effect coverage, so `-ga` and `-ra` spells, Accession, Divine Veil and Majesty reach every affected character rather than only the direct target.

A failsafe timer releases any locked gear if a completion message never arrives, so you cannot get stuck wearing cure-potency gear in a fight. The delay is configurable in `data/settings.xml` as `delay` (default 3 seconds).

---

## 12. Customization Hooks

The engine builds a gear set, then calls your function and merges whatever you return. Define only the hooks you need — the engine will tell you which are missing when `warn` is on.

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

### Auto-buff hooks

Return the **name** of an ability or spell to use, or `'None'`.

```lua
function check_buff_JA()
    local buff = 'None'
    if os.clock() - buff_time > Buff_Delay then          -- throttle the recast lookup
        local ja_recasts = windower.ffxi.get_ability_recasts()
        if not buffactive['Berserk'] and ja_recasts[1] == 0 then
            buff = "Berserk"
        end
        if buff ~= 'None' then buff_time = os.clock() end
    end
    return buff
end

function check_buff_SP()
    local buff = 'None'
    return buff
end
```

`check_buff_SP` is only called while you are standing still, so movement is not interrupted by casting.

### Pet hooks

| Function | Called |
|---|---|
| `pet_change_custom(pet, gain)` | Pet summoned or dismissed |
| `pet_midcast_custom(spell)` | Pet action midcast |
| `pet_aftercast_custom(spell)` | Pet action complete |

### Other hooks

| Function | Called |
|---|---|
| `self_command_custom(command)` | Any `gs c` command the engine did not recognize — add your own |
| `sub_job_change_custom()` | Subjob changed |
| `Cycle_Timer()` | Every 2 seconds, for periodic work |
| `user_file_unload()` | Job file unloading — clean up anything you created |

`Cycle_Timer` is useful for time-of-day gear:

```lua
function Cycle_Timer()
    if world.time >= 17*60 or world.time <= 7*60 then
        sets.Movement = set_combine(sets.Movement, sets.Movement.Night)
    else
        sets.Movement = set_combine(sets.Movement, sets.Movement.Day)
    end
end
```

### Startup

Call this once, outside `get_sets()`, to apply your lockstyle, macro book and keybinds:

```lua
jobsetup(LockStylePallet, MacroBook, MacroSet)
```

---

## 13. Troubleshooting

### A set warning in chat

Two messages mean a cast reached for gear and found none:

```
[sets.Midcast.Cure] not found!  Use gs c gearreporting to trace fallback pattern.
[sets.Midcast.Regen] is empty!  Use gs c gearreporting to trace fallback pattern.
```

**"not found!"** means your job file never declared that set. If the spell should have its own gear, add it in `get_sets()`. If it should not, nothing is wrong — the cast used a more general set instead, and `gs c gearreporting` will show you which one.

**"is empty!"** means you declared the set but it holds no gear. This is the one that usually indicates a mistake, and the most common cause is building a set from a parent that is itself empty:

```lua
sets.Midcast.Enhancing = {}                                    -- nothing in here
sets.Midcast.Aquaveil = set_combine(sets.Midcast.Enhancing, {}) -- so nothing here either
```

Run **`gs c checksets`** to see every such set in one list. To silence a set you deliberately leave bare, delete the declaration rather than emptying it — an undeclared set merges silently, an empty declared one is reported.

A third message, `Chosen set is [Empty]`, means no set at all produced gear for your current state. It repeats at most once every 30 seconds.

`//gs c warn` turns these off entirely.

### Gear is not swapping

1. `//gs c debug` and watch the debug box.
2. If `is_Busy` is stuck on, an action never reported completion — it clears itself within a couple of seconds.
3. If `is_Moving` is stuck on, you may be on a mount or in an area where position updates are unreliable.
4. `//gs c enableall` releases every locked slot.
5. `//gs c update auto` forces a re-evaluation.

### A slot is stuck

Some features deliberately lock slots — Sleep locks main and ranged, Doom locks your Cursna set, `SpellReceived ON` locks the received set, and either Hoxne mode holds range and ammo. Use `//gs c enablebymode` to release what the current mode allows, or `//gs c enableall` to release everything.

`//gs c enableall` is a manual override, so it releases range and ammo even while a Hoxne mode is on. The mode notices within a second and takes them back. If you want them free, switch Hoxne to `OFF`.

If the Hoxne Ampulla is sitting in your ammo slot after a reload, wait a few seconds — the engine detects a stranded Ampulla shortly after loading and puts your normal gear back on its own. `//gs c hoxneinfo` shows what it is doing.

### An item is not equipping

The engine can only equip items you own. Check spelling exactly as the item appears in game, and confirm it is in inventory or a wardrobe — not in storage, a satchel or a sack.

### An enchanted item is not being used

`gs c use` names the reason it stopped, so read the chat line first — it will tell you whether the item is missing, unusable by your job, or on cooldown. If it printed `Equipping and using [...]` and then nothing happened, run `gs c enchinfo <item>` and check the `-> engine sees:` line described under [Diagnostics](#diagnostics).

A few things are worth knowing:

- **The first use after equipping always takes a few seconds.** Enchanted gear has to be worn for its equip delay before the game will accept a use, and the server wants a little more than the delay the wiki lists.
- **Timings restart every time the item is re-equipped**, so anything that swaps that slot mid-wait starts the clock again.
- **A song or Geomancy cast clears your ammo slot.** If you are running Hoxne `ON-Allow Critical`, that is why the Ampulla disappears during a song and returns afterwards.

### A bard song or Geomancy spell fails with a command error

Check whether Hoxne is set to `ON-Locked`. Honor March and Aria of Passion can only be cast while Marsyas or Loughnashade is equipped, and Geomancy needs a handbell, so a mode that blocks the range slot blocks those actions before GearSwap ever sees them. Switch to `ON-Allow Critical`, which stands aside for exactly these cases.

### The display box is gone

`//gs c zero` moves it back to the top-left corner. If it is hidden rather than lost, `//gs c display`.

### Settings are not saving

Saving is skipped while zoning. Wait until you are fully loaded, then `//gs c save`. Settings live in `Windower4/addons/GearSwap/data/settings.xml`, under a node named for your character.

Dragging a box saves silently, so no chat message on release is normal — confirm by checking the `pos` values in `settings.xml`, or reload GearSwap and see whether the box returns to where you dropped it.

### The status box shows blank squares or the columns are ragged

The box uses circle and triangle characters that exist in Consolas, Lucida Console and Courier New. If you have changed `font` in `settings.xml` to a font lacking them, Windows substitutes a glyph from another font at a different width, which knocks the columns out of alignment. Switch back to a monospaced font that covers them.

### Auto-buff is not working

Check that AutoBuff is `ON` in the status box, that you are not in a town, and that your job file's `check_buff_JA` / `check_buff_SP` actually return an ability name. AutoBuff switches itself off when you zone.

### Nothing loads at all

Confirm `Mirdain-Include.lua` is in `GearSwap/libs/` and your job file is in `GearSwap/data/`. Then `//gs reload` and watch for errors in the Windower console.

---

## Credits

Original concept and engine by **Mirdain**. This enhanced revision conceived and programmed by **Rahvin**.

Contributions and issue reports welcome via the Silmaril or Vinland discords.  IYKYK.
