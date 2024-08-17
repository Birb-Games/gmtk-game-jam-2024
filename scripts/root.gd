extends Node2D

@export var get_request: PackedScene

var coins: int = 0

# keeps track of the number of backed up requests, if any of these
# exceed a certain threshold then you lose the game
var spawn_counts = {
	"spawn_get": 0,
	"return": 0
}

# once a timer runs out, reset it to these times
var reset_times = {
	"spawn_get": 5.0
}

var timers = {
	"spawn_get": 1.0
}

var input_pipes = []

const tile_atlas_positions = {
	"in": Vector2i(0, 0),
	"out": Vector2i(1,0),
	"splitter": Vector2i(0,1),
	"filter": Vector2i(1,1),
	"server": Vector2i(2,1),
	"compressor": Vector2i(3,1),
	"storage": Vector2i(0,2),
	"belt": Vector2i(0,3),
	"conveyor_corner": Vector2i(2, 3)
}

const tile_costs = {
	"in": 150,
	"out": 50,
	"splitter": 100,
	"filter": 100,
	"server": 100,
	"compressor": 100,
	"storage":100,
	"belt":10,
	"conveyor_corner":10,
}

func add_tile_no_cost(id: String, x: int, y: int) -> void:
	if id == "delete":
		$TileMapLayer.erase_cell(Vector2i(x, y))
		return
	if id == "in":
		input_pipes.push_back(Vector2i(x, y))
	$TileMapLayer.set_cell(Vector2i(x, y), 0, tile_atlas_positions[id], 0)

func add_tile(id: String, x: int, y: int) -> void:
	if id == "delete":
		$TileMapLayer.erase_cell(Vector2i(x, y))
		return
	if $TileMapLayer.get_cell_tile_data(Vector2i(x, y)) != null:
		return
		
	if id == "in":
		input_pipes.push_back(Vector2i(x, y))
	if(coins>=tile_costs[id]):
		add_coins(-tile_costs[id])
		$TileMapLayer.set_cell(Vector2i(x, y), 0, tile_atlas_positions[id], 0)
	else:
		print("insufficent funds")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_coins(100) # Makes sure the user starts with 100 coins
	add_tile_no_cost("in", 1, 1)
	
func update_timers(dt: float) -> void:
	# iterate through timers to update them
	for id in timers:
		timers[id] -= dt

func spawn() -> void:
	var tilemap_sz: float = $TileMapLayer.tile_set.tile_size.x
	for id in timers:
		if timers[id] <= 0.0:
			# Chose a random input pipe
			var rand_pipe = input_pipes[randi() % len(input_pipes)]
			var instance
			if id == "spawn_get":
				instance = get_request.instantiate()
			var x: float = tilemap_sz * rand_pipe.x + tilemap_sz / 2.0
			var y: float = tilemap_sz * rand_pipe.y + tilemap_sz / 2.0
			# Place the request in the world
			instance.position = Vector2(x, y)
			$Requests.add_child(instance)
			timers[id] = reset_times[id]
			spawn_counts[id] += 1

func _unhandled_input(event):
	if(event.is_action_pressed("left_click")):
		var pos=$TileMapLayer.local_to_map(get_global_mouse_position())
		if($HUD.get_selected()!=""):
			add_tile($HUD.get_selected(), pos[0], pos[1])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_timers(delta)
	spawn()

func add_coins(coinAmt):
	coins += coinAmt
	$HUD.publish_coins(coins)
