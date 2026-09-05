#!/usr/bin/env python3
"""CLI for the passage commentary pipeline. See docs/plans/2026-09-05-passage-commentary-design.md."""
import signal
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from scripts.passage_pipeline.cli import main  # noqa: E402

if __name__ == "__main__":
    # `passages.py brief 2:4 | head` must not spray a BrokenPipeError traceback.
    signal.signal(signal.SIGPIPE, signal.SIG_DFL)
    sys.exit(main())
