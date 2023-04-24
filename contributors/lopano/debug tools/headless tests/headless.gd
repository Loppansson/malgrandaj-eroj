extends Node

var _vertices := {} as Dictionary
var _triangles := [] as Array

func _ready():
	#-- For Headles --------------------------------------------------#
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
	#-----------------------------------------------------------------#
	
	var dict_1 = {0: {0: 1}}
	var dict_2 = {0: {1: 1}}
	
	print(merge_recursive(dict_1, dict_2))
	
	
	_create_triangle(
		Vector3(0, 0, 0),
		Vector3(0, 1, 0),
		Vector3(0, 0, 1)
	)
	print(_vertices)
	print(_triangles)
	
	_vertices[0.0][0.0][0.0] = Vector3(-1, -1, -1)
	_update_triangles()
	print()
	print(_vertices)
	print(_triangles)

func _update_triangles():
	var _updated_triangles := [] as Array
	for _triangle in _triangles:
		_updated_triangles.append([
			_vertices[_triangle[0].x][_triangle[0].y][_triangle[0].z],
			_vertices[_triangle[1].x][_triangle[1].y][_triangle[1].z],
			_vertices[_triangle[2].x][_triangle[2].y][_triangle[2].z]
		])
		
	_triangles = _updated_triangles

func _create_triangle(_vertex_1 : Vector3, _vertex_2 : Vector3, _vertex_3 : Vector3):
	_add_vertex(_vertex_1)
	_add_vertex(_vertex_2)
	_add_vertex(_vertex_3)
	
	var _triangle = [
		_vertices[_vertex_1.x][_vertex_1.y][_vertex_1.z],
		_vertices[_vertex_2.x][_vertex_2.y][_vertex_2.z],
		_vertices[_vertex_3.x][_vertex_3.y][_vertex_3.z]
	]
	
	_triangles.append(_triangle)

func _add_vertex(_pos : Vector3):
	merge_recursive(
			_vertices, 
			{_pos.x: {_pos.y : {_pos.z: _pos}}}
	)
	
#	if _vertices.has(_pos.x):
#		if _vertices[_pos.x].has(_pos.y):
#			if _vertices[_pos.x][_pos.y].has(_pos.z):
#				_vertices[_pos.x][_pos.y][_pos.z] = _pos
#			else:
#				_vertices[_pos.x][_pos.y].merge({_pos.z: _pos})
#		else:
#			_vertices[_pos.x].merge({_pos.y : {_pos.z: _pos}})
#	_vertices.merge({_pos.x: {_pos.y : {_pos.z: _pos}}})


func _create_vertex(_pos: Vector3):
	return {
		_pos.x: {
			_pos.y: {
				_pos.z: _pos
			}
		}
	}


func merge_recursive(dict1, dict2):
	var result = {}
	for key in dict1.keys():
		var left = dict1[key]
		if dict2.has(key):
			var right = dict2[key]
			# both values are dictionaries, great, merge recursively
			if left is Dictionary and right is Dictionary:
				result[key] = merge_recursive(left, right)
			else:
			# key is in both but value is no dictionary, right wins.
				result[key] = right   
		else:
			# key is only in left  but not in right, left wins
			result[key] = left
	
	# now handle keys that are only in right
	for key in dict2.keys():
		if not dict1.has(key):
			result[key] = dict2[key]
	
	return result
	
