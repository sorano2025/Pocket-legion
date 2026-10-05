import Foundation
import Combine

// ============================================================
//  GameState — single source of truth for the whole app.
//  Persistence: Codable SaveData -> JSON file in Documents.
//  Simple, robust, easy to inspect and reset while developing.
//
//  MONETIZATION PLUG POINT: when ads/IAP ship, add purchased
//  flags (e.g. adsRemoved) to SaveData and gate ad calls here.
//
//  CLOUDKIT PLUG POINT: when cloud sync ships, replace
//  persist()/loadSave() with CKRecord encode/decode against a
//  private database; the rest of the app only talks to `save`.
// ============================================================

final class GameState: ObservableObject {

    @Published var save: SaveData
    @Published var navPath: [Screen] = []

    private let saveURL: URL = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("pocket-legion-save.json")

    static let maxUnitLevel = 10

    init() {
        if let data = try? Data(contentsOf: saveURL),
           let decoded = try? JSONDecoder().decode(SaveData.self, from: data) {
            save = decoded
        } else {
            // Fresh player starter kit: 5 units, 100 gold.
            save = SaveData(
                gold: 100,
                arenaIndex: 0,
                winStreak: 0,
                highestArena: 0,
                units: [
                    "rusty_shield": OwnedUnitData(level: 1, duplicates: 0),
                    "sling_rookie": OwnedUnitData(level: 1, duplicates: 0),
                    "patch_medic": OwnedUnitData(level: 1, duplicates: 0),
                    "ember_archer": OwnedUnitData(level: 1, duplicates: 0),
                    "iron_vanguard": OwnedUnitData(level: 1, duplicates: 0),
                ]
            )
        }
    }

    func persist() {
        try? JSONEncoder().encode(save).write(to: saveURL, options: .atomic)
    }

    /// Deletes the save and restarts fresh (handy while testing).
    func resetSave() {
        try? FileManager.default.removeItem(at: saveURL)
        save = SaveData(
            gold: 100, arenaIndex: 0, winStreak: 0, highestArena: 0,
            units: [
                "rusty_shield": OwnedUnitData(level: 1, duplicates: 0),
                "sling_rookie": OwnedUnitData(level: 1, duplicates: 0),
                "patch_medic": OwnedUnitData(level: 1, duplicates: 0),
                "ember_archer": OwnedUnitData(level: 1, duplicates: 0),
                "iron_vanguard": OwnedUnitData(level: 1, duplicates: 0),
            ]
        )
        navPath = []
    }

    // MARK: - Collection helpers

    func isOwned(_ id: String) -> Bool { save.units[id] != nil }

    func ownedLevel(of id: String) -> Int? { save.units[id]?.level }

    func ownedDuplicates(of id: String) -> Int { save.units[id]?.duplicates ?? 0 }

    /// Gold cost to upgrade a unit. Duplicates discount the price
    /// (10 gold off each) and are consumed on upgrade. -1 = maxed.
    func upgradeCost(for def: UnitDefinition) -> Int {
        guard let owned = save.units[def.id],
              owned.level < GameState.maxUnitLevel else { return -1 }
        let raw = 40 * owned.level * def.rarity.costMultiplier - 10 * owned.duplicates
        return max(10, raw)
    }

    @discardableResult
    func upgradeUnit(_ def: UnitDefinition) -> Bool {
        let cost = upgradeCost(for: def)
        guard cost > 0, save.gold >= cost, save.units[def.id] != nil else { return false }
        save.gold -= cost
        save.units[def.id]?.level += 1
        save.units[def.id]?.duplicates = 0
        persist()
        return true
    }

    // MARK: - Arena

    func nextSquad() -> EnemySquad {
        enemySquads[min(save.arenaIndex, enemySquads.count - 1)]
    }

    // MARK: - Battle results

    func applyBattleResult(won: Bool) -> BattleOutcome {
        if won {
            let streakBonus = 5 * min(save.winStreak, 5)
            let gold = 40 + 10 * save.arenaIndex + streakBonus
            save.gold += gold
            save.winStreak += 1

            var arenaAdvanced = false
            if save.arenaIndex < enemySquads.count - 1 {
                save.arenaIndex += 1
                arenaAdvanced = true
            }
            save.highestArena = max(save.highestArena, save.arenaIndex)

            var chest: ChestResult? = nil
            if Double.random(in: 0..<1) < 0.45 {
                chest = rollChest()
            }
            persist()
            return BattleOutcome(
                won: true, gold: gold, chest: chest,
                streak: save.winStreak, arenaAdvanced: arenaAdvanced
            )
        } else {
            save.gold += 10 // consolation
            save.winStreak = 0
            persist()
            return BattleOutcome(
                won: false, gold: 10, chest: nil,
                streak: 0, arenaAdvanced: false
            )
        }
    }

    private func rollChest() -> ChestResult {
        let id = unitDefinitions.randomElement()!.id
        if save.units[id] == nil {
            save.units[id] = OwnedUnitData(level: 1, duplicates: 0)
            return ChestResult(unitId: id, isNew: true, goldBonus: 0)
        } else {
            save.units[id]?.duplicates += 1
            save.gold += 20
            return ChestResult(unitId: id, isNew: false, goldBonus: 20)
        }
    }
}
