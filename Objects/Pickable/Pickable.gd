extends RigidBody2D

# Force the body can be grabbed
export var GRAB_FORCE = Vector2(5, 5)

# Force kickable bodies are kicked with
export var KICK_FORCE = Vector2(100, 100)

# Force max kick velocity
export var MAX_VELOCITY = Vector2(400, 400)

signal clicked

var picked_up = false

func _input_event(viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("clicked", self)

func _physics_process(_delta):
	if picked_up:
		var position_diff = get_global_mouse_position() - get_global_position()
		var grab_force = position_diff.normalized() * GRAB_FORCE
		
		if abs(linear_velocity.x) < MAX_VELOCITY.x and abs(linear_velocity.y) < MAX_VELOCITY.y :
			apply_central_impulse(grab_force)


func pickup():
	if picked_up:
		return
	
	picked_up = true

func drop(impulse = Vector2.ZERO):
	if not picked_up:
		return
	
	apply_central_impulse(impulse)
	
	picked_up = false
