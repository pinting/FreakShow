extends CanvasLayer

export var speed_div: Vector2 = Vector2(6666.0, 6666.0)
export var color: Color = Color(1.0, 1.0, 0.6, 0.3)

onready var canvas = $Canvas

func _ready() -> void:
	canvas.visible = true
	canvas.material.set_shader_param("color", color)

func _process(_delta: float) -> void:
	var camera = Game.current_camera

	if camera:
		var offset = camera.scrolling_vector / speed_div
		
		canvas.material.set_shader_param("offset", offset)
