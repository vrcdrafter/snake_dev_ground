extends Node3D
 # just drop in the stuff 
var snake_node :Node3D 
var skeleton :Skeleton3D
var anim_player :AnimationPlayer
var one_shot :bool = true
func _ready() -> void:
	snake_node = find_child("sn*")
	var name = snake_node.name
	skeleton = snake_node.find_child("Skeleton3D",true,true)
	anim_player = snake_node.find_child("Anim*",true,true)
	
	
func _physics_process(delta: float) -> void:
	if one_shot:
		_make_curve_from_animation(anim_player,skeleton,false)
		one_shot = false
	
func _make_curve_from_animation(whole_lib :AnimationPlayer, snake_skeleton :Skeleton3D, debug :bool):
	var anim_library :AnimationLibrary = whole_lib.get_animation_library("")
	var anim_list :Array[StringName] = anim_library.get_animation_list()
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
			var save_result = ResourceSaver.save(curve_new,"res://transition_curves//" + curve_new.resource_name + ".tres")
	
