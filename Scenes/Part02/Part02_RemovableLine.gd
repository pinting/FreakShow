extends "res://Objects/Selectable/Selectable.gd"

# After how large value the line should disappear
export var limit: int = 10

# Size of one step
export var step: int = 9

# Initial value
export var start: int = 1

var current: int = 0

func _ready():
	connect("selected", self, "_on_selected")
	
	current = start

func _process(delta):
	material.set_shader_param("amount", current)

func _on_selected():
	if step <= 0:
		return
	
	current += step
	
	if current >= limit:
		remove()

func remove():
	get_parent().remove_child(self)
	remove_description()
