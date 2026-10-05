import AVFoundation

// ============================================================
//  MusicBox — a tiny generative music loop. No audio files:
//  an 8-bar upbeat loop (Am–F–C–G) is composed into a buffer
//  once, then looped forever through AVAudioEngine.
//  If a real track is ever dropped in as Audio/bgm.mp3,
//  SoundManager prefers it and this stays silent.
// ============================================================

final class MusicBox {
    static let shared = MusicBox()

    private let engine = AVAudioEngine()
    private var source: AVAudioSourceNode?
    private var playing = false

    private init() {}

    // MARK: - Composition

    private func midi(_ m: Int) -> Double {
        440.0 * pow(2.0, Double(m - 69) / 12.0)
    }

    /// Render the whole loop into one buffer. 132 BPM, 8 bars.
    private func renderLoop() -> [Float] {
        let sr = 44100.0
        let bpm = 132.0
        let step = 60.0 / bpm / 4.0          // 16th note
        let stepsPerBar = 16
        // (bass root midi, chord tones midi)
        let bars: [(Int, [Int])] = [
            (45, [57, 60, 64]),  // Am
            (45, [57, 60, 64]),
            (41, [53, 57, 60]),  // F
            (41, [53, 57, 60]),
            (48, [60, 64, 67]),  // C
            (48, [60, 64, 67]),
            (43, [55, 59, 62]),  // G
            (43, [55, 59, 62]),
        ]
        let total = Int(Double(bars.count * stepsPerBar) * step * sr)
        var buf = [Float](repeating: 0, count: total)

        func addNote(midi m: Int, at t: Double, dur: Double,
                     amp: Float, bright: Float) {
            let f = self.midi(m)
            let start = Int(t * sr)
            let n = min(Int(dur * sr), total - start)
            guard n > 0, start < total else { return }
            for i in 0..<n {
                let tt = Double(i) / sr
                let env = Float(exp(-tt * 6.0)) * min(1.0, Float(tt * 60.0) + 0.2)
                let s = sin(2.0 * .pi * f * tt)
                    + bright * 0.4 * sin(2.0 * .pi * f * 2.0 * tt)
                    + bright * 0.15 * sin(2.0 * .pi * f * 3.0 * tt)
                buf[start + i] += amp * env * Float(s) * 0.5
            }
        }

        func addHat(at t: Double, amp: Float) {
            let start = Int(t * sr)
            let n = min(Int(0.04 * sr), total - start)
            guard n > 0, start < total else { return }
            var seed: UInt32 = 12345
            for i in 0..<n {
                seed = seed &* 1103515245 &+ 12345
                let nz = Float(Int(seed >> 16) & 0x7FFF) / 32767.0 - 0.5
                let env = Float(exp(-Double(i) / sr * 220.0))
                buf[start + i] += amp * env * nz
            }
        }

        for (bar, (root, chord)) in bars.enumerated() {
            let barT = Double(bar * stepsPerBar) * step
            // Bass: driving 8ths, fifth on the back half.
            for e in 0..<8 {
                let m = (e == 3 || e == 7) ? root + 7 : root
                addNote(midi: m, at: barT + Double(e * 2) * step,
                        dur: step * 1.8, amp: 0.34, bright: 0.7)
            }
            // Lead: 16th arpeggio, octave pop near the bar end.
            for s in 0..<16 {
                var m = chord[[0, 1, 2, 1][s % 4]]
                if s == 14 { m += 12 }
                addNote(midi: m, at: barT + Double(s) * step,
                        dur: step * 1.4, amp: 0.20, bright: 1.0)
            }
            // Hats: 8ths, accents off-beat.
            for e in 0..<8 {
                addHat(at: barT + Double(e * 2) * step,
                       amp: e % 2 == 1 ? 0.10 : 0.06)
            }
        }

        // Gentle master normalize.
        let peak = buf.map(abs).max() ?? 1.0
        let g = min(1.0, 0.85 / peak)
        return buf.map { $0 * g }
    }

    // MARK: - Playback

    func start() {
        if playing { return }
        playing = true
        let loop = renderLoop()
        var pos = 0
        let node = AVAudioSourceNode { _, _, frameCount, audioBufferList in
            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for frame in 0..<Int(frameCount) {
                let s = loop[pos]
                pos = (pos + 1) % loop.count
                for buf in abl {
                    let ptr = buf.mData!.assumingMemoryBound(to: Float.self)
                    ptr[frame] = s
                }
            }
            return noErr
        }
        source = node
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: nil)
        engine.mainMixerNode.outputVolume = 0.5
        try? engine.start()
    }

    func stop() {
        engine.stop()
        if let source = source { engine.detach(source) }
        source = nil
        playing = false
    }
}
