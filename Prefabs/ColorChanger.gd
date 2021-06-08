class_name ColorChanger
extends Node2D

export var color_change_speed: float = 0.5

# Name of the property on the self to change 
export var color_property: String = "modulate"

# Name of the shader parameter on the material to change
export var color_shader_param: String = ""

# Add this offset to the result
export var offset: Color = Color(0.75, 0.75, 0.75)

# Scale color with this property
export var scale_color: Color = Color(0.33, 0.33, 0.33)

var current: Color = Color(0.0, 0.0, 0.0)
var current_second: float = 0

func _ready() -> void:
	var r = 1.0
	var g = 0.0
	var b = 0.0
	
	var state = Tools.random_int(0, 2)
	
	if state == 0:
		r = Tools.random_float(0.5, 1.0)
		g = 1.0 - r
		b = 0.0
	elif state == 1:
		g = Tools.random_float(0.5, 1.0)
		b = 1.0 - g
		r = 0.0
	else:
		b = Tools.random_float(0.5, 1.0)
		r = 1.0 - b
		g = 0.0
	
	current = Color(r, g, b)

func _process(delta: float) -> void:
	current_second += delta
	
	if current.r <= 1.0 and current.g < 1.0 and current.b == 0:
		current.r -= delta * color_change_speed
		current.g += delta * color_change_speed
	elif current.r == 0.0 and current.g <= 1.0 and current.b < 1.0:
		current.g -= delta * color_change_speed
		current.b += delta * color_change_speed
	elif current.r < 1.0 and current.g == 0.0 and current.b <= 1.0:
		current.b -= delta * color_change_speed
		current.r += delta * color_change_speed
	 
	current.r = max(0.0, min(1.0, current.r))
	current.g = max(0.0, min(1.0, current.g))
	current.b = max(0.0, min(1.0, current.b))
	
	# Scale and add offset, but limit the value between 0.0 - 1.0
	var result = Color(
		max(min(scale_color.r * current.r + offset.r, 1.0), 0.0), 
		max(min(scale_color.g * current.g + offset.g, 1.0), 0.0),
		max(min(scale_color.b * current.b + offset.b, 1.0), 0.0))
	
	if len(color_property):
		set(color_property, result)
	
	if len(color_shader_param) and material:
		material.set_shader_param(color_shader_param, result)
