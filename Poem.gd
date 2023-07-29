extends Sprite2D

@export var effect_scale_inc = 1.0

var effect_scale = 0.0

func _ready():
	refresh()

func _process(delta):
	effect_scale += delta * effect_scale_inc
	
	refresh()

func refresh():
	material.set_shader_parameter("scale", effect_scale)
