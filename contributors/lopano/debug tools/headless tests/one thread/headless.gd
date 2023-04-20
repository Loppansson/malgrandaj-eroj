extends Node

signal thread_free
@export var child: PackedScene
var thread: Thread
var using_thread = false

var _time_buildup := 0.0

func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
	
	thread = Thread.new()
	
	var instance_1 = child.instantiate()
	var instance_2 = child.instantiate()
	var instance_3 = child.instantiate()
	
	add_child(instance_1)
	add_child(instance_2)
	add_child(instance_3)

func _process(delta):
	_time_buildup += delta

func _exit_tree():
	thread.wait_to_finish()


func _on_thread_free():
	print(_time_buildup)
