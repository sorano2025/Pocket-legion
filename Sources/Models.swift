import Foundation

// MARK: - Teams

enum Team {
    case player
    case enemy
}

// MARK: - Rarity

enum Rarity: String, Codable, CaseIterable {
    case common
    case rare
    case epic

    var displayName: String { rawValue.capitalized }

    /// Gold-cost multiplier for upgrades.
    var costMultiplier: Int {
        switch self {
        case .common: return 1
        case .rare: return 2
        case .epic: return 3
        }
    }
}

// MARK: - Roles

enum Role: String, Codable, CaseIterable {
    case tank
    case fighter
    case ranger
    case healer
    case assassin

    var displayName: String { rawValue.capitalized }

    var description: String {
        switch self {
        case .tank: return "Soaks damage up front."
        case .fighter: return "Balanced melee damage."
        case .ranger: return "Attacks from range."
        case .healer: return "Heals the most damaged ally."
        case .assassin: return "Fast; hunts the weakest enemy."
        }
    }
}

// MARK: - Unit definition (static data, see Units.swift)

struct UnitDefinition: Identifiable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let rarity: Rarity
    let role: Role
    let baseHP: Double
    let baseAttack: Double
    /// Attacks per second. 0 for healers (they don't attack).
    let attackSpeed: Double
    /// Attack (or heal) range in scene points.
    let range: Double
    /// Movement speed in points per second.
    let moveSpeed: Double
    /// Amount healed per heal tick (healers only).
    let healPower: Double
    let blurb: String

    /// Level scaling: +18% per level above 1.
    func hp(at level: Int) -> Double {
        baseHP * (1.0 + 0.18 * Double(max(1, level) - 1))
    }

    func attack(at level: Int) -> Double {
        baseAttack * (1.0 + 0.18 * Double(max(1, level) - 1))
    }

    func heal(at level: Int) -> Double {
        healPower * (1.0 + 0.18 * Double(max(1, level) - 1))
    }
}

// MARK: - Player-owned units (persisted)

struct OwnedUnitData: Codable {
    var level: Int
    var duplicates: Int
}

// MARK: - Battle placement

struct PlacedUnit: Hashable {
    let unitId: String
    let level: Int
    let cell: Int          // 0-5, maps to a grid position
    let team: Team
}

// MARK: - AI squads

struct SquadSlot: Hashable {
    let unitId: String
    let level: Int
    let cell: Int
}

struct EnemySquad: Hashable {
    let name: String
    let slots: [SquadSlot]
}

// MARK: - Save data (persisted as JSON)

struct SaveData: Codable {
    var gold: Int
    var arenaIndex: Int     // index into enemySquads = NEXT opponent
    var winStreak: Int
    var highestArena: Int
    var units: [String: OwnedUnitData]  // unitId -> owned data
}

// MARK: - Navigation & battle results

enum Screen: Hashable {
    case draft
    case battle(player: [PlacedUnit], enemy: [PlacedUnit], enemyName: String)
    case results(BattleOutcome)
    case collection
}

struct ChestResult: Hashable {
    let unitId: String
    let isNew: Bool
    let goldBonus: Int
}

struct BattleOutcome: Hashable {
    let won: Bool
    let gold: Int
    let chest: ChestResult?
    let streak: Int
    let arenaAdvanced: Bool
}
