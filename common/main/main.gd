extends Node3D

@onready var world = preload("res://common/world/world.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var instance = world.instantiate()
	add_child(instance)
