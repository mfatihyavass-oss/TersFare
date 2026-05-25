#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$ROOT_DIR/TersFare.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"

swiftc \
  "$ROOT_DIR/Sources/TersFare/main.swift" \
  -o "$MACOS_DIR/TersFare" \
  -framework Cocoa \
  -framework ApplicationServices

cat > "$CONTENTS_DIR/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>TersFare</string>
  <key>CFBundleIdentifier</key>
  <string>local.codex.TersFare</string>
  <key>CFBundleName</key>
  <string>TersFare</string>
  <key>CFBundleDisplayName</key>
  <string>TersFare</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSHumanReadableCopyright</key>
  <string>Built locally for personal use.</string>
</dict>
</plist>
PLIST

chmod +x "$MACOS_DIR/TersFare"

if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign - "$APP_DIR" >/dev/null 2>&1
fi

echo "$APP_DIR"
