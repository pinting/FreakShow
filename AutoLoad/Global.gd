extends Node

# Enable debug messages
const DEBUG: bool = true

# Disable sounds
const NO_SOUNDS: bool = false

# Disable intro
const NO_INTRO: bool = false

# Virtual mouse
const VIRTUAL_MOUSE: Vector2 = Vector2(3, 3)

# Max loading time per tick (in msec)
const MAX_LOADING_TIME: int = 100

# Use virtual input 
const USING_VIRTUAL: bool = true

var current_camera: Camera2D = null
var player: Player = null
var subtitle_display: SubtitleDisplay = null
var subtitle: SubtitleManager = null
var virtual_mouse_position: Vector2 = Vector2(0.0, 0.0)
var last_virtual_click_left: bool = false
var last_virtual_click_right: bool = false

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
	virtual_mouse_position = get_viewport().size / 2

func debug(message: String):
	if DEBUG:
		print(message)

func get_scene_mouse_position():
	if not current_camera:
		return Vector2.ZERO
	
	if not USING_VIRTUAL:
		return current_camera.get_global_mouse_position()
	
	var center = virtual_mouse_position - (get_viewport().size / 2)
	
	center.x -= 0.5
	center.y -= 0.5
	
	return current_camera.get_camera_screen_center() + center * current_camera.zoom

func _create_click_event(button_index, pressed):
	var event = InputEventMouseButton.new()
	
	event.position = virtual_mouse_position
	event.button_index = BUTTON_LEFT
	event.pressed = pressed
	
	get_tree().input_event(event)
	
func _create_move_event(relative: Vector2):
	var event = InputEventMouseMotion.new()
	var p = virtual_mouse_position
	
	event.relative = relative
	event.speed = VIRTUAL_MOUSE
	event.global_position = p
	event.position = p
	
	get_tree().input_event(event)

func _process_input(delta: float):
	var right_strength = Input.get_action_strength("virtual_mouse_right")
	var left_strength = Input.get_action_strength("virtual_mouse_left")
	var up_strength = Input.get_action_strength("virtual_mouse_up")
	var down_strength = Input.get_action_strength("virtual_mouse_down")
	
	var virtual_click_left = Input.is_action_pressed("virtual_click_left")
	var virtual_click_right = Input.is_action_pressed("virtual_click_right")
	
	var strength = Vector2(right_strength - left_strength, down_strength - up_strength)
	
	if strength.x != 0.0 or strength.y != 0.0:
		var diff = strength * VIRTUAL_MOUSE
		
		virtual_mouse_position += diff
		
		Input.warp_mouse_position(virtual_mouse_position)
		_create_move_event(diff)
	
	if last_virtual_click_left or virtual_click_left:
		last_virtual_click_left = virtual_click_left
		_create_click_event(BUTTON_LEFT, virtual_click_left)
	
	if last_virtual_click_right or virtual_click_right:
		last_virtual_click_right = virtual_click_right
		_create_click_event(BUTTON_RIGHT, virtual_click_right)

func _process(delta: float):
	_process_input(delta)
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
