extends Node3D

## Generates the world's terrain.
##
## Currently the terrain is devided into 16x16x16 chunks.

## How far from the origin chunks generate.
@export var generation_distance := 4 as int
@export var remove_distance := -1 as int

#----------------#
# Atempt at LODs #
#----------------#
@export var lods := true
#----------------#

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






# Called when the node enters the scene tree for the first time.
func _ready():
	_active_chunk = _position_to_chunk(origin.position)

	_load_start_time = Time.get_unix_time_from_system()

	_generate_full_generation_distance(true)

	_load_end_time = Time.get_unix_time_from_system()

	print()
	print("Load Time: ", _load_end_time - _load_start_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if _origin_moved_chunk():
		_update_at_distance(generation_distance)
		_remove_at_distance(remove_distance)
		_update_active_chunk()


func _update_at_distance(distance):
	var chunks_to_render := []

	var rd := distance as int

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
		_generate_chunk(chunk, lods)





func _remove_at_distance(distance):
	if not remove_distance == -1:
		var chunks_to_render := []
		
		var point_1 = _active_chunk - Vector3.ONE * distance 
		var point_2 = _active_chunk + Vector3.ONE * (distance + 1)
		var coords = _get_coords_between_coords(point_1, point_2)
		
		for coord in coords:
			if (
					coord.x == _active_chunk.x + distance
					or coord.x == _active_chunk.x - distance
					or coord.y == _active_chunk.y + distance
					or coord.y == _active_chunk.y - distance
					or coord.z == _active_chunk.z + distance
					or coord.z == _active_chunk.z - distance
			):
				chunks_to_render.append(coord)
		
		for chunk in chunks_to_render:
			_remove_chunk(chunk)





func _remove_chunk(chunk):
	if _chunks.has(chunk.x):
		if _chunks[chunk.x].has(chunk.y):
			if _chunks[chunk.x][chunk.y].has(chunk.z):
				_chunks[chunk.x][chunk.y][chunk.z].queue_free()
				_chunks[chunk.x][chunk.y].erase(chunk.z)






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


## Returns the chunk _position is in.
func _position_to_chunk(_position: Vector3):
	return Vector3(
			floor(_position.x / chunk_size),
			floor(_position.y / chunk_size),
			floor(_position.z / chunk_size)
	)


## Generates all the chunks with in render distance.
func _generate_full_generation_distance(_initial_generation := false):
	var _distance := Vector3.ZERO
	if _initial_generation:
		_distance = intitial_generation_distance
	else:
		_distance = Vector3.ONE * generation_distance

	var _coords_to_generate = _get_coords_between_coords(
			_active_chunk - _distance,
			_active_chunk + _distance
	)

	for _coord in _coords_to_generate:
		_generate_chunk(_coord)
		
		if _initial_generation:
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
	
	print()


func _update_active_chunk():
	_last_chunk = _active_chunk
	_active_chunk = _position_to_chunk(origin.position)


func _origin_moved_chunk():
	return _active_chunk != _position_to_chunk(origin.position)


func _generate_chunk(_chunk_coordinate: Vector3, _over_write := false):
	_over_write = false
	if _chunk_is_empty(_chunk_coordinate) or _over_write:
		var _chunk_name = (
				str(_chunk_coordinate.x) + ", " +
				str(_chunk_coordinate.y) + ", " +
				str(_chunk_coordinate.z)
		)
		
		var _instance = chunk_mesh.instantiate() as Node3D
		_instance.set("position", _chunk_coordinate * chunk_size)
		_instance.set("name", _chunk_name)
		
		
		var _x = _chunk_coordinate.x
		var _y = _chunk_coordinate.y
		var _z = _chunk_coordinate.z
		
		if _chunks.has(_x):
			if _chunks[_x].has(_y):
				if _over_write and _chunks[_x][_y].has(_z):
					_chunks[_x][_y][_z].queue_free()
				_chunks[_x][_y].merge(
					{_z: _instance},
					_over_write
				)
			else:
				_chunks[_x].merge({_y: {_z: _instance}})
		else:
			_chunks.merge({_x: {_y: {_z: _instance}}})
		
		
		
		add_child(_instance)


func _chunk_is_empty(_chunk_coordinate: Vector3):
	var _x = _chunk_coordinate.x
	var _y = _chunk_coordinate.y
	var _z = _chunk_coordinate.z

	if _chunks.has(_x):
		if _chunks[_x].has(_y):
			if _chunks[_x][_y].has(_z):
				return false
	return true


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
