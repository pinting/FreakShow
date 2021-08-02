extends Node

# Actual mouse clicks and virtual ones are distinguished by their pressure value
const virtual_pressure: float = 0.123

# Maximum difference to compare pressure with
const eps: float = 0.01

# Disable every input
var disable: bool = false

# Disable motion input
var disable_motion: bool = false

var virtual_mouse_position: Vector2 = Vector2(0.0, 0.0)
var prev_virtual_mouse_position: Vector2 = Vector2(0.0, 0.0)

var prev_virtual_click_left: bool = false
var prev_virtual_click_right: bool = false

var using_virtual_input: bool = false

var test_mode: bool = false
var test_keys: Array = []

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

func set_virtual_mouse_position(viewport_position: Vector2, warp_cursor: bool, from_virtual: bool = false) -> void:
	prev_virtual_mouse_position = virtual_mouse_position
	virtual_mouse_position = viewport_position
	
	var relative = virtual_mouse_position - prev_virtual_mouse_position
	
	if warp_cursor:
		CursorManager.apply_movement(viewport_position, relative, from_virtual)

func get_world_mouse_position() -> Vector2:
	var camera = CameraManager.current
	
	if not camera:
		return Vector2.ZERO
	
	if not using_virtual_input:
		return camera.get_global_mouse_position()
	
	var project_size = get_project_size()
	
	# The virtual_mouse_position goes from (0, 0) to get_viewport().size
	var p = virtual_mouse_position / project_size
	
	# Cut if it is outside of the window and move the center to the origo
	p.x = max(0.0, min(1.0, p.x)) - 0.5
	p.y = max(0.0, min(1.0, p.y)) - 0.5
	
	return camera.get_camera_screen_center() + project_size * camera.zoom * p

func create_click_event(viewport_position: Vector2, button_index: int, pressed: bool) -> void:
	var event = InputEventMouseButton.new()
	
	# Documentation says this should be viewport relative, but it only works like this
	event.position = mouse_viewport_to_window_position(viewport_position)
	event.global_position = mouse_viewport_to_window_position(viewport_position)
	event.button_index = button_index
	event.pressed = pressed
	
	get_tree().input_event(event)

func create_move_event(viewport_position: Vector2, relative: Vector2, speed: Vector2, pressure: float) -> void:
	var event = InputEventMouseMotion.new()
	
	event.position = mouse_viewport_to_window_position(viewport_position)
	event.global_position = mouse_viewport_to_window_position(viewport_position)
	event.relative = relative
	event.speed = speed
	event.pressure = pressure
	
	get_tree().input_event(event)

func _input(event: InputEvent) -> void:
	var is_motion = event is InputEventMouseMotion
	
	if not is_motion or disable or disable_motion:
		return
	
	using_virtual_input = abs(event.pressure - virtual_pressure) < eps
	
	if not using_virtual_input:
		# When mouse is NOT captured, new position comes precalculated
		var mouse_position = event.position

		# When mouse is captured, new position needs to be calculated manually
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			mouse_position = virtual_mouse_position + event.relative
		
		set_virtual_mouse_position(mouse_position, true, false)

func _process(_delta: float) -> void:
	if disable:
		return
	
	if not disable_motion:
		_process_virtual_motion()
	
	_process_virtual_click()

func _process_virtual_motion() -> void:
	var virtual_mouse_right = VirtualInput.get_action_strength("virtual_mouse_right")
	var virtual_mouse_left = VirtualInput.get_action_strength("virtual_mouse_left")
	var virtual_mouse_up = VirtualInput.get_action_strength("virtual_mouse_up")
	var virtual_mouse_down = VirtualInput.get_action_strength("virtual_mouse_down")
	
	var virtual_mouse = Vector2(virtual_mouse_right - virtual_mouse_left, virtual_mouse_down - virtual_mouse_up)
	
	if virtual_mouse.x != 0.0 or virtual_mouse.y != 0.0:
		using_virtual_input = true
		
		var relative = virtual_mouse * Config.virtual_mouse_speed
		
		set_virtual_mouse_position(virtual_mouse_position + relative, true, true)
		create_move_event(virtual_mouse_position, relative, Config.virtual_mouse_speed, virtual_pressure)

func _process_virtual_click() -> void:
	var virtual_click_left = VirtualInput.is_action_pressed("virtual_click_left")
	var virtual_click_right = VirtualInput.is_action_pressed("virtual_click_right")
	
	if (prev_virtual_click_left and not virtual_click_left) or (not prev_virtual_click_left and virtual_click_left):
		prev_virtual_click_left = virtual_click_left
		using_virtual_input = true
		
		create_click_event(virtual_mouse_position, BUTTON_LEFT, virtual_click_left)
	
	if (prev_virtual_click_right and not virtual_click_right) or (not prev_virtual_click_right and virtual_click_right):
		prev_virtual_click_right = virtual_click_right
		using_virtual_input = true
		
		create_click_event(virtual_mouse_position, BUTTON_RIGHT, virtual_click_right)

func get_action_strength(action: String) -> float:
	if test_mode:
		return 1.0 if test_keys.has(action) else 0.0
	
	if disable:
		return 0.0
	
	return Input.get_action_strength(action)

func is_action_pressed(action: String) -> bool:
	if test_mode:
		return test_keys.has(action)
	
	if disable:
		return false
	
	return Input.is_action_pressed(action)

func is_action_just_pressed(action: String) -> bool:
	if test_mode:
		return test_keys.has(action)
	
	if disable:
		return false
	
	return Input.is_action_just_pressed(action)
