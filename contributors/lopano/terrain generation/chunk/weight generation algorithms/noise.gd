extends Node3D

@export var noise: FastNoiseLite
@export var weight_gain := 0.0
var _marching_cube

func _ready():
	assert (
		get_parent()._RELATIVE_CORNER_COORDS,
		"Parrent is not an marching cube"
	)
	_marching_cube = get_parent()


func _generate_corner_weights(_subdivition_position, _subdivition_fraction):
	var _corner_weights = []
	for _relative_corner_position in _marching_cube._RELATIVE_CORNER_COORDS:
		var _corner_posistion = global_position + _subdivition_position + _relative_corner_position * _subdivition_fraction * _marching_cube.side_length
		
		var _corner_weight = noise.get_noise_3dv(_corner_posistion)
		
		_corner_weight += weight_gain
		
		
		_corner_weights.append(_corner_weight)
		
	return _corner_weights
