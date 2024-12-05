extends CharacterBody3D

const ACCEL = 10
const DEACCEL = 30
var SNAKE_SPEED = 3
const SPEED = 10
const SPRINT_MULT = 2
const JUMP_VELOCITY = 4.5
var bone_length :float = 0
var bone_numbers :int = 0
@onready var body_piece_one :MeshInstance3D = get_node("../body1")
@onready var body_piece_two :MeshInstance3D = get_node("../body2")
@onready var nav : NavigationAgent3D = $NavigationAgent3D
signal ensnared 
@export var target : Node3D

@onready var donut = get_node("../donut")

var tris_ready :bool = false
# curve stuff
var path :Path3D 
var curve :Curve3D
var ensnarement_points :PackedVector3Array
var animation_transiton_point :PackedVector3Array
var rotate_heper :Array[Node3D]
var tri_array :Array[MeshInstance3D]
var area_array :Array[Area3D]
var Segment_colission_array :Array[CollisionShape3D]
var follow_path_array :Array[PathFollow3D] 
var running_on_track :bool = false
var just_tarting_out :bool = true

@onready var measure_path_global = get_node("../Path3D/PathFollow3D")
var halt: bool = false
@export var _ensnared : bool = false

var patrol_objects :Array[MeshInstance3D]


var snake_state:String = "player_seeking"
var pick_new_object :bool = false
@export var idle_animation :bool = false # makes the snake idle at beginning with some aninmation
@export var magic_number :Vector3
signal state_change

# snake wave stuff
var time :float = 0
var snake_wavyness :float = 1
var wave_thing :float = 0
var skeleton :Skeleton3D
var parent_basis :Transform3D

var animation_stuff :AnimationPlayer 
# used for moving the snake if there is a odd rotation 
var head_position_marker :Marker3D 
var head_position_1 :Vector3
var animation_repositioned :bool = false
var parent_rotation_deg :float = 0.0 

var snake_to_player :float 

var one_shot_transition_key :bool = false

var old_position_snake_for_idle :Vector3   # this is important for restoring the positon of the snake because the animaitons are always relative 
var old_position_snake_for_idle_head :Vector3
func _ready() -> void:
	# find the snake in the tree 
	var snake_node :Node3D = get_parent().find_child("sn*")
	var name = snake_node.name
	skeleton = snake_node.find_child("Skeleton3D",true,true)
	var skeleton_name = skeleton.name
	skeleton.ready.connect(_on_skeleton_3d_ready) # not being even used . 
	animation_stuff = snake_node.find_child("AnimationPlayer")
	var bone_attach :BoneAttachment3D = BoneAttachment3D.new()
	var point_3d :Marker3D = Marker3D.new()
	skeleton.add_child(bone_attach)
	bone_attach.bone_name = "head"
	bone_attach.add_child(point_3d)
	head_position_marker = point_3d
	# get all the partrol objects
	# these 3 lines below are what keeps the snake oriented properly if you rotate and translate
	# the parent node 
	var parent_node :Node3D = get_parent()
	parent_basis = parent_node.global_transform
	parent_rotation_deg = parent_node.rotation_degrees.y
	
	for child in get_node("../../idle_objects").get_children():
		patrol_objects.append(child)

	
	time = randf() * 10
	path = get_node("../Path3D")
	var new_curve :Curve3D = Curve3D.new()
	var curve_resource :Curve3D = load("res://Resources/perfect_ensnarement_2.tres")
	var resource_points :PackedVector3Array = curve_resource.get_baked_points()
	# run a for loop to add all the points 
	for i in resource_points.size():
		new_curve.add_point(resource_points[i])
	path.curve = new_curve # set it so its the new curve istance 
	# get points 
	curve = path.curve
	curve.up_vector_enabled = false # because I said so 
	ensnarement_points = curve.get_baked_points()

	# make a curve just for going into idle animations , have array ready 
	var curve_transition :Curve3D = Curve3D.new()
	var curve_seet_transition :Curve3D = load("res://transition_curve.tres")
	var resource_points_transition :PackedVector3Array = curve_seet_transition.get_baked_points()
	for i in resource_points_transition.size():
		curve_transition.add_point(resource_points_transition[i])
	animation_transiton_point = curve_seet_transition.get_baked_points()
	# end of transiton curve stuff
	
	

	bone_numbers = skeleton.get_bone_count()
		# get # of bones 
	if GlobalVars.game_started == true:
		give_snake_speed()
	# build as manny triangles as you have bones . 
	
	for i in bone_numbers:
		# add area 3d 
		
		rotate_heper.append(Node3D.new())
		
		rotate_heper[i].name = "rotate" + str(i)
		rotate_heper[i].position = Vector3(0,0,i*.2)
		self.add_sibling.call_deferred(rotate_heper[i])
		
		# add triangles
		tri_array.append(MeshInstance3D.new())
		tri_array[i].mesh = PrismMesh.new()
		tri_array[i].name = "body"+str(i)
		tri_array[i].rotate_y(deg_to_rad(90))
		tri_array[i].rotate_x(deg_to_rad(90))
		tri_array[i].hide()
		
		rotate_heper[i].add_child.call_deferred(tri_array[i])
		
		area_array.append(Area3D.new())
		area_array[i].name = str(i)
		Segment_colission_array.append(CollisionShape3D.new())
		Segment_colission_array[i].shape = BoxShape3D.new()
		tri_array[i].add_child(area_array[i])
		area_array[i].add_child(Segment_colission_array[i])
	# get first ensarement data loaded 
	# rotate animations automatically also translations position because moving rotations on animations affects that too 
	#head_position_1 = head_position_marker.global_position


	# start up animations 
	animation_stuff.advance(randf())
	animation_stuff.speed_scale = randf_range(.5,1)
	animation_stuff.play("tree_idle")

