extends Area2D

@export var ret: PackedScene

var collision_counts: int = 0

var timer = 1.0
var timer_enabled = 0.0

func reset():
	timer = 1.0
	timer_enabled = 0.0
	collision_counts = 0
	$MoveableItem.stop = false
	$MoveableItem.direction = Vector2i.ZERO
	$MoveableItem.new_tile = true
	set_process(true)
	show()

func remove():
	hide()
	set_process(false)
	get_tree().get_root().get_node("Root/GameScreen/Spawner").get_pool.append(self)
	get_tree().get_root().get_node("Root/GameScreen/Requests").remove_child(self)

func _process(delta: float):
	timer -= delta * timer_enabled
	
	if $MoveableItem.stop:
		var current_tile = $MoveableItem.current_tile
		var tiledata = $MoveableItem.bottom_tile_map.get_cell_tile_data(current_tile)
		if tiledata == null:
			$MoveableItem.stop = false
			$MoveableItem.new_tile = true
			timer_enabled = 0.0
			timer = 1.0
		elif tiledata.get_custom_data("Type") != "server":
			$MoveableItem.stop = false
			$MoveableItem.new_tile = true 
			timer_enabled = 0.0
			timer = 1.0

func _on_moveable_item_output() -> void:
	# NO YOU ARE NOT SUPPOSED TO PUT THIS IN AN OUTPUT
	# Lose a coin
	$/root/Root/GameScreen.add_coins(-40)
	$/root/Root/GameScreen.spawn_counts["get"] -= 1
	remove()

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
	remove()

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
	remove()

func _on_moveable_item_storage() -> void:
	$/root/Root/GameScreen.spawn_counts["get"] -= 1
	$/root/Root/GameScreen.add_coins(-40)
	remove()
