

extends Sprite3D
@onready var parent_node :Node3D = get_node("..")
@onready var colission_shape :Area3D = $Area3D
signal found_a_key

func _ready():
	
	print(parent_node.name)

func _process(delta):

	self.rotate(Vector3(0,1,0),0+delta*2)



func _on_area_3d_body_entered(body):
	print("body has endered ", parent_node.name)
	found_a_key.emit(parent_node.name)
	self.queue_free()
