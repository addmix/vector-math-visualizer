extends Spatial

const vector = preload("res://vector.tscn")
const red = preload("res://red.tres")
const green = preload("res://green.tres")
const blue = preload("res://blue.tres")

export var vector_width : float = 0.1 setget set_width

var vectors : Array = []

onready var x = vector.instance()
onready var y = vector.instance()
onready var z = vector.instance()

func _ready() -> void:
	#setup vectors
	#x/r
	x.name = "x"
	vectors.append(x)
	add_child(x)
	x.setup(red)
	#y/g
	y.name = "y"
	vectors.append(y)
	add_child(y)
	y.setup(green)
	#z/b
	z.name = "z"
	vectors.append(z)
	add_child(z)
	z.setup(blue)
	#set initial orientation
	x.set_vector(Vector3(1, 0, 0))
	y.set_vector(Vector3(0, 1, 0))
	z.set_vector(Vector3(0, 0, 1))
	
	_ready_input_boxes()
	generate_grid()
	
	play_button.connect("pressed", self, "start_tween")
	
	tween.connect("tween_completed", self, "on_tween_completed")
	tween.connect("tween_step", self, "tween_step")

func set_width(width : float = 0.1):
	call_deferred("_set_width", width)

func _set_width(width : float = 0.1):
	for i in vectors:
		i.set_width(width)
	$CSGSphere.radius = vector_width * 1.25

#input boxes
onready var xx = $Control/PanelContainer/MarginContainer/Vectors/X/X
onready var xy = $Control/PanelContainer/MarginContainer/Vectors/X/Y
onready var xz = $Control/PanelContainer/MarginContainer/Vectors/X/Z
onready var xl = $Control/PanelContainer/MarginContainer/Vectors/X/Length

onready var yx = $Control/PanelContainer/MarginContainer/Vectors/Y/X
onready var yy = $Control/PanelContainer/MarginContainer/Vectors/Y/Y
onready var yz = $Control/PanelContainer/MarginContainer/Vectors/Y/Z
onready var yl = $Control/PanelContainer/MarginContainer/Vectors/Y/Length

onready var zx = $Control/PanelContainer/MarginContainer/Vectors/Z/X
onready var zy = $Control/PanelContainer/MarginContainer/Vectors/Z/Y
onready var zz = $Control/PanelContainer/MarginContainer/Vectors/Z/Z
onready var zl = $Control/PanelContainer/MarginContainer/Vectors/Z/Length

onready var NormalizeX = $Control/PanelContainer/MarginContainer/Vectors/X/Normalize
onready var NormalizeY = $Control/PanelContainer/MarginContainer/Vectors/Y/Normalize

func _ready_input_boxes() -> void:
	xx.connect("value_changed", self, "x_input_changed")
	xy.connect("value_changed", self, "x_input_changed")
	xz.connect("value_changed", self, "x_input_changed")
	xl.connect("value_changed", self, "x_length_changed")
	NormalizeX.connect("pressed", self, "normalize_x")
	
	yx.connect("value_changed", self, "y_input_changed")
	yy.connect("value_changed", self, "y_input_changed")
	yz.connect("value_changed", self, "y_input_changed")
	yl.connect("value_changed", self, "y_length_changed")
	NormalizeY.connect("pressed", self, "normalize_y")

func x_input_changed(_value : float) -> void:
	set_x(Vector3(xx.value, xy.value, xz.value))

func x_length_changed(value : float) -> void:
	if x.get_vector().length() == 0:
		xl.value = 0
		return
	set_x(x.get_vector().normalized() * value)

func y_input_changed(_value : float) -> void:
	set_y(Vector3(yx.value, yy.value, yz.value))

func y_length_changed(value : float) -> void:
	if y.get_vector().length() == 0:
		yl.value = 0
		return
	set_y(y.get_vector().normalized() * value)

func normalize_x() -> void:
	set_x(x.get_vector().normalized())
func normalize_y() -> void:
	set_y(y.get_vector().normalized())

func set_x(vector : Vector3) -> void:
	x.set_vector(vector)
	xx.value = vector.x
	xy.value = vector.y
	xz.value = vector.z
	xl.value = vector.length()
	update_math()

