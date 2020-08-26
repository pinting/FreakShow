class_name Enemy
extends KinematicBody2D

# Speed of the enemy
export var SPEED: float = 250.0

# Rotation speed of the enemy
export var ROTATION_SPEED: float = 10.0

# Zero value
export var ZERO: float = 1.0

onready var animated_sprite = $AnimatedSprite

var path : = PoolVector2Array()
var current_speed = SPEED

var _rotation_dest = 0
var _current_velocity = 0

func _ready():
	assert(animated_sprite)

func _physics_process(delta: float):
	if path.size() == 0:
		return
	
	var distance = global_position.distance_to(path[0])
	var direction = global_position.direction_to(path[0])
	
	if distance < current_speed * delta:
		path.remove(0)
	
	_current_velocity = move_and_slide(direction * current_speed)
	_rotation_dest = 180 * (direction.angle() / PI)
	
	animated_sprite.playing = abs(_current_velocity.x) > ZERO and abs(_current_velocity.y) > ZERO 
	
	var rotation_diff = _rotation_dest - rotation_degrees
	
	if abs(rotation_diff) > 0:
		var rotation_step = rotation_diff / abs(rotation_diff) * ROTATION_SPEED
		
		if abs(rotation_diff) >= abs(rotation_step):
			rotation_degrees += rotation_step
		else:
			rotation_degrees += rotation_diff
