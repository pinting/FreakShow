extends Node

# Enable debug messages
const DEBUG: bool = true

# Disable sounds
const NO_SOUNDS: bool = false

# Disable intro
const NO_INTRO: bool = true

# Low performance mode
const LOW_PERFORMANCE: bool = false

# Only use the virtual mouse
const ONLY_VIRTUAL_MOUSE: bool = false

# Virtual cursor instead of the windows one
const VIRTUAL_CURSOR: bool = false

# Virtual mouse speed
const VIRTUAL_MOUSE_SPEED: Vector2 = Vector2(3, 3)

# Max loading time per tick (in msec)
const LOADING_TIME_PER_TICK: int = 100

# Use Mac based joystick buttons
const MAC_VIRTUAL_INPUT_FIX = false

var current_camera: Camera2D = null
var players: Array = []
var subtitle_display: SubtitleDisplay = null
var subtitle: SubtitleManager = null
var viewable_display: CanvasLayer = null
var virtual_cursor: CanvasLayer = null
var random_generator: RandomNumberGenerator = null

# Disable every selectable object
var disable_selectable: bool = false

# Position on the viewport
var virtual_mouse_position: Vector2 = Vector2(0.0, 0.0)

var last_virtual_click_left: bool = false
var last_virtual_click_right: bool = false

var using_virtual: bool = ONLY_VIRTUAL_MOUSE
var pressure_virtual = max(0.1, min(0.9, randf()))

var loader = null

class SubtitleManager:
	var subtitle_queue = []
	
	func say(text: String, speed: float = 2.0, timeout: float = 10.0) -> void:
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
	
	func describe(key: int, text: String, keep: bool = false) -> void:
		if Global.subtitle_display:
			Global.subtitle_display.describe(key, text, keep)
	
	func describe_remove(key: int, force: bool = false) -> void:
		if Global.subtitle_display:
			Global.subtitle_display.describe_remove(key, force)

func _ready():
	random_generator = RandomNumberGenerator.new()
	subtitle = SubtitleManager.new()
	
	random_generator.randomize()
	
	if NO_SOUNDS:
		for i in range(AudioServer.bus_count):
			AudioServer.set_bus_volume_db(i, -500)

func timer(duration: float = 1.0) -> SceneTreeTimer:
	return get_tree().create_timer(duration)

func debug(message: String) -> void:
	if DEBUG:
		print(message)

func _mouse_viewport_to_window_position(viewport_position: Vector2) -> Vector2:
	var viewport_size = get_viewport().size
	var window_size = OS.window_size
	var ratio = window_size / viewport_size
	
	var project_width = ProjectSettings.get_setting("display/window/size/width")
	var project_height = ProjectSettings.get_setting("display/window/size/height")
	var project_size = Vector2(project_width, project_height)
	
	var base = (viewport_position / project_size) * viewport_size
	
	if ProjectSettings.get_setting("display/window/stretch/aspect") == "keep":
		if ratio.x > ratio.y:
			return base + Vector2((window_size.x - viewport_size.x * ratio.y) / 2.0, 0.0)
		elif ratio.y > ratio.x:
			return base + Vector2(0.0, (window_size.y - viewport_size.y * ratio.x) / 2.0)
	 
	return base

func _set_virtual_mouse_position(viewport_position: Vector2, change_cursor_position: bool = true) -> void:
	virtual_mouse_position = viewport_position
	
	if change_cursor_position:
		set_cursor_position(viewport_position)

func set_cursor_position(viewport_position) -> void:
	get_viewport().warp_mouse(viewport_position)
	
	if VIRTUAL_CURSOR and virtual_cursor:
		virtual_cursor.cursor.position = viewport_position
		virtual_cursor.visible = true

func get_world_mouse_position() -> Vector2:
	if not current_camera:
		return Vector2.ZERO
	
	if not using_virtual:
		return current_camera.get_global_mouse_position()
	
	var project_width = ProjectSettings.get_setting("display/window/size/width")
	var project_height = ProjectSettings.get_setting("display/window/size/height")
	var project_size = Vector2(project_width, project_height)
	
	# The virtual_mouse_position goes from (0, 0) to get_viewport().size
	var p = virtual_mouse_position / project_size
	
	# Cut if it is outside of the window and move the center to the origo
	p.x = max(0.0, min(1.0, p.x)) - 0.5
	p.y = max(0.0, min(1.0, p.y)) - 0.5
	
	return current_camera.get_camera_screen_center() + project_size * current_camera.zoom * p

