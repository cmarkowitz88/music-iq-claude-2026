
import SwiftUI
import AVFoundation
import Combine

// MARK: - Option State
enum OptionState: Equatable {
    case normal, selected, correct, wrong

    var bg: Color {
        switch self {
        case .normal:   return Color(.systemBackground)
        case .selected: return Color(hex: "#EEEDFE")
        case .correct:  return Color(hex: "#E1F5EE")
        case .wrong:    return Color(hex: "#FAECE7")
        }
    }
    var border: Color {
        switch self {
        case .normal:   return Color(.separator)
        case .selected: return Color(hex: "#534AB7")
        case .correct:  return Color(hex: "#0F6E56")
        case .wrong:    return Color(hex: "#993C1D")
        }
    }
    var text: Color {
        switch self {
        case .normal:   return .primary
        case .selected: return Color(hex: "#3C3489")
        case .correct:  return Color(hex: "#085041")
        case .wrong:    return Color(hex: "#4A1B0C")
        }
    }
    var letterBg: Color {
        switch self {
        case .normal: return Color(.systemFill)
        default:      return border
        }
    }
    var letterFg: Color {
        switch self {
        case .normal: return .secondary
        default:      return .white
        }
    }
}

// MARK: - Quiz View Model
@MainActor
final class QuizViewModel: ObservableObject {

    @Published var currentIndex: Int      = 0
    @Published var score: Int             = 0
    @Published var selectedOption: Int?   = nil
    @Published var answered: Bool         = false
    @Published var isCorrect: Bool        = false
    @Published var showFeedback: Bool     = false
    @Published var timerValue: Int        = 15
    @Published var timerProgress: Double  = 1.0
    @Published var streak: Int            = 0
    @Published var bestStreak: Int        = 0
    @Published var results: [Bool]        = []
    @Published var isFinished: Bool       = false
    @Published var sfxEnabled: Bool       = true
    @Published var mysteryPlayed: Bool    = false
    @Published var showLineup: Bool       = false
    @Published var playingChoiceId: UUID? = nil
    @Published var lockedChoiceIds: Set<UUID> = []
    @Published var hintUsed: Bool             = false
    @Published var eliminatedOptionIndex: Int? = nil
    @Published var eliminatedChoiceId: UUID?   = nil

    let quizSet: QuizSet
    var onComplete: (Int, [GameResult], Int, Int) -> Void
    var questionStartTime: Date = Date()

    private var timerTask: Task<Void, Never>?
    private var gameResults: [GameResult] = []
    private var timerStarted = false

    init(quizSet: QuizSet, initialStreak: Int = 0, initialBestStreak: Int = 0,
         onComplete: @escaping (Int, [GameResult], Int, Int) -> Void) {
        self.quizSet    = quizSet
        self.streak     = initialStreak
        self.bestStreak = initialBestStreak
        self.onComplete = onComplete
    }

    var currentClip: Clip { quizSet.clips[currentIndex] }
    var totalClips: Int   { quizSet.clips.count }

    var comboMessage: String? {
        streak >= 3 ? "🔥 \(streak)x combo!" : streak >= 2 ? "⚡ \(streak)x combo!" : nil
    }
    var bonusMultiplier: Double {
        streak >= 3 ? 2.0 : streak >= 2 ? 1.5 : 1.0
    }

    var hintAvailable: Bool {
        !hintUsed && !answered && !(currentClip.hint?.isEmpty ?? true)
    }

    /// Eliminates one wrong option (or wrong lineup choice) at random and reveals the clip's
    /// hint text. Only usable once per question, before it's answered.
    func useHint() {
        guard hintAvailable else { return }
        hintUsed = true

        switch currentClip.questionType {
        case .multipleChoice:
            guard let q = currentClip.multipleChoiceQuestion else { return }
            let wrongIndices = q.options.indices.filter { $0 != q.correctIndex }
            eliminatedOptionIndex = wrongIndices.randomElement()
            if selectedOption == eliminatedOptionIndex { selectedOption = nil }
        case .audioLineup:
            guard let lu = currentClip.audioLineupQuestion else { return }
            guard let toRemove = lu.choices.filter({ !$0.isCorrect }).randomElement() else { return }
            eliminatedChoiceId = toRemove.id
            if playingChoiceId == toRemove.id {
                AudioManager.shared.stopAll()
                playingChoiceId = nil
            }
            if let idx = lu.choices.firstIndex(where: { $0.id == toRemove.id }), selectedOption == idx {
                selectedOption = nil
            }
        }
    }

