extends GridMap

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in get_children():
		var t = world_to_map(node.translation)
		print("setting cube " + str(t))
		set_cell_item(t[0], t[1], t[2], node.type)

func get_cell_pawn(cell : Vector3):
	# By having this function we don't need to keep an array of all of its child objects
	for node in get_children():
		if world_to_map(node.translation) == cell:
			return node

func get_whole_shape(cell : Vector3, visited : Array = []):
	for c in get_neighbours(cell):
		if not c in visited:
			visited.append(c)
			get_whole_shape(c.translation, visited)
			
	if not visited:
		visited.append(get_cell_pawn(world_to_map(cell)))
	return visited
	
func get_neighbours(cell : Vector3):
	var adjacent_directions = [Vector3.LEFT, Vector3.RIGHT, Vector3.UP, Vector3.DOWN, Vector3.FORWARD, Vector3.BACK]
	var neighbours = []
	for d in adjacent_directions:
		var n = world_to_map(cell) + d
		var result = get_cell_item(n[0], n[1], n[2])
		if result != -1:
			neighbours.append(get_cell_pawn(n))
	return neighbours

func move(cells : Array, direction : Vector3):
	var pivot_point = Vector3()
	for c in cells:
		if direction == Vector3.RIGHT:
			pivot_point = max(c.translation.x, pivot_point.x)
			
	

func _input(event):
	handle_interact(event)

func handle_interact(event):
	if Input.is_action_just_pressed("FirstAction"):
		var result_dict = get_object_under_mouse()
		var object = result_dict["collider"]
		if object == self:
			var pos = world_to_map(result_dict["position"])
			var child = get_cell_pawn(pos)
			if child:
				print(get_whole_shape(child.translation))
				
func get_object_under_mouse() -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera()
	var ray_from = camera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * 1000
	var space_state = get_world().direct_space_state
	var selection = space_state.intersect_ray(ray_from, ray_to)
	selection["position"] = selection["position"] + ray_to*0.001
	return selection