extends Snake

var snake_state :String = "patrol"
@onready var test_mesh :MeshInstance3D = get_node("../MeshInstance3D")

func _ready() -> void:

	# make triangles for each bone in snake , move position to each bone 
	#make_tris() ( head tris is green ) 
	make_tris()
	
	nav_startup_ready() # starts up the navigation
	print("ran this")
	
	
func _physics_process(delta: float) -> void:
	

	# have snake start to chase target 
	match snake_state:
		
		"patrol":
			set_movement_target(test_mesh.global_position) # assigns target
			nav_startup_physics_process(delta,tri_array[0]) #starts up the navigation server 
			#start tris following eachother
			follower(delta,tri_array,bone_length)
			if (test_mesh.global_position - tri_array[0].global_position).length() < 1:
				print("your close , start to ensnare")
				snake_state = "ensnare"
		"ensnare":
			pass
			# run through ensnare routine 
			# move segments to 
			#make_ensnarement_curve()
			#move_segments_to_path()
			
		"chase":
			#slither toward target fast (target is player)
			pass 
			
		"vore": # were not doing this in this kind of game 
			pass 
			
	
