#!/bin/zsh
# Builds OutputSwitcher and wraps it in a menu-bar-only .app bundle (no Dock icon).
set -euo pipefail
cd "${0:A:h}/.."

swift build -c release
BIN="$(swift build -c release --show-bin-path)/OutputSwitcher"

APP="OutputSwitcher.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/OutputSwitcher"
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key><string>local.OutputSwitcher</string>
    <key>CFBundleName</key><string>OutputSwitcher</string>
    <key>CFBundleExecutable</key><string>OutputSwitcher</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>LSMinimumSystemVersion</key><string>26.0</string>
    <key>LSUIElement</key><true/>
    <key>NSAppleEventsUsageDescription</key><string>OutputSwitcher asks AirBuddy to read and change the listening mode of your AirPods.</string>
    <key>NSBluetoothAlwaysUsageDescription</key><string>OutputSwitcher reads the battery level of your Bluetooth headphones.</string>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP"
echo "Built $PWD/$APP"
