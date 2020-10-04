class_name Player
extends KinematicBody2D

# Animation
export (SpriteFrames) var animation_frames

# Max velocity
export var max_speed: float = 280.0

# Max acceleration
export var acceleration: float = 6000.0

# Defines how many waves (0% to 100% to 0% in walk acceleration) happen in a second 
export var walk_wave_count: float = 1.25

# Offset walk waves (e.g. 0.5 equals start at 100% in walk acceleration)
export var walk_wave_offset: float = 0.5

# Avatar max speed
export var avatar_max_speed: float = 450.0

# Avatar acceleration
export var avatar_acceleration: float = 8000.0

# Jump force
export var jump_force: float = 800.0

# Friction on the platform (only X axis)
export var friction: float = 0.001

# Gravity (only Y axis)
export var gravity: float = 800.0

# Sprint speed
export var sprint_scale: float = 1.35

# Speed of the animation (sprint modifies it)
export var animation_speed: float = 1.0

# In which direction does the floor pushes the player
export var floor_normal: Vector2 = Vector2.UP

# Floor detect distance
export var floor_detect_distance: float = 20.0

# Freeze the player in place
export var freeze: bool = false

# Enable or disable avatar mode
export var avatar_mode: bool = false

# The player dies after taking this amount of a hit
export var hit_to_die: Vector2 = Vector2(20.0, 50.0)

# Scale velocity
export var scale_velocity: Vector2 = Vector2(1, 1)

# Zero value
export var ZERO: float = 1.0

onready var platform_detector_00 = $PlatformDetector00
onready var platform_detector_01 = $PlatformDetector01
onready var top_detector = $TopDetector

onready var stand_collision = $StandCollision
onready var crouch_collision = $CrouchCollision
onready var avatar_collision = $AvatarCollision

onready var transform_effect = $TransformEffect
onready var death_effect = $DeathEffect

onready var animated_sprite = $AnimatedSprite

var current_second: float = 0.0

# Prefix of the current animation
var animation_prefix: String = ""

# Current velocity (between 0 and current_max_speed)
var current_velocity: Vector2 = Vector2.ZERO

# Current maximum speed (the acceleration oscillates between this and zero)
var current_max_speed: float = max_speed

# Current acceleration (it oscillates)
var current_acceleration: float = acceleration

# Current animation speed
var current_animation_speed: float = animation_speed

# Transition between two blocks of animation
var transition: bool = false

# Moving in X direction
var moving_x: bool = false

# Transformation in progress
var transforming: bool = false

# Transformation effect timeout counter
var transforming_seconds: float = 0.0

# Is transforming done
var transforming_done: bool = true

# Enable crouching
var crouching: bool = false

# Enable fast walking
var fast_walking: bool = false

# Force gravity even when freezed
var force_gravity: bool = false

# Is the player dead
var dead: bool = false

# Register player to players list
var register: bool = true

# Disable max speed
var no_max_speed: bool = false

func _ready() -> void:
	set_animation_frames(animation_frames)
	
	animation_prefix = "" if avatar_mode else "a"
	
	if register:
		Global.players.push_back(self)
		Global.debug("Player registered")

func set_animation_frames(frames) -> void:
	assert(frames != null)
	
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
	
	assert(frames.has_animation("default"))
	
	animated_sprite.frames = frames

func _process_transforming_effect(delta: float) -> void:
	if not transforming:
		transform_effect.self_modulate.a = 0.0
		return
	
	transforming_seconds += delta
	
	var t = transforming_seconds
	
	if t >= 0.0 and t < 1.0:
		transform_effect.emitting = true
		transform_effect.self_modulate.a = t
		freeze = true
		transforming_done = false
	elif t >= 1.0 and t < 2.0:
		if not transforming_done:
			avatar_mode = not avatar_mode
			transforming_done = true
		
		transform_effect.self_modulate.a = 1.0 - (t - 1.0)
	elif t >= 2.0:
		transform_effect.self_modulate.a = 0.0
		transform_effect.emitting = false
		freeze = false
		transforming = false
		transforming_seconds = 0.0

func _process_collision_shapes() -> void:
	stand_collision.disabled = dead or crouching or avatar_mode
	crouch_collision.disabled = dead or not crouching or avatar_mode
	avatar_collision.disabled = dead or not avatar_mode

func toggle_avatar_mode() -> void:
	if not freeze:
		transforming = not transforming

func enable_avatar_mode() -> void:
	if not avatar_mode:
		toggle_avatar_mode()

func disable_avatar_mode() -> void:
	if avatar_mode:
		toggle_avatar_mode()

