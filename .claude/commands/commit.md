# Commit

Create a git commit that includes the current app version and build number in the message.

## Instructions

1. Run `git status` to see staged and unstaged changes
2. Read the current `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` from `Thaqalayn.xcodeproj/project.pbxproj`
3. Stage all modified tracked files (do NOT use `git add -A` — add specific files seen in `git status`)
4. Summarize what changed across the staged files (tafsir data, UI changes, scripts, agent configs, etc.)
5. Compose a commit message in this format:

```
v{MARKETING_VERSION} ({CURRENT_PROJECT_VERSION}): {short summary of main changes}

- {bullet 1: key change}
- {bullet 2: key change}
- {bullet 3: key change}
... (only include bullets for meaningful changes, omit trivial ones)

```

6. Create the commit using a HEREDOC to preserve formatting
7. Run `git status` after to confirm success

## Arguments

$ARGUMENTS - Optional short description to use as the commit summary. If not provided, infer from staged changes.

## Notes

- Always include the version string `v{MARKETING_VERSION} ({CURRENT_PROJECT_VERSION}):` at the start of the subject line
- Keep the subject line under 72 characters total
- Do NOT push after committing unless explicitly asked
