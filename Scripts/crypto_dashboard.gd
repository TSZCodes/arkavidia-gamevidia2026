extends Control

@export var market_manager: Node
@export var crypto_list_container: VBoxContainer
@export var stock_list_container: VBoxContainer
@export var wallet_label: Label
@export var debt_label: Label
@export var total_assets_label: Label 
@export var trading_panel: Control
@export var header_label: Label
@export var price_label: Label
@export var owned_label: Label
@export var price_graph_line: Line2D
@export var input_usd: LineEdit
@export var news_container: Control
@export var news_button: Button
@export var news_vbox_panel: VBoxContainer

var selected_stock_index: int = -1

func _ready() -> void:
	trading_panel.visible = false

	add_to_group("dashboard")
	

	GameManager.connect("money_changed", _update_ui)
	GameManager.connect("debt_changed", _update_ui)
	GameManager.connect("day_changed", _on_day_changed)
	
	EventBus.connect("news_released", _on_news_received)
	GameManager.connect("notif_message", _on_notification_received)
	

	setup_news_container()
	
	if news_button:
		news_button.pressed.connect(_on_news_button_pressed)
	
	_update_ui()
	rebuild_lists()

func setup_news_container() -> void:
	if news_vbox_panel:
		news_vbox = news_vbox_panel
		for child in news_vbox.get_children():
			child.queue_free()
		
		var welcome_label = Label.new()
		welcome_label.text = "📰 News will appear here..."
		welcome_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))
		welcome_label.add_theme_font_size_override("font_size", 12)
		news_vbox.add_child(welcome_label)
	elif news_container:
		for child in news_container.get_children():
			child.queue_free()
		
		var scroll = ScrollContainer.new()
		scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		news_container.add_child(scroll)
		
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(vbox)
		
		news_vbox = vbox
		
		var welcome_label = Label.new()
		welcome_label.text = "📰 Latest news will appear here..."
		welcome_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))
		welcome_label.add_theme_font_size_override("font_size", 12)
		welcome_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		news_vbox.add_child(welcome_label)

var news_vbox: VBoxContainer

func _on_day_changed(_day: int) -> void:
	rebuild_lists()
	_update_asset_tracker()
	if selected_stock_index != -1:
		_on_stock_selected(selected_stock_index)

func rebuild_lists() -> void:
	for child in crypto_list_container.get_children():
		child.queue_free()
	for child in stock_list_container.get_children():
		child.queue_free()

	for i in range(market_manager.active_stocks.size()):
		var stock = market_manager.active_stocks[i]
		var btn = Button.new()
		btn.text = stock.symbol + " $" + str(snapped(stock.current_price, 0.01))
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size.y = 45
		
		btn.add_theme_stylebox_override("normal", create_button_style(Color(0.15, 0.15, 0.2)))
		btn.add_theme_stylebox_override("hover", create_button_style(Color(0.2, 0.2, 0.25)))
		btn.add_theme_stylebox_override("pressed", create_button_style(Color(0.1, 0.1, 0.15)))
		
		btn.pressed.connect(_on_stock_selected.bind(i))
		
		if stock.is_crypto:
			crypto_list_container.add_child(btn)
		else:
			stock_list_container.add_child(btn)

