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
func get_sorted_entries() -> Array[ProgramExerciseEntry]:
	var sorted: Array[ProgramExerciseEntry] = entries.duplicate()
	sorted.sort_custom(func(a, b): return a.order < b.order)
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
