extends Node3D

#=-------------------------------------------------------=#
#                   -= ACTIVE GOALS =-                    #
#=-------------------------------------------------------=#
#                          LODs                           #  
#=-------------------------------------------------------=#
# Give the MarchingCubes the ability renader at different #
# LODs. The steps between different LODs MUST be seem-    #
# less; gaps that allow the player to see through the are #
# NOT allowed world.                                      #
#                                                         #
# Subgoals:                                               #
#  - Be able to move a spesific vertex of the marching    #
#    cube up and down manualy.                            #
#  - Be able to move every other vertext up and down in   #
#    some kind of loop.                                   #
#  - Make the the frequency based on a variable; every    #
#    other, third, forth, ect.                            #
#                                                         #
#=-------------------------------------------------------=#

## Gives a parent MeshInstance an ArrayMesh from data using the MarchingCubes 
## concept. 
##
## Ether just one segment/marching cube can be generated, or the area can be 
## divided into mutiple segments throug subdeviding along all sides. [br][br]
## 
## The final shape's side length is also adjustable.
##
## If smoothing is set to on, the final shape will be smoother.
##
## The system uses data between -1 and 1, where < 0 is considered inside and 
## >= 0 is considerd out side.

## The relative position of each of the corners shown in the look up table.
const _RELATIVE_CORNER_COORDS = [
	Vector3(0.0, 0.0, 0.0),
	Vector3(1.0, 0.0, 0.0),
	Vector3(0.0, 1.0, 0.0),
	Vector3(1.0, 1.0, 0.0),
	Vector3(0.0, 0.0, 1.0),
	Vector3(1.0, 0.0, 1.0),
	Vector3(0.0, 1.0, 1.0),
	Vector3(1.0, 1.0, 1.0)
]
@export var subdivitions := 3.0 as float
@export var side_length := 16.0 as float
@export var smoothing := true
@export var _weight_generator: Node3D
## The MeshInstance3D to which the generated ArrayMesh is given. 
var _mesh_instance: MeshInstance3D
@onready var look_up_table = $"LookUpTable"


#----------------#
# Atempt at LODs #
#----------------#
@export var lod = 1
var vertices = {
	"local_positions":[],
	"global_positions":[],
	"is_in":[]
}
#----------------#



func _ready() -> void:
	_get_mesh_instance()
	
	
	#----------------#
	# Atempt at LODs #
	#----------------#
	if lod > 0:
		subdivitions = pow(2, lod) - 1
	#----------------#	
	
	vertices = _get_vertices()
	
#	print(vertices["local_positions"])
#	print(vertices["global_positions"])
	
	if len(vertices["global_positions"]) != 0:
		#----------------#
		# Atempt at LODs #
		#----------------#
		
		pass
#		print(vertices["global_positions"])
		
		
#		if lod > 0:
#			for i in range(len(vertices["global_positions"])):
#				var vertex_global_pos = vertices["global_positions"][i]
#				var vertex_local_pos = vertices["local_positions"][i]
#				if not (vertex_local_pos.y == 0 or vertex_local_pos.y == 1): 
#					if vertex_global_pos.x == global_position.x:
#						prints(
#								subdivitions,
#								vertex_local_pos,
#								vertex_local_pos.z * (subdivitions + 1)
#						)
		
		
		#----------------#
		
		
		
		var _packed_vertices = _pack_vertices(vertices["local_positions"])
		var _packed_normals = _pack_normals(vertices["local_positions"])
		
		_mesh_instance.mesh = _create_mesh(
				_packed_vertices, 
				_packed_normals
		)
		
		_mesh_instance.create_trimesh_collision.call_deferred()


## Makes sure that parent is of correct type (MeshInstance3D), and stores it.
func _get_mesh_instance():
	assert(
			$MeshInstance3D as MeshInstance3D,
			"Parent is not of type MeshInstance3D"
	)
	_mesh_instance = $MeshInstance3D
	


## Returns an arraya containing all the vertecies to be generated within the 
## marching cube collection.
func _get_vertices():
	var _result := {
		"local_positions":[],
		"global_positions":[]
	}
	
	for z in range(subdivitions + 1):
		for y in range(subdivitions + 1):
			for x in range(subdivitions + 1):
				var _vertices = _get_segment_vertices(
						x, 
						y, 
						z, 
						_RELATIVE_CORNER_COORDS
				)
				_result["local_positions"] += _vertices["local_positions"]
				_result["global_positions"] += _vertices["global_positions"]
	
	return _result


