extends GridMap

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in get_children():
		var t = world_to_map(node.translation)
		print("setting cube " + str(node.translation))
		set_cell_item(t[0], t[1], t[2], node.type)

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
#	for c in cells:
#		var t = world_to_map(c.translation)
#		var new_pos = t + direction
#		set_cell_item(t[0], t[1], t[2], -1)
#		set_cell_item(new_pos[0], new_pos[1], new_pos[2], c.type)
#		c.move(direction)

	var a = Vector3.DOWN.cross(direction)
	
	for c in cells:
		var pivot_point
		for d in cells:
			if d.translation[1] != 1:
				continue
			
			if not pivot_point:
				pivot_point = d.translation
			else:
				if d.translation.dot(direction) > pivot_point.dot(direction):
					pivot_point = d.translation
		
		if not pivot_point:
			continue
		
		if direction == Vector3.FORWARD or direction == Vector3.BACK:
			pivot_point[0] = c.translation[0]
		if direction == Vector3.LEFT or direction == Vector3.RIGHT:
			pivot_point[2] = c.translation[2]
		if direction == Vector3.DOWN or direction == Vector3.UP:
			print("down or up is unsupported")
			
		pivot_point = pivot_point + direction*cell_size/2 + Vector3.DOWN*cell_size/2
		
		var t = c.translation
		var old_pos = world_to_map(t)
		var world_pos = (t - pivot_point).cross(a) + pivot_point
		var new_pos = world_to_map(world_pos)

		set_cell_item(old_pos[0], old_pos[1], old_pos[2], -1)
		set_cell_item(new_pos[0], new_pos[1], new_pos[2], c.type)
		c.move(direction, world_pos)
		


func _input(event):
	handle_interact(event)

func handle_interact(event):
	if Input.is_action_just_pressed("FirstAction"):
		var result_dict = get_object_under_mouse()
		var object = result_dict["collider"] if result_dict.has("collider") else null
		if object == self:
			var pos = world_to_map(result_dict["position"])
			var child = get_cell_pawn(pos)
			if child:
				child.select_or_deselect()
	elif Input.is_action_pressed("Forward"):
		for child in get_children():
			if child.is_selected():
				var whole_shape = get_whole_shape(child.translation)
				move_whole_shape(whole_shape, Vector3.FORWARD)
	elif Input.is_action_pressed("Down"):
		for child in get_children():
			if child.is_selected():
				var whole_shape = get_whole_shape(child.translation)
				move_whole_shape(whole_shape, Vector3.BACK)
	elif Input.is_action_pressed("Left"):
		for child in get_children():
			if child.is_selected():
				var whole_shape = get_whole_shape(child.translation)
				move_whole_shape(whole_shape, Vector3.LEFT)
	elif Input.is_action_pressed("Right"):
		for child in get_children():
			if child.is_selected():
				var whole_shape = get_whole_shape(child.translation)
				move_whole_shape(whole_shape, Vector3.RIGHT)
			
				
func get_object_under_mouse() -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera()
	var ray_from = camera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * 1000
	var space_state = get_world().direct_space_state
	var selection = space_state.intersect_ray(ray_from, ray_to)
	if selection:
		selection["position"] = selection["position"] + (ray_to-ray_from)*0.0001
	print(selection)
	return selection