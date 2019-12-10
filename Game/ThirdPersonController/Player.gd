extends KinematicBody

var keys = 0

func pickup(value):
	match value:
		"Key":
			keys += 1
			print(keys)
		_:
			pass