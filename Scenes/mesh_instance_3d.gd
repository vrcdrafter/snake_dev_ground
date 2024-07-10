@tool

extends CSGPolygon3D


var speed = -5	



func _process(delta: float) -> void:
	self.material_override.uv1_offset.x += delta * speed
