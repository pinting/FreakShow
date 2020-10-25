extends CanvasLayer

onready var animation_player = $AnimationPlayer
onready var canvas = $Canvas

func _ready() -> void:
	canvas.modulate.a = 1.0

func fade_in(speed_scale: float = 1.0) -> void:
	assert(speed_scale > 0.0)

	canvas.modulate.a = 0.0

	animation_player.set_speed_scale(1.0 / speed_scale)
	animation_player.play("fade_in")

	Game.debug("Black screen fade in")

func fade_out(speed_scale: float = 1.0) -> void:
	assert(speed_scale > 0.0)

	canvas.modulate.a = 1.0

	animation_player.set_speed_scale(1.0 / speed_scale)
	animation_player.play("fade_out")

	Game.debug("Black screen fade out")