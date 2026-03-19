extends PanelContainer

@onready var date_label = $HBoxContainer/Clock/VBoxContainer/Date
@onready var time_label = $HBoxContainer/Clock/VBoxContainer/Time
@onready var user_button = $HBoxContainer/UserSelect/VBoxContainer/UserButton

func _ready():
	#==Clock==
	update_clock()
	
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(update_clock)
	add_child(timer)
	
	#==SelectUser==
	

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
	MenuManager.change_menu("res://scenes/OverviewMenu/overview.tscn")
	# In NavBar disable this menu
	MenuManager.nav_bar.get_node("HBoxContainer/Overview").disabled = true
	# Enable other menus
	MenuManager.nav_bar.get_node("HBoxContainer/Session").disabled = false
	MenuManager.nav_bar.get_node("HBoxContainer/Program").disabled = false
	MenuManager.nav_bar.get_node("HBoxContainer/Data").disabled = false

func _on_data_pressed():
	MenuManager.change_menu("res://scenes/DataMenu/dataMenu.tscn")
	# In NavBar disable this menu
	MenuManager.nav_bar.get_node("HBoxContainer/Data").disabled = true
	# Enable other menus
	MenuManager.nav_bar.get_node("HBoxContainer/Overview").disabled = false
	MenuManager.nav_bar.get_node("HBoxContainer/Session").disabled = false
	MenuManager.nav_bar.get_node("HBoxContainer/Program").disabled = false


func _on_session_pressed():
	MenuManager.change_menu("res://scenes/SessionMenu/sessionMenu.tscn")
	# In NavBar disable this menu
	MenuManager.nav_bar.get_node("HBoxContainer/Session").disabled = true
	# Enable other menus
	MenuManager.nav_bar.get_node("HBoxContainer/Overview").disabled = false
	MenuManager.nav_bar.get_node("HBoxContainer/Program").disabled = false
	MenuManager.nav_bar.get_node("HBoxContainer/Data").disabled = false


func _on_program_pressed():
	MenuManager.change_menu("res://scenes/ProgramMenu/programMenu.tscn")
	# In NavBar disable this menu
	MenuManager.nav_bar.get_node("HBoxContainer/Program").disabled = true
	# Enable other menus
	MenuManager.nav_bar.get_node("HBoxContainer/Overview").disabled = false
	MenuManager.nav_bar.get_node("HBoxContainer/Session").disabled = false
	MenuManager.nav_bar.get_node("HBoxContainer/Data").disabled = false
