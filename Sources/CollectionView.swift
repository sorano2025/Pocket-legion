import SwiftUI

// ============================================================
//  Collection screen — every unit in the game. Owned units show
//  level, stats and an upgrade button; locked ones are silhouettes.
//  Upgrade cost: 40 x level x rarity multiplier, minus 10 gold
//  per duplicate (min 10). Duplicates are consumed on upgrade.
// ============================================================

struct CollectionView: View {
    @EnvironmentObject var game: GameState

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(unitDefinitions) { def in
                    if game.isOwned(def.id) {
                        VStack(spacing: 6) {
                            UnitCardView(
                                def: def,
                                level: game.ownedLevel(of: def.id),
                                duplicates: game.ownedDuplicates(of: def.id)
                            )
                            upgradeButton(for: def)
                        }
                    } else {
                        VStack(spacing: 6) {
                            VStack(spacing: 3) {
                                Text("❓")
                                    .font(.largeTitle)
                                Text("???")
                                    .font(.caption)
                                    .bold()
                                Text(def.rarity.displayName)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("Win chests to unlock")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(8)
                            .frame(width: 108, height: 148)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .opacity(0.6)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Collection")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func upgradeButton(for def: UnitDefinition) -> some View {
        let cost = game.upgradeCost(for: def)
        if cost < 0 {
            Text("MAX")
                .font(.caption)
                .bold()
                .foregroundColor(.yellow)
        } else {
            Button(action: { _ = game.upgradeUnit(def) }) {
                Text("⬆️ \(cost)🪙")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(game.save.gold >= cost ? Color.green : Color.gray)
                    .cornerRadius(8)
            }
            .disabled(game.save.gold < cost)
        }
    }
}
