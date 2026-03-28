# MainControl.gd
extends Control

@onready var content = $CurrentSceneContent
@onready var popup_panel = $PopupPanel
@onready var userSelectButton = $NavBar/HBoxContainer/UserSelect/VC/UserButton
@onready var navBar = $NavBar

var user_popup_scene = preload("res://scenes/mainMenu/UserPopup.tscn")
var init_menu := Menu.new("init_menu", "res://scenes/InitMenu/initMenu.tscn")

@onready var focus_light = $FocusLight2D
@onready var center_light = $CenterLight2D
@onready var canvas_modulate = $CanvasModulate
var current_focus: Control = null

func _ready():	
	# Set the main control reference in MenuManager
	MenuManager.set_main_control(content)
	MenuManager.set_nav_bar(navBar)
	MenuManager.set_transition_rect($MenuTransitionLayer/TransitionRect)
	
	# Setting stuff (TODO move it to SettingsGlobal)
	var resolution = SettingsGlobal.get_resolution()
	DisplayServer.window_set_size(resolution)
	Engine.max_fps = SettingsGlobal.get_max_frames()
	focus_light.enabled = SettingsGlobal.get_focus_light_enabled()
	center_light.visible = SettingsGlobal.get_center_light_enabled()
	canvas_modulate.visible = SettingsGlobal.get_center_light_enabled()

	# After init is loaded set to init menu
	init_menu.load_completed.connect(func(_scene): MenuManager.change_menu("init_menu"))
	init_menu.preload_scene()

	MenuManager.register(init_menu)
	
	#run_debug()
	#print("current user: ", DataManager.current_user)
	
	# For tracking current focus
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	
	# Disable nav bar, enable it in init menu after all navbar menus are preloaded
	MenuManager.toggle_nav_buttons_disable(true)

func run_debug():
	var debug_script = load("res://db/scripts/debug.gd")
	var debug_instance = debug_script.new()
	add_child(debug_instance)

func _on_user_button_pressed():
	# Remove existing popup if present
	for child in popup_panel.get_children():
		child.queue_free()

	# Instantiate popup
	var popup = user_popup_scene.instantiate()

	# Make it fill the panel
	popup.anchor_left = 0
	popup.anchor_top = 0
	popup.anchor_right = 1
	popup.anchor_bottom = 1
	popup.offset_left = 0
	popup.offset_top = 0
	popup.offset_right = 0
	popup.offset_bottom = 0
	
	# CONNECT SIGNAL
	popup.popup_closed.connect(_on_popup_closed)
	popup.user_selected.connect(_on_user_selected)
	
	popup_panel.add_child(popup)

	popup_panel.visible = true

func _on_popup_closed():
	for child in popup_panel.get_children():
		child.queue_free()
	popup_panel.visible = false
	userSelectButton.grab_focus() # return focus to button

func _on_user_selected(user: UserResource):
	DataManager.current_user = user
	userSelectButton.text=user.name
	print("Selected user:", user.name)	
	
func _on_focus_changed(node):
	current_focus = node
	if focus_light:
		focus_light.set_focus(node)