func _process(delta: float) -> void:
	_process_transforming_effect(delta)
	_process_collision_shapes()

func _physics_process(delta: float) -> void:
	current_second += delta
	
	var direction = _get_direction()
	
	_process_crouch()
	_process_sprint()
	_process_velocity(delta, direction)
	_process_facing(direction)
	_process_animation(direction)
	_process_pickable_kick()
	_process_fall_damage()

func _process_fall_damage():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		
		if not collision:
			continue
		
		var hit = collision.travel - collision.remainder
		
		if hit.abs() > hit_to_die:
			pass

func _process_velocity(delta: float, direction: Vector2) -> void:
	if freeze:
		if not avatar_mode and force_gravity:
			var next_velocity = _calculate_next_velocity(delta, Vector2.ZERO, acceleration)
			var on_platform = platform_detector_00.is_colliding() or platform_detector_01.is_colliding()
			var snap_vector = -1 * floor_normal * floor_detect_distance if direction.y == 0 else Vector2.ZERO
			
			current_velocity = move_and_slide_with_snap(next_velocity, snap_vector, floor_normal, on_platform, 4, 0.9, false)
		else:
			current_velocity = Vector2.ZERO
	elif avatar_mode:
		var next_velocity = _calculate_next_velocity(delta, direction, avatar_acceleration)
		
		current_velocity = move_and_slide(next_velocity)
	else:
		var next_velocity = _calculate_next_velocity(delta, direction, current_acceleration)
		var on_platform = platform_detector_00.is_colliding() or platform_detector_01.is_colliding()
		
		if abs(current_velocity.x) > ZERO:
			var rad = walk_wave_count * current_second * current_animation_speed * PI
			
			current_acceleration = acceleration * abs(sin(rad + walk_wave_offset * PI))	
		
		var snap_vector = -1 * floor_normal * floor_detect_distance if direction.y == 0 else Vector2.ZERO
		
		current_velocity = move_and_slide_with_snap(next_velocity, snap_vector, floor_normal, on_platform, 4, 0.9, false)

func _process_pickable_kick() -> void:
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var body = collision.collider
		
		if body and body.is_in_group("pickable") and body.get("disabled") == false:
			var position_diff = body.global_position - global_position
			
			body._apply_force(position_diff.normalized() * body.KICK_FORCE)

func _process_crouch() -> void:
	var crouch_pressed = Input.is_action_just_pressed("crouch")
	
	if crouch_pressed:
		crouching = not crouching

func _process_sprint() -> void:
	var fast_walk_pressed = Input.is_action_just_pressed("fast_walk")
	
	if fast_walk_pressed:
		fast_walking = not fast_walking
	
	var can_go_up = avatar_mode or (is_on_floor() and not crouching)
	var speed_mod = sprint_scale if not avatar_mode and fast_walking and can_go_up else 1.0
	
	current_max_speed = speed_mod * max_speed
	current_acceleration = speed_mod * acceleration
	current_animation_speed = speed_mod * animation_speed

func _process_animation(direction: Vector2) -> void:
	var next_animation = _get_next_animation(direction)
	
	if next_animation.freeze:
		animated_sprite.speed_scale = 0.0
	else:
		animated_sprite.speed_scale = current_animation_speed
	
	var d = "_" if len(animation_prefix) > 0 else ""
	
	animated_sprite.animation = animation_prefix + d + next_animation.name

func _process_facing(direction: Vector2) -> void:
	if avatar_mode:
		animation_prefix = ""
	elif len(animation_prefix) == 0:
		animation_prefix = "a"
	
	if (gravity > ZERO and not is_on_floor() and not avatar_mode) or direction.x == 0.0:
		return
	
	var m = 1.0 if direction.x > 0.0 else -1.0
	
	animated_sprite.scale.x = abs(animated_sprite.scale.x) * m
	crouch_collision.scale.x = abs(crouch_collision.scale.x) * m
	stand_collision.scale.x = abs(stand_collision.scale.x) * m
	avatar_collision.scale.x = abs(avatar_collision.scale.x) * m
	
	if not avatar_mode and direction.x != 0.0:
		animation_prefix = "a" if direction.x > 0.0 else "b"

func _get_direction() -> Vector2:
	if freeze:
		return Vector2(0, 0)
	
	var top_colliding = top_detector.is_colliding()
	
	var right_strength = Input.get_action_strength("move_right")
	var left_strength = Input.get_action_strength("move_left")
	var up_strength = Input.get_action_strength("move_up")
	var down_strength = Input.get_action_strength("move_down")
	
	var can_go_up = avatar_mode or (is_on_floor() and not crouching and not top_colliding) or gravity < ZERO
	var can_go_down = avatar_mode or (not is_on_floor() and not crouching)
	
	var x = right_strength - left_strength
	var y = (down_strength if can_go_down else 0.0) - (up_strength if can_go_up else 0.0)
	
	return Vector2(x, y)

