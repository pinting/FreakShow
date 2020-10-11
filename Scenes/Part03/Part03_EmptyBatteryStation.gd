extends Sprite

onready var area = $Area2D

signal battery_inside

var inside: Node = null

func _ready() -> void:
	area.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body: Node):
	if not body.is_in_group("battery") or not body.is_in_group("pickable"):
		return
	
	inside = body
	
	_process_inside()
	emit_signal("battery_inside")

func _process_inside() -> void:
	if not inside:
		return
	
	inside.mode = RigidBody2D.MODE_STATIC
	inside.sleeping = true
	inside.global_position = global_position
	inside.rotation_degrees = rotation_degrees - fmod(rotation_degrees, 90.0)
	
	inside.disable()

func _process(delta: float) -> void:
	_process_inside()
