extends Node

@onready var parent = get_parent()

var _is_set_up = false
var _used_thread_index := -1 as int

func _ready():
	if not _is_set_up:
		if parent.threads_in_use < parent.thread_count:
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
	if parent.threads_in_use < parent.thread_count and not _is_set_up:
		_start_thread()


func _start_thread():
	for thread_i in range(len(parent.threads)):
		if (
				not parent.threads_use_state[thread_i]
				and _used_thread_index == -1
		):
			parent.threads[thread_i].start(
					Callable(
							self, 
							"_thread_function_with_return"
					).bind("Wafflecopter")
			)
			parent.threads_use_state[thread_i] = true
			parent.threads_in_use += 1
			
			_used_thread_index = thread_i
			
			print("Thread ", thread_i, " started.")
			break


func _thread_function_with_return(userdata):
	var _thread_created_array := []
	for i in range(5):
		_thread_created_array.append(i)
	
	var x = 0
	for i in range(50000000):
		x += i
	
	_thread_created_array.append(userdata)
	
	call_deferred("_thread_task_finished", _thread_created_array)


func _thread_task_finished(_returned_array):
	parent.threads[_used_thread_index].wait_to_finish()
	
	parent.threads_use_state[_used_thread_index] = false
	parent.threads_in_use -= 1
	prints(
			"Thread", 
			_used_thread_index, 
			"finnished and returned", 
			_returned_array
	)
	parent.emit_signal("thread_free")
	
	_is_set_up = true
	_used_thread_index = -1
