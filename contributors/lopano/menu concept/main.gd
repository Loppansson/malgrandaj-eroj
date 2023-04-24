extends Node

#=----------------------------=#
#             MAIN             #
#=----------------------------=#
# Manages the game state at    #
# the highest level.           #
#                              #
# Changing scene should be     #
# done through this node (ex.  #
# swiching between menues) to  #
# keep things consistent and   #
# more robust.                 #
#=----------------------------=#

# Stores all the scenes in the game.
@export var scenes: Array[PackedScene]
# Stores the currently loaded scene.
var _current_scene: Node

# Changes scene to the first in 
# "scenes" on when game starts.
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
# a scene in "scenes".
func change_scene_by_name(_name: String):
	pass












