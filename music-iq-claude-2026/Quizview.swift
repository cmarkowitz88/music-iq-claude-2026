
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
    @Published var hintUsed: Bool             = false
    @Published var eliminatedOptionIndex: Int? = nil
    @Published var eliminatedChoiceId: UUID?   = nil
    /// Display-order permutations, re-shuffled every time a question is shown (including on a
    /// failed-round retry) so the correct answer's on-screen position can't be memorized —
    /// each holds original-array indices in the order they should render.
    @Published var optionOrder: [Int] = []
    @Published var choiceOrder: [Int] = []

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
        shuffleAnswerOrder()
    }

    private func shuffleAnswerOrder() {
        switch currentClip.questionType {
        case .multipleChoice:
            optionOrder = Array(currentClip.multipleChoiceQuestion?.options.indices ?? 0..<0).shuffled()
            choiceOrder = []
        case .audioLineup:
            choiceOrder = Array(currentClip.audioLineupQuestion?.choices.indices ?? 0..<0).shuffled()
            optionOrder = []
        }
    }

    var currentClip: Clip { quizSet.clips[currentIndex] }
    var totalClips: Int   { quizSet.clips.count }

    /// True for the one clip per round randomly picked to pay out `Difficulty.bonusQuestionPoints`.
    var isBonusQuestion: Bool { quizSet.bonusClipID == currentClip.id }
    /// The point value this specific question is worth before the streak/combo multiplier —
    /// the bonus payout if this is the round's bonus question, otherwise the clip's normal value.
    var currentQuestionPoints: Int {
        isBonusQuestion ? currentClip.difficulty.bonusQuestionPoints : currentClip.points
    }

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
        runCountdown(from: currentClip.timerSeconds)
    }

    private func runCountdown(from remainingSeconds: Int) {
        timerTask?.cancel()
        timerStarted  = true
        let total     = currentClip.timerSeconds
        timerValue    = remainingSeconds
        timerProgress = Double(remainingSeconds) / Double(total)
        timerTask = Task { [weak self] in
            for remaining in stride(from: remainingSeconds, through: 0, by: -1) {
                guard !Task.isCancelled, let self else { return }
                await MainActor.run {
                    self.timerValue    = remaining
                    self.timerProgress = Double(remaining) / Double(total)
                    if remaining <= 5 { self.sfxTick() }
                    if remaining == 0 { self.timeUp() }
                }
                if remaining == 0 { return }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }

    func stopTimer() { timerTask?.cancel(); timerTask = nil }

    /// Pauses the countdown in place (e.g. while the user has paused the clip) — `timerValue`
    /// is left untouched so `resumeTimer()` can continue from exactly where it left off.
    func pauseTimer() { stopTimer() }

    /// Continues a paused countdown from its current value. No-op if it's already running,
    /// hasn't started yet, or the question's already been answered.
    func resumeTimer() {
        guard timerTask == nil, timerStarted, !answered else { return }
        runCountdown(from: timerValue)
    }

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
        gameResults.append(GameResult(category: currentClip.category, difficulty: currentClip.difficulty,
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
            earned  = Int(Double(currentQuestionPoints) * bonusMultiplier)
            score  += earned
            streak >= 3 ? sfxCombo() : sfxCorrect()
        } else {
            streak = 0
            sfxWrong()
        }

        results.append(correct)
        gameResults.append(GameResult(category: currentClip.category, difficulty: currentClip.difficulty,
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
            questionStartTime = Date()
            resetTimerDisplay()
            shuffleAnswerOrder()
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
                AudioManager.shared.stopAll()
                self?.showLineup = true
            }
        }
    }

    /// Choices can be freely replayed, paused/resumed, and switched between at any time before
    /// the question's answered — there's no "used it up" lockout here, unlike the multiple
    /// choice play button.
    func toggleChoice(_ choice: AudioChoice) {
        let audio = AudioManager.shared
        let isCurrent = playingChoiceId == choice.id

        if isCurrent && audio.isPlaying {
            audio.pause()
            pauseTimer()
        } else if isCurrent && !audio.didFinishPlaying {
            audio.resume()
            resumeTimer()
        } else {
            playingChoiceId = choice.id
            audio.play(fileName: choice.fileName)
            // The answer countdown only starts once the user actually plays a candidate —
            // startTimerIfNeeded() begins it the first time; resumeTimer() covers switching to
            // a fresh choice after having paused, so the countdown doesn't stay frozen forever.
            startTimerIfNeeded()
            resumeTimer()
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

    init(snapshot: QuizProgressionSnapshot) {
        remaining       = snapshot.remainingByDifficulty
        difficultyIndex = snapshot.difficultyIndex
        roundCounts     = snapshot.roundCounts
    }

    var snapshot: QuizProgressionSnapshot {
        QuizProgressionSnapshot(remainingByDifficulty: remaining, difficultyIndex: difficultyIndex,
                                 roundCounts: roundCounts)
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
            let roundClips = Array(pool.prefix(Self.roundSize))
            return QuizSet(name: name, category: .other, clips: roundClips,
                            bonusClipID: roundClips.randomElement()?.id)
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
    /// Computed the moment the session ends (manual exit or the pool running out) from whatever
    /// rounds were actually passed — nil if nothing was passed yet, in which case there's
    /// nothing meaningful to show.
    @Published var recapScore: MusicalIQScore?

    private(set) var sessionScore = 0
    private(set) var sessionResults: [GameResult] = []
    private(set) var carryStreak = 0
    private(set) var carryBestStreak = 0

    private let progression: QuizProgression
    let onComplete: (Int, [GameResult]) -> Void
    /// Fires as soon as a round is passed, with that round's earned points and results — this is
    /// what actually banks points (and Musical IQ data) to the player's running total. A "full
    /// session" (every difficulty tier's entire pool exhausted) is effectively unreachable in
    /// normal play, so `onComplete` firing only at the very end isn't a usable point at which to
    /// credit anything.
    let onRoundBanked: (Int, [GameResult]) -> Void

    var hasMoreRoundsAvailable: Bool { progression.hasMoreRounds }

    init(clips: [Clip], onComplete: @escaping (Int, [GameResult]) -> Void,
         onRoundBanked: @escaping (Int, [GameResult]) -> Void) {
        self.progression   = QuizProgression(clips: clips)
        self.onComplete    = onComplete
        self.onRoundBanked = onRoundBanked
        self.currentRound = progression.nextRound()
        saveSnapshot()
    }

    /// Picks a session back up from a saved snapshot — restarting at the beginning of the
    /// round that was in progress, with the pool/score/streak state as of when that round began.
    init(resuming snapshot: QuizSessionSnapshot, onComplete: @escaping (Int, [GameResult]) -> Void,
         onRoundBanked: @escaping (Int, [GameResult]) -> Void) {
        self.progression     = QuizProgression(snapshot: snapshot.progression)
        self.onComplete      = onComplete
        self.onRoundBanked   = onRoundBanked
        self.sessionScore     = snapshot.sessionScore
        self.sessionResults   = snapshot.sessionResults
        self.carryStreak      = snapshot.carryStreak
        self.carryBestStreak  = snapshot.carryBestStreak
        let resumedClips = snapshot.currentRoundClips.shuffled()
        self.currentRound = QuizSet(name: snapshot.currentRoundName, category: .other,
                                     clips: resumedClips, bonusClipID: resumedClips.randomElement()?.id)
    }

    private func saveSnapshot() {
        guard let round = currentRound else { return }
        QuizPersistence.save(QuizSessionSnapshot(
            currentRoundClips: round.clips,
            currentRoundName: round.name,
            progression: progression.snapshot,
            sessionScore: sessionScore,
            sessionResults: sessionResults,
            carryStreak: carryStreak,
            carryBestStreak: carryBestStreak
        ))
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
            onRoundBanked(outcome.score, outcome.results)
            if let next = progression.nextRound() {
                currentRound = next
                saveSnapshot()
            } else {
                onComplete(sessionScore, sessionResults)
                recapScore = MusicalIQScore.calculate(results: sessionResults)
                isFinished = true
                QuizPersistence.clear()
            }
        } else {
            // Redo the same clips in a new order, with a freshly re-rolled bonus question — the
            // streak that led to this failed attempt doesn't carry into the reset the retry
            // represents.
            carryStreak  = 0
            let retryClips = outcome.round.clips.shuffled()
            currentRound = QuizSet(name: outcome.round.name, category: outcome.round.category,
                                    clips: retryClips, bonusClipID: retryClips.randomElement()?.id)
            saveSnapshot()
        }
    }

    /// Ends the session early (the player tapped the X mid-round) — scores whatever rounds were
    /// already passed rather than discarding them.
    func requestExit() {
        guard !isFinished else { return }
        recapScore = MusicalIQScore.calculate(results: sessionResults)
        isFinished = true
    }
}

// MARK: - Quiz Session View
struct QuizSessionView: View {
    @StateObject private var vm: QuizSessionViewModel
    @Environment(\.dismiss) private var dismiss

    init(clips: [Clip], onComplete: @escaping (Int, [GameResult]) -> Void,
         onRoundBanked: @escaping (Int, [GameResult]) -> Void) {
        _vm = StateObject(wrappedValue: QuizSessionViewModel(clips: clips, onComplete: onComplete,
                                                              onRoundBanked: onRoundBanked))
    }

    init(resuming snapshot: QuizSessionSnapshot, onComplete: @escaping (Int, [GameResult]) -> Void,
         onRoundBanked: @escaping (Int, [GameResult]) -> Void) {
        _vm = StateObject(wrappedValue: QuizSessionViewModel(resuming: snapshot, onComplete: onComplete,
                                                              onRoundBanked: onRoundBanked))
    }

    var body: some View {
        Group {
            if vm.isFinished {
                MusicalIQRecapView(score: vm.recapScore) { dismiss() }
            } else if let outcome = vm.pendingOutcome {
                RoundOutcomeView(outcome: outcome, hasMoreRounds: vm.hasMoreRoundsAvailable) {
                    vm.continueAfterOutcome()
                }
            } else if let round = vm.currentRound {
                QuizView(quizSet: round, initialStreak: vm.carryStreak, initialBestStreak: vm.carryBestStreak,
                         onExit: { vm.requestExit() }) { score, results, streak, bestStreak in
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
    /// Overrides what the top bar's X button does — used by QuizSessionView to intercept an
    /// exit mid-session and show a Musical IQ recap instead of just popping away. Defaults to
    /// the plain environment dismiss for standalone uses (e.g. the debug question preview).
    var onExit: (() -> Void)?

    init(quizSet: QuizSet, initialStreak: Int = 0, initialBestStreak: Int = 0,
         onExit: (() -> Void)? = nil,
         onComplete: @escaping (Int, [GameResult], Int, Int) -> Void) {
        _vm = StateObject(wrappedValue: QuizViewModel(quizSet: quizSet, initialStreak: initialStreak,
                                                       initialBestStreak: initialBestStreak, onComplete: onComplete))
        self.onExit = onExit
    }

    var body: some View {
        VStack(spacing: 0) {
            QuizTopBar(vm: vm, onDismiss: onExit ?? { dismiss() })
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
        .background(
            ZStack {
                Color(.systemGroupedBackground)
                // A subtle per-difficulty wash — reuses the same accent colors as
                // DifficultyBadge/the progress dots, just at low opacity over the system
                // background so it still adapts correctly in dark mode.
                Color(hex: vm.currentClip.difficulty.accentHex).opacity(0.07)
            }
        )
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
    let onDismiss: () -> Void
    @State private var showSFXTooltip = false
    var body: some View {
        HStack {
            Button {
                AudioManager.shared.stopAll()
                vm.playingChoiceId = nil
                onDismiss()
            } label: {
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
                .help("Sound effects — the correct/wrong/combo chimes, muted separately from the quiz audio itself")
                .accessibilityLabel(vm.sfxEnabled ? "Sound effects on" : "Sound effects off")
                .onLongPressGesture(minimumDuration: 0.4) { showSFXTooltip = true }
                .popover(isPresented: $showSFXTooltip) {
                    Text("Toggles the short chime/buzz/combo sound effects — this doesn't affect the quiz clip audio itself.")
                        .font(.system(size: 13))
                        .padding()
                        .frame(maxWidth: 240)
                        .presentationCompactAdaptation(.popover)
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
                if vm.isBonusQuestion {
                    BonusQuestionBadge(points: vm.currentQuestionPoints)
                }
                WaveformView(isPlaying: isPlaying)
                HStack(spacing: 14) {
                    Button {
                        if isPlaying {
                            audio.pause()
                            vm.pauseTimer()
                        } else if hasPlayedOnce && isCurrentClip {
                            audio.resume()
                            vm.resumeTimer()
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
                ForEach(Array(vm.optionOrder.enumerated()), id: \.offset) { position, i in
                    if i != vm.eliminatedOptionIndex {
                        OptionBtn(letter: letters[position], text: q.options[i], state: optState(i),
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
    static let choiceLabels = ["Clip A", "Clip B", "Clip C", "Clip D"]

    func choiceState(_ i: Int, _ choice: AudioChoice) -> OptionState {
        guard vm.answered else { return vm.selectedOption == i ? .selected : .normal }
        if choice.isCorrect { return .correct }
        if vm.selectedOption == i && !vm.isCorrect { return .wrong }
        return .normal
    }

    private func isCurrent(_ choice: AudioChoice) -> Bool { vm.playingChoiceId == choice.id }
    private func isPlaying(_ choice: AudioChoice) -> Bool { isCurrent(choice) && audio.isPlaying }

    var body: some View {
        VStack(spacing: 14) {
            if vm.isBonusQuestion {
                BonusQuestionBadge(points: vm.currentQuestionPoints)
            }
            if !vm.showLineup {
                MysteryCardView(vm: vm)
            } else if let lu = vm.currentClip.audioLineupQuestion {
                HStack {
                    DifficultyBadge(difficulty: vm.currentClip.difficulty)
                    Spacer()
                    Text("\(vm.currentQuestionPoints) pts").font(.system(size: 12)).foregroundColor(.secondary)
                }
                Text(lu.promptText).font(.system(size: 15, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                HintRow(vm: vm)
                ForEach(Array(vm.choiceOrder.enumerated()), id: \.offset) { position, i in
                    let choice = lu.choices[i]
                    if choice.id != vm.eliminatedChoiceId {
                        AudioChoiceBtn(
                            choice: choice, displayLabel: Self.choiceLabels[position],
                            displayDescription: "Candidate \(position + 1)",
                            isPlaying: isPlaying(choice),
                            state: choiceState(i, choice),
                            disabled: vm.answered,
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
                    AudioManager.shared.stopAll()
                    withAnimation { vm.showLineup = true }
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
    let choice: AudioChoice
    /// Positional label/description ("Clip A" / "Candidate 1", etc.) — derived from on-screen
    /// position rather than the choice's stored values, since choices render in a shuffled
    /// order each time; these are purely visual identifiers, not tied to any real data.
    let displayLabel: String
    let displayDescription: String
    let isPlaying: Bool; let state: OptionState
    /// Gates both picking this choice as the answer and playing it — choices can be freely
    /// replayed/switched between at any time until the question's answered.
    let disabled: Bool
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
                        .opacity(disabled ? 0.5 : 1.0)
                    }.disabled(disabled)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(displayLabel).font(.system(size: 13, weight: .medium)).foregroundColor(state.text)
                        Text(displayDescription).font(.system(size: 12)).foregroundColor(.secondary)
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
        .buttonStyle(.plain).disabled(disabled)
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
            var text = "Correct!"
            if vm.isBonusQuestion {
                let earned = Int(Double(vm.currentQuestionPoints) * vm.bonusMultiplier)
                text = "⭐ Bonus! +\(earned) pts"
            }
            if vm.streak >= 2 { text += " — \(vm.streak)x combo! 🔥" }
            return text
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

// MARK: - Bonus Question Badge
struct BonusQuestionBadge: View {
    let points: Int
    var body: some View {
        Label("Bonus Question — \(points) pts!", systemImage: "star.fill")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color(hex: "#854F0B"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color(hex: "#FAEEDA"))
            .cornerRadius(10)
    }
}

// MARK: - Difficulty Badge
struct DifficultyBadge: View {
    let difficulty: Difficulty
    var color: Color { Color(hex: difficulty.accentHex) }
    var bg: Color    { Color(hex: difficulty.bgHex) }
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
