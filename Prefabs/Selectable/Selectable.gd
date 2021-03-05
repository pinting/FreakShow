class_name Selectable
extends Sprite

# Description of the selectable
export var description: String = ""

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
export var selection_area_scale: Vector2 = Vector2(1.0, 1.0)

# Clone material
export var clone_material: bool = false

var current_effect_value: float = effect_default
var is_inside: bool = false
var disabled: bool = false
var held: bool = false
var is_described: bool = false

signal selected
signal cursor_inside
signal cursor_outside

func _ready() -> void:
	assert(effect_hover >= effect_default)
	assert(is_in_group("selectable"))
	
	connect("cursor_inside", self, "_set_inside", [true])
	connect("cursor_outside", self, "_set_inside", [false])
	
	if clone_material:
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

func _is_top(mouse_position: Vector2) -> bool:
	var tree = get_tree()
	var selectable_group = tree.get_nodes_in_group("selectable")
	var self_index = selectable_group.find(self)
	
	assert(self_index >= 0)

	var self_z_index = _get_absolute_z_index(self)
	
	for i in range(0, len(selectable_group) - 1):
		if i == self_index:
			continue
		
		var node = selectable_group[i]
		var node_z_index = _get_absolute_z_index(node)
		
		var is_selected = node.get_rect().has_point(node.to_local(mouse_position))
		var is_front = node_z_index > self_z_index
		var is_visible = node.visible
		
		if is_selected and is_front and is_visible:
			return false
	
	return true

func _on_hover(mouse_position) -> bool:
	if _can_hover():
		var rect = get_rect()
		var scale = selection_area_scale
		var offset = rect.size / -scale if max(scale.x, scale.y) > 1.0 else Vector2.ZERO
		var large_rect = Rect2(rect.position + offset, rect.size * scale)
		
		if large_rect.has_point(to_local(mouse_position)) and _is_top(mouse_position):
			return true
	
	return false

func _can_hover() -> bool:
	var self_id = get_instance_id()

	return not Game.disable_selectable and not disabled and Cursor.is_free(self_id) and visible

func _input(event: InputEvent) -> void:
	if not Game.disable_selectable and not disabled and event is InputEventMouseButton:
		if is_inside and event.pressed:
			emit_signal("selected")

func _process(delta: float) -> void:
	var mouse_position = VirtualInput.get_world_mouse_position()

	if _on_hover(mouse_position):
		if len(offset_key):
			var offset = to_local(mouse_position) / get_rect().size
			
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
		
		_set_description()
	elif not held:
		if len(effect_key):
			current_effect_value -= delta / effect_step
			current_effect_value = max(effect_default, current_effect_value)
		
		if is_inside:
			emit_signal("cursor_outside")
		
		_reset_description()
	
	if len(effect_key):
		material.set_shader_param(effect_key, current_effect_value)

func disable():
	_reset_description()
	disabled = true

func hold():
	held = true

func drop():
	held = false

func _set_description() -> void:
	if not is_described:
		is_described = true
		SubtitleManager.describe(get_instance_id(), tr(description))

func _reset_description() -> void:
	if is_described:
		is_described = false
		SubtitleManager.describe_reset(get_instance_id())
