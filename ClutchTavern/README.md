# Clutch Tavern (iPhone prototype)

Milestone 1 app shell for the vertical slice. See `docs/DECISIONS.md` for the design decisions behind it.

## Current flow

Main Menu -> Start Run -> Battle (placeholder) -> Game Over -> Play Again / Main Menu

The battle has no combat yet; the tester chooses victory or defeat. Minigames are intentionally not implemented.

## Layout

```text
App/              App entry point and root navigation
Application/      RunSession: the app's run state manager
Features/
  MainMenu/       Main menu screen
  Run/            Run container, placeholder battle, game over
Packages/GameCore Pure Swift rules (no SwiftUI) with Swift Testing tests
docs/             Architecture decision log
project.yml       XcodeGen project spec
```

## Requirements

- macOS with Xcode 16 or newer (Swift 6, Swift Testing)
- iOS 17 or later (uses the Observation framework)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) — optional but recommended

## Build and run

With XcodeGen:

```sh
xcodegen generate
open ClutchTavern.xcodeproj
```

Then select an iPhone simulator and run the `ClutchTavern` scheme.

Without XcodeGen, create a new iOS App project named `ClutchTavern` in Xcode (SwiftUI, Swift), delete its template Swift files, add the `App`, `Application` and `Features` folders, and add `Packages/GameCore` as a local package dependency.

## Tests

```sh
cd Packages/GameCore
swift test
```

Or open `Packages/GameCore/Package.swift` in Xcode and run tests with Cmd+U.

## Status

This code was written on Windows without access to Xcode, so it has not been compiled yet. Build it on a Mac and run the GameCore tests before starting Milestone 2.
