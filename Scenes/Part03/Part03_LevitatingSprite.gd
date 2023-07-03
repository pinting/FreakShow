extends Sprite2D

@export var time_scale: float = 1.0
@export var diff_scale: float = 0.5
@export var offset_key: String = ""
@export var duplicate_material: bool = true

var current_second = 0
var generation_base = Vector2(randf_range(50, 100), randf_range(50, 100))

func _ready() -> void:
	super._ready()
	
	if material:
		material = material.duplicate()

func _generate_offset(v: Vector2):
	var r1 = v * generation_base
	var r2 = Vector2(sin(r1.x), cos(r1.y))
	var r3 = Vector2(r2.x - floor(r2.x), r2.y - floor(r2.y))
	
	return r3

func _process(delta: float):
	super._process(delta)

	current_second += delta * time_scale
	
	var diff = Vector2(sin(current_second), cos(current_second))
	
	position += diff * diff_scale
	
	if material and offset_key and fmod(current_second, 0.025 * time_scale) < 0.01:
		var offset = _generate_offset(diff)
		
		material.set_shader_parameter(offset_key, offset)
