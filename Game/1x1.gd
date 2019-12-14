extends "pawn.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var grid_map : GridMap = get_parent()
# Called when the node enters the scene tree for the first time.
var value = 0.0
var t_value = 0.0
var SPEED = 1
onready var start = transform
onready var end = transform.origin + Vector3.RIGHT*10
func _process(delta):
	var t = transform

	# Rotation
	var lookDir = Vector3(0,0,0)
	var rotTransform = t.looking_at(lookDir,Vector3(0,1,0))
	var thisRotation = Quat(start.basis).slerp(rotTransform.basis, value)
	
	# Translation
	t.origin = start.origin.linear_interpolate(end, value)
	value += delta*SPEED

	if value > 1:
		value = 1
	set_transform(Transform(thisRotation, t.origin))