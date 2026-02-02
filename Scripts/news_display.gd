extends PopupPanel

@onready var news_vbox = $VBoxContainer/NewsScroll/NewsVBox
@onready var close_button = $VBoxContainer/CloseButton

func _ready() -> void:
	EventBus.connect("news_released", _on_news_received)
	GameManager.connect("notif_message", _on_notification_received)
	close_button.pressed.connect(_on_close_pressed)
	
	# Add welcome message
	var welcome_label = Label.new()
	welcome_label.text = "📰 Market News Feed\n\nNews and notifications will appear here.\nClick '🌙 SLEEP' to advance days and generate market news!"
	welcome_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
	welcome_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	news_vbox.add_child(welcome_label)
	
	# Populate with recent news from crypto dashboard
	call_deferred("populate_recent_news")

func populate_recent_news() -> void:
	# Get recent news from crypto dashboard
	var crypto_dashboard = get_node("../CryptoDashboard")
	if crypto_dashboard and crypto_dashboard.has_method("get_news_items"):
		var recent_news = crypto_dashboard.get_news_items()
		# Add recent news (skip the welcome message)
		for i in range(min(5, recent_news.size())):  # Show last 5 items
			var item = recent_news[recent_news.size() - 1 - i]
			if item.text != "📰 Latest news will appear here...":  # Skip welcome
				var label = Label.new()
				label.text = item.text
				label.add_theme_color_override("font_color", item.color)
				label.add_theme_font_size_override("font_size", 14)
				label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				news_vbox.add_child(label)
				news_vbox.move_child(label, 1)  # After welcome message

func _on_news_received(stock_name: String, impact: float, message: String) -> void:
	if news_vbox:
		var impact_str = "📈" if impact > 0 else "📉"
		var news_text = impact_str + " " + stock_name + " - " + message
		
		# Create new news label
		var news_label = Label.new()
		news_label.text = news_text
		news_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3, 1))
		news_label.add_theme_font_size_override("font_size", 14)
		news_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		# Add to top of the list
		news_vbox.add_child(news_label)
		news_vbox.move_child(news_label, 0)
		
		# Animate the new news
		news_label.modulate = Color(1, 1, 0, 1)
		var tween = create_tween()
		tween.tween_property(news_label, "modulate", Color(1, 0.9, 0.3, 1), 0.5)
		
		# Limit to 20 news items
		if news_vbox.get_child_count() > 20:
			var oldest = news_vbox.get_child(news_vbox.get_child_count() - 1)
			oldest.queue_free()

func _on_notification_received(message: String) -> void:
	if news_vbox:
		# Create new notification label
		var notif_label = Label.new()
		notif_label.text = "📢 " + message
		notif_label.add_theme_color_override("font_color", Color(1, 0.8, 0.5, 1))
		notif_label.add_theme_font_size_override("font_size", 14)
		notif_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		# Add to top of the list
		news_vbox.add_child(notif_label)
		news_vbox.move_child(notif_label, 0)
		
		# Animate the new notification
		notif_label.modulate = Color(1, 1, 0, 1)
		var tween = create_tween()
		tween.tween_property(notif_label, "modulate", Color(1, 0.8, 0.5, 1), 0.5)
		
		# Limit to 20 items total
		if news_vbox.get_child_count() > 20:
			var oldest = news_vbox.get_child(news_vbox.get_child_count() - 1)
			oldest.queue_free()

func _on_close_pressed() -> void:
	hide()
