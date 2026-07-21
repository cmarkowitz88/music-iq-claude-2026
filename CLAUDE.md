# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

MusicIQ is a SwiftUI iOS app — an ear-training quiz game. Users listen to short audio clips and
answer questions about them (instrument, tempo, time signature, genre feel), plus an "Audio
Lineup" mode where a mystery clip plays once and the user must match it from memory against 4
candidates. A post-quiz scoring model produces an overall "Musical IQ" (80–160) with a tier label.

This is an early-stage prototype: quiz content is hardcoded sample data, audio files referenced by
filename are not actually bundled anywhere in the repo, the remote audio fallback points at a
placeholder URL, and the results screen is a stub. Don't assume any of this is wired up to real
content — check before building on top of it.

## Commands

Single-target Xcode project (`music-iq-claude-2026.xcodeproj`), Swift 5.0, iOS deployment target
26.5, no external dependencies (no SPM packages, no CocoaPods). There is no test target in this
project.

Build from the command line:
```
xcodebuild -project music-iq-claude-2026.xcodeproj -scheme music-iq-claude-2026 -destination 'generic/platform=iOS Simulator' build
```

Otherwise open `music-iq-claude-2026.xcodeproj` in Xcode and run on a simulator.

## Architecture

Everything lives in `music-iq-claude-2026/`, seven Swift files, no submodules:

- **`Models.swift`** is the source of truth for the domain model: `Clip`, `QuizSet`,
  `MultipleChoiceQuestion`, `AudioLineupQuestion`/`AudioChoice`, `Difficulty`, `ClipCategory`. A
  `Clip` holds *either* a multiple-choice question *or* an audio-lineup question via
  `questionType` + two optional fields — check `questionType` before force-using either. Scoring
  math (`Clip.points`, difficulty multipliers) and the end-of-quiz `MusicalIQScore.calculate(results:)`
  (accuracy + speed + streak → IQ score and tier) both live here.

- **`SampleData.swift`** defines the only quiz content that exists (`QuizSet.sampleSets`): four
  hardcoded sets covering instrument ID, time signature, tempo/feel, and audio lineup. There is no
  remote content pipeline — adding a quiz means editing this file directly.

- **`AudioManager.swift`** is a singleton (`AudioManager.shared`) that plays a clip by filename:
  it first checks the app bundle, then falls back to a remote URL built from a placeholder R2
  bucket base URL. It also tracks "has this been played once" state, used to enforce the
  Audio Lineup mystery clip's no-replay rule.

- **`Quizview.swift`** contains both the quiz flow view (`QuizView`) and its view model
  (`QuizViewModel`, `@MainActor`/`ObservableObject`). The view model owns the per-question timer
  (`Task`-based countdown, difficulty-dependent duration), scoring/streak/combo logic, and
  synthesizes its own SFX tones at runtime via raw `AVAudioEngine` buffers (no sound asset files).
  The two question UIs (`MCQuestionView`, `LineupQuestionView`) branch on `Clip.questionType`.

- **`Homeview.swift`** is the app's landing screen — streak/points/level header, the list of
  `QuizSet.sampleSets`, and a mock leaderboard — and owns navigation into `QuizView`.

- **`Extensions.swift`** defines `Color(hex:)` and `Int.formattedWithCommas`. The file explicitly
  comments that `Color(hex:)` should not be redefined elsewhere — reuse this one.

Persisted state is minimal and uses `@AppStorage` directly in `HomeView` (`totalPoints`,
`streakDays`) — there is no persistence layer beyond that.
