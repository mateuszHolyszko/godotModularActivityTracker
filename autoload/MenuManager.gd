extends Node

# Reference to the main control container where menus will be displayed
var main_control: Control
# Reference to NavBar so that it can be accessed anaywhere
var nav_bar: PanelContainer

# Keep track of menu history for back navigation
var menu_history: Array[String] = []

# Cache for loaded scenes to improve performance
var scene_cache: Dictionary = {}

# Track the current menu scene path
var current_menu: String = ""

# Signal emitted when menu changes
signal menu_changed(scene_path: String)

func _ready():
	# Make sure this node persists across scene changes
	process_mode = PROCESS_MODE_ALWAYS

func change_menu(scene_path: String, add_to_history: bool = true) -> bool:
	"""Change the current menu to a new scene"""
	
	if not main_control:
		push_error("MenuManager: main_control not set! Call set_main_control() first.")
		return false
	
	# Validate scene path
	if not ResourceLoader.exists(scene_path):
		push_error("MenuManager: Scene does not exist: " + scene_path)
		return false
	
	# Add current menu to history if requested
	if add_to_history and current_menu != "":
		# Don't add if it's the same as the current one
		if menu_history.size() == 0 or menu_history.back() != current_menu:
			menu_history.append(current_menu)
	
	# Clear current content
	for child in main_control.get_children():
		child.queue_free()
	
	# Load and instantiate new scene
	var new_scene = _load_scene(scene_path)
	if new_scene:
		main_control.add_child(new_scene)
		_set_control_anchors(new_scene)
		
		# Update current menu
		current_menu = scene_path
		
		menu_changed.emit(scene_path)
		return true
	
	return false

func go_back() -> bool:
	"""Go back to the previous menu"""
	if menu_history.size() == 0:
		return false
	
	# Get previous menu
	var previous_menu = menu_history.pop_back()
	
	return change_menu(previous_menu, false)

func set_main_control(control: Control) -> void:
	"""Set the main control container reference"""
	main_control = control
	
	# Clear history when setting new main control
	menu_history.clear()
	current_menu = ""

func set_nav_bar(navBar: PanelContainer) -> void:
	"""Set the nav bar container reference"""
	nav_bar = navBar

func clear_history() -> void:
	"""Clear the menu history"""
	menu_history.clear()

func get_current_menu() -> String:
	"""Get the current menu scene path"""
	return current_menu

func _load_scene(scene_path: String) -> Node:
	"""Load a scene with optional caching"""
	var scene: PackedScene
	
	# Check cache first
	if scene_cache.has(scene_path):
		scene = scene_cache[scene_path]
	else:
		# Load and cache
		scene = load(scene_path)
		scene_cache[scene_path] = scene
	
	if scene:
		return scene.instantiate()
	else:
		push_error("MenuManager: Failed to load scene: " + scene_path)
		return null

func _set_control_anchors(control: Control) -> void:
	"""Set a control to fill its parent completely"""
	control.anchor_left = 0
	control.anchor_right = 1
	control.anchor_top = 0
	control.anchor_bottom = 1
	
	# Also set size flags to ensure proper expansion
	control.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL
	control.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_FILL

# Optional: Preload frequently used menus
func preload_menu(scene_path: String) -> void:
	"""Preload a menu scene into cache"""
	if not scene_cache.has(scene_path) and ResourceLoader.exists(scene_path):
		scene_cache[scene_path] = load(scene_path)

# Optional: Clear cache to free memory
func clear_cache() -> void:
	"""Clear the scene cache"""
	scene_cache.clear()

# Convenience function to toggle all nav bar buttons
func toggle_nav_buttons(disable: bool) -> void:
	"""Toggle all navigation bar buttons disabled state"""
	if not nav_bar:
		push_error("MenuManager: nav_bar not set!")
		return
	
	# Get all menu buttons (you may need to adjust the path based on your scene structure)
	var buttons_container = nav_bar.get_node_or_null("HBoxContainer")
	if not buttons_container:
		push_error("MenuManager: Could not find HBoxContainer in nav_bar")
		return
	
	for child in buttons_container.get_children():
		if child is Button:
			child.disabled = disable

# Function to disable all nav buttons except the current active one
func disable_all_nav_buttons_except_current() -> void:
	"""Disable all navigation buttons except the one corresponding to the current menu"""
	if not nav_bar:
		push_error("MenuManager: nav_bar not set!")
		return
	
	# Map menu paths to button names
	var menu_button_map = {
		"res://scenes/OverviewMenu/overview.tscn": "Overview",
		"res://scenes/SessionMenu/sessionMenu.tscn": "Session",
		"res://scenes/ProgramMenu/programMenu.tscn": "Program",
		"res://scenes/DataMenu/dataMenu.tscn": "Data"
	}
	
	var current_button_name = menu_button_map.get(current_menu, "")
	
	var buttons_container = nav_bar.get_node_or_null("HBoxContainer")
	if not buttons_container:
		push_error("MenuManager: Could not find HBoxContainer in nav_bar")
		return
	
	# Disable all buttons, then re-enable the current one
	for child in buttons_container.get_children():
		if child is Button:
			child.disabled = true
	
	# Enable the current active button
	if current_button_name != "":
		var current_button = buttons_container.get_node_or_null(current_button_name)
		if current_button:
			current_button.disabled = false

# Function to reset all nav buttons to their proper states based on current menu
func reset_nav_buttons_state() -> void:
	"""Reset all navigation buttons to the proper state based on the current menu"""
	if not nav_bar:
		push_error("MenuManager: nav_bar not set!")
		return
	
	# Map menu paths to button names
	var menu_button_map = {
		"res://scenes/OverviewMenu/overview.tscn": "Overview",
		"res://scenes/SessionMenu/sessionMenu.tscn": "Session",
		"res://scenes/ProgramMenu/programMenu.tscn": "Program",
		"res://scenes/DataMenu/dataMenu.tscn": "Data"
	}
	
	var buttons_container = nav_bar.get_node_or_null("HBoxContainer")
	if not buttons_container:
		push_error("MenuManager: Could not find HBoxContainer in nav_bar")
		return
	
	# Enable all buttons first
	for child in buttons_container.get_children():
		if child is Button:
			child.disabled = false
	
	# Disable the current active button
	var current_button_name = menu_button_map.get(current_menu, "")
	if current_button_name != "":
		var current_button = buttons_container.get_node_or_null(current_button_name)
		if current_button:
			current_button.disabled = true
