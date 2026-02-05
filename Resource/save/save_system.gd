extends Node

const DEFAULT_SAVE_PATH := "user://savedata.tres"

var cached_save: SaveData

func load_data():
	# SaveData file does not exist yet, return default save file
	if not FileAccess.file_exists(DEFAULT_SAVE_PATH):
		cached_save = SaveData.new()
		return

	var save := ResourceLoader.load(DEFAULT_SAVE_PATH)
	if save == null:
		# NOTE: Any change made to the SaveData class that conflicts with previous json serializations of it
		# will result in a fresh SaveData returned when this function is called. Be warned.
		cached_save = SaveData.new()
	else:
		cached_save = save

func write_data() -> void:
	ResourceSaver.save(cached_save, DEFAULT_SAVE_PATH)

func has_data() -> bool:
	return cached_save != null

func get_data() -> SaveData:
	if not has_data():
		load_data()
	return cached_save

func reset_data() -> void:
	cached_save = SaveData.new()
