extends Node2D

export var angular_velocity: float = 300
export var color_change_speed: float = 0.5

onready var top_lamp = $TopLamp
onready var bottom_lamp = $BottomLamp
onready var top_light = $TopLamp/DirectionalLight
onready var bottom_light = $BottomLamp/DirectionalLight

var current: Color = Color(1.0, 0.0, 0.0)

var current_second = 0

func _ready():
	pass

func _process(delta):
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
