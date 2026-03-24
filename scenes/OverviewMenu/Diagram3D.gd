extends Node3D

#"Chest": Color8(255, 102, 102),
@onready var chest1 = $RootNode/Chest_1
@onready var chest2 = $RootNode/Chest_2
@onready var chest3 = $RootNode/Chest_3
#"Back": Color8(255, 178, 102),
@onready var back1 = $RootNode/Back_Lat
@onready var back2 = $RootNode/Back_Romb_1
@onready var back3 = $RootNode/Back_Romb_2
@onready var back4 = $RootNode/Back_Trap
#"Quads": Color8(153, 255, 51),
@onready var quad1 = $RootNode/Quad_1
@onready var quad2 = $RootNode/Quad_2
@onready var quad3 = $RootNode/Quad_3
#@onready var quad4 = $RootNode/Abductors_1
@onready var quad5 = $RootNode/Abductors_2
@onready var quad6 = $RootNode/Abductors_3
#"Hamstrings": Color8(51, 255, 51),
@onready var ham1 = $RootNode/Hamstring_1
@onready var ham2 = $RootNode/Hamstring_2
@onready var ham3 = $RootNode/Hamstring_3
#"Glutes": Color8(51, 255, 153),
@onready var glutes1 = $RootNode/Glutes_1
@onready var glutes2 = $RootNode/Glutes_2
#"Shoulders": Color8(102, 102, 255),
@onready var shoulders1 = $RootNode/Shoulders_1
@onready var shoulders2 = $RootNode/Shoulders_2
#"Biceps": Color8(102, 255, 255),
@onready var biceps1 = $RootNode/Biceps_1
@onready var biceps2 = $RootNode/Biceps_2
@onready var biceps3 = $RootNode/Biceps_3
@onready var biceps4 = $RootNode/Biceps_4
#"Triceps": Color8(102, 178, 255),
@onready var triceps1 = $RootNode/Triceps
#"Abs": Color8(178, 102, 255),
@onready var abs1 = $RootNode/Abs_1
@onready var abs2 = $RootNode/Abs_2
@onready var abs3 = $RootNode/Abs_3
#"Calves": Color8(255, 102, 255),
@onready var calv1 = $RootNode/Calf_1
@onready var calv2 = $RootNode/Calf_2
@onready var calv3 = $RootNode/Calf_3
@onready var calv4 = $RootNode/Calf_4
#"Forearms": Color8(255, 102, 178)
@onready var for1 = $RootNode/Forearms_1
@onready var for2 = $RootNode/Forearms_2
@onready var for3 = $RootNode/Forearms_3
@onready var for4 = $RootNode/Forearms_4
@onready var for5 = $RootNode/Forearms_5
@onready var for6 = $RootNode/Forearms_6
@onready var for8 = $RootNode/Forearms_8
@onready var for7 = $RootNode/Foreamrs_7


func _ready():
	# Set metadata
	#"Chest": Color8(255, 102, 102),
	chest1.set_meta("muscle_group", "Chest")
	chest2.set_meta("muscle_group", "Chest")
	chest3.set_meta("muscle_group", "Chest")
	#"Back": Color8(255, 178, 102),
	back1.set_meta("muscle_group", "Back")
	back2.set_meta("muscle_group", "Back")
	back3.set_meta("muscle_group", "Back")
	back4.set_meta("muscle_group", "Back")
	#"Quads": Color8(153, 255, 51),
	quad1.set_meta("muscle_group", "Quads")
	quad2.set_meta("muscle_group", "Quads")
	quad3.set_meta("muscle_group", "Quads")
	#quad4.set_meta("muscle_group", "Quads")
	quad5.set_meta("muscle_group", "Quads")
	quad6.set_meta("muscle_group", "Quads")
	
	#"Hamstrings": Color8(51, 255, 51),
	ham1.set_meta("muscle_group", "Hamstrings")
	ham2.set_meta("muscle_group", "Hamstrings")
	ham3.set_meta("muscle_group", "Hamstrings")
	#"Glutes": Color8(51, 255, 153),
	glutes1.set_meta("muscle_group", "Glutes")
	glutes2.set_meta("muscle_group", "Glutes")
	#"Shoulders": Color8(102, 102, 255),
	shoulders1.set_meta("muscle_group", "Shoulders")
	shoulders2.set_meta("muscle_group", "Shoulders")
	#"Biceps": Color8(102, 255, 255),
	biceps1.set_meta("muscle_group", "Biceps")
	biceps2.set_meta("muscle_group", "Biceps")
	biceps3.set_meta("muscle_group", "Biceps")
	biceps4.set_meta("muscle_group", "Biceps")
	#"Triceps": Color8(102, 178, 255),
	triceps1.set_meta("muscle_group", "Triceps")
	#"Abs": Color8(178, 102, 255),
	abs1.set_meta("muscle_group", "Abs")
	abs2.set_meta("muscle_group", "Abs")
	abs3.set_meta("muscle_group", "Abs")
	#"Calves": Color8(255, 102, 255),
	calv1.set_meta("muscle_group", "Calves")
	calv2.set_meta("muscle_group", "Calves")
	calv3.set_meta("muscle_group", "Calves")
	calv4.set_meta("muscle_group", "Calves")
	#"Forearms": Color8(255, 102, 178)
	for1.set_meta("muscle_group", "Forearms")
	for2.set_meta("muscle_group", "Forearms")
	for3.set_meta("muscle_group", "Forearms")
	for4.set_meta("muscle_group", "Forearms")
	for5.set_meta("muscle_group", "Forearms")
	for6.set_meta("muscle_group", "Forearms")
	for7.set_meta("muscle_group", "Forearms")
	for8.set_meta("muscle_group", "Forearms")
	
	apply_muscle_colors(self)


func apply_muscle_colors(node):
	for child in node.get_children():
		
		if child is MeshInstance3D and child.has_meta("muscle_group"):
			
			var group = child.get_meta("muscle_group")
			var color = MuscleData.get_color(group)

			var mat = StandardMaterial3D.new()
			mat.albedo_color = color

			child.set_surface_override_material(0, mat)

		apply_muscle_colors(child)
