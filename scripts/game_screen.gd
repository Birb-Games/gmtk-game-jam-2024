extends Node2D

@export var get_request: PackedScene
@export var bad_request: PackedScene
@export var download_request: PackedScene

var coins: int = 0 
const SALE_PERCENT_RECOVERED: float = 0.25 #the amount of value recouped when you sell something
var current_tile = Vector2i.ZERO
var is_game_over: bool = false

var alternative: int = 0

#used for increasing max num of files allowed onscreen
var max_servers_placed: int = 0
var current_servers_placed: int = 0
var max_storages_placed: int = 0
var current_storages_placed: int = 0

# keeps track of the number of backed up requests, if any of these
# exceed a certain threshold then you lose the game
var spawn_counts = {
	"get": 0,
	"return": 0,
	"bad": 0,
	"download": 0,
}

var max_counts = {
	"get": 256,
	"bad": 128,
	"download": 128,
}

var input_pipes = []

const tile_atlas_positions = {
	"in": Vector2i(0, 0),
	"out": Vector2i(1,0),
	"splitter": Vector2i(0,1),
	"green_filter": Vector2i(1,1),
	"white_filter": Vector2i(1,2),
	"blue_filter": Vector2i(2,2),
	"server": Vector2i(2,1),
	"deleter": Vector2i(3,1),
	"storage": Vector2i(0,2),
	"merger": Vector2i(3, 2),
	"bridge": Vector2i(3,0),
	"conveyor": Vector2i(0,3),
	"conveyor_corner": Vector2i(2, 3),
}

var tile_costs = {
	"in": 10000,
	"out": 100,
	"green_filter": 60,
	"white_filter": 60,
	"blue_filter": 60,
	"server": 40,
	"splitter": 30,
	"deleter": 20,
	"storage": 80,
	"merger": 60,
	"bridge": 30,
	"conveyor": 1,
	"conveyor_corner": 1,
}

const COST_MULTIPLIER: int = 16

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	add_coins(100) # Makes sure the user starts with 100 coins
	for t in $TopTileMapLayer.get_used_cells_by_id(-1, tile_atlas_positions["in"]):
		input_pipes.push_back(t)

func add_top_tile(id: String, x: int, y: int) -> void:
	var tiledata = $TopTileMapLayer.get_cell_tile_data(Vector2i(x, y))
	if id == "delete":
		if tiledata:
			if len(input_pipes) == 1 and tiledata.get_custom_data("Type") == "input":
				return
			if tiledata.get_custom_data("Type") == "server":
				current_servers_placed -= 1
			if tiledata.get_custom_data("Type") == "storage":
				current_storages_placed -= 1
		tiledata = $BottomTileMapLayer.get_cell_tile_data(Vector2i(x, y))
		if tiledata and tile_costs.has(tiledata.get_custom_data("Type")):
			var refund = int(tile_costs[tiledata.get_custom_data("Type")] * SALE_PERCENT_RECOVERED)
			if tile_costs[tiledata.get_custom_data("Type")] > 0:
				refund = max(refund, 1)
			add_coins(refund)
		$TopTileMapLayer.erase_cell(Vector2i(x, y))
		$BottomTileMapLayer.erase_cell(Vector2i(x, y))
		var input_pipes_len = len(input_pipes)
		input_pipes.erase(Vector2i(x, y))
		if tiledata:
			$/root/Root/Audio/Destroy.play()
		return
	if tiledata != null:
		if tiledata.get_custom_data("Type")!=id:
			return
	tiledata = $BottomTileMapLayer.get_cell_tile_data(Vector2i(x, y))
	if tiledata and tiledata.get_custom_data("Type")!=id:
		return
	# replace conveyor belt
	if tiledata and (tiledata.get_custom_data("Type") == "conveyor" or tiledata.get_custom_data("Type") == "conveyor_corner"):
		coins += 1
	if tiledata and (tiledata.get_custom_data("Type")==id):
		add_coins(tile_costs[id])
	if spend_coins(tile_costs[id]):
		$/root/Root/Audio/Place.play()
		if id == "in":
			tile_costs[id] *= COST_MULTIPLIER
			input_pipes.push_back(Vector2i(x, y))
		elif id == "server":
			if current_servers_placed == max_servers_placed:
				max_servers_placed += 1
				$Spawner.add_to_pool("get", 64)
				max_counts["get"] += 64
			current_servers_placed += 1
		elif id == "storage":
			if current_storages_placed == max_storages_placed:
				max_storages_placed += 1
				$Spawner.add_to_pool("get", 16)
				max_counts["download"] += 16
			current_storages_placed += 1
		$BottomTileMapLayer.erase_cell(Vector2i(x, y))
		$BottomTileMapLayer.set_cell(Vector2i(x, y), 0, tile_atlas_positions[id], alternative)
		$TopTileMapLayer.set_cell(Vector2i(x, y), 0, tile_atlas_positions[id], alternative)

