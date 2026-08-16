# Patch Notes

Release-by-release detail for Mirdain-Include Enhanced by Rahvin.

The [README](README.md) describes what the engine does **now**. This file records
**what changed and when**, newest first, and keeps every release. Check your running
version in game with `//gs c version`.

Each release is broken into the same four headings, so you can scan for what matters:

- **Notices** — changes that need something from you before they take effect.
- **New and Changed Features** — what the release adds or does differently.
- **Optimizations** — the same behaviour, cheaper.
- **Bug Fixes** — things that now work as intended.

A heading is omitted when a release has nothing under it.

**Credits.** Mirdain-Include was created by **Mirdain**; version 1.5.12 is the original
and the base this suite was forked from. Everything from **1.6.0** forward — engine
revisions and sample job files alike — was conceived and programmed by **Rahvin**.

| Version | Summary |
|---|---|
| [1.7.1](#171) | Per-action gear reporting and warning throttle; status box redesign; the HP-priority gear library |
| [1.7.0](#170) | Thrown-item job abilities; cancel and override for item use; reload recovery; `gs c enchinfo` and `gs c hoxneinfo` |
| [1.6.6](#166) | Enchanted item engine rebuilt around live cooldowns; Hoxne split into two on states |
| [1.6.5](#165) | Status box rebuild; mode arguments validated; SpellReceived reduced to OFF/ON |
| [1.6.4](#164) | 196 blue magic spells classified; item-search bag list corrected |
| [1.6.0 – 1.6.3](#160--163) | The initial enhancement work over Mirdain 1.5.x |
| [1.5.12](#1512) | Mirdain's original |

---

## 1.7.1

Know what your gear sets are doing. Every action names the set it wore, in one
consistent format, and the warnings that tell you a set is empty stay readable through a
long fight.  GearSets-Include.lua introduces a full library of HP, MP and rank prioritized gear to be used 
for automatic hp-saving ordering of gear swaps for any set, any action.  You will save hundreds of hp per
cast by not accidentally dropping your Max HP for no reason.

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

The full write-up is [Performance Impact Report.md](Performance%20Impact%20Report.md).

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
Mirdain for the original concept and scaffolding. It is kept in the repository as a
reference copy for performance comparison.
