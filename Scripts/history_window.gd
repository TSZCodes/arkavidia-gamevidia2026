extends PopupPanel

@onready var history_vbox = $VBoxContainer/ScrollContainer/HistoryVBox
@onready var overall_label = $VBoxContainer/OverallLabel
@onready var close_btn = $VBoxContainer/CloseBtn

func _ready() -> void:
	if not history_vbox or not overall_label or not close_btn:
		push_error("HistoryWindow: Nodes not found!")
		return
	close_btn.pressed.connect(func(): hide(); queue_free())
	_populate_history()

func _populate_history() -> void:
	var log_data = GameManager.history_log
	if log_data.is_empty():
		var l = Label.new()
		l.text = "No history available yet."
		if history_vbox: history_vbox.add_child(l)
		return
	var start = log_data[0].net_worth
	var current = log_data[log_data.size()-1].net_worth
	var diff = current - start
	var pct = (diff / start) * 100.0 if start > 0 else 0.0
	if overall_label:
		overall_label.text = "Total Growth: %s$%.2f (%s%.2f%%)" % ["+" if diff>=0 else "", diff, "+" if pct>=0 else "", pct]
		if diff >= 0: overall_label.modulate = Color.GREEN
		else: overall_label.modulate = Color.RED
	for i in range(log_data.size() - 1, -1, -1):
		var entry = log_data[i]
		var prev_worth = entry.net_worth
		if i > 0: prev_worth = log_data[i-1].net_worth
		var day_diff = entry.net_worth - prev_worth
		var day_sign = "+" if day_diff >= 0 else ""
		var col = Color.GREEN if day_diff >= 0 else Color.RED
		var hbox = HBoxContainer.new()
		var day_lbl = Label.new()
		day_lbl.text = "DAY " + str(entry.day)
		day_lbl.custom_minimum_size.x = 80
		var money_lbl = Label.new()
		money_lbl.text = "$ " + str(snapped(entry.net_worth, 0.1))
		money_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var change_lbl = Label.new()
		change_lbl.text = "(%s$%.1f)" % [day_sign, day_diff]
		change_lbl.modulate = col
		hbox.add_child(day_lbl)
		hbox.add_child(money_lbl)
		hbox.add_child(change_lbl)
		if history_vbox:
			history_vbox.add_child(hbox)
			history_vbox.add_child(HSeparator.new())
