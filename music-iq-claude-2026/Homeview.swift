
import SwiftUI

struct HomeView: View {

    @AppStorage("totalPoints") private var totalPoints: Int = 0
    @AppStorage("streakDays")  private var streakDays: Int  = 5
    @State private var navigateToQuiz = false
    @State private var resumableSnapshot: QuizSessionSnapshot? = nil

    private var level: Int { max(1, totalPoints / 500 + 1) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("MusicIQ")
                                .font(.system(size: 24, weight: .medium))
                            Text("What's your Musical IQ?")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        HStack(spacing: 8) {
                            Label("\(totalPoints.formattedWithCommas) pts", systemImage: "flame.fill")
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Color(hex: "#FAEEDA"))
                                .foregroundColor(Color(hex: "#633806"))
                                .clipShape(Capsule())
                            Text("Lv \(level)")
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Color(hex: "#EEEDFE"))
                                .foregroundColor(Color(hex: "#3C3489"))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    StreakCardView(streakDays: streakDays)
                        .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Today's round")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .kerning(0.8)
                            .padding(.horizontal, 20)

                        StartQuizCardView(resumableRoundName: resumableSnapshot?.currentRoundName)
                            .padding(.horizontal, 20)
                            .onTapGesture { navigateToQuiz = true }
                    }

                    LeaderboardCardView(yourPoints: totalPoints)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .onAppear { resumableSnapshot = QuizPersistence.load() }
            .navigationDestination(isPresented: $navigateToQuiz) {
                if let snapshot = resumableSnapshot {
                    QuizSessionView(resuming: snapshot) { earned, _ in
                        totalPoints += earned
                    }
                } else {
                    QuizSessionView(clips: QuizSet.activeSets.flatMap { $0.clips }) { earned, _ in
                        totalPoints += earned
                    }
                }
            }
        }
    }
}

struct StreakCardView: View {
    let streakDays: Int
    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Daily streak")
                    .font(.system(size: 13)).foregroundColor(.secondary)
                HStack(spacing: 6) {
                    ForEach(0..<7, id: \.self) { i in
                        Circle()
                            .fill(i < streakDays ? Color(hex: "#EF9F27") : Color(.systemFill))
                            .frame(width: 10, height: 10)
                    }
                }
                Text("\(streakDays) days — keep it going!")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#854F0B"))
            }
            Spacer()
            ZStack {
                Circle().fill(Color(hex: "#FAEEDA")).frame(width: 48, height: 48)
                Image(systemName: "flame.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: "#EF9F27"))
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))
    }
}

struct StartQuizCardView: View {
    let resumableRoundName: String?

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: ClipCategory.other.bgHex))
                    .frame(width: 44, height: 44)
                Image(systemName: resumableRoundName != nil ? "arrow.clockwise" : "shuffle")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: ClipCategory.other.accentHex))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(resumableRoundName != nil ? "Continue Quiz" : "Start Quiz")
                    .font(.system(size: 14, weight: .medium))
                if let roundName = resumableRoundName {
                    Text("Pick back up on \(roundName)")
                        .font(.system(size: 12)).foregroundColor(.secondary)
                } else {
                    Text("12 questions per round · 9 to pass · easy → hard")
                        .font(.system(size: 12)).foregroundColor(.secondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13)).foregroundColor(.secondary)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))
    }
}

struct LeaderboardCardView: View {
    let yourPoints: Int
    private let mockPlayers: [(String, Int, String, String)] = [
        ("Kai L.",  3820, "#FAEEDA", "#633806"),
        ("Maya P.", 2990, "#EEEDFE", "#3C3489"),
        ("Sam R.",  1650, "#E1F5EE", "#085041"),
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Top players today")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary).padding(.bottom, 10)
            ForEach(Array(mockPlayers.enumerated()), id: \.offset) { idx, p in
                HStack(spacing: 10) {
                    Text("\(idx + 1)").font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary).frame(width: 22)
                    ZStack {
                        Circle().fill(Color(hex: p.2)).frame(width: 32, height: 32)
                        Text(String(p.0.prefix(2)))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(hex: p.3))
                    }
                    Text(p.0).font(.system(size: 13, weight: .medium))
                    Spacer()
                    Text("\(p.1.formattedWithCommas) pts")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "#3C3489"))
                }
                .padding(.vertical, 8)
                if idx < mockPlayers.count - 1 { Divider().padding(.leading, 42) }
            }
            Divider().padding(.leading, 42)
            HStack(spacing: 10) {
                Text("4").font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#534AB7")).frame(width: 22)
                ZStack {
                    Circle().fill(Color(hex: "#EEEDFE")).frame(width: 32, height: 32)
                    Text("You").font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "#3C3489"))
                }
                Text("You").font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#534AB7"))
                Spacer()
                Text("\(yourPoints.formattedWithCommas) pts")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#3C3489"))
            }
            .padding(8)
            .background(Color(hex: "#EEEDFE").opacity(0.5))
            .cornerRadius(8).padding(.top, 4)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))
    }
}

#Preview { HomeView() }
