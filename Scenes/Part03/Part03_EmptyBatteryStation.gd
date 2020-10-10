extends Sprite

onready var area = $Area2D

signal battery_inside

func _ready():
	area.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body: Node):
	if not body.is_in_group("battery") or not body.is_in_group("pickable"):
		return
	
	body.mode = RigidBody2D.MODE_STATIC
	body.sleeping = true
	body.global_position = global_position
	body.rotation_degrees = rotation_degrees - fmod(rotation_degrees, 90.0)
	
	body.disable()
	
	emit_signal("battery_inside")
