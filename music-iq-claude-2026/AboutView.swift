
import SwiftUI

struct AboutView: View {
    private let howItWorks: [(icon: String, title: String, subtitle: String)] = [
        ("waveform", "Listen & answer",
         "Every round plays short audio clips and asks what you hear — instrument, tempo, time signature, or genre feel."),
        ("chart.bar.fill", "Easy → hard",
         "Rounds start easy and ramp up in difficulty. Pass a round to move on; fail it and you'll redo the same round."),
        ("waveform.badge.magnifyingglass", "Audio Lineup",
         "A mystery clip plays once from memory, then you match it against 4 candidates."),
        ("brain.head.profile", "Your Musical IQ",
         "Accuracy, speed, and streaks combine into an overall Musical IQ score and tier."),
    ]

    private var versionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build   = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(spacing: 10) {
                        ZStack {
                            Circle().fill(Color(hex: "#EEEDFE")).frame(width: 64, height: 64)
                            Image(systemName: "music.note")
                                .font(.system(size: 28))
                                .foregroundColor(Color(hex: "#534AB7"))
                        }
                        Text("MusicIQ")
                            .font(.system(size: 20, weight: .medium))
                        Text("An ear-training game that puts your musical instincts to the test.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)

                    Text("How it works")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .kerning(0.8)
                        .padding(.horizontal, 20)

                    VStack(spacing: 10) {
                        ForEach(howItWorks, id: \.title) { item in
                            HStack(alignment: .top, spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(hex: "#EEEDFE"))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: item.icon)
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: "#534AB7"))
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(.system(size: 14, weight: .medium))
                                    Text(item.subtitle)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer(minLength: 0)
                            }
                            .padding(14)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))
                        }
                    }
                    .padding(.horizontal, 20)

                    Text(versionString)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
}

#Preview { AboutView() }
