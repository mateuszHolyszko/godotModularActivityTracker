extends Node
## ==== USER PART =====
signal user_changed(user: UserResource)

var users : Array[UserResource] = []
var current_user : UserResource = null :
	set(value):
		current_user = value
		load_programs()
		user_changed.emit(value)	

const USER_DIR = "res://db/data/"

func _ready():
	DirAccess.make_dir_recursive_absolute(USER_DIR)
	load_users()
	load_exercises()

func load_users():
	users.clear()
	var dir = DirAccess.open(USER_DIR)
	if dir == null:
		return

	dir.list_dir_begin()

	var file = dir.get_next()

	while file != "":
		if file.ends_with(".tres"):
			var user = ResourceLoader.load(USER_DIR + file)
			users.append(user)

		file = dir.get_next()
		
func create_user(name : String):

	var user = UserResource.new()

	user.name = name
	user.id = str(Time.get_unix_time_from_system())

	ResourceSaver.save(user, USER_DIR + user.id + ".tres")

	users.append(user)

	return user
	
func save_user(user : UserResource):

	var path = USER_DIR + user.id + ".tres"

	ResourceSaver.save(user, path)

func get_last_measurement(user : UserResource) -> MeasurementResource:
	if user == null or user.measurements.is_empty():
		return null

	var last : MeasurementResource = user.measurements[0]
	for m in user.measurements:
		if m.timestamp > last.timestamp:
			last = m

	return last

func get_measurements_in_range(user: UserResource, days_back: int = 0, months_back: int = 0, years_back: int = 0) -> Array[MeasurementResource]:
	var result: Array[MeasurementResource] = []
	if user == null or user.measurements.is_empty():
		return result

	var now_dict = Time.get_datetime_dict_from_system()

	# Roll back the date
	var target_day   = now_dict.day
	var target_month = now_dict.month - months_back
	var target_year  = now_dict.year - years_back

	# Normalize months underflow
	while target_month <= 0:
		target_month += 12
		target_year -= 1

	# Convert to unix then subtract remaining days
	var from_timestamp = Time.get_unix_time_from_datetime_dict({
		"year": target_year, "month": target_month, "day": target_day,
		"hour": 0, "minute": 0, "second": 0
	}) - days_back * 86400

	for m in user.measurements:
		if m.timestamp >= from_timestamp:
			result.append(m)

	return result


func add_measurement(user : UserResource,
	arms : float,
	chest : float,
	waist : float,
	thigh : float,
	weight : float):

	var m = MeasurementResource.new()

	m.timestamp = Time.get_unix_time_from_system()
	m.arms = arms
	m.chest = chest
	m.waist = waist
	m.thigh = thigh
	m.weight = weight

	user.measurements.append(m)

	save_user(user)

## ==== Exercise Part
## Exercises are stored globally (not per-user) in a shared .tres file.
 
const EXERCISE_PATH = "res://db/data/exercises.tres"
 
## Holds all ExerciseResource objects at runtime.
var exercises: Array[ExerciseResource] = []
 
 
func load_exercises() -> void:
	exercises.clear()
	if ResourceLoader.exists(EXERCISE_PATH):
		var container = ResourceLoader.load(EXERCISE_PATH)
		if container and container is ExerciseListResource:
			exercises = container.items.duplicate()
 
 
func save_exercises() -> void:
	var container := ExerciseListResource.new()
	container.items = exercises.duplicate()
	ResourceSaver.save(container, EXERCISE_PATH)
 
 
func create_exercise(
	exercise_name: String,
	target_muscle: String,
	bodyweight: bool,
	tension_profile: ExerciseResource.TensionProfile,
	intensity: ExerciseResource.Intensity,
	isolation: bool,
	rep_min: int,
	rep_max: int
) -> ExerciseResource:
 
	var ex := ExerciseResource.new()
	ex.id             = str(Time.get_unix_time_from_system())
	ex.name           = exercise_name
	ex.target_muscle  = target_muscle
	ex.bodyweight     = bodyweight
	ex.tension_profile = tension_profile
	ex.intensity      = intensity
	ex.isolation      = isolation
	ex.rep_range      = Vector2i(rep_min, rep_max)
 
	exercises.append(ex)
	save_exercises()
	return ex
 
 
func delete_exercise(exercise_id: String) -> void:
	exercises = exercises.filter(func(e): return e.id != exercise_id)
	save_exercises()
 
 
func get_exercises_by_muscle(muscle: String) -> Array[ExerciseResource]:
	return exercises.filter(func(e): return e.target_muscle == muscle)

func get_exercises_filtered(
	targetMuscle: Variant = null,
	isIsolation: Variant = null,
	curve: Variant = null,
	intensity: Variant = null,
	isbodyweight: Variant = null
) -> Array[ExerciseResource]:

	var result: Array[ExerciseResource] = []

	for e in exercises:

		if targetMuscle != null and e.target_muscle != targetMuscle:
			continue

		if isIsolation != null and e.isolation != isIsolation:
			continue

		if curve != null and e.tension_profile != curve:
			continue

		if intensity != null and e.intensity != intensity:
			continue

		if isbodyweight != null and e.bodyweight != isbodyweight:
			continue

		result.append(e)

	return result


