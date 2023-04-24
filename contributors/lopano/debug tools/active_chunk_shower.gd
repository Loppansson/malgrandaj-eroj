extends MeshInstance3D

@onready var generator = $".."

func _process(delta):
	position = (Vector3(generator._active_chunk) + Vector3.ONE / 2) * generator.chunk_size
	
	if Input.is_action_just_pressed("toggle_chunk_border"):
		visible = not visible
