#!/usr/bin/env python3
"""Regenerates music-iq-claude-2026/DebugData.swift from the source question JSON.

Usage:
    python3 Scripts/generate_debug_data.py
    python3 Scripts/generate_debug_data.py --src /path/to/other_export.json

To add or edit quiz content: edit the source JSON (matching its existing schema —
ID, Question, Answer1-4, Correct_Answer, Track_Length, Hint, Level, Type, Active,
File_Path, Score, and for Audio Lineup entries AnswerN_File_Path/AnswerN_Track_Length),
then re-run this script. Don't hand-edit DebugData.swift directly — it's overwritten
each time this runs.
"""

import argparse
import json
from pathlib import Path

DEFAULT_SRC = "/Users/craigmarkowitz/Documents/Development/Music_IQ/AWS/music_iq_questions_for_insert_with_type_and_active.json"
REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_OUT = REPO_ROOT / "music-iq-claude-2026" / "DebugData.swift"

DIFFICULTY = {"1": "easy", "2": "medium", "3": "hard"}


def esc(s: str) -> str:
    return s.strip().replace("\\", "\\\\").replace('"', '\\"')


def parse_track_length(v: str) -> int:
    v = (v or "").strip()
    if not v:
        return 0
    if ":" in v:
        minutes, seconds = v.split(":")
        return int(minutes) * 60 + int(seconds)
    return int(v)


def hint_literal(h: str) -> str:
    h = (h or "").strip()
    return f'"{esc(h)}"' if h else "nil"


def swift_bool(b: bool) -> str:
    return "true" if b else "false"


def is_active(item) -> bool:
    # Audio Lineup entries never have an Active field at all — treat missing as active so they
    # aren't silently dropped. Only an explicit non-"true" value excludes an entry.
    value = item.get("Active")
    if value is None:
        return True
    return value.strip().lower() == "true"


def build_multiple_choice_clips(items):
    by_difficulty = {"easy": [], "medium": [], "hard": []}
    skipped_ids = []
    inactive_ids = []

    for it in items:
        if not is_active(it):
            inactive_ids.append(it.get("ID"))
            continue

        answers = [it.get(f"Answer{i}") for i in range(1, 5)]
        correct_answer = it.get("Correct_Answer")
        if correct_answer not in answers:
            skipped_ids.append(it.get("ID"))
            continue

        difficulty = DIFFICULTY[it["Level"]]
        set_name = {
            "easy": "Music Knowledge (Debug - Easy)",
            "medium": "Music Knowledge (Debug - Medium)",
            "hard": "Music Knowledge (Debug - Hard)",
        }[difficulty]
        correct_index = answers.index(correct_answer)
        name40 = esc(it["Question"])[:40]

        block = f"""            Clip(name: "{name40}", fileName: "{it['File_Path']}",
                 category: .other, setName: "{set_name}", difficulty: .{difficulty},
                 trackLengthSeconds: {parse_track_length(it.get('Track_Length'))}, hint: {hint_literal(it.get('Hint'))},
                 sourceID: "{esc(it['ID'])}", sourceScore: {int(it['Score'])},
                 question: MultipleChoiceQuestion(
                    text: "{esc(it['Question'])}",
                    options: [{", ".join(f'"{esc(a)}"' for a in answers)}], correctIndex: {correct_index})),"""
        by_difficulty[difficulty].append(block)

    return by_difficulty, skipped_ids, inactive_ids


