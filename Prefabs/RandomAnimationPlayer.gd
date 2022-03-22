extends AnimationPlayer

export var scale_time = 1.0
export var scale_mod = 1.0

var time: float = 0.0
var base_playback_speed: float = 1.0

func _ready():
	time = Tools.random_float(0.0, 100.0)
	base_playback_speed = playback_speed

func _process(delta: float) -> void:
	time += delta
	playback_speed = base_playback_speed + scale_mod * sin(time * scale_time)
