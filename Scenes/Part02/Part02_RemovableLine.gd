extends "res://Objects/Selectable/Selectable.gd"

onready var body_collision_shape = $Body/CollisionShape
onready var boss_detector_collision_shape = $Body/CollisionShape
onready var boss_detector = $BossDetector

export var limit: int = 10
export var step: int = 9
export var start: int = 1

var current: int = 0

func _ready() -> void:
	connect("selected", self, "_on_selected")
	boss_detector.connect("body_entered", self, "_on_boss_collide")
	
	current = start

func _on_boss_collide(body: Node) -> void:
	if body.is_in_group("boss"):
		remove()

func _process(delta: float) -> void:
	material.set_shader_param("amount", current)

func _on_selected() -> void:
	if step <= 0:
		return
	
	current += step
	
	if current >= limit:
		remove()

func remove() -> void:
	body_collision_shape.disabled = true
	boss_detector_collision_shape.disabled = true
	
	get_parent().remove_child(self)
	remove_description()
	queue_free()
