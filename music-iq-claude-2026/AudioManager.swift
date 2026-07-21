import Foundation
import AVFoundation
import Combine

final class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {

    static let shared = AudioManager()

    @Published var isPlaying      = false
    @Published var currentFileID  = ""
    @Published var hasPlayed      = false

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
        currentFileID = fileName
        hasPlayed     = true

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
                self?.isPlaying = false
        }
    }

    func stopAll() {
        player?.stop()
        remotePlayer?.pause()
        player       = nil
        remotePlayer = nil
        DispatchQueue.main.async { self.isPlaying = false }
    }

    func resetMysteryState() {
        stopAll()
        DispatchQueue.main.async {
            self.hasPlayed     = false
            self.currentFileID = ""
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { self.isPlaying = false }
    }
}
