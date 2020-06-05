class_name Player
extends KinematicBody2D

# Max velocity
export var MAX_SPEED = 308

# Max acceleration
export var ACCELERATION = 1320

# Jump force
export var JUMP_FORCE = 400

# Friction on the platform (only X axis)
export var FRICTION = 0.05

# Gravity (only Y axis)
export var GRAVITY = 300

# Sprint speed
export var SPRINT_SCALE = 1.35

# Velocity limit
export var WALK_THRESHOLD = 0.1

# Speed of the animation (sprint modifies it)
export var ANIMATION_SPEED = 1

# Defines how many waves (100% to 0% to 100% in walk acceleration) happen in a second 
export var WALK_WAVE_COUNT = 0.5

# Prefix of the front side
export var SIDE_A_PREFIX = "a"

# Prefix of the rear side
export var SIDE_B_PREFIX = "b"

# In which direction does the floor pushes the player
export var FLOOR_NORMAL = Vector2.UP

# Floor detect distance
export var FLOOR_DETECT_DISTANCE = 20.0

onready var platform_detector_00 = $PlatformDetector00
onready var platform_detector_01 = $PlatformDetector01
onready var animated_sprite = $AnimatedSprite
onready var collision_polygon = $CollisionPolygon2D

# Set the default side
var animation_prefix = SIDE_A_PREFIX

var current_second = 0
var current_velocity = Vector2(0, 0)
var current_max_speed = MAX_SPEED
var current_acceleration = ACCELERATION
var current_animation_speed = ANIMATION_SPEED

func _ready():
	Global.player_position = get_global_position()

func _physics_process(delta):
	var direction = get_direction()
	
	if direction.x != 0 || current_velocity.x != 0:
		var rad = WALK_WAVE_COUNT * current_second * current_animation_speed * PI
		
		current_acceleration = ACCELERATION * abs(sin(rad))
		current_second += delta
	
	var snap_vector = -1 * FLOOR_NORMAL * FLOOR_DETECT_DISTANCE if direction.y == 0 else Vector2.ZERO
	var on_platform = platform_detector_00.is_colliding() || platform_detector_01.is_colliding()
	var next_velocity = calculate_next_velocity(delta, direction)
	
	current_velocity = move_and_slide_with_snap(next_velocity, snap_vector, FLOOR_NORMAL, on_platform, 4, 0.9, false)
	
	if is_on_floor() && direction.x != 0:
		animated_sprite.scale.x = abs(animated_sprite.scale.x) * (1 if direction.x > 0 else -1)
		animated_sprite.scale.x = abs(animated_sprite.scale.x) * (1 if direction.x > 0 else -1)
		animation_prefix = SIDE_A_PREFIX if direction.x > 0 else SIDE_B_PREFIX
	
	var next_animation = get_next_animation(direction)
	
	set_animation(next_animation.name)
	
	if next_animation.freeze:
		animated_sprite.speed_scale = 0
	else:
		animated_sprite.speed_scale = current_animation_speed
	
	Global.player_position = get_global_position()

func get_direction():
	var right = Input.get_action_strength("move_right")
	var left = Input.get_action_strength("move_left")
	var jump = Input.is_action_just_pressed("jump")
	var sprint = Input.is_action_pressed("sprint")
	
	var x = right - left
	var y = -1 if is_on_floor() and jump else 0
	
	var speed_mod = SPRINT_SCALE if sprint else 1
	
	current_max_speed = speed_mod * MAX_SPEED
	current_acceleration = speed_mod * ACCELERATION
	current_animation_speed = speed_mod * ANIMATION_SPEED
	
	return Vector2(x, y)

func calculate_next_velocity(delta, direction):
	var next_velocity = current_velocity
	
	if is_on_floor():
		next_velocity.x *= pow(FRICTION, delta)
		
		if direction.y != 0:
			next_velocity.y += direction.y * JUMP_FORCE
	else:
		next_velocity.y += GRAVITY * delta
	
	if abs(next_velocity.x) > current_max_speed:
		next_velocity.x = (next_velocity.x / abs(next_velocity.x)) * current_max_speed
	elif direction.x != 0:
		next_velocity.x += direction.x * current_acceleration * delta
	
	return next_velocity

func get_next_animation(direction):
	var next_animation = "stand"
	var freeze = false
	
	if is_on_floor():
		if abs(current_velocity.x) > WALK_THRESHOLD:
			if not direction.x:
				next_animation = "walk_to_stand"
			else:
				next_animation = "walk"
		else:
			if direction.x:
				next_animation = "stand_to_walk"
			else:
				next_animation = "stand"
	else:
		if current_velocity.y > 0:
			next_animation = "jump"
			freeze = true
		else: 
			next_animation = "jump"
	
	return {
		"name": next_animation,
		"freeze": freeze
	}

func set_animation(name):
	animated_sprite.animation = animation_prefix + "_" + name

func get_animation():
	return animated_sprite.animation.substr(animated_sprite.animation.find("_") + 1)
