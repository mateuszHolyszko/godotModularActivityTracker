# ValueInput.gd
class_name ValueInput
extends Button

signal value_changed(value)
signal value_confirmed(value)
signal edit_started
signal edit_canceled

@export var value: float = 0
@export var step: float = 1
@export var min_value: float = 0
@export var max_value: float = INF

var editing := false
var original_value := 0.0

func _ready():
	update_text()

func _gui_input(event):
	if disabled:
		return
	if not event is InputEventKey or not event.pressed:
		return
	match event.keycode:
		KEY_ENTER:
			if editing: confirm_value()
			else: start_edit()
			accept_event()
		KEY_ESCAPE:
			if editing: cancel_edit()
			accept_event()
		KEY_PERIOD:
			if editing: change_value(1)
			accept_event()
		KEY_COMMA:
			if editing: change_value(-1)
			accept_event()

func start_edit():
	if disabled:
		return
	editing = true
	original_value = value
	modulate = Color(1, 1, 0.6)
	update_text()
	edit_started.emit()

func confirm_value():
	editing = false
	modulate = Color.WHITE
	update_text()
	value_confirmed.emit(value)

func cancel_edit():
	value = original_value
	editing = false
	modulate = Color.WHITE
	update_text()
	edit_canceled.emit()

func change_value(direction: int):
	value = clamp(value + step * direction, min_value, max_value)
	# Round to 2 decimal places when changed
	value = round(value * 100) / 100.0
	update_text()
	value_changed.emit(value)

func update_text():
	if editing:
		# Show with 2 decimal places when editing
		text = "> %.2f <" % value
	else:
		# Show with 2 decimal places normally
		text = "%.2f" % value

# Optional: Add a method to set value with rounding
func set_value(new_value: float):
	value = round(new_value * 100) / 100.0
	update_text()

# Optional: Override the setter for the value property
func set_value_and_round(new_value: float):
	value = round(new_value * 100) / 100.0
	update_text()
