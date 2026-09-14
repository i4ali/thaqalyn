# scripts/passage_pipeline/cli.py
from __future__ import annotations

import argparse
import json
import sys

from . import assemble as assemble_mod
from . import audit as audit_mod
from . import brief as brief_mod
from . import gather as gather_mod
from . import metrics as metrics_mod
from . import prose as prose_mod
from . import quiz as quiz_mod
from . import rukus
from . import status as status_mod
from . import titles as titles_mod
from . import validate as validate_mod


def cmd_gather(args) -> int:
    ref = rukus.parse_passage_ref(args.ref)
    result = gather_mod.gather(ref)
    n = len(result["sources"])
    print(f"{ref.id} ({ref.start}-{ref.end}): {n} source blocks -> {ref.work_dir}")
    for key, vs in result["unavailable"].items():
        print(f"  unavailable {key}: {vs}")
    fallback = [f"{r['key']} {r['verses']}" for r in result["sources"] if "greattafsirs.com" in (r.get("url") or "")]
    if fallback:
        print(f"  from greattafsirs: {', '.join(fallback)}")
    partial = [f"{r['key']} {r['verses']} ({r.get('pages')} pages)" for r in result["sources"] if r.get("partial")]
    if partial:
        print(f"  partial (altafsir dropped pages): {', '.join(partial)}")
    if result.get("corpus_hits_dropped"):
        print(f"  dropped {result['corpus_hits_dropped']} hadith corpus hits that do not quote the verse")
    return 0


def load_work(ref):
    d = ref.work_dir
    read = lambda name: json.loads((d / name).read_text(encoding="utf-8"))
    return read("draft.json"), read("sources.json"), read("verses.json")


def cmd_validate(args) -> int:
    ref = rukus.parse_passage_ref(args.ref)
    try:
        draft, gathered, verses = load_work(ref)
    except FileNotFoundError as e:
        print(f"missing file: {e.filename}")
        return 2
    errs = validate_mod.validate_draft(draft, gathered, verses)
    if errs:
        print(f"{ref.id}: {len(errs)} problem(s)")
        for e in errs:
            print(f"  - {e}")
        return 1
    print(f"{ref.id}: draft is valid")
    return 0


def cmd_brief(args) -> int:
    ref = rukus.parse_passage_ref(args.ref)
    d = ref.work_dir
    read = lambda name: json.loads((d / name).read_text(encoding="utf-8"))
    try:
        draft = read("draft.json") if args.audit else None
        print(brief_mod.render(read("verses.json"), read("sources.json"), draft))
    except FileNotFoundError as e:
        print(f"missing file: {e.filename}")
        return 2
    return 0


def cmd_audit_check(args) -> int:
    ref = rukus.parse_passage_ref(args.ref)
    try:
        draft = json.loads((ref.work_dir / "draft.json").read_text(encoding="utf-8"))
    except FileNotFoundError as e:
        print(f"missing file: {e.filename}")
        return 2
    path = ref.work_dir / f"audit.{args.attempt}.json" if args.attempt else audit_mod.latest(ref.work_dir)
    if path is None or not path.exists():
        print("no audit file")
        return 2
    doc = json.loads(path.read_text(encoding="utf-8"))
    errs, passed = audit_mod.check(doc, draft, polished=prose_mod.polished(ref.work_dir))
    if errs:
        print(f"{path.name}: malformed")
        for e in errs:
            print(f"  - {e}")
        return 2
    print(f"{path.name}: {'PASS' if passed else 'FAIL'}")
    if audit_mod.audit_schema(doc) < 2:
        print("  note        schema 1 audit: source glosses were not targets")
    for v in doc["verdicts"]:
        if v["verdict"] != "supported":
            print(f"  {v['verdict']:11s} {v['target']}: {v.get('note') or v['claim']}")
    for u in doc.get("uncited") or []:
        print(f"  uncited     {u['where']}: {u['claim']}")
    # Prose flags do not change PASS or FAIL; they send the passage to the polisher.
    for f in doc.get("prose") or []:
        print(f"  prose       {f['where']}: {f['sentence']}")
    return 0 if passed else 1


