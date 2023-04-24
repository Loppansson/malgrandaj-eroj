extends Node3D

## Generates the world's terrain.
##
## Instanciates and adds cubic chunks, with sides of lenght 
## [member chunk_size], to the world in a grid fashion.

## The max distence chunks can generate durring _process().
@export var generation_distance := 4 as int

## How far from [member _active_chunk] chunks generate on _read() along each 
## axis.
@export var intitial_generation_distance := Vector3i(4.0, 4.0, 4.0)
## Offset the initial generation from the [member _active_chunk].
@export var intitial_generation_offset := Vector3i(0.0, 0.0, 0.0)

## The lenght of the chunks sides.
@export var chunk_size = 16
## The mesh representing a chunk.
@export var chunk_mesh: PackedScene
## The point that world generation centers around. Rn it's the player.
@export var origin: Node3D
## Stores what chunks have been generated, and what they contain
var _chunks = {}
## The current chunk that origin is in.
var _active_chunk: Vector3i
## The last chunk that origin was in.
var _last_chunk: Vector3i
## Inciments when a new chunk is generated during initial generation. Serves to 
## give feedback to the user during initial generation.
var _initial_chunks_generated := 0
## Inciments when a chunk collision shape is generated during initial 
## generation. Serves to give feedback to the user during initial generation.
var _initial_collisions_generated := 0
## Shows the ratio between _initial_chunks_generated and 
## _initial_collisions_generated as procent. Serves to give feedback
## to the user during initial generation.
var _procent_generated := 0 as int
## Stores the time at which the inital generation starts.
var _load_start_time
## Stores the time at which the inital generation completes.
var _load_end_time
## The total amount of chunks to generate during initial generation. Serves to 
## give feedback to the user during initial generation.
@onready var _initial_to_generate := intitial_generation_distance.x * intitial_generation_distance.y * intitial_generation_distance.z * 8 as float

