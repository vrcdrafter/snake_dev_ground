extends Node3D
const SPEED = 5.0

func _physics_process(delta: float) -> void:
	

	

	
	var input_dir :Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	$MeshInstance3D.global_position += Vector3(input_dir.x*delta*SPEED,input_dir.y*delta*SPEED,0)
	$MeshInstance3D.look_at(Vector3(input_dir.y,0,input_dir.y))
	
	# need to get positin at radius  


	$MeshInstance3D2.look_at($MeshInstance3D.global_position)
	print(($MeshInstance3D.global_position - $MeshInstance3D2.global_position).length())
	if ($MeshInstance3D.global_position - $MeshInstance3D2.global_position).length() > 1:
		
		$MeshInstance3D2.global_position = $MeshInstance3D2.global_position.lerp($MeshInstance3D.global_position,delta *4 )
	

	
	$MeshInstance3D3.look_at($MeshInstance3D2.global_position)
	if ($MeshInstance3D2.global_position - $MeshInstance3D3.global_position).length() > 1:
		$MeshInstance3D3.global_position = $MeshInstance3D3.global_position.lerp($MeshInstance3D2.global_position,delta *4)
