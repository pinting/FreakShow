class_name Selection
extends Sprite

# Primary effect name
export var PRIMARY_KEY = "penetration_amount"

# Primary effect when mouse is hovering
export var PRIMARY_HOVER = 1.1

# Default primary effect value
export var PRIMARY_DEFAULT = 1.0

# Secondary effect name
export var SECONDARY_KEY = "glow_amount"

# Secondary effect when mouse is hovering
export var SECONDARY_HOVER = 0.5

# Default secondary effect value
export var SECONDARY_DEFAULT = 0.0

# Effect step size in one second (both glow and penetration)
export var EFFECT_STEP = 1.0

# Effect limit box between (0, 0) and (1, 1)
export var LIMIT = Vector2(1, 1)

# Center of the object
export var CENTER = Vector2(0.5, 0.5)

var _current_primary = PRIMARY_DEFAULT
var _current_secondary = SECONDARY_DEFAULT

var held = false

signal on_select

func _ready():
	assert(PRIMARY_HOVER >= PRIMARY_DEFAULT)
	assert(SECONDARY_HOVER >= SECONDARY_DEFAULT)

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
		
		_current_primary += EFFECT_STEP * delta
		_current_primary = min(PRIMARY_HOVER, _current_primary)
		
		_current_secondary += EFFECT_STEP * delta
		_current_secondary = min(SECONDARY_HOVER, _current_secondary)
	elif not held:
		_current_primary -= EFFECT_STEP * delta
		_current_primary = max(PRIMARY_DEFAULT, _current_primary)
		
		_current_secondary -= EFFECT_STEP * delta
		_current_secondary = max(SECONDARY_DEFAULT, _current_secondary)
	
	material.set_shader_param(PRIMARY_KEY, _current_primary)
	material.set_shader_param(SECONDARY_KEY, _current_secondary)
