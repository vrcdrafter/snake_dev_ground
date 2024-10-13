extends MeshInstance3D



func _ready() -> void:
	var handle_snake :CharacterBody3D = get_node("../../../../head")
	var callable :Callable = Callable(self,"change_color")
	handle_snake.connect("state_change",callable)

	
	
	
func change_color():
	print("better change the color")
	
	material_override.albedo_color = Color(randf(),randf(),randf())
