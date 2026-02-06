extends Control

signal repay_confirmed(amount)

# UI Nodes
@onready var info_label = $VBoxContainer/InfoPanel/Margin/InfoLabel
@onready var amount_display = $VBoxContainer/InputContainer/AmountInput
@onready var slider = $VBoxContainer/SliderContainer/AmountSlider
# Ensure this path points to your actual NotificationPopup in the Main scene
@onready var notif_popup = $"../NotificationPopup" 

# Local variables
var current_wallet: float = 0.0  # We use current_wallet, NOT current_money
var current_debt: float = 0.0
var pay_amount: float = 0.0

func _ready():
	visible = false
	slider.value_changed.connect(_on_slider_value_changed)
	amount_display.text_changed.connect(_on_amount_text_changed)

# --- CALL THIS FUNCTION TO OPEN THE POPUP ---
func open(wallet_val: float, debt_val: float):
	current_wallet = wallet_val
	current_debt = debt_val
	
	# Update the UI Labels
	update_labels()
	
	# Setup Slider limits
	var max_payment = min(current_wallet, current_debt)
	
	slider.min_value = 0
	slider.max_value = max_payment
	slider.value = 0
	slider.step = 100.0
	
	# Reset display
	pay_amount = 0.0
	update_amount_display()
	
	visible = true

func update_labels():
	# Display the stored wallet and debt values
	info_label.text = "Debt: $%.2f\nWallet: $%.2f" % [current_debt, current_wallet]

func update_amount_display():
	amount_display.text = "%.2f" % pay_amount

func _on_slider_value_changed(value):
	pay_amount = value
	update_amount_display()

func _on_amount_text_changed(new_text: String):
	if new_text.is_empty():
		pay_amount = 0.0
		return
	
	var entered_amount = new_text.to_float() if new_text.is_valid_float() else 0.0
	if entered_amount > current_wallet:
		# Cap at current_wallet
		entered_amount = current_wallet
		amount_display.text = "%.2f" % current_wallet
	
	pay_amount = entered_amount
	
	# Update slider to match input
	if slider.value != entered_amount:
		slider.set_value_no_signal(entered_amount)

func _on_cancel_pressed():
	visible = false

func _on_pay_now_pressed():
	if pay_amount <= 0:
		return
		
	# FIXED: Used 'current_wallet' instead of 'current_money'
	if pay_amount > current_wallet:
		if notif_popup:
			notif_popup.show_notification("Insufficient funds!")
		return

	# Emit signal to Main Game to handle the deduction
	emit_signal("repay_confirmed", pay_amount)
	
	# Trigger Notification
	if notif_popup:
		notif_popup.show_notification("Repaid $%.2f of debt!" % pay_amount)
	
	visible = false