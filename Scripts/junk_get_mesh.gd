@tool
extends MeshInstance3D



func _ready() -> void:
	
	print("verticies ", self.mesh.get_faces().size())
