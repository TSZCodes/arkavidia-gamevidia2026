extends Node2D

const words : Array[String] = [
  "Algorithm", "Variable", "Function", "Recursion", "Loop", "Boolean", "Integer", "Float", "String", "Array", "Pointer", "Reference", "Syntax", "Semantics", "Scope", "Class", "Object", "Inheritance", "Polymorphism", "Encapsulation", "Abstraction", "Interface", "Constructor", "Destructor", "Instance", "Method", "Attribute", "Stack", "Queue", "LinkedList", "BinaryTree", "Hashmap", "Graph", "Vector", "Tuple", "Dictionary", "Set", "Heap", "Matrix", "Compiler", "Interpreter", "Debugger", "Terminal", "Shell", "Git", "Repository", "Commit", "Branch", "Merge", "PullRequest", "Docker", "Container", "Linux", "Vim", "API", "JSON", "XML", "HTTP", "Server", "Client", "Database", "Frontend", "Backend", "Framework", "Library", "Endpoint", "Token", "Authentication", "Deploy", "Bug", "Refactor", "Deprecated", "Compile", "Runtime", "Latency", "Bandwidth", "Throughput", "Deadlock", "RaceCondition", "Overflow", "Segfault", "Callback", "Closure", "Promise"
]

@export var label_template : Label
@export var label_player : Label

var player_inputs : Array[String] = []

var on_done := false

func _ready() -> void:
	on_done = true
	label_template.text = change_word()
	on_done = false

func _process(_delta: float) -> void:
	label_player.text = "".join(player_inputs)
	if label_player.text == label_template.text :
		on_done = true
		label_player.text = ""
		label_template.text = change_word()
		player_inputs.clear()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			var label = DisplayServer.keyboard_get_label_from_physical(event.physical_keycode)
			var chara = OS.get_keycode_string(label)
			if event.unicode != 0:
				if is_valid_letter(chara):
					player_inputs.append(chara if event.shift_pressed else chara.to_lower())
			if event.keycode == KEY_DELETE or event.keycode == KEY_BACKSPACE:
				player_inputs.remove_at(-1)
			
func is_valid_letter(chara : String) -> bool:
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z]$")
	return regex.search(chara) != null

func change_word() -> String:
	if on_done :
		var word = words[randi_range(0, words.size() - 1)]
		return word
	else :
		return "null"
