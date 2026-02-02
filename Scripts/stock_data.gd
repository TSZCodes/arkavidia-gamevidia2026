class_name StockData
extends Resource

@export var company_name: String = "Stock Ltd"
@export var symbol: String = "STK"
@export var current_price: float = 100.0
@export var volatility: float = 0.1 
@export var is_crypto: bool = false 


var hidden_trend_modifier: float = 0.0


var price_history: Array[float] = []

func update_price() -> void:

	price_history.append(current_price)

	var fluctuation = randf_range(-volatility, volatility)


	var final_change_percent = fluctuation + hidden_trend_modifier

	current_price = current_price * (1.0 + final_change_percent)

	if current_price < 1.0:
		current_price = 1.0

	hidden_trend_modifier = move_toward(hidden_trend_modifier, 0.0, 0.05)

func apply_news_impact(strength: float, duration_days: int) -> void:
	hidden_trend_modifier = strength
	print("News impact applied to ", company_name, ": ", strength)