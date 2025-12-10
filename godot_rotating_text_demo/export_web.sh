#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$PROJECT_DIR/build/web"
mkdir -p "$OUT"

if command -v godot4 >/dev/null 2>&1; then GODOT_BIN="$(command -v godot4)"
elif command -v godot >/dev/null 2>&1; then GODOT_BIN="$(command -v godot)"
elif [[ -x "/Applications/Godot4.app/Contents/MacOS/Godot" ]]; then GODOT_BIN="/Applications/Godot4.app/Contents/MacOS/Godot"
elif [[ -x "/Applications/Godot.app/Contents/MacOS/Godot" ]]; then GODOT_BIN="/Applications/Godot.app/Contents/MacOS/Godot"
else
  echo "ERROR: Cannot find Godot."
  exit 1
fi

echo "Exporting Web build to $OUT (preset: Web)"
"$GODOT_BIN" --headless --path "$PROJECT_DIR" --export-release "Web" "$OUT/index.html"
echo "Done."