func add_bottom_tile(id: String, x: int, y: int) -> void:
	var tiledata = $TopTileMapLayer.get_cell_tile_data(Vector2i(x, y))
	if tiledata != null:
		return
	tiledata = $BottomTileMapLayer.get_cell_tile_data(Vector2i(x, y))
	if tiledata != null:
		return
	if(coins >= tile_costs[id]):
		$/root/Root/Audio/Place.play()
		add_coins(-tile_costs[id])
		$TopTileMapLayer.erase_cell(Vector2i(x, y))
		$BottomTileMapLayer.set_cell(Vector2i(x, y), 0, tile_atlas_positions[id], alternative)
	else:
		print("insufficent funds")

func _unhandled_input(event):
	if is_game_over:
		return
	
	if (event.is_action_pressed("left_click")):
		var pos=$TopTileMapLayer.local_to_map(get_global_mouse_position())
		if ($HUD.get_selected() == "conveyor" or $HUD.get_selected() == "conveyor_corner"):
			add_bottom_tile($HUD.get_selected(), pos[0], pos[1])
		elif ($HUD.get_selected() != ""):
			add_top_tile($HUD.get_selected(), pos[0], pos[1])
	
	if (event.is_action_pressed("right_click") and !Input.is_action_pressed("reverse_rotation")):
		if $HUD.get_selected() != "" and $HUD.get_selected() != "delete":
			alternative += 1
			$PreviewTileMapLayer.set_cell(current_tile, 0, tile_atlas_positions[$HUD.get_selected()], alternative)
			$PreviewTileMapLayer.fix_invalid_tiles()
			if $PreviewTileMapLayer.get_cell_alternative_tile(current_tile) == -1:
				alternative = 0
				$PreviewTileMapLayer.set_cell(current_tile, 0, tile_atlas_positions[$HUD.get_selected()], alternative)
	elif (event.is_action_pressed("right_click") and Input.is_action_pressed("reverse_rotation")):
		if $HUD.get_selected() != "" and $HUD.get_selected() != "delete":
			alternative -= 1
			$PreviewTileMapLayer.set_cell(current_tile, 0, tile_atlas_positions[$HUD.get_selected()], alternative)
			if $PreviewTileMapLayer.get_cell_alternative_tile(current_tile) == -1:
				var atlas_pos = tile_atlas_positions[$HUD.get_selected()]
				var source = $PreviewTileMapLayer.tile_set.get_source(0)
				alternative = source.get_alternative_tiles_count(atlas_pos) - 1
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

func check_game_over():
	for item in spawn_counts:
		if max_counts.has(item) and max_counts[item]:
			if spawn_counts[item] > max_counts[item]:
				game_over("THE SERVER CRASHED!")
	if coins < 0:
		game_over("YOU WENT BANKRUPT!")

func game_over(msg: String):
	if !is_game_over:
		$HUD/GameOver.show()
		$/root/Root/Audio/Gameover.play()
		$HUD/GameOver/GameOverText.text = msg
		$HUD/GameOver/FinalScore.text = "Final Score: $" + str(coins)
	is_game_over = true
	get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	display_preview()
	$HUD.update_text()
	check_game_over()
	
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
