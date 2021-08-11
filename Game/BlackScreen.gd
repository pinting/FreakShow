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
	
	tween.stop(color_rect, "modulate:a")
	tween.interpolate_property(color_rect, "modulate:a",
		color_rect.modulate.a, 1.0, duration)
	tween.start()

	Tools.debug("Black screen fade in")

	return tween

func fade_out(duration: float = 1.0) -> Tween:
	assert(duration > 0.0, "Duration needs to be greater than zero")
	
	tween.stop(color_rect, "modulate:a")
	tween.interpolate_property(color_rect, "modulate:a",
		color_rect.modulate.a, 0.0, duration)
	tween.start()

	Tools.debug("Black screen fade out")
	
	return tween
