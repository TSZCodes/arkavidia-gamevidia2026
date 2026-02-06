extends Control

# Type Minigame - Typing Accuracy Minigame (MonkeyType Style)
# Player must type technical terms correctly to gain insider information

signal minigame_won(target_stock: String, is_positive: bool)

# Programming terms for typing practice (MonkeyType style)
const words: Array[String] = [
	"Algorithm", "Variable", "Function", "Recursion", "Loop", "Boolean", "Integer", "Float", "String", "Array", "Pointer", "Reference", "Syntax", "Semantics", "Scope", "Class", "Object", "Inheritance", "Polymorphism", "Encapsulation", "Abstraction", "Interface", "Constructor", "Destructor", "Instance", "Method", "Attribute", "Stack", "Queue", "LinkedList", "BinaryTree", "Hashmap", "Graph", "Vector", "Tuple", "Dictionary", "Set", "Heap", "Matrix", "Compiler", "Interpreter", "Debugger", "Terminal", "Shell", "Git", "Repository", "Commit", "Branch", "Merge", "PullRequest", "Docker", "Container", "Linux", "Vim", "API", "JSON", "XML", "HTTP", "Server", "Client", "Database", "Frontend", "Backend", "Framework", "Library", "Endpoint", "Token", "Authentication", "Deploy", "Bug", "Refactor", "Deprecated", "Compile", "Runtime", "Latency", "Bandwidth", "Throughput", "Deadlock", "RaceCondition", "Overflow", "Segfault", "Callback", "Closure", "Promise"
]

# Insider news snippets - displayed as reward after completing typing
const insider_news: Array[Dictionary] = [
	# POSITIVE NEWS
	{"text": "ABIOPARMA SERUM MANUSIA ABADI", "stock": "ABIO", "is_positive": true},
	{"text": "NASI JAMUAN ASING ELANG JAWA", "stock": "NASI", "is_positive": true},
	{"text": "TESLA TOWER LISTRIK UTAMA", "stock": "PSK", "is_positive": true},
	{"text": "BIG BATTERY ARC REACTOR", "stock": "BBC", "is_positive": true},
	{"text": "DRAF UNDANG PERAMPASAN ASET BCA", "stock": "BCA", "is_positive": true},
	{"text": "AMATEUR BIOTECH POHON UANG", "stock": "ABC", "is_positive": true},
	{"text": "BATU BARU KOMEN HADIAH", "stock": "BBHP", "is_positive": true},
	{"text": "INDIGO KUADRALIUM INTERNET", "stock": "IND", "is_positive": true},
	{"text": "BETAvERSE PASANGAN LAJANG", "stock": "META", "is_positive": true},
	{"text": "KAPAL NEPTUNUS PRASEJARAHA", "stock": "KLN", "is_positive": true},
	{"text": "SANG SURYA PERTIWI ENERGI", "stock": "SSP", "is_positive": true},
	{"text": "PT PANASEA BIOTEK", "stock": "PANA", "is_positive": true},
	# NEGATIVE NEWS
	{"text": "BATU BARU ANAK PENAMBANG", "stock": "BBHP", "is_positive": false},
	{"text": "SUMSANG XIAOMAY XIAOMI", "stock": "SSNG", "is_positive": false},
	{"text": "WWG DANA JALAN RAPAT", "stock": "WWG", "is_positive": false},
	{"text": "JENDERAL KOMISARI PERTAMINI", "stock": "PRTM", "is_positive": false},
	{"text": "BCA KORUPSI AYAM JAGO", "stock": "BCA", "is_positive": false},
	{"text": "INDOAPRIl BOLOSMART DONASI", "stock": "IDAP", "is_positive": false},
	{"text": "SAWIT MAKMUR MINYAK SWASTA", "stock": "SMH", "is_positive": false},
	{"text": "ELANG JAWA LITTLE ST JAMES", "stock": "ELJA", "is_positive": false},
	{"text": "PINJOL KAYA SLOTS KAKEK", "stock": "PBKI", "is_positive": false},
	{"text": "UNIPELER PAYUNG NAPAS PREMIUM", "stock": "ULVR", "is_positive": false},
	{"text": "PAYUNG CORP NAPAS PREMIUM", "stock": "UMB", "is_positive": false}
]

@export var word_display: RichTextLabel

var player_inputs: Array[String] = []
var current_word: String = ""
var words_completed: int = 0
var target_words: int = 5
var current_target_stock: String = ""
var current_is_positive: bool = true

func _ready() -> void:
	change_word()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var keycode = event.keycode
		if event.unicode > 0:
			var char_str = char(event.unicode)
			if is_valid_letter(char_str):
				if player_inputs.size() < current_word.length():
					var next_char_index = player_inputs.size()
					var target_char = current_word[next_char_index]
					if char_str == String(target_char):
						player_inputs.append(char_str)
						update_display()
						check_word_finished()
					else:
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
	if not word_display:
		return
	
	var typed_str = "".join(player_inputs)
	var untyped_str = current_word.substr(typed_str.length())
	
	var bbcode = "[center][color=#44ff44]%s[/color][color=#666677]%s[/color][/center]" % [typed_str, untyped_str]
	word_display.text = bbcode

func check_word_finished() -> void:
	var typed_str = "".join(player_inputs)
	if typed_str == current_word:
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
	# Select ONE random insider news as the reward
	var news = insider_news[randi() % insider_news.size()]
	current_target_stock = news["stock"]
	current_is_positive = news["is_positive"]
	
	emit_signal("minigame_won", current_target_stock, current_is_positive)
	queue_free()

func _on_skip_pressed() -> void:
	_win_game()

func _on_exit_pressed() -> void:
	queue_free()
