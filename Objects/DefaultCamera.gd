extends Camera2D

var ZOOM = Vector2(3.5, 3.5)

func _ready():
	var resolution = Vector2(OS.get_window_size().x, OS.get_window_size().y)
	
	zoom = (resolution / Vector2(1920, 1080)) * ZOOM
