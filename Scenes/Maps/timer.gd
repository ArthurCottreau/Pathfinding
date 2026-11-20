extends Label

var time: float
var minute: int
var seconde: int
var format_string: String = "%02d : %02d"
var active: bool = true

func _process(delta: float) -> void:
	if active:
		time += delta
		minute = int(time / 60) % 60
		seconde = int(time) % 60
		text = format_string % [minute, seconde]

func set_active(arg: bool) -> void:
	active = false
