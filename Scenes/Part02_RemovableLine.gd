extends "res://Objects/Selectable/Selectable.gd"

# After how large value the line should disappear
export var LIMIT: int = 10

# Size of one step
export var STEP: int = 1

# Initial value
export var START: int = 0

var current: int = START

func _ready():
	assert(STEP > 0)
	connect("selected", self, "_on_selected")
	material.set_shader_param("amount", current)

func _on_selected():
	current += STEP
	
	material.set_shader_param("amount", current)
	
	if current >= LIMIT:
		get_parent().remove_child(self)
