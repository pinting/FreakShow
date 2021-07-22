extends Node

# Actual mouse clicks and virtual ones are distinguished by their pressure value
const VIRTUAL_PRESSURE: float = 0.0123456789

# Position on the viewport
var virtual_mouse_position: Vector2 = Vector2(0.0, 0.0)

# Previous position on the viewport
var last_virtual_mouse_position: Vector2 = Vector2(0.0, 0.0)

var last_virtual_click_left: bool = false
var last_virtual_click_right: bool = false
var using_virtual: bool = false

var test_mode: bool = false
var test_keys: Array = []

# Disable the movement of the mouse
var disable: bool = false

# Disable every selectable
var disable_selectable: bool = false

func set_position_to_center() -> void:
	_set_virtual_mouse_position(get_project_size() / 2, false)

func move_to_center() -> void:
	set_position_to_center()
	VirtualCursorManager.move_to_center()

func get_project_size() -> Vector2:
	var project_width = ProjectSettings.get_setting("display/window/size/width")
	var project_height = ProjectSettings.get_setting("display/window/size/height")
	
	return Vector2(project_width, project_height)

func mouse_viewport_to_window_position(viewport_position: Vector2) -> Vector2:
	var viewport_size = get_viewport().size
	var window_size = OS.window_size
	var ratio = window_size / viewport_size
	var project_size = get_project_size()
	var base = (viewport_position / project_size) * viewport_size
	
	if ProjectSettings.get_setting("display/window/stretch/aspect") == "keep":
		if ratio.x > ratio.y:
			return base + Vector2((window_size.x - viewport_size.x * ratio.y) / 2.0, 0.0)
		elif ratio.y > ratio.x:
			return base + Vector2(0.0, (window_size.y - viewport_size.y * ratio.x) / 2.0)
	 
	return base

func _set_virtual_mouse_position(viewport_position: Vector2, apply_cursor: bool = true) -> void:
	var camera = CameraManager.current
	
	if not camera:
		Tools.debug("No GameCamera is registered")
		return
	
	last_virtual_mouse_position = virtual_mouse_position
	virtual_mouse_position = viewport_position
	
	if apply_cursor:
		var diff = virtual_mouse_position - last_virtual_mouse_position
		
		VirtualCursorManager.display.cursor.global_position += diff * camera.zoom

func set_mouse_position(viewport_position) -> void:
	get_viewport().warp_mouse(viewport_position)

# Use VirtualCursorManager.get_world_cursor_position() instead
func get_world_mouse_position() -> Vector2:
	var camera = CameraManager.current
	
	if not camera:
		return Vector2.ZERO
	
	if not using_virtual:
		return camera.get_global_mouse_position()
	
	var project_size = get_project_size()
	
	# The virtual_mouse_position goes from (0, 0) to get_viewport().size
	var p = virtual_mouse_position / project_size
	
	# Cut if it is outside of the window and move the center to the origo
	p.x = max(0.0, min(1.0, p.x)) - 0.5
	p.y = max(0.0, min(1.0, p.y)) - 0.5
	
	return camera.get_camera_screen_center() + project_size * camera.zoom * p

func _create_click_event(viewport_position: Vector2, button_index: int, pressed: bool) -> void:
	var event = InputEventMouseButton.new()
	
	# Documentation says this should be viewport relative, but it only works like this
	event.position = mouse_viewport_to_window_position(viewport_position)
	event.global_position = mouse_viewport_to_window_position(viewport_position)
	event.button_index = button_index
	event.pressed = pressed
	
	get_tree().input_event(event)
	
	if not is_locked():
		lock_mouse()

func _create_move_event(viewport_position: Vector2, relative: Vector2, pressure: float) -> void:
	var event = InputEventMouseMotion.new()
	
	event.position = mouse_viewport_to_window_position(viewport_position)
	event.global_position = mouse_viewport_to_window_position(viewport_position)
	event.relative = relative
	event.speed = Config.virtual_mouse_speed
	event.pressure = pressure
	
	get_tree().input_event(event)
	
	if not is_locked():
		lock_mouse()

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		release_mouse()
	elif event is InputEventMouseButton and not is_locked():
			lock_mouse()
	elif event is InputEventMouseMotion and is_locked() and not disable:
		using_virtual = event.pressure == VIRTUAL_PRESSURE
		
		if not using_virtual:
			var mouse_position = virtual_mouse_position + event.relative

			_set_virtual_mouse_position(mouse_position)

func _process(_delta: float) -> void:
	# If OS is Windows
	var directions = {
		"right": "virtual_mouse_right",
		"left": "virtual_mouse_left",
		"up": "virtual_mouse_up",
		"down": "virtual_mouse_down"
	}

	# If OS is not Windows (tested using MacOS)
	if OS.get_name() != "Windows":
		directions.right = "virtual_mouse_right"
		directions.left = "virtual_mouse_up"
		directions.up = "virtual_mouse_down"
		directions.down = "virtual_mouse_left"
	
	var virtual_mouse_right = VirtualInput.get_action_strength(directions.get("right"))
	var virtual_mouse_left = VirtualInput.get_action_strength(directions.get("left"))
	var virtual_mouse_up = VirtualInput.get_action_strength(directions.get("up"))
	var virtual_mouse_down = VirtualInput.get_action_strength(directions.get("down"))
	
	var virtual_mouse = Vector2(virtual_mouse_right - virtual_mouse_left, virtual_mouse_down - virtual_mouse_up)
	
	if virtual_mouse.x != 0.0 or virtual_mouse.y != 0.0:
		using_virtual = true
		
		var relative = virtual_mouse * Config.virtual_mouse_speed
		
		_set_virtual_mouse_position(virtual_mouse_position + relative)
		_create_move_event(virtual_mouse_position, relative, VIRTUAL_PRESSURE)
	
	var virtual_click_left = VirtualInput.is_action_pressed("virtual_click_left")
	var virtual_click_right = VirtualInput.is_action_pressed("virtual_click_right")
	
	if (last_virtual_click_left and not virtual_click_left) or (not last_virtual_click_left and virtual_click_left):
		last_virtual_click_left = virtual_click_left
		using_virtual = true
		
		_create_click_event(virtual_mouse_position, BUTTON_LEFT, virtual_click_left)
	
	if (last_virtual_click_right and not virtual_click_right) or (not last_virtual_click_right and virtual_click_right):
		last_virtual_click_right = virtual_click_right
		using_virtual = true
		
		_create_click_event(virtual_mouse_position, BUTTON_RIGHT, virtual_click_right)

func get_action_strength(action: String) -> float:
	if test_mode:
		return 1.0 if test_keys.has(action) else 0.0
	
	if not is_locked() or disable:
		return 0.0
	
	return Input.get_action_strength(action)

func is_action_pressed(action: String) -> bool:
	if test_mode:
		return test_keys.has(action)
	
	if not is_locked() or disable:
		return false
	
	return Input.is_action_pressed(action)

func is_action_just_pressed(action: String) -> bool:
	if test_mode:
		return test_keys.has(action)
	
	if not is_locked() or disable:
		return false
	
	return Input.is_action_just_pressed(action)

func lock_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func is_locked() -> bool:
	return Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
