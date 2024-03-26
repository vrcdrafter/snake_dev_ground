

extends Sprite2D


func _ready():
	var key = get_node("../key/Sprite3D")
	modulate = Color(1,1,1,.1)
	var callable = Callable(self,"dim_the_key")
	key.connect("found_a_key", callable)


func dim_the_key():
	print("dim the key ")
	modulate = Color(1,1,1,1)
