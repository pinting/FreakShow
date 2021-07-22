class_name GameCamera 
extends Camera2D

# Node to follow
export (NodePath) var follow_node

# Initial position offset to start with
export var follow_init_offset: Vector2 = Vector2(0.0, 0.0)

# Position offset to follow with
export var follow_offset: Vector2 = Vector2(0.0, 0.0)

# Speed to follow with
export var follow_speed: Vector2 = Vector2(1000.0, 1000.0)

# Distance to reach the follow speed
export var follow_scale_speed_before: float = 1200.0

# Distance under the reached signal is emitted
export var follow_reached_distance: float = 500.0

# Move cursor with follow
export var follow_move_cursor: bool = false

# Maximum shake in pixels.
export var shake_max_offset = Vector2(100, 75)

# Maximum rotation in radians
export var shake_max_roll = 0.1

onready var tween: Tween = $Tween

# Vector for scrolling background
var scrolling_vector: Vector2 = Vector2.ZERO

var shake: float = 0.0
var shake_offset_y: float = 0.0

var base_zoom: Vector2
var base_follow_speed: Vector2
var base_follow_offset: Vector2

var disable_follow: float = false
var instant_follow: bool = false

signal target_reached

func _ready() -> void:
	assert(not smoothing_enabled, "Smoothing is not supported!")
	
	_process_current()
	
	base_zoom = zoom
	base_follow_speed = follow_speed
	base_follow_offset = follow_offset
	
	if follow_node:
		global_position = get_node(follow_node).global_position + follow_init_offset

func update_position() -> void:
	global_position = get_node(follow_node).global_position + follow_offset

func _process(delta: float) -> void:
	_process_current()
	_process_shake(delta)
	_process_follow(delta)

func _process_current():
	if current and CameraManager.current != self:
		CameraManager.set_current(self)

func _process_follow(delta: float) -> void:
	if not follow_node or disable_follow:
		return
	
	var destination = get_node(follow_node).global_position + follow_offset
	var direction = global_position.direction_to(destination)
	var distance = global_position.distance_to(destination)

	var speed_scale = min(distance / follow_scale_speed_before, 1.0)
	var step = delta * speed_scale * follow_speed * direction
	var step_distance = global_position.distance_to(global_position + step)
	var diff = destination - global_position
	
	if instant_follow or step_distance > distance:
		step = diff
	
	global_position += step
	scrolling_vector += step
	
	if distance <= follow_reached_distance:
		emit_signal("target_reached")
	
	if follow_move_cursor:
		var cursor_display = VirtualCursorManager.display
		
		if cursor_display:
			cursor_display.cursor.global_position += step

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
	tween.stop(self, "zoom")
	
	tween.interpolate_property(
		self,
		"zoom",
		zoom,
		amount,
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	
	tween.start()

func change_shake(amount: float, duration: float) -> void:
	tween.stop(self, "shake")
	
	tween.interpolate_property(
		self,
		"shake",
		shake,
		amount,
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	
	tween.start()

func reset(new_position: Vector2, with_scrolling_vector: bool = true) -> void:
	var cursor_display = VirtualCursorManager.display
	
	assert(cursor_display, "VirtualCursorDisplay is not registered")
	
	var old_position = global_position
	
	if with_scrolling_vector:
		scrolling_vector += new_position - old_position
	
	var cursor_diff = old_position - cursor_display.cursor.global_position
	
	global_position = new_position
	
	cursor_display.correct_position()
	cursor_display.cursor.global_position = new_position - cursor_diff

func scale_follow_speed(scale: float) -> void:
	follow_speed = base_follow_speed * scale

func scale_follow_offset(scale: float) -> void:
	follow_offset = base_follow_offset * scale
