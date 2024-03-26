@tool
extends Node3D

func _process(delta):
	
	
	$Timer.start(1)
	

func _on_timer_timeout():
	print("im out")
