extends Node

## Manages the game at the top level.

## If > 0, fps is limited to the set value.
@export var max_fps := 144 as int

func _ready():
	if max_fps > 0:
		Engine.max_fps = max_fps
