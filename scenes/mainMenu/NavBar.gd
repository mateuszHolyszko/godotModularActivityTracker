extends PanelContainer

@onready var date_label = $HBoxContainer/Clock/VBoxContainer/Date
@onready var time_label = $HBoxContainer/Clock/VBoxContainer/HC/Time

@onready var overview = $HBoxContainer/Overview
@onready var session = $HBoxContainer/Session
@onready var program = $HBoxContainer/Program
@onready var data = $HBoxContainer/Data

@onready var settings = $HBoxContainer/SettingsBattery/HC/SettingButton


func _ready():
	#==Clock==
	update_clock()
	
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(update_clock)
	add_child(timer)
	
	

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


func _on_overview_pressed():
	# Check if we are already here
	if MenuManager._active_menu_name == "overview_menu":
		overview.button_pressed=true # Since we dont change menu in this case re press button to indicate we are still here
		return
	MenuManager.change_menu("overview_menu")
	MenuManager.toggle_nav_buttons_pressed(false)
	overview.button_pressed=true
	#overview.grab_focus()
	

func _on_data_pressed():
	# Check if we are already here
	if MenuManager._active_menu_name == "data_menu":
		data.button_pressed=true
		return
	MenuManager.change_menu("data_menu")
	MenuManager.toggle_nav_buttons_pressed(false)
	data.button_pressed=true
	#data.grab_focus()


func _on_session_pressed():
	# Check if we are already here
	if MenuManager._active_menu_name == "session_menu":
		session.button_pressed=true
		return
	MenuManager.change_menu("session_menu")
	MenuManager.toggle_nav_buttons_pressed(false)
	session.button_pressed=true
	#session.grab_focus()


func _on_program_pressed():
	# Check if we are already here
	if MenuManager._active_menu_name == "program_menu":
		program.button_pressed=true
		return
	MenuManager.change_menu("program_menu")
	MenuManager.toggle_nav_buttons_pressed(false)
	program.button_pressed=true
	#program.grab_focus()


func _on_setting_button_pressed():
	# Check if we are already here
	if MenuManager._active_menu_name == "settings_menu":
		settings.button_pressed=true
		return
	MenuManager.change_menu("settings_menu")
	MenuManager.toggle_nav_buttons_pressed(false)
	settings.button_pressed=true
