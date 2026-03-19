extends Resource
class_name ExerciseListResource

## Thin wrapper so the exercises array can be saved as a single .tres file.
@export var items: Array[ExerciseResource] = []
