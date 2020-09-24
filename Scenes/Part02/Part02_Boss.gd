extends "res://Objects/PathFindingEnemy.gd"

export var high_speed_after: float = 0.0

export var high_speed_scale: float = 1.0

export var color_change_speed: float = 0.5

onready var animated_sprite = $AnimatedSprite
onready var death_effect = $DeathEffect
onready var collision = $CollisionPolygon2D
onready var mouth_area = $MouthArea/CollisionShape2D

var dead = false
var current: Color = Color(1.0, 0.0, 0.0)

func _ready():
	pass

func _physics_process(delta: float):
	var d = path_distance()
	
	if d > high_speed_after:
		current_speed = speed * high_speed_scale
	else:
		current_speed = speed

func kill():
	if dead:
		return
	
	dead = true
	animated_sprite.visible = false
	death_effect.emitting = true
	collision.disabled = true
	mouth_area.disabled = true

func _process(delta: float):
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
	
	animated_sprite.material.set_shader_param("replacement_color", current)
