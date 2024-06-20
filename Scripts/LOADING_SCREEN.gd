extends Control


@export var loading_bar : ProgressBar

@export var percenctage_label  :Label

var scene_path :String
var progress : Array

func _ready() -> void:
	scene_path = "res://Scenes/level_2.tscn"
	ResourceLoader.load_threaded_request(scene_path)
	
func _process(delta: float) -> void:
	ResourceLoader.load_threaded_get_status(scene_path, progress)
	loading_bar.value = progress[0]
	percenctage_label.text = str(progress[0] * 100)
	
	if loading_bar.value >= 1.0:
		get_tree().change_scene_to_packed(
			ResourceLoader.load_threaded_get(scene_path)
		)
