# Clutch Tavern: Technical Architecture

Status: architecture proposal, based on the approved GDD  
Target: iPhone, Swift, SwiftUI; GameKit where appropriate  
Scope: system boundaries, folder structure, conceptual models, state ownership, persistence, and multiplayer evolution. No implementation code.

## 1. Architectural direction

Build an offline-first iPhone app around a deterministic, platform-independent Swift game core. SwiftUI presents state and sends player intentions; it does not own game rules. A session coordinator connects presentation to either a local match authority or, eventually, a remote authority.

**The key investment is a stable authority boundary, not networking infrastructure on day one.** Offline players, bots, and future remote players all use the same conceptual commands and rules.

| Decision | Recommendation | Reason |
|---|---|---|
| App architecture | Small layered architecture with feature-organized presentation | Clear ownership without a framework-heavy setup |
| UI | SwiftUI screens, navigation, board, shop, and challenge presentation | Native iPhone experience and accessible controls |
| Game rules | Framework-independent Swift package | Reusable in tests, offline sessions, and a potential Swift backend |
| State | Explicit match phase machine and one serialized authority per match | Prevents competing mutations and invalid transitions |
| Saves | Versioned local document snapshots initially | Easy inspection, migration, and offline recovery |
| Multiplayer destination | Dedicated authoritative backend for competitive live play | Protects hidden information and survives client departure |
| Apple services | Game Center identity, achievements, leaderboards; optional casual matchmaking | Useful platform services, not a game server |
| Minigames | Compile-time catalog of independent challenge modules | Easy additions without runtime plugin complexity |

### Scope assumptions

- The GDD's eight-player hybrid PvP/PvE format remains the eventual target; the first playable is one local human with bots or bundled opponent snapshots.
- The prototype requires neither sign-in nor internet access. A locally seeded practice run is not an official online daily competition.
- Gameplay is touch-first. Future platforms are a reason to isolate rules, not a reason to build cross-platform UI now.
- Ranked play, production matchmaking, remote content delivery, and cloud progression are later stages.
- GDD balance numbers remain versioned tuning data, not architectural constants.

## 2. System boundaries and dependency direction

Conceptual flow:

1. SwiftUI feature sends a player intention to the session coordinator.
2. The coordinator submits a command to the active match authority.
3. The authority validates it, applies rules, and advances the match.
4. It publishes the appropriate player-visible state and presentation events.
5. Presentation updates; persistence records an eligible checkpoint.

The local authority runs on the device. A future remote authority runs on the backend, with an iPhone connection acting as its client. Network delivery adds pending, rejected, and reconnecting states; it is not assumed to be instantaneous just because the local prototype is.

| Boundary | Owns | Must not own |
|---|---|---|
| Presentation | Screens, animations, navigation, transient selection and touch feedback | Gold calculations, legal moves, authoritative timers |
| Application/session | Session lifecycle, command routing, adapters, save coordination | Duplicated combat or reward formulas |
| Game core | Rules, models, simulation, phase transitions, challenge evaluation | SwiftUI, GameKit, file access, sockets, device clocks |
| Platform infrastructure | Files, lifecycle signals, authentication, transport, diagnostics | Game balance and match outcomes |
| Content | Unit definitions, encounters, challenges, economy and reward configuration | Arbitrary executable behavior supplied by data |

Dependencies point inward toward the core. The core never imports the app or infrastructure. Keep the application/session layer in the app initially; a separate package is unnecessary until reuse justifies it.

Do not build microservices, an entity-component framework, a generalized scripting language, or a full event-sourcing platform for this prototype.

## 3. Proposed folder structure

This is a logical structure, not a request to create a project yet. Start with one iOS app target and one local Swift package; folders do not each imply a framework.

