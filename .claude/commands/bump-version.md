# Bump Version

Bump the app version and build number in the Xcode project file.

## Instructions

1. Read the current `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` from `Thaqalayn.xcodeproj/project.pbxproj`
2. If user provided a version (e.g., `/bump-version 3.1`), use that as the new `MARKETING_VERSION`
3. If no version provided, increment the minor version (e.g., 4.4 → 4.5)
4. Always increment `CURRENT_PROJECT_VERSION` by 1
5. Update ALL occurrences of `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in the pbxproj file (they appear in both Debug and Release configurations)
6. Report the changes: "Version: X.X → Y.Y, Build: N → N+1"

## Arguments

$ARGUMENTS - Optional version number (e.g., "4.5" or "5.0"). If not provided, auto-increment minor version.
