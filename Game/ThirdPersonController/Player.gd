extends KinematicBody

var keys = 0

func pickup(value):
	match value:
		"Key":
			Global.keys += 1
			print(keys)
		_:
			pass