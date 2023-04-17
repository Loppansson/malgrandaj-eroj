extends Node3D

## Generates the world's terrain.
##
## Currently the terrain is devided into 16x16x16 chunks.

## How far from the origin chunks load.
@export var render_distance: = 2 as int
## The mesh representing a chunk.
@export var chunk_mesh: PackedScene
## The point that world generation centers around. Rn it's the player.
@export var origin: Node3D

var _chunk_size = 16
## Stores what chunks have been generated, and what they contain
var _chunks = {}
## The current chunk that origin is in.
var _active_chunk: Vector3
## The last chunk that origin was in.
var _last_chunk: Vector3


# Called when the node enters the scene tree for the first time.
func _ready():
	_active_chunk = _position_to_chunk(origin.position)
	
	_generate_plane_render_distance(-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if _origin_moved_chunk():
		_update_active_chunk()
		_generate_slice_at_render_distance()

## Returns the chunk _position is in.
func _position_to_chunk(_position: Vector3):
	return Vector3(
			floor(_position.x / _chunk_size), 
			floor(_position.y / _chunk_size),
			floor(_position.z / _chunk_size)
	)


## Generates all chunks at the y level _y that are within render distance.
func _generate_plane_render_distance(_y : int):
	for _x in range(
			-render_distance + _active_chunk.x,
			render_distance + _active_chunk.x
	):
		for _z in range(
				-render_distance + _active_chunk.z, 
				render_distance + _active_chunk.z
		):
			_generate_chunk(Vector3(_x, _y, _z))


## Generates chunks at the egde of render_distance in the direction origin 
## is moving. (Works both side-ways and up and down.)
func _generate_slice_at_render_distance():
	var _axis = _check_direction(_last_chunk, _active_chunk)
	# Hack: With out the " - 1" there's always a gap in the generation? 
	var _generation_distance = render_distance - 1
	var _generation_width = render_distance
	
	for _part in range(-_generation_distance, _generation_distance):
		var _relative_from: Vector3
		var _relative_to: Vector3
		
		# Hack: It feel to me like there got to be a bettre way than this?
		match _axis:
			"-x":
				_relative_from = Vector3(
						-_generation_distance, 
						_part, 
						-_generation_width
				)
				_relative_to = Vector3(
						-_generation_distance, 
						_part, 
						_generation_width
				)
			"x":
				_relative_from = Vector3(
						_generation_distance, 
						_part, 
						-_generation_width
				)
				_relative_to = Vector3(
						_generation_distance, 
						_part, 
						_generation_width
				)
			"-y":
				_relative_from = Vector3(
						_part,
						-_generation_distance, 
						-_generation_width
				)
				_relative_to = Vector3(
						_part, 
						-_generation_distance, 
						_generation_width
				)
			"y":
				_relative_from = Vector3(
						_part, 
						_generation_distance, 
						-_generation_width
						)
				_relative_to = Vector3(
						_part, 
						_generation_distance, 
						_generation_width
				)
			"-z":
				_relative_from = Vector3(
						-_generation_width, 
						_part, 
						-_generation_distance
				)
				_relative_to = Vector3(
						_generation_width, 
						_part, 
						-_generation_distance
				)
			"z":
				_relative_from = Vector3(
						-_generation_width, 
						_part, 
						_generation_distance
				)
				_relative_to = Vector3(
						_generation_width, 
						_part, 
						_generation_distance
				)
		
		_generate_chunk_line(
				_relative_from + _active_chunk,
				_relative_to + _active_chunk
		)

## Generates all the chunks with in render distance.
func _generate_full_render_distance():
	var _chunck_position = _position_to_chunk(origin.position)
	
	for _x in range(
			-render_distance + _chunck_position.x, 
			render_distance + _chunck_position.x
	):
		for _y in range(
			-render_distance + _chunck_position.y, 
			render_distance + _chunck_position.y
		):
			for _z in range(
					-render_distance + _chunck_position.z, 
					render_distance + _chunck_position.z
			):
				_generate_chunk(Vector3(_x, _y, _z))

## Generates chunks in a line, from _from to _to. _from and _to need to
## share two values to align.
func _generate_chunk_line(_from: Vector3, _to: Vector3):
	var _axis = _check_direction(_from, _to)
	
	if _axis == "x" or _axis == "-x":
		for x in range(abs(_to.x - _from.x)):
			_generate_chunk(
					Vector3(min(_from.x, _to.x) + x, _from.y, _from.z)
			)
	if _axis == "y" or _axis == "-y":
		for y in range(abs(_to.y - _from.y)):
			_generate_chunk(
					Vector3(_from.x, min(_from.y, _to.y) + y, _from.z)
			)
	if _axis == "z" or _axis == "-z":
		for z in range(abs(_to.z - _from.z)):
			_generate_chunk(
					Vector3(_from.x, _from.y, min(_from.z, _to.z) + z)
			)


## Returns which axis _position_2 most points towards in relation to 
## _position_1.
func _check_direction(_position_1: Vector3, _position_2: Vector3):
	var _relative_pos = _position_2 - _position_1
	
	
	if abs(_relative_pos.x) >= abs(_relative_pos.y):
		if abs(_relative_pos.x) >= abs(_relative_pos.z):
			if _relative_pos.x > 0:
				return "x"
			else:
				return "-x"
	
	if abs(_relative_pos.y) >= abs(_relative_pos.x):
		if abs(_relative_pos.y) >= abs(_relative_pos.z):
			if _relative_pos.y > 0:
				return "y"
			else:
				return "-y"
	
	if abs(_relative_pos.z) >= abs(_relative_pos.x):
		if abs(_relative_pos.z) >= abs(_relative_pos.y):
			if _relative_pos.z > 0:
				return "z"
			else:
				return "-z"
	
	assert(true, "Direction check failed.")


func _update_active_chunk():
	_last_chunk = _active_chunk
	_active_chunk = _position_to_chunk(origin.position)


func _origin_moved_chunk():
	return _active_chunk != _position_to_chunk(origin.position)


func _generate_chunk(_chunk_coordinate: Vector3i):
	if _chunk_is_empty(_chunk_coordinate):
		if _chunk_coordinate.y > -1:
			_chunks.merge({
						_chunk_coordinate.x: {
							_chunk_coordinate.y: {
								_chunk_coordinate.z: ""
							}
						}
					}
			)
		else:
			var _instance = chunk_mesh.instantiate()
			_instance.set("position", _chunk_coordinate * _chunk_size)
			_instance.set(
					"name", 
					(
							str(_chunk_coordinate.x) + ", " +
							str(_chunk_coordinate.y) + ", " +
							str(_chunk_coordinate.z) + ", "
					)
			)
			add_child(_instance)
			
			_chunks.merge({
						_chunk_coordinate.x: {
							_chunk_coordinate.y: {
								_chunk_coordinate.z: _instance
							}
						}
					}
			)


func _chunk_is_empty(_chunk_coordinate: Vector3i):
	if not _chunks.find_key(_chunk_coordinate.x):
		if not _chunks.find_key(_chunk_coordinate.y):
			if not _chunks.find_key(_chunk_coordinate.z):
				return true
	return false
