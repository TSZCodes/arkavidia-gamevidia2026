extends Control

@export var market_manager: Node
@export var stock_list_container: VBoxContainer
@export var wallet_label: Label
@export var debt_label: Label
@export var trading_panel: Control
@export var header_label: Label
@export var price_label: Label
@export var owned_label: Label
@export var candle_chart: Control 
@export var input_usd: LineEdit
@export var amount_slider: HSlider
@export var slider_label: Label
@export var news_vbox_panel: VBoxContainer

var daily_summary_scene = preload("res://Scenes/daily_summary_popup.tscn")
var history_popup_scene = preload("res://Scenes/history_window.tscn")
var pay_debt_popup_scene = preload("res://Scenes/pay_debt_popup.tscn")

var selected_stock_index: int = -1
var current_trade_mode: String = "SPOT"
var current_leverage: float = 1.5 
var btn_lev_1_5x: Button
var btn_lev_2x: Button
var active_minigame_layer: CanvasLayer = null

# Tracks Cash + Assets
var start_of_day_equity: float = 0.0

func _ready() -> void:
	_apply_visual_styling()
	if candle_chart:
		candle_chart.position = Vector2.ZERO
	if trading_panel: trading_panel.visible = true 
	add_to_group("dashboard")
	
	if not GameManager.money_changed.is_connected(_update_ui):
		GameManager.connect("money_changed", _update_ui)
	if not GameManager.debt_changed.is_connected(_update_ui):
		GameManager.connect("debt_changed", _update_ui)
	if not GameManager.day_changed.is_connected(_on_day_changed):
		GameManager.connect("day_changed", _on_day_changed)
	if not EventBus.news_released.is_connected(_on_news_received):
		EventBus.connect("news_released", _on_news_received)
	if not GameManager.notif_message.is_connected(_on_notification_received):
		GameManager.connect("notif_message", _on_notification_received)
	
	if amount_slider:
		if not amount_slider.value_changed.is_connected(_on_slider_value_changed):
			amount_slider.value_changed.connect(_on_slider_value_changed)
	
	var overlay_bg = find_child("OverlayBg", true, false)
	if overlay_bg:
		overlay_bg.gui_input.connect(_on_overlay_bg_input)
	
	if market_manager: market_manager.update_active_stocks()
	
	_setup_trading_buttons()
	_setup_top_buttons()
	_setup_leverage_ui()
	
	var state = _capture_financial_state()
	start_of_day_equity = state["equity"]
	
	if start_of_day_equity <= 0.001:
		start_of_day_equity = GameManager.player_money
		
	_update_ui()
	rebuild_lists()
	
	if market_manager and not market_manager.active_stocks.is_empty():
		_on_stock_selected(0)

func _remove_focus(btn: Button) -> void:
	if not btn: return
	btn.focus_mode = Control.FOCUS_NONE
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _setup_top_buttons() -> void:
	var btns = [
		find_child("NextDayBtn", true, false),
		find_child("PinjolBtn", true, false),
		find_child("HistoryBtn", true, false),
		find_child("PayDebtBtn", true, false),
		find_child("HamburgerBtn", true, false)
	]
	for b in btns:
		_remove_focus(b)

