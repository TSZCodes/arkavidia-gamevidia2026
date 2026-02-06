extends Node2D

# Signal to tell the dashboard the result (True = Win/Trend Boost, False = Fail)
# Added target_symbol to identify which stock gets the effect
signal game_finished(success: bool, target_symbol: String)

@export var scenario_type : int
@export var scroll_container : ScrollContainer
@export var message_list : VBoxContainer
@export var chat_bubble : PackedScene
@export var option1 : Button
@export var option2 : Button
@export var option3 : Button
@export var user_received : StyleBoxFlat
@export var user_sent : StyleBoxFlat
@export var user_blocked : StyleBoxFlat
@export var chat_texts : Resource # Changed type to Resource to avoid cyclic dependency if class_name isn't global

var option_buttons : Array[Button] 
var correct_button : Array[Button]
var wrong_button : Array[Button]
var option_now : int
var current_target_symbol : String = ""

func _ready() -> void:
	option_buttons = [option1, option2, option3]
	reset()
	# Ensure chat_texts is loaded. If it's null in Inspector, load it here
	if not chat_texts:
		chat_texts = preload("res://Resource/chat_options.tres")
		
	scenario_type = randi_range(0,1)
	
	# Assign target stock based on scenario
	if scenario_type == 0:
		current_target_symbol = "RKSN" # Rocksun (GTA 6 / Robinson)
	elif scenario_type == 1:
		current_target_symbol = "NASI" # NASI (Aliens)
	
	option_now = 1
	if option_now == 1:
		load_option1(scenario_type)
	
	# "ABORT / EXIT" button code removed here.

func reset() -> void:
	option1.text = ""
	option2.text = ""
	option3.text = ""
	if message_list:
		for msg in message_list.get_children():
			msg.queue_free()
	option1.disabled = false
	option2.disabled = false
	option3.disabled = false

func add_msg(text: String, is_user: bool) -> void:
	if not chat_bubble: return
	var bubble = chat_bubble.instantiate()
	message_list.add_child(bubble)

	var label = bubble.get_node("PanelContainer/Label")
	label.text = text

	if is_user:
		bubble.size_flags_horizontal = Control.SIZE_SHRINK_END
		bubble.get_node("PanelContainer").add_theme_stylebox_override("panel", user_sent)
	else :
		bubble.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		bubble.get_node("PanelContainer").add_theme_stylebox_override("panel", user_received)
	
	await get_tree().process_frame
	if scroll_container:
		scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)

func load_option1(scenario: int) :
	if option_now == 1 :
		if scenario == 0:
			add_msg(chat_texts.responses_scenario_1[10], true)
			add_msg(chat_texts.responses_scenario_1[0], false)
			var keys = chat_texts.options1_scenario_1.keys()
			keys.shuffle()
			for key in keys:
				var current_button = option_buttons[key]
				var rand_key = keys[key]
				current_button.text = chat_texts.options1_scenario_1[rand_key]
				if rand_key == 0:
					correct_button.append(current_button)
				else :
					wrong_button.append(current_button)
		elif scenario == 1:
			add_msg(chat_texts.responses_scenario_2[0], false)
			var keys = chat_texts.options1_scenario_2.keys()
			keys.shuffle()
			for key in keys:
				var current_button = option_buttons[key]
				var rand_key = keys[key]
				current_button.text = chat_texts.options1_scenario_2[rand_key]
				if rand_key == 0:
					correct_button.append(current_button)
				else :
					wrong_button.append(current_button)
	await get_tree().process_frame
	scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)

func load_option2(scenario : int) -> void:
	if option_now == 2 :
		if scenario == 0:
			add_msg(chat_texts.responses_scenario_1[1], false)
			var keys = chat_texts.options1_scenario_1.keys()
			keys.shuffle()
			for key in keys:
				var current_button = option_buttons[key]
				var rand_key = keys[key]
				current_button.text = chat_texts.options2_scenario_1[rand_key]
				if rand_key == 0:
					correct_button.append(current_button)
				else :
					wrong_button.append(current_button)
		elif scenario == 1:
			add_msg(chat_texts.responses_scenario_2[1], false)
			var keys = chat_texts.options1_scenario_2.keys()
			keys.shuffle()
			for key in keys:
				var current_button = option_buttons[key]
				var rand_key = keys[key]
				current_button.text = chat_texts.options2_scenario_2[rand_key]
				if rand_key == 0:
					correct_button.append(current_button)
				else :
					wrong_button.append(current_button)
				
	await get_tree().process_frame
	scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)

