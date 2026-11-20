class_name PawnGrid

enum { EMPTY = -1, ACTOR, OBSTACLE, EVENT }

const CELL_SIZE: float = 16.0

var size: Vector2i
var grid_array: PackedInt32Array
var pawn_coords: Dictionary[Vector2i, Pawn]

func _init(x: int, y: int) -> void:
	size = Vector2i(x, y)
	grid_array.resize(size.x * size.y)

func initialize_cells(node_group: StringName, custom_data: String) -> void:
	var used_cells: Dictionary[Vector2i,int] = get_custom_cell_data(node_group, custom_data)
	for cell in used_cells.keys():
		set_cell(cell, used_cells[cell])

func initialize_pawns(pawn_grid: Node2D, pawn_type: int) -> void:
	for child in pawn_grid.get_children():
		if child.type == pawn_type:
			var child_map_pos: Vector2i = local_to_grid(child.position)
			set_cell(child_map_pos, child.type)
			pawn_coords[child_map_pos] = child
		
		if child.type == ACTOR:
			child.curr_cell = local_to_grid(child.position)

func get_custom_cell_data(node_group: StringName, custom_data: String) -> Dictionary[Vector2i,int]:
	var scene_tree: SceneTree = Engine.get_main_loop()
	var all_layers: Array[Node] = scene_tree.get_nodes_in_group(node_group)
	var cell_data: Dictionary[Vector2i,int]
	for layer in all_layers:
		var used_cells: Array[Vector2i] = layer.get_used_cells_by_id()
		for cell in used_cells:
			var get_target_data: TileData = layer.get_cell_tile_data(cell)
			var cell_data_id: int = get_target_data.get_custom_data(custom_data)
			cell_data[cell] = cell_data_id
	return cell_data

func local_to_grid(local: Vector2i) -> Vector2i:
	return local / CELL_SIZE

func grid_to_local(grid: Vector2i) -> Vector2i:
	return grid * CELL_SIZE

func get_cell_data(start: Vector2i, direction: Vector2i) -> Dictionary:
	var cell_start: Vector2i = local_to_grid(start)
	var cell_target: Vector2i = cell_start + direction
	var cell_target_type: int = get_cell_type(cell_target)
	
	return { "start": cell_start, "target": cell_target, "target_type": cell_target_type }

func get_cell_pawn(coordinates: Vector2i) -> Pawn:
	if pawn_coords.has(coordinates):
		return pawn_coords[coordinates] # If a Pawn has those coordinates
	
	return # No Pawn

func get_cell_id(cell_target: Vector2i) -> int:
	return cell_target.x + cell_target.y * size.x

func get_cell_pos(id: int) -> Vector2i:
	var pos_x: int = id % size.x
	var pos_y: int = floor(float(id) / size.x);
	return Vector2i(pos_x,pos_y)

func is_within_grid(cell: int) -> bool:
	return cell > 0 and cell <= size.x * size.y

func set_cell(cell_target: Vector2i, pawn_type: int) -> void:
	var cell: int = get_cell_id(cell_target)
	if is_within_grid(cell):
		grid_array[cell] = pawn_type

func get_cell_type(cell_target: Vector2i) -> int:
	var cell: int = get_cell_id(cell_target)
	if is_within_grid(cell):
		return grid_array[cell]
	return EMPTY

func update_pawn_pos(pawn_type: int, cell_start: Vector2i, cell_target: Vector2i) -> void:
	set_cell(cell_target, pawn_type)
	set_cell(cell_start, EMPTY)
	
	# Avoids adding obstacles to pawn_coords
	if pawn_coords.has(cell_start):
		pawn_coords[cell_target] = pawn_coords[cell_start]
		pawn_coords.erase(cell_start)

func get_used_cells() -> Array[Vector2i]:
	var used_cells: Array[Vector2i]
	for cell_id in grid_array.size():
		if grid_array[cell_id] == OBSTACLE:
			var pos: Vector2i = get_cell_pos(cell_id)
			used_cells.append(pos)
	return used_cells
