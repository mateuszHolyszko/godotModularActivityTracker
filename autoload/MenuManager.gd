extends Node

# Reference to the main control container where menus will be displayed
var main_control: Control
# Reference to NavBar so that it can be accessed anaywhere
var nav_bar: PanelContainer

# Keep track of menu history for back navigation
var menu_history: Array[String] = []

# Cache for loaded scenes to improve performance
var scene_cache: Dictionary = {}

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
	if add_to_history and menu_history.size() > 0:
		# Don't add if it's the same as the last one
		if menu_history.back() != scene_path:
			menu_history.append(scene_path)
	elif add_to_history and menu_history.size() == 0:
		menu_history.append(scene_path)
	
	# Clear current content
	for child in main_control.get_children():
		child.queue_free()
	
	# Load and instantiate new scene
	var new_scene = _load_scene(scene_path)
	if new_scene:
		main_control.add_child(new_scene)
		_set_control_anchors(new_scene)
		menu_changed.emit(scene_path)
		return true
	
	return false

func go_back() -> bool:
	"""Go back to the previous menu"""
	if menu_history.size() <= 1:
		return false
	
	# Remove current menu from history
	menu_history.pop_back()
	# Get previous menu
	var previous_menu = menu_history.back()
	# Remove it from history again so change_menu doesn't add it twice
	menu_history.pop_back()
	
	return change_menu(previous_menu, true)

func set_main_control(control: Control) -> void:
	"""Set the main control container reference"""
	main_control = control
	
	# Clear history when setting new main control
	menu_history.clear()

func set_nav_bar(navBar: PanelContainer) -> void:
	"""Set the nav bar container reference"""
	nav_bar = navBar

func clear_history() -> void:
	"""Clear the menu history"""
	menu_history.clear()

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
