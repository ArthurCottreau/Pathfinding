class_name PathNode

var pos: Vector2i

var g_cost: int
var h_cost: int
var f_cost: int

var cameFrom: PathNode

var is_walkable: bool = true
var weight: int = 1

func _init(position: Vector2i) -> void:
	pos = position

func calculate_f_cost() -> void:
	f_cost = g_cost + h_cost
