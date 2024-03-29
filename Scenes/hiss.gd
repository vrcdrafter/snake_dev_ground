
extends AudioStreamPlayer3D
@onready var timer :Timer = $Timer
var run_audio :bool = false
var play_audio :float = randf()
func _ready():
	timer.start()
	

func _process(delta):
	 
	if run_audio:
		play_audio = randf()
		run_audio = false
		
	
	if play_audio < .5:
		
		play()
		play_audio = 1.0


func _on_timer_timeout():
	run_audio =true
