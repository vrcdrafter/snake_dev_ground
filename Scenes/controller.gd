extends CharacterBody3D

const ACCEL = 10
const DEACCEL = 30

const SPEED = 5.0
const SPRINT_MULT = 2
const JUMP_VELOCITY = 4.5
var bone_length :float = 0
var bone_numbers :int = 0
@onready var body_piece_one :MeshInstance3D = get_node("../body1")
@onready var body_piece_two :MeshInstance3D = get_node("../body2")
@onready var nav : NavigationAgent3D = $NavigationAgent3D
@onready var target :Marker3D = get_node("../Marker3D")
var body_segment_pimitived :Array[MeshInstance3D] = []

@onready var skeleton :Skeleton3D = get_node("../snake_hefty/Armature/Skeleton3D")
var tris_ready :bool = false

func _ready() -> void:
		# get bone lenghts 
	bone_length = calc_length()
	print("bone length ", skeleton.get_bone_count())
	bone_numbers = skeleton.get_bone_count()
		# get # of bones 
		
	# build as manny triangles as you have bones . 
	var tri_array :Array[MeshInstance3D] 
	
	for i in bone_numbers:
		tri_array.append(MeshInstance3D.new())
		tri_array[i].mesh = PrismMesh.new()
		tri_array[i].name = "body"+str(i)
		tri_array[i].global_position = Vector3(0,0,i*.2)
		self.add_sibling.call_deferred(tri_array[i])


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
	
	follower(delta)
	
func _physics_process(delta: float) -> void:
	
	var current_location = global_transform.origin
	nav.target_position = target.global_position
	var next_location = nav.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
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
