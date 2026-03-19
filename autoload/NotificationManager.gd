extends Node

signal notification_requested(text: String, duration: float)

func notify(text: String, duration: float = 3.0):
	notification_requested.emit(text, duration)
