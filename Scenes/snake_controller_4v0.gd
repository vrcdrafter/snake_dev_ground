extends Snake
var ensnare_state :String = "path"
var snake_state :String = "patrol"
@onready var player :CharacterBody3D = get_node("../Player")
@onready var test_mesh :MeshInstance3D = get_node("../MeshInstance3D")
var snake_target :Node3D = null

@onready var skel :Skeleton3D
var all_animation_curves :Array[Curve3D]

var bone_overriding :bool = true



func _ready() -> void:
	snake_target = player
	# make triangles for each bone in snake , move position to each bone 
	#make_tris() ( head tris is green ) 
	make_tris()
	
	# initialize the ensnarment points , basically the points where the snake wraps around . 
	initialize_ensnarment_curve()
	
	initialize_timing_sway() # initializes the snakes wavyness with time 
	
	nav_startup_ready() # starts up the navigation
	
	skel = find_skeleton()
	
	initialize_patrol_objects()
	
	snake_target = fetch_random_patrol_object() # just pick a first target . 
	
	all_animation_curves = _make_curve_from_animation(skel,false) # register animations if ther is any on the model

	
func _physics_process(delta: float) -> void:
	
	snake_wave_pysics_process(delta) # initialize the snake wavyness
	
	# have snake start to chase target 
	match snake_state:
		
		"patrol":
			
			#find something to patrol to 
			
			
			set_movement_target(snake_target.global_position) # assigns target
			nav_startup_physics_process(delta,tri_array[0]) #starts up the navigation server 
			#start tris following eachother
			follower(delta,tri_array,bone_length)
			
			if tri_array[0].global_position.distance_to(snake_target.global_position) < 1 and not snake_target.is_in_group("A"):
				# pick new object
				var next_target :MeshInstance3D = fetch_random_patrol_object()
				while next_target == target:
					next_target = patrol_objects.pick_random()
				snake_target = next_target
			if tri_array[0].global_position.distance_to(snake_target.global_position) < 1 and snake_target.is_in_group("A"):
				# its a animated spot run an animated ensnar 
				snake_state = "ensnare_anim"
				print("run a animation ensnare")
				
		"ensnare":
			var ennarement_done :bool = false
			match ensnare_state:
				
				"path":
					make_ensnarement_curve(ensnarement_points,tri_array,snake_target)
					move_segments_to_path()
					ensnare_state = "run"
				"run":
					
					ennarement_done = move_segments_along_path(delta)
					
					if ennarement_done and not ((snake_target.global_position - tri_array[0].global_position).length() > 2):
						ensnare_state = "finished"
						print("ensare finished")
						
					elif (snake_target.global_position - tri_array[0].global_position).length() > 2:
						ensnare_state = "abort"
						print("prey escaped")
					else :
						pass
				"finished":
					
					if (snake_target.global_position - tri_array[0].global_position).length() > 2.0:
						ensnare_state = "abort"
						print("prey has escaped")
						
				"abort":
					
					move_segments_back_normal()
					snake_state = "patrol"
					ensnare_state = "path"
			
		"chase":
			#slither toward target fast (target is player)
			pass 
			
		"ensnare_anim": # meaning animated ensnarement
			
			var animation_curve = all_animation_curves[1] # for now just play the first curve found
			
			print("animation to play ",animation_curve)
			var ennarement_done :bool = false
			match ensnare_state:
				
				"path":
					make_ensnarement_curve(ensnarement_points,tri_array,snake_target,animation_curve)
					move_segments_to_path()
					ensnare_state = "run"
				"run":
					
					ennarement_done = move_segments_along_path(delta)
					
					if ennarement_done and not ((snake_target.global_position - tri_array[0].global_position).length() > 2):
						ensnare_state = "run_animation"
						
					elif (snake_target.global_position - tri_array[0].global_position).length() > 2:
						ensnare_state = "abort"
					else :
						pass
				"run_animation":
					bone_overriding = false
					skel.clear_bones_global_pose_override()
					# move the snake to the position 
					self.global_transform = snake_target.global_transform
					var target_animation = find_target_animation(snake_target)
					print("should be playing ", target_animation)
					snake_animations.play(target_animation)
					
				"abort":
					
					move_segments_back_normal()
					snake_state = "patrol"
					ensnare_state = "path"
			
		"vore": # were not doing this in this kind of game 
			pass 
			
	if bone_overriding:
		override_skeleton(skel)
