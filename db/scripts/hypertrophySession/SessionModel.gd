extends Object
class_name SessionModel

# ========================
# SIGNALS
# ========================

signal set_added(exercise_idx: int, set_res: ExerciseSetResource)
signal set_removed(exercise_idx: int, set_number: int)
signal set_edited(exercise_idx: int, set_number: int, set_res: ExerciseSetResource)

signal exercise_changed(exercise_idx: int)

signal session_started(timestamp: int)
signal session_ended(timestamp: int)

signal model_reset()


# ========================
# DATA
# ========================

var session_resource: HypertrophySessionResource
var program_template: HypertrophyProgramResource

var exercises: Array = []
var sets: Array = [] # Array[Array[ExerciseSetResource]]  export so that its visible in the inspector for debugging

var start_time: int = 0
var end_time: int = 0

# Used so that exercises that are bodyweight can access this instead of quering the last measurement every time
var lastWeight = DataManager.get_last_measurement(DataManager.current_user).weight


# ========================
# INIT
# ========================

func _init(program: HypertrophyProgramResource):
	program_template = program
	session_resource = HypertrophySessionResource.new()

	exercises.clear()
	sets.clear()

	for entry in program.get_sorted_entries():
		var exercise = entry.exercise
		exercises.append(exercise)
		sets.append([]) # Initialize empty sets for this exercise

		var history: Array = SessionManager.find_most_recent_sets(exercise)

		for historic_set in history:
			var s := ExerciseSetResource.new()
			s.session = session_resource
			s.exercise = exercise
			s.set_number = historic_set.set_number
			s.weight = historic_set.weight
			s.reps = historic_set.reps
			s.timestamp = 0

			sets[-1].append(s)

		# If no history, append an extra set with timestamp = now, weight = 0, reps = 0
		if history.is_empty():
			var now = Time.get_unix_time_from_system()
			var extra_set := ExerciseSetResource.new()
			extra_set.session = session_resource
			extra_set.exercise = exercise
			extra_set.set_number = 1
			extra_set.weight = 0.0
			extra_set.reps = 0
			extra_set.timestamp = now
			sets[-1].append(extra_set)

	model_reset.emit()


# ========================
# SESSION CONTROL
# ========================

func start_session(timestamp: int):
	start_time = timestamp
	session_started.emit(timestamp)


func end_session(timestamp: int):
	end_time = timestamp
	session_ended.emit(timestamp)


func finish_session() -> HypertrophySessionResource:
	var now := Time.get_unix_time_from_system()
	end_time = now

	session_resource.timestamp_start = start_time
	session_resource.timestamp_end = now

	session_resource.sets.clear()

	for exercise_sets in sets:
		for s in exercise_sets:
			var keep: bool = not ((s.weight == 0.0 and s.reps == 0) or s.timestamp == 0)
			if keep:
				session_resource.sets.append(s)

	session_resource.program = program_template

	session_ended.emit(now)

	return session_resource


func abort_session() -> void:
	sets.clear()
	exercises.clear()
	start_time = 0
	end_time = 0

	session_resource = HypertrophySessionResource.new()

	model_reset.emit()


# ========================
# SET OPERATIONS
# ========================

func add_set(exercise_idx: int, weight: float, reps: int, timestamp: int):
	var set_res = ExerciseSetResource.new()
	set_res.session = session_resource
	set_res.exercise = exercises[exercise_idx]
	set_res.set_number = sets[exercise_idx].size() + 1  
	set_res.weight = weight
	set_res.reps = reps
	set_res.timestamp = timestamp

	sets[exercise_idx].append(set_res)

	set_added.emit(exercise_idx, set_res)


func remove_set(exercise_idx: int, set_number: int):
	var exercise_sets = sets[exercise_idx]

	var new_array := []
	var removed := false

	for s in exercise_sets:
		if s.set_number == set_number:
			removed = true
		else:
			new_array.append(s)

	sets[exercise_idx] = new_array

	if removed:
		set_removed.emit(exercise_idx, set_number)


func edit_set(exercise_idx: int, set_number: int, new_weight: float, new_reps: int):
	sets[exercise_idx][set_number].weight = new_weight
	sets[exercise_idx][set_number].reps = new_reps
	sets[exercise_idx][set_number].timestamp = Time.get_unix_time_from_system()
	set_edited.emit(exercise_idx, set_number, sets[exercise_idx][set_number])

# ========================
# HELPERS
# ========================


func get_sets_for_exercise(exercise_idx: int) -> Array:
	if sets[exercise_idx].is_empty():
		var exercise = exercises[exercise_idx]
		
		var empty_set = ExerciseSetResource.new()
		empty_set.session = session_resource
		empty_set.exercise = exercise
		empty_set.set_number = 1  # Since size is 0, size+1 = 1
		empty_set.weight = 0.0
		empty_set.reps = 0
		empty_set.timestamp = 0
		
		sets[exercise_idx].append(empty_set)
		set_added.emit(exercise_idx, empty_set)
	
	return sets[exercise_idx]


# ========================
# OPTIONAL
# ========================

func change_exercise(exercise_idx: int, new_exercise):
	exercises[exercise_idx] = new_exercise

	# Find most recent sets for the new exercise, similar to _init
	var history: Array = SessionManager.find_most_recent_sets(new_exercise)
	var new_sets := []
	for historic_set in history:
		var s := ExerciseSetResource.new()
		s.session = session_resource
		s.exercise = new_exercise
		s.set_number = historic_set.set_number
		s.weight = historic_set.weight
		s.reps = historic_set.reps
		s.timestamp = 0
		new_sets.append(s)

	# If no history, append an extra set with timestamp = now, weight = 0, reps = 0
	if history.is_empty():
		var now = Time.get_unix_time_from_system()
		var extra_set := ExerciseSetResource.new()
		extra_set.session = session_resource
		extra_set.exercise = new_exercise
		extra_set.set_number = 1
		extra_set.weight = 0.0
		extra_set.reps = 0
		extra_set.timestamp = now
		new_sets.append(extra_set)

	sets[exercise_idx] = new_sets

	exercise_changed.emit(exercise_idx)


# ========================
# EXPORT
# ========================

func to_resource_sets() -> Array:
	var flat: Array = []
	for exercise_sets in sets:
		flat.append_array(exercise_sets)
	return flat
