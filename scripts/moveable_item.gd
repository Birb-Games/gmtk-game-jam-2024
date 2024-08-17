extends Node2D

@onready var top_tile_map: TileMapLayer = $/root/Root/TopTileMapLayer
@onready var bottom_tile_map: TileMapLayer = $/root/Root/BottomTileMapLayer
var current_top_tile_data: TileData
var current_bottom_tile_data: TileData
var current_tile: Vector2i
@onready var item: Node2D = get_parent()
var stop: bool = false

signal output
signal server
signal empty
signal deleter

var new_tile: bool = true

const speed = 40
var direction: Vector2i

var directions = [
	TileSet.CELL_NEIGHBOR_TOP_SIDE,
	TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,
	TileSet.CELL_NEIGHBOR_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_RIGHT_SIDE
]
# The conveyor belt for each corresponding 
var should_match = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

const direction_ids = {
	Vector2i.RIGHT: 0,
	Vector2i.LEFT: 1,
	Vector2i.DOWN: 2,
	Vector2i.UP: 3
}

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
	var neighbor = get_neighbor(get_conveyor_direction(current_bottom_tile_data))
	if neighbor == null and get_conveyor_direction(current_bottom_tile_data) != Vector2i.ZERO:
		blocked = true
	elif get_conveyor_direction(current_bottom_tile_data) != Vector2i.ZERO:
		var tile = bottom_tile_map.get_neighbor_cell(current_tile, neighbor)
		var tiledata = bottom_tile_map.get_cell_tile_data(tile)
	if neighbor != null:
		var tile = bottom_tile_map.get_neighbor_cell(current_tile, neighbor)
		var tiledata = bottom_tile_map.get_cell_tile_data(tile)
		var conveyor_dir = get_conveyor_direction(tiledata)
		var current_dir = get_conveyor_direction(current_bottom_tile_data)
		
		if !tiledata: #check bottom, then top
			tile = top_tile_map.get_neighbor_cell(current_tile, neighbor)
			tiledata = top_tile_map.get_cell_tile_data(tile)
			conveyor_dir = get_conveyor_direction(tiledata)
			if !tiledata:
				blocked = true
		
		if !blocked and tiledata.get_custom_data("Type") == "input":
			blocked = true
		
		if !blocked and tiledata.get_custom_data("Type") == "conveyor" and conveyor_dir != current_dir:
			blocked = true
		
		var current_id = direction_ids[current_dir]
		if !blocked and tiledata.get_custom_data("Type") == "conveyor_corner":
			var id = tiledata.get_custom_data("alternate_id")
			blocked = corner_lookup[current_id][id] == 0
	
	if !blocked:
		direction = get_conveyor_direction(current_bottom_tile_data)
	else:
		direction = Vector2i.ZERO

func move_on_conveyor_corner():
	var blocked = false
	var neighbor = get_neighbor(get_conveyor_direction(current_bottom_tile_data))
	if neighbor == null and get_conveyor_direction(current_bottom_tile_data) != Vector2i.ZERO:
		blocked = true
	elif get_conveyor_direction(current_bottom_tile_data) != Vector2i.ZERO:
		var tile = bottom_tile_map.get_neighbor_cell(current_tile, neighbor)
		var tiledata = bottom_tile_map.get_cell_tile_data(tile)
		var conveyor_dir = get_conveyor_direction(tiledata)
		
		if !tiledata:
			blocked = true
			
		if !blocked and tiledata.get_custom_data("Type") == "input":
			blocked = true
		
		if !blocked and tiledata.get_custom_data("Type") == "conveyor_corner":
			var current_id = current_bottom_tile_data.get_custom_data("alternate_id")
			var id = tiledata.get_custom_data("alternate_id")
			if corner_lookup[current_id][id] == 0:
				blocked = true
		
		if !blocked and tiledata.get_custom_data("Type") == "conveyor":
			blocked = get_conveyor_direction(tiledata) != get_conveyor_direction(current_bottom_tile_data)
	
	if !blocked:
		direction = get_conveyor_direction(current_bottom_tile_data)
	else:
		direction = Vector2i.ZERO

func push_in_random_dir():
	var possible_directions = [false, false, false, false] #up down left right
	for i in range(len(directions)):
		var dir = directions[i]
		var tile = bottom_tile_map.get_neighbor_cell(current_tile, dir)
		var tiledata = bottom_tile_map.get_cell_tile_data(tile)
		if !tiledata:
			continue
		var conveyor_dir = get_conveyor_direction(tiledata)
		if tiledata.get_custom_data("Type") == "conveyor":
			possible_directions[i] = conveyor_dir == should_match[i]
			continue
		if tiledata.get_custom_data("Type") == "conveyor_corner":
			var direction_id = direction_ids[should_match[i]]
			var id = tiledata.get_custom_data("alternate_id")
			possible_directions[i] = corner_lookup[id][direction_id] == 1
			continue
	direction = get_random_direction(possible_directions)
	

func update_based_on_tile():
	current_bottom_tile_data = bottom_tile_map.get_cell_tile_data(current_tile)
	if !current_bottom_tile_data and !current_top_tile_data:
		empty.emit()
		direction = Vector2i.ZERO
		return
		
	if !new_tile:
		return
	
	if current_bottom_tile_data and new_tile:
		match current_bottom_tile_data.get_custom_data("Type"):
			"conveyor":
				move_on_conveyor()
			"conveyor_corner":
				move_on_conveyor_corner()
			"input":
				push_in_random_dir()
			"output":
				output.emit()
			"server":
				push_in_random_dir()
				server.emit()
			"splitter":
				direction = get_random_direction([false, true, false, true])
			"deleter":
				deleter.emit()
			_:
				empty.emit()
				direction = Vector2i.ZERO

func _process(delta: float) -> void:
	current_tile = top_tile_map.local_to_map(top_tile_map.to_local(item.position))
	new_tile = item.position.round() == top_tile_map.to_global(top_tile_map.map_to_local(current_tile))
	
	current_top_tile_data = top_tile_map.get_cell_tile_data(current_tile)
	current_bottom_tile_data = bottom_tile_map.get_cell_tile_data(current_tile)
	
	if (!current_bottom_tile_data and !current_top_tile_data): #stops the item immediately if it leaves the tileset
		direction = Vector2i.ZERO
	
	update_based_on_tile()
	
	if !stop:
		item.position += direction * speed * delta
	if (new_tile):
		new_tile = false

#return a direction based on an array containing which directions are valid
#the array should have 4 booleans: up, down, left, and right availability
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
