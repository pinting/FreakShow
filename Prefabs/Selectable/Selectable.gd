class_name Selectable
extends PureSelectable

# Selection material
export (Material) var effect_material = preload("res://Materials/SelectionMaterial.tres")

# Vanish material
export (Material) var vanish_material = preload("res://Materials/DisintegrateMaterial.tres")

# Primary effect name
export var effect_key: String = "scale"

# Mouse offset key
export var effect_offset_key: String = "offset"

# Primary effect when mouse is hovering
export var effect_hover: float = 1.0

# Default primary effect value
export var effect_default: float = 0.0

# Effect change duration
export var effect_duration: float = 0.5

# Vanish key
export var vanish_key: String = "amount"

# Vanish minimum value
export var vanish_min: float = 0.0

# Vanish maximum value
export var vanish_max: float = 10.0

# Vanish duration
export var vanish_duration: float = 1.0

var tween: Tween

func _ready() -> void:
	assert(not material or not effect_material, 
		"Both material and effect_material exists")
	
	SelectableManager.connect("cursor_entered", self, "_on_cursor_inside")
	SelectableManager.connect("cursor_exited", self, "_on_cursor_outside")

	tween = Tween.new()
	
	add_child(tween)

func _set_effect(value: float) -> void:
	if material and effect_key:
		material.set_shader_param(effect_key, value)

func _set_vanish(value: float) -> void:
	if material and vanish_key:
		material.set_shader_param(vanish_key, value)

func _process(_delta: float) -> void:
	var is_selected = SelectableManager.is_selected(self)
	
	if not is_selected:
		return
	
	var cursor_position = CursorManager.get_position(viewport_based_cursor)
	
	if material and effect_offset_key:
		var rect = get_selection_area()
		var offset = to_local(cursor_position) / rect.size
		
		if centered:
			offset += Vector2(0.5, 0.5)
			
		offset.x = min(1.0, max(0.0, offset.x))
		offset.y = min(1.0, max(0.0, offset.y))
		
		material.set_shader_param(effect_offset_key, offset)

func _on_cursor_inside(target: Selectable) -> void:
	if target != self:
		return
	
	if effect_material:
		material = effect_material.duplicate()
	
	if material and effect_key:
		tween.stop_all()
		tween.interpolate_method(self, "_set_effect", 
			effect_default, effect_hover, effect_duration)
		tween.start()

func _on_cursor_outside(target: Selectable) -> void:
	if target != self:
		return
	
	if not material:
		return
	
	if effect_key:
		tween.stop_all()
		tween.interpolate_method(self, "_set_effect", 
			effect_hover, effect_default, effect_duration)
		tween.start()
		
		yield(tween, "tween_completed")
	
	if not SelectableManager.is_selected(self):
		# Do not waste resources on unused materials
		material = null

func hide() -> void:
	if not visible:
		return
	
	disable()
	
	if vanish_material:
		material = vanish_material.duplicate()
	
		tween.stop_all()
		tween.interpolate_method(self, "_set_vanish", 
			vanish_min, vanish_max, vanish_duration)
		tween.interpolate_property(self, "modulate:a",
			1.0, 0.0, vanish_duration)
		tween.start()
		
		yield(tween, "tween_completed")
		
		material = null
	
	visible = false

func show() -> void:
	if visible:
		return
	
	enable()
	
	visible = true
	
	if vanish_material:
		material = vanish_material.duplicate()
	
		tween.stop_all()
		tween.interpolate_method(self, "_set_vanish", 
			vanish_max, vanish_min, vanish_duration)
		tween.interpolate_property(self, "modulate:a",
			0.0, 1.0, vanish_duration)
		tween.start()
		
		yield(tween, "tween_completed")
		
		material = null
