#!/usr/bin/env bash
set -euo pipefail

# Directory of this script == project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# macOS output (Godot will create bundle)
OUT="$PROJECT_DIR/build/RotatingTextDemo.app"
mkdir -p "$(dirname "$OUT")"

# Find a Godot binary
if command -v godot4 >/dev/null 2>&1; then
  GODOT_BIN="$(command -v godot4)"
elif command -v godot >/dev/null 2>&1; then
  GODOT_BIN="$(command -v godot)"
elif [[ -x "/Applications/Godot4.app/Contents/MacOS/Godot" ]]; then
  GODOT_BIN="/Applications/Godot4.app/Contents/MacOS/Godot"
elif [[ -x "/Applications/Godot.app/Contents/MacOS/Godot" ]]; then
  GODOT_BIN="/Applications/Godot.app/Contents/MacOS/Godot"
else
  echo "ERROR: Could not find Godot executable."
  exit 1
fi

echo "Exporting macOS build (preset: macOS) → $OUT"
"$GODOT_BIN" --headless --path "$PROJECT_DIR" --export-release "macOS" "$OUT"
echo "Done."

