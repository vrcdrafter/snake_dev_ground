extends Control


@export var loading_bar : ProgressBar

@export var percenctage_label  :Label

var scene_path :String
var progress : Array

func _ready() -> void:
	# fetch what is in global 
	var next_level :String = GlobalVars.next_level
	scene_path = next_level
	ResourceLoader.load_threaded_request(scene_path)
	
func _process(delta: float) -> void:
	ResourceLoader.load_threaded_get_status(scene_path, progress)
	loading_bar.value = progress[0]
	percenctage_label.text = str(progress[0] * 100)
	
	if loading_bar.value >= 1.0:
		get_tree().change_scene_to_packed(
			ResourceLoader.load_threaded_get(scene_path)
		)
