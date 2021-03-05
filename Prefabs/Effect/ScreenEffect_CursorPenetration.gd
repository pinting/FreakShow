extends CanvasLayer

export var strength: float = 0.1

onready var canvas = $Canvas

func _ready():
	canvas.visible = true

func _process(_delta: float) -> void:
	if Cursor.is_hidden:
		canvas.material.set_shader_param("value", 0)
		return
	
	var position = VirtualInput.virtual_mouse_position
	var size = VirtualInput.get_project_size()
	
	canvas.material.set_shader_param("value", strength)
	canvas.material.set_shader_param("offset", position / size)
