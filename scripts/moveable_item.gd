extends Node2D

@onready var tile_map: TileMapLayer = $/root/Root/TileMapLayer
var current_tile_data: TileData
var current_tile: Vector2i
@onready var item: Node2D = get_parent()
var new_tile: bool = true

signal output

const speed = 50
var direction: Vector2i

func _ready():
	pass

func _process(delta: float) -> void:
	current_tile = tile_map.local_to_map(tile_map.to_local(item.global_position))
	new_tile = item.global_position.round() == tile_map.to_global(tile_map.map_to_local(current_tile))
	
	if (new_tile):
		current_tile_data = tile_map.get_cell_tile_data(current_tile)
		if current_tile_data:
			match current_tile_data.get_custom_data("Type"):
				"conveyor":
					if !current_tile_data.flip_h and !current_tile_data.transpose:
						direction = Vector2i.RIGHT
					elif current_tile_data.flip_h and !current_tile_data.transpose:
						direction = Vector2i.LEFT
					elif !current_tile_data.flip_v and current_tile_data.transpose:
						direction = Vector2i.DOWN
					elif current_tile_data.flip_v and current_tile_data.transpose:
						direction = Vector2i.UP
				"input":
					var possible_directions = [false, false, false, false] #up down left right
					if tile_map.get_cell_tile_data(tile_map.get_neighbor_cell(current_tile, TileSet.CELL_NEIGHBOR_TOP_SIDE)) and tile_map.get_cell_tile_data(tile_map.get_neighbor_cell(current_tile, TileSet.CELL_NEIGHBOR_TOP_SIDE)).get_custom_data("Type") == "conveyor":
						possible_directions[0] = true
					if tile_map.get_cell_tile_data(tile_map.get_neighbor_cell(current_tile, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)) and tile_map.get_cell_tile_data(tile_map.get_neighbor_cell(current_tile, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)).get_custom_data("Type") == "conveyor":
						possible_directions[1] = true
					if tile_map.get_cell_tile_data(tile_map.get_neighbor_cell(current_tile, TileSet.CELL_NEIGHBOR_LEFT_SIDE)) and tile_map.get_cell_tile_data(tile_map.get_neighbor_cell(current_tile, TileSet.CELL_NEIGHBOR_LEFT_SIDE)).get_custom_data("Type") == "conveyor":
						possible_directions[2] = true
					if tile_map.get_cell_tile_data(tile_map.get_neighbor_cell(current_tile, TileSet.CELL_NEIGHBOR_RIGHT_SIDE)) and tile_map.get_cell_tile_data(tile_map.get_neighbor_cell(current_tile, TileSet.CELL_NEIGHBOR_RIGHT_SIDE)).get_custom_data("Type") == "conveyor":
						possible_directions[3] = true
					direction = get_random_direction(possible_directions)
				"output":
					output.emit()
				_:
					direction = Vector2i.ZERO
	
	item.position += direction * speed * delta
	if (new_tile):
		new_tile = false

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
