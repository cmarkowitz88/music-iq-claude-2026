# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

MusicIQ is a SwiftUI iOS app — an ear-training quiz game. Users listen to short audio clips and
answer questions about them (instrument, tempo, time signature, genre feel), plus an "Audio
Lineup" mode where a mystery clip plays once and the user must match it from memory against 4
candidates. A post-quiz scoring model produces an overall "Musical IQ" (80–160) with a tier label.

This is an early-stage prototype: audio files referenced by filename are not actually bundled
anywhere in the repo, and the remote audio fallback points at a placeholder R2 URL
(`AudioManager.baseURL`). Don't assume everything is wired up to real content — check before
building on top of it.

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

Everything lives in `music-iq-claude-2026/`, 13 Swift files, no submodules. The app root
(`music_iq_claude_2026App.swift`) is a `TabView` with three tabs: **Home** (`HomeView`, the main
quiz entry point), **About** (`AboutView`, static app description), and **Settings**
(`SettingsView`, Reset Progress + the debug question finder). Each tab owns its own
`NavigationStack`.

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
force-using either. Per-clip scoring (`Clip.points`, `Difficulty.pointMultiplier`) lives here too.

`MusicalIQScore.calculate(results:)` (accuracy + speed + streak → IQ score 80–160 + tier label)
is scored **by `Difficulty`**, not `ClipCategory` — the debug content pool tags nearly everything
`.other`, so a category breakdown wouldn't be meaningful; difficulty tier is the axis that
actually varies across real content. Returns `nil` (not a misleading default score) when `results`
is empty. See `MusicalIQView.swift` for where it's actually consumed.

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
   content, with a freshly re-rolled bonus question — see below) rather than drawing a new round.
   Score and `GameResult`s only get folded into the session total
   (`QuizSessionViewModel.sessionScore/sessionResults`) when a round is passed — a failed
   attempt's points are discarded. Combo streak (`carryStreak`/`carryBestStreak`) carries forward
   across passed rounds but resets to 0 on a failed retry. `onRoundBanked(Int, [GameResult])`
   fires the moment a round passes — this is what actually credits `totalPoints` and appends to
   `MusicalIQStore` in `HomeView`, since a *full session* (every tier's pool exhausted) is
   effectively unreachable in normal play and can't be the thing anything waits on.

   One clip per round is randomly picked as a **bonus question** (`QuizSet.bonusClipID`), paying
   `Difficulty.bonusQuestionPoints` (1000/1500/2000) instead of its normal value if answered
   correctly — re-rolled every time a round is (re)dealt, same as the shuffle.

   When a session **ends** — either the player taps the top bar's X mid-round
   (`QuizViewModel`'s `onExit` closure, intercepted by `QuizSessionViewModel.requestExit()`) or
   the pool actually runs out — `QuizSessionView` swaps in `MusicalIQRecapView` in place (not a
   nav push) showing a brief "calculating" state before revealing the `MusicalIQScore` computed
   from that session's `sessionResults`.

2. **Round layer** (`QuizView` / `QuizViewModel`) — plays a single round (one `QuizSet`) clip by
   clip. The view model owns the per-question timer (`Task`-based countdown,
   difficulty-dependent duration), scoring/streak/combo logic within the round, and synthesizes
   its own SFX tones at runtime via raw `AVAudioEngine` buffers (no sound asset files). It
   receives `initialStreak`/`initialBestStreak` from the session and reports final streak values
   back out through `onComplete(score, results, streak, bestStreak)` when the round ends. The two
   question UIs (`MCQuestionView`, `LineupQuestionView`) branch on `Clip.questionType`.

When changing round/session behavior (pass threshold, retry logic, round size), the source of
truth is `QuizProgression` + `QuizSessionViewModel.continueAfterOutcome()`, not `QuizViewModel`.

### `QuizPersistence.swift` — persistence (`UserDefaults` + `Codable`, no other storage layer)

Two independent stores here:
- **`QuizPersistence`** saves a `QuizSessionSnapshot` every time a new round begins — the very
  first round, each subsequent round after a pass, and each reshuffled retry after a fail.
  Leaving mid-round (dismissing, backgrounding, the app getting killed) and coming back therefore
  resumes at the *start* of the round that was in progress, not the exact question — nothing
  about mid-question state (timer, audio playback, current selection) is restored, only
  round-level checkpoints are. Cleared when a session ends (either way — see above). `HomeView`
  checks `QuizPersistence.load()` on appear and, if present, launches `QuizSessionView(resuming:)`
  instead of building a fresh session from `QuizSet.activeSets`.
- **`MusicalIQStore`** accumulates every passed round's `[GameResult]` across *all* sessions ever
  played (append-only, cleared by Reset Progress). This is what `HomeView`'s live Musical IQ card
  is computed from — an all-time stat, not a per-session one.

### `MusicalIQView.swift`

`MusicalIQRecapView` (session-exit recap, see above), `MusicalIQCardView` (the live all-time stat
shown on `HomeView`), and `MusicalIQBadge` (the shared circular IQ-number badge both use).

### `AudioManager.swift`

Singleton (`AudioManager.shared`) that plays a clip by filename: checks the app bundle first,
then falls back to a remote URL built from `baseURL` (a placeholder R2 bucket). Tracks "has this
been played once" (`hasPlayed`), used to enforce the Audio Lineup mystery clip's no-replay rule
(`allowReplay: false`).

### `Homeview.swift`

The Home tab — streak/points/level header, a live `MusicalIQCardView`, a single entry point
(`StartQuizCardView`, labeled "Continue Quiz" instead of "Start Quiz" when a snapshot exists)
that launches `QuizSessionView` either fresh from `QuizSet.activeSets.flatMap { $0.clips }` or
resumed from a saved snapshot, and a mock leaderboard. There is no per-category/per-set picker;
difficulty progression and category mixing are handled entirely by `QuizProgression`.

### `SettingsView.swift` / `AboutView.swift`

`SettingsView` holds **Reset Progress** (clears `QuizPersistence`, `MusicalIQStore`, and the
`totalPoints`/`streakDays` `@AppStorage` values, behind a confirmation alert) and, `#if DEBUG`
only, an entry into `DebugQuestionFinderView`. `AboutView` is static app-description content.
Both are plain `NavigationStack`-wrapped tabs, styled to match `HomeView`'s card language.

### `DebugQuestionFinderView.swift`

Entirely wrapped in `#if DEBUG` — compiled out of Release builds. Searches
`QuizSet.activeSets.flatMap { $0.clips }` by filename or source ID and drops the match straight
into a real `QuizView` (a one-clip `QuizSet`) so you can see/hear exactly one question without
playing through a round. Testing-only; not a production feature.

### `Extensions.swift`

`Color(hex:)` and `Int.formattedWithCommas`. The file explicitly comments that `Color(hex:)`
should not be redefined elsewhere — reuse this one.

`totalPoints`/`streakDays` use `@AppStorage` directly in `HomeView`; `totalPoints` is incremented
from `onRoundBanked` (per round pass), not the session-level `onComplete`. See
`QuizPersistence.swift` above for the two other persisted stores (`QuizPersistence`,
`MusicalIQStore`).

## Initial audio clips sourced from
/Users/craigmarkowitz/Documents/Development/Music_IQ/musiciq-audio-mp3
