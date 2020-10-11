extends Camera2D
class_name DefaultCamera 

# Maximum shake in pixels.
export var max_offset = Vector2(100, 75)

# Maximum rotation in radians
export var max_roll = 0.1

# Increase zoom by this amount
export var zoom_action: Vector2 = Vector2(10.0, 10.0)

# Speed of zoom
export var zoom_speed: float = 1.0

var noise: OpenSimplexNoise = OpenSimplexNoise.new()
var shake: float = 0.0
var shake_offset_y: float = 0.0
var is_action_zoom_on: bool = false
var zoom_base: Vector2

func _ready() -> void:
	assert(Global.current_camera == null)
	
	Global.current_camera = self
	
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2
	
	zoom_base = zoom

func _process(delta) -> void:
	_process_shake(delta)
	_process_zoom(delta)

func _process_shake(delta) -> void:
	if not shake:
		return
	
	shake_offset_y += delta
	
	rotation = max_roll * shake * noise.get_noise_2d(noise.seed, shake_offset_y)
	offset.x = max_offset.x * shake * noise.get_noise_2d(noise.seed * 2, shake_offset_y)
	offset.y = max_offset.y * shake * noise.get_noise_2d(noise.seed * 3, shake_offset_y)


func _process_zoom(delta) -> void:
	var camera = Global.current_camera
	
	if not camera:
		return
	
	var step = Vector2.ZERO
	
	if is_action_zoom_on and camera.zoom < zoom_action:
		step = delta * zoom_speed * (zoom_action - zoom_base)
	elif not is_action_zoom_on and camera.zoom > zoom_base:
		step = delta * zoom_speed * (zoom_base - zoom_action)
	
	camera.zoom += step

func zoom_action() -> void:
	is_action_zoom_on = true

func zoom_base() -> void:
	is_action_zoom_on = false
