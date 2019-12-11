extends Spatial

func _on_Area_body_entered(body):
	if body.keys >= 1:
		body.keys -= 1
		$AnimationPlayer.play("Open")