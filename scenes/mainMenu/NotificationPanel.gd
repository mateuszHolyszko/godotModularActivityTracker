extends VBoxContainer

@export var notification_scene: PackedScene

@export var max_notifications: int = 5  # limit queue

func _ready():
	NotificationManager.notification_requested.connect(_on_notification)

func _on_notification(text: String, duration: float):
	# Limit number of notifications
	if get_child_count() >= max_notifications:
		get_child(0).queue_free()

	# Instantiate notification
	var n = notification_scene.instantiate()
	add_child(n)
	n.show_notification(text, duration)
