# Game Design Document — Working Title: **"Clutch Tavern"**

*Multiplayer roguelike auto-battler with synchronized skill challenges*
Version 0.1 (concept / pre-production) · Status: Draft for critique

---

## 0. Executive Summary & Design Pillars

**Pitch:** An 8-player auto-battler in the vein of Hearthstone Battlegrounds where you recruit units, build synergies, and fight increasingly difficult encounters. Every few rounds, all players simultaneously face the *same* short skill challenge (clicking, memory, pattern, timing, reaction). Performance converts into strategic rewards — choices, not raw power.

**Pillars**
1. **Strategy decides the game; skill tilts it.** Challenges must never outweigh drafting/positioning decisions. Target: a perfect challenge player with a mediocre build should lose to a strong build with average challenge play.
2. **Same test, fair test.** Identical seed, identical content, normalized scoring, server-validated.
3. **Short, punchy, legible.** Challenges are 8–15 seconds, learnable in one viewing, and readable at a glance.
4. **Every run tells a story.** Roguelike variance in units, events, and bosses.

### ⚠️ Critical framing issue up front
The concept mixes two audiences: **auto-battler players** (slow, cerebral, often play on mobile / second monitor / while relaxed) and **dexterity players** (APM, reflexes). Dropping twitch tests into a strategy game risks alienating the core audience *and* not satisfying action players. The entire design below is built around **containing** challenge impact (capped, percentile-based, choice-based rewards) rather than letting it dominate. If playtests show players hate the interruptions, the fallback is making challenges **opt-in wagers** (see §6.7).

### Another ambiguity: PvP or PvE?
"Progress through increasingly difficult encounters" (PvE roguelike) conflicts with "inspired by Hearthstone Battlegrounds" (8-player PvP elimination). **Recommendation: hybrid** — PvP lobby as the backbone, with PvE "Encounter" rounds (creeps / bosses) every few turns that scale in difficulty. This gives the roguelike escalation without losing the social competition. Alternatives are discussed in §2.5.

---

## 1. Core Gameplay Loop

### 1.1 Moment-to-moment loop (one round, ~60–90 s)
```
 ┌──────────────┐   ┌───────────────┐   ┌──────────────┐   ┌──────────────┐
 │ RECRUIT      │ → │ POSITION      │ → │ COMBAT       │ → │ RESOLVE      │
 │ buy/sell/    │   │ arrange board │   │ auto-resolved│   │ damage, gold,│
 │ reroll/level │   │ (7 slots)     │   │ vs opponent  │   │ HP, rewards  │
 └──────────────┘   └───────────────┘   └──────────────┘   └──────┬───────┘
        ▲                                                         │
        └──────────── (every 3rd round: SKILL CHALLENGE) ◄────────┘
```

### 1.2 Run loop (one match, ~25–35 min)
Lobby → pick Commander (hero) → ~14–18 rounds of Recruit/Combat → challenges every ~3 rounds → PvE Encounter rounds every ~4 rounds → elimination by HP → final placement → meta rewards.

### 1.3 Meta loop (between runs)
Placement + challenge performance → XP / currency → unlock Commanders, cosmetics, challenge variants, ranked tiers → queue again.

### 1.4 Critique: where should the challenge sit in the loop?
| Option | Pros | Cons | Verdict |
|---|---|---|---|
| **A. Separate phase between rounds** (everyone pauses) | Clean, fair, focused | Adds 15–20 s dead time per occurrence; breaks flow | ✅ **Recommended**, but only every 3rd round and ≤15 s |
| B. During the Recruit phase (steals shop time) | No extra match length | Forces trade-off between thinking and clicking; punishes slow deciders; feels bad | ❌ Avoid — creates a hidden APM tax |
| C. During combat (combat is passive anyway) | Uses "dead" spectating time | Players miss seeing their combat — key learning moment in auto-battlers | ⚠️ Viable as a *variant* only if combat replay is available |

Recommended: **Option A**, with combat replays allowing Option C experiments later.

---

## 2. Run Structure

