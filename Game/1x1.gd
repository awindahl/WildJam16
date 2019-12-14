extends "pawn.gd"

onready var grid_map : GridMap = get_parent()

var value : float
var start : Transform
var end : Transform

var SPEED = 2

func _ready():
	set_process(false)
	
func _process(delta):
	value += delta*SPEED
	
	if value > 1:
		value = 1
	
	transform = start.interpolate_with(end, value)
	
	if value == 1:
		set_process(false)
	
func move(direction : Vector3):
	value = 0
	start = transform
	end = Transform(start.basis.rotated(Vector3.UP.cross(direction), deg2rad(90)), start.origin + direction*grid_map.cell_size)
	set_process(true)
