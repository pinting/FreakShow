extends Sprite

onready var area = $Area2D

signal battery_inside

var inside: Node = null

func _ready() -> void:
	area.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body: Node):
	if not inside or not body.is_in_group("battery") or not body.is_in_group("pickable"):
		return
	
	inside.rotation_degrees = rotation_degrees - fmod(rotation_degrees, 90.0)
	inside = body
	
	emit_signal("battery_inside")