    func startTimer() {
        timerTask?.cancel()
        let seconds   = currentClip.timerSeconds
        timerValue    = seconds
        timerProgress = 1.0
        timerTask = Task { [weak self] in
            for remaining in stride(from: seconds, through: 0, by: -1) {
                guard !Task.isCancelled, let self else { return }
                await MainActor.run {
                    self.timerValue    = remaining
                    self.timerProgress = Double(remaining) / Double(seconds)
                    if remaining <= 5 { self.sfxTick() }
                    if remaining == 0 { self.timeUp() }
                }
                if remaining == 0 { return }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }

    func stopTimer() { timerTask?.cancel(); timerTask = nil }

    /// Shows the full countdown duration for the upcoming question without starting it —
    /// the clock only actually starts once the user taps play.
    func resetTimerDisplay() {
        timerValue    = currentClip.timerSeconds
        timerProgress = 1.0
    }

    /// Starts the countdown the first time the user plays the clip; later replays don't
    /// restart it.
    func startTimerIfNeeded() {
        guard !timerStarted else { return }
        timerStarted      = true
        questionStartTime = Date()
        startTimer()
    }

    func timeUp() {
        guard !answered else { return }
        AudioManager.shared.stopAll()
        playingChoiceId = nil
        answered     = true
        isCorrect    = false
        showFeedback = true
        streak       = 0
        results.append(false)
        sfxWrong()
        gameResults.append(GameResult(category: currentClip.category,
                                      correct: false, speedScore: 0, pointsEarned: 0))
    }

    func selectOption(_ index: Int) {
        guard !answered else { return }
        selectedOption = index
    }

    func submitAnswer() {
        guard !answered, let sel = selectedOption else { return }
        stopTimer()
        AudioManager.shared.stopAll()
        playingChoiceId = nil
        answered = true

        let correct: Bool
        switch currentClip.questionType {
        case .multipleChoice:
            correct = sel == (currentClip.multipleChoiceQuestion?.correctIndex ?? -1)
        case .audioLineup:
            correct = currentClip.audioLineupQuestion?.choices[sel].isCorrect == true
        }

        isCorrect    = correct
        showFeedback = true

        let elapsed = Date().timeIntervalSince(questionStartTime)
        let speed   = max(0, min(1.0, 1.0 - elapsed / Double(currentClip.timerSeconds)))
        var earned  = 0

        if correct {
            streak += 1
            if streak > bestStreak { bestStreak = streak }
            earned  = Int(Double(currentClip.points) * bonusMultiplier)
            score  += earned
            streak >= 3 ? sfxCombo() : sfxCorrect()
        } else {
            streak = 0
            sfxWrong()
        }

        results.append(correct)
        gameResults.append(GameResult(category: currentClip.category,
                                      correct: correct, speedScore: speed,
                                      pointsEarned: earned))
    }

    func advance() {
        AudioManager.shared.stopAll()
        playingChoiceId = nil
        if currentIndex + 1 >= totalClips {
            isFinished = true
            onComplete(score, gameResults, streak, bestStreak)
        } else {
            currentIndex   += 1
            selectedOption  = nil
            answered        = false
            isCorrect       = false
            showFeedback    = false
            mysteryPlayed   = false
            showLineup      = false
            timerStarted    = false
            hintUsed              = false
            eliminatedOptionIndex = nil
            eliminatedChoiceId    = nil
            lockedChoiceIds       = []
            questionStartTime = Date()
            resetTimerDisplay()
        }
    }

    /// Falls back to this when a clip has no real `trackLengthSeconds` (e.g. hand-written
    /// sample data that predates the imported duration field).
    private static let fallbackPlaybackSeconds = 3.0

    func playMystery() {
        guard !mysteryPlayed else { return }
        mysteryPlayed = true
        // AudioManager's own no-replay guard is keyed off a single global flag that's never
        // otherwise reset — clear it here so an earlier clip played anywhere else in the app
        // doesn't block this one. `mysteryPlayed` above is what actually enforces "once per
        // question."
        AudioManager.shared.resetMysteryState()
        AudioManager.shared.play(fileName: currentClip.fileName, allowReplay: false)
        let seconds = currentClip.trackLengthSeconds > 0
            ? Double(currentClip.trackLengthSeconds) : Self.fallbackPlaybackSeconds
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            await MainActor.run {
                self?.showLineup = true
                self?.startTimer()
            }
        }
    }

    /// Mirrors the multiple-choice play button: a choice can be paused and resumed freely
    /// (position preserved, using its own real length to know when it's actually finished),
    /// but once it's finished — or abandoned in favor of a different choice, whose playback
    /// can't be resumed once AudioManager's single player has moved on — it locks for good.
    func toggleChoice(_ choice: AudioChoice) {
        guard !lockedChoiceIds.contains(choice.id) else { return }
        let audio = AudioManager.shared
        let isCurrent = playingChoiceId == choice.id

        if isCurrent && audio.isPlaying {
            audio.pause()
        } else if isCurrent && !audio.didFinishPlaying {
            audio.resume()
        } else {
            if let previous = playingChoiceId, previous != choice.id {
                lockedChoiceIds.insert(previous)
            }
            playingChoiceId = choice.id
            audio.play(fileName: choice.fileName)
        }
    }

    private func sfxCorrect() { guard sfxEnabled else { return }; playSFX([523,659,784],      [0.1,0.1,0.15]) }
    private func sfxCombo()   { guard sfxEnabled else { return }; playSFX([523,659,784,1047], [0.08,0.08,0.08,0.2]) }
    private func sfxWrong()   { guard sfxEnabled else { return }; playSFX([220,180],           [0.15,0.2], sawtooth: true) }
    private func sfxTick()    { guard sfxEnabled else { return }; playSFX([880],               [0.06]) }

    private func playSFX(_ freqs: [Float], _ durs: [Float], sawtooth: Bool = false) {
        let sr: Double = 44100
        var samples: [Float] = []
        for (i, freq) in freqs.enumerated() {
            let dur   = Double(i < durs.count ? durs[i] : 0.1)
            let count = Int(sr * dur)
            for j in 0..<count {
                let t   = Float(j) / Float(sr)
                let env = 1.0 - Float(j) / Float(count)
                let v: Float = sawtooth
                    ? (2 * (freq * t - floor(freq * t + 0.5))) * 0.12 * env
                    : sin(2 * .pi * freq * t) * 0.18 * env
                samples.append(v)
            }
        }
        guard let fmt = AVAudioFormat(standardFormatWithSampleRate: sr, channels: 1),
              let buf = AVAudioPCMBuffer(pcmFormat: fmt, frameCapacity: AVAudioFrameCount(samples.count))
        else { return }
        buf.frameLength = buf.frameCapacity
        let ch = buf.floatChannelData![0]
        samples.enumerated().forEach { ch[$0.offset] = $0.element }
        let engine = AVAudioEngine()
        let node   = AVAudioPlayerNode()
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: fmt)
        try? engine.start()
        node.scheduleBuffer(buf)
        node.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { _ = engine }
    }
}

