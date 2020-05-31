extends Camera2D

var default_size = OS.get_window_size()
var previous_size = OS.get_window_size()
var ignore_y = false
var ignore_x = false

func _ready():
	pass

func _on_Camera2D_draw():
	zoom = (Global.RESOLUTION / OS.get_window_size()) * Global.CAMERA_ZOOM
 
func _process(delta):
	if is_current():
		Global.current_camera = self
		
	var current_size = OS.get_window_size()
	var new_scale = current_size / default_size
	var position = OS.get_window_position()
   
	if current_size.x != previous_size.x && not ignore_x:
		OS.set_window_size(Vector2(current_size.x, default_size.y * new_scale.x))
		ignore_y = true
	elif current_size.x == previous_size.x && ignore_x:
		ignore_x = false
   
	if current_size.y != previous_size.y && not ignore_y:
		OS.set_window_size(Vector2(default_size.x * new_scale.y, current_size.y))
		ignore_x = true
	elif current_size.y == previous_size.y && ignore_y:
		ignore_y = false
   
	if position.y < 0:
		OS.set_window_position(Vector2(position.x, 0))
   
	if current_size < default_size:
		OS.set_window_size(default_size)
   
	previous_size = current_size
