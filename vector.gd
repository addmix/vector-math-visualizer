extends Spatial

onready var cylinder : CSGCylinder = $Cylinder
var vector : Vector3 = Vector3.ZERO

func setup(material : SpatialMaterial) -> void:
	cylinder.material = material

func set_width(width : float = 0) -> void:
	cylinder.radius = width

func set_vector(vector : Vector3 = Vector3.ZERO) -> void:
	self.vector = vector
	cylinder.height = vector.length()
	
	transform.origin = vector / 2
	
	#prevent error if already looking at vector, or 0 length vector
	if -transform.basis.z == vector.normalized() or vector.length() == 0:
		return
	
	transform = transform.looking_at(vector, Vector3(randf(), randf(), randf()))

func get_vector() -> Vector3:
	return vector
