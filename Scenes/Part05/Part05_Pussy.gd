extends "res://Objects/Selectable/Selectable.gd"

onready var area = $Area2D
onready var area_collision_shape = $Area2D/CollisionShape
onready var filled = $Filled
onready var light = $Light

signal dildo_inside

func _ready() -> void:
	area.connect("body_entered", self, "_on_body_entered")
	
	visible = false

func _on_body_entered(body: Node):
	if not body.is_in_group("dildo"):
		return
	
	body.get_parent().remove_child(body)
	body.queue_free()
	
	filled.visible = true
	light.visible = false
	
	emit_signal("dildo_inside")

func enable():
	area_collision_shape.disabled = false
	visible = true
