class_name Player
extends KinematicBody2D

const MAX_SPEED = Vector2(1000, 18000)
const ACCELERATION = Vector2(1000, 18000)
const FLOOR_NORMAL = Vector2.UP
const FLOOR_DETECT_DISTANCE = 20.0
const FRICTION = 0.001
const GRAVITY = 200
const WALK_THRESHOLD = 1

onready var platform_detector = $PlatformDetector
onready var sprite = $AnimatedSprite

var animation_prefix = "a"
var current_velocity = Vector2(0, 0)
var current_second = 0
var current_accleleration = ACCELERATION;

func _ready():
	pass

func _physics_process(delta):
	var direction = get_direction()
	
	if(direction.x != 0 || current_velocity.x != 0):
		var m = abs(sin(PI * current_second))
		var current_accleleration = ACCELERATION * m
		
		current_second += 2 * delta
	
	var is_jump_interrupted = Input.is_action_just_released("jump") and current_velocity.y < 0
	var snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE if direction.y == 0 else Vector2.ZERO
	var is_on_platform = platform_detector.is_colliding()
	var next_velocity = calculate_next_velocity(delta, direction, is_on_platform, is_jump_interrupted)
	
	current_velocity = move_and_slide_with_snap(
		next_velocity, snap_vector, FLOOR_NORMAL, not is_on_platform, 4, 0.9, false)
	
	if direction.x != 0:
		if direction.x > 0:
			sprite.scale.x = abs(sprite.scale.x)
			animation_prefix = "a"
		else:
			sprite.scale.x = -abs(sprite.scale.x)
			animation_prefix = "b"
	
	var next_animation = get_animation(direction)
	
	if(next_animation[1]):
		sprite.speed_scale = 0
	else:
		sprite.speed_scale = 1
	
	set_animation(next_animation[0])

func get_direction():
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1 if is_on_floor() and Input.is_action_just_pressed("jump") else 0
	)

func calculate_next_velocity(delta, direction, is_on_platform, is_jump_interrupted):
	var next_velocity = current_velocity
	
	next_velocity.x *= pow(FRICTION, delta)
	
	if not is_on_platform:
		next_velocity.y += GRAVITY * delta
	
	if direction.x != 0.0:
		next_velocity.x += direction.x * current_accleleration.x * delta
		
		if (abs(next_velocity.x) > abs(MAX_SPEED.x)):
			next_velocity.x = direction.x * MAX_SPEED.x
	
	if direction.y != 0.0:
		next_velocity.y += direction.y * current_accleleration.y * delta
		
		if (abs(next_velocity.y) > abs(MAX_SPEED.y)):
			next_velocity.y = direction.y * MAX_SPEED.y
	
	if is_jump_interrupted && next_velocity.y > 0.0:
		next_velocity.y = 0.0
	
	return next_velocity

func get_animation(direction):
	var next_animation = "stand"
	var freeze = false
	
	if is_on_floor():
		if abs(current_velocity.x) > WALK_THRESHOLD:
			if(direction.x == 0):
				next_animation = "walk_to_stand"
			else:
				next_animation = "walk"
		else:
			if(direction.x != 0):
				next_animation = "stand_to_walk"
			else:
				next_animation = "stand"
	else:
		if current_velocity.y > 0:
			next_animation = "jump"
			freeze = true
		else:
			next_animation = "jump"
	
	return [next_animation, freeze]

func set_animation(name):
	sprite.animation = animation_prefix + "_" + name

func remove_animation_prefix(name):
	return sprite.animation.substr(sprite.animation.find("_") + 1)
