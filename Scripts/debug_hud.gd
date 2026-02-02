extends Control

@export var market_manager: Node 
@export var money_label: Label
@export var debt_label: Label
@export var day_label: Label
@export var stock_container: VBoxContainer
@export var pay_debt_btn: Button

func _ready() -> void:
	GameManager.connect("money_changed", _on_money_changed)
	GameManager.connect("debt_changed", _on_debt_changed)
	GameManager.connect("day_changed", _on_day_changed)
	GameManager.connect("notif_message", _on_notif_message)
	
	# Initial UI
	_on_money_changed(GameManager.player_money)
	_on_debt_changed(GameManager.debt_amount)
	_on_day_changed(GameManager.current_day)
	
	generate_stock_ui()

func generate_stock_ui() -> void:
	for child in stock_container.get_children():
		child.queue_free()
	
	for i in range(market_manager.active_stocks.size()):
		var stock = market_manager.active_stocks[i]
		
		# Main Row
		var row = VBoxContainer.new()
		
		# Info
		var info_label = Label.new()
		info_label.text = stock.company_name + " $" + str(int(stock.current_price))
		row.add_child(info_label)
		
		# -- BUTTON ROW --
		var btn_row = HBoxContainer.new()
		
		# INVESTING BUTTONS (Green)
		var buy_btn = Button.new()
		buy_btn.text = "BUY (Long)"
		buy_btn.modulate = Color.GREEN
		buy_btn.pressed.connect(func(): market_manager.buy_stock_usd(i, 10); refresh_stock_list())
		btn_row.add_child(buy_btn)
		
		var sell_btn = Button.new()
		sell_btn.text = "SELL"
		sell_btn.pressed.connect(func(): market_manager.sell_stock_usd(i, 10); refresh_stock_list())
		btn_row.add_child(sell_btn)
		
		# SHORTING BUTTONS (Red)
		var short_btn = Button.new()
		short_btn.text = "SHORT"
		short_btn.modulate = Color.RED
		short_btn.pressed.connect(func(): market_manager.short_stock_usd(i, 10); refresh_stock_list())
		btn_row.add_child(short_btn)
		
		var cover_btn = Button.new()
		cover_btn.text = "COVER"
		cover_btn.modulate = Color.ORANGE
		cover_btn.pressed.connect(func(): market_manager.cover_stock_usd(i, 10); refresh_stock_list())
		btn_row.add_child(cover_btn)
		
		row.add_child(btn_row)
		stock_container.add_child(row)

func refresh_stock_list() -> void:
	generate_stock_ui()

func _on_money_changed(_new_amount: float) -> void:
	if money_label:
		money_label.text = "CASH: $" + str(snapped(GameManager.player_money, 0.01))

func _on_debt_changed(_new_debt: float) -> void:
	if debt_label:
		debt_label.text = "DEBT: $" + str(snapped(GameManager.debt_amount, 0.01))
	if pay_debt_btn:
		var payment = min(500.0, GameManager.player_money)
		pay_debt_btn.text = "PAY DEBT ($" + str(snapped(payment, 0.01)) + ")"

func _on_day_changed(new_day: int) -> void:
	if day_label:
		day_label.text = "DAY: " + str(new_day)
	refresh_stock_list()

func _on_notif_message(text: String) -> void:
	print("NOTIFICATION: ", text)

func _on_next_day_pressed() -> void:
	market_manager.trigger_market_update()
