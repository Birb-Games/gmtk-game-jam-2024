extends Node2D

@export var get_request: PackedScene

var coins: int = 0

# keeps track of the number of backed up requests, if any of these
# exceed a certain threshold then you lose the game
var spawn_counts = {
	"spawn_get": 0
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
	"storage":Vector2i(0,2),
	"conveyor":Vector2i(0,3)

}

func add_top_tile(id: String, x: int, y: int) -> void:
	if id == "in":
		input_pipes.push_back(Vector2i(x, y))
	$BottomTileMapLayer.erase_cell(Vector2i(x, y))
	$TopTileMapLayer.set_cell(Vector2i(x, y), 0, tile_atlas_positions[id])

func add_bottom_tile(id: String, x: int, y: int) -> void:
	if id == "in":
		input_pipes.push_back(Vector2i(x, y))
	$TopTileMapLayer.erase_cell(Vector2i(x, y))
	$BottomTileMapLayer.set_cell(Vector2i(x, y), 0, tile_atlas_positions[id])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for t in $TopTileMapLayer.get_used_cells_by_id(-1, tile_atlas_positions["in"]):
		input_pipes.push_back(t)
	
func update_timers(dt: float) -> void:
	# iterate through timers to update them
	for id in timers:
		timers[id] -= dt

func spawn() -> void:
	for id in timers:
		if timers[id] <= 0.0:
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
		if ($HUD.get_selected() == "conveyor"):
			add_bottom_tile($HUD.get_selected(), pos[0], pos[1])
		elif ($HUD.get_selected() != ""):
			add_top_tile($HUD.get_selected(), pos[0], pos[1])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_timers(delta)
	spawn()

func add_coins(coinAmt):
	coins += coinAmt
	$HUD.publish_coins()

#process moveable items entering the output pipe
func process_output(item: Node2D):
	for g in item.get_groups():
		match g:
			StringName("get"): add_coins(10) #for now, just earn money
