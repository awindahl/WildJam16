extends "pawn.gd"

onready var grid_map : GridMap = get_parent()
onready var selected = false
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
	
func move(direction : Vector3, world_pos : Vector3):
	value = 0
	start = transform
	end = Transform(start.basis.rotated(Vector3.UP.cross(direction), deg2rad(90)), world_pos)
	set_process(true)

func select_or_deselect():
	selected = not selected
	
func is_selected():
	return selected