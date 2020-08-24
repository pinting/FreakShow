class_name Player
extends "res://Objects/Actor/BaseActor.gd"

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

# Defines how many waves (0% to 100% to 0% in walk acceleration) happen in a second 
export var WALK_WAVE_COUNT: float = 1.25

# Offset walk waves (e.g. 0.5 equals start at 100% in walk acceleration)
export var WALK_WAVE_OFFSET: float = 0.5

# In which direction does the floor pushes the player
export var FLOOR_NORMAL: Vector2 = Vector2.UP

# Floor detect distance
export var FLOOR_DETECT_DISTANCE: float = 20.0

# Zero value
export var EPS: float = 1.0

onready var platform_detector_00 = $PlatformDetector00
onready var platform_detector_01 = $PlatformDetector01
onready var top_detector = $TopDetector

onready var stand_collision = $StandCollision
onready var crouch_collision = $CrouchCollision
onready var avatar_collision = $AvatarCollision

onready var transform_effect = $TransformEffect

onready var animated_sprite = $AnimatedSprite

var current_second: float = 0.0
var freeze: bool = false

var _avatar_mode: bool = true
var _animation_prefix: String = ""
var _current_velocity: Vector2 = Vector2(0, 0)
var _current_max_speed: float = MAX_SPEED
var _current_acceleration: float = ACCELERATION
var _current_animation_speed: float = ANIMATION_SPEED
var _crouching: bool = false
var _transition: bool = false
var _moving_x: bool = false
var _transforming_seconds: float = 0.0
var _transforming: bool = false
var _transform_done: bool = false

func _ready():
	assert(ANIMATION_FRAMES != null)
	
	assert(ANIMATION_FRAMES.has_animation("a_stand_still"))
	assert(ANIMATION_FRAMES.has_animation("a_stand_still_to_move"))
	assert(ANIMATION_FRAMES.has_animation("a_stand_move"))
	assert(ANIMATION_FRAMES.has_animation("a_stand_move_to_still"))
	assert(ANIMATION_FRAMES.has_animation("a_crouch_still"))
	assert(ANIMATION_FRAMES.has_animation("a_crouch_still_to_move"))
	assert(ANIMATION_FRAMES.has_animation("a_crouch_move"))
	assert(ANIMATION_FRAMES.has_animation("a_crouch_move_to_still"))
	assert(ANIMATION_FRAMES.has_animation("a_jump"))
	
	assert(ANIMATION_FRAMES.has_animation("b_stand_still"))
	assert(ANIMATION_FRAMES.has_animation("b_stand_still_to_move"))
	assert(ANIMATION_FRAMES.has_animation("b_stand_move"))
	assert(ANIMATION_FRAMES.has_animation("b_stand_move_to_still"))
	assert(ANIMATION_FRAMES.has_animation("b_crouch_still"))
	assert(ANIMATION_FRAMES.has_animation("b_crouch_still_to_move"))
	assert(ANIMATION_FRAMES.has_animation("b_crouch_move"))
	assert(ANIMATION_FRAMES.has_animation("b_crouch_move_to_still"))
	assert(ANIMATION_FRAMES.has_animation("b_jump"))
	
	assert(ANIMATION_FRAMES.has_animation("default"))
	
	animated_sprite.frames = ANIMATION_FRAMES
	Global.player = self
	
	_animation_prefix = "" if _avatar_mode else "a"
	
func _process_transforming_effect(delta: float):
	if not _transforming:
		return
	
	_transforming_seconds += delta
	
	var t = _transforming_seconds
	
	if t >= 0.0 and t < 1.0:
		transform_effect.self_modulate.a = t
		freeze = true
		_transform_done = false
	elif t >= 1.0 and t < 2.0:
		if not _transform_done:
			_avatar_mode = not _avatar_mode
			_transform_done = true
		
		transform_effect.self_modulate.a = 1.0 - (t - 1.0)
	elif t >= 2.0:
		transform_effect.self_modulate.a = 0.0
		freeze = false
		_transforming = false
		_transforming_seconds = 0.0

func _process_collision_shapes():
	stand_collision.disabled = _crouching or _avatar_mode
	crouch_collision.disabled = not _crouching or _avatar_mode
	avatar_collision.disabled = not _avatar_mode

func toggle_avatar_mode():
	if not freeze:
		_transforming = not _transforming

func _process(delta: float):
	_process_transforming_effect(delta)
	_process_collision_shapes()

func _physics_process(delta: float):
	current_second += delta
	
	var direction = _get_direction()
	
	_process_crouch()
	_process_sprint()
	_process_velocity(delta, direction)
	_process_facing(direction)
	_process_animation(direction)
	_process_pickable_kick()

func _process_velocity(delta: float, direction: Vector2):
	if _avatar_mode:
		var next_velocity = _calculate_next_velocity(delta, direction, ACCELERATION)
		
		_current_velocity = move_and_slide(next_velocity)
	else:
		var next_velocity = _calculate_next_velocity(delta, direction, _current_acceleration)
		var on_platform = platform_detector_00.is_colliding() or platform_detector_01.is_colliding()
		
		if abs(_current_velocity.x) > EPS:
			var rad = WALK_WAVE_COUNT * current_second * _current_animation_speed * PI
			
			_current_acceleration = ACCELERATION * abs(sin(rad + WALK_WAVE_OFFSET * PI))	
		
		var snap_vector = -1 * FLOOR_NORMAL * FLOOR_DETECT_DISTANCE if direction.y == 0 else Vector2.ZERO
		
		_current_velocity = move_and_slide_with_snap(next_velocity, snap_vector, FLOOR_NORMAL, on_platform, 4, 0.9, false)

