
import Foundation

// MARK: - Question Type
enum QuestionType: String, Codable {
    case multipleChoice
    case audioLineup
}

// MARK: - Category
enum ClipCategory: String, Codable, CaseIterable {
    case instrument = "Instrument"
    case tempo      = "Tempo & Feel"
    case timeSig    = "Time Signature"
    case genre      = "Genre"
    case memory     = "Audio Lineup"
    case other      = "Other"

    var icon: String {
        switch self {
        case .instrument: return "music.note"
        case .tempo:      return "timer"
        case .timeSig:    return "metronome"
        case .genre:      return "guitars"
        case .memory:     return "waveform.badge.magnifyingglass"
        case .other:      return "waveform"
        }
    }
    var accentHex: String {
        switch self {
        case .instrument: return "#534AB7"
        case .tempo:      return "#D85A30"
        case .timeSig:    return "#1D9E75"
        case .genre:      return "#BA7517"
        case .memory:     return "#7B3FB8"
        case .other:      return "#888780"
        }
    }
    var bgHex: String {
        switch self {
        case .instrument: return "#EEEDFE"
        case .tempo:      return "#FAECE7"
        case .timeSig:    return "#E1F5EE"
        case .genre:      return "#FAEEDA"
        case .memory:     return "#F3EAFE"
        case .other:      return "#F1EFE8"
        }
    }
}

// MARK: - Difficulty
enum Difficulty: Int, Codable, CaseIterable {
    case easy   = 1
    case medium = 2
    case hard   = 3

    var label: String {
        switch self {
        case .easy:   return "Easy"
        case .medium: return "Medium"
        case .hard:   return "Hard"
        }
    }
    var timerSeconds: Int {
        switch self {
        case .easy:   return 30
        case .medium: return 25
        case .hard:   return 20
        }
    }
    var pointMultiplier: Double {
        switch self {
        case .easy:   return 1.0
        case .medium: return 1.5
        case .hard:   return 2.0
        }
    }
}

// MARK: - Multiple Choice Question
struct MultipleChoiceQuestion: Identifiable, Codable {
    let id: UUID
    let text: String
    let options: [String]
    let correctIndex: Int
    let basePoints: Int

    init(id: UUID = UUID(), text: String, options: [String],
         correctIndex: Int, basePoints: Int = 100) {
        self.id           = id
        self.text         = text
        self.options      = options
        self.correctIndex = correctIndex
        self.basePoints   = basePoints
    }
}

// MARK: - Audio Choice
struct AudioChoice: Identifiable, Codable {
    let id: UUID
    let label: String
    let description: String
    let fileName: String
    let isCorrect: Bool

    init(id: UUID = UUID(), label: String, description: String,
         fileName: String, isCorrect: Bool) {
        self.id          = id
        self.label       = label
        self.description = description
        self.fileName    = fileName
        self.isCorrect   = isCorrect
    }
}

// MARK: - Audio Lineup Question
struct AudioLineupQuestion: Identifiable, Codable {
    let id: UUID
    let promptText: String
    let choices: [AudioChoice]
    let basePoints: Int

    init(id: UUID = UUID(), promptText: String,
         choices: [AudioChoice], basePoints: Int = 150) {
        self.id         = id
        self.promptText = promptText
        self.choices    = choices
        self.basePoints = basePoints
    }

    var correctChoice: AudioChoice? { choices.first { $0.isCorrect } }
}

// MARK: - Clip
struct Clip: Identifiable, Codable {
    let id: UUID
    let name: String
    let fileName: String
    let category: ClipCategory
    let setName: String
    let questionType: QuestionType
    let difficulty: Difficulty
    let multipleChoiceQuestion: MultipleChoiceQuestion?
    let audioLineupQuestion: AudioLineupQuestion?

    var points: Int {
        let base: Int
        switch questionType {
        case .multipleChoice: base = multipleChoiceQuestion?.basePoints ?? 100
        case .audioLineup:    base = audioLineupQuestion?.basePoints ?? 150
        }
        return Int(Double(base) * difficulty.pointMultiplier)
    }