func set_y(vector : Vector3) -> void:
	y.set_vector(vector)
	yx.value = vector.x
	yy.value = vector.y
	yz.value = vector.z
	yl.value = vector.length()
	update_math()

func set_z(vector : Vector3) -> void:
	z.set_vector(vector)
	zx.value = vector.x
	zy.value = vector.y
	zz.value = vector.z
	zl.value = vector.length()

func update_math() -> void:
	set_z(x.get_vector().cross(y.get_vector()))

#code for the horizon-aligned unit grid
var grid_size := 20.0
var grid_color := Color(0.1,0.1,0.1,0.1)
func generate_grid() -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)
	
	for _x in grid_size:
		st.add_color(grid_color)
		st.add_vertex(Vector3(-grid_size / 2 + _x, 0, -grid_size / 2 - 1))
		st.add_color(grid_color)
		st.add_vertex(Vector3(-grid_size / 2 + _x, 0, grid_size / 2))
	for _y in grid_size:
		st.add_color(grid_color)
		st.add_vertex(Vector3(-grid_size / 2 - 1, 0, -grid_size / 2 + _y))
		st.add_color(grid_color)
		st.add_vertex(Vector3(grid_size / 2, 0, -grid_size / 2 + _y))
	
	$MeshInstance.mesh = st.commit()

#camera pivot
onready var camera_pivot : Spatial = $CameraPivot
func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		#if right click
		if Input.is_mouse_button_pressed(2):
			camera_pivot.rotation_degrees.x = clamp(camera_pivot.rotation_degrees.x - event.relative.y, -90, 90)
			camera_pivot.rotation_degrees.y -= event.relative.x



#tween stuff
onready var play_button : Button = $Control/PanelContainer/MarginContainer/Vectors/Animation/Play
onready var t : SpinBox = $Control/PanelContainer/MarginContainer/Vectors/Animation/Time
#x
onready var xxt : SpinBox = $Control/PanelContainer/MarginContainer/Vectors/XTo/X
onready var xyt : SpinBox = $Control/PanelContainer/MarginContainer/Vectors/XTo/Y
onready var xzt : SpinBox = $Control/PanelContainer/MarginContainer/Vectors/XTo/Z
#y
onready var yxt : SpinBox = $Control/PanelContainer/MarginContainer/Vectors/YTo/X
onready var yyt : SpinBox = $Control/PanelContainer/MarginContainer/Vectors/YTo/Y
onready var yzt : SpinBox = $Control/PanelContainer/MarginContainer/Vectors/YTo/Z

onready var tween : Tween = $Tween
var animation_progress := 0.0
var start_x := Vector3.ZERO
var start_y := Vector3.ZERO

func xto() -> Vector3:
	return Vector3(xxt.value, xyt.value, xzt.value)
func yto() -> Vector3:
	return Vector3(yxt.value, yyt.value, yzt.value)

func start_tween() -> void:
	start_x = x.get_vector()
	start_y = y.get_vector()
	tween.interpolate_property(self, "animation_progress", 0, 1, t.value, Tween.TRANS_CUBIC)
	$Control.hide()
	
	yield(get_tree().create_timer(1.0), "timeout")
	
	tween.start()
	

func get_x_progress() -> Vector3:
	var xto := xto()
	var length : float = lerp(start_x.length(), xto.length(), animation_progress)
	var start_x_norm := start_x.normalized()
	var xto_norm := xto.normalized()
	return start_x_norm.slerp(xto_norm, animation_progress) * length
func get_y_progress() -> Vector3:
	var yto := yto()
	var length : float = lerp(start_y.length(), yto.length(), animation_progress)
	var start_y_norm := start_y.normalized()
	var yto_norm := yto.normalized()
	return start_y_norm.slerp(yto_norm, animation_progress) * length

func tween_step(object : Object, key : NodePath, elapsed : float, _value : float) -> void:
	if tween.is_active():
		set_x(get_x_progress())
		set_y(get_y_progress())

func on_tween_completed(object, key) -> void:
	yield(get_tree().create_timer(1.0), "timeout")
	$Control.show()
