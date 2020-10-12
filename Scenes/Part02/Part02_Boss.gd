extends "res://Objects/PathFindingEnemy.gd"

export var high_speed_after: float = 0.0
export var high_speed_scale: float = 1.0
export var color_change_speed: float = 0.5

onready var animated_sprite = $AnimatedSprite
onready var died_effect = $DeathEffect
onready var collision_shape = $CollisionShape
onready var mouth_collision_shape = $MouthArea/CollisionShape

var dead = false
var current: Color = Color(1.0, 0.0, 0.0)

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var d = path_distance()
	
	if d > high_speed_after:
		current_speed = speed * high_speed_scale
	else:
		current_speed = speed

func kill() -> void:
	if dead:
		return
	
	dead = true
	animated_sprite.visible = false
	died_effect.emitting = true
	collision_shape.disabled = true
	mouth_collision_shape.disabled = true

func _process(delta: float) -> void:
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
