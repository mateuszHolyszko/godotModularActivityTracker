extends Node3D

@onready var camera = $"../Camera3D"
@onready var cam_top = $"../CameraTop"
@onready var cam_bottom = $"../CameraBottom"
@onready var model = $Model

var timer := 0.0
var switch_time := 5.0
var top_view := true

func _process(delta):

	# spin the origin not the model
	rotate_y(delta * 0.5)

	timer += delta

	if timer > switch_time:
		timer = 0
		switch_view()


func switch_view():

	if top_view:
		move_camera(cam_bottom)
	else:
		move_camera(cam_top)

	top_view = !top_view


func move_camera(target: Node3D):

	camera.global_transform = target.global_transform
