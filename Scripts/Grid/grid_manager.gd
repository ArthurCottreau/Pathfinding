extends Node2D

enum { EMPTY = -1, ACTOR, OBSTACLE, EVENT }

#TODO Rework to work like AstarGrid
var actor_grid: PawnGrid = ActorGrid.new(33,23)
var event_grid: PawnGrid = EventGrid.new(33,23)

func _ready() -> void:
	_initialize_grids()

func _initialize_grids() -> void:
	actor_grid.initialize_cells(&"Tilemap", "coll_type")
	actor_grid.initialize_pawns(self, ACTOR)
	actor_grid.initialize_astar()
	event_grid.initialize_pawns(self, EVENT)

func request_move(pawn: Pawn, direction: Vector2i) -> Vector2i:
	return actor_grid.request_move(pawn, direction)

func get_astar_path(pawn: Pawn, end_cell: Vector2i) -> Array[Vector2i]:
	return actor_grid.get_move_path(pawn, end_cell)

func request_actor(pawn: Pawn, direction: Vector2i) -> void:
	actor_grid.request_event(pawn, direction)

func request_event(pawn: Pawn, direction: Vector2i) -> void:
	event_grid.request_event(pawn, direction)
