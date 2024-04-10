extends Sprite2D

@export var effect_duration = 10.0
@export var effect_min = 1.0
@export var effect_max = 0.0

var appeared: bool = false

func _ready():
	refresh()

func refresh():
	material.set_shader_parameter("scale", effect_max)

func appear():
	Animator.tween_material(self, "scale", effect_max, effect_min, effect_duration)
	
	appeared = true

func disappear():
	Animator.tween_material(self, "scale", effect_max, effect_min, effect_duration)
	
	appeared = false
