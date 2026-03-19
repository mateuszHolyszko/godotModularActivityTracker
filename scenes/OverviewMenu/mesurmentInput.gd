extends Control

@onready var exitButton = $CurrentSceneContent/MarginContainer/HBoxContainer/LeftPanel/MarginContainer/VBoxMesurments/ExitButton
@onready var saveButton = $CurrentSceneContent/MarginContainer/HBoxContainer/LeftPanel/MarginContainer/VBoxMesurments/SaveButton
@onready var armsInput = $CurrentSceneContent/MarginContainer/HBoxContainer/LeftPanel/MarginContainer/VBoxMesurments/HBoxContainer2/Arms
@onready var chestInput = $CurrentSceneContent/MarginContainer/HBoxContainer/LeftPanel/MarginContainer/VBoxMesurments/HBoxContainer3/Chest
@onready var waistInput = $CurrentSceneContent/MarginContainer/HBoxContainer/LeftPanel/MarginContainer/VBoxMesurments/HBoxContainer4/Waist
@onready var thighInput = $CurrentSceneContent/MarginContainer/HBoxContainer/LeftPanel/MarginContainer/VBoxMesurments/HBoxContainer5/Thigh
@onready var weightInput = $CurrentSceneContent/MarginContainer/HBoxContainer/LeftPanel/MarginContainer/VBoxMesurments/HBoxContainer/Weight
@onready var rootContainter = $CurrentSceneContent

# Plot Elements
@onready var optionButtonMesurmentQuery = $CurrentSceneContent/MarginContainer/HBoxContainer/RightPanel/VBoxContainer/PlotterInputsPanel/MarginContainer/HBoxContainer/OptionButton
@onready var plotter = $CurrentSceneContent/MarginContainer/HBoxContainer/RightPanel/VBoxContainer/PlotterPanel/MarginContainer/plot
@onready var dayInput = $CurrentSceneContent/MarginContainer/HBoxContainer/RightPanel/VBoxContainer/PlotterInputsPanel/MarginContainer/HBoxContainer/DayInputPanel/VBoxContainer/DayInput
@onready var monthInput = $CurrentSceneContent/MarginContainer/HBoxContainer/RightPanel/VBoxContainer/PlotterInputsPanel/MarginContainer/HBoxContainer/MonthInputPanel2/VBoxContainer/MonthInput
@onready var yearInput = $CurrentSceneContent/MarginContainer/HBoxContainer/RightPanel/VBoxContainer/PlotterInputsPanel/MarginContainer/HBoxContainer/YearInputPanel3/VBoxContainer/YearInput

# Maps option button index to measurement field name and color
const PLOT_OPTIONS = [
	{ "label": "Weight", "field": "weight", "color": Color.WHITE },
	{ "label": "Arms",   "field": "arms",   "color": Color.LIGHT_BLUE },
	{ "label": "Chest",  "field": "chest",  "color": Color.INDIAN_RED },
	{ "label": "Waist",  "field": "waist",  "color": Color.HOT_PINK },
	{ "label": "Thigh",  "field": "thigh",  "color": Color.GREEN_YELLOW },
]


func _ready():
	exitButton.grab_focus()
	saveButton.pressed.connect(_on_save_button_pressed)
	DataManager.user_changed.connect(_on_user_changed)
	_set_inputs_enabled(DataManager.current_user != null)
	_load_last_measurement()

	# Populate option button from PLOT_OPTIONS
	optionButtonMesurmentQuery.clear()
	for opt in PLOT_OPTIONS:
		optionButtonMesurmentQuery.add_item(opt["label"])

	# Connect plot controls
	optionButtonMesurmentQuery.item_selected.connect(_on_plot_inputs_changed)
	dayInput.value_confirmed.connect(_on_plot_inputs_changed)
	monthInput.value_confirmed.connect(_on_plot_inputs_changed)
	yearInput.value_confirmed.connect(_on_plot_inputs_changed)

	_update_plot()


func _on_user_changed(user: UserResource):
	_set_inputs_enabled(user != null)
	_load_last_measurement()
	_update_plot()


func _on_plot_inputs_changed(_val = null):
	_update_plot()


func _update_plot():
	plotter.clear()
 
	var user = DataManager.current_user
	if user == null:
		return
 
	var measurements = DataManager.get_measurements_in_range(
		user,
		int(dayInput.value),
		int(monthInput.value),
		int(yearInput.value)
	)
 
	if measurements.size() < 2:
		return
 
	# Sort by timestamp ascending
	measurements.sort_custom(func(a, b): return a.timestamp < b.timestamp)
 
	var opt = PLOT_OPTIONS[optionButtonMesurmentQuery.selected]
	var field = opt["field"]
 
	# Build shared timestamps array
	var timestamps = PackedFloat64Array()
	for m in measurements:
		timestamps.append(float(m.timestamp))
 
	# Always plot the selected metric
	var values = PackedFloat64Array()
	for m in measurements:
		values.append(float(m.get(field)))
	plotter.add_plot_line(timestamps, values, opt["color"], opt["label"])
 
	# If selected metric is not weight, also plot weight as reference
	if field != "weight":
		var weight_values = PackedFloat64Array()
		for m in measurements:
			weight_values.append(float(m.weight))
		plotter.add_plot_line(timestamps, weight_values, Color.WHITE, "Weight")


func _set_inputs_enabled(enabled: bool):
	saveButton.disabled = !enabled
	armsInput.disabled  = !enabled
	chestInput.disabled = !enabled
	waistInput.disabled = !enabled
	thighInput.disabled = !enabled
	weightInput.disabled = !enabled


func _load_last_measurement():
	var last = DataManager.get_last_measurement(DataManager.current_user)
	if last == null:
		return

	armsInput.value   = last.arms
	armsInput.update_text()
	chestInput.value  = last.chest
	chestInput.update_text()
	waistInput.value  = last.waist
	waistInput.update_text()
	thighInput.value  = last.thigh
	thighInput.update_text()
	weightInput.value = last.weight
	weightInput.update_text()


func _on_save_button_pressed():
	var user = DataManager.current_user
	if user == null:
		push_warning("mesurmentInput: No current_user set on DataManager.")
		return

	DataManager.add_measurement(
		user,
		armsInput.value,
		chestInput.value,
		waistInput.value,
		thighInput.value,
		weightInput.value
	)
	_on_plot_inputs_changed()
	NotificationManager.notify("Data Saved")


func _on_exit_button_pressed():
	MenuManager.change_menu("res://scenes/OverviewMenu/overview.tscn")
