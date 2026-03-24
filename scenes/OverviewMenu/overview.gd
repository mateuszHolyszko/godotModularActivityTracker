extends Control

@onready var rootContainter = $CurrentSceneContent
@onready var container = $CurrentSceneContent/MarginContainer/HBoxContainer/PanelMiddle/MarginContainer/VBoxMiddle
@onready var buttonMesurments = $CurrentSceneContent/MarginContainer/HBoxContainer/VBoxLeft/ButtonMesurments
@onready var LastWeightLabel = $CurrentSceneContent/MarginContainer/HBoxContainer/VBoxLeft/WeightPanel/HBoxContainer/LastWeightTakenDate
@onready var LastDateLabel = $CurrentSceneContent/MarginContainer/HBoxContainer/VBoxLeft/WeightPanel/HBoxContainer/LastWeightTaken


var custom_theme = preload("res://assets/style/retro_style.tres")

func _ready():
	#buttonMesurments.grab_focus()
	container.theme = custom_theme
	create_muscle_buttons()
	DataManager.user_changed.connect(_on_user_changed)
	_update_weight_label()


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


func create_muscle_buttons():

	for muscle in MuscleData.get_all_muscles():

		var btn = Button.new()
		btn.text = muscle

		var color = MuscleData.get_color(muscle)
		apply_button_color(btn, color)

		container.add_child(btn)

func apply_button_color(button: Button, color: Color):

	var style = StyleBoxFlat.new()
	style.bg_color = color
	
	button.add_theme_color_override("font_color", Color.BLACK)
	button.add_theme_font_size_override("font_size", 30)

	button.add_theme_stylebox_override("normal", style)

func _on_button_mesurments_pressed():
	MenuManager.change_menu("user_mesurment_menu")
