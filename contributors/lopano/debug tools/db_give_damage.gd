extends Node

@onready var status_system = $"../StatusSystem" as StatusSystem


func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		status_system.add_status_current("health", -1)


func _on_status_system_status_at_min(status):
	if status == "health":
		print("You Died!!")
