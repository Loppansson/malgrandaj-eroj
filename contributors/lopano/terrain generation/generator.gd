extends Node3D

## Generates the world's terrain.
##
## Currently the terrain is devided into 16x16x16 chunks.

## How far from the origin chunks generate.
@export var generation_distance := 4 as int

# Hack: LODs
@export var lods := true 
@export var lods_distance_positions: Array[int]
@export var lods_distance_subdivitions: Array[int]

## How far from the origin chunks are generated on _read().
@export var intitial_generation_distance := Vector3(4.0, 4.0, 4.0)
@export var intitial_generation_offset := Vector3(0.0, 0.0, 0.0)

@export var chunk_size = 16
## The mesh representing a chunk.
@export var chunk_mesh: PackedScene
## The point that world generation centers around. Rn it's the player.
@export var origin: Node3D
## Stores what chunks have been generated, and what they contain
var _chunks = {}
## The current chunk that origin is in.
var _active_chunk: Vector3
## The last chunk that origin was in.
var _last_chunk: Vector3
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

var _load_start_time
var _load_end_time

## The total amount of chunks to generate during initial generation. Serves to 
## give feedback to the user during initial generation.
@onready var _initial_to_generate := intitial_generation_distance.x * intitial_generation_distance.y * intitial_generation_distance.z * 8


#--------------------------#
# Implementing Multithread #
#--------------------------#

signal thread_free
@export var child: PackedScene
var thread_count := 2 as int
var threads_in_use := 0 as int
var threads: Array[Thread]
var threads_use_state: Array[bool]

var _time_buildup := 0.0

#--------------------------#






