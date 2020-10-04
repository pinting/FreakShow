extends RigidBody2D

# Force the body can be grabbed
export var GRAB_FORCE = Vector2(5.0, 5.0)

# Force kickable bodies are kicked with
export var KICK_FORCE = Vector2(100.0, 100.0)

# Force max kick velocity
export var MAX_VELOCITY = Vector2(400.0, 400.0)

# Max force
export var MAX_FORCE = Vector2(120.0, 120.0)

# Selectable or normal sprite
onready var sprite = $Sprite

var disabled = false
var held = false

signal picked

func _ready() -> void:
	assert(is_in_group("pickable"))

func _input_event(_viewport: Object, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		emit_signal("picked", self)

func _physics_process(_delta: float) -> void:
	if not held or disabled:
		return
	
	var position_diff = Global.get_world_mouse_position() - global_position
	var grab_force = position_diff.normalized() * GRAB_FORCE
	
	if abs(linear_velocity.x) < MAX_VELOCITY.x and abs(linear_velocity.y) < MAX_VELOCITY.y :
		_apply_force(grab_force)

func _apply_force(force: Vector2) -> void:
	if force < MAX_FORCE and linear_velocity < MAX_VELOCITY:
		apply_central_impulse(force)

func pickup() -> void:
	if held or disabled:
		return
	
	# If sprite is a selectiable, it needs to remain lit
	if sprite and sprite.get("held"):
		sprite.held = true
	
	held = true

func drop(impulse: Vector2 = Vector2.ZERO) -> void:
	if not held:
		return
	
	_apply_force(impulse)
	
	# Only true of selectable
	if sprite and sprite.get("held"):
		sprite.held = false
	
	held = false

func disable() -> void:
	disabled = true
	held = false
	
	# Only true of selectable
	if sprite.get("held") and sprite.get("disable"):
		sprite.disabled = true
		sprite.held = false
