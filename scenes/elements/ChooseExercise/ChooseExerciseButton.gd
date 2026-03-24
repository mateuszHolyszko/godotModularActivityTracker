@tool
extends Button
class_name ChooseExerciseButton

signal exercise_selected(target: String, exercise_entry: ProgramExerciseEntry)

@export var selector_scene: PackedScene
@export var prompt_text: String = "Choose target and exercise"
@export var placeholder_text: String = "Select exercise..."

var selected_target: String = ""
var selected_exercise_entry: ProgramExerciseEntry = null


func _ready():
	if Engine.is_editor_hint():
		if selected_target.is_empty() or not selected_exercise_entry:
			text = placeholder_text
		else:
			_update_display_text()
		return

	pressed.connect(_open_selector)


func _open_selector():
	if selector_scene == null:
		push_warning("Exercise selector scene not assigned.")
		return

	var selector = selector_scene.instantiate()
	get_tree().root.add_child(selector)

	# Position and size it as an overlay
	selector.size = get_viewport().get_visible_rect().size
	selector.position = Vector2.ZERO

	selector.selection_completed.connect(_on_selection_completed)
	selector.cancelled.connect(_on_selector_cancel)
	selector.tree_exited.connect(_on_selector_closed)


func _on_selection_completed(target: String, exercise_entry: ProgramExerciseEntry):
	selected_target = target
	selected_exercise_entry = exercise_entry
	
	_update_display_text()
	
	exercise_selected.emit(target, exercise_entry)
	# Focus will be grabbed when selector closes


func _on_selector_cancel():
	pass  # Focus will be grabbed when selector closes


func _on_selector_closed():
	# Grab focus when selector is removed from scene
	call_deferred("grab_focus")


func _update_display_text():
	if selected_exercise_entry and selected_exercise_entry.exercise:
		text = "%s" % [selected_exercise_entry.exercise.name]
	else:
		text = placeholder_text


## Clear the current selection
func clear_selection():
	selected_target = ""
	selected_exercise_entry = null
	text = placeholder_text


## Check if an exercise has been selected
func has_selection() -> bool:
	return selected_exercise_entry != null


## Get the selected exercise entry
func get_selected_exercise() -> ProgramExerciseEntry:
	return selected_exercise_entry


## Get the selected target muscle
func get_selected_target() -> String:
	return selected_target
