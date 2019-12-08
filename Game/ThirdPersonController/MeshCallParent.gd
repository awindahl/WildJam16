extends Spatial

func _call_parent():
	print("AAA")
	get_parent().get_node("Controller")._jump()