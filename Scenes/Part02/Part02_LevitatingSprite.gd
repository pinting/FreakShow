extends Sprite

# Speed of the levitation effect
export var TIME_SCALE: float = 1.0

# How far will the sprite levitate out
export var DIFF_SCALE: float = 0.5

# Offset key of the shader
export var OFFSET_KEY: String = ""

# Duplicate the material
export var DUPLICATE_MATERIAL: bool = true

var current_second = 0
var generation_base = Vector2(rand_range(50, 100), rand_range(50, 100))

func _ready():
	if material:
		material = material.duplicate()

func _generate_offset(v: Vector2):
	var r1 = v * generation_base
	var r2 = Vector2(sin(r1.x), cos(r1.y))
	var r3 = Vector2(r2.x - floor(r2.x), r2.y - floor(r2.y))
	
	return r3

func _process(delta: float):
	current_second += delta * TIME_SCALE
	
	var diff = Vector2(sin(current_second), cos(current_second))
	
	position += diff * DIFF_SCALE
	
	if material and OFFSET_KEY and fmod(current_second, 0.025 * TIME_SCALE) < 0.01:
		var offset = _generate_offset(diff)
		
		material.set_shader_param(OFFSET_KEY, offset)