func _on_hamburger_btn_pressed() -> void:
	var side_drawer = find_child("SideDrawer", true, false)
	var drawer_list = find_child("DrawerList", true, false)
	var drawer_panel = find_child("DrawerPanel", true, false)
	if not side_drawer or not drawer_list: return
	
	for child in drawer_list.get_children():
		child.queue_free()
	
	if market_manager:
		for i in range(market_manager.active_stocks.size()):
			var stock = market_manager.active_stocks[i]
			
			var btn = Button.new()
			btn.custom_minimum_size.y = 65
			btn.toggle_mode = true
			btn.button_pressed = (i == selected_stock_index)
			
			var base_col = Color(0.16, 0.16, 0.20)
			if i == selected_stock_index: base_col = Color(0.2, 0.22, 0.28)
			
			var style_norm = _get_card_style(base_col)
			style_norm.border_color = Color(1,1,1,0.05)
			style_norm.set_border_width_all(1)
			
			var style_hover = _get_card_style(base_col.lightened(0.05))
			style_hover.border_color = Color(1,1,1,0.2)
			style_hover.set_border_width_all(1)
			
			var style_pressed = _get_card_style(base_col.darkened(0.1))
			
			btn.add_theme_stylebox_override("normal", style_norm)
			btn.add_theme_stylebox_override("hover", style_hover)
			btn.add_theme_stylebox_override("pressed", style_pressed)
			_remove_focus(btn)
			
			btn.pressed.connect(_on_drawer_item_selected.bind(i))
			
			var margin = MarginContainer.new()
			margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			margin.add_theme_constant_override("margin_left", 0)
			margin.add_theme_constant_override("margin_top", 0)
			margin.add_theme_constant_override("margin_right", 15)
			margin.add_theme_constant_override("margin_bottom", 0)
			margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
			var h_box = HBoxContainer.new()
			h_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
			h_box.add_theme_constant_override("separation", 12)
			
			var strip = ColorRect.new()
			strip.custom_minimum_size.x = 4
			strip.color = _get_category_color(stock.category)
			strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
			var info_vbox = VBoxContainer.new()
			info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			info_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
			info_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
			var symbol_lbl = Label.new()
			symbol_lbl.text = stock.symbol
			symbol_lbl.add_theme_font_size_override("font_size", 15)
			symbol_lbl.add_theme_color_override("font_color", Color.WHITE)
			
			var name_lbl = Label.new()
			name_lbl.text = stock.company_name
			name_lbl.add_theme_font_size_override("font_size", 11)
			name_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65))
			name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			
			info_vbox.add_child(symbol_lbl)
			info_vbox.add_child(name_lbl)
			
			var price_vbox = VBoxContainer.new()
			price_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
			price_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
			var price_lbl = Label.new()
			price_lbl.text = "$" + str(snapped(stock.current_price, 0.01))
			price_lbl.add_theme_font_size_override("font_size", 14)
			price_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			price_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.9))
			
			price_vbox.add_child(price_lbl)
			
			var owned_qty = GameManager.portfolio.get(stock.company_name, 0.0)
			if owned_qty > 0.0001:
				var own_lbl = Label.new()
				own_lbl.text = "Own: " + str(snapped(owned_qty, 0.1))
				own_lbl.add_theme_font_size_override("font_size", 10)
				own_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.5))
				own_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				price_vbox.add_child(own_lbl)
			
			h_box.add_child(strip)
			
			var spacer_strip = Control.new()
			spacer_strip.custom_minimum_size.x = 8
			spacer_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
			h_box.add_child(spacer_strip)
			
			h_box.add_child(info_vbox)
			h_box.add_child(price_vbox)
			
			margin.add_child(h_box)
			btn.add_child(margin)
			
			drawer_list.add_child(btn)

	side_drawer.visible = true
	if drawer_panel:
		drawer_panel.position.x = -drawer_panel.size.x
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(drawer_panel, "position:x", 0.0, 0.3)

func _get_category_color(category: String) -> Color:
	match category:
		"Teknologi & Media": return Color(0.3, 0.6, 0.9)
		"Energi & SDA": return Color(0.9, 0.7, 0.2)
		"Perbankan & Keuangan": return Color(0.2, 0.8, 0.4)
		"Infrastruktur": return Color(0.6, 0.6, 0.6)
		"Konsumsi & Retail": return Color(0.9, 0.4, 0.6)
		"Transportasi": return Color(0.4, 0.8, 0.9)
		"Kesehatan": return Color(0.9, 0.3, 0.3)
		_: return Color.WHITE

func _on_drawer_item_selected(id: int) -> void:
	if id < 0 or id >= market_manager.active_stocks.size(): return
	_on_drawer_close_pressed()
	_on_stock_selected(id)

