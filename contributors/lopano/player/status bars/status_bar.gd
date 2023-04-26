class_name StatusBar
extends ProgressBar

#=---------------------------------------------------=#
#                     Status Bar                      #
#=---------------------------------------------------=#
# Dependencies: StatusSystem. Parent or Path.         #
#=---------------------------------------------------=#
# Displayes a status from a StatusSystem node. This   #
# node must be a parent or specified by a path.       #
#=---------------------------------------------------=#

@export var status_name: String
@export var status_system: Node


func _ready():
	if not status_system:
		assert(
			get_parent().has_method("get_status_index"),
			"Status System is empty and parent is not a StatusSystem"
		)
	
	assert(
		status_system.has_method("get_status_index"),
		"The provided node is not a StatusSystem"
	)
	
	status_system.get_status_value(status_name)
	