## ==== Program Part ====
## Programs are stored per-user at res://db/data/{user_id}/programs/

var programs: Array[HypertrophyProgramResource] = []


func _get_program_dir(user: UserResource) -> String:
	return USER_DIR + user.id + "/programs/"


func load_programs() -> void:
	programs.clear()
	if current_user == null:
		return

	var dir_path = _get_program_dir(current_user)
	DirAccess.make_dir_recursive_absolute(dir_path)

	var dir = DirAccess.open(dir_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var file = dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			var program = ResourceLoader.load(dir_path + file)
			if program and program is HypertrophyProgramResource:
				programs.append(program)
		file = dir.get_next()


func save_program(program: HypertrophyProgramResource) -> void:
	var dir_path = _get_program_dir(program.user)
	DirAccess.make_dir_recursive_absolute(dir_path)
	ResourceSaver.save(program, dir_path + program.id + ".tres")


func create_program(program_name: String) -> HypertrophyProgramResource:
	var program := HypertrophyProgramResource.new()
	program.id = str(Time.get_unix_time_from_system())
	program.name = program_name
	program.user = current_user

	programs.append(program)
	save_program(program)
	return program


func delete_program(program_id: String) -> void:
	for program in programs:
		if program.id == program_id:
			var path = _get_program_dir(program.user) + program_id + ".tres"
			DirAccess.remove_absolute(path)
			break
	programs = programs.filter(func(p): return p.id != program_id)


func add_exercise_to_program(
	program: HypertrophyProgramResource,
	exercise: ExerciseResource,
	exercise_type: ProgramExerciseEntry.ExerciseType
) -> ProgramExerciseEntry:

	var entry := ProgramExerciseEntry.new()
	entry.exercise = exercise
	entry.exercise_type = exercise_type
	entry.order = program.entries.size()

	program.entries.append(entry)
	save_program(program)
	return entry


## Inserts a new exercise at a specific order position, shifting all existing
## entries at or after insert_order up by one to make room.
func add_exercise_at_order(
	program: HypertrophyProgramResource,
	exercise: ExerciseResource,
	exercise_type: ProgramExerciseEntry.ExerciseType,
	insert_order: int
) -> ProgramExerciseEntry:

	# Shift all entries at or after insert_order up by one
	for e in program.entries:
		if e.order >= insert_order:
			e.order += 1

	# Update superset references that were shifted
	for s in program.supersets:
		if s.order_a >= insert_order:
			s.order_a += 1
		if s.order_b >= insert_order:
			s.order_b += 1

	var entry := ProgramExerciseEntry.new()
	entry.exercise = exercise
	entry.exercise_type = exercise_type
	entry.order = insert_order

	program.entries.append(entry)
	save_program(program)
	return entry


func remove_exercise_from_program(program: HypertrophyProgramResource, order_index: int) -> void:
	# Remove any supersets that referenced this entry
	program.supersets = program.supersets.filter(func(s):
		return s.order_a != order_index and s.order_b != order_index)

	# Remove the entry
	program.entries = program.entries.filter(func(e): return e.order != order_index)

	# Re-number remaining entries and fix superset references
	var sorted = program.get_sorted_entries()
	for i in sorted.size():
		var old_order = sorted[i].order
		sorted[i].order = i
		# Update any superset that referenced the old order value
		for s in program.supersets:
			if s.order_a == old_order:
				s.order_a = i
			if s.order_b == old_order:
				s.order_b = i

	save_program(program)


func add_superset(
	program: HypertrophyProgramResource,
	order_a: int,
	order_b: int
) -> ProgramSuperset:

	assert(abs(order_a - order_b) == 1, "Superset exercises must be adjacent")
	assert(program.is_valid(), "Program has invalid state before adding superset")

	var pair := ProgramSuperset.new()
	pair.order_a = order_a
	pair.order_b = order_b

	program.supersets.append(pair)
	save_program(program)
	return pair


func remove_superset(program: HypertrophyProgramResource, order_a: int, order_b: int) -> void:
	program.supersets = program.supersets.filter(func(s):
		return not (s.order_a == order_a and s.order_b == order_b))
	save_program(program)


func get_programs_for_user(user: UserResource) -> Array:
	return programs.filter(func(p): return p.user == user)

func get_program_muscle_overview(program: HypertrophyProgramResource) -> Dictionary:
	var overview: Dictionary = {}

	# Initialize all muscles with 0
	for muscle in MuscleData.get_all_muscles():
		overview[muscle] = 0

	if program == null:
		return overview

	# Count exercises
	for entry in program.entries:
		if entry.exercise == null:
			continue

		var muscle: String = entry.exercise.target_muscle

		if overview.has(muscle):
			overview[muscle] += 1
		else:
			# In case an exercise uses a muscle not in MUSCLE_COLORS
			overview[muscle] = 1

	return overview
