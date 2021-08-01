class_name PureSelectable
extends Sprite

# Description key of the selectable
export var description_key: String = ""

# Selection area
export (NodePath) var selection_area

# Cursor according to viewport (if false, according to world)
export var viewport_based_cursor: bool = false

var is_inside: bool = false
var is_described: bool = false
var disabled: bool = false
var keep_selected: bool = false

signal selected
signal cursor_inside
signal cursor_outside

func _ready() -> void:
	assert(is_in_group("selectable"), "Selectable not in group of 'selectable'")

func _input(event: InputEvent) -> void:
	var not_disabled = not SelectableManager.disable and not disabled

	if not_disabled and event is InputEventMouseButton and event.pressed and is_inside:
		emit_signal("selected")

func get_selection_area() -> Rect2:
	if selection_area:
		var area = get_node(selection_area)
		
		return area.get_rect()
	
	return get_rect()

func _process(_delta: float) -> void:
	var is_selected = SelectableManager.is_selected(self, viewport_based_cursor)
	
	if is_selected:
		if not is_inside:
			is_inside = true

			emit_signal("cursor_inside")
			_on_cursor_inside()
	elif not keep_selected:
		if is_inside:
			is_inside = false

			emit_signal("cursor_outside")
			_on_cursor_outside()

func _on_cursor_inside() -> void:
	if not is_described and len(description_key):
		SubtitleManager.set_describe(get_instance_id(), Text.find(description_key))
		is_described = true

func _on_cursor_outside() -> void:
	if is_described and len(description_key):
		SubtitleManager.reset_describe(get_instance_id())
		is_described = false

func _exit_tree():
	_on_cursor_outside()

func disable() -> void:
	disabled = true
	_on_cursor_outside()

func enable() -> void:
	disabled = false
