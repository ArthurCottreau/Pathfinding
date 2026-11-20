extends Character

@export var target: Pawn

var path: Array[Vector2i]
var move_step: int = 0
var move_max: int
var curr_target: Vector2i

@onready var slimed_timer: Timer = $SlimedTimer

func _process(_delta) -> void:
	if can_move():
		if path.is_empty() or has_target_changed_pos():
			curr_target = target.curr_cell
			path = Grid.get_astar_path(self, curr_target)
			move_step = 0
			move_max = path.size()
			return
		
		var current_step: Vector2i = path.get(move_step)
		chara_skin.set_animation_direction(current_step)
		
		# Checks if the next movement opportunity is possible, if it is move to target position
		Grid.request_actor(self, current_step) # Check if there's an event
		var target_position: Vector2i = Grid.request_move(self, current_step)
		if not target_position:
			path.clear()
			return
		move_to(target_position)
		
		# Loops movement when move_step is equal to 0
		move_step += 1
		if move_step >= move_max:
			path.clear()

func has_target_changed_pos() -> bool:
	return curr_target != target.curr_cell

func _move_tween_done() -> void:
	Grid.request_event(self, Vector2i.ZERO) # Check if there's an event
	super()

func trigger_event() -> void:
	if not is_moving:
		print("NPC AStar")

func slimed() -> void:
	actual_speed = 0.8
	slimed_timer.start()

func unslime() -> void:
	actual_speed = speed
