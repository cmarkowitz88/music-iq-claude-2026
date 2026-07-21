
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

    let quizSet: QuizSet
    var onComplete: (Int, [GameResult]) -> Void
    var questionStartTime: Date = Date()

    private var timerTask: Task<Void, Never>?
    private var gameResults: [GameResult] = []

    init(quizSet: QuizSet, onComplete: @escaping (Int, [GameResult]) -> Void) {
        self.quizSet    = quizSet
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

    func startTimer() {
        timerTask?.cancel()
        let seconds   = currentClip.difficulty.timerSeconds
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

    func timeUp() {
        guard !answered else { return }
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
        let speed   = max(0, min(1.0, 1.0 - elapsed / Double(currentClip.difficulty.timerSeconds)))
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
            onComplete(score, gameResults)
        } else {
            currentIndex   += 1
            selectedOption  = nil
            answered        = false
            isCorrect       = false
            showFeedback    = false
            mysteryPlayed   = false
            showLineup      = false
            questionStartTime = Date()
            if currentClip.questionType == .multipleChoice { startTimer() }
        }
    }

    func playMystery() {
        guard !mysteryPlayed else { return }
        mysteryPlayed = true
        AudioManager.shared.play(fileName: currentClip.fileName, allowReplay: false)
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            await MainActor.run {
                self?.showLineup = true
                self?.startTimer()
            }
        }
    }

    func toggleChoice(_ choice: AudioChoice) {
        if playingChoiceId == choice.id {
            AudioManager.shared.stopAll()
            playingChoiceId = nil
        } else {
            AudioManager.shared.stopAll()
            playingChoiceId = choice.id
            AudioManager.shared.play(fileName: choice.fileName)
            Task { [weak self] in
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                await MainActor.run {
                    if self?.playingChoiceId == choice.id { self?.playingChoiceId = nil }
                }
            }
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

// MARK: - Quiz View
struct QuizView: View {
    @StateObject private var vm: QuizViewModel
    @Environment(\.dismiss) private var dismiss

    init(quizSet: QuizSet, onComplete: @escaping (Int, [GameResult]) -> Void) {
        _vm = StateObject(wrappedValue: QuizViewModel(quizSet: quizSet, onComplete: onComplete))
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
                .padding(16)
            }
            QuizActionBar(vm: vm)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .onAppear {
            vm.questionStartTime = Date()
            if vm.currentClip.questionType == .multipleChoice { vm.startTimer() }
        }
        .navigationDestination(isPresented: $vm.isFinished) {
            Text("MusicIQ Results — coming next!")
                .navigationBarHidden(false)
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
    @State private var isPlaying = false
    @State private var playCount = 0
    let letters = ["A","B","C","D","E","F"]

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
                Text(vm.currentClip.name)
                    .font(.system(size: 14, weight: .medium)).multilineTextAlignment(.center)
                WaveformView(isPlaying: isPlaying)
                HStack(spacing: 14) {
                    Button {
                        isPlaying.toggle()
                        if isPlaying {
                            playCount += 1
                            AudioManager.shared.play(fileName: vm.currentClip.fileName)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { isPlaying = false }
                        } else {
                            AudioManager.shared.stopAll()
                        }
                    } label: {
                        ZStack {
                            Circle().fill(Color(hex: "#534AB7")).frame(width: 52, height: 52)
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 20)).foregroundColor(.white)
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isPlaying ? "Playing…" : playCount == 0 ? "Tap to listen" : "Replay (\(playCount)x)")
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
                ForEach(Array(q.options.enumerated()), id: \.offset) { i, opt in
                    OptionBtn(letter: letters[i], text: opt, state: optState(i),
                              disabled: vm.answered) { vm.selectOption(i) }
                }
            }
        }
    }
}

// MARK: - Audio Lineup
struct LineupQuestionView: View {
    @ObservedObject var vm: QuizViewModel

    func choiceState(_ i: Int, _ choice: AudioChoice) -> OptionState {
        guard vm.answered else { return vm.selectedOption == i ? .selected : .normal }
        if choice.isCorrect { return .correct }
        if vm.selectedOption == i && !vm.isCorrect { return .wrong }
        return .normal
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
                ForEach(Array(lu.choices.enumerated()), id: \.offset) { i, choice in
                    AudioChoiceBtn(
                        choice: choice, index: i,
                        isPlaying: vm.playingChoiceId == choice.id,
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
    let isPlaying: Bool; let state: OptionState; let disabled: Bool
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
                    }.disabled(disabled)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(choice.label).font(.system(size: 13, weight: .medium)).foregroundColor(state.text)
                        Text(choice.description).font(.system(size: 12)).foregroundColor(.secondary)
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
                    Button(vm.currentIndex + 1 >= vm.totalClips ? "See my MusicIQ →" : "Next →") {
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
        .onChange(of: isPlaying) { _, newValue in
            if newValue {
                withAnimation(.linear(duration: 0.6).repeatForever(autoreverses: false)) {
                    phase += .pi * 2
                }
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
    QuizView(quizSet: QuizSet.sampleSets[0]) { _, _ in }
}
