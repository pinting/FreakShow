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
export var effect_value_on_init: float = 0.0

# Max effect value
export var effect_value_on_hide: float = 10.0

# Speed of step
export var effect_speed: float = 1.0

onready var tween = $Tween
onready var line_body = $LineBody

var current_effect_value: int = 0

func _ready() -> void:
	connect("selected", self, "_on_selected")
	reset()

func reset() -> void:
	tween.stop_all()
	
	if hide_on_init:
		disable()
		_set_effect_value(effect_value_on_hide)
	else:
		enable()
		_set_effect_value(effect_value_on_init)

func _set_effect_value(value: float) -> void:
	var at_init = value == effect_value_on_init
	var at_hide = value == effect_value_on_hide
	
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
	tween.interpolate_method(
		self,
		"_set_effect_value",
		current_effect_value,
		effect_value_on_hide,
		effect_speed,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	
	tween.start()
	
	yield(tween, "tween_completed")
	
	disable()

func show() -> void:
	enable()
	
	tween.interpolate_method(
		self,
		"_set_effect_value",
		current_effect_value,
		effect_value_on_init,
		effect_speed,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	
	tween.start()

func disable() -> void:
	visible = false
	Tools.set_body_visibility(line_body, false)

func enable() -> void:
	visible = true
	Tools.set_body_visibility(line_body, true)
