
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