func _process(delta: float) -> void:
	
	# get the bone lenght 
	if skeleton.ready: # this is not how you use this . 
		bone_length = calc_length()
	
	# before you do anything , start up animation briefly and to a cartesian position move because the keys are modified

	if (snake_to_player < 5) and not (snake_state == "player_seeking"):
		idle_animation = false

	
	if animation_stuff.is_playing() and not animation_repositioned:
		var head_position_2 = head_position_marker.global_position
		var model_move :Vector3 = head_position_1 - head_position_2
		animation_repositioned = true
	
	if tris_ready != true:
	# get all Node 3d's (triangles) into an array .
		var all_nodes :Array[Node] = get_node("..").get_children()


		rotate_heper
			

		tris_ready = true


	
	if (target.global_position - global_position).length() < 2 and not running_on_track and not snake_state == "idle_anim":
			if snake_state == "going_to_idle":
				var head_position = animation_transiton_point[0]
				head_position.y = 0
				make_ensnarement_curve(shift_rotate_points(animation_transiton_point,0,head_position),rotate_heper)
			else:
				make_ensnarement_curve(ensnarement_points,rotate_heper) # jsut make track one 
				emit_signal("ensnared")
			move_segments_to_path()
			running_on_track = true
			
	if running_on_track and follow_path_array[bone_numbers-1].progress_ratio > .99:
		halt = true
		if snake_state == "going_to_idle" and not idle_animation:
			
			# so there is allot that has to happen here , clear bones , play anim , offset the animation , 
			skeleton.clear_bones_global_pose_override()
			animation_stuff.play("tree_idle")
			idle_animation = true
			var head_position :Vector3 = animation_transiton_point[animation_transiton_point.size() - 1]
			var parent_node :Node3D = get_parent()
			old_position_snake_for_idle = parent_node.global_position # we use this later to go back into slither 
			parent_node.global_position = target.global_position - head_position
			# need to move actual follower head ( green triangle as well ) 
			global_position = target.global_position - head_position
			# remember these are the two lines that keep the snake all oriented during these movements . 
			parent_basis = parent_node.global_transform
			parent_rotation_deg = parent_node.rotation_degrees.y
			# move the curve as well 
			path.curve.clear_points()
			
	if (target.global_position - global_position).length() >3 and running_on_track : # this will be continue chase , relace with other condition 
		move_segments_back_normal()
		running_on_track =false
		halt = false
		



	
