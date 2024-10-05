extends Area3D

var toggle :bool = false

@onready var audio_handle :AudioStreamPlayer = get_node("../AudioStreamPlayer")

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		
		if toggle:
			audio_handle.stop()
			toggle = false
		else:
			audio_handle.play()
			toggle = true
		
