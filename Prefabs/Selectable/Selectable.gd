class_name Selectable
extends PureSelectable

# Selection material
@export var effect_material: Material = preload("res://Resources/Materials/SelectionMaterial.tres")

# Vanish material
@export var vanish_material: Material = preload("res://Resources/Materials/DisintegrateMaterial.tres")

# Primary effect name
@export var effect_key: String = "scale"

# Mouse offset key
@export var effect_offset_key: String = "offset"

# Default primary effect value
@export var effect_min: float = 0.0

# Primary effect when mouse is hovering
@export var effect_max: float = 1.0

# Effect change duration
@export var effect_duration: float = 0.5

# Vanish key
@export var vanish_key: String = "amount"

# Vanish minimum value
@export var vanish_min: float = 0.0

# Vanish maximum value
@export var vanish_max: float = 10.0

# Vanish duration
@export var vanish_duration: float = 1.0

func _ready() -> void:
	super._ready()

	assert(not material or not effect_material, 
		"Both material and effect_material exists")

func _set_effect(value: float) -> void:
	if material and effect_material and effect_key != "":
		var effect_value = effect_min + value * (effect_max - effect_min)
		
		material.set_shader_parameter(effect_key, effect_value)

func _process(_delta: float) -> void:
	var is_selected = SelectableManager.is_selected(self)
	
	if not is_selected:
		return
	
	var cursor_position = CursorManager.get_position(viewport_based_cursor)
	
	if material and effect_material and effect_offset_key != "":
		var rect = get_selection_area()
		var effect_offset = to_local(cursor_position) / rect.size
		
		if centered:
			effect_offset += Vector2(0.5, 0.5)
		
		effect_offset.clamp(Vector2.ZERO, Vector2.ONE)
		
		material.set_shader_parameter(effect_offset_key, effect_offset)

func _on_cursor_entered(target: Object) -> void:
	super._on_cursor_entered(target)
	
	if target != self:
		return
	
	super._debug("Cursor entered the Selectable %d" % get_instance_id())
	
	if effect_material:
		material = effect_material.duplicate()
	
	if material and effect_material and effect_key != "":
		await Animator.run(self, "_set_effect", 0.0, 1.0, effect_duration)

func _on_cursor_exited(target: Object) -> void:
	super._on_cursor_exited(target)
	
	if target != self:
		return
	
	super._debug("Cursor exited the Selectable %d" % get_instance_id())
	
	if not material or not effect_material:
		return
	
	if effect_material and effect_key != "":
		await Animator.run(self, "_set_effect", 1.0, 0.0, effect_duration)
	
	if not SelectableManager.is_selected(self):
		# Do not waste resources on unused materials
		material = null

func _set_vanish(value: float) -> void:
	modulate.a = value

	if material and vanish_key != "":
		var vanish_value = vanish_min + (1.0 - value) * (vanish_max - vanish_min)

		material.set_shader_parameter(vanish_key, vanish_value)

func disappear() -> void:
	if not visible:
		return
	
	disable()
	
	if vanish_material:
		material = vanish_material.duplicate()
		
		await Animator.run(self, "_set_vanish", 1.0, 0.0, vanish_duration)
		
		material = null
	
	super.disappear()

func appear() -> void:
	if visible:
		return
	
	super.appear()
	enable()
	
	if vanish_material:
		material = vanish_material.duplicate()
	
		await Animator.run(self, "_set_vanish", 0.0, 1.0, vanish_duration)
		
		material = null

func create_clone() -> PureSelectable:
	var clone = duplicate()
	
	if clone.effect_material:
		clone.material = null
	
	return clone
