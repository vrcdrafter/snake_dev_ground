@tool
extends PathFollow3D

#Even though you can add this node with just "add child" to work properly you should use "instantiate child scene" (otherwise signals will be missing)
class_name SkeletonPathFollow3D

#If false bones are only rotated, so they may not match with path exactly
@export var exact : bool = true

#Data to hold skeleton and calculated bone length in one place
class SkeletonData:
	var skeleton : Skeleton3D
	var bone_length : float
	
	#Calculate bone length assuming all bones are of the same length (as first one)
	func calc_length():
		bone_length = (skeleton.get_bone_global_rest(0).origin - skeleton.get_bone_global_rest(1).origin).length()

var path_node : Path3D
var skeletons : Array[SkeletonData] = []

func _ready():
	if(get_parent() is Path3D):
		path_node = get_parent()
	set_process(!skeletons.is_empty())

func _process(_delta : float):
	if(!path_node):
		return
	for data in skeletons:
		if(data.skeleton.is_visible_in_tree()):
			if(exact):
				
				_adjust_bone_exact(0, data, 3.0)
			else:
				_adjust_bone(0, data.skeleton)

func _on_child_entered_tree(node : Node):
	var skeletonsInNode = node.find_children("*", "Skeleton3D")
	
	for sk in skeletonsInNode:
		var skelData : SkeletonData = SkeletonData.new()
		skelData.skeleton = sk
		skelData.calc_length()
		
		skeletons.append(skelData)
		
	set_process(!skeletons.is_empty())

func _on_child_exiting_tree(node : Node):
	var skeletonsInNode = node.find_children("*", "Skeleton3D")
	for sk in skeletonsInNode:
		for i in skeletons.size():
			if(skeletons[i].skeleton == sk):
				skeletons.remove_at(i)
				break
	set_process(!skeletons.is_empty())

func _adjust_bone_exact(bone_id : int, data : SkeletonData, currentOffset : float):
	var parentBoneId : int = data.skeleton.get_bone_parent(bone_id)
	var boneGlobalTransform : Transform3D = Transform3D.IDENTITY
	var pathGlobalTransform : Transform3D = Transform3D.IDENTITY
	var targetTransform : Transform3D = Transform3D.IDENTITY
	var parentBoneGlobalTransform : Transform3D = data.skeleton.global_transform
	
	if(parentBoneId != -1):
		boneGlobalTransform = data.skeleton.global_transform * data.skeleton.get_bone_global_pose(bone_id)
		parentBoneGlobalTransform = parentBoneGlobalTransform * data.skeleton.get_bone_global_pose(parentBoneId)
		
		currentOffset -= data.bone_length * boneGlobalTransform.basis.get_scale().x

		
		if(currentOffset < 0.0):
			currentOffset = 0.0
	else:
		boneGlobalTransform = data.skeleton.global_transform * data.skeleton.get_bone_global_rest(bone_id)
		currentOffset = path_node.curve.get_closest_offset(path_node.to_local(boneGlobalTransform.origin))
		
	pathGlobalTransform = path_node.global_transform * path_node.curve.sample_baked_with_rotation(currentOffset, cubic_interp, tilt_enabled)
	targetTransform = pathGlobalTransform
	targetTransform.basis.x = pathGlobalTransform.basis.y
	targetTransform.basis.y = pathGlobalTransform.basis.z
	targetTransform.basis.z = pathGlobalTransform.basis.x
	targetTransform = parentBoneGlobalTransform.affine_inverse() * targetTransform
	
	data.skeleton.set_bone_pose_rotation(bone_id, targetTransform.basis.get_rotation_quaternion())
	data.skeleton.set_bone_pose_position(bone_id, targetTransform.origin)
	
	#Adjust children bones
	var children : PackedInt32Array = data.skeleton.get_bone_children(bone_id)
	for child in children:
		_adjust_bone_exact(child, data, currentOffset)

func _adjust_bone(bone_id : int, skeleton : Skeleton3D):
	#Adjust current bone
	var boneGlobalPosition : Vector3 = skeleton.global_transform * skeleton.get_bone_global_pose(bone_id).origin
	var pathGlobalBasis : Basis = path_node.global_basis * path_node.curve.sample_baked_with_rotation(path_node.curve.get_closest_offset(path_node.to_local(boneGlobalPosition)), cubic_interp, tilt_enabled).basis
	var targetBasis : Basis = pathGlobalBasis
	#Fix basis
	targetBasis.x = pathGlobalBasis.y
	targetBasis.y = pathGlobalBasis.z
	targetBasis.z = pathGlobalBasis.x
	var parentBoneId : int = skeleton.get_bone_parent(bone_id)
	if(parentBoneId != -1):
		targetBasis = (skeleton.global_basis * skeleton.get_bone_global_pose(parentBoneId).basis).inverse() * targetBasis
	else:
		targetBasis = skeleton.global_basis.inverse() * targetBasis
	skeleton.set_bone_pose_rotation(bone_id, targetBasis.get_rotation_quaternion())
	skeleton.set_bone_pose_position(bone_id, skeleton.get_bone_rest(bone_id).origin)
	
	#Adjust children bones
	var children : PackedInt32Array = skeleton.get_bone_children(bone_id)
	for child in children:
		_adjust_bone(child, skeleton)