// MARK: - Round Outcome
struct RoundOutcome: Identifiable {
    let id = UUID()
    let round: QuizSet
    let score: Int
    let results: [GameResult]
    let correctCount: Int
    let requiredCount: Int
    let passed: Bool
    let streak: Int
    let bestStreak: Int
    var totalCount: Int { round.clips.count }
}

// MARK: - Quiz Progression
/// Hands out successive rounds of `roundSize` clips, one difficulty tier at a time
/// (easy → medium → hard). A tier keeps producing fresh rounds for as long as it has
/// enough unused clips left to fill one; once it can't, the next tier takes over. The
/// session runs out of rounds once every tier is short on remaining content.
final class QuizProgression {
    static let roundSize = 12
    static let passRatio = 0.75

    static func requiredCorrect(for roundSize: Int) -> Int {
        Int((Double(roundSize) * passRatio).rounded(.up))
    }

    private let difficulties: [Difficulty] = Difficulty.allCases.sorted { $0.rawValue < $1.rawValue }
    private var remaining: [Difficulty: [Clip]]
    private var roundCounts: [Difficulty: Int] = [:]
    private var difficultyIndex = 0

    init(clips: [Clip]) {
        remaining = Dictionary(grouping: clips, by: \.difficulty)
    }

    /// True if calling `nextRound()` right now would return a round rather than nil.
    var hasMoreRounds: Bool {
        guard difficultyIndex < difficulties.count else { return false }
        return difficulties[difficultyIndex...].contains {
            (remaining[$0]?.count ?? 0) >= Self.roundSize
        }
    }

    func nextRound() -> QuizSet? {
        while difficultyIndex < difficulties.count {
            let difficulty = difficulties[difficultyIndex]
            var pool = remaining[difficulty] ?? []
            guard pool.count >= Self.roundSize else {
                difficultyIndex += 1
                continue
            }
            pool.shuffle()
            remaining[difficulty] = Array(pool.dropFirst(Self.roundSize))
            roundCounts[difficulty, default: 0] += 1

            let name = "\(difficulty.label) Round \(roundCounts[difficulty]!)"
            return QuizSet(name: name, category: .other, clips: Array(pool.prefix(Self.roundSize)))
        }
        return nil
    }
}

