class_name GameCamera 
extends Camera2D

# Node to follow
@export var follow_node: NodePath

# Initial position offset to start with
@export var follow_init_offset: Vector2 = Vector2(0.0, 0.0)

# Position offset to follow with
@export var follow_offset: Vector2 = Vector2(0.0, 0.0)

# Speed to follow with
@export var follow_speed: Vector2 = Vector2(1000.0, 1000.0)

# Maximum shake in pixels.
@export var shake_max_offset = Vector2(100, 75)

# Maximum rotation in radians
@export var shake_max_roll = 0.1

const debug_zoom_speed: Vector2 = Vector2(0.05, 0.05)
const debug_move_speed: Vector2 = Vector2(10.0, 10.0)

const follow_scale_speed_after_distance: float = 1200.0
const follow_reached_distance: float = 500.0

# Vector for scrolling background
var scrolling_vector: Vector2 = Vector2.ZERO

var shake: float = 0.0
var shake_offset_y: float = 0.0

var base_zoom: Vector2
var base_follow_speed: Vector2
var base_follow_offset: Vector2

var follow_target: Node2D = null
var disable_follow: float = false
var instant_follow: bool = false

signal target_reached

func _ready() -> void:
	assert(not position_smoothing_enabled, "Smoothing is not supported!")
	
	_process_current()
	
	base_zoom = zoom
	base_follow_speed = follow_speed
	base_follow_offset = follow_offset
	
	if follow_node:
		follow_target = get_node(follow_node)
		global_position = follow_target.global_position + follow_init_offset / zoom

func _process(delta: float) -> void:
	if Config.DEBUG:
		_process_debug_zoom_control()
	
	_process_current()
	_process_shake(delta)
	_process_follow(delta)

func _process_debug_zoom_control() -> void:
	var zoom_in = VirtualInput.get_action_strength("camera_zoom_in")
	var zoom_out = VirtualInput.get_action_strength("camera_zoom_out")
	
	var diff = -1 * debug_zoom_speed * zoom_in + debug_zoom_speed * zoom_out
	
	zoom = Vector2(max(0.01, zoom.x + diff.x), max(0.01, zoom.y + diff.y))
	
	var camera_left = VirtualInput.get_action_strength("camera_left")
	var camera_right = VirtualInput.get_action_strength("camera_right")
	var camera_up = VirtualInput.get_action_strength("camera_up")
	var camera_down = VirtualInput.get_action_strength("camera_down")
	
	var x = camera_right - camera_left
	var y = camera_down - camera_up
	
	position += Vector2(x, y) * debug_move_speed

func _process_current():
	if is_current() and CameraManager.current != self:
		CameraManager.set_current(self)

func _process_follow(delta: float) -> void:
	if not follow_target or disable_follow:
		return
	
	var destination = follow_target.global_position + follow_offset / zoom
	var direction = global_position.direction_to(destination)
	var distance = global_position.distance_to(destination)

	var speed_scale = min(distance / follow_scale_speed_after_distance, 1.0)
	var step = delta * speed_scale * follow_speed * direction
	var step_distance = global_position.distance_to(global_position + step)
	var diff = destination - global_position
	
	if instant_follow or step_distance > distance:
		step = diff
	
	global_position += step
	scrolling_vector += step
	
	if distance <= follow_reached_distance:
		emit_signal("target_reached")

func _process_shake(delta: float) -> void:
	if not shake:
		rotation = 0.0
		offset.x = 0.0
		offset.y = 0.0
		
		return
	
	shake_offset_y += delta
	
	rotation = shake_max_roll * shake * Tools.noise.get_noise_2d(Tools.noise.seed, shake_offset_y)
	offset.x = shake_max_offset.x * shake * Tools.noise.get_noise_2d(Tools.noise.seed * 2, shake_offset_y)
	offset.y = shake_max_offset.y * shake * Tools.noise.get_noise_2d(Tools.noise.seed * 3, shake_offset_y)

func change_zoom(amount: Vector2, duration: float) -> void:
	await Animator.run(self, "zoom", zoom, amount, duration)

func change_shake(amount: float, duration: float) -> void:
	await Animator.run(self, "shake", shake, amount, duration)

func reset(new_position: Vector2, with_scrolling_vector: bool = true) -> void:
	var old_position = global_position
	
	if with_scrolling_vector:
		scrolling_vector += new_position - old_position
	
	global_position = new_position
	
	CursorManager.reset(old_position, new_position)

func scale_follow_speed(value: float) -> void:
	follow_speed = base_follow_speed * value

func scale_follow_offset(value: float) -> void:
	follow_offset = base_follow_offset * value
