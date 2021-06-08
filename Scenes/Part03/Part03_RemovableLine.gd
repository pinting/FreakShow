extends "res://Prefabs/Selectable/Selectable.gd"

onready var tween = $Tween
onready var line_body = $LineBody
onready var boss_detector = $BossDetector

# Start effect value
export var line_effect_start: float = 0.5

# Max effect value
export var line_effect_end: float = 10.0

# Speed of step
export var line_step_speed: float = 1.0

# Auto hide the line when ready
export var hide_on_init: bool = false

# Enable player interaction
export var enable_player_interaction: bool = true

var current: int = 0

signal line_removed

func _ready() -> void:
	boss_detector.connect("body_entered", self, "_on_boss_collide")
	connect("selected", self, "_on_selected")
	
	if hide_on_init:
		disable()
		_set_effect(line_effect_end)
	else:
		_set_effect(line_effect_start)

func _on_boss_collide(line_body: Node) -> void:
	if line_body.is_in_group("boss"):
		hide()

func _set_effect(amount: float) -> void:
	material.set_shader_param("amount", amount)
	
	current = amount

func _on_selected() -> void:
	if enable_player_interaction:
		hide()

func hide() -> void:
	tween.interpolate_method(
		self,
		"_set_effect",
		current,
		line_effect_end,
		line_step_speed,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	
	tween.start()
	
	yield(tween, "tween_completed")
	
	disable()

func show() -> void:
	enable()
	
	tween.interpolate_method(
		self,
		"_set_effect",
		current,
		line_effect_start,
		line_step_speed,
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