# Called when the node enters the scene tree for the first time.
func _ready():
	_active_chunk = _position_to_chunk(origin.global_position)
	
	_load_start_time = Time.get_unix_time_from_system()
	
	# Fixme: Clean round 1. Done to this. #1
	
	_generate_full_generation_distance(true)
	
	_load_end_time = Time.get_unix_time_from_system()
	print()
	print("Load Time: ", _load_end_time - _load_start_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if _origin_moved_chunk():
		_update_active_chunk()
		_generate_slice_at_generation_distance()




## Returns the chunk _position is in.
func _position_to_chunk(_position: Vector3):
	return Vector3i(
			floor(_position.x / chunk_size), 
			floor(_position.y / chunk_size),
			floor(_position.z / chunk_size)
	)


## Generates all chunks at the y level _y that are within render distance.
func _generate_plane_generation_distance(_y: int, _initial_generation := false):
	if _initial_generation:
		for _x in range(
				-intitial_generation_distance.x + _active_chunk.x + intitial_generation_offset.x,
				intitial_generation_distance.x + _active_chunk.x + intitial_generation_offset.x
		):
			for _z in range(
					-intitial_generation_distance.z + _active_chunk.z + intitial_generation_offset.z, 
					intitial_generation_distance.z + _active_chunk.z + intitial_generation_offset.z
			):
				_generate_chunk(Vector3(_x, _y, _z))
	
	else:
		for _x in range(
				-generation_distance + _active_chunk.x,
				generation_distance + _active_chunk.x
		):
			for _z in range(
					-generation_distance + _active_chunk.z, 
					generation_distance + _active_chunk.z
			):
				_generate_chunk(Vector3(_x, _y, _z))


## Generates chunks at the egde of generation_distance in the direction origin 
## is moving. (Works both side-ways and up and down.)
func _generate_slice_at_generation_distance():
	var _axis = _check_direction(_last_chunk, _active_chunk)
	# Hack: With out the " - 1" there's always a gap in the generation? 
	var _generation_distance = generation_distance - 1
	var _generation_width = generation_distance
	
	for _part in range(-_generation_distance, _generation_distance):
		var _relative_from: Vector3i
		var _relative_to: Vector3i
		
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
func _generate_full_generation_distance(_initial_generation := false):
	var _chunk_position = _position_to_chunk(origin.position)
	
	if not _initial_generation:
		var _coords_to_generate = _get_coords_between_coords(
				_active_chunk - Vector3i.ONE * generation_distance,
				_active_chunk + Vector3i.ONE * generation_distance
		)
		
		# Fixme: Clean round 1. Done to this. #2
		for _coordinate in _coords_to_generate:
			_generate_chunk(_coordinate)
	
	else:
		var _coords_to_generate = _get_coords_between_coords(
				(_active_chunk
				- intitial_generation_distance
				+ intitial_generation_offset),
				(_active_chunk
				+ intitial_generation_distance
				+ intitial_generation_offset)
		)
		
		for _coordinate in _coords_to_generate:
			_generate_chunk(_coordinate)
			_print_generation_progress()


## Prints the procentege of chunks that have been generated durring the initial
## generation so far.
func _print_generation_progress():
	_initial_chunks_generated += 1.0
	if _procent_generated != _float_to_procent(
			_initial_chunks_generated
			/ _initial_to_generate
	):
		_procent_generated = _float_to_procent(
				_initial_chunks_generated
				/ _initial_to_generate
		)
		print(
				"Generating Meshes: ", 
				_procent_generated, 
				"%"
		)


## Get returns all coordinates from _point_1 to _point_2.
func _get_coords_between_coords(_point_1: Vector3i, _point_2: Vector3i):
	var _coords = []
	for _x in range(_point_2.x - _point_1.x):
		for _y in range(_point_2.y - _point_1.y):
			for _z in range(_point_2.z - _point_1.z):
				_coords.append(Vector3i(
						_x + _point_1.x,
						_y + _point_1.y,
						_z + _point_1.z
				))
	return _coords



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

## Generates a chunk at a given coordinate.
func _generate_chunk(_chunk_coordinate: Vector3i):
	if _chunk_is_empty(_chunk_coordinate):
		# Fixme: Clean round 1. Done to this. #3
		var _instance = chunk_mesh.instantiate() as MeshInstance3D
		_instance.set("position", _chunk_coordinate * chunk_size)
		_instance.set(
				"name", 
				(
						str(_chunk_coordinate.x) + ", " +
						str(_chunk_coordinate.y) + ", " +
						str(_chunk_coordinate.z)
				)
		)
		
		var _db_string: String
		
		var _x = _chunk_coordinate.x
		var _y = _chunk_coordinate.y
		var _z = _chunk_coordinate.z
		
		if _chunks.has(_x):
			_db_string += "true, "
			
			if _chunks[_x].has(_y):
				_db_string += "true"
				
				_chunks[_x][_y].merge(
					{_z: _instance}
				)
			else:
				_db_string += "false"
				
				_chunks[_x].merge({_y: {_z: _instance}})
		else:
			_db_string = "false, false"
			_chunks.merge({_x: {_y: {_z: _instance}}})
		
		add_child(_instance)

## Returns true if there is no entry in _chunks for the given coordinate.
func _chunk_is_empty(_chunk_coordinate: Vector3i):
	if (
			not _chunks.find_key(_chunk_coordinate.x)
			and not _chunks.find_key(_chunk_coordinate.y)
			and not _chunks.find_key(_chunk_coordinate.z)
	):
		return true
	return false


func _db_print_chunks():
	print("{")
	for _x in _chunks.keys():
		print("    ", _x, ": {")
		for _y in _chunks.keys():
			print("        ", _y, ": {")
			for _z in _chunks.keys():
				print(_chunks[_x][_y])
				print("            ", _z, ": {")
				print("                ", _chunks[_x][_y][_z])
				print("            }")
			print("        }")
		print("    }")
	print("}")

func _float_to_procent(_f: float):
	return floor(_f * 100)
