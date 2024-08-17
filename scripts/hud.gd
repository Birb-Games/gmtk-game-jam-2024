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
	selected="in"
	print("In pressed")


func _on_out_button_pressed():
	selected="out"
	print("Out pressed")


func _on_belt_button_pressed():
	selected="conveyor"
	print("belt pressed")


func _on_compressor_button_pressed():
	selected="deleter"
	print("compressor pressed")


func _on_storage_button_pressed():
	selected="storage"
	print("storage pressed")


func _on_server_button_pressed():
	selected="server"
	print("server pressed")


func _on_filter_button_pressed():
	selected="filter"
	print("filter pressed")


func _on_splitter_button_pressed():
	selected="splitter"
	print("splitter pressed")


func _on_corner_belt_button_pressed() -> void:
	selected = "conveyor_corner"
	print("corner belt pressed")


func _on_delete_pressed() -> void:
	selected = "delete"
	print("delete pressed")
