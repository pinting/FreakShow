extends PureSelectable

# Auto hide the line when ready
export var hide_on_init: bool = false

# Enable player interaction
export var enable_player_interaction: bool = true

# Effect material
export (Material) var effect_material = preload("res://Materials/DisintegrateMaterial.tres")

# Effect key
export var effect_key = "amount"

# Start effect value
export var effect_value_on_show: float = 0.0

# Max effect value
export var effect_value_on_hide: float = 10.0

# Speed of step
export var effect_speed: float = 1.0

onready var tween = $Tween
onready var line_body = $LineBody
onready var boss_detector = $BossDetector

var current_effect_value: int = 0

func _ready() -> void:
	boss_detector.connect("body_entered", self, "_on_boss_collide")
	connect("selected", self, "_on_selected")
	
	if hide_on_init:
		disable()
		_set_effect_value(effect_value_on_hide)
	else:
		enable()
		_set_effect_value(effect_value_on_show)

func _on_boss_collide(line_body: Node) -> void:
	if line_body.is_in_group("_boss"):
		hide()

func _set_effect_value(value: float) -> void:
	if value == effect_value_on_show or value == effect_value_on_hide:
		material = null
	elif not material:
		material = effect_material
	
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
		effect_value_on_show,
		effect_speed,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	
	tween.start()

func disable() -> void:
	visible = false
	Tools.set_body_visibility(line_body, false)
	Tools.set_body_visibility(boss_detector, false)

func enable() -> void:
	visible = true
	Tools.set_body_visibility(line_body, true)
	Tools.set_body_visibility(boss_detector, true)
