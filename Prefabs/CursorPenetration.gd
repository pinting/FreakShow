extends CanvasLayer

# Strength of the effect
@export var strength: float = 0.1

@onready var color_rect: ColorRect = $ColorRect

var is_hidden: bool = true

func _ready() -> void:
	_set_effect(0.0)

func _set_effect(value: float) -> void:
	color_rect.material.set_shader_parameter("value", value)

func appear(duration: float = 0.5) -> void:
	if not is_hidden:
		return
	
	is_hidden = false
	
	await Animator.run(self, "_set_effect", 0.0, strength, duration)

func disappear(duration: float = 0.5) -> void:
	if is_hidden:
		return
	
	is_hidden = true
	
	await Animator.run(self, "_set_effect", strength, 0.0, duration)

func _process(_delta: float) -> void:
	if CursorManager.is_hidden():
		disappear()
		return
	
	var position = CursorManager.get_position(true)
	var size = VirtualInput.get_project_size()
	var effect_offset = position / size
	
	color_rect.material.set_shader_parameter("offset", effect_offset)
	
	appear()
