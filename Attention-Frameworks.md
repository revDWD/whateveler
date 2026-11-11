# Attention Game: First-Principles Frameworks

Status: design exploration. Follows `Attention-Concept-Review.md`, but deliberately throws out its assumptions: no card battler, no "desk of boards," no inherited genre. Nothing here has been playtested.

---

## 1. Start over: what *is* attention?

The earlier review treated attention as **time**: you look at one panel while the others tick. That's the obvious model. It isn't wrong, but it isn't the only one, and it hides a decision that should be made deliberately.

A clock makes attention scarce in the most direct way: you can't look at everything before the world moves. It also brings real strengths: tension you can feel, a fantasy that's easy to read, and trailer appeal. Five Nights at Freddy's built a franchise on switching between cameras against a clock. The original concept listed "decisions over reflexes" as a pillar. This brief says to challenge everything, so treat that pillar as a preference to test, not a law. The real distinction isn't *clock versus no clock*. It's what the clock rewards:

- **Speed of judgment.** Papers, Please, Mini Metro and FTL put time pressure on *deciding*. Players can lose because they thought too slowly, and that's still a strategic game.
- **Speed of execution.** Actions per minute, aiming, and reaction time put pressure on the *hands*. A clock that rewards this turns the game into a dexterity test, whatever the theme.

A clock that pressures judgment is a legitimate and possibly strongest lever. One that pressures execution is the failure mode to watch for.

In real life, attention isn't one resource. It's at least five, and **each one creates a different game**:

| Scarcity | What you can't do | Real-world example |
|---|---|---|
| **Observation** | See everything at once | A lifeguard scanning a beach |
| **Presence** | Be everywhere at once | A head chef walking the line |
| **Investment** | Commit fully to every front | A general splitting troops |
| **Retention** | Remember everything you saw | A detective with a notebook |
| **Commitment** | Change plans freely once made | A surgeon's operating schedule |

### What makes an attention decision *interesting*?

From first principles, a choice about where to attend is interesting only when all four of these hold:

1. **Unattended things change.** If the world waits for you, there's no cost to neglect.
2. **You don't know exactly how they changed.** If you can compute the unseen state, attention is just bookkeeping. **Uncertainty is the core ingredient, not time.**
3. **Attending has value you can estimate but not know.** "Is it worth checking?" must be a judgment call: the *value of information*.
4. **Neglect is recoverable, but at a rising price.** Instant death makes the choice obvious. No consequence makes it irrelevant.

**Key insight, and a correction to the earlier review:** condition 2 means a clock is *one* lever, not the only one. **Hidden, evolving information** makes attention scarce even in a fully turn-based game. That's *epistemic* overload: too much you don't know. A clock creates *temporal* overload: too little time. The two levers are independent and can be combined. So the time model should be a dial the prototype tests, not a premise the design assumes.

| Time model | What makes attention scarce | Strength | Main risk |
|---|---|---|---|
| **Turn-based** | Hidden, evolving state only | Accessible, mobile-friendly, deep, novel | Can feel calm or solvable; weaker felt overload |
| **Shot clock per turn** | Hidden state plus limited thinking time | Pressure on judgment, no dexterity needed | Turns feel rushed without being harder to solve |
| **Real time with pause** (FTL) | Simultaneous events; pause sets the pace | Felt urgency, but the player controls it | Expert play becomes pause-scumming |
| **Continuous real time** (FNAF, Mini Metro) | Everything above, plus the inability to stop | Strongest tension and stream and trailer appeal | Execution speed creeps in; excludes some players |

A framework that works under several of these is more valuable, because playtests can choose the time model instead of the design locking it in.

The five frameworks below each build a whole game around a different scarcity.

---

## 2. Five radically different frameworks

### Framework A: The Lighthouse (scarcity: observation)

**One sentence:** You can act anywhere, but you can only *see* one place at a time, and everything you aren't watching keeps moving.

**Fantasy:** A lighthouse keeper on a stormy coast, a night-watch over a city, or a mission controller with one telescope.

**How it plays (turn-based or timed, with the same rules):**
- The map has 6 to 8 **sites** (a ship drifting toward rocks, a fire in the docks, smugglers in a cove, a stranded fisherman). Each site has a **hidden state** that evolves every turn by known rules plus randomness.
- Each turn you get **1 Look** and **2 Acts**.
  - **Look** reveals one site's exact state (and adjacent sites at low fidelity).
  - **Acts** (send a boat, ring a bell, light a flare) work anywhere, but their effect depends on the *true* state. Acting on stale information can waste the act or make things worse.
