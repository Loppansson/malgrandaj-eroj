extends Button

var _is_pressed = false
@onready var origin = $"../Origin"

func _process(delta):
	if _is_pressed:
		position = get_global_mouse_position() - Vector2.ONE * 20
	
	var _relative_pos = position - origin.position as Vector2
	
	print(_direction(_relative_pos))
	
	
#	print(_relative_pos)
#	print(_normalized_relative_position(_relative_pos))
#	print(_pos_neg(_relative_pos))
#	print(_normalized_relative_position(_relative_pos), ", ", _direction(_relative_pos))


func _normalized_relative_position(_relative_pos: Vector2):
	return _relative_pos.normalized()


func _pos_neg(_relative_pos: Vector2):
	var _result: String
	if _relative_pos.x >= 0:
		_result += "x"
	else: 
		_result += "-x"
	
	if _relative_pos.y >= 0:
		_result += ", y"
	else: 
		_result += ", -y"
	
	return _result


func _direction(_relative_pos: Vector2):
	var _angle = rad_to_deg(_relative_pos.angle())
	pass
	
	if abs(_relative_pos.y) > abs(_relative_pos.x):
		if _relative_pos.y >= 0:
			return "y"
		else:
			return "-y"
	else:
		if _relative_pos.x >= 0:
			return "x"
		else:
			return "-x"
	return ""
	
#	if _angle > -180 and _angle <= -135:
#		return "-x"
#	elif _angle > -135 and _angle <= -45:
#		return "-y"
#	elif _angle > -45 and _angle <= 45:
#		return "x"
#	elif _angle > 45 and _angle <= 135:
#		return "y"
#	else:
#		return "-x"


func _on_button_up():
	_is_pressed = false


func _on_button_down():
	_is_pressed = true