// MARK: - Quiz Session View Model
@MainActor
final class QuizSessionViewModel: ObservableObject {
    @Published var currentRound: QuizSet?
    @Published var pendingOutcome: RoundOutcome?
    @Published var isFinished = false

    private(set) var sessionScore = 0
    private(set) var sessionResults: [GameResult] = []
    private(set) var carryStreak = 0
    private(set) var carryBestStreak = 0

    private let progression: QuizProgression
    let onComplete: (Int, [GameResult]) -> Void

    var hasMoreRoundsAvailable: Bool { progression.hasMoreRounds }

    init(clips: [Clip], onComplete: @escaping (Int, [GameResult]) -> Void) {
        self.progression = QuizProgression(clips: clips)
        self.onComplete  = onComplete
        self.currentRound = progression.nextRound()
    }

    func handleRoundComplete(score: Int, results: [GameResult], streak: Int, bestStreak: Int) {
        guard let round = currentRound else { return }
        let correct  = results.filter { $0.correct }.count
        let required = QuizProgression.requiredCorrect(for: round.clips.count)
        pendingOutcome = RoundOutcome(round: round, score: score, results: results,
                                       correctCount: correct, requiredCount: required,
                                       passed: correct >= required, streak: streak, bestStreak: bestStreak)
    }

    func continueAfterOutcome() {
        guard let outcome = pendingOutcome else { return }
        pendingOutcome = nil
        carryBestStreak = max(carryBestStreak, outcome.bestStreak)

        if outcome.passed {
            sessionScore   += outcome.score
            sessionResults += outcome.results
            carryStreak      = outcome.streak
            if let next = progression.nextRound() {
                currentRound = next
            } else {
                onComplete(sessionScore, sessionResults)
                isFinished = true
            }
        } else {
            // Redo the same clips in a new order — the streak that led to this failed
            // attempt doesn't carry into the reset the retry represents.
            carryStreak  = 0
            currentRound = QuizSet(name: outcome.round.name, category: outcome.round.category,
                                    clips: outcome.round.clips.shuffled())
        }
    }
}

// MARK: - Quiz Session View
struct QuizSessionView: View {
    @StateObject private var vm: QuizSessionViewModel

    init(clips: [Clip], onComplete: @escaping (Int, [GameResult]) -> Void) {
        _vm = StateObject(wrappedValue: QuizSessionViewModel(clips: clips, onComplete: onComplete))
    }

    var body: some View {
        Group {
            if let outcome = vm.pendingOutcome {
                RoundOutcomeView(outcome: outcome, hasMoreRounds: vm.hasMoreRoundsAvailable) {
                    vm.continueAfterOutcome()
                }
            } else if let round = vm.currentRound {
                QuizView(quizSet: round, initialStreak: vm.carryStreak, initialBestStreak: vm.carryBestStreak) { score, results, streak, bestStreak in
                    vm.handleRoundComplete(score: score, results: results, streak: streak, bestStreak: bestStreak)
                }
                .id(round.id)
            } else {
                VStack(spacing: 16) {
                    Text("No quiz content available.")
                        .font(.system(size: 15)).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            }
        }
        .navigationDestination(isPresented: $vm.isFinished) {
            Text("MusicIQ Results — coming next!")
                .navigationBarHidden(false)
        }
    }
}

// MARK: - Round Outcome View
struct RoundOutcomeView: View {
    let outcome: RoundOutcome
    let hasMoreRounds: Bool
    let onContinue: () -> Void

    private var continueLabel: String {
        guard outcome.passed else { return "Try again" }
        return hasMoreRounds ? "Next round →" : "See my MusicIQ →"
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle()
                    .fill(outcome.passed ? Color(hex: "#E1F5EE") : Color(hex: "#FAECE7"))
                    .frame(width: 88, height: 88)
                Image(systemName: outcome.passed ? "checkmark" : "arrow.counterclockwise")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundColor(outcome.passed ? Color(hex: "#0F6E56") : Color(hex: "#993C1D"))
            }
            VStack(spacing: 6) {
                Text(outcome.passed ? "Round passed!" : "Round failed")
                    .font(.system(size: 20, weight: .medium))
                Text("\(outcome.correctCount) of \(outcome.totalCount) correct — you need \(outcome.requiredCount) to pass.")
                    .font(.system(size: 14)).foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                if !outcome.passed {
                    Text("Let's give this round another shot.")
                        .font(.system(size: 13)).foregroundColor(.secondary)
                }
            }
            Spacer()
            Button(action: onContinue) {
                Text(continueLabel)
                    .font(.system(size: 15, weight: .medium)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 13)
                    .background(Color(hex: "#534AB7")).cornerRadius(12)
            }
        }
        .padding(24)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Quiz View
struct QuizView: View {
    @StateObject private var vm: QuizViewModel
    @Environment(\.dismiss) private var dismiss

