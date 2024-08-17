extends Node2D

signal item_outputted

@onready var top_tile_map: TileMapLayer = $/root/Root/TopTileMapLayer
@onready var bottom_tile_map: TileMapLayer = $/root/Root/BottomTileMapLayer
var current_top_tile_data: TileData
var current_bottom_tile_data: TileData
var current_tile: Vector2i
@onready var item: Node2D = get_parent()
var is_new_tile: bool = true

const speed = 50
var direction: Vector2i

func _ready():
	pass

func _process(delta: float) -> void:
	current_tile = top_tile_map.local_to_map(top_tile_map.to_local(item.global_position))
	is_new_tile = item.global_position.round() == top_tile_map.to_global(top_tile_map.map_to_local(current_tile))
	
	if (is_new_tile):
		current_top_tile_data = top_tile_map.get_cell_tile_data(current_tile)
		current_bottom_tile_data = bottom_tile_map.get_cell_tile_data(current_tile)
		if current_bottom_tile_data and current_bottom_tile_data.get_custom_data("Type") == "conveyor":
			if !current_bottom_tile_data.flip_h and !current_bottom_tile_data.transpose:
				direction = Vector2i.RIGHT
			elif current_bottom_tile_data.flip_h and !current_bottom_tile_data.transpose:
				direction = Vector2i.LEFT
			elif !current_bottom_tile_data.flip_v and current_bottom_tile_data.transpose:
				direction = Vector2i.DOWN
			elif current_bottom_tile_data.flip_v and current_bottom_tile_data.transpose:
				direction = Vector2i.UP
		if current_top_tile_data:
			match current_top_tile_data.get_custom_data("Type"):
				"input":
					var possible_directions = [false, false, false, false] #up down left right
					if bottom_tile_map.get_cell_tile_data(bottom_tile_map.get_neighbor_cell(current_tile, TileSet.CELL_NEIGHBOR_TOP_SIDE)) and bottom_tile_map.get_cell_tile_data(bottom_tile_map.get_neighbor_cell(current_tile, TileSet.CELL_NEIGHBOR_TOP_SIDE)).get_custom_data("Type") == "conveyor":
						possible_directions[0] = true
					if bottom_tile_map.get_cell_tile_data(bottom_tile_map.get_neighbor_cell(current_tile, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)) and bottom_tile_map.get_cell_tile_data(bottom_tile_map.get_neighbor_cell(current_tile, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)).get_custom_data("Type") == "conveyor":
						possible_directions[1] = true
					if bottom_tile_map.get_cell_tile_data(bottom_tile_map.get_neighbor_cell(current_tile, TileSet.CELL_NEIGHBOR_LEFT_SIDE)) and bottom_tile_map.get_cell_tile_data(bottom_tile_map.get_neighbor_cell(current_tile, TileSet.CELL_NEIGHBOR_LEFT_SIDE)).get_custom_data("Type") == "conveyor":
						possible_directions[2] = true
					if bottom_tile_map.get_cell_tile_data(bottom_tile_map.get_neighbor_cell(current_tile, TileSet.CELL_NEIGHBOR_RIGHT_SIDE)) and bottom_tile_map.get_cell_tile_data(bottom_tile_map.get_neighbor_cell(current_tile, TileSet.CELL_NEIGHBOR_RIGHT_SIDE)).get_custom_data("Type") == "conveyor":
						possible_directions[3] = true
					direction = get_random_direction(possible_directions)
				"output":
					item_outputted.connect($/root/Root.process_output)
					item_outputted.emit(item)
					item.queue_free()
				_:
					direction = Vector2i.ZERO
	
	item.position += direction * speed * delta
	if (is_new_tile):
		is_new_tile = false

#return a direction based on an array containing which directions are valid
func get_random_direction(options: Array) -> Vector2i:
	var true_indices = []

	# Collect indices where the value is true
	for i in range(options.size()):
		if options[i]:
			true_indices.append(i)

	# Check if there are any true values
	if true_indices.size() == 0:
		return Vector2i.ZERO

	# Select a random direction from the true indices
	match true_indices[randi() % true_indices.size()]:
		0: return Vector2i.UP
		1: return Vector2i.DOWN
		2: return Vector2i.LEFT
		3: return Vector2i.RIGHT
		_: return Vector2i.ZERO
