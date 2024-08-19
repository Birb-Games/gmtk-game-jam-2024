extends Node

@onready var game_screen = get_parent()

# once a timer runs out, reset it to these times
var reset_times = {
	"get": 3.0,
	"bad": 7.0,
	"download": 7.0,
}

# How fast each timer should speed up
var speed_up = {
	"get": 0.05,
	"bad": 0.07,
	"download": 0.2
}

var timers = {
	"get": 3.0,
	"bad": 180.0,
	"download": 300.0,
}

const GET_POOL_SIZE = 1200
const BAD_POOL_SIZE = 160
const DOWNLOAD_POOL_SIZE = 600
var get_pool = []
var bad_pool = []
var download_pool = []

func add(pool: Array, position: Vector2):
	if len(pool) == 0:
		return
	var instance = pool[-1]
	pool.pop_back()
	instance.reset()
	instance.position = position
	game_screen.get_node("Requests").add_child(instance)

func _ready():
	var instance
	for i in range(GET_POOL_SIZE):
		get_pool.append( game_screen.get_request.instantiate())
	for i in range(BAD_POOL_SIZE):
		bad_pool.append(game_screen.bad_request.instantiate())
	for i in range(DOWNLOAD_POOL_SIZE):
		download_pool.append(game_screen.download_request.instantiate())

func update_timers(dt: float) -> void:
	# iterate through timers to update them
	for id in timers:
		timers[id] -= dt

func spawn() -> void:
	for id in timers:
		if len(game_screen.input_pipes) == 0:
			continue
		if timers[id] <= 0.0:
			# Chose a random input pipe
			var rand_pipe = game_screen.input_pipes[randi() % len(game_screen.input_pipes)]
			var pos = game_screen.get_node("TopTileMapLayer").map_to_local(rand_pipe)
			if id == "get":
				add(get_pool, pos)
			elif id == "bad":
				add(bad_pool, pos)
			elif id == "download":
				add(download_pool, pos)
			
			timers[id] = reset_times[id]
			reset_times[id] = max(reset_times[id] - speed_up[id], 0.2)  
			game_screen.spawn_counts[id] += 1

func _process(delta: float):
	if !get_tree().paused:
		update_timers(delta)
	spawn()
	assert(game_screen.spawn_counts["get"] + len(get_pool) == GET_POOL_SIZE)
	assert(game_screen.spawn_counts["bad"] + len(bad_pool) == BAD_POOL_SIZE)
	assert(game_screen.spawn_counts["download"] + len(download_pool) == DOWNLOAD_POOL_SIZE)