- Unwatched sites show only **"last seen 3 turns ago"** plus a widening uncertainty band.
- The world emits free but **ambiguous signals**: smoke, a distant bell, a gull flock. Some are false.

**The core decision:** "Where is my uncertainty most expensive right now?" That's value-of-information reasoning, which is exactly what skilled attention is.

**Example turn:** The ship was 2 tiles from the rocks two turns ago and drifts 0 to 2 per turn. The fire hasn't been checked in 4 turns and spreads slowly. You hear a bell from the cove, which is 70% reliable. Do you look at the ship you're fairly sure about, the fire you know nothing about, or chase the bell?

| Pros | Cons |
|---|---|
| Purest expression of attention. Looking is the main verb | Can feel passive ("I spent my turn just looking") |
| Works turn-based (accessible, mobile-friendly) or on a clock (urgent, streamable) with the same rules | Hidden stochastic rules must be learnable, or failure feels random |
| One core rule; scales by adding site types, not systems | Risk of a trivial heuristic ("look at the stalest site") dominating |
| Timed observation games are proven (FNAF camera switching); the turn-based, strategic version is rare | Turn-based mode is harder to show in a trailer (the tension is in your head) |
| Reveals skill clearly: experts build mental models of the unseen | Needs strong UI for uncertainty (bands, ghosts, "last seen") |

---

### Framework B: The Conductor (scarcity: presence)

**One sentence:** You lead a crew of semi-competent autonomous agents, and wherever you stand, things go well.

**Fantasy:** A ship's captain, a head chef, an orchestra conductor, or a heist leader.

**How it plays (slow real time or ticks):**
- 4 to 6 **agents** run tasks on their own. Each has traits: reckless, slow, brilliant but distractible.
- Your **presence** at a station multiplies that agent's quality and lets you make decisions the agent can't (spend resources, choose risky options).
- Unsupervised agents make *characteristic* mistakes. The reckless one cuts corners; the timid one stalls.
- Between missions, you hire, train, and fire. **Your build is your crew**, and its real purpose is deciding which agents you can trust alone.

**The core decision:** "Who needs me now, and who can I trust?" That's delegation as strategy.

| Pros | Cons |
|---|---|
| Strong power fantasy; delegation turns overload into mastery | Agent AI is expensive and hard to make readable |
| Emergent stories ("Pip burned the soup again") give it streamability | Fits real time best, but moving the conductor around can make execution speed matter more than judgment (the Overcooked trap) |
| Natural progression: better crew means more freedom | "Managing people" can feel like a job |
| Clear visual: you can *see* the conductor move | Failure attribution is blurry (was it me or the agent?) |

---

### Framework C: The Divided General (scarcity: investment)

**One sentence:** Several contests happen at once, you secretly split a fixed pool of focus across them, and whoever invests more in a front wins it.

**Fantasy:** A general on several fronts, a chess grandmaster playing a simul against a rival grandmaster, or a politician running several campaigns.

**How it plays (simultaneous turns, best against an opponent):**
- 3 to 5 **fronts** of different value are active each round.
- Each round both players secretly allocate N focus tokens across the fronts (game theory calls this **Colonel Blotto**). Higher investment wins that front.
- Twists: fronts persist and carry momentum, a neglected front decays, investing reveals information about the opponent, and bluffing matters.

**The core decision:** "Where will my opponent *not* be paying attention?" That's attention as a mind game.

| Pros | Cons |
|---|---|
| Extremely deep, well-studied decision space | Needs an opponent (human or good AI) to come alive |
| Short, tight rounds; strong competitive and PvP potential | Abstract; weak "overload" feeling, more poker than juggling |
| Prototype with paper tokens in an afternoon | Simultaneous blind bidding is a known genre (much less novel) |
| Pure reads and bluffs; execution speed never matters | Solo play against AI often feels hollow |

---

### Framework D: The Notebook (scarcity: retention)

**One sentence:** Information streams past once; you can keep only a few notes, and later decisions depend on what you chose to remember.

**Fantasy:** A wartime codebreaker, a detective listening to testimony, or a spy at a party.

**How it plays (paced, not timed):**
- A stream of **clues** arrives: overheard lines, telegrams, sightings. Each is shown once, at a readable pace the player controls.
- Your **notebook holds 5 entries**. Keeping a clue means discarding another.
- Periodically you must **act on a question** ("Which ship carries the gold?", "Who is the double agent?") using only your notebook.
- Clues combine: two weak clues can be worth more than one strong one.

