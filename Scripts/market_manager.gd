extends Node

@export var all_possible_stocks: Array[StockData] = []
var active_stocks: Array[StockData] = []

var max_active_stocks: int = 6
var false_info_chance: float = 0.2

var good_news_templates = [
	"announces breakthrough technology!",
	"partners with major tech giant.",
	"reports record quarterly profits.",
	"CEO announces stock buyback program.",
	"receives regulatory approval for new product."
]

var bad_news_templates = [
	"faces lawsuit over patent infringement.",
	"CEO steps down amid controversy.",
	"reports disappointing earnings.",
	"suffers data breach affecting millions.",
	"faces regulatory scrutiny."
]

func _ready() -> void:
	EventBus.connect("news_released", _on_news_received)
	update_active_stocks()

func update_active_stocks() -> void:
	active_stocks.clear()
	for i in range(min(max_active_stocks, all_possible_stocks.size())):
		var stock = all_possible_stocks[i]
		active_stocks.append(stock)
	
		if stock.price_history.is_empty():
			var fake_price = stock.current_price * 0.9
			for d in range(10):
				stock.price_history.append(fake_price)
				fake_price *= randf_range(0.95, 1.05)
			stock.price_history.append(stock.current_price)

func trigger_market_update() -> void:
	generate_daily_news()
	for stock in active_stocks:
		stock.update_price()
	GameManager.next_day()

func generate_daily_news() -> void:
	if active_stocks.is_empty(): return
	
	# 40% chance of news each day
	if randf() < 0.4:
		var stock = active_stocks.pick_random()
		var is_good = randf() > 0.5
		var impact = randf_range(0.1, 0.2)
		if not is_good: impact *= -1.0
		
		var msg = good_news_templates.pick_random() if is_good else bad_news_templates.pick_random()
			
		EventBus.emit_signal("news_released", stock.company_name, impact, msg)

# --- USD-BASED TRADING ---

func buy_stock_usd(index: int, usd_to_spend: float) -> void:
	if index >= active_stocks.size() or usd_to_spend <= 0: return
	var stock = active_stocks[index]

	var final_usd = min(usd_to_spend, GameManager.player_money)
	var coin_amount = final_usd / stock.current_price
	
	if GameManager.spend_money(final_usd):
		add_to_portfolio(stock.company_name, coin_amount)

func sell_stock_usd(index: int, usd_to_receive: float) -> void:
	if index >= active_stocks.size() or usd_to_receive <= 0: return
	var stock = active_stocks[index]
	
	var coins_needed = usd_to_receive / stock.current_price
	var currently_owned = GameManager.portfolio.get(stock.company_name, 0.0)

	var actual_coins = min(coins_needed, currently_owned)
	var payout = actual_coins * stock.current_price
	
	if actual_coins > 0:
		GameManager.add_money(payout)
		add_to_portfolio(stock.company_name, -actual_coins)

func short_stock_usd(index: int, usd_to_short: float) -> void:
	if index >= active_stocks.size() or usd_to_short <= 0: return
	var stock = active_stocks[index]
	var coin_amount = usd_to_short / stock.current_price
	
	GameManager.add_money(usd_to_short)
	add_to_portfolio(stock.company_name, -coin_amount)

func cover_stock_usd(index: int, usd_to_cover: float) -> void:
	if index >= active_stocks.size() or usd_to_cover <= 0: return
	var stock = active_stocks[index]
	var currently_owned = GameManager.portfolio.get(stock.company_name, 0.0)
	
	if currently_owned < 0:
		var coins_to_buy = usd_to_cover / stock.current_price
		var actual_coins = min(coins_to_buy, abs(currently_owned))
		var cost = actual_coins * stock.current_price
		
		if GameManager.spend_money(cost):
			add_to_portfolio(stock.company_name, actual_coins)

func add_to_portfolio(name: String, amount: float) -> void:
	GameManager.portfolio[name] = GameManager.portfolio.get(name, 0.0) + amount

# --- UPGRADES & INTEL ---

func apply_insider_info(stock_index: int, impact: float) -> void:
	if stock_index >= active_stocks.size(): return
	var stock = active_stocks[stock_index]
	if randf() < false_info_chance:
		impact *= -1.0
	stock.hidden_trend_modifier += impact

func _on_news_received(stock_name: String, impact: float, message: String) -> void:
	# Find the stock in our active list
	for stock in active_stocks:
		if stock.company_name == stock_name:
			stock.apply_news_impact(impact, 3)
			GameManager.emit_signal("notif_message", "NEWS: " + stock_name + " " + message)
