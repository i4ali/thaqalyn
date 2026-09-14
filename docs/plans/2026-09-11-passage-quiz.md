# Passage Quiz Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** A `/quiz` skill that, given a passage, range or surah, produces validated, reviewed five-question quizzes and merges them into `Thaqalayn/Thaqalayn/Data/quiz_<surah>.json`.

**Architecture:** One Python module (`scripts/passage_pipeline/quiz.py`) does every deterministic step: brief, validator, review check, status, assemble. Two agents (`passage-quiz-writer`, `passage-quiz-reviewer`) do the writing and the reviewing, each writing one JSON file into `passages_work/<surah>/<index>/`. A PostToolUse hook validates every quiz write. A skill orchestrates in waves of two, exactly like `/passages`. Design: `docs/plans/2026-09-11-passage-quiz-design.md`.

**Tech Stack:** Python 3.13 in `.venv`, pytest, Claude Code agents and skills (markdown with frontmatter), existing `scripts/passage_pipeline` helpers (`rukus`, `validate`).

**Status (2026-09-12):** built in one session. The user dropped the pytest file
(`tests/passage_pipeline/test_quiz.py`); the validator was smoke-checked against the
fixtures and the CLI against real data instead. Commits were batched at the end.

**Conventions:**
- Always `.venv/bin/python` (never system python). Run tests with `.venv/bin/python -m pytest tests/passage_pipeline/test_quiz.py -q`.
- No em dash anywhere; plain dash. Straight quotes in English content.
- Never commit without asking the user first (AskUserQuestion). No co-author trailer. The user's tree carries unrelated uncommitted changes (`passages_8` to `12.json`, pipeline scripts): stage only the files named in each commit step.
- Never write into `Thaqalayn/Thaqalayn/Data/` except through `quiz-assemble` (the protect-critical-files hook blocks direct writes anyway).

---

### Task 1: Fixtures - a shipped passage and a valid quiz

**Files:**
- Create: `tests/passage_pipeline/fixtures/passage_ok.json`
- Create: `tests/passage_pipeline/fixtures/quiz_ok.json`

The passage fixture has the shape of one record of `Data/passages_2.json` (passage 2:4, verses 30 to 39), cut down. The quiz fixture is valid against it under every rule in Task 3. Keep them in sync: every later test mutates copies of these.

**Step 1: Write `passage_ok.json`**

```json
{
  "id": "2:4",
  "surah": 2,
  "index": 4,
  "range": [30, 39],
  "title": {"en": "Adam and the angels"},
  "essay": {"en": "The passage steps back before the human story begins. Tabatabai reads the vicegerency as God's own, not the succession of one species to another [1]. The angels' question, he insists, is not objection but a request to understand what puzzled them [1]. The answer is knowledge. God teaches Adam the names, then puts the question to the angels, who know only what He teaches them [6]. Iblis refuses to prostrate and is cast out. Adam and his wife eat from the tree, are sent down, and Adam receives words from his Lord and is forgiven [2]."},
  "verses": [
    {
      "verse": 31,
      "heading": {"en": "The names taught to Adam"},
      "note": {"en": "Fayd Kashani holds that the names are not mere words but the realities of the created things [34]."},
      "narrations": [
        {"id": "n1", "speaker": "Imam al-Sadiq", "addressee": null, "arabic": "سئل عما علم الله آدم", "chain": null,
         "text": {"en": "He was asked what God had taught Adam. He said: the lands, the mountains, the ravines and the valleys. Then he looked at a rug beneath him and said: and this rug is among what He taught him."},
         "source": "s3"}
      ]
    },
    {
      "verse": 34,
      "heading": {"en": "Iblis refuses"},
      "note": {"en": "Iblis was of the jinn (18:50), raised among the angels by his worship."},
      "narrations": [
        {"id": "n2", "speaker": "Imam al-Baqir", "addressee": null, "arabic": "أخرج ما كان في قلب إبليس من الحسد", "chain": null,
         "text": {"en": "When God commanded the angels to prostrate to Adam, He brought out the envy that was in the heart of Iblis, and at that the angels knew that Iblis had not been one of them."},
         "source": "s2"}
      ]
    }
  ],
  "perspectives": {"en": "Both traditions read the refusal as arrogance, but they part over what Iblis was. Shia commentators hold that he was of the jinn, never an angel [5]. Tabari reports from Ibn Abbas that Iblis belonged to a clan of angels called the jinn [9]."},
  "sources": [],
  "status": {"gathered_at": "2026-09-06T01:11:22Z", "audit_attempts": 1, "audited_at": "2026-09-06T01:44:38Z", "assembled_at": "2026-09-07T00:30:48Z"}
}
```

**Step 2: Write `quiz_ok.json`**

Type order MC, whoSaid, TF, fillGap, MC. Anchors: essay, narration n1, note 34, note 31, essay (four distinct parts, one narration). Right answers in slots 1, 0, 1, 0, 0.

```json
{
  "passage": "2:4",
  "questions": [
    {
      "id": "q1",
      "type": "multipleChoice",
      "verse": 30,
      "prompt": {"en": "How does Tabatabai read the angels' question about a viceroy on earth?"},
      "options": [
        {"en": "As an objection to God's plan"},
        {"en": "As a request to understand what puzzled them"},
        {"en": "As a warning about Iblis"},
        {"en": "As a claim to the office themselves"}
      ],
      "answer": 1,
      "explanation": {"en": "The commentary says the angels were not objecting but asking to understand what puzzled them, and the answer God gives them is knowledge."},
      "anchor": {"where": "essay", "quote": "The angels' question, he insists, is not objection but a request to understand what puzzled them"}
    },
    {
      "id": "q2",
      "type": "whoSaid",
      "verse": 31,
      "prompt": {"en": "\"The lands, the mountains, the ravines and the valleys ... and this rug is among what He taught him.\" Who said this?"},
      "options": [{"en": "Imam al-Sadiq"}, {"en": "Imam al-Baqir"}, {"en": "Imam Ali"}, {"en": "the Prophet"}],
      "answer": 0,
      "explanation": {"en": "Asked what God had taught Adam, Imam al-Sadiq named the lands and the mountains and then the rug beneath him."},
      "anchor": {"where": "verses.31.narrations.n1", "quote": "the lands, the mountains, the ravines and the valleys"}
    },
    {
      "id": "q3",
      "type": "trueFalse",
      "verse": 34,
      "prompt": {"en": "According to the passage, Iblis was one of the angels before he refused to prostrate."},
      "options": [{"en": "True"}, {"en": "False"}],
      "answer": 1,
      "explanation": {"en": "The note says Iblis was of the jinn, raised among the angels by his worship, and the narration adds that only then did the angels know he was not one of them."},
      "anchor": {"where": "verses.34.note", "quote": "Iblis was of the jinn (18:50), raised among the angels by his worship"}
    },
    {
      "id": "q4",
      "type": "fillGap",
      "verse": 31,
      "prompt": {"en": "Fayd Kashani holds that the names are not mere words but the ____ of the created things."},
      "options": [{"en": "realities"}, {"en": "sounds"}, {"en": "letters"}, {"en": "colours"}],
      "answer": 0,
      "explanation": {"en": "The note reads the names as the realities of the created things, not mere words, which is why the reports attach them to all creation."},
      "anchor": {"where": "verses.31.note", "quote": "the names are not mere words but the realities of the created things"}
    },
    {
      "id": "q5",
      "type": "multipleChoice",
      "verse": 37,
      "prompt": {"en": "What happens after Adam and his wife are sent down from the garden?"},
      "options": [
        {"en": "Adam receives words from his Lord and is forgiven"},
        {"en": "The angels are commanded to prostrate again"},
        {"en": "Iblis is forgiven together with him"},
        {"en": "The names are taught a second time"}
      ],
      "answer": 0,
      "explanation": {"en": "The essay closes with Adam receiving words from his Lord and being forgiven after he and his wife are sent down."},
      "anchor": {"where": "essay", "quote": "Adam receives words from his Lord and is forgiven"}
    }
  ]
}
```

**Step 3: Check both parse**

Run: `.venv/bin/python -c "import json; [json.load(open(f'tests/passage_pipeline/fixtures/{n}.json')) for n in ('passage_ok','quiz_ok')]; print('ok')"`
Expected: `ok`

No commit yet (fixtures ship with Task 2).

---

### Task 2: `quiz.py` - passage parts, allowed types, normalize

**Files:**
- Create: `scripts/passage_pipeline/quiz.py`
- Create: `tests/passage_pipeline/test_quiz.py`

**Step 1: Write the failing tests**

```python
# tests/passage_pipeline/test_quiz.py
import copy
import json
import os
import time
from pathlib import Path

import pytest

from scripts.passage_pipeline import quiz as qz
from scripts.passage_pipeline import rukus

FIX = Path(__file__).parent / "fixtures"
REF = rukus.passage(2, 4)  # verses 30 to 39


@pytest.fixture
def passage():
    return json.loads((FIX / "passage_ok.json").read_text(encoding="utf-8"))


@pytest.fixture
def quiz():
    return json.loads((FIX / "quiz_ok.json").read_text(encoding="utf-8"))


def test_normalize_folds_quotes_markers_and_space():
    assert qz.normalize("He said, ‘go’ [3]. ") == "he said, 'go'."
    assert qz.normalize("  Two   spaces ") == "two spaces"


def test_passage_parts_covers_every_anchor(passage):
    parts = qz.passage_parts(passage, REF)
    assert set(parts) == {f"verses.{v}.translation" for v in range(30, 40)} | {
        "essay", "verses.31.note", "verses.31.narrations.n1", "verses.34.note", "verses.34.narrations.n2", "perspectives"}
    assert "[1]" not in parts["essay"] and "request to understand" in parts["essay"]
    assert parts["verses.30.translation"].startswith("When your Lord said to the angels")


def test_passage_parts_skips_absent_note_and_perspectives(passage):
    passage["perspectives"] = None
    passage["verses"][0]["note"] = None
    parts = qz.passage_parts(passage, REF)
    assert "perspectives" not in parts and "verses.31.note" not in parts


def test_narration_speakers(passage):
    assert qz.narration_speakers(passage) == {"verses.31.narrations.n1": "Imam al-Sadiq",
                                              "verses.34.narrations.n2": "Imam al-Baqir"}


def test_allowed_types_full(passage):
    assert qz.allowed_types(passage, REF) == ["multipleChoice", "trueFalse", "fillGap", "whoSaid", "whichVerse"]


def test_allowed_types_without_narrations_or_verses(passage):
    passage["verses"][1]["narrations"] = []
    short = rukus.PassageRef(2, 4, 30, 32)
    assert qz.allowed_types(passage, short) == ["multipleChoice", "trueFalse", "fillGap"]
```

