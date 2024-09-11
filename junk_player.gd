extends Marker3D
const SPEED = .1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var input_dir :Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	self.global_position += Vector3(input_dir.x*delta*SPEED,0,input_dir.y*delta*SPEED)
