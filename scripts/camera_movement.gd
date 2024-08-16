extends Camera2D

class_name CustomCamera2D

@export var speed = 300
@export var zoom_speed = 0.03

func _unhandled_input(event):
	if(event.is_action_pressed("zoom_in")):
		zoom *= 1 + zoom_speed
	if(event.is_action_pressed("zoom_out")):
		zoom *= 1 / (1 + zoom_speed)

func _process(delta: float) -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	var zoom_inverse = Vector2(1.0 / zoom.x, 1.0 / zoom.y)
	position += input_direction * speed * zoom_inverse * delta