def _latest_audit_doc(work_dir):
    path = audit_mod.latest(work_dir)
    return json.loads(path.read_text(encoding="utf-8")) if path and path.exists() else None


def _print_flags(flags) -> None:
    for f in flags:
        print(f"  {f['where']}: {f['sentence']}")
        if f.get("note"):
            print(f"      note: {f['note']}")


def cmd_prose(args) -> int:
    if args.surah:
        total = 0
        for ref in rukus.passages_for_surah(args.surah):
            if not (ref.work_dir / "draft.json").exists():
                continue
            draft = json.loads((ref.work_dir / "draft.json").read_text(encoding="utf-8"))
            flags = prose_mod.outstanding(ref.work_dir, draft, _latest_audit_doc(ref.work_dir))
            if flags:
                total += len(flags)
                print(f"{ref.id} ({ref.start}-{ref.end}): {len(flags)} outstanding")
                _print_flags(flags)
        print(f"{total} outstanding flag(s) in surah {args.surah}")
        return 1 if total else 0
    if not args.ref:
        print("give a passage (2:3) or --surah S")
        return 2
    ref = rukus.parse_passage_ref(args.ref)
    try:
        draft = json.loads((ref.work_dir / "draft.json").read_text(encoding="utf-8"))
    except FileNotFoundError as e:
        print(f"missing file: {e.filename}")
        return 2
    flags = prose_mod.outstanding(ref.work_dir, draft, _latest_audit_doc(ref.work_dir))
    if not flags:
        print(f"{ref.id}: no outstanding flags")
        return 0
    print(f"{ref.id}: {len(flags)} outstanding flag(s)")
    _print_flags(flags)
    return 1


def cmd_prose_check(args) -> int:
    ref = rukus.parse_passage_ref(args.ref)
    try:
        draft = json.loads((ref.work_dir / "draft.json").read_text(encoding="utf-8"))
        doc = json.loads((ref.work_dir / prose_mod.PROSE_FILE).read_text(encoding="utf-8"))
    except FileNotFoundError as e:
        print(f"missing file: {e.filename}")
        return 2
    errs = prose_mod.check(doc, draft)
    if errs:
        print(f"{prose_mod.PROSE_FILE}: malformed")
        for e in errs:
            print(f"  - {e}")
        return 2
    print(f"{prose_mod.PROSE_FILE}: ok ({len(doc['flags'])} flags)")
    return 0


def cmd_next_attempt(args) -> int:
    ref = rukus.parse_passage_ref(args.ref)
    print(audit_mod.next_attempt(ref.work_dir))
    return 0


def cmd_status(args) -> int:
    refs = rukus.passages_for_surah(args.surah) if args.surah else rukus.all_passages()
    for r in refs:
        s = status_mod.state(r)
        if args.all or s["stage"] != "new":
            valid = "" if s["valid"] is None else (" valid" if s["valid"] else " INVALID")
            audit = f" audit {s['audit']} x{s['attempts']}" if s["audit"] else ""
            prose = f" prose {s['prose']}" if s["prose"] else ""
            titles = " titles ok" if s["titles"] else ""
            print(f"{r.id:7s} {r.start:>3}-{r.end:<3} {s['stage']:9s}{valid}{audit}{prose}{titles}")
    return 0


def cmd_next(args) -> int:
    for r in status_mod.next_passages(args.surah, args.count):
        print(r.id)
    return 0


def cmd_titles(args) -> int:
    if args.apply:
        for pid in titles_mod.apply(args.surah):
            print(f"applied {pid}")
        return 0
    print(titles_mod.collect(args.surah))
    return 0


def cmd_assemble(args) -> int:
    written, skipped = assemble_mod.assemble(args.surah)
    for pid in written:
        print(f"assembled {pid}")
    for pid, why in skipped:
        print(f"skipped   {pid}: {why}")
    return 0 if written or not skipped else 1


