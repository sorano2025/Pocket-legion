import SpriteKit

// ============================================================
//  BattleScene — the auto-battler engine.
//  Player units (blue, bottom) vs enemy units (red, top).
//
//  Each unit, every frame:
//    - Healer  -> heals the most-damaged ally in range (2s tick)
//    - Assassin -> targets the lowest-HP-fraction enemy
//    - Others  -> target the nearest enemy
//  Melee units walk into range and hit instantly; ranged units
//  fire travelling projectiles. All targeting/movement/damage
//  happens here — SwiftUI only starts the scene and fires Rally.
// ============================================================

final class BattleUnit {
    let def: UnitDefinition
    let level: Int
    let team: Team
    let maxHP: Double
    var hp: Double
    let attack: Double
    let baseInterval: Double   // seconds between attacks
    var cooldown: Double
    var healCooldown: Double = 0
    var buffTimer: Double = 0  // Rally attack-speed buff
    var alive = true

    let container = SKNode()
    let sprite: SKSpriteNode
    let ring: SKShapeNode
    let hpBG: SKShapeNode
    let hpFG: SKShapeNode

    init(def: UnitDefinition, level: Int, team: Team, position: CGPoint) {
        self.def = def
        self.level = level
        self.team = team
        self.maxHP = def.hp(at: level)
        self.hp = maxHP
        self.attack = def.attack(at: level)
        self.baseInterval = def.attackSpeed > 0 ? 1.0 / def.attackSpeed : 999.0
        self.cooldown = Double.random(in: 0...0.4)

        let teamColor: SKColor = team == .player
            ? SKColor(red: 0.25, green: 0.55, blue: 1.0, alpha: 1.0)
            : SKColor(red: 1.0, green: 0.32, blue: 0.32, alpha: 1.0)

        // Team ring under the sprite — keeps sides readable at a glance.
        ring = SKShapeNode(circleOfRadius: 30)
        ring.strokeColor = teamColor
        ring.lineWidth = 3
        ring.fillColor = SKColor(white: 0, alpha: 0.25)
        ring.position = CGPoint(x: 0, y: -4)

        if let tex = spriteTexture(for: def) {
            sprite = SKSpriteNode(texture: tex)
        } else {
            // Fallback: plain team-colored disc if art is missing.
            sprite = SKSpriteNode(color: teamColor,
                                  size: CGSize(width: 44, height: 44))
        }
        sprite.size = CGSize(width: 62, height: 62)

        hpBG = SKShapeNode(rectOf: CGSize(width: 40, height: 6), cornerRadius: 3)
        hpBG.fillColor = SKColor(white: 0, alpha: 0.55)
        hpBG.strokeColor = .clear
        hpBG.position = CGPoint(x: 0, y: 32)

        hpFG = SKShapeNode(rectOf: CGSize(width: 40, height: 6), cornerRadius: 3)
        hpFG.fillColor = .green
        hpFG.strokeColor = .clear
        hpFG.position = CGPoint(x: 0, y: 32)

        container.addChild(ring)
        container.addChild(sprite)
        container.addChild(hpBG)
        container.addChild(hpFG)
        container.position = position

        // Spawn pop-in.
        container.setScale(0.1)
        container.run(SKAction.scale(to: 1.0, duration: 0.25))
    }

    /// Effective attack interval (Rally buff = 40% faster).
    var interval: Double {
        buffTimer > 0 ? baseInterval / 1.4 : baseInterval
    }

    func refreshBar() {
        let f = max(0.0, hp / maxHP)
        let cf = CGFloat(f)
        hpFG.xScale = cf
        hpFG.position.x = -20.0 * (1.0 - cf) // keep left edge anchored
        if f > 0.5 {
            hpFG.fillColor = .green
        } else if f > 0.25 {
            hpFG.fillColor = .yellow
        } else {
            hpFG.fillColor = .red
        }
    }
}

// ------------------------------------------------------------

final class BattleScene: SKScene {

    private var units: [BattleUnit] = []
    private var lastTime: TimeInterval = 0
    private var endTimer: Double = 0
    private var battleEnded = false
    private var abilityUsed = false
    weak var controller: BattleController?

