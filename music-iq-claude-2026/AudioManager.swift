import Foundation
import AVFoundation
import Combine

final class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {

    static let shared = AudioManager()

    @Published var isPlaying        = false
    @Published var currentFileID    = ""
    @Published var hasPlayed        = false
    /// True once the current clip has played all the way through — distinct from a manual
    /// pause, so callers can tell "can resume" from "nothing left to play."
    @Published var didFinishPlaying = false

    private var player: AVAudioPlayer?
    private var remotePlayer: AVPlayer?

    private let baseURL = "https://your-r2-bucket.r2.dev/"

    private override init() {
        super.init()
        configureSession()
    }

    private func configureSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func play(fileName: String, allowReplay: Bool = true) {
        guard allowReplay || !hasPlayed else { return }
        stopAll()
        currentFileID    = fileName
        hasPlayed        = true
        didFinishPlaying = false

        let base = (fileName as NSString).deletingPathExtension
        let ext  = (fileName as NSString).pathExtension

        if let url = Bundle.main.url(forResource: base, withExtension: ext, subdirectory: "Audio")
            ?? Bundle.main.url(forResource: base, withExtension: ext) {
            playLocal(url: url)
        } else if let url = URL(string: baseURL + fileName) {
            playRemote(url: url)
        }
    }

    private func playLocal(url: URL) {
        guard let p = try? AVAudioPlayer(contentsOf: url) else { return }
        player           = p
        player?.delegate = self
        player?.prepareToPlay()
        player?.play()
        DispatchQueue.main.async { self.isPlaying = true }
    }

    private func playRemote(url: URL) {
        let item     = AVPlayerItem(url: url)
        remotePlayer = AVPlayer(playerItem: item)
        remotePlayer?.play()
        DispatchQueue.main.async { self.isPlaying = true }
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item, queue: .main) { [weak self] _ in
                self?.isPlaying        = false
                self?.didFinishPlaying = true
        }
    }

    /// Pauses in place — unlike `stopAll()`, playback position is preserved so `resume()`
    /// continues from where it left off rather than restarting from the beginning.
    func pause() {
        player?.pause()
        remotePlayer?.pause()
        DispatchQueue.main.async { self.isPlaying = false }
    }

    /// Continues a paused clip from its current position. No-op if nothing is loaded.
    func resume() {
        guard player != nil || remotePlayer != nil else { return }
        player?.play()
        remotePlayer?.play()
        DispatchQueue.main.async { self.isPlaying = true }
    }

    func stopAll() {
        player?.stop()
        remotePlayer?.pause()
        player       = nil
        remotePlayer = nil
        DispatchQueue.main.async { self.isPlaying = false }
    }

    /// Synchronous by design (unlike the other methods here) — callers rely on `hasPlayed`
    /// being cleared immediately so a `play(..., allowReplay: false)` right after this call
    /// isn't blocked by its own now-stale guard.
    func resetMysteryState() {
        stopAll()
        hasPlayed     = false
        currentFileID = ""
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying        = false
            self.didFinishPlaying = true
        }
    }
}
