extends CanvasLayer

# Strength of the effect
export var strength: float = 0.1

onready var color_rect: ColorRect = $ColorRect

var is_hidden: bool = true

func _ready() -> void:
	_set_effect(0.0)

func _set_effect(value: float) -> void:
	color_rect.material.set_shader_param("value", value)

func show(duration: float = 0.5) -> void:
	if not is_hidden:
		return
	
	is_hidden = false
	
	yield(Animator.run(self, "_set_effect", 
		0.0, strength, duration), "completed")

func hide(duration: float = 0.5) -> void:
	if is_hidden:
		return
	
	is_hidden = true
	
	yield(Animator.run(self, "_set_effect",
		strength, 0.0, duration), "completed")

func _process(_delta: float) -> void:
	if CursorManager.is_hidden():
		hide()
		return
	
	var position = CursorManager.get_position(true)
	var size = VirtualInput.get_project_size()
	var offset = position / size
	
	offset.y = 1.0 - offset.y
	
	color_rect.material.set_shader_param("offset", offset)
	show()
