extends Area2D

var timer: float
var value: int = 10

func _ready():
	timer = 3.0
	$MoveableItem.stop = true
	$/root/Root.spawn_counts["return"] += 1

func _process(delta: float) -> void:
	timer -= delta
	if timer < 0.0:
		$MoveableItem.stop = false

func _on_moveable_item_output() -> void:
	$/root/Root.add_coins(value)
	$/root/Root.spawn_counts["return"] -= 1
	queue_free()

func _on_moveable_item_empty() -> void:
	$/root/Root.spawn_counts["return"] -= 1
	queue_free()

func _on_moveable_item_deleter() -> void:
	$/root/Root.spawn_counts["return"] -= 1
	queue_free()
