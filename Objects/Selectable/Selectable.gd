class_name Selectable
extends Sprite

# Description of the selectable
export var description: String = ""

# Mouse offset key
export var offset_key: String = ""

# Primary effect name
export var primary_key: String = ""

# Primary effect when mouse is hovering
export var primary_hover: float = 0.0

# Default primary effect value
export var primary_default: float = 0.0

# Secondary effect name
export var secondary_key: String = ""

# Secondary effect when mouse is hovering
export var secondary_hover: float = 0.0

# Default secondary effect value
export var secondary_default: float = 0.0

# Effect step size in one second (both primary and secondary)
export var effect_step: float = 1.0

# Clone material
export var clone_material: bool = false

var current_primary: float = primary_default
var current_secondary: float = secondary_default

var held = false

signal selected

func _ready():
	assert(primary_hover >= primary_default)
	assert(secondary_hover >= secondary_default)
	assert(is_in_group("selectable"))
	
	if clone_material:
		material = material.duplicate()

func _is_top(mouse_position: Vector2):
	var tree = get_tree()
	var selectable_group = tree.get_nodes_in_group("selectable")
	var self_index = selectable_group.find(self)
	
	assert(self_index >= 0)
	
	for i in range(0, len(selectable_group) - 1):
		if i == self_index:
			continue
		
		var node = selectable_group[i]
		
		var is_selected = node.get_rect().has_point(node.to_local(mouse_position))
		var is_front = node.z_index > z_index or (node.z_index == z_index and i < self_index)
		var is_visible = node.visible
		
		if is_selected and is_front and is_visible:
			return false
	
	return true

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		var mouse_position = Global.get_world_mouse_position()
		
		if get_rect().has_point(to_local(mouse_position)) and _is_top(mouse_position):
			emit_signal("selected")

func show_description():
	Global.subtitle.describe(get_instance_id(), tr(description))

func remove_description():
	Global.subtitle.describe_remove(get_instance_id())

func _physics_process(delta: float):
	var mouse_position = Global.get_world_mouse_position()
	
	if get_rect().has_point(to_local(mouse_position)) and _is_top(mouse_position):
		if len(offset_key):
			var offset = to_local(mouse_position) / get_rect().size
			
			if centered:
				offset += Vector2(0.5, 0.5)
				
			offset.x = min(1.0, max(0.0, offset.x))
			offset.y = min(1.0, max(0.0, offset.y))
			
			material.set_shader_param(offset_key, offset)
		
		if len(primary_key):
			current_primary += effect_step * delta
			current_primary = min(primary_hover, current_primary)
		
		if len(secondary_key):
			current_secondary += effect_step * delta
			current_secondary = min(secondary_hover, current_secondary)
		
		show_description()
	elif not held:
		if len(primary_key):
			current_primary -= effect_step * delta
			current_primary = max(primary_default, current_primary)
		
		if len(secondary_key):
			current_secondary -= effect_step * delta
			current_secondary = max(secondary_default, current_secondary)
		
		remove_description()
	
	if len(primary_key):
		material.set_shader_param(primary_key, current_primary)
	
	if len(secondary_key):
		material.set_shader_param(secondary_key, current_secondary)
