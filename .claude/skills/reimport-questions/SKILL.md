---
description: Regenerates DebugData.swift from the source quiz-question JSON after questions have been added, edited, or fixed. Use when the user says they've added/edited a question, changed the source JSON, or asks to reimport/regenerate/reload the quiz content.
---

# Reimport Questions

`music-iq-claude-2026/DebugData.swift` is generated, not hand-written. It's built from the
source JSON export at:

```
/Users/craigmarkowitz/Documents/Development/Music_IQ/AWS/music_iq_questions_for_insert_with_type_and_active.json
```

Whenever someone edits that JSON (adds a question, fixes a typo, sets `Active`, etc.), the
regenerated file needs to be rebuilt from it. Never hand-edit `DebugData.swift` directly — it
gets fully overwritten every time the script below runs.

## Steps

1. Run the generator from the project root:

   ```
   python3 Scripts/generate_debug_data.py
   ```

2. Read its printed summary — it reports the easy/medium/hard/lineup clip counts and two skip
   lists:

   ```
   easy: 68
   medium: 89
   hard: 71
   lineup: 17
   skipped (bad Correct_Answer): []
   skipped (inactive): []
   wrote: .../DebugData.swift
   ```

   - If the user just added or edited a specific question, confirm the relevant count actually
     changed (e.g. a new medium-difficulty question should show up as medium going up by 1).
   - If `skipped (bad Correct_Answer)` lists an ID that wasn't skipped before, flag it — it means
     `Correct_Answer` doesn't exactly match one of `Answer1`-`Answer4` for that entry (usually a
     typo), so it's silently excluded until fixed.
   - `skipped (inactive)` lists anything explicitly marked `Active` other than `"true"`.

3. Build to confirm the regenerated file compiles:

   ```
   xcodebuild -project music-iq-claude-2026.xcodeproj -scheme music-iq-claude-2026 -destination 'generic/platform=iOS Simulator' build
   ```

Report back the count changes and any new skips — don't just say "done."
