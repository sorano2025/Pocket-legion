import Foundation
import Combine

// ============================================================
//  BattleController — the bridge between SpriteKit and SwiftUI.
//  The scene reports battle end + ability state here on the main
//  thread; SwiftUI observes the @Published flags.
// ============================================================

final class BattleController: ObservableObject {
    @Published var abilityUsed = false
    @Published var battleOver = false
    @Published var playerWon = false

    weak var scene: BattleScene?

    func useRally() {
        scene?.triggerRally()
    }

    func battleDidEnd(won: Bool) {
        DispatchQueue.main.async {
            self.playerWon = won
            self.battleOver = true
        }
    }
}
