#!/usr/bin/env python3
"""
Protect critical files from accidental modification via Claude Code operations.
This script runs as a Claude Code PreToolUse hook for Bash, Write, and Edit tools.

Protected:
- urdutranslations.csv
- All files in Thaqalayn/Thaqalayn/Data/

Exit codes:
- 0: Command allowed (proceed)
- 2: Command blocked (would modify protected file)

Output format (JSON to stdout):
- Success: {"decision": "allow"}
- Block: {"decision": "block", "reason": "error message"}
"""

import json
import os
import re
import shlex
import sys
from datetime import datetime
from pathlib import Path

# Setup logging to file
LOG_DIR = Path(__file__).parent.parent.parent / "logs"
LOG_FILE = LOG_DIR / "protect_files.log"

# Protected file
PROTECTED_FILE = "urdutranslations.csv"

# Protected directory (relative to project root)
PROTECTED_DIR = "Thaqalayn/Thaqalayn/Data"

# Project root (for resolving absolute paths)
PROJECT_ROOT = Path(__file__).parent.parent.parent.resolve()


def log(message: str):
    """Append a timestamped message to the log file."""
    try:
        LOG_DIR.mkdir(exist_ok=True)
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with open(LOG_FILE, "a", encoding="utf-8") as f:
            f.write(f"[{timestamp}] {message}\n")
    except Exception:
        pass  # Silently fail if logging fails


def output_block(reason: str):
    """Output JSON block decision and exit with code 2."""
    print(json.dumps({"decision": "block", "reason": reason}))
    sys.exit(2)


def output_allow(reason: str = ""):
    """Output JSON allow decision and exit with code 0."""
    print(json.dumps({"decision": "allow"}))
    if reason:
        log(f"ALLOWED: {reason}")
    sys.exit(0)


def matches_protected_file(arg: str) -> bool:
    """
    Check if an argument matches the protected file.
    Handles: direct names, paths, and glob patterns.
    """
    # Direct match
    if arg == PROTECTED_FILE:
        return True

    # Path ending with protected file
    if arg.endswith(f"/{PROTECTED_FILE}") or arg.endswith(f"\\{PROTECTED_FILE}"):
        return True

    # Glob patterns that would match CSV files
    csv_globs = ["*.csv", "*.CSV", "*translations*", "urdu*", "*urdu*"]
    for glob in csv_globs:
        if arg == glob:
            return True

    return False


def matches_protected_dir(arg: str) -> tuple[bool, str]:
    """
    Check if an argument matches or is inside the protected directory.
    Returns (is_match, matched_path).
    """
    # Normalize the argument path
    arg_normalized = arg.rstrip("/\\")

    # Check if arg is exactly the protected directory
    if arg_normalized == PROTECTED_DIR or arg_normalized == f"./{PROTECTED_DIR}":
        return True, PROTECTED_DIR

    # Check if arg is inside the protected directory
    if arg_normalized.startswith(f"{PROTECTED_DIR}/") or arg_normalized.startswith(f"./{PROTECTED_DIR}/"):
        return True, arg_normalized

    # Check for partial paths that would match (e.g., "Data" when in Thaqalayn/Thaqalayn/)
    # This handles cases like "Data/*.json" or "Data/tafsir_1.json"
    if arg_normalized.startswith("Data/") or arg_normalized == "Data":
        return True, f"Thaqalayn/Thaqalayn/{arg_normalized}"

    # Check for parent directory deletions that would include protected dir
    protected_parts = PROTECTED_DIR.split("/")
    for i in range(len(protected_parts)):
        parent = "/".join(protected_parts[:i+1])
        if arg_normalized == parent or arg_normalized == f"./{parent}":
            return True, parent

    # Check for glob patterns that could match protected files
    data_globs = ["*.json", "*.JSON", "tafsir_*", "quran_*"]
    for glob in data_globs:
        if arg == glob:
            return True, f"glob pattern '{glob}'"

    return False, ""


def is_dangerous_rm(args: list) -> tuple[bool, str]:
    """Check if rm command would delete the protected file or directory."""
    # Skip flags to get to file arguments
    skip_next = False
    for arg in args:
        if skip_next:
            skip_next = False
            continue

        # Skip common rm flags
        if arg in ["-f", "-r", "-R", "--force", "--recursive"]:
            continue
        if arg.startswith("-"):
            continue

        # Check if this argument matches protected file
        if matches_protected_file(arg):
            return True, PROTECTED_FILE

        # Check if this argument matches protected directory
        is_dir_match, matched_path = matches_protected_dir(arg)
        if is_dir_match:
            return True, matched_path

        # Check for directory deletion that contains the file
        # rm -rf . or rm -rf ./ would delete everything
        if arg in [".", "./", ".."]:
            return True, "current directory (contains protected files)"

    return False, ""


