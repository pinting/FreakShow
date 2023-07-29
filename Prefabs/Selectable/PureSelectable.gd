class_name PureSelectable
extends Sprite2D

# Enable Selectable debug, results in a lot of console output
const DEBUG: bool = false

# Description key of the selectable
@export var description_key: String = ""

# Selection area
@export var selection_area: NodePath

# Cursor according to viewport (if false, according to world)
@export var viewport_based_cursor: bool = false

# Enable drag by cursor
@export var drag: bool = false

var disabled: bool = false
var hover_lock: bool = false

var prev_cursor_position: Vector2
var cursor_position: Vector2

var item_selected: Callable
var item_released: Callable

signal cursor_entered
signal cursor_exited
signal selected
signal released

func _ready() -> void:
	assert(is_in_group("selectable"), "Selectable not in group of 'selectable'")

func _process(_delta: float) -> void:
	if drag:
		_process_drag()

func _process_drag() -> void:
	prev_cursor_position = cursor_position
	cursor_position = CursorManager.get_position()
	
	if SelectableManager.is_selected(self):
		var diff = cursor_position - prev_cursor_position
		
		global_position += diff
	

func get_selection_area() -> Rect2:
	if selection_area:
		var area = get_node(selection_area)
		
		return area.get_rect()
	
	return get_rect()

func on_cursor_entered() -> void:
	if description_key:
		SubtitleManager.set_describe(get_instance_id(), Text.find(description_key))
	
	_debug("Cursor entered the PureSelectable %d" % get_instance_id())
	
	emit_signal("cursor_entered")

func on_cursor_exited() -> void:
	if description_key:
		SubtitleManager.reset_describe(get_instance_id())
	
	_debug("Cursor exited the PureSelectable %d" % get_instance_id())
	
	emit_signal("cursor_exited")

func on_selected() -> void:
	emit_signal("selected")

func on_released() -> void:
	emit_signal("released")

func _exit_tree():
	on_cursor_exited()

func disable() -> void:
	if disabled:
		return
	
	disabled = true
	hover_lock = false
	
	on_cursor_exited()

func enable() -> void:
	if not disabled:
		return
	
	disabled = false

func appear() -> void:
	visible = true

func disappear() -> void:
	visible = false

func _debug(message) -> void:
	if DEBUG:
		Tools.debug(message)

func create_clone() -> PureSelectable:
	return duplicate()
