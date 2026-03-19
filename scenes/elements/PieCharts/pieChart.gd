extends Control
class_name PieChart

@onready var PieChartPanel = $Panel/HC/PieChartPanel
@onready var LegendContainer = $Panel/HC/LegendPanel/MC/VboxLegendsContainer
@onready var MarkerContainer = $Panel/HC/PieChartPanel/MarkerContainer  # Node2D for markers
@onready var LineContainer = $Panel/HC/PieChartPanel/LineContainer      # Node2D for lines

# -------------------------------------------------------------------
# Entry class
# -------------------------------------------------------------------
class PieEntry:
	var value: float
	var color: Color
	var label: Label  # Reference to the label in legend
	var marker: Node2D  # Marker at the midpoint
	var label_marker: Node2D  # Marker at the label position
	var muscle_name: String  # Store muscle name for label text

	# calculated each draw
	var start_angle: float
	var end_angle: float
	var mid_angle: float
	var mid_point: Vector2

	func _init(v: float, c: Color = Color(), name: String = ""):
		value = v
		if c == Color():
			color = Color(randf(), randf(), randf())
		else:
			color = c
		muscle_name = name

# -------------------------------------------------------------------
# Chart data
# -------------------------------------------------------------------
var entries: Array[PieEntry] = []
var total_value: float = 0.0
var _redraw_pending: bool = false  # Prevent multiple redraws
var _redraw_queued: bool = false  # Queue redraw for batch operations

# -------------------------------------------------------------------
# Settings
# -------------------------------------------------------------------
@export_range(0,100) var radius_percent: float = 90.0
@export var start_angle: float = -PI / 2
@export var connection_line_width: float = 3.0
@export var show_connections: bool = true
@export var draw_delay_frames: int = 4  # Number of frames to wait for layout

# -------------------------------------------------------------------
# Public draw function - call this to recalculate midpoints and redraw
# -------------------------------------------------------------------
func draw_chart():
	if _redraw_pending:
		_redraw_queued = true
		return
	_redraw_pending = true
	_redraw_queued = false
	
	# Wait for panel to have a valid size
	if PieChartPanel.size == Vector2.ZERO or PieChartPanel.size.x < 10 or PieChartPanel.size.y < 10:
		await get_tree().process_frame
		if PieChartPanel.size == Vector2.ZERO:
			# If still zero, wait more frames
			for i in range(draw_delay_frames):
				await get_tree().process_frame
	
	# Calculate all midpoints
	_calculate_midpoints()
	
	# Redraw the chart
	PieChartPanel.queue_redraw()
	
	# Wait for panel to actually redraw
	for i in range(draw_delay_frames):
		await get_tree().process_frame
	
	# Rebuild legend with updated midpoints
	_rebuild_legend()
	
	# Wait for labels to be added and laid out
	for i in range(draw_delay_frames):
		await get_tree().process_frame
	
	# Draw connection lines
	if show_connections:
		await _draw_connection_lines()
	
	_redraw_pending = false
	
	# If another redraw was queued, do it now
	if _redraw_queued:
		draw_chart()

# -------------------------------------------------------------------
# Calculate midpoints for all entries
# -------------------------------------------------------------------
func _calculate_midpoints():
	if entries.size() == 0:
		return
		
	var panel_size = PieChartPanel.size
	var center = panel_size / 2.0
	var radius = min(panel_size.x, panel_size.y) * (radius_percent / 200.0)
	
	var current_angle = start_angle
	
	for entry in entries:
		var angle_span = (entry.value / total_value) * TAU
		
		entry.start_angle = current_angle
		entry.end_angle = current_angle + angle_span
		entry.mid_angle = (entry.start_angle + entry.end_angle) * 0.5
		
		# midpoint inside slice (for labels later)
		entry.mid_point = center + Vector2(cos(entry.mid_angle), sin(entry.mid_angle)) * (radius * 0.5)
		
		current_angle += angle_span

# -------------------------------------------------------------------
# Legend rebuild
# -------------------------------------------------------------------
func _rebuild_legend():
	for c in LegendContainer.get_children():
		c.queue_free()

	# Sort entries by mid_point.y ascending (top of screen = lower y = first)
	var sorted_entries = entries.duplicate()
	sorted_entries.sort_custom(func(a, b): return a.mid_point.y < b.mid_point.y)

	for entry in sorted_entries:
		var label := Label.new()
		# Use muscle name if available, otherwise use value
		if entry.muscle_name and entry.muscle_name != "":
			label.text = entry.muscle_name + ": " + str(entry.value)
		else:
			label.text = str(entry.value)
		
		# Set minimum height to 20px
		label.custom_minimum_size.y = 20
		
		# Make label font fit the element
		label.autowrap_mode = TextServer.AUTOWRAP_OFF    # Disable word wrapping
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Allow horizontal expansion
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER  # Center vertically
		
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		# Optional: Adjust vertical alignment
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		# Optional: Set font to autoscale (Godot 4.x)
		label.set_autowrap_mode(TextServer.AUTOWRAP_WORD_SMART)
		
		label.modulate = entry.color
		LegendContainer.add_child(label)
		entry.label = label  # Store reference to label

