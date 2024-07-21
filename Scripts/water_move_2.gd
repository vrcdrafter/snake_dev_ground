@tool
extends MeshInstance3D


var time = 0 

func _process(delta: float) -> void:
	
	time += delta
	
	self.position.y = (sin(time)*.01) -6.3
	
	self.material_override.uv1_offset.x = (sin(time)*.1)
	self.material_override.uv1_offset.y = (cos(time)*.1)
