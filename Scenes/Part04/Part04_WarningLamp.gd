extends Node2D

export var angular_velocity: float = 300
export var color_change_speed: float = 0.5

onready var top_lamp = $TopLamp
onready var bottom_lamp = $BottomLamp
onready var top_light = $TopLamp/DirectionalLight
onready var bottom_light = $BottomLamp/DirectionalLight

var current: Color = Color(1.0, 0.0, 0.0)

var current_second = 0

func _ready() -> void:
	var r = 1.0
	var g = 0.0
	var b = 0.0
	
	var state = Global.random_generator.randi_range(0, 2)
	
	if state == 0:
		r = Global.random_generator.randf_range(0.5, 1.0)
		g = 1.0 - r
		b = 0.0
	elif state == 1:
		g = Global.random_generator.randf_range(0.5, 1.0)
		b = 1.0 - g
		r = 0.0
	else:
		b = Global.random_generator.randf_range(0.5, 1.0)
		r = 1.0 - b
		g = 0.0
	
	current = Color(r, g, b)

func _process(delta: float) -> void:
	current_second += delta
	
	var diff = angular_velocity * delta
	
	rotation_degrees = fmod(rotation_degrees + diff, 360.0)
	
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
	
	top_light.color = current
	top_lamp.modulate = current
	
	bottom_light.color = current
	bottom_lamp.modulate = current
