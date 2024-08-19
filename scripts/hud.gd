extends CanvasLayer

var selected: String=""

func defocus():
	selected=""
	$Inventory/InButton.release_focus()
	$Inventory/OutButton.release_focus()
	$Inventory/CornerBeltButton.release_focus()
	$Inventory/BeltButton.release_focus()
	$Inventory/TrashButton.release_focus()
	$Inventory/StorageButton.release_focus()
	$Inventory/ServerButton.release_focus()
	$Inventory/GreenFilterButton.release_focus()
	$Inventory/WhiteFilterButton.release_focus()
	$Inventory/BlueFilterButton.release_focus()
	$Inventory/SplitterButton.release_focus()
	$Inventory/MergerButton.release_focus()
	$Inventory/Delete.release_focus()

func get_selected():
	return selected
  
func publish_coins(coins: int):
	$CoinLabel.text = "$" + str(coins)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func select(option):
	$/root/Root/Audio/Click.play()
	get_parent().alternative = 0
	if(selected==option):
		defocus()
	else:
		selected=option

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input.is_action_just_pressed("defocus")):
		defocus()
	
	if(Input.is_action_just_pressed("quit")):
		$Quit.visible = !$Quit.visible
		if $Quit.visible:
			get_tree().paused = true
		else:
			get_tree().paused = false

func _on_in_button_pressed():
	select("in")

func _on_out_button_pressed():
	select("out")

func _on_belt_button_pressed():
	select("conveyor")
	
func _on_compressor_button_pressed():
	select("deleter")

func _on_storage_button_pressed():
	select("storage")

func _on_server_button_pressed():
	select("server")

func _on_green_filter_button_pressed():
	select("green_filter")

func _on_white_filter_button_pressed():
	select("white_filter")

func _on_blue_filter_button_pressed():
	select("blue_filter")

func _on_splitter_button_pressed():
	select("splitter")

func _on_corner_belt_button_pressed() -> void:
	select("conveyor_corner")

func _on_delete_pressed() -> void:
	select("delete")

func _on_merger_button_pressed() -> void:
	select("merger")

func set_count_text(label: Label, id: String):
	label.text = str($/root/Root/GameScreen.spawn_counts[id])
	label.text += "/" + str($/root/Root/GameScreen.max_counts[id])
	label.text += " (" + str(int(round($/root/Root/GameScreen/Spawner.timers[id]))) + "s)"
	
func update_text():
	set_count_text($Counts/GetCount, "get")
	set_count_text($Counts/BadCount, "bad")
	set_count_text($Counts/DownloadCount, "download")
	$Counts/RetCount.text = str($/root/Root/GameScreen.spawn_counts["return"])

	if $/root/Root/GameScreen.tile_costs.has(selected):
		$Cost.text = "Cost: $" + str($/root/Root/GameScreen.tile_costs[selected])
	else:
		$Cost.text = ""
	
	if get_tree().paused:
		$Paused.text = "Paused"
	else:
		$Paused.text = ""

func _on_return_to_menu_pressed() -> void:
	get_parent().queue_free()
	$/root/Root/MainMenu.show()

func _on_no_pressed() -> void:
	$Quit.hide()
	get_tree().paused = false
