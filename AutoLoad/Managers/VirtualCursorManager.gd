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
	Tools.debug("Cursor display changed")
	emit_signal("display_changed")

func is_free(owner: int):
	return not is_hidden() and (current_owner == -1 or current_owner == owner)

func set_icon(type: String, owner: int, force: bool = false):
	if not display or (not force and not is_free(owner)):
		return
	
	if type == "default":
		display.cursor.texture = cursor_default
	elif type == "pick":
		display.cursor.texture = cursor_pick
	elif type == "view":
		display.cursor.texture = cursor_view
	else:
		Tools.debug("Non-existing cursor type was used!")
	
	current_owner = owner

func reset_icon(owner: float, force: bool = false):
	if current_owner == owner or force:
		set_icon("default", -1, true);

func get_viewport_cursor_position() -> Vector2:
	if not display:
		return Vector2.ZERO
	
	return display.get_viewport_position()

func move_to_center():
	if not display:
		Tools.debug("VirtualCursorDisplay not exists, but move_to_center was called")
		return
	
	display.move_to_center()

func show():
	if not display:
		Tools.debug("VirtualCursorDisplay not exists, but show was called")
		return
	
	display.cursor.show()
	
	VirtualInput.disable_movement = false

func hide(with_disable_movement: bool = true):
	if not display:
		Tools.debug("VirtualCursorDisplay not exists, but hide was called")
		return
	
	display.cursor.hide()
	
	if with_disable_movement:
		VirtualInput.disable_movement = true

func is_hidden() -> bool:
	return not display or display.is_hidden()
