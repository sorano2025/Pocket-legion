# ⚔️ Pocket Legion — Game Design Document

**Genre:** Auto-battler-lite (mobile) · **Platform:** iOS 17+ · **Engine:** SwiftUI + SpriteKit
**Session length:** ~2 minutes · **Monetization:** free-to-play, ads + IAP

---

## 1. Core loop

**Draft (30s)** → **Battle (~45s, auto)** → **Loot & upgrade** → **Climb**

1. Player drafts 5 units from their collection onto a 3×2 grid.
2. Units fight automatically — positioning and team composition are the strategy.
3. Win gold, open chests, upgrade units, beat the next arena squad.

The "one more run" engine: short sessions, constant progression (gold → upgrades → new units → next arena), and an async ladder where your squad defends overnight.

## 2. Battle system

- **Field:** vertical arena. Player (blue) bottom, enemy (red) top.
- **Targeting**
  - Tank / Fighter / Ranger → nearest enemy
  - Assassin → lowest-HP-fraction enemy
  - Healer → most-damaged ally in range (2s heal tick), otherwise drifts toward allies
- **Combat:** melee units close to range and hit instantly (with lunge animation); ranged units fire travelling projectiles. Attacks run on per-unit cooldowns derived from attack speed. Floating damage numbers, hit flashes, HP bars, death fades.
- **Player agency:** one active ability per battle — **⚡ Rally**: heals the whole team 30% of max HP and boosts attack speed 40% for 8 seconds. Timing it is the skill expression.
- **Win condition:** wipe the enemy squad. 1.2s slow-mo beat, then results.

## 3. Units (10 — tune in `Sources/Units.swift`)

Level scaling: **+18% HP/attack/heal per level** above 1 (see `Models.swift`).

| Unit | Emoji | Rarity | Role | HP | ATK | Spd | Range | Move | Notes |
|---|---|---|---|---|---|---|---|---|---|
| Rusty Shield | 🛡️ | Common | Tank | 420 | 22 | 0.7/s | 34 | 70 | Frontline sponge |
| Sling Rookie | 🪨 | Common | Ranger | 160 | 26 | 0.9/s | 190 | 75 | Cheap backline |
| Patch Medic | 💚 | Common | Healer | 200 | — | 2s tick | 200 | 75 | Heals 45/tick |
| Ember Archer | 🏹 | Rare | Ranger | 220 | 38 | 1.0/s | 210 | 80 | Reliable DPS |
| Iron Vanguard | ⚔️ | Rare | Fighter | 330 | 40 | 0.9/s | 36 | 85 | Bruiser |
| Swift Dagger | 🗡️ | Rare | Assassin | 200 | 55 | 1.3/s | 34 | 130 | Backline hunter |
| Oak Cleric | 🌿 | Rare | Healer | 260 | — | 2s tick | 220 | 75 | Heals 70/tick |
| Stormcaller | ⛈️ | Epic | Ranger | 280 | 60 | 1.1/s | 230 | 85 | Long-range nuke |
| Warlord's Blade | 🔥 | Epic | Fighter | 420 | 68 | 1.0/s | 38 | 90 | Premium bruiser |
| Granite Colossus | 🗿 | Epic | Tank | 700 | 45 | 0.6/s | 40 | 55 | The wall |

*(Stormcaller/Warlord's Blade/Granite Colossus are Epic.)*

**Design notes:** Assassins counter Rangers; Tanks protect Healers; focus-fire beats spread damage. Formation matters: glass cannons hide behind tanks.

## 4. AI ladder (10 arenas)

| # | Squad | Composition |
|---|---|---|
| 1 | Rookie Raiders | Commons, lvl 1 |
| 2 | Dust Devils | Commons lvl 2 + Ember Archer |
| 3 | Iron Pups | Iron Vanguard, Oak Cleric join |
| 4 | Ember Band | Swift Dagger appears |
| 5 | Stone Fists | First Epic (Colossus lvl 1) |
| 6 | Night Blades | Assassin-heavy |
| 7 | Storm Pack | Stormcaller + Colossus |
| 8 | Crimson Guard | Epic core, lvl 4–5 |
| 9 | Titan Squad | All lvl 4–5 |
| 10 | Warlord's Guard | Everything lvl 6 |

Beating a squad unlocks the next. Losing keeps you at the current arena (no punishment beyond the streak reset).

## 5. Economy

- **Win:** 40 + 10×arena gold, +5 per win-streak (max +25)
- **Loss:** 10 gold consolation, streak resets
- **Chest (45% on win):** random unit — new units join the collection at Lv 1; duplicates give +1 duplicate counter and +20 gold instantly
- **Upgrades:** cost = 40 × level × rarity multiplier (Common 1 / Rare 2 / Epic 3), minus 10 gold per duplicate (min 10). Duplicates are consumed on upgrade. Max level 10.
- **Starter kit:** 100 gold + Rusty Shield, Sling Rookie, Patch Medic, Ember Archer, Iron Vanguard

Economy target: a focused player unlocks a new unit every ~4–6 wins and upgrades every 2–3 wins. Tune in `GameState.swift`.

## 6. Monetization plan (post-prototype)

1. **Rewarded video ads** — open chests instantly, revive a lost battle, double win gold. (Highest LTV lever in the genre.)
2. **Remove Ads** — $2.99 one-time IAP.
3. **Gem packs** — $0.99–$9.99, speed up chests, buy gold.
4. **Season pass** — $4.99/season: exclusive unit skins, bonus chests, ladder rewards.

Code plug points are marked `MONETIZATION` in `GameState.swift`.

## 7. Tech roadmap

- **Now (prototype):** SwiftUI + SpriteKit, Codable JSON save in Documents. Zero dependencies, zero cost.
- **Next:** CloudKit private database for save sync (`CLOUDKIT` plug point in `GameState.swift` — the app only talks to `save`, so the swap is contained).
- **Then:** async PvP ladder — upload squad + formation, matchmake by arena, overnight defense reports, seasons.
- **Later:** GameKit leaderboards/achievements, more units, abilities per unit, guilds.

## 8. Tuning guide

| Want… | Change |
|---|---|
| Longer/shorter battles | unit HP/attack in `Units.swift` |
| Faster progression | gold/chest numbers in `GameState.applyBattleResult` |
| Cheaper/pricier upgrades | `upgradeCost(for:)` in `GameState.swift` |
| Harder/easier ladder | squad levels in `enemySquads` |
| Stronger/weaker Rally | `triggerRally()` in `BattleScene.swift` |
| Different level curve | `hp(at:)/attack(at:)/heal(at:)` in `Models.swift` |
