extends Control

const EXERCISE_ROW_SCENE = preload("res://scenes/DataMenu/exerciseRow.tscn")
const ROW_HEIGHT = 100

@onready var scroll_content = $CurrentSceneContent/MC/VC/ScrollPanelContainer/ScrollContainer/ScrollContent
@onready var addExButton = $CurrentSceneContent/MC/VC/HC/AddExButton

#Filters ====
@onready var optionButtonTarget = $CurrentSceneContent/MC/VC/HC/FiltersPanel/HC/InputPanelTarget/VC/InputTarget
@onready var optionButtonIsolation = $CurrentSceneContent/MC/VC/HC/FiltersPanel/HC/InputPanelIsolation/VC/InputIsolation
@onready var optionButtonIntensity = $CurrentSceneContent/MC/VC/HC/FiltersPanel/HC/InputPanelIntensity/VC/InputIntensity
@onready var optionButtonCurve = $CurrentSceneContent/MC/VC/HC/FiltersPanel/HC/InputPanelCurve/VC/InputCurve
@onready var optionButtonBodyweight = $CurrentSceneContent/MC/VC/HC/FiltersPanel/HC/InputPanelBodyweight2/VC/InputBodyWeight

func _ready() -> void:
	#optionButtonTarget.grab_focus()
	
	addExButton.pressed.connect(_on_add_exercise_pressed)
	optionButtonTarget.item_selected.connect(_on_filter_changed)
	optionButtonIsolation.item_selected.connect(_on_filter_changed)
	optionButtonIntensity.item_selected.connect(_on_filter_changed)
	optionButtonCurve.item_selected.connect(_on_filter_changed)
	optionButtonBodyweight.item_selected.connect(_on_filter_changed)

	_populate()

func _populate() -> void:
	for child in scroll_content.get_children():
		child.queue_free()

	var target = _option_to_value_string(optionButtonTarget)
	var isolation = _option_to_bool(optionButtonIsolation)
	var curve = _option_to_value_enum(optionButtonCurve)
	var intensity = _option_to_value_enum(optionButtonIntensity)
	var bodyweight = _option_to_bool(optionButtonBodyweight)

	var exercises: Array[ExerciseResource] = DataManager.get_exercises_filtered(
		target,
		isolation,
		curve,
		intensity,
		bodyweight
	)

	var count := exercises.size()
	scroll_content.custom_minimum_size.y = max(count, 1) * ROW_HEIGHT

	for exercise in exercises:
		var row = EXERCISE_ROW_SCENE.instantiate()
		scroll_content.add_child(row)
		row.load_exercise_resource(exercise)

func _on_add_exercise_pressed() -> void:
	scroll_content.custom_minimum_size.y += ROW_HEIGHT

	var row = EXERCISE_ROW_SCENE.instantiate()
	scroll_content.add_child(row)

	# Wait one frame for the row's _ready() to run before grabbing focus
	await get_tree().process_frame
	row.name_input.grab_focus()

func _option_to_bool(option: OptionButton) -> Variant:
	if option.selected == -1:
		return null

	var text := option.get_item_text(option.selected)

	if text == "True":
		return true
	if text == "False":
		return false

	return null


func _option_to_value_enum(option: OptionButton) -> Variant:
	if option.selected == -1:
		return null

	if option.get_item_text(option.selected) == "All":
		return null

	return option.get_item_id(option.selected)


func _option_to_value_string(option: OptionButton) -> Variant:
	if option.selected == -1:
		return null

	if option.get_item_text(option.selected) == "All":
		return null

	return option.get_item_text(option.selected)
	
func _on_filter_changed(_index:int) -> void:
	_populate()
