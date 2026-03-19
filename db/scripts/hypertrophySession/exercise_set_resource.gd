extends Resource
class_name ExerciseSetResource

## The session this set belongs to.
@export var session: HypertrophySessionResource

## The exercise that was performed (mirrors the entry at log time,
## but stored directly so the set is self-contained even if the entry is later swapped).
@export var exercise: ExerciseResource

## 1-based index within this exercise's sets for this session (1, 2, 3 …).
@export var set_number: int = 1

@export var weight: float = 0.0
@export var reps: int = 0

## Unix timestamp of when this set was logged.
@export var timestamp: int = 0
