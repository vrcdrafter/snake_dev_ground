

extends Control
  # this scrips rotates the player to force it to load stuff 


@onready var player :CharacterBody3D = get_node("../Player")

var rotating :bool = true

var load_value :float = 0.0

var one_shot :bool = true
	
func _process(delta: float) -> void:
	
	print(rad_to_deg(player.rotation.y))
	if rad_to_deg(player.rotation.y) > 179:
		rotating = false
	
	# rotate player for a second 
	if rotating:
		player.global_position = get_node("../idle_objects/cube5").global_position
		
		player.rotate(Vector3(0,1,0),0+delta*.5)
	else:
		self.visible = false
		
		if one_shot:
			player.global_position = Vector3(-41.099,2.668,-81.275)
			one_shot = false
		
	load_value = rad_to_deg(player.rotation.y)/180 
	
	$ProgressBar.value = load_value




