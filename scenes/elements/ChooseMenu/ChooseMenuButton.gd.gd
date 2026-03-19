@tool
extends Button
class_name ChooseMenuButton

signal option_changed(option : String)

@export var choose_menu_scene : PackedScene
@export var prompt_text : String = "Choose option"
@export var options : Array[String] = []

@export var placeholder_text : String = "Select..."
@export var button_size : Vector2 = Vector2(200, 60)

var current_option : String = ""


func _ready():

	if Engine.is_editor_hint():
		if current_option == "":
			text = placeholder_text
		return

	pressed.connect(_open_menu)


func _open_menu():

	if choose_menu_scene == null:
		push_warning("Choose menu scene not assigned.")
		return

	var menu = choose_menu_scene.instantiate()
	get_tree().root.add_child(menu)

	menu.setup(prompt_text, options)
	menu.button_size = button_size

	menu.option_selected.connect(_on_option_selected)
	menu.canceled.connect(_on_menu_cancel)
	menu.tree_exited.connect(_on_menu_closed)  # Connect to tree_exited signal


func _on_option_selected(option : String):

	current_option = option
	text = option

	option_changed.emit(option)
	# Focus will be grabbed when menu closes


func _on_menu_cancel():
	pass  # Focus will be grabbed when menu closes


func _on_menu_closed():
	# Grab focus when menu is removed from scene
	call_deferred("grab_focus")
