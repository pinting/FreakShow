class_name Player
extends KinematicBody2D

# Animation
export var animation_frames = preload("res://Animations/Player00.tres")

# Transform effect
export var transform_effect = preload("res://Prefabs/Effect/Effect_Transforming.tscn")

# Death effect
export var death_effect = preload("res://Prefabs/Effect/Effect_PlayerDeath.tscn")

# Register player to the store
export var register_player: bool = true

# Sync player movement with others
export var sync_player: bool = false

# Disable jumping
export var disable_jump: bool = false

# Max velocity
export var max_speed: float = 320.0

# Max acceleration
export var normal_acceleration: float = 800.0

# Friction on the platform (only X axis)
export var friction: float = 0.001

# Avatar max speed
export var avatar_max_speed: float = 900.0

# Avatar acceleration
export var avatar_acceleration: float = 1800.0

# Jump force
export var jump_force: float = 800.0

# Gravity (only Y axis)
export var gravity: float = 1000.0

# Speed of the animation
export var animation_speed: float = 0.95

# In which direction does the floor pushes the player
export var floor_normal: Vector2 = Vector2.UP

# The player dies after taking this amount of a hit
export var hit_to_die: Vector2 = Vector2(20.0, 50.0)

# Scale velocity
export var scale_velocity: Vector2 = Vector2(1.0, 1.0)

# Force pickable bodies are kicked with
export var kick_force = Vector2(10.0, 0.0)

# Force pickable bodies are pushed with
export var push_force = Vector2(1.0, 1.0)

# Duration of the transform effect
const transform_duration: float = 2.0

# Since player after this amount of seconds passed
const sync_player_delay: float = 2.0

# Floor detect distance
const floor_detect_distance: float = 20.0

# Defines how many waves (0% to 100% to 0% in walk acceleration) happen in a second 
const walk_wave_count: float = 1.25

# Offset walk waves (e.g. 0.5 equals start at 100% in walk acceleration)
const walk_wave_offset: float = 0.5

# A small number which is used to check for near-ZERO numbers
const eps: float = 1.0

onready var tween = $Tween
onready var animated_sprite = $AnimatedSprite

onready var platform_detector_00 = $PlatformDetector00
onready var platform_detector_01 = $PlatformDetector01
onready var top_detector = $TopDetector

onready var stand_collision_shape = $StandCollisionShape
onready var crouch_collision_shape = $CrouchCollisionShape
onready var avatar_collision_shape = $AvatarCollisionShape

onready var kick_area = $KickArea
onready var kick_area_collision_shape = $KickArea/CollisionShape

onready var transform_sound = $TransformSound
onready var transform_effect_container = $TransformEffectContainer

signal reseted
signal died

var current_second: float = 0.0

# Prefix of the current animation
var animation_prefix: String = ""

# Current velocity (between 0 and current_max_speed)
var current_velocity: Vector2 = Vector2.ZERO

# Current maximum speed (the acceleration oscillates between this and zero)
var current_max_speed: float = max_speed

# Transition between two blocks of animation
var transition: bool = false

# Moving in X direction
var moving_x: bool = false

# Enable crouching
var crouching: bool = false

# Force gravity even when frozen
var force_gravity: bool = false

# Is the player dead
var dead: bool = false

# Is the player frozen
var frozen: bool = false

# Enable or disable avatar mode
var avatar_mode: bool = false

# Register player to players list
var register: bool = register_player

# Skip the (local) velocity process
var skip_next_velocity_process: bool = false

func _ready() -> void:
	set_animation_frames(animation_frames)
	
	animation_prefix = "" if avatar_mode else "a"
	
	if register:
		PlayerManager.register(self)

func set_animation_frames(frames) -> void:
	assert(frames != null, "No animation is set for player!")
	
	assert(frames.has_animation("a_stand_still"), "Bad animation")
	assert(frames.has_animation("a_stand_still_to_move"), "Bad animation")
	assert(frames.has_animation("a_stand_move"), "Bad animation")
	assert(frames.has_animation("a_stand_move_to_still"), "Bad animation")
	assert(frames.has_animation("a_crouch_still"), "Bad animation")
	assert(frames.has_animation("a_crouch_still_to_move"), "Bad animation")
	assert(frames.has_animation("a_crouch_move"), "Bad animation")
	assert(frames.has_animation("a_crouch_move_to_still"), "Bad animation")
	assert(frames.has_animation("a_jump"), "Bad animation")
	
	assert(frames.has_animation("b_stand_still"), "Bad animation")
	assert(frames.has_animation("b_stand_still_to_move"), "Bad animation")
	assert(frames.has_animation("b_stand_move"), "Bad animation")
	assert(frames.has_animation("b_stand_move_to_still"), "Bad animation")
	assert(frames.has_animation("b_crouch_still"), "Bad animation")
	assert(frames.has_animation("b_crouch_still_to_move"), "Bad animation")
	assert(frames.has_animation("b_crouch_move"), "Bad animation")
	assert(frames.has_animation("b_crouch_move_to_still"), "Bad animation")
	assert(frames.has_animation("b_jump"), "Bad animation")
	
	assert(frames.has_animation("default"), "Bad animation")
	
	animated_sprite.frames = frames

