extends CharacterBody3D

const ACCEL = 10
const DEACCEL = 30
const SNAKE_SPEED = 4
const SPEED = 10
const SPRINT_MULT = 2
const JUMP_VELOCITY = 4.5
var bone_length :float = 0
var bone_numbers :int = 0
@onready var body_piece_one :MeshInstance3D = get_node("../body1")
@onready var body_piece_two :MeshInstance3D = get_node("../body2")
@onready var nav : NavigationAgent3D = $NavigationAgent3D
@onready var target :Marker3D = get_node("../../Marker3D")
var body_segment_pimitived :Array[MeshInstance3D] = []
@onready var donut = get_node("../donut")
@onready var skeleton :Skeleton3D = get_node("../snake_hefty/Armature/Skeleton3D")
var tris_ready :bool = false
# curve stuff
var path :Path3D 
var curve :Curve3D
var ensnarement_points :PackedVector3Array
var tri_array :Array[MeshInstance3D]
var area_array :Array[Area3D]
var Segment_colission_array :Array[CollisionShape3D]
var follow_path_array :Array[PathFollow3D] 
var running_on_track :bool = false
var just_tarting_out :bool = true

@onready var measure_path_global = get_node("../Path3D/PathFollow3D")

#Class for easier storage and update of curve points
class CurvePoint:
	var point : Vector3
	var point_in : Vector3
	var point_out : Vector3
	
	func trans(transf : Transform3D):
		point_in = point + point_in
		point_out = point + point_out
		point = transf * point
		point_in = transf * point_in
		point_out = transf * point_out
	
	func loc(node : Node3D):
		point = node.to_local(point)
		point_in = node.to_local(point_in) - point
		point_out = node.to_local(point_out) - point

func _ready() -> void:
	
	path= get_node("../Path3D")
	curve = path.curve
	ensnarement_points = curve.get_baked_points()
	for i in range(ensnarement_points.size()):
		ensnarement_points[i] = path.to_local(ensnarement_points[i])
		# get bone lenghts 
	bone_length = calc_length()
	print("bone length ", skeleton.get_bone_count())
	bone_numbers = skeleton.get_bone_count()
		# get # of bones 
		
	# build as manny triangles as you have bones . 
	
	for i in bone_numbers:
		tri_array.append(MeshInstance3D.new())
		tri_array[i].mesh = PrismMesh.new()
		tri_array[i].name = "body"+str(i)
		tri_array[i].global_position = Vector3(0,0,i*.2)
		self.add_sibling.call_deferred(tri_array[i])
		
		area_array.append(Area3D.new())
		area_array[i].name = str(i)
		Segment_colission_array.append(CollisionShape3D.new())
		Segment_colission_array[i].shape = BoxShape3D.new()
		tri_array[i].add_child(area_array[i])
		area_array[i].add_child(Segment_colission_array[i])
	# get first ensarement data loaded 

func _process(delta: float) -> void:
	
	if tris_ready != true:
	# get all body segments into an array .
		var all_nodes :Array[Node] = get_node("..").get_children()
		for i in range(all_nodes.size()):
			if all_nodes[i].name.contains("body"):
				body_segment_pimitived.append(all_nodes[i])
			
		for i in range(body_segment_pimitived.size()):
			print(body_segment_pimitived[i].name, " ")
		tris_ready = true

	# This just controls acceleration. Don't touch it.

	
	var input_dir :Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	target.global_position += Vector3(input_dir.x*delta*SPEED,0,input_dir.y*delta*SPEED)
	
	if Input.is_action_just_pressed("ui_accept"):
		if !running_on_track:
			make_ensnarement_curve() # jsut make track one 
			move_segments_to_path()
			running_on_track = true
		else:
			move_segments_back_normal()
			running_on_track =false

	if not running_on_track:
			follower(delta)
	else:
		var segment_positions :Array[float]
		var segment_follow_path :Array[PathFollow3D]
		for i in bone_numbers:
			segment_follow_path.append(get_node("../Path3D/"+ "path" + str(i)))
		for i in bone_numbers:
			segment_follow_path[i].progress += 2 *delta
		# put test dont
	
