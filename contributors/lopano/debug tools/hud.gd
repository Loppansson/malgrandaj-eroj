extends CanvasLayer

@onready var player = $".."
@onready var player_pos = $PlayerPos
@onready var player_chunk_pos = $PlayerChunkPos
@onready var generator = $"../../LopanaGenerator"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):#
	if Input.is_action_just_pressed("toggle_chunk_border"):
		visible = not visible
	
	player_pos.text = str(
			"Player Pos: ",
			"x %.2f" % player.global_position.x, ", ",
			"y %.2f" % player.global_position.y, ", ",
			"z %.2f" % player.global_position.z
	)
	
	player_chunk_pos.text = str(
			"Player Pos: ",
			"x ", generator._active_chunk.x, ", ",
			"y ", generator._active_chunk.y, ", ",
			"z ", generator._active_chunk.z
	)
