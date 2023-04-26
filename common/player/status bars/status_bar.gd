class_name StatusBar
extends ProgressBar

## Displayes a status from a StatusSystem node. This
## node must be a parent or specified by a path.
##
## [b]Dependencies:[/b] StatusSystem. Parent or Path.

@export var status_name: String
@export var status_system: StatusSystem


func _ready():
	if not status_system:
		assert(
			get_parent() is StatusSystem,
			"Status System is empty and parent is not a StatusSystem"
		)
		
		status_system = get_parent()
	
	assert(
		status_system is StatusSystem,
		"The provided node is not a StatusSystem"
	)
	
	min_value = status_system.get_status_min(status_name)
	max_value = status_system.get_status_max(status_name)


func _process(delta):
	value = status_system.get_status_current(status_name)