# Called when the node enters the scene tree for the first time.
func _ready():
	# Hack: Lods
	assert(
		len(lods_distance_positions) == len(lods_distance_subdivitions),
		"lods_distance_positions and lods_distance_subdivitions are different in lenght"
	)
	
	#--------------------------#
	# Implementing Multithread #
	#--------------------------#
	for i in range(thread_count):
		threads.append(Thread.new())
		threads_use_state.append(false)
	#--------------------------#
	
	
	
	_active_chunk = _position_to_chunk(origin.position)
	
	_load_start_time = Time.get_unix_time_from_system()
	
	_generate_full_generation_distance(true)
	
	_load_end_time = Time.get_unix_time_from_system()
	
	print()
	print("Load Time: ", _load_end_time - _load_start_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if _origin_moved_chunk():
		_update_at_render_distance()
		_update_active_chunk()
	
	#--------------------------#
	# Implementing Multithread #
	#--------------------------#
	_time_buildup += delta     
	
	if Input.is_action_just_pressed("toggle_chunk_border"):
		print()
		for thread_i in range(len(threads)):
			prints(threads[thread_i], ":", threads_use_state[thread_i])
		print()
	#--------------------------#

#--------------------------#
# Implementing Multithread #
#--------------------------#------------------------------------------------#
func _exit_tree():
	for thread in threads:
		thread.wait_to_finish()

func _on_thread_free():
	pass
#	prints("(", _time_buildup, ") threads_in_use:", threads_in_use)
#	print()
#---------------------------------------------------------------------------#

func _update_at_render_distance():
	var chunks_to_render := []
	
	var rd := generation_distance as int
	
	var point_1 = _active_chunk - Vector3.ONE * rd
	var point_2 = _active_chunk + Vector3.ONE * (rd + 1)
	var coords = _get_coords_between_coords(point_1, point_2)
	
	for coord in coords:
		if (
				coord.x == _active_chunk.x + rd 
				or coord.x == _active_chunk.x - rd
				or coord.y == _active_chunk.y + rd
				or coord.y == _active_chunk.y - rd
				or coord.z == _active_chunk.z + rd
				or coord.z == _active_chunk.z - rd
		):
			chunks_to_render.append(coord)
	
	for chunk in chunks_to_render:
		_generate_chunk(chunk, true)



## Get returns all coordinates from _point_1 to _point_2.
func _get_coords_between_coords(_point_1: Vector3, _point_2: Vector3):
	var _coords = []
	for _x in range(_point_2.x - _point_1.x):
		for _y in range(_point_2.y - _point_1.y):
			for _z in range(_point_2.z - _point_1.z):
				_coords.append(Vector3(
						_x + _point_1.x,
						_y + _point_1.y,
						_z + _point_1.z
				))
	return _coords

func _generate_slices_at_lod_distances():
	for distance in lods_distance_positions:
		_generate_slice_at_distance(distance)



## Returns the chunk _position is in.
func _position_to_chunk(_position: Vector3):
	return Vector3(
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
func _generate_slice_at_distance(_distance: int):
	var _axis = _check_direction(_last_chunk, _active_chunk)
	# Hack: With out the " - 1" there's always a gap in the generation? 
	var _generation_distance = _distance
	var _generation_width = _distance
	
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
func _generate_full_generation_distance(_initial_generation := false):
	var _chunck_position = _position_to_chunk(origin.position)
	
	if not _initial_generation:
		for _x in range(
				-generation_distance + _chunck_position.x, 
				generation_distance + _chunck_position.x
		):
			for _y in range(
				-generation_distance + _chunck_position.y, 
				generation_distance + _chunck_position.y
			):
				for _z in range(
						-generation_distance + _chunck_position.z, 
						generation_distance + _chunck_position.z 
				):
					_generate_chunk(Vector3(_x, _y, _z))
	
	else:
		for _x in range(
				-intitial_generation_distance.x + _chunck_position.x + intitial_generation_offset.x, 
				intitial_generation_distance.x + _chunck_position.x + intitial_generation_offset.x
		):
			for _y in range(
				-intitial_generation_distance.y + _chunck_position.y + intitial_generation_offset.y, 
				intitial_generation_distance.y + _chunck_position.y + intitial_generation_offset.y
			):
				for _z in range(
						-intitial_generation_distance.z + _chunck_position.z + intitial_generation_offset.z, 
						intitial_generation_distance.z + _chunck_position.z + intitial_generation_offset.z
				):
					_generate_chunk(Vector3(_x, _y, _z))
					_initial_chunks_generated += 1
					
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


func _generate_chunk(_chunk_coordinate: Vector3, _over_write := false):
	if _chunk_is_empty(_chunk_coordinate) or _over_write:
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
		
		# Hack: LODs
		
		var do_not_add = false
		
		if lods:
			for i in range(len(lods_distance_positions)):
				var _chunk_distance = max(
						abs(_chunk_coordinate.x - _active_chunk.x),
						abs(_chunk_coordinate.y - _active_chunk.y),
						abs(_chunk_coordinate.z - _active_chunk.z),
				)
				var i_plus_1_is = (len(lods_distance_positions) == (i))
				var _distance_less_than = true
				
				if i_plus_1_is:
					_distance_less_than = _chunk_distance < lods_distance_positions[i + 1]
				
				if _chunk_distance > lods_distance_positions[i] and _distance_less_than:
					if lods_distance_subdivitions[i] < 0:
						var f = abs(lods_distance_subdivitions[i]) 
						if (
							_chunk_coordinate.x % (f + 1) != 0
							or _chunk_coordinate.y % (f + 1) != 0
							or _chunk_coordinate.z % (f + 1) != 0
						):
							do_not_add = true
						else:
							var cube = _instance.get_node("MarchingCubes")
							cube.subdivitions = 0
							
							if _chunk_coordinate.x < 0:
								_instance.position.x -= cube.side_length * (f - 1)
							if _chunk_coordinate.y < 0:
								_instance.position.y -= cube.side_length * (f - 1)
							if _chunk_coordinate.z < 0:
								_instance.position.z -= cube.side_length * (f - 1)
							
							cube.side_length *= (f + 1)
					else:
						_instance.get_node(
								"MarchingCubes"
						).subdivitions = lods_distance_subdivitions[i]
		
		
		var _db_string: String
		
		var _x = _chunk_coordinate.x
		var _y = _chunk_coordinate.y
		var _z = _chunk_coordinate.z
		
		if _chunks.has(_x):
			if _chunks[_x].has(_y):
				_chunks[_x][_y].merge(
					{_z: _instance},
					_over_write
				)
			else:
				_chunks[_x].merge({_y: {_z: _instance}})
		else:
			_chunks.merge({_x: {_y: {_z: _instance}}})
		
		# Hack: LODs
		if not do_not_add:
			add_child(_instance)


func _chunk_is_empty(_chunk_coordinate: Vector3):
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
