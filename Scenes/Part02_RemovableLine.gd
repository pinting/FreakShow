extends "res://Objects/Selectable/Selectable.gd"

# After how large value the line should disappear
export var limit: int = 10

# Size of one step
export var step: int = 9

# Initial value
export var start: int = 1

var current: int = start

func _ready():
	assert(step > 0)
	connect("selected", self, "_on_selected")
	material.set_shader_param("amount", current)

func _on_selected():
	if step <= 0:
		return
	
	current += step
	
	material.set_shader_param("amount", current)
	
	if current >= limit:
		remove()

func remove():
	get_parent().remove_child(self)
