@tool
extends Path3D





@onready var thing_outside_path :CSGMesh3D= get_node("../CSGMesh3D")

@onready var mover :MeshInstance3D = get_node("../MeshInstance3D")




func _process(delta: float) -> void:
	
	var pos = curve.get_closest_point(thing_outside_path.global_position)
	mover.global_position = pos
