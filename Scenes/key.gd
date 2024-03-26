@tool

extends Sprite3D

@onready var colission_shape :Area3D = $Area3D
signal found_a_key

func _ready():
	pass


func _process(delta):
	
	self.rotate(Vector3(0,1,0),0+delta*2)


func _on_area_3d_body_entered(body):
	print("body has endered ")
	found_a_key.emit()
	self.queue_free()