    init(quizSet: QuizSet, initialStreak: Int = 0, initialBestStreak: Int = 0,
         onComplete: @escaping (Int, [GameResult], Int, Int) -> Void) {
        _vm = StateObject(wrappedValue: QuizViewModel(quizSet: quizSet, initialStreak: initialStreak,
                                                       initialBestStreak: initialBestStreak, onComplete: onComplete))
    }

    var body: some View {
        VStack(spacing: 0) {
            QuizTopBar(vm: vm, dismiss: dismiss)
            QuizProgressBar(vm: vm)
            ScrollView {
                VStack(spacing: 14) {
                    switch vm.currentClip.questionType {
                    case .multipleChoice: MCQuestionView(vm: vm)
                    case .audioLineup:    LineupQuestionView(vm: vm)
                    }
                }
                .id(vm.currentClip.id)
                .padding(16)
            }
            QuizActionBar(vm: vm)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .onAppear {
            vm.questionStartTime = Date()
            vm.resetTimerDisplay()
        }
    }
}

// MARK: - Top Bar
struct QuizTopBar: View {
    @ObservedObject var vm: QuizViewModel
    let dismiss: DismissAction
    var body: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14)).foregroundColor(.secondary)
                    .padding(8).background(Color(.systemFill)).clipShape(Circle())
            }
            Spacer()
            Text(vm.quizSet.name).font(.system(size: 15, weight: .medium)).lineLimit(1)
            Spacer()
            HStack(spacing: 8) {
                Button { vm.sfxEnabled.toggle() } label: {
                    Image(systemName: vm.sfxEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .font(.system(size: 13))
                        .foregroundColor(vm.sfxEnabled ? Color(hex: "#534AB7") : .secondary)
                }
                Text("\(vm.score) pts")
                    .font(.system(size: 13, weight: .medium))
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color(hex: "#EEEDFE"))
                    .foregroundColor(Color(hex: "#3C3489"))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(Divider(), alignment: .bottom)
    }
}

// MARK: - Progress Bar
struct QuizProgressBar: View {
    @ObservedObject var vm: QuizViewModel
    var timerColor: Color {
        vm.timerProgress > 0.5 ? Color(hex: "#534AB7") :
        vm.timerProgress > 0.25 ? Color(hex: "#BA7517") : Color(hex: "#E24B4A")
    }
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Question \(vm.currentIndex + 1) of \(vm.totalClips)")
                    .font(.system(size: 12)).foregroundColor(.secondary)
                Spacer()
                Text("\(vm.timerValue)s")
                    .font(.system(size: 12, weight: .medium)).foregroundColor(timerColor)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2).fill(Color(.systemFill)).frame(height: 4)
                    RoundedRectangle(cornerRadius: 2).fill(timerColor)
                        .frame(width: geo.size.width * vm.timerProgress, height: 4)
                        .animation(.linear(duration: 1), value: vm.timerProgress)
                }
            }.frame(height: 4)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(0..<vm.totalClips, id: \.self) { i in
                        Circle().fill(dotColor(i)).frame(width: 10, height: 10)
                            .animation(.spring(), value: vm.results.count)
                    }
                }
            }
        }
        .padding(.horizontal, 16).padding(.top, 10).padding(.bottom, 6)
    }
    func dotColor(_ i: Int) -> Color {
        i < vm.results.count ? (vm.results[i] ? Color(hex: "#1D9E75") : Color(hex: "#E24B4A")) :
        i == vm.currentIndex ? Color(hex: "#534AB7") : Color(.systemFill)
    }
}

// MARK: - Multiple Choice
struct MCQuestionView: View {
    @ObservedObject var vm: QuizViewModel
    @ObservedObject private var audio = AudioManager.shared
    @State private var hasPlayedOnce = false
    let letters = ["A","B","C","D","E","F"]

    /// Whether AudioManager's current playback state actually belongs to this clip (it's a
    /// shared singleton, so this guards against stale state left over from a previous clip).
    private var isCurrentClip: Bool { audio.currentFileID == vm.currentClip.fileName }
    private var isPlaying: Bool     { isCurrentClip && audio.isPlaying }
    /// True once this clip has played all the way through — at that point there's nothing
    /// left to resume, so the button locks rather than allowing a restart from the beginning.
    private var hasFinished: Bool   { isCurrentClip && audio.didFinishPlaying }

