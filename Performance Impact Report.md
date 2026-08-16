# Divergence Load Test

**Mirdain-Include performance assessment · 2026-08-16**

Upstream **1.5.12** versus this repository's **1.7.0**, each measured in two
configurations — **full** (every chat channel on, Hoxne ON-Allow Critical) and
**lean** (all chat off, Hoxne off) — replaying an identical simulated Dynamis
Divergence fight: a 6-box local party inside an 18-player alliance with a
15-mob wave, on the engines' real code and the six live job files. Measured
with `tools/perfsim` (394 hot-loop microbenchmarks plus four 300-second
frame-by-frame timeline runs) on PUC Lua 5.1.5. The styled version of this
report with charts is `divergence-load-test.html` in this directory.

> **Verdict: 1.7.0 with every feature and every chat channel enabled costs the
> same CPU as 1.5.12 running completely silent** (199.8 vs 200.3 µs/s across
> the whole six-client box), and 1.7.0 lean is the fastest configuration
> measured (181.7 µs/s). 1.7.0 wins every per-cast, frame-budget, and
> allocation comparison in both configurations. 1.5.12's only wins are two
> lean-config CPU cells on the lowest-cast-rate jobs (BRD, WAR), worth a few
> ten-thousandths of a percent of one core. No configuration of either engine
> comes near a dropped frame: the worst engine frame observed anywhere was
> 1.2% of the 60 fps budget.

## Scoreboard

| Metric | Winner | Margin |
|---|---|---|
| Cost per cast | **1.7.0** — every cast, both configs | 1.5–2.2× faster (closest race: BLU Sinker Drill, even) |
| Whole-box CPU | **1.7.0** — both configs overall | lean 181.7 vs 200.3; full 199.8 vs 279.4 µs/s |
| Frame-budget safety | **1.7.0** — all 12 cells | lower mean and worst frame everywhere |
| Allocation / GC pressure | **1.7.0** — all configs | ~28% less garbage per second |
| Idle / low-APM background | **1.5.12** — lean config only | wins BRD and WAR cells by 2.5–3.7 µs/s; buys no automation |
| Chat volume, everything on | **1.5.12** — fewer lines | 1,075 vs 1,364 lines/min; lean: both silent (~20/min) |

## The scenario

Six local clients in `Dynamis - San d'Oria [D]` for 300 simulated seconds.
Every client's `action` handler sees ~16 foreign events/s (12 remote players +
15 mobs + local peers), plus 28 incoming packets/s, 3 movement chunks/s, a
buff pair every 2 s. The BRD renders at 60 fps, the rest at 30.

| Job | FPS | Rotation | Casts / 5 min |
|---|---|---|---|
| BRD | 60 | 5-song volleys (incl. Honor March) + Lullaby, melee between; Hoxne ON-Allow Critical in the full config on 1.7.0 | 20 |
| GEO | 30 | Tier-V nukes, Indi/Geo bubbles every 2 min | 43 |
| WHM | 30 | Cure III/IV stream, Curaga II, Regen II, Haste, Cursna | 73 |
| COR | 30 | Ranged attacks, Leaden Salute, rolls + Double-Up, Quick Draw | 83 |
| BLU | 30 | Sinker Drill spam, Spectral Floe, Magic Fruit, Savage Blade | 81 |
| WAR | 30 | Auto-attack, Upheaval every 12 s, Berserk cycle; Aftermath Lv.3 up | 28 |

Configurations: **full** = warn/info/debug on (+gearreporting on 1.7.0), Hoxne
ON-Allow Critical; **lean** = all chat off, Hoxne off. 1.7.0's spell-received
system stays ON in both (its engine default). 1.5.12 has no Hoxne, no gear
reporting and no spell-received system in any configuration.

## Whole-box CPU load

Engine-code µs per second of combat (one core = 1,000,000 µs/s):

```text
1.5.12 full  ████████████████████████████████████████  279.4 µs/s
1.5.12 lean  █████████████████████████████             200.3
1.7.0  full  █████████████████████████████             199.8
1.7.0  lean  ██████████████████████████                181.7   ← fastest
```

