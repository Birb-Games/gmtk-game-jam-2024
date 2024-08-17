extends Area2D

@export var ret: PackedScene

var collision_counts: int = 0

var timer = 1.0
var timer_enabled = 0.0

func _process(delta: float):
	timer -= delta * timer_enabled

func _on_moveable_item_output() -> void:
	# NO YOU ARE NOT SUPPOSED TO PUT THIS IN AN OUTPUT
	# Lose a coin
	$/root/Root.add_coins(-5)
	$/root/Root.spawn_counts["spawn_get"] -= 1
	queue_free()

func _on_moveable_item_server() -> void:
	$MoveableItem.stop = true
	timer_enabled = float(collision_counts == 0)
	if collision_counts > 0:
		timer = 4.0
	if collision_counts > 0 or timer > 0.0:
		return
	var instance = ret.instantiate()
	instance.position = position
	$/root/Root/Requests.add_child(instance)
	$/root/Root.spawn_counts["spawn_get"] -= 1
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("return"):
		collision_counts += 1

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("return"):
		collision_counts -= 1

func _on_moveable_item_empty() -> void:
	$/root/Root.add_coins(-5)
	queue_free()
