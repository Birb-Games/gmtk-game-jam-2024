extends Node

@onready var game_screen = get_parent()

var time = 0

const starting_reset_times = {
	"get": 4.0,
	"bad": 6.0,
	"download": 7.0,
}

# lower is faster spawning
const timer_shrink_rates = {
	"get": 4,
	"bad": 5,
	"download": 4.5
}

# once a timer runs out, reset it to these times
var reset_times = {
	"get": 4.0,
	"bad": 6.0,
	"download": 7.0,
}

var timers = {
	"get": 3.0,
	"bad": 90.0,
	"download": 180.0,
}

func add(scene: PackedScene, position: Vector2):
	var instance = scene.instantiate()
	instance.position = position
	game_screen.get_node("Requests").add_child(instance)

func update_timers(dt: float) -> void:
	# iterate through timers to update them
	for id in timers:
		timers[id] -= dt

func update_reset_times(dt: float): #difficulty scaling
	time += dt * 60.0
	for id in timers:
		reset_times[id] = starting_reset_times[id] * pow(1 - pow(10, -timer_shrink_rates[id]), time) #https://www.desmos.com/calculator/efsgwweud1

func spawn() -> void:
	for id in timers:
		if len(game_screen.input_pipes) == 0:
			continue
		if timers[id] <= 0.0:
			# Chose a random input pipe
			var rand_pipe = game_screen.input_pipes[randi() % len(game_screen.input_pipes)]
			var pos = game_screen.get_node("TopTileMapLayer").map_to_local(rand_pipe)
			if id == "get":
				add(game_screen.get_request, pos)
			elif id == "bad":
				add(game_screen.bad_request, pos)
			elif id == "download":
				add(game_screen.download_request, pos)
			
			timers[id] = reset_times[id]
			game_screen.spawn_counts[id] += 1

func _process(delta: float):
	if !get_tree().paused:
		update_timers(delta)
		update_reset_times(delta)
	spawn()
