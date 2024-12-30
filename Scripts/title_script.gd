extends Control

const path :String = "user://.save"

var data = "1"

var file :FileAccess

@onready var terminal :Label = $Label
func _ready() -> void:
	
	#build a file so its ready 
	
	if FileAccess.file_exists(path):
		#do a read 
		file = FileAccess.open(path,FileAccess.READ)
		print("data esists")
		terminal.text = "file already exists \n"
		terminal.text = "is is here \n " + file.get_path_absolute() + "\n"
		# load it 
		
		
		terminal.text = load_game() +"\n"
		
		# close the file 
		
		
	else:
		# make a new one and make a default value 
		
		file = FileAccess.open(path,FileAccess.WRITE)
		save(data)
		print("file does not exist we made one here ",file.get_path_absolute())
		terminal.text = "file does not exist we made one here \n " + file.get_path_absolute()
		file.close()
	print(load_game())
	
	level_access() # asses what levels the player gets 
	
	
func save(content):
	
	file.store_string(content)
	
func load_game():
	var file = FileAccess.open(path,FileAccess.READ)
	var content = file.get_as_text()
	return content
	
	
func _on_level_4_button_down() -> void:

	GlobalVars.next_level = "res://Scenes/level_4.tscn"
	get_tree().change_scene_to_file("res://Scenes/loading.tscn")
	setup_level()


func _on_level_3_button_down() -> void:
	GlobalVars.next_level = "res://Scenes/level_3.tscn"
	get_tree().change_scene_to_file("res://Scenes/loading.tscn")
	setup_level()

func _on_level_2_button_down() -> void:
	GlobalVars.next_level = "res://Scenes/level_2.tscn"
	get_tree().change_scene_to_file("res://Scenes/loading.tscn")
	setup_level()


func _on_level_1_button_down() -> void:
	GlobalVars.next_level = "res://Scenes/MainScene.tscn"
	get_tree().change_scene_to_file("res://Scenes/loading.tscn")
	setup_level()



func level_access():
	if load_game().contains("1"):
		$LEVEL1.disabled = false
	else:
		$LEVEL1.disabled = true
		
	if load_game().contains("11"):
		$LEVEL2.disabled = false
		$Node2D/level_1_vid2.modulate = Color(1,1,1,1)
	else:
		$LEVEL2.disabled = true
	if load_game().contains("111"):
		$LEVEL3.disabled = false
		$Node2D/level_1_vid3.modulate = Color(1,1,1,1)
	else:
		$LEVEL3.disabled = true


func setup_level():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GlobalVars.game_started = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_level_5_button_down() -> void:
	GlobalVars.next_level = "res://Scenes/experiment_3.tscn"
	get_tree().change_scene_to_file("res://Scenes/loading.tscn")
	setup_level()