    /// Locked once answered, or once the clip has played to completion — pausing and
    /// resuming mid-playback stays available the whole time in between.
    var playDisabled: Bool { vm.answered || hasFinished }

    func optState(_ i: Int) -> OptionState {
        guard vm.answered else { return vm.selectedOption == i ? .selected : .normal }
        let c = vm.currentClip.multipleChoiceQuestion?.correctIndex ?? -1
        if i == c { return .correct }
        if i == vm.selectedOption && !vm.isCorrect { return .wrong }
        return .normal
    }

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 12) {
                HStack {
                    Text("Clip \(vm.currentIndex + 1)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary).textCase(.uppercase).kerning(0.7)
                    Spacer()
                    DifficultyBadge(difficulty: vm.currentClip.difficulty)
                }
                WaveformView(isPlaying: isPlaying)
                HStack(spacing: 14) {
                    Button {
                        if isPlaying {
                            audio.pause()
                        } else if hasPlayedOnce && isCurrentClip {
                            vm.startTimerIfNeeded()
                            audio.resume()
                        } else if !hasPlayedOnce {
                            hasPlayedOnce = true
                            vm.startTimerIfNeeded()
                            audio.play(fileName: vm.currentClip.fileName)
                        }
                    } label: {
                        ZStack {
                            Circle().fill(Color(hex: "#534AB7")).frame(width: 52, height: 52)
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 20)).foregroundColor(.white)
                        }
                        .opacity(playDisabled ? 0.5 : 1.0)
                    }
                    .disabled(playDisabled)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isPlaying ? "Playing…" : hasFinished ? "Played" : hasPlayedOnce ? "Paused" : "Tap to listen")
                            .font(.system(size: 13)).foregroundColor(.secondary)
                        if let combo = vm.comboMessage {
                            Text(combo).font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "#EF9F27"))
                        }
                    }
                    Spacer()
                }
            }
            .padding(16).background(Color(.systemBackground)).cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))

            if let q = vm.currentClip.multipleChoiceQuestion {
                Text(q.text).font(.system(size: 15, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                HintRow(vm: vm)
                ForEach(Array(q.options.enumerated()), id: \.offset) { i, opt in
                    if i != vm.eliminatedOptionIndex {
                        OptionBtn(letter: letters[i], text: opt, state: optState(i),
                                  disabled: vm.answered) { vm.selectOption(i) }
                    }
                }
            }
        }
    }
}

// MARK: - Audio Lineup
struct LineupQuestionView: View {
    @ObservedObject var vm: QuizViewModel
    @ObservedObject private var audio = AudioManager.shared

    func choiceState(_ i: Int, _ choice: AudioChoice) -> OptionState {
        guard vm.answered else { return vm.selectedOption == i ? .selected : .normal }
        if choice.isCorrect { return .correct }
        if vm.selectedOption == i && !vm.isCorrect { return .wrong }
        return .normal
    }

    private func isCurrent(_ choice: AudioChoice) -> Bool { vm.playingChoiceId == choice.id }
    private func isPlaying(_ choice: AudioChoice) -> Bool { isCurrent(choice) && audio.isPlaying }
    /// True once this specific choice has finished playing, or was abandoned for a different
    /// choice — either way there's nothing left to resume, so its play button locks.
    private func hasFinished(_ choice: AudioChoice) -> Bool {
        (isCurrent(choice) && audio.didFinishPlaying) || vm.lockedChoiceIds.contains(choice.id)
    }

