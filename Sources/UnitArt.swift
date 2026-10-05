import SwiftUI
import SpriteKit
import UIKit

// ============================================================
//  UnitArt — bridges the bundled sprite PNGs (Resources/<id>.png)
//  into SwiftUI views and the SpriteKit battle scene.
// ============================================================

extension UnitDefinition {
    /// SwiftUI image for this unit's sprite.
    var art: Image {
        Image(id, bundle: .module)
    }
}

/// SpriteKit texture for a unit's sprite. Returns nil if the art
/// is missing, so callers can fall back to a plain colored disc.
func spriteTexture(for def: UnitDefinition) -> SKTexture? {
    guard let ui = UIImage(named: def.id, in: .module, with: nil) else {
        return nil
    }
    return SKTexture(image: ui)
}
