#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$SCRIPT_DIR/PivyShell.app"
CONTENTS_DIR="$APP_DIR/Contents"
ICONSET_DIR="$SCRIPT_DIR/AppIcon.iconset"
BUILD_UNIVERSAL="${BUILD_UNIVERSAL:-0}"

mkdir -p "$CONTENTS_DIR/MacOS" "$CONTENTS_DIR/Resources"

swift "$SCRIPT_DIR/IconGenerator.swift" "$ICONSET_DIR"
iconutil -c icns "$ICONSET_DIR" -o "$CONTENTS_DIR/Resources/AppIcon.icns"

if [[ "$BUILD_UNIVERSAL" == "1" ]]; then
  ARM64_BINARY="$CONTENTS_DIR/MacOS/PivyShell-arm64"
  X86_64_BINARY="$CONTENTS_DIR/MacOS/PivyShell-x86_64"

  swiftc \
    -parse-as-library \
    -target arm64-apple-macos13 \
    "$SCRIPT_DIR/GPGVerificationLogic.swift" \
    "$SCRIPT_DIR/PivyShell.swift" \
    -o "$ARM64_BINARY" \
    -framework AppKit \
    -framework SwiftUI

  swiftc \
    -parse-as-library \
    -target x86_64-apple-macos13 \
    "$SCRIPT_DIR/GPGVerificationLogic.swift" \
    "$SCRIPT_DIR/PivyShell.swift" \
    -o "$X86_64_BINARY" \
    -framework AppKit \
    -framework SwiftUI

  lipo -create "$ARM64_BINARY" "$X86_64_BINARY" -output "$CONTENTS_DIR/MacOS/PivyShell"
  rm -f "$ARM64_BINARY" "$X86_64_BINARY"
else
  swiftc \
    -parse-as-library \
    "$SCRIPT_DIR/GPGVerificationLogic.swift" \
    "$SCRIPT_DIR/PivyShell.swift" \
    -o "$CONTENTS_DIR/MacOS/PivyShell" \
    -framework AppKit \
    -framework SwiftUI
fi

cp "$SCRIPT_DIR/Info.plist" "$CONTENTS_DIR/Info.plist"
chmod +x "$CONTENTS_DIR/MacOS/PivyShell"

echo "已构建：$APP_DIR"