    var body: some View {
        VStack(spacing: 14) {
            if !vm.showLineup {
                MysteryCardView(vm: vm)
            } else if let lu = vm.currentClip.audioLineupQuestion {
                HStack {
                    DifficultyBadge(difficulty: vm.currentClip.difficulty)
                    Spacer()
                    Text("\(vm.currentClip.points) pts").font(.system(size: 12)).foregroundColor(.secondary)
                }
                Text(lu.promptText).font(.system(size: 15, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                HintRow(vm: vm)
                ForEach(Array(lu.choices.enumerated()), id: \.offset) { i, choice in
                    if choice.id != vm.eliminatedChoiceId {
                        AudioChoiceBtn(
                            choice: choice, index: i,
                            isPlaying: isPlaying(choice),
                            state: choiceState(i, choice),
                            selectDisabled: vm.answered,
                            playDisabled: vm.answered || hasFinished(choice),
                            onPlay: { vm.toggleChoice(choice) },
                            onSelect: { vm.selectedOption = i }
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Mystery Card
struct MysteryCardView: View {
    @ObservedObject var vm: QuizViewModel
    @State private var pulse = false
    var body: some View {
        VStack(spacing: 16) {
            DifficultyBadge(difficulty: vm.currentClip.difficulty)
                .frame(maxWidth: .infinity, alignment: .leading)
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: "#534AB7"), Color(hex: "#3C3489")],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                    .shadow(color: Color(hex: "#534AB7").opacity(pulse ? 0.5 : 0.2),
                            radius: pulse ? 20 : 10)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulse)
                Image(systemName: vm.mysteryPlayed ? "checkmark" : "flame.fill")
                    .font(.system(size: 28)).foregroundColor(.white)
            }.onAppear { pulse = true }
            VStack(spacing: 4) {
                Text("Mystery clip").font(.system(size: 16, weight: .medium))
                Text(vm.mysteryPlayed ? "✓ Played once" : "Tap to play — listen carefully!")
                    .font(.system(size: 13)).foregroundColor(.secondary)
                if !vm.mysteryPlayed {
                    Text("⚠ One play only — no replays")
                        .font(.system(size: 12, weight: .medium)).foregroundColor(Color(hex: "#E24B4A"))
                }
            }
            Button { vm.playMystery() } label: {
                Label(vm.mysteryPlayed ? "Played once" : "Play mystery clip",
                      systemImage: vm.mysteryPlayed ? "checkmark" : "play.fill")
                    .font(.system(size: 15, weight: .medium)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 13)
                    .background(vm.mysteryPlayed ? Color(hex: "#1D9E75") : Color(hex: "#534AB7"))
                    .cornerRadius(12)
            }.disabled(vm.mysteryPlayed)
            if vm.mysteryPlayed {
                Text("Now compare it against the clips below")
                    .font(.system(size: 13)).foregroundColor(.secondary).multilineTextAlignment(.center)
                Button {
                    withAnimation { vm.showLineup = true }
                    vm.startTimer()
                } label: {
                    Text("Show the lineup →")
                        .font(.system(size: 15, weight: .medium)).foregroundColor(Color(hex: "#534AB7"))
                        .frame(maxWidth: .infinity).padding(.vertical, 13)
                        .background(Color(hex: "#EEEDFE")).cornerRadius(12)
                }
            }
        }
        .padding(18).background(Color(.systemBackground)).cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))
    }
}

// MARK: - Option Button
struct OptionBtn: View {
    let letter: String; let text: String; let state: OptionState
    let disabled: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(state.letterBg).frame(width: 28, height: 28)
                    Text(letter).font(.system(size: 12, weight: .medium)).foregroundColor(state.letterFg)
                }
                Text(text).font(.system(size: 14)).foregroundColor(state.text)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding(13).background(state.bg).cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(state.border, lineWidth: 0.5))
            .scaleEffect(state == .correct ? 1.02 : 1.0)
            .animation(.spring(response: 0.3), value: state)
        }
        .buttonStyle(.plain).disabled(disabled)
    }
}

// MARK: - Audio Choice Button
struct AudioChoiceBtn: View {
    let choice: AudioChoice; let index: Int
    let isPlaying: Bool; let state: OptionState
    /// Gates picking this choice as the answer — only once the question's answered.
    let selectDisabled: Bool
    /// Gates the play/pause button specifically — also locks once this choice has finished
    /// playing (or was abandoned for another choice), independent of whether it's selectable.
    let playDisabled: Bool
    let onPlay: () -> Void; let onSelect: () -> Void
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Button(action: onPlay) {
                        ZStack {
                            Circle().fill(isPlaying ? Color(hex: "#1D9E75") : Color(hex: "#534AB7"))
                                .frame(width: 36, height: 36)
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 13)).foregroundColor(.white)
                        }
                        .opacity(playDisabled ? 0.5 : 1.0)
                    }.disabled(playDisabled)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(choice.label).font(.system(size: 13, weight: .medium)).foregroundColor(state.text)
                        Text(choice.description).font(.system(size: 12)).foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    ZStack {
                        Circle().stroke(state.border, lineWidth: 1.5).frame(width: 20, height: 20)
                        if state != .normal { Circle().fill(state.border).frame(width: 11, height: 11) }
                    }
                }
                if isPlaying { WaveformView(isPlaying: true).frame(height: 24) }
            }
            .padding(14).background(state.bg).cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(state.border, lineWidth: 0.5))
        }
        .buttonStyle(.plain).disabled(selectDisabled)
    }
}

