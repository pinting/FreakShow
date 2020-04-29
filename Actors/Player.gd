class_name Player
extends Actor

const FLOOR_DETECT_DISTANCE = 20.0

onready var platform_detector = $PlatformDetector
onready var sprite = $AnimatedSprite

func _ready():
	pass

func _physics_process(_delta):
	var direction = get_direction()

	var is_jump_interrupted = Input.is_action_just_released("jump") and _velocity.y < 0.0
	
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)

	var snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE if direction.y == 0.0 else Vector2.ZERO
	var is_on_platform = platform_detector.is_colliding()
	
	_velocity = move_and_slide_with_snap(
		_velocity, snap_vector, FLOOR_NORMAL, not is_on_platform, 4, 0.9, false
	)
	
	if direction.x != 0:
		sprite.scale.x = 1 if direction.x > 0 else -1
	
	sprite.animation = get_animation()

func get_direction():
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1 if is_on_floor() and Input.is_action_just_pressed("jump") else 0
	)

func calculate_move_velocity(linear_velocity, direction, speed, is_jump_interrupted):
	var velocity = linear_velocity
	
	velocity.x = speed.x * direction.x
	
	if direction.y != 0.0:
		velocity.y = speed.y * direction.y
	
	if is_jump_interrupted:
		velocity.y = 0.0
	
	return velocity

func get_animation():
	var animation = "idle"
	
	if is_on_floor():
		animation = "run" if abs(_velocity.x) > 0.1 else "idle"
	else:
		animation = "fall" if _velocity.y > 0 else "jump"
	
	return animation
