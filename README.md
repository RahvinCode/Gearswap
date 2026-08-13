# Mirdain-Include Enhanced

**Version 1.6.4** · A GearSwap engine for Final Fantasy XI (Windower 4)

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

**Status box** — always available, shows your current modes:

```
TH:[None] Spell-Rec:[ON-Locked] Hoxne:[OFF] Stance:[DT] DPS:[Chango]
```

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

Drag either box with the left mouse button. The position saves to disk automatically when you release. You can also save manually with `//gs c save`, reset a lost box to the top-left corner with `//gs c zero`, hide the status box with `//gs c display`, and switch between one-line and stacked layouts with `//gs c displaymode`.

> Saving is skipped while you are zoning. If you see *"Cannot save while zoning"*, wait a moment and try again.

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
| <kbd>Ctrl</kbd>+<kbd>F10</kbd> | Cycle **Hoxne** |
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

When on, the engine checks roughly ten times a second whether you are missing a buff it can reapply, and uses it. Disabled in towns, and while asleep, stunned, terrorized, paralyzed, silenced or muddled.  This is leftover from development prior to the use of other automation tools.  Usable if manually single boxing.  Leave off if using other automation software.

- **Options:** `OFF` `ON`
- **Command:** `//gs c AutoBuff ON`
- Automatically switched **off** when you zone.
- What gets buffed is defined by you — see [`check_buff_JA` / `check_buff_SP`](#12-customization-hooks).

### SpellReceived — multibox spell-received gear

For players running more than one character. When another of your characters casts a supported spell on you, this character equips its "received" gear *before the spell lands* — even through Quick Magic.

| Mode | Behavior |
|---|---|
| `ON-Locked` | Equip received gear and lock those slots until the spell resolves *(recommended)* |
| `ON-Unlocked` | Equip received gear but allow other actions to overwrite it |
| `OFF` | Disabled |

**Command:** `//gs c SpellReceived ON-Locked`

Requires the corresponding `*_Received` sets. See [Spell-Received Tracking](#spell-received-tracking-multibox).

### Hoxne — Hoxne Ampulla lock

Locks Hoxne Ampulla into your ammo slot and stops the engine from unlocking it. Persists through zoning. You must still use the item manually to gain the buff.

- **Options:** `OFF` `ON`
- **Command:** `//gs c hoxne`
- Will refuse to turn on if the item is not in your inventory or wardrobes.

### JobMode and JobMode2 — your own switches

Two free-form modes for anything a job needs. The engine only tracks the value; what it means is up to your job file.

```lua
UI_Name  = 'Tank'          -- label shown in the status box
state.JobMode:options('OFF','Auto Tank')

UI_Name2 = 'Rune'
state.JobMode2:options('Ignis','Gelus','Flabra')
```

**Commands:** `//gs c JobMode "Auto Tank"` · `//gs c JobMode2 Ignis`

If `UI_Name` is left empty the mode is hidden from the status box.

### RAMode — ranged ammunition type

Selects which ammo table the engine reads: `Bullet`, `Arrow` or `Bolt`. Defaults to `Bullet`. See [Ammunition](#ammunition).

---

## 7. Commands

All commands are typed as `//gs c <command>` and are **case-insensitive**.

### Modes

| Command | Description |
|---|---|
| `gs c OffenseMode [mode]` | Cycle, or jump to a specific mode |
| `gs c WeaponMode [mode]` | Cycle, or jump to a specific weapon set |
| `gs c TreasureHunter [mode]` | Cycle, or jump to a TH mode |
| `gs c AutoBuff [mode]` | Cycle, or set auto-buffing |
| `gs c SpellReceived [mode]` | Cycle, or set spell-received tracking |
| `gs c hoxne [on\|off]` | Toggle or set Hoxne Ampulla lock |
| `gs c JobMode [mode]` | Cycle, or jump to a job-specific mode |
| `gs c JobMode2 [mode]` | Cycle, or jump to a second job-specific mode |

Quote any value containing a space: `//gs c WeaponMode "Savage Blade"`

### Display

| Command | Description |
|---|---|
| `gs c display` | Show/hide the status box |
| `gs c displaymode` | Toggle one-line vs. stacked layout |
| `gs c zero` | Move the status box to the top-left corner and save |
| `gs c save` | Save current settings to disk |
| `gs c debug` | Toggle the debug box and verbose logging |
| `gs c info` | Toggle informational messages (skillchains, set changes) |
| `gs c warn` | Toggle missing-gear-set warnings |

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

### Items

| Command | Description |
|---|---|
| `gs c food` | Use the item named in your `Food` variable |
| `gs c use <item>` | Use any enchanted item; auto-detects slot and cast time |
| `gs c temps` | Use the six Escha temporary drinks in sequence |
| `gs c warp` | Use Warp Ring |
| `gs c warp club` | Use Warp Cudgel |
| `gs c holla` | Use Dim. Ring (Holla) |
| `gs c dem` | Use Dim. Ring (Dem) |
| `gs c mea` | Use Dim. Ring (Mea) |
| `gs c cp` | Use Trizek Ring |

### Other

| Command | Description |
|---|---|
| `gs c version` | Print the include version |
| `gs c shutdown` | Terminate the game client |
| `gs c profile <name>` | Load a Silmaril profile script for your job/subjob/character |

You can add your own commands with [`self_command_custom`](#12-customization-hooks).

---

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
| `UI_Name` | string | `''` | Status box label for JobMode; empty hides it |
| `UI_Name2` | string | `''` | Status box label for JobMode2; empty hides it |

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

Every set below is pre-created as an empty table by the engine, so you only fill in the ones you use. If the engine needs a set you have not defined, it prints a warning naming the exact set — turn these on with `//gs c warn` while building your file.

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

- **Weather and day bonus** — on elemental magic, equips Hachirin-no-Obi, Orpheus's Sash, Chatoyant Staff or Twilight Cape when day, weather or target distance makes them worthwhile. Only if you actually own the item.
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

### "sets.X not found!" in chat

Exactly what it says — the engine wanted a set you have not defined. Add it to `get_sets()`, even as an empty table:

```lua
sets.Weapons.Sleep = {}
```

Silence these with `//gs c warn` once your file is finished.

### Gear is not swapping

1. `//gs c debug` and watch the debug box.
2. If `is_Busy` is stuck on, an action never reported completion — it clears itself within a couple of seconds.
3. If `is_Moving` is stuck on, you may be on a mount or in an area where position updates are unreliable.
4. `//gs c enableall` releases every locked slot.
5. `//gs c update auto` forces a re-evaluation.

### A slot is stuck

Some features deliberately lock slots — Sleep locks main and ranged, Doom locks your Cursna set, `SpellReceived ON-Locked` locks the received set, Hoxne mode locks ammo. Use `//gs c enablebymode` to release what the current mode allows, or `//gs c enableall` to release everything.

### An item is not equipping

The engine can only equip items you own. Check spelling exactly as the item appears in game, and confirm it is in inventory or a wardrobe — not in storage, a satchel or a sack.

### The display box is gone

`//gs c zero` moves it back to the top-left corner. If it is hidden rather than lost, `//gs c display`.

### Settings are not saving

Saving is skipped while zoning. Wait until you are fully loaded, then `//gs c save`. Settings live in `Windower4/addons/GearSwap/data/settings.xml`.

### Auto-buff is not working

Check that AutoBuff is `ON` in the status box, that you are not in a town, and that your job file's `check_buff_JA` / `check_buff_SP` actually return an ability name. AutoBuff switches itself off when you zone.

### Nothing loads at all

Confirm `Mirdain-Include.lua` is in `GearSwap/libs/` and your job file is in `GearSwap/data/`. Then `//gs reload` and watch for errors in the Windower console.

---

## Credits

Original concept and engine by **Mirdain**. This enhanced revision conceived and programmed by **Rahvin**.

Contributions and issue reports welcome via the Silmaril or Vinland discords.  IYKYK.
