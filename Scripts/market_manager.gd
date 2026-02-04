extends Node

var all_possible_stocks: Array[StockData] = []
var active_stocks: Array[StockData] = []
var max_active_stocks: int = 100 

var good_news_templates = ["partners with tech giant.", "reports record profits.", "launches revolutionary product.", "approved by regulators.", "receives massive investment."]
var bad_news_templates = ["faces class-action lawsuit.", "suffers major data breach.", "CEO steps down.", "banned in major country.", "misses earnings report."]

var false_info_chance: float = 0.2

func _ready() -> void:
	_generate_custom_stocks()
	update_active_stocks()
	# Connect to the event bus for the friend's social game logic
	if not EventBus.news_released.is_connected(_on_news_received):
		EventBus.news_released.connect(_on_news_received)

func _generate_custom_stocks() -> void:
	var definitions = [
		# Sektor teknologi dan media
		["Sumsang Electronics", "SSNG", "Teknologi & Media", 1200.0, false],
		["Xiomay Global", "XMI", "Teknologi & Media", 50.0, false],
		["Gugle Search & Destroy", "GGL", "Teknologi & Media", 2800.0, false],
		["Ipong", "IPNG", "Teknologi & Media", 180.0, false],
		["Betaverse", "META", "Teknologi & Media", 300.0, false],
		["WhyApp", "WHY", "Teknologi & Media", 150.0, false],
		["Mouse Trap House", "MTH", "Teknologi & Media", 90.0, false],
		["Rocksun", "RKSN", "Teknologi & Media", 110.0, false],
		["NASI", "NASI", "Teknologi & Media", 2000.0, false],
		["Indigo", "IND", "Teknologi & Media", 25.0, false],
		
		# Sektor energi dan SDA
		["Pertamini Jaya", "PRTM", "Energi & SDA", 500.0, false],
		["Sawit Makmur Hektaran", "SMH", "Energi & SDA", 80.0, false],
		["Batu Bara Hitam Pekat", "BBHP", "Energi & SDA", 120.0, false],
		["Big Battery Cell", "BBC", "Energi & SDA", 300.0, false],
		["Sang Surya dan Pertiwi", "SSP", "Energi & SDA", 45.0, false],
		["Pabrik Semua Kesetrum", "PSK", "Energi & SDA", 220.0, false],
		["Amateur Biotech Company", "ABC", "Energi & SDA", 15.0, false],
		
		# Sektor perbankan dan keuangan
		["Bank Central Aselole", "BCA", "Perbankan & Keuangan", 850.0, false],
		["Pinjol Berkedok Kaya", "PBKI", "Perbankan & Keuangan", 5.0, false],
		["Asuransi Sakit Hati", "ASH", "Perbankan & Keuangan", 40.0, false],
		["Crypto C nya Cihuy", "CCC", "Perbankan & Keuangan", 0.5, true], 
		
		# Sektor infrastruktur dan konstruksi
		["Waskito atau Waskita", "WWG", "Infrastruktur", 60.0, false],
		["Semen Keras Kepala", "SKK", "Infrastruktur", 150.0, false],
		["Tol Langit Permaisuri", "TLP", "Infrastruktur", 90.0, false],
		
		# Sektor konsumsi dan retail
		["PT Makanan Indo", "INDO", "Konsumsi & Retail", 15.0, false],
		["Unipeler Indonesia", "ULVR", "Konsumsi & Retail", 450.0, false],
		["Indoapril", "IDAP", "Konsumsi & Retail", 30.0, false],
		["Bolosmart", "BLSM", "Konsumsi & Retail", 28.0, false],
		["Rokok Matahari", "RMTH", "Konsumsi & Retail", 65.0, false],
		["Rokok Cacat", "RCCT", "Konsumsi & Retail", 55.0, false],
		
		# Sektor transportasi dan logistik
		["Ojolali", "OJL", "Transportasi", 12.0, false],
		["Elang Jawa", "ELJA", "Transportasi", 80.0, false],
		["Kapal Laut Neptunus", "KLN", "Transportasi", 200.0, false],
		
		# Sektor kesehatan
		["Abioparma", "ABIO", "Kesehatan", 320.0, false],
		["Payung Corp.", "UMB", "Kesehatan", 666.0, false],
		["PT Panasea", "PANA", "Kesehatan", 45.0, false]
	]
	
	for def in definitions:
		var stock = StockData.new()
		stock.company_name = def[0]
		stock.symbol = def[1]
		stock.category = def[2]
		stock.current_price = def[3]
		stock.is_crypto = def[4]
		stock.volatility = 0.08 if stock.is_crypto else 0.03
		all_possible_stocks.append(stock)

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

