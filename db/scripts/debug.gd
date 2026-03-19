extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	# === User/Mesurment
	#debug_create_user()
	#debug_create_test1_user()
	#debug_test_measurement_range()
	debug_print_users()
	# === Exercises
	#create_exercise()
	find_exercise()
	# === Programs
	#debug_create_program()
	#debug_print_programs() # sets first user as current user
	#debug_add_superset()
	#debug_remove_exercise()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func debug_create_user():
	print("here")
	var user = DataManager.create_user("Test")

	DataManager.add_measurement(user, 38, 105, 84, 60, 75)
	DataManager.add_measurement(user, 39, 106, 83, 61, 78)

	print("User created")

func debug_print_users():

	if DataManager.users.size() == 0:
		print("No users found")
		return

	for user in DataManager.users:

		print("=== User ===")
		print("ID:", user.id)
		print("Name:", user.name)
		print("Measurements:", user.measurements.size())

		for m in user.measurements:

			var dt = Time.get_datetime_dict_from_unix_time(m.timestamp)

			var date_str = "%04d-%02d-%02d %02d:%02d" % [
				dt.year,
				dt.month,
				dt.day,
				dt.hour,
				dt.minute]

			print(
				"  Date:", date_str,
				" Arms:", m.arms,
				" Chest:", m.chest,
				" Waist:", m.waist,
				" Thigh:", m.thigh,
				" Weight:", m.weight)

# Creates "test1" user with measurements spread across the past ~14 months
func debug_create_test1_user():
	var user = DataManager.create_user("test1")
	var now = Time.get_unix_time_from_system()
 
	# Helper: offset in days from now
	var day = 86400
 
	# Spread measurements across different time windows for easy range testing
	_add_measurement_at(user, now - 2   * day,  38.0, 105.0, 84.0, 60.0, 75.0)  # 2 days ago
	_add_measurement_at(user, now - 10  * day,  38.5, 105.5, 83.5, 60.5, 74.5)  # 10 days ago
	_add_measurement_at(user, now - 20  * day,  39.0, 106.0, 83.0, 61.0, 74.0)  # 20 days ago
	_add_measurement_at(user, now - 40  * day,  39.5, 106.5, 82.5, 61.5, 73.5)  # ~1.5 months ago
	_add_measurement_at(user, now - 75  * day,  40.0, 107.0, 82.0, 62.0, 73.0)  # ~2.5 months ago
	_add_measurement_at(user, now - 120 * day,  40.5, 107.5, 81.5, 62.5, 72.5)  # ~4 months ago
	_add_measurement_at(user, now - 200 * day,  41.0, 108.0, 81.0, 63.0, 72.0)  # ~6.5 months ago
	_add_measurement_at(user, now - 370 * day,  41.5, 108.5, 80.5, 63.5, 71.5)  # ~1 year ago
	_add_measurement_at(user, now - 500 * day,  42.0, 109.0, 80.0, 64.0, 71.0)  # ~16 months ago
 
	print("[debug] test1 user created with ", user.measurements.size(), " measurements")
 
 
func _add_measurement_at(user: UserResource, timestamp: int, arms: float, chest: float, waist: float, thigh: float, weight: float):
	var m = MeasurementResource.new()
	m.timestamp = timestamp
	m.arms   = arms
	m.chest  = chest
	m.waist  = waist
	m.thigh  = thigh
	m.weight = weight
	user.measurements.append(m)
	DataManager.save_user(user)
 
 
func debug_test_measurement_range():
	# Find test1 user
	var test_user: UserResource = null
	for u in DataManager.users:
		if u.name == "test1":
			test_user = u
			break
 
	if test_user == null:
		print("[debug] test1 user not found — run debug_create_test1_user() first")
		return
 
	print("\n=== Range Query Tests for user: ", test_user.name, " ===")
	print("Total measurements: ", test_user.measurements.size())
 
	_print_range(test_user, "Last 7 days",    7,  0,  0)
	_print_range(test_user, "Last 30 days",  30,  0,  0)
	_print_range(test_user, "Last 1 month",   0,  1,  0)
	_print_range(test_user, "Last 3 months",  0,  3,  0)
	_print_range(test_user, "Last 6 months",  0,  6,  0)
	_print_range(test_user, "Last 1 year",    0,  0,  1)
	_print_range(test_user, "Last 2 years",   0,  0,  2)
 
 
func _print_range(user: UserResource, label: String, days: int, months: int, years: int):
	var results = DataManager.get_measurements_in_range(user, days, months, years)
	print("\n--- %s (days:%d months:%d years:%d) -> %d result(s) ---" % [label, days, months, years, results.size()])
	for m in results:
		var dt = Time.get_datetime_dict_from_unix_time(m.timestamp)
		print("  %04d-%02d-%02d | arms:%.1f chest:%.1f waist:%.1f thigh:%.1f weight:%.1f" % [
			dt.year, dt.month, dt.day,
			m.arms, m.chest, m.waist, m.thigh, m.weight
		])

#=== Exercises

