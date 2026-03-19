extends Panel

signal program_selected(program)

@onready var program_list_container = $MC/HC/VC/PanelProgramList/ProgramListContainer
@onready var panel_program_list = $MC/HC/VC/PanelProgramList
@onready var targer_volume_panel = $MC/HC/LastSessionsSummary/VC/TargetVolumePanel
@onready var session_history_panel = $MC/HC/LastSessionsSummary/VC/SessionHistoryPanel

# References to noData panels 
@onready var program_list_no_data = $MC/HC/VC/PanelProgramList/noData
@onready var target_volume_no_data = $MC/HC/LastSessionsSummary/VC/TargetVolumePanel/noData
@onready var session_history_no_data = $MC/HC/LastSessionsSummary/VC/SessionHistoryPanel/noData

const PROGRAM_ROW_SCENE = preload("res://scenes/SessionMenu/playProgramListRow.tscn")

func _ready():
	# Connect to user_changed signal
	DataManager.user_changed.connect(_on_user_changed)
	reload_programs()

func reload_programs():
	# Clear old rows
	for child in program_list_container.get_children():
		child.queue_free()
	
	# Update program list visibility based on current user
	_update_program_list_visibility()
	
	# Only rebuild list if there's a current user
	if DataManager.current_user != null:
		for program in DataManager.programs:
			var row = PROGRAM_ROW_SCENE.instantiate()
			program_list_container.add_child(row)
			row.set_program(program)
			row.program_pressed.connect(_on_program_pressed)
	
	# Update target volume and session history panels
	_update_target_volume_panel()
	_update_session_history_panel()

func _update_program_list_visibility():
	# Show/hide program list container and noData panel based on user
	if DataManager.current_user == null:
		# No user selected - show noData panel, hide program list
		program_list_container.hide()
		if program_list_no_data:
			program_list_no_data.show()
	else:
		# User selected - show program list, hide noData panel
		program_list_container.show()
		if program_list_no_data:
			program_list_no_data.hide()

func _update_target_volume_panel():
	# Check if target volume panel has any child nodes besides the noData panel
	var has_content = false
	for child in targer_volume_panel.get_children():
		if child != target_volume_no_data:
			has_content = true
			break
	
	# Show/hide noData panel based on whether there's content
	if target_volume_no_data:
		target_volume_no_data.visible = not has_content

func _update_session_history_panel():
	# Check if session history panel has any child nodes besides the noData panel
	var has_content = false
	for child in session_history_panel.get_children():
		if child != session_history_no_data:
			has_content = true
			break
	
	# Show/hide noData panel based on whether there's content
	if session_history_no_data:
		session_history_no_data.visible = not has_content

func _on_program_pressed(program):
	program_selected.emit(program)
	NotificationManager.notify("Session started for program:\n%s" % program.name)

func _on_user_changed(user):
	# When user changes, reload programs and update visibility
	reload_programs()
	
	# You might also want to update target volume and session history panels
	# with data for the new user here
	_update_target_volume_panel()
	_update_session_history_panel()

# Optional: Call this when adding content to target volume or session history panels
func on_target_volume_content_added():
	_update_target_volume_panel()

# Optional: Call this when adding content to session history panel
func on_session_history_content_added():
	_update_session_history_panel()
