extends Sprite

func _process(delta):
	var camera = Global.current_camera
	
	if(camera == null):
		return
	
	position = camera.get_camera_screen_center()
