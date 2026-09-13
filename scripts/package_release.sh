#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

VERSION="${1:-1.0.0}"
# Strip leading 'v' if present (e.g. v1.0.0 -> 1.0.0)
VERSION="${VERSION#v}"

echo "==> Packaging Antigravity Quota v${VERSION}..."

# Build app bundle without installing to /Applications
export NO_INSTALL=1
"$SCRIPT_DIR/build_app.sh"

BUILD_DIR="$ROOT_DIR/build"
APP_NAME="Antigravity Quota.app"
APP_DIR="$BUILD_DIR/$APP_NAME"

if [ ! -d "$APP_DIR" ]; then
    echo "Error: $APP_DIR not found!"
    exit 1
fi

ZIP_NAME="Antigravity-Quota-${VERSION}.zip"
DMG_NAME="Antigravity-Quota-${VERSION}.dmg"

echo "==> Creating ZIP archive: $ZIP_NAME..."
rm -f "$BUILD_DIR/$ZIP_NAME"
cd "$BUILD_DIR"
ditto -c -k --keepParent "$APP_NAME" "$ZIP_NAME"

echo "==> Creating DMG disk image: $DMG_NAME..."
rm -f "$BUILD_DIR/$DMG_NAME"
DMG_STAGING="$BUILD_DIR/dmg_staging"
rm -rf "$DMG_STAGING"
mkdir -p "$DMG_STAGING"

cp -R "$APP_DIR" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"

hdiutil create -volname "Antigravity Quota" \
  -srcfolder "$DMG_STAGING" \
  -ov -format UDZO \
  "$BUILD_DIR/$DMG_NAME"

rm -rf "$DMG_STAGING"

echo "==> Release packaging complete!"
echo "    - ZIP: $BUILD_DIR/$ZIP_NAME"
echo "    - DMG: $BUILD_DIR/$DMG_NAME"