    init(playerSquad: [PlacedUnit], enemySquad: [PlacedUnit], controller: BattleController) {
        self.controller = controller
        super.init(size: CGSize(width: 420, height: 740))
        scaleMode = .aspectFit
        backgroundColor = SKColor(red: 0.08, green: 0.09, blue: 0.13, alpha: 1.0)
        buildArena()
        for p in playerSquad { addUnit(p, team: .player) }
        for e in enemySquad { addUnit(e, team: .enemy) }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func cellPosition(cell: Int, team: Team) -> CGPoint {
        let col = cell % 3
        let row = cell / 3
        let x = CGFloat(70 + 140 * col)
        let y: CGFloat = team == .player
            ? CGFloat(110 + 100 * row)
            : CGFloat(630 - 100 * row)
        return CGPoint(x: x, y: y)
    }

    private func buildArena() {
        let line = SKShapeNode(rectOf: CGSize(width: 420, height: 4))
        line.fillColor = SKColor(white: 1.0, alpha: 0.25)
        line.strokeColor = .clear
        line.position = CGPoint(x: 210, y: 370)
        addChild(line)

        let bottom = SKShapeNode(rectOf: CGSize(width: 420, height: 300))
        bottom.fillColor = SKColor(red: 0.25, green: 0.55, blue: 1.0, alpha: 0.08)
        bottom.strokeColor = .clear
        bottom.position = CGPoint(x: 210, y: 160)
        addChild(bottom)

        let top = SKShapeNode(rectOf: CGSize(width: 420, height: 300))
        top.fillColor = SKColor(red: 1.0, green: 0.32, blue: 0.32, alpha: 0.08)
        top.strokeColor = .clear
        top.position = CGPoint(x: 210, y: 580)
        addChild(top)
    }

    private func addUnit(_ p: PlacedUnit, team: Team) {
        guard let def = unitById[p.unitId] else { return }
        let u = BattleUnit(def: def, level: p.level, team: team,
                           position: cellPosition(cell: p.cell, team: team))
        units.append(u)
        addChild(u.container)
    }

    // MARK: - Game loop

    override func update(_ currentTime: TimeInterval) {
        guard !battleEnded else { return }
        if lastTime == 0 { lastTime = currentTime }
        let dt = min(currentTime - lastTime, 1.0 / 20.0)
        lastTime = currentTime

        for u in units where u.alive {
            u.cooldown -= dt
            u.healCooldown -= dt
            if u.buffTimer > 0 { u.buffTimer -= dt }
            act(u, dt: dt)
            u.refreshBar()
        }

        let enemiesAlive = units.contains { $0.alive && $0.team == .enemy }
        let alliesAlive = units.contains { $0.alive && $0.team == .player }
        if !enemiesAlive || !alliesAlive {
            endTimer += dt
            if endTimer >= 1.2 {
                battleEnded = true
                controller?.battleDidEnd(won: alliesAlive && !enemiesAlive)
            }
        } else {
            endTimer = 0
        }
    }

    // MARK: - Unit AI

    private func act(_ u: BattleUnit, dt: Double) {
        if u.def.role == .healer {
            healerAct(u, dt: dt)
            return
        }
        guard let target = acquireTarget(for: u) else { return }
        let pos = u.container.position
        let tpos = target.container.position
        let dx = Double(tpos.x - pos.x)
        let dy = Double(tpos.y - pos.y)
        let dist = max(1.0, hypot(dx, dy))
        if dist <= u.def.range {
            if u.cooldown <= 0 {
                u.cooldown = u.interval
                strike(attacker: u, target: target)
            }
        } else {
            let step = min(u.def.moveSpeed * dt, dist - u.def.range * 0.85)
            let nx = pos.x + CGFloat(dx / dist * step)
            let ny = pos.y + CGFloat(dy / dist * step)
            u.container.position = CGPoint(x: nx, y: ny)
        }
    }

    private func acquireTarget(for u: BattleUnit) -> BattleUnit? {
        let foes = units.filter { $0.alive && $0.team != u.team }
        guard !foes.isEmpty else { return nil }
        if u.def.role == .assassin {
            // Hunts the weakest enemy.
            return foes.min { ($0.hp / $0.maxHP) < ($1.hp / $1.maxHP) }
        }
        let pos = u.container.position
        func d(_ v: BattleUnit) -> Double {
            let p = v.container.position
            return hypot(Double(p.x - pos.x), Double(p.y - pos.y))
        }
        return foes.min { d($0) < d($1) }
    }

    private func healerAct(_ u: BattleUnit, dt: Double) {
        let allies = units.filter { $0.alive && $0.team == u.team && $0 !== u }
        guard let target = allies
            .filter({ $0.hp < $0.maxHP })
            .min(by: { ($0.hp / $0.maxHP) < ($1.hp / $1.maxHP) })
        else { return }

        let pos = u.container.position
        let tpos = target.container.position
        let dx = Double(tpos.x - pos.x)
        let dy = Double(tpos.y - pos.y)
        let dist = max(1.0, hypot(dx, dy))

        if dist <= u.def.range {
            if u.healCooldown <= 0 {
                u.healCooldown = 2.0
                let amount = u.def.heal(at: u.level)
                target.hp = min(target.maxHP, target.hp + amount)
                target.refreshBar()
                SoundManager.shared.play(.heal, volume: 0.7)
                maybeVoice(for: u)
                floatText(at: tpos, text: "+\(Int(amount))", color: .green)
                let ring = SKShapeNode(circleOfRadius: 26)
                ring.strokeColor = .green
                ring.lineWidth = 3
                ring.position = tpos
                addChild(ring)
                ring.run(SKAction.sequence([
                    SKAction.scale(to: 1.4, duration: 0.3),
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.removeFromParent(),
                ]))
            }
        } else {
            // Drift toward the wounded ally.
            let step = min(u.def.moveSpeed * dt, dist - u.def.range * 0.85)
            let nx = pos.x + CGFloat(dx / dist * step)
            let ny = pos.y + CGFloat(dy / dist * step)
            u.container.position = CGPoint(x: nx, y: ny)
        }
    }

    // MARK: - Combat

    private var lastVoiceAt: Double = 0

    /// Occasional battle bark — throttled so units don't talk over each other.
    private func maybeVoice(for u: BattleUnit) {
        let now = Date().timeIntervalSince1970
        guard now - lastVoiceAt > 3.0 else { return }
        guard Double.random(in: 0...1) < 0.35 else { return }
        lastVoiceAt = now
        SoundManager.shared.playVoice(for: u.def.id)
    }

    private func strike(attacker: BattleUnit, target: BattleUnit) {
        let isRanged = attacker.def.range > 60
        maybeVoice(for: attacker)
        if isRanged {
            SoundManager.shared.play(.shoot, volume: 0.7)
            let proj = SKShapeNode(circleOfRadius: 5)
            proj.fillColor = attacker.team == .player ? .cyan : .orange
            proj.strokeColor = .clear
            proj.position = attacker.container.position
            proj.zPosition = 5
            addChild(proj)
            let dest = target.container.position
            let dist = max(1.0, hypot(Double(dest.x - proj.position.x),
                                      Double(dest.y - proj.position.y)))
            let duration = dist / 520.0
            proj.run(SKAction.sequence([
                SKAction.move(to: dest, duration: duration),
                SKAction.run { [weak self, weak target] in
                    guard let self = self, let target = target, target.alive else { return }
                    self.dealDamage(to: target, amount: attacker.attack)
                },
                SKAction.removeFromParent(),
            ]))
        } else {
            dealDamage(to: target, amount: attacker.attack)
            // Quick lunge for melee feel.
            let ap = attacker.container.position
            let tp = target.container.position
            let dx = Double(tp.x - ap.x)
            let dy = Double(tp.y - ap.y)
            let len = max(1.0, hypot(dx, dy))
            let ox = CGFloat(dx / len * 10.0)
            let oy = CGFloat(dy / len * 10.0)
            attacker.container.removeAction(forKey: "lunge")
            attacker.container.run(SKAction.sequence([
                SKAction.moveBy(x: ox, y: oy, duration: 0.07),
                SKAction.moveBy(x: -ox, y: -oy, duration: 0.09),
            ]), withKey: "lunge")
        }
    }

    private func dealDamage(to target: BattleUnit, amount: Double) {
        guard target.alive else { return }
        target.hp -= amount
        SoundManager.shared.play(.hit, volume: 0.8)
        flash(target)
        floatText(at: target.container.position, text: "-\(Int(amount))", color: .white)
        if target.hp <= 0 {
            target.hp = 0
            target.alive = false
            target.container.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.35),
                SKAction.removeFromParent(),
            ]))
        }
        target.refreshBar()
    }

    private func flash(_ u: BattleUnit) {
        // White hit-flash on the sprite (colorize pulse).
        u.sprite.run(SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.85,
                              duration: 0.05),
            SKAction.wait(forDuration: 0.07),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.08),
        ]))
    }

    private func floatText(at pos: CGPoint, text: String, color: SKColor) {
        let label = SKLabelNode(text: text)
        label.fontSize = 14
        label.fontColor = color
        label.position = CGPoint(x: pos.x, y: pos.y + 20)
        label.zPosition = 10
        addChild(label)
        label.run(SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 24, duration: 0.6),
                SKAction.fadeOut(withDuration: 0.6),
            ]),
            SKAction.removeFromParent(),
        ]))
    }

    // MARK: - Player ability: Rally (once per battle)

    /// Team-wide heal (30% max HP) + 40% attack speed for 8s.
    func triggerRally() {
        guard !abilityUsed, !battleEnded else { return }
        abilityUsed = true
        SoundManager.shared.play(.rally)
        for u in units where u.alive && u.team == .player {
            u.hp = min(u.maxHP, u.hp + u.maxHP * 0.30)
            u.buffTimer = 8.0
            u.refreshBar()
            floatText(at: u.container.position, text: "RALLY!", color: .yellow)
            let ring = SKShapeNode(circleOfRadius: 30)
            ring.strokeColor = .yellow
            ring.lineWidth = 4
            ring.position = u.container.position
            addChild(ring)
            ring.run(SKAction.sequence([
                SKAction.scale(to: 1.6, duration: 0.4),
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent(),
            ]))
        }
        DispatchQueue.main.async { [weak self] in
            self?.controller?.abilityUsed = true
        }
    }
}
