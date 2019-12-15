extends Spatial

func _on_WinBox_body_entered(body):
		get_tree().change_scene("res://Winning Scene.tscn")