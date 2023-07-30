extends Sprite2D

@export var effect_duration = 1.0
@export var effect_min = 1000.0
@export var effect_max = 0.0

func _ready():
	refresh()

func refresh():
	material.set_shader_parameter("scale", effect_max)

func appear():
	var tween = get_tree().create_tween()
	var method = Callable(material, "set_shader_parameter").bind("scale")
	
	tween.tween_method(method, effect_max, effect_min, effect_duration)

func disappear():
	var tween = get_tree().create_tween()
	var method = Callable(material, "set_shader_parameter").bind("scale")
	
	tween.tween_method(method, effect_min, effect_max, effect_duration)