**The core decision:** "What will matter later?" That's attention as curation.

| Pros | Cons |
|---|---|
| Very novel; deeply cerebral; strong mystery theme | Easily becomes a raw memory test (excludes many players) |
| No time pressure needed at all | Content-heavy: clues and mysteries must be authored or generated well |
| Great "aha" moments when clues connect | Losing because you discarded the wrong clue feels unfair |
| Works well on phones | Weak sense of a living, overloading world |

---

### Framework E: The Planner (scarcity: commitment)

**One sentence:** You schedule your attention in advance on a timeline, then watch the plan collide with reality, with only a few interrupts to fix it.

**Fantasy:** An air-traffic controller's shift plan, a surgeon's schedule, or a heist timeline.

**How it plays (plan, then resolve):**
- A timeline of upcoming **events** is partly visible (some certain, some likely, some hidden).
- You place a limited number of **attention blocks** on the timeline before the round starts.
- The round resolves step by step. Surprise events appear, and you hold 1 or 2 **interrupts** to move a block.
- Reward depends on how well your blocks covered what actually happened.

**The core decision:** "How much do I commit now versus keep in reserve for surprises?" That's attention as planning under uncertainty.

| Pros | Cons |
|---|---|
| No execution speed involved; ideal for mobile and short sessions | Most of the tension sits in planning, so resolution can feel like spectating |
| Clear failure attribution: you can see exactly what you missed | Closer to a scheduling puzzle than to "managing attention live" |
| Into the Breach-style telegraphing is proven and loved | Risk of being "solved" if events are too predictable |
| Easy to build and to balance with simulations | Least "overload": the brief's core fantasy is weakest here |

---

## 3. Comparison

Scores are 1 to 5, based on judgment, not data.

| Criterion | A. Lighthouse | B. Conductor | C. General | D. Notebook | E. Planner |
|---|---|---|---|---|---|
| Attention *is* the core verb | **5** | 4 | 3 | 4 | 3 |
| Rewards judgment more than execution speed | **5** | 3 | **5** | 4 | **5** |
| Feeling of meaningful overload | 4 | **5** | 2 | 3 | 2 |
| Novelty | 4 | 3 | 2 | **4** | 3 |
| Solo-play strength | **5** | **5** | 2 | 4 | 4 |
| Readability, trailer appeal | 3 | **5** | 3 | 2 | 3 |
| Content cost (5 = cheap) | 4 | 2 | **5** | 2 | 4 |
| One-week prototype ease | 4 | 2 | **5** | 3 | 4 |
| Risk of a trivial dominant strategy (5 = low risk) | 3 | 3 | 4 | 3 | 2 |
| Works both turn-based and on a clock | **5** | 4 | 3 | 3 | 3 |
| **Total** | **42** | 36 | 34 | 32 | 33 |

The "judgment over execution speed" row replaces the earlier "decisions over reflexes" row. It doesn't penalize time pressure. It only penalizes designs where how fast your hands move outweighs how well you decide. With that change, the Conductor closes some of the gap. It's the strongest runner-up if playtests show a clock is essential.

---

## 4. Which best supports attention as a resource?

**Framework A, the Lighthouse.** It's the only framework where:

- the main verb is attending, not acting, so attention isn't a disguised action budget;
- neglect costs **knowledge**, the defining property of real attention, and not just time or points;
- it meets all four conditions from §1 **with or without a clock**, so the time model becomes a playtest decision instead of a design premise. It could even ship as two modes (a calm one and a timed one) using the same rules;
- skill is legible: an expert's advantage is a better mental model of the unseen, which is exactly the fantasy in the brief ("what deserves attention, what can be ignored").

### The strongest version is a hybrid

The Lighthouse alone risks feeling passive and hard to read. Borrow **one** element from Framework B and keep everything else out:

> **Lighthouse plus delegation:** you can station a **watcher** (a lamp, a scout, an apprentice) at a site. A watched site stays partly visible without spending your Look, but watchers are limited, cost upkeep, and only report coarse information. Upgrading watchers is the run's progression.

This gives the run a build axis ("what do I automate seeing?"), an answer to "it feels passive," and the earlier review's delegation power fantasy, all without agent AI.

Explicitly **reject** for now:

