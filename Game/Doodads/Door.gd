extends Spatial

func _on_Area_body_entered(body):
	if Global.keys >= 1:
		Global.keys -= 1
		$AnimationPlayer.play("Open")