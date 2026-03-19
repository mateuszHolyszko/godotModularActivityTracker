extends Panel
@onready var plot = $MarginContainer/plot

# Called when the node enters the scene tree for the first time.
func _ready():

	var times := PackedFloat64Array()
	var values1 := PackedFloat64Array()
	var values2 := PackedFloat64Array()

	for i in range(20):
		times.append(Time.get_unix_time_from_system() + i * 60)
		values1.append(randf() * 10.0)
		values2.append(randf() * 7.0)

	plot.add_plot_line(times, values1, Color.INDIAN_RED, "Test1")
	plot.add_plot_line(times, values2, Color.SKY_BLUE, "Test2")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
