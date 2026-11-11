# Vertical Slice Development Roadmap

Platform: iPhone, Swift and SwiftUI  
Basis: approved GDD and technical architecture  
Purpose: prove that a short skill challenge makes an auto-battler decision more enjoyable. This is a roadmap, not an implementation.

## 1. Scope lock

**Playable path:** Start Run -> Choose Team -> Play Minigame -> Earn and Allocate Reward -> Auto-Battle -> Game Over -> Play Again.

One run contains one challenge and one battle, targeting roughly 2-4 minutes for a first-time player. "Game Over" is the shared end screen for victory and defeat, not necessarily a loss.

| Included | Slice decision |
|---|---|
| Three unit definitions | A durable Guard, a high-damage Striker, and a Support with one simple ally benefit; placeholder names/art |
| One meaningful team choice | Choose two of the three units and set their order; all three are available immediately |
| One enemy encounter | One fixed, clearly labeled enemy formation using the same unit definitions; no additional enemy archetype or boss system |
| One minigame | Touch-first Memory Match: three pairs and one fixed time limit, initially around 12 seconds |
| One reward type | Focus Tokens; one use only: each adds a small amount of health to a selected friendly unit for the upcoming battle |
| Performance-based reward | A participation floor, with a small capped bonus based on completion, time and score; initially 1-2 tokens |
| One auto-battle | Deterministic resolution with readable attack order and visible health changes |
| End screen | Victory/defeat, challenge result, reward allocation, and Play Again |
| Offline execution | No account, connection or Apple service required |

Token quantity varies, but its effect does not: there are no alternate currencies, loot tables or reward catalogs. Selecting the recipient supplies the strategic choice. Token values and the health increment are playtest parameters, not commitments.

**Excluded:** multiplayer, matchmaking, GameKit integration, shops and rerolls, leveling, extra units, extra encounters, extra minigames, meta progression, cloud saves, ranked play, monetization, production art, and a generalized plugin framework.

The full architecture remains the destination, not the slice's workload. Preserve the game-core/UI boundary and independent minigame rules; defer production networking and full save migrations.

## 2. Milestones

Milestones are ordered dependencies. Each must meet its exit gate before expanding scope.

### Milestone 1: Lock the playable hypothesis

**Outcome:** a small, testable design rather than a miniature version of the entire GDD.

- Set the three units' roles, the fixed enemy formation, and the legal team/order choices.
- Define Memory Match completion, raw score, timing, and how these produce the bounded token award.
- Define reward targeting, combat ties, timeout behavior, and victory/defeat.
- Walk through several team and reward choices on paper.

**Exit gate:** there is a plausible tradeoff between at least two team choices and between reward recipients. The maximum challenge reward does not make every legal team an automatic winner.

**Critical warning:** if the encounter is predetermined regardless of player decisions, this slice cannot test strategic fun. Retune choices and encounter numbers rather than adding content.

**Status:** the engineering foundation (SwiftUI app shell, main menu, run state manager, placeholder battle, game over, navigation) is implemented in `ClutchTavern/`; see `ClutchTavern/docs/DECISIONS.md`. The design lock above is still open.

### Milestone 2: Make the battle decision playable

**Depends on:** Milestone 1.

**Outcome:** Choose Team -> Auto-Battle -> Game Over works on iPhone with placeholder visuals.

- Separate SwiftUI presentation from unit rules, combat resolution and match state.
- Support all three selectable units, two-unit teams, ordering and the single enemy encounter.
- Show enough combat feedback to understand attacks, damage and the outcome.
- Support victory, defeat, and a clean restart.
- Use a temporary developer-only reward setting to inspect how the proposed token effect changes outcomes.

**Exit gate:** identical inputs produce the same battle result; legal choices include both winning and losing outcomes; no choice is obviously best in every tested situation. A player can explain why a battle was won or lost.

Do not polish combat animation yet. Test the strategic foundation before the minigame can obscure its weaknesses.

### Milestone 3: Make one minigame enjoyable in isolation

**Depends on:** Milestone 1; complete before full integration.

**Outcome:** a short, understandable Memory Match challenge with reliable scoring.

