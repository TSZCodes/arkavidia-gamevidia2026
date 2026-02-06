extends Node

# --- Audio Assets ---
# Preloading the assets found in your uploaded folder
const STREAM_CLICK = preload("res://Audio/SFX_button_clickr.mp3")
const STREAM_HOVER = preload("res://Audio/SFX_Button_Hover.mp3")
const STREAM_NOTIF_GENERIC = preload("res://Audio/sfx_notif_geddit.mp3")
const STREAM_NOTIF_BAD = preload("res://Audio/sfx_notiff_quakcs.mp3")
const STREAM_HACKER_WIN = preload("res://Audio/sfx_notif_hackerman.mp3")
const STREAM_SOCIAL_WIN = preload("res://Audio/sfx_notif_sarjana_teknik_komunikasi.mp3")
const STREAM_BGM = preload("res://Audio/BGM/thismightbealiltoogroovy.mp3")

# --- Audio Players ---
var sfx_click_player: AudioStreamPlayer
var sfx_hover_player: AudioStreamPlayer
var sfx_main_player: AudioStreamPlayer # For general notifications
var music_player: AudioStreamPlayer # For Background Music

func _ready() -> void:
	# 1. Critical Fix: Ensure Audio Buses exist at runtime
	# This fixes the bug where sliders wouldn't work because the bus didn't exist
	_ensure_bus_exists("SFX")
	_ensure_bus_exists("Music")

	# 2. Initialize Players attached to the specific buses
	sfx_click_player = _create_audio_player(STREAM_CLICK, "SFX")
	sfx_hover_player = _create_audio_player(STREAM_HOVER, "SFX")
	sfx_main_player = _create_audio_player(STREAM_NOTIF_GENERIC, "SFX")
	
	# Initialize Music Player attached to the Music bus
	music_player = _create_audio_player(STREAM_BGM, "Music")
	
	# 3. Apply saved volumes immediately
	init_volume()
	
	# 4. Start Music
	play_music()

# --- Runtime Bus Creation Fix ---
func _ensure_bus_exists(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) == -1:
		# Bus is missing, create it dynamically
		var index = AudioServer.bus_count
		AudioServer.add_bus() # Adds at the end
		AudioServer.set_bus_name(index, bus_name)
		AudioServer.set_bus_send(index, "Master")
		print("AudioManager: Created missing bus '" + bus_name + "'")

# --- Helper to create players dynamically ---
func _create_audio_player(stream: AudioStream, bus: String) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.bus = bus
	add_child(player)
	return player

# --- Public Play Functions ---
func play_music() -> void:
	if music_player:
		if music_player.playing:
			return
		
		# Set the stream and play
		music_player.stream = STREAM_BGM
		music_player.play()
		
		# Ensure it loops if the import settings didn't catch it
		if not music_player.finished.is_connected(_on_music_finished):
			music_player.finished.connect(_on_music_finished)

func _on_music_finished() -> void:
	if music_player:
		music_player.play()

func play_click() -> void:
	if sfx_click_player:
		# Randomize pitch slightly for variety
		sfx_click_player.pitch_scale = randf_range(0.95, 1.05) 
		sfx_click_player.play()

func play_hover() -> void:
	if sfx_hover_player:
		sfx_hover_player.pitch_scale = randf_range(0.98, 1.02)
		sfx_hover_player.play()

func play_notification() -> void:
	if sfx_main_player:
		sfx_main_player.stream = STREAM_NOTIF_GENERIC
		sfx_main_player.pitch_scale = 1.0
		sfx_main_player.play()

func play_bad_notification() -> void:
	if sfx_main_player:
		sfx_main_player.stream = STREAM_NOTIF_BAD
		sfx_main_player.pitch_scale = 1.0
		sfx_main_player.play()

func play_hacker_win() -> void:
	if sfx_main_player:
		sfx_main_player.stream = STREAM_HACKER_WIN
		sfx_main_player.pitch_scale = 1.0
		sfx_main_player.play()

func play_social_win() -> void:
	if sfx_main_player:
		sfx_main_player.stream = STREAM_SOCIAL_WIN
		sfx_main_player.pitch_scale = 1.0
		sfx_main_player.play()

# --- Volume Control (Preserved) ---
func init_volume() -> void:
	# Iterate through known buses or saved data to apply volumes
	var buses = ["Master", "SFX", "Music"]
	for bus in buses:
		set_volume_linear(bus, get_volume_linear(bus))

func set_volume_linear(bus: String, vol_linear: float) -> void:
	var idx = AudioServer.get_bus_index(bus)
	if idx == -1:
		return
		
	var data: SaveData = SaveSystem.get_data()
	# Set the volume on the AudioServer
	AudioServer.set_bus_volume_linear(idx, vol_linear)
	
	# Save the data
	match bus:
		"Master":
			data.vol_master = vol_linear
		"SFX":
			data.vol_sfx = vol_linear
		"Music":
			data.vol_music = vol_linear
		_:
			pass
	SaveSystem.write_data()

func get_volume_linear(bus_name: String) -> float:
	var data: SaveData = SaveSystem.get_data()
	match bus_name:
		"Master":
			return data.vol_master
		"SFX":
			return data.vol_sfx
		"Music":
			return data.vol_music
		_:
			return 1.0 # Default to 1.0 if unknown