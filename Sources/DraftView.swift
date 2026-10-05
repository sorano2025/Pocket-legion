import SwiftUI

// ============================================================
//  Draft screen — pick 5 owned units and place them on your
//  half of the 3x2 grid. Tap a card, then tap a cell.
//  Tap a placed unit to remove it.
// ============================================================

struct DraftView: View {
    @EnvironmentObject var game: GameState
    @State private var selectedId: String? = nil
    @State private var placements: [Int: PlacedUnit] = [:]

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    private var ownedDefs: [UnitDefinition] {
        unitDefinitions
            .filter { game.isOwned($0.id) }
            .sorted { ($0.rarity.displayName, $0.name) < ($1.rarity.displayName, $1.name) }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Enemy preview
            let squad = game.nextSquad()
            VStack(spacing: 2) {
                Text("⚔️ vs \(squad.name)")
                    .font(.headline)
                HStack(spacing: 4) {
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
            }
            .padding(.top, 4)

            Text("Your formation — \(placements.count)/5 placed")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Placement grid (3 x 2)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(0..<6, id: \.self) { cell in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.12))
                            .frame(height: 84)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                        if let placed = placements[cell],
                           let def = unitById[placed.unitId] {
                            def.art
                                .resizable()
                                .scaledToFit()
                                .frame(width: 56, height: 56)
                        } else {
                            Text("＋")
                                .font(.title)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onTapGesture { tapCell(cell) }
                }
            }
            .padding(.horizontal)

            Text("Tap a unit, then tap a cell")
                .font(.caption)
                .foregroundColor(.secondary)

            // Collection picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(ownedDefs) { def in
                        let placed = placements.values.contains { $0.unitId == def.id }
                        UnitCardView(
                            def: def,
                            level: game.ownedLevel(of: def.id),
                            duplicates: game.ownedDuplicates(of: def.id)
                        )
                        .opacity(placed ? 0.35 : 1.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedId == def.id ? Color.green : Color.clear,
                                        lineWidth: 3)
                        )
                        .onTapGesture {
                            if placed { return }
                            selectedId = (selectedId == def.id) ? nil : def.id
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            Button(action: startBattle) {
                Text("⚔️ START BATTLE")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(placements.count == 5 ? Color.red : Color.gray)
                    .cornerRadius(16)
            }
            .disabled(placements.count != 5)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Draft Your Squad")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func tapCell(_ cell: Int) {
        if placements[cell] != nil {
            placements[cell] = nil
            SoundManager.shared.play(.tap, volume: 0.5)
            return
        }
        guard let sel = selectedId,
              !placements.values.contains(where: { $0.unitId == sel }) else { return }
        SoundManager.shared.play(.tap, volume: 0.5)
        placements[cell] = PlacedUnit(
            unitId: sel,
            level: game.ownedLevel(of: sel) ?? 1,
            cell: cell,
            team: .player
        )
        selectedId = nil
    }

    private func startBattle() {
        let squad = game.nextSquad()
        let enemyPlaced = squad.slots.map {
            PlacedUnit(unitId: $0.unitId, level: $0.level, cell: $0.cell, team: .enemy)
        }
        game.navPath.append(.battle(
            player: Array(placements.values),
            enemy: enemyPlaced,
            enemyName: squad.name
        ))
    }
}
