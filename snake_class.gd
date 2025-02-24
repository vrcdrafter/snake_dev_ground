extends Node3D
class_name Snake



var path :Path3D 
var curve :Curve3D
var ensnarement_points :PackedVector3Array
var animation_transiton_points :PackedVector3Array
var all_transition_curves :Array[Curve3D]
var rotate_heper :Array[Node3D]
var tri_array :Array[MeshInstance3D]
var area_array :Array[Area3D]
var Segment_colission_array :Array[CollisionShape3D]
var follow_path_array :Array[PathFollow3D] 
var running_on_track :bool = false
var just_tarting_out :bool = true
var bone_length :float
var bone_numbers :int
var parent_basis :Transform3D
var parent_rotation_deg :float
var skeleton :Skeleton3D
var SPEED :float = 10
var target :Node3D

var debug = false

# navigation agent stuff , stuff to move the green triangle
var navigation_agent :NavigationAgent3D 
var movement_speed: float = 4.0
var movement_delta: float


func _init() -> void:


	
	print("ran this too")
	if debug:
		var snake_node :Node3D = find_child("sn*")
		var name = snake_node.name
		
		skeleton = snake_node.find_child("Skeleton3D",true,true)
		bone_numbers = skeleton.get_bone_count()
		bone_length = (skeleton.get_bone_global_rest(0).origin - skeleton.get_bone_global_rest(1).origin).length()
		
		var parent_node :Node3D = get_parent()
		parent_basis = parent_node.global_transform
		parent_rotation_deg = parent_node.rotation_degrees.y
	else:
		print("ran this in else")
		print_tree_pretty()
	

func follower(delta :float, body_segment_pimitived :Array[MeshInstance3D], bone_length :float):
	for i in range(body_segment_pimitived.size()):
		
		if i == 0: # meaning its the first piece, THE HEAD , note the head is already the green triangle and needs to follow nothing 
			pass
		else:
			body_segment_pimitived[i].look_at(body_segment_pimitived[i-1].global_position)
			if ((body_segment_pimitived[i-1].global_position - body_segment_pimitived[i].global_position).length() > bone_length):
				body_segment_pimitived[i].global_position = body_segment_pimitived[i].global_position.lerp(body_segment_pimitived[i-1].global_position,delta * SPEED)

func calc_length(skeleton :Skeleton3D):
	var bone_length
	bone_length = (skeleton.get_bone_global_rest(0).origin - skeleton.get_bone_global_rest(1).origin).length()
	return bone_length
	
func make_ensnarement_curve(ensnarement_data :PackedVector3Array, body_segment_pimitived :Array[Node3D]):
	# first make curve for all points where snake is at that moment 
 
	var parent_node :Node3D = get_parent()
	var parent_basis :Transform3D = parent_node.global_transform
	var parent_rotation_deg :float = parent_node.rotation_degrees.y

	var points :Array[Vector3] 
	for i in range(body_segment_pimitived.size()):

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


	
func move_triangles_to_bones(tris :Array[Node3D]):
	for i in bone_numbers:
		
		tris[i].global_transform = skeleton.get_bone_global_pose((skeleton.get_bone_count()-1)-i) # go reverse
		tris[i].global_position = tris[i].global_position  # may need to comment this out 
	
func shift_rotate_points(points :PackedVector3Array, angle_deg :float, offset :Vector3):
	var new_points :PackedVector3Array
	for i in points.size():
		new_points.append(points[i].rotated(Vector3(0,1,0),deg_to_rad(angle_deg)) - offset)
	return new_points
	

	
func _make_curve_from_animation(whole_lib :AnimationPlayer, snake_skeleton :Skeleton3D, debug :bool) -> Array[Curve3D]:
	var anim_library :AnimationLibrary = whole_lib.get_animation_library("")
	var anim_list :Array[StringName] = anim_library.get_animation_list()
	var transition_curves :Array[Curve3D]
	print(anim_list)
	if not debug:
		for i in anim_list.size():
			whole_lib.play(anim_list[i])
			
			whole_lib.advance(0)
			#whole_lib.seek(0.0,true,false)
			var curve_new :Curve3D = Curve3D.new()
			for g in snake_skeleton.get_bone_count():
				var bone_position :Vector3 = snake_skeleton.get_bone_global_pose(g).origin
				curve_new.add_point(bone_position)
			curve_new.resource_name = anim_list[i]
			transition_curves.append(curve_new)
			
	return transition_curves


func make_tris():
	
	var snake_node :Node3D = find_child("sn*")
	var name = snake_node.name
	
	skeleton = snake_node.find_child("Skeleton3D",true,true)
	bone_numbers = skeleton.get_bone_count()
	bone_length = (skeleton.get_bone_global_rest(0).origin - skeleton.get_bone_global_rest(1).origin).length()
	

	
	for i in bone_numbers:
		# add triangles
		tri_array.append(MeshInstance3D.new())
		tri_array[i].mesh = PrismMesh.new()
		
		tri_array[i].name = "body"+str(i)
		var new_mat :StandardMaterial3D = StandardMaterial3D.new()
		new_mat.albedo_color = Color(0,1,0,0)
		tri_array[0].set_surface_override_material(0,new_mat)


		tri_array[i].transform = skeleton.get_bone_global_pose(i)
		add_child.call_deferred(tri_array[i])

# navigation stuff 
func velocity_computed(safe_velocity: Vector3) -> void:
	tri_array[0].global_position = tri_array[0].global_position.move_toward(tri_array[0].global_position + safe_velocity, movement_delta)
	
func nav_startup_ready():
	
	navigation_agent = NavigationAgent3D.new()
	tri_array[0].add_child(navigation_agent)
	
	var _on_velocity_computed :Callable = Callable(self,"velocity_computed")
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	
func nav_startup_physics_process(delta,head_object :MeshInstance3D):
			# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return

	movement_delta = movement_speed * delta
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = head_object.global_position.direction_to(next_path_position) * movement_delta
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		velocity_computed(new_velocity)
	
func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)
