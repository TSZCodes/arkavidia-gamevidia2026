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

# --- FRIEND'S ADDITION ---
var hidden_trend_modifier: float = 0.0

func queue_news_impact(strength: float, duration: int) -> void:
	pending_news_impact = strength
	impact_duration = duration

func update_price() -> void:
	price_history.append(current_price)
	if pending_news_impact != 0.0:
		active_news_impact = pending_news_impact
		pending_news_impact = 0.0
		
	var change_percent = randf_range(-volatility, volatility)
	
	# Apply Logic
	if impact_duration > 0:
		change_percent += active_news_impact
		active_news_impact *= 0.5
		impact_duration -= 1
	else:
		active_news_impact = 0.0
		
	# Apply Friend's Hidden Trend (Social Game)
	change_percent += hidden_trend_modifier
	# Slowly reduce the hidden trend back to 0
	hidden_trend_modifier = move_toward(hidden_trend_modifier, 0.0, 0.01)

	current_price = current_price * (1.0 + change_percent)
	if current_price < 1.0:
		current_price = 1.0

# --- FRIEND'S ADDITION ---
func apply_news_impact(strength: float, _duration_days: int) -> void:
	# This sets the trend modifier immediately
	hidden_trend_modifier = strength
	queue_news_impact(strength, _duration_days)
