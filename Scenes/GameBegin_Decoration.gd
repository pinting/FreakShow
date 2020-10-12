extends Node2D

export var pi_per_pixel: float = PI * 0.0025
export var turn_back_after: float = 1220
export var speed: float = 0.5
export var y_scale: float = 2.0

onready var animated_sprite = $AnimatedSprite

var base_position: Vector2
var direction: float = 1

func _ready():
	base_position = position

func _process(delta):
	position.y += sin(position.x * pi_per_pixel) * y_scale
	position.x += direction * speed
	
	if position.x >= base_position.x + turn_back_after:
		position = Vector2(base_position.x + turn_back_after, base_position.y)
		direction = -1
		
		_next_frame()
	
	if position.x <= base_position.x:
		position = Vector2(base_position.x + turn_back_after, base_position.y)
		direction = 1
		
		_next_frame()

func _next_frame():
	var current_animation = animated_sprite.animation
	var last_frame = animated_sprite.frames.get_frame_count(current_animation) - 1
	
	if animated_sprite.frame == last_frame:
		animated_sprite.frame = 0
	else:
		animated_sprite.frame += 1
