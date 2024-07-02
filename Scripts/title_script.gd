extends Control

const path :String = "user://.save"

var data = "1"

var file :FileAccess

@onready var terminal :Label = $Label
func _ready() -> void:
	
	#build a file so its ready 
	
	if FileAccess.file_exists(path):
		#do a read 
		print("data esists")
		terminal.text = "file already exists \n"
		# load it 
		
		
		terminal.text = load_game()
		
		# close the file 
		
		
	else:
		# make a new one and make a default value 
		
		file = FileAccess.open(path,FileAccess.WRITE)
		save(data)
		print("file does not exist we made one here ",file.get_path_absolute())
		terminal.text = "file does not exist we made one here \n " + file.get_path_absolute()
		file.close()
	print(load_game())
	
	
func save(content):
	
	file.store_string(content)
	
func load_game():
	var file = FileAccess.open(path,FileAccess.READ)
	var content = file.get_as_text()
	return content
	


func _on_level_3_button_down() -> void:
	print(load_game())
	if load_game() == "111":
		print("load level 3")
	else:
		print("save is corrupt")

func _on_level_2_button_down() -> void:
	print(load_game())
	if load_game() == "11":
		print("load level 2")
	else:
		print("save is corrupt")

func _on_level_1_button_down() -> void:
	print(load_game())
	if load_game() == "1":
		get_tree().change_scene_to_file("res://Scenes/MainScene.tscn")
	else:
		print("save is corrupt")
