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
var sets: Array = []

var start_time: int = 0
var end_time: int = 0


# ========================
# INIT (ALWAYS NEW SESSION)
# ========================

func _init(program: HypertrophyProgramResource):
	print("SessionModel: Initializing NEW session with program =", program)

	program_template = program
	session_resource = HypertrophySessionResource.new()

	exercises.clear()
	sets.clear()

	print("SessionModel: Copying exercises from program template")
	for entry in program.entries:
		print("SessionModel: Duplicating exercise:", entry.exercise)
		exercises.append(entry.exercise.duplicate())

	print("SessionModel: Initialization complete. Exercises:", exercises)

	model_reset.emit()


# ========================
# SESSION CONTROL
# ========================

func start_session(timestamp: int):
	print("SessionModel: Starting session at", timestamp)
	start_time = timestamp
	session_started.emit(timestamp)


func end_session(timestamp: int):
	print("SessionModel: Ending session at", timestamp)
	end_time = timestamp
	session_ended.emit(timestamp)


func finish_session() -> HypertrophySessionResource:
	print("SessionModel: Finishing session")

	# Set end time on both the model and the resource.
	var now := Time.get_unix_time_from_system()
	end_time = now
	session_resource.timestamp_start = start_time
	session_resource.timestamp_end = now

	# Discard sets where both weight and reps are zero (never filled in).
	var valid_sets := sets.filter(func(s: ExerciseSetResource) -> bool:
		var keep := not (s.weight == 0.0 and s.reps == 0)
		if not keep:
			print("SessionModel: Discarding empty set — exercise:", s.exercise, " set_number:", s.set_number)
		return keep
	)
	sets = valid_sets

	# Write the cleaned sets into the resource.
	session_resource.sets.clear()
	for s in sets:
		session_resource.sets.append(s)

	# Attach the originating program.
	session_resource.program = program_template

	print("SessionModel: Session resource ready to save. Sets kept:", session_resource.sets.size())

	session_ended.emit(now)
	return session_resource


func abort_session() -> void:
	print("SessionModel: Aborting session — discarding all data, nothing will be saved")

	sets.clear()
	exercises.clear()
	start_time = 0
	end_time = 0

	# Reset the resource so any lingering reference is inert.
	session_resource = HypertrophySessionResource.new()

	model_reset.emit()


# ========================
# SET OPERATIONS
# ========================

func add_set(exercise_idx: int, weight: float, reps: int, timestamp: int):
	print("SessionModel: Adding set for exercise index:", exercise_idx, " weight:", weight, " reps:", reps, " timestamp:", timestamp)

	var set_res = ExerciseSetResource.new()
	set_res.session = session_resource
	set_res.exercise = exercises[exercise_idx]
	set_res.set_number = get_next_set_number(exercise_idx)
	set_res.weight = weight
	set_res.reps = reps
	set_res.timestamp = timestamp

	sets.append(set_res)

	print("SessionModel: Set added:", set_res)

	set_added.emit(exercise_idx, set_res)


func remove_set(exercise_idx: int, set_number: int):
	print("SessionModel: Removing set for exercise index:", exercise_idx, " set_number:", set_number)

	var removed := false
	var ex_id = exercises[exercise_idx].id

	sets = sets.filter(func(s):
		var match = (s.exercise.id == ex_id and s.set_number == set_number)
		if match:
			print("SessionModel: Removing set:", s)
			removed = true
		return not match
	)

	if removed:
		set_removed.emit(exercise_idx, set_number)

	print("SessionModel: Sets after removal:", sets)


func edit_set(exercise_idx: int, set_number: int, new_weight: float, new_reps: int):
	print("SessionModel: Editing set for exercise index:", exercise_idx, " set_number:", set_number)

	var ex_id = exercises[exercise_idx].id

	for s in sets:
		if s.exercise.id == ex_id and s.set_number == set_number:
			s.weight = new_weight
			s.reps = new_reps

			print("SessionModel: Set edited:", s)

			set_edited.emit(exercise_idx, set_number, s)
			return


# ========================
# HELPERS
# ========================

func get_next_set_number(exercise_idx: int) -> int:
	print("SessionModel: Calculating next set number for exercise index:", exercise_idx)

	var count = 0
	var ex_id = exercises[exercise_idx].id

	for s in sets:
		if s.exercise.id == ex_id:
			count += 1

	var next_number = count + 1
	print("SessionModel: Next set number is:", next_number)

	return next_number


func get_sets_for_exercise(exercise_idx: int) -> Array:
	print("SessionModel: Getting sets for exercise index:", exercise_idx)

	var result: Array = []
	var ex_id = exercises[exercise_idx].id

	for s in sets:
		if s.exercise.id == ex_id:
			result.append(s)

	if result.is_empty():
		print("SessionModel: No sets found, creating and adding one real set")

		var empty_set = ExerciseSetResource.new()
		empty_set.session = session_resource
		empty_set.exercise = exercises[exercise_idx]
		empty_set.set_number = 1
		empty_set.weight = 0.0
		empty_set.reps = 0
		empty_set.timestamp = 0

		sets.append(empty_set)
		result.append(empty_set)

		set_added.emit(exercise_idx, empty_set)

	print("SessionModel: Sets found:", result)

	return result


# ========================
# OPTIONAL
# ========================

func change_exercise(exercise_idx: int, new_exercise):
	print("SessionModel: Changing exercise at index:", exercise_idx, " to:", new_exercise)

	exercises[exercise_idx] = new_exercise

	exercise_changed.emit(exercise_idx)


# ========================
# EXPORT
# ========================

func to_resource_sets() -> Array:
	print("SessionModel: Returning sets for resource saving:", sets)
	return sets