func _physics_process(delta: float) -> void:
	
	if running_on_track:
		var all_point :PackedVector3Array = curve.get_baked_points()
		self.global_position = all_point[all_point.size()-1]
	
	else:
		var current_location = global_transform.origin
		nav.target_position = target.global_position
		var next_location = nav.get_next_path_position()
		self.look_at(next_location)
		var new_velocity = (next_location - current_location).normalized() * SNAKE_SPEED
		
		velocity = new_velocity
		move_and_slide()
	


func follower(delta):
	for i in range(body_segment_pimitived.size()):
		
		if i == 1: # meaning its the first piece  
			body_segment_pimitived[i].look_at(global_position)
			if ((global_position - body_segment_pimitived[i].global_position).length() > bone_length):
				body_segment_pimitived[i].global_position += (global_position - body_segment_pimitived[i].global_position) * delta * SPEED
			if ((global_position - body_segment_pimitived[i].global_position).length() < bone_length + .1):
				body_segment_pimitived[i].global_position -= (global_position - body_segment_pimitived[i].global_position) * delta * SPEED
		else:
			body_segment_pimitived[i].look_at(body_segment_pimitived[i-1].global_position)
			if ((body_segment_pimitived[i-1].global_position - body_segment_pimitived[i].global_position).length() > bone_length):
				body_segment_pimitived[i].global_position += (body_segment_pimitived[i-1].global_position - body_segment_pimitived[i].global_position) * delta * SPEED
			if ((body_segment_pimitived[i-1].global_position - body_segment_pimitived[i].global_position).length() < bone_length + .1):
				body_segment_pimitived[i].global_position -= (body_segment_pimitived[i-1].global_position - body_segment_pimitived[i].global_position) * delta * SPEED

func calc_length():
	bone_length = (skeleton.get_bone_global_rest(0).origin - skeleton.get_bone_global_rest(1).origin).length()
	return bone_length
	
func make_ensnarement_curve():
	# first make curve for all points where snake is at that moment 
	var points :Array[Vector3] 
	for i in range(body_segment_pimitived.size()):
		points.append(body_segment_pimitived[i].global_position)
	curve.clear_points()
	points.pop_front() # have no idea why I have to do this 
	for i in points.size():
		curve.add_point(points[(points.size()-1)-i]) # add the points in reverse
	# hard part , want to force a concatenation 
	# get head direction 
	var head_direction :Vector3 = self.transform.basis.z.normalized()
	var point_ahead =  (head_direction * -3 ) + global_position# putting it 2 meters away, assuming target is 2 meters away 
	curve.add_point(point_ahead)
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
		get_node("..").remove_child(tri_array[i])
		tri_array[i].global_position = Vector3(0,0,0)
		get_node("../Path3D/"+ "path" + str(i) ).add_child(tri_array[i])
		#zero it all out 
		
		get_node("../Path3D/"+ "path" + str(i)).set_progress(i*bone_length*1.1)

func move_segments_back_normal():
	for i in bone_numbers:
		var tri_pos :Vector3 = tri_array[i].global_position
		get_node("../Path3D/"+ "path" + str(i) ).remove_child(tri_array[i])
		get_node("../Path3D").remove_child(follow_path_array[i])
		tri_array[i].global_position = tri_pos
		get_node("..").add_child(tri_array[i])
		
func take_measurment_setup(delta): # takes a measurement of all the tri meshs
	var main_follow_path :PathFollow3D = get_node("../Path3D/PathFollow3D")
	var bone_positions :Array[float]
	var tiney_measurment_box :Area3D = get_node("../Path3D/PathFollow3D/Area3D")
	var colission_tiney_box :CollisionShape3D = get_node("../Path3D/PathFollow3D/Area3D/CollisionShape3D")