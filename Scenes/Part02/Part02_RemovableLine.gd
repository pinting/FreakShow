extends "res://Objects/Selectable/Selectable.gd"

onready var body = $Body
onready var boss_detector = $BossDetector

export var limit: int = 10
export var step: int = 9
export var start: int = 1

var amount: int = 0

func _ready() -> void:
	connect("selected", self, "_on_selected")
	boss_detector.connect("body_entered", self, "_on_boss_collide")
	
	amount = start

func _on_boss_collide(body: Node) -> void:
	if body.is_in_group("boss"):
		remove()

func _process(delta: float) -> void:
	material.set_shader_param("amount", amount)

func _on_selected() -> void:
	if step <= 0:
		return
	
	amount += step
	
	if amount >= limit:
		remove()

func remove() -> void:
	Tools.set_shapes_disabled(body, true)
	Tools.set_shapes_disabled(boss_detector, true)
	
	get_parent().remove_child(self)
	remove_description()
	queue_free()
