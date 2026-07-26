
import SwiftUI

struct SettingsView: View {
    @AppStorage("totalPoints") private var totalPoints: Int = 0
    @AppStorage("streakDays")  private var streakDays: Int  = 5
    @State private var showResetConfirmation = false
    #if DEBUG
    @State private var showDebugFinder = false
    #endif

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("General")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .kerning(0.8)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                    SettingsActionRow(
                        icon: "arrow.counterclockwise",
                        iconBgHex: "#FAECE7", iconAccentHex: "#993C1D",
                        title: "Reset Progress",
                        subtitle: "Clears points, streak, and any quiz in progress"
                    ) { showResetConfirmation = true }
                        .padding(.horizontal, 20)

                    #if DEBUG
                    Text("Debug")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .kerning(0.8)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    SettingsActionRow(
                        icon: "magnifyingglass",
                        iconBgHex: "#EEEDFE", iconAccentHex: "#534AB7",
                        title: "Find Question",
                        subtitle: "Search by filename or source ID to preview one clip"
                    ) { showDebugFinder = true }
                        .padding(.horizontal, 20)
                    #endif

                    Spacer(minLength: 24)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Settings")
            .alert("Reset Progress?", isPresented: $showResetConfirmation) {
                Button("Reset", role: .destructive) { resetProgress() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This clears your points, streak, Musical IQ, and any quiz in progress. This can't be undone.")
            }
            #if DEBUG
            .navigationDestination(isPresented: $showDebugFinder) {
                DebugQuestionFinderView { showDebugFinder = false }
            }
            #endif
        }
    }

    private func resetProgress() {
        QuizPersistence.clear()
        MusicalIQStore.clear()
        totalPoints = 0
        streakDays  = 0
    }
}

struct SettingsActionRow: View {
    let icon: String
    let iconBgHex: String
    let iconAccentHex: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: iconBgHex))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: iconAccentHex))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 12)).foregroundColor(.secondary)
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
        .buttonStyle(.plain)
    }
}

#Preview { SettingsView() }
