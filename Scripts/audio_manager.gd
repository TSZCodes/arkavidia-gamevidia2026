extends Node

func _ready() -> void:
	init_volume()

# --- Volume Control ---

func init_volume() -> void:
	for i in range(AudioServer.bus_count):
		var bus := AudioServer.get_bus_name(i)
		set_volume_linear(bus, get_volume_linear(bus))

func set_volume_linear(bus: String, vol_linear: float) -> void:
	var data := SaveSystem.get_data()
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(bus), vol_linear)
	match bus:
		"Master":
			data.vol_master = vol_linear
		"SFX":
			data.vol_sfx = vol_linear
		"Music":
			data.vol_music = vol_linear
		_:
			printerr("Invalid bus volume name")
	SaveSystem.write_data()

func get_volume_linear(bus_name: String) -> float:
	var data := SaveSystem.get_data()
	match bus_name:
		"Master":
			return data.vol_master
		"SFX":
			return data.vol_sfx
		"Music":
			return data.vol_music
		_:
			printerr("Invalid bus volume name")
			return -1
