extends Node2D

export var color_change_speed: float = 0.5

export var offset: Color = Color(0.75, 0.75, 0.75)
export var scale_color: Color = Color(0.33, 0.33, 0.33)

var current: Color = Color(0.0, 0.0, 0.0)
var current_second: float = 0

func _ready() -> void:
	var r = 1.0
	var g = 0.0
	var b = 0.0
	
	var state = Game.random_generator.randi_range(0, 2)
	
	if state == 0:
		r = Game.random_generator.randf_range(0.5, 1.0)
		g = 1.0 - r
		b = 0.0
	elif state == 1:
		g = Game.random_generator.randf_range(0.5, 1.0)
		b = 1.0 - g
		r = 0.0
	else:
		b = Game.random_generator.randf_range(0.5, 1.0)
		r = 1.0 - b
		g = 0.0
	
	current = Color(r, g, b)

func _process(delta: float) -> void:
	current_second += delta
	
	if current.r <= 1.0 and current.g < 1.0 and current.b == 0:
		current.r -= delta * color_change_speed
		current.g += delta * color_change_speed
	elif current.r == 0.0 and current.g <= 1.0 and current.b < 1.0:
		current.g -= delta * color_change_speed
		current.b += delta * color_change_speed
	elif current.r < 1.0 and current.g == 0.0 and current.b <= 1.0:
		current.b -= delta * color_change_speed
		current.r += delta * color_change_speed
	 
	current.r = max(0.0, min(1.0, current.r))
	current.g = max(0.0, min(1.0, current.g))
	current.b = max(0.0, min(1.0, current.b))
	
	modulate = Color(
		max(min(scale_color.r * current.r + offset.r, 1.0), 0.0), 
		max(min(scale_color.g * current.g + offset.g, 1.0), 0.0),
		max(min(scale_color.b * current.b + offset.b, 1.0), 0.0))
