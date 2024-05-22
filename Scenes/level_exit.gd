extends MeshInstance3D

@onready var audio :AudioStreamPlayer3D = $AudioStreamPlayer3D
var unlocked :bool = false

var un_locked_audio: Resource  = preload("res://sounds/glitchedtones_Door+Bathroom+Unlock+01.mp3")
var locked_audio: Resource  = preload("res://sounds/zapsplat_household_door_handle_try_open_locked_001_10218.mp3")

var keys_found_num :int = 0

func _ready() -> void:
	
	
	var callable_1 = Callable(self,"_on_key_1_key_found")
	var callable_2 = Callable(self,"_on_key_2_key_found")
	var callable_3 = Callable(self,"_on_key_3_key_found")
		# connect stuff 
	var key_1_handle :Sprite2D = get_node("../key1")
	var key_2_handle :Sprite2D = get_node("../key2")
	var key_3_handle :Sprite2D = get_node("../key3")
	key_1_handle.connect("key_found", callable_1)
	key_2_handle.connect("key_found", callable_2)
	key_3_handle.connect("key_found", callable_3)


func _process(delta):

	if keys_found_num == 3:
		unlocked = true
		
	

	
	

	
# weesle peesle


func _on_area_3d_body_entered(body):
	if unlocked:
		audio.stream = un_locked_audio
		audio.play()
		
		get_tree().change_scene_to_file("res://Scenes/level_2.tscn")
		# add credits scene 
	else:
		audio.stream = locked_audio
		audio.play()



func _on_key_2_key_found():
	keys_found_num += 1


func _on_key_3_key_found():
	keys_found_num += 1


func _on_key_1_key_found():
	keys_found_num += 1
