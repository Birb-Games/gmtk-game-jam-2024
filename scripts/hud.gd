extends CanvasLayer

var selected: String=""

var upgrade_get_cost = 200
var upgrade_bad_cost = 800
var upgrade_download_cost = 200

func defocus():
	selected=""
	$Cost.text = ""
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
	$Inventory/BridgeButton.release_focus()
	$Inventory/Delete.release_focus()

func get_selected():
	return selected
	
func color_selected():
	if $/root/Root/GameScreen.tile_costs.has(selected):
		if $/root/Root/GameScreen.coins>=$/root/Root/GameScreen.tile_costs[selected]:
			$Cost.add_theme_color_override("font_color",Color(1.0,1.0,1.0))
		else:
			$Cost.add_theme_color_override("font_color",Color(1.0,0.0,0.0))
  
func publish_coins(coins: int):
	$CoinLabel.text = "$" + str(coins)
	color_selected()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_count_text($Counts/Get/GetCount, "get")
	set_count_text($Counts/Bad/BadCount, "bad")
	set_count_text($Counts/Download/DownloadCount, "download")
	$Counts/RetCount.text = str($/root/Root/GameScreen.spawn_counts["return"])
	
	set_upgrade_text($Counts/Get/UpgradeGet, upgrade_get_cost)
	set_upgrade_text($Counts/Bad/UpgradeBad, upgrade_bad_cost)
	set_upgrade_text($Counts/Download/UpgradeDownload, upgrade_download_cost)
	

func select(option):
	$/root/Root/Audio/Click.play()
	get_parent().alternative = 0
	if(selected==option):
		defocus()
	else:
		selected=option
		if $/root/Root/GameScreen.tile_costs.has(selected):
			$Cost.text = "Cost: $" + str($/root/Root/GameScreen.tile_costs[selected])
		else:
			$Cost.text = ""
		color_selected()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input.is_action_just_pressed("defocus")):
		defocus()
	
	if(Input.is_action_just_pressed("quit") and !$GameOver.visible):
		$Quit.visible = !$Quit.visible
		$Paused.text = ""
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

func _on_bridge_button_pressed() -> void:
	select("bridge")

func set_count_text(label: Label, id: String):
	var percent_to_max = float($/root/Root/GameScreen.spawn_counts[id]) / float($/root/Root/GameScreen.max_counts[id])
	if percent_to_max > 0.8:
		label.modulate = Color.RED
	else:
		label.modulate = Color.WHITE
	label.text = str($/root/Root/GameScreen.spawn_counts[id])
	label.text += "/MAX " + str($/root/Root/GameScreen.max_counts[id])
	label.text += " (" + str(int(round($/root/Root/GameScreen/Spawner.timers[id]))) + "s)"

func set_upgrade_text(button: Button, cost: int):
	button.text = "+MAX: $" + str(cost)
	
func update_text():
	set_count_text($Counts/Get/GetCount, "get")
	set_count_text($Counts/Bad/BadCount, "bad")
	set_count_text($Counts/Download/DownloadCount, "download")
	$Counts/RetCount.text = str($/root/Root/GameScreen.spawn_counts["return"])

func update_paused():
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

func _on_view_factory_pressed() -> void:
	$GameOver.hide()
	$Inventory.hide()
	$CoinLabel.hide()
	$Counts.hide()
	$Cost.hide()

func _on_upgrade_get_pressed() -> void:
	if $/root/Root/GameScreen.spend_coins(upgrade_get_cost):
		upgrade_get_cost *= 4
		$/root/Root/GameScreen.max_counts["get"] *= 2
		set_upgrade_text($Counts/Get/UpgradeGet, upgrade_get_cost)

func _on_upgrade_bad_pressed() -> void:
	if $/root/Root/GameScreen.spend_coins(upgrade_bad_cost):
		upgrade_bad_cost *= 4
		$/root/Root/GameScreen.max_counts["bad"] *= 2
		set_upgrade_text($Counts/Bad/UpgradeBad, upgrade_bad_cost)

func _on_upgrade_download_pressed() -> void:
	if $/root/Root/GameScreen.spend_coins(upgrade_download_cost):
		upgrade_download_cost *= 4
		$/root/Root/GameScreen.max_counts["download"] *= 2
		set_upgrade_text($Counts/Download/UpgradeDownload, upgrade_download_cost)
