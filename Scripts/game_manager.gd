extends Node

# Game Manager - Core Game State & Economy
# Manages player money, debt, portfolio, and game progression

signal money_changed(new_amount)
signal day_changed(new_day)
signal debt_changed(new_debt)
signal notif_message(text)
signal minigame_opportunity(type: String) # Added for daily minigame notifications

var player_money: float = 1000.0
var current_day: int = 1

var debt_amount: float = 100000.0
var daily_interest_rate: float = 0.05
var interest_cycle_days: int = 10

var pinjol_loan_amount: float = 10000.0
var pinjol_interest_multiplier: float = 1.2

var portfolio: Dictionary = {}
var futures_positions: Dictionary = {}

var history_log: Array = []

# Tracks which minigame is valid today
var active_minigame: String = "" 

func _ready() -> void:
	emit_signal("money_changed", player_money)
	emit_signal("day_changed", current_day)
	emit_signal("debt_changed", debt_amount)
	log_history(1000.0)
	
	# Initial delay for first notification
	await get_tree().create_timer(1.5).timeout
	_determine_daily_event()

func add_money(amount: float) -> void:
	player_money += amount
	emit_signal("money_changed", player_money)

func spend_money(amount: float) -> bool:
	if player_money >= amount:
		player_money -= amount
		emit_signal("money_changed", player_money)
		return true
	return false

func take_emergency_loan() -> void:
	add_money(pinjol_loan_amount)
	debt_amount += (pinjol_loan_amount * pinjol_interest_multiplier)
	emit_signal("debt_changed", debt_amount)
	emit_signal("notif_message", "Emergency Loan Taken: +$10k")

func pay_debt(amount: float) -> void:
	if debt_amount <= 0:
		emit_signal("notif_message", "You are debt free!")
		return
	var payment = min(amount, debt_amount)
	if spend_money(payment):
		debt_amount -= payment
		emit_signal("debt_changed", debt_amount)
		emit_signal("notif_message", "Paid Debt: -$" + str(snapped(payment, 0.01)))
	else:
		emit_signal("notif_message", "Not enough cash to pay debt!")

func next_day() -> void:
	current_day += 1
	active_minigame = "" # Reset daily event
	emit_signal("day_changed", current_day)
	
	if current_day % interest_cycle_days == 0:
		var interest = debt_amount * daily_interest_rate
		debt_amount += interest
		emit_signal("debt_changed", debt_amount)
		emit_signal("notif_message", "10-Day Cycle: 5% Interest Added to Debt")
	
	# Delay 2 seconds after sleeping before showing the new opportunity
	await get_tree().create_timer(2.0).timeout
	_determine_daily_event()

func _determine_daily_event() -> void:
	var roll = randf()
	if roll > 0.5:
		active_minigame = "type"
		minigame_opportunity.emit("type")
	else:
		active_minigame = "social"
		minigame_opportunity.emit("social")

func log_history(net_worth: float) -> void:
	var entry = {
		"day": current_day,
		"net_worth": net_worth,
		"debt": debt_amount
	}
	history_log.append(entry)