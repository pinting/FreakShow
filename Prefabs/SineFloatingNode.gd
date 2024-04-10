extends Node2D

export var pi_per_pixel: float = PI * 0.0025
export var limit: float = 1350
export var speed: float = 0.2
export var y_scale: float = 2.0

var base_position: Vector2
var direction: float = 1

signal direction_changed

func _ready():
	base_position = position

func _process(_delta: float) -> void:
	position.y += sin(position.x * pi_per_pixel) * y_scale
	position.x += direction * speed
	
	if position.x >= base_position.x + limit:
		position = Vector2(base_position.x + limit, base_position.y)
		direction = -1
		
		emit_signal("direction_changed")
	
	if position.x <= base_position.x:
		position = Vector2(base_position.x + limit, base_position.y)
		direction = 1
		
		emit_signal("direction_changed")
