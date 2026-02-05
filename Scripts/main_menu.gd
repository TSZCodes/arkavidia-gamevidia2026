extends Control

func _on_play_button_pressed() -> void:
	SceneManager.change_scene("res://Scenes/main.tscn")


func _on_settings_button_pressed() -> void:
	SceneManager.overlay_scene("res://Scenes/settings.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
