#!/bin/zsh
# Builds ~/Desktop/Model Library.app from ModelLibrary.swift (no Xcode project needed).
set -e
cd "$(dirname "$0")"
APP="$HOME/Desktop/Model Library.app"
rm -rf "$APP"; mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
swiftc -O -parse-as-library -target arm64-apple-macos13.0 -o "$APP/Contents/MacOS/ModelLibrary" ModelLibrary.swift
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>Model Library</string>
  <key>CFBundleDisplayName</key><string>Model Library</string>
  <key>CFBundleIdentifier</key><string>dev.imranali.modellibrary</string>
  <key>CFBundleExecutable</key><string>ModelLibrary</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>LSApplicationCategoryType</key><string>public.app-category.utilities</string>
</dict></plist>
PLIST
[ -f AppIcon.icns ] && cp AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
codesign --force --sign - "$APP" >/dev/null 2>&1 || true
echo "built: $APP"
