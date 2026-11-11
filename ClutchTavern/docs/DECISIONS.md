# Architecture Decision Log — Milestone 1

Each entry records what was decided, why, and what would change it. These are scoped to the vertical slice and follow `Technical-Architecture.md`.

## Scope note

The roadmap's Milestone 1 was originally a design exercise (locking units, encounter and reward numbers). This implementation provides the **engineering foundation** instead: app shell, navigation and run state. The design lock is still required before Milestone 2 combat work.

---

## D1. Game rules live in a separate `GameCore` Swift package

**Decision:** Run state and transition rules live in `Packages/GameCore`, which does not import SwiftUI.

**Why:** Rules can be unit-tested without a simulator, cannot depend on view state, and can later be reused by bots or a server authority. A local package is the lightest way to enforce this: the compiler rejects UI imports.

**Rejected:** Rules inside view models or views; multiple packages (Domain, Rules, Simulation, …) — too much ceremony for one state machine.

**Revisit when:** a backend needs the rules on Linux (verify Foundation usage), or the package grows enough to split.

## D2. Run state is a value type changed only by a pure engine

**Decision:** `RunState` is a `Codable`, `Equatable` struct. Its `phase` has an `internal` setter, so code outside GameCore cannot mutate it. All changes go through `RunEngine.apply(_:to:)`, which returns a new state or throws `RunError`.

**Why:** One place defines legal transitions. Value semantics make tests trivial, make future saving straightforward, and keep the same command model usable for an online authority (architecture §5).

**Rejected:** A mutable class with public setters; an event-sourcing framework or third-party architecture library (e.g. TCA) — unnecessary for the slice.

## D3. Phases are an enum with associated values

**Decision:** `RunPhase` is `.battle` or `.gameOver(RunOutcome)`. The outcome exists only when the run has ended.

**Why:** Invalid combinations (an outcome during battle) cannot be represented. Adding team selection, minigame and reward phases later is a compiler-guided change: every `switch` that must handle them fails to compile until updated.

**Revisit when:** phases need substantial per-phase data; at that point store it in associated values or a separate per-phase state.

## D4. `RunSession` is the single run state manager

**Decision:** An `@Observable`, `@MainActor` class owns the optional active run and exposes `startRun()`, `send(_:)` and `endRun()`. It is created once in the `App` and injected with `.environment(_:)`.

**Why:** Observation (iOS 17) re-renders only views that read changed properties, without `ObservableObject`/`@Published` boilerplate. Main-actor isolation matches SwiftUI and satisfies Swift 6 strict concurrency. Views express intent; they never compute outcomes.

**Rejected action handling:** Illegal actions (for example, a second tap after the battle resolved) are logged and ignored rather than crashing. They are expected user behavior, not programmer errors.

**Rejected:** A global singleton (hard to preview/test); a view model per screen (no shared ownership of the run).

## D5. Navigation is derived from run state

**Decision:** `NavigationStack` uses a path computed from `RunSession`: empty when no run exists, `[.run]` when one does. Popping the path ends the run.

**Why:** Navigation and game state cannot drift apart. There is no separate router whose path could show a battle screen after the run ended, or a menu while a run is still active.

**Rejected:** A stored `[AppRoute]` path updated alongside the session — two sources of truth; full-screen covers — less natural for future settings/collection screens.

## D6. One `.run` route; phases switch inside `RunView`

**Decision:** Battle and Game Over are not separate navigation routes. `RunView` selects the screen from `run.phase`.

**Why:** Phases are a game sequence, not user-driven navigation. Pushing a route per phase would let the back gesture return from Game Over into a finished battle. Future phases (team selection, minigame, reward) slot into the same switch.

**Details:** The back button is hidden during a run; an **Abandon** action with confirmation replaces it. Phase views use `.id(run.id)` so **Play Again** resets all local view state.

## D7. Phase screens receive values and closures, not the session

**Decision:** `BattlePlaceholderView` and `GameOverView` take plain data and callbacks. Only `RunView` and `MainMenuView` read the environment.

**Why:** Screens stay reusable and previewable without constructing sessions, and coupling stays concentrated in one container view.

## D8. The placeholder battle lets the tester choose the result

**Decision:** `RunAction.resolveBattle(RunOutcome)` carries the outcome supplied by the UI.

**Why:** It allows the full Start -> Battle -> Game Over -> Restart flow to be exercised now. In Milestone 2 this becomes an engine-computed result from deterministic combat; the "Simulate" buttons are removed from the player path.

**Risk:** This is the only place a view decides an outcome. It is explicitly marked as temporary.

## D9. No persistence, minigames, or networking yet

**Decision:** Runs exist only in memory; quitting the app abandons a run. Minigames and GameKit are not implemented.

**Why:** The roadmap defers saves to post-playtest work and minigames to Milestone 3. Types are already `Codable` so later saving requires no model changes.

## D10. Tooling and platform

- **iOS 17 minimum**, iPhone only, portrait — required for Observation; matches the target platform.
- **Swift 6 language mode** — catches data races at compile time from day one.
- **Swift Testing** for GameCore tests — the current Apple test framework; parameterized tests cover both outcomes without duplication.
- **XcodeGen `project.yml`** instead of a committed `.xcodeproj` — a readable, merge-friendly project definition. Optional; manual Xcode setup is documented in the README.
- **SF Symbols and system styles** as placeholder art — supports Dynamic Type, Dark Mode and accessibility without custom assets.
