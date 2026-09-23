#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$DIR"

APP_NAME="XingYuan"
WIDGET_NAME="XingYuanWidget"

echo "⚙️ Generating Xcode project via xcodegen..."
xcodegen generate

echo "🔨 Building $APP_NAME and embedded $WIDGET_NAME (Release)..."
xcodebuild -project XingYuan.xcodeproj \
    -scheme XingYuan \
    -configuration Release \
    -derivedDataPath .build/derivedData \
    build

BUILT_APP="$DIR/.build/derivedData/Build/Products/Release/$APP_NAME.app"
INSTALLED_APP="/Applications/$APP_NAME.app"
INSTALLED_WIDGET="$INSTALLED_APP/Contents/PlugIns/$WIDGET_NAME.appex"

echo "📂 Installing $APP_NAME.app to /Applications..."
killall "$APP_NAME" 2>/dev/null || true
rm -rf "$INSTALLED_APP"
cp -R "$BUILT_APP" "$INSTALLED_APP"

echo "📡 Registering bundle with LaunchServices and PlugInKit..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -u "$INSTALLED_APP" 2>/dev/null || true
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f -R -trusted "$INSTALLED_APP" || true
pluginkit -A -a "$INSTALLED_WIDGET" || true
pluginkit -e use -i com.xingyuan.costperday.desktopwidget || true

# Refresh chronod to pick up the new widget
killall -9 chronod 2>/dev/null || true

echo "✅ $APP_NAME.app bundle successfully installed to /Applications with native WidgetKit Extension"
