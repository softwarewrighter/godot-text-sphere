extends Node3D

# FIX VERSION (debug)
const FIX_VERSION := "2025-12-09T21:20Z"

@export var text_to_extrude: String = "[godot-text-sphere]"
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
