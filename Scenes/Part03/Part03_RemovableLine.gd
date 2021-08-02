extends PureSelectable

# Auto hide the line when ready
export var hide_on_init: bool = false

# Enable player interaction
export var enable_player_interaction: bool = true

# Enable boss interaction
export var enable_boss_interaction: bool = true

# Effect material
export (Material) var effect_material = preload("res://Materials/DisintegrateMaterial.tres")

# Effect key
export var effect_key = "amount"

# Use material at init
export var use_material_at_init: bool = true

# Start effect value
export var effect_init: float = 0.0

# Max effect value
export var effect_end: float = 10.0

# Speed of step
export var effect_duration: float = 1.0

onready var tween = $Tween
onready var line_body = $LineBody

var current_effect_value: float = 0.0

func _ready() -> void:
	connect("selected", self, "_on_selected")
	reset()

func reset() -> void:
	tween.stop_all()
	
	if hide_on_init:
		disable()
		_effect(effect_end)
	else:
		enable()
		_effect(effect_init)

func _effect(value: float) -> void:
	var at_init = value == effect_init
	var at_hide = value == effect_end
	
	if (not use_material_at_init and at_init) or at_hide:
		material = null
	elif not material:
		material = effect_material.duplicate()
	
	if material:
		material.set_shader_param(effect_key, value)
	
	current_effect_value = value

func _on_selected() -> void:
	if enable_player_interaction:
		hide()

func hide() -> void:
	tween.interpolate_method(self, "_effect", current_effect_value, effect_end, effect_duration)
	tween.start()
	
	yield(tween, "tween_completed")
	
	disable()

func show() -> void:
	enable()
	
	tween.interpolate_method(self, "_effect", current_effect_value, effect_init, effect_duration)
	tween.start()

func disable() -> void:
	visible = false
	Tools.set_body_visibility(line_body, false)

func enable() -> void:
	visible = true
	Tools.set_body_visibility(line_body, true)
