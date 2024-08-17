extends Node2D

@export var get_request: PackedScene

var coins: int = 0
var current_tile = Vector2i.ZERO

var alternative: int = 0

# keeps track of the number of backed up requests, if any of these
# exceed a certain threshold then you lose the game
var spawn_counts = {
	"spawn_get": 0,
	"return": 0
}

var max_counts = {
	"spawn_get": 200,
}

# once a timer runs out, reset it to these times
var reset_times = {
	"spawn_get": 5.0
}

var timers = {
	"spawn_get": 5.0
}

var input_pipes = []

const tile_atlas_positions = {
	"in": Vector2i(0, 0),
	"out": Vector2i(1,0),
	"splitter": Vector2i(0,1),
	"filter": Vector2i(1,1),
	"server": Vector2i(2,1),
	"deleter": Vector2i(3,1),
	"storage": Vector2i(0,2),
	"merger": Vector2i(3, 2),
	"conveyor": Vector2i(0,3),
	"conveyor_corner": Vector2i(2, 3),
}

const tile_costs = {
	"in": 500,
	"out": 50,
	"splitter": 100,
	"filter": 100,
	"server": 75,
	"deleter": 20,
	"storage":100,
	"merger": 100,
	"conveyor": 1,
	"conveyor_corner": 1,
}

func add_top_tile(id: String, x: int, y: int) -> void:
	var tiledata = $TopTileMapLayer.get_cell_tile_data(Vector2i(x, y))
	if id == "delete":
		if tiledata and len(input_pipes) == 1 and tiledata.get_custom_data("Type") == "input":
			return
		$TopTileMapLayer.erase_cell(Vector2i(x, y))
		$BottomTileMapLayer.erase_cell(Vector2i(x, y))
		input_pipes.erase(Vector2i(x, y))
		return
	if tiledata != null:
		return
	tiledata = $BottomTileMapLayer.get_cell_tile_data(Vector2i(x, y))
	if tiledata != null:
		return
	if spend_coins(tile_costs[id]):
		if id == "in":
			input_pipes.push_back(Vector2i(x, y))
		$BottomTileMapLayer.erase_cell(Vector2i(x, y))
		$BottomTileMapLayer.set_cell(Vector2i(x, y), 0, tile_atlas_positions[id], alternative)
		$TopTileMapLayer.set_cell(Vector2i(x, y), 0, tile_atlas_positions[id], alternative)
	else:
		print("insufficent funds")

func add_bottom_tile(id: String, x: int, y: int) -> void:
	var tiledata = $TopTileMapLayer.get_cell_tile_data(Vector2i(x, y))
	if tiledata != null:
		return
	tiledata = $BottomTileMapLayer.get_cell_tile_data(Vector2i(x, y))
	if tiledata != null:
		return
	if(coins >= tile_costs[id]):
		add_coins(-tile_costs[id])
		$TopTileMapLayer.erase_cell(Vector2i(x, y))
		$BottomTileMapLayer.set_cell(Vector2i(x, y), 0, tile_atlas_positions[id], alternative)
	else:
		print("insufficent funds")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_coins(100) # Makes sure the user starts with 100 coins
	for t in $TopTileMapLayer.get_used_cells_by_id(-1, tile_atlas_positions["in"]):
		input_pipes.push_back(t)
	
func update_timers(dt: float) -> void:
	# iterate through timers to update them
	for id in timers:
		timers[id] -= dt

func spawn() -> void:
	for id in timers:
		if timers[id] <= 0.0:
			if len(input_pipes) == 0:
				continue
			# Chose a random input pipe
			var rand_pipe = input_pipes[randi() % len(input_pipes)]
			var instance
			if id == "spawn_get":
				instance = get_request.instantiate()
			# Place the request in the world
			instance.position = $TopTileMapLayer.map_to_local(rand_pipe)
			$Requests.add_child(instance)
			timers[id] = reset_times[id]
			spawn_counts[id] += 1

func _unhandled_input(event):
	if (event.is_action_pressed("left_click")):
		var pos=$TopTileMapLayer.local_to_map(get_global_mouse_position())
		if ($HUD.get_selected() == "conveyor" or $HUD.get_selected() == "conveyor_corner"):
			add_bottom_tile($HUD.get_selected(), pos[0], pos[1])
		elif ($HUD.get_selected() != ""):
			add_top_tile($HUD.get_selected(), pos[0], pos[1])
	if (event.is_action_pressed("right_click")):
		alternative += 1
		$PreviewTileMapLayer.set_cell(current_tile, 0, tile_atlas_positions[$HUD.get_selected()], alternative)
		$PreviewTileMapLayer.fix_invalid_tiles()
		if $PreviewTileMapLayer.get_cell_alternative_tile(current_tile) == -1:
			alternative = 0
			$PreviewTileMapLayer.set_cell(current_tile, 0, tile_atlas_positions[$HUD.get_selected()], alternative)

func display_preview():
	if current_tile == $PreviewTileMapLayer.local_to_map(get_global_mouse_position()):
		return
	else:
		$PreviewTileMapLayer.erase_cell(current_tile)
		current_tile = $PreviewTileMapLayer.local_to_map(get_global_mouse_position())
		if ($HUD.get_selected() == "delete"):
			$PreviewTileMapLayer.material.set_shader_parameter("remove", true)
			$PreviewTileMapLayer.set_cell(current_tile, 0, Vector2i.ZERO)
		elif ($HUD.get_selected() != ""):
			$PreviewTileMapLayer.material.set_shader_parameter("remove", false)
			$PreviewTileMapLayer.set_cell(current_tile, 0, tile_atlas_positions[$HUD.get_selected()], alternative)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !get_tree().paused:
		update_timers(delta)
	display_preview()
	spawn()
	$HUD.update_text()
	

	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused

func spend_coins(coinAmt):
	if(coins>=coinAmt):
		coins-=coinAmt
		$HUD.publish_coins(coins)
		return true
	else:
		print("insufficent funds")
		return false

func add_coins(coinAmt):
	coins += coinAmt
	$HUD.publish_coins(coins)
