extends "pawn.gd"
signal finished_moving
signal failed_moving

onready var grid_map : GridMap = get_parent()
var selected = false setget set_selected, get_selected
onready var mesh_instance = $smallboi
onready var static_body = $smallboi/StaticBody
onready var stone = mesh_instance.get_material_override()
onready var stone_selected = preload("res://Assets/StoneSelected.material")

var value : float
var translate : Transform
var rotate : Transform
var start_transform : Transform
var end_quat : Quat
var SPEED = 2

func _ready():
	connect("failed_moving", grid_map, "on_cube_failed_move")
	static_body.connect("input_event", grid_map, "on_cube_clicked_on")

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
	end_quat = Quat(Vector3.UP.cross(direction), deg2rad(90))
	set_process(true)
	return (translate.inverse() * Transform(end_quat) * translate).xform(translation)

func set_selected(b : bool):
	selected = b
	if selected:
		mesh_instance.set_material_override(stone_selected)
	else:
		mesh_instance.set_material_override(stone)

func get_selected() -> bool:
	return selected

func select_or_deselect():
	set_selected(not selected)
	
func is_selected():
	return selected

func _on_Area_body_entered(body):
	if not body is GridMap and body != static_body:
		emit_signal("failed_moving")

func reverse():
	value = 1 - value
	start_transform = translate.inverse() * Transform(end_quat) * translate * start_transform
	end_quat = end_quat.inverse()
