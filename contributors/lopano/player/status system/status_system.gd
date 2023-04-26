extends Node

#=----------------------------------------------------------=#
#                        Status System                       #
#=----------------------------------------------------------=#
# Stores variables useful when giving stuff status elements, #
# like health,  hunger, and thirst.                          #
#                                                            #
# All arrays must be the same size.                          #
#=----------------------------------------------------------=#
#               statuses : The statuses that are in use by   #
#                          name.                             #
#             status_min : The min value the status can be.  #
#             status_max : The max value the status can be.  #
#         status_default : Status_current is set to          #
#                          status_default at ready().        #
#         status_current : The current state of the status.  #
# get_status_index(name) : Gets the index a status by name   #
#                          has in statuses.                  #
# get_status_value(name) : Gets status_current associated    #
#                          with the name given.              #
#=----------------------------------------------------------=#

@export var statuses: Array[String]
@export var status_min: Array[int]
@export var status_max: Array[int]
@export var status_default: Array[int]
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


func get_status_index(name: String) -> int:
	var _found_status_index: int
	
	for i in range(_number_statuses):
		if statuses[i] == name:
			_found_status_index = i
	
	assert(
		_found_status_index,
		str(
			'No status with the name "', 
			name, 
			'" was found.'
		)
	)
	
	return _found_status_index


func get_status_value(name: String) -> int:
	return status_current[get_status_index(name)]
