extends Panel
class_name CustomDialog

signal confirmed
signal canceled

@onready var title_label = $VBoxContainer/TitleLabel
@onready var message_label = $VBoxContainer/MessageLabel
@onready var confirm_button = $VBoxContainer/HBoxContainer/ConfirmButton
@onready var cancel_button = $VBoxContainer/HBoxContainer/CancelButton

var dialog_title: String = ""
var dialog_message: String = ""

func _ready():
	# Connect buttons
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	
	# Update labels
	title_label.text = dialog_title
	message_label.text = dialog_message
	
	# Set initial visibility
	hide()

func show_dialog(title: String, message: String):
	dialog_title = title
	dialog_message = message
	
	if title_label:
		title_label.text = dialog_title
	if message_label:
		message_label.text = dialog_message
	
	show()
	# Center on screen
	position = (get_viewport_rect().size - size) / 2

func _on_confirm_pressed():
	confirmed.emit()
	hide()

func _on_cancel_pressed():
	canceled.emit()
	hide()

func close():
	hide()
