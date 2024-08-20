extends Control

@export var game_screen: PackedScene

func _ready():
	if OS.get_name() == "Web":
		$VBoxContainer/Quit.hide()

func _on_start_pressed() -> void:
	hide()
	$/root/Root/Audio/Click.play()
	$/root/Root.add_child(game_screen.instantiate())

func _on_credits_pressed() -> void:
	$/root/Root/Audio/Click.play()
	hide()
	$/root/Root/CreditsScreen.show()

func _on_quit_pressed() -> void:
	get_tree().quit()
