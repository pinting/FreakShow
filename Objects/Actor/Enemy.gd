class_name Enemy
extends "res://Objects/Actor/BaseActor.gd"

# Animation
export (SpriteFrames) var ANIMATION_FRAMES

# Speed of the enemy
export var SPEED: float = 250.0

# Rotation speed of the enemy
export var ROTATION_SPEED: float = 10.0

# Zero value
export var EPS: float = 1.0

onready var animated_sprite = $AnimatedSprite

var path : = PoolVector2Array()

var _rotation_dest = 0
var _current_velocity = 0

func _ready():
	assert(ANIMATION_FRAMES.has_animation("default"))
	
	animated_sprite.frames = ANIMATION_FRAMES

func _physics_process(delta: float):
	if path.size() == 0:
		return
	
	var distance = global_position.distance_to(path[0])
	var direction = global_position.direction_to(path[0])
	
	if distance < SPEED * delta:
		path.remove(0)
	
	_current_velocity = move_and_slide(direction * SPEED)
	_rotation_dest = 180 * (direction.angle() / PI)
	
	animated_sprite.playing = abs(_current_velocity.x) > EPS and abs(_current_velocity.y) > EPS 
	
	var rotation_diff = _rotation_dest - rotation_degrees
	
	if abs(rotation_diff) > 0:
		var rotation_step = rotation_diff / abs(rotation_diff) * ROTATION_SPEED
		
		if abs(rotation_diff) >= abs(rotation_step):
			rotation_degrees += rotation_step
		else:
			rotation_degrees += rotation_diff

static func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	
	return q0.linear_interpolate(q1, t)

static func smooth_path(raw_path: PoolVector2Array, step: float = 10):
	var raw_size = raw_path.size()
	
	if raw_size < 3:
		return raw_path
	
	var result = PoolVector2Array()
	var i = 0
	
	while i + 2 < raw_size:
		for t in range(step + 1):
			var v = _quadratic_bezier(raw_path[i], raw_path[i + 1], raw_path[i + 2], t / step)
			
			result.push_back(v)
		
		i += 2
	
	while i < raw_size:
		result.push_back(raw_path[i])
		i += 1
	
	return result
