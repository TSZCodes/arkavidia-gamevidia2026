extends Control

@onready var panel: PanelContainer = $PanelContainer
@onready var label: Label = $PanelContainer/MarginContainer/HBoxContainer/Label

# specific ID to track the current notification instance
var notification_id: int = 0

func _ready() -> void:
	# Ensure the node is hidden and positioned off-screen at the start
	visible = false
	reset_position_offscreen()
	
	# Connect mouse input event to the panel
	panel.gui_input.connect(_on_panel_gui_input)

func reset_position_offscreen() -> void:
	# Position at bottom right, hidden below the viewport
	var viewport_size = get_viewport_rect().size
	position = Vector2(viewport_size.x - size.x - 20, viewport_size.y + 100)

func show_notification(message: String) -> void:
	notification_id += 1 # Increment ID for the new notification
	var current_id = notification_id
	
	label.text = message
	reset_position_offscreen()
	visible = true
	
	# Slide In Animation
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var target_y = get_viewport_rect().size.y - size.y - 20
	tween.tween_property(self, "position:y", target_y, 0.5)
	
	# Play sound if available
	if Engine.has_singleton("AudioManager") or get_node_or_null("/root/AudioManager"):
		var audio_manager = get_node_or_null("/root/AudioManager")
		if audio_manager and audio_manager.has_method("play_notification"):
			audio_manager.play_notification()
	
	# Wait 10 seconds, then slide out
	await get_tree().create_timer(10.0).timeout
	
	# Only hide if this is still the active notification (hasn't been clicked or replaced)
	if current_id == notification_id:
		hide_notification()

func hide_notification() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	var target_y = get_viewport_rect().size.y + 100
	tween.tween_property(self, "position:y", target_y, 0.5)
	await tween.finished
	visible = false

# Handle click events on the panel
func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Increment ID so the pending timer won't trigger a double hide or hide a future notif
		notification_id += 1 
		hide_notification()