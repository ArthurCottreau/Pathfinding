class_name Pathfinding

var size: Vector2i
var grid_array: Array[PathNode]

func initialize_path_grid(arg_size: Vector2i) -> void:
	size = arg_size
	for i in range(size.x * size.y):
		var pos_x: int = i % size.x
		var pos_y: int = floor(float(i) / size.x);
		var pos: Vector2i = Vector2i(pos_x,pos_y)
		grid_array.append(PathNode.new(pos))

func get_grid() -> Array[PathNode]:
	return grid_array

func get_path(cell_start: Vector2i, cell_target: Vector2i) -> Array[PathNode]:
	var start_node: PathNode = grid_array[cell_start.x + cell_start.y * size.x]
	var end_node: PathNode = grid_array[cell_target.x + cell_target.y * size.x]
	
	var open_list: Array[PathNode] = [start_node]
	var closed_list: Array[PathNode] = []
	
	for i in range(size.x * size.y):
		var grid_pos: Vector2i = grid_array[i].pos
		var cell_node: PathNode = grid_array[grid_pos.x + grid_pos.y * size.x]
		cell_node.g_cost = 4294967295
		cell_node.calculate_f_cost()
		cell_node.cameFrom = null
	
	start_node.g_cost = 0
	start_node.h_cost = _calculate_dist_cost(start_node, end_node)
	start_node.calculate_f_cost()
	
	while (open_list.size() > 0):
		var curr_node: PathNode = _get_lowest_cost(open_list)
		
		if curr_node == end_node:
			return _calculate_path(end_node)
		
		open_list.erase(curr_node)
		closed_list.append(curr_node)
	
		for neighboor in get_neighbor_nodes(curr_node):
			if closed_list.has(neighboor): continue
			if not neighboor.is_walkable:
				closed_list.append(neighboor)
				continue
			
			var dist_cost: int = _calculate_dist_cost(curr_node, neighboor) * neighboor.weight
			var tent_g_cost: int = curr_node.g_cost + dist_cost
			if tent_g_cost >= neighboor.g_cost: continue
			
			neighboor.cameFrom = curr_node
			neighboor.g_cost = tent_g_cost
			neighboor.h_cost = _calculate_dist_cost(neighboor, end_node)
			neighboor.calculate_f_cost()
		
			if not open_list.has(neighboor):
				open_list.append(neighboor)
	
	return []

func _get_node(pos: Vector2i) -> PathNode:
	return grid_array[pos.x + pos.y * size.x]

func get_neighbor_nodes(curr_node: PathNode) -> Array[PathNode]:
	var neighbor_nodes: Array[PathNode]
	if curr_node.pos.x - 1 >= 0:
		neighbor_nodes.append(_get_node(curr_node.pos + Vector2i.LEFT))
	if curr_node.pos.x + 1 < size.x:
		neighbor_nodes.append(_get_node(curr_node.pos + Vector2i.RIGHT))
	if curr_node.pos.y - 1 >= 0:
		neighbor_nodes.append(_get_node(curr_node.pos + Vector2i.UP))
	if curr_node.pos.y + 1 < size.y:
		neighbor_nodes.append(_get_node(curr_node.pos + Vector2i.DOWN))
	return neighbor_nodes

func _calculate_path(cell_target: PathNode) -> Array[PathNode]:
	var path: Array[PathNode]
	path.append(cell_target)
	
	var curr_node: PathNode = cell_target
	while curr_node.cameFrom != null:
		path.append(curr_node.cameFrom)
		curr_node = curr_node.cameFrom
	
	path.reverse()
	return path

func _calculate_dist_cost(cell_start: PathNode, cell_target: PathNode) -> int:
	var x_dist: int = abs(cell_start.pos.x - cell_target.pos.x)
	var y_dist: int = abs(cell_start.pos.y - cell_target.pos.y)
	var rem: int = abs(x_dist - y_dist)
	return rem

func _get_lowest_cost(node_list: Array[PathNode]) -> PathNode:
	var lowest_cost: PathNode = node_list[0]
	for i in node_list.size():
		if node_list[i].f_cost < lowest_cost.f_cost:
			lowest_cost =  node_list[i]
	return lowest_cost

func set_node_is_walkable(pos: Vector2i, is_walk: bool) -> void:
	var cell_id: int = pos.x + pos.y * size.x
	if _is_within_grid(cell_id):
		grid_array[pos.x + pos.y * size.x].is_walkable = is_walk

func set_node_weight(pos: Vector2i, cost: int) -> void:
	var cell_id: int = pos.x + pos.y * size.x
	if _is_within_grid(cell_id):
		grid_array[pos.x + pos.y * size.x].weight = cost

func _is_within_grid(cell: int) -> bool:
	return cell > 0 and cell <= size.x * size.y
