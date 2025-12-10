#!/usr/bin/env bash
set -euo pipefail

SETUP_VERSION="2025-12-09T21:20Z"
echo "SETUP SCRIPT VERSION=${SETUP_VERSION}"
echo "Running as: $0"
echo "PWD before: $(pwd)"

PROJECT_ROOT="godot_rotating_text_demo"

echo "Removing existing project dir: ${PROJECT_ROOT}"
rm -rf "${PROJECT_ROOT}"

echo "Creating project directory"
mkdir -p "${PROJECT_ROOT}"
cd "${PROJECT_ROOT}"

echo "PWD inside project: $(pwd)"

mkdir -p fonts

# ------------------------------------------------------------------
# 1. project.godot
# ------------------------------------------------------------------
echo "Creating project.godot"
cat <<'EOF' > project.godot
[application]
config/name="RotatingTextDemo"
run/main_scene="res://main.tscn"

[rendering]
renderer/rendering_method="forward_plus"
EOF

# ------------------------------------------------------------------
# 2. Main.gd
# ------------------------------------------------------------------
echo "Creating Main.gd"
cat <<'EOF' > Main.gd
extends Node3D

# FIX VERSION (debug)
const FIX_VERSION := "2025-12-09T21:20Z"

@export var text_to_extrude: String = "DEMO"
@export var radius: float = 8.0
@export var letter_thickness: float = 0.3
@export var rotation_speed: float = 0.4
@export var letter_scale: float = 3.0
@export var font_size: int = 64

@export var override_font: Font

@onready var cam: Camera3D = $Camera3D

var letters_root: Node3D

func _ready() -> void:
    print("Main.gd FIX_VERSION =", FIX_VERSION)

    scale = Vector3.ONE
    _create_sphere()

    letters_root = Node3D.new()
    add_child(letters_root)

    _create_letters()

    if cam:
        cam.global_transform.origin = Vector3(0, 4, 20)
        cam.look_at(Vector3.ZERO, Vector3.UP)


func _process(delta: float) -> void:
    if letters_root:
        # Negative for clockwise when viewed from +Y
        letters_root.rotate_y(-rotation_speed * delta)


func _create_sphere() -> void:
    var m := SphereMesh.new()
    m.radius = 3.0
    m.height = 6.0             # 2 * radius => true sphere
    m.radial_segments = 64
    m.rings = 32

    var s := MeshInstance3D.new()
    s.name = "Sphere"
    s.mesh = m
    s.scale = Vector3.ONE

    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.2,0.4,0.8)
    mat.roughness = 0.4
    s.set_surface_override_material(0, mat)

    add_child(s)


func _get_font() -> Font:
    if override_font:
        return override_font

    var sf := SystemFont.new()
    sf.font_names = []
    return sf


func _create_letters() -> void:
    var letters: Array[String] = []

    for c in text_to_extrude:
        if c != " ":
            letters.append(str(c))

    if letters.is_empty():
        return

    var count: int = letters.size()
    var angle_step: float = TAU / float(count)
    var base_angle: float = 0.0

    var font: Font = _get_font()

    for i in count:
        var ch: String = letters[i]

        var tm := TextMesh.new()
        tm.text = ch
        tm.font = font
        tm.font_size = font_size
        tm.depth = letter_thickness

        var li := MeshInstance3D.new()
        li.name = "Letter_%s_%d" % [ch, i]
        li.mesh = tm
        li.scale = Vector3.ONE

        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color.from_hsv(float(i)/float(count),0.8,1.0)
        li.set_surface_override_material(0,mat)

        # NEGATIVE angle so ordering around circle flips to D-E-M-O visually
        var angle: float = base_angle - angle_step * float(i)

        var pos := Vector3(
            radius * cos(angle),
            0.0,
            radius * sin(angle)
        )

        var xf := Transform3D.IDENTITY
        xf.origin = pos

        # Letters face inward so front is readable
        var inward := (Vector3.ZERO - pos).normalized()
        xf.basis = Basis().looking_at(inward, Vector3.UP)

        li.transform = xf
        li.scale = Vector3.ONE * letter_scale

        letters_root.add_child(li)
EOF

# ------------------------------------------------------------------
# 3. main.tscn
# ------------------------------------------------------------------
echo "Creating main.tscn"
cat <<'EOF' > main.tscn
[gd_scene load_steps=2]

[ext_resource type="Script" path="res://Main.gd" id=1]

[node name="Main" type="Node3D"]
script = ExtResource("1")

[node name="Camera3D" type="Camera3D" parent="."]
current = true

[node name="DirectionalLight3D" type="DirectionalLight3D" parent="."]
transform = Transform3D(
  1,0,0,
  0,0.707107,-0.707107,
  0,0.707107, 0.707107,
  0,6,0
)
EOF

# ------------------------------------------------------------------
# 4. run.sh
# ------------------------------------------------------------------
echo "Creating run.sh"
cat <<'EOF' > run.sh
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
EOF

chmod +x run.sh

# ------------------------------------------------------------------
# 5. export_mac.sh
# ------------------------------------------------------------------
echo "Creating export_mac.sh"
cat <<'EOF' > export_mac.sh
#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG="$PROJECT_DIR/build/RotatingTextDemo.app"

mkdir -p "$(dirname "$PKG")"

if command -v godot4 >/dev/null 2>&1; then GODOT_BIN="$(command -v godot4)"
elif command -v godot >/dev/null 2>&1; then GODOT_BIN="$(command -v godot)"
elif [[ -x "/Applications/Godot4.app/Contents/MacOS/Godot" ]]; then GODOT_BIN="/Applications/Godot4.app/Contents/MacOS/Godot"
elif [[ -x "/Applications/Godot.app/Contents/MacOS/Godot" ]]; then GODOT_BIN="/Applications/Godot.app/Contents/MacOS/Godot"
else
  echo "ERROR: Cannot find Godot."
  exit 1
fi

echo "Exporting macOS build to $PKG (preset: macOS)"
"$GODOT_BIN" --headless --path "$PROJECT_DIR" --export-release "macOS" "$PKG"
echo "Done."
EOF

chmod +x export_mac.sh

# ------------------------------------------------------------------
# 6. export_web.sh
# ------------------------------------------------------------------
echo "Creating export_web.sh"
cat <<'EOF' > export_web.sh
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
EOF

chmod +x export_web.sh

# ------------------------------------------------------------------
# Run the project immediately
# ------------------------------------------------------------------
echo
echo "Project created in $(pwd)"
echo "Launching project..."
./run.sh || {
  echo "Run failed."
  exit 1
}

