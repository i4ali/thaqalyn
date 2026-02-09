# Bump Version

Bump the app version and build number in Info.plist.

## Instructions

1. Read the current version from `Thaqalayn/Info.plist`
2. If user provided a version (e.g., `/bump-version 3.1`), use that version
3. If no version provided, increment the minor version (e.g., 3.0 → 3.1)
4. Always increment the build number by 1
5. Update both `CFBundleShortVersionString` (version) and `CFBundleVersion` (build) in Info.plist
6. Report the changes: "Version: X.X → Y.Y, Build: N → N+1"

## Arguments

$ARGUMENTS - Optional version number (e.g., "3.1" or "4.0"). If not provided, auto-increment minor version.
