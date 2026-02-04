extends PopupPanel

@onready var info_label = $VBoxContainer/InfoPanel/Margin/InfoLabel
@onready var slider = $VBoxContainer/SliderContainer/AmountSlider
@onready var input = $VBoxContainer/InputContainer/AmountInput
@onready var btn_confirm = $VBoxContainer/ActionButtons/ConfirmBtn
@onready var btn_cancel = $VBoxContainer/ActionButtons/CancelBtn

var max_payable: float = 0.0

func _ready() -> void:
	if not btn_cancel or not btn_confirm:
		push_error("PayDebtPopup: Buttons not found!")
		return
	btn_cancel.pressed.connect(func(): queue_free())
	btn_confirm.pressed.connect(_on_pay_pressed)
	if slider: slider.value_changed.connect(_on_slider_changed)
	if input: input.text_changed.connect(_on_text_changed)
	_setup_ui()

func _setup_ui() -> void:
	var debt = GameManager.debt_amount
	var cash = GameManager.player_money
	max_payable = min(debt, cash)
	if info_label:
		info_label.text = "Outstanding Debt: $%s\nAvailable Cash: $%s" % [str(snapped(debt, 0.01)), str(snapped(cash, 0.01))]
	if slider:
		slider.min_value = 0
		slider.max_value = max_payable
		slider.step = 1.0
		slider.value = 0
	if input:
		input.text = "0"
	if max_payable <= 0:
		btn_confirm.disabled = true
		btn_confirm.text = "NO FUNDS"
		if input: input.editable = false
		if slider: slider.editable = false

func _on_slider_changed(value: float) -> void:
	if input: input.text = str(value)

func _on_text_changed(text: String) -> void:
	if text.is_valid_float():
		var val = float(text)
		if val > max_payable:
			val = max_payable
			input.text = str(val)
			input.caret_column = text.length()
		if slider: slider.set_value_no_signal(val)

func _on_pay_pressed() -> void:
	if not input: return
	var amount = float(input.text)
	if amount > 0:
		GameManager.pay_debt(amount)
		queue_free()
