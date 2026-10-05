import SwiftUI
import SpriteKit

// ============================================================
//  BattleView — hosts the SpriteKit battle plus the one-tap
//  Rally ability button. When the scene reports the battle is
//  over, applies the result and pushes the results screen.
// ============================================================

struct BattleView: View {
    @EnvironmentObject var game: GameState

    let playerSquad: [PlacedUnit]
    let enemySquad: [PlacedUnit]
    let enemyName: String

    @StateObject private var controller: BattleController
    @State private var scene: BattleScene
    @State private var finished = false

    init(playerSquad: [PlacedUnit], enemySquad: [PlacedUnit], enemyName: String) {
        self.playerSquad = playerSquad
        self.enemySquad = enemySquad
        self.enemyName = enemyName
        let c = BattleController()
        _controller = StateObject(wrappedValue: c)
        let s = BattleScene(playerSquad: playerSquad, enemySquad: enemySquad, controller: c)
        _scene = State(initialValue: s)
        c.scene = s
    }

    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()

            VStack {
                Text("You  vs  \(enemyName)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.55))
                    .cornerRadius(10)
                    .padding(.top, 54)

                Spacer()

                Button(action: { controller.useRally() }) {
                    Text(controller.abilityUsed
                         ? "RALLY SPENT"
                         : "⚡ RALLY — team heal + attack boost")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(controller.abilityUsed ? Color.gray : Color.orange)
                        .cornerRadius(14)
                }
                .disabled(controller.abilityUsed || controller.battleOver)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: controller.battleOver) { _, newValue in
            guard newValue, !finished else { return }
            finished = true
            let outcome = game.applyBattleResult(won: controller.playerWon)
            game.navPath.append(.results(outcome))
        }
    }
}