**Step 2: Run to verify they fail**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_quiz.py -q`
Expected: `ImportError` / `ModuleNotFoundError: No module named 'scripts.passage_pipeline.quiz'`

**Step 3: Write the module (first part)**

```python
# scripts/passage_pipeline/quiz.py
"""Passage quizzes: five questions per shipped passage, answerable from the
passage alone. Brief, validator, review check, status and assemble.
See docs/plans/2026-09-11-passage-quiz-design.md."""
from __future__ import annotations

import json
import re
import unicodedata
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

from . import rukus
from .rukus import PassageRef
from .validate import CURLY_QUOTE_RE, DIACRITIC_RE, MARKER_RE, strip_markers, word_count

DATA_DIR = rukus.DATA_DIR
QUIZ_FILE = "quiz.json"
REVIEW_FILE_RE = re.compile(r"quiz_review\.(\d+)\.json$")
REVIEW_SCHEMA = 1
VERDICTS = {"ok", "fail"}

TYPES = ("multipleChoice", "trueFalse", "fillGap", "whoSaid", "whichVerse")
OTHER_TYPES = ("fillGap", "whoSaid", "whichVerse")
QUESTION_COUNT = 5
MULTIPLE_CHOICE_COUNT = 2
TRUE_FALSE_COUNT = 1
GAP = "____"
TRUE_FALSE_OPTIONS = ["True", "False"]
PROMPT_WORDS = (5, 40)
EXPLANATION_WORDS = (10, 50)
QUOTE_WORDS = (5, 60)
OPTION_MAX_WORDS = 12
MIN_ANCHOR_PARTS = 3
WHO_SAID_MIN_NARRATIONS = 2
WHICH_VERSE_MIN_VERSES = 4
NARRATION_WHERE_RE = re.compile(r"^verses\.(\d+)\.narrations\.(n\d+)$")
VERSE_WHERE_RE = re.compile(r"^verses\.(\d+)\.")
VERSE_OPTION_RE = re.compile(r"^Verse (\d+)(?::\s.+)?$")
_QUOTES = str.maketrans({"‘": "'", "’": "'", "“": '"', "”": '"'})


