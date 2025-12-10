#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GODOT_BIN="${GODOT_BIN:-}"

if [[ -z "${GODOT_BIN}" ]]; then
  if command -v godot4 >/dev/null 2>&1; then GODOT_BIN="$(command -v godot4)"
  elif command -v godot >/dev/null 2>&1; then GODOT_BIN="$(command -v godot)"
  elif [[ -x "/Applications/Godot4.app/Contents/MacOS/Godot" ]]; then GODOT_BIN="/Applications/Godot4.app/Contents/MacOS/Godot"
  elif [[ -x "/Applications/Godot.app/Contents/MacOS/Godot" ]]; then GODOT_BIN="/Applications/Godot.app/Contents/MacOS/Godot"
  else
    echo "ERROR: Cannot find Godot."
    exit 1
  fi
fi

echo "Running Godot from $GODOT_BIN"
exec "$GODOT_BIN" --path "$PROJECT_DIR" "$@"