func create_button_style(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	style.content_margin_left = 10
	style.content_margin_right = 10
	return style

func _on_stock_selected(index: int) -> void:
	selected_stock_index = index
	trading_panel.visible = true
	var stock = market_manager.active_stocks[index]
	header_label.text = "📈 " + stock.company_name + " (" + stock.symbol + ")"
	price_label.text = "$" + str(snapped(stock.current_price, 0.01))
	
	var owned = GameManager.portfolio.get(stock.company_name, 0.0)
	var current_usd_value = owned * stock.current_price 
	
	owned_label.text = "💼 You Own: " + str(snapped(owned, 0.0001)) + " coins ($" + str(snapped(current_usd_value, 0.01)) + ")"
	
	if stock.price_history.size() > 1:
		var prev_price = stock.price_history[stock.price_history.size() - 2]
		var change = ((stock.current_price - prev_price) / prev_price) * 100
		var change_str = "+" + str(snapped(change, 0.01)) + "%" if change >= 0 else str(snapped(change, 0.01)) + "%"
		var price_change_label = get_node_or_null("MainLayout/TradingPanel/VBoxContainer/PriceChange")
		if price_change_label:
			price_change_label.text = change_str
			price_change_label.modulate = Color(0.3, 0.9, 0.4) if change >= 0 else Color(0.9, 0.3, 0.3)

func _update_ui(_v=null) -> void:
	wallet_label.text = "💰 WALLET: $" + str(snapped(GameManager.player_money, 0.01))
	debt_label.text = "💳 DEBT: $" + str(snapped(GameManager.debt_amount, 0.01))
	_update_asset_tracker()

func _update_asset_tracker() -> void:
	var total_market_value: float = 0.0
	
	for stock in market_manager.active_stocks:
		var owned_qty = GameManager.portfolio.get(stock.company_name, 0.0)
		total_market_value += (owned_qty * stock.current_price) 
	
	if total_assets_label:
		total_assets_label.text = "📊 ASSETS: $" + str(snapped(total_market_value, 0.01))

# --- BUTTON ACTIONS ---

func _on_btn_buy_pressed() -> void:
	if selected_stock_index != -1 and input_usd.text.is_valid_float():
		var amount = float(input_usd.text)
		if amount > 0:
			market_manager.buy_stock_usd(selected_stock_index, amount)
			_after_trade_cleanup()

func _on_btn_sell_pressed() -> void:
	if selected_stock_index != -1 and input_usd.text.is_valid_float():
		var amount = float(input_usd.text)
		if amount > 0:
			market_manager.sell_stock_usd(selected_stock_index, amount)
			_after_trade_cleanup()

func _after_trade_cleanup() -> void:
	input_usd.text = "" 
	_on_stock_selected(selected_stock_index) 
	_update_asset_tracker()

func _on_next_day_btn_pressed() -> void:
	market_manager.trigger_market_update()

func _on_tab_container_tab_changed(tab: int) -> void:
	var target_container = crypto_list_container if tab == 0 else stock_list_container
	if target_container.get_child_count() > 0:
		target_container.get_child(0).emit_signal("pressed")

func _on_pinjol_btn_pressed() -> void:
	GameManager.take_emergency_loan()

func _on_btn_short_pressed() -> void:
	if selected_stock_index != -1 and input_usd.text.is_valid_float():
		var amount = float(input_usd.text)
		if amount > 0:
			market_manager.short_stock_usd(selected_stock_index, amount)
			_after_trade_cleanup()

func _on_btn_cover_pressed() -> void:
	if selected_stock_index != -1 and input_usd.text.is_valid_float():
		var amount = float(input_usd.text)
		if amount > 0:
			market_manager.cover_stock_usd(selected_stock_index, amount)
			_after_trade_cleanup()

# --- NEWS TICKER ---

func _on_news_received(stock_name: String, impact: float, message: String) -> void:
	if news_vbox:
		var impact_str = "📈" if impact > 0 else "📉"
		var pct = snapped(impact * 100, 0.1)
		var sign_str = "+" if impact > 0 else ""
		var news_text = "%s %s (%s%s%%) - %s" % [impact_str, stock_name, sign_str, str(pct), message]
		
		var news_label = Label.new()
		news_label.text = news_text
		var color = Color(0.3, 0.9, 0.4) if impact > 0 else Color(0.9, 0.3, 0.3)
		news_label.add_theme_color_override("font_color", color)
		news_label.add_theme_font_size_override("font_size", 14)
		
		for child in news_vbox.get_children():
			if child is Label and child.text.begins_with("📰 News will appear"):
				child.queue_free()
			
		news_vbox.add_child(news_label)
		news_vbox.move_child(news_label, 0)
		
		news_label.modulate = Color(1, 1, 0, 1)
		var tween = create_tween()
		tween.tween_property(news_label, "modulate", color, 0.5)
		
		while news_vbox.get_child_count() > 8:
			var oldest = news_vbox.get_child(news_vbox.get_child_count() - 1)
			oldest.queue_free()

func _on_notification_received(message: String) -> void:
	if message.begins_with("NEWS:"): return
	
	if news_vbox:
		var notif_label = Label.new()
		notif_label.text = "📢 " + message
		notif_label.add_theme_color_override("font_color", Color(1, 0.8, 0.5, 1))
		notif_label.add_theme_font_size_override("font_size", 12)
		notif_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		news_vbox.add_child(notif_label)
		news_vbox.move_child(notif_label, 0)
		
		notif_label.modulate = Color(1, 1, 0, 1)
		var tween = create_tween()
		tween.tween_property(notif_label, "modulate", Color(1, 0.8, 0.5, 1), 0.5)
		
		if news_vbox.get_child_count() > 15:
			var oldest = news_vbox.get_child(news_vbox.get_child_count() - 1)
			oldest.queue_free()

func _on_news_button_pressed() -> void:
	var news_scene = preload("res://Scenes/news_window.tscn").instantiate()
	get_tree().root.add_child(news_scene)
	news_scene.popup_centered()

func get_news_items() -> Array:
	var items = []
	if news_vbox:
		for child in news_vbox.get_children():
			if child is Label:
				if child.text.begins_with("📰"):
					continue
				var item = {
					"text": child.text,
					"color": child.get_theme_color("font_color", "Label")
				}
				items.append(item)
	return items
