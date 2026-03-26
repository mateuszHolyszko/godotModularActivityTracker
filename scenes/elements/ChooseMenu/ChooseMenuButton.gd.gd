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

# Store reference to the currently open menu
var current_menu : Node = null


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
	
	current_menu = menu  # Store reference to the open menu

	menu.setup(prompt_text, options)
	menu.button_size = button_size

	menu.option_selected.connect(_on_option_selected)
	menu.canceled.connect(_on_menu_cancel)
	menu.tree_exited.connect(_on_menu_closed)


func _on_option_selected(option : String):
	current_option = option
	text = option

	option_changed.emit(option)
	# Focus will be grabbed when menu closes


func _on_menu_cancel():
	pass  # Focus will be grabbed when menu closes


func _on_menu_closed():
	# Clear reference to the closed menu
	current_menu = null
	# Grab focus when menu is removed from scene
	call_deferred("grab_focus")


# ============ NEW FUNCTIONS ============

func set_options(new_options: Array[String], update_current: bool = false):
	"""
	Set new options for the button.
	
	Parameters:
		- new_options: Array of strings with the new options
		- update_current: If true, updates current_option to match new options if it exists
	"""
	options = new_options
	
	# Update current option if it still exists in the new options
	if update_current and current_option != "":
		if current_option in options:
			text = current_option
		else:
			# Current option no longer exists, clear it
			clear_selection()
	
	# If menu is currently open, refresh it
	if current_menu and current_menu.is_inside_tree():
		refresh_open_menu()


func add_option(option: String, select_if_current: bool = false):
	"""
	Add a single option to the options list.
	
	Parameters:
		- option: The option to add
		- select_if_current: If true, automatically select this option if it becomes current
	"""
	if option not in options:
		options.append(option)
		
		# If menu is open, refresh it
		if current_menu and current_menu.is_inside_tree():
			refresh_open_menu()
		
		# Optionally select this option
		if select_if_current:
			set_current_option(option)


func remove_option(option: String):
	"""
	Remove an option from the options list.
	
	Parameters:
		- option: The option to remove
	"""
	if option in options:
		options.erase(option)
		
		# If the removed option was currently selected, clear selection
		if current_option == option:
			clear_selection()
		
		# If menu is open, refresh it
		if current_menu and current_menu.is_inside_tree():
			refresh_open_menu()


func clear_options():
	"""
	Clear all options from the button.
	"""
	options.clear()
	clear_selection()
	
	# If menu is open, refresh it
	if current_menu and current_menu.is_inside_tree():
		refresh_open_menu()


func set_current_option(option: String):
	"""
	Set the current selected option.
	
	Parameters:
		- option: The option to set as current
	"""
	if option in options:
		current_option = option
		text = option
		option_changed.emit(option)
	else:
		push_warning("Cannot set current option to '%s' - not in options list" % option)


func clear_selection():
	"""
	Clear the current selection, resetting to placeholder text.
	"""
	current_option = ""
	text = placeholder_text
	option_changed.emit("")  # Emit empty string to indicate cleared selection


func refresh_open_menu():
	"""
	Refresh the currently open menu with updated options.
	"""
	if current_menu and current_menu.is_inside_tree():
		# Re-setup the menu with updated options
		current_menu.setup(prompt_text, options)


func get_current_option() -> String:
	"""
	Get the currently selected option.
	
	Returns:
		The current selected option string, or empty string if none selected.
	"""
	return current_option


func has_option(option: String) -> bool:
	"""
	Check if an option exists in the options list.
	
	Parameters:
		- option: The option to check
	
	Returns:
		True if the option exists, false otherwise.
	"""
	return option in options


func get_options_count() -> int:
	"""
	Get the number of options.
	
	Returns:
		The number of options in the list.
	"""
	return options.size()