```text
ClutchTavern\
  App\
    Composition\                 Dependency assembly and local/online mode selection
    Navigation\                  App-level navigation
    Lifecycle\                   Foreground, background, interruption coordination
  Features\
    Home\
    Lobby\
    Run\
      Board\
      Shop\
      CombatPlayback\
      Rewards\
    Challenges\
      SharedPresentation\
      MemoryMatch\
      PatternSpotter\
      TargetRush\
    Results\
    Progression\
    Settings\
  Application\
    Sessions\                    Coordinator and authority-facing contracts
    LocalAuthority\              Offline orchestration around game-core rules
    Opponents\                   Bot decisions and bundled ghost selection
    Persistence\                 Save orchestration and repository contracts
    Progression\                 End-of-run settlement coordination
  Infrastructure\
    Persistence\                 Local files and migration adapters
    GameCenter\                  GameKit integration
    Networking\                  Future backend client and wire-model mapping
    Diagnostics\                 Local logs and future opt-in telemetry
  Resources\
    Content\                     Versioned gameplay catalogs
    Assets\
    Localization\
  Packages\
    GameCore\
      Sources\
        Domain\                  IDs, definitions, and runtime state
        Rules\                   Economy, units, combat, and rewards
        Simulation\              Deterministic ordering and random streams
        MatchFlow\               Phase machine and scheduling
        Challenges\
          Contracts\
          MemoryMatch\
          PatternSpotter\
          TargetRush\
        Content\                 Catalog contracts and validation
      Tests\
  Tests\
    Application\
    Persistence\
    Presentation\
    ContractFixtures\
  UITests\
```

Keep challenge UI under the app and challenge rules under GameCore. Adding a challenge should not require editing combat, economy, or save orchestration. Networking folders may remain absent until needed; the authority boundary exists first.

## 4. Conceptual data models

### Definitions versus instances

Definitions describe content shared across a ruleset. Instances describe one run. A unit's localized display name or array position is never its identity.

| Model | Important information | Ownership |
|---|---|---|
| ContentManifest | Content version, rules version, catalog integrity identifier, supported challenge versions | Bundled content initially |
| RulesetDefinition | Lobby size, phase schedule, health, board limits, economy rules, reward policy | Core configuration |
| UnitDefinition | Stable ID, tribe IDs, tier, base stats, supported ability descriptions | Content |
| Commander / Trinket / Encounter definitions | Stable IDs, legal effects, parameters and presentation references | Content |
| UnitInstance | Unique instance ID, definition ID, current stats, upgrades, persistent modifiers | Match authority |
| MatchState | Match ID, mode, revision, round, phase, participants, shared pool, scheduled encounter/challenge, random stream states, pinned versions | Match authority only |
| PlayerRunState | Participant ID, health, board, bench, shop, gold, tokens, commander, trinkets, pending choices, elimination status | Match authority |
| CombatSnapshot / CombatResult | Combat-entry boards, encounter/opponent identity, outcome, damage, ordered playback events | Core, then authority |
| PlayerMatchView | Own private shop/resources, permitted opponent information, phase/deadline, public results | Derived for one participant |
| PlayerCommand | Command ID, participant/session context, phase identity, expected revision, intention and parameters | Submitted to authority |
| DomainEvent | Accepted facts such as purchase, combat resolved, or reward granted | Emitted by authority |
| Profile | Local profile ID, cosmetic/horizontal unlocks, mastery, preferences, optional external identity link | Local initially; backend for verified online progression |
| RunSummary | Outcome, placement, challenge summaries, progression receipts, offline/unverified versus online/verified origin | Settled at run end |
| GhostSnapshot | Board and round context, compatible rules/content versions, origin and verification status | Bundled offline or backend later |

The shared unit pool and other players' private shops never belong in an online client snapshot. Definition catalogs can be public; secret match state cannot.

### Challenge models

