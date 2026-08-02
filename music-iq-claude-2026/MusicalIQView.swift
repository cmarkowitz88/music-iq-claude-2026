
import SwiftUI

// MARK: - Musical IQ Recap (shown when a quiz session ends)
/// Shown in place when a session ends — either the player taps the X mid-round or the content
/// pool actually runs out. Briefly shows a "calculating" state before revealing the score, since
/// an instant reveal reads as less considered for something framed as an actual assessment.
struct MusicalIQRecapView: View {
    let score: MusicalIQScore?
    let onDone: () -> Void
    @State private var isCalculating = true

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            if isCalculating {
                ProgressView()
                    .scaleEffect(1.3)
                Text("Calculating your Musical IQ…")
                    .font(.system(size: 15)).foregroundColor(.secondary)
            } else if let score {
                MusicalIQBadge(iq: score.overallIQ, size: 96)
                VStack(spacing: 6) {
                    Text(score.tierLabel)
                        .font(.system(size: 20, weight: .medium))
                    Text(score.tierDescription)
                        .font(.system(size: 14)).foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                if !score.difficultyScores.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(Difficulty.allCases.sorted { $0.rawValue < $1.rawValue }, id: \.self) { difficulty in
                            if let value = score.difficultyScores[difficulty] {
                                DifficultyScoreRow(difficulty: difficulty, value: value)
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                }
                Text("Based on \(score.questionsAnswered) question\(score.questionsAnswered == 1 ? "" : "s") this session")
                    .font(.system(size: 12)).foregroundColor(.secondary)
            } else {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 40)).foregroundColor(.secondary)
                Text("Not enough data yet")
                    .font(.system(size: 18, weight: .medium))
                Text("Pass at least one round to see your Musical IQ.")
                    .font(.system(size: 14)).foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()
            Button(action: onDone) {
                Text("Done")
                    .font(.system(size: 15, weight: .medium)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 13)
                    .background(Color(hex: "#534AB7")).cornerRadius(12)
            }
        }
        .padding(24)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation { isCalculating = false }
            }
        }
    }
}

private struct DifficultyScoreRow: View {
    let difficulty: Difficulty
    let value: Int
    var body: some View {
        HStack(spacing: 10) {
            Text(difficulty.label)
                .font(.system(size: 13)).foregroundColor(.secondary)
                .frame(width: 56, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(Color(.systemFill)).frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: difficulty.accentHex))
                        .frame(width: geo.size.width * CGFloat(min(max(value, 0), 100)) / 100, height: 6)
                }
            }
            .frame(height: 6)
            Text("\(value)")
                .font(.system(size: 12, weight: .medium)).foregroundColor(.secondary)
                .frame(width: 24, alignment: .trailing)
        }
    }
}

// MARK: - Musical IQ Badge
struct MusicalIQBadge: View {
    let iq: Int
    var size: CGFloat = 64
    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [Color(hex: "#534AB7"), Color(hex: "#3C3489")],
                                      startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size, height: size)
            VStack(spacing: 0) {
                Text("\(iq)")
                    .font(.system(size: size * 0.36, weight: .bold))
                    .foregroundColor(.white)
                Text("IQ")
                    .font(.system(size: size * 0.13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

// MARK: - Musical IQ Card (Home screen, all-time live stat)
struct MusicalIQCardView: View {
    let score: MusicalIQScore?

    var body: some View {
        HStack(spacing: 14) {
            if let score {
                MusicalIQBadge(iq: score.overallIQ, size: 52)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your Musical IQ").font(.system(size: 13)).foregroundColor(.secondary)
                    Text(score.tierLabel).font(.system(size: 16, weight: .medium))
                    Text("From \(score.questionsAnswered) question\(score.questionsAnswered == 1 ? "" : "s") answered")
                        .font(.system(size: 11)).foregroundColor(.secondary)
                }
            } else {
                ZStack {
                    Circle().fill(Color(hex: "#EEEDFE")).frame(width: 52, height: 52)
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 22)).foregroundColor(Color(hex: "#534AB7"))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your Musical IQ").font(.system(size: 13)).foregroundColor(.secondary)
                    Text("Play a round to find out")
                        .font(.system(size: 14, weight: .medium))
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13)).foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))
    }
}

#Preview("Recap") {
    MusicalIQRecapView(score: MusicalIQScore.calculate(results: [
        GameResult(category: .other, difficulty: .easy, correct: true, speedScore: 0.8, pointsEarned: 100),
        GameResult(category: .other, difficulty: .medium, correct: true, speedScore: 0.6, pointsEarned: 150),
        GameResult(category: .other, difficulty: .hard, correct: false, speedScore: 0.2, pointsEarned: 0),
    ])) {}
}

#Preview("Card") {
    MusicalIQCardView(score: MusicalIQScore.calculate(results: [
        GameResult(category: .other, difficulty: .easy, correct: true, speedScore: 0.8, pointsEarned: 100),
    ]))
    .padding()
}
