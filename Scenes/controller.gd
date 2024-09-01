extends MeshInstance3D

const ACCEL = 10
const DEACCEL = 30

const SPEED = 5.0
const SPRINT_MULT = 2
const JUMP_VELOCITY = 4.5

@onready var body_piece_one :MeshInstance3D = get_node("../body1")
@onready var body_piece_two :MeshInstance3D = get_node("../body2")
var body_segment_pimitived :Array[MeshInstance3D] = []

func _ready() -> void:
	
	# get all body segments into an array . 
	
	var all_nodes :Array[Node] = get_node("..").get_children()
	for i in range(all_nodes.size()):
		if all_nodes[i].name.contains("body"):
			body_segment_pimitived.append(all_nodes[i])
		
	for i in range(body_segment_pimitived.size()):
		print(body_segment_pimitived[i].name, " ")


func _process(delta: float) -> void:
	
	
	# This just controls acceleration. Don't touch it.

	
	var input_dir :Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	position += Vector3(input_dir.x*delta*SPEED,0,input_dir.y*delta*SPEED)
	
	follower(delta)
	

func follower(delta):
	for i in range(body_segment_pimitived.size()):
		
		if i == 1: # meaning its the first piece  
			body_segment_pimitived[i].look_at(global_position)
			if ((global_position - body_segment_pimitived[i].global_position).length() > 1):
				body_segment_pimitived[i].global_position += (global_position - body_segment_pimitived[i].global_position) * delta * SPEED
			if ((global_position - body_segment_pimitived[i].global_position).length() < 1.1):
				body_segment_pimitived[i].global_position -= (global_position - body_segment_pimitived[i].global_position) * delta * SPEED
		else:
			body_segment_pimitived[i].look_at(body_segment_pimitived[i-1].global_position)
			if ((body_segment_pimitived[i-1].global_position - body_segment_pimitived[i].global_position).length() > 1):
				body_segment_pimitived[i].global_position += (body_segment_pimitived[i-1].global_position - body_segment_pimitived[i].global_position) * delta * SPEED
			if ((body_segment_pimitived[i-1].global_position - body_segment_pimitived[i].global_position).length() < 1.1):
				body_segment_pimitived[i].global_position -= (body_segment_pimitived[i-1].global_position - body_segment_pimitived[i].global_position) * delta * SPEED
