extends Node3D
 # just drop in the stuff 

func _ready() -> void:
	
	pass
	
func _make_curve_from_animation(whole_lib :AnimationPlayer, snake_skeleton :Skeleton3D) -> Curve3D:
	var anim_library :AnimationLibrary = whole_lib.get_animation_library("")
	whole_lib.play("TYPING")
	whole_lib.advance(0)
	#whole_lib.seek(0.0,true,false)
	var curve_new :Curve3D = Curve3D.new()
	for i in snake_skeleton.get_bone_count():
		var bone_position :Vector3 = snake_skeleton.get_bone_global_pose(i).origin
		curve_new.add_point(bone_position)
	curve_new.resource_name = "transition_curve"
	var save_result = ResourceSaver.save(curve_new,"res://" + curve_new.resource_name + ".tres")
	return curve_new
