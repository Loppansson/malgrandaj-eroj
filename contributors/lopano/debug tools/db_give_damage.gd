extends Node

@onready var status_system = $"../StatusSystem"

func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		