def build_lineup_clips(items):
    labels = ["Clip A", "Clip B", "Clip C", "Clip D"]
    blocks = []
    inactive_ids = []

    for it in items:
        if not is_active(it):
            inactive_ids.append(it.get("ID"))
            continue

        difficulty = DIFFICULTY[it["Level"]]
        file_paths = [it.get(f"Answer{i}_File_Path") for i in range(1, 5)]
        track_lens = [parse_track_length(it.get(f"Answer{i}_Track_Length")) for i in range(1, 5)]
        # The "correct" candidate is whichever answer file matches the mystery clip's own
        # file — Correct_Answer text is occasionally inconsistent with this in the source
        # data, so file identity is the reliable signal.
        correct_index = file_paths.index(it["File_Path"])

        choice_lines = "\n".join(
            f'                        AudioChoice(label: "{labels[i]}", description: "Candidate {i + 1}", '
            f'fileName: "{file_paths[i]}", trackLengthSeconds: {track_lens[i]}, '
            f"isCorrect: {swift_bool(i == correct_index)}),"
            for i in range(4)
        )

        block = f"""            Clip(name: "{esc(it['ID'])} - {it['File_Path']}", fileName: "{it['File_Path']}",
                 category: .memory, setName: "Audio Lineup (Debug)", difficulty: .{difficulty},
                 trackLengthSeconds: {parse_track_length(it.get('Track_Length'))}, hint: {hint_literal(it.get('Hint'))},
                 sourceID: "{esc(it['ID'])}", sourceScore: {int(it['Score'])},
                 lineupQuestion: AudioLineupQuestion(
                    promptText: "{esc(it['Question'])}",
                    choices: [
{choice_lines}
                    ])),"""
        blocks.append(block)

    return blocks, inactive_ids


def generate(src_path: Path, out_path: Path):
    items = json.loads(src_path.read_text())["Items"]
    mk_items = [it for it in items if it.get("Type") == "music-knowledge"]
    mm_items = [it for it in items if it.get("Type") == "music-memory"]

    by_difficulty, skipped_ids, mk_inactive_ids = build_multiple_choice_clips(mk_items)
    lineup_clips, mm_inactive_ids = build_lineup_clips(mm_items)
    inactive_ids = mk_inactive_ids + mm_inactive_ids

    skipped_note  = ", ".join(skipped_ids) if skipped_ids else "(none)"
    inactive_note = ", ".join(inactive_ids) if inactive_ids else "(none)"
    content = f"""
import Foundation

// Debug-only content imported from {src_path.name}.
// Not for production use -- the real app will pull quiz content from S3.
// Regenerated by Scripts/generate_debug_data.py -- do not hand-edit, re-run that script instead.
// Skipped at import time (Correct_Answer did not exactly match any option): {skipped_note}
// Skipped at import time (Active is not "true"): {inactive_note}

/// Flip to true to have HomeView show the imported debug question set instead of the
/// hardcoded sample sets. Temporary until quiz content is pulled from S3.
enum DebugConfig {{
    static let useDebugQuestionSets = true
}}

extension QuizSet {{
    static let debugSets: [QuizSet] = [
        debugKnowledgeEasySet, debugKnowledgeMediumSet, debugKnowledgeHardSet, debugAudioLineupSet
    ]

    static var activeSets: [QuizSet] {{
        DebugConfig.useDebugQuestionSets ? debugSets : sampleSets
    }}

    static let debugKnowledgeEasySet = QuizSet(
        name: "Music Knowledge (Debug - Easy)", category: .other, clips: [
{chr(10).join(by_difficulty['easy'])}
        ])

    static let debugKnowledgeMediumSet = QuizSet(
        name: "Music Knowledge (Debug - Medium)", category: .other, clips: [
{chr(10).join(by_difficulty['medium'])}
        ])

    static let debugKnowledgeHardSet = QuizSet(
        name: "Music Knowledge (Debug - Hard)", category: .other, clips: [
{chr(10).join(by_difficulty['hard'])}
        ])

    static let debugAudioLineupSet = QuizSet(
        name: "Audio Lineup (Debug)", category: .memory, clips: [
{chr(10).join(lineup_clips)}
        ])
}}
"""
    out_path.write_text(content)

    print(f"easy: {len(by_difficulty['easy'])}")
    print(f"medium: {len(by_difficulty['medium'])}")
    print(f"hard: {len(by_difficulty['hard'])}")
    print(f"lineup: {len(lineup_clips)}")
    print(f"skipped (bad Correct_Answer): {skipped_ids}")
    print(f"skipped (inactive): {inactive_ids}")
    print(f"wrote: {out_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--src", default=DEFAULT_SRC, help="Path to the source question JSON export")
    parser.add_argument("--out", default=str(DEFAULT_OUT), help="Path to write DebugData.swift to")
    args = parser.parse_args()
    generate(Path(args.src), Path(args.out))
