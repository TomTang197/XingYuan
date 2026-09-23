#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$DIR"

APP_NAME="XingYuan"
WIDGET_NAME="XingYuanWidget"
APP_DIR="$DIR/build/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
PLUGINS_DIR="$CONTENTS_DIR/PlugIns"
WIDGET_APPEX_DIR="$PLUGINS_DIR/$WIDGET_NAME.appex"
WIDGET_CONTENTS_DIR="$WIDGET_APPEX_DIR/Contents"
WIDGET_MACOS_DIR="$WIDGET_CONTENTS_DIR/MacOS"

echo "🔨 Building $APP_NAME release binary..."
swift build -c release

echo "🔨 Building $WIDGET_NAME release binary..."
mkdir -p "$DIR/.build/release"
swiftc -O -parse-as-library \
    -framework WidgetKit \
    -framework SwiftUI \
    -target arm64-apple-macos14.0 \
    "$DIR/Sources/XingYuan/Engine/WidgetSnapshotModel.swift" \
    "$DIR/Sources/XingYuanWidget/XingYuanWidgetBundle.swift" \
    "$DIR/Sources/XingYuanWidget/XingYuanWidget.swift" \
    "$DIR/Sources/XingYuanWidget/WidgetViews.swift" \
    -o "$DIR/.build/release/$WIDGET_NAME"

echo "📦 Creating $APP_NAME.app bundle structure..."
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"
mkdir -p "$WIDGET_MACOS_DIR"

# Copy main binary
cp "$DIR/.build/release/$APP_NAME" "$MACOS_DIR/$APP_NAME"

# Copy widget binary
cp "$DIR/.build/release/$WIDGET_NAME" "$WIDGET_MACOS_DIR/$WIDGET_NAME"

# Main App Info.plist
cat <<EOF > "$CONTENTS_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.xingyuan.costperday</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>星元</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>com.xingyuan.url</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>xingyuan</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
EOF

# Widget Extension Info.plist
cat <<EOF > "$WIDGET_CONTENTS_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>zh_CN</string>
    <key>CFBundleDisplayName</key>
    <string>星元小组件</string>
    <key>CFBundleExecutable</key>
    <string>$WIDGET_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.xingyuan.costperday.widget</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$WIDGET_NAME</string>
    <key>CFBundlePackageType</key>
    <string>XPC!</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.widgetkit-extension</string>
    </dict>
</dict>
</plist>
EOF

echo "🔏 Code signing $APP_NAME.app and extensions..."
codesign --force --deep --sign - "$APP_DIR"

echo "📡 Registering bundle with LaunchServices and PlugInKit..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP_DIR" || true
pluginkit -a "$WIDGET_APPEX_DIR" || true

echo "✅ $APP_NAME.app bundle successfully created with native WidgetKit Extension at: $APP_DIR"
