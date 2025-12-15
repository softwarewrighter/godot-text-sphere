# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Godot 4.5 project that creates a 3D rotating text sphere demo. Letters from a configurable string are arranged in a circle around a central sphere and rotate continuously.

## Commands

All commands should be run from the `godot_rotating_text_demo/` directory.

```bash
# Run the project (auto-detects Godot installation)
./run.sh

# Export for macOS
./export_mac.sh

# Export for Web (outputs to repo root /docs for GitHub Pages)
./export_web.sh

# Regenerate the entire project from scratch
cd .. && ./setup_godot_rotating_text_demo.sh
```

The scripts auto-detect Godot via: `godot4` command, `godot` command, or common macOS .app locations. Override with `GODOT_BIN` environment variable.

## Architecture

**Single-script architecture**: `Main.gd` handles everything - scene setup, mesh generation, and animation.

Key flow in `_ready()`:
1. Creates a blue SphereMesh at origin
2. Creates a `letters_root` Node3D as rotation container
3. Generates TextMesh letters arranged in a circle using `_create_letters()`
4. Positions camera to view the scene

The `_process()` loop rotates `letters_root` around Y-axis for continuous animation.

**Exported parameters** (configurable in editor):
- `text_to_extrude`: String to display (default: "DEMO")
- `radius`: Distance of letters from center
- `letter_thickness`, `letter_scale`, `font_size`: Letter appearance
- `rotation_speed`: Animation speed
- `override_font`: Optional custom font

**Scene structure** (`main.tscn`):
- Main (Node3D with script)
  - Camera3D
  - DirectionalLight3D

Export presets are configured for macOS and Web targets.
