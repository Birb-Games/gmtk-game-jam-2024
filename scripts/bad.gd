extends Area2D

func reset():
	$MoveableItem.stop = false
	$MoveableItem.direction = Vector2i.ZERO
	$MoveableItem.new_tile = true
	set_process(true)
	show()
	
func remove():
	hide()
	set_process(false)
	get_tree().get_root().get_node("Root/GameScreen/Spawner").bad_pool.append(self)
	get_tree().get_root().get_node("Root/GameScreen/Requests").remove_child(self)

func _on_moveable_item_deleter() -> void:
	$/root/Root/GameScreen.spawn_counts["bad"] -= 1
	remove()

func _on_moveable_item_output() -> void:
	$/root/Root/GameScreen.spawn_counts["bad"] -= 1
	$/root/Root/GameScreen.add_coins(-320)
	remove()

func _on_moveable_item_server() -> void:
	$/root/Root/GameScreen.spawn_counts["bad"] -= 1
	$/root/Root/GameScreen.add_coins(-80)
	remove()

func _on_moveable_item_empty() -> void:
	var i = randi() % len($/root/Root/GameScreen.input_pipes)
	position = $/root/Root/GameScreen/TopTileMapLayer.map_to_local($/root/Root/GameScreen.input_pipes[i])
	$MoveableItem.stop = false
