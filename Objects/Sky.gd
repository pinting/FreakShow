extends Sprite

func _process(delta: float):
	_process_position(delta)

func _process_position(_delta: float):
	var camera = Global.current_camera
	
	if not camera:
		return
	
	position = camera.get_camera_screen_center()
