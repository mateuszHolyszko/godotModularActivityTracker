extends Panel

@onready var main_control = $"../.."
@onready var start_time_label = $HC/StartTimePanel/HC/StartTimeLabel
@onready var elapsed_time_label = $HC/ElapsedTimePanel2/HC/ElapsedTimeLabel
@onready var average_time_label = $HC/AverageTimePanel3/HC/AverageTimeLabel

var currentSession: HypertrophySessionResource

# Called when the node enters the scene tree for the first time.
func _ready():
	currentSession = main_control.current_session
	update_start_time()
	update_elapsed()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_elapsed()

func update_start_time():
	if currentSession and currentSession.timestamp_start > 0:
		var dt_dict = Time.get_datetime_dict_from_system(currentSession.timestamp_start)
		var formatted = "%02d:%02d:%02d" % [dt_dict.hour, dt_dict.minute, dt_dict.second]
		start_time_label.text = "Start: " + formatted
	else:
		start_time_label.text = "No session"

func update_elapsed():
	var elapsed: int = 0
	if currentSession:
		elapsed = currentSession.get_duration()
	var minutes = elapsed / 60
	var seconds = elapsed % 60
	elapsed_time_label.text = "Elapsed: %02d:%02d" % [minutes, seconds]