func _process_pickable_kick():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var body = collision.collider
		
		if body.is_in_group("pickable"):
			var position_diff = body.global_position - global_position
			
			body.apply_central_impulse(position_diff.normalized() * body.KICK_FORCE)

func _process_crouch():
	var crouch_pressed = Input.is_action_just_pressed("crouch")
	
	if crouch_pressed:
		_crouching = not _crouching

func _process_sprint():
	var sprint_pressed = Input.is_action_pressed("sprint")
	
	if Global.DEBUG:
		if Input.is_action_just_pressed("avatar"):
			toggle_avatar_mode()
	
	var can_go_up = _avatar_mode or (is_on_floor() and not _crouching)
	var speed_mod = SPRINT_SCALE if not _avatar_mode and sprint_pressed and can_go_up else 1.0
	
	_current_max_speed = speed_mod * MAX_SPEED
	_current_acceleration = speed_mod * ACCELERATION
	_current_animation_speed = speed_mod * ANIMATION_SPEED

func _process_animation(direction: Vector2):
	var next_animation = _get_next_animation(direction)
	
	if next_animation.freeze:
		animated_sprite.speed_scale = 0.0
	else:
		animated_sprite.speed_scale = _current_animation_speed
	
	var d = "_" if len(_animation_prefix) > 0 else ""
	
	animated_sprite.animation = _animation_prefix + d + next_animation.name

func _process_facing(direction: Vector2):
	if _avatar_mode:
		_animation_prefix = ""
	elif len(_animation_prefix) == 0:
		_animation_prefix = "a"
	
	if (GRAVITY > EPS and not is_on_floor() and not _avatar_mode) or direction.x == 0.0:
		return
	
	var m = 1.0 if direction.x > 0.0 else -1.0
	
	animated_sprite.scale.x = abs(animated_sprite.scale.x) * m
	crouch_collision.scale.x = abs(crouch_collision.scale.x) * m
	stand_collision.scale.x = abs(stand_collision.scale.x) * m
	avatar_collision.scale.x = abs(avatar_collision.scale.x) * m
	
	if not _avatar_mode and direction.x != 0.0:
		_animation_prefix = "a" if direction.x > 0.0 else "b"

func _get_direction():
	if freeze:
		return Vector2(0, 0)
	
	var top_colliding = top_detector.is_colliding()
	
	var right_strength = Input.get_action_strength("move_right")
	var left_strength = Input.get_action_strength("move_left")
	var up_strength = Input.get_action_strength("move_up")
	var down_strength = Input.get_action_strength("move_down")
	
	var can_go_up = _avatar_mode or (is_on_floor() and not _crouching and not top_colliding) or GRAVITY < EPS
	var can_go_down = _avatar_mode or (not is_on_floor() and not _crouching)
	
	var x = right_strength - left_strength
	var y = (down_strength if can_go_down else 0.0) - (up_strength if can_go_up else 0.0)
	
	return Vector2(x, y)

func _calculate_next_velocity(delta: float, direction: Vector2, acceleration: float):
	var next_velocity = _current_velocity
	
	if _avatar_mode or GRAVITY < EPS:
		# Slowing needs to be added, otherwise it would be more real, but hard to control
		next_velocity.x *= pow(FRICTION, delta)
		next_velocity.y *= pow(FRICTION, delta)
			
		if abs(next_velocity.y) > _current_max_speed:
			next_velocity.y = (next_velocity.y / abs(next_velocity.y)) * _current_max_speed
		elif direction.y != 0.0:
			next_velocity.y += direction.y * acceleration * delta
	else:
		if is_on_floor():
			next_velocity.x *= pow(FRICTION, delta)
			
			if direction.y < 0.0:
				next_velocity.y += direction.y * JUMP_FORCE
		else:
			next_velocity.y += GRAVITY * delta

	if abs(next_velocity.x) > _current_max_speed:
		next_velocity.x = (next_velocity.x / abs(next_velocity.x)) * _current_max_speed
	elif direction.x != 0.0:
		next_velocity.x += direction.x * acceleration * delta
	
	return next_velocity

func _get_next_animation(direction: Vector2):
	var next_animation = "default"
	var freeze = false
	
	var current_animation = animated_sprite.animation
	var last_frame = animated_sprite.frames.get_frame_count(current_animation) - 1
	var animation_looped = animated_sprite.frames.get_animation_loop(current_animation)
	
	if _avatar_mode:
		if direction.x == 0.0 and direction.y == 0.0:
			freeze = true
	else:
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
			
			next_animation = "jump"
			
			# When falling, freeze the current frame of the jump animation
			if _current_velocity.y > 0.0 and GRAVITY > EPS:
				freeze = true
	
	return {
		"name": next_animation,
		"freeze": freeze
	}
