extends Node

signal current_changed

var current: GameCamera = null

const debug_camera_wait_before_create: float = 0.5
const debug_camera_zoom: Vector2 = Vector2(2.0, 2.0)

func _ready() -> void:
	yield(Tools.timer(debug_camera_wait_before_create), "timeout")
	
	if Config.DEBUG and not current:
		create_debug_camera()

func create_debug_camera() -> void:
	var camera = GameCamera.new()
	
	camera.zoom = Vector2(debug_camera_zoom)
	camera.current = true
	
	var root = get_tree().get_root()
	
	root.add_child(camera)
	CursorManager.show()
	Tools.debug("Debug camera was created")

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
	
	Tools.destroy_node(current)
	
	current = null
