extends Control

@export var next_screen: PackedScene

func _on_button_pressed() -> void:
	$/root/Root.add_child(next_screen.instantiate())
	queue_free()
