extends Node3D

@export var ground_level := 0.0
@export var noise: FastNoiseLite
@export var noise_amplitude := 1.0
var _marching_cube


func _ready():
	assert(
		get_parent()._RELATIVE_CORNER_COORDS,
		"Parrent is not an marching cube"
	)
	_marching_cube = get_parent()


func _generate_corner_weights(_subdivition_position, _subdivition_fraction):
	var _corner_weights = []
	for _relative_corner_position in _marching_cube._RELATIVE_CORNER_COORDS:
		var _corner_posistion = global_position + _subdivition_position + _relative_corner_position * _subdivition_fraction * _marching_cube.side_length
		
		var _corner_weight: float
		
		
		var _surface_offset = noise.get_noise_2dv(
				Vector2(_corner_posistion.x, _corner_posistion.z)
		) * noise_amplitude
		
		_corner_weight = 0
		
		_corner_weight -= _surface_offset - _corner_posistion.y + ground_level
		
		_corner_weights.append(_corner_weight)
		
	return _corner_weights
