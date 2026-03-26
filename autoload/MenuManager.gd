extends Node

# Reference to the main control container where menus will be displayed
var main_control: Control
# Reference to NavBar so that it can be accessed anaywhere
var nav_bar: PanelContainer
# Reference to the transition color rect for fade in/out effects during menu changes or refeshes
var transition_rect: ColorRect = null

var menus: Dictionary = {}  # String -> Menu

var _active_menu_name: String = ""
var _pending_menu_name: String = ""

func _ready():
	# Make sure this node persists across scene changes
	process_mode = PROCESS_MODE_ALWAYS

func register(menu: Menu) -> void:
	menus[menu.name] = menu

# Change menu -> start fade out -> on fade out completed change menu and start fade in

func change_menu(menu_name: String) -> void:
	if not menus.has(menu_name):
		push_error("MenuManager: unknown menu '%s'." % menu_name)
		return
	
	if not transition_rect:
		push_error("MenuManager: transition_rect not set!")
		return
	
	_pending_menu_name = menu_name
	
	# Connect to fade_out signal if not already connected
	if not transition_rect.fade_out_completed.is_connected(_on_fade_out_completed):
		transition_rect.fade_out_completed.connect(_on_fade_out_completed)
	
	# Start fade out
	transition_rect.fade_out()

func _on_fade_out_completed():
	# Disconnect to avoid multiple calls
	if transition_rect.fade_out_completed.is_connected(_on_fade_out_completed):
		transition_rect.fade_out_completed.disconnect(_on_fade_out_completed)
	
	# Now change the menu
	_do_change_menu()
	
	# Start fade in
	transition_rect.fade_in()

func _do_change_menu():
	if _pending_menu_name == "":
		return
		
	if not menus.has(_pending_menu_name):
		push_error("MenuManager: unknown menu '%s'." % _pending_menu_name)
		return
	
	# Hide or free existing children depending on their persistence
	for child in main_control.get_children():
		var child_menu_name := child.get_meta("menu_name", "") as String
		if child_menu_name != "" and menus.has(child_menu_name) and menus[child_menu_name].is_persistent:
			child.hide()
		else:
			child.queue_free()
	
	# Reuse the cached instance for persistent menus, or instantiate fresh
	var pending_menu: Menu = menus[_pending_menu_name]
	var scene: Node = pending_menu.get_or_instantiate()
	if scene == null:
		return
	
	# Only add to the tree if it isn't already a child (persistent reuse)
	if scene.get_parent() != main_control:
		scene.set_meta("menu_name", _pending_menu_name)
		main_control.add_child(scene)
		_set_control_anchors(scene)
	
	scene.show()
	
	# Update active menu name
	_active_menu_name = _pending_menu_name
	_pending_menu_name = ""

func set_main_control(control: Control) -> void:
	"""Set the main control container reference"""
	main_control = control

func set_nav_bar(navBar: PanelContainer) -> void:
	"""Set the nav bar container reference"""
	nav_bar = navBar

func set_transition_rect(rect: ColorRect) -> void:
	transition_rect = rect

func _set_control_anchors(control: Control) -> void:
	"""Set a control to fill its parent completely"""
	control.anchor_left = 0
	control.anchor_right = 1
	control.anchor_top = 0
	control.anchor_bottom = 1
	
	# Also set size flags to ensure proper expansion
	control.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL
	control.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_FILL

# Convenience function to toggle all nav bar buttons
func toggle_nav_buttons_disable(disable: bool) -> void:
	"""Toggle all navigation bar buttons disabled state"""
	if not nav_bar:
		push_error("MenuManager: nav_bar not set!")
		return
	
	# Get all menu buttons 
	var buttons_container = nav_bar.get_node_or_null("HBoxContainer")
	if not buttons_container:
		push_error("MenuManager: Could not find HBoxContainer in nav_bar")
		return
	
	for child in buttons_container.get_children():
		if child is Button:
			child.disabled = disable
	
	# Disable user select button
	var user_button = nav_bar.get_node("HBoxContainer/UserSelect/VC/UserButton")
	if user_button:
		user_button.disabled = disable

# Convenience function to toggle all nav bar buttons
func toggle_nav_buttons_pressed(pressed: bool) -> void:
	"""Toggle all navigation bar buttons disabled state"""
	if not nav_bar:
		push_error("MenuManager: nav_bar not set!")
		return
	
	# Get all menu buttons 
	var buttons_container = nav_bar.get_node_or_null("HBoxContainer")
	if not buttons_container:
		push_error("MenuManager: Could not find HBoxContainer in nav_bar")
		return
	
	for child in buttons_container.get_children():
		if child is Button:
			child.button_pressed = pressed

	var user_button = nav_bar.get_node("HBoxContainer/SettingsBattery/HC/SettingButton")
	if user_button:
		user_button.button_pressed = pressed

func play_refresh_animation():

	if transition_rect:
		transition_rect.play_refresh_animation()
	else:
		push_warning("MenuManager: transition_rect not registered!")
