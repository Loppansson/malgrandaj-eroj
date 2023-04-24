extends Node3D

@export var ground_level := 0.0
@export var noises: Array[FastNoiseLite]
@export var noise_amplitudes: Array[float]
@export var noise_toggles: Array[bool]
var _marching_cube


# 195.10 s, 2 layers, 2 On. 16, 1, 16.
# 140.25 s, 2 layers, 1 On. 16, 1, 16.
#  67.82 s, 2 layers, 1 On.  8, 2,  8.


func _ready():
	assert(
		get_parent()._RELATIVE_CORNER_COORDS,
		"Parrent is not an marching cube"
	)
	_marching_cube = get_parent()
	
	assert(
			len(noises) == len(noise_amplitudes) and len(noises) == len(noise_toggles),
			"Arrays are of different lenghts."
	)


func _generate_corner_weights(_subdivition_position, _subdivition_fraction):
	var _corner_weights = []
	for _relative_corner_position in _marching_cube._RELATIVE_CORNER_COORDS:
		var _corner_posistion = global_position + _subdivition_position + _relative_corner_position * _subdivition_fraction * _marching_cube.side_length
		
		var _corner_weight: float
		
		var _surface_offset = 0.0
		for i in range(len(noises)):
			if noise_toggles[i]:
				_surface_offset += noises[i].get_noise_2dv(
						Vector2(_corner_posistion.x, _corner_posistion.z)
				) * noise_amplitudes[i]
		
#		if _corner_posistion.y == -4:
#			_corner_weight = -1
#		elif _corner_posistion.y == -3:
#			_corner_weight = -1
#		elif _corner_posistion.y == -2:
#			_corner_weight = -1
#		elif _corner_posistion.y == -1:
#			_corner_weight = -1
#		elif _corner_posistion.y == 0:
#			_corner_weight = 0
#		elif _corner_posistion.y == 1:
#			_corner_weight = 1
#		elif _corner_posistion.y == 2:
#			_corner_weight = 1
		
		_corner_weight = 0
		
		_corner_weight -= _surface_offset - _corner_posistion.y + ground_level
		
		_corner_weights.append(_corner_weight)
		
	return _corner_weights
