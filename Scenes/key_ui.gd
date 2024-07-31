

extends Sprite2D

signal key_found

func _ready():
	modulate = Color(1,1,1,.1)
	var key1 = get_node("../key_1/Sprite3D")
	var key2 = get_node("../key_2/Sprite3D")
	var key3 = get_node("../key_3/Sprite3D")
	var callable = Callable(self,"dim_the_key")
	key1.connect("found_a_key", callable)
	key2.connect("found_a_key", callable)
	key3.connect("found_a_key", callable)
	

func dim_the_key(key_name):
	
	
	match  key_name:
		"key_1":
			if name == "key1":
				modulate = Color(1,1,1,1)
				key_found.emit()
		"key_2":
			if name == "key2":
				modulate = Color(1,1,1,1)
				key_found.emit()
		"key_3":
			if name == "key3":
				modulate = Color(1,1,1,1)
				key_found.emit()
	
	
