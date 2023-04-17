extends Node3D

## The Main manages the game at the top level. It for example loads the world.

## Limits the fps. No limit if <= 0.
@export var max_fps := 144 as int
@onready var world = preload("res://common/world/world.tscn")

func _ready():
	if max_fps > 0:
		Engine.max_fps = max_fps
	
	var instance = world.instantiate()
	add_child(instance)