func _on_drawer_close_pressed() -> void:
	var side_drawer = find_child("SideDrawer", true, false)
	var drawer_panel = find_child("DrawerPanel", true, false)
	if not side_drawer: return
	if drawer_panel:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(drawer_panel, "position:x", -drawer_panel.size.x, 0.2)
		await tween.finished
	side_drawer.visible = false

func _on_overlay_bg_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_on_drawer_close_pressed()

func _setup_leverage_ui() -> void:
	if not input_usd: return
	if find_child("LeverageContainer", true, false): return
	var input_container = input_usd.get_parent()
	var trading_vbox = input_container.get_parent()
	var lev_container = HBoxContainer.new()
	lev_container.name = "LeverageContainer"
	lev_container.add_theme_constant_override("separation", 10)
	lev_container.visible = false 
	var lbl = Label.new()
	lbl.text = "Leverage:"
	lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	lev_container.add_child(lbl)
	
	btn_lev_1_5x = Button.new()
	btn_lev_1_5x.text = "1.5x"
	btn_lev_1_5x.size_flags_horizontal = 3
	btn_lev_1_5x.toggle_mode = true
	btn_lev_1_5x.button_pressed = true 
	btn_lev_1_5x.pressed.connect(_on_leverage_selected.bind(1.5))
	_remove_focus(btn_lev_1_5x)
	lev_container.add_child(btn_lev_1_5x)
	
	btn_lev_2x = Button.new()
	btn_lev_2x.text = "2x"
	btn_lev_2x.size_flags_horizontal = 3
	btn_lev_2x.toggle_mode = true
	btn_lev_2x.pressed.connect(_on_leverage_selected.bind(2.0))
	_remove_focus(btn_lev_2x)
	lev_container.add_child(btn_lev_2x)
	
	trading_vbox.add_child(lev_container)
	trading_vbox.move_child(lev_container, input_container.get_index())
	_update_leverage_visuals()

func _on_leverage_selected(val: float) -> void:
	current_leverage = val
	if btn_lev_1_5x: btn_lev_1_5x.button_pressed = (val == 1.5)
	if btn_lev_2x: btn_lev_2x.button_pressed = (val == 2.0)
	_update_leverage_visuals()

func _update_leverage_visuals() -> void:
	var active_col = Color(0.2, 0.6, 0.8)
	var inactive_col = Color(0.15, 0.15, 0.2)
	var style_active = _get_card_style(active_col)
	style_active.set_corner_radius_all(6)
	var style_inactive = _get_card_style(inactive_col)
	style_inactive.set_corner_radius_all(6)
	
	if btn_lev_1_5x:
		btn_lev_1_5x.add_theme_stylebox_override("normal", style_active if current_leverage == 1.5 else style_inactive)
		btn_lev_1_5x.add_theme_stylebox_override("pressed", style_active)
	if btn_lev_2x:
		btn_lev_2x.add_theme_stylebox_override("normal", style_active if current_leverage == 2.0 else style_inactive)
		btn_lev_2x.add_theme_stylebox_override("pressed", style_active)

func _get_card_style(bg_color: Color, border_color: Color = Color.TRANSPARENT, border_width: int = 0) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.set_corner_radius_all(10)
	if border_width > 0:
		style.border_color = border_color
		style.set_border_width_all(border_width)
	return style

func _update_tab_buttons(active: Button, inactive: Button) -> void:
	var col_normal = Color(0.1, 0.1, 0.1) 
	var col_hover = Color(0.3, 0.3, 0.3)  
	var col_active = Color(0.2, 0.5, 0.9) 
	active.add_theme_stylebox_override("normal", _get_card_style(col_active))
	active.add_theme_stylebox_override("hover", _get_card_style(col_active.lightened(0.1)))
	active.add_theme_stylebox_override("pressed", _get_card_style(col_active.darkened(0.1)))
	inactive.add_theme_stylebox_override("normal", _get_card_style(col_normal))
	inactive.add_theme_stylebox_override("hover", _get_card_style(col_hover))
	inactive.add_theme_stylebox_override("pressed", _get_card_style(col_normal))

