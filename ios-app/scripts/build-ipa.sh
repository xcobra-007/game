#!/usr/bin/env bash
#
# Build a signed .ipa for دومنة المناويج.
# Run this ON A MAC with Xcode + Command Line Tools + CocoaPods installed.
#
# Usage (from the ios-app/ folder):
#   ./scripts/build-ipa.sh
#
# By default it reads signing settings from ios-app/ExportOptions.plist.
# Copy the template first and fill in your Team ID:
#   cp ExportOptions.example.plist ExportOptions.plist
#   # then edit ExportOptions.plist -> set <teamID> and <method>
#
# Override the options file if you keep it elsewhere:
#   EXPORT_OPTIONS=/path/to/ExportOptions.plist ./scripts/build-ipa.sh
#
# Result: ios-app/build/ipa/App.ipa
#
set -euo pipefail

# Resolve the ios-app/ root (parent of this scripts/ folder) and work from there.
APP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$APP_ROOT"

EXPORT_OPTIONS="${EXPORT_OPTIONS:-$APP_ROOT/ExportOptions.plist}"
ARCHIVE_PATH="$APP_ROOT/build/App.xcarchive"
IPA_DIR="$APP_ROOT/build/ipa"
WORKSPACE="$APP_ROOT/ios/App/App.xcworkspace"
SCHEME="App"

if [ ! -d "/Applications/Xcode.app" ] && ! xcode-select -p >/dev/null 2>&1; then
  echo "ERROR: Xcode does not appear to be installed. This must be run on a Mac." >&2
  exit 1
fi

if [ ! -f "$EXPORT_OPTIONS" ]; then
  echo "ERROR: export options not found at: $EXPORT_OPTIONS" >&2
  echo "       Create one from the template, then set your Team ID:" >&2
  echo "         cp ExportOptions.example.plist ExportOptions.plist" >&2
  exit 1
fi

echo "==> [1/4] Installing JS dependencies"
npm install

echo "==> [2/4] Syncing the latest game into the iOS project (sync-web + cap sync ios)"
npm run prepare-ios

echo "==> [3/4] Archiving (Release, generic iOS device)"
rm -rf "$ARCHIVE_PATH"
xcodebuild \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE_PATH" \
  clean archive

echo "==> [4/4] Exporting .ipa using $(basename "$EXPORT_OPTIONS")"
rm -rf "$IPA_DIR"
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$IPA_DIR" \
  -exportOptionsPlist "$EXPORT_OPTIONS"

echo ""
echo "==> Done. Built .ipa:"
ls -1 "$IPA_DIR"/*.ipa 2>/dev/null || { echo "No .ipa produced — check the export log above (usually a signing/Team ID issue)." >&2; exit 1; }
