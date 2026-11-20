#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${VERSION:-1.0.0}"
BUILD_DIR="$ROOT_DIR/.build-release"
DIST_DIR="$ROOT_DIR/Release"
DERIVED_DATA="$BUILD_DIR/DerivedData"
APP_PATH="$DERIVED_DATA/Build/Products/Release/ColorPicker.app"
ZIP_PATH="$DIST_DIR/ColorPicker-v${VERSION}-macOS.zip"
DMG_PATH="$DIST_DIR/ColorPicker-v${VERSION}-macOS.dmg"

rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$DERIVED_DATA" "$DIST_DIR"

xcodebuild \
  -project "$ROOT_DIR/ColorPicker.xcodeproj" \
  -scheme ColorPicker \
  -configuration Release \
  -destination 'generic/platform=macOS' \
  -derivedDataPath "$DERIVED_DATA" \
  ARCHS="arm64 x86_64" \
  ONLY_ACTIVE_ARCH=NO \
  MARKETING_VERSION="$VERSION" \
  CODE_SIGNING_ALLOWED=NO \
  build

codesign --force --deep --sign - "$APP_PATH"

ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"

DMG_STAGING="$BUILD_DIR/dmg"
mkdir -p "$DMG_STAGING"
cp -R "$APP_PATH" "$DMG_STAGING/ColorPicker.app"
ln -s /Applications "$DMG_STAGING/Applications"
hdiutil create \
  -volname "ColorPicker" \
  -srcfolder "$DMG_STAGING" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

cd "$DIST_DIR"
shasum -a 256 "$(basename "$ZIP_PATH")" "$(basename "$DMG_PATH")" > SHA256SUMS.txt

printf '\nCreated:\n'
printf '  %s\n' "$ZIP_PATH" "$DMG_PATH" "$DIST_DIR/SHA256SUMS.txt"
