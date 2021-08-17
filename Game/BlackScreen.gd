class_name BlackScreen
extends Node

onready var color_rect = $ColorRect

func _ready() -> void:
	color_rect.modulate.a = 1.0

func is_fading() -> bool:
	return Animator.is_active(color_rect, "modulate:a")

func is_faded() -> bool:
	return color_rect.modulate.a == 1.0

func fade_in(duration: float = 1.0) -> void:
	assert(duration > 0.0, "Duration needs to be greater than zero")

	yield(Animator.run(color_rect, "modulate:a", 
		color_rect.modulate.a, 1.0, duration), "completed")
	
	Tools.debug("Black screen fade in")

func fade_out(duration: float = 1.0) -> void:
	assert(duration > 0.0, "Duration needs to be greater than zero")
	
	yield(Animator.run(color_rect, "modulate:a", 
		color_rect.modulate.a, 0.0, duration), "completed")

	Tools.debug("Black screen fade out")