### 2.1 Match parameters (starting values — tune in playtest)
| Parameter | Value |
|---|---|
| Players per lobby | 8 (also support 4-player "Quick" mode) |
| Starting HP | 40 |
| Board slots | 7 |
| Shop tiers | 6 |
| Recruit timer | 45 s rising to 75 s by late game |
| Challenge frequency | Rounds 3, 6, 9, 12, 15 (5 per run max) |
| PvE Encounter rounds | Rounds 4, 8, 12, 16 |

### 2.2 Phases of a run
| Phase | Rounds | Focus | Challenge style |
|---|---|---|---|
| **Early (Tavern)** | 1–5 | Economy, tempo, establishing a tribe | Easy, tutorial-like (Reaction, Rapid Click) |
| **Mid (Road)** | 6–10 | Committing to synergies, leveling shop | Medium (Memory, Pattern) |
| **Late (Siege)** | 11+ | Scaling, positioning, final boss | Hard / combined (Timing + Pattern) |

### 2.3 PvE Encounter rounds
- Every 4th round you fight an AI-controlled encounter instead of a player. Encounters are **identical for all players** (same seed), scale per round, and come from a curated pool (e.g., "Goblin Warband", "Lich Choir", "Siege Golem").
- Winning grants loot (a unit, a trinket, or gold). Losing deals **reduced** HP damage (half) — PvE losses should sting but not eliminate.
- **Final Boss** (round ~16 or when 3 players remain): optional twist — survivors see each other's boss result, adding drama.

### 2.4 Run variance (roguelike layer)
- **Commander** (hero) with a passive or activatable power.
- **Lobby Modifiers**: 1 random global rule per match (e.g., "Rerolls cost 0 on challenge rounds", "Tier 3 units have +1/+1").
- **Tribe pool rotation**: 5 of ~8 tribes per lobby (as Battlegrounds does) — prevents solved metas.
- **Events**: occasional "Crossroads" choice cards (take 1 of 3 blessings/curses).

### 2.5 Alternatives considered
| Model | Description | Critique |
|---|---|---|
| Pure PvP elimination (BG clone) | 8 players, last one standing | Proven, but "increasingly difficult encounters" is just "opponents get stronger"; little roguelike identity; heavy IP-likeness risk |
| Pure PvE roguelike with leaderboard | Everyone runs the same seeded dungeon; compare scores | Easiest to build (async, no matchmaking), great for daily challenges; loses head-to-head drama |
| **Hybrid (recommended)** | PvP backbone + shared PvE encounters + shared challenges | More content, more complexity, but the most distinctive |

**Strong suggestion:** build the **Pure PvE seeded "Daily Run"** first as the vertical slice. It exercises units, economy, challenges, and determinism without netcode or matchmaking risk. Add PvP after.

---

## 3. Meta Progression

### 3.1 Principles
- **Horizontal, not vertical.** Meta unlocks add *options* (Commanders, cosmetics, challenge skins) — never raw stat bonuses. Vertical power in a competitive PvP lobby is a **bad idea**: it creates pay/grind-to-win and poisons ranked.
- Exception: PvE-only modes (Daily Run, Solo Gauntlet) may use light vertical progression if fully segregated from ranked PvP.

### 3.2 Systems
| System | Description |
|---|---|
| **Account level** | XP from placement + challenge participation. Unlocks Commanders and modes on a gentle curve (all core Commanders by ~level 20). |
| **Rating (MMR)** | Separate ranked ladder. Based on **placement only** — do *not* factor challenge score into MMR directly (it already affects placement indirectly). |
| **Challenge Mastery** | Per-challenge-type personal bests, badges, and medals. Separate leaderboards (Global / Friends / Weekly). Gives dexterity players a "home" without distorting the strategy game. |
| **Collection / Codex** | Discovering units, synergies, and bosses fills a codex with lore and cosmetic rewards. |
| **Battle Pass / Seasons** | Cosmetic tracks only. Quests should reward *playing varied strategies*, not grinding challenges. |
| **Cosmetics** | Boards, unit skins, Commander skins, challenge themes (e.g., memory cards with custom art). |

