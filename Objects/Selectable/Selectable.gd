class_name Selectable
extends Sprite

# Mouse offset key
export var OFFSET_KEY = "offset"

# Primary effect name
export var PRIMARY_KEY = "grab_amount"

# Primary effect when mouse is hovering
export var PRIMARY_HOVER = 1.1

# Default primary effect value
export var PRIMARY_DEFAULT = 1.0

# Secondary effect name
export var SECONDARY_KEY = "glow_amount"

# Secondary effect when mouse is hovering
export var SECONDARY_HOVER = 0.5

# Default secondary effect value
export var SECONDARY_DEFAULT = 0.0

# Effect step size in one second (both primary and secondary)
export var EFFECT_STEP = 1.0

# Clone material
export var CLONE_MATERIAL = true

var _current_primary = PRIMARY_DEFAULT
var _current_secondary = SECONDARY_DEFAULT

var held = false

signal select

func _ready():
	assert(PRIMARY_HOVER >= PRIMARY_DEFAULT)
	assert(SECONDARY_HOVER >= SECONDARY_DEFAULT)
	assert(is_in_group("selectable"))
	
	if CLONE_MATERIAL:
		material = material.duplicate()

func is_overlap(mouse_position):
	var tree = get_tree()
	var selectable_group = tree.get_nodes_in_group("selectable")
	var self_index = selectable_group.find(self)
	
	for i in range(0, len(selectable_group) - 1):
		if i == self_index:
			continue
			
		var node = selectable_group[i]
		
		var is_selected = node.get_rect().has_point(node.to_local(mouse_position))
		var is_front = node.z_index > z_index or (node.z_index == z_index and i < self_index)
		
		if is_selected and is_front:
			return true
	
	return false

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		var mouse_position = get_global_mouse_position()
		
		if get_rect().has_point(to_local(mouse_position)) and not is_overlap(mouse_position):
			emit_signal("select")

func _physics_process(delta):
	var mouse_position = get_global_mouse_position()
	
	if get_rect().has_point(to_local(mouse_position)) and not is_overlap(mouse_position):
		var offset = to_local(mouse_position) / get_rect().size
		
		if centered:
			offset += Vector2(0.5, 0.5)
			
		offset.x = min(1.0, max(0.0, offset.x))
		offset.y = min(1.0, max(0.0, offset.y))
		
		material.set_shader_param(OFFSET_KEY, offset)
		
		_current_primary += EFFECT_STEP * delta
		_current_primary = min(PRIMARY_HOVER, _current_primary)
		
		_current_secondary += EFFECT_STEP * delta
		_current_secondary = min(SECONDARY_HOVER, _current_secondary)
	elif not held:
		_current_primary -= EFFECT_STEP * delta
		_current_primary = max(PRIMARY_DEFAULT, _current_primary)
		
		_current_secondary -= EFFECT_STEP * delta
		_current_secondary = max(SECONDARY_DEFAULT, _current_secondary)
	
	material.set_shader_param(PRIMARY_KEY, _current_primary)
	material.set_shader_param(SECONDARY_KEY, _current_secondary)
