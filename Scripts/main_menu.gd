extends Control

# Main Menu - Game Entry Point
# Handles game start, settings, and quit

func _on_start_btn_pressed() -> void:
	SceneManager.switch_scene("res://Scenes/main.tscn")

func _on_settings_btn_pressed() -> void:
	SceneManager.switch_scene("res://Scenes/settings.tscn")

func _on_quit_btn_pressed() -> void:
	get_tree().quit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_settings_btn_pressed()
