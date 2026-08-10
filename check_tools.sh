#!/bin/bash
# Convert SVG to PNG using Python and AppKit

python3 << 'EOF'
import subprocess
import os

# Check if we can use AppKit via Python
try:
    from AppKit import NSImage, NSBitmapImageRep, NSPNGFileType, NSMakeSize, NSMakeRect
    from Foundation import NSString
    print("AppKit available via PyObjC")
except ImportError:
    print("AppKit not available, trying alternative method...")

# Try using rsvg-convert (from librsvg)
result = subprocess.run(['which', 'rsvg-convert'], capture_output=True, text=True)
if result.returncode == 0:
    print("Found rsvg-convert at:", result.stdout.strip())
else:
    rsvg_path = '/opt/homebrew/bin/rsvg-convert'
    if os.path.exists(rsvg_path):
        print("Found rsvg-convert at:", rsvg_path)
    else:
        print("rsvg-convert not found")

# Try using inkscape
result = subprocess.run(['which', 'inkscape'], capture_output=True, text=True)
if result.returncode == 0:
    print("Found inkscape at:", result.stdout.strip())
else:
    inkscape_path = '/Applications/Inkscape.app/Contents/MacOS/inkscape'
    if os.path.exists(inkscape_path):
        print("Found inkscape at:", inkscape_path)
    else:
        print("inkscape not found")

# Try using convert (ImageMagick)
result = subprocess.run(['which', 'convert'], capture_output=True, text=True)
if result.returncode == 0:
    print("Found convert at:", result.stdout.strip())
else:
    convert_path = '/opt/homebrew/bin/convert'
    if os.path.exists(convert_path):
        print("Found convert at:", convert_path)
    else:
        print("convert not found")

EOF
