extends Sprite

func _process(_delta):
	var camera = Global.current_camera
	
	if camera == null:
		return
	
	position = camera.get_camera_screen_center()
