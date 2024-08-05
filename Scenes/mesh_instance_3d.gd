@tool

extends CSGPolygon3D


var speed = -3



func _process(delta: float) -> void:
	self.material_override.uv1_offset.x += speed * delta
	
