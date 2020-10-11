extends "res://Objects/Selectable/Selectable.gd"

export var limit: int = 10
export var step: int = 9
export var start: int = 1

var current: int = 0

func _ready() -> void:
	connect("selected", self, "_on_selected")
	
	current = start

func _process(delta: float) -> void:
	material.set_shader_param("amount", current)

func _on_selected() -> void:
	if step <= 0:
		return
	
	current += step
	
	if current >= limit:
		remove()

func remove() -> void:
	get_parent().remove_child(self)
	remove_description()
