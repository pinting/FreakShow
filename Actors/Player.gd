class_name Player
extends RigidBody2D

onready var character = $Character

const WALK_ACCEL = 500.0
const WALK_DEACCEL = 500.0
const WALK_MAX_VELOCITY = 170.0
const AIR_ACCEL = 50.0
const AIR_DEACCEL = 600.0
const JUMP_VELOCITY = 200
const STOP_JUMP_FORCE = 450.0
const MAX_FLOOR_AIRBORNE_TIME = 2

var animation_prefix = "b"
var siding_left = false
var jumping = false
var stopping_jump = false

var floor_h_velocity = 0.0
var airborne_time = 1e20

# Prepend side prefix (A or B) and set animation.
# @property name Name of the animation without side prefix.
func set_animation(name):
	character.animation = animation_prefix + "_" + name
	
# Update animation
# @property next_animation Name of the next animation without side prefix.
func update_animation(next_animation):
	var current_animation = character.animation

	if current_animation != animation_prefix + "_" + next_animation:
		set_animation(next_animation)

# Integrate forces (override).
# @property state State of the body.
func _integrate_forces(state):
	var lv = state.get_linear_velocity()
	var step = state.get_step()
	var next_animation = "stand"
	var will_side_left = siding_left
	
	# Get the controls.
	var move_left = Input.is_action_pressed("move_left")
	var move_right = Input.is_action_pressed("move_right")
	var jump = Input.is_action_pressed("jump")
	
	# Deapply prev floor velocity.
	lv.x -= floor_h_velocity
	floor_h_velocity = 0.0
	
	# Find the floor (a contact with upwards facing collision normal).
	var found_floor = false
	var floor_index = -1
	
	for x in range(state.get_contact_count()):
		var ci = state.get_contact_local_normal(x)
		
		if ci.dot(Vector2(0, -1)) > 0.6:
			found_floor = true
			floor_index = x
	
	if found_floor:
		airborne_time = 0.0
	else:
		airborne_time += step # Time it spent in the air.
	
	var on_floor = airborne_time < MAX_FLOOR_AIRBORNE_TIME

	# Process jump.
	if jumping:
		if lv.y > 0:
			# Set off the jumping flag if going down.
			jumping = false
		elif not jump:
			stopping_jump = true
		
		if stopping_jump:
			lv.y += STOP_JUMP_FORCE * step
	
	if on_floor:
		# Process logic when character is on floor.
		if move_left and not move_right:
			if lv.x > -WALK_MAX_VELOCITY:
				lv.x -= WALK_ACCEL * step
		elif move_right and not move_left:
			if lv.x < WALK_MAX_VELOCITY:
				lv.x += WALK_ACCEL * step
		else:
			var xv = abs(lv.x)
			xv -= WALK_DEACCEL * step
			if xv < 0:
				xv = 0
			lv.x = sign(lv.x) * xv
		
		# Check jump.
		if not jumping and jump:
			lv.y = -JUMP_VELOCITY
			jumping = true
			stopping_jump = false
		
		# Check siding.
		if lv.x < 0 and move_left:
			will_side_left = true
		elif lv.x > 0 and move_right:
			will_side_left = false
		if jumping:
			next_animation = "jump"
		elif abs(lv.x) < 0.1:
			next_animation = "stand"
		else:
			next_animation = "walk"
	else:
		# Process logic when the character is in the air.
		if move_left and not move_right:
			if lv.x > -WALK_MAX_VELOCITY:
				lv.x -= AIR_ACCEL * step
		elif move_right and not move_left:
			if lv.x < WALK_MAX_VELOCITY:
				lv.x += AIR_ACCEL * step
		else:
			var xv = abs(lv.x)
			
			xv -= AIR_DEACCEL * step
			
			if xv < 0:
				xv = 0
			lv.x = sign(lv.x) * xv
		
		next_animation = "jump"
	
	# Update siding
	if will_side_left != siding_left:
		if will_side_left:
			character.scale.x = -1 * abs(character.scale.x)
			animation_prefix = "a"
		else:
			character.scale.x = abs(character.scale.x)
			animation_prefix = "b"
		
		siding_left = will_side_left
	
	update_animation(next_animation)
	
	# Apply floor velocity.
	if found_floor:
		floor_h_velocity = state.get_contact_collider_velocity_at_position(floor_index).x
		lv.x += floor_h_velocity
	
	# Finally, apply gravity and set back the linear velocity.
	lv += state.get_total_gravity() * step
	state.set_linear_velocity(lv)
