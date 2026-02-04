class_name StockData
extends Resource

@export var company_name: String = "Stock Ltd"
@export var symbol: String = "STK"
@export var current_price: float = 100.0
@export var volatility: float = 0.05
@export var is_crypto: bool = false
@export var category: String = "General"

var price_history: Array[float] = []
var pending_news_impact: float = 0.0
var active_news_impact: float = 0.0
var impact_duration: int = 0

func queue_news_impact(strength: float, duration: int) -> void:
	pending_news_impact = strength
	impact_duration = duration

func update_price() -> void:
	price_history.append(current_price)
	if pending_news_impact != 0.0:
		active_news_impact = pending_news_impact
		pending_news_impact = 0.0
	var change_percent = randf_range(-volatility, volatility)
	if impact_duration > 0:
		change_percent += active_news_impact
		active_news_impact *= 0.5
		impact_duration -= 1
	else:
		active_news_impact = 0.0
	current_price = current_price * (1.0 + change_percent)
	if current_price < 1.0:
		current_price = 1.0