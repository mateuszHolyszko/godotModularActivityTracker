extends Panel
@onready var root = $"../../../../../.."
@onready var plot = $MarginContainer/plot
@onready var container = $MarginContainer

@onready var exerciseNode = $"../PlotterInputsPanel/ExerciseInput"
@onready var targetNode = $"../../../PanelMiddle/MarginContainer/VTargetMuscles"

var placeholder_label: Label = null

func _ready():
	root.plotQueryChanged.connect(_update_plot)
	exerciseNode.plotQueryChanged.connect(_update_plot)
	targetNode.target_selected.connect(_update_plot)
	DataManager.user_changed.connect(func(_value): _update_plot())
	
	_update_plot()
	
func _update_plot():
	# Clear plot
	plot.clear()
	
	# Remove placeholder if it exists
	if placeholder_label != null:
		placeholder_label.queue_free()
		placeholder_label = null
	
	# Get queried exercise
	var exercise: ExerciseResource = DataManager.get_exercise_by_name( root.plotQueryExercise )
	# Get queried time
	var time = root.plotQueryTime
	# Get plot color (based on exercise not root.plotQueryTarget)
	var color = MuscleData.get_color(exercise.target_muscle) if exercise else Color.WHITE
	
	# Check for null values and collect missing items
	var missing_items = []
	
	if exercise == null:
		missing_items.append("exercise")
	if DataManager.current_user == null:
		missing_items.append("current user")
	if root.plotQueryTarget == null or root.plotQueryTarget == "":
		missing_items.append("muscle target")
	if time == null:
		missing_items.append("time range")
	
	# If any required values are missing, show placeholder label
	if missing_items.size() > 0:
		# Create placeholder label
		placeholder_label = Label.new()
		placeholder_label.text = "Incomplete Query\nChoose: \n-" + "\n-".join(missing_items)
		placeholder_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		placeholder_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		placeholder_label.add_theme_font_size_override("font_size", 28)
		placeholder_label.add_theme_color_override("font_color", Color.WHITE)
		
		# Add the label to the container and make it fill the container
		container.add_child(placeholder_label)
		
		# Make the label fill the entire container
		placeholder_label.anchor_left = 0
		placeholder_label.anchor_right = 1
		placeholder_label.anchor_top = 0
		placeholder_label.anchor_bottom = 1
		placeholder_label.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL
		placeholder_label.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_FILL
		
		#print("Plot update aborted: missing ", ", ".join(missing_items))
		return
	
	#print("Query parameters:\ncolor -",color,"\nexercise - ",exercise.name,"\nTime - ",time)
	# Get weight array for queried exercise in queried time -> plotline 1
	# Get reps array for queried exercise in queried time -> plotline 2
	# Get corresponding timestamps for either weight or reps (they are the same)
	var queryOutputDict = SessionManager.find_top_sets_for_exercise_in_time_range( exercise, time )
	#print("Q:  ", queryOutputDict )
	# plot.add_plot_line(times, weight, Color, "Weight")
	plot.add_plot_line(queryOutputDict["timestamps"], queryOutputDict["weights"], color, "Weight")
	plot.add_plot_line(queryOutputDict["timestamps"], queryOutputDict["reps"], Color.WHITE, "Reps")
