extends Node

# Enable debug messages
const DEBUG: bool = true

# Disable sounds
const NO_SOUNDS: bool = true

# Disable intro
const NO_INTRO: bool = false

# Virtual mouse speed
const VIRTUAL_MOUSE_SPEED: Vector2 = Vector2(3, 3)

# Max loading time per tick (in msec)
const MAX_LOADING_TIME: int = 100

var current_camera: Camera2D = null
var player: Player = null
var subtitle_display: SubtitleDisplay = null
var subtitle: SubtitleManager = null

# Position on the viewport
var virtual_mouse_position: Vector2 = Vector2(0.0, 0.0)

var last_virtual_click_left: bool = false
var last_virtual_click_right: bool = false

var using_virtual: bool = false
var pressure_virtual = max(0.1, min(0.9, randf()))

var loader = null

class SubtitleManager:
	var subtitle_queue = []
	
	func say(text: String, speed: float = 2.0, timeout: float = 10.0):
		if not Global.subtitle_display:
			subtitle_queue.push_back({
				"text": text,
				"speed": speed,
				"timeout": timeout
			})
		else:	
			for s in subtitle_queue:
				Global.subtitle_display.say(s.text, s.speed, s.timeout)
			
			Global.subtitle_display.say(text, speed, timeout)
	
	func describe(key: int, text: String):
		if Global.subtitle_display:
			Global.subtitle_display.describe(key, text)
	
	func describe_remove(key: int):
		if Global.subtitle_display:
			Global.subtitle_display.describe_remove(key)

func _ready():
	subtitle = SubtitleManager.new()
	
	_set_virtual_mouse_position(get_viewport().size / 2)
	
	if NO_SOUNDS:
		AudioServer.global_rate_scale = 0.0

func debug(message: String):
	if DEBUG:
		print(message)

func _mouse_viewport_to_window_position(viewport_position):
	var window_size = OS.window_size
	var viewport_size = get_viewport().size
	var ratio = window_size / viewport_size
	
	print(ratio)
	
	if ratio.x > ratio.y:
		return viewport_position * ratio.y + Vector2(0.0, (window_size.y - viewport_size.y * ratio.y) / 2)
	if ratio.y > ratio.x:
		return viewport_position * ratio.x + Vector2((window_size.x - viewport_size.x * ratio.x) / 2, 0.0)
	else:
		return viewport_position * ratio

func _set_virtual_mouse_position(viewport_position: Vector2, wrap_mouse_position: bool = true):
	virtual_mouse_position = viewport_position
	
	if wrap_mouse_position:
		Input.warp_mouse_position(_mouse_viewport_to_window_position(viewport_position))

func get_world_mouse_position():
	if not current_camera:
		return Vector2.ZERO
	
	if not using_virtual:
		return current_camera.get_global_mouse_position()
	
	# The virtual_mouse_position goes from (0, 0) to get_viewport().size
	var viewport = get_viewport()
	var p = virtual_mouse_position / viewport.size
	
	# Cut if it is outside of the window and move the center to the origo
	p.x = max(0.0, min(1.0, p.x)) - 0.5
	p.y = max(0.0, min(1.0, p.y)) - 0.5
	
	return current_camera.get_camera_screen_center() + viewport.size * current_camera.zoom * p

func _create_click_event(viewport_position: Vector2, button_index: int, pressed: bool):
	var event = InputEventMouseButton.new()
	
	# Documentation says this should be viewport relative, but it only works like this
	event.position = _mouse_viewport_to_window_position(viewport_position)
	event.global_position = _mouse_viewport_to_window_position(viewport_position)
	event.button_index = button_index
	event.pressed = pressed
	
	get_tree().input_event(event)

func _create_move_event(viewport_position: Vector2, relative: Vector2, pressure: float):
	var event = InputEventMouseMotion.new()
	
	event.position = _mouse_viewport_to_window_position(viewport_position)
	event.global_position = _mouse_viewport_to_window_position(viewport_position)
	event.relative = relative
	event.speed = VIRTUAL_MOUSE_SPEED
	event.pressure = pressure
	
	get_tree().input_event(event)

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		using_virtual = event.pressure == pressure_virtual

func _process_virtual_input(delta: float):
	if not using_virtual:
		_set_virtual_mouse_position(get_viewport().get_mouse_position(), false)
	
	var virtual_mouse_right = Input.get_action_strength("virtual_mouse_right")
	var virtual_mouse_left = Input.get_action_strength("virtual_mouse_left")
	var virtual_mouse_up = Input.get_action_strength("virtual_mouse_up")
	var virtual_mouse_down = Input.get_action_strength("virtual_mouse_down")
	
	var virtual_mouse = Vector2(virtual_mouse_right - virtual_mouse_left, virtual_mouse_down - virtual_mouse_up)
	
	if virtual_mouse.x != 0.0 or virtual_mouse.y != 0.0:
		using_virtual = true
		
		var relative = virtual_mouse * VIRTUAL_MOUSE_SPEED
		
		_set_virtual_mouse_position(virtual_mouse_position + relative)
		_create_move_event(virtual_mouse_position, relative, pressure_virtual)
	
	var virtual_click_left = Input.is_action_pressed("virtual_click_left")
	var virtual_click_right = Input.is_action_pressed("virtual_click_right")
	
	if (last_virtual_click_left and not virtual_click_left) or (not last_virtual_click_left and virtual_click_left):
		last_virtual_click_left = virtual_click_left
		_create_click_event(virtual_mouse_position, BUTTON_LEFT, virtual_click_left)
	
	if (last_virtual_click_right and not virtual_click_right) or (not last_virtual_click_right and virtual_click_right):
		last_virtual_click_right = virtual_click_right
		_create_click_event(virtual_mouse_position, BUTTON_RIGHT, virtual_click_right)

func _process(delta: float):
	_process_virtual_input(delta)
	_process_loading(delta)

func _process_loading(delta):
	if not loader:
		return
	
	var now = OS.get_ticks_msec()
	
	while OS.get_ticks_msec() < now + MAX_LOADING_TIME:
		var result = loader.poll()
		
		if result == ERR_FILE_EOF:
			var resource = loader.get_resource()
			loader = null
			_set_new_scene(resource)
			break
		elif result == OK:
			var current = loader.get_stage()
			var count = loader.get_stage_count()
			
			debug(str("Loader progress: ", current, "/", count))
		else:
			debug("Error during loading!")
			loader = null
			break

func _set_new_scene(scene_resource):
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	var next_scene = scene_resource.instance()
	
	# This is needed to workaround canvas modulate glitches 
	for child in current_scene.get_children():
		if child.get("visible") != null:
			child.visible = false
		
		child.queue_free()
	
	current_scene.queue_free()
	root.add_child(next_scene)

func load_scene(path):
	current_camera = null
	player = null
	Global.subtitle_display = null
	
	loader = ResourceLoader.load_interactive(path)
	
	if loader == null:
		debug("Loader failed to initialize!")
