@tool

extends Node3D

@export var Radius :float = .2
@export var pitch :float = .01
@export var vertical_speed :float = 0.01
var speed :float = .5
var rad = 0
var oneshot :bool = true
var stop :bool  =false
@onready var curve :Curve3D = $Path3D.curve
func _ready() -> void:
	$Node3D/Marker3D.global_position = Vector3(Radius,0,0)
	
	curve.clear_points() # start out clearing 

func _process(delta: float) -> void:

	if not stop:
	
		$Node3D.rotate(Vector3(0,1,0),deg_to_rad(.1)*5)
		
		$Node3D.translate(Vector3(0,1.0 * delta * vertical_speed,0))
		var flat_angle :int = round($Node3D.get_rotation_degrees().y)
		
		if flat_angle % 10  == 0 and oneshot:
			print("found angle ", flat_angle)
			oneshot = false
			
			
			curve.add_point($Node3D/Marker3D.global_position)
			#print("found a degree at",get_rotation_degrees().y )
		if flat_angle % 10  != 0 and not oneshot:
			oneshot = true
	if Input.is_action_just_pressed("ui_accept"):
		if not stop:
			stop = true
		else :
			stop = false
	if Input.is_action_just_pressed("ui_cancel"):
		clear_reset()
func clear_reset():
	$Node3D/Marker3D.global_position = Vector3(Radius,0,0)
	
	curve.clear_points() # start out clearing 