# -------------------------------------------------------------------
# Draw connection lines using markers
# -------------------------------------------------------------------
func _draw_connection_lines():
	# Clear old lines
	for child in LineContainer.get_children():
		child.queue_free()
	
	if not show_connections or entries.size() == 0:
		return
	
	# Create markers
	_create_markers()
	
	# Wait for markers to be added
	for i in range(draw_delay_frames):
		await get_tree().process_frame
	
	# Update label markers
	_update_label_markers()
	
	# Wait for marker positions to update
	await get_tree().process_frame
	
	# Draw lines between markers
	var lines_drawn = 0
	for entry in entries:
		if entry.marker and entry.label_marker:
			var line = Line2D.new()
			line.width = connection_line_width
			line.default_color = entry.color
			line.add_point(entry.marker.position)  # Local to MarkerContainer
			line.add_point(entry.label_marker.position)  # Local to MarkerContainer
			LineContainer.add_child(line)
			lines_drawn += 1
	
	print("PieChart: Drew ", lines_drawn, " connection lines")

# -------------------------------------------------------------------
# Create markers for all entries
# -------------------------------------------------------------------
func _create_markers():
	# Clear old markers
	for child in MarkerContainer.get_children():
		child.queue_free()
	
	for entry in entries:
		if entry.mid_point != Vector2.ZERO:
			# Create marker at midpoint
			var marker = Node2D.new()
			marker.position = entry.mid_point
			MarkerContainer.add_child(marker)
			entry.marker = marker
			
			# Create marker for label (will be positioned later)
			var label_marker = Node2D.new()
			MarkerContainer.add_child(label_marker)
			entry.label_marker = label_marker

# -------------------------------------------------------------------
# Update label markers positions - Points to left side of label
# -------------------------------------------------------------------
func _update_label_markers():
	for entry in entries:
		if entry.label and entry.label_marker and is_instance_valid(entry.label):
			# Get label's global position
			var label_global_rect = entry.label.get_global_rect()
			
			# Point to left side center of label (vertical center, horizontal left)
			var label_global_pos = Vector2(
				label_global_rect.position.x,  # Left side X coordinate
				label_global_rect.position.y + label_global_rect.size.y / 2  # Vertical center
			)
			
			# Convert to MarkerContainer's local coordinates
			var label_local_pos = MarkerContainer.to_local(label_global_pos)
			entry.label_marker.position = label_local_pos

# -------------------------------------------------------------------
# BATCH OPERATIONS - Use these for multiple entries
# -------------------------------------------------------------------

# Clear all entries from the chart
func clear():
	entries.clear()
	total_value = 0.0
	# Don't draw immediately - wait for batch operation

# Add a single entry to the chart (use for individual adds)
func add_entry(value: float, color: Color = Color(), muscle_name: String = ""):
	var e = PieEntry.new(value, color, muscle_name)
	entries.append(e)
	total_value += value
	draw_chart()  # Draw immediately for single adds

# Add multiple entries at once (efficient for bulk adds)
func add_entries(entry_list: Array):
	print("PieChart: Adding ", entry_list.size(), " entries in batch")
	for entry_data in entry_list:
		var value = entry_data[0] if entry_data.size() > 0 else 0
		var color = entry_data[1] if entry_data.size() > 1 else Color()
		var name = entry_data[2] if entry_data.size() > 2 else ""
		var e = PieEntry.new(value, color, name)
		entries.append(e)
		total_value += value
	
	# Draw once after all entries are added
	draw_chart()

# Set multiple entries at once (replaces all existing entries)
func set_entries(new_entries: Array):
	clear()
	for e in new_entries:
		if e is PieEntry:
			entries.append(e)
			total_value += e.value
	draw_chart()

# Remove an entry at a specific index
func remove_entry(index: int):
	if index >= 0 and index < entries.size():
		total_value -= entries[index].value
		entries.remove_at(index)
		draw_chart()

# Update an entry's value at a specific index
func update_entry_value(index: int, new_value: float):
	if index >= 0 and index < entries.size():
		total_value -= entries[index].value
		entries[index].value = new_value
		total_value += new_value
		draw_chart()

# Update an entry's color at a specific index
func update_entry_color(index: int, new_color: Color):
	if index >= 0 and index < entries.size():
		entries[index].color = new_color
		draw_chart()

# Get all current entries
func get_entries() -> Array:
	return entries.duplicate()

# Get total value
func get_total_value() -> float:
	return total_value

# -------------------------------------------------------------------
# Ready function
# -------------------------------------------------------------------
func _ready():
	randomize()
	# Wait multiple frames for the panel to get its size
	for i in range(draw_delay_frames):
		await get_tree().process_frame
