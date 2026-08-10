#!/bin/bash
set -e

cd "/Users/jackson/Desktop/     /claude/task-timer-app"

echo "=== Generating Icon ==="

# Generate icons using Swift
swift generate_icon_swift.swift

# Convert iconset to icns
echo ""
echo "=== Converting to icns format ==="
cd "/Users/jackson/Desktop/     /claude/task-timer-app"
iconutil -c icns TaskTimerApp.iconset

# Move icon to project root
mv TaskTimerApp.iconset/icon.icns .
rm -rf TaskTimerApp.iconset

echo ""
echo "=== Building App ==="
chmod +x create_bundle.sh
./create_bundle.sh
