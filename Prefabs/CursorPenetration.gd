extends ColorRect

# Strength of the effect
export var strength: float = 0.1

# Scale the size of the canvas by this value
export var canvas_size_scale: float = 2.0

func _ready():
	CameraManager.connect("current_changed", self, "_on_camera_changed")

func _on_camera_changed() -> void:
	var camera = CameraManager.current
	
	assert(camera, "Camera is not registered")
	
	var project_size = VirtualInput.get_project_size()
	var actual_size = project_size * camera.zoom * canvas_size_scale
	
	rect_position = actual_size / -4
	rect_size = actual_size / 2

func _process(_delta: float) -> void:
	if VirtualCursorManager.is_hidden():
		material.set_shader_param("value", 0)
		return
	
	var position = VirtualCursorManager.get_viewport_cursor_position()
	var size = VirtualInput.get_project_size()
	var offset = position / size
	
	offset.y = 1.0 - offset.y
	
	material.set_shader_param("value", strength)
	material.set_shader_param("offset", offset)