func _setup_trading_buttons() -> void:
	var spot_tab = find_child("SPOT", true, false)
	if not spot_tab: return
	var trading_tabs = spot_tab.get_parent()
	trading_tabs.tabs_visible = false
	var trade_mode_box = find_child("TradeModeToggle", true, false)
	if not trade_mode_box: return
	var btn_spot = trade_mode_box.get_node_or_null("BtnSpot")
	var btn_futures = trade_mode_box.get_node_or_null("BtnFutures")
	if btn_spot and btn_futures:
		_remove_focus(btn_spot)
		_remove_focus(btn_futures)
		_update_tab_buttons(btn_spot, btn_futures)
		if not btn_spot.pressed.is_connected(_on_mode_spot):
			btn_spot.pressed.connect(_on_mode_spot.bind(trading_tabs, btn_spot, btn_futures))
			btn_futures.pressed.connect(_on_mode_futures.bind(trading_tabs, btn_futures, btn_spot))
	_style_action_buttons()

func _on_mode_spot(tabs, btn_s, btn_f):
	current_trade_mode = "SPOT"
	tabs.current_tab = 0
	_update_tab_buttons(btn_s, btn_f)
	var lev_box = find_child("LeverageContainer", true, false)
	if lev_box: lev_box.visible = false
	_on_stock_selected(selected_stock_index)

func _on_mode_futures(tabs, btn_f, btn_s):
	current_trade_mode = "FUTURES"
	tabs.current_tab = 1
	_update_tab_buttons(btn_f, btn_s)
	var lev_box = find_child("LeverageContainer", true, false)
	if lev_box: lev_box.visible = true
	_refresh_futures_ui()

func _style_action_buttons() -> void:
	var btn_buy = find_child("BtnBuy", true, false)
	var btn_sell = find_child("BtnSell", true, false)
	var btn_long = find_child("BtnLong", true, false) 
	var btn_short = find_child("BtnShort", true, false) 
	var type_game_btn = find_child("TypeGameBtn", true, false)
	_remove_focus(btn_buy)
	_remove_focus(btn_sell)
	_remove_focus(btn_long)
	_remove_focus(btn_short)
	_remove_focus(type_game_btn)
	var fix_btn = func(btn: Button, color: Color):
		if not btn: return
		btn.add_theme_stylebox_override("normal", _get_card_style(color))
		btn.add_theme_stylebox_override("hover", _get_card_style(color.lightened(0.1)))
		btn.add_theme_stylebox_override("pressed", _get_card_style(color.darkened(0.1)))
	fix_btn.call(btn_buy, Color(0.2, 0.7, 0.3))
	fix_btn.call(btn_sell, Color(0.8, 0.3, 0.3))
	fix_btn.call(btn_long, Color(0.2, 0.7, 0.3))
	fix_btn.call(btn_short, Color(0.8, 0.3, 0.3))

func _apply_visual_styling() -> void:
	if input_usd:
		var style = _get_card_style(Color(0.15, 0.15, 0.2))
		style.content_margin_left = 10
		input_usd.add_theme_stylebox_override("normal", style)
		input_usd.add_theme_stylebox_override("focus", style)

func _on_type_game_pressed() -> void: 
	if active_minigame_layer != null and is_instance_valid(active_minigame_layer):
		_on_notification_received("Minigame already active!")
		return
	var game = preload("res://Scenes/type_minigame.tscn").instantiate()
	active_minigame_layer = CanvasLayer.new() 
	active_minigame_layer.layer = 10
	active_minigame_layer.add_child(game)
	game.minigame_won.connect(_on_minigame_won)
	game.tree_exited.connect(func():
		if is_instance_valid(active_minigame_layer):
			active_minigame_layer.queue_free()
		active_minigame_layer = null
	)
	var btn = Button.new()
	btn.text = "EXIT"
	btn.position = Vector2(20, 20)
	btn.size = Vector2(80, 40)
	btn.pressed.connect(func(): game.queue_free())
	game.add_child(btn)
	get_tree().root.add_child(active_minigame_layer)

func _on_minigame_won() -> void:
	_on_notification_received("Accessing Insider Network...")
	await get_tree().create_timer(0.5).timeout
	market_manager.generate_insider_news()

