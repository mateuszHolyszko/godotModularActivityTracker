@tool
class_name Plotter2D
extends Control


@export var bottom_padding: float = 30.0
@export var tick_count: int = 6


class PlotLine:
	var timestamps: PackedFloat64Array = PackedFloat64Array()
	var y_points: PackedFloat64Array = PackedFloat64Array()

	var label: String = ""
	var color: Color = Color.WHITE
	var line_width: float = 2.0

	var y_min: float = 0.0
	var y_max: float = 1.0


var plot_lines: Array[PlotLine] = []


func _ready():
	queue_redraw()


func add_plot_line(timestamps: PackedFloat64Array, values: PackedFloat64Array, color: Color = Color.WHITE, label: String = ""):
	if timestamps.size() != values.size():
		push_error("Plotter2D: timestamps and values size mismatch")
		return

	var p := PlotLine.new()
	p.timestamps = timestamps
	p.y_points = values
	p.color = color
	p.label = label

	_compute_y_range(p)

	plot_lines.append(p)

	queue_redraw()


func clear():
	plot_lines.clear()
	queue_redraw()


func _compute_y_range(p: PlotLine):

	if p.y_points.is_empty():
		p.y_min = 0
		p.y_max = 1
		return

	var min_val := INF
	var max_val := -INF

	for v in p.y_points:
		if v < min_val:
			min_val = v
		if v > max_val:
			max_val = v

	if min_val < 0:
		min_val = 0

	if max_val == min_val:
		max_val += 1

	p.y_min = min_val
	p.y_max = max_val


func _get_global_time_range() -> Vector2:

	var min_time := INF
	var max_time := -INF

	for p in plot_lines:
		for t in p.timestamps:
			if t < min_time:
				min_time = t
			if t > max_time:
				max_time = t

	if min_time == INF:
		return Vector2(0, 1)

	if max_time == min_time:
		max_time += 1

	return Vector2(min_time, max_time)


func _draw():

	if plot_lines.is_empty():
		return

	var rect := get_rect()

	var width: float = rect.size.x
	var height: float = rect.size.y - bottom_padding

	var time_range := _get_global_time_range()
	var t_min := time_range.x
	var t_max := time_range.y
	var t_span := t_max - t_min

	# DRAW PLOT LINES
	for p in plot_lines:

		if p.timestamps.size() < 2:
			continue

		var y_span := p.y_max - p.y_min

		for i in range(p.timestamps.size() - 1):

			var t1 := p.timestamps[i]
			var t2 := p.timestamps[i + 1]

			var y1 := p.y_points[i]
			var y2 := p.y_points[i + 1]

			var x1 := (t1 - t_min) / t_span * width
			var x2 := (t2 - t_min) / t_span * width

			var py1 := height - ((y1 - p.y_min) / y_span * height)
			var py2 := height - ((y2 - p.y_min) / y_span * height)

			draw_line(Vector2(x1, py1), Vector2(x2, py2), p.color, p.line_width)

			# ---- DRAW VALUE LABEL NEAR POINT ----
			var value_label := "%.2f" % y1
			var font := get_theme_default_font()
			var font_size := 14

			var text_size := font.get_string_size(value_label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)

			var label_pos := Vector2(
				x1 + 4,
				py1 - 4
			)

			draw_string(
				font,
				label_pos,
				value_label,
				HORIZONTAL_ALIGNMENT_LEFT,
				-1,
				font_size,
				p.color
			)

	# DRAW X AXIS
	var axis_y := height
	draw_line(Vector2(0, axis_y), Vector2(width, axis_y), Color.GRAY, 2)

	# DRAW TICKS
	var font := get_theme_default_font()
	var font_size := 16

	for i in range(tick_count):

		var ratio: float = float(i) / float(tick_count - 1)
		var timestamp: float = lerp(t_min, t_max, ratio)
		var x: float = ratio * width

		draw_line(Vector2(x, axis_y), Vector2(x, axis_y + 6), Color.GRAY, 2)

		var dt := Time.get_datetime_dict_from_unix_time(int(timestamp))

		var labelDayMonth := "%02d-%02d" % [
			dt.day,
			dt.month,
		]
		var labelYear := "%04d" % [
			dt.year
		]

		var size1 := font.get_string_size(labelDayMonth, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var size2 := font.get_string_size(labelYear, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)

		draw_string(
			font,
			Vector2(x - size1.x / 2, axis_y + 18),
			labelDayMonth,
			HORIZONTAL_ALIGNMENT_CENTER,
			-1,
			font_size
		)
		draw_string(
			font,
			Vector2(x - size2.x / 2, axis_y + 32),
			labelYear,
			HORIZONTAL_ALIGNMENT_CENTER,
			-1,
			font_size
		)