- Provide one-sentence instructions and a clear start, countdown, active period and result.
- Record completion/progress, elapsed time, score and accuracy.
- Keep timing independent of animation frame rate.
- Keep challenge evaluation separate from its SwiftUI view and from reward calculation.
- Handle timeout, no input, and interruption explicitly.

**Exit gate:** a first-time player can understand the task without coaching. Completion, incomplete attempts, and different performances produce sensible results. Basic iPhone screen-size and touch checks reveal no layout-dependent scoring advantage.

**Fun gate:** if matching feels like a chore, revise pacing and feedback before adding reward stakes. Do not solve it by adding a second minigame.

### Milestone 4: Connect the complete run

**Depends on:** Milestones 2 and 3.

**Outcome:** the exact requested player journey is playable end to end.

- Place the minigame between team selection and battle.
- Convert its outcome into the single token reward, capped at the agreed maximum.
- Let the player allocate tokens to either selected unit; make the health change visible.
- Resolve combat and show the final result with challenge and reward context.
- Reset every run-specific value on Play Again.
- Remove the developer reward bypass from the ordinary player journey.

**Exit gate:** Start Run -> Minigame -> Reward -> Battle -> Game Over can be completed without developer controls. Repeated taps or repeated result presentation cannot duplicate rewards or start combat twice.

**Design check:** both low and high challenge performance remain playable. Rewards should sometimes change a close battle or a sensible allocation decision, but should not erase the importance of team construction.

### Milestone 5: Run the fun experiment

**Depends on:** Milestone 4.

**Outcome:** evidence for whether the distinctive mechanic earns its place.

Recruit a small initial group, roughly 6-10 players including strategy-game players, rather than relying only on the developer's impressions. Treat this as directional qualitative evidence, not statistical proof.

For comparison, use a test-only baseline that skips the minigame and grants a fixed token amount within the same reward range. Keep enemy, units and presentation unchanged; vary the order in which participants see the versions.

Observe:

- Can players finish a first run without intervention?
- Do they understand how challenge performance changes the reward?
- Can they explain why they selected a reward recipient?
- Do they prefer the challenge version to the fixed-reward version?
- Do they voluntarily replay or try a different team?
- Does a poor challenge result feel recoverable, or does it make battle feel pointless?

**Exit gate:** most participants can complete the loop unaided and explain the reward-to-battle connection. Record a provisional preference gate before testing, such as at least two-thirds preferring the challenge version, alongside the reasons and observed behavior.

Preference alone is insufficient if players like tapping but ignore the battle. Look for engagement with both halves of the loop.

**Decision:** proceed if the combination is promising; iterate if its impact is unclear; reshape or remove the challenge requirement if players consistently prefer the baseline. This is a valid result, not a reason to expand scope.

### Milestone 6: Deliver a repeatable, testable slice

**Depends on:** Milestone 5's proceed decision, or a clearly defined revision.

**Outcome:** a stable iPhone build that another person can play repeatedly.

- Fix the most consequential comprehension and balance issues from playtests.
- Improve only essential readability, touch feedback, result clarity and audio/haptic cues.
- Define background behavior: abandon an interrupted challenge attempt rather than granting a fresh timed retry; return an interrupted offline run to a clearly explained state.
- For this short slice, process termination may abandon the run. State this plainly; persistent run-resume is deferred.
- Check rapid input, timeout, interruption, repeated runs, and both battle outcomes.
- Distribute through an appropriate iPhone test-build route.

**Exit gate:** a tester can install, launch offline, finish several runs, and restart without assistance or state leaking between runs. Known limitations are visible, and the playtest findings support the decision to continue.

## 3. Definition of done

The vertical slice is complete when:

- One offline run follows the full requested sequence.
- Exactly three playable unit definitions, one encounter, one minigame and one reward type are present.
- Team selection and reward allocation create understandable decisions.
- Challenge performance affects the bounded reward, and the reward has an observable battle effect.
- Victory, defeat, timeout, interruption and replay behave deliberately.
- External players have tested the loop, and their feedback supports either continuing or a specific redesign.

**Do not begin multiplayer or increase content volume simply because the flow works.** The next investment is justified by evidence that the combined loop is worth replaying, not by technical completion alone.