### 3.3 Bad ideas to avoid
- ❌ **Unlockable units** that are in the shared pool — a player who hasn't unlocked a unit can't be in the same pool. Keep the unit pool universal.
- ❌ **Challenge practice that grants power.** Practice mode should be free and reward-free (or cosmetic only), otherwise you incentivize grinding minigames instead of the game.
- ❌ **Persistent stat upgrades** in PvP.

---

## 4. Unit System

### 4.1 Unit anatomy
| Field | Notes |
|---|---|
| Name, Art, Tribe(s) | 1 tribe typically; some dual-tribe or "neutral" |
| Tier (1–6) | Determines shop availability and cost profile |
| Attack / Health | Integer stats |
| Keywords | See below |
| Ability text | Triggered/static effects |
| Upgraded ("Golden") form | Triple 3 copies → golden version (double stats, enhanced effect) + discover a unit from tier+1 |

### 4.2 Keyword set (starter, keep ≤10 for readability)
- **Rally** (start of combat), **Last Breath** (on death), **Guard** (must be attacked first), **Shield** (blocks first damage), **Venom** (destroys any unit it damages), **Frenzy** (attacks twice), **Echo** (repeat trigger), **Rally Cry** (on buy), **Grow** (end of turn gain stats), **Focus** *(new — challenge-linked, see 4.4)*.

> **IP note:** Avoid lifting Hearthstone keyword names (Taunt, Divine Shield, Deathrattle, Battlecry, Reborn, Windfury) and tavern-tier presentation 1:1. Mechanics are not copyrightable, but trade dress and names invite trouble and make the game look derivative.

### 4.3 Tribes (example roster of 8, 5 active per lobby)
| Tribe | Identity | Scaling style |
|---|---|---|
| Ironclad (mechs) | Shields, magnetize/merge | Board-wide durability |
| Wildkin (beasts) | Token summoning | Wide boards |
| Hexers (undead) | Last Breath chains | Death value |
| Embers (elementals) | Shop manipulation | Economy |
| Tidefolk (pirates/naga) | Gold generation | Tempo |
| Runesmiths | Spell/trinket synergy | Item scaling |
| Swarmlings | Venom, many small units | Attrition |
| Clockwork | **Focus** synergy (challenge-linked) | Skill-tilted scaling |

### 4.4 Linking units to challenges — careful
A *small* number of units can interact with challenge results ("**Focus**: After a Skill Challenge, gain +1/+1 per reward tier earned"). This makes challenges matter to drafting decisions.

**Critique:** If more than ~10% of the unit pool scales on challenge performance, the best strategy becomes "be good at minigames" and the game collapses into a reflex test. Rules:
- Max one tribe (Clockwork) plus a handful of neutrals have Focus.
- Focus effects reward **participation thresholds** (e.g., "Bronze or better"), not raw score — so an average player can still enable them.
- Never put Focus on high-tier "carry" units.

### 4.5 Unit pool size
- Shared pool per lobby (finite copies per unit: tier 1 ×16, tier 2 ×15, tier 3 ×13, tier 4 ×11, tier 5 ×9, tier 6 ×7). Contest-for-units is a core strategic tension; keep it.
- Launch target: ~90–110 units (5 active tribes × ~14 + neutrals). Don't over-scope; Battlegrounds launched with fewer.

---

## 5. Economy System

### 5.1 Baseline (proven model — don't reinvent)
| Element | Value |
|---|---|
| Gold per turn | 3 on turn 1, +1 per turn, cap 10 |
| Buy unit | 3 gold |
| Sell unit | 1 gold |
| Reroll shop | 1 gold |
| Freeze shop | Free |
| Level shop tier | Cost decreases by 1 each turn you don't level (e.g., 5/7/8/9/10 base) |

### 5.2 New economy elements
| Element | Purpose |
|---|---|
| **Trinkets** | Passive items earned from PvE encounters / challenges. Max 2 slots. Adds build variety without bloating the board. |
| **Challenge Tokens** | Secondary currency earned from challenges; spent at an occasional **Challenge Shop** (rounds after a challenge) for choices: discover a unit, reroll trinket, +1 gold next turn, etc. |
| **Interest?** | ❌ Not recommended. Auto Chess-style interest increases complexity and rewards passive saving; conflicts with the Battlegrounds tempo model you're emulating. |

