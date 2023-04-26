extends Node


@export var status_system : StatusSystem
@onready var scene_manager = get_tree().get_root().get_node(
		"Main/SceneManager"
)
@onready var player = $".."
@onready var _player_start_pos = player.get("global_position")
@onready var _player_start_rot = player.get("global_rotation")

func _ready():
	assert(
			status_system.has_signal("status_at_min"),
			"The given Node is not of type StatusSystem."
	)
	
	status_system.connect(
			"status_at_min",
			Callable(
					self,
					"_on_status_system_status_at_min"
			)
	)


func _on_status_system_status_at_min(status_name : String):
	if status_name == "health":
		status_system.set_status_current(
				status_name,
				status_system.get_status_default(status_name)
		)
		player.set("global_position", _player_start_pos)
		player.set("global_rotation", _player_start_rot)
