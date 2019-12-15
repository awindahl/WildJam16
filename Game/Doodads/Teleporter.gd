extends Spatial

func _on_Area_body_entered(body):
	match name:
		"Teleporter1":
			print("AA")
		"Teleporter2":
			pass
		"Teleporter3":
			pass