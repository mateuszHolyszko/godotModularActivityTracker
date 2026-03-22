extends Control
class_name BarChart

# ========================
# CONFIG
# ========================
@export var default_bar_color : Color = Color(0.7, 0.7, 0.7)
@export var zero_bar_alpha := 0.35
@export var show_zero_bars := true

@export var bar_spacing := 10.0
@export var label_height := 20.0
@export var value_height := 16.0
@export var top_padding := 10.0
@export var bottom_padding := 10.0

# ========================
# DATA
# ========================
var data : Dictionary = {}
var max_value : float = 1.0

# ========================
# API
# ========================
func set_data(new_data : Dictionary):
	data = new_data.duplicate()
	_compute_max()
	queue_redraw()

# ========================
# INTERNAL
# ========================
func _compute_max():
	max_value = 1.0
	for v in data.values():
		if v > max_value:
			max_value = v

func _get_bar_color(muscle: String, value: float) -> Color:
	var color : Color

	color = MuscleData.get_color(muscle)

	# Dim zero values
	if value == 0:
		color.a *= zero_bar_alpha

	return color

# ========================
# DRAW
# ========================
func _draw():
	if data.is_empty():
		return

	var keys = data.keys()
	var count = keys.size()

	var total_spacing = bar_spacing * (count + 1)
	var bar_width = (size.x - total_spacing) / count

	var available_height = size.y - label_height - value_height - top_padding - bottom_padding
	var y_base = size.y - label_height - bottom_padding

	var x = bar_spacing

	for key in keys:
		var value = float(data[key])

		if value == 0 and not show_zero_bars:
			x += bar_width + bar_spacing
			continue

		var ratio = value / max_value
		var bar_height = ratio * available_height

		var rect = Rect2(
			Vector2(x, y_base - bar_height),
			Vector2(bar_width, bar_height)
		)

		# 🎯 Color per muscle
		var color = _get_bar_color(key, value)

		draw_rect(rect, color)

		# Value
		draw_string(
			get_theme_default_font(),
			Vector2(x, y_base - bar_height - 4),
			str(int(value)),
			HORIZONTAL_ALIGNMENT_LEFT,
			bar_width,
			value_height
		)

		# Label
		draw_string(
			get_theme_default_font(),
			Vector2(x, size.y - 4),
			str(key),
			HORIZONTAL_ALIGNMENT_LEFT,
			bar_width,
			label_height
		)

		x += bar_width + bar_spacing