// MARK: - Action Bar
struct QuizActionBar: View {
    @ObservedObject var vm: QuizViewModel
    var canSubmit: Bool {
        guard !vm.answered, vm.selectedOption != nil else { return false }
        if vm.currentClip.questionType == .audioLineup && !vm.showLineup { return false }
        return true
    }
    var feedbackText: String {
        if vm.isCorrect {
            return "Correct!" + (vm.streak >= 2 ? " — \(vm.streak)x combo! 🔥" : "")
        }
        switch vm.currentClip.questionType {
        case .multipleChoice:
            let i = vm.currentClip.multipleChoiceQuestion?.correctIndex ?? 0
            let a = vm.currentClip.multipleChoiceQuestion?.options[i] ?? ""
            return "Not quite — the answer was \(a)."
        case .audioLineup:
            return "Not quite — the match was \(vm.currentClip.audioLineupQuestion?.correctChoice?.label ?? "")."
        }
    }
    var body: some View {
        VStack(spacing: 0) {
            if vm.showFeedback {
                HStack(spacing: 8) {
                    Image(systemName: vm.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(vm.isCorrect ? Color(hex: "#0F6E56") : Color(hex: "#993C1D"))
                    Text(feedbackText).font(.system(size: 13))
                        .foregroundColor(vm.isCorrect ? Color(hex: "#085041") : Color(hex: "#4A1B0C"))
                    Spacer()
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(vm.isCorrect ? Color(hex: "#E1F5EE") : Color(hex: "#FAECE7"))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            Divider()
            HStack(spacing: 12) {
                if !vm.answered {
                    Button("Lock it in") { vm.submitAnswer() }
                        .font(.system(size: 15, weight: .medium)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 13)
                        .background(canSubmit ? Color(hex: "#534AB7") : Color(.systemFill))
                        .cornerRadius(12).disabled(!canSubmit)
                        .animation(.easeInOut(duration: 0.2), value: canSubmit)
                } else {
                    Button(vm.currentIndex + 1 >= vm.totalClips ? "Finish round →" : "Next →") {
                        withAnimation { vm.advance() }
                    }
                    .font(.system(size: 15, weight: .medium)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 13)
                    .background(Color(hex: "#534AB7")).cornerRadius(12)
                }
            }
            .padding(16).background(Color(.systemBackground))
        }
    }
}

// MARK: - Waveform
struct WaveformView: View {
    let isPlaying: Bool
    @State private var phase: Double = 0
    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            ForEach(0..<28, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(isPlaying ? Color(hex: "#534AB7") : Color(.systemFill))
                    .frame(width: 4, height: isPlaying
                           ? max(6, 28 * abs(sin(phase + Double(i) * 0.44)))
                           : CGFloat.random(in: 6...28))
            }
        }
        .onAppear {
            if isPlaying {
                withAnimation(.linear(duration: 0.6).repeatForever(autoreverses: false)) {
                    phase += .pi * 2
                }
            }
        }
        .onChange(of: isPlaying) { newValue in
            if newValue {
                withAnimation(.linear(duration: 0.6).repeatForever(autoreverses: false)) {
                    phase += .pi * 2
                }
            }
        }
    }
}

// MARK: - Hint Row
struct HintRow: View {
    @ObservedObject var vm: QuizViewModel

    var body: some View {
        if let hint = vm.currentClip.hint, !hint.isEmpty {
            if vm.hintUsed {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 11)).foregroundColor(Color(hex: "#EF9F27"))
                    Text(hint).font(.system(size: 12)).foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "#FAEEDA"))
                .cornerRadius(10)
            } else {
                Button { vm.useHint() } label: {
                    Label("Use a hint", systemImage: "lightbulb")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "#EF9F27"))
                }
                .disabled(!vm.hintAvailable)
            }
        }
    }
}

// MARK: - Difficulty Badge
struct DifficultyBadge: View {
    let difficulty: Difficulty
    var color: Color {
        switch difficulty {
        case .easy:   return Color(hex: "#1D9E75")
        case .medium: return Color(hex: "#BA7517")
        case .hard:   return Color(hex: "#993C1D")
        }
    }
    var bg: Color {
        switch difficulty {
        case .easy:   return Color(hex: "#E1F5EE")
        case .medium: return Color(hex: "#FAEEDA")
        case .hard:   return Color(hex: "#FAECE7")
        }
    }
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(i < difficulty.rawValue ? color : Color(.systemFill))
                    .frame(width: 8, height: 8)
            }
            Text(difficulty.label).font(.system(size: 11, weight: .medium)).foregroundColor(color)
        }
        .padding(.horizontal, 8).padding(.vertical, 4).background(bg).clipShape(Capsule())
    }
}

#Preview {
    QuizView(quizSet: QuizSet.sampleSets[0]) { _, _, _, _ in }
}
