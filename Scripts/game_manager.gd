extends Node

signal money_changed(new_amount)
signal debt_changed(new_amount)
signal day_changed(new_day)
signal notif_message(msg)
signal minigame_opportunity(type)

var player_money: float = 1000.0
var debt_amount: float = 100000.0
var current_day: int = 1
var history_log: Array = []

# Loan restriction
var loan_taken_today: bool = false

# Portfolio: { "StockName": quantity }
var portfolio: Dictionary = {}

# Futures: { "StockName": { "entry_price": float, "leverage": float, "is_long": bool, "margin": float } }
var futures_positions: Dictionary = {}

# Minigame state
var active_minigame: String = "" # "", "type", "social"

func _ready() -> void:
	randomize()
	_trigger_daily_minigame()

func add_money(amount: float) -> void:
	player_money += amount
	money_changed.emit(player_money)

func spend_money(amount: float) -> bool:
	if player_money >= amount:
		player_money -= amount
		money_changed.emit(player_money)
		return true
	return false

func take_emergency_loan() -> void:
	if loan_taken_today:
		notif_message.emit("❌ LOAN REJECTED: You can only take 1 loan per day!")
		return
		
	var loan_val = 5000.0
	player_money += loan_val
	debt_amount += loan_val * 1.1 # 10% instant interest
	loan_taken_today = true
	
	money_changed.emit(player_money)
	debt_changed.emit(debt_amount)
	notif_message.emit("⚠️ Emergency Loan taken!\n+$5,000 (Debt +10%)")

func pay_debt(amount: float) -> void:
	if amount <= 0: return
	if player_money >= amount:
		player_money -= amount
		debt_amount = max(0, debt_amount - amount)
		money_changed.emit(player_money)
		debt_changed.emit(debt_amount)
		notif_message.emit("💸 Repaid $%s of debt." % str(amount))

func next_day() -> void:
	current_day += 1
	# Reset daily limits
	loan_taken_today = false
	
	day_changed.emit(current_day)
	debt_changed.emit(debt_amount)
	
	_trigger_daily_minigame()

func log_history(equity: float) -> void:
	history_log.append({
		"day": current_day,
		"net_worth": equity
	})

func _trigger_daily_minigame() -> void:
	# Rotating pattern: type -> social -> social_feed -> repeat
	# This guarantees all 3 types appear equally over time with no streaks
	var game_types = ["type", "social", "social_feed"]
	var day_index = (current_day - 1) % game_types.size()
	active_minigame = game_types[day_index]
	minigame_opportunity.emit(active_minigame)
