#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$SCRIPT_DIR/PivyShell.app"
CONTENTS_DIR="$APP_DIR/Contents"
ICONSET_DIR="$SCRIPT_DIR/AppIcon.iconset"

mkdir -p "$CONTENTS_DIR/MacOS" "$CONTENTS_DIR/Resources"

swift "$SCRIPT_DIR/IconGenerator.swift" "$ICONSET_DIR"
iconutil -c icns "$ICONSET_DIR" -o "$CONTENTS_DIR/Resources/AppIcon.icns"

swiftc \
  -parse-as-library \
  "$SCRIPT_DIR/PivyShell.swift" \
  -o "$CONTENTS_DIR/MacOS/PivyShell" \
  -framework AppKit \
  -framework SwiftUI

cp "$SCRIPT_DIR/Info.plist" "$CONTENTS_DIR/Info.plist"
chmod +x "$CONTENTS_DIR/MacOS/PivyShell"

echo "已构建：$APP_DIR"
