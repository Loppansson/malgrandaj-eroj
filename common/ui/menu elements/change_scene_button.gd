extends Button

#=----------------------------=#
#     CHANGE SCENE BUTTON      #
#=----------------------------=#
# Useful when creating ui that # 
# interacts with SceneManager. #
#=----------------------------=#

## Scene to change to's name.
@export var next_scene: String
@onready var _scene_manager = get_tree().get_root().get_node("Main/SceneManager")


func _on_pressed():
	_scene_manager.change_scene_by_name(next_scene)
