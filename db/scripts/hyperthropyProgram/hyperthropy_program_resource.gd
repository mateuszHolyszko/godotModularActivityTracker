extends Resource
class_name HypertrophyProgramResource

@export var id: String
@export var name: String

## Full UserResource reference — serialised as a path, not a copy.
@export var user: UserResource

## Exercise slots. Keep sorted by ProgramExerciseEntry.order.
@export var entries: Array[ProgramExerciseEntry] = []

## Superset pairs referencing .order values from entries above.
@export var supersets: Array[ProgramSuperset] = []


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

## Returns entries sorted by their .order field.
## If debug is true, prints detailed sorting information.
func get_sorted_entries(debug: bool = false) -> Array[ProgramExerciseEntry]:
	if debug:
		print("=== get_sorted_entries called ===")
		print("Total entries count: ", entries.size())
		
		# Print original order
		print("Original entries order:")
		for i in range(entries.size()):
			var entry = entries[i]
			var exercise_name = entry.exercise.name if entry.exercise else "NO EXERCISE"
			print("  Index ", i, ": order=", entry.order, " - ", exercise_name)
	
	var sorted: Array[ProgramExerciseEntry] = entries.duplicate()
	sorted.sort_custom(func(a, b): return a.order < b.order)
	
	if debug:
		# Print sorted order
		print("Sorted entries order:")
		for i in range(sorted.size()):
			var entry = sorted[i]
			var exercise_name = entry.exercise.name if entry.exercise else "NO EXERCISE"
			print("  Position ", i, ": order=", entry.order, " - ", exercise_name)
		
		# Verify sorting worked
		var is_sorted = true
		for i in range(sorted.size() - 1):
			if sorted[i].order > sorted[i+1].order:
				is_sorted = false
				print("  WARNING: Sorting issue detected at position ", i, 
					  " (", sorted[i].order, " > ", sorted[i+1].order, ")")
		
		print("Sorting successful: ", is_sorted)
		print("===============================")
	
	return sorted


## Returns the two ProgramExerciseEntry objects for a superset.
func get_superset_entries(order_a: int, order_b: int) -> Array[ProgramExerciseEntry]:
	var result: Array[ProgramExerciseEntry] = []
	for entry in entries:
		if entry.order == order_a or entry.order == order_b:
			result.append(entry)
		if result.size() == 2:
			break
	return result


## Returns true if the given order index is part of any superset pair.
func is_in_superset(order_index: int) -> bool:
	for pair in supersets:
		if pair.order_a == order_index or pair.order_b == order_index:
			return true
	return false


## Returns true when all superset pairs reference valid adjacent entries.
func is_valid() -> bool:
	var orders: Array[int] = []
	for e in entries:
		orders.append(e.order)

	for pair in supersets:
		if not (pair.order_a in orders and pair.order_b in orders):
			return false
		if abs(pair.order_a - pair.order_b) != 1:
			return false
	return true
