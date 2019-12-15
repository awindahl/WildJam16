extends Spatial

func _on_Area_body_entered(body):
	match name:
		"Teleporter1":
			get_tree().change_scene("res://Levels/Level1.tscn")
		"Teleporter2":
			get_tree().change_scene("res://Levels/Level2.tscn")
		"Teleporter3":
			get_tree().change_scene("res://Levels/Level3.tscn")
		