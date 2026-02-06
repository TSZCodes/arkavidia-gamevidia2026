extends PopupPanel

# Daily Summary Popup - End of Day Financial Report
# Shows player's financial progress from previous day to current day

@onready var day_label = $PanelContainer/MarginContainer/VBoxContainer/DayLabel
@onready var wallet_label = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SummaryVBox/WalletLabel
@onready var assets_label = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SummaryVBox/AssetsLabel
@onready var total_label = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SummaryVBox/TotalLabel
@onready var changes_vbox = $PanelContainer/MarginContainer/VBoxContainer/ChangesScroll/ChangesVBox
@onready var debt_label = $PanelContainer/MarginContainer/VBoxContainer/ChangesScroll/ChangesVBox/DebtLabel
@onready var net_change_label = $PanelContainer/MarginContainer/VBoxContainer/NetChangeLabel
@onready var close_btn = $PanelContainer/MarginContainer/VBoxContainer/CloseBtn

var previous_day_data = {}
var current_day_data = {}

func _ready() -> void:
	if close_btn:
		if not close_btn.pressed.is_connected(_on_close_pressed):
			close_btn.pressed.connect(_on_close_pressed)
	else:
		push_error("DailySummary: CloseBtn not found! Check scene tree path.")

func setup(previous_data: Dictionary, current_data: Dictionary, previous_day: int, current_day: int) -> void:
	previous_day_data = previous_data
	current_day_data = current_data
	
	if day_label:
		day_label.text = "Day %d → Day %d" % [previous_day, current_day]
	
	var wallet = current_data.get("wallet", 0.0)
	if wallet_label:
		wallet_label.text = "Wallet: $%s" % str(snapped(wallet, 0.01))
	
	var assets = current_data.get("assets", 0.0)
	if assets_label:
		assets_label.text = "Assets: $%s" % str(snapped(assets, 0.01))
	
	var total = current_data.get("total", 0.0)
	if total_label:
		total_label.text = "Net Worth: $%s" % str(snapped(total, 0.01))
	
	var debt = current_data.get("debt", 0.0)
	if debt_label:
		debt_label.text = "Debt: $%s" % str(snapped(debt, 0.01))
	
	_build_changes(previous_data, current_data)
	
	var prev_total = previous_data.get("total", 0.0)
	var net_change = total - prev_total
	var change_str = "+$%s" % str(snapped(net_change, 0.01)) if net_change >= 0 else "-$%s" % str(snapped(abs(net_change), 0.01))
	
	if net_change_label:
		net_change_label.text = "Net Change: %s" % change_str
		if net_change >= 0:
			net_change_label.modulate = Color(0.3, 0.9, 0.4)
		else:
			net_change_label.modulate = Color(0.9, 0.3, 0.3)

func _build_changes(previous_data: Dictionary, current_data: Dictionary) -> void:
	if not changes_vbox:
		return
	
	for child in changes_vbox.get_children():
		if child.name != "DebtLabel":
			child.queue_free()
			
	var portfolio = current_data.get("portfolio", {})
	var prev_portfolio = previous_data.get("portfolio", {})
	
	for stock_name in portfolio:
		var current_qty = portfolio[stock_name]
		var prev_qty = prev_portfolio.get(stock_name, 0.0)
		
		if current_qty != prev_qty:
			var change = current_qty - prev_qty
			var change_str = "+%s" % str(snapped(change, 0.0001)) if change >= 0 else str(snapped(change, 0.0001))
			
			var label = Label.new()
			label.text = "%s: %s → %s (%s)" % [stock_name, str(snapped(prev_qty, 0.0001)), str(snapped(current_qty, 0.0001)), change_str]
			label.add_theme_font_size_override("font_size", 12)
			changes_vbox.add_child(label)
			
	if changes_vbox.get_child_count() <= 1:
		var label = Label.new()
		label.text = "No portfolio changes today"
		label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
		label.add_theme_font_size_override("font_size", 12)
		changes_vbox.add_child(label)

func _on_close_pressed() -> void:
	hide()
	queue_free()
