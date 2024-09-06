@tool

extends MeshInstance3D
@onready var point :Marker3D = get_node("../Marker3D")

func _process(delta: float) -> void:
	
	var direction = transform.basis.z.normalized()
	point.global_position = (direction * 2 ) + global_position