def is_dangerous_git_clean(args: list) -> tuple[bool, str]:
    """Check if git clean would remove the protected file or directory."""
    # git clean -f removes untracked files
    # git clean -fd removes untracked files and directories
    has_force = "-f" in args or "--force" in args
    has_all = "-x" in args  # -x removes ignored files too

    # If git clean with force is run without specific paths, it could delete our file
    if has_force:
        # Check if there's a path filter that excludes our file
        for arg in args:
            if not arg.startswith("-") and arg not in ["clean"]:
                # There's a path argument, check if it matches
                if matches_protected_file(arg):
                    return True, PROTECTED_FILE
                is_dir_match, matched_path = matches_protected_dir(arg)
                if is_dir_match:
                    return True, matched_path
        # No specific path = clean all untracked
        return True, "all untracked files (includes protected files)"

    return False, ""


def is_dangerous_git_checkout(args: list) -> tuple[bool, str]:
    """Check if git checkout would discard changes to protected file or directory."""
    # git checkout -- file.csv discards changes
    has_double_dash = "--" in args

    if has_double_dash:
        # Everything after -- is a file path
        dash_idx = args.index("--")
        files = args[dash_idx + 1:]
        for f in files:
            if matches_protected_file(f):
                return True, PROTECTED_FILE
            is_dir_match, matched_path = matches_protected_dir(f)
            if is_dir_match:
                return True, matched_path

    return False, ""


def is_dangerous_git_restore(args: list) -> tuple[bool, str]:
    """Check if git restore would discard changes to protected file or directory."""
    for arg in args:
        if matches_protected_file(arg):
            return True, PROTECTED_FILE
        is_dir_match, matched_path = matches_protected_dir(arg)
        if is_dir_match:
            return True, matched_path
    return False, ""


def is_dangerous_python_script(args: list) -> tuple[bool, str]:
    """
    Check if a Python script references protected paths in its source code.
    This catches scripts that have hardcoded paths to protected files.
    Returns (is_dangerous, reason).
    """
    # Skip flags to find the script file
    script_path = None
    for arg in args:
        # Skip python flags
        if arg.startswith("-"):
            # -c means inline code follows, check it directly
            if arg == "-c":
                continue
            continue
        # Skip if it's the code after -c
        if args and "-c" in args:
            c_idx = args.index("-c")
            if args.index(arg) == c_idx + 1:
                # This is inline code, check it for protected paths
                code = arg
                if PROTECTED_DIR in code or PROTECTED_FILE in code:
                    return True, f"inline Python code references protected path"
                if "/Data/" in code and "tafsir" in code.lower():
                    return True, f"inline Python code references Data/tafsir files"
                continue
        # This should be the script path
        if arg.endswith(".py"):
            script_path = arg
            break
        # Could also be a script without .py extension
        if not arg.startswith("-") and "/" in arg:
            script_path = arg
            break

    if not script_path:
        return False, ""

    # Resolve the script path
    try:
        path = Path(script_path)
        if not path.is_absolute():
            path = PROJECT_ROOT / path

        if not path.exists():
            return False, ""

        # Read the script content
        content = path.read_text(encoding="utf-8")

        # Check for references to protected directory (various forms)
        protected_patterns = [
            PROTECTED_DIR,                           # Thaqalayn/Thaqalayn/Data
            PROTECTED_DIR.replace("/", "\\"),        # Windows paths
            f"/{PROTECTED_DIR}/",                    # Absolute path fragment
            "/Thaqalayn/Data/",                      # Partial path
            "Thaqalayn/Data/",                       # Relative
        ]

        for pattern in protected_patterns:
            if pattern in content:
                # Find the line for context
                for i, line in enumerate(content.split("\n"), 1):
                    if pattern in line and not line.strip().startswith("#"):
                        return True, f"Python script '{script_path}' references protected path at line {i}"
                return True, f"Python script '{script_path}' references protected path '{pattern}'"

        # Also check for the protected file
        if PROTECTED_FILE in content:
            for i, line in enumerate(content.split("\n"), 1):
                if PROTECTED_FILE in line and not line.strip().startswith("#"):
                    return True, f"Python script '{script_path}' references protected file at line {i}"
            return True, f"Python script '{script_path}' references protected file '{PROTECTED_FILE}'"

    except Exception as e:
        log(f"Error reading Python script {script_path}: {e}")
        return False, ""

    return False, ""


