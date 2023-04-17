extends MeshInstance3D

@onready var _x = $"../Node3D/-x"
@onready var x = $"../Node3D/x"
@onready var _y = $"../Node3D/-y"
@onready var y = $"../Node3D/y"
@onready var _z = $"../Node3D/-z"
@onready var z = $"../Node3D/z"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_x.hide()
	x.hide()
	_y.hide()
	y.hide()
	_z.hide()
	z.hide()
	
	match _direciton(position):
		"-x":
			_x.show()
		"x":
			x.show()
		"-y":
			_y.show()
		"y":
			y.show()
		"-z":
			_z.show()
		"z":
			z.show()
	

func _direciton(_relative_pos: Vector3):
	if abs(_relative_pos.x) >= abs(_relative_pos.y):
		if abs(_relative_pos.x) >= abs(_relative_pos.z):
			if _relative_pos.x > 0:
				return "x"
			else:
				return "-x"
	
	if abs(_relative_pos.y) >= abs(_relative_pos.x):
		if abs(_relative_pos.y) >= abs(_relative_pos.z):
			if _relative_pos.y > 0:
				return "y"
			else:
				return "-y"
	
	if abs(_relative_pos.z) >= abs(_relative_pos.x):
		if abs(_relative_pos.z) >= abs(_relative_pos.y):
			if _relative_pos.z > 0:
				return "z"
			else:
				return "-z"
	
	return ""
