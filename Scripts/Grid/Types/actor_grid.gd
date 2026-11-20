class_name ActorGrid
extends PawnGrid

var pathfinding: Pathfinding = Pathfinding.new()
var last_pawn_coords: Dictionary[Vector2i,Pawn]

func initialize_astar() -> void:
	pathfinding.initialize_path_grid(size)
	_update_astar_grid()
	_update_astar_grid_pawns()
	initialize_weights(&"Tilemap", "weight")

func initialize_weights(node_group: StringName, custom_data: String) -> void:
	var used_cells: Dictionary[Vector2i,int] = get_custom_cell_data(node_group, custom_data)
	for cell in used_cells.keys():
		pathfinding.set_node_weight(cell, used_cells[cell])

func _update_astar_grid() -> void:
	for pos in get_used_cells():
		pathfinding.set_node_is_walkable(pos, false)

func request_move(pawn: Pawn, direction: Vector2i) -> Vector2i:
	var cell: Dictionary = get_cell_data(pawn.position, direction)
	
	match cell.target_type:
		EMPTY:
			update_pawn_pos(pawn.type, cell.start, cell.target)
			pawn.curr_cell = cell.target
			return grid_to_local(cell.target)
		_:
			return Vector2i.ZERO

func node_todir_path(path_nodes: Array[PathNode]) -> Array[Vector2i]:
	var path_moves: Array[Vector2i]
	
	for i in range(path_nodes.size() - 1):
		path_moves.append(path_nodes[i+1].pos - path_nodes[i].pos)
	
	return path_moves

func get_move_path(pawn: Pawn, end_cell: Vector2i) -> Array[Vector2i]:
	_update_astar_grid_pawns()
	# Will allow to atleast try to get to target, even if it's impossible
	pathfinding.set_node_is_walkable(end_cell, true)
	
	var start_point: Vector2i = local_to_grid(pawn.position)
	
	var path: Array[PathNode] = pathfinding.get_path(start_point, end_cell)
	var path_moves: Array[Vector2i] = node_todir_path(path)
	return path_moves

func get_cell_weight(cell_target: Vector2i) -> int:
	return pathfinding.get_node_weight(cell_target)

func set_cell_weight(cell_target: Vector2i, weight: int) -> void:
	pathfinding.set_node_weight(cell_target, weight)

func _update_astar_grid_pawns() -> void:
	for pos in last_pawn_coords:
		pathfinding.set_node_is_walkable(pos, true)
	
	last_pawn_coords = pawn_coords.duplicate()
	
	for pos in pawn_coords:
		pathfinding.set_node_is_walkable(pos, false)

func request_event(pawn: Pawn, direction: Vector2i) -> void:
	var cell: Dictionary = get_cell_data(pawn.position, direction)
	
	if cell.target_type == ACTOR:
		var event_pawn: Pawn = get_cell_pawn(cell.target)
		if event_pawn: event_pawn.trigger_event()
