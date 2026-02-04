extends Node

# Signals
@warning_ignore_start("unused_signal")
signal money_changed(new_amount)
signal day_changed(new_day)
signal debt_changed(new_debt)
signal quota_updated(amount, days_left)
signal game_over(reason)
signal notif_message(text)

# --- ECONOMY SETTINGS ---
var player_money: float = 1000.0  # Starting amount: 1000
var current_day: int = 1

# THE PARENTS DEBT (Main Goal)
var debt_amount: float = 100000.0 # Total: 100,000
var daily_interest_rate: float = 0.05 
var interest_cycle_days: int = 10     # Interest every 10 days

# THE PINJOL (Instant Loan Option)
var pinjol_loan_amount: float = 500000.0 # Amount you can borrow
var pinjol_interest_multiplier: float = 1.2 # Must pay back 120%

# Player Inventory
var portfolio: Dictionary = {}

func _ready() -> void:
	emit_signal("money_changed", player_money)
	emit_signal("day_changed", current_day)
	emit_signal("debt_changed", debt_amount)

func add_money(amount: float) -> void:
	player_money += amount
	emit_signal("money_changed", player_money)

func spend_money(amount: float) -> bool:
	if player_money >= amount:
		player_money -= amount
		emit_signal("money_changed", player_money)
		return true
	return false

# Function to take an instant loan (Pinjol)
func take_emergency_loan() -> void:
	add_money(pinjol_loan_amount) 
	debt_amount += (pinjol_loan_amount * pinjol_interest_multiplier)
	emit_signal("debt_changed", debt_amount)
	emit_signal("notif_message", "Emergency Loan Taken: +500k Cash")

func pay_debt(amount: float) -> void:
	if spend_money(amount):
		debt_amount -= amount
		if debt_amount < 0: debt_amount = 0
		emit_signal("debt_changed", debt_amount)

func next_day() -> void:
	current_day += 1
	emit_signal("day_changed", current_day)
	

	if current_day % interest_cycle_days == 0:
		var interest = debt_amount * daily_interest_rate
		debt_amount += interest
		emit_signal("debt_changed", debt_amount)
		emit_signal("notif_message", "10-Day Cycle: 5% Interest Added to Debt")
