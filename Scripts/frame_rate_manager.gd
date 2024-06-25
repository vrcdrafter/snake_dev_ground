extends Node3D

@onready var Frame_label :Label = $FRAMES
 
signal restor_speed


var snake_new = preload("res://Scenes/Snake.tscn")
@export var frames :int = 60
signal reconnect_snakes

func _process(delta: float) -> void:
	
	#var frames = Engine.get_frames_per_second()
	
	Frame_label.text = str(frames)
	
	if frames < 15:
		reset_snakes()
		emit_signal("restor_speed")


func reset_snakes():
		var snake_instance = []
		for n in range(6):
			# load snakes into array
			snake_instance.append(snake_new.instantiate())
			snake_instance[n].position = get_node("Reset_snake_position_"+str(n+1)).global_position
			
		var remove_snake :Array = get_tree().get_nodes_in_group("snake")
		for n in range(6):
			# gets handles
			remove_snake[n].queue_free()
			get_tree().get_root().get_node("./Node3D").add_child(snake_instance[n])
			snake_instance[n].name = "Snake" + str(n+1)
			
			
		emit_signal("reconnect_snakes")
