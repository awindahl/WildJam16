extends Timer

onready var label : Label = $MyLabel

func _on_Timer_timeout():
	get_tree().change_scene("res://Overworld.tscn")

func _process(delta):
	label.text = "Time left: " + str(time_left).substr(0, 4)