extends PureSelectable

# Auto hide the line when ready
@export var hide_on_init: bool = false

# Enable player interaction
@export var enable_player_interaction: bool = true

# Enable boss interaction
@export var enable_boss_interaction: bool = true

# Effect material
@export var effect_material: Material = preload("res://Resources/Materials/DisintegrateMaterial.tres")

# Use material at init
@export var effect_material_on_init: bool = true

# Effect key
@export var effect_key = "amount"

# Speed of step
@export var effect_duration: float = 1.0

# Start effect value
@export var effect_min: float = 0.0

# Max effect value
@export var effect_max: float = 10.0

@onready var line_body = $LineBody

func _ready() -> void:
	super._ready()
	
	connect("selected", Callable(self, "_on_selected"))
	reset()

func reset() -> void:
	Animator.remove_tween(self, "_set_hide_effect")
	
	if hide_on_init:
		disable()
		_set_hide_effect(1.0)
	else:
		enable()
		_set_hide_effect(0.0)

func _set_hide_effect(value: float) -> void:
	modulate.a = 1.0 - value

	if (not effect_material_on_init and value == 0.0) or value == 1.0:
		material = null
	elif not material:
		material = effect_material.duplicate()
	
	if material:
		var effect_value = effect_min + value * (effect_max - effect_min)

		material.set_shader_parameter(effect_key, effect_value)

func _on_selected() -> void:
	if enable_player_interaction:
		disappear()

func disappear() -> void:
	await Animator.run(self, "_set_hide_effect",
		0.0, 1.0, effect_duration)
	
	disable()

func appear() -> void:
	enable()
	
	await Animator.run(self, "_set_hide_effect",
		1.0, 0.0, effect_duration)

func disable() -> void:
	visible = false
	Tools.set_body_visibility(line_body, false)

func enable() -> void:
	visible = true
	Tools.set_body_visibility(line_body, true)
