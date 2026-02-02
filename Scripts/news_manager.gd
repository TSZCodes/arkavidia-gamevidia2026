# res://Scripts/news_manager.gd
extends Node

var headlines = {
    "BITCOIN": ["BTC legal tender in new country!", "Crypto hack scares investors."],
    "TESLA": ["Tesla AI bot goes viral!", "Recall affects thousands of cars."],
    "NVIDIA": ["New AI chips sell out!", "Supply chain issues delay production."]
}

func trigger_random_news() -> void:
    var keys = headlines.keys()
    var stock_name = keys[randi() % keys.size()]
    var is_good = randf() > 0.5
    var msg = headlines[stock_name][0 if is_good else 1]
    
    # Positive impact = Price Pump, Negative = Price Dump
    var impact = randf_range(0.2, 0.4) * (1 if is_good else -1)
    
    # Send the signal through the global bus
    EventBus.emit_signal("news_released", stock_name, impact, msg)