def cmd_extract_gems(args) -> int:
    print(f"gems_{args.surah}.json: {assemble_mod.extract_gems(args.surah)} verses")
    return 0


def cmd_metrics(args) -> int:
    rs = metrics_mod.rows(args.surah)
    print(f"{'passage':8s} {'stage':9s} {'attempts':>8s} {'first':>6s} {'hours':>6s} {'sources':>8s}")
    for r in rs:
        print(f"{r['id']:8s} {r['stage']:9s} {r['attempts']:>8d} {str(r['first_pass']):>6s} {str(r['hours']):>6s} {r['sources']:>8d}")
    done = [r for r in rs if r["stage"] == "passed"]
    if done:
        print(f"\n{len(done)} passed, first-try {sum(1 for r in done if r['first_pass'])}/{len(done)}, "
              f"mean attempts {sum(r['attempts'] for r in done) / len(done):.1f}")
    return 0


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


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="passages.py", description="Passage commentary pipeline")
    sub = p.add_subparsers(dest="cmd", required=True)
    g = sub.add_parser("gather", help="fetch and cache the citable sources for a passage")
    g.add_argument("ref", help="surah:index, e.g. 2:4")
    g.set_defaults(fn=cmd_gather)
    vp = sub.add_parser("validate", help="check draft.json against the rules")
    vp.add_argument("ref")
    vp.set_defaults(fn=cmd_validate)
    b = sub.add_parser("brief", help="print the packet the writer (or with --audit, the auditor) reads")
    b.add_argument("ref")
    b.add_argument("--audit", action="store_true")
    b.set_defaults(fn=cmd_brief)
    ac = sub.add_parser("audit-check", help="validate the latest audit file and print PASS or FAIL")
    ac.add_argument("ref")
    ac.add_argument("--attempt", type=int)
    ac.set_defaults(fn=cmd_audit_check)
    na = sub.add_parser("next-attempt", help="print the attempt number the next audit file should use")
    na.add_argument("ref")
    na.set_defaults(fn=cmd_next_attempt)
    pr = sub.add_parser("prose", help="outstanding prose flags for a passage (or with --surah, a whole surah)")
    pr.add_argument("ref", nargs="?")
    pr.add_argument("--surah", type=int)
    pr.set_defaults(fn=cmd_prose)
    pc = sub.add_parser("prose-check", help="validate prose.json against the draft")
    pc.add_argument("ref")
    pc.set_defaults(fn=cmd_prose_check)
    st = sub.add_parser("status", help="stage of every passage that has been touched")
    st.add_argument("--surah", type=int)
    st.add_argument("--all", action="store_true", help="include untouched passages")
    st.set_defaults(fn=cmd_status)
    nx = sub.add_parser("next", help="next passages that have not passed audit")
    nx.add_argument("--surah", type=int)
    nx.add_argument("--count", type=int, default=2)
    nx.set_defaults(fn=cmd_next)
    t = sub.add_parser("titles", help="write (or with --apply, apply) the per-surah title review file")
    t.add_argument("surah", type=int)
    t.add_argument("--apply", action="store_true")
    t.set_defaults(fn=cmd_titles)
    a = sub.add_parser("assemble", help="merge passed, title-approved passages into Data/passages_<surah>.json")
    a.add_argument("surah", type=int)
    a.set_defaults(fn=cmd_assemble)
    eg = sub.add_parser("extract-gems", help="copy quickOverview from tafsir_<surah>.json into gems_<surah>.json")
    eg.add_argument("surah", type=int)
    eg.set_defaults(fn=cmd_extract_gems)
    m = sub.add_parser("metrics", help="pilot numbers per passage")
    m.add_argument("surah", type=int)
    m.set_defaults(fn=cmd_metrics)
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
    return p


def main(argv=None) -> int:
    args = build_parser().parse_args(argv)
    return args.fn(args)


if __name__ == "__main__":
    sys.exit(main())
