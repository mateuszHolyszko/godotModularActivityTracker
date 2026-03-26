extends Control

signal plotQueryChanged

@onready var rootContainter = $CurrentSceneContent
@onready var container = $CurrentSceneContent/MarginContainer/HBoxContainer/PanelMiddle/MarginContainer/VTargetMuscles
@onready var buttonMesurments = $CurrentSceneContent/MarginContainer/HBoxContainer/VBoxLeft/ButtonMesurments
@onready var LastWeightLabel = $CurrentSceneContent/MarginContainer/HBoxContainer/VBoxLeft/WeightPanel/HBoxContainer/LastWeightTakenDate
@onready var LastDateLabel = $CurrentSceneContent/MarginContainer/HBoxContainer/VBoxLeft/WeightPanel/HBoxContainer/LastWeightTaken

@onready var ValueInDay = $CurrentSceneContent/MarginContainer/HBoxContainer/PanelRight/VBoxContainer/PlotterInputsPanel/TimeInput/HC/DayInputPanel/VBoxContainer/DayInput
@onready var ValueInMonth = $CurrentSceneContent/MarginContainer/HBoxContainer/PanelRight/VBoxContainer/PlotterInputsPanel/TimeInput/HC/MonthInputPanel2/VBoxContainer/MonthInput
@onready var ValueInYear = $CurrentSceneContent/MarginContainer/HBoxContainer/PanelRight/VBoxContainer/PlotterInputsPanel/TimeInput/HC/YearInputPanel3/VBoxContainer/YearInput
var custom_theme = preload("res://assets/style/retro_style.tres")

var plotQueryTarget: String
var plotQueryExercise: String
var plotQueryTime

func _ready():
	#buttonMesurments.grab_focus()
	container.theme = custom_theme
	DataManager.user_changed.connect(_on_user_changed)
	_update_weight_label()
	
	# === Time Query stuff ===
	get_time_from_time_inputs()
	# connect to value inputs
	ValueInDay.value_confirmed.connect(_on_time_input_changed)
	ValueInMonth.value_confirmed.connect(_on_time_input_changed)
	ValueInYear.value_confirmed.connect(_on_time_input_changed)


func _on_user_changed(_user: UserResource):
	_update_weight_label()


func _update_weight_label():
	var last = DataManager.get_last_measurement(DataManager.current_user)
	if last == null:
		LastWeightLabel.text = "Selected"
		LastDateLabel.text = "No User"
		return

	LastWeightLabel.text = str(last.weight) + " kg"

	# Calculate days difference
	var now = Time.get_unix_time_from_system()
	var diff_seconds = now - last.timestamp
	var diff_days = floor(diff_seconds / 86400)  # 86400 seconds in a day
	
	if diff_days == 0:
		LastDateLabel.text = "Today"
	elif diff_days == 1:
		LastDateLabel.text = "Yesterday"
	else:
		LastDateLabel.text = str(diff_days) + " days ago"


func _on_button_mesurments_pressed():
	MenuManager.change_menu("user_mesurment_menu")
	
	
func _on_time_input_changed(_value):
	"""Handle any time input change by recalculating the total time"""
	get_time_from_time_inputs()

func get_time_from_time_inputs():
	"""Calculate total time in seconds from day, month, and year inputs"""
	var day_in_seconds = 24 * 60 * 60  # 86400 seconds
	
	# Note: This is a simplified calculation assuming 31 days per month
	# For more accuracy, you might want to use actual calendar calculations
	var days = ValueInDay.value + (ValueInMonth.value * 31) + (ValueInYear.value * 365)
	
	plotQueryTime = days * day_in_seconds
	#print("Time calculated - Days: ", days, " Seconds: ", plotQueryTime)
	plotQueryChanged.emit()
