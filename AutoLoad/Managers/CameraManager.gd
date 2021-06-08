extends Node

signal current_changed

var current: GameCamera = null

func set_current(camera: GameCamera) -> void:
	# Check if the custom GameCamera is used
	assert(camera is GameCamera, "Only GameCamera is supported.")
	
	current = camera
	
	Tools.debug("Current camera changed")
	emit_signal("current_changed")

func clear() -> void:
	if not current:
		Tools.debug("Current GameCamera not exists, but clear was called")
		return
	
	Tools.destroy(current)
	
	current = null
