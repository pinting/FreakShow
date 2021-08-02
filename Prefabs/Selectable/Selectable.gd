class_name Selectable
extends PureSelectable

# Selection material
export (Material) var effect_material = preload("res://Materials/GrabMaterial.tres")

# Primary effect name
export var effect_key: String = "scale"

# Mouse offset key
export var effect_offset_key: String = "offset"

# Primary effect when mouse is hovering
export var effect_hover: float = 1.0

# Default primary effect value
export var effect_default: float = 0.0

# Effect step size in one second
export var effect_step: float = 0.1

var current_effect_value: float = effect_default

func _ready() -> void:
	assert(not material or not effect_material, "Both material and effect_material exists")

func _process(delta: float) -> void:
	var is_selected = SelectableManager.is_selected(self, viewport_based_cursor)
	
	if is_selected:
		var cursor_position = CursorManager.get_position(viewport_based_cursor)
		
		if not is_inside:
			is_inside = true

			emit_signal("cursor_inside")
			_on_cursor_inside()
			
			if effect_material:
				material = effect_material.duplicate()
				current_effect_value = effect_default
		
		if material:
			var rect = get_selection_area()
			var offset = to_local(cursor_position) / rect.size
			
			if centered:
				offset += Vector2(0.5, 0.5)
				
			offset.x = min(1.0, max(0.0, offset.x))
			offset.y = min(1.0, max(0.0, offset.y))
			
			if len(effect_offset_key):
				material.set_shader_param(effect_offset_key, offset)
			
			if current_effect_value != effect_hover:
				current_effect_value += delta / effect_step
				current_effect_value = min(effect_hover, current_effect_value)
	elif not keep_selected:
		if is_inside:
			is_inside = false

			emit_signal("cursor_outside")
			_on_cursor_outside()
		
		if material:
			current_effect_value -= delta / effect_step
			current_effect_value = max(effect_default, current_effect_value)
			
			if current_effect_value == effect_default:
				material = null
	
	if material and len(effect_key):
		material.set_shader_param(effect_key, current_effect_value)
