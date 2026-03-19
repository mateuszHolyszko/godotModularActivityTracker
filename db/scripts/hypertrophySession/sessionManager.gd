extends Node
## Manages creation, persistence, and in-memory state of HypertrophySessionResource.
## Mirrors the pattern used by DataManager for programs and exercises.
##
## Add to your autoload list AFTER DataManager so current_user is available.


# ---------------------------------------------------------------------------
# Signals
# ---------------------------------------------------------------------------

signal session_started(session: HypertrophySessionResource)
signal session_ended(session: HypertrophySessionResource)
signal sessions_loaded()


# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

const USER_DIR = "res://db/data/"

## All sessions for the current user, loaded at startup / user switch.
var sessions: Array[HypertrophySessionResource] = []

## The session currently in progress, or null when idle.
var active_session: HypertrophySessionResource = null


# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

func _get_session_dir(user: UserResource) -> String:
	return USER_DIR + user.id + "/sessions/"


# ---------------------------------------------------------------------------
# Load / Save
# ---------------------------------------------------------------------------

## Call this whenever DataManager.current_user changes (or on _ready).
func load_sessions(user: UserResource) -> void:
	sessions.clear()
	active_session = null

	if user == null:
		return

	var dir_path = _get_session_dir(user)
	DirAccess.make_dir_recursive_absolute(dir_path)

	var dir = DirAccess.open(dir_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var file = dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			var session = ResourceLoader.load(dir_path + file)
			if session and session is HypertrophySessionResource:
				sessions.append(session)
				# Restore active session if app was restarted mid-session.
				if session.is_active():
					active_session = session
		file = dir.get_next()

	sessions_loaded.emit()


func save_session(session: HypertrophySessionResource) -> void:
	if session.program == null or session.program.user == null:
		push_error("SessionManager: cannot save session — program or user is null.")
		return

	var dir_path = _get_session_dir(session.program.user)
	DirAccess.make_dir_recursive_absolute(dir_path)
	ResourceSaver.save(session, dir_path + session.program.id + "_" + str(session.timestamp_start) + ".tres")


# ---------------------------------------------------------------------------
# Session lifecycle
# ---------------------------------------------------------------------------

## Creates a new session from a program, deep-copying its entries so they
## can be edited independently. Starts the timer immediately.
func start_session(program: HypertrophyProgramResource) -> HypertrophySessionResource:
	if active_session != null:
		push_warning("SessionManager: a session is already active. End it before starting a new one.")
		return active_session

	var session := HypertrophySessionResource.new()
	session.program = program
	session.timestamp_start = Time.get_unix_time_from_system()

	# Deep-copy each ProgramExerciseEntry so changes here never touch the program.
	for source_entry in program.get_sorted_entries():
		var copy := ProgramExerciseEntry.new()
		copy.order = source_entry.order
		copy.exercise_type = source_entry.exercise_type
		copy.exercise = source_entry.exercise   # ExerciseResource itself is shared (read-only data)
		session.entries.append(copy)

	active_session = session
	sessions.append(session)
	save_session(session)

	session_started.emit(session)
	return session


## Marks the active session as finished and persists it.
func end_session() -> void:
	if active_session == null:
		push_warning("SessionManager: no active session to end.")
		return

	active_session.timestamp_end = Time.get_unix_time_from_system()
	save_session(active_session)

	session_ended.emit(active_session)
	active_session = null


# ---------------------------------------------------------------------------
# Entry editing during a session
# ---------------------------------------------------------------------------

## Swaps the exercise at order_index in the active session.
## Pass a new_type (ProgramExerciseEntry.ExerciseType) to also change the set type,
## or leave it null to keep the original.
func swap_exercise_in_active_session(order_index: int, new_exercise: ExerciseResource,
		new_type: Variant = null) -> bool:
	if active_session == null:
		push_error("SessionManager: no active session.")
		return false

	var swapped = active_session.swap_exercise(order_index, new_exercise, new_type)
	if swapped:
		save_session(active_session)
	return swapped


# ---------------------------------------------------------------------------
# Set management
# ---------------------------------------------------------------------------

## Logs a new set for the given exercise in the active session.
## set_number defaults to next available — pass it explicitly if you need a specific slot.
## Returns the created ExerciseSetResource.
func log_set(exercise: ExerciseResource, weight: float, reps: int, set_number: int = -1) -> ExerciseSetResource:
	assert(active_session != null, "SessionManager: no active session to log a set into.")
 
	var s := ExerciseSetResource.new()
	s.session    = active_session
	s.exercise   = exercise
	s.set_number = set_number if set_number > 0 else active_session.get_set_count_for_exercise(exercise) + 1
	s.weight     = weight
	s.reps       = reps
	s.timestamp  = Time.get_unix_time_from_system()
 
	active_session.sets.append(s)
	save_session(active_session)
	return s


## Edits weight and reps on an already-logged set (identified by exercise + set_number).
## Returns false if the set was not found.
func edit_set(exercise: ExerciseResource, set_number: int,
		new_weight: float, new_reps: int) -> bool:
	assert(active_session != null, "SessionManager: no active session.")

	for s in active_session.sets:
		if s.exercise == exercise and s.set_number == set_number:
			s.weight = new_weight
			s.reps   = new_reps
			save_session(active_session)
			return true
	return false


## Removes a logged set and re-numbers any higher sets for that exercise
## so set_number stays contiguous (1, 2, 3 …).
## Returns false if the set was not found.
func remove_set(exercise: ExerciseResource, set_number: int) -> bool:
	assert(active_session != null, "SessionManager: no active session.")

	var before_size := active_session.sets.size()
	active_session.sets = active_session.sets.filter(
		func(s): return not (s.exercise == exercise and s.set_number == set_number))

	if active_session.sets.size() == before_size:
		return false  # nothing was removed

	# Re-number remaining sets for this exercise to close the gap.
	var remaining := active_session.get_sets_for_exercise(exercise)  # sorted by set_number
	for i in remaining.size():
		remaining[i].set_number = i + 1

	save_session(active_session)
	return true


# ---------------------------------------------------------------------------
# Queries
# ---------------------------------------------------------------------------

## Returns all finished sessions that were built from the given program.
func get_sessions_for_program(program: HypertrophyProgramResource) -> Array[HypertrophySessionResource]:
	return sessions.filter(func(s): return s.program == program and not s.is_active())


## Returns the most recent finished session for a program, or null.
func get_last_session_for_program(program: HypertrophyProgramResource) -> HypertrophySessionResource:
	var filtered = get_sessions_for_program(program)
	if filtered.is_empty():
		return null
	filtered.sort_custom(func(a, b): return a.timestamp_start > b.timestamp_start)
	return filtered[0]


## Returns every session in the given unix-time range (inclusive).
func get_sessions_in_range(from_ts: int, to_ts: int) -> Array[HypertrophySessionResource]:
	return sessions.filter(func(s): return s.timestamp_start >= from_ts and s.timestamp_start <= to_ts)


## Returns the sets from the most recent workout where the given exercise was logged.
## Scans all sets across all sessions directly (no per-session crawl needed thanks
## to the per-set timestamp). Returns an empty array if the exercise has never been logged.
func find_most_recent_sets(exercise: ExerciseResource) -> Array[ExerciseSetResource]:
	# Collect every set ever logged for this exercise.
	var all_sets: Array[ExerciseSetResource] = []
	for session in sessions:
		for s in session.sets:
			if s.exercise == exercise:
				all_sets.append(s)

	if all_sets.is_empty():
		return []

	# Find the timestamp of the most recent set for this exercise.
	var latest_ts: int = all_sets[0].timestamp
	for s in all_sets:
		if s.timestamp > latest_ts:
			latest_ts = s.timestamp

	# Keep only sets that share the same session as that latest set.
	# Using session identity rather than timestamp equality avoids falsely grouping
	# sets logged in different sessions that happen to share a close timestamp.
	var latest_session: HypertrophySessionResource = null
	for s in all_sets:
		if s.timestamp == latest_ts:
			latest_session = s.session
			break

	var result: Array[ExerciseSetResource] = all_sets.filter(
		func(s): return s.session == latest_session)
	result.sort_custom(func(a, b): return a.set_number < b.set_number)
	return result
