extends Node3D


@onready var player_handle = get_node("../Player")



func _ready() -> void:
	
	# turn off visability 
	
	self.visible = false

func _process(delta: float) -> void:
	
	
	var distance = player_handle.global_position.z
	
	if distance > -35.8:
		#print("make it visable")
		self.visible = true
