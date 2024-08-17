extends Area2D

@export var ret: PackedScene

func _on_moveable_item_output() -> void:
	# NO YOU ARE NOT SUPPOSED TO PUT THIS IN AN OUTPUT
	# Lose a coin
	$/root/Root.add_coins(-5)
	queue_free()


func _on_moveable_item_server() -> void:
	var instance = ret.instantiate()
	instance.position = position
	$/root/Root/Requests.add_child(instance)
	queue_free()