| Model | Purpose |
|---|---|
| ChallengeDefinition | Stable type ID, version, supported difficulty/configuration, semantic input kinds |
| ChallengeAssignment | Instance ID, type/version, content seed or authorized public configuration, ruleset, duration, phase identity, common timing window |
| ChallengeState | Type-specific progression needed to evaluate a challenge; separate from view animation state |
| ChallengeInputRecord | Ordered semantic action, challenge instance, relative monotonic time, action-specific data |
| ChallengeSubmission | Assignment reference, bounded input trace, claimed summary for diagnostics, submission identity |
| ChallengeOutcome | Completion/progress, elapsed time, raw score, accuracy, normalized score, reward tier, validity/status |
| RewardOffer / RewardReceipt | Eligible choices and an exactly-once record of the accepted grant |

Use explicit typed models, not a dictionary of loosely typed fields throughout the game. A shared challenge envelope may contain a versioned type-specific payload. Keep file-save models and future network messages separate from domain models where their compatibility or privacy needs differ.

Store gameplay quantities such as gold, stats, and authoritative score components in stable numeric representations. Screen coordinates and animations may use floating point; they must not determine combat outcomes.

## 5. Game state architecture

### State ownership

- **Authoritative match state:** only the match authority may mutate it.
- **Session state:** loading, running, suspended, reconnecting, completed, or failed; owned by the session coordinator.
- **Presentation state:** selected unit, open sheet, drag preview, animation progress; local to the relevant feature.
- **Profile state:** separate lifetime from a match; updated through progression settlement, never by a challenge view.

SwiftUI observes a presentation-facing store on the main actor. Rule evaluation, input processing, and persistence have isolated ownership and do not block animation. Exact concurrency mechanisms are implementation decisions, but overlapping authority mutations are prohibited.

### Match phase machine

| Phase | Responsibility and permitted activity |
|---|---|
| Setup | Validate content; choose commander, participants, modifiers and seeds |
| Recruit | Purchases, sales, rerolls, upgrades and positioning |
| CombatLock | Close recruit commands and freeze combat-entry boards |
| CombatResolution | Resolve either PvP pairings or the scheduled PvE encounter |
| RoundResolution | Apply damage, elimination, encounter loot and pending choices |
| ChallengePreview | Present shared assignment and instructions when scheduled |
| ChallengeActive | Accept challenge inputs; strategic board is locked |
| ChallengeSettlement | Finalize outcomes, rankings and bounded reward offers |
| RewardChoice | Accept choices or apply a predefined deadline default |
| NextRound / Completed | Advance the schedule or settle the run once |

Combat playback is presentation over an already resolved result, not a second authority. A player skipping an animation cannot make their combat end earlier in the rules.

Resolve scheduling collisions explicitly: on round 12, resolve the PvE encounter first, then the scheduled challenge for surviving eligible participants. Once the match has ended, do not create another gameplay challenge. Place challenge-shop access in the following Recruit phase, as the GDD proposes.

Persist pending reward choices and their grant status. Restoring a run must not offer an already granted reward again. Rules define ties, odd-player pairings, eliminated-player behavior, and timeout defaults rather than leaving them to UI decisions.

### Determinism

Pin a match to its rules, content, simulation, and challenge versions. Use stable ordering and independently seeded random streams for shops, pairings, combat, encounters, and challenges. An extra shop reroll must not change the challenge assigned to everyone.

Saving just the initial seed is insufficient for a snapshot: preserve current random-stream positions/states or enough deterministic history to reconstruct them. Cosmetic randomness is separate.

Match authority accepts commands in a defined sequence. Rejected commands have explicit reasons. Offline bots submit legal intentions through the same authority rather than editing their boards directly.

## 6. Extensible minigame architecture

Each minigame is a self-contained capability with:

- A stable type ID and versioned configuration.
- Deterministic setup from the assignment.
- Semantic input interpretation and objective evaluation.
- A common outcome containing completion, time, score and accuracy.
- Independent SwiftUI presentation and accessibility metadata.
- A bounded recording format and compatibility tests.

A central catalog pairs challenge rules with their available presentation. The run scheduler selects catalog entries allowed by the pinned ruleset. The reward system consumes the common outcome, not challenge-specific internals.

