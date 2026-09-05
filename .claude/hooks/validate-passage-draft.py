#!/usr/bin/env python3
"""PostToolUse hook: when an agent writes passages_work/<s>/<i>/draft.json, run the
validator. Exit 2 with the errors on stderr so the write is reported back as blocked."""
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PATTERN = re.compile(r"passages_work/(\d+)/(\d+)/draft\.json$")


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
                           "validate", ref], capture_output=True, text=True)
    if proc.returncode == 0:
        print(f"Passage draft {ref} is valid")
        sys.exit(0)
    print("PASSAGE DRAFT REJECTED. Fix every item and write draft.json again:\n" + proc.stdout, file=sys.stderr)
    sys.exit(2)


if __name__ == "__main__":
    main()
