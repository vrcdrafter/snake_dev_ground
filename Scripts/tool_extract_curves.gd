extends Node3D
 # just drop in the stuff 
@onready var anim_player :AnimationPlayer = get_node("snake_hefty_animated/AnimationPlayer")
@onready var skeleton_snake :Skeleton3D = get_node("snake_hefty_animated/Armature_001/Skeleton3D")
var one_shot :bool = true
func _ready() -> void:
	
	$snake_hefty_animated/AnimationPlayer.play("typing_2_001")
	
func _physics_process(delta: float) -> void:
	if one_shot:
		_make_curve_from_animation(anim_player,skeleton_snake)
		one_shot = false
	
func _make_curve_from_animation(whole_lib :AnimationPlayer, snake_skeleton :Skeleton3D) -> Curve3D:
	var anim_library :AnimationLibrary = whole_lib.get_animation_library("")
	whole_lib.play("typing_2_001")
	whole_lib.advance(0)
	#whole_lib.seek(0.0,true,false)
	var curve_new :Curve3D = Curve3D.new()
	for i in snake_skeleton.get_bone_count():
		var bone_position :Vector3 = snake_skeleton.get_bone_global_pose(i).origin
		curve_new.add_point(bone_position)
	curve_new.resource_name = "transition_curve"
	var save_result = ResourceSaver.save(curve_new,"res://" + curve_new.resource_name + ".tres")
	return curve_new
