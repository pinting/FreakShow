extends "res://Objects/PathFindingEnemy.gd"

export var high_speed_after: float = 0.0
export var high_speed_scale: float = 1.0

onready var animated_sprite = $AnimatedSprite
onready var died_effect = $DeathEffect
onready var collision_shape = $CollisionShape
onready var mouth_collision_shape = $MouthArea/CollisionShape

var dead = false

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