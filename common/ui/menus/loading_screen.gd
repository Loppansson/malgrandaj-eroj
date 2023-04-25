extends Control

#=------------------------=#
#      LOADING SCREEN      #
#=------------------------=#
# Shown while world loads. #
#=------------------------=#

@onready var _scene_manager = get_tree().get_root().get_node("Main/SceneManager")

func _ready():
	await get_tree().create_timer(0.1).timeout
	_scene_manager.change_scene_by_name("World")
