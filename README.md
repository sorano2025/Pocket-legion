# ⚔️ Pocket Legion — iOS Game Prototype

An auto-battler-lite iOS game built with **pure SwiftUI + SpriteKit** — no dependencies, no backend.
Draft 5 units, watch them fight, loot chests, upgrade your squad, climb a 10-arena AI ladder.

## 5-minute setup in Xcode

You need: a Mac with Xcode 15+ and an Apple ID (free tier works).

**Fastest way (recommended):**
1. In Finder, double-click **`Package.swift`** in this folder — it opens the whole project in Xcode.
2. Wait for Xcode to finish resolving (a few seconds, no downloads — zero dependencies).
3. Pick a simulator (iPhone 15 or newer) → ⌘R. The game boots to the home screen.

**Manual way (if the package ever misbehaves):**
1. Xcode → File → New → Project → **iOS → App**
   - Product Name: `PocketLegion`, Interface: **SwiftUI**, Language: **Swift**, Storage: **None**
   - Uncheck "Include Tests" (or leave them — your call)
2. In Finder, open the `Sources/` folder from this package
   - Drag **all 11 `.swift` files** into your Xcode project navigator (drop them on the `PocketLegion` group)
   - In the import dialog: ✅ check **"Copy items if needed"**, ✅ check your app target
   - Delete the template `ContentView.swift` Xcode generated (we ship our own inside `PocketLegionApp.swift`)
3. Click the project → your app target → General → **Minimum Deployments: iOS 17.0**
4. Pick a simulator → ⌘R.

## Build to your physical iPhone (free Apple ID)

1. Connect your iPhone via cable. On the iPhone: trust the computer if asked.
2. In Xcode: Signing & Capabilities → Team → **Add Account…** → sign in with your Apple ID (no paid developer account needed).
3. Set a unique **Bundle Identifier** (e.g. `com.yourname.pocketlegion`).
4. Select your iPhone as the run destination → ⌘R.
5. First launch: iPhone → Settings → General → VPN & Device Management → trust your Apple ID → open the app.

> Free Apple IDs can install to their own devices for personal testing (apps expire after 7 days and need a rebuild — normal for free provisioning). For TestFlight/App Store distribution you'll need the $99/yr Apple Developer Program.

## How to play

1. **Home** — shows gold, current arena, and the next AI squad. Tap **BATTLE**.
2. **Draft** — tap a unit card, then tap a grid cell to place it (5 units on your 3×2 half). Tap a placed unit to remove it. Hit **START BATTLE**.
3. **Battle** — your squad (blue, bottom) fights the AI squad (red, top) automatically:
   - Tanks/Fighters close distance, Rangers shoot projectiles, Healers heal the most-damaged ally, Assassins hunt the weakest enemy.
   - **⚡ RALLY button** (once per battle): heals your whole team 30% and boosts attack speed 40% for 8 seconds. Time it for when you're losing.
4. **Results** — gold for wins (streaks pay more), 45% chance of a chest (new unit or duplicate→gold), arena unlocks on wins.
5. **Collection** — upgrade units with gold (cost scales by level × rarity; duplicates discount the price).

## Tuning the game

**Everything tunable lives in two files:**
- `Sources/Units.swift` — all 10 unit stats (HP, attack, speed, range, roles, rarities) and the 10 AI squads (names, unit levels, formations).
- `Sources/Models.swift` — level scaling formula (`+18% per level`), in `hp(at:)`, `attack(at:)`, `heal(at:)`.
- `Sources/GameState.swift` — economy: win gold (40 + 10×arena + streak bonus), loss consolation (10), chest chance (45%), upgrade cost formula.

## Resetting your save (while testing)

`GameState.resetSave()` wipes the JSON save in the app's Documents folder. To use it during development, call it once from a debug button or `onAppear` — then remove the call.

## Roadmap (marked in code)

- **Monetization** — search `MONETIZATION` in `GameState.swift`: rewarded video ads (chest speed-ups, revives), remove-ads IAP, gem packs, season pass.
- **Cloud sync** — search `CLOUDKIT` in `GameState.swift`: swap the JSON file for CloudKit `CKRecord`s; the rest of the app only talks to `save`, so the change is contained.
- **Async PvP ladder** — needs the backend above: upload squad + defense results, matchmake by arena level, overnight defense reports.

## Project structure

```
pocket-legion/
├── README.md            ← you are here
├── GAMEPLAN.md          ← full game design doc
├── Package.swift        ← ★ double-click this to open in Xcode
└── Sources/
    ├── PocketLegionApp.swift   ← app entry, nav stack, home screen
    ├── Models.swift            ← data types, save format, level scaling
    ├── Units.swift              ← ★ TUNE HERE: units, AI ladder
    ├── GameState.swift          ← gold, collection, arena, persistence
    ├── BattleScene.swift        ← ★ SpriteKit battle engine
    ├── BattleController.swift  ← SpriteKit ↔ SwiftUI bridge
    ├── BattleView.swift         ← battle screen + Rally button
    ├── DraftView.swift          ← squad drafting + formation
    ├── ResultsView.swift        ← win/lose, chest reveal
    ├── CollectionView.swift     ← unit upgrades
    ├── UnitCardView.swift       ← shared unit card UI
    ├── UnitArt.swift            ← sprite loading (SwiftUI + SpriteKit)
    └── Resources/               ← ★ 10 unit sprites (<unitId>.png)
```