func _process_collision_shapes() -> void:
	stand_collision_shape.disabled = dead or crouching or avatar_mode
	crouch_collision_shape.disabled = dead or not crouching or avatar_mode
	avatar_collision_shape.disabled = dead or not avatar_mode
	kick_area_collision_shape.disabled = dead or avatar_mode

func toggle_avatar_mode() -> void:
	if tween.is_active():
		return
	
	Tools.play_packed_effect(transform_effect, self, transform_duration)
	transform_sound.play()
	
	tween.interpolate_property(
		transform_effect_container,
		"modulate:a",
		0.0,
		1.0,
		transform_duration / 2.0,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	
	tween.start()
	
	yield(tween, "tween_all_completed")
	
	avatar_mode = not avatar_mode
	
	tween.interpolate_property(
		transform_effect_container,
		"modulate:a",
		1.0,
		0.0,
		transform_duration / 2.0,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	
	tween.start()
	
	yield(tween, "tween_all_completed")
	
	tween.stop_all()

func enable_avatar_mode() -> void:
	if not avatar_mode:
		yield(toggle_avatar_mode(), "completed")

func disable_avatar_mode() -> void:
	if avatar_mode:
		yield(toggle_avatar_mode(), "completed")

func _process(delta: float) -> void:
	if dead:
		return
	
	_process_collision_shapes()

func _physics_process(delta: float) -> void:
	if dead:
		return
	
	current_second += delta
	
	var direction = _get_direction()
	
	_process_crouch()
	_process_velocity(delta, direction)
	_process_facing(direction)
	_process_animation(direction)
	_process_fall_damage()
	_process_pickable_kick()

func _process_fall_damage():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		
		if not collision:
			continue
		
		var hit = collision.travel - collision.remainder
		
		if hit.abs() > hit_to_die:
			pass

func manual_process_velocity(delta: float, direction: Vector2):
	_process_velocity(delta, direction, true)
	
	skip_next_velocity_process = true

func _process_velocity(delta: float, direction: Vector2, skip_sync: bool = false) -> void:
	if skip_next_velocity_process:
		skip_next_velocity_process = false
		return
	
	if frozen:
		if not avatar_mode and force_gravity:
			var next_velocity = _calculate_next_velocity(delta, Vector2.ZERO, normal_acceleration, skip_sync)
			var on_platform = platform_detector_00.is_colliding() or platform_detector_01.is_colliding()
			var snap_vector = -1 * floor_normal * floor_detect_distance if direction.y == 0 else Vector2.ZERO
			
			current_velocity = move_and_slide_with_snap(next_velocity, snap_vector, floor_normal, on_platform, 4, 0.9, false)
		else:
			current_velocity = Vector2.ZERO
	elif avatar_mode:
		var next_velocity = _calculate_next_velocity(delta, direction, avatar_acceleration, skip_sync)
		
		current_velocity = move_and_slide(next_velocity)
	else:
		var next_velocity = _calculate_next_velocity(delta, direction, normal_acceleration, skip_sync)
		var on_platform = platform_detector_00.is_colliding() or platform_detector_01.is_colliding()
		
		if abs(current_velocity.x) > eps:
			var s = walk_wave_count * current_second * animation_speed + walk_wave_offset
			
			current_max_speed = max_speed * abs(sin(PI * s))	
		
		var snap_vector = -1 * floor_normal * floor_detect_distance if direction.y == 0 else Vector2.ZERO
		
		current_velocity = move_and_slide_with_snap(next_velocity, snap_vector, floor_normal, on_platform, 4, 0.9, false)

func _push_pickable(body: Node, force: Vector2) -> void:
	var position_diff = body.global_position - global_position
	var direction = position_diff.normalized()
	
	if body.is_in_group("pickable"):
		body.push(direction * force)

func _process_pickable_kick() -> void:
	# Body kick force (when touches the lower part of the body)
	for body in kick_area.get_overlapping_bodies():
		if body and body.is_in_group("pickable"):
			_push_pickable(body, kick_force)

	# Body push force (when touches the body)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var body = collision.collider
		
		if body and body.is_in_group("pickable"):
			_push_pickable(body, push_force)

func _process_crouch() -> void:
	var crouch_pressed = VirtualInput.is_action_just_pressed("player_crouch")
	
	if crouch_pressed:
		crouching = not crouching

func _process_animation(direction: Vector2) -> void:
	var next_animation = _get_next_animation(direction)
	
	if next_animation.pause:
		animated_sprite.speed_scale = 0.0
	else:
		animated_sprite.speed_scale = animation_speed
	
	var d = "_" if len(animation_prefix) > 0 else ""
	
	animated_sprite.animation = animation_prefix + d + next_animation.name

func _process_facing(direction: Vector2) -> void:
	if avatar_mode:
		animation_prefix = ""
	elif len(animation_prefix) == 0:
		animation_prefix = "a"
	
	if (gravity > eps and not is_on_floor() and not avatar_mode) or direction.x == 0.0:
		return
	
	var m = 1.0 if direction.x > 0.0 else -1.0
	
	animated_sprite.scale.x = abs(animated_sprite.scale.x) * m
	crouch_collision_shape.scale.x = abs(crouch_collision_shape.scale.x) * m
	stand_collision_shape.scale.x = abs(stand_collision_shape.scale.x) * m
	avatar_collision_shape.scale.x = abs(avatar_collision_shape.scale.x) * m
	
	if not avatar_mode and direction.x != 0.0:
		animation_prefix = "a" if direction.x > 0.0 else "b"

func _get_direction() -> Vector2:
	if frozen:
		return Vector2(0, 0)
	
	var top_colliding = top_detector.is_colliding()
	
	var right_strength = VirtualInput.get_action_strength("player_right")
	var left_strength = VirtualInput.get_action_strength("player_left")
	var up_strength = VirtualInput.get_action_strength("player_up")
	var down_strength = VirtualInput.get_action_strength("player_down")
	
	var on_floor = is_on_floor()
	var can_jump = on_floor and not crouching and not top_colliding and not disable_jump
	var can_go_up = avatar_mode or gravity < eps or can_jump
	var can_go_down = avatar_mode or (not on_floor and not crouching)
	
	var x = right_strength - left_strength
	var y = (down_strength if can_go_down else 0.0) - (up_strength if can_go_up else 0.0)
	
	return Vector2(x, y)

func _calculate_next_velocity(delta: float, direction: Vector2, acceleration: float, skip_sync: bool) -> Vector2:
	var next_velocity = current_velocity
	
	direction *= scale_velocity
	
	# In case of avatar mode is enabled
	if avatar_mode or abs(gravity) < eps:
		if direction.y != 0.0 and abs(next_velocity.y) < avatar_max_speed:
			# Apply acceleration on Y
			next_velocity.y += direction.y * acceleration * delta
		
		if direction.y == 0.0 or direction.y * next_velocity.y < 0.0:
			# Apply friction on Y
			next_velocity.y *= pow(friction, delta)
		
		# Apply acceleration on X
		if direction.x != 0.0 and abs(next_velocity.x) < avatar_max_speed:
			next_velocity.x += direction.x * acceleration * delta
			
		if direction.x == 0.0 or direction.x * next_velocity.x < 0.0:
			# Apply friction on X
			next_velocity.x *= pow(friction, delta)
	else:
		if is_on_floor():
			# Apply jump force on Y
			if direction.y < 0.0:
				next_velocity.y += direction.y * jump_force
		
			if direction.x == 0.0 or direction.x * next_velocity.x < 0.0:
				# Apply friction on X
				next_velocity.x *= pow(friction, delta)
		else:
			# Apply gravity on Y
			next_velocity.y += gravity * delta
		
		if direction.x != 0.0 and abs(next_velocity.x) < current_max_speed:
			# Apply acceleration on X
			next_velocity.x += direction.x * acceleration * delta
	
	# Sync X velocity of players
	if not skip_sync and sync_player and current_second > sync_player_delay:
		var selected_abs_v_x = abs(next_velocity.x)

		for player in PlayerManager.players:
			if player == self:
				continue
			
			player.manual_process_velocity(delta, direction)
			
			if abs(player.current_velocity.x) < selected_abs_v_x:
				selected_abs_v_x = abs(player.current_velocity.x)
		
		if abs(next_velocity.x) > selected_abs_v_x:
			var scaled_min_v_x = selected_abs_v_x
			
			if next_velocity.x != 0.0:
				scaled_min_v_x *= next_velocity.x / abs(next_velocity.x)
			
			next_velocity.x = scaled_min_v_x
	
	return next_velocity

func freeze(with_gravity: bool = false) -> void:
	force_gravity = with_gravity
	frozen = true

func unfreeze() -> void:
	if not tween.is_active():
		frozen = false

func kill() -> void:
	if dead:
		return
	
	dead = true
	frozen = true
	animated_sprite.visible = false
	
	Tools.play_packed_effect(death_effect, self)
	
	_process_collision_shapes()
	emit_signal("died")

func is_dead() -> bool:
	return dead

func reset(start_in_avatar_mode: bool = false) -> void:
	animated_sprite.visible = true
	current_velocity = Vector2.ZERO
	dead = false
	avatar_mode = start_in_avatar_mode
	frozen = false
	
	emit_signal("reseted")

func _get_next_animation(direction: Vector2) -> Dictionary:
	var next_animation = "default"
	var pause = false
	
	var current_animation = animated_sprite.animation
	var last_frame = animated_sprite.frames.get_frame_count(current_animation) - 1
	var animation_looped = animated_sprite.frames.get_animation_loop(current_animation)
	
	if avatar_mode:
		if direction.x == 0.0 and direction.y == 0.0:
			pause = true
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
			
			if crouching:
				next_animation = "crouch_still"
			else:
				next_animation = "jump"
			
			# When falling, pause the current frame of the jump animation
			if current_velocity.y > 0.0 and gravity > eps:
				pause = true
	
	return {
		"name": next_animation,
		"pause": pause
	}

func create_clone():
	var clone = duplicate()

	# Disable register property of clones
	clone.register = false
	
	return clone
