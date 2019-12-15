extends "pawn.gd"
signal finished_moving

onready var grid_map : GridMap = get_parent()
onready var selected = false
onready var mesh_instance = $smallboi

var stone = preload("res://Assets/stone.material")
var stone_selected = preload("res://Assets/StoneSelected.material")

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
		emit_signal("finished_moving")
	
func move(direction : Vector3, pivot_point : Vector3):
	value = 0
	start_transform = transform
	translate = Transform.IDENTITY
	translate.origin = - pivot_point
	print(transform)
	end_quat = Quat(Vector3.UP.cross(direction), deg2rad(90))
	set_process(true)
	return (translate.inverse() * Transform(end_quat) * translate).xform(translation)

func select_or_deselect():
	if selected:
		mesh_instance.set_material_override(stone)
	else:
		mesh_instance.set_material_override(stone_selected)
		
	selected = not selected
	
func is_selected():
	return selected