func _create_click_event(viewport_position: Vector2, button_index: int, pressed: bool) -> void:
	var event = InputEventMouseButton.new()
	
	# Documentation says this should be viewport relative, but it only works like this
	event.position = _mouse_viewport_to_window_position(viewport_position)
	event.global_position = _mouse_viewport_to_window_position(viewport_position)
	event.button_index = button_index
	event.pressed = pressed
	
	get_tree().input_event(event)

func _create_move_event(viewport_position: Vector2, relative: Vector2, pressure: float) -> void:
	var event = InputEventMouseMotion.new()
	
	event.position = _mouse_viewport_to_window_position(viewport_position)
	event.global_position = _mouse_viewport_to_window_position(viewport_position)
	event.relative = relative
	event.speed = VIRTUAL_MOUSE_SPEED
	event.pressure = pressure
	
	get_tree().input_event(event)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not ONLY_VIRTUAL_MOUSE:
		using_virtual = event.pressure == pressure_virtual
		
		if not using_virtual:
			_set_virtual_mouse_position(event.position, false)

func _process_virtual_input(_delta: float) -> void:
	var directions = {
		"right": "virtual_mouse_right",
		"left": "virtual_mouse_left",
		"up": "virtual_mouse_up",
		"down": "virtual_mouse_down"
	}
	
	if MAC_VIRTUAL_INPUT_FIX:
		directions.right = "virtual_mouse_right"
		directions.left = "virtual_mouse_up"
		directions.up = "virtual_mouse_down"
		directions.down = "virtual_mouse_left"
	
	var virtual_mouse_right = Input.get_action_strength(directions.get("right"))
	var virtual_mouse_left = Input.get_action_strength(directions.get("left"))
	var virtual_mouse_up = Input.get_action_strength(directions.get("up"))
	var virtual_mouse_down = Input.get_action_strength(directions.get("down"))
	
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
		using_virtual = true
		
		_create_click_event(virtual_mouse_position, BUTTON_LEFT, virtual_click_left)
	
	if (last_virtual_click_right and not virtual_click_right) or (not last_virtual_click_right and virtual_click_right):
		last_virtual_click_right = virtual_click_right
		using_virtual = true
		
		_create_click_event(virtual_mouse_position, BUTTON_RIGHT, virtual_click_right)

func _process(delta: float) -> void:
	_process_virtual_input(delta)
	_process_loading(delta)

func _process_loading(_delta: float) -> void:
	if not loader:
		return
	
	var now = OS.get_ticks_msec()
	
	while OS.get_ticks_msec() < now + LOADING_TIME_PER_TICK:
		var result = loader.poll()
		
		if result == ERR_FILE_EOF:
			_set_new_scene(loader.get_resource())
			break
		elif result == OK:
			var current = loader.get_stage()
			var count = loader.get_stage_count()
			
			debug(str("Loader progress: ", current + 1, "/", count))
		else:
			debug("Error during loading!")
			loader = null
			break

func _set_new_scene(scene_resource) -> void:
	for player in players:
		player.get_parent().remove_child(player)
		player.queue_free()
	
	players = []
	
	if current_camera:
		current_camera.get_parent().remove_child(current_camera)
		current_camera.queue_free()
	
	current_camera = null
	
	if subtitle_display:
		subtitle_display.get_parent().remove_child(subtitle_display)
		subtitle_display.queue_free()
	
	subtitle_display = null
	
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	
	# This is needed to workaround canvas modulate glitches 
	for child in current_scene.get_children():
		if child.get("visible") != null:
			child.visible = false
		
		current_scene.remove_child(child)
		child.queue_free()
	
	current_scene.queue_free()
	
	var next_scene = scene_resource.instance()
	
	root.add_child(next_scene)
	
	loader = null

func load_scene(path) -> void:
	if loader:
		return
	
	loader = ResourceLoader.load_interactive(path)
	
	if loader == null:
		debug("Loader failed to initialize!")
