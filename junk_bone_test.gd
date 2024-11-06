@tool
extends Node3D

# Assuming 'skeleton' is your Skeleton node and 'animation_player' is your AnimationPlayer node
@onready var skeleton = $Skeleton3D
@onready var animation_player = get_node("../AnimationPlayer")
#@onready var object = $ObjectToSnap

func _process(delta):
	var bone_index = skeleton.find_bone("head")
	if bone_index != -1:
		var bone_transform = skeleton.get_bone_global_pose(bone_index)
		print(bone_transform)
		#object.global_transform = bone_transform
