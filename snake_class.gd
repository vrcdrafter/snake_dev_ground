@icon("res://snake_icon.svg")
extends Node3D
class_name Snake


var ensarement_path :Path3D

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
	
func make_ensnarement_curve(ensnarement_data :PackedVector3Array, body_segment_pimitived :Array[MeshInstance3D],target):
	# first make curve for all points where snake is at that moment 
 	
	var node :Node3D = self
	var transform_global :Transform3D = self.global_transform
	var rotation_global_y :float = self.rotation_degrees.y
	var position_global :Vector3 = self.global_position
	var rotation_global :Vector3 = self.rotation
	var points :Array[Vector3] 
	for i in range(body_segment_pimitived.size()):

		points.append((body_segment_pimitived[i].global_position - position_global).rotated(Vector3(0,1,0),deg_to_rad(rotation_global_y * -1)))
	curve.clear_points()
	points.pop_front() # have no idea why I have to do this 
	for i in points.size():
		curve.add_point(points[(points.size()-1)-i]) # add the points in revers
	# add points to current curve , no rotation yet
	for i in ensnarement_data.size():
		var parent_thing :Node3D= get_node("..")
		var magic_numver :Vector3 = target.global_position - position_global

		curve.add_point((ensnarement_data[i]) + (magic_numver).rotated(Vector3(0,1,0),deg_to_rad(rotation_global_y * -1)) + Vector3(0,0,0)) 
	ensarement_path.curve = curve

func move_segments_to_path():
	# need to make follow paths and put the meshes in each one 
	
	for i in bone_numbers:
		follow_path_array.append(PathFollow3D.new())
		follow_path_array[i].name = "path" + str(i)
		ensarement_path.add_child(follow_path_array[i])

	# move each segment into array 
	for i in bone_numbers:

		remove_child(tri_array[i])
		follow_path_array[i].add_child(tri_array[i])
		tri_array[i].transform.origin = Vector3(0, 0, 0)
		tri_array[i].rotation_degrees = Vector3(0, 0, 0)
		
		#follow_path_array[i].set_progress(i*bone_length*1.1) # may need this backwards, MICROSOFT AI < PLEASE HELP HERE > 
		follow_path_array[i].set_progress((bone_numbers - 1 - i) * bone_length * 1.1)
func move_segments_back_normal():
	var tri_pos :Array[Transform3D] 
	for i in bone_numbers:
		tri_pos.append(tri_array[i].global_transform)
		follow_path_array[i].remove_child(tri_array[i])
		ensarement_path.remove_child(follow_path_array[i])

	for i in bone_numbers:
		add_child(tri_array[i])
		tri_array[i].global_transform = tri_pos[i]
		
		

	 
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
	tri_array[0].look_at(tri_array[0].global_position + safe_velocity)
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
	
	
func initialize_ensnarment_curve():
	curve = Curve3D.new() # this is the one that will get remade again and again with each ensnarement
	var curve_resource :Curve3D = load("res://Resources/perfect_ensnarement_2.tres")
	var curve :Curve3D = Curve3D.new() #may not use this
	ensnarement_points = curve_resource.get_baked_points()
	
	# make a path too 
	ensarement_path = Path3D.new()
	add_child(ensarement_path)
	
func move_segments_along_path(delta) -> bool:
	for i in bone_numbers:
		follow_path_array[i].progress += 8 *delta
	if follow_path_array[0].progress_ratio > .99:
		return true
	else:
		return false
