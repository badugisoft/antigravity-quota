#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> Building AntigravityQuota & WidgetExtension in Release mode..."
cd "$ROOT_DIR"
swift build -c release

APP_NAME="Antigravity Quota.app"
BUILD_DIR="$ROOT_DIR/build"
APP_DIR="$BUILD_DIR/$APP_NAME"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
PLUGINS_DIR="$CONTENTS_DIR/PlugIns"

echo "==> Creating macOS App Bundle at $APP_DIR..."
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"
mkdir -p "$PLUGINS_DIR"

BIN_PATH="$ROOT_DIR/.build/release/AntigravityQuota"
if [ ! -f "$BIN_PATH" ]; then
    BIN_PATH="$(find "$ROOT_DIR/.build" -type f -name "AntigravityQuota" -perm +111 | grep -E "release/AntigravityQuota$" | head -n 1)"
fi

if [ -z "$BIN_PATH" ] || [ ! -f "$BIN_PATH" ]; then
    echo "Error: Main binary not found!"
    exit 1
fi

echo "==> Copying main binary from $BIN_PATH..."
cp "$BIN_PATH" "$MACOS_DIR/AntigravityQuota"
chmod +x "$MACOS_DIR/AntigravityQuota"

echo "==> Copying AppIcon.icns..."
if [ -f "$ROOT_DIR/Sources/AntigravityQuota/Resources/AppIcon.icns" ]; then
    cp "$ROOT_DIR/Sources/AntigravityQuota/Resources/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
fi

echo "==> Generating App Info.plist..."
cat <<EOF > "$CONTENTS_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>AntigravityQuota</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.badugisoft.AntigravityQuota</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Antigravity Quota</string>
    <key>CFBundleDisplayName</key>
    <string>Antigravity Quota</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleSupportedPlatforms</key>
    <array>
        <string>MacOSX</string>
    </array>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSUserNotificationAlertStyle</key>
    <string>banner</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

# Assembling WidgetKit Extension Bundle (.appex)
WIDGET_BIN_PATH="$ROOT_DIR/.build/release/AntigravityQuotaWidgetExtension"
if [ ! -f "$WIDGET_BIN_PATH" ]; then
    WIDGET_BIN_PATH="$(find "$ROOT_DIR/.build" -type f -name "AntigravityQuotaWidgetExtension" -perm +111 | grep -E "release/AntigravityQuotaWidgetExtension$" | head -n 1)"
fi

if [ -f "$WIDGET_BIN_PATH" ]; then
    echo "==> Packaging WidgetKit extension from $WIDGET_BIN_PATH..."
    WIDGET_APPEX_DIR="$PLUGINS_DIR/AntigravityQuotaWidget.appex"
    WIDGET_CONTENTS_DIR="$WIDGET_APPEX_DIR/Contents"
    WIDGET_MACOS_DIR="$WIDGET_CONTENTS_DIR/MacOS"
    
    mkdir -p "$WIDGET_MACOS_DIR"
    cp "$WIDGET_BIN_PATH" "$WIDGET_MACOS_DIR/AntigravityQuotaWidgetExtension"
    chmod +x "$WIDGET_MACOS_DIR/AntigravityQuotaWidgetExtension"
    
    cat <<EOF > "$WIDGET_CONTENTS_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleDisplayName</key>
    <string>Antigravity Quota</string>
    <key>CFBundleExecutable</key>
    <string>AntigravityQuotaWidgetExtension</string>
    <key>CFBundleIdentifier</key>
    <string>com.badugisoft.AntigravityQuota.Widget</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>AntigravityQuotaWidgetExtension</string>
    <key>CFBundlePackageType</key>
    <string>XPC!</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleSupportedPlatforms</key>
    <array>
        <string>MacOSX</string>
    </array>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSApplicationCategoryType</key>
    <string>NSExtension</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.widgetkit-extension</string>
    </dict>
</dict>
</plist>
EOF
    echo "==> Code signing widget extension with sandboxed entitlements..."
    codesign --force --sign - --entitlements "$ROOT_DIR/scripts/entitlements/widget.entitlements" "$WIDGET_APPEX_DIR"
fi

echo "==> Code signing main app bundle..."
codesign --force --sign - --entitlements "$ROOT_DIR/scripts/entitlements/app.entitlements" "$APP_DIR"

echo "==> Done! App bundle created at: $APP_DIR"

if [ -n "$NO_INSTALL" ]; then
    echo "==> Skipping local installation (NO_INSTALL is set)."
    exit 0
fi

# Install locally to /Applications
echo "==> Installing to /Applications/$APP_NAME..."
pkill -f "AntigravityQuota" 2>/dev/null || true
sleep 1
rm -rf "/Applications/AntigravityQuota.app"
rm -rf "/Applications/$APP_NAME"
cp -R "$APP_DIR" "/Applications/$APP_NAME"

echo "==> Registering with LaunchServices & PluginKit..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f -R "/Applications/$APP_NAME"
pluginkit -a "/Applications/$APP_NAME/Contents/PlugIns/AntigravityQuotaWidget.appex" || true

echo "==> Refreshing WidgetKit daemon (chronod)..."
killall -9 chronod 2>/dev/null || true

echo "==> Launching installed app from /Applications/$APP_NAME..."
open "/Applications/$APP_NAME"

echo "==> Successfully installed and running!"
