extends Camera2D
class_name CustomCamera2D
# TODO: maybe add a setting to switch between moving content and moving camera (ie: invert movement)
var pos= Vector2(0,0)
@export var speed=1000

func _process(_delta) -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	pos+=input_direction*speed*_delta
	set_position(pos)
