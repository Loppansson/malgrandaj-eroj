extends Node

#=-----------------------------=#
#         SCENE MANAGER         #
#=-----------------------------=#
# Manages the game state at the #
# highest level.                #
#                               #
# Changing scene should be done #
# through this node (ex.        #
# swiching between menues) to   #
# keep things consistent and    #
# more robust.                  #
#                               #
# Loads the first scene in      #
# "scenes" when ready.          #
#=-----------------------------=#

# Stores all the scenes in the game.
@export var scenes: Array[PackedScene]
# Stores the currently loaded scene.
var _current_scene: Node


# Changes scene to the first in 
# "scenes" when game starts.
func _ready():
	change_scene_by_index(0)


# Changes the current scene, to a 
# scene in "scenes", at the the 
# index "_index". 
# 
# If "scenes" is empty, the function
# asserts.
#
# If the given index is out of 
# bounds, the function asserts.
func change_scene_by_index(_index: int):
	assert(
			not scenes.is_empty(),
			'"scenes" is empty.'
	)
	
	assert(
			(
				_index < len(scenes)
				and _index >= 0 
			),
			"_index is out of bounds."
	)
	
	if _current_scene:
		_current_scene.queue_free()
	_current_scene = scenes[_index].instantiate()
	add_child(_current_scene)


# Changes the current scene, to
# a scene in "scenes", by the name 
# of _name.
#
# If "scenes" is empty, the function
# asserts.
#
# If no scene by the given name is 
# found in scenes, the function 
# asserts.
func change_scene_by_name(_name: String):
	assert(
			not scenes.is_empty(),
			'"scenes" is empty.'
	)
	
	var _found_scene : Node
	
	for _scene in scenes:
		if _scene.instantiate().name == _name:
			_found_scene = _scene.instantiate()
	
	assert(
			_found_scene,
			str(
					'No scene by the name of "', 
					_name, 
					'" was not found in "scenes"'
			)
	)
	
	if _current_scene:
		_current_scene.queue_free()
	_current_scene = _found_scene
	add_child(_current_scene)
