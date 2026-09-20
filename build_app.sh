#!/bin/bash
set -e

APP_BUNDLE="build/Oatmeal.app"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp Info.plist "$APP_BUNDLE/Contents/"
cp build/debug/oatmeal/oatmeal "$APP_BUNDLE/Contents/MacOS/"
chmod +x "$APP_BUNDLE/Contents/MacOS/oatmeal"

echo "App bundle created at $APP_BUNDLE"
