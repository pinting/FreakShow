class_name Pickable
extends RigidBody2D

# Force the body can be grabbed
export var grab_force = Vector2(10.0, 10.0)

# How far from the cursor grabbing force is applied
onready var grab_distance: float = 40.0

# Force max kick velocity
export var max_velocity: Vector2 = Vector2(400.0, 400.0)

# Disable at init
export var disable_at_init: bool = false

# Disable shapes when disabled
export var disable_with_shapes: bool = true

onready var selectable = $Selectable

var disabled: bool = false

var trigger_reset: bool = false
var reset_rotation: float = 0.0;
var reset_position: Vector2 = Vector2.ZERO
var reset_velocity: bool = true
var reset_relative: bool = true

signal picked(pickable)
signal dropped(pickable)

func _ready() -> void:
	assert(is_in_group("pickable"), "Pickable not in group of 'pickable'")
	assert(selectable.is_in_group("selectable"), "Selectable not in group of 'selectable'")
	
	selectable.connect("selected", self, "hold")
	
	if disable_at_init:
		disable()

func is_held() -> bool:
	return PickableManager.is_held(self)

func _integrate_forces(state):
	if state.linear_velocity.abs() > max_velocity:
		state.linear_velocity = state.linear_velocity.normalized() * max_velocity
	
	if trigger_reset:
		if reset_velocity:
			state.linear_velocity = Vector2.ZERO
		
		if not reset_relative:
			state.transform = Transform2D(reset_rotation, reset_position)
		else:
			var new_rotation = state.transform.get_rotation() + reset_rotation
			var new_position = state.transform.get_origin() + reset_position

			state.transform = Transform2D(new_rotation, new_position)
		
		trigger_reset = false
	
	if disabled:
		state.linear_velocity = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	if disabled:
		sleeping = true
		return
	
	if not is_held():
		reset_cursor()
		return
	
	set_cursor()
	
	var to = CursorManager.get_position()
	var from = global_position
	var direction = from.direction_to(to)
	var distance = from.distance_to(to)
	
	if distance > grab_distance:
		apply_central_impulse(direction * grab_force)
	else:
		sleeping = true

func reset(position: Vector2, rotation = 0.0, reset_v = true, relative = false):
	reset_position = position
	reset_rotation = rotation
	reset_velocity = reset_v
	reset_relative = relative
	trigger_reset = true
	
	while trigger_reset:
		yield(Tools.wait(0.1), "completed")

func push(direction: Vector2 = Vector2.ZERO) -> void:
	if is_held() or disabled:
		return
	
	apply_central_impulse(direction)

func drop(impulse: Vector2 = Vector2.ZERO) -> void:
	if not is_held():
		return
	
	selectable.lock = false
	
	apply_central_impulse(impulse)
	
	PickableManager.drop(self)
	emit_signal("dropped", self)

func hold() -> void:
	if is_held() or disabled:
		return
	
	selectable.lock = true
	
	PickableManager.pick(self)
	emit_signal("picked", self)

func disable() -> void:
	PickableManager.drop(self)
	
	disabled = true
	mode = RigidBody2D.MODE_STATIC
	
	if disable_with_shapes:
		Tools.set_shapes_disabled(self, true)
	
	selectable.disable()
	reset_cursor()

func enable() -> void:
	disabled = false
	mode = RigidBody2D.MODE_RIGID
	
	if disable_with_shapes:
		Tools.set_shapes_disabled(self, false)
	
	selectable.enable()

func hide() -> void:
	yield(selectable.hide(), "completed")
	drop()

func show() -> void:
	yield(selectable.show(), "completed")

func create_clone() -> Pickable:
	var clone = self.duplicate()
	
	clone.selectable = self.selectable.duplicate()
	
	for child in clone.get_children():
		if child.is_in_group("no_dupe"):
			Tools.destroy_node(child)
	
	return clone

func set_cursor() -> void:
	CursorManager.set_icon("pick", selectable.get_instance_id())

func reset_cursor() -> void:
	CursorManager.reset_icon(selectable.get_instance_id())

func _exit_tree():
	reset_cursor()
