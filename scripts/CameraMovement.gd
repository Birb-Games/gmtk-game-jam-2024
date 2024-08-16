extends Camera2D
class_name CustomCamera2D
# TODO: maybe add a setting to switch between moving content and moving camera (ie: invert movement)
var pos= Vector2(0,0)
@export var speed=1000
@export var zoom_speed=0.03
func _unhandled_input(event):
	if(event.is_action_pressed("zoom_in")):
		zoom*=1+zoom_speed
	if(event.is_action_pressed("zoom_out")):
		zoom*=1/(1+zoom_speed)

func _process(_delta) -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	pos+=input_direction*speed*_delta
	set_position(pos)
