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
	$/root/Root/GameScreen.add_coins(-40)
	$/root/Root/GameScreen.spawn_counts["get"] -= 1
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
	$/root/Root/GameScreen/Requests.add_child(instance)
	$/root/Root/GameScreen.spawn_counts["get"] -= 1
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("return"):
		collision_counts += 1

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("return"):
		collision_counts -= 1

func _on_moveable_item_empty() -> void:
	var i = randi() % len($/root/Root/GameScreen.input_pipes)
	position = $/root/Root/GameScreen/TopTileMapLayer.map_to_local($/root/Root/GameScreen.input_pipes[i])
	timer = 1.0
	$MoveableItem.stop = false

func _on_moveable_item_deleter() -> void:
	$/root/Root/GameScreen.spawn_counts["get"] -= 1
	$/root/Root/GameScreen.add_coins(-40)
	queue_free()

func _on_moveable_item_storage() -> void:
	$/root/Root/GameScreen.spawn_counts["get"] -= 1
	$/root/Root/GameScreen.add_coins(-40)
	queue_free()
