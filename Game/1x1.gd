extends "pawn.gd"

onready var grid_map : GridMap = get_parent()

var value : float
var translate : Transform
var rotate : Transform
var start_transform : Transform
var end_quat : Quat
var SPEED = 2

func _ready():
	set_process(false)
	
func _process(delta):
	value += delta*SPEED
	if value > 1:
		value = 1
	
	rotate = Transform(Quat.IDENTITY.slerp(end_quat, value))
	transform = translate.inverse() * rotate * translate * start_transform

	if value == 1:
		set_process(false)
	
func move(direction : Vector3, pivot_point : Vector3):
	value = 0
	start_transform = transform
	translate = Transform.IDENTITY
	translate.origin = - pivot_point
	print(transform)
	end_quat = Quat(Vector3.UP.cross(direction), deg2rad(90))
	set_process(true)
	return (translate.inverse() * Transform(end_quat) * translate).xform(translation)