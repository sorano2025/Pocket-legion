import SwiftUI

@main
struct PocketLegionApp: App {
    @StateObject private var game = GameState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(game)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        NavigationStack(path: $game.navPath) {
            HomeView()
                .navigationDestination(for: Screen.self) { screen in
                    switch screen {
                    case .draft:
                        DraftView()
                    case .battle(let player, let enemy, let enemyName):
                        BattleView(playerSquad: player, enemySquad: enemy, enemyName: enemyName)
                    case .results(let outcome):
                        ResultsView(outcome: outcome)
                    case .collection:
                        CollectionView()
                    }
                }
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        VStack(spacing: 22) {
            Text("⚔️ POCKET LEGION")
                .font(.largeTitle)
                .bold()
                .padding(.top, 30)

            HStack(spacing: 6) {
                Text("🪙")
                Text("\(game.save.gold)")
                    .font(.title2)
                    .bold()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)

            let squad = game.nextSquad()
            VStack(spacing: 4) {
                Text("Arena \(game.save.arenaIndex + 1) of \(enemySquads.count)")
                    .font(.headline)
                Text("Next: \(squad.name)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack(spacing: 2) {
                    ForEach(squad.slots, id: \.self) { slot in
                        if let def = unitById[slot.unitId] {
                            def.art
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                        } else {
                            Text("?")
                                .font(.title3)
                        }
                    }
                }
                .font(.title3)
                if game.save.winStreak > 1 {
                    Text("🔥 \(game.save.winStreak)-win streak")
                        .font(.subheadline)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(14)
            .padding(.horizontal)

            Button(action: { game.navPath.append(.draft) }) {
                Text("⚔️  BATTLE")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(16)
            }
            .padding(.horizontal)

            Button(action: { game.navPath.append(.collection) }) {
                Text("🗂  Collection")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
            }
            .padding(.horizontal)

            Spacer()

            Text("Draft 5 units. They fight on their own.\nTap RALLY once per battle to turn the tide.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom)
    }
}