**Adding a minigame should mean adding its rules, UI, content, tests, and one catalog registration.** It should not require new reward plumbing or new networking logic. A genuinely new interaction may require a new versioned input payload; do not force every game into generic tap coordinates.

Use normalized logical layouts and semantic targets so iPhone screen size, safe areas, or Dynamic Type do not change the puzzle itself. Target placement and hit-region rules must be defined independently of animation frames. Challenge timing follows elapsed monotonic time, not SwiftUI render frequency.

This is modularity, not downloadable plugins. New executable minigame behavior ships in an app update; future remote configuration may select compatible content and parameters, not introduce arbitrary code.

### Scoring and reward separation

Challenge evaluators calculate performance. A separate reward policy applies thresholds, participation rules, caps, catch-up modifiers and token offers. Store raw and normalized results so balance analysis remains possible.

Support incomplete, interrupted, timed-out, and invalid submissions explicitly. For open-ended challenges such as Target Rush, completion means reaching the defined endpoint; score measures performance within it. Do not invent a completion-speed bonus where every valid attempt lasts the full window.

The GDD gives both attempt-based participation and an AFK/disconnect floor. Represent these as distinct outcome statuses with an explicit reward policy. An invalid competitive submission must not silently become an ordinary successful attempt.

## 7. Save system and iPhone lifecycle

### Storage strategy

Start with versioned local document snapshots in app-managed Application Support storage. Separate active-run saves, profile progression, settings, and optional replay/diagnostic data. SwiftData is not needed for a small aggregate snapshot; reconsider it if searchable history or larger relational collections justify it.

| Artifact | Contents | Trust |
|---|---|---|
| Profile document | Horizontal unlocks, mastery, local results, settlement IDs | Offline/unverified |
| Active-run snapshot | Full local authority state, phase, RNG state, pinned versions, pending rewards, save revision | Resume source for offline mode only |
| Online resume reference | Match ID, participant reference, last observed revision | Hint used to reconnect, not authoritative state |
| Settings | Audio, accessibility and display preferences | Device/user preferences |
| Credentials | Future authentication secrets | Keychain, never ordinary save files |

Offline coins, scores, and wins must not later import into ranked balances or verified leaderboards. Linking a local profile to Game Center is an account policy, not proof that its historical results were honest.

### Checkpoints and recovery

- Checkpoint after committed strategic commands, phase transitions, reward settlement, and run completion; save coordination may coalesce writes without claiming unsaved changes are durable.
- Use an atomic replacement strategy and retain a last-known-good snapshot. Coordinate profile and run settlement through stable receipt IDs so recovery cannot double-grant progression.
- Include save schema version, run ID, save revision, rules/content versions, integrity metadata, and creation/update metadata.
- On load, validate structure, invariants, references and compatibility before exposing the run.
- Corruption produces a visible recovery path to a validated backup; never silently reset progress.
- Integrity checks detect accidental damage, not deliberate cheating by someone controlling the device.

Checkpoint proactively. iOS may suspend or terminate an app without enough time to finish a background save; termination callbacks are not a durability guarantee.

### Pause and interruption policy

| Situation | Offline | Future live online |
|---|---|---|
| Background during Recruit | Checkpoint and suspend the local timer | Server deadline continues |
| Background during combat playback | Resume or replay resolved combat | Reconnect to current authority revision |
| Background during a challenge | Mark attempt interrupted; checkpoint the outcome and apply the documented participation policy | Server window continues; settle according to submission and timeout policy |
| App terminates during a challenge | A saved active-attempt marker restores as interrupted, not a fresh attempt | Reconnect; client cannot restart the assignment |
| App restarts after completion | Recover the same settlement receipts | Fetch verified result; do not grant it locally again |

Do not serialize a monotonic clock reading as though it remains valid after process restart. Offline checkpoints preserve remaining phase duration where pausing is allowed; live deadlines are server-owned. Practice mode may allow retries but remains explicitly unverified.

### Updates and cloud saves

