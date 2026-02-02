extends PopupPanel

@onready var news_vbox = $VBoxContainer/ScrollContainer/NewsVBox
@onready var close_btn = $VBoxContainer/CloseBtn

var news_items: Array = []

func _ready() -> void:
	close_btn.pressed.connect(_on_close_pressed)
	
	
	EventBus.connect("news_released", _on_news_received)
	GameManager.connect("notif_message", _on_notification_received)
	
	load_existing_news()

func load_existing_news() -> void:	var dashboard = get_tree().get_first_node_in_group("dashboard")
	if dashboard and dashboard.has_method("get_news_items"):
		var items = dashboard.get_news_items()
		for i in range(items.size() - 1, -1, -1):
			var item = items[i]
			add_news_item(item["text"], item["color"])

func _on_news_received(stock_name: String, impact: float, message: String) -> void:
	var impact_str = "📈" if impact > 0 else "📉"
	var color = Color(0.3, 0.9, 0.4) if impact > 0 else Color(0.9, 0.3, 0.3)
	var pct = snapped(impact * 100, 0.1)
	var sign_str = "+" if impact > 0 else ""
	add_news_item("%s %s (%s%s%%) - %s" % [impact_str, stock_name, sign_str, str(pct), message], color)

func _on_notification_received(message: String) -> void:
	if message.begins_with("NEWS:"): return
	add_news_item("📢 " + message, Color(1, 0.8, 0.5))

func add_news_item(text: String, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 14)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	news_vbox.add_child(label)
	news_vbox.move_child(label, 0)
	
	if news_vbox.get_child_count() > 20:
		var oldest = news_vbox.get_child(news_vbox.get_child_count() - 1)
		oldest.queue_free()
	
	news_items.append({"text": text, "color": color})

func _on_close_pressed() -> void:
	hide()
	queue_free()
