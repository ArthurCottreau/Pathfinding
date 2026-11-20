extends Character

signal on_death

const MOVEMENTS: Dictionary[StringName, Vector2i] = {
	&"ui_up": Vector2i.UP,
	&"ui_left": Vector2i.LEFT,
	&"ui_right": Vector2i.RIGHT,
	&"ui_down": Vector2i.DOWN 
}

var input_history: Array[StringName] = []
var cur_direction: Vector2i = Vector2i.DOWN
var is_dead: bool = false

@onready var slimed_timer: Timer = $SlimedTimer

func _input(event: InputEvent) -> void:
	for direction in MOVEMENTS.keys():
		if event.is_action_released(direction):
			var index: int = input_history.find(direction)
			if index != -1: input_history.remove_at(index)
		
		if event.is_action_pressed(direction):
			input_history.append(direction)

func _process(_delta) -> void:
	if not can_move(): return
	if is_dead: return
	
	var input_direction: Vector2i = set_direction()
	if input_direction:
		cur_direction = input_direction
		chara_skin.set_animation_direction(input_direction)
		
		# Checks if the next movement opportunity is possible, if it is move to target position
		var target_position: Vector2i = Grid.request_move(self, input_direction)
		if target_position: move_to(target_position)

func input_priority() -> void:
	# Input priority system, prioritize the latest inputs
	for direction in MOVEMENTS.keys():
		if Input.is_action_just_released(direction):
			var index: int = input_history.find(direction)
			if index != -1: input_history.remove_at(index)
		
		if Input.is_action_just_pressed(direction):
			input_history.append(direction)

func set_direction() -> Vector2i:
	# Handles the movement direction depending on the inputs
	var direction: Vector2i = Vector2i()
	
	if input_history.size():
		for i in input_history:
			direction += MOVEMENTS[i]
		
		match(input_history.back()):
			&"ui_right", &"ui_left": if direction.x != 0: direction.y = 0
			&"ui_up", &"ui_down": if direction.y != 0: direction.x = 0
	
	return direction

func _move_tween_done() -> void:
	Grid.request_event(self, Vector2i.ZERO) # Check if there's an event
	super()

func set_talking(talk_state: bool) -> void:
	is_talking = talk_state
	if is_talking: input_history.clear()

func trigger_event() -> void:
	is_dead = true
	on_death.emit()

func slimed() -> void:
	actual_speed = 0.8
	slimed_timer.start()

func unslime() -> void:
	actual_speed = speed
