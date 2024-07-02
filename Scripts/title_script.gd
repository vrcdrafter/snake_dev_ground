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
	


func _on_level_3_button_down() -> void:
	print(load_game())
	if load_game() == "111":
		print("load level 3")
	else:
		
		print("save is corrupt")

func _on_level_2_button_down() -> void:

	get_tree().change_scene_to_file("res://Scenes/level_2.tscn")


func _on_level_1_button_down() -> void:

	get_tree().change_scene_to_file("res://Scenes/MainScene.tscn")



func level_access():
	if load_game().contains("1"):
		$LEVEL1.disabled = false
	else:
		$LEVEL1.disabled = true
		
	if load_game().contains("11"):
		$LEVEL2.disabled = false
	else:
		$LEVEL2.disabled = true
	if load_game().contains("111"):
		$LEVEL3.disabled = false
	else:
		$LEVEL3.disabled = true
