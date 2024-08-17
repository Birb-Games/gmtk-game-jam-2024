extends Node2D

@onready var tile_map: TileMapLayer = $/root/Root/TileMapLayer
var current_tile_data: TileData
var current_tile: Vector2i
@onready var item: Node2D = get_parent()
var new_tile: bool = true

signal output

const speed = 50
var direction: Vector2i

var directions = [
	TileSet.CELL_NEIGHBOR_TOP_SIDE,
	TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,
	TileSet.CELL_NEIGHBOR_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_RIGHT_SIDE
]
# The conveyor belt for each corresponding 
var should_match = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

# if row, column is 1 then they can connect
# otherwise, no
const corner_lookup = [
	[ 0, 0, 1, 1, 0, 0, 0, 0 ],
	[ 0, 0, 0, 0, 0, 0, 1, 1 ],
	[ 1, 1, 0, 0, 0, 0, 0, 0 ],
	[ 0, 0, 0, 0, 1, 1, 0, 0 ],
	[ 0, 0, 1, 1, 0, 0, 0, 0 ],
	[ 0, 0, 0, 0, 0, 0, 1, 1 ],
	[ 1, 1, 0, 0, 0, 0, 0, 0 ],
	[ 0, 0, 0, 0, 1, 1, 0, 0 ],
]

func get_neighbor(dir: Vector2i):
	if dir == Vector2i.UP:
		return TileSet.CELL_NEIGHBOR_TOP_SIDE
	elif dir == Vector2i.DOWN:
		return TileSet.CELL_NEIGHBOR_BOTTOM_SIDE
	elif dir == Vector2i.LEFT:
		return TileSet.CELL_NEIGHBOR_LEFT_SIDE
	elif dir == Vector2i.RIGHT:
		return TileSet.CELL_NEIGHBOR_RIGHT_SIDE
	return null

func get_conveyor_direction(tiledata):
	var d = Vector2i.ZERO
	if !tiledata:
		return d
	if !tiledata.flip_h and !tiledata.transpose:
		d = Vector2i.RIGHT
	elif tiledata.flip_h and !tiledata.transpose:
		d = Vector2i.LEFT
	elif !tiledata.flip_v and tiledata.transpose:
		d = Vector2i.DOWN
	elif tiledata.flip_v and tiledata.transpose:
		d = Vector2i.UP
	return d

func move_on_conveyor():
	var blocked = false
	var neighbor = get_neighbor(direction)
	if neighbor == null:
		blocked = true
	if neighbor != null:
		var tile = tile_map.get_neighbor_cell(current_tile, neighbor)
		var tiledata = tile_map.get_cell_tile_data(tile)
		var conveyor_dir = get_conveyor_direction(tiledata)
		
		if !tiledata:
			blocked = true
		
		if !blocked and tiledata.get_custom_data("Type") == "conveyor" and conveyor_dir != direction:
			blocked = true
		
		if !blocked and tiledata.get_custom_data("Type") == "conveyor_corner" and conveyor_dir == -direction:
			blocked = true
			
	if !blocked:
		direction = get_conveyor_direction(current_tile_data)
	else:
		direction = Vector2i.ZERO

func move_on_conveyor_corner():
	var blocked = false
	var neighbor = get_neighbor(get_conveyor_direction(current_tile_data))
	if neighbor == null and get_conveyor_direction(current_tile_data) != Vector2i.ZERO:
		blocked = true
	elif get_conveyor_direction(current_tile_data) != Vector2i.ZERO:
		var tile = tile_map.get_neighbor_cell(current_tile, neighbor)
		var tiledata = tile_map.get_cell_tile_data(tile)
		var conveyor_dir = get_conveyor_direction(tiledata)
		
		if !tiledata:
			blocked = true
		
		if !blocked and tiledata.get_custom_data("Type") == "conveyor_corner":
			var current_id = current_tile_data.get_custom_data("alternate_id")
			var id = tiledata.get_custom_data("alternate_id")
			if corner_lookup[current_id][id] == 0:
				blocked = true
		
		if tiledata.get_custom_data("Type") == "conveyor":
			blocked = get_conveyor_direction(tiledata) != get_conveyor_direction(current_tile_data)
			
	if !blocked:
		direction = get_conveyor_direction(current_tile_data)
	else:
		direction = Vector2i.ZERO

func update_based_on_tile():
	if !new_tile:
		return
	current_tile_data = tile_map.get_cell_tile_data(current_tile)
	if !current_tile_data:
		return
	match current_tile_data.get_custom_data("Type"):
		"conveyor":
			move_on_conveyor()
		"conveyor_corner":
			move_on_conveyor_corner()
		"input":
			var possible_directions = [false, false, false, false] #up down left right
			for i in range(len(directions)):
				var dir = directions[i]
				var tile = tile_map.get_neighbor_cell(current_tile, dir)
				var tiledata = tile_map.get_cell_tile_data(tile)
				if !tiledata:
					continue
				var conveyor_dir = get_conveyor_direction(tiledata)
				if tiledata.get_custom_data("Type") == "conveyor":
					possible_directions[i] = conveyor_dir == should_match[i]
					continue
				if tiledata.get_custom_data("Type") == "conveyor_corner":
					const direction_ids = {
						Vector2i.RIGHT: 0,
						Vector2i.LEFT: 1,
						Vector2i.DOWN: 2,
						Vector2i.UP: 3
					}
					var direction_id = direction_ids[should_match[i]]
					var id = tiledata.get_custom_data("alternate_id")
					possible_directions[i] = corner_lookup[id][direction_id] == 1
					continue
			direction = get_random_direction(possible_directions)
		"output":
			output.emit()
		_:
			direction = Vector2i.ZERO

func _process(delta: float) -> void:
	current_tile = tile_map.local_to_map(tile_map.to_local(item.position))
	new_tile = item.position.round() == tile_map.to_global(tile_map.map_to_local(current_tile))
	
	update_based_on_tile()
	
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
