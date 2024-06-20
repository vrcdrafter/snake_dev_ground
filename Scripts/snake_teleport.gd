extends Area3D

@onready var old_snake_handle = get_node("../../Snake")

var snake_new = preload("res://Scenes/Snake.tscn")


func _on_body_entered(body: Node3D) -> void:
	print("found some body ")
	var snake_instance = snake_new.instantiate()
	snake_instance.position = $Marker3D.global_position
	if body.is_in_group("player"):
		print("player is in camper")
		#remove snake 
		old_snake_handle.queue_free()
		
		
		get_tree().get_root().get_node("./Node3D").add_child(snake_instance)
		
	