### 5.3 Critique: Why a separate token currency instead of gold?
Paying challenge rewards in **gold** directly creates a tempo snowball: gold → earlier tier-up → stronger board → wins. A skill advantage would compound every round. A **separate token currency with a limited, choice-based shop** caps the value, makes the reward *interesting* (a decision), and is easier to balance independently.

### 5.4 Economy safeguards
- Gold cap per turn stays at 10 even with bonuses (bonus gold can exceed by max +2).
- Tokens expire at end of run (no hoarding across runs).
- Token shop offers are **seeded per lobby** so everyone sees the same options per tier (fairness, and fun "what did you pick?" comparisons).

---

## 6. Skill Challenge Framework

### 6.1 Design rules for every challenge
1. **Duration:** 8–15 s of play, plus a 3 s preview/instruction and 2 s results.
2. **Learnable in one view:** single-sentence instruction + animated example.
3. **Deterministic:** fully driven by a shared seed; same layout, timings, and sequence for all players.
4. **Input-agnostic where possible:** must work on mouse, touch, and (ideally) controller. Design for **tap**, not "click + drag + keyboard."
5. **Scorable objectively:** produces `completed (bool)`, `time_ms`, `raw_score`, `accuracy`.
6. **Accessibility-aware:** colorblind-safe palettes, no audio-only cues, no flashing patterns (photosensitivity), reduced-motion variant.
7. **Bot-resistant:** randomized positions within seed, human-plausibility checks (see §7.4).

### 6.2 Challenge catalog (launch: 6–8 types, each with difficulty tiers)
| Challenge | Mechanic | Primary skill | Notes / Critique |
|---|---|---|---|
| **Target Rush** (rapid clicking) | Targets appear; tap them before they fade | Speed + accuracy | ⚠️ Most bot-able and most hardware-dependent (mouse vs touch vs trackpad). Use large targets, penalize misses, cap target spawn rate. |
| **Memory Match** | Flip pairs on a 4×4 grid | Working memory | ✅ Fair across devices; low latency sensitivity. Good flagship. |
| **Sequence Recall** (Simon) | Repeat a growing sequence | Memory | ✅ Fair; score = sequence length reached. |
| **Pattern Spotter** | Find the odd one out / complete the sequence | Pattern recognition | ✅ Cognitive, fits strategy audience best. |
| **Perfect Timing** | Stop a moving needle in a zone | Timing | ⚠️ Latency + frame-rate sensitive. Must evaluate **client-side with local clock**, not server round-trip. |
| **Reflex Gate** | React when a signal appears | Reaction time | ❌ **Weakest idea.** Pure reaction time is mostly genetics/age/hardware (monitor Hz, input lag); hard to improve, easy to fake, low fun after the first time. Recommend replacing with **Choice Reaction** (react with the *correct* one of 3 options), which adds cognition and resists bots. |
| **Unit Quiz** *(alternative)* | "Which of these 3 boards wins?" or "Which unit has Venom?" | Game knowledge | ✅ Strongly recommended addition — ties challenges to the core game, rewards strategy players. |
| **Path Trace** | Trace a route through a maze before time ends | Spatial + motor | Optional; good on touch. |

**Suggested ratio per run:** at least 3 of 5 challenges should be cognitive (Memory, Pattern, Quiz, Sequence) rather than motor (Target, Timing). This aligns challenges with the audience.

### 6.3 Challenge selection
- Server picks the challenge type with a **seeded weighted shuffle** — no type repeats within a run.
- Players see an icon of the **next challenge type one round in advance**. This lets them make preparation decisions (e.g., buy a Focus unit) and reduces "gotcha" frustration.
- Difficulty tier scales with round (Early/Mid/Late).

### 6.4 Scoring model
Each challenge outputs a **normalized performance score `P` ∈ [0, 100]**:

```
P = completion_weight * C + accuracy_weight * A + speed_weight * S
  where  C = 1 if completed else (progress fraction)
         A = correct_actions / total_actions
         S = clamp((T_max - t) / (T_max - T_par), 0, 1)
```
Default weights: completion 50%, accuracy 30%, speed 20%. Speed is deliberately the **smallest** weight — it's the most latency/hardware-sensitive component.