func _physics_process(delta: float) -> void:
	
	#wavy stuff
	time += delta
	wave_thing = (sin(time * 2)*snake_wavyness)
	# main decision tree logic ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

	if snake_state == "player_seeking":
		target = get_node("../../Player")
		
		
	if snake_state == "idle_anim":
		# wait for signal to leave idle animation 
		pass
	if snake_state == "patrol":
		# logic to pick new cub if close enough  .
		if ((target.global_position - global_position).length() < 3.0):
			pick_new_object = true
			# this is where random switching and uncontrolled may occur . 
			
		if pick_new_object: 
			# to make sure the next target is different 
			var next_target :MeshInstance3D = patrol_objects.pick_random()
			# if the next target is the same keep picking new target
			while next_target == target:
				next_target = patrol_objects.pick_random()
			target = next_target

			if target.is_in_group("chair"):
				print("found a chair")
				snake_state = "going_to_idle"
			pick_new_object = false
			
		
	# end decision process for snake ^^^^^^^^^^
	snake_to_player = (get_node("../../Player").global_position - global_position).length()

	# beginning of snakes decisions tree -------------------------------------------
	if idle_animation:
		snake_state = "idle_anim"
		
	else:
		
		if !_ensnared and (snake_to_player > 13.0) and (snake_state != "patrol") and (snake_state != "going_to_idle"):
			animation_stuff.stop()

			snake_state = "patrol"
			emit_signal("state_change")
			pick_new_object = true
			
		if (snake_to_player < 5) and not (snake_state == "player_seeking"):
			if snake_state == "idle_anim":
				var parent_node = get_parent()
				parent_node.global_position = old_position_snake_for_idle
				global_position = target.global_position 
				# remember these are the two lines that keep the snake all oriented during these movements . 
				parent_basis = parent_node.global_transform
				parent_rotation_deg = parent_node.rotation_degrees.y
			
			animation_stuff.stop()
			snake_state = "player_seeking"
			emit_signal("state_change")
		
	# end  of snakes decisions tree ------------------------------------------

	if snake_state == "idle_anim":
		pass # specifically so green triangle. 
	else:
		var current_location = global_transform.origin
		nav.target_position = target.global_position
		var next_location = nav.get_next_path_position()
		self.look_at(next_location)
		var new_velocity = (next_location - current_location).normalized() * SNAKE_SPEED
		
		# run new velocty through wave algorithme 
		if new_velocity.length() != 0:
			var perpendicular :Vector3 = Vector3(new_velocity.z/new_velocity.length(),new_velocity.y,-new_velocity.x/new_velocity.length())
			var waving_perpendicular :Vector3 = perpendicular.normalized() * wave_thing
			
			velocity = new_velocity + waving_perpendicular
		else:
			velocity = new_velocity

		move_and_slide()
	
	if not running_on_track and not halt and not(snake_state == "idle_anim") :
		follower(delta,rotate_heper)
	elif running_on_track and not halt:
		var segment_positions :Array[float]
		var segment_follow_path :Array[PathFollow3D]
		for i in bone_numbers:
			segment_follow_path.append(get_node("../Path3D/"+ "path" + str(i)))
		for i in bone_numbers:
			segment_follow_path[i].progress += 8 *delta
	
	elif snake_state == "idle_anim":
		pass # meaning your not ensnared yet and your not chasing or in patrol 
	elif snake_state == "player_seeking":
		pass # meaning your not ensnared yet and your not chasing or in patrol 
	else:
		_ensnared = true
		
	# move them bones 
	
	if snake_state == "idle_anim":
		#move_triangles_to_bones(rotate_heper)  # there is a problem here 
		pass
		
	else:

		override_skeleton(skeleton)



func follower(delta :float, body_segment_pimitived :Array[Node3D]):
	for i in range(body_segment_pimitived.size()):
		
		if i == 0: # meaning its the first piece  
			body_segment_pimitived[i].look_at(global_position)
			if ((global_position - body_segment_pimitived[i].global_position).length() > bone_length):
				body_segment_pimitived[i].global_position = body_segment_pimitived[i].global_position.lerp(global_position,delta * SPEED)
		else:
			body_segment_pimitived[i].look_at(body_segment_pimitived[i-1].global_position)
			if ((body_segment_pimitived[i-1].global_position - body_segment_pimitived[i].global_position).length() > bone_length):
				body_segment_pimitived[i].global_position = body_segment_pimitived[i].global_position.lerp(body_segment_pimitived[i-1].global_position,delta * SPEED)

func calc_length():
	bone_length = (skeleton.get_bone_global_rest(0).origin - skeleton.get_bone_global_rest(1).origin).length()
	return bone_length
	
