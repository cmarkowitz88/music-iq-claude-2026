
import Foundation

/// A snapshot of an in-progress quiz session, captured every time a new round begins (including
/// a failed-round retry). Leaving mid-round — backgrounding, dismissing, or the app getting
/// killed — and coming back resumes at the start of that same round rather than losing all
/// progress; anything mid-question (timer, audio playback, current answer) isn't restored,
/// since none of that means anything once the app's been away. Cleared once a full session
/// completes.
struct QuizProgressionSnapshot: Codable {
    let remainingByDifficulty: [Difficulty: [Clip]]
    let difficultyIndex: Int
    let roundCounts: [Difficulty: Int]
}

struct QuizSessionSnapshot: Codable {
    let currentRoundClips: [Clip]
    let currentRoundName: String
    let progression: QuizProgressionSnapshot
    let sessionScore: Int
    let sessionResults: [GameResult]
    let carryStreak: Int
    let carryBestStreak: Int
}

enum QuizPersistence {
    private static let key = "quizSessionSnapshot"

    static func save(_ snapshot: QuizSessionSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func load() -> QuizSessionSnapshot? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(QuizSessionSnapshot.self, from: data)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

/// Every passed round's results, accumulated across all sessions ever played, so the Home
/// screen can show a live, all-time Musical IQ rather than one that only appears at the end of
/// a session (which — like points before — would be unreachable in practice given how long a
/// full session actually is).
enum MusicalIQStore {
    private static let key = "allTimeGameResults"

    static func load() -> [GameResult] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let results = try? JSONDecoder().decode([GameResult].self, from: data) else { return [] }
        return results
    }

    static func append(_ results: [GameResult]) {
        var all = load()
        all.append(contentsOf: results)
        guard let data = try? JSONEncoder().encode(all) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
