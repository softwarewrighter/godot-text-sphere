#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$PROJECT_DIR/.." && pwd)"
OUT="$REPO_ROOT/docs"
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

# Add .nojekyll to prevent Jekyll processing on GitHub Pages
touch "$OUT/.nojekyll"

# Add cache busting to index.html
# Use milliseconds since epoch (macOS compatible)
TIMESTAMP=$(python3 -c "import time; print(int(time.time() * 1000))" 2>/dev/null || date +%s000)
if [[ -f "$OUT/index.html" ]]; then
  # Add cache busting query params to JS and asset references
  sed -i.bak "s|src=\"index.js\"|src=\"index.js?v=$TIMESTAMP\"|g" "$OUT/index.html"
  sed -i.bak "s|href=\"index.icon.png\"|href=\"index.icon.png?v=$TIMESTAMP\"|g" "$OUT/index.html"
  sed -i.bak "s|href=\"index.apple-touch-icon.png\"|href=\"index.apple-touch-icon.png?v=$TIMESTAMP\"|g" "$OUT/index.html"
  sed -i.bak "s|src=\"index.png\"|src=\"index.png?v=$TIMESTAMP\"|g" "$OUT/index.html"
  rm -f "$OUT/index.html.bak"
  echo "Added cache busting with timestamp: $TIMESTAMP"
fi

echo "Done. Output at: $OUT"
