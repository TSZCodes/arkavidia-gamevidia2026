extends Control

@export var master_slider : HSlider
@export var sfx_slider : HSlider
@export var music_slider : HSlider

func _ready():
	# AUDIO SLIDERS
	master_slider.value = SaveSystem.get_data().vol_master * 100.0
	music_slider.value = SaveSystem.get_data().vol_music * 100.0
	sfx_slider.value = SaveSystem.get_data().vol_sfx * 100.0

func _on_back_button_pressed() -> void:
	if get_tree().paused == true:
		get_tree().paused = false
		SceneManager.unoverlay_scene()

func _on_master_slider_value_changed(value: float) -> void:
	var safe_vol = value / 100.0
	var bus_idx = AudioServer.get_bus_index("Master")
	if bus_idx != -1: AudioServer.set_bus_volume_db(bus_idx, linear_to_db(safe_vol))
	SaveSystem.get_data().vol_sfx = safe_vol
	SaveSystem.write_data()

func _on_sfx_slider_value_changed(value: float) -> void:
	var safe_vol = value / 100.0
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx != -1: AudioServer.set_bus_volume_db(bus_idx, linear_to_db(safe_vol))
	SaveSystem.get_data().vol_sfx = safe_vol
	SaveSystem.write_data()

func _on_music_slider_value_changed(value: float) -> void:
	var safe_vol = value / 100.0
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx != -1: AudioServer.set_bus_volume_db(bus_idx, linear_to_db(safe_vol))
	SaveSystem.get_data().vol_music = safe_vol
	SaveSystem.write_data()