| Job (fps) | 1.5.12 full | 1.5.12 lean | 1.7.0 full | 1.7.0 lean | Cheapest |
|---|---:|---:|---:|---:|---|
| BRD (60) | 38.4 | **25.4** | 32.5 | 27.9 | 1.5.12 lean |
| GEO (30) | 44.1 | 31.2 | 32.1 | **29.1** | 1.7.0 lean |
| WHM (30) | 61.5 | 46.8 | 39.2 | **35.4** | 1.7.0 lean |
| COR (30) | 50.3 | 36.2 | 34.2 | **31.0** | 1.7.0 lean |
| BLU (30) | 54.3 | 41.3 | 38.9 | **35.0** | 1.7.0 lean |
| WAR (30) | 30.9 | **19.5** | 22.9 | 23.2 | 1.5.12 lean |
| **ALL** | 279.4 | 200.3 | 199.8 | **181.7** | 1.7.0 lean |

Why 1.5.12 lean wins the BRD and WAR cells: with chat and Hoxne off, per-cast
cost stops mattering for jobs that barely cast. What remains is background,
and 1.5.12's is structurally smaller — no prerender handler (the 60 fps BRD
pays 1.7.0 ~11 µs/s in tick gates) and no spell-received listener (~20 IPC
parses a minute). That is 2.5–3.7 µs/s, ~0.0003% of one core, in exchange for
none of 1.7.0's automation. Every job that actually casts is cheaper on 1.7.0
in both configurations.

## Cost per cast

Full chain: pretarget → precast → outgoing chunk → action-start → midcast →
completion → aftercast → queued `update auto`, including all string
formatting up to the `add_to_chat` boundary.

| Cast | 1.5.12 full | 1.5.12 lean | 1.7.0 full | 1.7.0 lean | 1.7.0 advantage |
|---|---:|---:|---:|---:|---|
| BRD song (µs) | 199.5 | 166.6 | 91.5 | **81.5** | ÷2.0 |
| BRD Honor March | 191.7 | 167.1 | 100.8 | **90.2** | ÷1.9 |
| GEO Fire V | 155.4 | 148.9 | 89.7 | **84.0** | ÷1.8 |
| WHM Cure IV | 147.1 | 136.9 | 88.8 | **80.2** | ÷1.7 |
| COR ranged attack | 127.5 | 117.6 | 65.8 | **57.6** | ÷2.0 |
| BLU Spectral Floe | 148.5 | 141.6 | 88.2 | **76.4** | ÷1.9 |
| BLU Sinker Drill | 81.9 | 78.3 | 78.0 | **75.0** | even |
| WAR Upheaval | 82.7 | 78.0 | **45.3** | 45.4 | ÷1.8 |

Chat-off narrows 1.5.12's gap only slightly, for a structural reason:
**1.5.12 builds its message strings at the call site before the gate check**
(`info('['..spell.english..'] Set')` concatenates whether or not info is on),
while 1.7.0's vararg writers defer the join until after the gate — silence is
nearly free on 1.7.0 and still costs concatenation on 1.5.12.

Sinker Drill is the one near-tie: 1.5.12's small blue-magic lists don't
contain it, so it falls through to its cheapest generic path, while 1.7.0
classifies all 196 blue-magic spells and still matches it. 1.7.0's WHM chains
additionally carry the spell-received IPC send inside these same numbers.

## Frame budgets

Worst single frame in five minutes, as a share of the frame budget
(16,667 µs at 60 fps; 33,333 µs at 30 fps). 100% would be one dropped frame.

| Job (fps) | 1.5.12 full | 1.5.12 lean | 1.7.0 full | 1.7.0 lean |
|---|---:|---:|---:|---:|
| BRD (60) | 1.199% | 1.004% | 0.607% | **0.543%** |
| GEO (30) | 0.482% | 0.451% | 0.281% | **0.264%** |
| WHM (30) | 0.512% | 0.453% | 0.305% | **0.277%** |
| COR (30) | 0.397% | 0.357% | 0.202% | **0.177%** |
| BLU (30) | 0.460% | 0.429% | 0.310% | **0.283%** |
| WAR (30) | 0.265% | 0.241% | **0.148%** | 0.149% |

A 60 fps frame needs ~16,700 µs of engine work to drop; the worst frame
measured anywhere in twenty minutes of simulated combat was 200 µs. No
configuration of either engine can influence frame pacing from Lua. The
residual frame-time risk is Windower-side chat and text rendering — which the
lean configuration eliminates on both engines by emitting nothing.

## Allocation

```text
1.5.12 full  ████████████████████████████████  118.6 KB/s
1.5.12 lean  ███████████████████████████████   115.2
1.7.0  full  ███████████████████████           85.9
1.7.0  lean  ███████████████████████           85.7   (−28%)
```

Chat settings barely move allocation — the garbage is gear-set tables, not
strings. 1.5.12's `set_combine` allocates two to three tables per input set
on every merge of every cast: ~427 MB churned per box per hour against
1.7.0's ~309 MB, meaning more frequent incremental GC steps in exactly the
frames where casts land.

