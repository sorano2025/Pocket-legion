import Foundation

// ============================================================
//  POCKET LEGION — GAME DATA
//  Tune the whole game from this file: unit stats, AI ladder,
//  rarities. Level scaling (+18%/level) lives in Models.swift.
// ============================================================

let unitDefinitions: [UnitDefinition] = [
    // ---------- COMMON ----------
    UnitDefinition(
        id: "rusty_shield", name: "Rusty Shield", emoji: "🛡️",
        rarity: .common, role: .tank,
        baseHP: 420, baseAttack: 22, attackSpeed: 0.7,
        range: 34, moveSpeed: 70, healPower: 0,
        blurb: "Old shield. Refuses to fall down."
    ),
    UnitDefinition(
        id: "sling_rookie", name: "Sling Rookie", emoji: "🪨",
        rarity: .common, role: .ranger,
        baseHP: 160, baseAttack: 26, attackSpeed: 0.9,
        range: 190, moveSpeed: 75, healPower: 0,
        blurb: "Throws rocks. Surprisingly accurate."
    ),
    UnitDefinition(
        id: "patch_medic", name: "Patch Medic", emoji: "💚",
        rarity: .common, role: .healer,
        baseHP: 200, baseAttack: 0, attackSpeed: 0,
        range: 200, moveSpeed: 75, healPower: 45,
        blurb: "Bandages, hope, and strong tea."
    ),

    // ---------- RARE ----------
    UnitDefinition(
        id: "ember_archer", name: "Ember Archer", emoji: "🏹",
        rarity: .rare, role: .ranger,
        baseHP: 220, baseAttack: 38, attackSpeed: 1.0,
        range: 210, moveSpeed: 80, healPower: 0,
        blurb: "Her arrows arrive already on fire."
    ),
    UnitDefinition(
        id: "iron_vanguard", name: "Iron Vanguard", emoji: "⚔️",
        rarity: .rare, role: .fighter,
        baseHP: 330, baseAttack: 40, attackSpeed: 0.9,
        range: 36, moveSpeed: 85, healPower: 0,
        blurb: "First in, last out."
    ),
    UnitDefinition(
        id: "swift_dagger", name: "Swift Dagger", emoji: "🗡️",
        rarity: .rare, role: .assassin,
        baseHP: 200, baseAttack: 55, attackSpeed: 1.3,
        range: 34, moveSpeed: 130, healPower: 0,
        blurb: "Targets the weakest. No mercy, no waiting."
    ),
    UnitDefinition(
        id: "oak_cleric", name: "Oak Cleric", emoji: "🌿",
        rarity: .rare, role: .healer,
        baseHP: 260, baseAttack: 0, attackSpeed: 0,
        range: 220, moveSpeed: 75, healPower: 70,
        blurb: "The oak bends so the squad doesn't break."
    ),

    // ---------- EPIC ----------
    UnitDefinition(
        id: "stormcaller", name: "Stormcaller", emoji: "⛈️",
        rarity: .epic, role: .ranger,
        baseHP: 280, baseAttack: 60, attackSpeed: 1.1,
        range: 230, moveSpeed: 85, healPower: 0,
        blurb: "Calls the storm. The storm answers."
    ),
    UnitDefinition(
        id: "warlords_blade", name: "Warlord's Blade", emoji: "🔥",
        rarity: .epic, role: .fighter,
        baseHP: 420, baseAttack: 68, attackSpeed: 1.0,
        range: 38, moveSpeed: 90, healPower: 0,
        blurb: "Forged for a warlord. Wielded by you."
    ),
    UnitDefinition(
        id: "granite_colossus", name: "Granite Colossus", emoji: "🗿",
        rarity: .epic, role: .tank,
        baseHP: 700, baseAttack: 45, attackSpeed: 0.6,
        range: 40, moveSpeed: 55, healPower: 0,
        blurb: "A walking mountain with opinions."
    ),
]

let unitById: [String: UnitDefinition] = Dictionary(
    uniqueKeysWithValues: unitDefinitions.map { ($0.id, $0) }
)

// ============================================================
//  AI LADDER — 10 squads, increasing difficulty.
//  cell: 0-5 on the enemy's 3x2 grid (mirrored from player's).
// ============================================================

