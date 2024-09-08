@tool
extends PathFollow3D

@onready var segment_along_path :MeshInstance3D = get_node("../../MeshInstance3D")

func _process(delta: float) -> void:
	
	progress += 1 * delta
	
	
	var strobe_current_psotion :Vector3 = $CSGMesh3D2.global_position
	
	if strobe_current_psotion == segment_along_path.global_position:
		print("found the postion ", position, " here ")
