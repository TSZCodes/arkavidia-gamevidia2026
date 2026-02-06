extends Node

# --- Audio Assets ---
# Preloading the assets found in your uploaded folder
const STREAM_CLICK = preload("res://Audio/SFX_button_clickr.mp3")
const STREAM_HOVER = preload("res://Audio/SFX_Button_Hover.mp3")
const STREAM_NOTIF_GENERIC = preload("res://Audio/sfx_notif_geddit.mp3")
const STREAM_NOTIF_BAD = preload("res://Audio/sfx_notiff_quakcs.mp3")
const STREAM_HACKER_WIN = preload("res://Audio/sfx_notif_hackerman.mp3")
const STREAM_SOCIAL_WIN = preload("res://Audio/sfx_notif_sarjana_teknik_komunikasi.mp3")

# --- Audio Players ---
var sfx_click_player: AudioStreamPlayer
var sfx_hover_player: AudioStreamPlayer
var sfx_main_player: AudioStreamPlayer # For general notifications

func _ready() -> void:
	# Initialize Players attached to the SFX bus
	sfx_click_player = _create_audio_player(STREAM_CLICK, "SFX")
	sfx_hover_player = _create_audio_player(STREAM_HOVER, "SFX")
	sfx_main_player = _create_audio_player(STREAM_NOTIF_GENERIC, "SFX")
	
	init_volume()

# --- Helper to create players dynamically ---
func _create_audio_player(stream: AudioStream, bus: String) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.bus = bus
	add_child(player)
	return player

# --- Public Play Functions ---
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
	for i in range(AudioServer.bus_count):
		var bus: String = AudioServer.get_bus_name(i)
		set_volume_linear(bus, get_volume_linear(bus))

func set_volume_linear(bus: String, vol_linear: float) -> void:
	var data: SaveData = SaveSystem.get_data()
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(bus), vol_linear)
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
			return -1.0