func _on_social_game_pressed() -> void:
	if active_minigame_layer != null and is_instance_valid(active_minigame_layer):
		_on_notification_received("Minigame already active!")
		return
		
	var game = preload("res://Scenes/social_engineering_game.tscn").instantiate()
	
	active_minigame_layer = CanvasLayer.new() 
	active_minigame_layer.layer = 10
	active_minigame_layer.add_child(game)
	
	if game.has_signal("game_finished"):
		game.game_finished.connect(_on_social_game_finished)
	
	game.tree_exited.connect(func():
		if is_instance_valid(active_minigame_layer):
			active_minigame_layer.queue_free()
		active_minigame_layer = null
	)
	
	get_tree().root.add_child(active_minigame_layer)

func _on_social_game_finished(success: bool) -> void:
	if success:
		_on_notification_received("Social Engineering Successful! Market Trend Manipulated.")
		var idx = randi() % market_manager.active_stocks.size()
		if market_manager.has_method("apply_insider_info"):
			market_manager.apply_insider_info(idx, 0.15) 
	else:
		_on_notification_received("Social Engineering Failed! You were blocked.")

func _on_slider_value_changed(value: float) -> void:
	if slider_label: slider_label.text = str(int(value)) + "%"
	_calculate_slider_amount()

func _calculate_slider_amount() -> void:
	var cash = GameManager.player_money
	var limit = cash
	if selected_stock_index != -1:
		var stock = market_manager.active_stocks[selected_stock_index]
		var owned_qty = GameManager.portfolio.get(stock.company_name, 0.0)
		var owned_val = owned_qty * stock.current_price
		limit = max(cash, owned_val)
	var pct = amount_slider.value / 100.0
	var calculated_usd = limit * pct
	var safe_usd = floor(calculated_usd * 100.0) / 100.0
	input_usd.text = str(safe_usd)

func _on_news_received(stock_name: String, impact: float, message: String) -> void:
	var impact_str = "📈" if impact > 0 else "📉"
	var color = Color(0.3, 0.9, 0.4) if impact > 0 else Color(0.9, 0.3, 0.3)
	var pct = snapped(impact * 100, 0.1)
	var sign_str = "+" if impact > 0 else ""
	var text = "[INSIDER] %s %s (%s%s%%)\n%s" % [impact_str, stock_name, sign_str, str(pct), message]
	_add_log_label(text, color)

func _on_notification_received(message: String) -> void:
	_add_log_label("🔔 " + message, Color(1, 0.8, 0.4))

func _add_log_label(text: String, color: Color) -> void:
	if not news_vbox_panel: return
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 13)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	news_vbox_panel.add_child(label)
	news_vbox_panel.move_child(label, 0)
	if news_vbox_panel.get_child_count() > 20:
		news_vbox_panel.get_child(news_vbox_panel.get_child_count() - 1).queue_free()

func _on_history_btn_pressed() -> void:
	var popup = history_popup_scene.instantiate()
	add_child(popup)
	popup.popup_centered()

func _on_pinjol_btn_pressed() -> void: GameManager.take_emergency_loan()
func _on_pay_debt_btn_pressed() -> void:
	var popup = pay_debt_popup_scene.instantiate()
	add_child(popup)
	popup.popup_centered()

func get_news_items() -> Array:
	var items = []
	if news_vbox_panel:
		for child in news_vbox_panel.get_children():
			if child is Label:
				items.append({
					"text": child.text,
					"color": child.get_theme_color("font_color")
				})
	return items

func _on_next_day_btn_pressed() -> void: 
	var prev_data = _capture_financial_state()
	var prev_day = GameManager.current_day
	market_manager.trigger_market_update()
	await get_tree().process_frame
	var curr_data = _capture_financial_state()
	var curr_day = GameManager.current_day
	
	GameManager.log_history(curr_data["equity"])
	
	var popup = daily_summary_scene.instantiate()
	add_child(popup)
	popup.setup(prev_data, curr_data, prev_day, curr_day)
	popup.popup_centered()

