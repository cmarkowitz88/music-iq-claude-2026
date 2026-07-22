# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

MusicIQ is a SwiftUI iOS app — an ear-training quiz game. Users listen to short audio clips and
answer questions about them (instrument, tempo, time signature, genre feel), plus an "Audio
Lineup" mode where a mystery clip plays once and the user must match it from memory against 4
candidates. A post-quiz scoring model produces an overall "Musical IQ" (80–160) with a tier label.

This is an early-stage prototype: audio files referenced by filename are not actually bundled
anywhere in the repo, the remote audio fallback points at a placeholder R2 URL
(`AudioManager.baseURL`), and the results screen is a stub (`Text("MusicIQ Results — coming
next!")` in `QuizSessionView`). Don't assume any of this is wired up to real content — check
before building on top of it.

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

Everything lives in `music-iq-claude-2026/`, nine Swift files, no submodules.

### Content sources — two parallel `QuizSet` catalogs

- **`SampleData.swift`** defines `QuizSet.sampleSets`: four small hand-written sets covering
  instrument ID, time signature, tempo/feel, and audio lineup (4 clips each).
- **`DebugData.swift`** defines `QuizSet.debugSets` — **generated, do not hand-edit** — from an
  external JSON export at
  `/Users/craigmarkowitz/Documents/Development/Music_IQ/AWS/music_iq_questions_for_insert_with_type_and_active.json`
  (not in this repo). Three large "Music Knowledge" sets split by difficulty (~70–85 clips each,
  all `category: .other`) plus a debug audio-lineup set. `DebugConfig.useDebugQuestionSets`
  (currently `true`) selects which catalog `QuizSet.activeSets` resolves to —
  **`activeSets` is what the app actually uses**; flip that flag to compare against the
  hand-written sample content. To add/edit debug quiz content: edit the source JSON (matching its
  existing schema), then run `python3 Scripts/generate_debug_data.py` to rebuild
  `DebugData.swift` from it. `SampleData.swift`, by contrast, has no generator — it's edited by
  hand directly.
- **`quiz_questions.xlsx`** (repo root) is a review/drafting spreadsheet for new questions before
  they're added to the source JSON — not consumed by the app or the generator script.

### `Models.swift` — domain model + scoring math

`Clip`, `QuizSet`, `MultipleChoiceQuestion`, `AudioLineupQuestion`/`AudioChoice`, `Difficulty`,
`ClipCategory`, `GameResult`. A `Clip` holds *either* a multiple-choice question *or* an
audio-lineup question via `questionType` + two optional fields — check `questionType` before
force-using either. Per-clip scoring (`Clip.points`, `Difficulty.pointMultiplier`) and the
end-of-session `MusicalIQScore.calculate(results:)` (accuracy + speed + streak → IQ score and
tier) both live here. `MusicalIQScore` is not yet consumed anywhere — the results screen is a stub.

### `Quizview.swift` — the whole gameplay stack, session → round → question

This is the largest file and has two layers that are easy to conflate:

1. **Session layer** (`QuizSessionView` / `QuizSessionViewModel` / `QuizProgression` /
   `RoundOutcome`) — owns a *session*: the full clip pool pulled from `QuizSet.activeSets`.
   `QuizProgression` buckets clips by `Difficulty` and hands out 12-clip rounds one difficulty
   tier at a time (all easy rounds first, then medium, then hard), shuffling each round and
   consuming clips from the pool as rounds are dealt out; a tier keeps producing fresh rounds
   until it can't fill one, then the next tier takes over. A round needs `≥75%` correct
   (`QuizProgression.requiredCorrect`, 9/12) to pass; `RoundOutcomeView` shows a pass/fail
   interstitial between rounds. Failing **replays the same 12 clips reshuffled** (not fresh
   content) rather than drawing a new round. Score and `GameResult`s only get folded into the
   session total (`QuizSessionViewModel.sessionScore/sessionResults`) when a round is passed —
   a failed attempt's points are discarded. Combo streak (`carryStreak`/`carryBestStreak`)
   carries forward across passed rounds but resets to 0 on a failed retry.

2. **Round layer** (`QuizView` / `QuizViewModel`) — plays a single round (one `QuizSet`) clip by
   clip. The view model owns the per-question timer (`Task`-based countdown,
   difficulty-dependent duration), scoring/streak/combo logic within the round, and synthesizes
   its own SFX tones at runtime via raw `AVAudioEngine` buffers (no sound asset files). It
   receives `initialStreak`/`initialBestStreak` from the session and reports final streak values
   back out through `onComplete(score, results, streak, bestStreak)` when the round ends. The two
   question UIs (`MCQuestionView`, `LineupQuestionView`) branch on `Clip.questionType`.

When changing round/session behavior (pass threshold, retry logic, round size), the source of
truth is `QuizProgression` + `QuizSessionViewModel.continueAfterOutcome()`, not `QuizViewModel`.

### `QuizPersistence.swift` — resuming an in-progress session

`QuizSessionViewModel` saves a `QuizSessionSnapshot` (`QuizPersistence.save`, backed by
`UserDefaults`, JSON via `Codable`) every time a new round begins — the very first round, each
subsequent round after a pass, and each reshuffled retry after a fail. Leaving mid-round
(dismissing, backgrounding, the app getting killed) and coming back therefore resumes at the
*start* of the round that was in progress, not the exact question — nothing about mid-question
state (timer, audio playback, current selection) is restored, only round-level checkpoints are.
The snapshot is cleared when a full session completes. `HomeView` checks `QuizPersistence.load()`
on appear and, if present, launches `QuizSessionView(resuming:)` instead of building a fresh
session from `QuizSet.activeSets`.

### `AudioManager.swift`

Singleton (`AudioManager.shared`) that plays a clip by filename: checks the app bundle first,
then falls back to a remote URL built from `baseURL` (a placeholder R2 bucket). Tracks "has this
been played once" (`hasPlayed`), used to enforce the Audio Lineup mystery clip's no-replay rule
(`allowReplay: false`).

### `Homeview.swift`

Landing screen — streak/points/level header, a single entry point (`StartQuizCardView`, labeled
"Continue Quiz" instead of "Start Quiz" when a snapshot exists) that launches `QuizSessionView`
either fresh from `QuizSet.activeSets.flatMap { $0.clips }` or resumed from a saved snapshot, and
a mock leaderboard. There is no per-category/per-set picker anymore; difficulty progression and
category mixing are handled entirely by `QuizProgression`.

### `Extensions.swift`

`Color(hex:)` and `Int.formattedWithCommas`. The file explicitly comments that `Color(hex:)`
should not be redefined elsewhere — reuse this one.

Persisted state is minimal and uses `@AppStorage` directly in `HomeView` (`totalPoints`,
`streakDays`) — there is no persistence layer beyond that. `totalPoints` is incremented from the
session-level `onComplete` callback (fires once, at the very end of a full session), not per round.

## Initial audio clips sourced from
/Users/craigmarkowitz/Documents/Development/Music_IQ/musiciq-audio-mp3
