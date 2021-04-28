class_name GameCamera 
extends Camera2D

# Maximum shake in pixels.
export var shake_max_offset = Vector2(100, 75)

# Maximum rotation in radians
export var shake_max_roll = 0.1

# Increase zoom by this amount
export var zoom_action: Vector2 = Vector2(10.0, 10.0)

# Speed of zoom
export var zoom_speed: float = 1.0

# Index of the player to follow
export var follow_player: int = 0

# Speed to follow the player with
export var follow_speed: Vector2 = Vector2(1000.0, 1000.0)

# Scale up the follow speed linearly from zero to max in this distance
export var follow_scale_speed_before: float = 1200.0

# Follow offset
export var follow_offset: Vector2 = Vector2(0.0, 0.0)

# Vector for scrolling background
var scrolling_vector: Vector2 = Vector2.ZERO

var noise: OpenSimplexNoise = OpenSimplexNoise.new()
var shake: float = 0.0
var shake_offset_y: float = 0.0
var is_action_zoom_on: bool = false
var follow_init_done: bool = false

var zoom_base: Vector2 = Vector2.ZERO

func _ready() -> void:
	assert(not smoothing_enabled, "Smoothing is not supported")
	
	Game.current_camera = self
	
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2
	
	zoom_base = zoom

func _process(delta: float) -> void:
	_process_shake(delta)
	_process_zoom(delta)
	_process_follow(delta)

func _process_follow(delta: float) -> void:
	if follow_player < 0 or follow_player >= len(Game.players):
		scrolling_vector = global_position
		return
	
	var player = Game.players[follow_player]
	
	if not follow_init_done:
		global_position = player.global_position + follow_offset
		follow_init_done = true
	
	var destination = player.global_position + follow_offset
	var direction = global_position.direction_to(destination)
	var distance = global_position.distance_to(destination)

	var speed_scale = min(distance / follow_scale_speed_before, 1.0)
	var step = delta * speed_scale * follow_speed * direction
	var step_distance = global_position.distance_to(global_position + step)

	if step_distance > distance:
		global_position += distance
		scrolling_vector += distance
	else:
		global_position += step
		scrolling_vector += step

func _process_shake(delta: float) -> void:
	if not shake:
		return
	
	shake_offset_y += delta
	
	rotation = shake_max_roll * shake * noise.get_noise_2d(noise.seed, shake_offset_y)
	offset.x = shake_max_offset.x * shake * noise.get_noise_2d(noise.seed * 2, shake_offset_y)
	offset.y = shake_max_offset.y * shake * noise.get_noise_2d(noise.seed * 3, shake_offset_y)

func _process_zoom(delta: float) -> void:
	var camera = Game.current_camera
	
	if not camera:
		return
	
	var step = Vector2.ZERO
	
	if is_action_zoom_on and camera.zoom < zoom_action:
		step = delta * zoom_speed * (zoom_action - zoom_base)
	elif not is_action_zoom_on and camera.zoom > zoom_base:
		step = delta * zoom_speed * (zoom_base - zoom_action)
	
	camera.zoom += step

func set_zoom_action() -> void:
	is_action_zoom_on = true

func revert_zoom() -> void:
	is_action_zoom_on = false

func destroy() -> void:
	get_parent().remove_child(self)
	queue_free()

func reset(new_position) -> void:
	scrolling_vector += new_position - global_position
	global_position = new_position
