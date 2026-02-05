extends Node

@warning_ignore_start("unused_signal")
# Signal to broadcast news to the entire game
signal news_released(stock_name: String, impact: float, message: String)
