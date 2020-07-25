class_name Player
extends KinematicBody2D

# Animation
export (SpriteFrames) var FRAMES

# Max velocity
export var MAX_SPEED = 280

# Max acceleration
export var ACCELERATION = 6000

# Jump force
export var JUMP_FORCE = 400

# Friction on the platform (only X axis)
export var FRICTION = 0.001

# Gravity (only Y axis)
export var GRAVITY = 300

# Sprint speed
export var SPRINT_SCALE = 1.35

# Speed of the animation (sprint modifies it)
export var ANIMATION_SPEED = 1

# Defines how many waves (100% to 0% to 100% in walk acceleration) happen in a second 
export var WALK_WAVE_COUNT = 1.25
export var WALK_WAVE_OFFSET = PI / 2

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
onready var top_detector = $TopDetector
onready var animated_sprite = $AnimatedSprite
onready var stand_collision = $StandCollision
onready var crouch_collision = $CrouchCollision

var current_second = 0
var freeze = false

var _animation_prefix = SIDE_A_PREFIX
var _current_velocity = Vector2(0, 0)
var _current_max_speed = MAX_SPEED
var _current_acceleration = ACCELERATION
var _current_animation_speed = ANIMATION_SPEED
var _crouching = false
var _transition = false
var _moving_x = false

func _ready():
	animated_sprite.frames = FRAMES
	Global.player = self

func _physics_process(delta):
	_check_crouch()
	
	var on_platform = platform_detector_00.is_colliding() or platform_detector_01.is_colliding()
	var head_colliding = top_detector.is_colliding()
	var direction = _get_direction()
	
	if on_platform and top_detector.is_colliding():
		direction.y = 0
	
	if _current_velocity.x != 0:
		var rad = WALK_WAVE_COUNT * current_second * _current_animation_speed * PI
		
		_current_acceleration = ACCELERATION * abs(sin(rad + WALK_WAVE_OFFSET))
		current_second += delta
	
	var snap_vector = -1 * FLOOR_NORMAL * FLOOR_DETECT_DISTANCE if direction.y == 0 else Vector2.ZERO
	var next_velocity = _calculate_next_velocity(delta, direction)
	
	_current_velocity = move_and_slide_with_snap(next_velocity, snap_vector, FLOOR_NORMAL, on_platform, 4, 0.9, false)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var body = collision.collider
		
		if body.is_in_group("pickable"):
			var position_diff = body.global_position - global_position
			
			body.apply_central_impulse(position_diff.normalized() * body.KICK_FORCE)
	
	if is_on_floor() and direction.x != 0:
		var m = 1 if direction.x > 0 else -1
		
		animated_sprite.scale.x = abs(animated_sprite.scale.x) * m
		crouch_collision.scale.x = abs(crouch_collision.scale.x) * m
		stand_collision.scale.x = abs(stand_collision.scale.x) * m
		
		_animation_prefix = SIDE_A_PREFIX if direction.x > 0 else SIDE_B_PREFIX
	
	var next_animation = _get_next_animation(direction)
	
	if next_animation.freeze:
		animated_sprite.speed_scale = 0
	else:
		animated_sprite.speed_scale = _current_animation_speed
	
	_set_animation(next_animation.name)

func _check_crouch():
	if Input.is_action_just_pressed("crouch"):
		_crouching = not _crouching
		
	stand_collision.disabled = _crouching
	crouch_collision.disabled = not _crouching

func _get_direction():
	if freeze:
		return Vector2(0, 0)
	
	var right = Input.get_action_strength("move_right")
	var left = Input.get_action_strength("move_left")
	var jump = Input.is_action_just_pressed("jump")
	var sprint = Input.is_action_pressed("sprint")
	
	var on_floor = is_on_floor()
	var x = right - left
	var y = -1 if on_floor and jump and not _crouching else 0
	var speed_mod = SPRINT_SCALE if sprint and on_floor else 1
	
	_current_max_speed = speed_mod * MAX_SPEED
	_current_acceleration = speed_mod * ACCELERATION
	_current_animation_speed = speed_mod * ANIMATION_SPEED
	
	return Vector2(x, y)

func _calculate_next_velocity(delta, direction):
	var next_velocity = _current_velocity
	
	if is_on_floor():
		next_velocity.x *= pow(FRICTION, delta)
		
		if direction.y != 0:
			next_velocity.y += direction.y * JUMP_FORCE
	else:
		next_velocity.y += GRAVITY * delta
	
	if abs(next_velocity.x) > _current_max_speed:
		next_velocity.x = (next_velocity.x / abs(next_velocity.x)) * _current_max_speed
	elif direction.x != 0:
		next_velocity.x += direction.x * _current_acceleration * delta
	
	return next_velocity

func _get_next_animation(direction):
	var next_animation = "stand_still"
	var freeze = false
	
	var current_animation = animated_sprite.animation
	var last_frame = animated_sprite.frames.get_frame_count(current_animation) - 1
	var animation_looped = animated_sprite.frames.get_animation_loop(current_animation)
	
	if is_on_floor():
		if direction.x:
			if not _moving_x:
				_moving_x = true
				_transition = true
			elif not animation_looped and animated_sprite.frame == last_frame:
				_transition = false
				
			if _transition:
				next_animation = "still_to_move"
			else:
				next_animation = "move"
		else:
			if _moving_x:
				_moving_x = false
				_transition = true
			elif not animation_looped and animated_sprite.frame == last_frame:
				_transition = false
				
			if _transition:
				next_animation = "move_to_still"
			else:
				next_animation = "still"
				
		next_animation = ("crouch" if _crouching else "stand") + "_" + next_animation
	else:
		if abs(_current_velocity.x) > 0:
			_moving_x = true
			_transition = false
		
		if _current_velocity.y > 0:
			# When falling, freeze the current frame of the jump animation
			next_animation = "jump"
			freeze = true
		else: 
			next_animation = "jump"
	
	return {
		"name": next_animation,
		"freeze": freeze
	}

func _set_animation(name):
	animated_sprite.animation = _animation_prefix + "_" + name

func get_animation():
	return animated_sprite.animation.substr(animated_sprite.animation.find("_") + 1)
