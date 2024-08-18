extends Node2D

@onready var top_tile_map: TileMapLayer = $/root/Root/TopTileMapLayer
@onready var bottom_tile_map: TileMapLayer = $/root/Root/BottomTileMapLayer
var current_top_tile_data: TileData
var current_bottom_tile_data: TileData
var current_tile: Vector2i
@onready var item: Node2D = get_parent()
var stop: bool = false
var filter_direction: Array

signal output
signal server
signal empty
signal deleter
signal storage

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

const splitter_directions = [
	[ true, true, false, false ],
	[ true, true, false, false ],
	[ false, false, true, true ],
	[ false, false, true, true ]
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
		
		#if it's the complete opposite direction
		if !blocked and tiledata.get_custom_data("Type") == "merger" and conveyor_dir + current_dir == Vector2i.ZERO:
			blocked = true
		
		var current_id = direction_ids[current_dir]
		if !blocked and tiledata.get_custom_data("Type") == "conveyor_corner":
			var id = tiledata.get_custom_data("alternate_id")
			blocked = corner_lookup[current_id][id] == 0
		
		if !blocked and tiledata.get_custom_data("Type") == "splitter":
			# var id = tiledata.get_custom_data("alternate_id")
			blocked = tiledata.get_custom_data("alternate_id") != current_id

		if !blocked and (tiledata.get_custom_data("Type") == "green_filter" or tiledata.get_custom_data("Type") == "white_filter" or tiledata.get_custom_data("Type") == "blue_filter"):
			blocked = tiledata.get_custom_data("alternate_id") != current_id
	
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
		
		#if it's the complete opposite direction
		if !blocked and tiledata.get_custom_data("Type") == "merger" and conveyor_dir + get_conveyor_direction(current_bottom_tile_data) == Vector2i.ZERO:
			blocked = true
	
	if !blocked:
		direction = get_conveyor_direction(current_bottom_tile_data)
	else:
		direction = Vector2i.ZERO

enum FilterType {
	GREEN = 0,
	WHITE = 1,
	BLUE = 2,
}

#returns an array of unit `vector2i`s to indicate the direction of the input, colored output, and red output respectively
func get_filter_direction(tileData: TileData) -> Array:
	var data = [tileData.flip_h, tileData.flip_v, tileData.transpose]
	match data:
		[false, false, false]: return [Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]
		[false, true, false]: return [Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]
		[true, false, false]: return [Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
		[true, true, false]: return [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.UP]
		[false, false, true]: return [Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]
		[true, false, true]: return [Vector2i.UP, Vector2i.RIGHT, Vector2i.LEFT]
		[false, true, true]: return [Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		[true, true, true]: return [Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT]
	return [Vector2i.ZERO, Vector2i.ZERO, Vector2i.ZERO]
	
func move_on_filter(type: FilterType):
	#check which directions are valid
	var id = current_top_tile_data.get_custom_data("alternate_id")
	var possible: Array = splitter_directions[id].duplicate()
	for i in range(len(possible)):
		if possible[i]:
			var dir = directions[i]
			var tile = bottom_tile_map.get_neighbor_cell(current_tile, dir)
			var tiledata = bottom_tile_map.get_cell_tile_data(tile)
			if tiledata == null:
				possible[i] = false
				continue
			if tiledata.get_custom_data("Type") == "conveyor":
				var neighbor_dir = get_conveyor_direction(tiledata)
				possible[i] = neighbor_dir == should_match[i]
			elif tiledata.get_custom_data("Type") == "conveyor_corner":
				var neighbor_id = tiledata.get_custom_data("alternate_id")
				var dir_id = direction_ids[should_match[i]]
				possible[i] = corner_lookup[dir_id][neighbor_id] == 1         
			else:
				possible[i] = false

	#find which direction is requested based on filter
	filter_direction = get_filter_direction(current_top_tile_data)
	for g in item.get_groups():
		match g:
			"get": 
				if type == FilterType.GREEN:
					direction = filter_direction[1]
				else:
					direction = filter_direction[2]
			"return":
				if type == FilterType.WHITE:
					direction = filter_direction[1]
				else:
					direction = filter_direction[2]
	
	if !((possible[0] and direction == Vector2i.UP) or (possible[1] and direction == Vector2i.DOWN) or (possible[2] and direction == Vector2i.LEFT) or (possible[3] and direction == Vector2i.RIGHT)):
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
			possible_directions[i] = corner_lookup[direction_id][id] == 1
			continue
	direction = get_random_direction(possible_directions)

func move_on_splitter():
	var id = current_top_tile_data.get_custom_data("alternate_id")
	var possible = splitter_directions[id].duplicate()
	for i in range(len(possible)):
		if possible[i]:
			var dir = directions[i]
			var tile = bottom_tile_map.get_neighbor_cell(current_tile, dir)
			var tiledata = bottom_tile_map.get_cell_tile_data(tile)
			if tiledata == null:
				possible[i] = false
				continue
			if tiledata.get_custom_data("Type") == "conveyor":
				var neighbor_dir = get_conveyor_direction(tiledata)
				possible[i] = neighbor_dir == should_match[i]
			elif tiledata.get_custom_data("Type") == "conveyor_corner":
				var neighbor_id = tiledata.get_custom_data("alternate_id")
				var dir_id = direction_ids[should_match[i]]
				possible[i] = corner_lookup[dir_id][neighbor_id] == 1         
			else:
				possible[i] = false
	direction = get_random_direction(possible)

func update_based_on_tile():
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
				move_on_splitter()
			"merger":
				move_on_conveyor() #acts exactly like a conveyor once the item's on there
			"deleter":
				deleter.emit()
			"storage":
				push_in_random_dir()
				storage.emit()
			"green_filter":
				move_on_filter(FilterType.GREEN)
			"white_filter":
				move_on_filter(FilterType.WHITE)
			"blue_filter":
				move_on_filter(FilterType.BLUE)
			_:
				empty.emit()
				direction = Vector2i.ZERO

func _process(delta: float) -> void:
	current_tile = top_tile_map.local_to_map(top_tile_map.to_local(item.position))
	var tile_map_pos = top_tile_map.to_global(top_tile_map.map_to_local(current_tile))
	var diff = item.position.round() - tile_map_pos
	new_tile = diff.length() <= 1.0
	
	current_top_tile_data = top_tile_map.get_cell_tile_data(current_tile)
	current_bottom_tile_data = bottom_tile_map.get_cell_tile_data(current_tile)
	
	update_based_on_tile()
	
	if !stop:
		var d = direction * speed * delta * 10.0 
		var travel_len = d.length()
		if travel_len > 0.8:
			d *= 0.8 / travel_len
		item.position += d
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
