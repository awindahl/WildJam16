extends Spatial

func _on_Area_body_entered(body):
	body.pickup(name)
	get_tree().change_scene("res://Overworld.tscn")
	queue_free()