Schema migration and gameplay compatibility are different concerns. Migrate document structure where safe, but do not resume an old run under changed unit rules. Retain the necessary compatible content or explicitly end the incompatible run with a clear explanation.

Defer cloud saves. Later, sync profile data under explicit merge rules; never merge two active match snapshots field by field. Game Center saved games are an optional synchronization facility, not a replacement for migrations, conflict policy, or authoritative online progression.

## 8. Networking and GameKit strategy

### Service responsibilities

| Capability | Recommended owner |
|---|---|
| Offline identity and practice | App-local profile |
| Apple player authentication | Game Center through GameKit, optional until online features |
| Achievements and social leaderboards | Game Center where product requirements fit |
| Casual friend matchmaking | Optional GameKit real-time matchmaking |
| Competitive MMR and matchmaking policy | Future backend |
| Shared pool, private shops, health, rewards, combat | Match authority; backend for competitive online |
| Reconnection and live match recovery | Backend session service |
| Verified cross-device progression | Backend; local cache is a projection |

**GameKit real-time matches do not supply a trusted dedicated game-rules server.** A host-led GameKit prototype is an optional casual experiment, not the ranked architecture. A turn-based GameKit match also does not fit synchronized timed minigames.

Choose one production matchmaking owner. Do not build independent GameKit and backend queues that compete to assemble the same lobby. Backend queues may use Game Center-authenticated identities; Game Center authentication must be verified by the backend rather than trusting an identifier sent by the client.

Platform availability, entitlements, authentication behavior, and supported player counts must be checked against the selected deployment target before implementation. This document does not assume every Game Center mode supports the desired eight-player flow.

### Evolution path

| Stage | Architecture | Completion criterion |
|---|---|---|
| 1. Offline prototype | Local authority, one human, bots/bundled ghosts, local saves, three challenges | Entire run works without sign-in or connectivity |
| 2. Multiplayer contract proof | Two test clients connected to one authoritative session; private friend lobby before public queue | Shared assignment, private views, disconnect/reconnect and duplicate-command behavior proven |
| 3. Online casual | Dedicated authority, identity, durable results, lobby service; GameKit casual experiment only if useful | Several iPhones complete a run without divergent outcomes |
| 4. Online matchmaking | Backend queue, population policy, compatible-version checks, telemetry | Target-size lobbies and acceptable recovery/queue behavior demonstrated |
| 5. Ranked | Verified progression, MMR, abuse handling, operational monitoring | Ranked integrity and recovery gates met |

The backend language and hosting provider remain undecided. A Swift backend could reuse GameCore, but first verify its dependencies work outside Apple platforms. A different-language backend requires shared rules specifications and deterministic test fixtures, not a promise of source-code reuse.

### Communication model

Use a reliable persistent connection for live phases; ordinary request/response services handle profiles and queue operations where suitable. UDP and frame-by-frame lockstep are unnecessary.

The client sends intentions, never authoritative balances, placements, or rewards. The backend returns command acceptance/rejection, revisions, player-specific snapshots/updates, combat playback data, and phase assignments.

Messages need match and participant context, protocol version, phase identity, sequence/revision information and deduplication identities. Reconnection fetches the latest permitted snapshot before accepting new actions. Stale purchases or late challenge submissions are rejected according to a published policy, not blindly replayed.

Keep one logical match authority and durable recovery records; no separate challenge, combat, or economy microservices are required initially. Identity, matchmaking and persistence are logical responsibilities that may share a deployment.

### Shared challenges, timing and integrity

Every eligible player receives the same challenge type, version, seed/configuration, difficulty and scoring policy. The backend schedules a common future start with a bounded readiness window. Client display uses a monotonic clock aligned to the estimated server schedule; submission deadlines and late-delivery rules remain server-owned.

**Correction to a GDD assumption:** replaying a client input log can verify that the claimed result follows from those inputs. It cannot prove the inputs were human, timestamps were truthful, or the client displayed the challenge honestly. Local timing reduces network jitter effects but does not eliminate delivery failures, clock manipulation or device input/display differences.

