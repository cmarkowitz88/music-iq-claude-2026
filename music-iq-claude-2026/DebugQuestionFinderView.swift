
import SwiftUI

#if DEBUG
/// Testing-only tool: search the full active question pool by filename or source ID and jump
/// straight into a real `QuizView` for that single clip, to see and hear it without playing
/// through an entire round. Compiled out of Release builds entirely via `#if DEBUG`.
struct DebugQuestionFinderView: View {
    /// Called when the preview round finishes — clears the caller's own presentation flag
    /// directly, rather than relying on `dismiss()` to cascade through two independently-owned
    /// navigation booleans two levels deep.
    let onFinishedTesting: () -> Void
    @State private var query = ""
    @State private var selectedClip: Clip? = nil
    @State private var showPreview = false

    private var allClips: [Clip] { QuizSet.activeSets.flatMap { $0.clips } }

    private var results: [Clip] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        return allClips.filter {
            $0.fileName.lowercased().contains(q) || ($0.sourceID?.lowercased().contains(q) ?? false)
        }
    }

    var body: some View {
        List {
            Section {
                TextField("File name or source ID", text: $query)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            if !query.isEmpty {
                Section("\(results.count) match\(results.count == 1 ? "" : "es")") {
                    ForEach(results) { clip in
                        Button {
                            selectedClip = clip
                            showPreview  = true
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(clip.fileName)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                Text("\(clip.difficulty.label) · \(clip.questionType == .multipleChoice ? "Multiple Choice" : "Audio Lineup") · \(clip.sourceID ?? "no source ID")")
                                    .font(.system(size: 12)).foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Debug: Find Question")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showPreview) {
            if let clip = selectedClip {
                QuizView(quizSet: QuizSet(name: "Debug Preview", category: .other, clips: [clip])) { _, _, _, _ in
                    showPreview = false
                    onFinishedTesting()
                }
            }
        }
    }
}
#endif
