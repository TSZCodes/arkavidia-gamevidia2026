extends Node2D

signal minigame_won

const words: Array[String] = [
	"Algorithm", "Variable", "Function", "Recursion", "Loop", "Boolean", "Integer", "Float", "String", "Array", "Pointer", "Reference", "Syntax", "Semantics", "Scope", "Class", "Object", "Inheritance", "Polymorphism", "Encapsulation", "Abstraction", "Interface", "Constructor", "Destructor", "Instance", "Method", "Attribute", "Stack", "Queue", "LinkedList", "BinaryTree", "Hashmap", "Graph", "Vector", "Tuple", "Dictionary", "Set", "Heap", "Matrix", "Compiler", "Interpreter", "Debugger", "Terminal", "Shell", "Git", "Repository", "Commit", "Branch", "Merge", "PullRequest", "Docker", "Container", "Linux", "Vim", "API", "JSON", "XML", "HTTP", "Server", "Client", "Database", "Frontend", "Backend", "Framework", "Library", "Endpoint", "Token", "Authentication", "Deploy", "Bug", "Refactor", "Deprecated", "Compile", "Runtime", "Latency", "Bandwidth", "Throughput", "Deadlock", "RaceCondition", "Overflow", "Segfault", "Callback", "Closure", "Promise"
]

@export var label_template: Label
@export var label_player: Label

var player_inputs: Array[String] = []
var current_word: String = ""
var words_completed: int = 0
var target_words: int = 5

func _ready() -> void:
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.08, 0.95)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.z_index = -1
	add_child(bg)
	var skip_btn = Button.new()
	skip_btn.text = "SKIP >>"
	skip_btn.position = Vector2(100, 20)
	skip_btn.size = Vector2(100, 40)
	skip_btn.pressed.connect(_on_skip_pressed)
	add_child(skip_btn)
	change_word()

func _process(_delta: float) -> void:
	label_player.text = "".join(player_inputs)
	if label_player.text == current_word:
		await get_tree().create_timer(0.2).timeout
		_word_finished()

func _word_finished() -> void:
	words_completed += 1
	if words_completed >= target_words:
		_win_game()
	else:
		label_player.text = ""
		player_inputs.clear()
		change_word()

func _win_game() -> void:
	emit_signal("minigame_won")
	queue_free()

func _on_skip_pressed() -> void:
	_win_game()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var keycode = event.keycode
		if event.unicode > 0:
			var char = char(event.unicode)
			if is_valid_letter(char):
				player_inputs.append(char)
		elif keycode == KEY_BACKSPACE:
			if player_inputs.size() > 0:
				player_inputs.remove_at(player_inputs.size() - 1)
		elif keycode == KEY_ESCAPE:
			queue_free()

func is_valid_letter(char: String) -> bool:
	return char.length() == 1 and char.to_lower() != char.to_upper()

func change_word() -> void:
	current_word = words[randi() % words.size()]
	label_template.text = current_word
