extends Spatial

onready var cylinder : CSGCylinder = $Cylinder
var vector : Vector3 = Vector3.ZERO
var origin : Vector3 = Vector3.ZERO setget set_origin

func setup(material : SpatialMaterial) -> void:
	cylinder.material = material

func set_width(width : float = 0) -> void:
	cylinder.radius = width

func set_vector(vector : Vector3 = Vector3.ZERO) -> void:
	self.vector = vector
	cylinder.height = vector.length()
	update_placement()

func get_vector() -> Vector3:
	return vector

func set_origin(vec : Vector3) -> void:
	origin = vec
	update_placement()

func update_placement() -> void:
	transform.origin = origin + vector / 2
	
	if -transform.basis.z == vector.normalized() or vector.length() == 0:
		return
	
	transform = transform.looking_at(vector + origin, Vector3(randf(), randf(), randf()))
