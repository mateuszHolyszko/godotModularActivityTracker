extends Resource
class_name ProgramExerciseEntry

enum ExerciseType { STRAIGHT_SET, DROP_SET, MYO_SET }

## Position in the program (0-based).
@export var order: int = 0

@export var exercise_type: ExerciseType = ExerciseType.STRAIGHT_SET

## Reference to the global ExerciseResource.
@export var exercise: ExerciseResource