func load_option3(scenario : int) -> void:
	if option_now == 3 :
		if scenario == 0:
			add_msg(chat_texts.responses_scenario_1[2], false)
			var keys = chat_texts.options1_scenario_1.keys()
			keys.shuffle()
			for key in keys:
				var current_button = option_buttons[key]
				var rand_key = keys[key]
				current_button.text = chat_texts.options3_scenario_1[rand_key]
				if rand_key == 0:
					correct_button.append(current_button)
				else :
					wrong_button.append(current_button)
		elif scenario == 1:
			add_msg(chat_texts.responses_scenario_2[2], false)
			var keys = chat_texts.options1_scenario_2.keys()
			keys.shuffle()
			for key in keys:
				var current_button = option_buttons[key]
				var rand_key = keys[key]
				current_button.text = chat_texts.options3_scenario_2[rand_key]
				if rand_key == 0:
					correct_button.append(current_button)
				else :
					wrong_button.append(current_button)
				
	await get_tree().process_frame
	scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)


func load_option4(scenario : int) -> void:
	if option_now == 4 :
		# Success scenarios!
		if scenario == 0:
			add_msg(chat_texts.responses_scenario_1[3], false)
			add_msg(chat_texts.responses_scenario_1[11], true)
			add_msg(chat_texts.responses_scenario_1[4], false)
			# Option 4 is the final choice
			var keys = chat_texts.options4_scenario_1.keys()
			keys.shuffle()
			for key in keys:
				var current_button = option_buttons[key]
				var rand_key = keys[key]
				current_button.text = chat_texts.options4_scenario_1[rand_key]
				if rand_key == 0:
					correct_button.append(current_button)
				else :
					wrong_button.append(current_button)
		elif scenario == 1:
			add_msg(chat_texts.responses_scenario_2[3], false)
			add_msg(chat_texts.responses_scenario_2[10], true)
			add_msg(chat_texts.responses_scenario_2[4], false)
			var keys = chat_texts.options1_scenario_2.keys()
			keys.shuffle()
			for key in keys:
				var current_button = option_buttons[key]
				var rand_key = keys[key]
				current_button.text = chat_texts.options4_scenario_2[rand_key]
				if rand_key == 0:
					correct_button.append(current_button)
				else :
					wrong_button.append(current_button)
	
	await get_tree().process_frame
	scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)

	# Instead of clearing text immediately, we wait for the user to pick the final option
	# The WIN condition happens in _on_option_X_pressed when option_now reaches 5

func blocked_message() -> void:
	var bubble = chat_bubble.instantiate()
	message_list.add_child(bubble)

	var label = bubble.get_node("PanelContainer/Label")
	label.text = "You have been blocked by this user"
	label.add_theme_color_override("font_color", Color(0,0,0))

	bubble.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	bubble.get_node("PanelContainer").add_theme_stylebox_override("panel", user_blocked)
	
	await get_tree().process_frame
	scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)
	
	_disable_buttons()
	# Emit LOSS signal after delay
	await get_tree().create_timer(1.5).timeout
	game_finished.emit(false, current_target_symbol)
	queue_free()

func _disable_buttons() -> void:
	option1.text = ""
	option2.text = ""
	option3.text = ""
	option1.disabled = true
	option2.disabled = true
	option3.disabled = true

func _check_answer(btn: Button) -> void:
	if correct_button.is_empty(): return
	
	if btn == correct_button[0]:
		option_now += 1
		correct_button.clear()
		wrong_button.clear()
		
		if option_now == 2: load_option2(scenario_type)
		elif option_now == 3: load_option3(scenario_type)
		elif option_now == 4: load_option4(scenario_type)
		elif option_now == 5:
			# PLAYER WON!
			_disable_buttons()
			await get_tree().create_timer(1.0).timeout
			game_finished.emit(true, current_target_symbol)
			queue_free()
	else:
		# Player Lost
		blocked_message()

func _on_option_1_pressed() -> void:
	add_msg(option1.text, true)
	_check_answer(option1)

func _on_option_2_pressed() -> void:
	add_msg(option2.text, true)
	_check_answer(option2)

func _on_option_3_pressed() -> void:
	add_msg(option3.text, true)
	_check_answer(option3)