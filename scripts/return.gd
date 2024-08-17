extends Area2D

var timer: float

func _ready():
	timer = 4.0
	$MoveableItem.stop = true

func _process(delta: float) -> void:
	timer -= delta
	if timer < 0.0:
		$MoveableItem.stop = false

func _on_moveable_item_output() -> void:
	$/root/Root.add_coins(10)
	queue_free()
