extends Node

@onready var parent = get_parent()

var _is_set_up = false

func _ready():
	if not _is_set_up:
		if not parent.using_thread:
			_start_thread()
		else:
			parent.connect(
					"thread_free",
					Callable(
							self,
							"_thread_freed"
					)
			)


func _thread_freed():
	if not parent.using_thread and not _is_set_up:
		_start_thread()


func _start_thread():
	parent.thread.start(
			Callable(
					self, 
					"_thread_function_with_return"
			).bind("Wafflecopter")
	)
	parent.using_thread = true


func _thread_function_with_return(userdata):
	var _thread_created_array := []
	for i in range(5):
		_thread_created_array.append(i)
	
	var x = 0
	for i in range(100000000):
		x += i
	
	_thread_created_array.append(userdata)
	
	call_deferred("_thread_task_finished", _thread_created_array)


func _thread_task_finished(_returned_array):
	parent.thread.wait_to_finish()
	parent.using_thread = false
	_is_set_up = true
	parent.emit_signal("thread_free")
	print(_returned_array)
