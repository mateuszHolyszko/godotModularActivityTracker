extends Panel

var overview_menu := Menu.new("overview_menu", "res://scenes/OverviewMenu/overview.tscn")
var user_mesurment_menu := Menu.new("user_mesurment_menu", "res://scenes/OverviewMenu/mesurmentInput.tscn") # this one doesnt get bar since its submenu
var session_menu := Menu.new("session_menu", "res://scenes/SessionMenu/sessionMenu.tscn")
var program_menu := Menu.new("program_menu", "res://scenes/ProgramMenu/programMenu.tscn")
var data_menu := Menu.new("data_menu", "res://scenes/DataMenu/dataMenu.tscn")

@onready var overview_bar: ProgressBar = $MC/VC/OverviewPanel/HC/OverviewBar
@onready var model_3d_bar: ProgressBar = $MC/VC/Models3dPanel/HC/Models3dBar
@onready var session_bar: ProgressBar = $MC/VC/SessionPanel/HC/SessionBar
@onready var program_bar: ProgressBar = $MC/VC/ProgramPanel2/HC/ProgramBar
@onready var data_bar: ProgressBar = $MC/VC/DataPanel/HC/DataBar

func _ready() -> void:
	# Wait for DataManager's ready signal
	#await DataManager.ready_emitted
	
	_setup_menu(overview_menu, overview_bar)
	overview_menu.load_completed.connect(func(_s): _setup_menu(user_mesurment_menu, session_bar))
	user_mesurment_menu.load_completed.connect(func(_s): _setup_3d_registry())
	SceneRegistry3d.load_completed.connect(func(_s): _setup_menu_barless(session_menu))
	session_menu.load_completed.connect(func(_s): _setup_menu(program_menu, program_bar))
	program_menu.load_completed.connect(func(_s): _setup_menu(data_menu, data_bar))
	data_menu.load_completed.connect(func(_s): _after_all_loaded() )

func _setup_menu(menu: Menu, bar: ProgressBar) -> void:
	bar.min_value = 0.0
	bar.max_value = 1.0
	bar.value = 0.0
	menu.load_progress_changed.connect(func(progress: float): bar.value = progress)
	menu.load_completed.connect(func(_scene): bar.value = 1.0)
	MenuManager.register(menu)
	menu.preload_scene()
	
func _setup_menu_barless(menu: Menu) -> void:
	MenuManager.register(menu)
	menu.preload_scene()
	
func _setup_3d_registry() -> void:
	model_3d_bar.min_value = 0.0
	model_3d_bar.max_value = 1.0
	model_3d_bar.value = 0.0

	SceneRegistry3d.load_progress_changed.connect(
		func(progress: float): model_3d_bar.value = progress
	)

	SceneRegistry3d.load_completed.connect(
		func(_scenes): model_3d_bar.value = 1.0
	)

	SceneRegistry3d.load_failed.connect(
		func(path): push_error("3D scene failed: %s" % path)
	)

	SceneRegistry3d.preload_scenes()
	
func _after_all_loaded() ->void:
	# Anable nav bar
	MenuManager.toggle_nav_buttons_disable(false)
	


