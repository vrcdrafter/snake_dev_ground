extends Button


func _on_player_remove_mouse():
	self.queue_free()