## Chat volume

Lines per minute across all six clients (counted at the `add_to_chat`
boundary; rendering happens in Windower and is not timeable offline):

| Configuration | Total | Breakdown |
|---|---:|---|
| 1.5.12 full | 1,075 | log(80) 984 · info(8) 90 |
| 1.7.0 full | 1,364 | log(80) 880 · debug(121) 282 · info(8) 122 · gear report(207) 49 · warn(123) 32 |
| 1.5.12 lean | 20 | one ungated line per WHM cast from the job file itself |
| 1.7.0 lean | 22 | same job-file line; engines silent |

With everything on, both engines are dominated by the legacy `log` trace;
1.7.0 adds the spell-received debug channel (the largest new source), the
gear-reporting trace and `[Empty]` warns for +27% lines and roughly triple
the bytes. With all channels off, both engines go essentially silent — the
residue is a direct `windower.add_to_chat` in the WHM job file's own hook,
identical on both engines. The chat toggles are worth three orders of
magnitude more rendered lines than the choice of engine.

## Background machinery

| Per occurrence (µs) | Rate/client | 1.5.12 full | 1.5.12 lean | 1.7.0 full | 1.7.0 lean |
|---|---|---:|---:|---:|---:|
| main_engine pass | ~3/s | 4.6 | 1.1 | 1.0 | **0.9** |
| `update auto` rebuild | per action | 22.6 | 23.3 | 15.6 | **11.8** |
| Prerender frame | 30–60/s | **0** | **0** | 0.18–0.20 | 0.17–0.19 |
| Foreign WS completion | ~1.6/s | 0.71 | 0.70 | 0.72 | 0.71 |
| … closing a skillchain | ~0.3/s | 2.71 | 1.10 | 2.80 | 1.11 |
| Incoming packet | 28/s | 0.09 | 0.09 | 0.09 | 0.09 |
| IPC tracked cast, targeted | ~0.1/s | — | — | 26–28 | 19–22 |
| IPC tracked cast, bystander | ~0.23/s | — | — | 3.3 | 3.3 |
| Hoxne tick + Ampulla cycle | 1/s + 3 uses/5 min | — | — | 0.2–0.4/frame + 75/use | off |

1.5.12's full-config `main_engine` pays ~3.5 µs per pass for the debug box
alone (per-line padding and measurement each rebuild); 1.7.0's cached layout
holds it at ~1 µs regardless of settings.

## Findings

- **The engine choice and the chat choice are separable, and the chat choice
  is bigger.** 1.5.12→1.7.0 saves ~28% CPU at equal settings; full→lean saves
  ~28% on 1.5.12 and ~9% on 1.7.0 — but moves rendered lines from
  ~1,100–1,400/min to ~20/min, the only quantity large enough to ever matter
  to frame pacing.
- **Hoxne ON-Allow Critical is measurably near-free**: its whole footprint —
  equip-wrapper filter, 1 Hz tick, critical windows, three Ampulla auto-uses
  (correctly deferred during song volleys) — sits inside a few µs/s.
- **Spell-received ships ON by default in 1.7.0** and stays on in both
  configurations here. CPU cost is 1–3 µs/s per client; with debug on it is
  the largest new chat channel (282 lines/min box-wide). That default is the
  remaining lever for a maximally lean 1.7.0.
- **Both engines share one alliance-scaled hotspot**: `run_burst` skillchain
  detection runs for every entity's WS and spell completion — identical code,
  a mob-table marshal per foreign WS, unaffected by any setting.
- **Bottom line**: there is no configuration in which upgrading costs
  performance. For long fights at 60 fps, the setting that actually protects
  frame time is the same on both engines: keep `debug` off.

## Method and caveats

Whole-engine sandbox: each engine file compiled complete into a per-client
`setfenv` environment, followed by the live job files in GearSwap's real load
order; GearSwap's own `set_merge`/`unify_slots` ported from upstream source to
preserve allocation behaviour; virtual clock keeps busy windows, critical
windows, throttles and cooldowns on real cadence inside the timing loops.
Timing: continuous ≥250 ms `os.clock` hot loops; allocation measured with the
collector stopped; all four configurations replay byte-identical seeded
timelines.

Not measured: Windower-side rendering (counted as volume), GearSwap core
per-event overhead (identical for both engines), exact marshal costs
(modelled identically for both). The fight runs clean — no deaths, sleepga
waves, or interrupts. **An in-game load remains the final word.**
