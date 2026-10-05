import SwiftUI

// ============================================================
//  Results screen — win/lose, gold earned, chest reveal,
//  arena progression. Battle Again re-drafts, Home pops all.
// ============================================================

struct ResultsView: View {
    @EnvironmentObject var game: GameState
    let outcome: BattleOutcome

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Text(outcome.won ? "🏆 VICTORY!" : "💀 DEFEAT")
                .font(.largeTitle)
                .bold()
                .foregroundColor(outcome.won ? .yellow : .secondary)

            HStack(spacing: 6) {
                Text("🪙")
                Text("+\(outcome.gold) gold")
                    .font(.title2)
                    .bold()
            }

            if outcome.streak > 1 {
                Text("🔥 \(outcome.streak)-win streak! (+5 gold per streak, max +25)")
                    .font(.subheadline)
            }

            if outcome.arenaAdvanced {
                Text("⬆️ New arena unlocked!")
                    .font(.headline)
                    .foregroundColor(.green)
            }

            if let chest = outcome.chest,
               let def = unitById[chest.unitId] {
                VStack(spacing: 6) {
                    Text("🎁 Chest opened!")
                        .font(.headline)
                    Text(def.emoji)
                        .font(.system(size: 64))
                    Text(def.name)
                        .bold()
                    Text(chest.isNew
                         ? "NEW UNIT added to your collection!"
                         : "Duplicate → +\(chest.goldBonus) gold")
                        .font(.subheadline)
                        .foregroundColor(chest.isNew ? .green : .orange)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
            }

            if !outcome.won {
                Text("Tip: upgrade your units or adjust your formation.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: { game.navPath = [.draft] }) {
                Text("⚔️ Battle Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(16)
            }
            .padding(.horizontal)

            Button(action: { game.navPath = [] }) {
                Text("🏠 Home")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationBarBackButtonHidden(true)
    }
}