func _capture_financial_state() -> Dictionary:
	var wallet = GameManager.player_money
	var debt = GameManager.debt_amount
	var assets_val = 0.0
	for stock_name in GameManager.portfolio:
		var qty = GameManager.portfolio[stock_name]
		var price = 0.0
		for s in market_manager.active_stocks:
			if s.company_name == stock_name:
				price = s.current_price
				break
		assets_val += qty * price
	
	for stock_name in GameManager.futures_positions:
		var pnl_data = market_manager.calculate_futures_pnl(stock_name)
		assets_val += pnl_data.payout
		
	var equity = wallet + assets_val
	
	return {
		"wallet": wallet,
		"assets": assets_val,
		"debt": debt,
		"equity": equity, 
		"total": equity - debt,
		"portfolio": GameManager.portfolio.duplicate()
	}

func _on_futures_long_pressed() -> void:
	if selected_stock_index != -1 and input_usd.text.is_valid_float():
		market_manager.open_futures_position(selected_stock_index, float(input_usd.text), true, current_leverage)
		_refresh_futures_ui()

func _on_futures_short_pressed() -> void:
	if selected_stock_index != -1 and input_usd.text.is_valid_float():
		market_manager.open_futures_position(selected_stock_index, float(input_usd.text), false, current_leverage)
		_refresh_futures_ui()

func _on_close_position_pressed() -> void:
	if selected_stock_index != -1:
		market_manager.close_futures_position(selected_stock_index)
		_refresh_futures_ui()

func _refresh_futures_ui() -> void:
	if selected_stock_index == -1: return
	var stock = market_manager.active_stocks[selected_stock_index]
	var futures_tab_container = find_child("FUTURES", true, false)
	if not futures_tab_container: return
	var close_btn = futures_tab_container.get_node_or_null("ClosePosBtn")
	var btn_long = find_child("BtnLong", true, false)
	var btn_short = find_child("BtnShort", true, false)
	
	if GameManager.futures_positions.has(stock.company_name):
		var pos = GameManager.futures_positions[stock.company_name]
		var type = "LONG" if pos.is_long else "SHORT"

		var pnl_data = market_manager.calculate_futures_pnl(stock.company_name)
		var pnl_usd = pnl_data.pnl
		var pnl_pct = pnl_data.pnl_pct * 100.0
		
		var sign = "+" if pnl_usd >= 0 else ""
		var col = Color(0.3, 0.9, 0.4) if pnl_usd >= 0 else Color(0.9, 0.3, 0.3)

		owned_label.text = "%s %s (Entry: $%s) [%sx]\nPnL: %s$%s (%s%%)" % [type, stock.symbol, str(snapped(pos.entry_price, 0.1)), str(pos.leverage), sign, str(snapped(pnl_usd, 0.1)), str(snapped(pnl_pct, 0.1))]
		owned_label.modulate = col
		if not close_btn:
			close_btn = Button.new()
			close_btn.name = "ClosePosBtn"
			close_btn.text = "CLOSE POSITION"
			close_btn.custom_minimum_size.y = 40
			close_btn.size_flags_horizontal = 3
			close_btn.add_theme_stylebox_override("normal", _get_card_style(Color(0.4, 0.4, 0.5)))
			close_btn.pressed.connect(_on_close_position_pressed)
			futures_tab_container.add_child(close_btn)
			futures_tab_container.move_child(close_btn, 0)
			_remove_focus(close_btn)
		if btn_long: btn_long.visible = false
		if btn_short: btn_short.visible = false
		close_btn.visible = true
		var lev_box = find_child("LeverageContainer", true, false)
		if lev_box: lev_box.visible = false
	else:
		owned_label.text = "No active futures contracts."
		owned_label.modulate = Color(0.4, 0.7, 1.0)
		if btn_long: btn_long.visible = true
		if btn_short: btn_short.visible = true
		if close_btn: close_btn.visible = false
		var lev_box = find_child("LeverageContainer", true, false)
		if lev_box and current_trade_mode == "FUTURES": lev_box.visible = true

