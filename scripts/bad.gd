extends Area2D

func _on_moveable_item_deleter() -> void:
	$/root/Root.spawn_counts["bad"] -= 1
	queue_free()

func _on_moveable_item_output() -> void:
	$/root/Root.spawn_counts["bad"] -= 1
	$/root/Root.add_coins(-10)
	queue_free()

func _on_moveable_item_server() -> void:
	$/root/Root.spawn_counts["bad"] -= 1
	$/root/Root.add_coins(-20)
	queue_free()

func _on_moveable_item_empty() -> void:
	$/root/Root.spawn_counts["bad"] -= 1
	$/root/Root.add_coins(-10)
	queue_free()