func _calculate_next_velocity(delta: float, direction: Vector2, acceleration: float) -> Vector2:
	var next_velocity = current_velocity
	var players = Global.players
	
	# In case of avatar mode is enabled
	if avatar_mode or abs(gravity) < ZERO:
		# Apply friction on X and Y
		next_velocity.x *= pow(friction, delta)
		next_velocity.y *= pow(friction, delta)
			
		# Apply acceleration on Y
		if abs(next_velocity.y) > avatar_max_speed and not no_max_speed:
			next_velocity.y = (next_velocity.y / abs(next_velocity.y)) * avatar_max_speed
		elif direction.y != 0.0:
			next_velocity.y += scale_velocity.y * direction.y * acceleration * delta
		
		# Apply acceleration on X
		if abs(next_velocity.x) > avatar_max_speed and not no_max_speed:
			next_velocity.x = (next_velocity.x / abs(next_velocity.x)) * avatar_max_speed
		elif direction.x != 0.0:
			next_velocity.x += scale_velocity.x * direction.x * acceleration * delta
	else:
		if is_on_floor():
			# Apply friction on X
			next_velocity.x *= pow(friction, delta)
			
			# Apply jump force on Y
			if direction.y < 0.0:
				next_velocity.y += scale_velocity.y * direction.y * jump_force
		else:
			# Apply gravity on Y
			next_velocity.y += scale_velocity.y * gravity * delta
		
		# Apply acceleration on X
		if abs(next_velocity.x) > current_max_speed and not no_max_speed:
			next_velocity.x = (next_velocity.x / abs(next_velocity.x)) * current_max_speed
		elif direction.x != 0.0:
			next_velocity.x += scale_velocity.x * direction.x * acceleration * delta
	
	var d = direction.length()
	
	if(next_velocity.x == NAN or next_velocity.y == NAN):
		return Vector2.ZERO
	
	# Makes n * 45 degree directions take the same distance over time
	next_velocity /= sqrt(d) if d > 1.0 else 1.0
	
	# Sync X velocity of players
	if current_second > 2.0:
		var min_v_x = next_velocity.x
		
		for player in players:
			if player != self and abs(player.current_velocity.x) < min_v_x:
					min_v_x = abs(player.current_velocity.x)
		
		if next_velocity.x > min_v_x:
			var scaled_min_v_x = min_v_x
			
			if next_velocity.x > 0.0:
				scaled_min_v_x *= next_velocity.x / abs(next_velocity.x)
			
			next_velocity.x = scaled_min_v_x
	
	return next_velocity

func freeze(with_gravity: bool = false) -> void:
	force_gravity = with_gravity
	freeze = true

func unfreeze() -> void:
	if not transforming:
		freeze = false

func kill() -> void:
	dead = true
	freeze = true
	transforming = false
	animated_sprite.visible = false
	death_effect.emitting = true

func is_dead() -> bool:
	return dead

func _get_next_animation(direction: Vector2) -> Dictionary:
	var next_animation = "default"
	var freeze = false
	
	var current_animation = animated_sprite.animation
	var last_frame = animated_sprite.frames.get_frame_count(current_animation) - 1
	var animation_looped = animated_sprite.frames.get_animation_loop(current_animation)
	
	if avatar_mode:
		if direction.x == 0.0 and direction.y == 0.0:
			freeze = true
	else:
		if is_on_floor():
			if direction.x and abs(current_velocity.x) > 0.0:
				if not moving_x:
					moving_x = true
					transition = true
				elif not animation_looped and animated_sprite.frame == last_frame:
					transition = false
					
				if transition:
					next_animation = "still_to_move"
				else:
					next_animation = "move"
			else:
				if moving_x:
					moving_x = false
					transition = true
				elif not animation_looped and animated_sprite.frame == last_frame:
					transition = false
					
				if transition:
					next_animation = "move_to_still"
				else:
					next_animation = "still"
					
			next_animation = ("crouch" if crouching else "stand") + "_" + next_animation
		else:
			if abs(current_velocity.x) > 0.0:
				moving_x = true
				transition = false
			
			next_animation = "jump"
			
			# When falling, freeze the current frame of the jump animation
			if current_velocity.y > 0.0 and gravity > ZERO:
				freeze = true
	
	return {
		"name": next_animation,
		"freeze": freeze
	}
