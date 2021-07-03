extends ColorRect

export var speed_div: Vector2 = Vector2(6666.0, 6666.0)
export var fog_color: Color = Color(1.0, 1.0, 0.6, 0.3)

func _ready() -> void:
	material.set_shader_param("color", fog_color)

func _process(_delta: float) -> void:
	var camera = CameraManager.current

	if camera:
		var offset = camera.scrolling_vector / speed_div
		
		material.set_shader_param("offset", offset)
