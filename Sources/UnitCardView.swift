import SwiftUI

func rarityColor(_ rarity: Rarity) -> Color {
    switch rarity {
    case .common: return .gray
    case .rare: return .blue
    case .epic: return .purple
    }
}

/// Shared unit card used by the draft and collection screens.
struct UnitCardView: View {
    let def: UnitDefinition
    let level: Int?          // nil = show rarity instead of level
    let duplicates: Int

    var body: some View {
        VStack(spacing: 3) {
            Text(def.emoji)
                .font(.largeTitle)
            Text(def.name)
                .font(.caption)
                .bold()
                .lineLimit(1)
            if let level = level {
                Text("Lv \(level)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("HP \(Int(def.hp(at: level))) · ATK \(Int(def.attack(at: level)))")
                    .font(.caption2)
                if def.role == .healer {
                    Text("Heal \(Int(def.heal(at: level)))")
                        .font(.caption2)
                }
                if duplicates > 0 {
                    Text("×\(duplicates) dup")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            } else {
                Text(def.rarity.displayName)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Text(def.role.displayName)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .frame(width: 108)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(rarityColor(def.rarity), lineWidth: 2)
        )
    }
}
