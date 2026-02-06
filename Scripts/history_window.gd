extends PopupPanel

# History Window - Player's Financial History Tracker
# Displays player's net worth progression over time

@onready var history_vbox = %HistoryVBox
@onready var overall_label = %OverallLabel
@onready var close_btn = $PanelContainer/MarginContainer/VBoxContainer/CloseBtn

func _ready() -> void:
	if close_btn:
		if not close_btn.pressed.is_connected(_on_close_pressed):
			close_btn.pressed.connect(_on_close_pressed)
	else:
		push_error("HistoryWindow: CloseBtn not found at $PanelContainer/MarginContainer/VBoxContainer/CloseBtn")

	_populate_history()

func _on_close_pressed() -> void:
	hide()
	queue_free()

func _populate_history() -> void:
	var log_data = GameManager.history_log
	
	if log_data.is_empty():
		var l = Label.new()
		l.text = "No history available yet."
		l.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if history_vbox:
			history_vbox.add_child(l)
		return
		
	var start = log_data[0].net_worth
	var current = log_data[log_data.size() - 1].net_worth
	var diff = current - start
	var pct = (diff / start) * 100.0 if start > 0 else 0.0
	
	if overall_label:
		var sign_str = "+" if diff >= 0 else ""
		overall_label.text = "Total Growth: %s$%.2f (%s%.2f%%)" % [sign_str, diff, sign_str, pct]
		if diff >= 0:
			overall_label.modulate = Color(0.4, 0.9, 0.5)
		else:
			overall_label.modulate = Color(0.9, 0.4, 0.4)
			
	for i in range(log_data.size() - 1, -1, -1):
		var entry = log_data[i]
		
		var prev_worth = entry.net_worth
		if i > 0:
			prev_worth = log_data[i - 1].net_worth
			
		var day_diff = entry.net_worth - prev_worth
		var day_sign = "+" if day_diff >= 0 else ""
		var col = Color(0.4, 0.9, 0.5) if day_diff >= 0 else Color(0.9, 0.4, 0.4)
		
		var hbox = HBoxContainer.new()
		
		var day_lbl = Label.new()
		day_lbl.text = "DAY " + str(entry.day)
		day_lbl.custom_minimum_size.x = 80
		day_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
		
		var money_lbl = Label.new()
		money_lbl.text = "$ " + str(snapped(entry.net_worth, 0.1))
		money_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		money_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		
		var change_lbl = Label.new()
		change_lbl.text = "(%s$%.1f)" % [day_sign, day_diff]
		change_lbl.modulate = col
		change_lbl.custom_minimum_size.x = 100
		change_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		
		hbox.add_child(day_lbl)
		hbox.add_child(money_lbl)
		hbox.add_child(change_lbl)
		
		if history_vbox:
			history_vbox.add_child(hbox)
			var sep = HSeparator.new()
			sep.modulate = Color(1, 1, 1, 0.1)
			history_vbox.add_child(sep)
