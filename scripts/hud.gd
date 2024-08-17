extends CanvasLayer

var selected: String=""

func get_selected():
	return selected
  
func publish_coins(coins: int):
	$CoinLabel.text = "$" + str(coins)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_in_button_pressed():
	selected = "in"
	get_parent().alternative = 0

func _on_out_button_pressed():
	selected = "out"
	get_parent().alternative = 0

func _on_belt_button_pressed():
	selected = "conveyor"
	get_parent().alternative = 0

func _on_compressor_button_pressed():
	selected = "deleter"
	get_parent().alternative = 0

func _on_storage_button_pressed():
	selected = "storage"
	get_parent().alternative = 0

func _on_server_button_pressed():
	selected = "server"
	get_parent().alternative = 0

func _on_filter_button_pressed():
	selected = "filter"
	get_parent().alternative = 0

func _on_splitter_button_pressed():
	selected = "splitter"
	get_parent().alternative = 0

func _on_corner_belt_button_pressed() -> void:
	selected = "conveyor_corner"
	get_parent().alternative = 0

func _on_delete_pressed() -> void:
	selected = "delete"
	get_parent().alternative = 0

func _on_merger_button_pressed() -> void:
	selected = "merger"
	get_parent().alternative = 0
	
func update_text():
	$Counts/GetCount.text = str($/root/Root.spawn_counts["spawn_get"])
	$Counts/GetCount.text += "/" + str($/root/Root.max_counts["spawn_get"])
	$Counts/GetCount.text += " (" + str(int(round($/root/Root.timers["spawn_get"]))) + "s)"
	$Counts/RetCount.text = str($/root/Root.spawn_counts["return"])
	if $/root/Root.tile_costs.has(selected):
		$Cost.text = "Cost: $" + str($/root/Root.tile_costs[selected])
	else:
		$Cost.text = ""
