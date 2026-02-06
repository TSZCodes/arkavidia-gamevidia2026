extends Control

# Settings - Audio & Display Settings
# Manages volume controls and settings navigation

var master_slider: Slider
var music_slider: Slider
var sfx_slider: Slider
var is_overlay_mode: bool = false

func _ready() -> void:
	master_slider = find_child("MasterSlider", true, false)
	music_slider = find_child("MusicSlider", true, false)
	sfx_slider = find_child("SfxSlider", true, false)
	
	if not master_slider:
		push_error("SETTINGS ERROR: Could not find UI nodes. Make sure node names match exactly: 'MasterSlider', etc.")
		return

	if not master_slider.value_changed.is_connected(_on_master_changed):
		master_slider.value_changed.connect(_on_master_changed)
	if not music_slider.value_changed.is_connected(_on_music_changed):
		music_slider.value_changed.connect(_on_music_changed)
	if not sfx_slider.value_changed.is_connected(_on_sfx_changed):
		sfx_slider.value_changed.connect(_on_sfx_changed)
	
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(1))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(2))
	
	# Check if we're in overlay mode (fullscreen settings panel blocking game)
	var bg = find_child("Bg", true, false)
	if bg:
		if is_overlay_mode:
			bg.visible = true
			# Make background not block input
			bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		else:
			bg.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()

func _on_master_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func _on_music_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(value))

func _on_sfx_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db(value))

func _on_back_pressed() -> void:
	if has_node("/root/SceneManager"):
		get_node("/root/SceneManager").go_back()
	else:
		queue_free()

func _on_main_menu_pressed() -> void:
	if has_node("/root/SceneManager"):
		get_node("/root/SceneManager").switch_scene("res://Scenes/main_menu.tscn")
