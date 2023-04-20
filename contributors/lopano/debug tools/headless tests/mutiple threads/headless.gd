extends Node

signal thread_free
@export var child: PackedScene
var thread_count := 3 as int
var threads_in_use := 0 as int
var threads: Array[Thread]
var threads_use_state: Array[bool]

var _time_buildup := 0.0

func _ready():
	#-- For Headles --------------------------------------------------#
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
	#-----------------------------------------------------------------#
	
	
	for i in range(thread_count):
		threads.append(Thread.new())
		threads_use_state.append(false)
	
	var instance_1 = child.instantiate()
	var instance_2 = child.instantiate()
	var instance_3 = child.instantiate()
	
	add_child(instance_1)
	add_child(instance_2)
	add_child(instance_3)

func _process(delta):
	_time_buildup += delta

func _exit_tree():
	for thread in threads:
		thread.wait_to_finish()

func _on_thread_free():
	prints("(", _time_buildup, ") threads_in_use:", threads_in_use)
	print()
