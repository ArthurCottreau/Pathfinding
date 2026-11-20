extends Pawn

var curr_cell: Vector2i
var old_cell_weight: int
var new_cell_weight: int = 5

@onready var Grid: Node2D = get_parent()

func created() -> void:
	old_cell_weight = Grid.get_cell_weight(curr_cell)
	print(old_cell_weight)
	Grid.set_cell_weight(curr_cell, new_cell_weight)

func trigger_event(pawn: Pawn) -> void:
	pawn.slimed()

func _on_timer_timeout() -> void:
	Grid.remove_event(curr_cell)
	Grid.set_cell_weight(curr_cell, old_cell_weight)
