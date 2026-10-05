import AVFoundation

// ============================================================
//  SoundManager — all game audio in one place.
//  Short SFX fire-and-forget; background music loops quietly
//  underneath. Everything is local (no downloads, no cost).
// ============================================================

enum SFX: String, CaseIterable {
    case tap    // UI taps
    case hit    // melee / projectile impact
    case shoot  // ranged projectile fired
    case heal   // healer tick
    case chest  // chest opened
    case win    // victory fanfare
    case lose   // defeat sting
    case rally  // Rally ability
}

final class SoundManager {
    static let shared = SoundManager()

    private var sfxPlayers: [AVAudioPlayer] = []
    private var musicPlayer: AVAudioPlayer?
    private let maxSfxPlayers = 8

    private init() {
        // Allow mixing with other audio; game sounds take priority.
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    /// Fire-and-forget sound effect.
    func play(_ sfx: SFX, volume: Float = 1.0) {        guard let url = Bundle.module.url(
            forResource: sfx.rawValue,
            withExtension: "wav",
            subdirectory: "Audio"
        ) else { return }
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return }
        player.volume = volume
        player.play()
        sfxPlayers.append(player)
        if sfxPlayers.count > maxSfxPlayers {
            sfxPlayers.removeFirst(sfxPlayers.count - maxSfxPlayers)
        }
    }

    /// Unit voice bark, e.g. "Hold the line!".
    func playVoice(for unitId: String, volume: Float = 0.9) {
        guard let url = Bundle.module.url(
            forResource: "\(unitId)_voice",
            withExtension: "mp3",
            subdirectory: "Audio/voices"
        ) else { return }
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return }
        player.volume = volume
        player.play()
        sfxPlayers.append(player)
        if sfxPlayers.count > maxSfxPlayers {
            sfxPlayers.removeFirst(sfxPlayers.count - maxSfxPlayers)
        }
    }

    /// Start (or resume) background music. Prefers a real track at
    /// Audio/bgm.mp3 when present; otherwise the generative loop.
    func startMusic(volume: Float = 0.32) {
        if let url = Bundle.module.url(
            forResource: "bgm",
            withExtension: "mp3",
            subdirectory: "Audio"
        ) {
            if let musicPlayer = musicPlayer {
                if !musicPlayer.isPlaying { musicPlayer.play() }
                return
            }
            guard let player = try? AVAudioPlayer(contentsOf: url) else { return }
            player.numberOfLoops = -1
            player.volume = volume
            player.play()
            musicPlayer = player
            return
        }
        MusicBox.shared.start()
    }

    func stopMusic() {
        musicPlayer?.stop()
        MusicBox.shared.stop()
    }
}
