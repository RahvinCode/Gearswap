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
Mirdain for the original concept and scaffolding. It is kept in the repository as a
reference copy for performance comparison.
