@tool

extends Node3D

var Radius :float = 1.0
var speed :float = .1
var rad = 0

func _ready() -> void:
	$Node3D/Marker3D.global_position = Vector3(Radius,0,0)
	


func _process(delta: float) -> void:
	
	
	rad += delta + speed
	
	$Node3D.rotate(Vector3(0,1,0),deg_to_rad(.1))
	
	var flat_angle :int = round($Node3D.get_rotation_degrees().y)
	
	if flat_angle % 10  == 0:
		print("found angle ", flat_angle)
		#print("found a degree at",get_rotation_degrees().y )
		

	
