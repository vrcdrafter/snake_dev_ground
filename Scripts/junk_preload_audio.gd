extends AudioStreamPlayer


@onready var audio :Resource = preload("res://sounds/walk.wav")

func _ready() -> void:
	
	stream = audio
