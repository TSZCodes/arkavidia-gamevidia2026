extends Control

# Signal to tell the dashboard the result
signal game_finished(success: bool, target_symbol: String)

# Stock symbol mapping from tweet mentions to actual stock symbols
var stock_mapping = {
	"Bank Central Aselole": "BCA",
	"BCA": "BCA",
	"Waskito atau Waskita": "WWG",
	"WWG": "WWG",
	"Betaverse": "META",
	"META": "META",
	"Sumsang Electronics": "SSNG",
	"SSNG": "SSNG",
	"Rocksun": "RKSN",
	"RKSN": "RKSN",
	"Xiomay Global": "XMI",
	"XMI": "XMI",
	"Mouse Trap House": "MTH",
	"MTH": "MTH",
	"SiNN": "NASI",
	"NASI": "NASI",
	"WhyApp": "WHY",
	"WHY": "WHY",
	"Pinjol Berkedok Kaya": "PBKI",
	"PBKI": "PBKI",
	"Pertamini Jaya": "PRTM",
	"PRTM": "PRTM",
	"Sawit Makmur Hektaran": "SMH",
	"SMH": "SMH",
	"Payung Corp.": "UMB",
	"UMB": "UMB",
	"Abioparma": "ABIO",
	"ABIO": "ABIO",
	"Ojolali": "OJL",
	"OJL": "OJL",
	"Elang Jawa": "ELJA",
	"ELJA": "ELJA",
	"Kapal Laut Neptunus": "KLN",
	"KLN": "KLN",
	"Big Battery Cell": "BBC",
	"BBC": "BBC",
	"Gugle": "GGL",
	"GGL": "GGL",
	"Ipong": "IPNG",
	"IPNG": "IPNG",
	"Indigo": "IND",
	"Semen Keras Kepala": "SKK",
	"SKK": "SKK",
	"Tol Langit Permaisuri": "TLP",
	"TLP": "TLP",
	"PT Makanan Indo": "INDO",
	"Unipeler Indonesia": "ULVR",
	"Indoapril": "IDAP",
	"Bolosmart": "BLSM",
	"Rokok Matahari": "RMTH",
	"Rokok Cacat": "RCCT",
	"Amateur Biotech Company": "ABC",
	"PT Panasea": "PANA"
}

var affected_stocks: Array = []
var post_container: VBoxContainer

func _ready() -> void:
	# Create the full UI
	_create_ui()
	
	# Load posts from JSON
	_load_posts()

