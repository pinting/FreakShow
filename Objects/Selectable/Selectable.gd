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

var current: float = effect_default

var disabled = false
var held = false

signal selected

func _ready() -> void:
	assert(effect_hover >= effect_default)
	assert(is_in_group("selectable"))
	
	if clone_material:
		material = material.duplicate()

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

func _on_select(mouse_position) -> bool:
	if not Game.disable_selectable and not disabled and visible:
		var rect = get_rect()
		var scale = selection_area_scale
		var offset = rect.size / -scale if max(scale.x, scale.y) > 1.0 else Vector2.ZERO
		var large_rect = Rect2(rect.position + offset, rect.size * scale)
		
		if large_rect.has_point(to_local(mouse_position)) and _is_top(mouse_position):
			return true
	
	return false

func _input(event: InputEvent) -> void:
	if not Game.disable_selectable and not disabled and event is InputEventMouseButton:
		if held and not event.pressed:
			held = false

		var mouse_position = VirtualInput.get_world_mouse_position()
		
		if _on_select(mouse_position) and event.pressed:
			held = true
			
			emit_signal("selected")

func show_description() -> void:
	Game.subtitle.describe(get_instance_id(), tr(description))

func remove_description() -> void:
	Game.subtitle.describe_remove(get_instance_id())

func _physics_process(delta: float) -> void:
	var mouse_position = VirtualInput.get_world_mouse_position()
	
	if _on_select(mouse_position):
		if len(offset_key):
			var offset = to_local(mouse_position) / get_rect().size
			
			if centered:
				offset += Vector2(0.5, 0.5)
				
			offset.x = min(1.0, max(0.0, offset.x))
			offset.y = min(1.0, max(0.0, offset.y))
			
			material.set_shader_param(offset_key, offset)
		
		if len(effect_key):
			current += delta / effect_step
			current = min(effect_hover, current)
		
		show_description()
	elif not held or disabled:
		if len(effect_key):
			current -= delta / effect_step
			current = max(effect_default, current)
		
		remove_description()
	
	if len(effect_key):
		material.set_shader_param(effect_key, current)

func disable():
	remove_description()
	
	disabled = true