    init(id: UUID = UUID(), name: String, fileName: String,
         category: ClipCategory, setName: String,
         difficulty: Difficulty = .easy,
         question: MultipleChoiceQuestion) {
        self.id                     = id
        self.name                   = name
        self.fileName               = fileName
        self.category               = category
        self.setName                = setName
        self.questionType           = .multipleChoice
        self.difficulty             = difficulty
        self.multipleChoiceQuestion = question
        self.audioLineupQuestion    = nil
    }

    init(id: UUID = UUID(), name: String, fileName: String,
         category: ClipCategory, setName: String,
         difficulty: Difficulty = .easy,
         lineupQuestion: AudioLineupQuestion) {
        self.id                     = id
        self.name                   = name
        self.fileName               = fileName
        self.category               = category
        self.setName                = setName
        self.questionType           = .audioLineup
        self.difficulty             = difficulty
        self.multipleChoiceQuestion = nil
        self.audioLineupQuestion    = lineupQuestion
    }
}

// MARK: - Quiz Set
struct QuizSet: Identifiable {
    let id: UUID
    let name: String
    let category: ClipCategory
    let clips: [Clip]

    var maxPoints: Int        { clips.reduce(0) { $0 + $1.points } }
    var hasLineupRounds: Bool { clips.contains { $0.questionType == .audioLineup } }

    init(id: UUID = UUID(), name: String, category: ClipCategory, clips: [Clip]) {
        self.id       = id
        self.name     = name
        self.category = category
        self.clips    = clips
    }
}

// MARK: - Game Result
struct GameResult {
    let category: ClipCategory
    let correct: Bool
    let speedScore: Double
    let pointsEarned: Int
}

// MARK: - Musical IQ Score
struct MusicalIQScore {
    let overallIQ: Int
    let categoryScores: [ClipCategory: Int]
    let tierLabel: String
    let tierDescription: String
    let strongestCategory: ClipCategory?
    let weakestCategory: ClipCategory?

    static func calculate(results: [GameResult]) -> MusicalIQScore {
        let categories = Array(Set(results.map { $0.category }))
        var catScores: [ClipCategory: Int] = [:]

        for category in categories {
            let catResults  = results.filter { $0.category == category }
            guard !catResults.isEmpty else { continue }
            let accuracy    = Double(catResults.filter { $0.correct }.count) / Double(catResults.count)
            let avgSpeed    = catResults.map { $0.speedScore }.reduce(0, +) / Double(catResults.count)
            let streakBonus = min(Double(catResults.filter { $0.correct }.count) * 0.05, 0.15)
            catScores[category] = Int((accuracy * 0.60 + avgSpeed * 0.25 + streakBonus) * 100)
        }

        let avg = catScores.isEmpty ? 50.0 :
            Double(catScores.values.reduce(0, +)) / Double(catScores.count)
        let iq  = min(160, max(80, Int(80 + (avg / 100.0) * 80)))

        let strongest = catScores.max(by: { $0.value < $1.value })?.key
        let weakest   = catScores.min(by: { $0.value < $1.value })?.key
        let (label, desc) = tierInfo(for: iq)

        return MusicalIQScore(
            overallIQ: iq,
            categoryScores: catScores,
            tierLabel: label,
            tierDescription: desc,
            strongestCategory: strongest,
            weakestCategory: weakest
        )
    }

    private static func tierInfo(for iq: Int) -> (String, String) {
        switch iq {
        case 150...: return ("Maestro",          "Exceptional musical intelligence. You hear what others miss.")
        case 135...: return ("Virtuoso",         "Near-perfect across the board. Your ears are finely tuned.")
        case 120...: return ("Melodic Genius",   "Strong instincts and sharp listening skills.")
        case 110...: return ("Harmonic Thinker", "Above average ear — you pick up subtle musical details.")
        case 100...: return ("Rhythm Scholar",   "Solid foundation. A few categories to sharpen up.")
        case 90...:  return ("Developing Ear",   "You're building your musical intuition. Keep practicing!")
        default:     return ("Musical Explorer", "Everyone starts somewhere. More listening = more IQ points!")
        }
    }
}
