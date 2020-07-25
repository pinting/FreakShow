extends "res://Objects/Selectable/Selectable.gd"

export var MAX = 100
export var STEP = 35

var count = 35

func _ready():
	assert(STEP > 0)
	connect("selected", self, "_on_selected")

func _on_selected():
	count += STEP
	
	material.set_shader_param("amount", count)
	
	if count >= MAX:
		get_parent().remove_child(self)
