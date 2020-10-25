extends Sprite

onready var inside = $Inside

signal battery_inside

var inside_body: Node = null

func _ready() -> void:
	inside.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body: Node):
	if inside_body or not body.is_in_group("battery") :
		return
	
	body.rotation_degrees = rotation_degrees - fmod(rotation_degrees, 90.0)
	body.global_position = inside.global_position
	
	body.disable()
	
	inside_body = body
	
	emit_signal("battery_inside")