func create_exercise():
	DataManager.create_exercise(
	"Romanian Deadlift",
	"Hamstrings",
	false,                                    # bodyweight
	ExerciseResource.TensionProfile.ECCENTRIC,
	ExerciseResource.Intensity.HARD,
	true,                                     # isolation
	6, 10                                     # rep_range min, max
)

func find_exercise():
	# Print all names
	var all: Array[ExerciseResource] = DataManager.exercises
	for ex in all:
		print(ex.name)

	# Print filtered names
	var back_exercises = DataManager.get_exercises_by_muscle("Hamstrings")
	for ex in back_exercises:
		print(ex.name)

	# Single result — .front() can return null if nothing matched, so guard it
	var target_id = "0"
	var ex = DataManager.exercises.filter(func(e): return e.id == target_id).front()
	if ex:
		print(ex.name)
	else:
		print("not found")


# === Programs

## Creates a program with 3 exercises for the first available user.
## Requires at least one user and at least 3 exercises in DataManager.
func debug_create_program():
	if DataManager.users.is_empty():
		print("[debug] no users found — run debug_create_user() first")
		return

	if DataManager.exercises.size() < 3:
		print("[debug] need at least 3 exercises — run create_exercise() a few times first")
		return

	# Set current user so data_manager knows where to save
	DataManager.current_user = DataManager.users[0]
	print("[debug] creating program for user: ", DataManager.current_user.name)

	var program = DataManager.create_program("Push Day A1")

	# Add 5 exercises with different types
	DataManager.add_exercise_to_program(
		program,
		DataManager.exercises[0],
		ProgramExerciseEntry.ExerciseType.STRAIGHT_SET
	)
	DataManager.add_exercise_to_program(
		program,
		DataManager.exercises[1],
		ProgramExerciseEntry.ExerciseType.DROP_SET
	)
	DataManager.add_exercise_to_program(
		program,
		DataManager.exercises[2],
		ProgramExerciseEntry.ExerciseType.MYO_SET
	)
	DataManager.add_exercise_to_program(
		program,
		DataManager.exercises[3],
		ProgramExerciseEntry.ExerciseType.STRAIGHT_SET
	)
	DataManager.add_exercise_to_program(
		program,
		DataManager.exercises[4],
		ProgramExerciseEntry.ExerciseType.STRAIGHT_SET
	)

	print("[debug] program created: '", program.name, "' with ", program.entries.size(), " exercises")
	print("[debug] is_valid: ", program.is_valid())


## Adds a superset between order 0 and order 1 on the first program.
func debug_add_superset():
	if DataManager.programs.is_empty():
		print("[debug] no programs found — run debug_create_program() first")
		return

	var program = DataManager.programs[0]

	if program.entries.size() < 2:
		print("[debug] program needs at least 2 exercises to superset")
		return

	DataManager.add_superset(program, 0, 1)
	print("[debug] superset added between order 0 and 1")
	print("[debug] is_valid: ", program.is_valid())

	# Print superset exercises
	var pair = program.supersets[0]
	var pair_entries = program.get_superset_entries(pair.order_a, pair.order_b)
	print("[debug] superset exercises:")
	for entry in pair_entries:
		print("  order:", entry.order, " name:", entry.exercise.name)


## Removes the middle exercise (order 1) and checks that re-numbering is correct.
func debug_remove_exercise():
	if DataManager.programs.is_empty():
		print("[debug] no programs found — run debug_create_program() first")
		return

	var program = DataManager.programs[0]

	print("[debug] entries before removal:")
	for e in program.get_sorted_entries():
		print("  order:", e.order, " name:", e.exercise.name)

	DataManager.remove_exercise_from_program(program, 1)

	print("[debug] entries after removing order 1:")
	for e in program.get_sorted_entries():
		print("  order:", e.order, " name:", e.exercise.name)

	print("[debug] supersets remaining: ", program.supersets.size())
	print("[debug] is_valid: ", program.is_valid())


## Prints all loaded programs with their entries and supersets.
func debug_print_programs():
	if DataManager.current_user == null:
		if DataManager.users.is_empty():
			print("[debug:programs] no users in DataManager")
			return
		DataManager.current_user = DataManager.users[0]

	if DataManager.programs.is_empty():
		print("[debug:programs] no programs for user: ", DataManager.current_user.name)
		return

	print("\n=== Programs for user: ", DataManager.current_user.name, " ===")

	for program in DataManager.programs:
		print("\n--- Program: '", program.name, "' (id:", program.id, ") ---")
		print("  Entries: ", program.entries.size(), "  Supersets: ", program.supersets.size())
		print("  is_valid: ", program.is_valid())

		var sorted = program.get_sorted_entries()
		for entry in sorted:
			var type_name = ProgramExerciseEntry.ExerciseType.keys()[entry.exercise_type]
			var in_ss = program.is_in_superset(entry.order)
			print("  [%d] %s | type: %s | superset: %s" % [
				entry.order,
				entry.exercise.name,
				type_name,
				"yes" if in_ss else "no"
			])

		if program.supersets.size() > 0:
			print("  Superset pairs:")
			for pair in program.supersets:
				print("    order %d <-> order %d" % [pair.order_a, pair.order_b])
