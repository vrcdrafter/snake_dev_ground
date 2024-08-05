extends Area3D


var player_entered :bool = false
var strength :float = 6

@onready var Player_handle :CharacterBody3D = get_node("../../Player")



func _process(delta: float) -> void:
	
	var pointing :Vector3= $Marker3D.global_position - $Marker3D2.global_position
	pointing = pointing.normalized()
	
	if player_entered:
		print("trying to move player")
		Player_handle.global_position += pointing * strength * delta


func _on_body_entered(body: Node3D) -> void:
	
	if body.is_in_group("player"):
		player_entered = true
		print("player is in accelerator")


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_entered = false
		print("player is out of acceleratro")
