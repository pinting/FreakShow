extends Node

signal display_changed

const CURSOR_DEFAULT: Texture = preload("res://Assets/Cursor/Cursor_Default.png")
const CURSOR_PICK: Texture = preload("res://Assets/Cursor/Cursor_Pick.png")
const CURSOR_VIEW: Texture = preload("res://Assets/Cursor/Cursor_View.png")

const NO_OWNER = -1

var display: VirtualCursorDisplay = null
var current_owner: int = NO_OWNER

func _ready() -> void:
	reset_icon(NO_OWNER, true)

	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func set_display(cursor_display: VirtualCursorDisplay) -> void:
	if not cursor_display:
		return
	
	display = cursor_display
	VirtualInput.disable = is_lock_needed()
	
	reset_icon(NO_OWNER, true)
	Input.set_custom_mouse_cursor(null)

	if is_lock_needed():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	Tools.debug("Cursor display changed")
	emit_signal("display_changed")

func clear() -> void:
	if not display:
		Tools.debug("VirtualCursorDisplay not exists, but clear was called")
		return
	
	Tools.destroy_node(display)
	
	display = null
	VirtualInput.disable = is_lock_needed()

func is_free(owner: int):
	return not is_hidden() and (current_owner == NO_OWNER or current_owner == owner)

func set_cursor_texture(texture: Resource) -> void:
	if display:
		display.cursor.set_texture(texture)
	else:
		Input.set_custom_mouse_cursor(texture)

func set_icon(type: String, owner: int, force: bool = false):
	if not force and not is_free(owner):
		return
	
	match type:
		"default":
			set_cursor_texture(CURSOR_DEFAULT)
		"pick":
			set_cursor_texture(CURSOR_PICK)
		"view":
			set_cursor_texture(CURSOR_VIEW)
		_:
			Tools.debug("Non-existing cursor type was used!")
	
	current_owner = owner

func reset_icon(owner: int, force: bool = false):
	if current_owner == owner or force:
		set_icon("default", NO_OWNER, true);

func get_position(viewport_based: bool = false) -> Vector2:
	if display:
		if viewport_based:
			return display.get_viewport_position()
		
		return display.cursor.global_position
	
	if viewport_based:
		return VirtualInput.virtual_mouse_position
	
	return VirtualInput.get_world_mouse_position()

func apply_movement(viewport_position: Vector2, relative: Vector2, from_virtual: bool) -> void:
	if display:
		var camera = CameraManager.current
		
		assert(camera, "No GameCamera is registered")
		
		display.cursor.global_position += relative * camera.zoom
	elif from_virtual:
		get_viewport().warp_mouse(viewport_position)

func move_to_center() -> void:
	var center = VirtualInput.get_project_size() / 2

	if display:
		VirtualInput.set_virtual_mouse_position(center, false)
		display.move_to_center()
	else:
		VirtualInput.set_virtual_mouse_position(center, true, true)

func show(duration: float = 0.5):
	if display:
		display.show(duration)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	VirtualInput.disable = is_lock_needed()

func hide(duration: float = 0.5):
	if display:
		display.hide(duration)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func is_hidden() -> bool:
	var physical_cursor_hidden = Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN
	var virtual_cursor_hidden = display and display.is_hidden()
	
	return physical_cursor_hidden or virtual_cursor_hidden

func lock() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	VirtualInput.disable = is_lock_needed()

func release_lock() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	VirtualInput.disable = is_lock_needed()

func is_lock_needed() -> bool:
	return display and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if display:
		var is_cancel = Input.is_action_pressed("ui_cancel")
		var is_click = event is InputEventMouseButton 
		
		if is_cancel:
			release_lock()
		elif is_click and is_lock_needed():
			lock()

func reset(from: Vector2, to: Vector2) -> void:
	if display:
		display.reset(from, to)
