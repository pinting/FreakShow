extends Node

const cursor_default: Texture = preload("res://Assets/Cursor/Cursor_Default.png")
const cursor_pick: Texture = preload("res://Assets/Cursor/Cursor_Pick.png")
const cursor_view: Texture = preload("res://Assets/Cursor/Cursor_View.png")

signal display_changed

var display: VirtualCursorDisplay = null
var current_owner: int = -1

func set_display(cursor_display: VirtualCursorDisplay) -> void:
	if not cursor_display:
		return
	
	display = cursor_display
	VirtualInput.use_virtual_cursor = true
	
	reset_icon(-1, true)

	Tools.debug("Cursor display changed")
	emit_signal("display_changed")

func clear() -> void:
	if not display:
		Tools.debug("VirtualCursorDisplay not exists, but clear was called")
		return
	
	Tools.destroy(display)
	
	display = null
	VirtualInput.use_virtual_cursor = false

func is_free(owner: int):
	return not is_hidden() and (current_owner == -1 or current_owner == owner)

func _set_texture(texture: Resource) -> void:
	if VirtualInput.use_virtual_cursor:
		display.cursor.set_texture(texture)
	else:
		Input.set_custom_mouse_cursor(texture)

func set_icon(type: String, owner: int, force: bool = false):
	if not force and not is_free(owner):
		return
	
	if type == "default":
		_set_texture(cursor_default)
	elif type == "pick":
		_set_texture(cursor_pick)
	elif type == "view":
		_set_texture(cursor_view)
	else:
		Tools.debug("Non-existing cursor type was used!")
	
	current_owner = owner

func reset_icon(owner: float, force: bool = false):
	if current_owner == owner or force:
		set_icon("default", -1, true);

func get_position(viewport_based: bool = false) -> Vector2:
	if VirtualInput.use_virtual_cursor:
		if viewport_based:
			return display.get_viewport_position()
		
		return display.cursor.global_position
	
	if viewport_based:
		return VirtualInput.virtual_mouse_position
	
	return VirtualInput.get_world_mouse_position()

func apply_movement(diff: Vector2) -> void:
	var camera = CameraManager.current
	
	assert(camera, "No GameCamera is registered")
	
	display.cursor.global_position += diff * camera.zoom

func move_to_center() -> void:
	var center = VirtualInput.get_project_size() / 2

	if VirtualInput.use_virtual_cursor:
		VirtualInput.set_virtual_mouse_position(center, false)
		display.move_to_center()
	else:
		VirtualInput.set_virtual_mouse_position(center)

func show():
	if VirtualInput.use_virtual_cursor:
		display.cursor.show()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	VirtualInput.disable_movement = false

func hide(with_disable: bool = true):
	if VirtualInput.use_virtual_cursor:
		display.cursor.hide()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	if with_disable:
		VirtualInput.disable_movement = true

func is_hidden() -> bool:
	var physical_cursor_hidden = Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN
	var virtual_cursor_hidden = display and display.is_hidden()
	
	return physical_cursor_hidden or virtual_cursor_hidden
