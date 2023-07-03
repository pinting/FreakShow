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

var disabled: bool = false
var lock: bool = false

signal selected
signal cursor_entered
signal cursor_exited

func _ready() -> void:
	assert(is_in_group("selectable"), "Selectable not in group of 'selectable'")
	
	SelectableManager.connect("cursor_entered", Callable(self, "_on_cursor_entered"))
	SelectableManager.connect("cursor_exited", Callable(self, "_on_cursor_exited"))

func select() -> void:
	var is_disabled = SelectableManager.disable or disabled
	var is_selected = SelectableManager.is_selected(self)
	
	if not is_disabled and is_selected:
		emit_signal("selected")

func get_selection_area() -> Rect2:
	if selection_area:
		var area = get_node(selection_area)
		
		return area.get_rect()
	
	return get_rect()

func _on_cursor_entered(target: Object) -> void:
	if target != self:
		return
	
	if description_key:
		SubtitleManager.set_describe(get_instance_id(), Text.find(description_key))
	
	_debug("Cursor entered the PureSelectable %d" % get_instance_id())
	emit_signal("cursor_entered")

func _on_cursor_exited(target: Object) -> void:
	if target != self:
		return
	
	if description_key:
		SubtitleManager.reset_describe(get_instance_id())
	
	_debug("Cursor exited the PureSelectable %d" % get_instance_id())
	emit_signal("cursor_exited")

func _exit_tree():
	_on_cursor_exited(self)

func disable() -> void:
	if disabled:
		return
	
	disabled = true
	lock = false
	
	_on_cursor_exited(self)

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