func rebuild_lists() -> void:
	if stock_list_container: for child in stock_list_container.get_children(): child.queue_free()
	
	if not market_manager: return
	
	var grouped_stocks = {}
	for i in range(market_manager.active_stocks.size()):
		var stock = market_manager.active_stocks[i]
		if not grouped_stocks.has(stock.category):
			grouped_stocks[stock.category] = []
		grouped_stocks[stock.category].append({"stock": stock, "index": i})
	
	var category_order = [
		"Teknologi & Media", "Energi & SDA", "Perbankan & Keuangan", 
		"Infrastruktur", "Konsumsi & Retail", "Transportasi", "Kesehatan"
	]
	
	var container = stock_list_container
	if not container: return
	
	for cat_name in category_order:
		if grouped_stocks.has(cat_name):
			# Header
			var header = Label.new()
			header.text = cat_name.to_upper()
			header.add_theme_color_override("font_color", Color(0.5, 0.6, 0.7))
			header.add_theme_font_size_override("font_size", 11)
			var margin_head = MarginContainer.new()
			margin_head.add_theme_constant_override("margin_top", 12)
			margin_head.add_theme_constant_override("margin_bottom", 4)
			margin_head.add_child(header)
			container.add_child(margin_head)
			
			# Cards
			for item in grouped_stocks[cat_name]:
				var stock = item["stock"]
				var idx = item["index"]
				
				# === UI Card Generation ===
				var btn = Button.new()
				btn.custom_minimum_size.y = 65
				
				# Normal Style
				var style_normal = _get_card_style(Color(0.16, 0.16, 0.20))
				style_normal.border_color = Color(0.25, 0.25, 0.3)
				style_normal.set_border_width_all(1)
				
				# Hover Style
				var style_hover = _get_card_style(Color(0.2, 0.2, 0.25))
				style_hover.border_color = Color(0.4, 0.4, 0.5)
				style_hover.set_border_width_all(1)
				
				# Selected Style Highlight
				if selected_stock_index == idx:
					style_normal.bg_color = Color(0.18, 0.22, 0.28)
					style_normal.border_color = Color(0.3, 0.6, 0.9)
					style_normal.set_border_width_all(2)
				
				btn.add_theme_stylebox_override("normal", style_normal)
				btn.add_theme_stylebox_override("hover", style_hover)
				btn.add_theme_stylebox_override("pressed", style_normal)
				_remove_focus(btn)
				btn.pressed.connect(_on_stock_selected.bind(idx))
				
				# Layout inside button
				var margin = MarginContainer.new()
				margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
				margin.add_theme_constant_override("margin_left", 12)
				margin.add_theme_constant_override("margin_right", 12)
				margin.add_theme_constant_override("margin_top", 8)
				margin.add_theme_constant_override("margin_bottom", 8)
				margin.mouse_filter = Control.MOUSE_FILTER_IGNORE # Let click pass to button
				
				var hbox = HBoxContainer.new()
				hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
				
				# LEFT: Symbol + Name
				var vbox_left = VBoxContainer.new()
				vbox_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				vbox_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
				vbox_left.alignment = BoxContainer.ALIGNMENT_CENTER
				
				var lbl_symbol = Label.new()
				lbl_symbol.text = stock.symbol
				lbl_symbol.add_theme_font_size_override("font_size", 16)
				# Fake bold by color brightness
				lbl_symbol.add_theme_color_override("font_color", Color(1, 1, 1)) 
				
				var lbl_name = Label.new()
				lbl_name.text = stock.company_name
				lbl_name.add_theme_font_size_override("font_size", 10)
				lbl_name.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
				lbl_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
				
				vbox_left.add_child(lbl_symbol)
				vbox_left.add_child(lbl_name)
				
				# RIGHT: Price + Change%
				var vbox_right = VBoxContainer.new()
				vbox_right.alignment = BoxContainer.ALIGNMENT_CENTER
				vbox_right.mouse_filter = Control.MOUSE_FILTER_IGNORE
				
				var lbl_price = Label.new()
				lbl_price.text = "$" + str(snapped(stock.current_price, 0.01))
				lbl_price.add_theme_font_size_override("font_size", 14)
				lbl_price.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				
				# Calc Change
				var prev_price = stock.price_history.back() if not stock.price_history.is_empty() else stock.current_price
				var change = 0.0
				if prev_price != 0:
					change = (stock.current_price - prev_price) / prev_price * 100.0
				
				var lbl_change = Label.new()
				var sign_str = "+" if change >= 0 else ""
				lbl_change.text = "%s%.2f%%" % [sign_str, change]
				lbl_change.add_theme_font_size_override("font_size", 11)
				lbl_change.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				lbl_change.add_theme_color_override("font_color", Color(0.4, 0.8, 0.5) if change >= 0 else Color(0.9, 0.4, 0.4))
				
				vbox_right.add_child(lbl_price)
				vbox_right.add_child(lbl_change)
				
				hbox.add_child(vbox_left)
				hbox.add_child(vbox_right)
				margin.add_child(hbox)
				btn.add_child(margin)
				
				container.add_child(btn)

