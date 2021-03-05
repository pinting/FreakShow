extends RigidBody2D

# Force the body can be grabbed
export var grab_force = Vector2(10.0, 10.0)

# How far from the cursor grabbing force is applied
onready var grab_distance: float = 40.0

# Force max kick velocity
export var max_velocity = Vector2(400.0, 400.0)

# Selectable Sprite
onready var selectable = $Selectable

var disabled: bool = false
var held: bool = false

var trigger_reset: bool = false
var start_angle: float = 0.0;
var start_position: Vector2 = Vector2.ZERO

signal picked

func _ready() -> void:
	assert(is_in_group("pickable"))
	assert(selectable.is_in_group("selectable") or selectable.is_in_group("random_child"))
	
	selectable.connect("selected", self, "_on_sprite_selected")

func _on_sprite_selected():
	emit_signal("picked", self)

func _integrate_forces(state):
	if state.linear_velocity.abs() > max_velocity:
		state.linear_velocity = state.linear_velocity.normalized() * max_velocity
	
	if trigger_reset:
		state.transform = Transform2D(start_angle, start_position)
		state.linear_velocity = Vector2.ZERO
		trigger_reset = false
	
	if disabled:
		state.linear_velocity = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	if disabled:
		mode = RigidBody2D.MODE_STATIC
		sleeping = true
		return
	
	if not held:
		_reset_cursor()
		return
	
	_set_cursor()
	
	var to = VirtualInput.get_world_mouse_position()
	var from = global_position
	var direction = from.direction_to(to)
	var distance = from.distance_to(to)
	
	if distance > grab_distance:
		apply_central_impulse(direction * grab_force)
	else:
		sleeping = true

func reset(new_position: Vector2, new_angle: float = 0.0):
	global_position = new_position
	start_position = new_position
	start_angle = new_angle
	trigger_reset = true

func push(direction: Vector2 = Vector2.ZERO) -> void:
	if held or disabled:
		return
	
	apply_central_impulse(direction)

func drop(impulse: Vector2 = Vector2.ZERO) -> void:
	if not held:
		return
	
	held = false
	
	apply_central_impulse(impulse)
	selectable.drop()

func hold() -> void:
	if held or disabled:
		return
	
	held = true

	selectable.hold()

func disable() -> void:
	disabled = true
	held = false
	
	selectable.disable()
	_reset_cursor()

func destroy() -> void:
	_reset_cursor()
	get_parent().remove_child(self)
	queue_free()

func _set_cursor() -> void:
	Cursor.set_icon("pick", selectable.get_instance_id())

func _reset_cursor() -> void:
	Cursor.reset_icon(selectable.get_instance_id())
