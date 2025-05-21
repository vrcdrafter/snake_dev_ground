extends Snake
var ensnare_state :String = "path"
var snake_state :String = "patrol"
@onready var player :CharacterBody3D = get_node("../Player")
@onready var test_mesh :MeshInstance3D = get_node("../MeshInstance3D")
var snake_target :Node3D = null

@onready var skel :Skeleton3D
var all_animation_curves :Array[Curve3D]

var bone_overriding :bool = true

# animation one start , so the animation timer plays once 
var onestart :bool = true
var transform_onestart :bool = true
var transform_save :Transform3D 

# list of oneshots 
var snake_ensnare_oneshot :bool = true

# slider bar
@onready var slidex :VSlider = get_node("../X_axis")

func _ready() -> void:
	snake_target = player
	
	#initialize spine 
	initilaize_spine_bones()
	
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

	var make_timer :Timer = make_anim_timer()

func _physics_process(delta: float) -> void:
	
	snake_wave_pysics_process(delta) # initialize the snake wavyness
	
	# have snake start to chase target 
	match snake_state:
		
		"patrol":
			
			# just be casual agressivness 
			aggressivness = 1
			movement_speed = 1
			#find something to patrol to 
		
			set_movement_target(snake_target.global_position) # assigns target
			nav_startup_physics_process(delta,tri_array[0]) #starts up the navigation server 
			#start tris following eachother
			follower(delta,tri_array,bone_length)
			
			var non_player_target_distance :float = tri_array[0].global_position.distance_to(snake_target.global_position)
			# if condition if its just a relay point
			var player_distance :float = tri_array[0].global_position.distance_to(player.global_position)
			if player_distance < 5:
				# chase player
				snake_target = player
				snake_state = "chase"
			else:
				if non_player_target_distance < 1 and not snake_target.is_in_group("A"):
					# pick new object
					var next_target :MeshInstance3D = fetch_random_patrol_object()
					while next_target == target:
						next_target = patrol_objects.pick_random()
					snake_target = next_target
				# if condition if its a animated object 
				if non_player_target_distance < 1 and snake_target.is_in_group("A"):
					# its a animated spot run an animated ensnar 
					snake_state = "ensnare_anim"
					
				
		"ensnare":
			var ennarement_done :bool = false
			
			match ensnare_state:
				
				"path":
					make_ensnarement_curve(ensnarement_points,tri_array,snake_target)
					move_segments_to_path()
					ensnare_state = "run"
				"run":
					# add a timer so that the decision is not too fast 
					if snake_ensnare_oneshot:
						var timer_reaction :Timer = make_reaction_timer()
						timer_reaction.start()
						snake_ensnare_oneshot = false
					ennarement_done = move_segments_along_path(delta,8)
					twist_triangles(0)
					if ennarement_done and not ((snake_target.global_position - tri_array[0].global_position).length() > 2):
						ensnare_state = "finished"
						
						
					elif ((snake_target.global_position - tri_array[0].global_position).length() > 2) and timer_up2:
						ensnare_state = "abort"
						
						snake_ensnare_oneshot = true
					else :
						pass
				"finished":
					
					if (snake_target.global_position - tri_array[0].global_position).length() > 2.0:
						ensnare_state = "abort"
						
						
				"abort":
					
					move_segments_back_normal()
					snake_state = "patrol"
					ensnare_state = "path"
			
		"chase":
			#find something to patrol to 
			aggressivness = 6
			movement_speed = 6
			# 

			set_movement_target(snake_target.global_position) # assigns target
			nav_startup_physics_process(delta,tri_array[0]) #starts up the navigation server 
			#start tris following eachother
			follower(delta,tri_array,bone_length)
			
			var player_distance :float = tri_array[0].global_position.distance_to(player.global_position)
			
			if player_distance < 1:
				snake_state = "ensnare_anim"  
				
				
			if player_distance > 8: # give up chase 
				snake_state = "patrol"
				snake_target = pick_new_target(snake_target) # get a new target too
			
		"ensnare_anim": # meaning animated ensnarement
			# need to find right curve to use 
			var target_animation :String = find_target_animation(snake_target)
			var animation_curve :Curve3D # for now just play the first curve found
			for i in all_animation_curves.size():
				if all_animation_curves[i].resource_name == target_animation:
					animation_curve = all_animation_curves[i]
			# if at some point the player gets too close resume chase 
			var ennarement_done :bool = false
			match ensnare_state:
				"path":
					make_ensnarement_curve(ensnarement_points,tri_array,snake_target,animation_curve)
					move_segments_to_path()
					ensnare_state = "run"
					if snake_target == player:
						emit_signal("ensnared") # good to put this signal here because path is only written once 
				"run":
					

					
					ennarement_done = move_segments_along_path(delta,2)
					var local_target_distance :float = (snake_target.global_position - tri_array[0].global_position).length()
					if ennarement_done and not (local_target_distance > 2.3):
						ensnare_state = "run_animation"
						
					elif local_target_distance > 2.3:
						
						ensnare_state = "abort"
					else :
						pass
				"run_animation":
					bone_overriding = false
					skel.clear_bones_global_pose_override()
					if transform_onestart:
						transform_save = self.global_transform # note this line needs to run once too 
						transform_onestart = false
					# move the snake to the position 
						self.global_transform = snake_target.global_transform
					
					# check to see if player gets close 
					var player_distance :float = self.global_position.distance_to(player.global_position) # the reason why its self .global is because of the animation transform 
					if player_distance < 5 and not snake_target == player: # but what if your after the player , ( problem here ) 
						# chase player
						# force timer to conclude 
						timer_up = true
						snake_target = player
					if player_distance > 3 and  snake_target == player:
						timer_up = true
						

					
					snake_animations.play(target_animation)
					if onestart:
						timer_move_on.start() # start the timer for how long to be there .
						onestart = false
					
					if timer_up:
						transform_onestart = true # reset this so it can grab the next transform when the time comes . 
						snake_state = "patrol"
						# reset the ensnare state too 
						ensnare_state = "path"
						onestart = true
						snake_animations.stop()
						bone_overriding = true
						#transform the object back too 
						self.global_transform = transform_save# remember to restore the transform 
						
						# also pick new target ( made a function ) 
						snake_target = pick_new_target(snake_target)
						timer_up = false
						
						
					
				"abort":
					
					move_segments_back_normal()
					snake_state = "patrol"
					ensnare_state = "path"
			
		"vore": # were not doing this in this kind of game 
			pass 
			
	if bone_overriding:
		override_skeleton(skel)