**Reward tiers from P:**
| Tier | Threshold | Purpose |
|---|---|---|
| Participation | P > 0 (attempted) | Never zero reward for trying |
| Bronze | P ≥ 40 | Most players reach this |
| Silver | P ≥ 65 | |
| Gold | P ≥ 85 | |
| Lobby Best | Highest P in lobby | Small bonus + bragging rights |

Use **absolute thresholds** for tiers (everyone can get Gold) plus **one relative bonus** (lobby best). Pure ranking would create a zero-sum game where 7 of 8 players feel they "lost" every challenge — bad.

### 6.5 Challenge flow (UX)
1. Announcement banner (round end): "SKILL CHALLENGE: Memory Match" (3 s).
2. Synchronized countdown 3-2-1 (local clock, started on server signal).
3. Play (8–15 s).
4. Results: your tier, lobby ranking, reward chosen/applied (2–4 s).
5. Return to Recruit phase.

### 6.6 Disconnects / AFK
- AFK or disconnected → Participation-tier reward only (not zero; disconnects shouldn't compound losses).
- Don't let players "skip" to save time — everyone waits the same fixed duration anyway.

### 6.7 Alternative model worth prototyping: **Wager Challenges**
Instead of mandatory challenges, players may **stake** something (gold, HP, a unit) before seeing the challenge, earning a multiplier on success. Non-participants lose nothing.
- **Pros:** Strategy players can opt out; skilled players self-select; adds a decision layer.
- **Cons:** Loses the "everyone plays together" moment; could become ignored.
- **Recommendation:** A/B in playtest against mandatory challenges. A hybrid is possible: mandatory base challenge + optional wager for bonus.

---

## 7. Multiplayer Architecture Options

> No code here — this is the architectural decision space.

### 7.1 Requirements
- 8 players per lobby, turn-based recruit phase, auto-resolved combat.
- Shared seeded RNG for challenges, PvE encounters, lobby modifiers.
- Cheat resistance for challenges (the highest-risk component).
- Mobile + PC; tolerate 150 ms+ latency and brief disconnects.

### 7.2 Options
| Option | Description | Pros | Cons | Fit |
|---|---|---|---|---|
| **A. Authoritative server, deterministic combat sim** | Server owns shop, pool, gold, HP; runs combat simulation with seeded RNG; clients receive results + replay log | Cheat-resistant, single source of truth, easy reconnection | Server CPU for 4 combats × 8 lobbies/turn (cheap — combat is tiny) | ✅ **Recommended** |
| B. Lockstep deterministic (clients simulate) | Clients exchange inputs; each simulates | Low server cost | Desync bugs; any client can cheat on hidden info (shop contents) | ❌ Poor fit for hidden-info game |
| C. Async "ghost" PvP | Opponents are snapshots of other players' boards from previous matches at the same round | No sync needed, no waiting, instant matchmaking, great for low population | Not "live" multiplayer; challenge ranking is vs. historical data | ✅ **Excellent for launch / low-population fallback**, and for Daily Runs |
| D. Peer-to-peer host | One player hosts | Cheap | Host advantage and cheating; unacceptable for ranked | ❌ |

**Recommendation:** **A for live lobbies + C for Daily Run / fallback matchmaking.** Both share the same deterministic simulation core, so the investment is reused. Low player population is the #1 killer of indie multiplayer games — async ghost mode is the insurance policy.

### 7.3 Component sketch
- **Matchmaking service** — MMR buckets, backfill with async ghosts or bots if queue > N seconds.
- **Game server (per lobby)** — stateful, authoritative; holds pool, shops, boards, timers, seed.
- **Simulation core** — pure, deterministic, shared library used by server (authoritative) and client (replay/preview). Must use integer math, seeded PRNG, and a stable ordering — no floating-point or wall-clock dependencies.
- **Challenge service** — issues seed + config, receives input logs, validates and scores.
- **Persistence** — accounts, MMR, unlocks, match history, challenge leaderboards.
- **Transport** — WebSocket (or similar reliable channel); real-time UDP is unnecessary for this genre.

### 7.4 Challenge integrity (the hardest problem)
Challenges are **real-time and client-side by necessity**, so the server can't simply observe them. Approach:
1. Server sends `seed + challenge config` at T-3 s; client generates identical content locally.
2. Client records a **timestamped input log** (relative to local challenge start, monotonic clock).
3. Client submits log at end; server **re-simulates** the challenge from seed + inputs and computes the score itself. Client-reported scores are never trusted.
4. **Plausibility checks:** inhuman reaction times (< ~120 ms consistently), zero-variance timing, perfect pixel-center clicks, impossible input rates → flag/score clamp.
5. **Late-reveal content:** for memory challenges, don't send the full answer key up front where possible (e.g., send card faces only on flip request) — trade-off with latency; acceptable for memory, not for timing.
6. Latency fairness: since timing is measured on the client's local clock, network latency doesn't matter; only **local input/display latency** does, which you can't fully fix — hence speed's low weight.
7. Ranked: apply stricter validation and server-side anomaly tracking over many matches; casual: lenient.

**Honest limitation:** a determined cheater with an automation tool can beat Target Rush and Reflex challenges. Mitigation is limiting reward impact (§8) so cheating isn't worth it, and favoring cognitive challenges that are harder to automate generically.

### 7.5 Timers & synchronization
- Server is the clock for phases; clients show interpolated countdowns.
- Challenge start: server broadcasts "start at server time X"; clients adjust with measured clock offset. Small discrepancies (<200 ms) don't matter because scoring is relative to each client's local start.

---

## 8. Reward Balancing Suggestions

### 8.1 The core balancing goal
> **Target: a full challenge sweep (all Gold, all Lobby Best) should be worth roughly the same as one good tempo turn — ~10–15% of a player's total resources across a run.** Enough to feel great, never enough to carry a bad build.

### 8.2 Reward design principles
1. **Choices over stats.** Gold tier = "pick 1 of 3" (discover a unit, trinket, reroll package); Bronze = "pick 1 of 2." Choice-based rewards scale with *strategic* skill, keeping the game about strategy.
2. **Same reward menu for everyone** in the lobby at a given tier — fairness and post-game discussion.
3. **Diminishing returns:** each subsequent Gold in a run is worth slightly less (e.g., 100% / 90% / 80% ...), or after the 3rd Gold rewards shift toward cosmetic/MMR-neutral bonuses.
4. **Catch-up mechanic:** players in the bottom half of HP get a +1 tier bump on their challenge reward (Bronze → Silver). This is *rubber-banding* — it makes challenges a comeback tool rather than a snowball tool. **Critical**, because otherwise challenges amplify existing leads.
5. **Never pay in HP or direct combat stats** for the whole board. Board-wide stat buffs are the most snowball-prone reward.
6. **Participation floor:** always some reward; zero rewards for a disconnected or disabled player is a fairness and accessibility failure.

### 8.3 Example reward table (starting point)
| Tier | Early (R3) | Mid (R6–9) | Late (R12–15) |
|---|---|---|---|
| Participation | 1 token | 1 token | 2 tokens |
| Bronze | 2 tokens | 3 tokens | 3 tokens |
| Silver | 3 tokens | 4 tokens | 5 tokens |
| Gold | 4 tokens + discover T(current) | 5 tokens + discover T(current) | 6 tokens + trinket choice |
| Lobby Best | +1 token | +1 token | +1 token + cosmetic flair |

Token shop prices: discover a unit = 4, +1 gold next turn = 2, trinket reroll = 3, free shop refresh ×2 = 2.

### 8.4 Telemetry to tune with
- **Win rate / avg placement delta by challenge tier.** Target: Gold-vs-Bronze placement difference ≤ 0.5 places on average. If larger, rewards are too strong.
- Correlation between challenge score and final placement (target low-moderate, e.g., r ≈ 0.1–0.2).
- Distribution of P per challenge type (each should have a healthy spread; a type where 80% get Gold is too easy and useless).
- Device split: compare score distributions mobile vs PC per challenge. If gap > ~10 P points, adjust that challenge or apply per-input-type normalization (casual only).
- Quit rate during/after challenges (frustration signal).
- Token shop pick rates (identify dominant picks).

### 8.5 Cross-platform fairness options
| Option | Critique |
|---|---|
| Separate queues per input type | Fair but splits population — bad for a new game |
| Per-device score normalization | Fair-ish, but players will feel penalized; complex |
| **Design challenges to be input-neutral + low speed weight** | ✅ Recommended primary strategy |
| Cross-play with opt-out | Good secondary option |

---

## 9. Risks and Mitigation

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| 1 | **Audience mismatch** — strategy players dislike twitch interruptions | High | Cap impact (§8.1), favor cognitive challenges, preview next challenge, prototype Wager model (§6.7), playtest with BG/TFT players early |
| 2 | **Snowballing** — skilled players get richer | High | Choice-based rewards, separate token currency, diminishing returns, catch-up bonus for low-HP players |
| 3 | **Cheating / bots** on challenges | High | Server-side re-simulation from input logs, plausibility checks, low reward ceiling, cognitive > motor challenges |
| 4 | **Hardware/latency unfairness** (monitor Hz, touch vs mouse) | Medium-High | Local-clock scoring, low speed weight, large targets, input-neutral designs, device telemetry |
| 5 | **Accessibility** — motor or visual impairments, photosensitivity | High (ethical & legal/platform) | Colorblind modes, no flashing, reduced motion, participation floor; consider an "assist" option that removes challenge eligibility for Lobby Best but keeps tier rewards (casual only) |
| 6 | **Challenge fatigue** — novelty wears off after 20 runs | Medium-High | Rotating challenge pool per season, difficulty variants, modifiers ("mirrored", "speed up"), Unit Quiz content that grows with the card pool |
| 7 | **Match length bloat** | Medium | ≤5 challenges/run, ≤20 s total each, 4-player Quick mode, keep combat animations skippable/fast |
| 8 | **Low player population** (multiplayer death spiral) | Critical for indie | Async ghost mode, bot backfill, Daily Run PvE mode, cross-platform from launch, smaller 4-player lobbies |
| 9 | **IP / derivative perception** (Hearthstone Battlegrounds) | Medium | Original keywords, tribes, art direction, and UI; the challenge mechanic must be front-and-center in marketing as the differentiator |
| 10 | **Scope creep** — 100+ units, 8 challenges, PvP+PvE, cross-platform | High | Vertical slice first: 3 tribes, ~40 units, 3 challenges, async PvE Daily Run. Validate fun before netcode |
| 11 | **Determinism bugs** (combat desync between server and client replay) | Medium | Integer-only shared sim core, seeded PRNG, replay-based automated regression tests |
| 12 | **Balance complexity** — two orthogonal skill axes to tune | Medium | Telemetry dashboards (§8.4), simulation bots that play challenges at fixed skill percentiles to test reward impact offline |
| 13 | **Monetization pressure creating P2W** | Medium | Cosmetic-only monetization; no purchasable Commanders with exclusive power in ranked, or rotate free Commander pools |
| 14 | **Toxicity around challenge performance** (leaderboard shaming) | Low-Medium | Show only your own score + tier publicly by default; lobby ranking optional; no free chat by default (emotes only) |

---

## 10. Recommended Next Steps
1. **Paper prototype** the economy and units (spreadsheets / cards) — validate synergies without code.
2. **Standalone challenge prototypes** (3 types: Memory Match, Pattern Spotter, Target Rush) — test fun, fairness across devices, and P distribution.
3. **Vertical slice: single-player seeded Daily Run** with 3 tribes, ~40 units, 3 challenges, ghost opponents.
4. **Playtest the core question:** *Do challenges make the run more fun, or are they an interruption?* Compare against a build with challenges disabled. Kill or reshape the mechanic based on data — don't let it survive on concept appeal alone.
5. Then build authoritative live lobbies.

## Appendix A — Open Questions
- Target platform priority: PC/web first or mobile first? (Affects challenge input design heavily.)
- Ranked at launch, or casual-only until population is proven?
- Session length target: 20 min (mobile-friendly) or 35 min (BG-like)?
- Art direction and setting (fantasy tavern is crowded — consider a distinctive theme).
