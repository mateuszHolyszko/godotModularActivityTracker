extends Node3D

# Muscle group color mapping
const MUSCLE_COLORS = {
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

# Alternative naming patterns (for special cases)
const ALTERNATIVE_NAMES = {
	"Abductors": "Quads",  # Map Abductors to Quads
	"Hamstring": "Hamstrings",
	"Calf": "Calves",
	"Bicep": "Biceps",
	"Tricep": "Triceps",
	"Forearm": "Forearms",
	"Shoulder": "Shoulders",
	"Glute": "Glutes",
	"Quad": "Quads",
	"Ab": "Abs"
}

func _ready():
	assign_muscle_groups_from_names(self)
	apply_muscle_colors(self)

func assign_muscle_groups_from_names(node: Node):
	"""
	Recursively traverse all children and assign muscle group metadata
	based on the node name.
	"""
	for child in node.get_children():
		if child is MeshInstance3D:
			var muscle_group = determine_muscle_group(child.name)
			
			if muscle_group:
				child.set_meta("muscle_group", muscle_group)
				#print("Assigned ", muscle_group, " to ", child.name)
		
		# Recursively process children
		assign_muscle_groups_from_names(child)

func determine_muscle_group(node_name: String) -> String:
	"""
	Determine muscle group from node name using multiple strategies.
	Returns empty string if no match found.
	"""
	# Strategy 1: Split by underscore and take first part
	var parts = node_name.split("_")
	if parts.size() > 0:
		var potential_group = parts[0]
		
		# Check direct match
		if MUSCLE_COLORS.has(potential_group):
			return potential_group
		
		# Check alternative names
		if ALTERNATIVE_NAMES.has(potential_group):
			return ALTERNATIVE_NAMES[potential_group]
	
	# Strategy 2: Try to find any muscle group name in the node name
	for muscle_group in MUSCLE_COLORS.keys():
		if node_name.find(muscle_group) != -1:
			return muscle_group
	
	# Strategy 3: Check alternative names in the node name
	for alt_name in ALTERNATIVE_NAMES.keys():
		if node_name.find(alt_name) != -1:
			return ALTERNATIVE_NAMES[alt_name]
	
	return ""

func apply_muscle_colors(node: Node):
	"""
	Recursively apply colors to mesh instances that have muscle_group metadata
	"""
	for child in node.get_children():
		if child is MeshInstance3D and child.has_meta("muscle_group"):
			var group = child.get_meta("muscle_group")
			var color = MUSCLE_COLORS.get(group)
			
			if color:
				var mat = StandardMaterial3D.new()
				mat.albedo_color = color
				child.set_surface_override_material(0, mat)
		
		# Recursively process children
		apply_muscle_colors(child)
