extends Snake
var ensnare_state :String = "path"
var snake_state :String = "patrol"
@onready var test_mesh :MeshInstance3D = get_node("../MeshInstance3D")

func _ready() -> void:

	# make triangles for each bone in snake , move position to each bone 
	#make_tris() ( head tris is green ) 
	make_tris()
	# initialize the ensnarment points , basically the points where the snake wraps around . 
	initialize_ensnarment_curve()
	
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
				
				snake_state = "ensnare"
		"ensnare":
			var ennarement_done :bool = false
			match ensnare_state:
				
				"path":
					make_ensnarement_curve(ensnarement_points,tri_array,test_mesh)
					move_segments_to_path()
					ensnare_state = "run"
				"run":
					ennarement_done = move_segments_along_path(delta)
					if ennarement_done:
						ensnare_state = "finished"
				"finished":
					# possibly run squeese animation 
					pass
				"abort":
					pass
			
		"chase":
			#slither toward target fast (target is player)
			pass 
			
		"vore": # were not doing this in this kind of game 
			pass 
			
	
