extends Node2D

const words: Array[String] = [
	"Algorithm", "Variable", "Function", "Recursion", "Loop", "Boolean", "Integer", "Float", "String", "Array", "Pointer", "Reference", "Syntax", "Semantics", "Scope", "Class", "Object", "Inheritance", "Polymorphism", "Encapsulation", "Abstraction", "Interface", "Constructor", "Destructor", "Instance", "Method", "Attribute", "Stack", "Queue", "LinkedList", "BinaryTree", "Hashmap", "Graph", "Vector", "Tuple", "Dictionary", "Set", "Heap", "Matrix", "Compiler", "Interpreter", "Debugger", "Terminal", "Shell", "Git", "Repository", "Commit", "Branch", "Merge", "PullRequest", "Docker", "Container", "Linux", "Vim", "API", "JSON", "XML", "HTTP", "Server", "Client", "Database", "Frontend", "Backend", "Framework", "Library", "Endpoint", "Token", "Authentication", "Deploy", "Bug", "Refactor", "Deprecated", "Compile", "Runtime", "Latency", "Bandwidth", "Throughput", "Deadlock", "RaceCondition", "Overflow", "Segfault", "Callback", "Closure", "Promise"
]

@export var label_template: Label
@export var label_player: Label

var player_inputs: Array[String] = []
var current_word: String = ""
var on_done: bool = false
var template_word : String

func _ready() -> void:
	on_done = true
	template_word = label_template.text
	on_done = false

func _process(_delta: float) -> void:
	label_player.text = "".join(player_inputs)
	
	# Check if typing is complete
	var max_length = max(template_word.length(), label_player.text.length())
	if label_player.text.length() > 0:
		for i in range(max_length):
			var char1 = label_player.text[i] if i < label_player.text.length() else ""
			var char2 = template_word[i] if i < template_word.length() else ""
			if char1 != char2:
				print("Wrong chara at %d!" % [i])
		
	if label_player.text == current_word:
		on_done = true
		await get_tree().create_timer(0.5).timeout
		label_player.text = ""
		change_word()
		template_word = label_template.text
		player_inputs.clear()
		on_done = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var keycode = event.keycode
		
		# Handle letter input
		if event.unicode > 0:
			var chara = char(event.unicode)
			if is_valid_letter(chara):
				player_inputs.append(chara)
		
		# Handle backspace
		elif keycode == KEY_BACKSPACE:
			if player_inputs.size() > 0:
				player_inputs.remove_at(-1)
		
		# Handle escape to exit
		elif keycode == KEY_ESCAPE:
			queue_free()

func is_valid_letter(chara: String) -> bool:
	return chara.length() == 1 and chara.to_lower() != chara.to_upper()

func change_word() -> void:
	if not on_done:
		return
	current_word = words[randi() % words.size()]
	label_template.text = current_word
