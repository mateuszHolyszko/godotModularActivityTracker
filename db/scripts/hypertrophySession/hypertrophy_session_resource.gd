extends Resource
class_name HypertrophySessionResource

## The program this session was created from.
@export var program: HypertrophyProgramResource

## Unix timestamps — end is 0 until the session is finished.
@export var timestamp_start: int = 0
@export var timestamp_end: int = 0

## Working copy of the program's exercise slots for this session.
## Each entry's .exercise can be swapped without touching the source program.
@export var entries: Array[ProgramExerciseEntry] = []

## All sets logged during this session across every exercise.
@export var sets: Array[ExerciseSetResource] = []


# ---------------------------------------------------------------------------
# Helpers — session state
# ---------------------------------------------------------------------------

## Duration in seconds. Returns 0 if the session has not ended yet.
func get_duration() -> int:
	if timestamp_end == 0:
		return 0
	return timestamp_end - timestamp_start


## Returns true while the session is still in progress.
func is_active() -> bool:
	return timestamp_start > 0 and timestamp_end == 0


# ---------------------------------------------------------------------------
# Helpers — entries (exercise slots)
# ---------------------------------------------------------------------------

## Returns entries sorted by their .order field.
func get_sorted_entries() -> Array[ProgramExerciseEntry]:
	var sorted: Array[ProgramExerciseEntry] = entries.duplicate()
	sorted.sort_custom(func(a, b): return a.order < b.order)
	return sorted


## Replaces the exercise at the given order slot with a new ExerciseResource.
## Preserves exercise_type unless new_type is supplied.
## Returns false if no entry with that order exists.
func swap_exercise(order_index: int, new_exercise: ExerciseResource,
		new_type: Variant = null) -> bool:
	for entry in entries:
		if entry.order == order_index:
			entry.exercise = new_exercise
			if new_type != null:
				entry.exercise_type = new_type
			return true
	return false


# ---------------------------------------------------------------------------
# Helpers — sets
# ---------------------------------------------------------------------------

## Returns all logged sets for a specific exercise, sorted by set_number.
## If no sets exist yet, returns an array with one empty placeholder set
## (set_number = 1, weight = 0, reps = 0) so the UI always has a row to display.
func get_sets_for_exercise(exercise: ExerciseResource) -> Array[ExerciseSetResource]:
	var result: Array[ExerciseSetResource] = sets.filter(
		func(s): return s.exercise == exercise)

	if result.is_empty():
		var placeholder := ExerciseSetResource.new()
		placeholder.session = self
		placeholder.exercise = exercise
		placeholder.set_number = 1
		return [placeholder]

	result.sort_custom(func(a, b): return a.set_number < b.set_number)
	return result


## Returns how many sets have been logged for a given exercise so far.
func get_set_count_for_exercise(exercise: ExerciseResource) -> int:
	return sets.filter(func(s): return s.exercise == exercise).size()
