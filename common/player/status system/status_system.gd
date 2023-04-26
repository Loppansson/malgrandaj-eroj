class_name StatusSystem
extends Node

## Stores variables useful when giving stuff status elements,
## like health, hunger, and thirst.
##
## All arrays must be the same size.


signal status_at_min(status: String)
signal status_updated(status: String)

## The statuses that are in use by name.
@export var statuses: Array[String]
## The min value the status can be.
@export var status_min: Array[int]
## The max value the status can be.
@export var status_max: Array[int]
## Status_current is set to status_default at ready().
@export var status_default: Array[int]
## The current state of the status.
@export var status_current: Array[int]
var _number_statuses: int


func _ready():
	_number_statuses = len(statuses)
	
	assert(
		(
			len(status_min) == _number_statuses
			and len(status_max) == _number_statuses
			and len(status_default) == _number_statuses
			and len(status_current) == _number_statuses
		),
		"Status arrays are of the different sizes."
	)
	
	# Set current status to default status.
	for i in range(_number_statuses):
		status_current[i] = status_default[i]
	
	connect(
			"status_updated",
			Callable(
					self,
					"_on_status_updated"
			)
	)

## Gets the index of a status by name in statuses.
func get_status_index(name: String) -> int:
	var _found_status_index = statuses.find(name)
	
	assert(
		_found_status_index != -1,
		str(
			'No status with the name "', 
			name, 
			'" was found.'
		)
	)
	
	return _found_status_index


## Gets status_min associated with the name given.
func get_status_min(name: String) -> int:
	return status_min[get_status_index(name)]


## Gets status_max associated with the name given.
func get_status_max(name: String) -> int:
	return status_max[get_status_index(name)]


## Gets status_default associated with the name given.
func get_status_default(name: String) -> int:
	return status_default[get_status_index(name)]


## Gets status_current associated with the name given.
func get_status_current(name: String) -> int:
	return status_current[get_status_index(name)]


func set_status_min(name: String, value: int) -> void:
	status_min[get_status_index(name)] = value


func set_status_max(name: String, value: int) -> void:
	status_max[get_status_index(name)] = value


func set_status_default(name: String, value: int) -> void:
	status_default[get_status_index(name)] = value


func set_status_current(name: String, value: int) -> void:
	status_current[get_status_index(name)] = value
	
	if get_status_current(name) < get_status_min(name):
		set_status_current(name, get_status_min(name))
	
	elif get_status_current(name) > get_status_max(name):
		set_status_current(name, get_status_max(name))
	
	emit_signal("status_updated", name)


func add_status_min(name: String, value: int) -> void:
	status_min[get_status_index(name)] += value


func add_status_max(name: String, value: int) -> void:
	status_max[get_status_index(name)] += value


func add_status_default(name: String, value: int) -> void:
	status_default[get_status_index(name)] += value


func add_status_current(name: String, value: int) -> void:
	status_current[get_status_index(name)] += value 
	
	if get_status_current(name) < get_status_min(name):
		set_status_current(name, get_status_min(name))
	
	elif get_status_current(name) > get_status_max(name):
		set_status_current(name, get_status_max(name))
	
	emit_signal("status_updated", name)


func _on_status_updated(status: String):
	if get_status_current(status) <= get_status_min(status):
		emit_signal("status_at_min", status)
