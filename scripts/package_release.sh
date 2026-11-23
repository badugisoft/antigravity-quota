#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

VERSION="${1:-1.3.1}"
# Strip leading 'v' if present (e.g. v1.0.0 -> 1.0.0)
VERSION="${VERSION#v}"
export APP_VERSION="$VERSION"

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

SHOULD_NOTARIZE=0
if [ -n "${APPLE_ID:-}" ] && [ -n "${APPLE_TEAM_ID:-}" ] && [ -n "${APPLE_APP_PASSWORD:-}" ]; then
    SHOULD_NOTARIZE=1
fi

if [ "$SHOULD_NOTARIZE" -eq 1 ]; then
    echo "==> Notarizing app bundle with Apple Notary Service..."
    NOTARIZE_ZIP="$BUILD_DIR/Antigravity-Quota-${VERSION}-notarize.zip"
    rm -f "$NOTARIZE_ZIP"
    cd "$BUILD_DIR"
    ditto -c -k --keepParent "$APP_NAME" "$NOTARIZE_ZIP"
    xcrun notarytool submit "$NOTARIZE_ZIP" \
        --apple-id "$APPLE_ID" \
        --team-id "$APPLE_TEAM_ID" \
        --password "$APPLE_APP_PASSWORD" \
        --wait
    rm -f "$NOTARIZE_ZIP"

    echo "==> Stapling notarization ticket to $APP_NAME..."
    xcrun stapler staple "$APP_DIR"
fi

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

if [ -z "${SIGN_IDENTITY:-}" ]; then
    SIGN_IDENTITY="$(security find-identity -v -p codesigning 2>/dev/null | grep "Developer ID Application:" | head -n 1 | sed -E 's/.*"([^"]+)".*/\1/' || true)"
fi

if [ -n "$SIGN_IDENTITY" ] && [ "$SIGN_IDENTITY" != "-" ]; then
    echo "==> Code signing DMG disk image..."
    codesign --force --timestamp --sign "$SIGN_IDENTITY" "$BUILD_DIR/$DMG_NAME"
fi

if [ "$SHOULD_NOTARIZE" -eq 1 ]; then
    echo "==> Notarizing DMG disk image..."
    xcrun notarytool submit "$BUILD_DIR/$DMG_NAME" \
        --apple-id "$APPLE_ID" \
        --team-id "$APPLE_TEAM_ID" \
        --password "$APPLE_APP_PASSWORD" \
        --wait

    echo "==> Stapling notarization ticket to $DMG_NAME..."
    xcrun stapler staple "$BUILD_DIR/$DMG_NAME"
fi

echo "==> Release packaging complete!"
echo "    - ZIP: $BUILD_DIR/$ZIP_NAME"
echo "    - DMG: $BUILD_DIR/$DMG_NAME"
