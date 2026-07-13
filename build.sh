#!/bin/bash
# build.sh — compile ClipHistory into a runnable .app bundle without Xcode.
# Requires the Swift toolchain (comes with Xcode or the Command Line Tools:
#   xcode-select --install).
#
# Usage:
#   cd ClipHistory
#   chmod +x build.sh
#   ./build.sh
# Result: ./ClipHistory.app  — double-click it, or `open ClipHistory.app`.

set -euo pipefail

APP="ClipHistory.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"

echo "Cleaning previous build…"
rm -rf "$APP"
mkdir -p "$MACOS"

echo "Compiling Swift sources (pure AppKit — no SwiftUI macros needed)…"
swiftc \
  -O \
  -target arm64-apple-macos13.0 \
  -framework AppKit \
  -o "$MACOS/ClipHistory" \
  main.swift ClipboardStore.swift

echo "Installing Info.plist…"
cp Info.plist "$CONTENTS/Info.plist"

# Ad-hoc code signature so macOS will run it locally without a dev account.
echo "Ad-hoc signing…"
codesign --force --deep --sign - "$APP"

echo ""
echo "Done → $APP"
echo "Run it with:  open $APP"
echo "(First launch: if Gatekeeper blocks it, right-click → Open, or"
echo " System Settings → Privacy & Security → Open Anyway.)"
