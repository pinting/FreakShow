class_name Selection
extends Sprite

# Penetration effect when mouse is hovering
export var SELECT_PENETRATION = 1.1

# Default penetration effect value
export var DEFAULT_PENETRATION = 1.0

# Glow effect when mouse is hovering
export var SELECT_GLOW = 0.5

# Default glow effect value
export var DEFAULT_GLOW = 0.0

# Effect step size in one second (both glow and penetration)
export var EFFECT_STEP = 1.0

# Effect limit box between (0, 0) and (1, 1)
export var LIMIT = Vector2(1, 1)

# Center of the object
export var CENTER = Vector2(0.5, 0.5)

# Keep the size of the sprite
export var KEEP_SIZE = true

var current_penetration = DEFAULT_PENETRATION
var current_glow = DEFAULT_GLOW

signal on_select

func _ready():
	assert(SELECT_PENETRATION > DEFAULT_PENETRATION)
	assert(SELECT_GLOW > DEFAULT_GLOW)
	
	material.set_shader_param("keep_size", KEEP_SIZE)

func _input_event(viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("on_select", event)

func _physics_process(delta):
	var offset = Vector2(global_position - get_global_mouse_position()) / (texture.get_size())
	var center = CENTER
	var sum = center + offset
	
	if sum.x >= 0.0 && sum.x <= LIMIT.x && sum.y >= 0.0 && sum.y <= LIMIT.y:
		material.set_shader_param("offset", sum)
		
		current_penetration += EFFECT_STEP * delta
		current_penetration = min(SELECT_PENETRATION, current_penetration)
		
		current_glow += EFFECT_STEP * delta
		current_glow = min(SELECT_GLOW, current_glow)
	else:
		current_penetration -= EFFECT_STEP * delta
		current_penetration = max(DEFAULT_PENETRATION, current_penetration)
		
		current_glow -= EFFECT_STEP * delta
		current_glow = max(DEFAULT_GLOW, current_glow)
	
	material.set_shader_param("penetration", current_penetration)
	material.set_shader_param("glow_amount", current_glow)
