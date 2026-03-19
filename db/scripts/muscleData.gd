extends Node

const MUSCLE_COLORS := {
	"Chest": Color8(255, 102, 102),
	"Back": Color8(255, 178, 102),
	"Quads": Color8(153, 255, 51),
	"Hamstrings": Color8(51, 255, 51),
	"Glutes": Color8(51, 255, 153),
	"Shoulders": Color8(102, 102, 255),
	"Biceps": Color8(102, 255, 255),
	"Triceps": Color8(102, 178, 255),
	"Abs": Color8(178, 102, 255),
	"Calves": Color8(255, 102, 255),
	"Forearms": Color8(255, 102, 178)
}

func get_color(muscle: String) -> Color:
	return MUSCLE_COLORS.get(muscle, Color.WHITE)

func get_all_muscles() -> Array:
	return MUSCLE_COLORS.keys()
