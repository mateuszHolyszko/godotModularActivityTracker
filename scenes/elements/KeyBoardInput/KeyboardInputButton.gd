@tool
extends Button
class_name KeyboardInputButton

signal text_changed(text)

@export var keyboard_scene: PackedScene
@export var placeholder_text: String = "Click to enter text"

var current_text: String = ""

func _ready():
	if Engine.is_editor_hint():
		if current_text == "":
			text = placeholder_text
	else:
		pressed.connect(_open_keyboard)


func _open_keyboard():
	if keyboard_scene == null:
		push_warning("Keyboard scene not assigned.")
		return

	var keyboard = keyboard_scene.instantiate()
	get_tree().root.add_child(keyboard)

	keyboard.text_entered.connect(_on_keyboard_text)
	keyboard.canceled.connect(_on_keyboard_cancel)
	keyboard.tree_exited.connect(_on_keyboard_closed)  # Add this line


func _on_keyboard_text(value: String):
	current_text = value
	text = current_text
	text_changed.emit(current_text)
	# Focus will be grabbed when keyboard closes


func _on_keyboard_cancel():
	pass  # Focus will be grabbed when keyboard closes


func _on_keyboard_closed():
	# Grab focus when keyboard is removed from scene
	call_deferred("grab_focus")