func _create_ui() -> void:
	# Background
	var bg = Panel.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.08, 0.08, 0.1, 1)
	bg.add_theme_stylebox_override("panel", bg_style)
	add_child(bg)
	
	# Header Panel
	var header_panel = PanelContainer.new()
	header_panel.custom_minimum_size = Vector2(0, 70)
	header_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header_panel.offset_bottom = 70
	add_child(header_panel)
	
	var header_margin = MarginContainer.new()
	header_margin.add_theme_constant_override("margin_left", 20)
	header_margin.add_theme_constant_override("margin_right", 20)
	header_panel.add_child(header_margin)
	
	var header_vbox = VBoxContainer.new()
	header_vbox.add_theme_constant_override("separation", 3)
	header_margin.add_child(header_vbox)
	
	var title = Label.new()
	title.text = "📱 SOCIAL MEDIA FEED"
	title.add_theme_color_override("font_color", Color(0.4, 0.7, 1))
	title.add_theme_font_size_override("font_size", 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_vbox.add_child(title)
	
	var subtitle = Label.new()
	subtitle.text = "🔒 Hack the feed to discover insider intel on ONE hidden stock!"
	subtitle.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_vbox.add_child(subtitle)
	
	# Scroll Container
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 70
	scroll.offset_bottom = -70
	scroll.vertical_scroll_mode = 2
	add_child(scroll)
	
	post_container = VBoxContainer.new()
	post_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	post_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	post_container.add_theme_constant_override("separation", 12)
	scroll.add_child(post_container)
	
	# Spacer Top
	var spacer_top = Control.new()
	spacer_top.custom_minimum_size = Vector2(0, 15)
	post_container.add_child(spacer_top)
	
	# Back Button
	var back_btn = Button.new()
	back_btn.custom_minimum_size = Vector2(0, 55)
	back_btn.text = "← BACK (Apply Insider Info)"
	back_btn.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	back_btn.add_theme_font_size_override("font_size", 16)
	back_btn.pressed.connect(_on_back_btn_pressed)
	post_container.add_child(back_btn)
	
	# Spacer Bottom
	var spacer_bottom = Control.new()
	spacer_bottom.custom_minimum_size = Vector2(0, 15)
	post_container.add_child(spacer_bottom)
	
	# Footer Panel
	var footer_panel = PanelContainer.new()
	footer_panel.custom_minimum_size = Vector2(0, 70)
	footer_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	footer_panel.offset_top = -70
	add_child(footer_panel)
	
	var footer_margin = MarginContainer.new()
	footer_margin.add_theme_constant_override("margin_left", 20)
	footer_margin.add_theme_constant_override("margin_right", 20)
	footer_panel.add_child(footer_margin)
	
	var footer_label = Label.new()
	footer_label.text = "Posts refresh daily.\nInsider effects applied when you return to dashboard."
	footer_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	footer_label.add_theme_font_size_override("font_size", 12)
	footer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer_margin.add_child(footer_label)

func _load_posts() -> void:
	if not post_container:
		return
	
	# Clear existing posts (keep spacers and back btn)
	for child in post_container.get_children():
		if child.name.begins_with("Post") or child.name.begins_with("PostContainer"):
			child.queue_free()
	
	# Load tweets from JSON using PostJsonReader
	var json_reader = Node.new()
	json_reader.set_script(load("res://Scripts/post_json_reader.gd"))
	var tweets = json_reader.load_tweets_as_resources()
	json_reader.queue_free()
	
	# Get active stocks from market manager
	var active_stock_symbols = _get_active_stock_symbols()
	
	# First, find stocks that have tweets
	var stocks_with_tweets = []
	for symbol in active_stock_symbols:
		for tweet in tweets:
			var mentioned_symbol = _check_stock_mentions(tweet.content_text, tweet.original_text if tweet.is_repost else "")
			if mentioned_symbol == symbol:
				stocks_with_tweets.append(symbol)
				break
	
	# Check if we already have a locked stock for today
	if GameManager.insider_stock_day == GameManager.current_day and GameManager.locked_insider_stock != "":
		# Use the locked stock if it has tweets, otherwise pick one that has tweets
		if GameManager.locked_insider_stock in stocks_with_tweets:
			affected_stocks = [GameManager.locked_insider_stock]
		else:
			# Locked stock has no tweets, pick a new one from stocks with tweets
			stocks_with_tweets.shuffle()
			if stocks_with_tweets.size() > 0:
				GameManager.locked_insider_stock = stocks_with_tweets[0]
				GameManager.insider_stock_day = GameManager.current_day
				affected_stocks = [GameManager.locked_insider_stock]
	elif stocks_with_tweets.size() > 0:
		# Randomly select only 1 stock from user's holdings and lock it
		stocks_with_tweets.shuffle()
		GameManager.locked_insider_stock = stocks_with_tweets[0]
		GameManager.insider_stock_day = GameManager.current_day
		affected_stocks = [GameManager.locked_insider_stock]
	
	# Filter tweets to only show the selected 1 stock
	var filtered_tweets = []
	for tweet in tweets:
		var mentioned_symbol = _check_stock_mentions(tweet.content_text, tweet.original_text if tweet.is_repost else "")
		if mentioned_symbol != "" and mentioned_symbol in affected_stocks:
			filtered_tweets.append(tweet)
	
	# Shuffle and load posts
	filtered_tweets.shuffle()
	
	for i in range(filtered_tweets.size()):
		var tweet = filtered_tweets[i]
		_create_post_ui(tweet, i)
	
	# Show indicator for the selected stock
	if affected_stocks.size() > 0:
		_show_stock_indicator()

func _get_active_stock_symbols() -> Array:
	var symbols = []
	var market_manager = get_tree().root.get_node_or_null("Main/MarketManager")
	if market_manager and market_manager.has_method("get_active_stock_symbols"):
		symbols = market_manager.get_active_stock_symbols()
	return symbols

func _check_stock_mentions(content: String, original_content: String = "") -> String:
	# Check both content and original content (for reposts)
	var all_text = content + " " + original_content
	
	for mention in stock_mapping.keys():
		if mention in all_text:
			return stock_mapping[mention]
	return ""

func _create_post_ui(tweet: Resource, index: int) -> void:
	# Create a panel for the post
	var panel = PanelContainer.new()
	panel.name = "PostContainer_" + str(index)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.13, 0.13, 0.16)
	style.set_corner_radius_all(12)
	style.border_color = Color(0.2, 0.2, 0.25)
	style.set_border_width_all(1)
	panel.add_theme_stylebox_override("panel", style)
	panel.custom_minimum_size = Vector2(0, 180)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)
	
	# Header row with avatar and author
	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	vbox.add_child(header)
	
	# Avatar placeholder
	var avatar = TextureRect.new()
	avatar.custom_minimum_size = Vector2(45, 45)
	avatar.texture = load("res://icon.svg")
	avatar.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_SCALE
	header.add_child(avatar)
	
	# Author info
	var author_info = VBoxContainer.new()
	author_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(author_info)
	
	var author_name = Label.new()
	author_name.text = tweet.user_handle
	author_name.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0))
	author_name.add_theme_font_size_override("font_size", 15)
	author_name.add_theme_font_size_override("font_style", 1)
	author_info.add_child(author_name)
	
	var timestamp = Label.new()
	timestamp.text = tweet.timestamp
	timestamp.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	timestamp.add_theme_font_size_override("font_size", 12)
	author_info.add_child(timestamp)
	
	# Content
	var content_label = Label.new()
	content_label.text = tweet.content_text
	content_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	content_label.add_theme_font_size_override("font_size", 13)
	content_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_label.custom_minimum_size.y = 60
	vbox.add_child(content_label)
	
	# Stats row
	var stats = HBoxContainer.new()
	stats.add_theme_constant_override("separation", 20)
	vbox.add_child(stats)
	
	var likes = Label.new()
	likes.text = "❤️ " + tweet.likes
	likes.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	likes.add_theme_font_size_override("font_size", 11)
	stats.add_child(likes)
	
	var retweets = Label.new()
	retweets.text = "🔁 " + tweet.retweets
	retweets.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	retweets.add_theme_font_size_override("font_size", 11)
	stats.add_child(retweets)
	
	var comments = Label.new()
	comments.text = "💬 " + tweet.comments
	comments.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	comments.add_theme_font_size_override("font_size", 11)
	stats.add_child(comments)
	
	post_container.add_child(panel)

