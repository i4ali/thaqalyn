# App Store Screenshot Formatter

Resize a screenshot to App Store Connect format for iPhone.

## Instructions

1. Find the screenshot file provided by the user (check working directory and Desktop)
2. Get current dimensions using `sips -g pixelWidth -g pixelHeight`
3. Resize to **1284 × 2778px** (6.7" iPhone portrait format) using:
   ```bash
   sips -z 2778 1284 "input.png" --out "appstore_screenshot.png"
   ```
4. Save output to the working directory as `appstore_screenshot.png` (or with a numbered suffix if file exists)
5. Verify output dimensions and report success

## App Store Screenshot Sizes Reference

| Device | Portrait | Landscape |
|--------|----------|-----------|
| 6.7" iPhone | 1284 × 2778 | 2778 × 1284 |
| 6.5" iPhone | 1242 × 2688 | 2688 × 1242 |

## Arguments

$ARGUMENTS - Path to the screenshot file to format. Can be a full path or just the filename.
