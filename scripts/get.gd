extends Area2D

func _on_moveable_item_output() -> void:
	# NO YOU ARE NOT SUPPOSED TO PUT THIS IN AN OUTPUT
	# Lose a coin
	$/root/Root.add_coins(-1)
	queue_free()