func _show_stock_indicator() -> void:
	# Create a label showing affected stocks
	var indicator = Label.new()
	indicator.name = "StockIndicator"
	indicator.text = "🔒 CLASSIFIED INTEL: " + ", ".join(affected_stocks) + " - ONE STOCK SELECTED"
	indicator.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0))
	indicator.add_theme_font_size_override("font_size", 14)
	indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	indicator.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	indicator.custom_minimum_size.y = 30
	
	post_container.add_child(indicator)
	
	# Move indicator to top (after spacer)
	post_container.move_child(indicator, 1)

func _apply_insider_effects() -> void:
	# Apply insider news effects to only the stock shown in the feed
	var market_manager = get_tree().root.get_node_or_null("Main/MarketManager")
	if not market_manager:
		return
	
	# Get the selected stock before clearing
	var selected_stock = ""
	if affected_stocks.size() > 0:
		selected_stock = affected_stocks[0]
	
	# Clear affected stocks now
	affected_stocks.clear()
	
	# Only apply to the 1 selected stock
	if selected_stock != "":
		var idx = market_manager.get_stock_index_by_symbol(selected_stock)
		if idx != -1:
			# Apply positive insider effect (random impact between 5-15%)
			var impact = randf_range(0.05, 0.15)
			market_manager.apply_insider_info(idx, impact)
			
			# Store for notification
			EventBus.emit_signal("news_released", "Social Media", 0.02, \
				"Insider intel gained on: " + selected_stock)

func _on_back_btn_pressed() -> void:
	# Apply insider effects before closing
	_apply_insider_effects()
	
	game_finished.emit(true, "")
	queue_free()
