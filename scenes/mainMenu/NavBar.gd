extends PanelContainer

@onready var date_label = $HBoxContainer/Clock/VBoxContainer/Date
@onready var time_label = $HBoxContainer/Clock/VBoxContainer/Time
@onready var user_button = $HBoxContainer/UserSelect/VBoxContainer/UserButton

# Store the current active menu button
var current_active_button: Button = null

func _ready():
	#==Clock==
	update_clock()
	
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(update_clock)
	add_child(timer)
	
	#==SelectUser==
	
	# Initialize by setting the current active button based on the current scene
	_set_current_active_button()

func update_clock():
	var now = Time.get_datetime_dict_from_system()

	var date_string = "%04d-%02d-%02d" % [
		now.year,
		now.month,
		now.day
	]

	var time_string = "%02d:%02d" % [
		now.hour,
		now.minute
	]

	date_label.text = date_string
	time_label.text = time_string

func _set_current_active_button():
	# Determine which menu is currently active based on the current scene
	var current_scene = MenuManager.current_menu
	if current_scene:
		match current_scene:
			"res://scenes/OverviewMenu/overview.tscn":
				current_active_button = MenuManager.nav_bar.get_node("HBoxContainer/Overview")
			"res://scenes/SessionMenu/sessionMenu.tscn":
				current_active_button = MenuManager.nav_bar.get_node("HBoxContainer/Session")
			"res://scenes/ProgramMenu/programMenu.tscn":
				current_active_button = MenuManager.nav_bar.get_node("HBoxContainer/Program")
			"res://scenes/DataMenu/dataMenu.tscn":
				current_active_button = MenuManager.nav_bar.get_node("HBoxContainer/Data")

func toggle_menu_buttons(disable: bool):
	"""
	Toggle all menu buttons disabled state.
	If disabling, store the current active button.
	If enabling, restore the active button's disabled state.
	"""
	var buttons = [
		MenuManager.nav_bar.get_node("HBoxContainer/Overview"),
		MenuManager.nav_bar.get_node("HBoxContainer/Session"),
		MenuManager.nav_bar.get_node("HBoxContainer/Program"),
		MenuManager.nav_bar.get_node("HBoxContainer/Data")
	]
	
	if disable:
		# Store the current active button before disabling
		_set_current_active_button()
		
		# Disable all buttons
		for button in buttons:
			if button:
				button.disabled = true
	else:
		# Re-enable all buttons
		for button in buttons:
			if button:
				button.disabled = false
		
		# Disable the active button (the one that should remain disabled)
		if current_active_button:
			current_active_button.disabled = true

func disable_all_buttons():
	"""Convenience function to disable all menu buttons"""
	toggle_menu_buttons(true)

func enable_all_buttons():
	"""Convenience function to enable all menu buttons while keeping the active one disabled"""
	toggle_menu_buttons(false)

func _on_overview_pressed():
	MenuManager.change_menu("res://scenes/OverviewMenu/overview.tscn")
	# Update current active button
	current_active_button = MenuManager.nav_bar.get_node("HBoxContainer/Overview")
	# In NavBar disable this menu
	current_active_button.disabled = true
	# Enable other menus
	MenuManager.nav_bar.get_node("HBoxContainer/Session").disabled = false
	MenuManager.nav_bar.get_node("HBoxContainer/Program").disabled = false
	MenuManager.nav_bar.get_node("HBoxContainer/Data").disabled = false

func _on_data_pressed():
	MenuManager.change_menu("res://scenes/DataMenu/dataMenu.tscn")
	# Update current active button
	current_active_button = MenuManager.nav_bar.get_node("HBoxContainer/Data")
	# In NavBar disable this menu
	current_active_button.disabled = true
	# Enable other menus
	MenuManager.nav_bar.get_node("HBoxContainer/Overview").disabled = false
	MenuManager.nav_bar.get_node("HBoxContainer/Session").disabled = false
	MenuManager.nav_bar.get_node("HBoxContainer/Program").disabled = false


func _on_session_pressed():
	MenuManager.change_menu("res://scenes/SessionMenu/sessionMenu.tscn")
	# Update current active button
	current_active_button = MenuManager.nav_bar.get_node("HBoxContainer/Session")
	# In NavBar disable this menu
	current_active_button.disabled = true
	# Enable other menus
	MenuManager.nav_bar.get_node("HBoxContainer/Overview").disabled = false
	MenuManager.nav_bar.get_node("HBoxContainer/Program").disabled = false
	MenuManager.nav_bar.get_node("HBoxContainer/Data").disabled = false


func _on_program_pressed():
	MenuManager.change_menu("res://scenes/ProgramMenu/programMenu.tscn")
	# Update current active button
	current_active_button = MenuManager.nav_bar.get_node("HBoxContainer/Program")
	# In NavBar disable this menu
	current_active_button.disabled = true
	# Enable other menus
	MenuManager.nav_bar.get_node("HBoxContainer/Overview").disabled = false
	MenuManager.nav_bar.get_node("HBoxContainer/Session").disabled = false
	MenuManager.nav_bar.get_node("HBoxContainer/Data").disabled = false