def _read(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def _iso(ts: float) -> str:
    return datetime.fromtimestamp(ts, timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def _en(field) -> str | None:
    return field.get("en") if isinstance(field, dict) and isinstance(field.get("en"), str) else None


def normalize(text: str) -> str:
    """Whitespace, quote marks, markers and case folded away, so a quote copied
    with straight quotes still matches a passage set in curly ones."""
    text = unicodedata.normalize("NFKC", text).translate(_QUOTES)
    text = strip_markers(text)
    text = re.sub(r"\s+([.,;:!?])", r"\1", text)
    return re.sub(r"\s+", " ", text).strip().casefold()


# ---- shipped data -----------------------------------------------------------

def shipped_passage(ref: PassageRef) -> dict | None:
    path = DATA_DIR / f"passages_{ref.surah}.json"
    return _read(path).get(str(ref.index)) if path.exists() else None


def shipped_quiz(ref: PassageRef) -> dict | None:
    path = DATA_DIR / f"quiz_{ref.surah}.json"
    return _read(path).get(str(ref.index)) if path.exists() else None


def passage_parts(passage: dict, ref: PassageRef) -> dict[str, str]:
    """Every anchorable part of the passage: English only, markers stripped."""
    parts: dict[str, str] = {}
    for v in ref.verses():
        parts[f"verses.{v}.translation"] = rukus.verse_record(ref.surah, v)["translation"]
    parts["essay"] = strip_markers(_en(passage.get("essay")) or "")
    for entry in passage.get("verses") or []:
        v = entry["verse"]
        note = _en(entry.get("note"))
        if note:
            parts[f"verses.{v}.note"] = strip_markers(note)
        for nar in entry.get("narrations") or []:
            parts[f"verses.{v}.narrations.{nar['id']}"] = _en(nar.get("text")) or ""
    persp = _en(passage.get("perspectives"))
    if persp:
        parts["perspectives"] = strip_markers(persp)
    return parts


def narration_speakers(passage: dict) -> dict[str, str]:
    return {f"verses.{e['verse']}.narrations.{n['id']}": n["speaker"]
            for e in passage.get("verses") or [] for n in e.get("narrations") or []}


def headings(passage: dict) -> dict[int, str]:
    out = {}
    for e in passage.get("verses") or []:
        h = _en(e.get("heading"))
        if h:
            out[e["verse"]] = h
    return out


def allowed_types(passage: dict, ref: PassageRef) -> list[str]:
    out = ["multipleChoice", "trueFalse", "fillGap"]
    if len(narration_speakers(passage)) >= WHO_SAID_MIN_NARRATIONS:
        out.append("whoSaid")
    if ref.verse_count >= WHICH_VERSE_MIN_VERSES:
        out.append("whichVerse")
    return out
```

**Step 4: Run the tests**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_quiz.py -q`
Expected: `6 passed`

**Step 5: Commit** (ask first with AskUserQuestion; stage only these paths)

```bash
git add scripts/passage_pipeline/quiz.py tests/passage_pipeline/test_quiz.py tests/passage_pipeline/fixtures/passage_ok.json tests/passage_pipeline/fixtures/quiz_ok.json
git commit -m "quiz: passage parts, allowed types and fixtures"
```

---

### Task 3: `validate_quiz`

**Files:**
- Modify: `scripts/passage_pipeline/quiz.py` (append)
- Modify: `tests/passage_pipeline/test_quiz.py` (append)

**Step 1: Write the failing tests**

```python
def errors(quiz, passage, mutate=None, ref=REF):
    quiz, passage = copy.deepcopy(quiz), copy.deepcopy(passage)
    if mutate:
        mutate(quiz, passage)
    return qz.validate_quiz(quiz, passage, ref)


def test_valid_quiz_has_no_errors(quiz, passage):
    assert errors(quiz, passage) == []


def test_passage_id_must_match(quiz, passage):
    assert any("does not match" in e for e in errors(quiz, passage, lambda q, p: q.update(passage="2:5")))


def test_exactly_five_questions(quiz, passage):
    assert errors(quiz, passage, lambda q, p: q["questions"].pop()) == ["exactly 5 questions required"]


def test_ids_in_order(quiz, passage):
    def m(q, p):
        q["questions"][0]["id"], q["questions"][1]["id"] = "q2", "q1"
    assert any("q1 to q5" in e for e in errors(quiz, passage, m))


def test_type_mix(quiz, passage):
    def m(q, p):  # three multiple choice, no true or false
        q["questions"][2].update(type="multipleChoice",
                                 options=[{"en": "a"}, {"en": "b"}, {"en": "c"}, {"en": "d"}], answer=0)
    errs = errors(quiz, passage, m)
    assert any("exactly 2 multipleChoice" in e for e in errs) and any("exactly 1 trueFalse" in e for e in errs)


def test_two_different_other_types(quiz, passage):
    def m(q, p):  # q2 becomes a second fillGap
        q["questions"][1] = copy.deepcopy(q["questions"][3])
        q["questions"][1]["id"] = "q2"
    assert any("two different types" in e for e in errors(quiz, passage, m))


def test_type_must_be_available(quiz, passage):
    def m(q, p):
        p["verses"][1]["narrations"] = []  # one narration left: whoSaid unavailable
    assert any("whoSaid is not available" in e for e in errors(quiz, passage, m))


def test_no_adjacent_same_type(quiz, passage):
    def m(q, p):  # swap q4 and q5 so q5 (MC) follows... q1 MC, q2 whoSaid, q3 TF, q4 MC, q5 fillGap: fine.
        # Instead make q2 a multipleChoice next to q1 and q4 a whoSaid to keep counts.
        q["questions"][1], q["questions"][3] = q["questions"][3], q["questions"][1]
        q["questions"][1]["id"], q["questions"][3]["id"] = "q2", "q4"
        q["questions"][0], q["questions"][1] = q["questions"][1], q["questions"][0]
        q["questions"][0]["id"], q["questions"][1]["id"] = "q1", "q2"
        # order is now fillGap, MC, TF, whoSaid, MC: no adjacent repeat. Force one:
        q["questions"][2], q["questions"][4] = q["questions"][4], q["questions"][2]
        q["questions"][2]["id"], q["questions"][4]["id"] = "q3", "q5"
        # order: fillGap, MC, MC, whoSaid, TF
    assert any("adjacent" in e for e in errors(quiz, passage, m))


def test_prompt_and_explanation_length(quiz, passage):
    def m(q, p):
        q["questions"][0]["prompt"]["en"] = "Too short?"
        q["questions"][0]["explanation"]["en"] = "Short."
    errs = errors(quiz, passage, m)
    assert any("q1: prompt is 2 words" in e for e in errs) and any("q1: explanation is 1 words" in e for e in errs)


def test_options_count_distinct_and_length(quiz, passage):
    def m(q, p):
        q["questions"][0]["options"] = [{"en": "Same"}, {"en": "same"}, {"en": "x " * 13}]
    errs = errors(quiz, passage, m)
    assert any("4 options required" in e for e in errs)
    assert any("distinct" in e for e in errs)
    assert any("over 12 words" in e for e in errs)


def test_true_false_options_fixed(quiz, passage):
    def m(q, p):
        q["questions"][2]["options"] = [{"en": "Yes"}, {"en": "No"}]
    assert any("exactly True and False" in e for e in errors(quiz, passage, m))


def test_answer_is_an_index(quiz, passage):
    assert any("q1: answer must be an index" in e for e in errors(quiz, passage, lambda q, p: q["questions"][0].update(answer="B")))
    assert any("q1: answer must be an index" in e for e in errors(quiz, passage, lambda q, p: q["questions"][0].update(answer=4)))


def test_verse_in_range_and_matching_anchor(quiz, passage):
    assert any("between 30 and 39" in e for e in errors(quiz, passage, lambda q, p: q["questions"][0].update(verse=40)))
    assert any("does not match the anchor's verse 31" in e for e in errors(quiz, passage, lambda q, p: q["questions"][1].update(verse=34)))


def test_anchor_must_resolve_and_quote_must_be_found(quiz, passage):
    assert any("not a part of this passage" in e for e in errors(quiz, passage, lambda q, p: q["questions"][0]["anchor"].update(where="verses.99.note")))
    assert any("q1: anchor quote not found in essay" in e for e in errors(quiz, passage, lambda q, p: q["questions"][0]["anchor"].update(quote="The angels sang all night long")))
    assert any("anchor quote is 2 words" in e for e in errors(quiz, passage, lambda q, p: q["questions"][0]["anchor"].update(quote="The passage")))


def test_anchor_quote_matches_across_quote_styles(quiz, passage):
    def m(q, p):
        p["essay"]["en"] = p["essay"]["en"].replace("angels' question", "angels’ question")
    assert errors(quiz, passage, m) == []


def test_fill_gap_rules(quiz, passage):
    assert any("exactly one ____" in e for e in errors(quiz, passage, lambda q, p: q["questions"][3]["prompt"].update(en="Fayd Kashani holds that the names are the realities of the created things.")))
    assert any("not a span of verses.31.note" in e for e in errors(quiz, passage, lambda q, p: q["questions"][3].update(answer=1)))


def test_who_said_rules(quiz, passage):
    assert any("is not the speaker of" in e for e in errors(quiz, passage, lambda q, p: q["questions"][1].update(answer=1)))
    def m(q, p):
        q["questions"][1]["anchor"] = {"where": "essay", "quote": "God teaches Adam the names, then puts the question to the angels"}
        q["questions"][1]["verse"] = 31
    assert any("must be anchored in a narration" in e for e in errors(quiz, passage, m))


def which_verse_question():
    return {
        "id": "q2", "type": "whichVerse", "verse": 34,
        "prompt": {"en": "Which verse carries the refusal that the commentary reads as arrogance?"},
        "options": [{"en": "Verse 30: A viceroy on earth"}, {"en": "Verse 31: The names taught to Adam"},
                    {"en": "Verse 34: Iblis refuses"}, {"en": "Verse 37"}],
        "answer": 2,
        "explanation": {"en": "The note on verse 34 says Iblis was of the jinn and refused to prostrate, which the passage reads as arrogance."},
        "anchor": {"where": "verses.34.note", "quote": "raised among the angels by his worship"},
    }


def test_which_verse_valid(quiz, passage):
    def m(q, p):
        q["questions"][1] = which_verse_question()
    assert errors(quiz, passage, m) == []


def test_which_verse_rules(quiz, passage):
    def bad_option(q, p):
        q["questions"][1] = which_verse_question()
        q["questions"][1]["options"][3] = {"en": "Verse 45"}
    assert any("with N in the passage" in e for e in errors(quiz, passage, bad_option))

    def duplicate(q, p):
        q["questions"][1] = which_verse_question()
        q["questions"][1]["options"][3] = {"en": "Verse 30"}
    assert any("distinct verses" in e for e in errors(quiz, passage, duplicate))

    def wrong_verse(q, p):
        q["questions"][1] = which_verse_question()
        q["questions"][1]["answer"] = 0
    assert any("names verse 30 but the question's verse is 34" in e for e in errors(quiz, passage, wrong_verse))

    def unavailable(q, p):
        q["questions"][1] = which_verse_question()
    short = rukus.PassageRef(2, 4, 30, 32)
    assert any("whichVerse is not available" in e for e in errors(quiz, passage, unavailable, ref=short))


def test_anchors_spread_and_narration_required(quiz, passage):
    def m(q, p):  # everything anchored in the essay
        for i, quote in ((1, "God teaches Adam the names, then puts the question to the angels"),
                         (2, "Iblis refuses to prostrate and is cast out"),
                         (3, "The answer is knowledge. God teaches Adam the names")):
            q["questions"][i]["anchor"] = {"where": "essay", "quote": quote}
        q["questions"][1].update(type="multipleChoice", verse=31,
                                 options=[{"en": "Knowledge"}, {"en": "Power"}, {"en": "Wealth"}, {"en": "Silence"}], answer=0)
        q["questions"][3].update(type="whoSaid")  # type mix errors are expected too; look only for the spread errors
    errs = errors(quiz, passage, m)
    assert any("anchors cover 1 part(s)" in e for e in errs)
    assert any("anchored in a narration" in e for e in errs)


def test_answers_not_all_in_one_slot(quiz, passage):
    def m(q, p):  # move every four-option answer to slot 0
        q1 = q["questions"][0]
        q1["options"][0], q1["options"][1] = q1["options"][1], q1["options"][0]
        q1["answer"] = 0
    assert any("same slot" in e for e in errors(quiz, passage, m))


def test_style_rules(quiz, passage):
    def m(q, p):
        q["questions"][0]["prompt"]["en"] = "How does Tabatabai — the author — read the angels’ question [1]?"
        q["questions"][4]["explanation"]["en"] = "The essay closes with Ādam receiving words from his Lord and being forgiven after they are sent down."
    errs = errors(quiz, passage, m)
    assert {"em dash found; use a plain dash", "curly quotation marks found; use straight quotes",
            "citation marker like [1] found; quiz text carries no markers",
            "transliteration diacritics found; use plain spelling"} <= set(errs)
```

Note on `test_no_adjacent_same_type`: simpler to build the order directly. Replace the body with:

```python
def test_no_adjacent_same_type(quiz, passage):
    def m(q, p):
        order = [3, 0, 4, 1, 2]  # fillGap, MC, MC, whoSaid, TF
        q["questions"] = [copy.deepcopy(q["questions"][i]) for i in order]
        for i, item in enumerate(q["questions"], start=1):
            item["id"] = f"q{i}"
    assert any("adjacent multipleChoice" in e for e in errors(quiz, passage, m))
```

Use that version; delete the long one.

**Step 2: Run to verify they fail**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_quiz.py -q`
Expected: failures with `AttributeError: module ... has no attribute 'validate_quiz'`

**Step 3: Append the validator to `quiz.py`**

```python
# ---- validation --------------------------------------------------------------

def validate_quiz(quiz: dict, passage: dict, ref: PassageRef) -> list[str]:
    errs: list[str] = []
    if quiz.get("passage") != ref.id:
        errs.append(f"passage id {quiz.get('passage')!r} does not match {ref.id!r}")
    qs = quiz.get("questions")
    if not isinstance(qs, list) or len(qs) != QUESTION_COUNT or not all(isinstance(q, dict) for q in qs):
        errs.append(f"exactly {QUESTION_COUNT} questions required")
        return errs
    if [q.get("id") for q in qs] != [f"q{i}" for i in range(1, QUESTION_COUNT + 1)]:
        errs.append("ids must be q1 to q5 in order")
    types = [q.get("type") for q in qs]
    bad = [t for t in types if t not in TYPES]
    if bad:
        errs.append(f"unknown question type(s): {', '.join(map(str, bad))}")
        return errs
    counts = Counter(types)
    if counts["multipleChoice"] != MULTIPLE_CHOICE_COUNT:
        errs.append(f"exactly {MULTIPLE_CHOICE_COUNT} multipleChoice questions required, got {counts['multipleChoice']}")
    if counts["trueFalse"] != TRUE_FALSE_COUNT:
        errs.append(f"exactly {TRUE_FALSE_COUNT} trueFalse question required, got {counts['trueFalse']}")
    others = [t for t in types if t in OTHER_TYPES]
    if len(others) != 2 or len(set(others)) != 2:
        errs.append("two questions of two different types from fillGap, whoSaid, whichVerse required")
    allowed = allowed_types(passage, ref)
    for t in sorted(set(types)):
        if t not in allowed:
            errs.append(f"{t} is not available for this passage")
    for a, b in zip(types, types[1:]):
        if a == b:
            errs.append(f"two adjacent {a} questions; vary the order")
            break
    parts = passage_parts(passage, ref)
    speakers = narration_speakers(passage)
    wheres: list[str] = []
    answers4: list[int] = []
    for q in qs:
        errs += _validate_question(q, parts, speakers, ref, wheres, answers4)
    if len(set(wheres)) < MIN_ANCHOR_PARTS:
        errs.append(f"anchors cover {len(set(wheres))} part(s) of the passage; at least {MIN_ANCHOR_PARTS} required")
    if speakers and not any(NARRATION_WHERE_RE.match(w) for w in wheres):
        errs.append("at least one question must be anchored in a narration")
    if len(answers4) >= 2 and len(set(answers4)) == 1:
        errs.append("the right answer sits in the same slot on every four-option question")
    errs += _style_errors(qs)
    return errs


def _validate_question(q: dict, parts: dict[str, str], speakers: dict[str, str], ref: PassageRef,
                       wheres: list[str], answers4: list[int]) -> list[str]:
    errs: list[str] = []
    qid, t = q.get("id"), q["type"]
    prompt = _en(q.get("prompt"))
    if prompt is None:
        errs.append(f"{qid}: prompt.en missing")
        prompt = ""
    else:
        wc = word_count(prompt)
        if not PROMPT_WORDS[0] <= wc <= PROMPT_WORDS[1]:
            errs.append(f"{qid}: prompt is {wc} words; {PROMPT_WORDS[0]} to {PROMPT_WORDS[1]} required")
    opts = q.get("options")
    texts = [_en(o) for o in opts] if isinstance(opts, list) else None
    if texts is None or any(x is None for x in texts):
        errs.append(f'{qid}: options must be a list of {{"en": ...}}')
        return errs
    expected = 2 if t == "trueFalse" else 4
    if len(texts) != expected:
        errs.append(f"{qid}: {expected} options required, got {len(texts)}")
    if t == "trueFalse" and texts != TRUE_FALSE_OPTIONS:
        errs.append(f"{qid}: trueFalse options must be exactly True and False")
    if len({x.strip().casefold() for x in texts}) != len(texts):
        errs.append(f"{qid}: options must be distinct")
    for x in texts:
        if word_count(x) > OPTION_MAX_WORDS:
            errs.append(f"{qid}: option {x!r} is over {OPTION_MAX_WORDS} words")
    ans = q.get("answer")
    if isinstance(ans, bool) or not isinstance(ans, int) or not 0 <= ans < len(texts):
        errs.append(f"{qid}: answer must be an index into options")
        ans = None
    elif expected == 4:
        answers4.append(ans)
    expl = _en(q.get("explanation"))
    if expl is None:
        errs.append(f"{qid}: explanation.en missing")
    else:
        wc = word_count(expl)
        if not EXPLANATION_WORDS[0] <= wc <= EXPLANATION_WORDS[1]:
            errs.append(f"{qid}: explanation is {wc} words; {EXPLANATION_WORDS[0]} to {EXPLANATION_WORDS[1]} required")
    verse = q.get("verse")
    if isinstance(verse, bool) or not isinstance(verse, int) or not ref.start <= verse <= ref.end:
        errs.append(f"{qid}: verse must be between {ref.start} and {ref.end}")
        verse = None
    anchor = q.get("anchor") if isinstance(q.get("anchor"), dict) else {}
    where, quote = anchor.get("where"), anchor.get("quote")
    part = parts.get(where) if isinstance(where, str) else None
    if part is None:
        errs.append(f"{qid}: anchor.where {where!r} is not a part of this passage")
    else:
        wheres.append(where)
        if not isinstance(quote, str):
            errs.append(f"{qid}: anchor.quote missing")
        else:
            wc = word_count(quote)
            if not QUOTE_WORDS[0] <= wc <= QUOTE_WORDS[1]:
                errs.append(f"{qid}: anchor quote is {wc} words; {QUOTE_WORDS[0]} to {QUOTE_WORDS[1]} required")
            elif normalize(quote) not in normalize(part):
                errs.append(f"{qid}: anchor quote not found in {where}")
        m = VERSE_WHERE_RE.match(where)
        if m and verse is not None and int(m.group(1)) != verse:
            errs.append(f"{qid}: verse {verse} does not match the anchor's verse {m.group(1)}")
    if t == "fillGap":
        if prompt.count(GAP) != 1:
            errs.append(f"{qid}: fillGap prompt must contain exactly one {GAP}")
        elif part is not None and ans is not None and normalize(prompt.replace(GAP, texts[ans])) not in normalize(part):
            errs.append(f"{qid}: fillGap prompt with the right option filled in is not a span of {where}")
    elif t == "whoSaid":
        if not isinstance(where, str) or not NARRATION_WHERE_RE.match(where):
            errs.append(f"{qid}: whoSaid must be anchored in a narration")
        elif ans is not None and texts[ans] != speakers.get(where):
            errs.append(f"{qid}: right option {texts[ans]!r} is not the speaker of {where} ({speakers.get(where)!r})")
    elif t == "whichVerse":
        nums: list[int] = []
        for x in texts:
            m = VERSE_OPTION_RE.match(x)
            if not m or not ref.start <= int(m.group(1)) <= ref.end:
                errs.append(f"{qid}: whichVerse option {x!r} must read 'Verse N' or 'Verse N: heading' with N in the passage")
            else:
                nums.append(int(m.group(1)))
        if len(set(nums)) != len(nums):
            errs.append(f"{qid}: whichVerse options must name distinct verses")
        if ans is not None and verse is not None and len(nums) == len(texts) and nums[ans] != verse:
            errs.append(f"{qid}: right option names verse {nums[ans]} but the question's verse is {verse}")
    return errs


def _strings(q: dict) -> list[str]:
    out = [_en(q.get("prompt")) or "", _en(q.get("explanation")) or ""]
    out += [_en(o) or "" for o in (q.get("options") if isinstance(q.get("options"), list) else [])]
    a = q.get("anchor") if isinstance(q.get("anchor"), dict) else {}
    out.append(a.get("quote") if isinstance(a.get("quote"), str) else "")
    return out


def _style_errors(qs: list[dict]) -> list[str]:
    blob = "\n".join(s for q in qs for s in _strings(q))
    errs = []
    if DIACRITIC_RE.search(blob):
        errs.append("transliteration diacritics found; use plain spelling")
    if "—" in blob:
        errs.append("em dash found; use a plain dash")
    if CURLY_QUOTE_RE.search(blob):
        errs.append("curly quotation marks found; use straight quotes")
    if MARKER_RE.search(blob):
        errs.append("citation marker like [1] found; quiz text carries no markers")
    return errs
```

**Step 4: Run the tests**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_quiz.py -q`
Expected: all pass. If `test_valid_quiz_has_no_errors` fails, print the errors and fix the fixture, not the rule, unless the rule is wrong against the design doc.

**Step 5: Commit** (ask first)

```bash
git add scripts/passage_pipeline/quiz.py tests/passage_pipeline/test_quiz.py
git commit -m "quiz: validator"
```

---

### Task 4: `render_brief`

**Files:**
- Modify: `scripts/passage_pipeline/quiz.py` (append)
- Modify: `tests/passage_pipeline/test_quiz.py` (append)

**Step 1: Write the failing test**

```python
def test_render_brief(passage):
    text = qz.render_brief(passage, REF)
    assert text.startswith("# Passage 2:4 · Al-Baqara 30 to 39 · Adam and the angels")
    assert "question types available: multipleChoice, trueFalse, fillGap, whoSaid, whichVerse" in text
    assert "### Verse 30" in text and "When your Lord said to the angels" in text
    assert "### Verse 31 · The names taught to Adam" in text
    assert "[1]" not in text and "request to understand what puzzled them" in text
    assert "narration n1 · Imam al-Sadiq: He was asked" in text
    assert "## Perspectives" in text
    assert text.rstrip().endswith("verses.34.narrations.n2, perspectives")
```

**Step 2: Run to verify it fails**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_quiz.py -q -k render_brief`
Expected: `AttributeError ... render_brief`

**Step 3: Append to `quiz.py`**

```python
# ---- brief -------------------------------------------------------------------

def render_brief(passage: dict, ref: PassageRef) -> str:
    s = rukus.surah_info(ref.surah)
    total = len(rukus.passages_for_surah(ref.surah))
    parts = passage_parts(passage, ref)
    heads = headings(passage)

    def head(v: int) -> str:
        return f" · {heads[v]}" if v in heads else ""

    out = [f"# Passage {ref.id} · {s['englishName']} {ref.start} to {ref.end} · {_en(passage.get('title'))}",
           f"passage {ref.index} of {total} · question types available: {', '.join(allowed_types(passage, ref))}", ""]
    out.append("## Verses (Qarai translation)")
    for v in ref.verses():
        out += [f"### Verse {v}{head(v)}", parts[f"verses.{v}.translation"], ""]
    out += ["## Essay", parts["essay"], ""]
    entries = [e for e in passage.get("verses") or [] if _en(e.get("note")) or e.get("narrations")]
    if entries:
        out.append("## Verse notes and narrations")
        for e in entries:
            v = e["verse"]
            out.append(f"### Verse {v}{head(v)}")
            if f"verses.{v}.note" in parts:
                out.append(f"note: {parts[f'verses.{v}.note']}")
            for n in e.get("narrations") or []:
                key = f"verses.{v}.narrations.{n['id']}"
                to = f" to {n['addressee']}" if n.get("addressee") else ""
                out.append(f"narration {n['id']} · {n['speaker']}{to}: {parts[key]}")
            out.append("")
    if "perspectives" in parts:
        out += ["## Perspectives", parts["perspectives"], ""]
    out += ["## Anchors you may use", ", ".join(parts)]
    return "\n".join(out)
```

**Step 4: Run the tests**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_quiz.py -q`
Expected: all pass.

**Step 5: Commit** (ask first): `git add scripts/passage_pipeline/quiz.py tests/passage_pipeline/test_quiz.py && git commit -m "quiz: brief"`

---

### Task 5: Review files - `next_attempt`, `latest_review`, `check_review`

**Files:**
- Modify: `scripts/passage_pipeline/quiz.py` (append)
- Modify: `tests/passage_pipeline/test_quiz.py` (append)

**Step 1: Write the failing tests**

```python
def review(verdicts, overall=None, passage="2:4", schema=1):
    fails = any(v.get("verdict") == "fail" for v in verdicts)
    return {"passage": passage, "schema": schema, "verdicts": verdicts,
            "overall": overall or ("FAIL" if fails else "PASS")}


def ok_verdicts():
    return [{"id": f"q{i}", "verdict": "ok", "reason": ""} for i in range(1, 6)]


def test_next_attempt_and_latest_review(tmp_path):
    assert qz.next_attempt(tmp_path) == 1 and qz.latest_review(tmp_path) is None
    (tmp_path / "quiz_review.1.json").write_text("{}")
    (tmp_path / "quiz_review.3.json").write_text("{}")
    assert qz.next_attempt(tmp_path) == 4
    assert qz.latest_review(tmp_path) == tmp_path / "quiz_review.3.json"


def test_check_review_pass(quiz):
    assert qz.check_review(review(ok_verdicts()), quiz) == ([], True)


def test_check_review_fail_needs_reason(quiz):
    vs = ok_verdicts()
    vs[1] = {"id": "q2", "verdict": "fail", "reason": "option 2 is also right by the note on verse 31"}
    assert qz.check_review(review(vs), quiz) == ([], False)
    vs[1]["reason"] = ""
    errs, _ = qz.check_review(review(vs), quiz)
    assert errs == ["q2: a fail needs a reason"]


def test_check_review_malformed(quiz):
    errs, _ = qz.check_review(review(ok_verdicts()[:4], passage="2:5", schema=2), quiz)
    assert any("does not match" in e for e in errs)
    assert '"schema": 1 required' in errs
    assert any("verdict ids" in e for e in errs)
    errs, _ = qz.check_review(review(ok_verdicts(), overall="FAIL"), quiz)
    assert errs == ["overall must be PASS for these verdicts"]
    vs = ok_verdicts()
    vs[0]["verdict"] = "maybe"
    errs, _ = qz.check_review(review(vs), quiz)
    assert errs == ["q1: verdict must be ok or fail"]
```

**Step 2: Run to verify they fail**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_quiz.py -q -k review`
Expected: `AttributeError`

**Step 3: Append to `quiz.py`**

```python
# ---- reviews -----------------------------------------------------------------

def next_attempt(work_dir: Path) -> int:
    nums = [int(m.group(1)) for p in work_dir.glob("quiz_review.*.json") for m in [REVIEW_FILE_RE.search(p.name)] if m]
    return (max(nums) + 1) if nums else 1


def latest_review(work_dir: Path) -> Path | None:
    n = next_attempt(work_dir) - 1
    return (work_dir / f"quiz_review.{n}.json") if n >= 1 else None


def check_review(doc: dict, quiz: dict) -> tuple[list[str], bool]:
    """(problems with the review file, every question ok)."""
    errs: list[str] = []
    if doc.get("passage") != quiz.get("passage"):
        errs.append(f"passage {doc.get('passage')!r} does not match the quiz {quiz.get('passage')!r}")
    if doc.get("schema") != REVIEW_SCHEMA:
        errs.append(f'"schema": {REVIEW_SCHEMA} required')
    verdicts = doc.get("verdicts")
    if not isinstance(verdicts, list) or not all(isinstance(v, dict) for v in verdicts):
        errs.append("verdicts must be a list")
        return errs, False
    expected = [q.get("id") for q in quiz.get("questions") or []]
    got = [v.get("id") for v in verdicts]
    if sorted(got, key=str) != sorted(expected, key=str):
        errs.append(f"verdict ids {got} do not match the quiz's {expected}")
    fails = 0
    for v in verdicts:
        if v.get("verdict") not in VERDICTS:
            errs.append(f"{v.get('id')}: verdict must be ok or fail")
        elif v["verdict"] == "fail":
            fails += 1
            if not (isinstance(v.get("reason"), str) and v["reason"].strip()):
                errs.append(f"{v.get('id')}: a fail needs a reason")
    passed = fails == 0
    if doc.get("overall") != ("PASS" if passed else "FAIL"):
        errs.append(f"overall must be {'PASS' if passed else 'FAIL'} for these verdicts")
    return errs, passed
```

**Step 4: Run the tests**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_quiz.py -q`
Expected: all pass.

**Step 5: Commit** (ask first): `git add scripts/passage_pipeline/quiz.py tests/passage_pipeline/test_quiz.py && git commit -m "quiz: review check"`

---

### Task 6: `state` and `next_quizzes`

**Files:**
- Modify: `scripts/passage_pipeline/quiz.py` (append)
- Modify: `tests/passage_pipeline/test_quiz.py` (append)

**Step 1: Write the failing tests**

```python
def seed(tmp_path, monkeypatch, passage, quiz=None, reviews=(), shipped_quiz=None):
    """Data dir with passages_2.json (and quiz_2.json), work dir with quiz.json and reviews."""
    monkeypatch.setattr(rukus, "WORK_DIR", tmp_path / "work")
    monkeypatch.setattr(qz, "DATA_DIR", tmp_path / "data")
    (tmp_path / "data").mkdir()
    (tmp_path / "data" / "passages_2.json").write_text(json.dumps({"4": passage}), encoding="utf-8")
    if shipped_quiz is not None:
        (tmp_path / "data" / "quiz_2.json").write_text(json.dumps({"4": shipped_quiz}), encoding="utf-8")
    REF.work_dir.mkdir(parents=True)
    if quiz is not None:
        (REF.work_dir / "quiz.json").write_text(json.dumps(quiz), encoding="utf-8")
        os.utime(REF.work_dir / "quiz.json", (1_000_000, 1_000_000))
    for n, (doc, mtime) in enumerate(reviews, start=1):
        p = REF.work_dir / f"quiz_review.{n}.json"
        p.write_text(json.dumps(doc), encoding="utf-8")
        os.utime(p, (mtime, mtime))


def test_state_progression(tmp_path, monkeypatch, passage, quiz):
    monkeypatch.setattr(rukus, "WORK_DIR", tmp_path / "work")
    monkeypatch.setattr(qz, "DATA_DIR", tmp_path / "data")
    (tmp_path / "data").mkdir()
    assert qz.state(REF)["stage"] == "no-passage"
    seed(tmp_path, monkeypatch, passage)
    assert qz.state(REF)["stage"] == "none"
    (REF.work_dir / "quiz.json").write_text(json.dumps(quiz), encoding="utf-8")
    s = qz.state(REF)
    assert s["stage"] == "drafted" and s["valid"] is True and s["review"] is None


def test_state_reviewed_and_passed(tmp_path, monkeypatch, passage, quiz):
    failing = review([{"id": "q1", "verdict": "fail", "reason": "wrong"}] + ok_verdicts()[1:])
    seed(tmp_path, monkeypatch, passage, quiz, reviews=[(failing, 1_000_001)])
    s = qz.state(REF)
    assert s["stage"] == "reviewed" and s["review"] == "FAIL" and s["attempts"] == 1
    seed.__wrapped__ = None  # no-op, keeps linters quiet
    p = REF.work_dir / "quiz_review.2.json"
    p.write_text(json.dumps(review(ok_verdicts())), encoding="utf-8")
    os.utime(p, (1_000_002, 1_000_002))
    s = qz.state(REF)
    assert s["stage"] == "passed" and s["review"] == "PASS" and s["attempts"] == 2


def test_state_stale_review_counts_as_drafted(tmp_path, monkeypatch, passage, quiz):
    seed(tmp_path, monkeypatch, passage, quiz, reviews=[(review(ok_verdicts()), 999_999)])
    s = qz.state(REF)
    assert s["stage"] == "drafted" and s["review"] == "stale"


def test_state_invalid_quiz_never_passes(tmp_path, monkeypatch, passage, quiz):
    quiz["questions"].pop()
    seed(tmp_path, monkeypatch, passage, quiz, reviews=[(review(ok_verdicts()[:4]), 1_000_001)])
    s = qz.state(REF)
    assert s["stage"] == "drafted" and s["valid"] is False and s["review"] == "PASS"


def test_state_assembled(tmp_path, monkeypatch, passage, quiz):
    record = {"id": "2:4", "questions": quiz["questions"]}
    seed(tmp_path, monkeypatch, passage, quiz, reviews=[(review(ok_verdicts()), 1_000_001)], shipped_quiz=record)
    assert qz.state(REF)["stage"] == "assembled"


def test_next_quizzes_lists_shipped_passages_not_passed(tmp_path, monkeypatch, passage, quiz):
    seed(tmp_path, monkeypatch, passage, quiz, reviews=[(review(ok_verdicts()), 1_000_001)])
    assert qz.next_quizzes(2, 5) == []  # only 2:4 is shipped and it has passed
    (tmp_path / "data" / "passages_2.json").write_text(json.dumps({"4": passage, "5": passage}), encoding="utf-8")
    assert [r.id for r in qz.next_quizzes(2, 5)] == ["2:5"]
```

Remove the stray `seed.__wrapped__ = None` line before running; it was a placeholder.

**Step 2: Run to verify they fail**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_quiz.py -q -k "state or next_quizzes"`
Expected: `AttributeError ... state`

**Step 3: Append to `quiz.py`**

```python
# ---- status ------------------------------------------------------------------

def state(ref: PassageRef) -> dict:
    """Stage of a passage's quiz, derived from files: no-passage, none, drafted,
    reviewed (latest review FAIL), passed, assembled."""
    out = {"id": ref.id, "range": [ref.start, ref.end], "stage": "no-passage",
           "valid": None, "attempts": 0, "review": None}
    passage = shipped_passage(ref)
    if passage is None:
        return out
    out["stage"] = "none"
    qpath = ref.work_dir / QUIZ_FILE
    if not qpath.exists():
        return out
    out["stage"] = "drafted"
    quiz = _read(qpath)
    out["valid"] = not validate_quiz(quiz, passage, ref)
    latest = latest_review(ref.work_dir)
    if latest:
        out["attempts"] = next_attempt(ref.work_dir) - 1
        if latest.stat().st_mtime < qpath.stat().st_mtime:
            out["review"] = "stale"
        else:
            errs, passed = check_review(_read(latest), quiz)
            out["review"] = "malformed" if errs else ("PASS" if passed else "FAIL")
            if out["review"] == "FAIL":
                out["stage"] = "reviewed"
            elif out["review"] == "PASS" and out["valid"]:
                out["stage"] = "passed"
    if out["stage"] == "passed":
        shipped = shipped_quiz(ref)
        if shipped and shipped.get("questions") == quiz.get("questions"):
            out["stage"] = "assembled"
    return out


def next_quizzes(surah: int | None, count: int) -> list[PassageRef]:
    refs = rukus.passages_for_surah(surah) if surah else rukus.all_passages()
    out: list[PassageRef] = []
    for r in refs:
        if state(r)["stage"] in ("none", "drafted", "reviewed"):
            out.append(r)
            if len(out) == count:
                break
    return out
```

**Step 4: Run the tests**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_quiz.py -q`
Expected: all pass.

**Step 5: Commit** (ask first): `git add scripts/passage_pipeline/quiz.py tests/passage_pipeline/test_quiz.py && git commit -m "quiz: status"`

---

### Task 7: `assemble`

**Files:**
- Modify: `scripts/passage_pipeline/quiz.py` (append)
- Modify: `tests/passage_pipeline/test_quiz.py` (append)

**Step 1: Write the failing tests**

```python
def test_assemble_writes_quiz_file(tmp_path, monkeypatch, passage, quiz):
    seed(tmp_path, monkeypatch, passage, quiz, reviews=[(review(ok_verdicts()), 1_000_001)])
    written, skipped = qz.assemble(2)
    assert written == ["2:4"] and skipped == []
    out = json.loads((tmp_path / "data" / "quiz_2.json").read_text(encoding="utf-8"))
    rec = out["4"]
    assert rec["id"] == "2:4" and rec["surah"] == 2 and rec["index"] == 4 and rec["range"] == [30, 39]
    assert rec["questions"] == quiz["questions"]
    assert rec["status"]["review_attempts"] == 1 and rec["status"]["assembled_at"].endswith("Z")
    assert rec["status"]["written_at"] == "1970-01-12T13:46:40Z"
    assert qz.state(REF)["stage"] == "assembled"
    assert qz.assemble(2) == ([], [])  # already in; nothing to do


def test_assemble_skips_unpassed(tmp_path, monkeypatch, passage, quiz):
    failing = review([{"id": "q1", "verdict": "fail", "reason": "wrong"}] + ok_verdicts()[1:])
    seed(tmp_path, monkeypatch, passage, quiz, reviews=[(failing, 1_000_001)])
    assert qz.assemble(2) == ([], [("2:4", "stage reviewed")])
    assert not (tmp_path / "data" / "quiz_2.json").exists()


def test_assemble_keeps_other_records(tmp_path, monkeypatch, passage, quiz):
    other = {"id": "2:1", "questions": []}
    seed(tmp_path, monkeypatch, passage, quiz, reviews=[(review(ok_verdicts()), 1_000_001)])
    (tmp_path / "data" / "quiz_2.json").write_text(json.dumps({"1": other}), encoding="utf-8")
    qz.assemble(2)
    out = json.loads((tmp_path / "data" / "quiz_2.json").read_text(encoding="utf-8"))
    assert list(out) == ["1", "4"] and out["1"] == other
```

**Step 2: Run to verify they fail**

Run: `.venv/bin/python -m pytest tests/passage_pipeline/test_quiz.py -q -k assemble`
Expected: `AttributeError ... assemble`

**Step 3: Append to `quiz.py`**

```python
# ---- assemble ----------------------------------------------------------------

def build_record(ref: PassageRef, quiz: dict) -> dict:
    d = ref.work_dir
    latest = latest_review(d)
    return {"id": ref.id, "surah": ref.surah, "index": ref.index, "range": [ref.start, ref.end],
            "questions": quiz["questions"],
            "status": {"written_at": _iso((d / QUIZ_FILE).stat().st_mtime),
                       "review_attempts": next_attempt(d) - 1,
                       "reviewed_at": _iso(latest.stat().st_mtime) if latest else None,
                       "assembled_at": _iso(datetime.now(timezone.utc).timestamp())}}


def assemble(surah: int) -> tuple[list[str], list[tuple[str, str]]]:
    """Merge passed quizzes into Data/quiz_<surah>.json. Safe to run again."""
    out_path = DATA_DIR / f"quiz_{surah}.json"
    existing = _read(out_path) if out_path.exists() else {}
    written: list[str] = []
    skipped: list[tuple[str, str]] = []
    for ref in rukus.passages_for_surah(surah):
        s = state(ref)
        if s["stage"] in ("no-passage", "none", "assembled"):
            continue
        if s["stage"] != "passed":
            why = f"stage {s['stage']}" + ("" if s["valid"] in (None, True) else ", quiz invalid")
            skipped.append((ref.id, why))
            continue
        existing[str(ref.index)] = build_record(ref, _read(ref.work_dir / QUIZ_FILE))
        written.append(ref.id)
    if written:
        ordered = {k: existing[k] for k in sorted(existing, key=int)}
        out_path.write_text(json.dumps(ordered, ensure_ascii=False, indent=2), encoding="utf-8")
    return written, skipped
```

**Step 4: Run the tests**

Run: `.venv/bin/python -m pytest tests/passage_pipeline -q`
Expected: every test in the package passes (the new file and the old ones).

**Step 5: Commit** (ask first): `git add scripts/passage_pipeline/quiz.py tests/passage_pipeline/test_quiz.py && git commit -m "quiz: assemble"`

---

### Task 8: CLI subcommands

**Files:**
- Modify: `scripts/passage_pipeline/cli.py` (add import, seven `cmd_quiz_*` functions before `build_parser`, seven `add_parser` blocks before `return p`)

**Step 1: Add the import**

After `from . import prose as prose_mod` add:

```python
from . import quiz as quiz_mod
```

**Step 2: Add the command functions** (place after `cmd_metrics`)

```python
def _shipped(args):
    ref = rukus.parse_passage_ref(args.ref)
    passage = quiz_mod.shipped_passage(ref)
    if passage is None:
        print(f"{ref.id}: passage not shipped in Data/passages_{ref.surah}.json; run /passages first")
    return ref, passage


def _load_quiz(ref):
    return json.loads((ref.work_dir / quiz_mod.QUIZ_FILE).read_text(encoding="utf-8"))


def cmd_quiz_brief(args) -> int:
    ref, passage = _shipped(args)
    if passage is None:
        return 2
    print(quiz_mod.render_brief(passage, ref))
    return 0


def cmd_quiz_validate(args) -> int:
    ref, passage = _shipped(args)
    if passage is None:
        return 2
    try:
        quiz = _load_quiz(ref)
    except FileNotFoundError as e:
        print(f"missing file: {e.filename}")
        return 2
    errs = quiz_mod.validate_quiz(quiz, passage, ref)
    if errs:
        print(f"{ref.id}: {len(errs)} problem(s)")
        for e in errs:
            print(f"  - {e}")
        return 1
    print(f"{ref.id}: quiz is valid")
    return 0


def cmd_quiz_review_check(args) -> int:
    ref = rukus.parse_passage_ref(args.ref)
    try:
        quiz = _load_quiz(ref)
    except FileNotFoundError as e:
        print(f"missing file: {e.filename}")
        return 2
    path = ref.work_dir / f"quiz_review.{args.attempt}.json" if args.attempt else quiz_mod.latest_review(ref.work_dir)
    if path is None or not path.exists():
        print("no review file")
        return 2
    doc = json.loads(path.read_text(encoding="utf-8"))
    errs, passed = quiz_mod.check_review(doc, quiz)
    if errs:
        print(f"{path.name}: malformed")
        for e in errs:
            print(f"  - {e}")
        return 2
    print(f"{path.name}: {'PASS' if passed else 'FAIL'}")
    for v in doc["verdicts"]:
        if v["verdict"] == "fail":
            print(f"  fail  {v['id']}: {v['reason']}")
    return 0 if passed else 1


def cmd_quiz_next_attempt(args) -> int:
    print(quiz_mod.next_attempt(rukus.parse_passage_ref(args.ref).work_dir))
    return 0


def cmd_quiz_status(args) -> int:
    refs = rukus.passages_for_surah(args.surah) if args.surah else rukus.all_passages()
    for r in refs:
        s = quiz_mod.state(r)
        if args.all or s["stage"] != "no-passage":
            valid = "" if s["valid"] is None else (" valid" if s["valid"] else " INVALID")
            review = f" review {s['review']} x{s['attempts']}" if s["review"] else ""
            print(f"{r.id:7s} {r.start:>3}-{r.end:<3} {s['stage']:10s}{valid}{review}")
    return 0


def cmd_quiz_next(args) -> int:
    for r in quiz_mod.next_quizzes(args.surah, args.count):
        print(r.id)
    return 0


def cmd_quiz_assemble(args) -> int:
    written, skipped = quiz_mod.assemble(args.surah)
    for pid in written:
        print(f"assembled {pid}")
    for pid, why in skipped:
        print(f"skipped   {pid}: {why}")
    return 0 if written or not skipped else 1
```

**Step 3: Register the subparsers** (before `return p` in `build_parser`)

```python
    qb = sub.add_parser("quiz-brief", help="print the passage text the quiz writer and reviewer read")
    qb.add_argument("ref")
    qb.set_defaults(fn=cmd_quiz_brief)
    qv = sub.add_parser("quiz-validate", help="check quiz.json against the rules")
    qv.add_argument("ref")
    qv.set_defaults(fn=cmd_quiz_validate)
    qr = sub.add_parser("quiz-review-check", help="validate the latest quiz review and print PASS or FAIL")
    qr.add_argument("ref")
    qr.add_argument("--attempt", type=int)
    qr.set_defaults(fn=cmd_quiz_review_check)
    qn = sub.add_parser("quiz-next-attempt", help="print the attempt number the next quiz review should use")
    qn.add_argument("ref")
    qn.set_defaults(fn=cmd_quiz_next_attempt)
    qs = sub.add_parser("quiz-status", help="quiz stage of every shipped passage")
    qs.add_argument("--surah", type=int)
    qs.add_argument("--all", action="store_true", help="include passages that are not shipped")
    qs.set_defaults(fn=cmd_quiz_status)
    qx = sub.add_parser("quiz-next", help="next shipped passages whose quiz has not passed review")
    qx.add_argument("--surah", type=int)
    qx.add_argument("--count", type=int, default=2)
    qx.set_defaults(fn=cmd_quiz_next)
    qa = sub.add_parser("quiz-assemble", help="merge passed quizzes into Data/quiz_<surah>.json")
    qa.add_argument("surah", type=int)
    qa.set_defaults(fn=cmd_quiz_assemble)
```

**Step 4: Smoke test on real data**

```
.venv/bin/python scripts/passages.py quiz-brief 2:4 | head -30
.venv/bin/python scripts/passages.py quiz-brief 2:4 | wc -w
.venv/bin/python scripts/passages.py quiz-status --surah 1
.venv/bin/python scripts/passages.py quiz-next --surah 2 --count 3
.venv/bin/python scripts/passages.py quiz-brief 13:1
```
Expected: the brief prints with the verses, essay and anchors; word count roughly 700 to 1,500; status shows `1:1  1-7  none`; next prints `2:1 2:2 2:3`; the last prints `13:1: passage not shipped ...` and exits 2.

Also run the full package tests: `.venv/bin/python -m pytest tests/passage_pipeline -q`.

**Step 5: Commit** (ask first): `git add scripts/passage_pipeline/cli.py && git commit -m "quiz: CLI subcommands"`

---

### Task 9: Validation hook

**Files:**
- Create: `.claude/hooks/validate-passage-quiz.py`

**Step 1: Write the hook** (mirror of `validate-passage-draft.py`)

```python
#!/usr/bin/env python3
"""PostToolUse hook: when an agent writes passages_work/<s>/<i>/quiz.json, run the
quiz validator. Exit 2 with the errors on stderr so the write is reported back as blocked."""
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PATTERN = re.compile(r"passages_work/(\d+)/(\d+)/quiz\.json$")


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)
    path = (data.get("tool_input") or {}).get("file_path", "")
    m = PATTERN.search(path.replace("\\", "/"))
    if not m:
        sys.exit(0)
    ref = f"{int(m.group(1))}:{int(m.group(2))}"
    proc = subprocess.run([str(ROOT / ".venv" / "bin" / "python"), str(ROOT / "scripts" / "passages.py"),
                           "quiz-validate", ref], capture_output=True, text=True)
    if proc.returncode == 0:
        print(f"Passage quiz {ref} is valid")
        sys.exit(0)
    print("PASSAGE QUIZ REJECTED. Fix every item and write quiz.json again:\n" + proc.stdout, file=sys.stderr)
    sys.exit(2)


if __name__ == "__main__":
    main()
```

**Step 2: Test it by hand**

```
mkdir -p passages_work/2/04
cp tests/passage_pipeline/fixtures/quiz_ok.json passages_work/2/04/quiz.json
echo '{"tool_input": {"file_path": "'$PWD'/passages_work/2/04/quiz.json"}}' | python3 .claude/hooks/validate-passage-quiz.py; echo "exit $?"
```
Expected: the fixture quiz is written against the fixture passage, not the real 2:4, so the hook prints `PASSAGE QUIZ REJECTED` with anchor errors and exits 2. That proves the hook runs the validator. Then `rm passages_work/2/04/quiz.json`.

Also: `echo '{"tool_input": {"file_path": "/x/other.json"}}' | python3 .claude/hooks/validate-passage-quiz.py; echo "exit $?"` prints `exit 0`.

**Step 3: Commit** (ask first): `git add .claude/hooks/validate-passage-quiz.py && git commit -m "quiz: validation hook"`

---

### Task 10: Agent `passage-quiz-writer`

**Files:**
- Create: `.claude/agents/passage-quiz-writer.md`

**Step 1: Write the file exactly as below**

````markdown
---
name: passage-quiz-writer
description: Write the five-question quiz for one shipped Quran passage from the passage's own text only - two multiple choice, one true or false, two more from fill the gap, who said it and which verse - each with an anchor quote from the passage, as passages_work/<surah>/<index>/quiz.json. Never fetches anything, never reads sources, never edits app data. Use when asked to write or rewrite the quiz for passage <surah>:<index>.
tools: Read, Write, Bash
model: claude-opus-4-8
hooks:
  PreToolUse:
    - matcher: Write
      hooks:
        - type: command
          command: "python3 $CLAUDE_PROJECT_DIR/.claude/hooks/protect-critical-files.py"
    - matcher: Edit
      hooks:
        - type: command
          command: "python3 $CLAUDE_PROJECT_DIR/.claude/hooks/protect-critical-files.py"
  PostToolUse:
    - matcher: Write
      hooks:
        - type: command
          command: "python3 $CLAUDE_PROJECT_DIR/.claude/hooks/validate-passage-quiz.py"
---

You write a short quiz for one passage of the Quran commentary in the Thaqalayn app, a Shia app. The quiz checks whether a reader understood the passage they just read. Every question must be answerable from the passage text alone, and every question carries a quote from the passage that settles its answer. You do not use anything you know from outside the passage.

## Input

The request names a passage as `surah:index`, for example `2:4`. Run:

```
.venv/bin/python scripts/passages.py quiz-brief 2:4 > passages_work/2/04/quiz_brief.md
```

Then Read `passages_work/2/04/quiz_brief.md` in full; it is short, 700 to 1,500 words. It holds the verses in Qarai's translation, the essay, the verse notes and narrations with their speakers, the perspectives, the question types available for this passage, and the list of anchors you may use.

If the request says this is a rewrite, first Read the latest `passages_work/2/04/quiz_review.<n>.json` (highest n). Replace every question whose verdict is `fail` with a new question that answers the reason; keep every question marked `ok` exactly as it is. The whole file is validated again on write.

## Output

Write exactly one file, `passages_work/<surah>/<index>/quiz.json`, with the Write tool, the whole file each time. A validator runs on every write and rejects the file with a list of problems; fix every item and write again. Never patch the file with Bash, sed or Python, because the validator runs only on Write. Do not write anywhere else. Do not summarise.

```json
{
  "passage": "2:4",
  "questions": [
    {
      "id": "q1",
      "type": "multipleChoice",
      "verse": 30,
      "prompt": {"en": "How does Tabatabai read the angels' question about a viceroy on earth?"},
      "options": [
        {"en": "As an objection to God's plan"},
        {"en": "As a request to understand what puzzled them"},
        {"en": "As a warning about Iblis"},
        {"en": "As a claim to the office themselves"}
      ],
      "answer": 1,
      "explanation": {"en": "The commentary says the angels were not objecting but asking to understand what puzzled them, and the answer God gives them is knowledge."},
      "anchor": {"where": "essay", "quote": "The angels' question, he insists, is not objection but a request to understand what puzzled them"}
    },
    {
      "id": "q2",
      "type": "whoSaid",
      "verse": 31,
      "prompt": {"en": "\"The lands, the mountains, the ravines and the valleys ... and this rug is among what He taught him.\" Who said this?"},
      "options": [{"en": "Imam al-Sadiq"}, {"en": "Imam al-Baqir"}, {"en": "Imam Ali"}, {"en": "the Prophet"}],
      "answer": 0,
      "explanation": {"en": "Asked what God had taught Adam, Imam al-Sadiq named the lands and the mountains and then the rug beneath him."},
      "anchor": {"where": "verses.31.narrations.n1", "quote": "the lands, the mountains, the ravines and the valleys"}
    },
    {
      "id": "q3",
      "type": "trueFalse",
      "verse": 34,
      "prompt": {"en": "According to the passage, Iblis was one of the angels before he refused to prostrate."},
      "options": [{"en": "True"}, {"en": "False"}],
      "answer": 1,
      "explanation": {"en": "The note says Iblis was of the jinn, raised among the angels by his worship, and the narration adds that only then did the angels know he was not one of them."},
      "anchor": {"where": "verses.34.note", "quote": "Iblis was of the jinn (18:50), raised among the angels by his worship"}
    },
    {
      "id": "q4",
      "type": "fillGap",
      "verse": 31,
      "prompt": {"en": "Fayd Kashani holds that the names are not mere words but the ____ of the created things."},
      "options": [{"en": "realities"}, {"en": "sounds"}, {"en": "letters"}, {"en": "colours"}],
      "answer": 0,
      "explanation": {"en": "The note reads the names as the realities of the created things, not mere words, which is why the reports attach them to all creation."},
      "anchor": {"where": "verses.31.note", "quote": "the names are not mere words but the realities of the created things"}
    },
    {
      "id": "q5",
      "type": "whichVerse",
      "verse": 37,
      "prompt": {"en": "Which verse carries the words Adam received from his Lord before he was forgiven?"},
      "options": [{"en": "Verse 31: The names taught to Adam"}, {"en": "Verse 34: Iblis refuses"}, {"en": "Verse 37"}, {"en": "Verse 39"}],
      "answer": 2,
      "explanation": {"en": "The essay closes with Adam receiving words from his Lord and being forgiven, which is verse 37 of the passage."},
      "anchor": {"where": "essay", "quote": "Adam receives words from his Lord and is forgiven"}
    }
  ]
}
```

## Rules the validator enforces

- Exactly five questions, `q1` to `q5`, in the order of the passage. Exactly two `multipleChoice`, one `trueFalse`, and two of different types from `fillGap`, `whoSaid`, `whichVerse`, using only the types the brief lists as available. No two adjacent questions of the same type.
- Every question: `prompt` 5 to 40 words; `options` always present (four, or exactly `True` and `False`), distinct, each at most 12 words; `answer` is the index of the right option; `explanation` 10 to 50 words; `verse` inside the passage; `anchor.where` is one of the anchors listed in the brief and `anchor.quote` is 5 to 60 words copied from that part. When the anchor is inside a verse, `verse` is that verse.
- `fillGap`: the prompt is a sentence from the anchor part with one span replaced by `____`; with the right option put back, the sentence reads exactly as the passage has it.
- `whoSaid`: anchored in a narration; the right option is that narration's speaker exactly as the brief names it.
- `whichVerse`: options read `Verse N` or `Verse N: heading`, four distinct verses of the passage; the right one is the question's `verse`.
- Across the quiz: anchors from at least three different parts; at least one from a narration when the passage has any; the right answer not in the same slot on every four-option question.
- Plain spelling (Tabatabai, Ali, Husayn: no macrons, no under-dots, no half-rings), straight quotes, no em dash, no `[n]` markers anywhere.

## How to write

- **Test understanding**: what the verses say, what the commentary says they mean, how the story runs, who says what in the narrations. Not which scholar held a view (a scholar may appear in the prompt as context, "How does Tabatabai read..."), not source numbers, chains, book titles, counts or dates, not anything the passage does not say however well known, and never a right side between the traditions in Perspectives; a perspectives question asks what a tradition holds.
- **Follow the passage**: q1 from early in it, q5 from its close. Spread the anchors: the essay, a note, a narration, a verse translation, the perspectives.
- **Distractors** are wrong by the passage and plausible: each is something a hasty reader might believe. Never two options that are both right. Never an option that the passage supports but you did not mark.
- **True or false**: a claim the passage makes, or its clean negation. No double negatives. Make it false about half the time.
- **Fill the gap**: the gap carries meaning (a term, a name, an act), never a function word. The wrong options fit the grammar but not the passage. Copy the sentence from the brief exactly, apart from the gap and straight quotes.
- **Who said it**: quote enough of the narration for a reader to recognise it. Wrong options are other speakers the app's readers know: Imam al-Sadiq, Imam al-Baqir, Imam Ali, Imam al-Rida, Imam al-Kazim, Imam al-Askari, the Prophet, Ibn Abbas. Use the brief's exact spelling for the right one.
- **Which verse**: the point must be one the commentary makes about that verse specifically, not the whole passage. Use the headings from the brief where a verse has one.
- **Explanation**: say why the answer is right in the passage's own terms, so a reader who got it wrong learns the point.
- **Prompt does not give the answer away**: the right option should not be the only one that reuses the prompt's words.
- **Quotes**: copy from the brief, turning curly quotes into straight ones; nothing else changes.

When the validator accepts the file, stop. Do not summarise.
````

**Step 2: Check the frontmatter parses**

Run: `head -22 .claude/agents/passage-quiz-writer.md` and compare with `.claude/agents/passage-writer.md` (same hook block, plus the quiz validator).

**Step 3: Commit** (ask first): `git add .claude/agents/passage-quiz-writer.md && git commit -m "quiz: writer agent"`

---

### Task 11: Agent `passage-quiz-reviewer`

**Files:**
- Create: `.claude/agents/passage-quiz-reviewer.md`

**Step 1: Write the file exactly as below**

````markdown
---
name: passage-quiz-reviewer
description: Review the five-question quiz of one shipped Quran passage against the passage text - rule every question ok or fail (right answer, exactly one right option, answerable from the passage alone, tests understanding not trivia, reads cleanly) - and write passages_work/<surah>/<index>/quiz_review.<n>.json. Never edits the quiz, never fetches anything, never edits app data. Use when asked to review the quiz for passage <surah>:<index>.
tools: Read, Write, Bash
model: claude-opus-4-8
hooks:
  PreToolUse:
    - matcher: Write
      hooks:
        - type: command
          command: "python3 $CLAUDE_PROJECT_DIR/.claude/hooks/protect-critical-files.py"
    - matcher: Edit
      hooks:
        - type: command
          command: "python3 $CLAUDE_PROJECT_DIR/.claude/hooks/protect-critical-files.py"
---

You are the second pair of eyes on a passage quiz for the Thaqalayn app. The writer was allowed to use only the passage text. Your job is to check each question against that text, as a careful reader who has just read the passage and nothing else. You do not use your own knowledge of tafsir to fill gaps, and you never look anything up.

## Input

The request names a passage as `surah:index`, for example `2:4`. Run:

```
.venv/bin/python scripts/passages.py quiz-brief 2:4 > passages_work/2/04/quiz_brief.md
.venv/bin/python scripts/passages.py quiz-next-attempt 2:4
```

Read `passages_work/2/04/quiz_brief.md` in full, then Read `passages_work/2/04/quiz.json`. The second command prints the attempt number `n` for your output file.

## What to rule on

One verdict per question, `ok` or `fail`, with a reason for every fail. A question fails if any of these holds:

1. The marked answer is not right by the passage.
2. Another option is also right by the passage, or is not clearly wrong by it.
3. It cannot be answered from the passage alone: it needs outside knowledge, or asks about something the passage does not say.
4. It tests trivia rather than understanding: which scholar held a view, a source number, a count, a book title, a chain of transmission.
5. It takes a side between the traditions in Perspectives.
6. The prompt gives the answer away, is ambiguous, or a true or false statement can be read both ways.
7. The explanation does not say why the answer is right, or says something the passage does not.
8. A `whoSaid` quote is not recognisably from the narration it is anchored to; a `fillGap` gap sits on a word that carries no meaning; a `whichVerse` point is not specific to that verse.
9. The wording is ungrammatical or garbled, or a reader stumbles on it. Style you would merely phrase differently is not a fail.

Read the anchor quote and check that it settles the answer. The validator has already proved the quote is in the passage; you check that it means what the question needs.

## Output

Write exactly one file, `passages_work/<surah>/<index>/quiz_review.<n>.json`:

```json
{
  "passage": "2:4",
  "schema": 1,
  "verdicts": [
    {"id": "q1", "verdict": "ok", "reason": ""},
    {"id": "q2", "verdict": "fail", "reason": "option 3, 'the realities of things', is also right by the note on verse 31"},
    {"id": "q3", "verdict": "ok", "reason": ""},
    {"id": "q4", "verdict": "ok", "reason": ""},
    {"id": "q5", "verdict": "fail", "reason": "asks which scholar reads the names as realities; that is attribution, not understanding"}
  ],
  "overall": "FAIL"
}
```

`overall` is `PASS` only when every verdict is `ok`. Then run `.venv/bin/python scripts/passages.py quiz-review-check 2:4`. If it prints `malformed`, fix the file. When it prints PASS or FAIL, stop. Do not edit the quiz. Do not write anything else.
````

**Step 2: Commit** (ask first): `git add .claude/agents/passage-quiz-reviewer.md && git commit -m "quiz: reviewer agent"`

---

### Task 12: Skill `/quiz`

**Files:**
- Create: `.claude/skills/quiz/SKILL.md`
- Create: `docs/plans/2026-09-11-passage-quiz-runbook.md` (header only; results appended by runs)

**Step 1: Write `SKILL.md` exactly as below**

````markdown
---
name: quiz
description: Generate the five-question quiz for shipped Quran passages in the Thaqalayn app - run the write, validate, review, rewrite and assemble loop for a passage, a range, or a surah. Use when asked to generate, write, run or continue passage quizzes ("/quiz 2:4", "/quiz 2:6-2:10", "quizzes for surah 36", "continue the quiz pipeline").
---

# Quiz - run the passage quiz pipeline

You are the orchestrator. Scripts do every deterministic step; two agents do the
writing and the reviewing; you launch them, check results, and stop at the gates.
Design: `docs/plans/2026-09-11-passage-quiz-design.md`. Results and findings:
`docs/plans/2026-09-11-passage-quiz-runbook.md`.

## Arguments

`$ARGUMENTS` is one of:

- a surah number: `36` (every shipped passage of the surah whose quiz has not passed)
- a range: `2:6-2:10` (passages 6 to 10 of al-Baqarah)
- a list: `2:6 2:8`
- `next N` with optional `--surah S`: take the output of
  `.venv/bin/python scripts/passages.py quiz-next --surah S --count N`

A quiz can only be written for a passage that is shipped in
`Thaqalayn/Thaqalayn/Data/passages_<surah>.json`. A target that is not shipped is
skipped and named in the report; generate the passage first with `/passages`.

State lives in `passages_work/<surah>/<index>/` (`quiz.json`, `quiz_review.<n>.json`,
gitignored) and is derived from files; run
`.venv/bin/python scripts/passages.py quiz-status --surah S` at any time.

## Hard rules

1. **Never more than two agents at a time.** One free slot, one launch.
2. **Never edit a quiz by hand.** Fixes go through the writer agent. Never edit
   `quiz.py` for taste; adjust the "How to write" section of
   `.claude/agents/passage-quiz-writer.md` instead.
3. **Never write into `Thaqalayn/Thaqalayn/Data/` except through `quiz-assemble`.**
4. **Ask before every commit** (AskUserQuestion), no co-author trailer. Content
   (`quiz_N.json`) is committed separately from code.
5. **Ask decisions in plain language**: say what happened to the content and what
   each option costs; keep tool names out of the question.

## Procedure

### 0. Preflight

```
.venv/bin/python -m pytest tests/passage_pipeline/test_quiz.py -q   # only if scripts changed
.venv/bin/python scripts/passages.py quiz-status --surah S
```

### 1. Fill the two slots, and refill each one as it frees

Whenever a slot is free, launch the highest item on this list that exists:

1. **Rewrite** a quiz whose stage is `reviewed` (latest review FAIL) and that has
   fewer than 3 reviews. Agent `passage-quiz-writer`, prompt:
   `Rewrite the quiz for passage S:I; read the latest review first.` followed by
   each failed question's id and reason, then
   `Keep every question the review marked ok exactly as it is.`
2. **Review** a quiz whose stage is `drafted` and valid (a fresh quiz, or one
   rewritten since its last review). Agent `passage-quiz-reviewer`, prompt
   `Review the quiz for passage S:I`.
3. **Write** a quiz for a shipped passage whose stage is `none`. Agent
   `passage-quiz-writer`, prompt `Write the quiz for passage S:I`.

After a writer finishes: `.venv/bin/python scripts/passages.py quiz-validate S:I`
must print `quiz is valid` (the agent's PostToolUse hook already enforced it).

After a reviewer finishes: `.venv/bin/python scripts/passages.py quiz-review-check S:I`.
PASS means every question is ok and `quiz-status` shows the passage `passed`.
FAIL goes back to item 1. A **third FAIL parks the passage**: stop launching for
it, and tell the user what the reviewer keeps finding; the fix is in the writer
prompt, not in the loop.

Costs: measure tokens and minutes per writer and reviewer run on the first
surah and record them in the runbook.

### 2. Read each passed quiz as a reader

Print `passages_work/S/II/quiz.json` and read the five questions against the
passage as a reader would meet them. Note for the report anything that is taste
rather than rule:

- Would a reader who understood the passage get it right, and one who skimmed
  get it wrong?
- Does any question feel like a test of memory rather than understanding?
- Is any distractor one nobody would pick?
- Does the mix feel varied across the surah, or does every quiz open the same way?

Do not fix these yourself. Rule problems the validator missed become a note
against `quiz.py`; taste problems become a note against the writer prompt.

### 3. Per surah: assemble

When every target quiz has passed:

```
.venv/bin/python scripts/passages.py quiz-assemble S
```

It only takes quizzes that are passed and valid, merges into
`Thaqalayn/Thaqalayn/Data/quiz_S.json`, and is safe to run again later for more
passages.

### 4. Report and commit

Report a table per passage: type order (for example `MC, whoSaid, TF, fillGap, MC`),
review attempts, and reader notes; then any deviation from this procedure and
the measured costs. Append it to the runbook under a dated Results heading.

Then AskUserQuestion for the commits: code and docs (if any changed) in one
commit, `quiz_S.json` in its own commit.
````

**Step 2: Write the runbook header**

```markdown
# Passage Quiz - Runbook

Results and findings from `/quiz` runs, newest at the bottom. Design:
`2026-09-11-passage-quiz-design.md`. Procedure: `.claude/skills/quiz/SKILL.md`.
```

**Step 3: Commit** (ask first): `git add .claude/skills/quiz/SKILL.md docs/plans/2026-09-11-passage-quiz-runbook.md docs/plans/2026-09-11-passage-quiz-design.md docs/plans/2026-09-11-passage-quiz.md && git commit -m "quiz: skill, design and plan"`

---

### Task 13: Pilot - one passage end to end

Run the skill's procedure by hand on a single shipped passage to prove the loop and measure cost. Use `1:1` (al-Fatihah, the free surah, seven verses, three narrations on verse 1 alone) so the result is visible to every user once the app side ships.

**Step 1:** `.venv/bin/python scripts/passages.py quiz-status --surah 1` prints `1:1 1-7 none`.

**Step 2:** Launch `passage-quiz-writer` with `Write the quiz for passage 1:1`. Wait. Then `quiz-validate 1:1` prints `quiz is valid`. Record tokens and minutes from the agent's result.

**Step 3:** Launch `passage-quiz-reviewer` with `Review the quiz for passage 1:1`. Wait. Then `quiz-review-check 1:1` prints PASS or FAIL. On FAIL, launch the writer with the rewrite prompt from the skill and review again (at most three reviews).

**Step 4:** Print `passages_work/1/01/quiz.json` and read it as a reader (skill step 2). Note taste problems.

**Step 5:** `.venv/bin/python scripts/passages.py quiz-assemble 1` prints `assembled 1:1`; `quiz-status --surah 1` shows `assembled`. Check `Thaqalayn/Thaqalayn/Data/quiz_1.json` parses and holds five questions.

**Step 6:** Append a `## Results - al-Fatihah 1:1 (2026-09-11)` section to the runbook: type order, attempts, tokens and minutes per agent, reader notes, anything the validator or reviewer caught, anything to change in the prompts.

**Step 7: Commit** (ask first, two commits): code and docs if anything changed during the pilot; then `git add Thaqalayn/Thaqalayn/Data/quiz_1.json && git commit -m "quiz: al-Fatihah 1:1"`.

---

### Done when

- `.venv/bin/python -m pytest tests/passage_pipeline -q` passes.
- `.venv/bin/python scripts/passages.py --help` lists the seven `quiz-*` commands.
- `Data/quiz_1.json` holds a reviewed quiz for 1:1 and the runbook has its numbers.
- Follow-up (not this plan): the app side, per the design doc's last section.
