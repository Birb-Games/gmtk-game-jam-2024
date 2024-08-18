extends Control

func _on_button_pressed() -> void:
	hide()
	$/root/Root/MainMenu.show()
	$/root/Root/Audio/Click.play()
