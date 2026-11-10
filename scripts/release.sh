#!/bin/bash
# Builds dist/BlueShooth-<version>.dmg, signs and notarizes it with Developer ID,
# then publishes it as a GitHub release of the current commit, which must be pushed.
# Bump CFBundleShortVersionString and CFBundleVersion in BlueShooth/Info.plist first.
# One-time setup: xcrun notarytool store-credentials bihan --key <AuthKey.p8> --key-id <id> --issuer <issuer-id>
set -euo pipefail
cd "$(dirname "$0")/.."

SIGN_ID="Developer ID Application: Zolfer Figueiredo (497V6MCDS8)"
NAME=BlueShooth
REPO=zolferfigueiredo/blueshooth
VERSION=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' BlueShooth/Info.plist)
DMG="dist/$NAME-$VERSION.dmg"

if gh release view "v$VERSION" -R "$REPO" >/dev/null 2>&1; then
  echo "v$VERSION is already released."
  exit 0
fi
[ -z "$(git status --porcelain)" ] || { echo "Commit your changes first." >&2; exit 1; }
git branch -r --contains HEAD | grep -q . || { echo "Push this commit first." >&2; exit 1; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

xcodebuild -project BlueShooth.xcodeproj -scheme BlueShooth -configuration Release \
  -derivedDataPath "$TMP/dd" ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO CODE_SIGN_IDENTITY=- \
  -quiet build
APP="$TMP/dd/Build/Products/Release/$NAME.app"
codesign --force --options runtime --timestamp \
  --entitlements BlueShooth/BlueShooth.entitlements --sign "$SIGN_ID" "$APP"

# ponytail: plain DMG (app + Applications link), add the background and layout from the macOS standard when wanted
mkdir -p "$TMP/dmg" dist
ditto "$APP" "$TMP/dmg/$NAME.app"
ln -s /Applications "$TMP/dmg/Applications"
hdiutil create -volname "$NAME" -srcfolder "$TMP/dmg" -format UDZO -ov "$DMG" >/dev/null

codesign --timestamp --sign "$SIGN_ID" "$DMG"
xcrun notarytool submit "$DMG" --keychain-profile bihan --wait
xcrun stapler staple "$DMG"
spctl --assess --type open --context context:primary-signature -vv "$DMG"

printf '{"version": "%s"}\n' "$VERSION" > dist/latest.json
gh release create "v$VERSION" "$DMG" dist/latest.json -R "$REPO" \
  --target "$(git rev-parse HEAD)" --title "$NAME $VERSION" --generate-notes
