extends Sprite2D

@export var effect_duration = 10.0
@export var effect_min = 1.0
@export var effect_max = 0.0

var appeared: bool = false

func _ready():
	refresh()

func refresh():
	_set_material_scale(effect_max)

func _set_material_scale(value):
	material.set_shader_parameter("scale", value)
	print(value)

func appear():
	var tween = get_tree().create_tween()
	var method = Callable(self, "_set_material_scale")
	
	tween.tween_method(method, effect_max, effect_min, effect_duration)
	
	appeared = true

func disappear():
	var tween = get_tree().create_tween()
	var method = Callable(self, "_set_material_scale")
	
	tween.tween_method(method, effect_min, effect_max, effect_duration)
	
	appeared = false
