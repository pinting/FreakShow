extends "res://Objects/Enemy.gd"

export var high_speed_after: float = 2000.0

export var high_speed_scale: float = 3.0

onready var animated_sprite = $AnimatedSprite
onready var death_effect = $DeathEffect
onready var collision = $CollisionPolygon2D
onready var mouth_area = $MouthArea/CollisionShape2D

var dead = false

func _ready():
	pass

func _physics_process(delta: float):
	var player = Global.player
	
	if path and player != null:
		var d = player.position.distance_to(position)
		
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
