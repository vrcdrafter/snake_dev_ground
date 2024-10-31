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
var body_segment_pimitived :Array[Node3D] = []
@onready var donut = get_node("../donut")
@onready var skeleton :Skeleton3D = get_node("../snake_hefty/Armature/Skeleton3D")
var tris_ready :bool = false
# curve stuff
var path :Path3D 
var curve :Curve3D
var ensnarement_points :PackedVector3Array
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

signal state_change

# snake wave stuff
var time :float = 0
var snake_wavyness :float = 1
var wave_thing :float = 0

var parent_basis :Transform3D

func _ready() -> void:
	# get all the partrol objects
	var parent_node :Node3D = get_parent()
	parent_basis = parent_node.global_transform
	
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
	for i in range(ensnarement_points.size()):
		ensnarement_points[i] = path.to_local(ensnarement_points[i])
		# get bone lenghts 
	bone_length = calc_length()

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

func _process(delta: float) -> void:
	
	if tris_ready != true:
	# get all Node 3d's (triangles) into an array .
		var all_nodes :Array[Node] = get_node("..").get_children()

		for i in range(all_nodes.size()):
			if all_nodes[i].name.contains("rotate"):
				body_segment_pimitived.append(all_nodes[i])

			

		tris_ready = true

	# This just controls acceleration. Don't touch it.

	
	var target_postion = target.global_position
	var head_positopnm = global_position
	
	if (target.global_position - global_position).length() < 2 and not running_on_track :

			make_ensnarement_curve() # jsut make track one 
			move_segments_to_path()
			running_on_track = true
			emit_signal("ensnared")
	if running_on_track and follow_path_array[bone_numbers-1].progress_ratio > .99:
		halt = true
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
		
	if snake_state == "patrol":
		# logic to pick new cub if close enough  .
		if ((target.global_position - global_position).length() < 3.0):
			pick_new_object = true
			# this is where random switching and uncontrolled may occur . 
			
		if pick_new_object: 
			# to make sure the next target is different 
			var next_target = patrol_objects.pick_random()
			# if the next target is the same keep picking new target
			while next_target == target:
				next_target = patrol_objects.pick_random()
			target = next_target
			pick_new_object = false
	# end decision process for snake ^^^^^^^^^^
	var snake_to_player :float = (get_node("../../Player").global_position - global_position).length()


	if !_ensnared and (snake_to_player > 16.0) and not (snake_state == "patrol"):
		
		snake_state = "patrol"
		emit_signal("state_change")
		pick_new_object = true
	
	if (snake_to_player < 5) and not (snake_state == "player_seeking"):
		
		snake_state = "player_seeking"
		emit_signal("state_change")
	if running_on_track:
		var all_point :PackedVector3Array = curve.get_baked_points()
		#self.global_position = all_point[all_point.size()-1]
	
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
	
	if not running_on_track and not halt:

		follower(delta)
	elif running_on_track and not halt:
		var segment_positions :Array[float]
		var segment_follow_path :Array[PathFollow3D]
		for i in bone_numbers:
			segment_follow_path.append(get_node("../Path3D/"+ "path" + str(i)))
		for i in bone_numbers:
			segment_follow_path[i].progress += 8 *delta
	else:
		_ensnared = true
		pass # meaning dont move at all 
		
	# move them bones 
	
		
	override_skeleton()


func follower(delta):
	for i in range(body_segment_pimitived.size()):
		
		if i == 0: # meaning its the first piece  
			body_segment_pimitived[i].look_at(global_position)
			
			if ((global_position - body_segment_pimitived[i].global_position).length() > bone_length):
				#body_segment_pimitived[i].global_position += (global_position - body_segment_pimitived[i].global_position) * delta * SPEED
				body_segment_pimitived[i].global_position = body_segment_pimitived[i].global_position.lerp(global_position,delta * SPEED)

		else:
			body_segment_pimitived[i].look_at(body_segment_pimitived[i-1].global_position)
			if ((body_segment_pimitived[i-1].global_position - body_segment_pimitived[i].global_position).length() > bone_length):
				#body_segment_pimitived[i].global_position += (body_segment_pimitived[i-1].global_position - body_segment_pimitived[i].global_position) * delta * SPEED
				body_segment_pimitived[i].global_position = body_segment_pimitived[i].global_position.lerp(body_segment_pimitived[i-1].global_position,delta * SPEED)

func calc_length():
	bone_length = (skeleton.get_bone_global_rest(0).origin - skeleton.get_bone_global_rest(1).origin).length()
	return bone_length
	
func make_ensnarement_curve():
	# first make curve for all points where snake is at that moment 
	var points :Array[Vector3] 
	for i in range(body_segment_pimitived.size()):
		points.append(body_segment_pimitived[i].global_position - parent_basis.origin)
	curve.clear_points()
	points.pop_front() # have no idea why I have to do this 
	for i in points.size():
		curve.add_point(points[(points.size()-1)-i]) # add the points in reverse
	# hard part , want to force a concatenation 
	# get head direction 
	var head_direction :Vector3 = self.transform.basis.z.normalized()
	var point_ahead =  ((head_direction * -2 ) + global_position)# putting it 2 meters away, assuming target is 2 meters away 
	#curve.add_point(point_ahead)
	# add points to current curve , no rotation yet
	for i in ensnarement_points.size():
		curve.add_point(ensnarement_points[i] + point_ahead)

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
		#zero it all out 
		
		get_node("../Path3D/"+ "path" + str(i)).set_progress(i*bone_length*1.1)

func move_segments_back_normal():
	for i in bone_numbers:
		var tri_pos :Vector3 = rotate_heper[i].global_position - parent_basis.origin
		get_node("../Path3D/"+ "path" + str(i) ).remove_child(rotate_heper[i])
		get_node("../Path3D").remove_child(follow_path_array[i])
		rotate_heper[i].global_position = tri_pos
		get_node("..").add_child(rotate_heper[i])
		
func take_measurment_setup(delta): # takes a measurement of all the tri meshs
	var main_follow_path :PathFollow3D = get_node("../Path3D/PathFollow3D")
	var bone_positions :Array[float]
	var tiney_measurment_box :Area3D = get_node("../Path3D/PathFollow3D/Area3D")
	var colission_tiney_box :CollisionShape3D = get_node("../Path3D/PathFollow3D/Area3D/CollisionShape3D")
	
func override_skeleton():
	for i in bone_numbers:
		var transform = tri_array[-i+bone_numbers-1].get_global_transform()
		transform.origin = transform.origin - parent_basis.origin
		skeleton.set_bone_global_pose_override(i, transform, 1, true)
		skeleton.set_bone_pose_rotation(i, tri_array[-i+bone_numbers-1].global_transform.basis.get_rotation_quaternion())
		
func give_snake_speed():
	SNAKE_SPEED = 3
