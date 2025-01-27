extends Node3D
# this is not used unless the snakes start to get stuck . 
@onready var Frame_label :Label = $FRAMES
 
signal restor_speed

signal remove_mouse

var snake_new = preload("res://Scenes/Snake.tscn")
var new_snake_animated = preload("res://Scenes/experimetal_snake_with_animation_v2.tscn")
signal reconnect_snakes

var toggle :bool = true # for the pause stuff

func _ready() -> void:
	
	var menu :Callable = Callable(self, "_on_button_button_down")
	var menu_button :Button = get_node("menu/Button")
	menu_button.connect("button_down",menu)
	
	var restart :Callable = Callable(self, "_on_button_2_button_down")
	var menu_button_2 :Button = get_node("menu/Button2")
	menu_button_2.connect("button_down",restart)



func _process(delta: float) -> void:
	
	var frames = Engine.get_frames_per_second()
	
	Frame_label.text = str(frames)
	
	var snakes :int = 0 
	
	var all_nodes :Array = get_children() 
	
	for i in all_nodes.size():
		
		if all_nodes[i].is_in_group("snake"):
			snakes += 1
	
	if GlobalVars.next_level == "res://Scenes/experiment_3.tscn":
		
		$snake_number.text = str(snakes)
	


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
		
func _input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("menu"):
		if toggle:
			Engine.time_scale = 0
			toggle = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$menu.visible = true
		else:
			Engine.time_scale = 1
			toggle = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			$menu.visible = false
	if Input.is_action_just_pressed("add_snake"):
		
		var new_snake :Node3D = new_snake_animated.instantiate()
		new_snake.global_position = Vector3(0,1,0)
		new_snake.add_to_group("snake")
		add_child(new_snake,true)
		print("new snake", new_snake.get_groups())
func _on_button_button_down() -> void:
	Engine.time_scale = 1
	GlobalVars.next_level = "res://Scenes/title.tscn"
	get_tree().change_scene_to_file("res://Scenes/loading.tscn")


func _on_button_2_button_down() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
