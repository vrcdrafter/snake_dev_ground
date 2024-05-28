extends Button


func _ready() -> void:
	
	var player_handle = get_node("../Player")
	var remove_mouse_callable = Callable(self,"_on_player_remove_mouse")
	player_handle.connect("remove_mouse",remove_mouse_callable)

func _on_player_remove_mouse():
	print("try to remove button ")
	self.hide()
