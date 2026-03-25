extends Node3D

@export var camera_node: Camera3D
@export var shot_a: Node3D
@export var shot_b: Node3D
@export var focus_point: Node3D
@export var wait_time: float = 2.0
@export var travel_time: float = 3.0
@export var arc_radius: float = 1.5  # Radius of the arc (how wide the curve is)

enum CameraState { WAITING, MOVING }
var current_state: CameraState = CameraState.WAITING
var current_target: Node3D = null
var elapsed_time: float = 0.0
var start_position: Vector3
var start_rotation: Basis
var arc_center: Vector3
var arc_start: Vector3
var arc_end: Vector3

func _ready():
	# Validate nodes
	if not camera_node or not shot_a or not shot_b or not focus_point:
		push_error("Missing required nodes! Please assign all nodes in the inspector.")
		return
	
	# Start at ShotA
	current_target = shot_a
	camera_node.global_transform = shot_a.global_transform
	# Ensure camera looks at focus point
	look_at_focus()
	
	# Start the sequence
	start_sequence()

func start_sequence():
	# Wait at ShotA
	current_state = CameraState.WAITING
	await get_tree().create_timer(wait_time).timeout
	move_to_shot_b()

func move_to_shot_b():
	current_state = CameraState.MOVING
	elapsed_time = 0.0
	
	# Set up arc parameters (horizontal arc on XZ plane, Y stays constant)
	arc_start = shot_a.global_position
	arc_end = shot_b.global_position
	
	# Keep Y coordinate the same (average of start and end)
	var avg_y = (arc_start.y + arc_end.y) / 2.0
	
	# Calculate center point for circular arc on XZ plane
	var start_xz = Vector2(arc_start.x, arc_start.z)
	var end_xz = Vector2(arc_end.x, arc_end.z)
	var mid_xz = (start_xz + end_xz) / 2.0
	var direction_xz = (end_xz - start_xz).normalized()
	var perpendicular_xz = Vector2(-direction_xz.y, direction_xz.x)  # Perpendicular vector
	
	# Calculate arc center (perpendicular offset from midpoint)
	var center_xz = mid_xz + perpendicular_xz * arc_radius
	
	# Store arc center in 3D (with constant Y)
	arc_center = Vector3(center_xz.x, avg_y, center_xz.y)
	
	# Store start position and rotation
	start_position = camera_node.global_position
	start_rotation = camera_node.global_transform.basis

func move_to_shot_a():
	current_state = CameraState.MOVING
	elapsed_time = 0.0
	
	# Set up arc parameters (reversed direction)
	arc_start = shot_b.global_position
	arc_end = shot_a.global_position
	
	# Keep Y coordinate the same (average of start and end)
	var avg_y = (arc_start.y + arc_end.y) / 2.0
	
	# Calculate center point for circular arc on XZ plane
	var start_xz = Vector2(arc_start.x, arc_start.z)
	var end_xz = Vector2(arc_end.x, arc_end.z)
	var mid_xz = (start_xz + end_xz) / 2.0
	var direction_xz = (end_xz - start_xz).normalized()
	var perpendicular_xz = Vector2(-direction_xz.y, direction_xz.x)  # Perpendicular vector
	
	# Calculate arc center (perpendicular offset from midpoint)
	var center_xz = mid_xz + perpendicular_xz * arc_radius
	
	# Store arc center in 3D (with constant Y)
	arc_center = Vector3(center_xz.x, avg_y, center_xz.y)
	
	# Store start position and rotation
	start_position = camera_node.global_position
	start_rotation = camera_node.global_transform.basis

func get_arc_position(t: float) -> Vector3:
	# t goes from 0 to 1
	# Calculate vectors from center to start and end points on XZ plane
	var start_vec_xz = Vector2(arc_start.x - arc_center.x, arc_start.z - arc_center.z)
	var end_vec_xz = Vector2(arc_end.x - arc_center.x, arc_end.z - arc_center.z)
	
	# Calculate angles
	var start_angle = atan2(start_vec_xz.y, start_vec_xz.x)
	var end_angle = atan2(end_vec_xz.y, end_vec_xz.x)
	
	# Calculate angle difference (shortest path)
	var angle_diff = end_angle - start_angle
	
	# Normalize angle difference to be between -PI and PI
	if angle_diff > PI:
		angle_diff -= 2 * PI
	elif angle_diff < -PI:
		angle_diff += 2 * PI
	
	# Interpolate angle
	var current_angle = start_angle + angle_diff * t
	
	# Calculate radius
	var radius = start_vec_xz.length()
	
	# Calculate position on XZ plane
	var direction = Vector2(cos(current_angle), sin(current_angle))
	var pos_x = arc_center.x + direction.x * radius
	var pos_z = arc_center.z + direction.y * radius
	
	# Return position with constant Y (from arc_center)
	return Vector3(pos_x, arc_center.y, pos_z)

func _process(delta):
	if current_state == CameraState.MOVING:
		elapsed_time += delta
		var t = elapsed_time / travel_time
		
		if t >= 1.0:
			# Snap to final position
			camera_node.global_position = arc_end
			look_at_focus()
			current_state = CameraState.WAITING
			
			# Start next movement after wait time
			if current_target == shot_a:
				current_target = shot_b
				await get_tree().create_timer(wait_time).timeout
				move_to_shot_a()
			else:
				current_target = shot_a
				await get_tree().create_timer(wait_time).timeout
				move_to_shot_b()
		else:
			# Use easing for smoother movement
			var eased_t = ease_in_out_cubic(t)
			
			# Get position on arc
			var new_position = get_arc_position(eased_t)
			camera_node.global_position = new_position
			
			# Always look at focus point
			look_at_focus()

func look_at_focus():
	if camera_node and focus_point:
		camera_node.look_at(focus_point.global_position, Vector3.UP)

func ease_in_out_cubic(t: float) -> float:
	if t < 0.5:
		return 4 * t * t * t
	else:
		var f = (2 * t - 2)
		return 0.5 * f * f * f + 1
