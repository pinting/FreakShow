extends AnimationPlayer

@export var scale_time = 1.0
@export var scale_mod = 1.0

var time: float = 0.0
var base_speed_scale: float = 1.0

func _ready():
	super._ready()

	time = Tools.random_float(0.0, 100.0)
	base_speed_scale = speed_scale

func _process(delta: float) -> void:
	super._process(delta)

	time += delta
	speed_scale = base_speed_scale + scale_mod * sin(time * scale_time)
