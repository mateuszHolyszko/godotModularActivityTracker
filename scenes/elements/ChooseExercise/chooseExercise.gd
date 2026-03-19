extends Control

signal target_selected(target: String)
signal exercise_selected(exercise_entry: ProgramExerciseEntry)
signal selection_completed(target: String, exercise_entry: ProgramExerciseEntry)
signal cancelled()

@onready var GetExercisePanel = $Panel/MC/GetExercisePanel
@onready var GetTargetPanel = $Panel/MC/GetTargetPanel

var selected_target: String = ""
var selected_exercise_entry: ProgramExerciseEntry = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Start with target panel visible, exercise panel hidden
	GetTargetPanel.show()
	GetExercisePanel.hide()
	
	# Connect to target panel
	GetTargetPanel.target_chosen.connect(_on_target_chosen)
	
	# Connect to exercise panel
	GetExercisePanel.exercise_chosen.connect(_on_exercise_chosen)
	GetExercisePanel.back_pressed.connect(_on_exercise_back_pressed)
	
	# Connect target panel's cancel button
	GetTargetPanel.cancelButton.pressed.connect(_on_cancel)


func _on_target_chosen(target: String) -> void:
	selected_target = target
	target_selected.emit(target)
	
	# Pass the selected target to the exercise panel
	GetExercisePanel.set_target_filter(target)
	
	# Hide target panel and show exercise panel
	GetTargetPanel.hide()
	GetExercisePanel.show()


func _on_exercise_chosen(exercise_entry: ProgramExerciseEntry) -> void:
	selected_exercise_entry = exercise_entry
	exercise_selected.emit(exercise_entry)
	
	# Emit completion signal with both selections
	selection_completed.emit(selected_target, selected_exercise_entry)
	
	# Free the entire selector from the scene
	queue_free()


func _on_exercise_back_pressed() -> void:
	# Go back to target selection
	GetExercisePanel.hide()
	GetTargetPanel.show()


func _on_cancel() -> void:
	cancelled.emit()
	# Free the entire selector from the scene
	queue_free()


func reset() -> void:
	selected_target = ""
	selected_exercise_entry = null
	GetTargetPanel.show()
	GetExercisePanel.hide()


# Method to start the selection process
func start_selection() -> void:
	show()
	reset()