let enemySquads: [EnemySquad] = [
    EnemySquad(name: "Rookie Raiders", slots: [
        SquadSlot(unitId: "rusty_shield", level: 1, cell: 0),
        SquadSlot(unitId: "sling_rookie", level: 1, cell: 1),
        SquadSlot(unitId: "patch_medic", level: 1, cell: 2),
        SquadSlot(unitId: "rusty_shield", level: 1, cell: 3),
        SquadSlot(unitId: "sling_rookie", level: 1, cell: 4),
    ]),
    EnemySquad(name: "Dust Devils", slots: [
        SquadSlot(unitId: "sling_rookie", level: 2, cell: 0),
        SquadSlot(unitId: "ember_archer", level: 1, cell: 1),
        SquadSlot(unitId: "rusty_shield", level: 2, cell: 3),
        SquadSlot(unitId: "patch_medic", level: 2, cell: 4),
        SquadSlot(unitId: "sling_rookie", level: 2, cell: 5),
    ]),
    EnemySquad(name: "Iron Pups", slots: [
        SquadSlot(unitId: "iron_vanguard", level: 2, cell: 0),
        SquadSlot(unitId: "ember_archer", level: 2, cell: 1),
        SquadSlot(unitId: "rusty_shield", level: 2, cell: 3),
        SquadSlot(unitId: "oak_cleric", level: 1, cell: 4),
        SquadSlot(unitId: "sling_rookie", level: 3, cell: 2),
    ]),
    EnemySquad(name: "Ember Band", slots: [
        SquadSlot(unitId: "ember_archer", level: 3, cell: 0),
        SquadSlot(unitId: "swift_dagger", level: 2, cell: 2),
        SquadSlot(unitId: "iron_vanguard", level: 2, cell: 3),
        SquadSlot(unitId: "patch_medic", level: 3, cell: 4),
        SquadSlot(unitId: "rusty_shield", level: 3, cell: 5),
    ]),
    EnemySquad(name: "Stone Fists", slots: [
        SquadSlot(unitId: "iron_vanguard", level: 3, cell: 0),
        SquadSlot(unitId: "oak_cleric", level: 2, cell: 1),
        SquadSlot(unitId: "ember_archer", level: 3, cell: 2),
        SquadSlot(unitId: "swift_dagger", level: 3, cell: 4),
        SquadSlot(unitId: "granite_colossus", level: 1, cell: 3),
    ]),
    EnemySquad(name: "Night Blades", slots: [
        SquadSlot(unitId: "swift_dagger", level: 4, cell: 0),
        SquadSlot(unitId: "warlords_blade", level: 2, cell: 2),
        SquadSlot(unitId: "oak_cleric", level: 3, cell: 1),
        SquadSlot(unitId: "ember_archer", level: 4, cell: 4),
        SquadSlot(unitId: "iron_vanguard", level: 3, cell: 3),
    ]),
    EnemySquad(name: "Storm Pack", slots: [
        SquadSlot(unitId: "stormcaller", level: 3, cell: 1),
        SquadSlot(unitId: "swift_dagger", level: 4, cell: 0),
        SquadSlot(unitId: "granite_colossus", level: 2, cell: 3),
        SquadSlot(unitId: "oak_cleric", level: 4, cell: 4),
        SquadSlot(unitId: "ember_archer", level: 4, cell: 2),
    ]),
    EnemySquad(name: "Crimson Guard", slots: [
        SquadSlot(unitId: "warlords_blade", level: 4, cell: 0),
        SquadSlot(unitId: "stormcaller", level: 4, cell: 2),
        SquadSlot(unitId: "granite_colossus", level: 3, cell: 3),
        SquadSlot(unitId: "oak_cleric", level: 4, cell: 4),
        SquadSlot(unitId: "swift_dagger", level: 5, cell: 1),
    ]),
    EnemySquad(name: "Titan Squad", slots: [
        SquadSlot(unitId: "granite_colossus", level: 4, cell: 3),
        SquadSlot(unitId: "warlords_blade", level: 5, cell: 0),
        SquadSlot(unitId: "stormcaller", level: 5, cell: 2),
        SquadSlot(unitId: "oak_cleric", level: 5, cell: 4),
        SquadSlot(unitId: "ember_archer", level: 5, cell: 1),
    ]),
    EnemySquad(name: "Warlord's Guard", slots: [
        SquadSlot(unitId: "granite_colossus", level: 6, cell: 3),
        SquadSlot(unitId: "warlords_blade", level: 6, cell: 0),
        SquadSlot(unitId: "stormcaller", level: 6, cell: 2),
        SquadSlot(unitId: "swift_dagger", level: 6, cell: 1),
        SquadSlot(unitId: "oak_cleric", level: 6, cell: 4),
    ]),
]