## Returns the vertecies of a segment.
func _get_segment_vertices(x, y, z, _RELATIVE_CORNER_COORDS):
	var _subdivition_fraction = 1.0 / (subdivitions + 1.0)
	var _subdivition_position = (
			Vector3(x, y, z) 
			* _subdivition_fraction
			* side_length
	)
	
	
	var _corner_weights = _weight_generator._generate_corner_weights(
			_subdivition_position, 
			_subdivition_fraction
	)
	
	var _marching_cubes_case = _find_marching_cube_case(_corner_weights)
	
	var triangulation = _triangulate_marching_cubes_case(_marching_cubes_case)
	
	var found_vertices = _triangulation_to_vertices(
			triangulation, 
			_subdivition_fraction,
			_subdivition_position,
			_corner_weights
	)
	return found_vertices


func _find_marching_cube_case(_corner_weights: Array):
	var _marching_cubes_case := 0 as int
	for weight_index in range(len(_corner_weights)):
		if _corner_weights[weight_index] >= 0.0:
			_marching_cubes_case += pow(2, weight_index)
	
	return _marching_cubes_case


func _triangulate_marching_cubes_case(_marching_cubes_case: int):
	var triangulation = []
	
	for value in look_up_table.TriangleTable[_marching_cubes_case]:
		triangulation.append(value)
	triangulation.pop_back()
	
	return triangulation


func _triangulation_to_vertices(
		triangulation, 
		_subdivition_fraction, 
		_subdivition_position,
		_corner_weights
	):
	var found_vertices := {
		"local_positions":[],
		"global_positions":[]
	}
	for edge_index in triangulation:
		var _edge_vertex_index_1 = look_up_table.EdgeVertexIndices[edge_index][0]
		var _edge_vertex_index_2 = look_up_table.EdgeVertexIndices[edge_index][1]
		
		var _corner_1_pos = _RELATIVE_CORNER_COORDS[_edge_vertex_index_1]
		var _corner_2_pos = _RELATIVE_CORNER_COORDS[_edge_vertex_index_2]
		
		var _weight_1 = _corner_weights[_edge_vertex_index_1]
		var _weight_2 = _corner_weights[_edge_vertex_index_2]
		
		var bettween_point = _generate_between_point(
				_corner_1_pos,
				_corner_2_pos,
				_weight_1,
				_weight_2
		)
		
		var _scaled_edge_coord = bettween_point * _subdivition_fraction * side_length
		
		var vertex_position = _subdivition_position + _scaled_edge_coord
		
		found_vertices["local_positions"].append(vertex_position)
		found_vertices["global_positions"].append(vertex_position + _subdivition_position + global_position)
	
	return found_vertices


func _generate_between_point(
		_corner_1_pos: Vector3, 
		_corner_2_pos: Vector3, 
		_weight_1: float, 
		_weight_2: float
	):
	var _weight_ratio: float
	
	if smoothing:
		_weight_ratio = (0 - _weight_1) / (_weight_2 - _weight_1)
	else:
		_weight_ratio = 0.5
	
	var bettween_point = Vector3(
			lerp(_corner_1_pos.x, _corner_2_pos.x, _weight_ratio),
			lerp(_corner_1_pos.y, _corner_2_pos.y, _weight_ratio),
			lerp(_corner_1_pos.z, _corner_2_pos.z, _weight_ratio)
	)
	
	return bettween_point


func _pack_vertices(_vertices: Array):
	var _packed_vertices: PackedVector3Array
	
	for _vertex in _vertices:
		_packed_vertices.push_back(_vertex)
	
	return _packed_vertices


func _pack_normals(_vertices: Array):
	var _packed_normals: PackedVector3Array
	
	for _pair_of_three in range(len(_vertices) / 3):
		for a in range(3):
			var _normal: Vector3
			
			_normal = _get_normal(
					_vertices[_pair_of_three * 3],
					_vertices[_pair_of_three * 3 + 1],
					_vertices[_pair_of_three * 3 + 2]
			)
			
			_packed_normals.push_back(_normal)
	
	return _packed_normals


func _get_normal(_vertex_1: Vector3, _vertex_2: Vector3, _vertex_3: Vector3):
	var _vector_1 = _vertex_3 - _vertex_1
	var _vector_2 = _vertex_2 - _vertex_3
	var _normal = _vector_1.cross(_vector_2)
	
	return _normal


func _create_mesh(
		_packed_vertices: PackedVector3Array, 
		_packed_normals: PackedVector3Array
	):
	# Initialize the ArrayMesh.
	var _array_mesh = ArrayMesh.new()
	var _arrays = []
	_arrays.resize(Mesh.ARRAY_MAX)
	
	_arrays[Mesh.ARRAY_VERTEX] = _packed_vertices
	_arrays[Mesh.ARRAY_NORMAL] = _packed_normals
	
	
	
	# Create the Mesh.
	_array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _arrays)
	return _array_mesh
