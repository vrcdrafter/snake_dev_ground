extends Snake
var ensnare_state :String = "path"
var snake_state :String = "patrol"
@onready var player :CharacterBody3D = get_node("../Player")
@onready var test_mesh :MeshInstance3D = get_node("../MeshInstance3D")
var snake_target = null


func _ready() -> void:
	snake_target = player
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
			set_movement_target(snake_target.global_position) # assigns target
			nav_startup_physics_process(delta,tri_array[0]) #starts up the navigation server 
			#start tris following eachother
			follower(delta,tri_array,bone_length)
			if (snake_target.global_position - tri_array[0].global_position).length() < 1:
				
				snake_state = "ensnare"
		"ensnare":
			var ennarement_done :bool = false
			match ensnare_state:
				
				"path":
					make_ensnarement_curve(ensnarement_points,tri_array,snake_target)
					move_segments_to_path()
					ensnare_state = "run"
				"run":
					ennarement_done = move_segments_along_path(delta)
					if ennarement_done and not ((snake_target.global_position - tri_array[0].global_position).length() < 2):
						ensnare_state = "finished"
					elif (snake_target.global_position - tri_array[0].global_position).length() < 2:
						ensnare_state == "abort"
						
					else :
						pass
				"finished":
					
					if (snake_target.global_position - tri_array[0].global_position).length() > 2.0:
						ensnare_state = "abort"
						
				"abort":
					print("should be aboring ")
					move_segments_back_normal()
					snake_state = "patrol"
			
		"chase":
			#slither toward target fast (target is player)
			pass 
			
		"vore": # were not doing this in this kind of game 
			pass 
			
	
