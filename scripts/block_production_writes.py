#!/usr/bin/env python3
"""
Block writes to production data files.
This script runs as a Claude Code PreToolUse hook for Write/Edit tools.

Prevents any agent from writing to or modifying files in:
  Thaqalayn/Thaqalayn/Data/

Exit codes:
- 0: Allow the write (file is not in production directory)
- 2: Block the write (file is in production directory)
"""

import json
import sys
from pathlib import Path

# Production data directory patterns to block
BLOCKED_PATHS = [
    "Thaqalayn/Thaqalayn/Data",
    "Thaqalayn/Data",  # Also catch if someone uses shorter path
]


def is_production_file(file_path: str) -> bool:
    """Check if file path is in a production data directory."""
    # Normalize the path
    normalized = str(Path(file_path).resolve())

    for blocked in BLOCKED_PATHS:
        if blocked in file_path or blocked in normalized:
            return True
    return False


def main():
    # Read hook input from stdin
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        # If stdin is empty or invalid, allow by default
        sys.exit(0)

    # Extract file path from tool_input
    tool_input = input_data.get("tool_input", {})
    file_path = tool_input.get("file_path", "")

    if not file_path:
        sys.exit(0)

    # Check if this is a production file
    if is_production_file(file_path):
        filename = Path(file_path).name
        print(f"🚫 BLOCKED: Cannot write to production data file!", file=sys.stderr)
        print(f"", file=sys.stderr)
        print(f"   File: {filename}", file=sys.stderr)
        print(f"   Path: {file_path}", file=sys.stderr)
        print(f"", file=sys.stderr)
        print(f"Production files in Thaqalayn/Thaqalayn/Data/ are protected.", file=sys.stderr)
        print(f"Write to new_tafsir/ or new_quickoverview/ instead.", file=sys.stderr)
        sys.exit(2)

    # Allow the write
    sys.exit(0)


if __name__ == "__main__":
    main()