def is_protected_path(file_path: str) -> tuple[bool, str]:
    """
    Check if a file path points to a protected file or directory.
    Handles both absolute and relative paths.
    Returns (is_protected, matched_path).
    """
    if not file_path:
        return False, ""

    # Normalize the path
    path = Path(file_path)

    # Try to resolve to absolute path
    try:
        if path.is_absolute():
            abs_path = path.resolve()
        else:
            abs_path = (PROJECT_ROOT / path).resolve()

        # Get relative path from project root
        try:
            rel_path = abs_path.relative_to(PROJECT_ROOT)
            rel_str = str(rel_path)
        except ValueError:
            # Path is outside project root
            rel_str = str(path)
    except Exception:
        rel_str = file_path

    # Check if it's the protected file
    if rel_str == PROTECTED_FILE or rel_str.endswith(f"/{PROTECTED_FILE}"):
        return True, PROTECTED_FILE

    # Check if it's inside the protected directory
    if rel_str.startswith(f"{PROTECTED_DIR}/") or rel_str == PROTECTED_DIR:
        return True, rel_str

    # Also check the original path in case resolution failed
    if file_path.endswith(f"/{PROTECTED_FILE}") or file_path == PROTECTED_FILE:
        return True, PROTECTED_FILE

    if f"/{PROTECTED_DIR}/" in file_path or file_path.endswith(f"/{PROTECTED_DIR}"):
        return True, file_path

    return False, ""


def analyze_command(command: str) -> tuple[bool, str]:
    """
    Analyze a bash command for dangerous operations on protected files.
    Returns (is_dangerous, reason).
    """
    # Try to parse the command
    try:
        # Handle shell operators by looking at each part
        parts = re.split(r'[;&|]', command)

        for part in parts:
            part = part.strip()
            if not part:
                continue

            try:
                args = shlex.split(part)
            except ValueError:
                # Malformed command, allow and let bash handle it
                continue

            if not args:
                continue

            cmd = args[0]

            # Check rm commands
            if cmd == "rm":
                is_dangerous, target = is_dangerous_rm(args[1:])
                if is_dangerous:
                    return True, f"rm command would delete {target}"

            # Check git clean
            if cmd == "git" and len(args) > 1 and args[1] == "clean":
                is_dangerous, target = is_dangerous_git_clean(args[1:])
                if is_dangerous:
                    return True, f"git clean could remove {target}"

            # Check git checkout --
            if cmd == "git" and len(args) > 1 and args[1] == "checkout":
                is_dangerous, target = is_dangerous_git_checkout(args[1:])
                if is_dangerous:
                    return True, f"git checkout would discard changes to {target}"

            # Check git restore
            if cmd == "git" and len(args) > 1 and args[1] == "restore":
                is_dangerous, target = is_dangerous_git_restore(args[2:])
                if is_dangerous:
                    return True, f"git restore would discard changes to {target}"

            # Check Python scripts for references to protected paths
            if cmd in ["python3", "python", "python3.9", "python3.10", "python3.11", "python3.12", "python3.13"]:
                is_dangerous, reason = is_dangerous_python_script(args[1:])
                if is_dangerous:
                    return True, reason

        return False, ""

    except Exception as e:
        log(f"Error parsing command: {e}")
        return False, ""


def main():
    # Read hook input from stdin
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        output_allow()

    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})

    # Handle Write and Edit tools
    if tool_name in ["Write", "Edit"]:
        file_path = tool_input.get("file_path", "")

        is_protected, matched = is_protected_path(file_path)
        if is_protected:
            log(f"BLOCKED: Write/Edit to protected path: {matched}")
            output_block(
                f"Protected: Cannot modify {matched}. "
                f"Files in {PROTECTED_DIR}/ are protected from modification. "
                f"If you need to modify this file, please do so manually."
            )
        else:
            output_allow(f"{tool_name} to non-protected path: {file_path}")

    # Handle Bash tool
    elif tool_name == "Bash":
        command = tool_input.get("command", "")

        if not command:
            output_allow("Bash: empty command")

        # Analyze the command
        is_dangerous, reason = analyze_command(command)

        if is_dangerous:
            log(f"BLOCKED: {reason}")
            output_block(
                f"Protected: {reason}. "
                f"This file/directory is protected from accidental deletion. "
                f"If you need to delete or discard changes to protected files, please do so manually."
            )
        else:
            short_cmd = command[:120] + ("..." if len(command) > 120 else "")
            output_allow(f"Bash: {short_cmd}")

    # Unknown tool, allow by default
    else:
        output_allow(f"Unknown tool '{tool_name}' — allowed by default")


if __name__ == "__main__":
    main()
