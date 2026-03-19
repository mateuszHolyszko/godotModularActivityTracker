extends Panel

@onready var label = $Label

func show_notification(text: String, duration: float):
	label.text = text
	modulate.a = 1.0  # fully visible

	# Wait for duration
	await get_tree().create_timer(duration).timeout

	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(self.queue_free)  
