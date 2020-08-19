extends RigidBody2D

# Force the body can be grabbed
export var GRAB_FORCE = Vector2(5.0, 5.0)

# Force kickable bodies are kicked with
export var KICK_FORCE = Vector2(100.0, 100.0)

# Force max kick velocity
export var MAX_VELOCITY = Vector2(400.0, 400.0)

# Selectable or normal sprite
onready var sprite = $Sprite

var held = false

signal picked

func _ready():
	assert(is_in_group("pickable"))

func _input_event(_viewport: Object, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("picked", self)

func _physics_process(_delta: float):
	if not held:
		return
	
	var position_diff = get_global_mouse_position() - global_position
	var grab_force = position_diff.normalized() * GRAB_FORCE
	
	if abs(linear_velocity.x) < MAX_VELOCITY.x and abs(linear_velocity.y) < MAX_VELOCITY.y :
		apply_central_impulse(grab_force)


func pickup():
	if held:
		return
	
	# If sprite is a selectiable, it needs to remain lit
	if sprite.get("held") != null:
		sprite.held = true
	
	held = true

func drop(impulse: Vector2 = Vector2.ZERO):
	if not held:
		return
	
	apply_central_impulse(impulse)
	
	if sprite.get("held") != null:
		sprite.held = false
	
	held = false