- Framework C's opponent model. It's a different game (PvP mind games), not an attention game.
- Framework D's memory test. Retention can stay *implicit*: players remember what they last saw, and the UI helps.
- Deciding the time model on paper. Test the Lighthouse turn-based *and* on a clock in the same week (see §5). The timed version has proven precedent (FNAF) and more trailer appeal. The turn-based version is more novel and more accessible. If the timed version clearly wins, keep it, and consider the Conductor as the natural expansion.

### What could still kill it

| Risk | Test |
|---|---|
| A trivial heuristic ("look at the stalest site") is near-optimal | Compare bots: random, round-robin, stalest-first, and expected-value. If round-robin is within ~10% of the best bot, the decision is shallow. Fix with sites that drift at different speeds, conflicting signals, and acts that need fresh information. |
| Losses feel random | Every site's drift rule must be visible on its card. Show "worst plausible state" on unwatched sites. Add an end-of-night replay that reveals what really happened. |
| "I just looked; nothing happened" feels passive | Each Look should also *do* something small (it calms a panicking ship, or deters smugglers), so looking is never wasted. |

---

## 5. Which is easiest to prototype in one week?

**Easiest overall:** Framework C (the General). A paper version takes an afternoon, but it tests a mind game, not attention overload. A fast prototype that answers the wrong question isn't useful.

**Easiest that answers the right question:** Framework A (the Lighthouse), as a **paper game with a game master**. Hidden state is the hard part to digitize, and a human behind a screen solves it for free.

### One-week Lighthouse plan

| Day | Work |
|---|---|
| 1 | Design 6 site types, each with a drift rule on an index card: ship (drift 0 to 2 per turn toward the rocks), fire (doubles every 3 turns), smugglers (appear and vanish), stranded fisherman (survives N turns), fog bank (blocks Looks), false bell (signal source). Scoring: rescues minus losses. |
| 2 | Build the paper kit: a map, hidden trackers behind a GM screen, "last seen" tokens for the player, dice. Self-test 5 nights of 10 turns. |
| 3 | Write a tiny simulation (a Swift script or spreadsheet) that runs the bots: random, round-robin, stalest-first, expected-value. Tune drift rules until expected-value clearly beats round-robin. |
| 4 | Play-test with 3 to 4 people, two nights each: one **turn-based** and one **timed**, with the order alternated. In the timed version, the GM advances the world every ~10 seconds on a metronome; each beat allows one Look and up to two Acts, and unused actions are lost. The facilitator only records data. |
| 5 | Add the watcher mechanic in whichever time model tested better, and test with 2 to 3 more people. Write up the results and a go/no-go decision, including which time model to carry forward. |

### What to measure

- **Priority talk:** do players say things like "I'll gamble the fire is fine and check the ship"? This is the single strongest signal.
- **Reasons:** after each night, ask "What did you choose not to look at, and why?"
- **Human versus bots:** experienced players should beat the round-robin bot.
- **Fun and stress** on a 1 to 7 scale, and whether players ask for another night.
- **Turn-based versus timed:** compare fun, stress and priority talk. After each timed loss, ask "Did you know what to do but run out of time, or did you choose wrong?" The first answer points to execution pressure; the second points to judgment pressure, which is the kind you want.

### Kill criteria (decide before testing)

- Round-robin is within 10% of the best play: **redesign the drift rules** once. If it still holds, the framework is shallow.
- Fewer than half the testers can explain why they looked where they did: **the hidden rules aren't learnable.**
- Timed mode wins on fun, but losses come mostly from "ran out of time": **keep the clock, but slow the beat or add a pause.** Don't drop it.
- Fun is below 5/7 in both modes even with watchers: **try Framework E (Planner) next.** It's the closest calm alternative and reuses the same site cards. If testers kept asking for *more* urgency, try Framework B (Conductor) instead.

---

## 6. What this changes from the earlier review

| Earlier assumption | Now |
|---|---|
| Attention is time; a clock makes it scarce | Attention is **observation**. Hidden, evolving state makes it scarce, with or without a clock |
| Chess-clock time bank recommended | The time model is an **open dial**: test turn-based and timed side by side with the same rules |
| "Decisions over reflexes" as a fixed pillar | Pressure on judgment is welcome; only pressure on execution speed is a risk to watch |
| Several boards, each its own small game | One shared map of **sites** with simple drift rules |
| Drafting opportunities into slots | Optional; the run's build is **watchers** (what you automate seeing) |
| A 3-to-4-week SwiftUI greybox for the time-model test | A **1-week paper plus simulation** test comes first |

The earlier review's three-board paper prototype (§5 of `Attention-Concept-Review.md`) remains a valid fallback if the Lighthouse fails.