func make_ensnarement_curve(ensnarement_data :PackedVector3Array, body_segment_pimitived :Array[Node3D]):
	# first make curve for all points where snake is at that moment 
 
	var points :Array[Vector3] 
	for i in range(body_segment_pimitived.size()):
		var parent_node :Node3D = get_parent()
		points.append((body_segment_pimitived[i].global_position - parent_node.global_position).rotated(Vector3(0,1,0),deg_to_rad(parent_rotation_deg * -1)))
	curve.clear_points()
	points.pop_front() # have no idea why I have to do this 
	for i in points.size():
		curve.add_point(points[(points.size()-1)-i]) # add the points in revers
	# add points to current curve , no rotation yet
	for i in ensnarement_data.size():
		var parent_thing :Node3D= get_node("..")
		var magic_numver :Vector3 = target.global_position - parent_thing.global_position

		curve.add_point((ensnarement_data[i]) + (magic_numver).rotated(Vector3(0,1,0),deg_to_rad(parent_rotation_deg * -1)) + Vector3(0,-.7,0)) # so there is a issue right here where the ensarement points are in the boonies rigth when you rotate

func move_segments_to_path():
	# need to make follow paths and put the meshes in each one 
	
	for i in bone_numbers:
		follow_path_array.append(PathFollow3D.new())
		follow_path_array[i].name = "path" + str(i)
		get_node("../Path3D").add_child(follow_path_array[i])
	
	# move each segment into array 
	for i in bone_numbers:
		get_node("..").remove_child(rotate_heper[i])
		rotate_heper[i].global_position = Vector3(0,0,0)
		get_node("../Path3D/"+ "path" + str(i) ).add_child(rotate_heper[i])
		get_node("../Path3D/"+ "path" + str(i)).set_progress(i*bone_length*1.1)

func move_segments_back_normal():
	var tri_pos :Array[Vector3] 
	for i in bone_numbers:
		tri_pos.append(rotate_heper[i].get_parent().position)
		get_node("../Path3D/"+ "path" + str(i) ).remove_child(rotate_heper[i])
		get_node("../Path3D").remove_child(follow_path_array[i])

	for i in bone_numbers:
		var reverse_num :int = -i + rotate_heper.size() -1
		# check is there is a parent 
		if rotate_heper[reverse_num].get_parent():
			rotate_heper[reverse_num].get_parent().remove_child(rotate_heper[reverse_num])
		rotate_heper[reverse_num].global_position = tri_pos[i]
		get_node("..").add_child(rotate_heper[reverse_num]) # problem is here . 
		

	 
func override_skeleton(skeleton_L :Skeleton3D): # need to changet this for two cases , one for ensnarement , one for chasing , right now only looks right for chasing !!!!!!!!!!!
	skeleton_L.rotation_degrees = Vector3(0,parent_rotation_deg * -1,0)  # i am not sure why i need to make this a -1 yet
	if running_on_track:
		for i in bone_numbers:
			var transform = tri_array[-i+bone_numbers-1].get_global_transform()
			transform.origin = transform.origin - parent_basis.origin
			
			skeleton_L.set_bone_global_pose_override(i, transform, 1, true)
			skeleton_L.set_bone_pose_rotation(i, tri_array[-i+bone_numbers-1].global_transform.basis.get_rotation_quaternion())
	else:
		for i in bone_numbers:
			var transform = tri_array[i].get_global_transform()
			transform.origin = transform.origin - parent_basis.origin
			
			skeleton_L.set_bone_global_pose_override(i, transform, 1, true)
			skeleton_L.set_bone_pose_rotation(i, tri_array[i].global_transform.basis.get_rotation_quaternion())

func give_snake_speed():
	SNAKE_SPEED = 3
	
func move_triangles_to_bones(tris :Array[Node3D]):
	for i in bone_numbers:
		
		tris[i].global_transform = skeleton.get_bone_global_pose((skeleton.get_bone_count()-1)-i) # go reverse
		tris[i].global_position = tris[i].global_position  # may need to comment this out 
	
func shift_rotate_points(points :PackedVector3Array, angle_deg :float, offset :Vector3):
	var new_points :PackedVector3Array
	for i in points.size():
		new_points.append(points[i].rotated(Vector3(0,1,0),deg_to_rad(angle_deg)) - offset)
	return new_points
	




func _on_skeleton_3d_ready() -> void:
	print("skeleton ready ")
