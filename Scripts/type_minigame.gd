extends Control

signal minigame_won

const words: Array[String] = [
	"Algorithm", "Variable", "Function", "Recursion", "Loop", "Boolean", "Integer", "Float", "String", "Array", "Pointer", "Reference", "Syntax", "Semantics", "Scope", "Class", "Object", "Inheritance", "Polymorphism", "Encapsulation", "Abstraction", "Interface", "Constructor", "Destructor", "Instance", "Method", "Attribute", "Stack", "Queue", "LinkedList", "BinaryTree", "Hashmap", "Graph", "Vector", "Tuple", "Dictionary", "Set", "Heap", "Matrix", "Compiler", "Interpreter", "Debugger", "Terminal", "Shell", "Git", "Repository", "Commit", "Branch", "Merge", "PullRequest", "Docker", "Container", "Linux", "Vim", "API", "JSON", "XML", "HTTP", "Server", "Client", "Database", "Frontend", "Backend", "Framework", "Library", "Endpoint", "Token", "Authentication", "Deploy", "Bug", "Refactor", "Deprecated", "Compile", "Runtime", "Latency", "Bandwidth", "Throughput", "Deadlock", "RaceCondition", "Overflow", "Segfault", "Callback", "Closure", "Promise"
]

@export var word_display: RichTextLabel

var player_inputs: Array[String] = []
var current_word: String = ""
var words_completed: int = 0
var target_words: int = 5

func _ready() -> void:
	change_word()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var keycode = event.keycode
		if event.unicode > 0:
			var char_str = char(event.unicode)
			# Only accept letters, and prevent over-typing length of current word
			if is_valid_letter(char_str):
				if player_inputs.size() < current_word.length():
					# Check if the typed character matches the target character
					var next_char_index = player_inputs.size()
					if char_str == current_word[next_char_index]:
						player_inputs.append(char_str)
						update_display()
						check_word_finished()
					else:
						# Optional: Flash red or shake if wrong? For now just ignore or reset
						pass 
						
		elif keycode == KEY_BACKSPACE:
			if player_inputs.size() > 0:
				player_inputs.remove_at(player_inputs.size() - 1)
				update_display()
				
		elif keycode == KEY_ESCAPE:
			_on_exit_pressed()

func is_valid_letter(chara: String) -> bool:
	return chara.length() == 1 and chara.to_lower() != chara.to_upper()

func update_display() -> void:
	if not word_display: return
	
	var typed_str = "".join(player_inputs)
	var untyped_str = current_word.substr(typed_str.length())
	
	# BBCode: Green for typed, Gray for untyped
	var bbcode = "[center][color=#44ff44]%s[/color][color=#666677]%s[/color][/center]" % [typed_str, untyped_str]
	word_display.text = bbcode

func check_word_finished() -> void:
	var typed_str = "".join(player_inputs)
	if typed_str == current_word:
		# Small delay for visual satisfaction
		set_process_input(false)
		await get_tree().create_timer(0.15).timeout
		
		words_completed += 1
		player_inputs.clear()
		
		if words_completed >= target_words:
			_win_game()
		else:
			change_word()
			set_process_input(true)

func change_word() -> void:
	current_word = words[randi() % words.size()]
	update_display()

func _win_game() -> void:
	emit_signal("minigame_won")
	queue_free()

func _on_skip_pressed() -> void:
	_win_game()

func _on_exit_pressed() -> void:
	queue_free()
