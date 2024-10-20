@tool

extends RayCast3D

@onready var otherray :RayCast3D = get_node("../RayCast3D")

func _process(delta: float) -> void:
	
	
	var vec :Vector3 = otherray.target_position
	target_position = Vector3(vec.z/vec.length(),vec.y,-vec.x/vec.length())
	
	
