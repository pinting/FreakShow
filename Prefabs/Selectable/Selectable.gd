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

# Default primary effect value
export var effect_min: float = 0.0

# Primary effect when mouse is hovering
export var effect_max: float = 1.0

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

func _ready() -> void:
	assert(not material or not effect_material, 
		"Both material and effect_material exists")
	
	SelectableManager.connect("cursor_entered", self, "_on_cursor_inside")
	SelectableManager.connect("cursor_exited", self, "_on_cursor_outside")

func _set_effect(value: float) -> void:
	if material and effect_key:
		var effect_value = effect_min + value * (effect_max - effect_min)
		
		material.set_shader_param(effect_key, effect_value)

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
		yield(Animator.run(self, "_set_effect", 
			0.0, 1.0, effect_duration), "completed")

func _on_cursor_outside(target: Selectable) -> void:
	if target != self:
		return
	
	if not material:
		return
	
	if effect_key:
		yield(Animator.run(self, "_set_effect", 
			1.0, 0.0, effect_duration), "completed")
	
	if not SelectableManager.is_selected(self):
		# Do not waste resources on unused materials
		material = null

func _set_vanish(value: float) -> void:
	modulate.a = value

	if material and vanish_key:
		var vanish_value = vanish_min + (1.0 - value) * (vanish_max - vanish_min)

		material.set_shader_param(vanish_key, vanish_value)

func hide() -> void:
	if not visible:
		return
	
	disable()
	
	if vanish_material:
		material = vanish_material.duplicate()
		
		yield(Animator.run(self, "_set_vanish", 
			1.0, 0.0, vanish_duration), "completed")
		
		material = null
	
	visible = false

func show() -> void:
	if visible:
		return
	
	enable()
	
	visible = true
	
	if vanish_material:
		material = vanish_material.duplicate()
	
		yield(Animator.run(self, "_set_vanish", 
			0.0, 1.0, vanish_duration), "completed")
		
		material = null
