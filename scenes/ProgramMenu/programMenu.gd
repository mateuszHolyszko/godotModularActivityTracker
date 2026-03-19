extends Control

signal active_program_changed(program: HypertrophyProgramResource)

func _ready():
	DataManager.user_changed.connect(_on_user_changed)

var active_program: HypertrophyProgramResource = null :
	set(value):
		active_program = value
		active_program_changed.emit(value)
		
func _on_user_changed(_user: UserResource) -> void:
	# Reset active program to null when user changes
	active_program = null

