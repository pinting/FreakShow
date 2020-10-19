extends RigidBody2D

# Force the body can be grabbed
export var GRAB_FORCE = Vector2(5.0, 5.0)

# Force kickable bodies are kicked with
export var KICK_FORCE = Vector2(100.0, 100.0)

# Force max kick velocity
export var MAX_VELOCITY = Vector2(400.0, 400.0)

# Max force
export var MAX_FORCE = Vector2(120.0, 120.0)

# Selectable or normal selectable
onready var selectable = $Sprite

var disable_position: Vector2 = Vector2.ZERO
var disabled = false
var held = false

signal picked

func _ready() -> void:
	assert(is_in_group("pickable"))
	assert(selectable.is_in_group("selectable") or selectable.is_in_group("random_child"))
	
	selectable.connect("selected", self, "_on_sprite_selected")

func _on_sprite_selected():
	emit_signal("picked", self)

func _physics_process(_delta: float) -> void:
	if disabled:
		position = disable_position
		mode = RigidBody2D.MODE_STATIC
		sleeping = true
		
		return
	
	if not held:
		return
	
	var position_diff = VirtualInput.get_world_mouse_position() - global_position
	var grab_force = position_diff.normalized() * GRAB_FORCE
	
	if abs(linear_velocity.x) < MAX_VELOCITY.x and abs(linear_velocity.y) < MAX_VELOCITY.y :
		apply_force(grab_force)

func apply_force(force: Vector2) -> void:
	if force < MAX_FORCE and linear_velocity < MAX_VELOCITY:
		apply_central_impulse(force)

func pickup() -> void:
	if held or disabled:
		return
	
	held = true

func drop(impulse: Vector2 = Vector2.ZERO) -> void:
	if not held:
		return
	
	apply_force(impulse)
	
	held = false

func disable() -> void:
	disable_position = position
	
	disabled = true
	held = false
	
	selectable.disable()
