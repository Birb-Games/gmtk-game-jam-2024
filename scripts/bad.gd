extends Area2D

func _on_moveable_item_deleter() -> void:
	$/root/Root/GameScreen.spawn_counts["bad"] -= 1
	queue_free()

func _on_moveable_item_output() -> void:
	$/root/Root/GameScreen.spawn_counts["bad"] -= 1
	$/root/Root/GameScreen.add_coins(-320)
	queue_free()

func _on_moveable_item_server() -> void:
	$/root/Root/GameScreen.spawn_counts["bad"] -= 1
	$/root/Root/GameScreen.add_coins(-80)
	queue_free()

func _on_moveable_item_empty() -> void:
	var i = randi() % len($/root/Root/GameScreen.input_pipes)
	position = $/root/Root/GameScreen/TopTileMapLayer.map_to_local($/root/Root/GameScreen.input_pipes[i])
	$MoveableItem.stop = false
