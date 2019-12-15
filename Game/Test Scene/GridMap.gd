extends GridMap
signal finished_moving_shape

onready var shape_moving = false
onready var shape_reversing = false

var input_translation = {
	"Forward" : Vector3.FORWARD, 
	"Down" : Vector3.BACK, 
	"Left" : Vector3.LEFT, 
	"Right" : Vector3.RIGHT}

func _ready():
	for node in get_children():
		var t = world_to_map(node.translation)
		print("setting cube " + str(node.translation))
		set_cell_item(t[0], t[1], t[2], node.type)

func is_anything_selected() -> bool:
	return get_selected_children().size() > 0

func get_cell_pawn(cell : Vector3):
	# By having this function we don't need to keep an array of all of its child objects
	for node in get_children():
		if world_to_map(node.translation) == cell:
			return node

func get_whole_shape(cell : Vector3, visited : Array = []):
	for c in get_neighbours(cell):
		if not c in visited and c != null:
			visited.append(c)
			get_whole_shape(c.translation, visited)
			
	if not visited:
		visited.append(get_cell_pawn(world_to_map(cell)))
	return visited
	
func get_neighbours(cell_translation : Vector3):
	var adjacent_directions = [Vector3.LEFT, Vector3.RIGHT, Vector3.UP, Vector3.DOWN, Vector3.FORWARD, Vector3.BACK]
	var neighbours = []
	for d in adjacent_directions:
		var n = world_to_map(cell_translation) + d
		var result = get_cell_item(n[0], n[1], n[2])
		if result != -1:
			neighbours.append(get_cell_pawn(n))
	return neighbours

func move_whole_shape(cells : Array, direction : Vector3):
	var pivot_point
	for d in cells:
		if d.translation[1] != 1:
			continue
		if not pivot_point:
			pivot_point = d.translation
		else:
			if d.translation.dot(direction) > pivot_point.dot(direction):
				pivot_point = d.translation

	if pivot_point:
		pivot_point = pivot_point + direction*cell_size/2 + Vector3.DOWN*cell_size/2
	else:
		return
		
	var new_pos_dict = Dictionary()
	var old_pos_dict = Dictionary()
	shape_reversing = false
	for c in cells:
		var t = c.translation
		var old_pos = world_to_map(t)
		var new_t = c.move(direction, pivot_point)
		var new_pos = world_to_map(new_t)
		new_pos_dict[c] = new_pos
		old_pos_dict[c] = old_pos
		
		if c == cells[-1]:
			yield(c, "finished_moving")
	
	if not shape_reversing:
		for c in cells:
			var old_pos = old_pos_dict.get(c)
			var new_pos = new_pos_dict.get(c)
			set_cell_item(old_pos[0], old_pos[1], old_pos[2], -1)
			set_cell_item(new_pos[0], new_pos[1], new_pos[2], c.type)

		
	for c in get_whole_shape(cells[0].translation):
		c.set_selected(true)

func get_selected_children() -> Array:
	var a = Array()
	for c in get_children():
		if c.is_selected():
			a.append(c)
	return a

func _input(event):
	handle_interact(event)

func handle_interact(event):
	if Input.is_action_just_pressed("FirstAction"):
		var selected_children = get_selected_children()
		for c in selected_children:
			c.selected = false
		var result_dict = get_object_under_mouse()
		var object = result_dict["collider"] if result_dict.has("collider") else null
		if not shape_moving and object.get_parent().get_parent() in get_children():
			var whole_shape = get_whole_shape(result_dict["position"])
			for child in whole_shape:
				if child and child.has_method("select_or_deselect"):
					child.select_or_deselect()

	for key in input_translation:
		check_box_moves(key)

func check_box_moves(key):
	if Input.is_action_pressed(key) and not shape_moving:
		var selected_children = get_selected_children()
		if not selected_children:
			return
		shape_moving = true
		move_whole_shape(selected_children, input_translation[key])
		shape_moving = false

func get_object_under_mouse() -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera()
	var ray_from = camera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * 1000
	var space_state = get_world().direct_space_state
	var selection = space_state.intersect_ray(ray_from, ray_to)
	if selection:
		selection["position"] = selection["position"] + (ray_to-ray_from)*0.0001
	return selection

func on_cube_failed_move():
	if not shape_reversing:
		shape_reversing = true
		for c in get_selected_children():
			c.reverse()
