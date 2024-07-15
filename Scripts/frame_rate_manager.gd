extends Node3D
# this is not used unless the snakes start to get stuck . 
@onready var Frame_label :Label = $FRAMES
 
signal restor_speed


var snake_new = preload("res://Scenes/Snake.tscn")

signal reconnect_snakes

func _process(delta: float) -> void:
	
	var frames = Engine.get_frames_per_second()
	
	Frame_label.text = str(frames)



func destroy_weakest_snake():
	
		var all_current_snakes :Array= get_tree().get_nodes_in_group("snake")
		var snake_append_hits :Array= []
		var highest_append_instance :int = 0
		var index :int 
		# put in append data 
		for n in range(all_current_snakes.size()):
			snake_append_hits.append(all_current_snakes[n].append_path_hits)
		print("all snake sized", snake_append_hits)
		# find highest hit 
		for i in snake_append_hits.size():
			if snake_append_hits[i] > highest_append_instance:
				highest_append_instance = snake_append_hits[i]
				index = i
		# find index

		
		var snake_to_desctory = all_current_snakes[index]
		print("highest index", index, "destroy", snake_to_desctory)
		#emit_signal("reconnect_snakes")
