#!/bin/bash
set -e

APP_BUNDLE="build/Oatmeal.app"
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp Info.plist "$APP_BUNDLE/Contents/"
cp build/debug/oatmeal/oatmeal "$APP_BUNDLE/Contents/MacOS/"
chmod +x "$APP_BUNDLE/Contents/MacOS/oatmeal"

cp icons/Icon-macOS-Default-1024x1024@1x.icns "$APP_BUNDLE/Contents/Resources/AppIcon.icns"

# codesign --remove-signature "$APP_BUNDLE" 2>/dev/null || true

# codesign --force --deep --sign - --identifier com.oatmeal.app "$APP_BUNDLE"

rm -rf /Applications/Oatmeal.app
cp -R "$APP_BUNDLE" /Applications/

echo "App bundle created at $APP_BUNDLE and installed to /Applications"
