#!/bin/bash
set -e

echo "Building TaskTimerApp..."

# Clean previous build
swift package clean
rm -rf .build

# Build for release
swift build -c release

# Create app bundle structure
echo "Creating app bundle..."
rm -rf TaskTimerApp.app
mkdir -p TaskTimerApp.app/Contents/MacOS
mkdir -p TaskTimerApp.app/Contents/Resources

# Copy the binary
cp .build/arm64-apple-macosx/release/TaskTimerApp TaskTimerApp.app/Contents/MacOS/

# Copy the icon if it exists
if [ -f "icon.icns" ]; then
    cp icon.icns TaskTimerApp.app/Contents/Resources/
    echo "Icon copied to bundle"
else
    echo "Warning: icon.icns not found in project root"
fi

# Create Info.plist
cat > TaskTimerApp.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>TaskTimerApp</string>
    <key>CFBundleIdentifier</key>
    <string>com.iflow.tasktimer</string>
    <key>CFBundleName</key>
    <string>TaskTimerApp</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>icon.icns</string>
</dict>
</plist>
EOF

# Sign the application
echo "Signing application..."
codesign --force --deep -s - TaskTimerApp.app

# Move to Applications folder
echo "Moving to /Applications..."
if [ -d "/Applications/TaskTimerApp.app" ]; then
    echo "Removing existing app from /Applications..."
    sudo rm -rf /Applications/TaskTimerApp.app
fi

sudo mv TaskTimerApp.app /Applications/

echo ""
echo "✅ Build complete!"
echo "📍 App installed to: /Applications/TaskTimerApp.app"
echo "🚀 Launching app..."
open /Applications/TaskTimerApp.app