func generate_insider_news() -> void:
	if active_stocks.is_empty(): return
	var stock = active_stocks.pick_random()
	var is_good = randf() > 0.5
	var volatility_multiplier = randf_range(2.0, 5.0)
	var impact = stock.volatility * volatility_multiplier * (1 if is_good else -1)
	var msg = good_news_templates.pick_random() if is_good else bad_news_templates.pick_random()
	EventBus.emit_signal("news_released", stock.company_name, impact, msg)

func trigger_market_update() -> void:
	for stock in active_stocks:
		stock.update_price()
	GameManager.next_day()

func buy_spot(index: int, usd_amount: float) -> void:
	if index >= active_stocks.size() or usd_amount <= 0: return
	var stock = active_stocks[index]
	if GameManager.spend_money(usd_amount):
		var coins = usd_amount / stock.current_price
		var current_owned = GameManager.portfolio.get(stock.company_name, 0.0)
		GameManager.portfolio[stock.company_name] = current_owned + coins

func sell_spot(index: int, usd_amount: float) -> void:
	if index >= active_stocks.size() or usd_amount <= 0: return
	var stock = active_stocks[index]
	var current_owned = GameManager.portfolio.get(stock.company_name, 0.0)
	var coins_to_sell = usd_amount / stock.current_price
	if current_owned >= coins_to_sell:
		GameManager.portfolio[stock.company_name] = current_owned - coins_to_sell
		GameManager.add_money(usd_amount)
	else:
		var payout = current_owned * stock.current_price
		GameManager.portfolio[stock.company_name] = 0.0
		GameManager.add_money(payout)

func open_futures_position(index: int, usd_margin: float, is_long: bool, leverage: float = 2.0) -> void:
	if index >= active_stocks.size() or usd_margin <= 0: return
	var stock = active_stocks[index]
	if GameManager.futures_positions.has(stock.company_name):
		GameManager.emit_signal("notif_message", "Close existing " + stock.symbol + " position first!")
		return
	if GameManager.spend_money(usd_margin):
		var position = {
			"entry_price": stock.current_price,
			"margin": usd_margin,
			"is_long": is_long,
			"leverage": leverage,
			"symbol": stock.symbol
		}
		GameManager.futures_positions[stock.company_name] = position
		var type_str = "LONG" if is_long else "SHORT"
		GameManager.emit_signal("notif_message", "Opened %s on %s (%sx)" % [type_str, stock.symbol, str(leverage)])

func calculate_futures_pnl(stock_name: String) -> Dictionary:
	if not GameManager.futures_positions.has(stock_name):
		return {"pnl": 0.0, "pnl_pct": 0.0, "payout": 0.0}

	var pos = GameManager.futures_positions[stock_name]
	var stock = null
	for s in active_stocks:
		if s.company_name == stock_name:
			stock = s
			break
	if not stock: return {"pnl": 0.0, "pnl_pct": 0.0, "payout": 0.0}

	var price_diff_pct = (stock.current_price - pos.entry_price) / pos.entry_price
	if not pos.is_long: price_diff_pct *= -1.0
	
	var pnl_pct = price_diff_pct * pos.leverage
	var payout = pos.margin * (1.0 + pnl_pct)
	if payout < 0: payout = 0.0
	var profit = payout - pos.margin
	return {"pnl": profit, "pnl_pct": pnl_pct, "payout": payout}

func close_futures_position(index: int) -> void:
	if index >= active_stocks.size(): return
	var stock = active_stocks[index]
	if not GameManager.futures_positions.has(stock.company_name): return
	
	var calc = calculate_futures_pnl(stock.company_name)
	
	GameManager.add_money(calc.payout)
	GameManager.futures_positions.erase(stock.company_name)
	
	var sign = "+" if calc.pnl >= 0 else "-"
	GameManager.emit_signal("notif_message", "Closed " + stock.symbol + ": " + sign + "$" + str(abs(int(calc.pnl))))

# --- SOCIAL GAME SUPPORT (UPDATED) ---
func apply_insider_info(stock_index: int, impact: float) -> void:
	if stock_index >= active_stocks.size(): return
	var stock = active_stocks[stock_index]
	
	var final_impact = impact
	var is_lie = false
	
	# Twist: 20% chance the info is wrong (False Info)
	if randf() < false_info_chance:
		final_impact *= -1.0 
		is_lie = true
		
	stock.hidden_trend_modifier += final_impact
	
	# === THIS IS THE FIX: EMIT THE VISUAL SIGNAL ===
	var msg = "Intel from Social Engineering"
	if is_lie: msg += " (Source seems suspicious...)"
	EventBus.emit_signal("news_released", stock.company_name, final_impact, msg)

func _on_news_received(stock_name: String, impact: float, message: String) -> void:
	for stock in active_stocks:
		if stock.company_name == stock_name:
			stock.apply_news_impact(impact, 3)