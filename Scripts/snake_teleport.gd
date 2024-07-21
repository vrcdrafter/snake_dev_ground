extends Area3D


var snake_new = preload("res://Scenes/Snake.tscn")

var number_of_snakes_needed :int = 0 
signal reconnect_snakes
var top_node_name : String

func _ready() -> void:
	for n in get_children():
		if n.get_class() == "Marker3D":
			number_of_snakes_needed += 1
	print("I have a marker 3d ", number_of_snakes_needed)
	top_node_name = get_tree().current_scene.name


func _on_body_entered(body: Node3D) -> void:
	
	
	# need a for loop for each new instance to make 


	if body.is_in_group("player"):
		set_deferred("monitoring", false)

		print("found player in area , should happen once . A")
		var snake_instance :Array[Node3D] = []
		for n in range(number_of_snakes_needed):
			# load snakes into array
			snake_instance.append(snake_new.instantiate())
			snake_instance[n].position = get_node("Marker3D"+str(n+1)).global_position
			
		var remove_snake :Array = get_tree().get_nodes_in_group("snake")
		for n in range(number_of_snakes_needed):
			# gets handles
			remove_snake[n].queue_free()
			get_tree().get_root().get_node("./" + top_node_name).add_child(snake_instance[n])
			snake_instance[n].name = "Snake" + str(n+1)

			
		emit_signal("reconnect_snakes")
	# end foor loop 
