extends RigidBody2D

signal clicked

var held = false

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("clicked", self)

func _physics_process(_delta):
	if held:
		apply_central_impulse(get_global_mouse_position() - position)


func pickup():
	if held:
		return
	
	held = true

func drop(impulse = Vector2.ZERO):
	if not held:
		return
	
	apply_central_impulse(impulse)
	
	held = false
