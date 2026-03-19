extends Resource
class_name ExerciseResource

enum TensionProfile { CONCENTRIC, ECCENTRIC, ISOMETRIC }
enum Intensity { EASY, MEDIUM, HARD }

@export var id: String
@export var name: String

## Must be one of the keys from MuscleData.MUSCLE_COLORS
@export var target_muscle: String

@export var bodyweight: bool = false
@export var isolation: bool = false

@export var tension_profile: TensionProfile = TensionProfile.CONCENTRIC
@export var intensity: Intensity = Intensity.MEDIUM

## [rep_range_min, rep_range_max]
@export var rep_range: Vector2i = Vector2i(8, 12)
