extends Area2D

@export var good_file: PackedScene

var collision_count: int = 0
var timer: float = 5.0
var timer_enabled: float = 0.0

func reset():
	timer = 5.0
	timer_enabled = 0.0
	collision_count = 0
	$MoveableItem.stop = false
	$MoveableItem.direction = Vector2i.ZERO
	$MoveableItem.new_tile = true
	set_process(true)
	show()

func remove():
	hide()
	set_process(false)
	get_tree().get_root().get_node("Root/GameScreen/Spawner").download_pool.append(self)
	get_tree().get_root().get_node("Root/GameScreen/Requests").remove_child(self)

func _process(delta):
	timer -= timer_enabled * delta
	
	if $MoveableItem.stop:
		var current_tile = $MoveableItem.current_tile
		var tiledata = $MoveableItem.bottom_tile_map.get_cell_tile_data(current_tile)
		if tiledata == null:
			$MoveableItem.stop = false
			$MoveableItem.new_tile = true
			timer_enabled = 0.0
			timer = 1.0
		elif tiledata.get_custom_data("Type") != "storage":
			$MoveableItem.stop = false
			$MoveableItem.new_tile = true 
			timer_enabled = 0.0
			timer = 1.0

func _on_moveable_item_empty() -> void:
	var i = randi() % len($/root/Root/GameScreen.input_pipes)
	position = $/root/Root/GameScreen/TopTileMapLayer.map_to_local($/root/Root/GameScreen.input_pipes[i])
	timer = 5.0
	$MoveableItem.stop = false

func _on_moveable_item_deleter() -> void:
	$/root/Root/GameScreen.spawn_counts["download"] -= 1
	$/root/Root/GameScreen.add_coins(-40)
	remove()

func _on_moveable_item_output() -> void:
	$/root/Root/GameScreen.spawn_counts["download"] -= 1
	$/root/Root/GameScreen.add_coins(-40)
	remove()

func _on_moveable_item_server() -> void:
	$/root/Root/GameScreen.spawn_counts["download"] -= 1
	$/root/Root/GameScreen.add_coins(-40)
	remove()

func _on_moveable_item_storage() -> void:
	$MoveableItem.stop = true
	
	if collision_count > 0:
		timer = 7.0
		timer_enabled = 0.0
		return
	timer_enabled = 1.0
	if timer > 0.0:
		return
	
	$/root/Root/GameScreen.spawn_counts["download"] -= 1
	
	var randval = randi() % 4
	if randval != 0:
		var instance = good_file.instantiate()
		instance.modulate = Color(0.8, 0.8, 0.8)
		instance.value = 40
		$/root/Root/GameScreen.spawn_counts["return"] += 1
		instance.position = position
		$/root/Root/GameScreen/Requests.add_child(instance)
	else:
		var spawner = $/root/Root/GameScreen/Spawner
		spawner.add(spawner.bad_pool, position)
		$/root/Root/GameScreen.spawn_counts["bad"] += 1
	
	remove()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bad") or area.is_in_group("return"):
		collision_count += 1

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("bad") or area.is_in_group("return"):
		collision_count -= 1
