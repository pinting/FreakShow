class_name Player
extends KinematicBody2D

# Animation
export (SpriteFrames) var ANIMATION_FRAMES

# Max velocity
export var MAX_SPEED: float = 280.0

# Max acceleration
export var ACCELERATION: float = 6000.0

# Jump force
export var JUMP_FORCE: float = 400.0

# Friction on the platform (only X axis)
export var FRICTION: float = 0.001

# Gravity (only Y axis)
export var GRAVITY: float = 300.0

# Sprint speed
export var SPRINT_SCALE: float = 1.35

# Speed of the animation (sprint modifies it)
export var ANIMATION_SPEED: float = 1.0

# Defines how many waves (100% to 0% to 100% in walk acceleration) happen in a second 
export var WALK_WAVE_COUNT: float = 1.25
export var WALK_WAVE_OFFSET: float = PI / 2

# In which direction does the floor pushes the player
export var FLOOR_NORMAL: Vector2 = Vector2.UP

# Floor detect distance
export var FLOOR_DETECT_DISTANCE: float = 20.0

onready var platform_detector_00 = $PlatformDetector00
onready var platform_detector_01 = $PlatformDetector01
onready var top_detector = $TopDetector

onready var stand_collision = $StandCollision
onready var crouch_collision = $CrouchCollision
onready var avatar_collision = $AvatarCollision

onready var animated_sprite = $AnimatedSprite

var current_second: float = 0.0
var freeze: bool = false
var avatar_mode: bool = false

var _animation_prefix: String = "a"
var _current_velocity: Vector2 = Vector2(0, 0)
var _current_max_speed: int = MAX_SPEED
var _current_acceleration: int = ACCELERATION
var _current_animation_speed: float = ANIMATION_SPEED
var _crouching: bool = false
var _transition: bool = false
var _moving_x: bool = false

func _ready():
	var frames = ANIMATION_FRAMES
	
	assert(frames.has_animation("a_stand_still"))
	assert(frames.has_animation("a_stand_still_to_move"))
	assert(frames.has_animation("a_stand_move"))
	assert(frames.has_animation("a_stand_move_to_still"))
	assert(frames.has_animation("a_crouch_still"))
	assert(frames.has_animation("a_crouch_still_to_move"))
	assert(frames.has_animation("a_crouch_move"))
	assert(frames.has_animation("a_crouch_move_to_still"))
	assert(frames.has_animation("a_jump"))
	
	assert(frames.has_animation("b_stand_still"))
	assert(frames.has_animation("b_stand_still_to_move"))
	assert(frames.has_animation("b_stand_move"))
	assert(frames.has_animation("b_stand_move_to_still"))
	assert(frames.has_animation("b_crouch_still"))
	assert(frames.has_animation("b_crouch_still_to_move"))
	assert(frames.has_animation("b_crouch_move"))
	assert(frames.has_animation("b_crouch_move_to_still"))
	assert(frames.has_animation("b_jump"))
	
	assert(frames.has_animation("avatar_move"))
	assert(frames.has_animation("avatar_still"))
	
	animated_sprite.frames = frames
	Global.player = self

func _physics_process(delta: float):
	_crouching = Input.is_action_pressed("crouch")
	
	stand_collision.disabled = _crouching
	crouch_collision.disabled = not _crouching
	
	var on_platform = platform_detector_00.is_colliding() or platform_detector_01.is_colliding()
	var head_colliding = top_detector.is_colliding()
	var direction = _get_direction()
	
	direction.y = 0.0
	
	if _current_velocity.x != 0.0:
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
	
	if is_on_floor() and direction.x != 0.0:
		var m = 1.0 if direction.x > 0.0 else -1.0
		
		animated_sprite.scale.x = abs(animated_sprite.scale.x) * m
		crouch_collision.scale.x = abs(crouch_collision.scale.x) * m
		stand_collision.scale.x = abs(stand_collision.scale.x) * m
		avatar_collision.scale.x = abs(avatar_collision.scale.x) * m
		
		_animation_prefix = "a" if direction.x > 0.0 else "b"
	
	var next_animation = _get_next_animation(direction)
	
	if next_animation.freeze:
		animated_sprite.speed_scale = 0.0
	else:
		animated_sprite.speed_scale = _current_animation_speed
	
	_set_animation(next_animation.name)

func _check_crouch():
	_crouching = Input.is_action_pressed("crouch")
	stand_collision.disabled = _crouching
	crouch_collision.disabled = not _crouching

func _get_direction():
	if freeze:
		return Vector2(0, 0)
	
	var right_strength = Input.get_action_strength("move_right")
	var left_strength = Input.get_action_strength("move_left")
	var up_strength = Input.get_action_strength("move_up")
	var down_strength = Input.get_action_strength("move_down")
	var sprint_pressed = Input.is_action_pressed("sprint")
	
	var can_go_up = avatar_mode or (is_on_floor() and not _crouching)
	var can_go_down = avatar_mode
	
	var x = right_strength - left_strength
	var y = (down_strength if can_go_down else 0.0) - (up_strength if can_go_up else 0.0)
	
	var speed_mod = SPRINT_SCALE if not avatar_mode and sprint_pressed and can_go_up else 1.0
	
	_current_max_speed = speed_mod * MAX_SPEED
	_current_acceleration = speed_mod * ACCELERATION
	_current_animation_speed = speed_mod * ANIMATION_SPEED
	
	return Vector2(x, y)

func _calculate_next_velocity(delta: float, direction: Vector2):
	var next_velocity = _current_velocity
	
	if is_on_floor():
		next_velocity.x *= pow(FRICTION, delta)
		
		if direction.y < 0.0:
			next_velocity.y += direction.y * JUMP_FORCE
	else:
		next_velocity.y += GRAVITY * delta
	
	if abs(next_velocity.x) > _current_max_speed:
		next_velocity.x = (next_velocity.x / abs(next_velocity.x)) * _current_max_speed
	elif direction.x != 0.0:
		next_velocity.x += direction.x * _current_acceleration * delta
	
	return next_velocity

func _get_next_animation(direction: Vector2):
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
		if abs(_current_velocity.x) > 0.0:
			_moving_x = true
			_transition = false
		
		if _current_velocity.y > 0.0:
			# When falling, freeze the current frame of the jump animation
			next_animation = "jump"
			freeze = true
		else: 
			next_animation = "jump"
	
	return {
		"name": next_animation,
		"freeze": freeze
	}

func _set_animation(name: String):
	animated_sprite.animation = _animation_prefix + "_" + name

func get_animation():
	return animated_sprite.animation.substr(animated_sprite.animation.find("_") + 1)
