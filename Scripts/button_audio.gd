extends Node
class_name ButtonAudio

# Automatically finds the parent button
@onready var parent_button: Control = get_parent()

func _ready() -> void:
	if parent_button is BaseButton:
		parent_button.pressed.connect(_on_pressed)
		parent_button.mouse_entered.connect(_on_mouse_entered)
	else:
		push_warning("ButtonAudio node must be a child of a Button node.")

func _on_pressed() -> void:
	AudioManager.play_click()

func _on_mouse_entered() -> void:
	if not parent_button.disabled:
		AudioManager.play_hover()
