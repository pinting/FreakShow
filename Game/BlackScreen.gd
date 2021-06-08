class_name BlackScreen
extends Node

onready var tween = $Tween
onready var color_rect = $ColorRect

func _ready() -> void:
	color_rect.modulate.a = 1.0

func is_fading() -> bool:
	return tween.is_active()

func is_faded() -> bool:
	return color_rect.modulate.a == 1.0

func fade_in(duration: float = 1.0) -> Tween:
	assert(duration > 0.0, "Duration needs to be greater than zero")
	
	tween.interpolate_property(
		color_rect,
		"modulate:a",
		color_rect.modulate.a,
		1.0,
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN)
	
	tween.start()
	SubtitleManager.reset_describe(-1, true)

	Tools.debug("Black screen fade in")

	return tween

func fade_out(duration: float = 1.0) -> Tween:
	assert(duration > 0.0, "Duration needs to be greater than zero")
	
	tween.interpolate_property(
		color_rect,
		"modulate:a",
		color_rect.modulate.a,
		0.0,
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT)
	
	tween.start()

	Tools.debug("Black screen fade out")
	
	return tween
