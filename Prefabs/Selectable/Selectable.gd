class_name Selectable
extends Sprite

# Description key of the selectable
export var description_key: String = ""

# Mouse offset key
export var offset_key: String = ""

# Primary effect name
export var effect_key: String = ""

# Primary effect when mouse is hovering
export var effect_hover: float = 0.0

# Default primary effect value
export var effect_default: float = 0.0

# Effect step size in one second
export var effect_step: float = 0.1

# Selection area scale
export (NodePath) var selection_area

# Clone material
export var clone_material: bool = true

# Cursor according to viewport (if false, according to world)
export var viewport_cursor: bool = false

var current_effect_value: float = effect_default
var is_inside: bool = false
var disabled: bool = false
var held: bool = false
var is_described: bool = false

signal selected
signal cursor_inside
signal cursor_outside

func _ready() -> void:
	assert(is_in_group("selectable"), "Selectable not in group of 'selectable'")
	
	connect("cursor_inside", self, "_set_inside", [true])
	connect("cursor_outside", self, "_set_inside", [false])
	
	if clone_material and material:
		material = material.duplicate()

func _set_inside(value: bool) -> void:
	is_inside = value

func _get_absolute_z_index(target: Node2D) -> int:
	var node = target
	var z_index = 0

	while node and node.is_class("Node2D"):
		z_index += node.z_index

		if !node.z_as_relative:
			break

		node = node.get_parent()
	
	return z_index

# Checks if the selectable is top of the other selectables at the given point
func _is_top(mouse_position: Vector2) -> bool:
	var tree = get_tree()
	var selectable_group = tree.get_nodes_in_group("selectable")
	var self_index = selectable_group.find(self)
	
	assert(self_index >= 0, "Self did not find in selectable group")

	var self_z_index = _get_absolute_z_index(self)
	
	for i in range(0, len(selectable_group) - 1):
		if i == self_index:
			continue
		
		var node = selectable_group[i]
		var node_z_index = _get_absolute_z_index(node)
		
		var is_selected = node.get_selection_area().has_point(node.to_local(mouse_position))
		var is_front = node_z_index > self_z_index
		var is_visible = node.visible
		
		if is_selected and is_front and is_visible:
			return false
	
	return true

# Checks if mouse can hover over the selectable
func _can_hover() -> bool:
	var self_id = get_instance_id()

	return not VirtualInput.disable_selectable and not disabled and VirtualCursorManager.is_free(self_id) and visible

# Check if mouse is hovering over the selectable
func _is_hovering(mouse_position) -> bool:
	if _can_hover():
		var rect = get_selection_area()
		
		if rect.has_point(to_local(mouse_position)) and _is_top(mouse_position):
			return true
	
	return false

func get_selection_area() -> Rect2:
	if selection_area:
		var node = get_node(selection_area)
		
		return node.get_rect()
	
	return get_rect()

func _input(event: InputEvent) -> void:
	var not_disabled = not VirtualInput.disable_selectable and not disabled

	if not_disabled and event is InputEventMouseButton and event.pressed and is_inside:
		emit_signal("selected")

func _process(delta: float) -> void:
	var cursor_display = VirtualCursorManager.display
	
	if not cursor_display:
		return
	
	var cursor_position 
	
	if viewport_cursor:
		cursor_position = cursor_display.get_viewport_position()
	else:
		cursor_position = cursor_display.cursor.global_position

	if _is_hovering(cursor_position):
		if len(offset_key):
			var rect = get_selection_area()
			var offset = to_local(cursor_position) / rect.size
			
			if centered:
				offset += Vector2(0.5, 0.5)
				
			offset.x = min(1.0, max(0.0, offset.x))
			offset.y = min(1.0, max(0.0, offset.y))
			
			material.set_shader_param(offset_key, offset)
		
		if len(effect_key):
			current_effect_value += delta / effect_step
			current_effect_value = min(effect_hover, current_effect_value)
		
		if not is_inside:
			emit_signal("cursor_inside")
		
		_on_cursor_inside()
	elif not held:
		if len(effect_key):
			current_effect_value -= delta / effect_step
			current_effect_value = max(effect_default, current_effect_value)
		
		if is_inside:
			emit_signal("cursor_outside")
		
		_on_cursor_outside()
	
	if len(effect_key):
		material.set_shader_param(effect_key, current_effect_value)

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

func hold() -> void:
	held = true

func drop() -> void:
	held = false
