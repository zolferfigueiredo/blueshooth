#!/bin/bash
# Builds dist/BlueShooth-<version>.dmg (ad hoc signed, not notarized) and publishes it
# as a GitHub release of the current commit, which must be pushed.
# Bump CFBundleShortVersionString and CFBundleVersion in BlueShooth/Info.plist first.
set -euo pipefail
cd "$(dirname "$0")/.."

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

# CODE_SIGN_IDENTITY=- gives an ad hoc signature, which Apple Silicon needs to run the app at all.
xcodebuild -project BlueShooth.xcodeproj -scheme BlueShooth -configuration Release \
  -derivedDataPath "$TMP/dd" ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO CODE_SIGN_IDENTITY=- \
  -quiet build
APP="$TMP/dd/Build/Products/Release/$NAME.app"

# ponytail: plain DMG (app + Applications link), add the background and layout from the macOS standard when wanted
mkdir -p "$TMP/dmg" dist
ditto "$APP" "$TMP/dmg/$NAME.app"
ln -s /Applications "$TMP/dmg/Applications"
hdiutil create -volname "$NAME" -srcfolder "$TMP/dmg" -format UDZO -ov "$DMG" >/dev/null

printf '{"version": "%s"}\n' "$VERSION" > dist/latest.json
gh release create "v$VERSION" "$DMG" dist/latest.json -R "$REPO" \
  --target "$(git rev-parse HEAD)" --title "$NAME $VERSION" --generate-notes \
  --notes "BlueShooth is not notarized by Apple. After dragging it to Applications, open it once, then go to System Settings > Privacy & Security and click **Open Anyway**. Or run: \`xattr -dr com.apple.quarantine /Applications/BlueShooth.app\`"