func _on_stock_selected(index: int) -> void:
	if index >= market_manager.active_stocks.size(): return
	selected_stock_index = index
	trading_panel.visible = true
	
	# Update visual selection in list immediately
	rebuild_lists()
	
	var stock = market_manager.active_stocks[index]
	header_label.text = "📈 %s (%s)" % [stock.company_name, stock.symbol]
	price_label.text = "$%s" % str(snapped(stock.current_price, 0.01))
	_update_price_graph(stock)
	if current_trade_mode == "SPOT":
		owned_label.modulate = Color(0.4, 0.7, 1.0)
		var owned = GameManager.portfolio.get(stock.company_name, 0.0)
		var val = owned * stock.current_price 
		owned_label.text = "💼 You Own: %s ($%s)" % [str(snapped(owned, 0.001)), str(snapped(val, 0.1))]
	else: _refresh_futures_ui()
	_calculate_slider_amount()

func _update_price_graph(stock: Resource) -> void:
	if not candle_chart: return
	if not "price_history" in stock or stock.price_history.size() < 2: return
	var history = stock.price_history
	var chart_data = history.duplicate()
	chart_data.append(stock.current_price)
	if candle_chart.has_method("setup_chart"):
		candle_chart.setup_chart(chart_data)
	var min_p = candle_chart.get("min_val")
	var max_p = candle_chart.get("max_val")
	var parent_bg = candle_chart.get_parent()
	var lbl_max = parent_bg.get_node_or_null("MaxPrice")
	var lbl_min = parent_bg.get_node_or_null("MinPrice")
	var lbl_mid = parent_bg.get_node_or_null("MidPrice")
	if lbl_max: lbl_max.text = str(snapped(max_p, 0.01))
	if lbl_min: lbl_min.text = str(snapped(min_p, 0.01))
	if lbl_mid: lbl_mid.text = str(snapped(min_p + ((max_p - min_p) * 0.5), 0.01))

func _update_ui(_v=null) -> void:
	if wallet_label: wallet_label.text = "💰 $" + str(snapped(GameManager.player_money, 0.01))
	if debt_label: debt_label.text = "💳 $" + str(snapped(GameManager.debt_amount, 0.01))
	_calculate_slider_amount()

func _on_btn_buy_pressed() -> void:
	if selected_stock_index != -1 and input_usd.text.is_valid_float():
		market_manager.buy_spot(selected_stock_index, float(input_usd.text))
		_on_stock_selected(selected_stock_index)

func _on_btn_sell_pressed() -> void:
	if selected_stock_index != -1 and input_usd.text.is_valid_float():
		market_manager.sell_spot(selected_stock_index, float(input_usd.text))
		_on_stock_selected(selected_stock_index)
		
func _on_day_changed(_d) -> void: 
	rebuild_lists()
	if selected_stock_index != -1: _on_stock_selected(selected_stock_index)
	var state = _capture_financial_state()
	start_of_day_equity = state["equity"]
	_update_ui()
