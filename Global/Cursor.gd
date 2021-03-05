extends Node

const cursor_default = preload("res://Assets/Cursor/Cursor_Default.png")
const cursor_pick = preload("res://Assets/Cursor/Cursor_Pick.png")
const cursor_view = preload("res://Assets/Cursor/Cursor_View.png")

var current_owner: int = -1
var is_hidden: bool = false

func is_free(owner: int):
	return current_owner == -1 or current_owner == owner

func set_icon(type: String, owner: int):
	if not is_free(owner):
		return
	
	if type == "default":
		Input.set_custom_mouse_cursor(cursor_default, Input.CURSOR_ARROW)
	elif type == "pick":
		Input.set_custom_mouse_cursor(cursor_pick, Input.CURSOR_ARROW)
	elif type == "view":
		Input.set_custom_mouse_cursor(cursor_view, Input.CURSOR_ARROW)
	else:
		Game.debug("Non-existing cursor type was used!")
	
	current_owner = owner

func reset_icon(owner: float, force: bool = false):
	if current_owner == owner or force:
		current_owner = -1
		set_icon("default", -1);

func show():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	is_hidden = false

func hide():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	is_hidden = true