Consequently:

- Keep speed-sensitive rewards small and capped.
- Validate traces, ordering, duration and assignment identity; use anomaly signals as evidence, not automatic proof of cheating.
- Do not use a universal reaction-time cutoff to punish legitimate players.
- Separate offline/personal records from verified competitive submissions.
- Make stricter server-observed timing or staged reveals a per-challenge tradeoff; both introduce network sensitivity.

There is a specific information-security tradeoff in the GDD: giving every player a full deterministic memory-layout seed also gives a modified client the answer key. Withholding that information requires a different staged-reveal design. Do not claim both full offline-equivalent generation and a server-secret answer layout. Preserve equal assignments while explicitly choosing the trust model for each challenge.

### Disconnect and low-population behavior

Live matches continue when a player backgrounds or disconnects. Use configured legal timeout defaults and preserve an opportunity to reconnect; the phone never assumes the server paused.

For casual queues, visibly labeled bots may fill seats under a documented population policy. Ghost boards are a distinct asynchronous mode: they do not experience the current shared challenge. Do not silently describe historical opponents as live players or use their historical challenge scores as if they were current participants.

## 9. Maintainability and architectural validation

These are future implementation acceptance criteria, not claims that software has been built or tested.

| Area | Required evidence |
|---|---|
| Rules | Legal and illegal commands, finite pool conservation, economy limits, elimination and phase ordering |
| Determinism | Same pinned versions, initial state and accepted commands produce the same outcomes; stream separation survives extra shop actions |
| Challenges | Each module satisfies outcome, input, timing, interruption and version-compatibility contracts |
| Saves | Resume equivalence, backup recovery, schema migration, incompatible-content handling and exactly-once settlement |
| Authority boundary | UI cannot grant rewards or change game state; bots use the same rules as humans |
| Online contracts | Duplicate, delayed and stale commands; player-private projections; reconnect and deadline handling |
| iPhone UX | Different screen sizes, touch accuracy, accessibility, frame-rate variation and background interruption |
| Expansion | A fourth challenge can be added without modifying combat, economy or persistence orchestration |

Capture useful diagnostics such as phase-transition failures, save failures, rejected commands, challenge interruptions and reconnect outcomes. Keep raw input traces bounded and short-lived unless a defined verification need requires retention; avoid collecting unrelated personal data.

## 10. Critical tradeoffs and deferred decisions

| Tempting approach | Problem | Preferred alternative |
|---|---|---|
| One global observable object for the entire game | UI, rules, networking and save concerns become inseparable | Explicit match, session, profile and presentation ownership |
| Put rules inside SwiftUI views | Hard to test; online authority requires a rewrite | Views emit intentions; core evaluates rules |
| Make GameKit the entire backend | Does not establish ranked authority or recover server-owned matches | Isolate Apple services and plan a dedicated authority |
| Build online systems immediately | Consumes effort before proving the challenge loop is fun | Local authority with future network-compatible semantics |
| Save only boards or the initial seed | Loses shops, pending choices, pool and current randomness | Complete versioned checkpoints |
| Trust local scores after sign-in | Account identity does not validate past gameplay | Separate offline and server-verified progression |
| Ship one universal minigame engine | Either overly restrictive or an unnecessary scripting framework | Small common lifecycle with type-specific rules and UI |
| Assume a separate token currency prevents snowballing | Tokens still buy combat-relevant resources | Central reward valuation, caps and playtest telemetry |

Defer backend provider, production queue algorithm, cloud-save provider and exact deployment target until their constraints matter. Before ranked launch, finalize challenge trust policies, account-linking rules, timeout/reward treatment, and active-run update compatibility.

**Recommended foundation:** one SwiftUI app, one pure Swift GameCore package, one local authority, versioned local saves, and three independently registered minigames. Preserve a clear route to authoritative multiplayer without building the production network stack during the offline prototype.
